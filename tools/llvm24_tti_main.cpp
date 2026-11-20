#include "tti_cost_kind.h"
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
#include <iostream>
#include <map>
#include <set>
#include <stdexcept>
using namespace llvm;
struct TargetCache {
  std::string triple, cpu, features;
  std::unique_ptr<TargetMachine> machine;

  TargetMachine &get(const Triple &targetTriple, StringRef targetCPU, StringRef targetFeatures) {
    if(machine&&triple==targetTriple.str()&&cpu==targetCPU&&features==targetFeatures)
      return *machine;
    std::string error;
    auto *target=TargetRegistry::lookupTarget(targetTriple,error);
    if(!target)throw std::runtime_error(error);
    std::unique_ptr<TargetMachine> replacement(
        target->createTargetMachine(targetTriple,targetCPU,targetFeatures,TargetOptions(),std::nullopt));
    if(!replacement)throw std::runtime_error("target machine unavailable");
    triple=targetTriple.str();
    cpu=targetCPU.str();
    features=targetFeatures.str();
    machine=std::move(replacement);
    return *machine;
  }
};
static int score(StringRef input,StringRef function,bool summaryOnly,bool compact,
                 TargetCache &targets, TargetTransformInfo::TargetCostKind costKind,
                 bool repriceMemory) {
 try {
  LLVMContext ctx;SMDiagnostic diagnostic;
  auto m=parseIRFile(input,diagnostic,ctx);
  if(!m){diagnostic.print("llvm24-tti",errs());return 2;}
  if(verifyModule(*m,&errs()))return 2;
  auto *f=m->getFunction(function);if(!f||f->isDeclaration())throw std::runtime_error("function missing");
  auto triple=m->getTargetTriple();
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
  auto &target=targets.get(triple,cpu,features);
  FunctionAnalysisManager fam;
  auto tti=target.getTargetIRAnalysis().run(*f,fam);
  int64_t total=0,count=0,unknown=0,zero=0;
  json::Array instructions;std::map<std::string,int64_t> histogram;
  std::set<const BasicBlock*> reachable;std::vector<const BasicBlock*> pending{&f->getEntryBlock()};
  while(!pending.empty()){auto*b=pending.back();pending.pop_back();if(!reachable.insert(b).second)continue;for(auto*s:successors(b))pending.push_back(s);}
  ModuleSlotTracker slots(m.get());if(!summaryOnly)slots.incorporateFunction(*f);
  unsigned blockID=0;
  for(auto &b:*f){unsigned bid=blockID++;if(!reachable.count(&b))continue;unsigned iid=0;
   for(auto&i:b){if(isa<DbgInfoIntrinsic>(i))continue;++count;
    auto cost=tti.getInstructionCost(&i,costKind);
    bool ttiValid=cost.isValid();
    auto v=ttiValid?cost.getValue():0;
    const auto nativeCost=v;
    if (repriceMemory && ttiValid && v>=0 &&
        (triple.isAMDGPU() || triple.isNVPTX()))
      if (isa<LoadInst>(i) || isa<StoreInst>(i)) {
        unsigned addressSpace=isa<LoadInst>(i)
            ? cast<LoadInst>(i).getPointerAddressSpace()
            : cast<StoreInst>(i).getPointerAddressSpace();
        if (addressSpace==1) v=4;
        if (addressSpace==3) v=2;
      }
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
      {"tti_cost",ttiValid?json::Value(nativeCost):json::Value(nullptr)},
      {"accepted_cost",valid?json::Value(v):json::Value(nullptr)},
      {"reason",reason},{"ir",ir}});
   }
  }
  json::Object hist;for(auto&kv:histogram)hist[kv.first]=kv.second;
  json::Object output{{"schema","llvm24-tti-v1"},{"llvm_version",LLVM_VERSION_STRING},
    {"source_revision","6be16f356d3e"},{"triple",triple.str()},{"cpu",cpu.str()},{"features",originalFeatures},
    {"effective_features",features},{"compatibility_adjustment",compatibility},
    {"cost_kind",fusion::ttiCostKindName()},{"optimization_passes_run",false},{"verifier_passed",true},
    {"instructions",count},{"unknown",unknown},{"zero",zero},{"modeled_cost",total},
    {"cost",unknown?json::Value(nullptr):json::Value(total)}};
  if(!summaryOnly){
    output["histogram"]=std::move(hist);
    output["instruction_costs"]=std::move(instructions);
  }
  if(repriceMemory)output["memory_cost_profile"]="as1-4-as3-2";
  json::Value result(std::move(output));
  if(compact)outs()<<result<<'\n';
  else outs()<<formatv("{0:2}\n",result);
  return 0;
 }catch(const std::exception&e){errs()<<e.what()<<"\n";return 2;}
}
int main(int argc,char **argv) {
  TargetTransformInfo::TargetCostKind costKind;
  try {
    costKind=fusion::ttiCostKindName()=="TCK_Latency" ? TargetTransformInfo::TCK_Latency
                                                     : TargetTransformInfo::TCK_RecipThroughput;
  } catch (const std::invalid_argument &error) {
    errs()<<error.what()<<"\n";
    return 2;
  }
  const char *loadProfile=std::getenv("FUSION_TTI_MEMORY_COST_PROFILE");
  if(loadProfile && StringRef(loadProfile)!="native" && StringRef(loadProfile)!="as1-4-as3-2") {
    errs()<<"FUSION_TTI_MEMORY_COST_PROFILE must be native or as1-4-as3-2\n";
    return 2;
  }
  const bool repriceMemory=loadProfile && StringRef(loadProfile)=="as1-4-as3-2";
  const bool fullServer=argc==3&&StringRef(argv[1])=="--serve-full";
  const bool server=fullServer||(argc==3&&StringRef(argv[1])=="--serve-summary");
  const bool summaryOnly=argc==4&&StringRef(argv[3])=="--summary-only";
  if(argc!=3&&!summaryOnly){
    errs()<<"usage: llvm24-tti IR FUNCTION [--summary-only] or llvm24-tti (--serve-summary|--serve-full) FUNCTION\n";
    return 2;
  }
  InitializeAllTargetInfos();InitializeAllTargets();InitializeAllTargetMCs();
  TargetCache targets;
  if(!server)return score(argv[1],argv[2],summaryOnly,false,targets,costKind,repriceMemory);
  std::string input;
  while(std::getline(std::cin,input)){
    if(score(input,argv[2],!fullServer,true,targets,costKind,repriceMemory))outs()<<"null\n";
    outs().flush();
  }
  return 0;
}
