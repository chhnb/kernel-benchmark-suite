#include "fusion_search.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/FormatVariadic.h"
#include <algorithm>
#include <functional>
#include <set>
#include <stdexcept>
using namespace llvm;using namespace fusion;
struct SeedTrace:Observer {std::vector<std::string> actions;void commit(unsigned,const Candidate&c,const ScoreResult&,const Module&)override{actions.push_back(c.key());}};
int main(int argc,char**argv){try{
 if(argc!=7)throw std::runtime_error("input function output-directory max-depth max-trials seed-trials");
 std::string fn=argv[2],dir=argv[3];unsigned depth=std::stoul(argv[4]),budget=std::stoul(argv[5]),seedBudget=std::stoul(argv[6]);
 if(depth>64||budget>100000||!depth)throw std::runtime_error("invalid limits");
 if(sys::fs::exists(dir))throw std::runtime_error("output exists");sys::fs::create_directories(dir);
 LLVMContext ctx;SMDiagnostic err;auto initial=parseIRFile(argv[1],err,ctx);if(!initial||verifyModule(*initial,&errs()))throw std::runtime_error("input invalid");
 if(!initial->getFunction(fn))throw std::runtime_error("function missing");
 cleanup(*initial,fn,3,CleanupMode::DarmCFGScalarFixedPoint);
 auto best=CloneModule(*initial);auto initialCost=features(*best->getFunction(fn)).cost,bestCost=initialCost;
 std::vector<std::string> bestPath;std::string origin="initial";unsigned trials=0,nodes=0,hits=0,cutoffs=0;bool limited=false;
 Options o;o.cleanupMode=CleanupMode::DarmCFGScalarFixedPoint;o.maxRounds=depth;o.maxTrials=seedBudget;
 SeedTrace seedTrace;auto seed=greedy(*initial,fn,o,StaticCostScorer(),&seedTrace);auto seedCost=features(*seed.module->getFunction(fn)).cost;
 if(seedCost<bestCost){bestCost=seedCost;best=std::move(seed.module);origin="greedy_seed";bestPath=seedTrace.actions;}
 std::set<std::string> seen;
 struct Child{std::unique_ptr<Module> m;std::string action;int64_t cost;};
 std::function<void(const Module&,std::vector<std::string>&)> visit;
 visit=[&](const Module&m,std::vector<std::string>&path){
  // Include remaining depth: reaching the same IR earlier leaves more legal search.
  auto key=moduleHash(m)+":"+std::to_string(depth-path.size());
  if(!seen.insert(key).second){hits++;return;}nodes++;
  if(path.size()>=depth){cutoffs++;return;}
  auto candidates=enumerate(*const_cast<Function*>(m.getFunction(fn)),path.size());std::vector<Child> children;
  for(auto&c:candidates){
   if(trials>=budget){limited=true;break;}trials++;
   auto t=tryPair(m,c,path.size(),3,CleanupMode::DarmCFGScalarFixedPoint);
   if(!t.valid)continue;
   auto cost=features(*t.normalized->getFunction(fn)).cost;
   if(cost<bestCost){bestCost=cost;best=CloneModule(*t.normalized);bestPath=path;bestPath.push_back(c.key());origin="backtracking";}
   children.push_back({std::move(t.normalized),c.key(),cost});
  }
  std::stable_sort(children.begin(),children.end(),[](const Child&a,const Child&b){return a.cost<b.cost;});
  for(auto&c:children){if(limited)break;path.push_back(c.action);visit(*c.m,path);path.pop_back();}
 };
 std::vector<std::string> path;visit(*initial,path);
 if(verifyModule(*best,&errs()))throw std::runtime_error("best invalid");
 std::error_code ec;raw_fd_ostream ir(dir+"/result.ll",ec);if(ec)throw std::runtime_error(ec.message());best->print(ir,nullptr);
 json::Array actions;for(auto&s:bestPath)actions.push_back(s);
 json::Object j{{"objective","minimum whole-function legacy static cost after fixed-point cleanup; not GPU time or cumulative Share"},{"function",fn},{"initial_cost",initialCost},{"best_cost",bestCost},{"best_origin",origin},{"backtracking_path",std::move(actions)},{"seed_cost",seedCost},{"seed_commits",int64_t(seed.commits)},{"seed_trials",int64_t(seed.trials)},{"seed_stop",seed.stop},{"trials",int64_t(trials)},{"nodes",int64_t(nodes)},{"memo_hits",int64_t(hits)},{"depth_cutoffs",int64_t(cutoffs)},{"max_depth",int64_t(depth)},{"max_trials",int64_t(budget)},{"trial_budget_exhausted",limited},{"exhaustive_within_depth",!limited},{"global_optimality_proven",false},{"allows_nonpositive_steps",true},{"semantic_validation","not_run"}};
 raw_fd_ostream log(dir+"/result.json",ec);if(ec)throw std::runtime_error(ec.message());log<<formatv("{0:2}\n",json::Value(std::move(j)));
 outs()<<"best="<<bestCost<<" seed="<<seedCost<<" trials="<<trials<<" limited="<<limited<<"\n";return 0;
}catch(const std::exception&e){errs()<<e.what()<<"\n";return 1;}}
