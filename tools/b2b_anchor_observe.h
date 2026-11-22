#pragma once

#include "b2b_anchor.h"
#include "llvm/Support/JSON.h"

namespace fusion {
enum class AnchorInsertion { Duplicate, Pruned, Kept };

struct ObservedAnchorState {
  llvm::ArrayRef<AnchorMatch> pairs;
  int64_t score;
  unsigned chargedSegments;
  int64_t phiCharge;
};

class B2BObservation {
  const char *path;
  llvm::json::Array transitions, pruned, conflictingPairs, segmentsObserved, plans;

public:
  B2BObservation();
  explicit operator bool() const { return path && *path; }

  void conflict(AnchorMatch);
  void prune(ObservedAnchorState, llvm::StringRef phase);
  void evict(ObservedAnchorState, llvm::StringRef phase, unsigned i, unsigned j);
  void segment(unsigned li, unsigned ri, unsigned le, unsigned re, bool rejoins);
  void transition(AnchorMatch, ObservedAnchorState, int cost, int inputs, llvm::StringRef reason);
  void transition(AnchorMatch, ObservedAnchorState, int cost, int inputs, AnchorInsertion);
  void plan(ObservedAnchorState);
  void write(llvm::ArrayRef<llvm::Instruction *> left, llvm::ArrayRef<llvm::Instruction *> right,
             llvm::BasicBlock &leftBlock, llvm::BasicBlock &rightBlock, bool pairTies, bool linear,
             llvm::ArrayRef<AnchorMatch> proposed, llvm::ArrayRef<AnchorMatch> anchors,
             llvm::ArrayRef<AnchorMatch> cutoffs, llvm::ArrayRef<AnchorMatch> forwardCutoffs,
             unsigned conflicts, llvm::function_ref<int(const llvm::Instruction &)> instructionCost,
             llvm::function_ref<int(llvm::Type *)> selectCost,
             llvm::function_ref<int(llvm::Type *)> phiCost,
             llvm::function_ref<bool(unsigned, unsigned)> canSkip);
};
} // namespace fusion
