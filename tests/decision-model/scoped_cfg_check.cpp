#include "scoped_cfg_cleanup.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/Support/SourceMgr.h"
#include <cassert>
using namespace llvm;
int main(){LLVMContext c;SMDiagnostic e;auto m=parseAssemblyString(R"(
define i32 @f(i32 %x) {
entry:
 %outside = add i32 %x, 7
 br label %head
head:
 br i1 true, label %yes, label %no
yes:
 br label %join
no:
 br label %join
join:
 %p = phi i32 [ 1, %yes ], [ 2, %no ]
 %result = add i32 %outside, %p
 ret i32 %result
})",e,c);assert(m);auto *f=m->getFunction("f");std::set<BasicBlock*> created;for(auto &b:*f)if(b.getName()=="head"||b.getName()=="yes"||b.getName()=="no")created.insert(&b);auto *outside=&f->getEntryBlock().front();fusion::cleanupScopedCFG(*f,{},created);assert(!verifyModule(*m,&errs()));assert(outside->getParent()==&f->getEntryBlock());for(auto &b:*f)if(auto *br=dyn_cast<BranchInst>(b.getTerminator()))assert(!br->isConditional());outs()<<"scoped constant branch and outside protection OK\n";}
