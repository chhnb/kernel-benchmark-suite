#include "decision_model.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/Program.h"
#include "llvm/Support/FormatVariadic.h"
#include <set>
#include <cstdlib>
#include <stdexcept>
using namespace llvm;
static void save(const std::string&p,const json::Value&v){std::error_code e;raw_fd_ostream o(p,e);if(e)throw std::runtime_error(e.message());o<<formatv("{0:2}\n",v);}
static json::Value read(const std::string&p){auto b=MemoryBuffer::getFile(p);if(!b)throw std::runtime_error("missing "+p);auto v=json::parse((*b)->getBuffer());if(!v)throw std::runtime_error(toString(v.takeError()));return std::move(*v);}
static int run(std::vector<std::string> a,const std::string&out,const std::string&err){for(const auto&p:{out,err})if(auto e=sys::fs::remove(p))throw std::runtime_error("cannot reset child output: "+p+": "+e.message());std::vector<StringRef> refs;for(auto&s:a)refs.push_back(s);std::array<Optional<StringRef>,3> red{{StringRef(""),StringRef(out),StringRef(err)}};return sys::ExecuteAndWait(a[0],refs,None,red,120);}
static sys::ProcessInfo startTrial(const std::vector<std::string> &args,
                                   const std::string &dir) {
  std::vector<StringRef> refs(args.begin(),args.end());
  const std::string output=dir+".stdout",error=dir+".stderr";
  std::array<Optional<StringRef>,3> redirects{
      StringRef(""),StringRef(output),StringRef(error)};
  bool failed=false;
  auto process=sys::ExecuteNoWait(refs.front(),refs,None,redirects,0,nullptr,&failed);
  return failed?sys::ProcessInfo():process;
}
static bool eligible(const decision::Arm&a,const decision::Arm&b){return a.kind!=decision::ArmKind::Unsupported&&b.kind!=decision::ArmKind::Unsupported;}
int main(int argc,char**argv){try{
 if(argc!=5)throw std::runtime_error("INPUT FUNCTION TOOL_ROOT NEW_OUTPUT required");
 std::string current=argv[1],fn=argv[2],root=argv[3],out=argv[4];if(sys::fs::exists(out))throw std::runtime_error("output exists");if(auto e=sys::fs::create_directories(out))throw std::runtime_error(e.message());
 auto limit=[](const char *name,int64_t fallback){const char*v=std::getenv(name);if(!v)return fallback;char*end=nullptr;auto n=std::strtoll(v,&end,10);if(!*v||*end||n<0||n>1000000)throw std::runtime_error(std::string("invalid ")+name);return int64_t(n);};
 const auto jobs=limit("DECISION_GREEDY_JOBS",1);
 if(jobs<1||jobs>64)throw std::runtime_error("DECISION_GREEDY_JOBS must be between 1 and 64");
 if(std::getenv("DECISION_CFG_CLEANUP")&&std::getenv("DECISION_DISABLE_SIMPLIFYCFG"))throw std::runtime_error("DECISION_CFG_CLEANUP conflicts with legacy DECISION_DISABLE_SIMPLIFYCFG");
 std::string cleanup=std::getenv("DECISION_CFG_CLEANUP")?std::getenv("DECISION_CFG_CLEANUP"):"structural";
 if(cleanup!="full"&&cleanup!="structural")throw std::runtime_error("invalid DECISION_CFG_CLEANUP");
 const int64_t requestedUniformLoss=limit("DECISION_MAX_UNIFORM_LOSS",std::getenv("DECISION_SPECULATION")&&std::string(std::getenv("DECISION_SPECULATION"))=="cost"?0:-1);
 const int64_t maxUniformLoss=cleanup=="full"?-1:requestedUniformLoss,maxPressureGrowth=limit("DECISION_MAX_PRESSURE_GROWTH",0),maxPressure=limit("DECISION_MAX_PRESSURE",1000000);
 LLVMContext ctx;SMDiagnostic error;auto initial=parseIRFile(current,error,ctx);if(!initial||!initial->getFunction(fn)||verifyModule(*initial,&errs()))throw std::runtime_error("invalid input");
 auto ds=decision::discover(*initial->getFunction(fn));std::vector<std::string> targets;std::set<BasicBlock*> covered,tagged;json::Array order;
 for(auto &d:ds){bool yes=false;for(unsigned i=0;i+1<d.arms.size();++i)yes|=eligible(d.arms[i],d.arms[i+1]);if(!yes||covered.count(d.root))continue;targets.push_back(d.id);for(auto*b:d.tests)covered.insert(b);for(unsigned i=0;i<d.arms.size();++i){auto&a=d.arms[i];if(!tagged.insert(a.entry).second)continue;std::string label;raw_string_ostream stream(label);a.entry->printAsOperand(stream,false);stream.flush();order.push_back(json::Object{{"entry",label},{"family",d.id},{"index",int64_t(i)}});}}
 save(out+"/order.json",json::Value(std::move(order)));json::Array targetJSON;for(auto&t:targets)targetJSON.push_back(t);save(out+"/targets.json",json::Value(std::move(targetJSON)));
 auto cost=[&](const std::string&input,const std::string&prefix){if(run({root+"/tools/run-llvm24-tti",input,fn},prefix+".json",prefix+".stderr"))throw std::runtime_error("TTI worker failed: "+prefix);auto v=read(prefix+".json");auto*o=v.getAsObject();if(!o||o->getInteger("unknown")!=Optional<int64_t>(0)||o->getString("source_revision")!=Optional<StringRef>("6be16f356d3e"))throw std::runtime_error("TTI unknown cost or revision mismatch");auto n=o->getInteger("cost");if(!n)throw std::runtime_error("missing cost");return *n;};
 int64_t parentCost=cost(current,out+"/initial-tti"),initialCost=parentCost;unsigned commits=0,trials=0;json::Array rounds,stops;
 auto report=[&](StringRef status){save(out+"/summary.json",json::Value(json::Object{{"status",status.str()},{"search","per-decision greedy; best positive adjacent candidate; initial decision order"},{"cfg_cleanup",cleanup},{"implicit_speculation_diagnostic_only",cleanup=="full"},{"uniform_loss_guard_enabled",maxUniformLoss>=0},{"max_uniform_loss",maxUniformLoss},{"max_pressure_growth",maxPressureGrowth},{"max_pressure",maxPressure},{"initial_cost",initialCost},{"final_cost",parentCost},{"commits",int64_t(commits)},{"trials",int64_t(trials)},{"final_ir",current},{"rounds",json::Value(json::Array(rounds))},{"stops",json::Value(json::Array(stops))}}));};
 report("running");
 for(auto &target:targets){for(unsigned iteration=0;iteration<256;++iteration){
  auto m=parseIRFile(current,error,ctx);if(!m)throw std::runtime_error("cannot read parent");auto catalog=decision::discover(*m->getFunction(fn));unsigned di=0;for(;di<catalog.size();++di)if(catalog[di].id==target)break;if(di==catalog.size()){stops.push_back(json::Object{{"decision",target},{"reason","decision_completed_or_absorbed"}});break;}
  unsigned identities=0;for(auto &candidate:catalog)identities+=candidate.id==target;if(identities!=1)throw std::runtime_error("ambiguous decision identity: "+target);
  cost(current,out+"/parent-side-tti");
  auto &d=catalog[di];int64_t bestCost=parentCost;std::string best;json::Array attempts;
  struct Trial { unsigned left; std::string dir; int rc; };
  std::vector<Trial> evaluated;
  unsigned next=0;
  while(next+1<d.arms.size()){
   std::vector<sys::ProcessInfo> running;
   const size_t start=evaluated.size();
   while(next+1<d.arms.size()&&evaluated.size()-start<size_t(jobs)){
    unsigned left=next++;
    if(!eligible(d.arms[left],d.arms[left+1]))continue;
    if(trials>=100000)throw std::runtime_error("trial budget exceeded");
    std::string dir=out+"/trial-"+std::to_string(trials++);
    save(dir+".request.json",json::Value(json::Object{
         {"decision",target},{"left",d.arms[left].id},{"right",d.arms[left+1].id}}));
    std::vector<std::string> args{root+"/build/decision-fuse/decision-fuse",current,fn,
        std::to_string(di),std::to_string(left),dir,out+"/order.json",dir+".request.json"};
    if(jobs==1){
      int rc=run(std::move(args),dir+".stdout",dir+".stderr");
      evaluated.push_back({left,std::move(dir),rc});
    }else{
      running.push_back(startTrial(args,dir));
      evaluated.push_back({left,std::move(dir),-1});
    }
   }
   for(size_t i=0;i<running.size();++i)
    if(running[i].Pid)
      evaluated[start+i].rc=sys::Wait(running[i],120,false).ReturnCode;
  }
  // Rank in the original adjacency order so ties select the same trial.
  for(const auto &trial:evaluated){
   const auto left=trial.left;
   const auto &dir=trial.dir;
   const int rc=trial.rc;
   json::Object attempt{{"directory",dir},{"left",d.arms[left].id},
                        {"right",d.arms[left+1].id},{"exit_code",rc}};
   if(rc){if(sys::fs::exists(dir+"/trial.json")){auto v=read(dir+"/trial.json");auto*r=v.getAsObject();if(r)if(auto reason=r->getString("reason"))attempt["reason"]=reason->str();}else attempt["reason"]="trial_process_failed";}
   else{auto verified=read(dir+"/trial.json");auto *actual=verified.getAsObject();
    if(!actual||actual->getString("decision")!=Optional<StringRef>(target)||actual->getString("left")!=Optional<StringRef>(d.arms[left].id)||actual->getString("right")!=Optional<StringRef>(d.arms[left+1].id))throw std::runtime_error("trial identity mismatch: "+dir);
    auto c=cost(dir+"/fused.ll",dir+"/tti");attempt["cost"]=c;attempt["gain"]=parentCost-c;std::string reject;
    auto *pb=actual->getObject("ir_pressure_before"),*pa=actual->getObject("ir_pressure");
    if(!pb||!pa||pb->getBoolean("complete")!=Optional<bool>(true)||pa->getBoolean("complete")!=Optional<bool>(true)||!pb->getInteger("peak_slots32")||!pa->getInteger("peak_slots32"))reject="pressure_metrics_unavailable";
    else if(*pa->getInteger("peak_slots32")>maxPressure||*pa->getInteger("peak_slots32")>*pb->getInteger("peak_slots32")+maxPressureGrowth)reject="pressure_limit";
    auto sideCost=[&](const json::Object&tti,const json::Array*blocks,int64_t&sum){sum=0;auto*rows=tti.getArray("instruction_costs");if(!rows||!blocks)return false;std::set<int64_t> wanted;for(auto&v:*blocks){auto n=v.getAsInteger();if(!n||*n<0)return false;wanted.insert(*n);}std::set<int64_t> found;for(auto&row:*rows){auto*r=row.getAsObject();if(!r)return false;auto bi=r->getInteger("block_index");if(!bi)return false;if(wanted.count(*bi)){auto v=r->getInteger("accepted_cost");if(!v)return false;sum+=*v;found.insert(*bi);}}return wanted==found;};
    auto beforeTTI=read(out+"/parent-side-tti.json");auto afterTTI=read(dir+"/tti.json");
    bool sidesOK=actual->getBoolean("side_metrics_available")==Optional<bool>(true);
    for(auto side:{"false","true"}){int64_t before=0,after=0;bool ok=beforeTTI.getAsObject()&&afterTTI.getAsObject()&&sideCost(*beforeTTI.getAsObject(),actual->getArray(std::string("side_before_")+side),before)&&sideCost(*afterTTI.getAsObject(),actual->getArray(std::string("side_after_")+side),after);sidesOK&=ok;if(ok){attempt[std::string("uniform_gain_")+side]=before-after;if(maxUniformLoss>=0&&after-before>maxUniformLoss&&reject.empty())reject="uniform_loss_limit";}}
    attempt["side_metrics_available"]=sidesOK;
    if(maxUniformLoss>=0&&!sidesOK&&reject.empty())reject="side_metrics_unavailable";
    attempt["eligible"]=reject.empty()&&c<parentCost;
    if(!reject.empty())attempt["reason"]=reject;
    if(reject.empty()&&c<bestCost){bestCost=c;best=dir;}}
   attempts.push_back(std::move(attempt));
  }
  json::Object record{{"decision",target},{"iteration",int64_t(iteration)},{"parent",current},{"parent_cost",parentCost},{"attempts",std::move(attempts)},{"selected",best}};
  if(best.empty()){rounds.push_back(std::move(record));stops.push_back(json::Object{{"decision",target},{"reason","no_positive_legal_candidate"}});report("running");break;}
  record["selected_cost"]=bestCost;record["score"]=double(parentCost-bestCost)/std::max<int64_t>(parentCost,1);rounds.push_back(std::move(record));parentCost=bestCost;current=best+"/fused.ll";++commits;report("running");outs()<<"commit="<<commits<<" cost="<<parentCost<<" decision="<<target<<"\n";outs().flush();
  if(iteration==255)throw std::runtime_error("round budget exceeded");
 }}
 if(auto e=sys::fs::copy_file(current,out+"/final.ll"))throw std::runtime_error(e.message());current=out+"/final.ll";report("completed");return 0;
}catch(const std::exception&e){errs()<<e.what()<<"\n";return 1;}}
