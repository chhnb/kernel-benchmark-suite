#pragma once
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/IR/Instructions.h"
namespace llvm {
inline unsigned speculationWeight(const Instruction &I) {
  switch (I.getOpcode()) {
  case Instruction::FDiv: case Instruction::FRem:
  case Instruction::SDiv: case Instruction::UDiv:
  case Instruction::SRem: case Instruction::URem:
    return 8;
  default:
    return isa<CallBase>(I) ? 4 : 1;
  }
}

inline bool safeToSpeculate(const Instruction &I) {
  if (I.mayReadOrWriteMemory() || I.mayHaveSideEffects())
    return false;
  // isSafeToSpeculativelyExecute ignores convergence; a convergent operation
  // run under a different set of active lanes changes its meaning.
  if (auto *CB = dyn_cast<CallBase>(&I))
    if (CB->isConvergent())
      return false;
  return isSafeToSpeculativelyExecute(&I);
}

}
