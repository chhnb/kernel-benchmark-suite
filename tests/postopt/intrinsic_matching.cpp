#include "fusion_search.h"
#include "darm_pair_engine/InstructionMatch.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IR/Constants.h"
#include <stdexcept>
#include "llvm/Analysis/PostDominators.h"
#include "llvm/Support/SourceMgr.h"
using namespace llvm;using namespace fusion;
static void require(bool b,const char*s){if(!b)throw std::runtime_error(s);}
int main(){try{LLVMContext c;SMDiagnostic e;auto m=parseAssemblyString(R"(
declare float @llvm.floor.f32(float) #0
declare float @llvm.copysign.f32(float,float) #0
declare float @llvm.amdgcn.rcp.f32(float) #0
declare float @llvm.fabs.f32(float) #0
declare float @llvm.amdgcn.image.sample.lz.3d.f32.f32(i32 immarg,float,float,float,<8 x i32>,<4 x i32>,i1 immarg,i32 immarg,i32 immarg) #1
define float @pure(float %x,float %y) {
entry:
 %a = call float @llvm.floor.f32(float %x)
 %b = call float @llvm.floor.f32(float %y)
 %c = call float @llvm.copysign.f32(float %x,float %y)
 %d = call float @llvm.copysign.f32(float %y,float %x)
 %e = call float @llvm.amdgcn.rcp.f32(float %x)
 %f = call float @llvm.amdgcn.rcp.f32(float %y)
 %g = call float @llvm.fabs.f32(float %x)
 %h = call float @llvm.fabs.f32(float %y)
 ret float %a
}
define float @sample(i1 %p,float %x,float %y,<8 x i32> %rs,<4 x i32> %ss) {
entry: br i1 %p,label %a,label %b
a:
 %av = call float @llvm.amdgcn.image.sample.lz.3d.f32.f32(i32 1,float %x,float 0.0,float 0.0,<8 x i32> %rs,<4 x i32> %ss,i1 false,i32 0,i32 0)
 br label %j
b:
 %bv = call float @llvm.amdgcn.image.sample.lz.3d.f32.f32(i32 1,float %x,float 0.0,float 0.0,<8 x i32> %rs,<4 x i32> %ss,i1 false,i32 0,i32 0)
 br label %j
j:
 %r = phi float [ %av,%a ],[ %bv,%b ]
 ret float %r
}
attributes #0 = { nounwind readnone speculatable willreturn }
attributes #1 = { nounwind readonly willreturn }
)",e,c);require(bool(m),"parse");require(!verifyModule(*m,&errs()),"input verifier");
 auto inst=[&](StringRef fn,StringRef n)->Instruction*{for(auto&b:*m->getFunction(fn))for(auto&i:b)if(i.getName()==n)return &i;throw std::runtime_error("missing instruction");};
 for(auto names:{std::make_pair("a","b"),std::make_pair("c","d"),std::make_pair("e","f")})require(InstructionMatch::match(inst("pure",names.first),inst("pure",names.second)),"pure whitelist match");
 require(!InstructionMatch::match(inst("pure","g"),inst("pure","h")),"unlisted intrinsic enabled");
 auto*a=cast<CallInst>(inst("sample","av")),*b=cast<CallInst>(inst("sample","bv"));require(InstructionMatch::match(a,b),"same image match");
 b->setArgOperand(0,ConstantInt::get(Type::getInt32Ty(c),2));require(!InstructionMatch::match(a,b),"different immarg accepted");b->setArgOperand(0,a->getArgOperand(0));
 b->setConvergent();require(!InstructionMatch::match(a,b),"convergent accepted");b->setAttributes(a->getAttributes());require(InstructionMatch::match(a,b),"match after removing convergence");
 Candidate pair{"sample","B0","B1","B2",0};auto hash=moduleHash(*m);auto trial=tryPair(*m,pair,0,3,CleanupMode::None);require(trial.valid,trial.reason.c_str());unsigned calls=0;for(auto&bb:*trial.raw->getFunction("sample"))for(auto&i:bb)calls+=isa<CallInst>(i);if(calls!=1)trial.raw->print(errs(),nullptr);require(calls==1,"sample not shared in raw IR");require(moduleHash(*m)==hash,"parent mutated");
 b->setArgOperand(1,m->getFunction("sample")->getArg(2));auto bad=tryPair(*m,pair,0,3,CleanupMode::None);require(bad.valid,bad.reason.c_str());
 unsigned selectedSamples=0;bool selectedCoordinates=false;
 for(auto&bb:*bad.raw->getFunction("sample"))for(auto&i:bb)if(auto*call=dyn_cast<CallInst>(&i)){++selectedSamples;selectedCoordinates=isa<SelectInst>(call->getArgOperand(1));}
 require(selectedSamples==1&&selectedCoordinates,"different coordinates not selected before shared sample");
 b->setArgOperand(0,ConstantInt::get(Type::getInt32Ty(c),2));
 auto separate=tryPair(*m,pair,0,3,CleanupMode::None);require(separate.valid,separate.reason.c_str());
 unsigned separateSamples=0;for(auto&bb:*separate.raw->getFunction("sample"))for(auto&i:bb)separateSamples+=isa<CallInst>(i);
 require(separateSamples==2,"incompatible immediates did not retain separate samples");
 PostDominatorTree pd(*separate.raw->getFunction("sample"));
 for(auto&bb:*separate.raw->getFunction("sample"))for(auto&i:bb)if(isa<CallInst>(i))
   require(!pd.dominates(&bb,&separate.raw->getFunction("sample")->getEntryBlock()),"unmatched sample speculated");
 b->replaceAllUsesWith(m->getFunction("sample")->getArg(2));b->eraseFromParent();
 auto oneSide=tryPair(*m,pair,0,3,CleanupMode::None);require(oneSide.valid,oneSide.reason.c_str());
 PostDominatorTree onePd(*oneSide.raw->getFunction("sample"));unsigned remaining=0;
 for(auto&bb:*oneSide.raw->getFunction("sample"))for(auto&i:bb)if(isa<CallInst>(i)){
   ++remaining;require(!onePd.dominates(&bb,&oneSide.raw->getFunction("sample")->getEntryBlock()),"one-sided sample speculated");
 }
 require(remaining==1,"one-sided sample removed or duplicated");
 outs()<<"PASS pure whitelist, unknown intrinsic rejection, immediate/convergence rejection, raw single sample, selected coordinates, incompatible immediates retained, parent immutability\n";
}catch(const std::exception&e){errs()<<e.what()<<"\n";return 1;}}
