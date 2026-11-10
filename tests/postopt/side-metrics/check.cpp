// Uniform-wave side reachability, the --max-uniform-loss guard, side-tag
// hygiene and per-trial exception isolation in greedy(). LLVM12 only: the
// LLVM24 cost aggregation is exercised end to end by run.sh when a worker exists.
#include "fusion_search.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include <stdexcept>
using namespace llvm;using namespace fusion;
static void check(bool v,const char *s){if(!v)throw std::runtime_error(s);}
static const char *IR=R"(
define i32 @tree(i32 %x, i32* %ptr) {
entry:
 %p = icmp slt i32 %x, 50
 br i1 %p, label %lower, label %upperq
lower:
 %pl = icmp slt i32 %x, 25
 br i1 %pl, label %a, label %b
a:
 %a1 = load i32, i32* %ptr
 %a2 = mul i32 %a1, 3
 %a3 = add i32 %a2, 1
 br label %join
b:
 %b1 = load i32, i32* %ptr
 %b2 = mul i32 %b1, 5
 %b3 = add i32 %b2, 2
 br label %join
upperq:
 %pu = icmp slt i32 %x, 75
 br i1 %pu, label %c, label %d
c:
 %c1 = load i32, i32* %ptr
 %c2 = mul i32 %c1, 7
 %c3 = add i32 %c2, 3
 br label %join
d:
 %d1 = load i32, i32* %ptr
 %d2 = mul i32 %d1, 9
 %d3 = add i32 %d2, 4
 br label %join
join:
 %r = phi i32 [ %a3, %a ], [ %b3, %b ], [ %c3, %c ], [ %d3, %d ]
 ret i32 %r
}
)";
static bool tagged(const Module *m){
  if(!m)return false;
  for(auto &f:*m){if(f.getMetadata("fusion.side.condition.arg"))return true;
    for(auto &b:f)for(auto &i:b)if(i.getMetadata("fusion.side.condition"))return true;}
  return false;
}
static bool contains(const std::vector<unsigned> &v,unsigned x){return std::find(v.begin(),v.end(),x)!=v.end();}
// Scores every trial with a fixed gain; throws for one chosen candidate key.
struct ThrowingScorer:Scorer{
  std::string throwFor;
  ScoreResult evaluate(const ScoreInput &i,const RoundContext &)const override{
    if(i.candidate.key()==throwFor)throw std::runtime_error("injected_scorer_failure");
    ScoreResult s;s.status=ScoreStatus::Scored;s.staticGain=s.parentGain=1;s.staticScore=s.total=1;s.reason="test";return s;
  }
};
struct Recorder:Observer{
  std::vector<std::string> reasons;
  void trial(const Trial &t,const RoundContext &,const ScoreResult &s,bool)override{reasons.push_back(t.reason+"|"+s.reason);}
};
int main(int argc,char **argv){try{
  check(argc==2,"output path");
  LLVMContext ctx;SMDiagnostic diag;auto m=parseAssemblyString(IR,diag,ctx);check(bool(m),"parse");
  // Block order: entry0 lower1 a2 b3 upperq4 c5 d6 join7.
  auto hash=moduleHash(*m);

  // 1. B2B inside the lower subtree: split B1 tests %pl.
  Candidate inner{"tree","B1","B2","B3",0};inner.hybrid=true;
  auto t=tryPair(*m,inner,0,3,CleanupMode::ScopedCFG);
  check(t.valid,t.reason.c_str());check(moduleHash(*m)==hash,"parent changed");
  check(t.sideBeforeOk&&t.sideAfterOk,("side metrics missing: "+t.sideReason).c_str());
  // %pl=true keeps a and drops b; the other split (%p) keeps both halves.
  check(contains(t.sideBefore[1],2)&&!contains(t.sideBefore[1],3),"before true side");
  check(contains(t.sideBefore[0],3)&&!contains(t.sideBefore[0],2),"before false side");
  for(unsigned s=0;s<2;++s){
    check(contains(t.sideBefore[s],4)&&contains(t.sideBefore[s],5)&&contains(t.sideBefore[s],6),"unrelated split pruned");
    auto n=t.normalized->getFunction("tree")->size();
    check(!t.sideAfter[s].empty(),"after side empty");
    for(auto b:t.sideAfter[s])check(b<n,"after side index out of range");
  }
  check(!tagged(t.raw.get())&&!tagged(t.normalized.get())&&!tagged(m.get()),"side tag leaked");

  // 2. Nested complete-leaf trial (opt-in cross-level R2B): before-sides come
  //    from the outer, pre-gate parent; the tag still never leaks.
  unsigned nested=0;
  for(auto c:enumerate(*m->getFunction("tree"),0,true)){
    if(c.left.empty()||c.left[0]!='E'||c.right[0]!='E')continue;
    c.hybrid=true;c.crossDecisionLeaves=true;
    auto e=tryPair(*m,c,0,3,CleanupMode::ScopedCFG);
    check(e.valid,e.reason.c_str());
    check(e.sideBeforeOk&&e.sideAfterOk,("nested side metrics missing: "+e.sideReason).c_str());
    // Split B0 tests %p: the true side is the lower subtree only.
    check(contains(e.sideBefore[1],1)&&!contains(e.sideBefore[1],4),"nested before true side");
    check(contains(e.sideBefore[0],4)&&!contains(e.sideBefore[0],1),"nested before false side");
    check(!tagged(e.raw.get())&&!tagged(e.normalized.get()),"nested side tag leaked");
    ++nested;
  }
  check(nested>0,"no nested complete-leaf trial");
  check(moduleHash(*m)==hash,"parent changed by nested trials");

  // 3. Guard semantics.
  Options o;ScoreResult s;s.status=ScoreStatus::Scored;s.total=s.parentGain=1;
  check(eligible(t,s,o),"guard off must not change eligibility");
  o.maxUniformLoss=5;check(!eligible(t,s,o),"guard on requires side metrics");
  s.metrics={{"side_metrics_available",1},{"uniform_gain_false",-4},{"uniform_gain_true",2}};
  check(eligible(t,s,o),"loss within bound rejected");
  s.metrics["uniform_gain_true"]=-6;check(!eligible(t,s,o),"loss beyond bound accepted");

  // 4. A throwing trial is a rejected trial; the search continues and commits.
  ThrowingScorer scorer;Recorder rec;Options g;g.hybrid=true;g.maxRounds=1;g.cleanupMode=CleanupMode::ScopedCFG;
  auto candidates=enumerate(*m->getFunction("tree"),0);check(candidates.size()>1,"need several candidates");
  scorer.throwFor=candidates.front().key();
  auto r=greedy(*m,"tree",g,scorer,&rec);
  check(r.commits==1,"search did not survive a throwing trial");
  bool seen=false;for(auto &x:rec.reasons)seen|=x.find("score_exception:injected_scorer_failure")!=std::string::npos;
  check(seen,"exception not recorded as a trial reason");
  check(!tagged(r.module.get()),"committed module carries side tag");

  std::error_code ec;raw_fd_ostream out(argv[1],ec);check(!ec,"output");r.module->print(out,nullptr);
  check(!verifyModule(*r.module,&errs()),"committed module invalid");
  return 0;
}catch(const std::exception &e){errs()<<e.what()<<"\n";return 1;}}
