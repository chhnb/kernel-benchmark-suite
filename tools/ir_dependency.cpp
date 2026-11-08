#include "ir_dependency.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/IntrinsicInst.h"
#include <algorithm>
#include <map>
#include <set>
#include <vector>
using namespace llvm;
namespace fusion {
IRDependency localDependencies(const Function&f) {
  IRDependency result;if(f.isDeclaration())return result;
  std::set<const BasicBlock*> reachable;
  std::vector<const BasicBlock*> pending{&f.getEntryBlock()};
  while(!pending.empty()){
    auto*b=pending.back();pending.pop_back();if(!reachable.insert(b).second)continue;
    for(auto*s:successors(b))pending.push_back(s);
  }
  std::map<const BasicBlock*,uint64_t> indegree;
  for(auto*b:reachable){indegree[b]=0;for(auto*p:predecessors(b))if(reachable.count(p))++indegree[b];}
  for(auto&kv:indegree)if(!kv.second)pending.push_back(kv.first);
  uint64_t visited=0;
  while(!pending.empty()){
    auto*b=pending.back();pending.pop_back();++visited;
    for(auto*s:successors(b))if(!--indegree[s])pending.push_back(s);
  }
  result.cfgHasCycle=visited!=reachable.size();
  for(auto*b:reachable){
    std::map<const Instruction*,uint64_t> depth,selects;
    for(auto&i:*b){
      if(isa<DbgInfoIntrinsic>(i))continue;
      if(auto*intr=dyn_cast<IntrinsicInst>(&i))
        if(intr->getIntrinsicID()==Intrinsic::lifetime_start||intr->getIntrinsicID()==Intrinsic::lifetime_end)continue;
      if(auto*phi=dyn_cast<PHINode>(&i)){result.phiBoundaryUses+=phi->getNumIncomingValues();continue;}
      uint64_t parent=0,selected=0;
      for(const auto&operand:i.operands())if(auto*definition=dyn_cast<Instruction>(operand.get())){
        if(definition->getParent()!=b){++result.crossBlockUses;continue;}
        parent=std::max(parent,depth[definition]);selected=std::max(selected,selects[definition]);
      }
      depth[&i]=parent+1;selects[&i]=selected+(isa<SelectInst>(i)?1:0);
      result.maxDepth=std::max(result.maxDepth,depth[&i]);
      result.maxSelectChain=std::max(result.maxSelectChain,selects[&i]);
      bool sink=i.isTerminator()||i.mayHaveSideEffects();
      for(auto*u:i.users())if(auto*use=dyn_cast<Instruction>(u))if(use->getParent()!=b)sink=true;
      if(sink)result.maxSinkDepth=std::max(result.maxSinkDepth,depth[&i]);
      if(i.mayReadOrWriteMemory())++result.memoryOperations;
      if(auto*call=dyn_cast<CallBase>(&i))if(!call->getCalledFunction()||!call->getCalledFunction()->isIntrinsic())++result.opaqueCalls;
    }
  }
  return result;
}
}
