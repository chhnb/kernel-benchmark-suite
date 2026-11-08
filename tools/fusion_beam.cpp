#include "beam_search.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/FormatVariadic.h"
#include <stdexcept>
using namespace llvm; using namespace fusion;
static json::Array pathJSON(const std::vector<Step>&path){json::Array a;for(auto&s:path)a.push_back(json::Object{{"parent_hash",s.parentHash},{"candidate_key",s.candidateKey},{"child_hash",s.childHash}});return a;}
static void writeIR(const Module&m,const std::string&file){if(verifyModule(m,&errs()))throw std::runtime_error("invalid_output");std::error_code ec;raw_fd_ostream out(file,ec);if(ec)throw std::runtime_error(ec.message());m.print(out,nullptr);}
int main(int argc,char**argv){try{
 if(argc!=8)throw std::runtime_error("input function new-output-dir depth main-width explore-width trials");
 std::string fn=argv[2],dir=argv[3];BeamOptions o;o.depth=std::stoul(argv[4]);o.beamMain=std::stoul(argv[5]);o.beamExplore=std::stoul(argv[6]);o.maxTrials=std::stoul(argv[7]);
 if(sys::fs::exists(dir))throw std::runtime_error("output exists");
 LLVMContext ctx;SMDiagnostic err;auto input=parseIRFile(argv[1],err,ctx);if(!input||verifyModule(*input,&errs()))throw std::runtime_error("invalid_input");
 auto result=beamSearch(*input,fn,o);auto ec=sys::fs::create_directories(dir);if(ec)throw std::runtime_error(ec.message());
 writeIR(*result.best,dir+"/result.ll");
 if(result.replayMismatch) writeIR(*result.replayMismatch,dir+"/replay-mismatch.ll");
 auto root=CloneModule(*input);cleanup(*root,fn,o.optLevel,o.cleanupMode);
 json::Array top;unsigned exportTrials=0;bool allReplay=result.bestReplayVerified;unsigned index=0;
 for(auto&e:result.top){std::string error;auto m=replay(*root,fn,e.path,o,&error,&exportTrials);bool ok=bool(m);allReplay &=ok;std::string file="top-"+std::to_string(index++)+".ll";{std::error_code ec;raw_fd_ostream out(dir+"/"+file,ec);if(ec)throw std::runtime_error(ec.message());out<<e.irText;}top.push_back(json::Object{{"hash",e.hash},{"cost",e.cost},{"path",pathJSON(e.path)},{"replay_verified",ok},{"error",error},{"file",file},{"artifact_source","actual_search_snapshot"}});}
 json::Object failures;for(auto&f:result.failures)failures[f.first]=int64_t(f.second);
 json::Object j{{"function",fn},{"baseline_cost",result.baselineCost},{"best_cost",result.bestCost},{"best_path",pathJSON(result.bestPath)},{"best_replay_verified",result.bestReplayVerified},{"replay_error",result.replayError},{"all_export_replays_verified",allReplay},{"top",std::move(top)},{"trials",int64_t(result.trials)},{"best_replay_trials",int64_t(result.replayTrials)},{"top_export_trials",int64_t(exportTrials)},{"nodes_expanded",int64_t(result.nodesExpanded)},{"dedup_hits",int64_t(result.dedupHits)},{"failures",std::move(failures)},{"semantic_rejects",int64_t(result.semanticRejects)},{"semantic_validation","not_run"},{"truncated",result.truncated},{"stop",result.stop},{"global_optimality_proven",false},{"layer_budget_cuts",int64_t(result.layerBudgetCuts)},{"pool_drops",int64_t(result.poolDrops)},{"beam_drops",int64_t(result.beamDrops)},{"depth",int64_t(o.depth)},{"beam_main",int64_t(o.beamMain)},{"beam_explore",int64_t(o.beamExplore)},{"max_trials",int64_t(o.maxTrials)},{"objective","whole-function legacy static cost after fixed-point cleanup"}};
 raw_fd_ostream log(dir+"/result.json",ec);if(ec)throw std::runtime_error(ec.message());log<<formatv("{0:2}\n",json::Value(std::move(j)));
 outs()<<fn<<" best="<<result.bestCost<<" trials="<<result.trials<<" stop="<<result.stop<<" replay="<<allReplay<<"\n";return allReplay?0:2;
}catch(const std::exception&e){errs()<<e.what()<<"\n";return 1;}}
