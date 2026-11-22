#pragma once

#include <cstdint>

#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/SmallVector.h"

namespace llvm {
class BasicBlock;
class Instruction;
class Type;
}
namespace fusion {
enum class AnchorGap { Fork, Linear, Both };

inline bool parseAnchorGap(llvm::StringRef name, AnchorGap &gap) {
  if (name == "fork") gap = AnchorGap::Fork;
  else if (name == "linear") gap = AnchorGap::Linear;
  else if (name == "both") gap = AnchorGap::Both;
  else return false;
  return true;
}

enum class AnchorLinearRequirement { Any, Divergent, DivergentOrUnknown };

struct AnchorScoring {
  bool selectDedup = false;
  bool liveCutoff = false;
  bool eagerGapRank = false;
  bool guardedGap = false;
  AnchorLinearRequirement linearRequirement = AnchorLinearRequirement::Any;
};

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
  int64_t score = 0;
  unsigned discarded = 0, conflicts = 0, segments = 0;
};
// The last simple memory instruction in each instruction's dependency chain
// (including itself), or -1 if it has none. A gap guards only its own roots.
llvm::SmallVector<int, 32> b2bGuardOrigins(llvm::ArrayRef<llvm::Instruction *> work);

llvm::SmallVector<AnchorPlan, 3> planB2BAnchors(
    llvm::ArrayRef<llvm::Instruction *> left,
    llvm::ArrayRef<llvm::Instruction *> right,
    llvm::BasicBlock &leftBlock, llvm::BasicBlock &rightBlock, llvm::BasicBlock *join, bool pairTies,
    llvm::function_ref<bool(llvm::Instruction &, llvm::Instruction &)> compatible,
    llvm::function_ref<int(const llvm::Instruction &)> instructionCost,
    llvm::function_ref<int(llvm::Type *)> selectCost,
    llvm::function_ref<int(llvm::Type *)> phiCost, bool linear = false, AnchorScoring scoring = {});
}
