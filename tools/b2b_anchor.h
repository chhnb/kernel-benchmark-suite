#pragma once

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
  unsigned anchors = 0, discarded = 0, conflicts = 0, segments = 0, pruned = 0;
};
llvm::SmallVector<AnchorPlan, 4> planB2BAnchors(
    llvm::ArrayRef<llvm::Instruction *> left,
    llvm::ArrayRef<llvm::Instruction *> right,
    llvm::BasicBlock &leftBlock, llvm::BasicBlock &rightBlock, llvm::BasicBlock *join,
    llvm::function_ref<bool(llvm::Instruction &, llvm::Instruction &)> compatible,
    llvm::function_ref<int(const llvm::Instruction &)> instructionCost,
    llvm::function_ref<int(llvm::Type *)> selectCost);
}
