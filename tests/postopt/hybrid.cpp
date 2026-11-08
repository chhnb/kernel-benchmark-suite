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
 check(argc==2,"TIGRE input required");auto input=parseIRFile(argv[1],diag,ctx);check(bool(input),"parse TIGRE");auto *f=input->getFunction("_Z19kernelPixelDetector8GeometryPfiiP13__hip_texture");check(f,"function missing");auto hash=moduleHash(*input);unsigned regions=0;
 for(auto mode:{CleanupMode::None,CleanupMode::DarmCFG})for(auto c:enumerate(*f,0)){
  if(c.left[0]!='R'||c.right[0]!='R')continue;
  c.hybrid=true;auto t=tryPair(*input,c,0,3,mode);check(t.valid,"Region fallback rejected");check(t.mergePath=="darm-fallback"&&t.localRejectReason=="local_requires_basic_blocks","fallback diagnostics");check(t.left.blocks.size()==2&&t.right.blocks.size()==2,"unexpected region boundary");check(t.left.liveOuts.size()>1&&t.right.liveOuts.size()>1,"multi output coverage");check(!verifyModule(*t.normalized,&errs()),"fallback verifier");check(moduleHash(*input)==hash,"fallback parent mutation");++regions;
 }
 check(regions==6,"expected three region pairs under each cleanup");
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
 outs()<<"PASS local preference; 3 two-block/multi-output fallback pairs under both none and DarmCFG; verifier; parent immutability; side-effect rejection\n";
}catch(const std::exception&e){errs()<<e.what()<<"\n";return 1;}}
