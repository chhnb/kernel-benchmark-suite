#pragma once
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/ValueHandle.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Analysis/InstructionSimplify.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Local.h"
#include <set>
#include <vector>
#include <map>
#include <functional>
#include <stdexcept>
namespace fusion {

inline std::string scopedCFGText(llvm::Function &f){std::string s;llvm::raw_string_ostream o(s);f.print(o);return o.str();}
inline bool foldProvenBranch(llvm::Function &f, const std::set<llvm::BasicBlock*> *allowed=nullptr) {
  llvm::DominatorTree dt(f);
  for(auto &b:f){
    if(allowed&&!allowed->count(&b))continue;
    auto *br=llvm::dyn_cast<llvm::BranchInst>(b.getTerminator());if(!br||!br->isConditional())continue;
    std::map<llvm::Value*,bool> facts;
    std::function<void(llvm::Value*,bool,unsigned)> add=[&](llvm::Value *v,bool truth,unsigned depth){
      if(depth>16)return;facts[v]=truth;
      if(auto *sel=llvm::dyn_cast<llvm::SelectInst>(v)){
        auto *t=llvm::dyn_cast<llvm::ConstantInt>(sel->getTrueValue());auto *ff=llvm::dyn_cast<llvm::ConstantInt>(sel->getFalseValue());
        if(t&&t->isOne()!=truth){add(sel->getCondition(),false,depth+1);add(sel->getFalseValue(),truth,depth+1);}
        if(ff&&ff->isOne()!=truth){add(sel->getCondition(),true,depth+1);add(sel->getTrueValue(),truth,depth+1);}
      }
    };
    auto *node=dt.getNode(&b);
    for(auto *parent=node?node->getIDom():nullptr;parent;parent=parent->getIDom()){
      auto *pb=llvm::dyn_cast<llvm::BranchInst>(parent->getBlock()->getTerminator());
      if(!pb||!pb->isConditional()||pb->getSuccessor(0)==pb->getSuccessor(1))continue;
      for(unsigned side=0;side<2;++side){
        llvm::BasicBlockEdge edge(parent->getBlock(),pb->getSuccessor(side));
        if(dt.dominates(edge,&b))add(pb->getCondition(),side==0,0);
      }
    }
    auto it=facts.find(br->getCondition());if(it==facts.end())continue;
    br->setCondition(llvm::ConstantInt::get(llvm::Type::getInt1Ty(f.getContext()),it->second));
    llvm::ConstantFoldTerminator(&b,allowed==nullptr);return true;
  }return false;
}
// Candidate-only cleanup. Never move instructions, rewrite terminators or
// visit unchanged neighboring computations. RAUW of a permitted value may
// update its users, but those users are not added to the optimization scope.
struct LocalSnapshot {
  llvm::WeakVH instruction;
  llvm::BasicBlock *parent;
  std::vector<llvm::Value*> operands;
  std::vector<std::pair<llvm::Value*,llvm::BasicBlock*>> phiEdges;
};
inline std::vector<LocalSnapshot> snapshotLocal(llvm::Function &f) {
  std::vector<LocalSnapshot> out;
  for(auto &b:f)for(auto &i:b){LocalSnapshot s{llvm::WeakVH(&i),&b,{}};
    for(auto &op:i.operands())s.operands.push_back(op.get());
    if(auto*p=llvm::dyn_cast<llvm::PHINode>(&i))for(unsigned n=0;n<p->getNumIncomingValues();++n)s.phiEdges.emplace_back(p->getIncomingValue(n),p->getIncomingBlock(n));
    out.push_back(std::move(s));}
  return out;
}
inline std::set<llvm::Instruction*> changedLocal(llvm::Function &f,const std::vector<LocalSnapshot>&before) {
  std::set<llvm::Instruction*> unchanged;
  for(auto &s:before)if(auto *i=llvm::dyn_cast_or_null<llvm::Instruction>((llvm::Value*)s.instruction)){
    bool same=i->getParent()==s.parent&&i->getNumOperands()==s.operands.size();
    if(same){
      if(auto*p=llvm::dyn_cast<llvm::PHINode>(i)){
        for(unsigned n=0;n<p->getNumIncomingValues();++n)
          same&=std::find(s.phiEdges.begin(),s.phiEdges.end(),std::make_pair(p->getIncomingValue(n),p->getIncomingBlock(n)))!=s.phiEdges.end();
      }else for(unsigned n=0;n<s.operands.size();++n)same&=i->getOperand(n)==s.operands[n];
    }
    if(same)unchanged.insert(i);
  }
  std::set<llvm::Instruction*> changed;
  for(auto &b:f)for(auto &i:b)if(!i.isTerminator()&&!unchanged.count(&i))changed.insert(&i);
  return changed;
}
inline unsigned cleanupScoped(llvm::Function &f,const std::set<llvm::Instruction*>&scope) {
  struct Protected {llvm::WeakVH inst;llvm::BasicBlock *parent;unsigned opcode;std::vector<llvm::WeakTrackingVH> operands;};
  std::vector<Protected> protectedInsts;std::vector<llvm::WeakVH> work;
  for(auto &b:f)for(auto &i:b){
    if(scope.count(&i)){work.push_back(llvm::WeakVH(&i));continue;}
    Protected p{llvm::WeakVH(&i),&b,i.getOpcode(),{}};for(auto &op:i.operands())p.operands.emplace_back(op.get());protectedInsts.push_back(std::move(p));
  }
  auto check=[&](){for(auto &p:protectedInsts){auto*i=llvm::dyn_cast_or_null<llvm::Instruction>((llvm::Value*)p.inst);
    if(!i||i->getParent()!=p.parent||i->getOpcode()!=p.opcode||i->getNumOperands()!=p.operands.size())throw std::runtime_error("scoped_cleanup_changed_protected_instruction");
    for(unsigned n=0;n<p.operands.size();++n)if(i->getOperand(n)!=(llvm::Value*)p.operands[n])throw std::runtime_error("scoped_cleanup_changed_protected_operand");
  }};
  llvm::SimplifyQuery query(f.getParent()->getDataLayout());
  unsigned rounds=0;
  for(;rounds<32;++rounds){bool changed=false;
    for(auto &handle:work){auto*i=llvm::dyn_cast_or_null<llvm::Instruction>((llvm::Value*)handle);if(!i)continue;
      if(auto*v=llvm::SimplifyInstruction(i,query)){if(v!=i){i->replaceAllUsesWith(v);if(llvm::isInstructionTriviallyDead(i)){i->eraseFromParent();changed=true;continue;}}}
      if(llvm::isInstructionTriviallyDead(i)){i->eraseFromParent();changed=true;continue;}
      // Common expressions only among allowed, earlier instructions in this BB.
      if(i->isTerminator()||llvm::isa<llvm::PHINode>(i)||i->mayReadOrWriteMemory()||i->mayHaveSideEffects())continue;
      if(auto*c=llvm::dyn_cast<llvm::CallBase>(i))if(c->isConvergent())continue;
      for(auto &prior:*i->getParent()){if(&prior==i)break;
        if(scope.count(&prior)&&prior.isIdenticalTo(i)){i->replaceAllUsesWith(&prior);i->eraseFromParent();changed=true;break;}}
    }
    check();if(!changed)return rounds+1;
  }
  throw std::runtime_error("scoped_cleanup_did_not_converge");
}
// Fold only short integer compare/select/cast triangles introduced by the
// trial. No loads, calls, division, floating-point operations or original
// body blocks are speculated. This is an opt-in structural cleanup experiment,
// not a target-cost policy.
inline bool foldScopedScalarTriangle(llvm::Function &f,
    const std::set<llvm::BasicBlock*> &created, std::set<llvm::Instruction*> &permitted,
    std::vector<llvm::WeakVH> &work) {
  for (auto &head : f) {
    if (!created.count(&head)) continue;
    auto *br=llvm::dyn_cast<llvm::BranchInst>(head.getTerminator());
    if (!br || !br->isConditional()) continue;
    for (unsigned side=0;side<2;++side) {
      auto *body=br->getSuccessor(side), *join=br->getSuccessor(1-side);
      if (body==join || body==&head || join==&head ||
          !created.count(body) || !created.count(join) || body->hasAddressTaken() ||
          body->getSinglePredecessor()!=&head || body->getSingleSuccessor()!=join)
        continue;
      unsigned count=0;bool safe=true;
      for (auto &i:*body) {
        if (i.isTerminator()) continue;
        ++count;
        bool kind=llvm::isa<llvm::ICmpInst>(i)||llvm::isa<llvm::SelectInst>(i)||
                  llvm::isa<llvm::TruncInst>(i)||llvm::isa<llvm::ZExtInst>(i)||llvm::isa<llvm::SExtInst>(i);
        safe &= kind && i.getType()->isIntegerTy() &&
                i.getType()->getIntegerBitWidth()<=64 &&
                !i.mayReadOrWriteMemory() && llvm::isSafeToSpeculativelyExecute(&i) &&
                permitted.count(&i);
      }
      if (!safe || !count || count>5) continue;
      for (auto &phi:join->phis())
        safe &= permitted.count(&phi) && phi.getBasicBlockIndex(&head)>=0 &&
                phi.getBasicBlockIndex(body)>=0;
      if (!safe) continue;
      while(body->size()>1) body->front().moveBefore(br);
      llvm::IRBuilder<> builder(br);
      for (auto &phi:join->phis()) {
        auto *direct=phi.getIncomingValueForBlock(&head);
        auto *via=phi.getIncomingValueForBlock(body);
        auto *v=builder.CreateSelect(br->getCondition(),side==0?via:direct,
                                    side==0?direct:via,"scoped.triangle.select");
        if(auto *i=llvm::dyn_cast<llvm::Instruction>(v))if(i->getParent()==&head){
          permitted.insert(i);work.emplace_back(i);
        }
        phi.removeIncomingValue(body,false);
        phi.setIncomingValue(phi.getBasicBlockIndex(&head),v);
      }
      auto *jump=llvm::BranchInst::Create(join,br);
      permitted.insert(jump);work.emplace_back(jump);
      br->eraseFromParent();body->eraseFromParent();
      return true;
    }
  }
  return false;
}
// CFG edits are restricted to blocks created by this trial. Boundary
// predecessor terminators and successor PHIs are the only additional edit
// sites. No generic SimplifyCFG or recursive DCE. The opt-in triangle
// mode only speculates the bounded integer operations checked above.
inline unsigned cleanupScopedCFG(llvm::Function &f, const std::set<llvm::Instruction*> &local,
                                  const std::set<llvm::BasicBlock*> &created, bool scalarTriangles=false) {
  std::set<llvm::Instruction*> permitted=local;
  std::vector<llvm::WeakVH> blocks, work;
  for(auto &b:f)if(created.count(&b)){
    blocks.emplace_back(&b);
    for(auto &i:b)permitted.insert(&i);
    for(auto *p:predecessors(&b))permitted.insert(p->getTerminator());
    for(auto *s:successors(&b))for(auto &phi:s->phis())permitted.insert(&phi);
  }
  struct Protected {llvm::WeakVH inst;llvm::BasicBlock *parent;unsigned opcode;std::vector<llvm::WeakTrackingVH> operands;};
  std::vector<Protected> outside;
  for(auto &b:f)for(auto &i:b){
    if(permitted.count(&i)){work.emplace_back(&i);continue;}
    Protected p{llvm::WeakVH(&i),&b,i.getOpcode(),{}};
    for(auto &op:i.operands())p.operands.emplace_back(op.get());
    outside.push_back(std::move(p));
  }
  auto audit=[&](){for(auto &p:outside){auto *i=llvm::dyn_cast_or_null<llvm::Instruction>((llvm::Value*)p.inst);
    if(!i||i->getParent()!=p.parent||i->getOpcode()!=p.opcode||i->getNumOperands()!=p.operands.size())throw std::runtime_error("scoped_cfg_changed_outside_instruction");
    for(unsigned n=0;n<p.operands.size();++n)if(i->getOperand(n)!=(llvm::Value*)p.operands[n])throw std::runtime_error("scoped_cfg_changed_outside_operand");
  }};
  for(unsigned round=1;round<=32;++round){
    auto before=scopedCFGText(f);
    std::set<llvm::Instruction*> scalar;
    for(auto &h:work)if(auto *i=llvm::dyn_cast_or_null<llvm::Instruction>((llvm::Value*)h))if(!i->isTerminator())scalar.insert(i);
    cleanupScoped(f,scalar);
    std::set<llvm::BasicBlock*> live;
    for(auto &h:blocks)if(auto *b=llvm::dyn_cast_or_null<llvm::BasicBlock>((llvm::Value*)h))live.insert(b);
    if(scalarTriangles && foldScopedScalarTriangle(f,live,permitted,work)){
      audit();if(llvm::verifyFunction(f,&llvm::errs()))throw std::runtime_error("scoped_triangle_invalid_ir");
      continue;
    }
    // Fold only conditions implied by dominating edges, within new blocks.
    foldProvenBranch(f,&live);
    for(auto &h:blocks)if(auto *b=llvm::dyn_cast_or_null<llvm::BasicBlock>((llvm::Value*)h))
      if(auto *br=llvm::dyn_cast<llvm::BranchInst>(b->getTerminator()))if(br->isConditional()&&llvm::isa<llvm::ConstantInt>(br->getCondition()))llvm::ConstantFoldTerminator(b,false);
    for(auto &h:blocks){auto *head=llvm::dyn_cast_or_null<llvm::BasicBlock>((llvm::Value*)h);if(!head)continue;
      auto *br=llvm::dyn_cast<llvm::BranchInst>(head->getTerminator());if(!br||!br->isConditional())continue;
      auto *a=br->getSuccessor(0),*b=br->getSuccessor(1);
      if(a==b||!live.count(a)||!live.count(b)||a->size()!=1||b->size()!=1||
         a->getSinglePredecessor()!=head||b->getSinglePredecessor()!=head)continue;
      auto *join=a->getSingleSuccessor();if(!join||join!=b->getSingleSuccessor()||join==head)continue;
      bool safe=true;for(auto &phi:join->phis())safe&=permitted.count(&phi)&&phi.getBasicBlockIndex(a)>=0&&phi.getBasicBlockIndex(b)>=0;
      if(!safe)continue;
      llvm::IRBuilder<> builder(br);
      for(auto &phi:join->phis()){
        auto *v=builder.CreateSelect(br->getCondition(),phi.getIncomingValueForBlock(a),phi.getIncomingValueForBlock(b),"scoped.exit.select");
        if(auto *i=llvm::dyn_cast<llvm::Instruction>(v))if(i->getParent()==head){work.emplace_back(i);permitted.insert(i);}
        phi.removeIncomingValue(a,false);phi.removeIncomingValue(b,false);phi.addIncoming(v,head);
      }
      llvm::BranchInst::Create(join,br);br->eraseFromParent();
      a->eraseFromParent();b->eraseFromParent();break;
    }
    // Bypass only newly-created branch-only blocks. LLVM's utility handles
    // PHI edge compatibility, including multiple edges from one predecessor.
    for(auto &h:blocks){auto *b=llvm::dyn_cast_or_null<llvm::BasicBlock>((llvm::Value*)h);if(!b||b==&f.getEntryBlock()||b->size()!=1)continue;
      auto *br=llvm::dyn_cast<llvm::BranchInst>(b->getTerminator());if(!br||!br->isUnconditional()||br->getSuccessor(0)==b)continue;
      bool safe=true;
      for(auto *p:predecessors(b))safe&=created.count(p)||permitted.count(p->getTerminator());
      for(auto &phi:br->getSuccessor(0)->phis())safe&=permitted.count(&phi);
      if(safe&&llvm::TryToSimplifyUncondBranchFromEmptyBlock(b))break;
    }
    // Join a newly-created block to its sole unconditional predecessor.
    // This only removes a straight-line boundary; no conditional is crossed.
    for(auto &h:blocks){auto *b=llvm::dyn_cast_or_null<llvm::BasicBlock>((llvm::Value*)h);if(!b)continue;
      auto *pred=b->getSinglePredecessor();if(!pred||pred==b)continue;
      auto *br=llvm::dyn_cast<llvm::BranchInst>(pred->getTerminator());if(!br||!br->isUnconditional())continue;
      if(!created.count(pred)&&!permitted.count(br))continue;
      if(llvm::MergeBlockIntoPredecessor(b))break;
    }
    audit();if(llvm::verifyFunction(f,&llvm::errs()))throw std::runtime_error("scoped_cfg_invalid_ir");
    if(scopedCFGText(f)==before)return round;
  }
  throw std::runtime_error("scoped_cfg_did_not_converge");
}

}
