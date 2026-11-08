#pragma once
#include "fusion_search.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/IntrinsicInst.h"
#include <map>
#include <set>
#include <vector>

namespace fusion {
// Narrow cancellation proof, not a cost model for synchronization latency.
// Require one acyclic, path-independent synchronization sequence, with exact
// operation/scope/order and stable block identity in every snapshot. The
// existing legal melding must be confined to a synchronization-free region.
inline bool commonFenceBackground(const ScoreInput &input,
                                  const llvm::Function &control) {
  using namespace llvm;
  auto sync=[](const Instruction &I) {
    if (isa<FenceInst>(I)) return true;
    auto *C=dyn_cast<CallBase>(&I);
    return C && C->getCalledFunction() &&
      C->getCalledFunction()->getName()=="llvm.amdgcn.s.barrier";
  };
  auto sequence=[&](const Function &F,std::vector<std::string> &result) {
    std::set<const BasicBlock*> reachable;
    std::vector<const BasicBlock*> pending{&F.getEntryBlock()};
    while(!pending.empty()) {
      auto *B=pending.back();pending.pop_back();
      if(!reachable.insert(B).second)continue;
      for(auto *S:successors(B))pending.push_back(S);
    }
    std::map<const BasicBlock*,unsigned> degree;
    for(auto *B:reachable)degree[B]=0;
    for(auto *B:reachable)for(auto *S:successors(B))++degree[S];
    std::vector<const BasicBlock*> ready;
    for(auto &B:F)if(reachable.count(&B)&&!degree[&B])ready.push_back(&B);
    std::map<const BasicBlock*,std::vector<std::string>> prefixes;
    std::set<const BasicBlock*> assigned{&F.getEntryBlock()};
    bool haveExit=false;
    for(size_t n=0;n<ready.size();++n) {
      auto *B=ready[n];auto prefix=prefixes[B];unsigned index=0;
      if(!isa<BranchInst>(B->getTerminator())&&!isa<ReturnInst>(B->getTerminator()))return false;
      for(auto &I:*B)if(sync(I)) {
        if(!B->hasName())return false;
        std::string text;raw_string_ostream stream(text);
        // Fence has no SSA operands; printing retains ordering and syncscope.
        if(isa<FenceInst>(I))I.print(stream);
        else {
          auto *C=cast<CallBase>(&I);
          if(C->arg_size()!=0)return false;
          stream<<C->getCalledFunction()->getName()<<":"<<C->getCallingConv();
        }
        stream.flush();prefix.push_back(B->getName().str()+":"+std::to_string(index++)+":"+text);
      }
      if(succ_empty(B)) {
        if(haveExit&&result!=prefix)return false;
        result=prefix;haveExit=true;
      }
      for(auto *S:successors(B)) {
        if(assigned.count(S)&&prefixes[S]!=prefix)return false;
        prefixes[S]=prefix;assigned.insert(S);
        if(!--degree[S])ready.push_back(S);
      }
    }
    return haveExit&&ready.size()==reachable.size()&&!result.empty();
  };
  // Candidate IDs refer to the uncleaned parent, not the control clone.
  const BasicBlock *split=nullptr;unsigned index=0;
  for(auto &B:input.beforeIR)
    if(input.candidate.split=="B"+std::to_string(index++))split=&B;
  if(!split)return false;
  auto *node=input.beforeAnalysis.pdt.getNode(const_cast<BasicBlock*>(split));
  if(!node||!node->getIDom()||!node->getIDom()->getBlock())return false;
  auto *join=node->getIDom()->getBlock();
  std::set<const BasicBlock*> region;
  std::vector<const BasicBlock*> todo;
  for(auto *S:successors(split))todo.push_back(S);
  while(!todo.empty()) {
    auto *B=todo.back();todo.pop_back();if(B==join)continue;
    if(!region.insert(B).second)continue;
    if(!input.beforeAnalysis.dt.dominates(split,B))return false;
    for(auto &I:*B)if(sync(I))return false;
    for(auto *S:successors(B))todo.push_back(S);
  }
  // Both selected scopes must be wholly inside that synchronization epoch.
  for(auto *boundary:{&input.left,&input.right})for(auto &label:boundary->blocks) {
    bool found=false;
    for(auto *B:region) {
      std::string text;raw_string_ostream stream(text);B->printAsOperand(stream,false);stream.flush();
      found|=text==label;
    }
    if(!found)return false;
  }
  std::vector<std::string> parent,baseline,raw,after;
  return sequence(input.beforeIR,parent)&&sequence(control,baseline)&&
    sequence(input.afterRawIR,raw)&&sequence(input.afterIR,after)&&
    parent==baseline&&parent==raw&&parent==after;
}
}
