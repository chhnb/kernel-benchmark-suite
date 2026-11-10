#include "decision_model.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/Program.h"
#include "llvm/Support/FormatVariadic.h"
#include <set>
#include <stdexcept>
using namespace llvm;
static void save(const std::string&p,const json::Value&v){std::error_code e;raw_fd_ostream o(p,e);if(e)throw std::runtime_error(e.message());o<<formatv("{0:2}\n",v);}
static json::Value read(const std::string&p){auto b=MemoryBuffer::getFile(p);if(!b)throw std::runtime_error("missing "+p);auto v=json::parse((*b)->getBuffer());if(!v)throw std::runtime_error(toString(v.takeError()));return std::move(*v);}
static int run(std::vector<std::string> a,const std::string&out,const std::string&err){std::vector<StringRef> refs;for(auto&s:a)refs.push_back(s);std::array<Optional<StringRef>,3> red{{StringRef(""),StringRef(out),StringRef(err)}};return sys::ExecuteAndWait(a[0],refs,None,red,120);}
static bool eligible(const decision::Arm&a,const decision::Arm&b){return a.kind!=decision::ArmKind::Unsupported&&b.kind!=decision::ArmKind::Unsupported;}
int main(int argc,char**argv){try{
 if(argc!=5)throw std::runtime_error("INPUT FUNCTION TOOL_ROOT NEW_OUTPUT required");
 std::string current=argv[1],fn=argv[2],root=argv[3],out=argv[4];if(sys::fs::exists(out))throw std::runtime_error("output exists");if(auto e=sys::fs::create_directories(out))throw std::runtime_error(e.message());
 LLVMContext ctx;SMDiagnostic error;auto initial=parseIRFile(current,error,ctx);if(!initial||!initial->getFunction(fn)||verifyModule(*initial,&errs()))throw std::runtime_error("invalid input");
 auto ds=decision::discover(*initial->getFunction(fn));std::vector<std::string> targets;std::set<BasicBlock*> covered,tagged;json::Array order;
 for(auto &d:ds){bool yes=false;for(unsigned i=0;i+1<d.arms.size();++i)yes|=eligible(d.arms[i],d.arms[i+1]);if(!yes||covered.count(d.root))continue;targets.push_back(d.id);for(auto*b:d.tests)covered.insert(b);for(unsigned i=0;i<d.arms.size();++i){auto&a=d.arms[i];if(!tagged.insert(a.entry).second)continue;std::string label;raw_string_ostream stream(label);a.entry->printAsOperand(stream,false);stream.flush();order.push_back(json::Object{{"entry",label},{"family",d.id},{"index",int64_t(i)}});}}
 save(out+"/order.json",json::Value(std::move(order)));json::Array targetJSON;for(auto&t:targets)targetJSON.push_back(t);save(out+"/targets.json",json::Value(std::move(targetJSON)));
 auto cost=[&](const std::string&input,const std::string&prefix){if(run({root+"/tools/run-llvm24-tti",input,fn},prefix+".json",prefix+".stderr"))throw std::runtime_error("TTI worker failed: "+prefix);auto v=read(prefix+".json");auto*o=v.getAsObject();if(!o||o->getInteger("unknown")!=Optional<int64_t>(0)||o->getString("source_revision")!=Optional<StringRef>("6be16f356d3e"))throw std::runtime_error("TTI unknown cost or revision mismatch");auto n=o->getInteger("cost");if(!n)throw std::runtime_error("missing cost");return *n;};
 int64_t parentCost=cost(current,out+"/initial-tti"),initialCost=parentCost;unsigned commits=0,trials=0;json::Array rounds,stops;
 auto report=[&](StringRef status){save(out+"/summary.json",json::Value(json::Object{{"status",status.str()},{"search","per-decision greedy; best positive adjacent candidate; initial decision order"},{"initial_cost",initialCost},{"final_cost",parentCost},{"commits",int64_t(commits)},{"trials",int64_t(trials)},{"final_ir",current},{"rounds",json::Value(json::Array(rounds))},{"stops",json::Value(json::Array(stops))}}));};
 report("running");
 for(auto &target:targets){for(unsigned iteration=0;iteration<256;++iteration){
  auto m=parseIRFile(current,error,ctx);if(!m)throw std::runtime_error("cannot read parent");auto catalog=decision::discover(*m->getFunction(fn));unsigned di=0;for(;di<catalog.size();++di)if(catalog[di].id==target)break;if(di==catalog.size()){stops.push_back(json::Object{{"decision",target},{"reason","decision_completed_or_absorbed"}});break;}
  auto &d=catalog[di];int64_t bestCost=parentCost;std::string best;json::Array attempts;
  for(unsigned left=0;left+1<d.arms.size();++left){if(!eligible(d.arms[left],d.arms[left+1]))continue;if(trials>=100000)throw std::runtime_error("trial budget exceeded");std::string dir=out+"/trial-"+std::to_string(trials++);save(dir+".request.json",json::Value(json::Object{{"decision",target},{"left",d.arms[left].id},{"right",d.arms[left+1].id}}));int rc=run({root+"/build/decision-fuse/decision-fuse",current,fn,std::to_string(di),std::to_string(left),dir,out+"/order.json",dir+".request.json"},dir+".stdout",dir+".stderr");json::Object attempt{{"directory",dir},{"left",d.arms[left].id},{"right",d.arms[left+1].id},{"exit_code",rc}};
   if(rc){if(sys::fs::exists(dir+"/trial.json")){auto v=read(dir+"/trial.json");auto*r=v.getAsObject();if(r)if(auto reason=r->getString("reason"))attempt["reason"]=reason->str();}else attempt["reason"]="trial_process_failed";}
   else{auto verified=read(dir+"/trial.json");auto *actual=verified.getAsObject();
    if(!actual||actual->getString("decision")!=Optional<StringRef>(target)||actual->getString("left")!=Optional<StringRef>(d.arms[left].id)||actual->getString("right")!=Optional<StringRef>(d.arms[left+1].id))throw std::runtime_error("trial identity mismatch: "+dir);
    auto c=cost(dir+"/fused.ll",dir+"/tti");attempt["cost"]=c;attempt["gain"]=parentCost-c;if(c<bestCost){bestCost=c;best=dir;}}
   attempts.push_back(std::move(attempt));
  }
  json::Object record{{"decision",target},{"iteration",int64_t(iteration)},{"parent",current},{"parent_cost",parentCost},{"attempts",std::move(attempts)},{"selected",best}};
  if(best.empty()){rounds.push_back(std::move(record));stops.push_back(json::Object{{"decision",target},{"reason","no_positive_legal_candidate"}});report("running");break;}
  record["selected_cost"]=bestCost;record["score"]=double(parentCost-bestCost)/std::max<int64_t>(parentCost,1);rounds.push_back(std::move(record));parentCost=bestCost;current=best+"/fused.ll";++commits;report("running");outs()<<"commit="<<commits<<" cost="<<parentCost<<" decision="<<target<<"\n";outs().flush();
  if(iteration==255)throw std::runtime_error("round budget exceeded");
 }}
 if(auto e=sys::fs::copy_file(current,out+"/final.ll"))throw std::runtime_error(e.message());current=out+"/final.ll";report("completed");return 0;
}catch(const std::exception&e){errs()<<e.what()<<"\n";return 1;}}
