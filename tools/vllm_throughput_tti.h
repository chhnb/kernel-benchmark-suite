#pragma once

#include "decision_speculation_tti.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/IntrinsicInst.h"
#include <type_traits>

namespace decision {
template<class Cost> inline llvm::Optional<int64_t> throughputValue(Cost Value) {
  if constexpr (std::is_integral_v<Cost>)
    return Value >= 0 ? llvm::Optional<int64_t>(Value) : llvm::None;
  else {
    auto CostValue = Value.getValue();
    return CostValue && *CostValue >= 0
               ? llvm::Optional<int64_t>(*CostValue)
               : llvm::None;
  }
}

// Scoped backport of the differing throughput rules observed in cache_eval
// against LLVM 24 revision 6be16f356d3e. Other queries use LLVM 12 TTI.
inline int64_t scoreVllmThroughput(llvm::Function &F, llvm::TargetMachine &Machine) {
  using namespace llvm;
  if (F.getName() != "cache_eval" ||
      F.getParent()->getTargetTriple() != "amdgcn-amd-amdhsa" ||
      F.getFnAttribute("target-cpu").getValueAsString() != "gfx906")
    throw std::runtime_error("LLVM24 vLLM scoring requires gfx906 cache_eval");
  FunctionAnalysisManager Analyses;
  auto TTI = Machine.getTargetIRAnalysis().run(F, Analyses);
  SmallPtrSet<const BasicBlock *, 32> Visited;
  SmallVector<const BasicBlock *, 32> Pending{&F.getEntryBlock()};
  int64_t Total = 0;
  while (!Pending.empty()) {
    auto *Block = Pending.pop_back_val();
    if (!Visited.insert(Block).second)
      continue;
    for (const auto &Inst : *Block) {
      if (isa<DbgInfoIntrinsic, FreezeInst, AllocaInst>(Inst))
        continue;
      if (auto *Branch = dyn_cast<BranchInst>(&Inst)) {
        Total += Branch->isConditional() ? 7 : 4;
        continue;
      }
      if (auto *Call = dyn_cast<CallBase>(&Inst)) {
        auto *Callee = Call->getCalledFunction();
        if (!Callee || !Callee->isIntrinsic())
          throw std::runtime_error("opaque call in LLVM24 vLLM scoring");
        auto Name = Callee->getName();
        if (Name == "llvm.amdgcn.workgroup.id.x" ||
            Name == "llvm.amdgcn.workitem.id.x" ||
            Name == "llvm.amdgcn.dispatch.ptr")
          continue;
      }
      auto Value = throughputValue(
          TTI.getInstructionCost(&Inst, TargetTransformInfo::TCK_RecipThroughput));
      if (!Value)
        throw std::runtime_error("unknown instruction cost in LLVM24 vLLM scoring");
      Total += *Value;
    }
    for (auto *Next : successors(Block))
      Pending.push_back(Next);
  }
  return Total;
}
} // namespace decision
