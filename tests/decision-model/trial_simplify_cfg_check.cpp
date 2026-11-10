#include "trial_simplify_cfg.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/Support/SourceMgr.h"
#include <cassert>
using namespace llvm;
int main(){for(bool memory:{false,true}){LLVMContext c;SMDiagnostic e;std::string text=R"(
define float @f(i1 %a, i1 %choose, float* %p) {
entry:
 br label %head
head:
 br i1 %choose, label %yes, label %tail
yes:
 BODY
 br label %tail
tail:
 %carrier = phi float [ %v, %yes ], [ undef, %head ]
 %result = select i1 %choose, float %carrier, float 1.0
 br label %exit
exit:
 ret float %result
})";text.replace(text.find("BODY"),4,memory?"%v = load volatile float, float* %p":"%v = select i1 %a, float 0.0, float 0.5");auto m=parseAssemblyString(text,e,c);assert(m);auto*f=m->getFunction("f");BasicBlock *head=nullptr,*exit=nullptr;for(auto &b:*f){if(b.getName()=="head")head=&b;if(b.getName()=="exit")exit=&b;}auto *outside=f->getEntryBlock().getTerminator();decision::simplifyTrialCFG(*f,head,exit);assert(!verifyModule(*m,&errs()));assert(outside==f->getEntryBlock().getTerminator());assert(cast<BranchInst>(head->getTerminator())->isConditional()==memory);unsigned loads=0;for(auto &b:*f)for(auto &i:b)loads+=isa<LoadInst>(i);assert(loads==unsigned(memory));}outs()<<"safe select folded; volatile load guard and outside boundary preserved\n";}
