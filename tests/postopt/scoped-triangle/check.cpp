#include "fusion_search.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include <stdexcept>
using namespace llvm;using namespace fusion;
static void require(bool v,const std::string&s){if(!v)throw std::runtime_error(s);}
static const char *body=R"(
define i32 @NAME(i1 %pick,i32 %x,i32 %y,i32* %ptr) {
entry:
 br i1 %pick,label %left,label %right
left:
 %a = add i32 %x, 1
 br label %join
right:
 %b = add i32 %y, 1
 %c = icmp sgt i32 %x, 0
 %d = select i1 %c, i32 %x, i32 0
 %e = icmp slt i32 %d, 1023
 %f = select i1 %e, i32 %d, i32 1023
 %q = icmp slt i32 %y, 0
 br i1 %q,label %negative,label %positive
negative:
 %n = add i32 %b, %f
 br label %join
positive:
 %v = sub i32 %b, %f
 br label %join
join:
 %out = phi i32 [%a,%left],[%n,%negative],[%v,%positive]
 ret i32 %out
}
)";
int main(int argc,char**argv){try{
 require(argc==2,"output path");LLVMContext ctx;SMDiagnostic d;std::string all;
 for(auto kind:{std::string("safe"),std::string("divide"),std::string("load")})for(auto suffix:{"base","old","new"}){
  std::string s=body;s.replace(s.find("NAME"),4,kind+"_"+suffix);
  const std::string line="%d = select i1 %c, i32 %x, i32 0";
  if(kind!="safe")s.replace(s.find(line),line.size(),kind=="divide"?"%d = sdiv i32 100, %x":"%d = load i32, i32* %ptr");
  all+=s;
 }
 auto m=parseAssemblyString(all,d,ctx);if(!m)d.print("triangles",errs());require(bool(m),"parse");
 for(auto kind:{std::string("safe"),std::string("divide"),std::string("load")}){
  int64_t oldBranches=0;
  for(bool enabled:{false,true}){
   auto fn=kind+(enabled?"_new":"_old");Candidate c{fn,"B0","B1","B2",0};
   auto hash=moduleHash(*m);auto t=tryPair(*m,c,0,3,enabled?CleanupMode::ScopedCFGTriangles:CleanupMode::ScopedCFG);
   require(t.valid,fn+":"+t.reason);require(hash==moduleHash(*m),"parent modified");require(!verifyModule(*t.normalized,&errs()),"verify");
   outs()<<fn<<" branches="<<t.after.branches<<" phis="<<t.after.phis<<" blocks="<<t.after.blocks<<"\n";
   if(enabled){if(kind=="safe")require(t.after.branches<oldBranches,"safe triangle not folded");else require(t.after.branches==oldBranches,"unsafe operation speculated");}
   oldBranches=t.after.branches;m=std::move(t.normalized);
  }
 }
 std::error_code ec;raw_fd_ostream out(argv[1],ec);require(!ec,"output");m->print(out,nullptr);return 0;
}catch(const std::exception&e){errs()<<e.what()<<"\n";return 1;}}
