#include "fusion_profile.h"
#include <fcntl.h>
#include <unistd.h>
#include <cerrno>
#include <csignal>
#include <optional>
#include <limits>
#include "fusion_search.h"
#include "ir_pressure.h"
#include "logical_region_state.h"
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
static json::Object planShape(const B2BPlanShape &shape) {
  return json::Object{{"segments",int64_t(shape.segments)},{"removes_branch",shape.removesBranch},
          {"sunk_pairs",int64_t(shape.sunkPairs)},{"sunk_instructions",int64_t(2 * shape.sunkPairs)}};
}
struct DebugObserver final:Observer {
  std::string dir;
  std::string inputPath, outputPath;
  bool fullSnapshots;
  unsigned n=0;
  DebugObserver(std::string d, bool full, StringRef input, StringRef output)
      : dir(std::move(d)), fullSnapshots(full) {
    if (!fullSnapshots) {
      SmallString<256> absoluteInput(input), absoluteOutput(output);
      if (auto ec=sys::fs::make_absolute(absoluteInput))throw std::runtime_error(ec.message());
      if (auto ec=sys::fs::make_absolute(absoluteOutput))throw std::runtime_error(ec.message());
      inputPath=absoluteInput.str().str();
      outputPath=absoluteOutput.str().str();
    }
    if(sys::fs::exists(dir))throw std::runtime_error("debug directory already exists");
    auto ec=sys::fs::create_directories(dir);if(ec)throw std::runtime_error(ec.message());
  }
  void logical(unsigned version,const std::string &value)override {
    std::error_code ec;raw_fd_ostream out(dir+"/logical-state-"+std::to_string(version)+".json",ec);if(ec)throw std::runtime_error(ec.message());out<<value;
  }
  void initial(const Module&m)override { if(fullSnapshots)writeIR(m,dir+"/state-0.ll"); }
  void round(const RoundContext&r)override {
    auto stem=dir+"/round-"+std::to_string(r.parentVersion);
    if(fullSnapshots)writeIR(*r.control,stem+"-control.ll");
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
    if (fullSnapshots) {
      if(t.raw)writeIR(*t.raw,path+"/after-raw.ll");
      if(t.normalized)writeIR(*t.normalized,path+"/after.ll");
    }
    if(t.logicalState){std::error_code ec;raw_fd_ostream out(path+"/logical-state.json",ec);if(ec)throw std::runtime_error(ec.message());out<<t.logicalState->json();}
    json::Array Origins;for(auto &P:t.blockProvenance)Origins.push_back(json::Object{
      {"left_source_id",P.leftID},{"right_source_id",P.rightID},
      {"left_alignment_label",P.leftLabel},{"right_alignment_label",P.rightLabel},
      {"raw_block",P.rawBlock},{"cleaned_block",P.cleanedBlock},
      {"coverage",P.cleanedBlock.empty()?"block_deleted_or_untracked":"surviving_block_identity_not_instruction_or_execution_mapping"}});
    jsonFile(path+"/block-provenance.json",json::Object{{"schema","melding-block-provenance-v1"},
      {"logical_decision",t.candidate.logicalDecision},{"logical_left",t.candidate.logicalLeft},{"logical_right",t.candidate.logicalRight},{"candidate",t.candidate.key()},{"parent_hash",r.parentHash},
      {"cleaned_hash",t.normalized?moduleHash(*t.normalized):""},{"blocks",std::move(Origins)}});
    json::Object report{{"schema","incremental-score-trial-v1"},{"logical_decision",t.candidate.logicalDecision},{"logical_left",t.candidate.logicalLeft},{"logical_right",t.candidate.logicalRight},{"candidate",t.candidate.key()},{"version",int64_t(t.candidate.version)},{"parent_hash",r.parentHash},{"control_hash",r.controlHash},{"round_context","../round-"+std::to_string(r.parentVersion)+".json"},{"valid",t.valid},{"rewrite_started",t.rewriteStarted},{"decision",!t.valid?"reject":score.status!=ScoreStatus::Scored?"unsupported":eligible?"accept":"reject"},{"reason",t.reason},{"merge_path",t.mergePath},{"layout_profitability",json::Array(t.layoutProfitability)},{"cross_decision_leaves",false},{"complete_leaf_plan",false},{"moved_leaf_instructions",int64_t(t.movedLeafInstructions)},{"leaf_anchors",int64_t(t.leafAnchors)},{"leaf_anchor_pairs",[&](){json::Array a;for(auto &p:t.leafAnchorPairs)a.push_back(p);return a;}()},{"fusion_plan",json::Object{{"kind",t.planKind},{"matched_left",t.matchedLeft},{"matched_right",t.matchedRight},{"left_context",bound(t.leftContext)},{"right_context",bound(t.rightContext)},{"split_is_loop_header",t.loopHeaderSplit},{"replication_required",t.replication}}},{"local_reject_reason",t.localRejectReason},{"score_result",scoreJson(score)},{"eligible",eligible},{"cleanup_iterations",int64_t(t.cleanupIterations)},{"alignment_order","function_order_v1"},{"original_darm_similarity",t.originalSimilarity},{"original_darm_profitable",t.originalProfitable},{"replication_required",t.replication},{"orientation_swapped",t.swapped},{"left",bound(t.left)},{"right",bound(t.right)},{"after_raw",stats(t.afterRaw)},{"after",stats(t.after)},{"cleaned_hash",t.normalized?moduleHash(*t.normalized):""},{"parent_ir",fullSnapshots?"../state-"+std::to_string(t.candidate.version)+".ll":inputPath},{"snapshot_mode",fullSnapshots?"full":"compact"},{"cleaned_ir",t.valid?(fullSnapshots?"after.ll":outputPath):""},{"timings_ms",json::Object{{"merge",t.mergeMs},{"normalization",t.normalizeMs},{"features",t.featuresMs},{"trial_total",t.totalMs},{"score_with_analysis",t.scoreMs}}},{"semantic_validation","not_run"}};
    if (t.b2bPlan) report["b2b_plan"] = planShape(*t.b2bPlan);
    jsonFile(path+"/trial.json",std::move(report));
  }
  void commit(unsigned version,const Candidate&c,const ScoreResult&score,const Module&m)override {
    writeIR(m,dir+"/state-"+std::to_string(version)+".ll");
    jsonFile(dir+"/commit-"+std::to_string(version)+".json",json::Object{{"logical_decision",c.logicalDecision},{"logical_left",c.logicalLeft},{"logical_right",c.logicalRight},{"candidate",c.key()},{"parent_version",int64_t(c.version)},{"version",int64_t(version)},{"score_result",scoreJson(score)},{"committed_hash",moduleHash(m)}});
  }
};
// A worker caches one immutable parent at a time and retains its TTI process
// across requests. Changing parent or cleanup invalidates the round cache.
struct TrialWorker {
  std::unique_ptr<LLVMContext> context = std::make_unique<LLVMContext>();
  std::unique_ptr<Module> parent;
  std::optional<RoundContext> round;
  std::unique_ptr<LLVM24Scorer> scorer;
  std::string input, function, worker;
  unsigned level = 0;
  CleanupMode cleanup = CleanupMode::None;
  std::string quoteMode;
};

