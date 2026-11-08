#include "ir_dependency.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include <cassert>
using namespace llvm;using namespace fusion;
int main(){LLVMContext c;SMDiagnostic e;auto m=parseAssemblyString(R"(
define i32 @parallel(i32 %x) {
 %a=add i32 %x,1
 %b=add i32 %x,2
 %c=add i32 %a,%b
 ret i32 %c
}
define i32 @serial(i32 %x) {
 %a=add i32 %x,1
 %b=add i32 %a,2
 %c=add i32 %b,3
 ret i32 %c
}
define i32 @selected(i32 %x,i32 %y,i1 %c) {
 %a=select i1 %c,i32 %x,i32 %y
 %b=add i32 %a,1
 %d=select i1 %c,i32 %b,i32 %x
 ret i32 %d
}
define i32 @loop(i32 %x) {
entry:
 br label %body
body:
 %i=phi i32 [0,%entry],[%next,%body]
 %next=add i32 %i,1
 %more=icmp slt i32 %next,%x
 br i1 %more,label %body,label %exit
exit:
 ret i32 %next
}
define i32 @memory(i32* %p) {
 %v=load i32,i32* %p
 store i32 %v,i32* %p
 ret i32 %v
}
)",e,c);assert(m&&!verifyModule(*m));
auto a=localDependencies(*m->getFunction("parallel"));auto b=localDependencies(*m->getFunction("serial"));
assert(a.maxDepth==3&&b.maxDepth==4&&a.maxSinkDepth==3&&b.maxSinkDepth==4);
assert(localDependencies(*m->getFunction("selected")).maxSelectChain==2);
auto l=localDependencies(*m->getFunction("loop"));assert(l.cfgHasCycle&&l.phiBoundaryUses==2&&l.crossBlockUses==1&&l.maxDepth==3);
auto mem=localDependencies(*m->getFunction("memory"));assert(mem.memoryOperations==2&&mem.maxDepth==2);
}
