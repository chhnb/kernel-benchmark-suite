#pragma once
#include "SpeculationSafety.h"
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
namespace speculation_policy {
// Compatibility policy for a block paired with a replication placeholder.
inline bool guardOriginalBlock(BasicBlock *Current, BasicBlock *Corresponding,
                               int Mode, unsigned Budget) {
  if (Corresponding->size() > 1 || Mode == 0 || Mode == 3) return true;
  unsigned Weight = 0;
  for (auto &I : *Current) {
    if (isa<PHINode>(I) || I.isTerminator()) continue;
    if (!isSafeToSpeculativelyExecute(&I)) return true;
    if (auto *Call = dyn_cast<CallBase>(&I))
      if (Call->isConvergent()) return true;
    if (Mode == 2 && !safeToSpeculate(I)) return true;
    Weight += speculationWeight(I);
  }
  return Mode == 2 && Weight > Budget;
}
inline bool speculate(ArrayRef<Instruction *> Instructions, int Mode,
                      unsigned Budget) {
  if (Mode != 2) return false;
  unsigned Weight = 0;
  for (auto *I : Instructions) {
    if (isa<PHINode>(I) || I->isTerminator() || !safeToSpeculate(*I)) return false;
    Weight += speculationWeight(*I);
  }
  return Weight <= Budget;
}
} // namespace speculation_policy

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
inline bool safeGap(ArrayRef<Instruction *> Instructions) {
  for (auto *I : Instructions) {
    if (isa<PHINode>(I) || I->isTerminator() || !safeToSpeculate(*I)) return false;
    if (auto *Call = dyn_cast<CallBase>(I)) {
      if (Call->hasRetAttr(Attribute::NoUndef)) return false;
      for (unsigned A = 0; A < Call->arg_size(); ++A)
        if (Call->paramHasAttr(A, Attribute::NoUndef)) return false;
    }
  }
  return true;
}
struct GapDecision {
 unsigned Weight=0, Count=0;
 int64_t TTI=0;
 bool Safe=true, Available=true, Speculate=false;
 std::string Reason;
 struct InstructionCost {std::string Opcode;unsigned Weight;int TTI;bool Safe;};
 std::vector<InstructionCost> Instructions;
};
namespace speculation_policy {
inline GapDecision decide(ArrayRef<Instruction*> Instructions,int Mode,unsigned Budget,
                          const TargetTransformInfo *TTI,unsigned CostThreshold,
                          DominatorTree &DT,const DenseMap<Instruction*,unsigned> &Position) {
 GapDecision D;SmallPtrSet<Instruction*,32> Earlier;
 for(auto *I:Instructions){
  unsigned W=speculationWeight(*I);D.Weight+=W;++D.Count;
  bool Safe=!isa<PHINode>(I)&&!I->isTerminator()&&safeToSpeculate(*I);
  // Integer division can depend on facts invalidated by widening execution.
  if(Mode==3&&(I->getOpcode()==Instruction::SDiv||I->getOpcode()==Instruction::UDiv||I->getOpcode()==Instruction::SRem||I->getOpcode()==Instruction::URem))Safe=false;
  if(Mode==3)if(auto *CB=dyn_cast<CallBase>(I))if(!isa<IntrinsicInst>(CB))Safe=false;
  D.Safe &= Safe;
  int C=TTI?TTI->getInstructionCost(I,TargetTransformInfo::TCK_SizeAndLatency):-1;
  if(C<0)D.TTI=-1;else if(D.TTI>=0)D.TTI+=C;
  D.Instructions.push_back({I->getOpcodeName(),W,C,Safe});
  for(auto &Op:I->operands())if(auto *Def=dyn_cast<Instruction>(Op.get())){
   bool Available=Earlier.count(Def)||(Def->getParent()==I->getParent()?Position.lookup(Def)<Position.lookup(I):DT.dominates(Def->getParent(),I->getParent()));
   D.Available &= Available;
  }
  Earlier.insert(I);
 }
 if(Mode!=3){D.Speculate=speculate(Instructions,Mode,Budget);D.Reason=D.Speculate?"weight_budget":"mode_or_safety_protect";return D;}
 if(!D.Safe)D.Reason="unsafe_instruction";
 else if(!D.Available)D.Reason="operand_unavailable";
 else if(!TTI||D.TTI<0)D.Reason="tti_unavailable";
 else if(D.TTI>int64_t(CostThreshold)*TargetTransformInfo::TCC_Basic)D.Reason="tti_threshold";
 else{D.Speculate=true;D.Reason="tti_within_threshold";}
 return D;
}
inline void sanitize(Instruction &I){
 I.dropPoisonGeneratingFlags();
 I.dropUnknownNonDebugMetadata();
 if(auto *CB=dyn_cast<CallBase>(&I)){
  for(auto A:{Attribute::NoUndef,Attribute::NonNull,Attribute::Dereferenceable,Attribute::DereferenceableOrNull,Attribute::Alignment}){
   CB->removeAttribute(AttributeList::ReturnIndex,A);
   for(unsigned n=0;n<CB->arg_size();++n)CB->removeParamAttr(n,A);
  }
 }
}
}
struct GapPlan {
  struct Move { Instruction *I, *Before; };
  std::vector<GapSegment> Segments;
  std::vector<GapDecision> Decisions;
  std::vector<Move> Moves;
  std::vector<GapSegment> Speculated;
  std::vector<GapGuard> Guards;
  unsigned CoalescedGroups = 0;
};

