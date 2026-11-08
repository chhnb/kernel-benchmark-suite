#pragma once
// Conservative lane-predicate equivalence, not an IR semantic-equivalence proof.
#include "llvm/IR/CFG.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/ModuleSlotTracker.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/SHA1.h"
#include "llvm/ADT/StringExtras.h"
#include <map>
#include <set>
#include <tuple>
#include <vector>
#include <stdexcept>


namespace fusion { namespace profile_detail {
using namespace llvm;
struct BDD {
 struct Node{unsigned var,lo,hi;};std::vector<Node> nodes{{~0u,0,0},{~0u,1,1}};
 std::map<std::tuple<unsigned,unsigned,unsigned>,unsigned> unique,cache;
 unsigned node(unsigned v,unsigned l,unsigned h){if(l==h)return l;auto key=std::make_tuple(v,l,h);auto it=unique.find(key);if(it!=unique.end())return it->second;if(nodes.size()>=100000)throw std::runtime_error("bdd_budget_exceeded");unsigned n=nodes.size();nodes.push_back({v,l,h});return unique[key]=n;}
 unsigned apply(unsigned op,unsigned a,unsigned b){if(a>b)std::swap(a,b);if(a<2&&b<2)return op==0?(a&b):op==1?(a|b):(a^b);auto key=std::make_tuple(op,a,b);auto it=cache.find(key);if(it!=cache.end())return it->second;auto v=std::min(nodes[a].var,nodes[b].var);auto aa=nodes[a],bb=nodes[b];auto lo=apply(op,aa.var==v?aa.lo:a,bb.var==v?bb.lo:b);auto hi=apply(op,aa.var==v?aa.hi:a,bb.var==v?bb.hi:b);return cache[key]=node(v,lo,hi);}
 unsigned land(unsigned a,unsigned b){return apply(0,a,b);}unsigned lor(unsigned a,unsigned b){return apply(1,a,b);}unsigned neg(unsigned a){return apply(2,a,1);}
};
struct Matcher {
 std::map<std::pair<const Value*,const Value*>,bool> memo;
 std::map<const LoadInst*,bool> cleanLoads;
 bool cleanLoad(const LoadInst *L){auto old=cleanLoads.find(L);if(old!=cleanLoads.end())return old->second;
  if(L->isVolatile()||L->isAtomic())return cleanLoads[L]=false;
  // A read of initial memory is comparable only when no preceding path can
  // write memory. The enclosing analysis rejects cycles before matching.
  for(auto &I:*L->getParent()){if(&I==L)break;if(I.mayWriteToMemory())return cleanLoads[L]=false;}
  std::set<const BasicBlock*> seen;std::vector<const BasicBlock*> todo;
  for(auto *P:predecessors(L->getParent()))todo.push_back(P);
  while(!todo.empty()){auto *B=todo.back();todo.pop_back();if(!seen.insert(B).second)continue;
   for(auto &I:*B)if(I.mayWriteToMemory())return cleanLoads[L]=false;
   for(auto *P:predecessors(B))todo.push_back(P);}
  return cleanLoads[L]=true;
 }
 bool pureCall(const CallInst *C){auto *F=C->getCalledFunction();if(!F||!F->isIntrinsic()||!C->doesNotAccessMemory()||C->hasOperandBundles())return false;
  auto N=F->getName();for(auto Prefix:{"llvm.fabs.","llvm.fma.","llvm.sqrt.","llvm.ctlz.","llvm.cttz.","llvm.ctpop.","llvm.amdgcn.frexp.","llvm.amdgcn.ldexp.","llvm.amdgcn.rcp.","llvm.amdgcn.workitem.id.","llvm.amdgcn.workgroup.id."})if(N.startswith(Prefix))return true;
  return N=="llvm.amdgcn.dispatch.ptr";
 }
 bool same(const Value *A,const Value *B){
  if(isa<UndefValue>(A)||isa<UndefValue>(B))return false;
  if(auto *K=dyn_cast<Constant>(A))if(!isa<GlobalValue>(K))
    for(auto &O:K->operands())if(!same(O.get(),O.get()))return false;
  if(auto *K=dyn_cast<Constant>(B))if(!isa<GlobalValue>(K))
    for(auto &O:K->operands())if(!same(O.get(),O.get()))return false;
  if(A==B)return true;if(A->getType()!=B->getType())return false;
  auto key=std::make_pair(A,B);auto old=memo.find(key);if(old!=memo.end())return old->second;memo[key]=false;
  if(auto *AA=dyn_cast<Argument>(A)){auto *AB=dyn_cast<Argument>(B);return memo[key]=AB&&AA->getArgNo()==AB->getArgNo()&&AA->getParent()->getFunctionType()==AB->getParent()->getFunctionType()&&AA->getParent()->getAttributes()==AB->getParent()->getAttributes();}
  if(auto *FA=dyn_cast<Function>(A)){auto *FB=dyn_cast<Function>(B);return memo[key]=FB&&FA->isIntrinsic()&&FB->isIntrinsic()&&FA->getIntrinsicID()==FB->getIntrinsicID()&&FA->getAttributes()==FB->getAttributes();}
  auto *IA=dyn_cast<Instruction>(A),*IB=dyn_cast<Instruction>(B);if(!IA||!IB||!IA->isSameOperationAs(IB))return false;
  if(isa<PHINode>(IA)||isa<FreezeInst>(IA)||IA->isTerminator()||IA->mayWriteToMemory())return false;
  if(auto *L=dyn_cast<LoadInst>(IA)){if(!cleanLoad(L)||!cleanLoad(cast<LoadInst>(IB)))return false;}
  else if(auto *C=dyn_cast<CallInst>(IA)){if(!pureCall(C)||!pureCall(cast<CallInst>(IB)))return false;}
  else if(IA->mayReadFromMemory()||IA->mayHaveSideEffects()||isa<AllocaInst>(IA))return false;
  for(unsigned I=0;I<IA->getNumOperands();++I)if(!same(IA->getOperand(I),IB->getOperand(I)))return false;
  // Check exact special state and poison-producing flags after replacing
  // structurally equal operands. The detached clone never enters either IR.
  auto *Clone=IB->clone();for(unsigned I=0;I<IA->getNumOperands();++I)Clone->setOperand(I,IA->getOperand(I));
  bool Equal=IA->isIdenticalTo(Clone);Clone->deleteValue();return memo[key]=Equal;
 }
};
struct Conditions {
 BDD bdd;Matcher matcher;std::vector<const Value*> atoms;std::map<const Value*,unsigned> expressions;
 std::vector<BasicBlock*> order(Function &F){std::set<BasicBlock*> seen;std::vector<BasicBlock*> todo{&F.getEntryBlock()};while(!todo.empty()){auto *B=todo.back();todo.pop_back();if(!seen.insert(B).second)continue;for(auto *N:successors(B))todo.push_back(N);}
  std::map<BasicBlock*,unsigned> degree;for(auto *B:seen)degree[B]=0;for(auto *B:seen)for(auto *N:successors(B))++degree[N];
  std::vector<BasicBlock*> ready,out;for(auto &B:F)if(seen.count(&B)&&!degree[&B])ready.push_back(&B);
  for(size_t I=0;I<ready.size();++I){auto *B=ready[I];out.push_back(B);for(auto *N:successors(B))if(!--degree[N])ready.push_back(N);}
  if(out.size()!=seen.size())throw std::runtime_error("cyclic_cfg_unsupported");
  for(auto *B:out)if(!isa<BranchInst>(B->getTerminator())&&!isa<ReturnInst>(B->getTerminator())&&!isa<UnreachableInst>(B->getTerminator()))throw std::runtime_error("non_branch_cfg_unsupported");return out;
 }
 unsigned expr(const Value *V){if(isa<UndefValue>(V))throw std::runtime_error("undefined_boolean_unsupported");auto old=expressions.find(V);if(old!=expressions.end())return old->second;
  if(auto *C=dyn_cast<ConstantInt>(V))return C->isZero()?0:1;
  unsigned R;
  if(auto *S=dyn_cast<SelectInst>(V)){auto C=expr(S->getCondition());R=bdd.lor(bdd.land(C,expr(S->getTrueValue())),bdd.land(bdd.neg(C),expr(S->getFalseValue())));}
  else if(auto *B=dyn_cast<BinaryOperator>(V)){unsigned Op=B->getOpcode();if(Op==Instruction::And||Op==Instruction::Or||Op==Instruction::Xor)R=bdd.apply(Op==Instruction::And?0:Op==Instruction::Or?1:2,expr(B->getOperand(0)),expr(B->getOperand(1)));else R=atom(V);}
  else R=atom(V);return expressions[V]=R;
 }
 unsigned atom(const Value *V){for(unsigned I=0;I<atoms.size();++I)if(matcher.same(V,atoms[I]))return bdd.node(I,0,1);unsigned I=atoms.size();atoms.push_back(V);return bdd.node(I,0,1);}
 std::map<const BasicBlock*,unsigned> reach(const std::vector<BasicBlock*> &Order){std::map<const BasicBlock*,unsigned> R;R[Order.front()]=1;
  for(auto *BB:Order){auto *Br=dyn_cast<BranchInst>(BB->getTerminator());if(!Br)continue;unsigned C=Br->isConditional()?expr(Br->getCondition()):1;
   for(unsigned I=0;I<Br->getNumSuccessors();++I){auto *Next=Br->getSuccessor(I);auto Edge=bdd.land(R[BB],I==0?C:bdd.neg(C));R[Next]=bdd.lor(R[Next],Edge);}}
  return R;
 }
};

}}
