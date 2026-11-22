#pragma once

#include "llvm/IR/Instructions.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/JSON.h"
#include "llvm/ADT/Triple.h"
#include <array>
#include <optional>

namespace fusion {
namespace wave_diagnostic {
using Shape = std::array<unsigned, 3>;

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

inline std::optional<llvm::APInt> evaluate(const llvm::Value *v, const Shape &ids,
                                          bool amd, unsigned depth = 0) {
  using namespace llvm;
  if (depth >= 32 || !v->getType()->isIntegerTy()) return std::nullopt;
  if (const auto *n = dyn_cast<ConstantInt>(v)) return n->getValue();
  if (const auto *call = dyn_cast<CallInst>(v)) {
    const auto *callee = call->getCalledFunction();
    if (!callee || !callee->isIntrinsic()) return std::nullopt;
    auto symbol = callee->getName();
    auto prefix = amd ? "llvm.amdgcn.workitem.id." : "llvm.nvvm.read.ptx.sreg.tid.";
    if (!symbol.consume_front(prefix) || symbol.size() != 1) return std::nullopt;
    auto dimension = StringRef("xyz").find(symbol.front());
    if (dimension >= ids.size()) return std::nullopt;
    APInt id(v->getType()->getIntegerBitWidth(), ids[dimension]);
    if (const auto *range = call->getMetadata(LLVMContext::MD_range)) {
      if (range->getNumOperands() != 2) return std::nullopt;
      const auto *low = mdconst::dyn_extract<ConstantInt>(range->getOperand(0));
      const auto *high = mdconst::dyn_extract<ConstantInt>(range->getOperand(1));
      if (!low || !high || low->getBitWidth() != id.getBitWidth() ||
          high->getBitWidth() != id.getBitWidth() || id.ult(low->getValue()) ||
          id.uge(high->getValue()))
        return std::nullopt;
    }
    return id;
  }
  const auto *inst = dyn_cast<Instruction>(v);
  if (!inst) return std::nullopt;
  auto operand = [&](unsigned i) { return evaluate(inst->getOperand(i), ids, amd, depth + 1); };
  if (isa<FreezeInst>(inst)) return operand(0);
  if (const auto *cast = dyn_cast<CastInst>(inst)) {
    const auto input = operand(0);
    if (!input) return std::nullopt;
    unsigned bits = cast->getType()->getIntegerBitWidth();
    if (isa<TruncInst>(cast)) return input->trunc(bits);
    if (isa<SExtInst>(cast)) return input->sext(bits);
    if (isa<ZExtInst>(cast)) return input->zext(bits);
    return std::nullopt;
  }
  if (isa<SelectInst>(inst)) {
    auto cond = operand(0), lhs = operand(1), rhs = operand(2);
    if (!cond || !lhs || !rhs) return std::nullopt;
    return *cond == 0 ? rhs : lhs;
  }
  const auto *operation = dyn_cast<BinaryOperator>(inst);
  const auto *compare = dyn_cast<ICmpInst>(inst);
  if (!operation && !compare) return std::nullopt;
  auto lhs = operand(0), rhs = operand(1);
  if (!lhs || !rhs || lhs->getBitWidth() != rhs->getBitWidth()) return std::nullopt;
  if (compare) {
    switch (compare->getPredicate()) {
    case ICmpInst::ICMP_EQ: return APInt(1, *lhs == *rhs);
    case ICmpInst::ICMP_NE: return APInt(1, *lhs != *rhs);
    case ICmpInst::ICMP_UGT: return APInt(1, lhs->ugt(*rhs));
    case ICmpInst::ICMP_UGE: return APInt(1, lhs->uge(*rhs));
    case ICmpInst::ICMP_ULT: return APInt(1, lhs->ult(*rhs));
    case ICmpInst::ICMP_ULE: return APInt(1, lhs->ule(*rhs));
    case ICmpInst::ICMP_SGT: return APInt(1, lhs->sgt(*rhs));
    case ICmpInst::ICMP_SGE: return APInt(1, lhs->sge(*rhs));
    case ICmpInst::ICMP_SLT: return APInt(1, lhs->slt(*rhs));
    case ICmpInst::ICMP_SLE: return APInt(1, lhs->sle(*rhs));
    default: return std::nullopt;
    }
  }
  bool signedOverflow = false, unsignedOverflow = false;
  APInt result;
  switch (operation->getOpcode()) {
  case Instruction::Add:
    result = lhs->sadd_ov(*rhs, signedOverflow);
    lhs->uadd_ov(*rhs, unsignedOverflow);
    break;
  case Instruction::Sub:
    result = lhs->ssub_ov(*rhs, signedOverflow);
    lhs->usub_ov(*rhs, unsignedOverflow);
    break;
  case Instruction::Mul:
    result = lhs->smul_ov(*rhs, signedOverflow);
    lhs->umul_ov(*rhs, unsignedOverflow);
    break;
  case Instruction::And: return *lhs & *rhs;
  case Instruction::Or: return *lhs | *rhs;
  case Instruction::Xor: return *lhs ^ *rhs;
  default: return std::nullopt;
  }
  if ((operation->hasNoSignedWrap() && signedOverflow) ||
      (operation->hasNoUnsignedWrap() && unsignedOverflow))
    return std::nullopt;
  return result;
}

inline const llvm::BranchInst *findBranch(const llvm::Function &f, llvm::StringRef split) {
  unsigned index;
  if (!split.consume_front("B") || split.getAsInteger(10, index) || index >= f.size())
    return nullptr;
  return llvm::dyn_cast<llvm::BranchInst>(std::next(f.begin(), index)->getTerminator());
}

inline bool validShape(const Shape &shape) {
  return llvm::all_of(shape, [](unsigned n) { return n && n <= 1024; }) &&
         shape[0] * shape[1] * shape[2] <= 1024;
}

inline std::optional<Shape> parseShape(llvm::StringRef launch) {
  llvm::SmallVector<llvm::StringRef, 3> dimensions;
  launch.split(dimensions, ',');
  Shape shape{};
  if (dimensions.size() != 3) return std::nullopt;
  for (unsigned i = 0; i != 3; ++i)
    if (dimensions[i].getAsInteger(10, shape[i])) return std::nullopt;
  return validShape(shape) ? std::optional<Shape>(shape) : std::nullopt;
}

inline std::optional<Shape> resolveShape(const llvm::Function &f, llvm::StringRef launch) {
  if (!launch.empty()) return parseShape(launch);
  auto *required = f.getMetadata("reqd_work_group_size");
  if (!required || required->getNumOperands() != 3) return std::nullopt;
  Shape shape{};
  for (unsigned i = 0; i != 3; ++i) {
    const auto *value = llvm::mdconst::dyn_extract<llvm::ConstantInt>(required->getOperand(i));
    if (!value || value->getValue().getActiveBits() > 32) return std::nullopt;
    shape[i] = value->getZExtValue();
  }
  return validShape(shape) ? std::optional<Shape>(shape) : std::nullopt;
}

inline llvm::json::Object classify(const llvm::Function &f, const llvm::BranchInst *branch,
                                   llvm::StringRef launch) {
  using namespace llvm;
  const auto resolved = resolveShape(f, launch);
  const bool exact = bool(resolved);
  const Shape shape = resolved.value_or(Shape{});
  const StringRef source = !exact ? "unavailable" : launch.empty() ? "reqd_work_group_size" : "external_launch";
  const unsigned threads = shape[0] * shape[1] * shape[2];

  Triple triple(f.getParent()->getTargetTriple());
  auto cpu = f.getFnAttribute("target-cpu");
  auto features = f.getFnAttribute("target-features");
  unsigned width = triple.isNVPTX() ? 32 : 0;
  if (triple.isAMDGPU() && cpu.isStringAttribute() && cpu.getValueAsString() == "gfx906" &&
      (!features.isStringAttribute() || !features.getValueAsString().contains("+wavefrontsize32")))
    width = 64;
  json::Object report{{"classification", "unknown"}, {"condition_source", classifySource(branch)},
      {"shape", exact ? json::Value(json::Array{shape[0], shape[1], shape[2]}) : json::Value(nullptr)},
      {"shape_source", exact ? source : "unavailable"},
      {"wave_size", width ? json::Value(width) : json::Value(nullptr)},
      {"total_waves", exact && width ? json::Value((threads + width - 1) / width) : json::Value(nullptr)},
      {"mixed_waves", nullptr}};
  if (!exact || !width || !branch || !branch->isConditional()) {
    report["reason"] = !exact ? "exact_shape_unavailable" :
        !width ? "wave_size_unavailable" : "no_conditional_branch";
    return report;
  }

  unsigned mixed = 0, directions = 0;
  for (unsigned linear = 0; linear != threads; ++linear) {
    Shape ids{linear % shape[0], linear / shape[0] % shape[1], linear / (shape[0] * shape[1])};
    auto value = evaluate(branch->getCondition(), ids, triple.isAMDGPU());
    if (!value) {
      report["reason"] = "condition_not_statically_evaluable";
      return report;
    }
    directions |= *value == 0 ? 1 : 2;
    if ((linear + 1) % width == 0 || linear + 1 == threads) {
      mixed += directions == 3;
      directions = 0;
    }
  }
  report["mixed_waves"] = mixed;
  report["classification"] = mixed == (threads + width - 1) / width ? "must-diverge" :
                             mixed == 0 ? "must-uniform" : "mixed";
  return report;
}
} // namespace wave_diagnostic
} // namespace fusion
