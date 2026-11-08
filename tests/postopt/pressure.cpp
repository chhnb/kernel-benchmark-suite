#include "ir_pressure.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/SourceMgr.h"
#include <cassert>
using namespace llvm;
int main() {
  LLVMContext ctx;SMDiagnostic err;
  auto m=parseAssemblyString(R"(
define i64 @diamond(i1 %c) {
entry:
 br i1 %c, label %l, label %r
l:
 %a=add i64 1, 2
 br label %join
r:
 %b=add i64 3, 4
 br label %join
join:
 %v=phi i64 [%a,%l], [%b,%r]
 ret i64 %v
dead:
 %unused=add i128 1, 2
 ret i64 0
}
define i32 @loop(i32 %n) {
entry:
 br label %body
body:
 %i=phi i32 [0,%entry], [%next,%body]
 %next=add i32 %i, 1
 %c=icmp slt i32 %next, %n
 br i1 %c, label %body, label %exit
exit:
 ret i32 %next
}
)",err,ctx);
  assert(m);
  auto d=fusion::irPressure(*m->getFunction("diamond"));
  assert(d.complete&&d.reachableBlocks==4&&d.peakValues==1&&d.peakSlots32==2);
  assert(d.blockPeakSlots32.at("%l")==2&&d.blockPeakSlots32.at("%join")==2);
  assert(d.blockCrossingValues.at("%l")==0);
  auto l=fusion::irPressure(*m->getFunction("loop"));
  assert(l.complete&&l.peakValues==3&&l.peakSlots32==3);
  assert(l.blockCrossingValues.at("%body")>=1);
  outs()<<"PASS block-local peaks and crossing values, PHI edges, unreachable blocks, i64 weighting, loop fixed point and argument liveness\n";
}
