#include "fusion_search.h"
#include "logical_region_state.h"
#include "llvm24_scorer.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/FormatVariadic.h"
#include <algorithm>
#include <stdexcept>
using namespace llvm;using namespace fusion;
static void write(const std::string&p,const std::string&s){std::error_code e;raw_fd_ostream o(p,e);if(e)throw std::runtime_error(e.message());o<<s;}
static void ir(const std::string&p,Module&m){std::string s;raw_string_ostream o(s);m.print(o,nullptr);write(p,o.str());}
int main(int argc,char**argv){try{
 if(argc!=5)throw std::runtime_error("INPUT FUNCTION DECISION OUTPUT_DIR required");
 LLVMContext ctx;SMDiagnostic diag;auto module=parseIRFile(argv[1],diag,ctx);if(!module)throw std::runtime_error("parse failed");
 std::string fn=argv[2],decision=argv[3],dir=argv[4];if(sys::fs::exists(dir))throw std::runtime_error("output exists");if(auto e=sys::fs::create_directories(dir))throw std::runtime_error(e.message());
 auto*func=module->getFunction(fn);if(!func)throw std::runtime_error("function missing");auto state=LogicalRegionState::initialize(*func);
 LLVM24Scorer scorer("/home/chh/kernel-benchmark-suite/tools/run-llvm24-tti");Options opts;opts.cleanupMode=CleanupMode::None;opts.adjacentOnly=true;opts.localCopysign=true;opts.localUnion=true;
 json::Array rounds;std::string stop="round_cap";unsigned commits=0;
 for(unsigned version=0;version<16;++version){
  ir(dir+"/state-"+std::to_string(version)+".ll",*module);write(dir+"/logical-state-"+std::to_string(version)+".json",state->json());
  DecisionGroup*group=nullptr;for(auto&d:state->decisions)if(d.id==decision)group=&d;if(!group)throw std::runtime_error("decision missing");
  std::map<std::string,unsigned> rank;for(auto i:group->active)rank[group->history[i].id]=group->history[i].first;
  auto all=state->filter(*module->getFunction(fn),enumerate(*module->getFunction(fn),version));std::vector<Candidate> candidates;
  for(auto&c:all)if(c.logicalDecision==decision)candidates.push_back(c);
  std::sort(candidates.begin(),candidates.end(),[&](auto&a,auto&b){if(rank.at(a.logicalLeft)!=rank.at(b.logicalLeft))return rank.at(a.logicalLeft)<rank.at(b.logicalLeft);return a.key()<b.key();});
  auto round=makeRound(*module,fn,version,3,CleanupMode::None);Trial best;ScoreResult bestScore;double score=0;json::Array attempts;
  for(auto c:candidates){c.localCopysign=true;c.localUnion=true;auto t=tryPair(*module,c,version,3,CleanupMode::None,state.get());auto s=evaluateTrial(*module,t,round,scorer);bool accept=eligible(t,s,opts);
   attempts.push_back(json::Object{{"left",c.logicalLeft},{"right",c.logicalRight},{"candidate",c.key()},{"valid",t.valid},{"reason",t.reason},{"gain",s.status==ScoreStatus::Scored?json::Value(s.staticGain):json::Value(nullptr)},{"eligible",accept}});
   if(accept&&s.total>score){score=s.total;bestScore=std::move(s);best=std::move(t);}
  }
  json::Object record{{"version",int64_t(version)},{"attempts",std::move(attempts)}};
  if(!best.valid){record["committed"]=false;rounds.push_back(std::move(record));stop=candidates.empty()?"no_supported_candidates":"no_eligible_candidate";break;}
  record["committed"]=true;record["left"]=best.candidate.logicalLeft;record["right"]=best.candidate.logicalRight;record["gain"]=bestScore.staticGain;record["cost_before"]=bestScore.metrics.at("work_before");record["cost_after"]=bestScore.metrics.at("work_after");
  rounds.push_back(std::move(record));state=std::move(best.logicalState);module=std::move(best.normalized);++commits;
 }
 if(verifyModule(*module,&errs()))throw std::runtime_error("invalid final module");ir(dir+"/final.ll",*module);
 write(dir+"/summary.json",formatv("{0:2}\n",json::Value(json::Object{{"decision",decision},{"tie_break","leftmost initial leaf interval, then physical candidate key"},{"commits",int64_t(commits)},{"stop",stop},{"rounds",std::move(rounds)}})).str());outs()<<"commits="<<commits<<" stop="<<stop<<"\n";
 }catch(const std::exception&e){errs()<<e.what()<<"\n";return 1;}}
