// Offline-only wave64 branch instrumentation. Never used by static scoring.
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/IntrinsicsAMDGPU.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Analysis/PostDominators.h"
#include "llvm/Analysis/LoopInfo.h"
#include <set>
#include <map>
using namespace llvm;
int main(int argc,char **argv) {
  if(argc!=7){errs()<<"usage: postopt-wave-profile INPUT FUNCTION SPLIT_INDEX OUTPUT LEFT_INDEX RIGHT_INDEX\n";return 2;}
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
  unsigned LI,RI;
  if(StringRef(argv[5]).getAsInteger(10,LI)||StringRef(argv[6]).getAsInteger(10,RI))return 2;
  BasicBlock *Left=nullptr,*Right=nullptr;N=0;
  for(auto &BB:*F){if(N==LI)Left=&BB;if(N==RI)Right=&BB;++N;}
  DominatorTree DT(*F);PostDominatorTree PDT(*F);LoopInfo Loops(DT);
  auto *PN=PDT.getNode(Split);auto *Join=PN&&PN->getIDom()?PN->getIDom()->getBlock():nullptr;
  if(!Left||!Right||Left==Right||!Join||!Loops.empty()||
     !DT.dominates(Split,Left)||!DT.dominates(Split,Right)||
     !PDT.dominates(Join,Left)||!PDT.dominates(Join,Right)){
    errs()<<"pair profile requires acyclic dominated scope and common join\n";return 2;
  }
  // LoopInfo alone does not exclude irreducible cycles.
  std::map<BasicBlock*,unsigned> Degree;SmallVector<BasicBlock*,32> Ready;
  for(auto &BB:*F)Degree[&BB]=0;
  for(auto &BB:*F)for(auto *Next:successors(&BB))++Degree[Next];
  for(auto &KV:Degree)if(!KV.second)Ready.push_back(KV.first);
  unsigned Removed=0;while(!Ready.empty()){auto *BB=Ready.pop_back_val();++Removed;
    for(auto *Next:successors(BB))if(!--Degree[Next])Ready.push_back(Next);}
  if(Removed!=F->size()){errs()<<"cyclic function unsupported by selected-block profile\n";return 2;}
  auto reach=[&](BasicBlock *Start){std::set<BasicBlock*> Seen;SmallVector<BasicBlock*,32> Q{Start};
    while(!Q.empty()){auto *BB=Q.pop_back_val();if(BB==Join||!Seen.insert(BB).second)continue;
      for(auto *Next:successors(BB))Q.push_back(Next);}return Seen;};
  auto T=reach(Branch->getSuccessor(0)),R=reach(Branch->getSuccessor(1));
  if(!T.count(Left)||R.count(Left)||!R.count(Right)||T.count(Right)){
    errs()<<"selected blocks must be exclusive true/false members\n";return 2;
  }
  SmallVector<Type*,8> Types;for(auto &A:F->args())Types.push_back(A.getType());
  Types.push_back(PointerType::get(Type::getInt64Ty(C),1));
  auto *NF=Function::Create(FunctionType::get(F->getReturnType(),Types,false),F->getLinkage(),F->getAddressSpace(),"profile.tmp",M.get());
  NF->copyAttributesFrom(F);NF->setCallingConv(F->getCallingConv());
  NF->removeFnAttr(Attribute::ReadNone);NF->removeFnAttr(Attribute::ReadOnly);
  NF->removeFnAttr(Attribute::NoSync);NF->removeFnAttr(Attribute::Speculatable);
  ValueToValueMapTy Map;auto NI=NF->arg_begin();for(auto &A:F->args()){NI->setName(A.getName());Map[&A]=&*NI++;}
  auto *Counters=&*NI;Counters->setName("wave.profile.counters");
  SmallVector<ReturnInst*,8> Returns;CloneFunctionInto(NF,F,Map,false,Returns);
  // Lane-local flags accumulate branch membership, then ballots at the
  // common postdominator recover wave-level overlap without guessing it.
  IRBuilder<> Entry(&*NF->getEntryBlock().getFirstInsertionPt());
  auto *LT=Entry.CreateAlloca(Entry.getInt1Ty(),nullptr,"profile.left.flag");
  auto *RT=Entry.CreateAlloca(Entry.getInt1Ty(),nullptr,"profile.right.flag");
  Entry.CreateStore(Entry.getFalse(),LT);Entry.CreateStore(Entry.getFalse(),RT);
  IRBuilder<> LB(cast<BasicBlock>(Map[Left])->getTerminator());LB.CreateStore(LB.getTrue(),LT);
  IRBuilder<> RB(cast<BasicBlock>(Map[Right])->getTerminator());RB.CreateStore(RB.getTrue(),RT);
  IRBuilder<> B(&*cast<BasicBlock>(Map[Join])->getFirstInsertionPt());
  auto *I64=B.getInt64Ty();auto *Ballot=Intrinsic::getDeclaration(M.get(),Intrinsic::amdgcn_ballot,{I64});
  auto *True=B.CreateCall(Ballot,{B.CreateLoad(B.getInt1Ty(),LT)},"profile.left");
  auto *False=B.CreateCall(Ballot,{B.CreateLoad(B.getInt1Ty(),RT)},"profile.right");
  auto *Active=B.CreateOr(True,False,"profile.selected.union");
  auto *Lo=B.CreateCall(Intrinsic::getDeclaration(M.get(),Intrinsic::amdgcn_mbcnt_lo),{B.getInt32(-1),B.getInt32(0)});
  auto *Lane=B.CreateCall(Intrinsic::getDeclaration(M.get(),Intrinsic::amdgcn_mbcnt_hi),{B.getInt32(-1),Lo});
  auto *First=B.CreateCall(Intrinsic::getDeclaration(M.get(),Intrinsic::cttz,{I64}),{Active,B.getFalse()});
  auto *Leader=B.CreateICmpEQ(B.CreateZExt(Lane,I64),First);
  auto *HasT=B.CreateICmpNE(True,B.getInt64(0));auto *HasF=B.CreateICmpNE(False,B.getInt64(0));
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
