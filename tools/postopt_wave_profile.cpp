// Offline-only wave64 branch instrumentation. Never used by static scoring.
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/IntrinsicsAMDGPU.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Transforms/Utils/Cloning.h"
using namespace llvm;
int main(int argc,char **argv) {
  if(argc!=5){errs()<<"usage: postopt-wave-profile INPUT FUNCTION BLOCK_INDEX OUTPUT\n";return 2;}
  LLVMContext C;SMDiagnostic E;auto M=parseIRFile(argv[1],E,C);
  if(!M){E.print(argv[0],errs());return 2;}
  auto *F=M->getFunction(argv[2]);unsigned Index;
  if(StringRef(argv[3]).getAsInteger(10,Index)||!F||F->isDeclaration()||
     F->getCallingConv()!=CallingConv::AMDGPU_KERNEL||!F->use_empty()||
     M->getTargetTriple()!="amdgcn-amd-amdhsa"||
     F->getFnAttribute("target-cpu").getValueAsString()!="gfx906") {
    errs()<<"requires unused gfx906 AMDGPU kernel and numeric block index\n";return 2;
  }
  BasicBlock *Split=nullptr;unsigned N=0;for(auto &B:*F)if(N++==Index)Split=&B;
  auto *Branch=Split?dyn_cast<BranchInst>(Split->getTerminator()):nullptr;
  if(!Branch||!Branch->isConditional()){errs()<<"conditional branch required\n";return 2;}
  SmallVector<Type*,8> Types;for(auto &A:F->args())Types.push_back(A.getType());
  Types.push_back(PointerType::get(Type::getInt64Ty(C),1));
  auto *NF=Function::Create(FunctionType::get(F->getReturnType(),Types,false),F->getLinkage(),F->getAddressSpace(),"profile.tmp",M.get());
  NF->copyAttributesFrom(F);NF->setCallingConv(F->getCallingConv());
  NF->removeFnAttr(Attribute::ReadNone);NF->removeFnAttr(Attribute::ReadOnly);
  NF->removeFnAttr(Attribute::NoSync);NF->removeFnAttr(Attribute::Speculatable);
  ValueToValueMapTy Map;auto NI=NF->arg_begin();for(auto &A:F->args()){NI->setName(A.getName());Map[&A]=&*NI++;}
  auto *Counters=&*NI;Counters->setName("wave.profile.counters");
  SmallVector<ReturnInst*,8> Returns;CloneFunctionInto(NF,F,Map,false,Returns);
  auto *NB=cast<BranchInst>(Map[Branch]);IRBuilder<> B(NB);
  auto *I64=B.getInt64Ty();auto *Ballot=Intrinsic::getDeclaration(M.get(),Intrinsic::amdgcn_ballot,{I64});
  auto *Active=B.CreateCall(Ballot,{B.getTrue()},"profile.active");
  auto *True=B.CreateCall(Ballot,{NB->getCondition()},"profile.true");
  auto *Lo=B.CreateCall(Intrinsic::getDeclaration(M.get(),Intrinsic::amdgcn_mbcnt_lo),{B.getInt32(-1),B.getInt32(0)});
  auto *Lane=B.CreateCall(Intrinsic::getDeclaration(M.get(),Intrinsic::amdgcn_mbcnt_hi),{B.getInt32(-1),Lo});
  auto *First=B.CreateCall(Intrinsic::getDeclaration(M.get(),Intrinsic::cttz,{I64}),{Active,B.getFalse()});
  auto *Leader=B.CreateICmpEQ(B.CreateZExt(Lane,I64),First);
  auto *HasT=B.CreateICmpNE(True,B.getInt64(0));auto *HasF=B.CreateICmpNE(True,Active);
  Value *Flags[]={B.getTrue(),HasT,HasF,B.CreateAnd(HasT,HasF)};
  for(unsigned I=0;I<4;I++){
    auto *Ptr=B.CreateInBoundsGEP(I64,Counters,B.getInt64(I));
    auto *Inc=B.CreateZExt(B.CreateAnd(Leader,Flags[I]),I64);
    B.CreateAtomicRMW(AtomicRMWInst::Add,Ptr,Inc,AtomicOrdering::Monotonic);
  }
  NF->takeName(F);F->eraseFromParent();
  if(verifyModule(*M,&errs()))return 3;
  std::error_code EC;raw_fd_ostream O(argv[4],EC,sys::fs::OF_None);if(EC){errs()<<EC.message();return 2;}M->print(O,nullptr);return 0;
}
