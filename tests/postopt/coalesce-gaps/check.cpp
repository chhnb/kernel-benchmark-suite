#include "fusion_search.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include <stdexcept>
using namespace llvm;using namespace fusion;
static void check(bool v,const char *s){if(!v)throw std::runtime_error(s);}
static std::string body=R"(
define i32 @NAME(i32 %which, i32 %x, i32* %ptr, i32* %marker) {
entry:
 %p = icmp eq i32 %which, 0
 br i1 %p, label %l0, label %q1
l0:
 %a = load i32, i32* %ptr
 %b = add i32 %a, %x
 %c = mul i32 %b, 3
 br label %join
q1:
 %q = icmp eq i32 %which, 1
 br i1 %q, label %l1, label %q2
l1:
 %positive = icmp sgt i32 %x, 0
 br i1 %positive, label %l1load, label %l1empty
l1load:
 %d = load i32, i32* %ptr
 %e = add i32 %d, %x
 %f = mul i32 %e, 5
 br label %l1tail
l1empty:
 %g = sub i32 0, %x
 br label %l1tail
l1tail:
 %v = phi i32 [ %f, %l1load ], [ %g, %l1empty ]
 %vv = add i32 %v, 7
 br label %join
q2:
 %r = icmp eq i32 %which, 2
 br i1 %r, label %l2, label %l3
l2:
 %positive2 = icmp sgt i32 %x, 0
 br i1 %positive2, label %l2load, label %l2empty
l2load:
 %h = load i32, i32* %ptr
 %i = add i32 %h, %x
 %j = mul i32 %i, 9
 br label %join
l2empty:
 %k = sub i32 2, %x
 br label %join
l3:
 store i32 99, i32* %marker
 ret i32 -123
join:
 %out = phi i32 [ %c, %l0 ], [ %vv, %l1tail ], [ %j, %l2load ], [ %k, %l2empty ]
 store i32 %out, i32* %marker
 ret i32 %out
}
)";
int main(int argc,char **argv){try{
 check(argc==2,"output path");LLVMContext ctx;SMDiagnostic diag;
 auto named=[](std::string n){auto s=body;s.replace(s.find("NAME"),4,n);return s;};
 auto m=parseAssemblyString(named("baseline")+named("fusion01")+named("fusion12")+named("fusion01on")+named("fusion12on"),diag,ctx);check(bool(m),"parse");
 for(auto spec:{std::make_pair("fusion01","l0"),std::make_pair("fusion12","l1"),std::make_pair("fusion01on","l0"),std::make_pair("fusion12on","l1")}){
  auto *f=m->getFunction(spec.first);bool found=false;
  for(auto c:enumerate(*f,0)){
   if(c.left.empty()||c.left[0]!='E'||c.right[0]!='E')continue;
   unsigned index=std::stoul(c.left.substr(1));auto it=f->begin();std::advance(it,index);
   if(it->getName()!=spec.second)continue;
   auto hash=moduleHash(*m);c.hybrid=true;c.coalesceGaps=StringRef(spec.first).endswith("on");
   auto t=tryPair(*m,c,0,3,CleanupMode::ScopedCFG);
   errs()<<spec.first<<" "<<c.key()<<" "<<t.reason<<" "<<t.mergePath<<" groups="<<t.coalescedGapGroups<<"\n";
   check(t.valid,"complete leaf trial failed");check(moduleHash(*m)==hash,"parent changed");
   check(t.left.exit=="%join"&&t.right.exit=="%join","wrong exit");
   check(t.left.blocks.size()+(t.right.blocks.size())>2,"incomplete region");
   check(!verifyModule(*t.normalized,&errs()),"verify");
   m=std::move(t.normalized);found=true;break;
  }
  check(found,"candidate missing");
 }

 // A second decision containing a potentially trapping operation must not
 // be hoisted onto the first leaf; reject on the unmodified parent.
 auto unsafe=named("unsafe");
 unsafe.insert(unsafe.find(" %q ="),std::string(" %quot = sdiv i32 1, %x")+char(10));
 auto u=parseAssemblyString(unsafe,diag,ctx);check(bool(u),"unsafe parse");
 bool rejected=false;
 for(auto c:enumerate(*u->getFunction("unsafe"),0)){
  if(c.left!="E1_12"||c.right!="E3_12")continue;
  c.hybrid=true;auto hash=moduleHash(*u);
  auto t=tryPair(*u,c,0,3,CleanupMode::ScopedCFG);
  check(!t.valid&&t.reason=="complete_leaf_entry_not_normalizable","unsafe predicate moved");
  check(moduleHash(*u)==hash,"rejected parent changed");rejected=true;
 }
 check(rejected,"unsafe candidate missing");
 std::error_code ec;raw_fd_ostream out(argv[1],ec);check(!ec,"output");m->print(out,nullptr);
 return 0;
}catch(const std::exception&e){errs()<<e.what()<<"\n";return 1;}}
