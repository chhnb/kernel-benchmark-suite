#include <optional>
#include <limits>
#include "fusion_search.h"
#include "ir_pressure.h"
#include "logical_region_state.h"
#include "postopt_scorer.h"
#include "llvm24_scorer.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Signals.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/FormatVariadic.h"
#include <cmath>
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/SHA1.h"
#include "llvm/ADT/StringExtras.h"
#include <stdexcept>
using namespace llvm;
using namespace fusion;
static void writeIR(const Module&m,const std::string&path) {
  std::error_code ec;raw_fd_ostream out(path,ec);if(ec)throw std::runtime_error(ec.message());m.print(out,nullptr);
}
static json::Object op(const OperationKey&k) {
 return json::Object{{"opcode",k.opcode},{"type",k.type},{"operand_types",k.operandTypes},{"category",k.category},{"scalar_bits",int64_t(k.scalarBits)},{"vector_elements",int64_t(k.lanes)},{"scalable",k.scalable},{"callee",k.callee},{"attributes",k.attributes},{"legacy_weight",k.legacyWeight}};
}
static json::Object stats(const Features&f) {
 json::Array ops;for(auto&kv:f.operations){auto o=op(kv.first);o["count"]=kv.second;ops.push_back(std::move(o));}
 return json::Object{{"blocks",f.blocks},{"instructions",f.instructions},{"darm_static_cost",f.cost},{"phis",f.phis},{"selects",f.selects},{"conditional_branches",f.branches},{"loops",f.loops},{"operations",std::move(ops)}};
}
static json::Object scoreJson(const ScoreResult&s) {
 json::Array cs;for(auto&c:s.contributions){auto o=op(c.operation);o["control_count"]=c.controlCount;o["after_count"]=c.afterCount;o["gain"]=c.gain;cs.push_back(std::move(o));}
 bool scored=s.status==ScoreStatus::Scored;
 json::Object o{{"status",scored?"scored":"not_evaluable"},{"reason",s.reason},{"profitability_rejection",s.profitabilityRejection},{"contributions",std::move(cs)},
 {"coverage",json::Object{{"dependency",s.coverage.dependency},{"liveness",s.coverage.liveness},{"divergence",s.coverage.divergence},{"provenance",s.coverage.provenance},{"hardware_costs",s.coverage.hardwareCosts},{"legacy_counts_complete",s.coverage.legacyCountsComplete},{"operand_context_model","not_modeled; inspect retained IR"}}}};
 for(auto&kv:std::vector<std::pair<std::string,double>>{{"static_gain",s.staticGain},{"cleanup_gain",s.cleanupGain},{"parent_gain",s.parentGain},{"static_score",s.staticScore},{"dependency_penalty_applied",s.dependencyPenalty},{"liveness_penalty_applied",s.livenessPenalty},{"total",s.total}})
  o[kv.first]=scored?json::Value(kv.second):json::Value(nullptr);
 o["work_delta"]=scored?json::Value(s.staticGain):json::Value(nullptr);
 auto pb=s.metrics.find("pressure_before_slots32"),pa=s.metrics.find("pressure_after_slots32");
 o["pressure_delta_slots32"]=pb!=s.metrics.end()&&pa!=s.metrics.end()?json::Value(pa->second-pb->second):json::Value(nullptr);
 o["dependency_delta"]=json::Value(nullptr);
 json::Object metrics;for(auto&kv:s.metrics)metrics[kv.first]=kv.second;o["metrics"]=std::move(metrics);
 return o;
}
static json::Array strings(const std::vector<std::string>&v) {json::Array a;for(auto&s:v)a.push_back(s);return a;}
static json::Object bound(const Boundary&b) {
  return json::Object{{"entry",b.entry},{"exit",b.exit},{"blocks",strings(b.blocks)},{"live_ins",strings(b.liveIns)},{"live_outs",strings(b.liveOuts)}};
}
static void jsonFile(const std::string&p,json::Object o) {
  std::error_code ec;raw_fd_ostream out(p,ec);if(ec)throw std::runtime_error(ec.message());out<<formatv("{0:2}\n",json::Value(std::move(o)));
}
struct DebugObserver final:Observer {
  std::string dir;unsigned n=0;
  explicit DebugObserver(std::string d):dir(std::move(d)) {
    if(sys::fs::exists(dir))throw std::runtime_error("debug directory already exists");
    auto ec=sys::fs::create_directories(dir);if(ec)throw std::runtime_error(ec.message());
  }
  void logical(unsigned version,const std::string &value)override {
    std::error_code ec;raw_fd_ostream out(dir+"/logical-state-"+std::to_string(version)+".json",ec);if(ec)throw std::runtime_error(ec.message());out<<value;
  }
  void initial(const Module&m)override { writeIR(m,dir+"/state-0.ll"); }
  void round(const RoundContext&r)override {
    auto stem=dir+"/round-"+std::to_string(r.parentVersion);
    writeIR(*r.control,stem+"-control.ll");
    jsonFile(stem+".json",json::Object{{"schema","incremental-score-round-v1"},{"hash_algorithm","llvm-sha1-printed-module"},{"parent_version",int64_t(r.parentVersion)},{"function",r.function},{"parent_hash",r.parentHash},{"control_hash",r.controlHash},{"llvm_version",r.llvmVersion},{"target_triple",r.targetTriple},{"data_layout",r.dataLayout},{"target_attributes",r.targetAttributes},{"cleanup",r.cleanup},{"feature_schema",r.featureSchema},{"weight_version",r.weightVersion},{"normalization_scale",r.normalizationScale},{"parent",stats(r.parentFeatures)},{"control",stats(r.controlFeatures)},{"control_ms",r.controlMs},{"control_cleanup_iterations",int64_t(r.controlCleanupIterations)}});
  }
  void trial(const Trial&t,const RoundContext&r,const ScoreResult&score,bool eligible)override {
    auto path=dir+"/trial-"+std::to_string(n++);auto ec=sys::fs::create_directory(path);if(ec)throw std::runtime_error(ec.message());
    if(t.valid) {
      auto pressure = [](const Function &function) {
        auto value = irPressure(function);
        return json::Object{{"complete",value.complete},{"peak_slots32",int64_t(value.peakSlots32)}};
      };
      jsonFile(path+"/pressure.json",json::Object{
        {"before",pressure(*r.control->getFunction(r.function))},
        {"after",pressure(*t.normalized->getFunction(r.function))}});
    }
    if(t.raw)writeIR(*t.raw,path+"/after-raw.ll");if(t.normalized)writeIR(*t.normalized,path+"/after.ll");
    if(t.logicalState){std::error_code ec;raw_fd_ostream out(path+"/logical-state.json",ec);if(ec)throw std::runtime_error(ec.message());out<<t.logicalState->json();}
    json::Array Origins;for(auto &P:t.blockProvenance)Origins.push_back(json::Object{
      {"left_source_id",P.leftID},{"right_source_id",P.rightID},
      {"left_alignment_label",P.leftLabel},{"right_alignment_label",P.rightLabel},
      {"raw_block",P.rawBlock},{"cleaned_block",P.cleanedBlock},
      {"coverage",P.cleanedBlock.empty()?"block_deleted_or_untracked":"surviving_block_identity_not_instruction_or_execution_mapping"}});
    jsonFile(path+"/block-provenance.json",json::Object{{"schema","melding-block-provenance-v1"},
      {"logical_decision",t.candidate.logicalDecision},{"logical_left",t.candidate.logicalLeft},{"logical_right",t.candidate.logicalRight},{"candidate",t.candidate.key()},{"parent_hash",r.parentHash},
      {"cleaned_hash",t.normalized?moduleHash(*t.normalized):""},{"blocks",std::move(Origins)}});
    jsonFile(path+"/trial.json",json::Object{{"schema","incremental-score-trial-v1"},{"logical_decision",t.candidate.logicalDecision},{"logical_left",t.candidate.logicalLeft},{"logical_right",t.candidate.logicalRight},{"candidate",t.candidate.key()},{"version",int64_t(t.candidate.version)},{"parent_hash",r.parentHash},{"control_hash",r.controlHash},{"round_context","../round-"+std::to_string(r.parentVersion)+".json"},{"valid",t.valid},{"rewrite_started",t.rewriteStarted},{"decision",!t.valid?"reject":score.status!=ScoreStatus::Scored?"unsupported":eligible?"accept":"reject"},{"reason",t.reason},{"merge_path",t.mergePath},{"layout_profitability",json::Array(t.layoutProfitability)},{"cross_decision_leaves",t.candidate.crossDecisionLeaves},{"complete_leaf_plan",t.candidate.completeLeafPlan},{"moved_leaf_instructions",int64_t(t.movedLeafInstructions)},{"leaf_anchors",int64_t(t.leafAnchors)},{"leaf_anchor_pairs",[&](){json::Array a;for(auto &p:t.leafAnchorPairs)a.push_back(p);return a;}()},{"alignment_choices",json::Array(t.alignmentChoices)},{"gap_choices",json::Array(t.gapChoices)},{"gap_plan",[&](){
      json::Array split,speculate;
      for(auto id:t.candidate.splitMatches)split.push_back(int64_t(id));
      for(auto id:t.candidate.speculateGaps)speculate.push_back(int64_t(id));
      return json::Object{{"split",std::move(split)},{"speculate",std::move(speculate)},
                          {"explicit",t.candidate.explicitGapPlan}};
    }()},{"coalesce_gaps",t.candidate.coalesceGaps},{"coalesced_gap_groups",int64_t(t.coalescedGapGroups)},{"fusion_plan",json::Object{{"kind",t.planKind},{"matched_left",t.matchedLeft},{"matched_right",t.matchedRight},{"left_context",bound(t.leftContext)},{"right_context",bound(t.rightContext)},{"split_is_loop_header",t.loopHeaderSplit},{"replication_required",t.replication}}},{"local_reject_reason",t.localRejectReason},{"score_result",scoreJson(score)},{"eligible",eligible},{"cleanup_iterations",int64_t(t.cleanupIterations)},{"alignment_order","function_order_v1"},{"original_darm_similarity",t.originalSimilarity},{"original_darm_profitable",t.originalProfitable},{"replication_required",t.replication},{"orientation_swapped",t.swapped},{"left",bound(t.left)},{"right",bound(t.right)},{"after_raw",stats(t.afterRaw)},{"after",stats(t.after)},{"cleaned_hash",t.normalized?moduleHash(*t.normalized):""},{"parent_ir","../state-"+std::to_string(t.candidate.version)+".ll"},{"timings_ms",json::Object{{"merge",t.mergeMs},{"normalization",t.normalizeMs},{"features",t.featuresMs},{"trial_total",t.totalMs},{"score_with_analysis",t.scoreMs}}},{"semantic_validation","not_run"}});
  }
  void commit(unsigned version,const Candidate&c,const ScoreResult&score,const Module&m)override {
    writeIR(m,dir+"/state-"+std::to_string(version)+".ll");
    jsonFile(dir+"/commit-"+std::to_string(version)+".json",json::Object{{"logical_decision",c.logicalDecision},{"logical_left",c.logicalLeft},{"logical_right",c.logicalRight},{"candidate",c.key()},{"parent_version",int64_t(c.version)},{"version",int64_t(version)},{"score_result",scoreJson(score)},{"committed_hash",moduleHash(m)}});
  }
};
// A worker handles one immutable parent and one scoring configuration.
struct R2RBatch {
  LLVMContext context;
  std::unique_ptr<Module> parent;
  std::optional<RoundContext> round;
  std::unique_ptr<LLVM24Scorer> scorer;
  std::string input, function, worker;
  unsigned level = 0;
  CleanupMode cleanup = CleanupMode::None;
};

