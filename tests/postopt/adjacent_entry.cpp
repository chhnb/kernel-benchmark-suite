#include "fusion_search.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include <stdexcept>
using namespace llvm;using namespace fusion;
static void check(bool b,const char*s){if(!b)throw std::runtime_error(s);}
int main(int argc,char**argv){try{
check(argc==2,"output required");LLVMContext c;SMDiagnostic d;
std::string body=R"(
define float @NAME(i32 %e, float %x, i1 %poison_second) {
entry:
 %p = icmp sgt i32 %e, 0
 br i1 %p, label %a, label %next
a:
 %u = fadd float %x, 1.0
 %v = fmul float %u, 2.0
 br label %join
next:
 %q = icmp sgt i32 %e, -10
 %overflow = add nsw i8 127, 1
 %bad = icmp eq i8 %overflow, 0
 %cond = select i1 %poison_second, i1 %bad, i1 %q
 br i1 %cond, label %b, label %tail
b:
 %w = fadd float %x, 3.0
 %z = fmul float %w, 4.0
 br label %join
tail:
 %other = fadd float %x, 5.0
 br label %join
join:
 %r = phi float [ %v, %a ], [ %z, %b ], [ %other, %tail ]
 ret float %r
}
)";
auto named=[&](const std::string&n){auto s=body;s.replace(s.find("NAME"),4,n);return s;};
auto m=parseAssemblyString(named("baseline")+named("candidate"),d,c);if(!m)d.print("adjacent",errs());check(bool(m),"parse");
auto h=moduleHash(*m);Candidate cand{"candidate","B0","B1","B3",0};cand.hybrid=true;
auto t=tryPair(*m,cand,0,3,CleanupMode::ScopedCFG);
check(t.valid,"adjacent fusion rejected");check(!t.replication&&t.planKind=="B2B"&&t.mergePath=="darm-adjacent-B2B","not direct B2B");
check(moduleHash(*m)==h&&!verifyModule(*t.normalized,&errs()),"parent/verify");
check(t.leftContext.blocks.size()==1&&t.rightContext.blocks.size()==1,"suffix included");
std::error_code ec;raw_fd_ostream out(argv[1],ec);check(!ec,"output");t.normalized->print(out,nullptr);out.close();
// A trapping second-entry operation cannot be speculated on the first path.
auto unsafe=named("unsafe");auto k=unsafe.find(" %q = icmp");unsafe.insert(k," %quot = sdiv i32 1, %e\n");
auto u=parseAssemblyString(unsafe,d,c);check(bool(u),"unsafe parse");cand.function="unsafe";auto uh=moduleHash(*u);
auto ut=tryPair(*u,cand,0,3,CleanupMode::ScopedCFG);
check(ut.mergePath!="darm-adjacent-B2B","unsafe entry was speculated");check(moduleHash(*u)==uh,"unsafe parent mutation");
outs()<<"adjacent entry verifier and rejection tests passed\n";return 0;
}catch(const std::exception&e){errs()<<e.what()<<"\n";return 1;}}
