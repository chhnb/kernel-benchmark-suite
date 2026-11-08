#include "fusion_search.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include <stdexcept>
#include <map>
#include <cmath>
#include <limits>
using namespace llvm;using namespace fusion;
static void require(bool ok,const char*why){if(!ok)throw std::runtime_error(why);}
static std::unique_ptr<Module> parse(const char*s,LLVMContext&c){SMDiagnostic e;auto m=parseAssemblyString(s,e,c);if(!m)e.print("test",errs());require(bool(m),"parse");return m;}
static void save(const Module&m,const std::string&p){std::error_code ec;raw_fd_ostream o(p,ec);require(!ec,"write");m.print(o,nullptr);}
static const char*blocks=R"IR(
define i32 @choose(i32 %x, i32 %side, i32 %inner) {
entry:
 %c = icmp ne i32 %side, 0
 br i1 %c, label %left, label %right
left:
 %a = add i32 %x, 7
 br label %join
right:
 %b = mul i32 %x, 3
 br label %join
join:
 %v = phi i32 [%a, %left], [%b, %right]
 ret i32 %v
}
)IR";
static const char*regions=R"IR(
define i32 @choose(i32 %x, i32 %side, i32 %inner) {
entry:
 %c = icmp ne i32 %side, 0
 %d = icmp ne i32 %inner, 0
 br i1 %c, label %left, label %right
left:
 br i1 %d, label %l0, label %l1
l0:
 %a = add i32 %x, 7
 br label %lj
l1:
 %b = mul i32 %x, 3
 br label %lj
lj:
 %lv = phi i32 [%a, %l0], [%b, %l1]
 br label %join
right:
 br i1 %d, label %r0, label %r1
r0:
 %u = sub i32 %x, 5
 br label %rj
r1:
 %v = mul i32 %x, 2
 br label %rj
rj:
 %rv = phi i32 [%u, %r0], [%v, %r1]
 br label %join
join:
 %z = phi i32 [%lv, %lj], [%rv, %rj]
 ret i32 %z
}
)IR";
static const char*chain=R"IR(
define i32 @choose(i32 %x, i32 %side, i32 %inner) {
entry:
 %c = icmp ne i32 %side, 0
 br i1 %c, label %left, label %right
left:
 %a = sdiv i32 1000, %x
 %aa = add i32 %a, 7
 br label %join
right:
 %b = sdiv i32 2000, %x
 %bb = mul i32 %b, 3
 br label %join
join:
 %v = phi i32 [%aa, %left], [%bb, %right]
 %d = icmp ne i32 %inner, 0
 br i1 %d, label %l2, label %r2
l2:
 %e = sdiv i32 3000, %v
 %ee = add i32 %e, 11
 br label %end
r2:
 %g = sdiv i32 4000, %v
 %gg = mul i32 %g, 5
 br label %end
end:
 %z = phi i32 [%ee, %l2], [%gg, %r2]
 ret i32 %z
}
)IR";
struct Recording:Observer{
 unsigned commits=0,trials=0,rounds=0;std::map<unsigned,double> maximum;std::map<unsigned,std::string> winner, hashes;
 void round(const RoundContext&r)override{++rounds;hashes[r.parentVersion]=r.parentHash;require(r.normalizationScale>=1,"control scale");}
 void trial(const Trial&t,const RoundContext&r,const ScoreResult&s,bool accept)override{++trials;require(hashes.at(t.candidate.version)==r.parentHash,"round shared identity");if(accept&&s.total>maximum[t.candidate.version]){maximum[t.candidate.version]=s.total;winner[t.candidate.version]=t.candidate.key();}}
 void commit(unsigned v,const Candidate&c,const ScoreResult&s,const Module&m)override{require(v==++commits,"version increment");require(c.version+1==v,"parent version");require(s.total==maximum[c.version]&&c.key()==winner[c.version],"best candidate selected");require(!verifyModule(m,&errs()),"committed IR");}
};
struct TestScorer:Scorer{
 mutable unsigned calls=0;
 ScoreResult evaluate(const ScoreInput&i,const RoundContext&r)const override{
   require(&i.beforeIR!=&i.afterIR,"isolated clone");require(!i.left.blocks.empty()&&!i.right.blocks.empty(),"boundaries");
   require(i.beforeAnalysis.regions.getTopLevelRegion()!=nullptr&&i.afterAnalysis.regions.getTopLevelRegion()!=nullptr,"region analyses");
   auto s=StaticCostScorer().evaluate(i,r);require(s.status==ScoreStatus::Scored,"classified score");s.total=double(++calls);return s;
 }
};
struct Zero:Scorer{ScoreResult evaluate(const ScoreInput&i,const RoundContext&r)const override{auto s=StaticCostScorer().evaluate(i,r);s.total=0;return s;}};
struct Nonfinite:Scorer{ScoreResult evaluate(const ScoreInput&i,const RoundContext&r)const override{auto s=StaticCostScorer().evaluate(i,r);s.total=std::numeric_limits<double>::quiet_NaN();return s;}};
int main(int argc,char**argv){try{
 require(argc==2||argc==3,"output directory and optional remerge fixture required");std::string dir=argv[1];require(!sys::fs::exists(dir),"fresh directory required");require(!sys::fs::create_directories(dir),"mkdir");
 LLVMContext context;
 for(auto kind:{std::string("blocks"),std::string("regions")}){
   std::string fixture=std::string(kind=="blocks"?blocks:regions)+R"IR(
define i32 @unrelated(i1 %c, i32 %x, i32 %y) {
entry:
 br i1 %c, label %left, label %right
left:
 br label %join
right:
 br label %join
join:
 %p=phi i32 [%y,%right], [%x,%left]
 ret i32 %p
}
)IR";
   auto m=parse(fixture.c_str(),context);auto cs=enumerate(*m->getFunction("choose"),0);Candidate c;bool found=false;
   for(auto&candidate:cs)if(candidate.split=="B0"&&((candidate.left[0]=='R')==(kind=="regions"))){c=candidate;found=true;break;}
   require(found,"expected pair enumerated");auto t=tryPair(*m,c,0,3);require(t.valid,"explicit pair trial");require(!verifyModule(*t.normalized,&errs()),"normalized pair verifier");
   const auto round=makeRound(*m,"choose",0,3);auto score=evaluateTrial(*m,t,round,StaticCostScorer());
   require(score.status==ScoreStatus::Scored,"round score");
   require(score.staticGain==round.controlFeatures.cost-t.after.cost,"control subtraction");
   require(score.cleanupGain+score.staticGain==score.parentGain,"gain decomposition");
   int64_t sum=0;for(auto&x:score.contributions)sum+=x.gain;require(sum==score.staticGain,"contribution sum");
   require(score.coverage.dependency=="unavailable"&&score.coverage.hardwareCosts=="uncalibrated","coverage is explicit");
   require(moduleHash(*m)==round.parentHash,"control did not replace parent");
   if(kind=="blocks")require(round.controlFeatures.blocks!=round.parentFeatures.blocks,"nontrivial cleanup control");
   auto badScore=evaluateTrial(*m,t,round,Nonfinite());require(t.valid&&badScore.status==ScoreStatus::NotEvaluable,"score failure is not trial invalidity");
   auto light=tryPair(*m,c,0,3,CleanupMode::DarmCFG);require(light.valid,"DARM CFG trial");
   auto lightRound=makeRound(*m,"choose",0,3,CleanupMode::DarmCFG);
   auto lightScore=evaluateTrial(*m,light,lightRound,StaticCostScorer());
   require(lightScore.status==ScoreStatus::Scored&&lightScore.staticGain==lightRound.controlFeatures.cost-light.after.cost,"DARM CFG matched control");
   require(evaluateTrial(*m,light,round,StaticCostScorer()).reason=="cleanup_mode_mismatch","cleanup mismatch rejected");
   auto hash=moduleHash(*light.normalized);cleanup(*light.normalized,"choose",3,CleanupMode::DarmCFG);
   require(moduleHash(*light.normalized)==hash,"DARM cleanup fixed point");
   require(moduleHash(*m)==round.parentHash,"light trial parent untouched");
   save(*m,dir+"/"+kind+"-darm-cfg-before.ll");
   save(*light.normalized,dir+"/"+kind+"-darm-cfg-after.ll");
   auto cseTrial=tryPair(*m,c,0,3,CleanupMode::DarmCFGEarlyCSE);
   require(cseTrial.valid,"EarlyCSE trial verifier");
   auto cseRound=makeRound(*m,"choose",0,3,CleanupMode::DarmCFGEarlyCSE);
   auto cseScore=evaluateTrial(*m,cseTrial,cseRound,StaticCostScorer());
   require(cseScore.status==ScoreStatus::Scored&&cseScore.staticGain==cseRound.controlFeatures.cost-cseTrial.after.cost,"EarlyCSE matched control");
   require(evaluateTrial(*m,cseTrial,lightRound,StaticCostScorer()).reason=="cleanup_mode_mismatch","CFG/EarlyCSE mismatch rejected");
   require(moduleHash(*m)==round.parentHash,"EarlyCSE parent untouched");
   save(*m,dir+"/"+kind+"-earlycse-before.ll");
   save(*cseTrial.normalized,dir+"/"+kind+"-earlycse-after.ll");
   auto fpTrial=tryPair(*m,c,0,3,CleanupMode::DarmCFGScalarFixedPoint);
   require(fpTrial.valid&&fpTrial.cleanupIterations>0&&fpTrial.cleanupIterations<=32,"fixed-point cleanup verified and converged");
   auto fpRound=makeRound(*m,"choose",0,3,CleanupMode::DarmCFGScalarFixedPoint);
   require(evaluateTrial(*m,fpTrial,fpRound,StaticCostScorer()).status==ScoreStatus::Scored,"fixed-point matched control");
   require(evaluateTrial(*m,fpTrial,cseRound,StaticCostScorer()).reason=="cleanup_mode_mismatch","fixed-point mode mismatch rejected");
   require(moduleHash(*m)==round.parentHash,"fixed-point parent untouched");
   save(*m,dir+"/"+kind+"-scalar-fp-before.ll");
   save(*fpTrial.normalized,dir+"/"+kind+"-scalar-fp-after.ll");
   auto wrongRound=makeRound(*m,"choose",1,3);require(evaluateTrial(*m,t,wrongRound,StaticCostScorer()).status==ScoreStatus::NotEvaluable,"wrong round rejected");
   Options acceptOptions;auto fake=score;fake.total=1;fake.parentGain=-1;require(!eligible(t,fake,acceptOptions),"parent cost increase veto");acceptOptions.requireParentGain=false;require(eligible(t,fake,acceptOptions),"explicit parent guard override");
   save(*m,dir+"/"+kind+"-before.ll");save(*t.normalized,dir+"/"+kind+"-after.ll");
   auto bad=c;bad.right=bad.left;auto overlap=tryPair(*m,bad,0,3);require(!overlap.valid&&overlap.reason=="overlapping_pair","overlap rejected");
   auto stale=tryPair(*m,c,1,3);require(!stale.valid&&stale.reason=="stale_candidate_version","stale rejected");
 }
 // A local diamond can be merged without changing the surrounding loop.
 auto loop=parse(R"IR(
define i32 @choose(i32 %x, i32 %side, i32 %n) {
entry:
 br label %header
header:
 %i=phi i32 [0,%entry], [%next,%join]
 %acc=phi i32 [0,%entry], [%sum,%join]
 %more=icmp slt i32 %i,%n
 br i1 %more,label %split,label %exit
split:
 %parity=add i32 %i,%side
 %bit=and i32 %parity,1
 %c=icmp eq i32 %bit,0
 br i1 %c,label %left,label %right
left:
 %a=add i32 %x,7
 br label %join
right:
 %b=add i32 %x,11
 br label %join
join:
 %v=phi i32 [%a,%left],[%b,%right]
 %sum=add i32 %acc,%v
 %next=add i32 %i,1
 br label %header
exit:
 ret i32 %acc
}
)IR",context);
 auto loopHash=moduleHash(*loop);auto loopCandidates=enumerate(*loop->getFunction("choose"),0);
 auto local=std::find_if(loopCandidates.begin(),loopCandidates.end(),[](const Candidate&c){return c.split=="B2"&&c.left=="B3"&&c.right=="B4";});
 require(local!=loopCandidates.end(),"local loop diamond enumerated");
 auto loopTrial=tryPair(*loop,*local,0,3,CleanupMode::DarmCFGEarlyCSE);
 require(loopTrial.valid,"local loop diamond verified");
 require(loopTrial.before.loops==1&&loopTrial.afterRaw.loops==1&&loopTrial.after.loops==1,"enclosing loop retained");
 require(moduleHash(*loop)==loopHash,"loop parent immutable");
 save(*loop,dir+"/loop-before.ll");save(*loopTrial.normalized,dir+"/loop-after.ll");
 // A split at the enclosing header is intentionally outside the narrow support.
 auto headerPair=*local;headerPair.split="B1";
 require(!tryPair(*loop,headerPair,0,3,CleanupMode::DarmCFGEarlyCSE).valid,"loop boundary rejected");
 auto m=parse(chain,context);auto original=m->getFunction("choose")->size();Options o;o.cleanupMode=CleanupMode::O3;o.maxRounds=2;o.maxTrials=256;o.requireParentGain=false;TestScorer scorer;Recording recording;
 auto result=greedy(*m,"choose",o,scorer,&recording);require(result.commits==2,"two greedy rounds required");require(recording.commits==2&&recording.rounds==2&&scorer.calls==recording.trials,"direct scorer callbacks");require(m->getFunction("choose")->size()==original,"parent untouched");
 save(*m,dir+"/chain-before.ll");save(*result.module,dir+"/chain-after.ll");
 Zero zero;auto stopped=greedy(*m,"choose",o,zero);require(stopped.commits==0&&stopped.stop=="no_positive_candidate","nonpositive stop");
 o.maxTrials=0;auto budget=greedy(*m,"choose",o,scorer);require(budget.commits==0&&budget.trials==0&&budget.stop=="trial_budget_before_complete_round","budget leaves parent uncommitted");
 // Classification preserves precision, vector shape, flags, and call identity.
 auto types=parse(R"IR(
declare double @llvm.sqrt.f64(double)
declare double @ordinary(double)
define double @types(float %f, double %d, <4 x float> %v) {
entry:
 %a = fadd float %f, 1.0
 %b = fadd fast double %d, 1.0
 %c = fadd <4 x float> %v, %v
 %e = call double @llvm.sqrt.f64(double %b)
 %g = call double @ordinary(double %e)
 ret double %g
}
)IR",context);
 auto tf=features(*types->getFunction("types"));bool f32=false,f64=false,v4=false,intrinsic=false,ordinary=false;int64_t totalCost=0,totalCount=0;
 for(auto&kv:tf.operations){auto&k=kv.first;totalCost+=k.legacyWeight*kv.second;totalCount+=kv.second;if(k.opcode=="fadd"){f32|=k.scalarBits==32&&k.lanes==1;f64|=k.scalarBits==64&&k.attributes.find("fmf=1111111")!=std::string::npos;v4|=k.scalarBits==32&&k.lanes==4;}intrinsic|=k.callee=="intrinsic:llvm.sqrt.f64";ordinary|=k.callee=="function:ordinary";}
 require(f32&&f64&&v4&&intrinsic&&ordinary,"operation classification");require(totalCost==tf.cost&&totalCount==tf.instructions,"histogram accounting");
 if(argc==3){
  SMDiagnostic error;auto fixture=parseIRFile(argv[2],error,context);require(bool(fixture),"remerge fixture parse");
  auto parentHash=moduleHash(*fixture);auto candidates=enumerate(*fixture->getFunction("evaluate"),0);const auto round=makeRound(*fixture,"evaluate",0,3);
  for(auto pair:std::vector<std::pair<std::string,std::string>>{{"B32","B40"},{"B35","B37"}}){
    auto found=std::find_if(candidates.begin(),candidates.end(),[&](const Candidate&c){return (c.left==pair.first&&c.right==pair.second)||(c.left==pair.second&&c.right==pair.first);});
    require(found!=candidates.end(),"merged computation pair must be enumerated");
    auto t=tryPair(*fixture,*found,0,3);require(t.valid,"remerge must verify");auto score=evaluateTrial(*fixture,t,round,StaticCostScorer());
    require(score.status==ScoreStatus::Scored&&score.staticGain==640,"remerge cost regression");require(moduleHash(*fixture)==parentHash,"remerge parent unchanged");
  }
 }
 outs()<<"PASS control accounting, structured score, unavailable coverage, classification, parent guard, explicit BB/Region pairs, two greedy rounds, best-score selection, direct IR/analysis callbacks, stale/overlap rejection, nonpositive and budget stops\n";return 0;
 }catch(const std::exception&e){errs()<<"FAIL "<<e.what()<<"\n";return 1;}}