inline bool gapMovable(Instruction *I) {
  if (I->isTerminator() || isa<PHINode>(I) || I->isEHPad() ||
      isa<CallBase>(I) || isa<FenceInst>(I)) return false;
  if (auto *L = dyn_cast<LoadInst>(I)) return L->isSimple();
  if (auto *S = dyn_cast<StoreInst>(I)) return S->isSimple();
  return !I->mayReadOrWriteMemory() && !I->mayHaveSideEffects();
}
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

// Pure planning: physical instruction order is not changed until the consumer
// applies Moves. Virtual order includes operand-select instructions inserted by
// the emitter, so such instructions are never silently crossed by a gap.
inline GapPlan planGaps(Function &F, ArrayRef<GapRange> Ranges, int Mode,
                         unsigned Budget, bool Coalesce,const TargetTransformInfo *TTI=nullptr,unsigned CostThreshold=4) {
  GapPlan Plan;
  std::vector<GapSegment> Segments;
  DenseMap<Instruction *, bool> Side;
  for (auto &Range : Ranges) {
    GapSegment S{Range.Left, {}};
    for (auto *I = Range.Start;; I = I->getNextNode()) {
      assert(I && "gap endpoint must be in the same block");
      Side[I] = Range.Left; S.Instructions.push_back(I);
      if (I == Range.End) break;
    }
    Segments.push_back(std::move(S));
  }
  DenseMap<Instruction *, Instruction *> Next;
  DenseMap<Instruction *, unsigned> Position;
  DominatorTree DT(F);
  if (Coalesce) Segments.clear();
  for (auto &BB : F) {
    std::vector<Instruction *> Order;
    for (auto &I : BB) Order.push_back(&I);
    if (Coalesce) {
      for (unsigned Begin = 0; Begin < Order.size();) {
        if (!Side.count(Order[Begin]) || !gapMovable(Order[Begin])) {
          ++Begin; continue;
        }
        unsigned End = Begin;
        while (End < Order.size() && Side.count(Order[End]) && gapMovable(Order[End])) ++End;
        SmallPtrSet<Instruction *, 32> Group;
        unsigned Runs = 0; bool Previous = !Side.lookup(Order[Begin]);
        for (unsigned N = Begin; N < End; ++N) {
          Group.insert(Order[N]); bool Left = Side.lookup(Order[N]);
          if (Left != Previous) ++Runs;
          Previous = Left;
        }
        bool Legal = Runs > 2;
        for (unsigned N = Begin; N < End && Legal; ++N)
          for (auto &Op : Order[N]->operands())
            if (auto *Def = dyn_cast<Instruction>(Op.get()))
              if (Group.count(Def) && Side.lookup(Def) != Side.lookup(Order[N])) Legal = false;
        if (Legal) {
          auto *Anchor = End < Order.size() ? Order[End] : nullptr;
          assert(Anchor && "movable group cannot contain terminator");
          std::vector<Instruction *> Sorted;
          bool First = Side.lookup(Order[Begin]);
          for (bool Left : {First, !First})
            for (unsigned N = Begin; N < End; ++N)
              if (Side.lookup(Order[N]) == Left) {
                Plan.Moves.push_back({Order[N], Anchor}); Sorted.push_back(Order[N]);
              }
          std::copy(Sorted.begin(), Sorted.end(), Order.begin() + Begin);
          ++Plan.CoalescedGroups;
        }
        Begin = End;
      }
      Instruction *Previous = nullptr;
      for (auto *I : Order) {
        if (Side.count(I)) {
          bool Left = Side.lookup(I);
          if (!Segments.empty() && Segments.back().Left == Left &&
              Segments.back().Instructions.back() == Previous)
            Segments.back().Instructions.push_back(I);
          else Segments.push_back({Left, {I}});
        }
        Previous = I;
      }
    }
    for(unsigned I=0;I<Order.size();++I)Position[Order[I]]=I;
    for (unsigned I = 1; I < Order.size(); ++I) Next[Order[I - 1]] = Order[I];
  }
  Plan.Segments = Segments;
  for(auto &S:Segments)Plan.Decisions.push_back(speculation_policy::decide(S.Instructions,Mode,Budget,TTI,CostThreshold,DT,Position));
  if(Mode==3){
   bool Changed;
   do{
    Changed=false;SmallPtrSet<Instruction*,32> Unavailable;
    for(unsigned n=0;n<Segments.size();++n)if(!Plan.Decisions[n].Speculate)Unavailable.insert(Segments[n].Instructions.begin(),Segments[n].Instructions.end());
    // Include intervening operand selects and other dependent computations.
    bool Grew;do{Grew=false;for(auto &B:F)for(auto &I:B)if(!isa<PHINode>(I)&&!I.isTerminator()&&!Unavailable.count(&I))for(auto &Op:I.operands())if(auto *Def=dyn_cast<Instruction>(Op.get()))if(Unavailable.count(Def)){Unavailable.insert(&I);Grew=true;break;}}while(Grew);
    for(unsigned n=0;n<Segments.size();++n)if(Plan.Decisions[n].Speculate)for(auto *I:Segments[n].Instructions)if(Unavailable.count(I)){
      Plan.Decisions[n].Speculate=false;Plan.Decisions[n].Available=false;Plan.Decisions[n].Reason="depends_on_protected_gap";Changed=true;break;
    }
   }while(Changed);
  }
  std::vector<GapSegment> Guarded;
  for(unsigned n=0;n<Segments.size();++n){if(Plan.Decisions[n].Speculate)Plan.Speculated.push_back(Segments[n]);else Guarded.push_back(Segments[n]);}
  for (unsigned I = 0; I < Guarded.size(); ++I) {
    auto &A = Guarded[I]; GapGuard G{A, {}};
    if (I + 1 < Guarded.size()) {
      auto &B = Guarded[I + 1];
      if (A.Left != B.Left && Next.lookup(A.Instructions.back()) == B.Instructions.front() &&
          independentGaps(A.Instructions, B.Instructions)) {
        G.Second = B.Instructions; ++I;
      }
    }
    Plan.Guards.push_back(std::move(G));
  }
  return Plan;
}
inline void applyGapSchedule(const GapPlan &Plan) {
  for (auto &Move : Plan.Moves) Move.I->moveBefore(Move.Before);
}
} // namespace llvm
