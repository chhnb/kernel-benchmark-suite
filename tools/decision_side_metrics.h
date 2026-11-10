#pragma once
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Analysis/InstructionSimplify.h"
#include "llvm/IR/CFG.h"
#include <set>
#include <map>
#include <algorithm>
namespace decision_side {
inline bool sideBlocks(llvm::Function &f,llvm::Value *cond,bool value,std::vector<unsigned> &out,std::string &why) {
  using namespace llvm;
  out.clear();
  if(!cond||!cond->getType()->isIntegerTy(1)){why="side_condition_not_i1";return false;}
  ValueToValueMapTy vm;Function *clone=CloneFunction(&f,vm);
  struct Erase{Function *f;~Erase(){f->eraseFromParent();}} erase{clone};
  Value *c=cond;if(!isa<Constant>(cond))c=vm.lookup(cond);
  if(!c){why="side_condition_unmapped";return false;}
  auto *k=ConstantInt::get(Type::getInt1Ty(f.getContext()),value);
  SimplifyQuery query(f.getParent()->getDataLayout());
  SmallVector<Instruction*,64> work;
  auto users=[&](Value *v){for(auto *u:v->users())if(auto *i=dyn_cast<Instruction>(u))work.push_back(i);};
  if(!isa<Constant>(c)){users(c);c->replaceAllUsesWith(k);}
  for(unsigned guard=0;!work.empty();){
    if(++guard>200000){why="side_simplification_budget";return false;}
    auto *i=work.pop_back_val();
    if(auto *v=SimplifyInstruction(i,query))if(v!=i){users(i);i->replaceAllUsesWith(v);}
  }
  std::map<BasicBlock*,unsigned> index;unsigned n=0;for(auto &b:*clone)index[&b]=n++;
  std::set<BasicBlock*> seen;SmallVector<BasicBlock*,32> todo{&clone->getEntryBlock()};
  while(!todo.empty()){
    auto *b=todo.pop_back_val();if(!seen.insert(b).second)continue;
    auto *t=b->getTerminator();
    if(auto *br=dyn_cast<BranchInst>(t))if(br->isConditional())if(auto *ci=dyn_cast<ConstantInt>(br->getCondition())){
      todo.push_back(br->getSuccessor(ci->isZero()?1:0));continue;
    }
    if(auto *sw=dyn_cast<SwitchInst>(t))if(auto *ci=dyn_cast<ConstantInt>(sw->getCondition())){
      todo.push_back(sw->findCaseValue(ci)->getCaseSuccessor());continue;
    }
    for(auto *s:successors(b))todo.push_back(s);
  }
  for(auto *b:seen)out.push_back(index.at(b));
  std::sort(out.begin(),out.end());
  return true;
}
inline bool sideBlocksBoth(llvm::Function &f,llvm::Value *cond,std::vector<unsigned> (&sides)[2],std::string &why) {
  return sideBlocks(f,cond,false,sides[0],why)&&sideBlocks(f,cond,true,sides[1],why);
}

}
