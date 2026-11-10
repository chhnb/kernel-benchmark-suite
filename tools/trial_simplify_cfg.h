#pragma once
#include "scoped_cfg_cleanup.h"
#include "llvm/Analysis/PostDominators.h"
#include "llvm/IR/Dominators.h"
#include <stdexcept>
namespace decision {
// Structural cleanup only. LLVM12 generic SimplifyCFG has unconditional
// speculation paths, so it is deliberately not invoked here. No TTI fallback
// is needed: this path does not make target-cost decisions.
inline unsigned simplifyTrialCFG(llvm::Function &f,llvm::BasicBlock *entry,
                                 llvm::BasicBlock *exit) {
 if(!entry||!exit||entry==exit)throw std::runtime_error("trial_cleanup_invalid_boundary");
 llvm::DominatorTree dt(f);llvm::PostDominatorTree pdt(f);
 std::set<llvm::BasicBlock*> owned;std::vector<llvm::BasicBlock*> todo{entry};
 while(!todo.empty()){
  auto *b=todo.back();todo.pop_back();
  if(b==exit||!owned.insert(b).second)continue;
  if(!dt.dominates(entry,b)||!pdt.dominates(exit,b))
   throw std::runtime_error("trial_cleanup_not_sese");
  for(auto *s:llvm::successors(b))todo.push_back(s);
 }
 std::set<llvm::Instruction*> scalar;
 std::set<llvm::BasicBlock*> removable;
 for(auto *b:owned){
  for(auto &i:*b)scalar.insert(&i);
  if(b!=entry)removable.insert(b);
 }
 // scalarTriangles=false: never hoist arm computations across a condition.
 return fusion::cleanupScopedCFG(f,scalar,removable,false);
}
}
