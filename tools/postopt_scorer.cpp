#include "postopt_scorer.h"
#include "common_fences.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/ModuleSlotTracker.h"
#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/Analysis/CFG.h"
#include "llvm/Analysis/DivergenceAnalysis.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Target/TargetMachine.h"
#include <algorithm>
#include <chrono>
#include <set>
#include <vector>
using namespace llvm;
namespace fusion {
PostOptFeatures postOptFeatures(const Function&f,int staticAllocaCost,bool dependencyFeatures) {
  PostOptFeatures x;
  auto timer=std::chrono::steady_clock::now();
  auto stamp=[&](const std::string&key){auto now=std::chrono::steady_clock::now();x.timingMs[key]=std::chrono::duration<double,std::milli>(now-timer).count();timer=now;};
  x.pressure=irPressure(f);stamp("pressure_initial");
  if(dependencyFeatures){x.dependency=localDependencies(f);stamp("dependency_local");}
  ModuleSlotTracker slots(f.getParent());slots.incorporateFunction(f);
  for(auto &block:f) {
    std::string key,body;raw_string_ostream k(key),b(body);
    block.printAsOperand(k,false,slots);k.flush();static_cast<const Value&>(block).print(b,slots);b.flush();
    x.blockText[key]=body;
  }
  stamp("block_text");
  static const bool initialized=[](){InitializeAllTargetInfos();InitializeAllTargets();InitializeAllTargetMCs();return true;}();
  (void)initialized;
  std::string error;
  const auto triple=f.getParent()->getTargetTriple();
  auto*target=TargetRegistry::lookupTarget(triple,error);
  if(!target)return x;
  auto cpu=f.getFnAttribute("target-cpu").getValueAsString();
  auto attrs=f.getFnAttribute("target-features").getValueAsString();
  std::unique_ptr<TargetMachine> tm(target->createTargetMachine(triple,cpu,attrs,TargetOptions(),None,None,CodeGenOpt::Default));
  if(!tm)return x;
  x.targetAvailable=true;
  FunctionAnalysisManager fam;
  auto tti=tm->getTargetIRAnalysis().run(const_cast<Function&>(f),fam);
  stamp("target_tti_setup");
  auto &mutableF=const_cast<Function&>(f);
  Analysis analyses(mutableF);
  ReversePostOrderTraversal<Function*> rpo(&mutableF);
  const bool kernel=f.getCallingConv()==CallingConv::AMDGPU_KERNEL||f.getCallingConv()==CallingConv::PTX_Kernel;
  if(kernel&&tti.hasBranchDivergence()&&!containsIrreducibleCFG<BasicBlock *>(rpo,analyses.loops)) {
    GPUDivergenceAnalysis da(mutableF,analyses.dt,analyses.pdt,analyses.loops,tti);
    std::set<const Value*> uniform;
    auto add=[&](const Value &v){
      if(!da.isUniform(v))return;
      for(auto &u:v.uses())if(da.isDivergentUse(u))return;
      uniform.insert(&v);
    };
    for(auto &a:f.args())add(a);
    for(auto &bb:f)for(auto &inst:bb)if(!inst.getType()->isVoidTy())add(inst);
    stamp("uniformity");
    x.pressure=irPressure(f,&uniform);x.uniformityAvailable=true;
    stamp("pressure_partitioned");
  }
  std::set<const BasicBlock*> seen;
  std::vector<const BasicBlock*> pending{&f.getEntryBlock()};
  while(!pending.empty()) {
    auto*b=pending.back();pending.pop_back();
    if(!seen.insert(b).second)continue;
    for(auto*s:successors(b))pending.push_back(s);
    std::string blockKey;raw_string_ostream blockStream(blockKey);
    b->printAsOperand(blockStream,false,slots);blockStream.flush();
    auto &block=x.blockWork[blockKey];
    for(auto&i:*b) {
      if(isa<DbgInfoIntrinsic>(i))continue;
      ++x.instructions;++block.instructions;
      // Arbitrary calls have no reliable whole-call static throughput cost.
      if(auto*c=dyn_cast<CallBase>(&i))
        if(!c->getCalledFunction()||!c->getCalledFunction()->isIntrinsic()){++x.unknown;++block.unknown;x.categories["unknown_call_count"]++;continue;}
      int cost=tti.getInstructionCost(&i,TargetTransformInfo::TCK_RecipThroughput);
      // LLVM12 target TTI leaves freeze unsupported. An explicit conservative
      // 32-bit-slot fallback prevents silently assigning zero work. This is an
      // uncalibrated IR cost, not a claimed machine instruction count.
      if(cost<0&&isa<FreezeInst>(i)&&i.getType()->isSized()) {
        auto bits=f.getParent()->getDataLayout().getTypeSizeInBits(i.getType());
        if(!bits.isScalable()) {
          cost=std::max<uint64_t>(1,(bits.getFixedSize()+31)/32);
          x.categories["freeze_fallback_count"]++;
        }
      }
      // Opt-in positive proxy only; allocation capacity is separately exposed.
      // This is not a scratch-traffic, occupancy, or backend register estimate.
      if(auto *allocation=dyn_cast<AllocaInst>(&i)) {
        if(allocation->isStaticAlloca()&&allocation->getType()->getPointerAddressSpace()==5&&
           StringRef(f.getParent()->getTargetTriple()).startswith("amdgcn")) {
          auto bits=allocation->getAllocationSizeInBits(f.getParent()->getDataLayout());
          if(bits) {
            x.categories["static_private_alloca_bytes"]+=(*bits+7)/8;
            if(cost<0&&staticAllocaCost>0) {
              cost=staticAllocaCost;
              x.categories["static_alloca_fallback_count"]++;
            }
          }
        }
      }
      if(cost<0){
        ++x.unknown;++block.unknown;
        std::string reason=i.getOpcodeName();
        if(auto*c=dyn_cast<CallBase>(&i))if(c->getCalledFunction())reason+=":"+c->getCalledFunction()->getName().str();
        x.categories["invalid_tti_count:"+reason]++;continue;
      }
      x.work+=cost;block.work+=cost;
      std::string category=i.mayReadOrWriteMemory()?"memory":i.isTerminator()?"control":
        (isa<SelectInst>(i)||isa<CastInst>(i))?"selection_conversion":"alu_other";
      x.categories[category]+=cost;block.categories[category]+=cost;
      std::string type;raw_string_ostream stream(type);i.getType()->print(stream);stream.flush();
      std::string key=std::string(i.getOpcodeName())+":"+type;
      if(auto*l=dyn_cast<LoadInst>(&i))key+=":as"+std::to_string(l->getPointerAddressSpace());
      if(auto*st=dyn_cast<StoreInst>(&i))key+=":as"+std::to_string(st->getPointerAddressSpace());
      auto &entry=x.costTable[key+ ":cost"+std::to_string(cost)];++entry.first;entry.second=cost;
    }
  }
  stamp("work");
  return x;
}
ScoreResult PostOptScorer::evaluate(const ScoreInput&i,const RoundContext&r)const {
  ScoreResult s;
  if(i.candidate.version!=r.parentVersion||i.candidate.function!=r.function) {
    s.reason="round_identity_mismatch";return s;
  }
  auto*b=r.control->getFunction(r.function);
  if(!b){s.reason="control_missing";return s;}
  // Cache values only: no IR/analysis pointers survive candidate deletion.
  const auto key=r.controlHash+":"+r.function+":"+r.cleanup+":"+r.targetAttributes;
  bool cacheHit=baselineKey==key;
  if(!cacheHit){baselineFeatures=postOptFeatures(*b,config.staticAllocaCost,config.dependencyFeatures);baselineKey=key;}
  const auto &before=baselineFeatures;
  auto after=postOptFeatures(i.afterIR,config.staticAllocaCost,config.dependencyFeatures);
  s.metrics={{"work_before",before.work},{"work_after",after.work},
    {"unknown_before",double(before.unknown)},{"unknown_after",double(after.unknown)},
    {"pressure_before_slots32",double(before.pressure.peakSlots32)},
    {"pressure_after_slots32",double(after.pressure.peakSlots32)},
    {"absolute_threshold",config.absoluteThreshold},{"relative_threshold",config.relativeThreshold},
    {"pressure_weight",config.pressureWeight},{"static_alloca_cost",double(config.staticAllocaCost)}};
  uint64_t localBefore=0,localAfter=0,crossBefore=0,crossAfter=0,changedBefore=0,changedAfter=0;
  for(auto &entry:before.blockText) {
    auto other=after.blockText.find(entry.first);
    if(other==after.blockText.end()||other->second!=entry.second) {
      ++changedBefore;
      auto peak=before.pressure.blockPeakSlots32.find(entry.first);
      if(peak!=before.pressure.blockPeakSlots32.end())localBefore=std::max(localBefore,peak->second);
      auto cross=before.pressure.blockCrossingValues.find(entry.first);
      if(cross!=before.pressure.blockCrossingValues.end())crossBefore=std::max(crossBefore,cross->second);
    }
  }
  for(auto &entry:after.blockText) {
    auto other=before.blockText.find(entry.first);
    if(other==before.blockText.end()||other->second!=entry.second) {
      ++changedAfter;
      localAfter=std::max(localAfter,after.pressure.blockPeakSlots32[entry.first]);
      crossAfter=std::max(crossAfter,after.pressure.blockCrossingValues[entry.first]);
    }
  }
  s.metrics["changed_block_pressure_before_slots32"]=localBefore;
  s.metrics["changed_block_pressure_after_slots32"]=localAfter;
  s.metrics["changed_blocks_before"]=changedBefore;s.metrics["changed_blocks_after"]=changedAfter;
  s.metrics["changed_block_max_crossing_values_before"]=crossBefore;
  s.metrics["changed_block_max_crossing_values_after"]=crossAfter;
  s.coverage.provenance="changed_block_text_footprint_not_instruction_mapping";
  for(auto&kv:after.timingMs)s.metrics["feature_ms:"+kv.first]=kv.second;
  s.metrics["instructions_before"]=before.instructions;
  s.metrics["instructions_after"]=after.instructions;
  s.metrics["unknown_cost_ratio_before"]=double(before.unknown)/std::max<uint64_t>(1,before.instructions);
  s.metrics["unknown_cost_ratio_after"]=double(after.unknown)/std::max<uint64_t>(1,after.instructions);
  s.metrics["pressure_uniform_before_slots32"]=before.pressure.uniformPeakSlots32;
  s.metrics["pressure_uniform_after_slots32"]=after.pressure.uniformPeakSlots32;
  s.metrics["pressure_unproven_before_slots32"]=before.pressure.unprovenPeakSlots32;
  s.metrics["pressure_unproven_after_slots32"]=after.pressure.unprovenPeakSlots32;
  s.metrics["baseline_cache_hit"]=cacheHit?1:0;
  for(auto&kv:before.categories)s.metrics["work_before_"+kv.first]=kv.second;
  for(auto&kv:after.categories)s.metrics["work_after_"+kv.first]=kv.second;
  for(auto&kv:before.costTable)s.metrics["tti_before_count:"+kv.first]=kv.second.first;
  for(auto&kv:after.costTable)s.metrics["tti_after_count:"+kv.first]=kv.second.first;
  s.coverage.hardwareCosts="TTI_reciprocal_throughput_with_explicit_freeze_slots32_fallback_uncalibrated";
  if(config.staticAllocaCost>0)s.coverage.hardwareCosts+=";explicit_static_private_alloca_proxy_uncalibrated";
  s.metrics["dependency_features_enabled"]=config.dependencyFeatures?1:0;
  if(config.dependencyFeatures) {
    s.coverage.dependency="block_local_structural_only_phi_boundaries_no_latency_crossblock_memory_or_loop_path";
    auto record=[&](const char*stage,const IRDependency&d){
      std::string prefix=std::string("dependency_")+stage+"_";
      s.metrics[prefix+"max_local_depth"]=d.maxDepth;
      s.metrics[prefix+"max_local_sink_depth"]=d.maxSinkDepth;
      s.metrics[prefix+"max_select_chain"]=d.maxSelectChain;
      s.metrics[prefix+"cross_block_uses"]=d.crossBlockUses;
      s.metrics[prefix+"phi_boundary_uses"]=d.phiBoundaryUses;
      s.metrics[prefix+"unmodeled_memory_operations"]=d.memoryOperations;
      s.metrics[prefix+"opaque_calls"]=d.opaqueCalls;
      s.metrics[prefix+"cfg_has_cycle"]=d.cfgHasCycle?1:0;
    };
    record("before",before.dependency);record("after",after.dependency);
    s.metrics["dependency_local_depth_delta"]=double(after.dependency.maxDepth)-double(before.dependency.maxDepth);
  }
  s.coverage.liveness="whole_function_phi_edge_slots32";
  s.coverage.divergence=before.uniformityAvailable&&after.uniformityAvailable?"llvm12_gpu_uniform_definition_and_all_uses":"unavailable_all_values_unproven_uniform";
  if(!before.targetAvailable||!after.targetAvailable){s.reason="target_unavailable";return s;}
  bool canceledFences=false;
  if(before.unknown||after.unknown) {
    auto onlyFences=[](const PostOptFeatures &f) {
      auto it=f.categories.find("invalid_tti_count:fence");
      return f.unknown>0&&it!=f.categories.end()&&it->second==double(f.unknown);
    };
    canceledFences=onlyFences(before)&&onlyFences(after)&&
      before.unknown==after.unknown&&commonFenceBackground(i,*b);
    if(!canceledFences){s.reason="unknown_cost_conservative_rejection";return s;}
    s.metrics["common_unknown_fences_canceled"]=before.unknown;
    s.metrics["work_is_partial"]=1;
    s.coverage.hardwareCosts+=";common_fences_canceled_sync_free_candidate_exact_sync_sequence;relative_work_is_modeled_subset";
    // Unknown common work cancels from the absolute delta, not the full
    // denominator. Do not silently apply calibrated full-work thresholds.
    if(config.relativeThreshold>0||config.pressureWeight>0) {
      s.reason="partial_work_requires_zero_relative_threshold_and_pressure_weight";
      return s;
    }
  }

  if(!before.pressure.complete||!after.pressure.complete){s.reason="unsupported_pressure_type";return s;}
  s.staticGain=before.work-after.work;
  s.staticScore=s.staticGain/std::max(before.work,1.0);
  const double growth=std::max(0.0,double(after.pressure.peakSlots32)-double(before.pressure.peakSlots32))
    /std::max(1.0,double(before.pressure.peakSlots32));
  s.livenessPenalty=config.pressureWeight*growth;
  s.total=s.staticScore-config.relativeThreshold-s.livenessPenalty;
  if(s.staticGain<=config.absoluteThreshold)s.total=std::min(s.total,0.0);
  // Parent legacy costs do not gate this independent post-opt policy.
  s.parentGain=s.staticGain;
  s.status=ScoreStatus::Scored;
  s.reason=s.total>0?"postopt_thresholds_passed":"postopt_thresholds_rejected";
  if(config.profileEnabled&&!canceledFences)applyProfilePolicy(i,r,before,after,config,s);
  else if(config.profileEnabled){s.metrics["profile_used"]=0;s.reason+=";profile_fallback_partial_work";}
  return s;
}
}
