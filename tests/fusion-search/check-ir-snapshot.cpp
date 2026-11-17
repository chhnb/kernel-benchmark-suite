#include "incremental_ir_snapshot.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/IR/Verifier.h"
#include <cassert>
using namespace llvm;
int main(){
 LLVMContext ctx;SMDiagnostic error;
 auto m=parseAssemblyString(R"(
 define i32 @f(i32 %x,i32 %y) {
 entry:
 %a=add i32 %x,1
 %b=mul i32 %y,3
 %c=add i32 %a,%b
 ret i32 %c
 })",error,ctx);assert(m);
 auto &block=m->getFunction("f")->getEntryBlock();
 auto *a=&block.front();auto *b=a->getNextNode();auto *c=b->getNextNode();
 uint64_t ai,bi,ci;
 {fusion::IRIdentity ids(*m);ai=ids.instruction(*a);bi=ids.instruction(*b);ci=ids.instruction(*c);}
 auto before=fusion::IRDependencySnapshot::capture(*m);
 // Modify A while B's instruction and users remain unchanged.
 a->setOperand(1,ConstantInt::get(Type::getInt32Ty(ctx),2));
 auto after=fusion::IRDependencySnapshot::capture(*m);
 assert(before.sameReads(after,{bi}));assert(!before.sameReads(after,{ai}));
 auto diff=before.changesTo(after);assert(diff.changed==std::set<uint64_t>{ai});
 assert(diff.within({ai},{ai}));assert(!diff.within({bi},{bi}));
 // An extra downstream use is a read dependency even when B itself is identical.
 c->setOperand(0,b);
 auto extraUse=fusion::IRDependencySnapshot::capture(*m);
 assert(!after.sameReads(extraUse,{ai}));
 assert(!after.sameReads(extraUse,{bi})); // Same user, now two operand uses.
 // B already used c: add a genuinely distinct use to test its use-list invalidation.
 auto *newUse=BinaryOperator::CreateAdd(b,ConstantInt::get(Type::getInt32Ty(ctx),1),"newuse",c);
 auto used=fusion::IRDependencySnapshot::capture(*m);
 assert(!extraUse.sameReads(used,{bi}));
 uint64_t added;{fusion::IRIdentity ids(*m);added=ids.instruction(*newUse);}
 auto writes=extraUse.changesTo(used);assert(writes.added==std::set<uint64_t>{added});
 assert(!writes.within({},{}));assert(writes.within({},{added}));
 // Cosmetic renames are not dependency changes.
 a->setName("a-new");b->setName("b-new");block.setName("entry-new");
 auto renamed=fusion::IRDependencySnapshot::capture(*m);
 assert(used.sameReads(renamed,{ai,bi,ci,added}));
 // Target/function context cannot be silently omitted.
 m->getFunction("f")->addFnAttr("target-cpu","gfx906");
 auto context=fusion::IRDependencySnapshot::capture(*m);
 assert(!renamed.sameReads(context,{bi}));assert(renamed.changesTo(context).contextChanged);
 // Unmodelled semantic metadata is rejected, not ignored.
 b->setMetadata("range",MDNode::get(ctx,{ConstantAsMetadata::get(ConstantInt::get(Type::getInt32Ty(ctx),0)),ConstantAsMetadata::get(ConstantInt::get(Type::getInt32Ty(ctx),10))}));
 bool rejected=false;try{fusion::IRDependencySnapshot::capture(*m);}catch(const std::runtime_error&){rejected=true;}
 assert(rejected);b->setMetadata("range",nullptr);
 assert(!verifyModule(*m,&errs()));
 outs()<<"PASS snapshot: independent writes, external uses, boundary escape, renaming, target context, unsupported metadata\n";
}
