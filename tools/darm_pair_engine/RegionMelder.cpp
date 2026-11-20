#include "InstructionPolicy.h"
#include "RegionMelder.h"
#include "CFMelderUtils.h"
#include "RegionReplicator.h"
#include "llvm/ADT/CachedHashString.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/iterator_range.h"
#include "llvm/IR/Constants.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include <chrono>

using namespace llvm;
#define ENABLE_TIMING 1

#define DEBUG_TYPE "cfmelder"

static cl::opt<bool>
    DumpSeqAlignStats("dump-seq-align-stats", cl::init(false), cl::Hidden,
                      cl::desc("Dump information on sequence alignment"));

STATISTIC(NumMeldings, "Number of profitable meldings performed");
STATISTIC(BBToBBMeldings, "Number of profitable basic block to basic block meldings");
STATISTIC(BBToRegionMeldings, "Number of profitable basic block to region meldings");
STATISTIC(RegionToRegionMeldings, "Number of profitable region to region meldings");
STATISTIC(InstrAlignTime, "Time spent in instruction alignment in microseconds");

AlignedSeq<Value *> RegionMelder::getAlignmentOfBlocks(BasicBlock *LeftBb,
                                                       BasicBlock *RightBb) {
  if (alignBlocks)
    if (auto Result = alignBlocks(LeftBb, RightBb, CurrMapping, ExitBlockL, ExitBlockR))
      return std::move(*Result);
  // do sequence aligment
  SmallVector<Value *, 32> LSeq;
  SmallVector<Value *, 32> RSeq;
  linearizeBb(LeftBb, LSeq);
  linearizeBb(RightBb, RSeq);
  // AlignedSequence<Value *> AlignedSeq;

  // NeedlemanWunschSA<SmallVectorImpl<Value *>> SA(ScoringSystem(-1, 2),
  //                                                InstructionMatch::match);
  // return SA.getAlignment(LSeq, RSeq);
  InstrMeldingProfitabilityModel ScoringFunc;
  auto SMSA =
      SmithWaterman<Value *, SmallVectorImpl<Value *>, nullptr>(ScoringFunc);

  auto Result = SMSA.compute(LSeq, RSeq);

  return Result;
}

