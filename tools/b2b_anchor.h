#pragma once

#include <cstdint>

#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallVector.h"

namespace llvm {
class BasicBlock;
class Instruction;
class Type;
}
namespace fusion {
struct AnchorMatch {
  unsigned left, right;
  bool swapped = false;
  bool operator==(const AnchorMatch &other) const {
    return left == other.left && right == other.right && swapped == other.swapped;
  }
};
struct AnchorPlan {
  llvm::SmallVector<AnchorMatch, 8> matches;
  llvm::SmallVector<AnchorMatch, 8> anchors;
  llvm::SmallVector<AnchorMatch, 8> cutoffs;
  llvm::SmallVector<AnchorMatch, 8> forwardCutoffs;
  unsigned chargedSegments = 0;
  int64_t phiCharge = 0;
  unsigned discarded = 0, conflicts = 0, segments = 0;
};
llvm::SmallVector<AnchorPlan, 3> planB2BAnchors(
    llvm::ArrayRef<llvm::Instruction *> left,
    llvm::ArrayRef<llvm::Instruction *> right,
    llvm::BasicBlock &leftBlock, llvm::BasicBlock &rightBlock, llvm::BasicBlock *join, bool pairTies,
    llvm::function_ref<bool(llvm::Instruction &, llvm::Instruction &)> compatible,
    llvm::function_ref<int(const llvm::Instruction &)> instructionCost,
    llvm::function_ref<int(llvm::Type *)> selectCost,
    llvm::function_ref<int(llvm::Type *)> phiCost);
}
