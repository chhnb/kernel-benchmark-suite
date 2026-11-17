// Diagnostic: per-layout probe or isolated full/incremental greedy comparison.
#include "isolated_b2b_greedy.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/FormatVariadic.h"
#include <chrono>
int main(int argc,char **argv){
 using namespace llvm;using namespace fusion;
 if(argc!=5&&argc!=6)return 2;
 auto &options=cl::getRegisteredOptions();auto opt=options.find("two-entry-phi-node-folding-threshold");
 if(opt==options.end()||opt->second->addOccurrence(0,"two-entry-phi-node-folding-threshold","7"))return 2;
 LLVMContext ctx;SMDiagnostic err;auto m=parseIRFile(argv[1],err,ctx);
 if(!m){err.print(argv[0],errs());return 2;}auto *f=m->getFunction(argv[2]);if(!f)return 2;
 LLVM24Scorer scorer(argv[3],"off");IRIdentity ids(*m);
 if(argc==6&&StringRef(argv[5])=="identity"){
   auto catalog=[&](){
     std::set<std::string> stable,coordinates;
     for(auto &r:resolveCandidateCatalog(*f,0)){
       auto id=[&](BasicBlock *b){return b?std::to_string(ids.block(*b)):"none";};
       stable.insert(id(r.split)+":"+(r.leftRegion?"R":"B")+id(r.leftEntry)+":"+id(r.leftExit)+":"+
                     (r.rightRegion?"R":"B")+id(r.rightEntry)+":"+id(r.rightExit));
       coordinates.insert(r.candidate.key());
     }
     return std::make_pair(stable,coordinates);
   };
   auto before=catalog();if(before.first.empty()||f->size()<3)return 1;
   unsigned n=0;for(auto &b:*f)b.setName("renamed."+std::to_string(n++));
   f->back().moveBefore(&*std::next(f->begin()));
   auto after=catalog();
   if(before.first!=after.first||before.second==after.second)return 1;
   outs()<<"PASS stable region identities across block renaming and reordering\n";return 0;
 }
 if(argc==6){
   double fullMs=0,cachedMs=0;
   auto run=[&](bool reuse){
     auto start=std::chrono::steady_clock::now();
     auto result=runIsolatedB2BGreedy(*m,argv[2],scorer,reuse,[&](const Module &ir,unsigned n){
       std::string path=std::string(argv[4])+(reuse?"/cached-":"/full-")+std::to_string(n)+".ll";
       std::error_code ec;raw_fd_ostream out(path,ec);if(ec)throw std::runtime_error(ec.message());ir.print(out,nullptr);
     },StringRef(argv[5])=="hybrid"||StringRef(argv[5])=="catalog",StringRef(argv[5])=="catalog");
     auto ms=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-start).count();
     (reuse?cachedMs:fullMs)=ms;
     std::error_code ec;raw_fd_ostream phase(std::string(argv[4])+(reuse?"/cached-phase.json":"/full-phase.json"),ec);
     if(ec)throw std::runtime_error(ec.message());
     phase<<formatv("{0:2}\n",json::Value(json::Object{{"elapsed_ms",ms},{"trials",int64_t(result.stats.trials)},{"commits",int64_t(result.stats.commits)}}));
     return result;
   };
   auto full=run(false),cached=run(true);
   if(full.hashes!=cached.hashes||full.identities!=cached.identities||full.costs!=cached.costs||full.gains!=cached.gains)
     throw std::runtime_error("real incremental/full divergence");
   json::Object fallbackOutcomes;for(auto &kv:cached.stats.fallbackOutcomes)fallbackOutcomes[kv.first]=int64_t(kv.second);
   json::Array costs,identities;for(auto c:full.costs)costs.push_back(c);for(auto &id:full.identities)identities.push_back(id);
   outs()<<formatv("{0:2}\n",json::Value(json::Object{
     {"fallback_outcomes",std::move(fallbackOutcomes)},{"identities",std::move(identities)},{"commits",int64_t(full.stats.commits)},{"costs",std::move(costs)},
     {"full_fallback_trials",int64_t(full.stats.fallbackTrials)},{"cached_fallback_trials",int64_t(cached.stats.fallbackTrials)},{"fallback_commits",int64_t(cached.stats.fallbackCommits)},{"full_trials",int64_t(full.stats.trials)},{"cached_trials",int64_t(cached.stats.trials)},
     {"reused_trials",int64_t(cached.stats.reusedTrials)},{"invalidated",int64_t(cached.stats.invalidated)},
     {"full_cleanups",int64_t(full.stats.layoutCleanups)},{"cached_cleanups",int64_t(cached.stats.layoutCleanups)},
     {"full_scores",int64_t(full.stats.scores)},{"cached_scores",int64_t(cached.stats.scores)},
     {"full_elapsed_ms",fullMs},{"cached_elapsed_ms",cachedMs},{"exact_step_parity",true}}));return 0;
 }
 auto round=makeRound(*m,argv[2],0,0,CleanupMode::None);
 json::Array results;unsigned n=0;
 for(auto &b:*f){auto unit=B2BOptimizationUnit::discover(b,ids);if(!unit.eligible())continue;
  auto *exit=ids.lookup(unit.exit)->getParent();if(exit->phis().empty())continue;
  B2BUnitCapsule capsule(*m,b);
  Trial control;control.valid=true;control.cleanupMode=CleanupMode::None;control.candidate={argv[2],"","","",0};
  control.normalized=capsule.apply(*m,*capsule.ir);control.raw=CloneModule(*control.normalized);
  control.before=features(*f);control.after=features(*control.normalized->getFunction(argv[2]));control.afterRaw=control.after;
  auto controlScore=evaluateTrial(*m,control,round,scorer);
  if(controlScore.status!=ScoreStatus::Scored)return 1;
  auto layouts=planSingleBranchB2B(*capsule.ir,{"unit","B0","B1","B2"},1,CleanupMode::DarmCFGInstCombine,"");
  for(auto &layout:layouts){if(!layout.valid||!layout.normalized)continue;
   Trial trial;trial.valid=true;trial.cleanupMode=CleanupMode::None;trial.candidate={argv[2],"","","",0};
   trial.normalized=capsule.apply(*m,*layout.normalized);trial.raw=CloneModule(*trial.normalized);
   trial.before=features(*f);trial.after=features(*trial.normalized->getFunction(argv[2]));trial.afterRaw=trial.after;
   auto score=evaluateTrial(*m,trial,round,scorer);
   if(score.status!=ScoreStatus::Scored){errs()<<"unscored layout\n";return 1;}
   std::string path=std::string(argv[4])+"/layout-"+std::to_string(n++)+".ll";std::error_code ec;
   raw_fd_ostream out(path,ec);if(ec)return 2;trial.normalized->print(out,nullptr);
   results.push_back(json::Object{{"candidate",unit.identity},{"unchanged_capsule_cost",controlScore.metrics.at("work_after")},{"plan_kind",layout.planKind},{"merge_path",layout.mergePath},{"file",path},{"before",score.metrics.at("work_before")},{"after",score.metrics.at("work_after")}});
  }
 }
 outs()<<formatv("{0:2}\n",json::Value(std::move(results)));
}
