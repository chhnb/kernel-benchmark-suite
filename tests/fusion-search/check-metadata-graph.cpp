#include "incremental_ir_snapshot.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/DebugInfoMetadata.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include <cassert>
using namespace llvm;
int main(){
 LLVMContext ctx;SMDiagnostic err;
 auto m=parseAssemblyString(R"(
 define i32 @f(i32 %x) {
 entry:
 %a=add i32 %x,1, !audit !0
 %b=add i32 %a,2, !audit !0
 ret i32 %b
 }
 !anchor = !{!0}
 !0 = distinct !{!0, !"same"}
 )",err,ctx);assert(m);assert(!verifyModule(*m,&errs()));
 auto *a=&m->getFunction("f")->getEntryBlock().front();auto *b=a->getNextNode();
 uint64_t ai;{fusion::IRIdentity ids(*m);ai=ids.instruction(*a);}
 auto before=fusion::IRDependencySnapshot::capture(*m);
 auto clone=CloneModule(*m);auto cloned=fusion::IRDependencySnapshot::capture(*clone);
 assert(before.context==cloned.context);assert(before.instructions==cloned.instructions);
 std::string text;raw_string_ostream stream(text);m->print(stream,nullptr);stream.flush();
 LLVMContext other;auto reloaded=parseAssemblyString(text,err,other);assert(reloaded);
 auto reload=fusion::IRDependencySnapshot::capture(*reloaded);
 assert(before.sameReads(reload,{ai}));
 // Two structurally equal DISTINCT nodes are not the same identity. Preserve
 // the graph relationship between the named anchor and both instruction roots.
 auto *original=a->getMetadata("audit");
 auto *fresh=MDTuple::getDistinct(ctx,{nullptr,MDString::get(ctx,"same")});fresh->replaceOperandWith(0,fresh);
 b->setMetadata("audit",fresh);
 auto separate=fusion::IRDependencySnapshot::capture(*m);
 assert(!before.sameReads(separate,{ai}));assert(before.changesTo(separate).contextChanged);
 b->setMetadata("audit",original);
 assert(before.context==fusion::IRDependencySnapshot::capture(*m).context);
 // Changing just the named anchor must also invalidate cross-root sharing.
 m->getNamedMetadata("anchor")->setOperand(0,fresh);
 assert(before.context!=fusion::IRDependencySnapshot::capture(*m).context);
 m->getNamedMetadata("anchor")->setOperand(0,original);
 original->replaceOperandWith(1,MDString::get(ctx,"changed"));
 assert(before.context!=fusion::IRDependencySnapshot::capture(*m).context);
 // Specialized nodes have fields beyond MD operands: do not hash them as tuples.
 a->setMetadata("audit.di",DIExpression::get(ctx,{}));
 bool rejected=false;try{fusion::IRDependencySnapshot::capture(*m);}catch(const std::runtime_error&){rejected=true;}
 assert(rejected);a->setMetadata("audit.di",nullptr);
 assert(!verifyModule(*m,&errs()));
 outs()<<"PASS metadata graph: cloning, roundtrip, cycles, distinct sharing, named roots, mutation, unsupported specialized nodes\n";
}
