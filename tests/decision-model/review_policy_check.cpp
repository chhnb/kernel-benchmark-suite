#include "trial_simplify_cfg.h"
#include "condition_simplify.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/Support/SourceMgr.h"
#include <stdexcept>
using namespace llvm;
static std::string phase;
static void require(bool b){if(!b)throw std::runtime_error("review policy assertion failed: "+phase);}
int main(){
 for(auto mode:{"ieee","preserve-sign","positive-zero"}){phase=mode;
  LLVMContext c;SMDiagnostic e;std::string text=R"(
define i1 @f(float %x) #0 {
 %a = fcmp olt float %x, 0x36A0000000000000
 %b = fcmp olt float %x, 1.0
 %v = or i1 %a, %b
 ret i1 %v
}
attributes #0 = { "denormal-fp-math"="MODE" }
)";text.replace(text.find("MODE"),4,mode);auto m=parseAssemblyString(text,e,c);require(bool(m));auto*f=m->getFunction("f");auto*ret=cast<ReturnInst>(f->front().getTerminator());auto*root=cast<Instruction>(ret->getReturnValue());auto*v=decision::simplifyCondition(root);require((v==root)==(std::string(mode)!="ieee"));require(!verifyModule(*m,&errs()));
 }
 for(int variant:{0,1,2}){phase="SESE "+std::to_string(variant);
 LLVMContext c;SMDiagnostic e;std::string text=R"(
define void @f(i1 %p, i1 %q) {
entry: br i1 %p, label %head, label %other
head: br i1 %q, label %body, label %exit
body: br label %exit
other: br label %DEST
exit: ret void
}
)";text.replace(text.find("%DEST"),5,variant==1?"%body":"%exit");if(variant==2)text.replace(text.find("body: br label %exit"),std::string("body: br label %exit").size(),"body: ret void");auto m=parseAssemblyString(text,e,c);require(bool(m));auto*f=m->getFunction("f");BasicBlock *head=nullptr,*exit=nullptr;for(auto&b:*f){if(b.getName()=="head")head=&b;if(b.getName()=="exit")exit=&b;}bool rejected=false;try{decision::simplifyTrialCFG(*f,head,exit);}catch(const std::runtime_error&e){errs()<<phase<<": "<<e.what()<<"\n";rejected=std::string(e.what())=="trial_cleanup_not_sese";}require(rejected==(variant!=0));require(!verifyModule(*m,&errs()));
 }
 outs()<<"FTZ denormal refusal and SESE side-entry checks passed\n";
}
