#include "b2b_optimization_unit.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/Support/SourceMgr.h"
#include <cassert>
using namespace llvm;
int main(){
 LLVMContext ctx;SMDiagnostic err;
 auto m=parseAssemblyString(R"(
 define i32 @f(i1 %p,i1 %q,i32 %x,i32 %y) {
 A: br i1 %p,label %AL,label %AR
 AL: %a=add i32 %x,1
 br label %B
 AR: %b=add i32 %x,2
 br label %B
 B: %u=phi i32 [%a,%AL],[%b,%AR]
 br i1 %q,label %BL,label %BR
 BL: %c=mul i32 %y,3
 br label %out
 BR: %d=mul i32 %y,4
 br label %out
 out: %v=phi i32 [%c,%BL],[%d,%BR]
 %sum=add i32 %u,%v
 ret i32 %sum
 })",err,ctx);assert(m);
 auto *f=m->getFunction("f");auto *a=&f->getEntryBlock();auto *al=a->getTerminator()->getSuccessor(0);auto *b=al->getSingleSuccessor();
 fusion::B2BOptimizationUnit au,bu;
 {fusion::IRIdentity ids(*m);au=fusion::B2BOptimizationUnit::discover(*a,ids);bu=fusion::B2BOptimizationUnit::discover(*b,ids);}
 assert(au.eligible()&&bu.eligible());assert(au.identity!=bu.identity);
 auto before=fusion::IRDependencySnapshot::capture(*m);
 al->front().setOperand(1,ConstantInt::get(Type::getInt32Ty(ctx),7));
 auto after=fusion::IRDependencySnapshot::capture(*m);
 assert(!before.sameReads(after,au.reads));assert(before.sameReads(after,bu.reads));
 assert(before.changesTo(after).within(au.writes,au.writes));
 // An external SSA value available at entry becomes an explicit input with
 // a recorded definition dependency.
 auto *bl=b->getTerminator()->getSuccessor(0);bl->front().setOperand(0,&b->front());
 {fusion::IRIdentity ids(*m);auto rejected=fusion::B2BOptimizationUnit::discover(*b,ids);assert(rejected.eligible() && !rejected.inputs.empty());}
 // A value from only one predecessor is not available at the unit entry.
 bl->front().setOperand(0,&al->front());
 {fusion::IRIdentity ids(*m);auto rejected=fusion::B2BOptimizationUnit::discover(*b,ids);assert(rejected.rejection=="external_operand_definition");}
 outs()<<"PASS B2B boundary discovery: independent reads, explicit SSA inputs, unavailable SSA rejection (not end-to-end reuse)\n";
}
