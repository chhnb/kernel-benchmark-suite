#pragma once
#include "scoped_cfg_cleanup.h"
#include "decision_speculation_tti.h"
#include "llvm/Analysis/PostDominators.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/IR/ValueHandle.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Transforms/Utils/SimplifyCFGOptions.h"
#include <set>
#include <vector>
#include <stdexcept>
namespace decision {
// SimplifyCFG can edit neighbours of BB. Bound traversal AND audit every
// instruction outside the SESE trial, allowing only its exit PHIs to change.
inline unsigned simplifyTrialCFGFull(llvm::Function &f,llvm::BasicBlock *entry,
                                 llvm::BasicBlock *exit,const llvm::TargetTransformInfo *provided=nullptr) {
 using namespace llvm;
 for(auto &bb:f)for(auto &i:bb)if(auto *cb=dyn_cast<CallBase>(&i))if(cb->isConvergent())throw std::runtime_error("full_cleanup_function_contains_convergent");
 if(!entry||!exit||entry==exit)throw std::runtime_error("trial_cleanup_invalid_boundary");
 DominatorTree dt(f);PostDominatorTree pdt(f);
 std::set<BasicBlock*> checked;std::vector<BasicBlock*> check{entry};
 while(!check.empty()){auto*b=check.back();check.pop_back();if(b==exit||!checked.insert(b).second)continue;if(!dt.dominates(entry,b)||!pdt.dominates(exit,b))throw std::runtime_error("trial_cleanup_not_sese");for(auto*s:successors(b))check.push_back(s);}
 std::set<BasicBlock*> owned;std::vector<BasicBlock*> todo{entry};
 while(!todo.empty()){auto *b=todo.back();todo.pop_back();if(b==exit||!owned.insert(b).second)continue;for(auto *s:successors(b))todo.push_back(s);}
 struct Protected {WeakVH inst;BasicBlock *parent;unsigned opcode;std::vector<WeakTrackingVH> operands;};
 std::vector<Protected> outside;
 for(auto &b:f)if(!owned.count(&b))for(auto &i:b){
  if(&b==exit&&isa<PHINode>(i))continue;
  Protected p{WeakVH(&i),&b,i.getOpcode(),{}};for(auto &op:i.operands())p.operands.emplace_back(op.get());outside.push_back(std::move(p));
 }
 std::vector<WeakVH> members;for(auto &b:f)if(owned.count(&b))members.emplace_back(&b);
 WeakVH entryHandle(entry),exitHandle(exit);
 std::unique_ptr<decision::SpeculationTTI> provider;if(!provided)provider=std::make_unique<decision::SpeculationTTI>(f);const auto &tti=provided?*provided:*provider->info;
 // LLVM12 defaults, including bonus threshold 1. No vLLM-specific threshold.
 SimplifyCFGOptions options;
 for(unsigned round=0;round<128;++round){
  auto before=fusion::scopedCFGText(f);
  std::vector<WeakVH> work;owned.clear();todo={entry};
  while(!todo.empty()){auto *b=todo.back();todo.pop_back();if(b==exit||!owned.insert(b).second)continue;for(auto *s:successors(b))todo.push_back(s);}
  std::set<BasicBlock*> known;for(auto &h:members)if(auto *b=dyn_cast_or_null<BasicBlock>((Value*)h))known.insert(b);
  for(auto &b:f)if(owned.count(&b)&&!known.count(&b))members.emplace_back(&b);
  for(auto &h:members)if(auto *b=dyn_cast_or_null<BasicBlock>((Value*)h))if(b!=entry&&b!=exit)work.emplace_back(b);
  bool changed=false;
  for(auto &h:work)if(auto *b=dyn_cast_or_null<BasicBlock>((Value*)h))if(simplifyCFG(b,tti,options)){changed=true;break;}
  std::set<Instruction*> scalar;for(auto &h:members)if(auto *b=dyn_cast_or_null<BasicBlock>((Value*)h))for(auto &i:*b)if(!i.isTerminator())scalar.insert(&i);
  fusion::cleanupScoped(f,scalar);
  changed |= fusion::scopedCFGText(f)!=before;
  if(!entryHandle||!exitHandle)throw std::runtime_error("trial_simplifycfg_deleted_boundary");
  for(auto &p:outside){auto *i=dyn_cast_or_null<Instruction>((Value*)p.inst);if(!i||i->getParent()!=p.parent||i->getOpcode()!=p.opcode||i->getNumOperands()!=p.operands.size())throw std::runtime_error("trial_simplifycfg_changed_outside");for(unsigned n=0;n<p.operands.size();++n)if(i->getOperand(n)!=(Value*)p.operands[n])throw std::runtime_error("trial_simplifycfg_changed_outside_operand");}
  if(verifyFunction(f,&errs()))throw std::runtime_error("trial_simplifycfg_invalid_ir");
  if(!changed)return round;
 }
 throw std::runtime_error("trial_simplifycfg_no_fixed_point");
}
}
