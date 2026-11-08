#include "postopt_scorer.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/SourceMgr.h"
#include <cassert>
using namespace llvm;using namespace fusion;
int main() {
 LLVMContext ctx;SMDiagnostic error;
 auto m=parseAssemblyString(R"(
target datalayout = "A5"
target triple = "amdgcn-amd-amdhsa"
define amdgpu_kernel void @k(i32 addrspace(1)* %p, i32 %n) #0 {
entry:
 %tid=call i32 @llvm.amdgcn.workitem.id.x()
 %v=add i32 %tid, %n
 %addr=getelementptr i32, i32 addrspace(1)* %p, i32 %tid
 store i32 %v, i32 addrspace(1)* %addr
 ret void
}
define i32 @base(i32 %x, i32 %y, i1 %c) #0 {
 %v=add i32 %x, %y
 ret i32 %v
}
define i32 @redundant_select(i32 %x, i32 %y, i1 %c) #0 {
 %s=select i1 %c, i32 %x, i32 %x
 %v=add i32 %s, %y
 ret i32 %v
}
define i32 @retained_select(i32 %x, i32 %y, i1 %c) #0 {
 %s=select i1 %c, i32 %x, i32 %y
 %v=add i32 %s, %y
 ret i32 %v
}
define i32 @freeze_case(i32 %x) #0 {
 %v=freeze i32 %x
 ret i32 %v
}
define i32 @unknown_call(i32 %x) #0 {
 %v=call i32 @external(i32 %x)
 ret i32 %v
}
define i8 addrspace(5)* @static_alloca() #0 {
entry:
 %p=alloca [2 x i8], align 1, addrspace(5)
 %q=getelementptr [2 x i8], [2 x i8] addrspace(5)* %p, i32 0, i32 0
 ret i8 addrspace(5)* %q
}
define i8 addrspace(5)* @dynamic_alloca(i32 %n) #0 {
entry:
 %p=alloca i8, i32 %n, align 1, addrspace(5)
 ret i8 addrspace(5)* %p
}
declare i32 @external(i32)
declare i32 @llvm.amdgcn.workitem.id.x()
attributes #0 = { "target-cpu"="gfx906" }
)",error,ctx);
 assert(m);auto*f=m->getFunction("k");
 auto x=postOptFeatures(*f);
 assert(x.targetAvailable&&x.uniformityAvailable&&x.unknown==0);
 assert(x.pressure.uniformPeakSlots32>0&&x.pressure.unprovenPeakSlots32>0);
 auto freeze=postOptFeatures(*m->getFunction("freeze_case"));
 assert(freeze.unknown==0&&freeze.categories.at("freeze_fallback_count")==1&&freeze.work>=1);
 auto allocation=postOptFeatures(*m->getFunction("static_alloca"));
 assert(allocation.unknown==1&&allocation.categories.at("static_private_alloca_bytes")==2);
 auto allocationOne=postOptFeatures(*m->getFunction("static_alloca"),1);
 auto allocationSeven=postOptFeatures(*m->getFunction("static_alloca"),7);
 assert(allocationOne.unknown==0&&allocationOne.categories.at("static_alloca_fallback_count")==1);
 assert(allocationSeven.work-allocationOne.work==6);
 assert(postOptFeatures(*m->getFunction("dynamic_alloca"),1).unknown==1);
 auto unknown=postOptFeatures(*m->getFunction("unknown_call"));
 assert(unknown.unknown==1);
 auto base=makeRound(*m,"base",0,3,CleanupMode::DarmCFGEarlyCSE);
 auto redundant=makeRound(*m,"redundant_select",0,3,CleanupMode::DarmCFGEarlyCSE);
 auto retained=makeRound(*m,"retained_select",0,3,CleanupMode::DarmCFGEarlyCSE);
 auto baseWork=postOptFeatures(*base.control->getFunction("base")).work;
 assert(postOptFeatures(*redundant.control->getFunction("redundant_select")).work==baseWork);
 assert(postOptFeatures(*retained.control->getFunction("retained_select")).work>baseWork);
 auto r=makeRound(*m,"k",0,3,CleanupMode::DarmCFGEarlyCSE);
 auto*c=r.control->getFunction("k");Analysis ca(*c);auto fs=features(*c);
 Candidate candidate{"k","","","",0};Boundary boundary;
 ScoreInput input{candidate,*c,*c,*c,ca,ca,fs,fs,fs,boundary,boundary,false};
 PostOptScorer scorer({0,0,0.1});
 auto s=scorer.evaluate(input,r);assert(s.status==ScoreStatus::Scored);
 assert(s.staticGain==0&&s.total==0&&s.metrics.at("baseline_cache_hit")==0);
 s=scorer.evaluate(input,r);assert(s.metrics.at("baseline_cache_hit")==1);
 candidate.version=1;s=scorer.evaluate(input,r);assert(s.status==ScoreStatus::NotEvaluable);
 outs()<<"PASS removed versus retained select cost, explicit freeze fallback, unknown external call coverage, GPU uniformity, identical optimized IR zero gain, cache reuse, stale round rejection\n";
}
