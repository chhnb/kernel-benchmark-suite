#pragma once

#include "darm_pair_engine/RegionMelder.h"
#include "llvm/Analysis/PostDominators.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/SSAUpdater.h"
#include <algorithm>
#include <functional>
#include <set>
#include <vector>

namespace fusion {
using namespace llvm;

struct LeafArm {
  BasicBlock *entry;
  std::set<BasicBlock*> blocks;
};

struct LeafPlanTrace {
  json::Array anchors, rejected, segments;
};

inline void appendSegmentDecisions(const RegionMelder &melder,json::Array &out,
                                   StringRef anchor={}) {
  for(const auto &segment:melder.SegmentDecisions){
    json::Array instructions;
    for(const auto &i:segment.Instructions)
      instructions.push_back(json::Object{{"opcode",i.Opcode},{"weight",i.Weight},
                                         {"tti",i.TTI},{"safe",i.Safe}});
    json::Object row{{"count",segment.Count},{"weight",segment.Weight},
      {"tti",segment.TTI},{"safe",segment.Safe},{"operands_available",segment.Available},
      {"decision",segment.Speculate?"speculate":"protect"},{"reason",segment.Reason},
      {"instructions",std::move(instructions)}};
    if(!anchor.empty())row["anchor"]=anchor.str();
    out.push_back(std::move(row));
  }
}

struct LeafPlanOptions {
  bool coalesce;
  int mode, budget;
  int threshold=4;
  TargetTransformInfo *tti=nullptr;
  std::vector<WeakVH> *speculated=nullptr;
  unsigned *speculatedRanges=nullptr;
  LeafPlanTrace *trace=nullptr;
};

inline std::string leafBlockName(const BasicBlock &block) {
  std::string name;
  raw_string_ostream out(name);
  block.printAsOperand(out,false);
  return out.str();
}

// Move only mandatory, simple-load dependency cones to a dedicated leaf
// prefix. Acyclic read-only leaves with speculatable calls cannot change the
// memory state or prevent the original mandatory loads from executing.
inline unsigned hoistLeafLoads(LeafArm &u, Function &f, BasicBlock *gate) {
  DominatorTree dt(f); PostDominatorTree pdt(f);
  for(auto *b:u.blocks)for(auto &i:*b){
    if(i.isTerminator()||isa<PHINode>(i))continue;
    if(auto *ld=dyn_cast<LoadInst>(&i)){if(!ld->isSimple())return 0;continue;}
    if(i.mayReadOrWriteMemory()||i.mayHaveSideEffects())return 0;
    if(auto *call=dyn_cast<CallBase>(&i))
      if(call->isConvergent()||!isSafeToSpeculativelyExecute(call))return 0;
  }
  SmallVector<Instruction*,32> ordered;
  std::set<Instruction*> selected;
  std::function<bool(Instruction*,SmallVectorImpl<Instruction*>&,std::set<Instruction*>&)> collect;
  collect=[&](Instruction *i,SmallVectorImpl<Instruction*>&pending,std::set<Instruction*>&seen){
    if(selected.count(i)||seen.count(i))return true;
    if(!u.blocks.count(i->getParent()))return dt.dominates(i,gate->getTerminator());
    if(!pdt.dominates(i->getParent(),u.entry)||isa<PHINode>(i)||i->isTerminator())return false;
    auto *ld=dyn_cast<LoadInst>(i);
    if(ld ? !ld->isSimple() : (isa<CallBase>(i)||i->mayReadOrWriteMemory()||!isSafeToSpeculativelyExecute(i)))return false;
    for(auto &op:i->operands())if(auto *d=dyn_cast<Instruction>(op))if(!collect(d,pending,seen))return false;
    seen.insert(i);pending.push_back(i);return true;
  };
  for(auto &b:f)if(u.blocks.count(&b)&&pdt.dominates(&b,u.entry))for(auto &i:b)if(isa<LoadInst>(i)){
    SmallVector<Instruction*,16> pending;std::set<Instruction*> seen;
    if(collect(&i,pending,seen))for(auto *p:pending)if(selected.insert(p).second)ordered.push_back(p);
  }
  if(ordered.empty())return 0;
  auto *prefix=BasicBlock::Create(f.getContext(),"leaf.load.prefix",&f,u.entry);
  auto *end=BranchInst::Create(u.entry,prefix);
  auto *branch=cast<BranchInst>(gate->getTerminator());
  for(unsigned j=0;j<2;++j)if(branch->getSuccessor(j)==u.entry)branch->setSuccessor(j,prefix);
  for(auto *i:ordered)i->moveBefore(end);
  u.blocks.insert(prefix);u.entry=prefix;
  return ordered.size();
}

// Two mutually exclusive straight-line blocks can share a DARM diamond even
// when neither postdominates its enclosing leaf. Keep entry proxies and return
// stubs: only lanes that originally executed an anchor reach its body. SSAUpdater
// carries path-specific values across the new join; no optional load is hoisted.
inline bool meldExclusiveBlocks(BasicBlock *left,BasicBlock *right,Value *choose,
                                const LeafPlanOptions &options,unsigned &groups,std::string &why,
                                StringRef anchor={}) {
  auto &f=*left->getParent();
  auto *lb=dyn_cast<BranchInst>(left->getTerminator());
  auto *rb=dyn_cast<BranchInst>(right->getTerminator());
  if(!lb||!rb||!lb->isUnconditional()||!rb->isUnconditional()||left==right){why="non_straight_anchor";return false;}
  auto reaches=[](BasicBlock *from,BasicBlock *to){
    std::set<BasicBlock*> seen;SmallVector<BasicBlock*,16> work{from};
    while(!work.empty()){auto *b=work.pop_back_val();if(b==to)return true;if(!seen.insert(b).second)continue;
      for(auto *s:successors(b))work.push_back(s);
    }return false;
  };
  if(reaches(left,right)||reaches(right,left)){why="ordered_or_crossing_anchor";return false;}
  for(auto *b:{left,right}){
    if(b->hasAddressTaken()){why="address_taken_anchor";return false;}
    for(auto &i:*b){
      if(i.mayHaveSideEffects()||i.mayWriteToMemory()||i.getType()->isTokenTy()){
        why="side_effect_anchor";return false;
      }
      if(auto *ld=dyn_cast<LoadInst>(&i))if(!ld->isSimple()){why="side_effect_anchor";return false;}
      if(auto *call=dyn_cast<CallBase>(&i))if(call->isConvergent()||call->cannotDuplicate()){
        why="side_effect_anchor";return false;
      }
    }
  }
  auto &ctx=f.getContext();auto *lexit=lb->getSuccessor(0),*rexit=rb->getSuccessor(0);
  auto *lbody=SplitBlock(left,left->getFirstNonPHI());
  auto *rbody=SplitBlock(right,right->getFirstNonPHI());
  auto *gate=BasicBlock::Create(ctx,"anchor.union",&f,lbody);
  auto *join=BasicBlock::Create(ctx,"anchor.return",&f,lexit);
  auto *ltail=BasicBlock::Create(ctx,"anchor.left.return",&f,lexit);
  auto *rtail=BasicBlock::Create(ctx,"anchor.right.return",&f,rexit);
  BranchInst::Create(lexit,ltail);BranchInst::Create(rexit,rtail);
  for(auto &phi:lexit->phis())phi.replaceIncomingBlockWith(lbody,ltail);
  for(auto &phi:rexit->phis())phi.replaceIncomingBlockWith(rbody,rtail);
  cast<BranchInst>(left->getTerminator())->setSuccessor(0,gate);
  cast<BranchInst>(right->getTerminator())->setSuccessor(0,gate);
  // Reuse the original leaf selector. It dominates all anchors and preserves
  // the established divergent predicate rather than reconstructing identity
  // from a new multi-entry PHI. This also avoids redundant selector PHIs.
  BranchInst::Create(lbody,rbody,choose,gate);
  cast<BranchInst>(lbody->getTerminator())->setSuccessor(0,join);
  cast<BranchInst>(rbody->getTerminator())->setSuccessor(0,join);
  BranchInst::Create(ltail,rtail,choose,join);
  DominatorTree dt(f);
  // Record uses before inserting PHIs; otherwise newly created PHI operands
  // would be visited twice. Undefined inputs occur only on the opposite path.
  std::vector<std::pair<Instruction*,SmallVector<Use*,8>>> repair;
  for(auto &b:f)for(auto &i:b){
    SmallVector<Use*,8> uses;
    for(auto &use:i.uses())if(isa<Instruction>(use.getUser())&&!dt.dominates(&i,use))uses.push_back(&use);
    if(!uses.empty())repair.emplace_back(&i,std::move(uses));
  }
  for(auto &item:repair){
    SSAUpdater updater;updater.Initialize(item.first->getType(),"anchor.live");
    updater.AddAvailableValue(item.first->getParent(),item.first);
    for(auto *use:item.second)updater.RewriteUse(*use);
  }
  if(verifyFunction(f,&errs())){why="anchor_ssa_verifier_failed";return false;}
  DominatorTree meldDT(f);PostDominatorTree meldPDT(f);
  RegionAnalyzer analyzer(gate,meldDT,meldPDT);
  analyzer.selectExplicitBlocks(lbody,rbody);
  RegionMelder melder(analyzer,true);
  melder.CoalesceGaps=options.coalesce;
  melder.SpeculationMode=options.mode;
  melder.SpeculationBudget=options.budget;
  melder.SpeculationCostThreshold=options.threshold;
  melder.SpeculationTTI=options.tti;
  melder.SpeculatedInstructions=options.speculated;
  melder.merge(0);
  groups+=melder.CoalescedGapGroups;
  if(options.trace)appendSegmentDecisions(melder,options.trace->segments,anchor);
  if(options.speculatedRanges)*options.speculatedRanges+=melder.SpeculatedRanges;
  if(verifyFunction(f,&errs())){why="anchor_meld_verifier_failed";return false;}
  return true;
}

inline bool meldLeafPlan(Function &f,const LeafPlanOptions &options,LeafArm l,LeafArm r,BasicBlock *gate,
                         unsigned &moved,unsigned &anchors,unsigned &groups,std::vector<std::string> &pairs,std::string &why) {
  for(auto *u:{&l,&r})for(auto *b:u->blocks)for(auto &i:*b)
    if(auto *call=dyn_cast<CallBase>(&i))if(call->isConvergent()||call->cannotDuplicate()){
      why="leaf_plan_convergence_sensitive_call";return false;
    }
  auto *branch=cast<BranchInst>(gate->getTerminator());
  Value *choose=branch->getCondition();
  if(branch->getSuccessor(0)!=l.entry)choose=IRBuilder<>(branch).CreateNot(choose,"leaf.plan.choose");
  WeakTrackingVH selector(choose);
  moved=hoistLeafLoads(l,f,gate);
  moved+=hoistLeafLoads(r,f,gate);
  if(verifyFunction(f,&errs())){why="leaf_load_motion_verifier_failed";return false;}
  PostDominatorTree initialPDT(f);
  struct Pair {WeakVH left,right;double score;std::string label;bool leftRequired,rightRequired;};
  std::vector<Pair> plan;
  for(auto &lb:f)if(l.blocks.count(&lb)&&lb.getSingleSuccessor())
    for(auto &rb:f)if(r.blocks.count(&rb)&&rb.getSingleSuccessor()){
      auto count=[](BasicBlock &b){unsigned n=0;for(auto &i:b)if(!isa<PHINode>(i)&&!i.isTerminator())++n;return n;};
      unsigned n=std::min(count(lb),count(rb));if(!n)continue;
      double sim=Utils::computeBBSimilarty(&lb,&rb);if(sim<=0)continue;
      plan.push_back({WeakVH(&lb),WeakVH(&rb),sim*n,leafBlockName(lb)+" + "+leafBlockName(rb),
        initialPDT.dominates(&lb,l.entry),initialPDT.dominates(&rb,r.entry)});
    }
  std::stable_sort(plan.begin(),plan.end(),[](const Pair &a,const Pair &b){return a.score>b.score;});
  std::set<BasicBlock*> used;
  // No cleanup between anchors: score and clean the whole composite trial.
  for(auto &p:plan){
    auto *lb=dyn_cast_or_null<BasicBlock>((Value*)p.left),*rb=dyn_cast_or_null<BasicBlock>((Value*)p.right);
    if(!lb||!rb||used.count(lb)||used.count(rb))continue;
    std::string reason;
    if(!meldExclusiveBlocks(lb,rb,selector,options,groups,reason,p.label)){
      if(options.trace)options.trace->rejected.push_back(
        json::Object{{"pair",p.label},{"reason",reason}});
      if(reason=="ordered_or_crossing_anchor"||reason=="non_straight_anchor"||reason=="address_taken_anchor"||reason=="side_effect_anchor")continue;
      why=reason;return false;
    }
    used.insert(lb);used.insert(rb);++anchors;pairs.push_back(p.label);
    if(options.trace)options.trace->anchors.push_back(json::Object{{"pair",p.label},
      {"left_must_execute",p.leftRequired},{"right_must_execute",p.rightRequired}});
  }
  if(!anchors){why="no_compatible_multi_anchor";return false;}
  return true;
}

} // namespace fusion
