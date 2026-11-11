#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/Config/llvm-config.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/ModuleSlotTracker.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/FormatVariadic.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Target/TargetMachine.h"
#include <map>
#include <set>
#include <stdexcept>
using namespace llvm;
int main(int argc,char**argv) {
 try {
  bool summaryOnly=argc==4&&StringRef(argv[3])=="--summary-only";
  if(argc!=3&&!summaryOnly)throw std::runtime_error("usage: llvm24-tti IR FUNCTION [--summary-only]");
  LLVMContext ctx;SMDiagnostic diagnostic;
  auto m=parseIRFile(argv[1],diagnostic,ctx);
  if(!m){diagnostic.print(argv[0],errs());return 2;}
  if(verifyModule(*m,&errs()))return 2;
  auto *f=m->getFunction(argv[2]);if(!f||f->isDeclaration())throw std::runtime_error("function missing");
  InitializeAllTargetInfos();InitializeAllTargets();InitializeAllTargetMCs();
  std::string error;auto triple=m->getTargetTriple();
  auto cpu=f->getFnAttribute("target-cpu").getValueAsString();
  std::string originalFeatures=f->getFnAttribute("target-features").getValueAsString().str();
  std::string features=originalFeatures,compatibility;
  // Old LLVM12 NVPTX accepted sm_70 with its default +ptx32. LLVM24
  // rejects this inconsistent combination. Only normalize this known case
  // in the read-only assessment copy; never send modified IR back to LLVM12.
  if(triple.isNVPTX()&&cpu=="sm_70") {
    SmallVector<StringRef,16> entries;StringRef(originalFeatures).split(entries,',');
    features.clear();
    for(auto entry:entries) {
      if(!features.empty())features+=",";
      if(entry=="+ptx32") {features+="+ptx60";compatibility="sm70_minimum_ptx60_replaces_legacy_ptx32";}
      else features+=entry.str();
    }
    if(!compatibility.empty())f->addFnAttr("target-features",features);
  }
  if(cpu.empty())throw std::runtime_error("target-cpu required; generic cost forbidden");
  auto*t=TargetRegistry::lookupTarget(triple,error);
  if(!t)throw std::runtime_error(error);
  std::unique_ptr<TargetMachine> tm(t->createTargetMachine(triple,cpu,features,TargetOptions(),std::nullopt));
  if(!tm)throw std::runtime_error("target machine unavailable");
  FunctionAnalysisManager fam;auto tti=tm->getTargetIRAnalysis().run(*f,fam);
  int64_t total=0,count=0,unknown=0,zero=0;
  json::Array instructions;std::map<std::string,int64_t> histogram;
  std::set<const BasicBlock*> reachable;std::vector<const BasicBlock*> pending{&f->getEntryBlock()};
  while(!pending.empty()){auto*b=pending.back();pending.pop_back();if(!reachable.insert(b).second)continue;for(auto*s:successors(b))pending.push_back(s);}
  ModuleSlotTracker slots(m.get());if(!summaryOnly)slots.incorporateFunction(*f);
  unsigned blockID=0;
  for(auto &b:*f){unsigned bid=blockID++;if(!reachable.count(&b))continue;unsigned iid=0;
   for(auto&i:b){if(isa<DbgInfoIntrinsic>(i))continue;++count;
    auto cost=tti.getInstructionCost(&i,TargetTransformInfo::TCK_RecipThroughput);
    bool ttiValid=cost.isValid();
    auto v=ttiValid?cost.getValue():0;
    std::string reason;
    if(auto*c=dyn_cast<CallBase>(&i))if(!c->getCalledFunction()||!c->getCalledFunction()->isIntrinsic())reason="opaque_call_cost_not_whole_callee_cost";
    if(!ttiValid||v<0)reason="invalid_tti_cost";
    bool valid=reason.empty();
    if(valid){total+=v;zero+=v==0;}else ++unknown;
    if(summaryOnly)continue;
    std::string ir;raw_string_ostream stream(ir);i.print(stream,slots);stream.flush();
    std::string key=i.getOpcodeName();
    if(isa<CondBrInst>(i))key="br.conditional";
    if(isa<UncondBrInst>(i))key="br.unconditional";
    if(auto*c=dyn_cast<CallBase>(&i))if(c->getCalledFunction())key+=":"+c->getCalledFunction()->getName().str();
    std::string type;raw_string_ostream ts(type);i.getType()->print(ts);ts.flush();key+=":"+type;
    if(valid)++histogram[key+":cost"+std::to_string(v)];
    instructions.push_back(json::Object{{"block_index",bid},{"instruction_index",iid++},{"key",key},
      {"tti_cost",ttiValid?json::Value(v):json::Value(nullptr)},
      {"accepted_cost",valid?json::Value(v):json::Value(nullptr)},
      {"reason",reason},{"ir",ir}});
   }
  }
  json::Object hist;for(auto&kv:histogram)hist[kv.first]=kv.second;
  json::Object output{{"schema","llvm24-tti-v1"},{"llvm_version",LLVM_VERSION_STRING},
    {"source_revision","6be16f356d3e"},{"triple",triple.str()},{"cpu",cpu.str()},{"features",originalFeatures},
    {"effective_features",features},{"compatibility_adjustment",compatibility},
    {"cost_kind","TCK_RecipThroughput"},{"optimization_passes_run",false},{"verifier_passed",true},
    {"instructions",count},{"unknown",unknown},{"zero",zero},{"modeled_cost",total},
    {"cost",unknown?json::Value(nullptr):json::Value(total)}};
  if(!summaryOnly){
    output["histogram"]=std::move(hist);
    output["instruction_costs"]=std::move(instructions);
  }
  outs()<<formatv("{0:2}\n",json::Value(std::move(output)));return 0;
 }catch(const std::exception&e){errs()<<e.what()<<"\n";return 2;}
}
