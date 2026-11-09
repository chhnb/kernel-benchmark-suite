#include "fusion_search.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include <stdexcept>
using namespace llvm;using namespace fusion;
static void require(bool v,const std::string&s){if(!v)throw std::runtime_error(s);}
static const char *body=R"(
define i32 @NAME(i1 %pickL,i1 %pickR,i1 %take,i32 %x,i32* %ptr,i32* %optional) {
entry:
 br i1 %pickL,label %left,label %testR
left:
 br i1 %take,label %la,label %lb
la:
 %a = load i32,i32* %optional
 %d = sdiv i32 300,%x
 %v = add i32 %a,%d
 br label %lend
lb:
 %b = mul i32 %x,7
 br label %lend
lend:
 %l = phi i32 [%v,%la],[%b,%lb]
 %lm = load i32,i32* %ptr
 %lo = add i32 %l,%lm
 br label %join
testR:
 br i1 %pickR,label %right,label %fallback
right:
 %rm = load i32,i32* %ptr
 br i1 %take,label %ra,label %rb
ra:
 %a2 = load i32,i32* %optional
 %d2 = sdiv i32 700,%x
 %v2 = add i32 %a2,%d2
 %ro = sub i32 %v2,%rm
 br label %join
rb:
 %b2 = mul i32 %x,11
 %ro2 = sub i32 %b2,%rm
 br label %join
fallback:
 br label %join
join:
 %out = phi i32 [%lo,%lend],[%ro,%ra],[%ro2,%rb],[123,%fallback]
 ret i32 %out
}
)";
int main(int argc,char**argv){try{
 require(argc==2,"output path");LLVMContext ctx;SMDiagnostic d;std::string all;
 for(auto fn:{"base","multi","unchanged"}){std::string s=body;s.replace(s.find("NAME"),4,fn);all+=s;}
 std::string sensitive=body;sensitive.replace(sensitive.find("NAME"),4,"sensitive");
 sensitive.replace(sensitive.find("left:\n"),6,"left:\n %mark = call i32 @marker(i32 %x)\n");
 all+=sensitive;all+="\ndefine i32 @marker(i32 %x) nounwind readnone willreturn convergent { ret i32 %x }\n";
 auto m=parseAssemblyString(all,d,ctx);if(!m)d.print("multi",errs());require(bool(m),"parse");
 auto otherHash=[](Function *f){std::string s;raw_string_ostream os(s);f->print(os);return os.str();};
 auto untouched=otherHash(m->getFunction("unchanged"));
 Candidate c{"multi","B0","E1_10","E6_10",0};c.hybrid=true;c.completeLeafPlan=true;c.coalesceGaps=true;
 auto rejectCandidate=c;rejectCandidate.function="sensitive";
 auto rejected=tryPair(*m,rejectCandidate,0,3,CleanupMode::ScopedCFGTriangles);
 require(!rejected.valid&&rejected.reason=="leaf_plan_convergence_sensitive_call","convergent leaf accepted");
 auto hash=moduleHash(*m);auto t=tryPair(*m,c,0,3,CleanupMode::ScopedCFGTriangles);
 require(t.valid,t.reason);require(hash==moduleHash(*m),"parent modified");require(t.leafAnchors>=2,"not multiple anchors");
 require(t.movedLeafInstructions==2,"mandatory loads not isolated");
 require(!verifyModule(*t.normalized,&errs()),"verify");require(untouched==otherHash(t.normalized->getFunction("unchanged")),"other function changed");
 outs()<<"anchors="<<t.leafAnchors<<" moved="<<t.movedLeafInstructions<<"\n";
 std::error_code ec;raw_fd_ostream out(argv[1],ec);require(!ec,"output");t.normalized->print(out,nullptr);return 0;
}catch(const std::exception&e){errs()<<e.what()<<"\n";return 1;}}
