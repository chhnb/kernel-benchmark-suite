#include "llvm24_scorer.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FormatVariadic.h"
#include <chrono>
#include <cassert>
#include <algorithm>
using namespace llvm;using namespace fusion;
struct LegacyAnalysisScorer:Scorer {
 LLVM24Scorer inner;
 explicit LegacyAnalysisScorer(std::string worker):inner(std::move(worker),"on"){}
 ScoreResult evaluate(const ScoreInput &i,const RoundContext &r)const override{return inner.evaluate(i,r);}
};
int main(int argc,char **argv){
 if(argc!=5)return 2;LLVMContext ctx;SMDiagnostic err;
 auto before=parseIRFile(argv[1],err,ctx),after=parseIRFile(argv[2],err,ctx);
 if(!before||!after)return 2;
 auto *b=before->getFunction(argv[3]),*a=after->getFunction(argv[3]);if(!a||!b)return 2;
 auto round=makeRound(*before,argv[3],0,CleanupMode::None);
 Trial trial;trial.valid=true;trial.cleanupMode=CleanupMode::None;trial.candidate={argv[3],"","","",0};
 trial.before=features(*b);trial.after=features(*a);trial.afterRaw=trial.after;
 trial.normalized=CloneModule(*after);trial.raw=CloneModule(*after);
 LegacyAnalysisScorer oldScorer(argv[4]);LLVM24Scorer newScorer(argv[4],"on");
 auto start=std::chrono::steady_clock::now();auto old=evaluateTrial(*before,trial,round,oldScorer);
 double oldMs=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-start).count();
 start=std::chrono::steady_clock::now();auto direct=evaluateTrial(*before,trial,round,newScorer);
 double directMs=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-start).count();
 assert(old.status==ScoreStatus::Scored&&direct.status==old.status&&direct.reason==old.reason);
 assert(old.metrics==direct.metrics&&old.total==direct.total&&old.staticGain==direct.staticGain&&old.staticScore==direct.staticScore&&old.parentGain==direct.parentGain&&old.cleanupGain==direct.cleanupGain&&old.dependencyPenalty==direct.dependencyPenalty&&old.livenessPenalty==direct.livenessPenalty&&old.profitabilityRejection==direct.profitabilityRejection);
 std::vector<double> oldWarm,newWarm;
 for(unsigned n=0;n<10;++n){
   auto run=[&](const Scorer &scorer,std::vector<double> &times){auto start=std::chrono::steady_clock::now();
     auto score=evaluateTrial(*before,trial,round,scorer);
     times.push_back(std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-start).count());
     assert(score.status==old.status&&score.metrics==old.metrics&&score.total==old.total);
   };
   if(n%2){run(newScorer,newWarm);run(oldScorer,oldWarm);}else{run(oldScorer,oldWarm);run(newScorer,newWarm);}
 }
 std::sort(oldWarm.begin(),oldWarm.end());std::sort(newWarm.begin(),newWarm.end());
 auto stale=trial.candidate;++stale.version;assert(newScorer.evaluatePair(stale,*b,*a,round).status==ScoreStatus::NotEvaluable);
 outs()<<formatv("{0:2}\n",json::Value(json::Object{{"quote_mode","on"},{"warm_repetitions",10},{"old_warm_median_ms",(oldWarm[4]+oldWarm[5])/2},{"new_warm_median_ms",(newWarm[4]+newWarm[5])/2},{"metrics_exact",true},{"old_ms",oldMs},{"direct_ms",directMs},{"before",old.metrics.at("work_before")},{"after",old.metrics.at("work_after")}}));
}