static int runSearch(int argc, const char *const *argv, R2RBatch *batch = nullptr) {
  try {
    std::string input,function,output,debug,split,left,right,replayParentHash,profileBundle,policy="llvm24";Options options;bool speculationGiven=false,budgetGiven=false,singleBranchB2B=false, useDP2=false, useDP3=false, strategyGiven=false, useDarmB2B=false, darmRegionCandidates=false;
    options.speculation=SpeculationMode::None; /* CLI default: no speculation of work */ PostOptConfig config;bool controlOnly=false,catalogOnly=false; unsigned gapTrials=0; std::string gapReplay;std::string ttiWorker="/home/chh/kernel-benchmark-suite/tools/run-llvm24-tti";
    for(int i=1;i<argc;++i){std::string k=argv[i];
      if(k=="--help"){outs()<<"fusion-search --ir FILE --function NAME --out FILE [--control-only 0|1] [--catalog-only 0|1 (requires debug-dir)] [--replay-parent-hash SHA1 (explicit snapshot pair only)] [--cross-decision-leaves 0|1 (default 0; permits complete leaves with different or unknown SSA discriminator, or a sub-decision of the same discriminator)] [--b2r-strategy darm|guarded] [--cross-level-b2r 0|1 (default 0; allow B2R/R2B that replicates a same-discriminator decision chain)] [--speculation none|legacy|budget|cost (default none: unmatched work is always guarded, only a decision's own condition may be evaluated early, structural dispatch never picks local if-conversion; legacy: historical behaviour, required to reproduce results before this option; budget: speculate safe work up to --speculation-budget)] [--speculation-budget N (default 4; div/rem=8 call=4 other=1)] [--max-uniform-loss TTI (default off; llvm24 scorer only; reject if a one-sided wave gets more than this much costlier)] [--complete-leaf-plan 0|1 (experimental mandatory-load motion and multiple guarded anchors)] [--b2b-strategy darm|dp1|dp2|dp3] [--single-branch-b2b 0|1 (explicit cost-mode pair)] [--structural 0|1 (B2B/R2R/B2R dispatch; adjacent-only 0; hybrid is a compatibility alias)] [--adjacent-only 0|1] [--local-union 0|1] [--local-compute 0|1 (alias of local-copysign)] [--local-copysign 0|1 (requires adjacent-only 1, cleanup none or scoped-local)] [--scorer llvm24|legacy|v1|v2|v5] [--tti-worker EXECUTABLE] [--profile-bundle FILE (experimental v5 only)] [--work-absolute 0] [--work-relative 0] [--pressure-weight 0] [--dependency-features 0|1] [--static-alloca-cost POSITIVE_INT (disabled by default)] [--rounds 8] [--trials 256] [--threshold 0] [--opt-level 3] [--debug-dir DIR] [--require-parent-gain 1] [--cleanup none|scoped-local|scoped-cfg|scoped-cfg-triangles|structural-cfg|postopt-fp|darm-cfg-scalar-fp|darm-cfg-earlycse|darm-cfg-dce|darm-cfg-dce-instcombine|darm-cfg|o3]\nExplicit pair: add --split B# --left B#/R#/Eentry_exit --right B#/R#/Eentry_exit. Complete E leaves require --structural 1. Optional --coalesce-gaps 0|1 (default 0) groups adjacent unmatched runs before unpredication. IDs refer to the input state (O3-normalized only in o3 mode). Default cleanup: darm-cfg-earlycse. Final codegen O3 is separate.\n";return 0;}
      if(i+1==argc)throw std::runtime_error("missing option value");std::string v=argv[++i];
      if(k=="--control-only"){if(v!="0"&&v!="1")throw std::runtime_error("control-only must be 0 or 1");controlOnly=v=="1";}
      else if(k=="--catalog-only"){if(v!="0"&&v!="1")throw std::runtime_error("catalog-only must be 0 or 1");catalogOnly=v=="1";}
      else if(k=="--darm-region-candidates"){
        if(v!="0"&&v!="1")throw std::runtime_error("darm-region-candidates must be 0 or 1");
        darmRegionCandidates=v=="1";
      }
      else if(k=="--scorer"){if(v!="llvm24"&&v!="legacy"&&v!="v1"&&v!="v2"&&v!="v5")throw std::runtime_error("scorer must be llvm24, legacy, v1, v2 or experimental v5");policy=v;}
      else if(k=="--work-absolute"||k=="--work-relative"||k=="--pressure-weight"){size_t pos=0;double n=std::stod(v,&pos);if(pos!=v.size()||!std::isfinite(n)||n<0)throw std::runtime_error("invalid postopt parameter");if(k=="--work-absolute")config.absoluteThreshold=n;else if(k=="--work-relative")config.relativeThreshold=n;else config.pressureWeight=n;}
      else if(k=="--dependency-features"){if(v!="0"&&v!="1")throw std::runtime_error("dependency-features must be 0 or 1");config.dependencyFeatures=v=="1";}
      else if(k=="--static-alloca-cost"){size_t pos=0;int n=std::stoi(v,&pos);if(pos!=v.size()||n<=0)throw std::runtime_error("static alloca cost must be a positive integer");config.staticAllocaCost=n;}
      else if(k=="--adjacent-only"){if(v!="0"&&v!="1")throw std::runtime_error("adjacent-only must be 0 or 1");options.adjacentOnly=v=="1";}
      else if(k=="--tti-worker")ttiWorker=v;
      else if(k=="--b2r-strategy"){if(v!="darm"&&v!="guarded")throw std::runtime_error("b2r-strategy must be darm or guarded");options.darmB2R=v=="darm";}
      else if(k=="--cross-level-b2r"){if(v!="0"&&v!="1")throw std::runtime_error("cross-level-b2r must be 0 or 1");options.crossLevelB2R=v=="1";}
      else if(k=="--gap-replay")gapReplay=v;
      else if(k=="--gap-trials"){
        if(StringRef(v).getAsInteger(10,gapTrials)||gapTrials>64)
          throw std::runtime_error("--gap-trials requires a count between 0 and 64");
      }
      else if(k=="--speculation"){if(v=="none")options.speculation=SpeculationMode::None;else if(v=="legacy")options.speculation=SpeculationMode::Legacy;else if(v=="budget")options.speculation=SpeculationMode::Budget;else if(v=="cost")options.speculation=SpeculationMode::Cost;else throw std::runtime_error("speculation must be none, legacy, budget or cost");speculationGiven=true;}
      else if(k=="--speculation-budget"){size_t pos=0;int n=std::stoi(v,&pos);if(pos!=v.size()||n<0)throw std::runtime_error("speculation-budget must be a nonnegative integer");options.speculationBudget=n;budgetGiven=true;}
      else if(k=="--max-uniform-loss"){size_t pos=0;double n=std::stod(v,&pos);if(pos!=v.size()||!std::isfinite(n)||n<0)throw std::runtime_error("max-uniform-loss must be finite and nonnegative");options.maxUniformLoss=n;}
      else if(k=="--profile-bundle")profileBundle=v;
      else if(k=="--cross-decision-leaves"){if(v!="0"&&v!="1")throw std::runtime_error("cross-decision-leaves must be 0 or 1");options.crossDecisionLeaves=v=="1";}
      else if(k=="--replay-parent-hash")replayParentHash=v;
      else if(k=="--ir")input=v;else if(k=="--function")function=v;else if(k=="--out")output=v;
      else if(k=="--complete-leaf-plan"){if(v!="0"&&v!="1")throw std::runtime_error("complete-leaf-plan must be 0 or 1");options.completeLeafPlan=v=="1";}
      else if(k=="--b2b-strategy"){
        if(v!="darm" && v!="dp1" && v!="dp2" && v!="dp3")
          throw std::runtime_error("b2b-strategy must be darm, dp1, dp2, or dp3");
        strategyGiven=true;
        useDP2=v=="dp2";
        useDP3=v=="dp3";
        useDarmB2B=v=="darm";
        singleBranchB2B=!useDarmB2B;
      }
      else if(k=="--single-branch-b2b"){
        if(v!="0"&&v!="1")throw std::runtime_error("single-branch-b2b must be 0 or 1");
        singleBranchB2B=v=="1";
      }
      else if(k=="--coalesce-gaps"){if(v!="0"&&v!="1")throw std::runtime_error("coalesce-gaps must be 0 or 1");options.coalesceGaps=v=="1";}
      else if(k=="--structural"||k=="--hybrid"){if(v!="0"&&v!="1")throw std::runtime_error("hybrid must be 0 or 1");options.hybrid=v=="1";}
      else if(k=="--local-union"){if(v!="0"&&v!="1")throw std::runtime_error("local-union must be 0 or 1");options.localUnion=v=="1";}
      else if(k=="--local-copysign"||k=="--local-compute"){if(v!="0"&&v!="1")throw std::runtime_error("local-copysign must be 0 or 1");options.localCopysign=v=="1";}
      else if(k=="--cleanup"){if(v=="scoped-cfg-triangles")options.cleanupMode=CleanupMode::ScopedCFGTriangles;else if(v=="scoped-cfg")options.cleanupMode=CleanupMode::ScopedCFG;else if(v=="scoped-local")options.cleanupMode=CleanupMode::ScopedLocal;else if(v=="structural-cfg")options.cleanupMode=CleanupMode::StructuralCFG;else if(v=="none")options.cleanupMode=CleanupMode::None;else if(v=="postopt-fp")options.cleanupMode=CleanupMode::PostOptFixedPoint;else if(v=="darm-cfg-scalar-fp")options.cleanupMode=CleanupMode::DarmCFGScalarFixedPoint;else if(v=="darm-cfg-earlycse")options.cleanupMode=CleanupMode::DarmCFGEarlyCSE;else if(v=="darm-cfg-dce")options.cleanupMode=CleanupMode::DarmCFGRedundancy;else if(v=="darm-cfg-dce-instcombine")options.cleanupMode=CleanupMode::DarmCFGInstCombine;else if(v=="darm-cfg")options.cleanupMode=CleanupMode::DarmCFG;else if(v=="o3")options.cleanupMode=CleanupMode::O3;else throw std::runtime_error("cleanup must be none, scoped-local, scoped-cfg, scoped-cfg-triangles, structural-cfg, postopt-fp, darm-cfg-scalar-fp, darm-cfg-earlycse, darm-cfg-dce, darm-cfg-dce-instcombine, darm-cfg or o3");}
      else if(k=="--debug-dir")debug=v;else if(k=="--split")split=v;else if(k=="--left")left=v;else if(k=="--right")right=v;
      else if(k=="--rounds"||k=="--trials"||k=="--opt-level"){
        size_t pos=0;auto n=std::stoul(v,&pos);if(v.empty()||v[0]=='-'||pos!=v.size()||n>1000000)throw std::runtime_error("invalid integer option");
        if(k=="--rounds")options.maxRounds=n;else if(k=="--trials")options.maxTrials=n;else options.optLevel=n;
      }else if(k=="--require-parent-gain"){if(v!="0"&&v!="1")throw std::runtime_error("require-parent-gain must be 0 or 1");options.requireParentGain=v=="1";}else if(k=="--threshold"){size_t pos=0;options.threshold=std::stod(v,&pos);if(pos!=v.size()||!std::isfinite(options.threshold)||options.threshold<0)throw std::runtime_error("threshold must be finite and nonnegative");}
      else throw std::runtime_error("unknown option: "+k);
    }
    if(input.empty()||function.empty()||output.empty())throw std::runtime_error("--ir, --function, --out required");
    if(options.optLevel!=2&&options.optLevel!=3)throw std::runtime_error("opt-level must be 2 or 3");
    if(sys::fs::exists(output))throw std::runtime_error("output already exists");
    bool pair=!split.empty()||!left.empty()||!right.empty();if(pair&&(split.empty()||left.empty()||right.empty()))throw std::runtime_error("explicit pair requires all three IDs");
    if(!gapReplay.empty()&&(!pair||gapTrials))
      throw std::runtime_error("--gap-replay requires an explicit pair and no gap search");
    if (options.cleanupMode == CleanupMode::DarmCFGInstCombine) {
      if (options.speculation != SpeculationMode::None || gapTrials || !gapReplay.empty())
        throw std::runtime_error("v1 cleanup requires guarded fusion without gap search");
      // LLVM 12 reads this registered option inside SimplifyCFG. Initialize it
      // once per process, including when a worker evaluates a batch of pairs.
      static const bool configured = [] {
        const StringRef name = "two-entry-phi-node-folding-threshold";
        auto &registered = cl::getRegisteredOptions();
        auto entry = registered.find(name);
        return entry != registered.end() && !entry->second->addOccurrence(0, name, "7");
      }();
      if (!configured) throw std::runtime_error("cannot configure v1 PHI fold threshold");
    }
    LLVMContext context;
    std::unique_ptr<MemoryBuffer> buffer;
    std::unique_ptr<Module> parsedModule;
    if (batch) {
      if (!pair || !StringRef(left).startswith("R") || !StringRef(right).startswith("R") ||
          !options.hybrid || options.adjacentOnly || policy != "llvm24" ||
          catalogOnly || controlOnly || options.cleanupMode == CleanupMode::O3 ||
          !gapReplay.empty() || !replayParentHash.empty())
        throw std::runtime_error("batch requires explicit structural R2R with LLVM24 scoring");
      if (batch->parent && (batch->input != input || batch->function != function ||
          batch->worker != ttiWorker || batch->level != options.optLevel ||
          batch->cleanup != options.cleanupMode))
        throw std::runtime_error("R2R batch parent or scoring configuration changed");
    }
    const bool reuseParent = batch && batch->parent;
    if (!reuseParent) {
      auto file = MemoryBuffer::getFile(input);
      if (!file) throw std::runtime_error("cannot read input IR");
      buffer = std::move(*file);
      SMDiagnostic error;
      parsedModule = parseIR(buffer->getMemBufferRef(), error, batch ? batch->context : context);
      if (!parsedModule) { error.print(argv[0], errs()); return 2; }
      if (batch) {
        if (verifyModule(*parsedModule, &errs())) return 2;
        batch->input = input;
        batch->function = function;
        batch->worker = ttiWorker;
        batch->level = options.optLevel;
        batch->cleanup = options.cleanupMode;
        batch->parent = std::move(parsedModule);
        batch->scorer = std::make_unique<LLVM24Scorer>(ttiWorker);
      }
    }
    auto *module = batch ? batch->parent.get() : parsedModule.get();
    json::Value gapReport(nullptr);
    if(!gapReplay.empty()){
      auto file=MemoryBuffer::getFile(gapReplay);
      if(!file)throw std::runtime_error("cannot read gap replay file");
      auto parsed=json::parse((*file)->getBuffer());
      if(!parsed)throw std::runtime_error(toString(parsed.takeError()));
      gapReport=std::move(*parsed);
      const auto *report=gapReport.getAsObject();
      const auto parent=report?report->getString("parent_hash"):None;
      if(!parent)throw std::runtime_error("missing gap replay parent hash");
      if(replayParentHash.empty()&&moduleHash(*module)!=*parent)
        replayParentHash=parent->str();
    }
    if(!replayParentHash.empty()) {
      if(!pair||catalogOnly||controlOnly)throw std::runtime_error("snapshot replay requires explicit pair only");
      if(replayParentHash.size()!=40||replayParentHash.find_first_not_of("0123456789abcdef")!=std::string::npos)
        throw std::runtime_error("replay-parent-hash must be lowercase SHA1");
      SHA1 sourceHash;sourceHash.update(buffer.get()->getBuffer());auto digest=sourceHash.final();std::string hex;
      const char*digits="0123456789abcdef";for(unsigned char byte:digest){hex+=digits[byte>>4];hex+=digits[byte&15];}
      if(hex!=replayParentHash)throw std::runtime_error("snapshot parent hash mismatch");
      std::string first=buffer.get()->getBuffer().split(char(10)).first.str();
      const std::string prefix="; ModuleID = '";
      if(first.size()<=prefix.size()||first.compare(0,prefix.size(),prefix)!=0||first.back()!=char(39))
        throw std::runtime_error("snapshot requires canonical printed ModuleID header");
      module->setModuleIdentifier(first.substr(prefix.size(),first.size()-prefix.size()-1));
      // The authenticated serialized origin is distinct from the parsed parent:
      // LLVM can reorder predecessor comments/use lists when reading legacy text.
    }
    if(options.completeLeafPlan&&!options.hybrid)throw std::runtime_error("complete-leaf-plan requires structural 1");
    if(options.hybrid&&(options.adjacentOnly||options.localCopysign||options.localUnion))throw std::runtime_error("hybrid requires general CFG enumeration and no local-only switches");
    if(options.localUnion&&!options.localCopysign)throw std::runtime_error("local-union requires local-copysign 1");
    if(options.localCopysign&&(!options.adjacentOnly||(options.cleanupMode!=CleanupMode::None&&options.cleanupMode!=CleanupMode::ScopedLocal)))throw std::runtime_error("local-copysign requires adjacent-only 1 and cleanup none or scoped-local");
    if(!batch && verifyModule(*module,&errs()))return 2;
    auto*f=module->getFunction(function);if(!f||f->isDeclaration())throw std::runtime_error("function missing");
    std::unique_ptr<DebugObserver> observer;if(!debug.empty())observer=std::make_unique<DebugObserver>(debug);
    if(catalogOnly){
      if(pair||controlOnly||!observer)throw std::runtime_error("catalog-only requires debug-dir and excludes pair/control-only");
      if(options.cleanupMode==CleanupMode::O3)normalize(*module,options.optLevel);
      if(verifyModule(*module,&errs()))return 2;
      observer->initial(*module);
      const char*cleanupName=options.cleanupMode==CleanupMode::ScopedCFGTriangles?"scoped-cfg-triangles":options.cleanupMode==CleanupMode::ScopedCFG?"scoped-cfg":options.cleanupMode==CleanupMode::ScopedLocal?"scoped-local":options.cleanupMode==CleanupMode::None?"none":options.cleanupMode==CleanupMode::PostOptFixedPoint?"postopt-fp":options.cleanupMode==CleanupMode::O3?"o3":options.cleanupMode==CleanupMode::DarmCFGEarlyCSE?"darm-cfg-earlycse":options.cleanupMode==CleanupMode::DarmCFGRedundancy?"darm-cfg-dce":options.cleanupMode==CleanupMode::DarmCFGInstCombine?"darm-cfg-dce-instcombine":options.cleanupMode==CleanupMode::DarmCFGScalarFixedPoint?"darm-cfg-scalar-fp":"darm-cfg";
      if(options.adjacentOnly){auto st=LogicalRegionState::initialize(*module->getFunction(function));observer->logical(0,st->json());}
      auto candidates=options.adjacentOnly?enumerateAdjacent(*module->getFunction(function),0):enumerate(*module->getFunction(function),0,options.crossDecisionLeaves,darmRegionCandidates);json::Array entries;
      const auto rejected=crossLevelCatalogRejections(*f,candidates,options);
      for(const auto&c:candidates)entries.push_back(json::Object{{"logical_decision",c.logicalDecision},{"logical_left",c.logicalLeft},{"logical_right",c.logicalRight},{"candidate",c.key()},{"function",c.function},{"split",c.split},{"left",c.left},{"right",c.right},{"preflight_rejection",rejected.count(c.key())?"b2r_replicates_same_decision_chain_requires_opt_in":""}});
      jsonFile(debug+"/catalog.json",json::Object{{"schema","postopt-candidate-catalog-v1"},{"adjacent_only",options.adjacentOnly},{"cross_decision_leaves",options.crossDecisionLeaves},{"source_ir",input},{"function",function},
        {"parent_hash",moduleHash(*module)},{"cleanup",cleanupName},{"opt_level",int64_t(options.optLevel)},{"count",int64_t(candidates.size())},{"candidates",std::move(entries)},
        {"legality","not_tested"},{"score","not_evaluated"},{"semantic_validation","not_run"}});
      writeIR(*module,output);outs()<<"catalog candidates="<<candidates.size()<<"; no trials or commits\n";return 0;
    }
    if(controlOnly){
      if(pair)throw std::runtime_error("control-only excludes explicit pair selection");
      auto round=makeRound(*module,function,0,options.optLevel,options.cleanupMode);
      if(observer){observer->initial(*module);observer->round(round);}
      writeIR(*round.control,output);outs()<<"verified no-meld control exported\n";return 0;
    }
    // All scoring compares equally normalized parent/candidate states.
    if(pair){if(options.cleanupMode==CleanupMode::O3&&replayParentHash.empty())normalize(*module,options.optLevel);if(!batch && verifyModule(*module,&errs()))return 2;
      if(observer)observer->initial(*module);
    }
    if(!profileBundle.empty()&&policy!="v5")throw std::runtime_error("profile-bundle requires experimental v5 scorer");
    config.profileEnabled=policy=="v5";
    if(config.profileEnabled){
      config.profileParsedParent=moduleHash(*module);config.profileSerializedParent=replayParentHash;
      // This alias is valid only for the parsed initial state, before any O3
      // normalization or accepted melding. The raw bytes are the buffer parsed
      // above, not a second file read.
      if(config.profileSerializedParent.empty()&&options.cleanupMode!=CleanupMode::O3){
        auto Raw=buffer.get()->getBuffer();config.profileSerializedParent=toHex(SHA1::hash(ArrayRef<uint8_t>(reinterpret_cast<const uint8_t*>(Raw.data()),Raw.size())),true);
      }
      if(profileBundle.empty())config.profileReadError="profile_missing";
      else {auto PB=MemoryBuffer::getFile(profileBundle);if(!PB)config.profileReadError="profile_unreadable";else config.profileBundleText=PB.get()->getBuffer().str();}
    }
    if(policy=="llvm24"&&(config.absoluteThreshold!=0||config.relativeThreshold!=0||config.pressureWeight!=0||config.staticAllocaCost!=-1||config.dependencyFeatures))throw std::runtime_error("llvm24 scorer does not accept legacy/postopt penalties or fallback options");
    if(budgetGiven&&options.speculation!=SpeculationMode::Budget)throw std::runtime_error("--speculation-budget requires --speculation budget");
    if(options.maxUniformLoss>=0&&policy!="llvm24")throw std::runtime_error("max-uniform-loss requires the llvm24 scorer");
    LLVM24Scorer standaloneScorer(ttiWorker);
    auto &llvm24Scorer = batch ? *batch->scorer : standaloneScorer;
    StaticCostScorer legacyScorer;
    if(policy=="v1")config.pressureWeight=0;
    if(observer)jsonFile(debug+"/run.json",json::Object{
      {"schema","postopt-scoring-run-v1"},{"adjacent_only",options.adjacentOnly},{"mode",pair?"explicit_pair":"greedy"},
      {"cross_decision_leaves",options.crossDecisionLeaves},{"complete_leaf_boundary_policy","same_ssa_constant_compare_no_sub_decision_or_explicit_opt_in"},{"max_uniform_loss",options.maxUniformLoss},{"cross_level_b2r",options.crossLevelB2R},{"speculation",options.speculation==SpeculationMode::None?"none":options.speculation==SpeculationMode::Legacy?"legacy":options.speculation==SpeculationMode::Budget?"budget":"cost"},{"speculation_budget",int64_t(options.speculationBudget)},{"hybrid",options.hybrid},{"complete_leaf_plan",options.completeLeafPlan},{"local_union",options.localUnion},{"local_copysign",options.localCopysign},{"policy",policy},{"profile_bundle",profileBundle},{"profile_bundle_sha1",toHex(SHA1::hash(ArrayRef<uint8_t>(reinterpret_cast<const uint8_t*>(config.profileBundleText.data()),config.profileBundleText.size())),true)},{"function",function},{"initial_parent_hash",moduleHash(*module)},{"replay_parent_hash",replayParentHash},
      {"work_absolute",config.absoluteThreshold},{"work_relative",config.relativeThreshold},
      {"dependency_features",config.dependencyFeatures},{"pressure_weight",config.pressureWeight},{"static_alloca_cost",int64_t(config.staticAllocaCost)},{"threshold",options.threshold},
      {"require_parent_gain",options.requireParentGain},{"opt_level",int64_t(options.optLevel)},
      {"semantic_validation","not_run"}});
    PostOptScorer postScorer(config);
    const Scorer&scorer=policy=="llvm24"?static_cast<const Scorer&>(llvm24Scorer):policy=="legacy"?static_cast<const Scorer&>(legacyScorer):static_cast<const Scorer&>(postScorer);
    if(pair){Candidate c{function,split,left,right,0};std::shared_ptr<LogicalRegionState> logical;if(options.adjacentOnly){logical=LogicalRegionState::initialize(*module->getFunction(function));if(observer)observer->logical(0,logical->json());auto adjacent=logical->filter(*module->getFunction(function),enumerate(*module->getFunction(function),0));bool found=false;for(auto &a:adjacent)if(a.key()==c.key()){found=true;c=a;}if(!found)throw std::runtime_error("explicit_pair_not_adjacent");}      std::optional<RoundContext> standaloneRound;
      auto &roundStorage = batch ? batch->round : standaloneRound;
      if (!roundStorage)
        roundStorage.emplace(makeRound(*module,function,0,options.optLevel,options.cleanupMode));
      const auto &round = *roundStorage;
      if(observer)observer->round(round);
      c.localCopysign=options.localCopysign;c.localUnion=options.localUnion;c.hybrid=options.hybrid;c.coalesceGaps=options.coalesceGaps;c.completeLeafPlan=options.completeLeafPlan;c.crossDecisionLeaves=options.crossDecisionLeaves;c.crossLevelB2R=options.crossLevelB2R;c.darmB2R=options.darmB2R;c.speculation=options.speculation;c.speculationBudget=options.speculationBudget;
      if(!gapReplay.empty()){
        const auto *report=gapReport.getAsObject();
        if(!report||report->getString("candidate")!=Optional<StringRef>(c.key())||
           report->getString("parent_hash")!=Optional<StringRef>(round.parentHash))
          throw std::runtime_error("gap replay identity mismatch");
        auto *plan=report->getObject("gap_plan");
        if(!plan||!plan->getBoolean("explicit"))
          throw std::runtime_error("invalid gap replay plan");
        c.explicitGapPlan=*plan->getBoolean("explicit");
        for(auto field:{std::make_pair("split",&c.splitMatches),
                        std::make_pair("speculate",&c.speculateGaps)}){
          auto *ids=plan->getArray(field.first);
          if(!ids)throw std::runtime_error("missing gap replay IDs");
          for(auto &value:*ids){
            auto id=value.getAsInteger();
            if(!id||*id<0||uint64_t(*id)>std::numeric_limits<unsigned>::max())
              throw std::runtime_error("invalid gap replay ID");
            field.second->insert(unsigned(*id));
          }
        }
      }
      StringRef replayLayout;
      if (!gapReplay.empty())
        if (auto path = gapReport.getAsObject()->getString("merge_path"))
          if (path->startswith("single-branch-")) replayLayout = *path;
      if (!replayLayout.empty() && strategyGiven &&
          (useDarmB2B || useDP2 != replayLayout.startswith("single-branch-dp2-") ||
           (useDP3 && replayLayout.startswith("single-branch-segment-dp")) ||
           (!useDP3 && replayLayout.startswith("single-branch-dp3-"))))
        throw std::runtime_error("B2B replay strategy mismatch");
      std::optional<std::map<std::string, int64_t>> intrinsicQuotes;
      std::set<std::string> unquotedIntrinsics;
      auto intrinsicCost = [&](const Instruction &inst) -> int {
        if (!intrinsicQuotes) {
          intrinsicQuotes.emplace();
          if (policy == "llvm24")
            *intrinsicQuotes = llvm24Scorer.intrinsicCosts(*module->getFunction(function));
        }
        StringRef name = cast<CallInst>(inst).getCalledFunction()->getName();
        auto found = intrinsicQuotes->lower_bound(name.str());
        if (found != intrinsicQuotes->end() &&
            (found->first == name || StringRef(found->first).startswith((name + ".").str())))
          return found->second;
        if (unquotedIntrinsics.insert(name.str()).second)
          errs() << "DP1 intrinsic cost fallback (1): " << name << "\n";
        return 1;
      };
      auto plans = !logical && (singleBranchB2B || !replayLayout.empty()) &&
          (gapReplay.empty() || !replayLayout.empty())
          ? planSingleBranchB2B(*module, c, options.optLevel, options.cleanupMode, replayLayout,
                                useDP2 || replayLayout.startswith("single-branch-dp2-"),
                                useDP3 || replayLayout.startswith("single-branch-dp3-"), intrinsicCost)
          : std::vector<Trial>{};
      if (!replayLayout.empty() && plans.empty())
        throw std::runtime_error("single-branch B2B replay layout unavailable");
      const bool plannedB2B = !plans.empty();
      Trial t;
      ScoreResult score;
      if (plannedB2B) {
        json::Array profitability;
        std::set<std::string> seenDP1;
        const bool dp2 = StringRef(plans.front().mergePath).startswith("single-branch-dp2-");
        for (auto &plan : plans) {
          if (!dp2 && plan.valid && !seenDP1.insert(moduleHash(*plan.normalized)).second)
            continue;
          auto result = evaluateTrial(*module, plan, round, scorer);
          const bool allowed = eligible(plan, result, options);
          auto metric = [&](StringRef name) -> json::Value {
            auto it = result.metrics.find(name.str());
            return it == result.metrics.end() ? json::Value(nullptr) : json::Value(it->second);
          };
          if (dp2) profitability.push_back(json::Object{
              {"layout", plan.mergePath}, {"inside_loop", plan.insideLoop},
              {"speculated_single_side_ops", int64_t(plan.speculatedSingleSideOps)},
              {"matched_compute_pairs", int64_t(plan.matchedComputePairs)},
              {"matched_memory_pairs", int64_t(plan.matchedMemoryPairs)},
              {"work_gain", metric("non_cfg_work_gain")}, {"cfg_phi_gain", metric("cfg_phi_gain")},
              {"total_gain", metric("total_tti_gain")}, {"eligible", allowed},
              {"reason", !result.profitabilityRejection.empty() ? result.profitabilityRejection :
                         !plan.valid ? plan.reason :
                         result.status != ScoreStatus::Scored ? result.reason :
                         !allowed ? "score_below_eligibility_threshold" : ""}});
          const bool candidateAllowed = dp2 && allowed;
          const bool currentAllowed = dp2 && eligible(t, score, options);
          if (t.mergePath.empty() || (candidateAllowed && !currentAllowed) ||
              (candidateAllowed == currentAllowed &&
               ((plan.valid && !t.valid) ||
                (result.status == ScoreStatus::Scored &&
                 (score.status != ScoreStatus::Scored || result.total > score.total))))) {
            t = std::move(plan);
            score = std::move(result);
          }
        }
        t.layoutProfitability = std::move(profitability);
      }
      const bool allowDarmB2B = !strategyGiven || useDarmB2B || useDP2 || useDP3;
      if (!plannedB2B) {
        t = tryPair(*module, c, 0, options.optLevel, options.cleanupMode,
                    logical.get(), allowDarmB2B);
        if (t.valid) score = evaluateTrial(*module, t, round, scorer);
      }
      if(!plannedB2B&&gapTrials&&t.valid&&c.speculation==SpeculationMode::Cost){
        using GapState=std::tuple<std::set<unsigned>,std::set<unsigned>,bool>;
        std::set<GapState> visited;
        while(gapTrials){
          const auto base=t.candidate;
          auto protectedPlan=base;
          protectedPlan.explicitGapPlan=true;
          protectedPlan.speculateGaps.clear();
          for(const auto &value:t.gapChoices){
            const auto &gap=*value.getAsObject();
            if(*gap.getBoolean("speculated"))
              for(const auto &id:*gap.getArray("ids"))
                protectedPlan.speculateGaps.insert(unsigned(*id.getAsInteger()));
          }
          std::vector<Candidate> neighbors;
          for(const auto &value:t.alignmentChoices){
            const auto &match=*value.getAsObject();
            auto alternative=base;
            alternative.splitMatches.insert(unsigned(*match.getInteger("id")));
            neighbors.push_back(std::move(alternative));
          }
          // Interleave gap policy changes with alignment changes so both are
          // considered even when the trial budget is small.
          size_t position=0;
          for(const auto &value:t.gapChoices){
            const auto &gap=*value.getAsObject();
            const bool wasSpeculated=*gap.getBoolean("speculated");
            if(!wasSpeculated&&!*gap.getBoolean("safe"))continue;
            auto alternative=protectedPlan;
            for(const auto &id:*gap.getArray("ids")){
              const auto number=unsigned(*id.getAsInteger());
              if(wasSpeculated)alternative.speculateGaps.erase(number);
              else alternative.speculateGaps.insert(number);
            }
            position=std::min(position+1,neighbors.size());
            neighbors.insert(neighbors.begin()+position,std::move(alternative));
            ++position;
          }
          bool improved=false;
          for(const auto &alternative:neighbors){
            if(!gapTrials)break;
            if(!visited.emplace(alternative.splitMatches,alternative.speculateGaps,
                                alternative.explicitGapPlan).second)continue;
            --gapTrials;
            auto trial=tryPair(*module,alternative,0,options.optLevel,options.cleanupMode,logical.get(),allowDarmB2B);
            if(!trial.valid)continue;
            auto ranked=evaluateTrial(*module,trial,round,scorer);
            if(ranked.status!=ScoreStatus::Scored)continue;
            const auto after=ranked.metrics.find("work_after");
            const auto best=score.metrics.find("work_after");
            if(after!=ranked.metrics.end()&&
               (best==score.metrics.end()||after->second<best->second)){
              t=std::move(trial);
              score=std::move(ranked);
              improved=true;
              break;
            }
          }
          if(!improved)break;
        }
      }
      if(observer)observer->trial(t,round,score,eligible(t,score,options));
      if(!t.valid){errs()<<"rejected: "<<t.reason<<"\n";return 4;}
      if(score.status!=ScoreStatus::Scored)errs()<<"score unsupported; exporting legal trial: "<<score.reason<<"\n";
      writeIR(*t.normalized,output);outs()<<"pair trial verified; static_score="<<score.total<<"; eligible="<<eligible(t,score,options)<<"; semantic validation not run\n";return 0;
    }
    auto result=greedy(*module,function,options,scorer,observer.get());writeIR(*result.module,output);
    outs()<<"commits="<<result.commits<<" trials="<<result.trials<<" stop="<<result.stop<<"; semantic validation not run\n";
    if(observer)jsonFile(debug+"/result.json",json::Object{{"commits",int64_t(result.commits)},{"trials",int64_t(result.trials)},{"stop",result.stop},{"policy",policy},{"require_parent_gain",options.requireParentGain},{"output_on_stop","last_committed_parent_or_initial_normalized_state"},{"semantic_validation","not_run"}});
    return 0;
  }catch(const std::exception&e){errs()<<"error: "<<e.what()<<"\n";return 2;}
}


