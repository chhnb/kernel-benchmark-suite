#include "postopt_scorer.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/Support/SourceMgr.h"
#include <cassert>
using namespace llvm;
int main(){LLVMContext C;SMDiagnostic E;auto M=parseAssemblyString(R"(
target triple = "amdgcn-amd-amdhsa"
define i32 @k(i1 %c,i32 %x,i32 %y) #0 {
entry:
 br i1 %c,label %left,label %right
left:
 %a=add i32 %x,%y
 br label %join
right:
 %b=call i32 @opaque(i32 %x)
 br label %join
join:
 %v=phi i32 [%a,%left],[%b,%right]
 ret i32 %v
dead:
 %z=call i32 @opaque(i32 %y)
 ret i32 %z
}
declare i32 @opaque(i32)
attributes #0 = { "target-cpu"="gfx906" }
)",E,C);assert(M);auto X=fusion::postOptFeatures(*M->getFunction("k"));assert(X.targetAvailable);
assert(X.blockWork.size()==4&&!X.blockWork.count("%dead"));assert(X.unknown==1&&X.blockWork.at("%right").unknown==1);
double W=0;uint64_t I=0,U=0;for(auto &KV:X.blockWork){auto &B=KV.second;W+=B.work;I+=B.instructions;U+=B.unknown;double S=0;for(auto &K:B.categories)S+=K.second;assert(S==B.work);}
assert(W==X.work&&I==X.instructions&&U==X.unknown);outs()<<"PASS block-work reachable partition and unknown accounting\n";
}
