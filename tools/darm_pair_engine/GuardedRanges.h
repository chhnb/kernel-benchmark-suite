#pragma once
#include "InstructionPolicy.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/Function.h"
#include <vector>
#include <stdexcept>

namespace llvm {
struct GapRange {
  Instruction *Start, *End;
  bool Left;
  GapRange(Instruction *Start, Instruction *End, bool Left)
      : Start(Start), End(End), Left(Left) {}
  Instruction *getStart() const { return Start; }
  Instruction *getEnd() const { return End; }
  bool splitToTrue() const { return Left; }
  bool splitToFalse() const { return !Left; }
  bool canExtendUsing(const GapRange &Other) const {
    return Other.Start->getPrevNode() == End && Other.Left == Left;
  }
  GapRange extendUsing(const GapRange &Other) const {
    assert(canExtendUsing(Other));
    return {Start, Other.End, Left};
  }
  friend raw_ostream &operator<<(raw_ostream &OS, const GapRange &R) {
    OS << "start : "; R.Start->print(OS); OS << ", end : "; R.End->print(OS);
    return OS << ", direction : " << (R.Left ? "T" : "F");
  }
};
inline void appendGap(SmallVectorImpl<GapRange> &Ranges, bool Left,
                      Instruction *I) {
  GapRange Next(I, I, Left);
  if (!Ranges.empty() && Ranges.back().canExtendUsing(Next)) {
    GapRange Previous = Ranges.pop_back_val();
    Ranges.push_back(Previous.extendUsing(Next));
  } else Ranges.push_back(Next);
}
struct GapSegment {
  bool Left;
  std::vector<Instruction *> Instructions;
  GapRange range() const { return {Instructions.front(), Instructions.back(), Left}; }
};
struct GapGuard {
  GapSegment First;
  // Empty means a one-sided guard; otherwise one complementary if/else.
  std::vector<Instruction *> Second;
};
inline bool independentGaps(ArrayRef<Instruction *> A,
                            ArrayRef<Instruction *> B) {
  SmallPtrSet<Instruction *, 32> First, Second;
  First.insert(A.begin(), A.end()); Second.insert(B.begin(), B.end());
  for (auto *I : A) for (auto &Op : I->operands())
    if (auto *Def = dyn_cast<Instruction>(Op.get()))
      if (Second.count(Def)) return false;
  for (auto *I : B) for (auto &Op : I->operands())
    if (auto *Def = dyn_cast<Instruction>(Op.get()))
      if (First.count(Def)) return false;
  return true;
}

struct GapPlan { std::vector<GapGuard> Guards; };
inline GapPlan planGaps(ArrayRef<GapRange> ranges) {
  GapPlan plan;
  std::vector<GapSegment> segments;
  for (const auto &range : ranges) {
    GapSegment segment{range.Left, {}};
    for (auto *inst = range.Start;; inst = inst->getNextNode()) {
      assert(inst && "guard endpoints must be in one block");
      segment.Instructions.push_back(inst);
      if (inst == range.End) break;
    }
    segments.push_back(std::move(segment));
  }
  for (unsigned i = 0; i < segments.size(); ++i) {
    const auto &a = segments[i];
    GapGuard guard{a, {}};
    if (i + 1 < segments.size()) {
      const auto &b = segments[i + 1];
      if (a.Left != b.Left && a.Instructions.back()->getNextNode() == b.Instructions.front() &&
          independentGaps(a.Instructions, b.Instructions)) {
        guard.Second = b.Instructions;
        ++i;
      }
    }
    plan.Guards.push_back(std::move(guard));
  }
  return plan;
}
} // namespace llvm
