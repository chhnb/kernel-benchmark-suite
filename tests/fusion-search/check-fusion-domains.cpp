#include "llvm/IR/Module.h"
#include "fusion_domains.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/Support/SourceMgr.h"
#include <cassert>
int main(){
 llvm::LLVMContext c;llvm::SMDiagnostic e;
 auto m=llvm::parseAssemblyString(R"(
define void @f(i1 %p,i1 %q) {
a: br i1 %p,label %body,label %b
b: br i1 %q,label %body,label %next
body: br label %next
next: br i1 %p,label %x,label %y
x: br label %end
y: br label %end
end: ret void
})",e,c);
 assert(m);auto &f=*m->getFunction("f");auto it=f.begin();auto *a=&*it++;auto *b=&*it++;auto *body=&*it++;auto *next=&*it++;
 decision::Decision d;d.root=a;d.tests={a,b}; // Deliberately no eligible arms.
 fusion::FusionDomains domains(f,{d});
 assert(domains.root(a)==domains.root(b));
 assert(domains.root(body)!=domains.root(a));
 assert(domains.root(next)!=domains.root(a));
 assert(domains.root("B1")==a);
 bool rejected=false;try{domains.root("B999");}catch(const std::runtime_error&){rejected=true;}assert(rejected);
 llvm::outs()<<"PASS condition-chain ownership, sequential separation, unknown coordinate rejection\n";
}
