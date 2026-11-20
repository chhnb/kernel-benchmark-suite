#include "incremental_ir_identity.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include <cassert>
using namespace llvm;
static std::unique_ptr<Module> parse(StringRef text,LLVMContext &ctx) {
  SMDiagnostic err;auto m=parseAssemblyString(text,err,ctx);
  if(!m){err.print("identity-test",errs());abort();}return m;
}
int main(){
 LLVMContext ctx;
 auto m=parse(R"(
 define i32 @f(i1 %p,i32 %x) {
 entry: br i1 %p,label %left,label %right
 left: %a=add i32 %x,1
 br label %join
 right: %b=add i32 %x,2
 br label %join
 join: %v=phi i32 [%a,%left],[%b,%right]
 ret i32 %v
 })",ctx);
 auto *f=m->getFunction("f");auto &root=f->getEntryBlock();
 auto *l=root.getTerminator()->getSuccessor(0),*r=root.getTerminator()->getSuccessor(1);
 std::string key;uint64_t resultID=0,leftID=0;
 {
  fusion::IRIdentity ids(*m);key=ids.candidate(root,*l,*r);
  resultID=ids.instruction(l->front());leftID=ids.block(*l);
 }
 // Names and instruction-slot numbering do not define identity.
 root.setName("renamed-root");l->setName("renamed-left");r->setName("renamed-right");
 l->front().setName("renamed-result");f->setName("renamed-function");
 {fusion::IRIdentity ids(*m);assert(ids.candidate(root,*l,*r)==key);}
 assert(!verifyModule(*m,&errs()));
 std::string text;raw_string_ostream out(text);m->print(out,nullptr);out.flush();
 LLVMContext fresh;auto reload=parse(text,fresh);
 auto *rf=reload->getFunction("renamed-function");auto &rr=rf->getEntryBlock();
 {fusion::IRIdentity ids(*reload);assert(ids.candidate(rr,*rr.getTerminator()->getSuccessor(0),*rr.getTerminator()->getSuccessor(1))==key);}
 // Normal module cloning retains unambiguous lineage.
 auto clone=CloneModule(*m);
 {fusion::IRIdentity ids(*clone);assert(ids.lookup(resultID));assert(!ids.ambiguous());}
 // Region/instruction cloning may duplicate tags. Neither descendant can
 // authorize reuse until the caller falls back/rebuilds the optimization unit.
 auto *copy=l->front().clone();copy->insertBefore(l->getTerminator());
 {fusion::IRIdentity ids(*m);assert(ids.ambiguous());assert(!ids.lookup(resultID));
  bool rejected=false;try{ids.instruction(l->front());}catch(const std::runtime_error&){rejected=true;}
  assert(rejected);}
 copy->eraseFromParent();
 // Deletion + creation cannot recycle a removed identity, even on a new parse.
 auto *term=l->getTerminator();auto *dest=term->getSuccessor(0);term->eraseFromParent();
 BranchInst::Create(dest,l);
 {fusion::IRIdentity ids(*m);assert(!ids.ambiguous());assert(ids.block(*l)!=leftID);
  assert(ids.lookup(leftID)==nullptr);assert(ids.candidate(root,*l,*r)!=key);}
 assert(!verifyModule(*m,&errs()));
 // A new block changes function order, not existing candidate identities.
 std::string before;
 {fusion::IRIdentity ids(*m);before=ids.candidate(root,*l,*r);}
 auto *newBlock=BasicBlock::Create(ctx,"unreachable",f,l);new UnreachableInst(ctx,newBlock);
 {fusion::IRIdentity ids(*m);assert(ids.candidate(root,*l,*r)==before);}
 assert(!verifyModule(*m,&errs()));
 outs()<<"PASS IR lineage: rename, serialize, clone, duplicate rejection, deletion, renumbering\n";
}
