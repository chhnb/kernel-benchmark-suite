#pragma once
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/Transforms/Utils/ValueMapper.h"
#include <functional>
namespace llvm {
// Narrow opt-in leaf fusion. No replication or speculative execution. All
// rejection checks precede mutation; original decision predicates stay intact.
inline bool fuseCopysignLeaves(BasicBlock *L, BasicBlock *R,
    const std::function<void(const ValueToValueMapTy&)> &transfer,
    std::string &reason) {
  auto reject=[&](const char*s){reason=s;return false;};
  if(L==R||L->hasAddressTaken()||R->hasAddressTaken())return reject("local_leaf_identity_or_address");
  auto *LP=L->getSinglePredecessor(),*RP=R->getSinglePredecessor();
  if(!LP||!RP||LP==RP||LP==R||RP==L)return reject("local_requires_distinct_single_predecessors");
  auto *LB=dyn_cast<BranchInst>(L->getTerminator()),*RB=dyn_cast<BranchInst>(R->getTerminator());
  if(!LB||!RB||!LB->isUnconditional()||!RB->isUnconditional()||LB->getSuccessor(0)!=RB->getSuccessor(0))return reject("local_requires_common_exit");
  auto *J=LB->getSuccessor(0);
  if(J==L||J==R||J==LP||J==RP)return reject("local_cyclic_boundary");
  if(!isa<BranchInst>(LP->getTerminator())||!isa<BranchInst>(RP->getTerminator()))return reject("local_requires_branch_predecessors");
  auto getCall=[](BasicBlock*B)->IntrinsicInst*{
    if(B->size()!=2)return nullptr;
    auto*C=dyn_cast<IntrinsicInst>(&B->front());
    if(!C||C->getIntrinsicID()!=Intrinsic::copysign||!C->getType()->isFloatingPointTy()||C->isMustTailCall()||C->getNumOperandBundles())return nullptr;
    return C;
  };
  auto *A=getCall(L),*B=getCall(R);
  if(!A||!B)return reject("local_requires_copysign_only_leaves");
  if(A->getType()!=B->getType()||A->getCalledFunction()!=B->getCalledFunction()||A->getAttributes()!=B->getAttributes()||A->getCallingConv()!=B->getCallingConv()||A->getFastMathFlags().any()||B->getFastMathFlags().any())return reject("local_call_attributes_mismatch");
  if(!isa<ConstantFP>(A->getArgOperand(0))||!isa<ConstantFP>(B->getArgOperand(0))||A->getArgOperand(1)!=B->getArgOperand(1))return reject("local_requires_constant_magnitudes_same_sign_input");
  for(auto*C:{A,B})for(auto*U:C->users()){
    auto*P=dyn_cast<PHINode>(U);if(!P||P->getParent()!=J)return reject("local_call_has_non_exit_use");
  }
  bool hasResult=false;
  for(auto&P:J->phis()){
    int li=P.getBasicBlockIndex(L),ri=P.getBasicBlockIndex(R);
    if(li<0||ri<0)return reject("local_missing_exit_phi_edge");
    auto*lv=P.getIncomingValue(li),*rv=P.getIncomingValue(ri);
    if(lv==A&&rv==B){hasResult=true;continue;}
    if(lv!=rv||lv==A||lv==B)return reject("local_incompatible_exit_phi");
  }
  if(!hasResult)return reject("local_missing_result_phi");
  auto*M=BasicBlock::Create(L->getContext(),"local.copysign",L->getParent(),J);
  auto*Magnitude=PHINode::Create(A->getType(),2,"local.magnitude",M);
  Magnitude->addIncoming(A->getArgOperand(0),LP);Magnitude->addIncoming(B->getArgOperand(0),RP);
  auto*Shared=cast<CallInst>(A->clone());Shared->setName("local.result");Shared->setArgOperand(0,Magnitude);M->getInstList().push_back(Shared);
  BranchInst::Create(J,M);
  ValueToValueMapTy map;map[A]=Shared;map[B]=Shared;if(transfer)transfer(map);map.clear();
  for(auto&P:J->phis()){
    Value*V=P.getIncomingValueForBlock(L);if(V==A)V=Shared;
    P.removeIncomingValue(L,false);P.removeIncomingValue(R,false);P.addIncoming(V,M);
  }
  for(auto pair:{std::make_pair(LP,L),std::make_pair(RP,R)}){
    auto*T=pair.first->getTerminator();for(unsigned i=0;i<T->getNumSuccessors();++i)if(T->getSuccessor(i)==pair.second)T->setSuccessor(i,M);
  }
  L->eraseFromParent();R->eraseFromParent();reason="local_copysign_shared";return true;
}
}
