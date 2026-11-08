#include "fusion_search.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Support/SourceMgr.h"
using namespace llvm;using namespace fusion;
int main(){LLVMContext c;SMDiagnostic diag;auto m=parseAssemblyString(R"(
declare float @llvm.copysign.f32(float,float)
define float @f(i1 %p,i1 %q,float %x,i32 %n) {
entry:
 %outside = add i32 %n, 0
 br i1 %p, label %a, label %b
a:
 %a_redundant = select i1 %q, float 1.0, float 1.0
 %av = call float @llvm.copysign.f32(float %a_redundant,float %x)
 br label %j
b:
 %b_redundant = select i1 %q, float 2.0, float 2.0
 %bv = call float @llvm.copysign.f32(float %b_redundant,float %x)
 br label %j
j:
 %v = phi float [ %av, %a ],[ %bv, %b ]
 %nf = uitofp i32 %outside to float
 %result = fadd float %v, %nf
 br i1 %q, label %later_a, label %later_b
later_a: br label %later_join
later_b: br label %later_join
later_join:
 %outside_phi = phi float [ %result, %later_b ], [ %result, %later_a ]
 ret float %outside_phi
}
)",diag,c);if(!m)return 1;auto hash=moduleHash(*m);Candidate pair{"f","B0","B1","B2",0};pair.localCopysign=true;pair.localUnion=true;auto t=tryPair(*m,pair,0,3,CleanupMode::ScopedLocal);
 if(!t.valid||verifyModule(*t.normalized,&errs())||hash!=moduleHash(*m)){errs()<<t.reason;return 2;}
 bool outside=false,outsidePhi=false,selectedRedundant=false;for(auto &b:*t.normalized->getFunction("f"))for(auto &i:b){outside|=i.getName()=="outside";outsidePhi|=i.getName()=="outside_phi";selectedRedundant|=i.getName()=="a_redundant"||i.getName()=="b_redundant";}
 if(!outside||!outsidePhi||selectedRedundant||t.after.instructions>=t.afterRaw.instructions)return 3;
 auto round=makeRound(*m,"f",0,3,CleanupMode::ScopedLocal);if(round.parentFeatures.instructions!=round.controlFeatures.instructions)return 4;
 outs()<<"PASS scoped cleanup removes selected redundant operands, retains outside add-zero, preserves parent and no-fusion control, verifies IR\n";
}
