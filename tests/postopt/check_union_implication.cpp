#include "darm_pair_engine/LocalCopysignFusion.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include <cassert>
using namespace llvm;
int main(){
 LLVMContext C;Module M("implication-test",C);
 for(Type*T:{Type::getFloatTy(C),Type::getDoubleTy(C)}){
  auto*F=Function::Create(FunctionType::get(Type::getVoidTy(C),{T},false),Function::ExternalLinkage,"test",M);
  auto*BB=BasicBlock::Create(C,"entry",F);IRBuilder<> B(BB);auto*X=&*F->arg_begin();
  auto check=[&](FCmpInst::Predicate P,double A,bool PT,FCmpInst::Predicate Q,double D,bool QT,bool expected){
    auto*L=cast<FCmpInst>(B.CreateFCmp(P,X,ConstantFP::get(T,A)));
    auto*R=cast<FCmpInst>(B.CreateFCmp(Q,X,ConstantFP::get(T,D)));
    assert(copysignHitImplies(L,PT,R,QT)==expected);
  };
  check(FCmpInst::FCMP_OLT,.75,true,FCmpInst::FCMP_UGT,1.25,false,true);
  check(FCmpInst::FCMP_OLT,1.25,true,FCmpInst::FCMP_UGT,.75,false,false);
  check(FCmpInst::FCMP_UGT,.25,false,FCmpInst::FCMP_OLT,.75,true,true);
  check(FCmpInst::FCMP_OLE,.75,true,FCmpInst::FCMP_OLT,.75,true,false);
  check(FCmpInst::FCMP_OLT,.75,true,FCmpInst::FCMP_OLE,.75,true,true);
  check(FCmpInst::FCMP_ULT,.75,true,FCmpInst::FCMP_OLE,1.25,true,false); // NaN counterexample
  check(FCmpInst::FCMP_OEQ,-0.0,true,FCmpInst::FCMP_OEQ,+0.0,true,true);
  B.CreateRetVoid();
 }
 assert(!verifyModule(M,&errs()));outs()<<"PASS float32/64 implication, reversed thresholds, strict boundary, NaN and signed zero\n";
}