void RegionMelder::computeRegionSeqAlignment(
    DenseMap<BasicBlock *, BasicBlock *> BbMap) {
#ifdef FUSION_DETERMINISTIC_REGION_ORDER
  // Beam replay requires address-independent block alignment order.
  for (auto &Block : *MA.getParentFunction()) {
    auto It = BbMap.find(&Block);
    if (It == BbMap.end()) continue;
#else
  for (auto It = BbMap.begin(); It != BbMap.end(); It++) {
#endif
    BasicBlock *LBB = It->first;
    BasicBlock *RBB = It->second;

    auto Alignment = getAlignmentOfBlocks(LBB, RBB);
    if (onAlignment)
      onAlignment(LBB, RBB, Alignment);
    RegionInstrAlignement.concat(Alignment);
  }
  if (DumpSeqAlignStats) {
    InstrMeldingProfitabilityModel ScoringFunc;
    int SavedCycles = 0;
    for (auto Entry : RegionInstrAlignement) {
      Value *Left = Entry.getLeft();
      Value *Right = Entry.getRight();
      if (Left && Right) {
        if (isa<BasicBlock>(Left))
          continue;
        SavedCycles += ScoringFunc(Left, Right);
      } else {
        SavedCycles -= ScoringFunc.gap(0);
      }
    }
    INFO << "Number of cycles saved by alignment : " << SavedCycles << "\n";
  }
}

std::string RegionMelder::sourceBlockID(BasicBlock *BB) const {
  for(auto &Source:SourceBlocks)if(Source.block==BB)return Source.id;
  return "generated_before_alignment";
}
void RegionMelder::recordBlockOrigin(BasicBlock *Left,BasicBlock *Right,BasicBlock *Merged) {
  if(!RecordOrigins)return;
  auto label=[](BasicBlock *BB){std::string S;raw_string_ostream O(S);BB->printAsOperand(O,false);O.flush();return S;};
  BlockOrigins.push_back({sourceBlockID(Left),sourceBlockID(Right),label(Left),label(Right),WeakVH(Merged)});
}

// Project the replicated CFG onto its own side. Replication makes branch
// choices leading to the matched block constant on that side.
static void collectReachableBlocks(BasicBlock *Entry, BasicBlock *Exit,
                                   SmallPtrSetImpl<BasicBlock *> &Reachable) {
  SmallVector<BasicBlock *, 16> Worklist{Entry};
  while (!Worklist.empty()) {
    auto *Block = Worklist.pop_back_val();
    if (Block == Exit || !Reachable.insert(Block).second)
      continue;
    auto *Branch = dyn_cast<BranchInst>(Block->getTerminator());
    if (Branch && Branch->isConditional())
      if (auto *Condition = dyn_cast<ConstantInt>(Branch->getCondition())) {
        Worklist.push_back(Branch->getSuccessor(Condition->isZero() ? 1 : 0));
        continue;
      }
    Worklist.append(succ_begin(Block), succ_end(Block));
  }
}

void RegionMelder::cloneInstructions() {
  SmallPtrSet<BasicBlock *, 16> ReachableLeft, ReachableRight;
  if (GuardReplicatedMemory) {
    collectReachableBlocks(EntryBlockL, ExitBlockL, ReachableLeft);
    collectReachableBlocks(EntryBlockR, ExitBlockR, ReachableRight);
  }
  auto NeedsGap = [&](Instruction *Original, BasicBlock *Opposite,
                      const SmallPtrSetImpl<BasicBlock *> &Reachable) {
    if (Opposite->size() > 1)
      return true;
    if (GuardReplicatedMemory)
      return Reachable.contains(Opposite) &&
             !safeToExecuteUnconditionally(*Original);
    return !NativeReplicationPredication;
  };

  INFO << "Cloning instructions\n";
  // generate the control flow for merged region
  IRBuilder<> Builder(&MA.getParentFunction()->getEntryBlock());
  for (auto &Entry : RegionInstrAlignement) {

    Value *LEntry = Entry.get(0);
    Value *REntry = Entry.get(1);
    if (Entry.match()) {
      if (isa<BasicBlock>(LEntry)) {
        assert(isa<BasicBlock>(REntry) &&
               "Both matching entries must be basic blocks");
        BasicBlock *NewBb =
            BasicBlock::Create(MA.getParentFunction()->getContext(),
                               "merged.bb", MA.getParentFunction());
        recordBlockOrigin(cast<BasicBlock>(LEntry),cast<BasicBlock>(REntry),NewBb);
        // update value map
        MergedValuesToLeftValues[NewBb] = LEntry;
        MergedValuesToRightValues[NewBb] = REntry;

        BasicBlock *LeftBb = dyn_cast<BasicBlock>(LEntry);
        BasicBlock *RightBb = dyn_cast<BasicBlock>(REntry);
        // update label map
        LeftBbToMergedBb[LeftBb] = NewBb;
        RightBbToMergedBb[RightBb] = NewBb;

        for (auto &I : *dyn_cast<BasicBlock>(LEntry)) {
          if (isa<PHINode>(&I)) {
            Instruction *NewI = cloneInstruction(&I, Builder);
            MergedValuesToLeftValues[NewI] = &I;
            OrigToMergedValues[&I] = NewI;
            MergedInstructions.push_back(NewI);
          }
        }

        for (auto &I : *dyn_cast<BasicBlock>(REntry)) {
          if (isa<PHINode>(&I)) {
            Instruction *NewI = cloneInstruction(&I, Builder);
            MergedValuesToRightValues[NewI] = &I;
            OrigToMergedValues[&I] = NewI;
            MergedInstructions.push_back(NewI);
          }
        }
        // add to merged blocks
        MergedBBs.push_back(NewBb);

      } else {
        assert(isa<Instruction>(LEntry) && isa<Instruction>(REntry) &&
               "Both entries must be instructions");
        // skip phi nodes
        if (!isa<PHINode>(LEntry)) {
          Instruction *LeftI = dyn_cast<Instruction>(LEntry);
          Instruction *RightI = dyn_cast<Instruction>(REntry);

          Instruction *NewI = cloneInstruction(LeftI, Builder);

          // update the maps
          MergedValuesToLeftValues[NewI] = LeftI;
          MergedValuesToRightValues[NewI] = RightI;
          OrigToMergedValues[LeftI] = NewI;
          OrigToMergedValues[RightI] = NewI;

          MergedInstructions.push_back(NewI);
        }
      }
    } else {
      if (LEntry != nullptr && !isa<PHINode>(LEntry)) {
        Instruction *LeftI = dyn_cast<Instruction>(LEntry);
        Instruction *NewI = cloneInstruction(LeftI, Builder);
        // update map
        MergedValuesToLeftValues[NewI] = LeftI;
        OrigToMergedValues[LeftI] = NewI;
        MergedInstructions.push_back(NewI);

        // Empty replica blocks can share the merged control flow.
        auto ClonedRightParentIt =
            MergedValuesToRightValues.find(NewI->getParent());
        assert(ClonedRightParentIt != MergedValuesToRightValues.end() &&
               "Cloned left BB not found for right value!");
        auto *corresponding = cast<BasicBlock>(ClonedRightParentIt->second);
        if (NeedsGap(LeftI, corresponding, ReachableRight))
          updateSplitRangeMap(true, NewI);
      }

      if (REntry != nullptr && !isa<PHINode>(REntry)) {
        Instruction *RightI = dyn_cast<Instruction>(REntry);
        Instruction *NewI = cloneInstruction(RightI, Builder);
        // update map
        MergedValuesToRightValues[NewI] = RightI;
        OrigToMergedValues[RightI] = NewI;
        MergedInstructions.push_back(NewI);

        // Empty replica blocks can share the merged control flow.
        auto ClonedLeftParentIt =
            MergedValuesToLeftValues.find(NewI->getParent());
        assert(ClonedLeftParentIt != MergedValuesToLeftValues.end() &&
               "Cloned left BB not found for right value!");
        auto *corresponding = cast<BasicBlock>(ClonedLeftParentIt->second);
        if (NeedsGap(RightI, corresponding, ReachableLeft))
          updateSplitRangeMap(false, NewI);
      }
    }
  }
}

void RegionMelder::fixPhiNode(PHINode *Orig) {
  // orig->print(errs()); errs() << "\n";
  // get the merged phi node
  assert(OrigToMergedValues.find(Orig) != OrigToMergedValues.end() &&
         "phi node is not found in merged control flow!");

  PHINode *MergedPhi = dyn_cast<PHINode>(OrigToMergedValues[Orig]);

  for (unsigned I = 0; I < Orig->getNumIncomingValues(); I++) {
    BasicBlock *OrigIncomingBb = Orig->getIncomingBlock(I);
    Value *OrigIncomingV = Orig->getIncomingValue(I);
    // set the matching incoming block and value in merged PHI node
    BasicBlock *MergedIncomingBb = OrigIncomingBb;
    Value *MergedIncomingV = OrigIncomingV;
    if (LeftBbToMergedBb.find(OrigIncomingBb) != LeftBbToMergedBb.end())
      MergedIncomingBb = LeftBbToMergedBb[OrigIncomingBb];
    else if (RightBbToMergedBb.find(OrigIncomingBb) != RightBbToMergedBb.end())
      MergedIncomingBb = RightBbToMergedBb[OrigIncomingBb];

    assert(MergedIncomingBb != nullptr &&
           "matching incoming block not found for phi node!");

    MergedPhi->setIncomingBlock(I, MergedIncomingBb);

    // check if origIncoming value is merged
    if (OrigToMergedValues.find(OrigIncomingV) != OrigToMergedValues.end())
      MergedIncomingV = OrigToMergedValues[OrigIncomingV];

    // set the incoming value
    MergedPhi->setIncomingValue(I, MergedIncomingV);
  }
}

void RegionMelder::fixOperends() {
  INFO << "Fixing operends\n";
  // set the correct operends in merged instructions
  for (auto &Entry : RegionInstrAlignement) {
    Value *L = Entry.get(0);
    Value *R = Entry.get(1);

    Instruction *MergedI;
    if (Entry.match()) {
      // L->print(errs()); errs() << "\n";
      // R->print(errs()); errs() << "\n";
      // ignore basic blocks, branch instructions and phi nodes
      if (isa<BasicBlock>(L))
        continue;

      // handle phi nodes seperately
      if (isa<PHINode>(L)) {
        fixPhiNode(dyn_cast<PHINode>(L));
        fixPhiNode(dyn_cast<PHINode>(R));
        continue;
      }

      Instruction *LeftI = dyn_cast<Instruction>(L);
      Instruction *RightI = dyn_cast<Instruction>(R);
      assert(OrigToMergedValues[L] == OrigToMergedValues[R] &&
             "matching instructions must have common merged instruction");
      // set the operends of merged instruction
      MergedI = dyn_cast<Instruction>(OrigToMergedValues[L]);

      if (isa<BranchInst>(L))
        setOperendsForBr(dyn_cast<BranchInst>(L), dyn_cast<BranchInst>(R),
                         dyn_cast<BranchInst>(MergedI));
      else if (auto *LeftSwitch = dyn_cast<SwitchInst>(LeftI)) {
        auto *RightSwitch = cast<SwitchInst>(RightI);
        for (unsigned N = 0; N < LeftSwitch->getNumSuccessors(); ++N) {
          auto *LeftTarget = LeftBbToMergedBb.lookup(LeftSwitch->getSuccessor(N));
          auto *RightTarget = RightBbToMergedBb.lookup(RightSwitch->getSuccessor(N));
          if (!LeftTarget || LeftTarget != RightTarget)
            throw std::runtime_error("switch_successor_mapping_mismatch");
        }
        auto *LeftCondition = LeftSwitch->getCondition();
        auto *RightCondition = RightSwitch->getCondition();
        if (Value *Mapped = OrigToMergedValues.lookup(LeftCondition))
          LeftCondition = Mapped;
        if (Value *Mapped = OrigToMergedValues.lookup(RightCondition))
          RightCondition = Mapped;
        IRBuilder<> Builder(MergedI);
        cast<SwitchInst>(MergedI)->setCondition(LeftCondition == RightCondition
            ? LeftCondition
            : Builder.CreateSelect(MA.getDivergentCondition(), LeftCondition, RightCondition));
      } else
        setOperends(LeftI, RightI, MergedI);

    } else {
      // ignore branch instructions
      // TODO : returns
      if (L != nullptr) {
        assert(!isa<BranchInst>(L) && "unmatched branch found!");
        if (isa<PHINode>(L)) {
          fixPhiNode(dyn_cast<PHINode>(L));
        } else {
          assert(!isa<BasicBlock>(L) &&
                 "non matching value can not be a basicblock");
          Instruction *LeftI = dyn_cast<Instruction>(L);
          MergedI = dyn_cast<Instruction>(OrigToMergedValues[L]);

          setOperends(LeftI, nullptr, MergedI);
        }
      }

      if (R != nullptr) {
        assert(!isa<BranchInst>(R) && "unmatched branch found!");
        if (isa<PHINode>(R)) {
          fixPhiNode(dyn_cast<PHINode>(R));
        } else {
          assert(!isa<BasicBlock>(R) &&
                 "non matching value can not be a basicblock");
          Instruction *RightI = dyn_cast<Instruction>(R);
          MergedI = dyn_cast<Instruction>(OrigToMergedValues[R]);

          setOperends(nullptr, RightI, MergedI);
        }
      }
    }
  }
}

void RegionMelder::setOperendsForBr(BranchInst *LeftBr, BranchInst *RightBr,
                                    BranchInst *MergedBr) {

  // for branches inside the merged regions : pick the correct condition using a
  // select branch labels are set in RAUW phase
  if (ExitBlockL && LeftBr->getParent() != ExitBlockL) {
    assert(LeftBr->getNumSuccessors() == RightBr->getNumSuccessors() &&
           "branches inside the merged region must have same number of "
           "successors!");
    if (LeftBr->isConditional()) {
      Value *LeftCond = LeftBr->getCondition();
      Value *RightCond = RightBr->getCondition();
      Value *MergedCond = nullptr;
      if (OrigToMergedValues.find(LeftCond) != OrigToMergedValues.end())
        LeftCond = OrigToMergedValues[LeftCond];
      if (OrigToMergedValues.find(RightCond) != OrigToMergedValues.end())
        RightCond = OrigToMergedValues[RightCond];

      MergedCond = LeftCond;
      // create a select if left and right conditions are not same
      if (LeftCond != RightCond) {
        IRBuilder<> Builder(MergedBr);
        MergedCond = Builder.CreateSelect(MA.getDivergentCondition(), LeftCond,
                                          RightCond);
        if (onOperandSelect && MergedCond != LeftCond && MergedCond != RightCond &&
            isa<SelectInst>(MergedCond))
          onOperandSelect(*LeftBr, 0, MergedCond->getType());
      }
      MergedBr->setCondition(MergedCond);
    }

    return;
  }

  // for branches in exit blocks : create two new basic blocks and copy left and
  // right branches trasfer control to new blocks based on merge path

  // create two new basic blocks and copy the branches from left and right sides
  BasicBlock *NewBbLeftBr =
      BasicBlock::Create(MA.getParentFunction()->getContext(),
                         "merged.branch.split", MA.getParentFunction());
  BasicBlock *NewBbRightBr =
      BasicBlock::Create(MA.getParentFunction()->getContext(),
                         "merged.branch.split", MA.getParentFunction());

  // clone the original branches and add them to new BBs
  IRBuilder<> Builder(NewBbLeftBr);
  Instruction *NewLeftBr = LeftBr->clone();
  Instruction *NewRightBr = RightBr->clone();
  Builder.Insert(NewLeftBr);
  Builder.SetInsertPoint(NewBbRightBr);
  Builder.Insert(NewRightBr);

  // create a new branch in the merged block to set the targets based on
  // mergepath remove exiting mergeBr
  Builder.SetInsertPoint(MergedBr->getParent());
  BranchInst *NewBi = Builder.CreateCondBr(MA.getDivergentCondition(),
                                           NewBbLeftBr, NewBbRightBr);
  MergedBr->eraseFromParent();

  // update the value maps
  MergedValuesToLeftValues[NewBi] = LeftBr;
  MergedValuesToRightValues[NewBi] = RightBr;
  OrigToMergedValues[LeftBr] = NewBi;
  OrigToMergedValues[RightBr] = NewBi;

  // fix the phi uses in all successors
  for (BasicBlock *SuccBb : dyn_cast<BranchInst>(NewLeftBr)->successors()) {
    SuccBb->replacePhiUsesWith(LeftBr->getParent(), NewBbLeftBr);
  }

  for (BasicBlock *SuccBb : dyn_cast<BranchInst>(NewRightBr)->successors()) {
    SuccBb->replacePhiUsesWith(RightBr->getParent(), NewBbRightBr);
  }
}



void RegionMelder::setOperends(Instruction *LeftI, Instruction *RightI,
                               Instruction *MergedI) {
  for (unsigned I = 0; I < MergedI->getNumOperands(); I++) {
    Value *LeftOp = nullptr, *RightOp = nullptr;

    if (LeftI)
      LeftOp = LeftI->getOperand(I);
    if (RightI)
      RightOp = RightI->getOperand(I);

    if (LeftOp && OrigToMergedValues.find(LeftOp) != OrigToMergedValues.end())
      LeftOp = OrigToMergedValues[LeftOp];
    if (RightOp && OrigToMergedValues.find(RightOp) != OrigToMergedValues.end())
      RightOp = OrigToMergedValues[RightOp];

    // if the operends are different add a select to pick the correct one
    Value *NewOp = LeftOp ? LeftOp : RightOp;
    if (LeftOp && RightOp && LeftOp != RightOp) {
      SelectInst *Select =
          SelectInst::Create(MA.getDivergentCondition(), LeftOp, RightOp,
                             "merged.select", MergedI);
      NewOp = dyn_cast<Value>(Select);
      if (onOperandSelect)
        onOperandSelect(*LeftI, I, Select->getType());
    }

    // set the new operenf
    MergedI->setOperand(I, NewOp);
  }
}

void RegionMelder::runPostMergeCleanup() {

  // replace all uses with merged vals
  // ignore basicblocks
  for (auto &Entry : RegionInstrAlignement) {

    Value *L = Entry.get(0);
    Value *R = Entry.get(1);

    Value *MergedValLeft = nullptr;
    Value *MergedValRight = nullptr;
    if (Entry.match()) {
      if (isa<BasicBlock>(L)) {
        MergedValLeft = LeftBbToMergedBb[dyn_cast<BasicBlock>(L)];
        MergedValRight = MergedValLeft;

      } else if (isa<PHINode>(L)) {
        MergedValLeft = OrigToMergedValues[L];
        MergedValRight = OrigToMergedValues[R];
      } else {
        MergedValLeft = OrigToMergedValues[L];
        MergedValRight = MergedValLeft;
      }

      L->replaceAllUsesWith(MergedValLeft);
      R->replaceAllUsesWith(MergedValRight);

    } else {
      if (L != nullptr) {
        if (isa<BasicBlock>(L))
          MergedValLeft = LeftBbToMergedBb[dyn_cast<BasicBlock>(L)];
        else
          MergedValLeft = OrigToMergedValues[L];

        L->replaceAllUsesWith(MergedValLeft);
      }
      if (R != nullptr) {
        if (isa<BasicBlock>(R))
          MergedValRight = LeftBbToMergedBb[dyn_cast<BasicBlock>(R)];
        else
          MergedValRight = OrigToMergedValues[R];

        R->replaceAllUsesWith(MergedValRight);
      }
    }
  }
  // fix outside phi nodes that are invalid after merge
  // FixOutsidePHINodes(outsidePhisBeforeRAUW);

  // Alignment includes instructions owned by these blocks. Inspect all entries
  // before deleting any block, otherwise later isa<> reads freed instructions.
  SmallVector<BasicBlock *, 32> BlocksToErase;
  SmallPtrSet<BasicBlock *, 32> SeenBlocks;
  for (auto &Entry : RegionInstrAlignement) {
    for (unsigned Side=0; Side<2; ++Side) {
      Value *V=Entry.get(Side);
      if (auto *BB=dyn_cast_or_null<BasicBlock>(V))
        if (SeenBlocks.insert(BB).second) BlocksToErase.push_back(BB);
    }
  }
  for (auto *BB : BlocksToErase) BB->eraseFromParent();

  // merging can result in additional predessors for merged entry blocks
  // scan all phi nodes and add missing incoming blocks, value will be undef
  // because these transitions will not happen during execution
  for (auto &BB : *MA.getParentFunction()) {
    for (PHINode &PN : BB.phis()) {
      for (auto It = pred_begin(&BB); It != pred_end(&BB); ++It) {
        if (PN.getBasicBlockIndex(*It) < 0) {
          // PN.print(errs());  errs() << "\n";
          // (*it)->print(errs());
          PN.addIncoming(UndefValue::get(PN.getType()), *It);
        }
      }
    }
  }
}

Region* RegionMelder::getRegionToReplicate(BasicBlock * MatchedBlock, BasicBlock* PathEntry) {
  SmallPtrSet<BasicBlock *, 16> visited;
  auto *current = MatchedBlock;
  while (current && visited.insert(current).second) {
    auto *candidate = MA.getRI()->getRegionFor(current);
    if (!candidate || candidate->isTopLevelRegion())
      return nullptr;
    auto *entry = candidate->getEntry();
    if (MA.getPDT()->dominates(entry, PathEntry))
      return candidate;

    current = nullptr;
    for (auto *pred : predecessors(entry))
      if (!candidate->contains(pred)) {
        current = pred;
        break;
      }
  }
  return nullptr;
}


void RegionMelder::merge(unsigned Index) {

  bool RegionAlreadySimplified = false;

  if (MA.requireRegionReplication()) {
    INFO << "Replicating regions in BB-region match\n";
    auto Mapping = MA.getRegionMatch(Index);
    assert(Mapping.size() == 1 &&
           "more than one pair of basic blocks to match in BB-region match");

    // determine on which side region needs to be replicated
    BasicBlock *LeftPathEntry =
        MA.getDivergentBlock()->getTerminator()->getSuccessor(0);
    BasicBlock *RightPathEntry =
        MA.getDivergentBlock()->getTerminator()->getSuccessor(1);

    BasicBlock *ExpandedBlock, *MatchedBlock = nullptr;
    Region *RToReplicate = nullptr;
    BasicBlock *Left = Mapping.begin()->first, *Right = Mapping.begin()->second;
    bool ExpandingLeft = false;
    if (MA.getPDT()->dominates(Left, LeftPathEntry)) {
      DEBUG << "Replicating right region\n";
      ExpandedBlock = Left;
      MatchedBlock = Right;
      RToReplicate = getRegionToReplicate(MatchedBlock, RightPathEntry);
      ExpandingLeft = true;
    } else {
      DEBUG << "Replicating left region\n";
      ExpandedBlock = Right;
      MatchedBlock = Left;
      RToReplicate = getRegionToReplicate(MatchedBlock, LeftPathEntry);
    }

    if (!RToReplicate)
      throw std::runtime_error("replication_region_boundary_not_found");

    // simplify the replicated region
    BasicBlock *ExitToReplicate = RToReplicate->getExit();
    BasicBlock *EntryToReplicate = RToReplicate->getEntry();
    if (MA.requireRegionSimplification(RToReplicate)) {
      INFO << "Replicated region is not a simple region, running region "
              "simplification\n";
      BasicBlock *Entry = RToReplicate->getEntry();
      ExitToReplicate =
          simplifyRegion(RToReplicate->getExit(), RToReplicate->getEntry());

      // recompute control-flow analyses , FIXME : this might be too expensive
      MA.recomputeControlFlowAnalyses();
      RToReplicate = MA.getRI()->getRegionFor(Entry);
      INFO << "region after region simplification : ";
      errs() << "[";
      RToReplicate->getEntry()->printAsOperand(errs(), false);
      errs() << " : ";
      RToReplicate->getExit()->printAsOperand(errs(), false);
      errs() << "]\n";

      RegionAlreadySimplified = true;
    }

    // replicate the region
    RegionReplicator RR(MA, ExpandingLeft);
    Region *ReplicatedR =
        RR.replicate(ExpandedBlock, MatchedBlock, RToReplicate,
                     !GuardReplicatedMemory);

    // prepare for melding
    if (ExpandingLeft) {
      EntryBlockL = ReplicatedR->getEntry();
      ExitBlockL = ReplicatedR->getExit();
      EntryBlockR = EntryToReplicate;
      ExitBlockR = ExitToReplicate;
    } else {
      EntryBlockR = ReplicatedR->getEntry();
      ExitBlockR = ReplicatedR->getExit();
      EntryBlockL = EntryToReplicate;
      ExitBlockL = ExitToReplicate;
    }

    RR.getBasicBlockMapping(CurrMapping, ExpandingLeft);

    BBToRegionMeldings++;

  } else {

    // set entry and exits
    EntryBlockL = MA.getRegionMatchEntryBlocks(Index).first;
    EntryBlockR = MA.getRegionMatchEntryBlocks(Index).second;

    // exit blocks are set for only region-region melding, otherwise null
    auto ExitBlocks = MA.getRegionMatchExitBlocks(Index);
    if (ExitBlocks.first && ExitBlocks.second) {
      ExitBlockL = ExitBlocks.first;
      ExitBlockR = ExitBlocks.second;
      RegionToRegionMeldings++;
    }
    else{
      BasicBlock* LeftUniqueSucc = EntryBlockL->getUniqueSuccessor();
      BasicBlock* RightUniqueSucc = EntryBlockR->getUniqueSuccessor();
      // if diamonf control-flow
      if (LeftUniqueSucc && RightUniqueSucc && LeftUniqueSucc == RightUniqueSucc) {
        BBToBBMeldings++;
      }
      else {
        BBToRegionMeldings++;
      }
    }

    CurrMapping = MA.getRegionMatch(Index);
  }

  INFO << "Melding entry blocks ";
  EntryBlockL->printAsOperand(errs(), false);
  errs() << " , ";
  EntryBlockR->printAsOperand(errs(), false);
  errs() << "\n";

  if (ExitBlockL) {
    INFO << "Melding exit blocks ";
    ExitBlockL->printAsOperand(errs(), false);
    errs() << " , ";
    ExitBlockR->printAsOperand(errs(), false);
    errs() << "\n";
  }
  // run pre merge passes
  runPreMergePasses(RegionAlreadySimplified);

  {

    // parentFunc->print(errs());

    // compute alignment
#if ENABLE_TIMING == 1
    auto T1 = std::chrono::high_resolution_clock::now();
#endif
    computeRegionSeqAlignment(CurrMapping);
#if ENABLE_TIMING == 1
    auto T2 = std::chrono::high_resolution_clock::now();
    auto micros = std::chrono::duration_cast<std::chrono::microseconds>(T2-T1).count();
    InstrAlignTime += (unsigned int)(micros);
#endif
    // for(auto& Entry : RegionInstrAlignement) {
    //   if(Entry.getLeft())
    //     Entry.getLeft()->print(errs());
    //   else
    //     errs() << "_";
    //   errs() << ":";
    //   if(Entry.getRight())
    //     Entry.getRight()->print(errs());
    //   else
    //     errs() << "_";
    //   errs() << "\n";
    // }
    // while(true);

    // An unmatched terminator needs its own CFG rewrite. Gap protection
    // cannot split after a terminator or clone it into an existing block.
    for (auto &Entry : RegionInstrAlignement)
      if (!Entry.match())
        for (unsigned Side : {0u, 1u})
          if (auto *I = dyn_cast_or_null<Instruction>(Entry.get(Side)))
            if (I->isTerminator())
              throw std::runtime_error("unmatched_terminator_in_meld");

    // merge
    cloneInstructions();
    fixOperends();
    // Transfer search-owned origins before original instructions are erased.
    if(onValueMapping)onValueMapping(OrigToMergedValues);
    runPostMergeCleanup();
    // parentFunc->print(errs());
    runPostOptimizations();

      runUnpredicationPass();
  }
  NumMeldings++;
  // verify the function
  // assert(!verifyFunction(*MA.getParentFunction()) &&
  //        "function verification failed!");
}

void RegionMelder::linearizeBb(BasicBlock *BB,
                               SmallVectorImpl<Value *> &LinearizedVals) {
  LinearizedVals.push_back(BB);
  for (Instruction &I : *BB) {
    LinearizedVals.push_back(&I);
  }
}

Instruction *RegionMelder::cloneInstruction(Instruction *OrigI,
                                            IRBuilder<> &Builder) {
  Instruction *NewI = OrigI->clone();

  BasicBlock *InsertAt = nullptr;
  // decide whta place to insert at
  if (LeftBbToMergedBb.find(OrigI->getParent()) != LeftBbToMergedBb.end())
    InsertAt = LeftBbToMergedBb[OrigI->getParent()];
  if (InsertAt == nullptr)
    InsertAt = RightBbToMergedBb[OrigI->getParent()];

  // insertion
  Builder.SetInsertPoint(InsertAt);
  Builder.Insert(NewI);
  return NewI;
}

// Reorder only adjacent unmatched instructions, never a shared instruction.
// Each side keeps its original instruction/memory order and remains guarded.
// Cross-side SSA dependencies, calls, volatile/atomic accesses and barriers
// stop grouping. This is scheduling within one block, not speculation.
bool RegionMelder::hasGuardedGap(const Instruction *instruction, bool left) const {
  for (const auto &range : SplitRanges) {
    if (range.splitToTrue() != left)
      continue;
    for (auto *current = range.getStart(); current; current = current->getNextNode()) {
      if (current == instruction)
        return true;
      if (current == range.getEnd())
        break;
    }
  }
  return false;
}

void RegionMelder::runUnpredicationPass() {
  auto Plan = planGaps(SplitRanges);
  for (auto &Guard : Plan.Guards) {
    auto Range = Guard.First.range();
    auto *End = Guard.Second.empty() ? Range.getEnd() : Guard.Second.back();
    auto *Start = Range.getStart();
    if (!Start->getParent() || Start->getParent() != End->getParent() ||
        !End->getNextNode() || isa<PHINode>(Start)) {
      throw std::runtime_error("invalid_guarded_range");
    }
    if (!Guard.Second.empty() &&
        Range.getEnd()->getNextNode() != Guard.Second.front())
      throw std::runtime_error("nonadjacent_guarded_ranges");

    if (!Guard.Second.empty()) {
      GapRange Other(Guard.Second.front(), Guard.Second.back(), !Range.Left);
        auto *Head = Range.getStart()->getParent();
        auto *First = SplitBlock(Head, Range.getStart(), static_cast<DominatorTree *>(nullptr), nullptr,
                                 nullptr, "predication.first");
        auto *Second = SplitBlock(First, Other.getStart(), static_cast<DominatorTree *>(nullptr), nullptr,
                                  nullptr, "predication.second");
        auto *Tail = SplitBlock(Second, Other.getEnd()->getNextNode(), static_cast<DominatorTree *>(nullptr),
                                nullptr, nullptr, "predication.join");
        auto *TrueArm = Range.splitToTrue() ? First : Second;
        auto *FalseArm = Range.splitToTrue() ? Second : First;
        auto *Condition = MA.getDivergentCondition();
        Head->getTerminator()->eraseFromParent();
        BranchInst::Create(TrueArm, FalseArm, Condition, Head);
        cast<BranchInst>(First->getTerminator())->setSuccessor(0, Tail);

        SmallVector<PHINode *, 16> Carriers;
        SmallPtrSet<SelectInst *, 16> Selects;
        for (auto *Arm : {First, Second}) {
          auto *Opposite = Arm == First ? Second : First;
          for (auto &I : *Arm) {
            SmallVector<Instruction *, 8> OutsideUsers;
            for (auto *U : I.users())
              if (auto *User = dyn_cast<Instruction>(U))
                if (User->getParent() != Arm) OutsideUsers.push_back(User);
            if (OutsideUsers.empty()) continue;
            auto *Phi = PHINode::Create(I.getType(), 2, "guard.value",
                                        Tail->getFirstNonPHI());
            Phi->addIncoming(&I, Arm);
            Phi->addIncoming(UndefValue::get(I.getType()), Opposite);
            Carriers.push_back(Phi);
            for (auto *User : OutsideUsers) {
              User->replaceUsesOfWith(&I, Phi);
              if (auto *Select = dyn_cast<SelectInst>(User))
                if (Select->getParent() == Tail && Select->getCondition() == Condition)
                  Selects.insert(Select);
            }
          }
        }
        // A selection of arm-local results is directly represented by a PHI.
        // Only touch selectors fed by the carrier PHIs created above.
        auto incoming = [&](Value *V, BasicBlock *Arm) -> Value * {
          if (auto *Phi = dyn_cast<PHINode>(V))
            if (Phi->getParent() == Tail) return Phi->getIncomingValueForBlock(Arm);
          if (isa<Constant>(V) || isa<Argument>(V)) return V;
          return nullptr;
        };
        // Use instruction order, rather than pointer-set order, for stable IR.
        for (auto It = Tail->begin(); It != Tail->end();) {
          auto *Select = dyn_cast<SelectInst>(&*It++);
          if (!Select || !Selects.count(Select)) continue;
          auto *TrueValue = incoming(Select->getTrueValue(), TrueArm);
          auto *FalseValue = incoming(Select->getFalseValue(), FalseArm);
          if (!TrueValue || !FalseValue) continue;
          auto *Phi = PHINode::Create(Select->getType(), 2, "guard.result",
                                      Tail->getFirstNonPHI());
          Phi->addIncoming(TrueValue, TrueArm);
          Phi->addIncoming(FalseValue, FalseArm);
          Select->replaceAllUsesWith(Phi);
          Select->eraseFromParent();
        }
        for (auto *Phi : Carriers)
          if (Phi->use_empty()) Phi->eraseFromParent();
        continue;
    }
    BasicBlock *BB = Range.getStart()->getParent();
    BasicBlock *SplitBb = SplitBlock(BB, Range.getStart(), static_cast<DominatorTree *>(nullptr), nullptr,
                                     nullptr, "predication.split");
    BasicBlock *TailBlock =
        SplitBlock(SplitBb, Range.getEnd()->getNextNode(), static_cast<DominatorTree *>(nullptr), nullptr,
                   nullptr, "predication.tail");
    // now only execute the splitBlock conditionally
    Instruction *OldBr = BB->getTerminator();
    BasicBlock *TrueTarget = nullptr;
    BasicBlock *FalseTarget = nullptr;
    if (Range.splitToTrue()) {
      TrueTarget = SplitBb;
      FalseTarget = TailBlock;
    } else {
      TrueTarget = TailBlock;
      FalseTarget = SplitBb;
    }
    BranchInst *NewBr = BranchInst::Create(TrueTarget, FalseTarget,
                                           MA.getDivergentCondition(), BB);
    OldBr->replaceAllUsesWith(NewBr);
    OldBr->eraseFromParent();

    // add phi node where necessary

    for (auto &I : *SplitBb) {
      SmallVector<Instruction *, 32> Users;
      PHINode *NewPhi = nullptr;
      for (auto It = I.user_begin(); It != I.user_end(); ++It) {
        Instruction *User = dyn_cast<Instruction>(*It);
        if (User->getParent() != SplitBb) {
          Users.push_back(User);
        }
      }

      if (!Users.empty()) {
        NewPhi =
            PHINode::Create(I.getType(), 2, "", TailBlock->getFirstNonPHI());
        NewPhi->addIncoming(&I, SplitBb);
        NewPhi->addIncoming(UndefValue::get(NewPhi->getType()), BB);
        for (auto User : Users) {
          User->replaceUsesOfWith(&I, NewPhi);
        }
      }
    }
  }
}

void RegionMelder::updateSplitRangeMap(bool Direction, Instruction *I) {
  appendGap(SplitRanges,Direction,I);
}

bool RegionMelder::isExitBlockSafeToMerge(BasicBlock *Exit, BasicBlock *Entry) {
  Region *R = MA.getRI()->getRegionFor(Entry);

  for (auto It = pred_begin(Exit); It != pred_end(Exit); ++It) {
    if (!R->contains(*It)) {
      // errs() << "not safe to merge\n";
      // (*it)->print(errs());
      return false;
    }
  }
  return true;
}

BasicBlock *RegionMelder::simplifyRegion(BasicBlock *Exit, BasicBlock *Entry) {
  // only applies for region merges (not needed for bb merges)
  // if the exit block of the region (to be merged) has preds from outside that
  // region create a new exit block and add an edge from new to old exit

  // create a new exit block
  Function *ParentFunc = MA.getParentFunction();
  BasicBlock *NewExit = BasicBlock::Create(ParentFunc->getContext(), "new.exit",
                                           ParentFunc, Exit);
  // add a jump from new exit to old exit
  BranchInst::Create(Exit, NewExit);
  Region *MergedR = MA.getRI()->getRegionFor(Entry);

  // move relavant phi nodes from old exit to new exit
  SmallVector<BasicBlock *, 4> IncomingBlocksToDelete;
  for (auto &Phi : Exit->phis()) {

    IncomingBlocksToDelete.clear();
    // create a new phi in new exit block
    PHINode *NewPhi =
        PHINode::Create(Phi.getType(), 1, "moved.phi", &*NewExit->begin());
    for (unsigned I = 0; I < Phi.getNumIncomingValues(); ++I) {
      Value *IncomingV = Phi.getIncomingValue(I);
      BasicBlock *IncomingB = Phi.getIncomingBlock(I);
      // incomingB->print(errs());

      if (MergedR->contains(IncomingB)) {
        NewPhi->addIncoming(IncomingV, IncomingB);
        IncomingBlocksToDelete.push_back(IncomingB);
      }
    }
    Phi.addIncoming(NewPhi, NewExit);
    // remove incoming values from within region for the old exit
    for (auto BB : IncomingBlocksToDelete) {
      Phi.removeIncomingValue(BB);
    }
  }

  // unlink the old exit from the region and link new exit block to region
  SmallVector<BasicBlock *, 4> PredsWithinRegion;
  for (auto It = pred_begin(Exit); It != pred_end(Exit); ++It) {
    BasicBlock *Pred = *It;
    // TODO : self loops?
    if (MergedR->contains(Pred))
      PredsWithinRegion.push_back(Pred);
  }

  for (BasicBlock *Pred : PredsWithinRegion) {
    Pred->getTerminator()->replaceSuccessorWith(Exit, NewExit);
  }

  return NewExit;
}

bool RegionMelder::isInsideMeldedRegion(BasicBlock *BB, BasicBlock *Entry,
                                        BasicBlock *Exit) {
  // melded region is a single BB
  if (!Exit) {
    return BB == Entry;
  }
  // melded region has mutiple BBs
  return (MA.getDT()->dominates(Entry, BB) && MA.getPDT()->dominates(Exit, BB));
}

void RegionMelder::mergeOutsideDefsAtEntry() {

  SmallVector<BasicBlock *, 16> LeftEntryPreds, RightEntryPreds;

  auto CreateUnifyingBB = [&]() {
    BasicBlock *UnifyBB =
        BasicBlock::Create(MA.getParentFunction()->getContext(), "unify.bb",
                           MA.getParentFunction(), EntryBlockL);
    BranchInst::Create(UnifyBB, UnifyBB, MA.getDivergentCondition(), UnifyBB);

    for (auto &PHI : EntryBlockL->phis()) {
      // add a new phi in unifying block
      PHINode *MovedPHI =
          PHINode::Create(PHI.getType(), 1, "moved.phi", &*UnifyBB->begin() );
      for (unsigned int I = 0; I < PHI.getNumIncomingValues(); ++I) {
        if (!isInsideMeldedRegion(PHI.getIncomingBlock(I), EntryBlockL,
                                  ExitBlockL)) {
          MovedPHI->addIncoming(PHI.getIncomingValue(I),
                                PHI.getIncomingBlock(I));
          PHI.setIncomingBlock(I, UnifyBB);
          PHI.setIncomingValue(I, MovedPHI);
        }
      }
    }

    for (auto &PHI : EntryBlockR->phis()) {
      // add a new phi in unifying block
      PHINode *MovedPHI =
          PHINode::Create(PHI.getType(), 1, "moved.phi", &*UnifyBB->begin());
      for (unsigned int I = 0; I < PHI.getNumIncomingValues(); ++I) {
        if (!isInsideMeldedRegion(PHI.getIncomingBlock(I), EntryBlockR,
                                  ExitBlockR)) {
          MovedPHI->addIncoming(PHI.getIncomingValue(I),
                                PHI.getIncomingBlock(I));
          PHI.setIncomingBlock(I, UnifyBB);
          PHI.setIncomingValue(I, MovedPHI);
        }
      }
    }

    // find the predecessors of left and right entries
    for (auto *LeftPred :
         make_range(pred_begin(EntryBlockL), pred_end(EntryBlockL))) {
      if (!isInsideMeldedRegion(LeftPred, EntryBlockL, ExitBlockL)){
        LeftEntryPreds.push_back(LeftPred);
      }
    }

    for (auto *RightPred :
         make_range(pred_begin(EntryBlockR), pred_end(EntryBlockR))) {
      if (!isInsideMeldedRegion(RightPred, EntryBlockR, ExitBlockR)){
        RightEntryPreds.push_back(RightPred);
      }
    }

    // add missing preds in phi nodes of unifybb
    for (auto &PHI : UnifyBB->phis()) {
      for (auto &Pred : LeftEntryPreds) {
        if (PHI.getBasicBlockIndex(Pred) == -1) {
          PHI.addIncoming(llvm::UndefValue::get(PHI.getType()), Pred);
        }
      }
      for (auto &Pred : RightEntryPreds) {
        if (PHI.getBasicBlockIndex(Pred) == -1) {
          PHI.addIncoming(llvm::UndefValue::get(PHI.getType()), Pred);
        }
      }
    }

    // set the branches correctly
    for (auto &LeftPred : LeftEntryPreds) {
      LeftPred->getTerminator()->replaceSuccessorWith(EntryBlockL, UnifyBB);
    }
    for (auto &RightPred : RightEntryPreds) {
      RightPred->getTerminator()->replaceSuccessorWith(EntryBlockR, UnifyBB);
    }

    UnifyBB->getTerminator()->setSuccessor(0, EntryBlockL);
    UnifyBB->getTerminator()->setSuccessor(1, EntryBlockR);

    return UnifyBB;
  };

  // create a unifiying basic block
  BasicBlock *UnifyingBB = CreateUnifyingBB();

  // recompute control-flow analyses
  MA.recomputeControlFlowAnalyses();

  // check if there are any def-use chains that are broken
  for (auto &BB : *MA.getParentFunction()) {
    // only need to check basic blocks detween top entry and unify BB
    if (MA.getDT()->dominates(MA.getDivergentBlock(), &BB) &&
        MA.getPDT()->dominates(UnifyingBB, &BB)) {
      // iterate over all users and check for broken def-uses
      for (auto &Def : make_range(BB.begin(), BB.end())) {
        SmallVector<Instruction *, 32> BrokenUsers;
        for (auto &Use : make_range(Def.use_begin(), Def.use_end())) {
          Instruction *User = dyn_cast<Instruction>(Use.getUser());
          // User->print(errs()); errs() << "\n";
          if (!MA.getDT()->dominates(&Def, Use)) {

            BrokenUsers.push_back(User);
          }
        }
        PHINode *NewUnifyingPHI = nullptr;
        for (Instruction *BrokenUser : BrokenUsers) {
          // errs() << "borken user\n";
          // add a new phi node in the unifying block
          if (!NewUnifyingPHI) {
            NewUnifyingPHI = PHINode::Create(Def.getType(), 0, "unify.phi",
                                              &*UnifyingBB->begin());

            BasicBlock *TopLeftSucc =
                MA.getDivergentBlock()->getTerminator()->getSuccessor(0);
            // which path the def is in?
            bool DefInLeft = MA.getDT()->dominates(TopLeftSucc, Def.getParent());

            // add incoming values for phi
            if (DefInLeft) {
              for (auto &LeftPred : LeftEntryPreds) {
                NewUnifyingPHI->addIncoming(&Def, LeftPred);
              }
              for (auto &RightPred : RightEntryPreds) {
                NewUnifyingPHI->addIncoming(
                    llvm::UndefValue::get(NewUnifyingPHI->getType()), RightPred);
              }
            } else {
              for (auto &LeftPred : LeftEntryPreds) {
                NewUnifyingPHI->addIncoming(
                    llvm::UndefValue::get(NewUnifyingPHI->getType()), LeftPred);
              }
              for (auto &RightPred : RightEntryPreds) {
                NewUnifyingPHI->addIncoming(&Def, RightPred);
              }
            }
          }
          BrokenUser->replaceUsesOfWith(&Def, NewUnifyingPHI);
        }
      }
    }
  }
}

void RegionMelder::updateMapping(BasicBlock *NewBb, BasicBlock *OldBb,
                                 bool IsLeft) {
  auto It = CurrMapping.begin();
  bool Found = false;
  for (; It != CurrMapping.end(); ++It) {
    if (IsLeft) {
      if (It->first == OldBb) {

        Found = true;
        break;
      }
    } else {
      if (It->second == OldBb) {
        Found = true;
        break;
      }
    }
  }
  assert(Found && "Old exit not found in the mapping!");
  CurrMapping.erase(It);
  if (IsLeft) {
    CurrMapping.insert(
        std::pair<BasicBlock *, BasicBlock *>(NewBb, ExitBlockR));
  } else {
    CurrMapping.insert(
        std::pair<BasicBlock *, BasicBlock *>(ExitBlockL, NewBb));
  }
}

void RegionMelder::runPreMergePasses(bool RegionAlreadySimplified) {

  // check if exit blocks need to be isolated
  if (ExitBlockL) {
    if (!RegionAlreadySimplified) {
      DEBUG << "Left exit not safe to merge\n";
      BasicBlock *OldExitLeft = ExitBlockL;
      ExitBlockL = simplifyRegion(ExitBlockL, EntryBlockL);
      // update the mapping
      updateMapping(ExitBlockL, OldExitLeft, true);
      MA.recomputeControlFlowAnalyses();
    }
  }

  if (ExitBlockR) {
    if (!RegionAlreadySimplified) {
      DEBUG << "Right exit not safe to merge\n";
      BasicBlock *OldExitRight = ExitBlockR;
      ExitBlockR = simplifyRegion(ExitBlockR, EntryBlockR);
      // update the mapping
      updateMapping(ExitBlockR, OldExitRight, false);
      MA.recomputeControlFlowAnalyses();
    }
  }

  mergeOutsideDefsAtEntry();
}

void RegionMelder::runPostOptimizations() {

  INFO << "Running post-merge optimizations\n";

  // check for phi nodes with identical incoming value, block pairs
  // and fold them
  for (auto &BB : *MA.getParentFunction()) {
    for (PHINode &Phi : BB.phis()) {
      bool Changed = false;
      do {
        Changed = false;
        for (unsigned I = 0; I < Phi.getNumIncomingValues(); I++) {
          for (unsigned J = I + 1; J < Phi.getNumIncomingValues(); J++) {
            if (Phi.getIncomingBlock(I) == Phi.getIncomingBlock(J) &&
                Phi.getIncomingValue(I) == Phi.getIncomingValue(J)) {
              Phi.removeIncomingValue(J);
              Changed = true;
              break;
            }
          }
          if(Changed) { break;}
        }
      } while (Changed);
    }
  }

  // remove phi nodes with one incoming value
  SmallVector<PHINode *, 8> PNToDelete;
  for (auto &BB : *MA.getParentFunction()) {
    for (auto &Phi : BB.phis()) {
      if (Phi.getNumIncomingValues() == 1)
        PNToDelete.push_back(&Phi);
    }
  }

  for (PHINode *PN : PNToDelete) {
    DEBUG << "Erasing phi node\n";
    // PN->print(DEBUG);
    // DEBUG << "\n";
    PN->replaceAllUsesWith(PN->getIncomingValue(0));
    PN->eraseFromParent();
  }

  // check for conditional branches with same target and fold them
  for (auto &BB : *MA.getParentFunction()) {
    if (BranchInst *BI = dyn_cast<BranchInst>(BB.getTerminator())) {
      if (BI->getNumSuccessors() == 2 &&
          BI->getSuccessor(0) == BI->getSuccessor(1)) {
        DEBUG << "Converting conditional branch to unconditional\n";
        IRBuilder<> Builder(BI);
        // BasicBlock *singleDest = BI->getSuccessor(0);
        // singleDest->removePredecessor(BI->getParent());
        Builder.CreateBr(BI->getSuccessor(0));
        BI->eraseFromParent();
      }
    }
  }
}
