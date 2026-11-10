// B2R that would replicate a same-discriminator decision chain is opt-in, and
// the speculation mode decides whether work runs on a path that did not run
// it: replication-paired blocks, else-if entry hoisting, local if-conversion
// and (budget only) cheap unmatched ranges of ordinary pairs.
// none = never, legacy = historical, budget = up to N weight units.
#include "fusion_search.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include <stdexcept>
using namespace llvm;using namespace fusion;
static void check(bool v,const std::string &s){if(!v)throw std::runtime_error(s);}
// chain: x<.5 L | x<.75 C | x<.875 D | E   (D, E sit behind further x tests)
static const char *CHAIN=R"(
define float @chain(float %x, float addrspace(1)* %t) {
entry:
  %p = fcmp olt float %x, 5.000000e-01
  br i1 %p, label %L, label %upperq
L:
  %a0 = getelementptr inbounds float, float addrspace(1)* %t, i64 0
  %a1 = load float, float addrspace(1)* %a0, align 4
  %a2 = fmul float %a1, %x
  %a3 = fdiv float %a2, 3.000000e+00
  %a4 = fadd float %a3, 1.000000e+00
  br label %join
upperq:
  %pu = fcmp olt float %x, 7.500000e-01
  br i1 %pu, label %c, label %q2
q2:
  %p2 = fcmp olt float %x, 8.750000e-01
  br i1 %p2, label %d, label %e
c:
  %c0 = getelementptr inbounds float, float addrspace(1)* %t, i64 2
  %c1 = load float, float addrspace(1)* %c0, align 4
  %c2 = fmul float %c1, %x
  %c3 = fdiv float %c2, 7.000000e+00
  %c4 = fadd float %c3, 3.000000e+00
  br label %join
d:
  %d0 = getelementptr inbounds float, float addrspace(1)* %t, i64 3
  %d1 = load float, float addrspace(1)* %d0, align 4
  %d2 = fmul float %d1, %x
  %d3 = fdiv float %d2, 9.000000e+00
  %d4 = fadd float %d3, 4.000000e+00
  br label %join
e:
  %e0 = getelementptr inbounds float, float addrspace(1)* %t, i64 4
  %e1 = load float, float addrspace(1)* %e0, align 4
  %e2 = fmul float %e1, %x
  %e3 = fdiv float %e2, 1.100000e+01
  %e4 = fadd float %e3, 5.000000e+00
  br label %join
join:
  %r = phi float [ %a4, %L ], [ %c4, %c ], [ %d4, %d ], [ %e4, %e ]
  ret float %r
}
)";
// same chain, pure arithmetic leaves (local if-conversion candidates)
static const char *PURE=R"(
define float @pure(float %x, float addrspace(1)* %t) {
entry:
  %p = fcmp olt float %x, 5.000000e-01
  br i1 %p, label %L, label %upperq
L:
  %a1 = fmul float %x, 1.500000e+00
  %a2 = fmul float %a1, %x
  %a3 = fdiv float %a2, 3.000000e+00
  %a4 = fadd float %a3, 1.000000e+00
  br label %join
upperq:
  %pu = fcmp olt float %x, 7.500000e-01
  br i1 %pu, label %c, label %q2
q2:
  %p2 = fcmp olt float %x, 8.750000e-01
  br i1 %p2, label %d, label %e
c:
  %c1 = fmul float %x, 2.500000e+00
  %c2 = fmul float %c1, %x
  %c3 = fdiv float %c2, 7.000000e+00
  %c4 = fadd float %c3, 3.000000e+00
  br label %join
d:
  %d1 = fmul float %x, 3.500000e+00
  %d2 = fmul float %d1, %x
  %d3 = fdiv float %d2, 9.000000e+00
  %d4 = fadd float %d3, 4.000000e+00
  br label %join
e:
  %e1 = fmul float %x, 4.500000e+00
  %e2 = fmul float %e1, %x
  %e3 = fdiv float %e2, 1.100000e+01
  %e4 = fadd float %e3, 5.000000e+00
  br label %join
join:
  %r = phi float [ %a4, %L ], [ %c4, %c ], [ %d4, %d ], [ %e4, %e ]
  ret float %r
}
)";
// L | heavy block `upper` then a branch on the unrelated %y -> c | d
static const char *HEAVY=R"(
define float @heavy(float %x, float %y) {
entry:
  %p = fcmp olt float %x, 5.000000e-01
  br i1 %p, label %L, label %upper
L:
  %a1 = fmul float %x, 1.500000e+00
  %a2 = fmul float %a1, %x
  %a3 = fdiv float %a2, 3.000000e+00
  %a4 = fadd float %a3, 1.000000e+00
  br label %join
upper:
  %u1 = fdiv float 1.000000e+00, %x
  %u2 = fdiv float %u1, %y
  %u3 = fmul float %u2, %u1
  %q = fcmp olt float %y, 0.000000e+00
  br i1 %q, label %c, label %d
c:
  %c1 = fmul float %u3, 2.500000e+00
  %c2 = fadd float %c1, 3.000000e+00
  br label %join
d:
  %d1 = fmul float %u3, %x
  %d2 = fmul float %d1, %x
  %d3 = fdiv float %d2, 9.000000e+00
  %d4 = fadd float %d3, 4.000000e+00
  br label %join
join:
  %r = phi float [ %a4, %L ], [ %c2, %c ], [ %d4, %d ]
  ret float %r
}
)";
// ordinary B2B with one cheap unmatched instruction (the fadd on the right)
static const char *GAP=R"(
define float @gap(float %x) {
entry:
  %p = fcmp olt float %x, 5.000000e-01
  br i1 %p, label %l, label %r
l:
  %l1 = fmul float %x, 2.000000e+00
  br label %join
r:
  %r0 = fadd float %x, 1.000000e+00
  %r1 = fmul float %r0, 3.000000e+00
  br label %join
join:
  %v = phi float [ %l1, %l ], [ %r1, %r ]
  ret float %v
}
)";
static const SpeculationMode NONE=SpeculationMode::None,LEGACY=SpeculationMode::Legacy,BUDGET=SpeculationMode::Budget;
static Trial trial(Module &m,const char *fn,const char *s,const char *l,const char *r,bool cross,SpeculationMode mode,int budget=4,bool hybrid=true){
  Candidate c{fn,s,l,r,0};c.hybrid=hybrid;c.crossLevelB2R=cross;c.speculation=mode;c.speculationBudget=budget;
  auto hash=moduleHash(m);auto t=tryPair(m,c,0,3,CleanupMode::ScopedCFG);
  check(moduleHash(m)==hash,std::string("parent changed: ")+fn+":"+s+":"+l+":"+r);
  if(t.valid)check(!verifyModule(*t.normalized,&errs()),"invalid normalized IR");
  return t;
}
// Extra fdiv instructions a wave whose lanes all take `side` of the split
// executes after fusion, relative to the parent (side reachability is exact
// for this split; unrelated splits keep both successors on both sides).
static unsigned fdivIn(Function *f,const std::vector<unsigned> &side){
  std::vector<BasicBlock*> blocks;for(auto &b:*f)blocks.push_back(&b);
  unsigned n=0;for(auto i:side)for(auto &x:*blocks.at(i))n+=x.getOpcode()==Instruction::FDiv;
  return n;
}
static int extraFdiv(const Trial &t,Module &parent,const char *fn,unsigned side){
  check(t.sideBeforeOk&&t.sideAfterOk,"side metrics missing: "+t.sideReason);
  return int(fdivIn(t.normalized->getFunction(fn),t.sideAfter[side]))-int(fdivIn(parent.getFunction(fn),t.sideBefore[side]));
}
int main(int argc,char **argv){try{
  check(argc==2,"output path");LLVMContext ctx;SMDiagnostic d;
  auto m=parseAssemblyString(std::string(CHAIN)+PURE+HEAVY+GAP,d,ctx);if(!m)d.print("b2r",errs());check(bool(m),"parse");
  // Blocks: entry0 L1 upperq2 q2(3) c4 d5 e6 join7 ; heavy: entry0 L1 upper2 c3 d4 join5.

  // 1. Gate: L + D needs the replicated x<.75 decision -> opt-in only.
  auto g=trial(*m,"chain","B0","B1","B5",false,LEGACY);
  check(!g.valid&&g.reason=="b2r_replicates_same_decision_chain_requires_opt_in","gate: "+g.reason);
  auto go=trial(*m,"chain","B0","B1","B5",true,LEGACY);
  check(go.valid&&go.mergePath=="darm-B2R","gate opt-in: "+go.reason+" "+go.mergePath);
  // Adjacent else-if leaves are a diamond after normalization, not gated, and
  // hoisting only the second decision's own compare is allowed even in none.
  for(auto mode:{NONE,LEGACY,BUDGET}){
    auto adj=trial(*m,"chain","B0","B1","B4",false,mode);
    check(adj.valid&&adj.mergePath=="darm-adjacent-B2B","adjacent leaves: "+adj.reason+" "+adj.mergePath);
  }

  // 2. Local if-conversion: legacy picks it; none never; budget only when cheap.
  auto lc=trial(*m,"pure","B3","B5","B6",false,LEGACY);
  check(lc.valid&&lc.mergePath=="local-compute","legacy local dispatch: "+lc.mergePath);
  check(extraFdiv(lc,*m,"pure",1)==1&&extraFdiv(lc,*m,"pure",0)==1,"if-conversion runs both fdiv chains");
  for(auto mode:{NONE,BUDGET}){
    auto lb=trial(*m,"pure","B3","B5","B6",false,mode);
    check(lb.valid&&lb.mergePath!="local-compute","local engine chosen without legacy: "+lb.mergePath);
    check(extraFdiv(lb,*m,"pure",1)==0&&extraFdiv(lb,*m,"pure",0)==0,"sibling merge adds an fdiv on a side");
  }

  // 3. else-if hoisting of leaf work + replication: L must not run upper's fdivs.
  auto h=trial(*m,"heavy","B0","B1","B4",false,LEGACY);
  check(h.valid&&h.mergePath=="darm-adjacent-B2B","legacy hoist: "+h.mergePath);
  check(extraFdiv(h,*m,"heavy",1)==2,"legacy: L side runs the two hoisted fdivs");
  for(auto mode:{NONE,BUDGET}){
    auto hb=trial(*m,"heavy","B0","B1","B4",false,mode);
    check(hb.valid&&hb.mergePath=="darm-B2R","hoisting refused, replicate instead: "+hb.reason+" "+hb.mergePath);
    check(extraFdiv(hb,*m,"heavy",1)==0,"L side runs an extra fdiv");
  }

  // 4. Ordinary pair, cheap unmatched fadd: guarded in none/legacy, kept in
  //    the melded block (no guard block) in budget mode.
  auto guards=[](const Trial &t){unsigned n=0;for(auto &b:*t.raw->getFunction("gap"))n+=b.getName().startswith("predication.");return n;};
  auto gn=trial(*m,"gap","B0","B1","B2",false,NONE,4,false);
  auto gl=trial(*m,"gap","B0","B1","B2",false,LEGACY,4,false);
  auto gb=trial(*m,"gap","B0","B1","B2",false,BUDGET,4,false);
  auto g0=trial(*m,"gap","B0","B1","B2",false,BUDGET,0,false);
  check(gn.valid&&gl.valid&&gb.valid&&g0.valid,"gap trials");
  check(guards(gn)>0&&guards(gl)>0,"unmatched fadd should be guarded in none/legacy");
  check(guards(gb)==0,"budget should speculate the cheap unmatched fadd");
  check(guards(g0)>0,"budget 0 must still guard");

  auto &hb=gb;
  std::error_code ec;raw_fd_ostream out(argv[1],ec);check(!ec,"output");hb.normalized->print(out,nullptr);
  return 0;
}catch(const std::exception &e){errs()<<e.what()<<"\n";return 1;}}