static int runSearch(int argc, const char *const *argv, TrialWorker *batch = nullptr) {
  fusion::requestProfile.clear();
  try {
    std::string input,function,output,debug,split,left,right,replayParentHash,policy="llvm24";Options options;options.cleanupMode=CleanupMode::DarmCFGInstCombine;bool singleBranchB2B=true, strategyGiven=true, useDarmB2B=false;
    B2BPlanner b2bPlanner = B2BPlanner::Legacy;
    B2RStrategy b2rStrategy = B2RStrategy::Darm;
    std::string recipeInput, quoteMode="on";
    bool recipeCache=false, fullSnapshots=true;
    bool controlOnly=false,catalogOnly=false;std::string ttiWorker="/home/chh/kernel-benchmark-suite/tools/run-llvm24-tti";
    for(int i=1;i<argc;++i){std::string k=argv[i];
      if(k=="--help"){outs()<<"fusion-search v1 --ir FILE --function NAME --out FILE [--b2b-strategy dp1|darm] [--b2b-planner legacy|unified] [--b2r-strategy darm|guarded] [--structural 0|1] [--split ID --left ID --right ID] [--debug-dir DIR] [--ir-snapshots full|compact] [--tti-worker EXECUTABLE] [--catalog-only 0|1] [--control-only 0|1] [--rounds N] [--trials N]\n";return 0;}
      if(i+1==argc)throw std::runtime_error("missing option value");std::string v=argv[++i];
      if(k=="--control-only"){if(v!="0"&&v!="1")throw std::runtime_error("control-only must be 0 or 1");controlOnly=v=="1";}
      else if(k=="--catalog-only"){if(v!="0"&&v!="1")throw std::runtime_error("catalog-only must be 0 or 1");catalogOnly=v=="1";}
      else if(k=="--darm-region-candidates"){if(v!="1")throw std::runtime_error("v1 uses DARM region alignment");}
      else if(k=="--ir-snapshots"){
        if(v!="full" && v!="compact")throw std::runtime_error("ir-snapshots must be full or compact");
        fullSnapshots=v=="full";
      }
      else if(k=="--tti-worker")ttiWorker=v;
      else if(k=="--b2b-recipe-in")recipeInput=v;
      else if(k=="--b2b-recipe-cache") { recipeInput=v; recipeCache=true; }
      else if(k=="--tti-quote-cache") {
        if(v!="off" && v!="audit" && v!="on") throw std::runtime_error("invalid TTI quote cache mode");
        quoteMode=v;
      }
      else if(k=="--b2r-strategy"){
        if(v!="darm" && v!="guarded")
          throw std::runtime_error("b2r-strategy must be darm or guarded");
        b2rStrategy=v=="guarded"?B2RStrategy::Guarded:B2RStrategy::Darm;
      }
      else if(k=="--replay-parent-hash")replayParentHash=v;
      else if(k=="--ir")input=v;else if(k=="--function")function=v;else if(k=="--out")output=v;
      else if(k=="--b2b-planner"){
        if(v!="legacy" && v!="unified")throw std::runtime_error("b2b-planner must be legacy or unified");
        b2bPlanner=v=="unified"?B2BPlanner::Unified:B2BPlanner::Legacy;
      }
      else if(k=="--b2b-strategy"){
        if(v!="darm" && v!="dp1")
          throw std::runtime_error("b2b-strategy must be darm or dp1");
        strategyGiven=true;
        useDarmB2B=v=="darm";
        singleBranchB2B=!useDarmB2B;
      }
      else if(k=="--structural"){if(v!="1")throw std::runtime_error("v1 uses structural enumeration");}
      else if(k=="--cleanup"){if(v!="darm-cfg-dce-instcombine")throw std::runtime_error("v1 cleanup is fixed to darm-cfg-dce-instcombine");}
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
    if (!recipeInput.empty() && (split.empty() || left.empty() || right.empty() || !singleBranchB2B || catalogOnly || controlOnly))
      throw std::runtime_error("recipe replay requires an explicit DP1 B2B pair");
    bool pair=!split.empty()||!left.empty()||!right.empty();if(pair&&(split.empty()||left.empty()||right.empty()))throw std::runtime_error("explicit pair requires all three IDs");
    if (options.cleanupMode == CleanupMode::DarmCFGInstCombine) {
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
    std::unique_ptr<LLVMContext> context = std::make_unique<LLVMContext>();
    std::unique_ptr<MemoryBuffer> buffer;
    std::unique_ptr<Module> parsedModule;
    if (batch) {
      if (!pair || catalogOnly || controlOnly ||
          !replayParentHash.empty())
        throw std::runtime_error("worker requires explicit pair with LLVM24 scoring");
      if (batch->parent && (batch->input != input || batch->function != function ||
          batch->worker != ttiWorker || batch->level != options.optLevel ||
          batch->cleanup != options.cleanupMode || batch->quoteMode != quoteMode))
      {
        batch->round.reset();
        batch->parent.reset();
        batch->context = std::make_unique<LLVMContext>();
        if (batch->function != function || batch->worker != ttiWorker || batch->quoteMode != quoteMode)
          batch->scorer.reset();
      }
    }
    const bool reuseParent = batch && batch->parent;
    if (!reuseParent) {
      auto file = MemoryBuffer::getFile(input);
      if (!file) throw std::runtime_error("cannot read input IR");
      buffer = std::move(*file);
      SMDiagnostic error;
      parsedModule = parseIR(buffer->getMemBufferRef(), error, batch ? *batch->context : *context);
      if (!parsedModule) { error.print(argv[0], errs()); return 2; }
      if (batch) {
        if (verifyModule(*parsedModule, &errs())) return 2;
        batch->input = input;
        batch->function = function;
        batch->worker = ttiWorker;
        batch->level = options.optLevel;
        batch->cleanup = options.cleanupMode;
        batch->quoteMode = quoteMode;
        batch->parent = std::move(parsedModule);
        if (!batch->scorer) batch->scorer = std::make_unique<LLVM24Scorer>(ttiWorker, quoteMode);
      }
    }
    auto *module = batch ? batch->parent.get() : parsedModule.get();

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
    if(!batch && verifyModule(*module,&errs()))return 2;
    auto*f=module->getFunction(function);if(!f||f->isDeclaration())throw std::runtime_error("function missing");
    std::unique_ptr<DebugObserver> observer;if(!debug.empty())observer=std::make_unique<DebugObserver>(debug,fullSnapshots,input,output);
    if(catalogOnly){
      if(pair||controlOnly||!observer)throw std::runtime_error("catalog-only requires debug-dir and excludes pair/control-only");
      if(verifyModule(*module,&errs()))return 2;
      observer->initial(*module);
      const char*cleanupName="darm-cfg-dce-instcombine";
      if(options.adjacentOnly){auto st=LogicalRegionState::initialize(*module->getFunction(function));observer->logical(0,st->json());}
      auto candidates=enumerate(*module->getFunction(function),0);json::Array entries;
      const auto rejected=crossLevelCatalogRejections(*f,candidates);
      for(const auto&c:candidates)entries.push_back(json::Object{{"logical_decision",c.logicalDecision},{"logical_left",c.logicalLeft},{"logical_right",c.logicalRight},{"candidate",c.key()},{"function",c.function},{"split",c.split},{"left",c.left},{"right",c.right},{"preflight_rejection",rejected.count(c.key())?"b2r_replicates_same_decision_chain_requires_opt_in":""}});
      jsonFile(debug+"/catalog.json",json::Object{{"schema","postopt-candidate-catalog-v1"},{"adjacent_only",options.adjacentOnly},{"cross_decision_leaves",false},{"source_ir",input},{"function",function},
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
    if(pair){if(!batch && verifyModule(*module,&errs()))return 2;
      if(observer)observer->initial(*module);
    }
    LLVM24Scorer standaloneScorer(ttiWorker, quoteMode);
    auto &llvm24Scorer = batch ? *batch->scorer : standaloneScorer;
    if(observer)jsonFile(debug+"/run.json",json::Object{
      {"schema","fusion-v1"},{"function",function},{"policy","llvm24"},
      {"b2b_strategy",useDarmB2B?"darm":"dp1"},{"b2r_strategy",b2rStrategy==B2RStrategy::Guarded?"guarded":"darm"},{"r2r_strategy","darm"},
      {"cleanup","darm-cfg-dce-instcombine"},{"phi_fold_threshold",7},
      {"initial_parent_hash",moduleHash(*module)},{"replay_parent_hash",replayParentHash},
      {"semantic_validation","not_run"}});
    const Scorer &scorer=llvm24Scorer;
    if(pair){Candidate c{function,split,left,right,0};std::shared_ptr<LogicalRegionState> logical;if(options.adjacentOnly){logical=LogicalRegionState::initialize(*module->getFunction(function));if(observer)observer->logical(0,logical->json());auto adjacent=logical->filter(*module->getFunction(function),enumerate(*module->getFunction(function),0));bool found=false;for(auto &a:adjacent)if(a.key()==c.key()){found=true;c=a;}if(!found)throw std::runtime_error("explicit_pair_not_adjacent");}      std::optional<RoundContext> standaloneRound;
      auto &roundStorage = batch ? batch->round : standaloneRound;
      if (!roundStorage)
        roundStorage.emplace(makeRound(*module,function,0,options.optLevel,options.cleanupMode));
      const auto &round = *roundStorage;
      if(observer)observer->round(round);
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
      std::optional<json::Value> recipe;
      if (!recipeInput.empty()) {
        auto buffer = MemoryBuffer::getFile(recipeInput);
        if (!buffer) throw std::runtime_error("cannot_read_b2b_recipe");
        auto parsed = json::parse((*buffer)->getBuffer());
        if (!parsed) throw std::runtime_error(toString(parsed.takeError()));
        recipe = std::move(*parsed);
        if (!recipe->getAsObject()) throw std::runtime_error("invalid_b2b_recipe");
      }
      json::Object recipeOut;
      std::string recipeCacheStatus=recipe ? "hit" : "miss";
      std::vector<Trial> plans;
      if (!logical && singleBranchB2B) {
        try {
          plans=planSingleBranchB2B(*module,c,options.optLevel,options.cleanupMode,"",intrinsicCost,
                                   &recipeOut,recipe ? recipe->getAsObject() : nullptr,b2bPlanner);
        } catch (const std::runtime_error &error) {
          if (!recipeCache || StringRef(error.what())!="b2b_recipe_dependencies_changed") throw;
          recipeCacheStatus="invalidated";
          recipe.reset();recipeOut=json::Object{};
          plans=planSingleBranchB2B(*module,c,options.optLevel,options.cleanupMode,"",intrinsicCost,&recipeOut,nullptr,b2bPlanner);
        }
      }
      if (recipeCache && plans.empty()) { recipe.reset(); recipeCacheStatus="ineligible"; }
      if (observer) jsonFile(debug+"/b2b-recipe-cache.json",json::Object{
          {"status",recipeCacheStatus},{"source",recipeInput},{"scores_reused",false}});
      if (observer && !recipeOut.empty()) jsonFile(debug+"/b2b-recipe.json", std::move(recipeOut));
      if (recipe && plans.empty()) throw std::runtime_error("b2b_recipe_dependencies_changed");
      const bool plannedB2B = !plans.empty();
      Trial t;
      ScoreResult score;
      if (plannedB2B) {
        json::Array profitability;
        std::set<std::string> seenDP1;
        for (auto &plan : plans) {
          if (plan.valid && !seenDP1.insert(moduleHash(*plan.normalized)).second)
            continue;
          auto result = profileCall("evaluate_score",[&](){return evaluateTrial(*module, plan, round, scorer);});
          if (StringRef(result.reason).startswith("tti_quote_")) throw std::runtime_error(result.reason);
          const bool allowed = eligible(plan, result, options);
          if (plan.b2bPlan)
            profitability.push_back(json::Object{
                {"layout",plan.mergePath},{"valid",plan.valid},{"eligible",allowed},
                {"b2b_plan",planShape(*plan.b2bPlan)},{"score_result",scoreJson(result)}});
          if (t.mergePath.empty() ||
              ((plan.valid && !t.valid) ||
                (result.status == ScoreStatus::Scored &&
                 (score.status != ScoreStatus::Scored || result.total > score.total)))) {
            t = std::move(plan);
            score = std::move(result);
          }
        }
        t.layoutProfitability = std::move(profitability);
      }
      const bool allowDarmB2B = !strategyGiven || useDarmB2B;
      if (!plannedB2B) {
        Trial boundaryFold;
        t = tryPair(*module, c, 0, options.optLevel, options.cleanupMode,
                    logical.get(), allowDarmB2B, b2rStrategy, &boundaryFold);
        if (t.valid) score = profileCall("evaluate_score",[&](){return evaluateTrial(*module, t, round, scorer);});
        if (boundaryFold.valid) {
          if (StringRef(score.reason).startswith("tti_quote_")) throw std::runtime_error(score.reason);
          auto alternate = profileCall("evaluate_score",[&](){return evaluateTrial(*module, boundaryFold, round, scorer);});
          if (StringRef(alternate.reason).startswith("tti_quote_")) throw std::runtime_error(alternate.reason);
          json::Array layouts;
          auto record = [&](const Trial &trial, const ScoreResult &scored) {
            auto cost = scored.metrics.find("work_after");
            layouts.push_back(json::Object{{"layout",trial.mergePath},
                {"eligible",eligible(trial,scored,options)},
                {"cost",cost==scored.metrics.end()?json::Value(nullptr):json::Value(cost->second)}});
          };
          record(t,score);
          record(boundaryFold,alternate);
          const bool originalEligible = eligible(t,score,options);
          const bool alternateEligible = eligible(boundaryFold,alternate,options);
          const bool betterScore = alternate.status == ScoreStatus::Scored &&
              (score.status != ScoreStatus::Scored || alternate.total > score.total);
          if (alternateEligible != originalEligible ? alternateEligible : betterScore) {
            t = std::move(boundaryFold);
            score = std::move(alternate);
          }
          t.layoutProfitability = std::move(layouts);
        }
      }
      if (StringRef(score.reason).startswith("tti_quote_")) throw std::runtime_error(score.reason);
      if(observer)jsonFile(debug+"/tti-quote-cache.json",llvm24Scorer.quoteCacheStats());
      if(observer)observer->trial(t,round,score,eligible(t,score,options));
      if(observer)jsonFile(debug+"/request-profile.json",profileJSON());
      if(!t.valid){errs()<<"rejected: "<<t.reason<<"\n";return 4;}
      if(score.status!=ScoreStatus::Scored)errs()<<"score unsupported; exporting legal trial: "<<score.reason<<"\n";
      writeIR(*t.normalized,output);outs()<<"pair trial verified; static_score="<<score.total<<"; eligible="<<eligible(t,score,options)<<"; semantic validation not run\n";return 0;
    }
    throw std::runtime_error("use decision-greedy for automatic search; fusion-search evaluates explicit pairs");
  }catch(const std::exception&e){errs()<<"error: "<<e.what()<<"\n";return 2;}
}


int main(int argc, char **argv) {
  sys::PrintStackTraceOnErrorSignal(argv[0]);
  const bool queue = argc == 3 && StringRef(argv[1]) == "--trial-queue";
  if (!queue && (argc != 3 || StringRef(argv[1]) != "--r2r-batch"))
    return runSearch(argc, argv);
  try {
    auto file = MemoryBuffer::getFile(argv[2]);
    if (!file) throw std::runtime_error("cannot read R2R batch manifest");
    auto manifest = json::parse((*file)->getBuffer());
    if (!manifest) throw std::runtime_error(toString(manifest.takeError()));
    auto *requests = manifest->getAsArray();
    if (!requests) throw std::runtime_error("invalid R2R batch manifest");
    TrialWorker batch;
    for (const auto &entry : *requests) {
      const auto *request = entry.getAsObject();
      const auto *args = request ? request->getArray("argv") : nullptr;
      const auto status = request ? request->getString("status") : None;
      if (!args || args->empty() || !status) throw std::runtime_error("invalid R2R batch request");
      if (queue) {
        const std::string claim = status->str() + ".claim";
        const int fd = ::open(claim.c_str(), O_CREAT | O_EXCL | O_WRONLY | O_CLOEXEC, 0600);
        if (fd < 0) {
          if (errno == EEXIST) continue;
          throw std::runtime_error("cannot claim trial: " + claim);
        }
        ::close(fd);
      }
      std::vector<std::string> arguments;
      for (const auto &arg : *args) {
        const auto value = arg.getAsString();
        if (!value) throw std::runtime_error("invalid R2R batch argument");
        arguments.push_back(value->str());
      }
      std::vector<const char *> refs;
      for (const auto &arg : arguments) refs.push_back(arg.c_str());
      int savedOut = -1, savedErr = -1;
      if (queue) {
        auto output = request->getString("stdout"), error = request->getString("stderr");
        if (!output || !error) throw std::runtime_error("missing trial log paths");
        outs().flush(); errs().flush();
        savedOut = ::dup(STDOUT_FILENO); savedErr = ::dup(STDERR_FILENO);
        int out = ::open(output->str().c_str(), O_WRONLY | O_CREAT | O_TRUNC, 0600);
        int err = ::open(error->str().c_str(), O_WRONLY | O_CREAT | O_TRUNC, 0600);
        if (savedOut < 0 || savedErr < 0 || out < 0 || err < 0 ||
            ::dup2(out, STDOUT_FILENO) < 0 || ::dup2(err, STDERR_FILENO) < 0)
          throw std::runtime_error("cannot redirect trial logs");
        ::close(out); ::close(err);
        ::alarm(120);
      }
      const int code = runSearch(refs.size(), refs.data(), &batch);
      if (queue) {
        ::alarm(0);
        outs().flush(); errs().flush();
        ::dup2(savedOut, STDOUT_FILENO); ::dup2(savedErr, STDERR_FILENO);
        ::close(savedOut); ::close(savedErr);
      }
      jsonFile(status->str(), json::Object{{"exit_code", code}, {"worker_pid", int64_t(::getpid())}});
      if (code != 0 && code != 4) {
        batch.round.reset(); batch.parent.reset();
        batch.context = std::make_unique<LLVMContext>();
      }
    }
    return 0;
  } catch (const std::exception &error) {
    errs() << "R2R batch: " << error.what() << "\n";
    return 2;
  }
}