int main(int argc, char **argv) {
  sys::PrintStackTraceOnErrorSignal(argv[0]);
  if (argc != 3 || StringRef(argv[1]) != "--r2r-batch")
    return runSearch(argc, argv);
  try {
    auto file = MemoryBuffer::getFile(argv[2]);
    if (!file) throw std::runtime_error("cannot read R2R batch manifest");
    auto manifest = json::parse((*file)->getBuffer());
    if (!manifest) throw std::runtime_error(toString(manifest.takeError()));
    auto *requests = manifest->getAsArray();
    if (!requests) throw std::runtime_error("invalid R2R batch manifest");
    R2RBatch batch;
    for (const auto &entry : *requests) {
      const auto *request = entry.getAsObject();
      const auto *args = request ? request->getArray("argv") : nullptr;
      const auto status = request ? request->getString("status") : None;
      if (!args || args->empty() || !status) throw std::runtime_error("invalid R2R batch request");
      std::vector<std::string> arguments;
      for (const auto &arg : *args) {
        const auto value = arg.getAsString();
        if (!value) throw std::runtime_error("invalid R2R batch argument");
        arguments.push_back(value->str());
      }
      std::vector<const char *> refs;
      for (const auto &arg : arguments) refs.push_back(arg.c_str());
      const int code = runSearch(refs.size(), refs.data(), &batch);
      jsonFile(status->str(), json::Object{{"exit_code", code}});
    }
    return 0;
  } catch (const std::exception &error) {
    errs() << "R2R batch: " << error.what() << "\n";
    return 2;
  }
}
