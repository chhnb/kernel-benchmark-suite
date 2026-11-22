#pragma once

#include "llvm/IR/Instructions.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/IR/Module.h"

namespace fusion {
namespace anchor_condition {
inline bool isKernel(const llvm::Function &f) {
  using namespace llvm;
  if (f.getCallingConv() == CallingConv::AMDGPU_KERNEL ||
      f.getCallingConv() == CallingConv::PTX_Kernel ||
      f.getCallingConv() == CallingConv::SPIR_KERNEL)
    return true;
  if (auto *annotations = f.getParent()->getNamedMetadata("nvvm.annotations"))
    for (auto *entry : annotations->operands()) {
      if (entry->getNumOperands() < 3) continue;
      auto *function = dyn_cast_or_null<ValueAsMetadata>(entry->getOperand(0));
      auto *key = dyn_cast_or_null<MDString>(entry->getOperand(1));
      auto *enabled = mdconst::dyn_extract<ConstantInt>(entry->getOperand(2));
      if (function && function->getValue() == &f && key &&
          key->getString() == "kernel" && enabled && enabled->isOne())
        return true;
    }
  return false;
}

inline llvm::StringRef classifySource(const llvm::BranchInst *branch) {
  using namespace llvm;
  if (!branch || !branch->isConditional()) return "data";
  SmallPtrSet<const Value *, 16> visited;
  SmallVector<const Value *, 16> pending{branch->getCondition()};
  bool workitem = false;
  const bool kernel = isKernel(*branch->getFunction());
  auto dimension = [](StringRef name, StringRef prefix) {
    return name.consume_front(prefix) && name.size() == 1 &&
           StringRef("xyz").contains(name.front());
  };
  while (!pending.empty()) {
    const auto *value = pending.pop_back_val();
    if (!visited.insert(value).second) continue;
    if (isa<UndefValue>(value)) return "data";
    if (isa<Argument>(value)) {
      if (!kernel) return "data";
      continue;
    }
    if (isa<GlobalValue>(value)) continue;
    const auto *user = dyn_cast<User>(value);
    if (const auto *call = dyn_cast<CallInst>(value)) {
      const auto *callee = call->getCalledFunction();
      if (!callee || !callee->isIntrinsic()) return "data";
      const auto name = callee->getName();
      if (dimension(name, "llvm.amdgcn.workitem.id.") ||
          dimension(name, "llvm.nvvm.read.ptx.sreg.tid.")) {
        workitem = true;
        continue;
      }
      if (dimension(name, "llvm.amdgcn.workgroup.id.") ||
          dimension(name, "llvm.nvvm.read.ptx.sreg.ctaid.") ||
          dimension(name, "llvm.nvvm.read.ptx.sreg.ntid.") ||
          dimension(name, "llvm.nvvm.read.ptx.sreg.nctaid.") ||
          name == "llvm.amdgcn.dispatch.ptr" || name == "llvm.amdgcn.kernarg.segment.ptr" ||
          name == "llvm.amdgcn.implicitarg.ptr" || name == "llvm.amdgcn.queue.ptr")
        continue;
      // Target intrinsics can read lane state implicitly, even with no memory effects.
      if (callee->isTargetIntrinsic() || call->isConvergent() ||
          !call->doesNotAccessMemory() || !isSafeToSpeculativelyExecute(call))
        return "data";
      for (const auto &arg : call->args()) pending.push_back(arg.get());
      continue;
    }
    if (!isa<Constant>(value) && !isa<BinaryOperator>(value) && !isa<CmpInst>(value) &&
        !isa<SelectInst>(value) && !isa<CastInst>(value) && !isa<GetElementPtrInst>(value) &&
        !isa<ExtractElementInst>(value) && !isa<InsertElementInst>(value) &&
        !isa<ShuffleVectorInst>(value) && !isa<ExtractValueInst>(value) &&
        !isa<InsertValueInst>(value) &&
        !(isa<FreezeInst>(value) &&
          isGuaranteedNotToBeUndefOrPoison(user->getOperand(0))))
      return "data";
    for (const auto &operand : user->operands()) pending.push_back(operand.get());
  }
  return workitem ? "thread-pattern" : "workgroup-uniform";
}

inline const llvm::BranchInst *findBranch(const llvm::Function &f, llvm::StringRef split) {
  unsigned index;
  if (!split.consume_front("B") || split.getAsInteger(10, index) || index >= f.size())
    return nullptr;
  return llvm::dyn_cast<llvm::BranchInst>(std::next(f.begin(), index)->getTerminator());
}

} // namespace anchor_condition
} // namespace fusion
