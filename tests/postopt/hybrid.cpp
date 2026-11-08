#include "fusion_search.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include <stdexcept>
using namespace llvm;using namespace fusion;
static void check(bool b,const char*m){if(!b)throw std::runtime_error(m);}
int main(int argc,char**argv){try{
 LLVMContext ctx;SMDiagnostic diag;
 auto fast=parseAssemblyString(R"(
declare float @llvm.copysign.f32(float, float)
define float @f(i1 %p, float %x) {
entry: br i1 %p, label %a, label %b
a:
 %u = call float @llvm.copysign.f32(float 1.0, float %x)
 br label %j
b:
 %v = call float @llvm.copysign.f32(float 2.0, float %x)
 br label %j
j:
 %r = phi float [ %u, %a ], [ %v, %b ]
 ret float %r
}
)",diag,ctx);check(bool(fast),"parse fast");auto before=moduleHash(*fast);bool local=false;
 for(auto mode:{CleanupMode::None,CleanupMode::DarmCFG})for(auto c:enumerate(*fast->getFunction("f"),0)){c.hybrid=true;auto t=tryPair(*fast,c,0,3,mode);if(t.valid){check(t.mergePath=="local-compute","local path not preferred");check(!verifyModule(*t.normalized,&errs()),"local verifier");local=true;}}
 check(local,"no local trial");check(moduleHash(*fast)==before,"local parent mutation");
 auto multi=parseAssemblyString(R"(
define float @multi(i1 %p, i1 %q, float %x) {
entry: br i1 %p, label %a, label %b
a:
 %u = fmul float %x, 2.0
 %v = fadd float %x, 3.0
 br label %j
b:
 %w = fmul float %x, 4.0
 %z = select i1 %q, float %x, float 0.0
 br label %j
j:
 %r = phi float [ %u, %a ], [ %w, %b ]
 %s = phi float [ %v, %a ], [ %z, %b ]
 %o = fadd float %r, %s
 ret float %o
}
)",diag,ctx);check(bool(multi),"parse multi-output");
 auto multiHash=moduleHash(*multi);Candidate mc{"multi","B0","B1","B2",0};mc.hybrid=true;
 auto mt=tryPair(*multi,mc,0,3,CleanupMode::ScopedCFG);
 check(mt.valid&&mt.mergePath=="darm-B2B","pure multi-output/select-root pair must use DARM B2B");
 check(!verifyModule(*mt.normalized,&errs())&&moduleHash(*multi)==multiHash,"multi-output verifier/parent");
 check(argc==2,"TIGRE input required");auto input=parseIRFile(argv[1],diag,ctx);check(bool(input),"parse TIGRE");auto *f=input->getFunction("_Z19kernelPixelDetector8GeometryPfiiP13__hip_texture");check(f,"function missing");auto hash=moduleHash(*input);unsigned regions=0;
 for(auto mode:{CleanupMode::None,CleanupMode::DarmCFG})for(auto c:enumerate(*f,0)){
  if(c.left[0]!='R'||c.right[0]!='R')continue;
  c.hybrid=true;auto t=tryPair(*input,c,0,3,mode);check(t.valid,"Region fallback rejected");check(t.mergePath=="darm-R2R"&&t.planKind=="R2R","fallback diagnostics");check(t.left.blocks.size()==2&&t.right.blocks.size()==2,"unexpected region boundary");check(t.left.liveOuts.size()>1&&t.right.liveOuts.size()>1,"multi output coverage");check(!verifyModule(*t.normalized,&errs()),"fallback verifier");check(moduleHash(*input)==hash,"fallback parent mutation");++regions;
 }
 check(regions==6,"expected three region pairs under each cleanup");
 // Loop-header split: X versus optional Z must be recognized as B2R.
 bool b2r=false,second=false;
 for(auto c:enumerate(*f,0)){
  if(c.split!="B37"||c.left!="B38"||c.right!="B42")continue;
  c.hybrid=true;auto t=tryPair(*input,c,0,3,CleanupMode::StructuralCFG);
  check(t.valid,"loop-header B2R rejected");check(t.planKind=="B2R"&&t.replication&&t.loopHeaderSplit,"B2R plan missing");
  check(t.rightContext.blocks.size()>1,"B2R context missing");check(moduleHash(*input)==hash,"B2R parent mutation");
  auto *next=t.normalized->getFunction(f->getName());
  for(auto nc:enumerate(*next,1)){
   nc.hybrid=true;auto nt=tryPair(*t.normalized,nc,1,3,CleanupMode::StructuralCFG);
   if(nt.valid&&nt.loopHeaderSplit&&nt.replication){check(nt.planKind=="B2R"||nt.planKind=="R2B","recursive plan");second=true;}
  }
  b2r=true;
 }
 check(b2r,"X/Z candidate not enumerated");check(second,"no recursive loop-header replication candidate");
 auto guards=parseAssemblyString(R"(
@g = global i32 0
define void @guards(i1 %p, i1 %q, i1 %r) {
entry:
 %c = select i1 %p, i1 false, i1 %q
 br i1 %c, label %a, label %j
a: br i1 %p, label %impossible, label %b
impossible:
 store i32 1, i32* @g
 br label %j
b: br i1 %r, label %effect, label %j
effect:
 store i32 2, i32* @g
 br label %j
j: ret void
}
)",diag,ctx);check(bool(guards),"parse guard test");
 cleanup(*guards,"guards",3,CleanupMode::StructuralCFG);
 check(!verifyModule(*guards,&errs()),"guard verifier");
 unsigned stores=0;for(auto &b:*guards->getFunction("guards"))for(auto &i:b)if(auto *st=dyn_cast<StoreInst>(&i)){++stores;check(cast<ConstantInt>(st->getValueOperand())->getZExtValue()==2,"impossible effect retained");}
 check(stores==1,"live effect lost");
 auto cyclic=parseAssemblyString(R"(
define float @f(i1 %p, i1 %q, float %x) {
entry: br i1 %p, label %a, label %b
a:
 %u = fadd float %x, 1.0
 br i1 %q, label %a, label %j
b:
 %v = fadd float %x, 2.0
 br label %j
j:
 %r = phi float [ %u, %a ], [ %v, %b ]
 ret float %r
}
)",diag,ctx);check(bool(cyclic),"parse cycle");Candidate cycle{"f","B0","B1","B2",0};cycle.hybrid=true;
 auto bad=tryPair(*cyclic,cycle,0,3,CleanupMode::StructuralCFG);check(!bad.valid&&bad.reason=="loop_in_trial_scope_not_supported","cyclic scope guard lost");
 auto unsafe=parseAssemblyString(R"(
@g = global float 0.0
define float @f(i1 %p, float %x) {
entry: br i1 %p, label %a, label %b
a:
 store float %x, float* @g
 %u = fadd float %x, 1.0
 br label %j
b:
 %v = fadd float %x, 2.0
 br label %j
j:
 %r = phi float [ %u, %a ], [ %v, %b ]
 ret float %r
}
)",diag,ctx);check(bool(unsafe),"parse unsafe");hash=moduleHash(*unsafe);Candidate c{"f","B0","B1","B2",0};c.hybrid=true;auto rejected=tryPair(*unsafe,c,0,3,CleanupMode::None);check(!rejected.valid&&rejected.reason=="side_effect_in_trial_scope_not_supported","side effect guard");check(moduleHash(*unsafe)==hash,"rejected parent mutation");
 outs()<<"PASS structural dispatch; R2R; loop-header B2R and recursive replication; proven guards; cyclic scope and side-effect rejection; verifier; parent immutability\n";
}catch(const std::exception&e){errs()<<e.what()<<"\n";return 1;}}
