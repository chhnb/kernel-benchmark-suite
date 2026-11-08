#pragma once
#include "fusion_search.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/Program.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/MemoryBuffer.h"
#include <array>
#include <set>
#include <stdexcept>
namespace fusion {
// LLVM12 owns all transformation IR; the isolated worker only reads text snapshots.
class LLVM24Scorer final:public Scorer {
  struct Cost {double value=0;int64_t unknown=0,zero=0,count=0;bool adjusted=false;std::map<std::string,double> counts;};
  std::string worker;
  mutable std::string cachedHash;
  mutable Cost cachedControl;
  Cost query(const llvm::Function&f)const {
    using namespace llvm;
    SmallString<128> directory;
    if(auto e=sys::fs::createUniqueDirectory("fusion-llvm24-tti",directory))throw std::runtime_error(e.message());
    struct Remove {std::string dir;~Remove(){sys::fs::remove_directories(dir);}} remove{directory.str().str()};
    const std::string input=remove.dir+"/input.ll",output=remove.dir+"/cost.json",error=remove.dir+"/error.txt";
    std::error_code ec;
    {raw_fd_ostream stream(input,ec);if(ec)throw std::runtime_error(ec.message());f.getParent()->print(stream,nullptr);}
    std::string name=f.getName().str(),message;
    std::array<StringRef,3> args{{worker,input,name}};
    std::array<Optional<StringRef>,3> redirects{{StringRef(""),StringRef(output),StringRef(error)}};
    int code=sys::ExecuteAndWait(worker,args,None,redirects,60,0,&message);
    if(code!=0){auto b=MemoryBuffer::getFile(error);throw std::runtime_error("llvm24_worker_failed:"+message+":"+(b?b.get()->getBuffer().take_front(800).str():""));}
    auto buffer=MemoryBuffer::getFile(output);if(!buffer)throw std::runtime_error("missing LLVM24 output");
    auto j=json::parse(buffer.get()->getBuffer());if(!j)throw std::runtime_error(toString(j.takeError()));
    auto*o=j->getAsObject();if(!o)throw std::runtime_error("invalid worker JSON");
    if(o->getString("schema")!=Optional<StringRef>("llvm24-tti-v1")||
       o->getString("source_revision")!=Optional<StringRef>("6be16f356d3e"))throw std::runtime_error("worker identity mismatch");
    if(o->getString("triple")!=Optional<StringRef>(f.getParent()->getTargetTriple())||
       o->getString("cpu")!=Optional<StringRef>(f.getFnAttribute("target-cpu").getValueAsString())||
       o->getString("features")!=Optional<StringRef>(f.getFnAttribute("target-features").getValueAsString()))throw std::runtime_error("worker target mismatch");
    auto n=o->getInteger("instructions"),u=o->getInteger("unknown"),z=o->getInteger("zero"),v=o->getInteger("modeled_cost");
    if(!n||!u||!z||!v)throw std::runtime_error("worker cost fields missing");
    int64_t count=0;std::set<const BasicBlock*> seen;std::vector<const BasicBlock*> pending{&f.getEntryBlock()};
    while(!pending.empty()){auto*b=pending.back();pending.pop_back();if(!seen.insert(b).second)continue;
      for(auto*s:successors(b))pending.push_back(s);for(auto&i:*b)if(!isa<DbgInfoIntrinsic>(i))++count;}
    if(count!=*n)throw std::runtime_error("IR_upgrade_changed_instruction_count");
    Cost c;c.value=*v;c.count=*n;c.unknown=*u;c.zero=*z;
    auto adjustment=o->getString("compatibility_adjustment");c.adjusted=adjustment&&!adjustment->empty();
    auto*h=o->getObject("histogram");if(!h)throw std::runtime_error("worker histogram missing");
    for(auto&kv:*h){auto value=kv.second.getAsInteger();if(!value)throw std::runtime_error("invalid histogram");c.counts[kv.first.str()]=*value;}
    return c;
  }
public:
  explicit LLVM24Scorer(std::string executable):worker(std::move(executable)){}
  ScoreResult evaluate(const ScoreInput&i,const RoundContext&r)const override {
    ScoreResult s;s.coverage.hardwareCosts="LLVM24_TTI_6be16f356d3e_reciprocal_throughput_uncalibrated";
    if(i.candidate.version!=r.parentVersion||i.candidate.function!=r.function){s.reason="round_identity_mismatch";return s;}
    try {
      if(cachedHash!=r.controlHash){auto*f=r.control->getFunction(r.function);if(!f)throw std::runtime_error("control_missing");cachedControl=query(*f);cachedHash=r.controlHash;}
      auto after=query(i.afterIR);auto &before=cachedControl;
      s.metrics={{"work_before",before.value},{"work_after",after.value},{"unknown_before",double(before.unknown)},
        {"unknown_after",double(after.unknown)},{"zero_before",double(before.zero)},{"zero_after",double(after.zero)},
        {"instructions_before",double(before.count)},{"instructions_after",double(after.count)},{"tti_major",24},
        {"sm70_ptx32_to_ptx60_before",before.adjusted?1.0:0.0},{"sm70_ptx32_to_ptx60_after",after.adjusted?1.0:0.0}};
      for(auto&kv:before.counts)s.metrics["tti24_before_count:"+kv.first]=kv.second;
      for(auto&kv:after.counts)s.metrics["tti24_after_count:"+kv.first]=kv.second;
      if(before.unknown||after.unknown){s.reason="llvm24_unknown_cost_rejection";return s;}
      s.staticGain=before.value-after.value;s.staticScore=s.staticGain/std::max(1.0,before.value);s.total=s.staticScore;
      s.parentGain=s.staticGain; // Preserve v1 acceptance semantics, not diagnostic S-A.
      s.status=ScoreStatus::Scored;s.reason="llvm24_static_control_delta";
    }catch(const std::exception&e){s.reason=e.what();}
    return s;
  }
};
}
