#pragma once
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/Transforms/Utils/ValueMapper.h"
#include <functional>
#include <vector>
#include <set>
#include "llvm/Analysis/ValueTracking.h"
namespace llvm {
// Prove implication by the exact cells of two IEEE comparison predicates.
// Thresholds, adjacent representable values, infinities and NaN cover every
// possible truth combination. Signed zero compares identically here.
inline bool copysignHitImplies(FCmpInst *A, bool ATrue, FCmpInst *B, bool BTrue) {
  auto *CA=dyn_cast<ConstantFP>(A->getOperand(1));
  auto *CB=dyn_cast<ConstantFP>(B->getOperand(1));
  if(!CA||!CB||A->getOperand(0)!=B->getOperand(0)||CA->getType()!=CB->getType())return false;
  auto *T=CA->getType();if(!T->isFloatTy()&&!T->isDoubleTy())return false;
  const auto &Sem=CA->getValueAPF().getSemantics();
  std::vector<APFloat> Samples{APFloat::getInf(Sem,true),APFloat::getInf(Sem,false),APFloat::getNaN(Sem)};
  for(auto*C:{CA,CB}){auto X=C->getValueAPF();Samples.push_back(X);auto Lo=X,Hi=X;Lo.next(true);Hi.next(false);Samples.push_back(Lo);Samples.push_back(Hi);}
  auto hit=[&](FCmpInst *I,bool TrueSide,const APFloat&X){
    auto*V=ConstantFP::get(I->getContext(),X);
    auto*Result=dyn_cast<ConstantInt>(ConstantExpr::getFCmp(I->getPredicate(),V,cast<Constant>(I->getOperand(1))));
    return Result && (Result->isOne()==TrueSide);
  };
  for(const auto&X:Samples)if(hit(A,ATrue,X)&&!hit(B,BTrue,X))return false;
  return true;
}
// A region is one shared root computation plus a closed, safely evaluable
// operand-expression DAG. Previously fused selects are ordinary DAG nodes.
struct LocalComputation {
  Instruction *root=nullptr;
  std::vector<Instruction*> operands;
};
inline bool describeLocalComputation(BasicBlock *BB, LocalComputation &D) {
  if(BB->size()<2)return false;
  D.root=BB->getTerminator()->getPrevNode();
  auto *Call=dyn_cast<IntrinsicInst>(D.root);
  bool supported=Call?Call->getIntrinsicID()==Intrinsic::copysign:
      (D.root->isBinaryOp()||D.root->isUnaryOp()||D.root->isCast());
  if(!supported||D.root->getType()->isVoidTy()||D.root->mayReadOrWriteMemory()||D.root->mayHaveSideEffects())return false;
  if(Call&&(Call->isMustTailCall()||Call->getNumOperandBundles()||Call->getFastMathFlags().any()))return false;
  std::set<Instruction*> Needed;
  std::function<bool(Value*)> visit=[&](Value*V){
    auto*I=dyn_cast<Instruction>(V);if(!I||I->getParent()!=BB)return true;
    if(I==D.root||isa<PHINode>(I)||isa<CallBase>(I)||I->isTerminator()||I->mayReadOrWriteMemory()||!isSafeToSpeculativelyExecute(I))return false;
    if(!Needed.insert(I).second)return true;
    for(auto &Op:I->operands())if(!visit(Op))return false;
    return true;
  };
  for(auto &Op:D.root->operands())if(!visit(Op))return false;
  for(auto&I:*BB){if(&I==D.root||I.isTerminator())continue;
    if(!Needed.count(&I))return false;
    for(auto*U:I.users())if(auto*UI=dyn_cast<Instruction>(U)){if(UI->getParent()!=BB)return false;}else return false;
    D.operands.push_back(&I);
  }
  return true;
}
// Recursive local computation fusion. No region replication. Operand DAGs
// may be evaluated on the union path only after speculation-safety checks.
// All rejection checks precede mutation.
inline bool fuseLocalComputations(BasicBlock *L, BasicBlock *R,
    const std::function<void(const ValueToValueMapTy&)> &transfer,
    std::string &reason, bool unionEntry=false) {
  auto reject=[&](const char*s){reason=s;return false;};
  if(L==R||L->hasAddressTaken()||R->hasAddressTaken())return reject("local_leaf_identity_or_address");
  auto *LP=L->getSinglePredecessor(),*RP=R->getSinglePredecessor();
  if(!LP||!RP||LP==R||RP==L)return reject("local_requires_distinct_single_predecessors");
  if(LP==RP&&!unionEntry)return reject("local_requires_distinct_single_predecessors");
  // Orient the chain by control flow, never by leaf numbers or block layout.
  if(unionEntry&&LP!=RP&&LP->getSinglePredecessor()==RP){std::swap(L,R);std::swap(LP,RP);}
  auto *LB=dyn_cast<BranchInst>(L->getTerminator()),*RB=dyn_cast<BranchInst>(R->getTerminator());
  if(!LB||!RB||!LB->isUnconditional()||!RB->isUnconditional()||LB->getSuccessor(0)!=RB->getSuccessor(0))return reject("local_requires_common_exit");
  auto *J=LB->getSuccessor(0);
  if(J==L||J==R||J==LP||J==RP)return reject("local_cyclic_boundary");
  if(!isa<BranchInst>(LP->getTerminator())||!isa<BranchInst>(RP->getTerminator()))return reject("local_requires_branch_predecessors");
  LocalComputation Left,Right;
  if(!describeLocalComputation(L,Left)||!describeLocalComputation(R,Right))return reject(unionEntry?"local_requires_closed_pure_computation":"local_requires_copysign_only_leaves");
  auto *A=Left.root,*B=Right.root;
  if(!A->isSameOperationAs(B)||A->getRawSubclassOptionalData()!=B->getRawSubclassOptionalData())return reject("local_computation_operation_mismatch");
  SmallVector<std::pair<unsigned,MDNode*>,8> AMetadata,BMetadata;
  A->getAllMetadataOtherThanDebugLoc(AMetadata);B->getAllMetadataOtherThanDebugLoc(BMetadata);
  if(AMetadata!=BMetadata)return reject("local_computation_metadata_mismatch");
  if(auto*CA=dyn_cast<CallInst>(A)){
    auto*CB=dyn_cast<CallInst>(B);
    if(!CB||CA->getCalledFunction()!=CB->getCalledFunction()||CA->getAttributes()!=CB->getAttributes()||CA->getCallingConv()!=CB->getCallingConv())return reject("local_call_attributes_mismatch");
  }
  // Keep the legacy PHI-only mode's deliberately narrow contract unchanged.
  if(!unionEntry){
    auto*CA=dyn_cast<IntrinsicInst>(A),*CB=dyn_cast<IntrinsicInst>(B);
    if(!CA||!CB||L->size()!=2||R->size()!=2)return reject("local_requires_copysign_only_leaves");
    if(!isa<ConstantFP>(CA->getArgOperand(0))||!isa<ConstantFP>(CB->getArgOperand(0))||CA->getArgOperand(1)!=CB->getArgOperand(1))return reject("local_requires_constant_magnitudes_same_sign_input");
  }
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
  if(unionEntry){
    auto *First=dyn_cast<BranchInst>(LP->getTerminator());
    auto *Second=dyn_cast<BranchInst>(RP->getTerminator());
    if(!First||!Second||!First->isConditional()||!Second->isConditional())return reject("local_union_requires_conditional_entries");
    bool Diamond=LP==RP;
    BasicBlock*Tail=nullptr;FCmpInst*Cmp1=nullptr,*Cmp2=nullptr;
    std::vector<Instruction*> SecondEntryComparisons;
    bool Hit1True=First->getSuccessor(0)==L,Hit2True=Second->getSuccessor(0)==R;
    if(Diamond){
      if(First->getSuccessor(Hit1True?1:0)!=R)return reject("local_union_invalid_diamond");
    }else{
      if(RP->getSinglePredecessor()!=LP||First->getSuccessor(Hit1True?1:0)!=RP||RP->hasAddressTaken())return reject("local_union_requires_direct_chain");
      Tail=Second->getSuccessor(Hit2True?1:0);
      if(Tail==L||Tail==R||Tail==LP||Tail==RP)return reject("local_union_cyclic_tail");
      Cmp1=dyn_cast<FCmpInst>(First->getCondition());Cmp2=dyn_cast<FCmpInst>(Second->getCondition());
      if(!Cmp1||!Cmp2||Cmp2->getParent()!=RP||Cmp1->getFastMathFlags().any()||Cmp2->getFastMathFlags().any())return reject("local_union_requires_pure_fcmp_chain");
      if(!isa<ConstantFP>(Cmp1->getOperand(1))||!isa<ConstantFP>(Cmp2->getOperand(1))||Cmp1->getOperand(0)!=Cmp2->getOperand(0))return reject("local_union_requires_same_comparison_input");
      // A previous group may retain several pure comparisons in its entry.
      // Move only this bounded entry, and only when all uses belong to the
      // selected computation or this entry's branch.
      for(auto &I:*RP){if(I.isTerminator())continue;
        auto*C=dyn_cast<FCmpInst>(&I);
        if(!C||C->getFastMathFlags().any()||C->getOperand(0)!=Cmp1->getOperand(0)||!isa<ConstantFP>(C->getOperand(1)))return reject("local_union_unsafe_entry_computation");
        for(auto*U:C->users()){auto*UI=dyn_cast<Instruction>(U);if(!UI||(UI!=Second&&UI->getParent()!=R))return reject("local_union_entry_has_external_use");}
        SecondEntryComparisons.push_back(C);
      }
    }
    // All validation above; only pure fcmp is moved across a branch.
    bool Implies=!Diamond&&copysignHitImplies(Cmp1,Hit1True,Cmp2,Hit2True);
    IRBuilder<> Entry(First);
    Value*Enter=nullptr;
    if(!Diamond){
      for(auto*I:SecondEntryComparisons)I->moveBefore(First);
      if(Implies)Enter=Second->getCondition();
      else{
        Value*ChooseA=Hit1True?First->getCondition():Entry.CreateNot(First->getCondition(),"local.choose.a");
        Value*HitB=Hit2True?Second->getCondition():Entry.CreateNot(Second->getCondition(),"local.hit.b");
        Enter=Entry.CreateOr(ChooseA,HitB,"local.entry.union");
      }
    }
    auto*M=Diamond?LP:BasicBlock::Create(L->getContext(),"local.copysign",L->getParent(),J);
    IRBuilder<> Builder(L->getContext());if(Diamond)Builder.SetInsertPoint(First);else Builder.SetInsertPoint(M);
    for(auto*I:Left.operands){if(Diamond)I->moveBefore(First);else I->moveBefore(*M,M->end());}
    for(auto*I:Right.operands){if(Diamond)I->moveBefore(First);else I->moveBefore(*M,M->end());}
    // Builder's insertion point is still before First (diamond) or block end.
    auto*Shared=A->clone();Shared->setName("local.result");
    for(unsigned N=0;N<A->getNumOperands();++N){
      Value*AV=A->getOperand(N),*BV=B->getOperand(N);
      Value*V=AV==BV?AV:Builder.CreateSelect(First->getCondition(),Hit1True?AV:BV,Hit1True?BV:AV,isa<IntrinsicInst>(A)&&N==0?"local.magnitude":"local.operand");
      Shared->setOperand(N,V);
    }
    if(Diamond)Shared->insertBefore(First);else M->getInstList().push_back(Shared);
    ValueToValueMapTy Map;Map[A]=Shared;Map[B]=Shared;if(transfer)transfer(Map);Map.clear();
    for(auto&P:J->phis()){
      Value*V=P.getIncomingValueForBlock(L);if(V==A)V=Shared;
      P.removeIncomingValue(L,false);P.removeIncomingValue(R,false);P.addIncoming(V,M);
    }
    if(Diamond){BranchInst::Create(J,First);First->eraseFromParent();}
    else{
      BranchInst::Create(J,M);
      for(auto&P:Tail->phis())P.replaceIncomingBlockWith(RP,LP);
      BranchInst::Create(Implies&&!Hit2True?Tail:M,Implies&&!Hit2True?M:Tail,Enter,First);First->eraseFromParent();
      RP->eraseFromParent();
    }
    L->eraseFromParent();R->eraseFromParent();
    reason=Diamond?"local_union_diamond":Implies?"local_union_threshold_implication":"local_union_general_or";
    return true;
  }
  auto*M=BasicBlock::Create(L->getContext(),"local.copysign",L->getParent(),J);
  auto*Magnitude=PHINode::Create(A->getType(),2,"local.magnitude",M);
  Magnitude->addIncoming(cast<CallInst>(A)->getArgOperand(0),LP);Magnitude->addIncoming(cast<CallInst>(B)->getArgOperand(0),RP);
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
