// Offline E0 diagnostics: never participates in candidate selection or commit.
#include "postopt_scorer.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/FormatVariadic.h"
#include "llvm/Support/SHA1.h"
#include "llvm/ADT/StringExtras.h"
#include <chrono>
#include <array>
#include <map>
#include <set>
#include <stdexcept>
using namespace llvm;
using namespace fusion;
static std::string bytes(const std::string &p) {
  auto b=MemoryBuffer::getFile(p);
  if(!b)throw std::runtime_error("cannot read "+p);
  return b.get()->getBuffer().str();
}
static std::string sha(StringRef s) {
  return toHex(SHA1::hash(ArrayRef<uint8_t>(reinterpret_cast<const uint8_t*>(s.data()),s.size())),true);
}
struct Stage {
  std::unique_ptr<LLVMContext> context;
  std::unique_ptr<Module> module;
  Function *function=nullptr;
  PostOptFeatures features;
  std::string path, fileHash, target;
  bool complete()const{return features.targetAvailable&&features.unknown==0;}
};
static Stage readStage(const std::string &p,const std::string &fn,int allocaCost) {
  Stage s;s.path=p;auto data=bytes(p);s.fileHash=sha(data);
  s.context=std::make_unique<LLVMContext>();SMDiagnostic e;
  s.module=parseIR(MemoryBufferRef(data,p),e,*s.context);
  if(!s.module||verifyModule(*s.module,&errs()))throw std::runtime_error("invalid IR: "+p);
  s.function=s.module->getFunction(fn);
  if(!s.function||s.function->isDeclaration())throw std::runtime_error("missing function: "+fn);
  auto &f=*s.function;
  s.target=s.module->getTargetTriple()+"|"+s.module->getDataLayoutStr()+"|"+
    f.getFnAttribute("target-cpu").getValueAsString().str()+"|"+
    f.getFnAttribute("target-features").getValueAsString().str();
  s.features=postOptFeatures(f,allocaCost,false);return s;
}
static json::Object stageJson(const Stage&s) {
  const auto &f=s.features;uint64_t valid=0,zero=0;double sum=0;
  json::Array table;
  for(auto &kv:f.costTable){valid+=kv.second.first;zero+=kv.second.second==0?kv.second.first:0;
    double cost=double(kv.second.first)*kv.second.second;sum+=cost;
    table.push_back(json::Object{{"key",kv.first},{"count",int64_t(kv.second.first)},
      {"unit_cost",kv.second.second},{"total_cost",cost}});
  }
  if(f.targetAvailable&&(valid+f.unknown!=f.instructions||sum!=f.work))
    throw std::runtime_error("cost coverage invariant failed");
  json::Object categories;for(auto&kv:f.categories)categories[kv.first]=kv.second;
  return json::Object{{"path",s.path},{"file_sha1",s.fileHash},{"verifier_passed",true},
    {"target_available",f.targetAvailable},{"cost_complete",s.complete()},
    {"cost",s.complete()?json::Value(f.work):json::Value(nullptr)},
    {"modeled_subtotal",f.targetAvailable?json::Value(f.work):json::Value(nullptr)},
    {"instructions",int64_t(f.instructions)},{"valid_cost_instructions",int64_t(valid)},
    {"zero_cost_instructions",int64_t(zero)},{"unknown_cost_instructions",int64_t(f.unknown)},
    {"unknown_fraction",f.targetAvailable?json::Value(double(f.unknown)/std::max<uint64_t>(f.instructions,1)):json::Value(nullptr)},
    {"categories",std::move(categories)},{"opcode_type_cost_table",std::move(table)}};
}
int main(int argc,char**argv) {
 try {
  std::string dir,out;unsigned trial=0;int allocaCost=-1;
  for(int i=1;i<argc;++i){std::string k=argv[i];
    if(k=="--help"){outs()<<"postopt-diagnostics --debug-dir DIR --trial N --out NEW.json [--static-alloca-cost POSITIVE_INT]\nReads saved snapshots only; no scoring or IR changes.\n";return 0;}
    if(++i==argc)throw std::runtime_error("missing argument");std::string v=argv[i];
    if(k=="--debug-dir")dir=v;else if(k=="--out")out=v;
    else if(k=="--trial"||k=="--static-alloca-cost") {
      size_t pos=0;auto n=std::stoul(v,&pos);
      if(v.empty()||v[0]=='-'||pos!=v.size()||n>1000000||(k=="--static-alloca-cost"&&n==0))throw std::runtime_error("invalid integer");
      if(k=="--trial")trial=n;else allocaCost=n;
    }else throw std::runtime_error("unknown argument: "+k);
  }
  if(dir.empty()||out.empty())throw std::runtime_error("debug-dir and out required");
  if(sys::fs::exists(out))throw std::runtime_error("output already exists");
  auto start=std::chrono::steady_clock::now();
  const auto path=dir+"/trial-"+std::to_string(trial);
  auto meta=json::parse(bytes(path+"/trial.json"));
  if(!meta)throw std::runtime_error(toString(meta.takeError()));
  auto *o=meta->getAsObject();if(!o)throw std::runtime_error("invalid trial metadata");
  auto version=o->getInteger("version");auto candidate=o->getString("candidate");
  if(!version||*version<0||!candidate)throw std::runtime_error("missing candidate/version");
  auto valid=o->getBoolean("valid");if(!valid||!*valid)throw std::runtime_error("trial was rejected; no complete four-stage diagnostic");
  std::string fn=candidate->split(':').first.str(),round=std::to_string(*version);
  auto S=readStage(dir+"/state-"+round+".ll",fn,allocaCost);
  auto B=readStage(dir+"/round-"+round+"-control.ll",fn,allocaCost);
  auto R=readStage(path+"/after-raw.ll",fn,allocaCost);
  auto A=readStage(path+"/after.ll",fn,allocaCost);
  if(S.target!=B.target||S.target!=R.target||S.target!=A.target)throw std::runtime_error("stage target mismatch");
  auto roundMeta=json::parse(bytes(dir+"/round-"+round+".json"));
  if(!roundMeta)throw std::runtime_error(toString(roundMeta.takeError()));
  auto *ro=roundMeta->getAsObject();if(!ro)throw std::runtime_error("invalid round metadata");
  // File hashes bind the exact archived snapshots, without relying on a parse/print roundtrip.
  for(auto key:{"parent_hash","control_hash"}) {
    auto t=o->getString(key),r=ro->getString(key);
    if(!t||!r||*t!=*r)throw std::runtime_error("trial/round identity mismatch");
    if(*t!=(StringRef(key)=="parent_hash"?S.fileHash:B.fileHash))throw std::runtime_error("snapshot hash mismatch");
  }
  auto cleaned=o->getString("cleaned_hash");
  if(!cleaned||*cleaned!=A.fileHash)throw std::runtime_error("cleaned snapshot hash mismatch");
  const bool complete=S.complete()&&B.complete()&&R.complete()&&A.complete();
  const double s=S.features.work,b=B.features.work,r=R.features.work,a=A.features.work;
  auto value=[&](double n){return complete?json::Value(n):json::Value(nullptr);};
  std::map<std::string,std::array<double,4>> opcode;
  Stage*stages[]={&S,&B,&R,&A};
  for(unsigned i=0;i<4;++i)for(auto&kv:stages[i]->features.costTable)
    opcode[kv.first.substr(0,kv.first.find(':'))][i]+=double(kv.second.first)*kv.second.second;
  json::Array rows;
  for(auto&kv:opcode)rows.push_back(json::Object{{"opcode",kv.first},{"S",kv.second[0]},
    {"B",kv.second[1]},{"R",kv.second[2]},{"A",kv.second[3]},
    {"modeled_net_delta",kv.second[1]-kv.second[3]}});
  auto cleanup=ro->getString("cleanup");
  json::Object report{{"schema","postopt-four-stage-diagnostics-v1"},{"diagnostics_only",true},
    {"candidate",candidate->str()},{"round_id",*version},{"trial_id",int64_t(trial)},
    {"target",S.target},{"cost_kind","TCK_RecipThroughput"},
    {"scope","entry-reachable blocks of selected function; debug intrinsics excluded"},
    {"cost_model","existing postOptFeatures; explicit freeze fallback; uncalibrated static proxy"},
    {"static_alloca_cost",allocaCost},{"cleanup",cleanup?cleanup->str():"unknown"},
    {"state_policy","historical coupled mode: normalized A is candidate commit state"},
    {"score_input","N(S) versus N(R); no separated state cleanup introduced by E0"},
    {"S",stageJson(S)},{"B",stageJson(B)},{"R",stageJson(R)},{"A",stageJson(A)},
    {"all_costs_complete",complete},{"transformation_gain",value(s-r)},
    {"cleanup_interaction",value((r-a)-(s-b))},{"net_gain",value(b-a)},
    {"parent_gain",value(s-a)},{"decomposition_residual",value((s-r)+(r-a)-(s-b)-(b-a))},
    {"transformation_boundary","R already includes DARM internal postprocessing"},
    {"unknown_handling","partial modeled subtotals retained; complete gains null if any stage unavailable; no unknown-cost cancellation"},
    {"opcode_modeled_cost_breakdown",std::move(rows)},
    {"legacy_parent_gain_field","unchanged; PostOptScorer uses control gain for compatibility, not diagnostic S-A"},
    {"semantic_validation","not_run_by_diagnostics"},
    {"diagnostics_ms",std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-start).count()}};
  std::error_code ec;raw_fd_ostream stream(out,ec);if(ec)throw std::runtime_error(ec.message());
  stream<<formatv("{0:2}\n",json::Value(std::move(report)));
  outs()<<"diagnostics written; complete="<<complete<<"; source snapshots unchanged\n";
  return 0;
 }catch(const std::exception&e){errs()<<"error: "<<e.what()<<"\n";return 2;}
}
