#include "anchor_uniform_gate.h"
#include "anchor_condition.h"
#include "fusion_profile.h"
#include <fcntl.h>
#include <unistd.h>
#include <cerrno>
#include <cstdlib>
#include <csignal>
#include <optional>
#include <limits>
#include "fusion_search.h"
#include "ir_pressure.h"
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
struct DebugObserver {
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
  void initial(const Module&m) { if(fullSnapshots)writeIR(m,dir+"/state-0.ll"); }
  void round(const RoundContext&r) {
    auto stem=dir+"/round-"+std::to_string(r.parentVersion);
    if(fullSnapshots)writeIR(*r.control,stem+"-control.ll");
    jsonFile(stem+".json",json::Object{{"schema","incremental-score-round-v1"},{"hash_algorithm","llvm-sha1-printed-module"},{"parent_version",int64_t(r.parentVersion)},{"function",r.function},{"parent_hash",r.parentHash},{"control_hash",r.controlHash},{"llvm_version",r.llvmVersion},{"target_triple",r.targetTriple},{"data_layout",r.dataLayout},{"target_attributes",r.targetAttributes},{"cleanup",r.cleanup},{"feature_schema",r.featureSchema},{"weight_version",r.weightVersion},{"normalization_scale",r.normalizationScale},{"parent",stats(r.parentFeatures)},{"control",stats(r.controlFeatures)},{"control_ms",r.controlMs},{"control_cleanup_iterations",int64_t(r.controlCleanupIterations)}});
  }
  void trial(const Trial&t,const RoundContext&r,const ScoreResult&score,bool eligible) {
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
    json::Array Origins;for(auto &P:t.blockProvenance)Origins.push_back(json::Object{
      {"left_source_id",P.leftID},{"right_source_id",P.rightID},
      {"left_alignment_label",P.leftLabel},{"right_alignment_label",P.rightLabel},
      {"raw_block",P.rawBlock},{"cleaned_block",P.cleanedBlock},
      {"coverage",P.cleanedBlock.empty()?"block_deleted_or_untracked":"surviving_block_identity_not_instruction_or_execution_mapping"}});
    jsonFile(path+"/block-provenance.json",json::Object{{"schema","melding-block-provenance-v1"},
      {"logical_decision",t.candidate.logicalDecision},{"logical_left",t.candidate.logicalLeft},{"logical_right",t.candidate.logicalRight},{"candidate",t.candidate.key()},{"parent_hash",r.parentHash},
      {"cleaned_hash",t.normalized?moduleHash(*t.normalized):""},{"blocks",std::move(Origins)}});
    json::Object report{{"schema","incremental-score-trial-v1"},{"logical_decision",t.candidate.logicalDecision},{"logical_left",t.candidate.logicalLeft},{"logical_right",t.candidate.logicalRight},{"candidate",t.candidate.key()},{"version",int64_t(t.candidate.version)},{"parent_hash",r.parentHash},{"control_hash",r.controlHash},{"round_context","../round-"+std::to_string(r.parentVersion)+".json"},{"valid",t.valid},{"rewrite_started",t.rewriteStarted},{"decision",!t.valid?"reject":score.status!=ScoreStatus::Scored?"unsupported":eligible?"accept":"reject"},{"reason",t.reason},{"merge_path",t.mergePath},{"layout_profitability",json::Array(t.layoutProfitability)},{"cross_decision_leaves",false},{"complete_leaf_plan",false},{"moved_leaf_instructions",int64_t(0)},{"leaf_anchors",int64_t(0)},{"leaf_anchor_pairs",json::Array{}},{"fusion_plan",json::Object{{"kind",t.planKind},{"matched_left",t.matchedLeft},{"matched_right",t.matchedRight},{"left_context",bound(t.leftContext)},{"right_context",bound(t.rightContext)},{"split_is_loop_header",t.loopHeaderSplit},{"replication_required",t.replication}}},{"local_reject_reason",t.localRejectReason},{"score_result",scoreJson(score)},{"eligible",eligible},{"cleanup_iterations",int64_t(t.cleanupIterations)},{"alignment_order","function_order_v1"},{"original_darm_similarity",t.originalSimilarity},{"original_darm_profitable",t.originalProfitable},{"replication_required",t.replication},{"orientation_swapped",t.swapped},{"left",bound(t.left)},{"right",bound(t.right)},{"after_raw",stats(t.afterRaw)},{"after",stats(t.after)},{"cleaned_hash",t.normalized?moduleHash(*t.normalized):""},{"parent_ir",fullSnapshots?"../state-"+std::to_string(t.candidate.version)+".ll":inputPath},{"snapshot_mode",fullSnapshots?"full":"compact"},{"cleaned_ir",t.valid?(fullSnapshots?"after.ll":outputPath):""},{"timings_ms",json::Object{{"merge",t.mergeMs},{"normalization",t.normalizeMs},{"features",t.featuresMs},{"trial_total",t.totalMs},{"score_with_analysis",t.scoreMs}}},{"semantic_validation","not_run"}};
    if (!t.dataflowExact.empty()) {
      auto handler = t.dataflowExact.getString("strategy");
      report[handler == Optional<StringRef>("dataflow") ? "dataflow" : "dataflow_exact"] = json::Object(t.dataflowExact);
    }
    if (t.observedPairs) report["source_pairs"] = json::Array(*t.observedPairs);
    if (!t.anchorStats.empty()) report["anchor"] = json::Object(t.anchorStats);
    if (!t.r2rSpeculation.empty()) report["r2r_speculation"] = json::Object(t.r2rSpeculation);
    jsonFile(path+"/trial.json", std::move(report));
  }

};
// A worker caches one immutable parent at a time and retains its TTI process
// across requests. Changing parent or quote settings invalidates the round cache.
struct TrialWorker {
  std::unique_ptr<LLVMContext> context = std::make_unique<LLVMContext>();
  std::unique_ptr<Module> parent;
  std::optional<RoundContext> round;
  std::unique_ptr<LLVM24Scorer> scorer;
  std::string input, function, worker;
  std::string quoteMode;
};

static int runSearch(int argc, const char *const *argv, TrialWorker *batch = nullptr) {
  fusion::requestProfile.clear();
  try {
    std::string input,function,output,debug,split,left,right;
    constexpr auto cleanupMode = CleanupMode::DarmCFGInstCombine;
    constexpr unsigned optLevel = 3;
    bool useArtifactB2B=false, useAnchorB2B=true, useDataflowExact=false;
    std::string dataflowSolver, dataflowCosts;
    bool heuristic = false, observePairs = false;
    std::string quoteMode="on";
    bool fullSnapshots=true;
    bool controlOnly=false,catalogOnly=false;std::string ttiWorker="/home/chh/kernel-benchmark-suite/tools/run-llvm24-tti";
    for(int i=1;i<argc;++i){std::string k=argv[i];
      if(k=="--help"){outs()<<"fusion-search v1 --ir FILE --function NAME --out FILE [--b2b-strategy anchor|darm|darm-artifact|dataflow-exact|dataflow] [--split ID --left ID --right ID] [--debug-dir DIR] [--ir-snapshots full|compact] [--tti-worker EXECUTABLE] [--catalog-only 0|1] [--control-only 0|1]\n";return 0;}
      if(i+1==argc)throw std::runtime_error("missing option value");std::string v=argv[++i];
      if(k=="--control-only"){if(v!="0"&&v!="1")throw std::runtime_error("control-only must be 0 or 1");controlOnly=v=="1";}
      else if(k=="--catalog-only"){if(v!="0"&&v!="1")throw std::runtime_error("catalog-only must be 0 or 1");catalogOnly=v=="1";}
      else if(k=="--ir-snapshots"){
        if(v!="full" && v!="compact")throw std::runtime_error("ir-snapshots must be full or compact");
        fullSnapshots=v=="full";
      }
      else if(k=="--tti-worker")ttiWorker=v;
      else if(k=="--tti-quote-cache") {
        if(v!="off" && v!="audit" && v!="on") throw std::runtime_error("invalid TTI quote cache mode");
        quoteMode=v;
      }
      else if(k=="--ir")input=v;else if(k=="--function")function=v;else if(k=="--out")output=v;
      else if(k=="--observe-source-pairs") {
        if (v != "1" && v != "0") throw std::runtime_error("observe-source-pairs must be 0 or 1");
        observePairs = v == "1";
      }
      else if(k=="--b2b-strategy"){
        if(v!="darm" && v!="darm-artifact" && v!="anchor" && v!="dataflow-exact" && v!="dataflow")
          throw std::runtime_error("b2b-strategy must be anchor, darm, darm-artifact, dataflow-exact or dataflow");
        useArtifactB2B=v=="darm-artifact";
        useAnchorB2B=v=="anchor";
        heuristic=v=="dataflow";
        useDataflowExact=v=="dataflow-exact" || heuristic;
      }
      else if(k=="--dataflow-solver")dataflowSolver=v;
      else if(k=="--dataflow-costs")dataflowCosts=v;
      else if(k=="--debug-dir")debug=v;else if(k=="--split")split=v;else if(k=="--left")left=v;else if(k=="--right")right=v;
      else throw std::runtime_error("unknown option: "+k);
    }

    if(input.empty()||function.empty()||output.empty())throw std::runtime_error("--ir, --function, --out required");
    if(sys::fs::exists(output))throw std::runtime_error("output already exists");
    bool pair=!split.empty()||!left.empty()||!right.empty();if(pair&&(split.empty()||left.empty()||right.empty()))throw std::runtime_error("explicit pair requires all three IDs");
    if (pair && useDataflowExact && (dataflowSolver.empty() || dataflowCosts.empty()))
      throw std::runtime_error(heuristic ? "dataflow requires --dataflow-solver and --dataflow-costs" :
                               "dataflow-exact requires --dataflow-solver and --dataflow-costs");
    // LLVM 12 reads this registered option inside SimplifyCFG. Initialize it
    // once per process, including when a worker evaluates a batch of pairs.
    static const bool configured = [] {
      const StringRef name = "two-entry-phi-node-folding-threshold";
      auto &registered = cl::getRegisteredOptions();
      auto entry = registered.find(name);
      return entry != registered.end() && !entry->second->addOccurrence(0, name, "7");
    }();
    if (!configured) throw std::runtime_error("cannot configure v1 PHI fold threshold");
    std::unique_ptr<LLVMContext> context = std::make_unique<LLVMContext>();
    std::unique_ptr<MemoryBuffer> buffer;
    std::unique_ptr<Module> parsedModule;
    if (batch) {
      if (!pair || catalogOnly || controlOnly)
        throw std::runtime_error("worker requires explicit pair with LLVM24 scoring");
      if (batch->parent && (batch->input != input || batch->function != function ||
          batch->worker != ttiWorker || batch->quoteMode != quoteMode))
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
        batch->quoteMode = quoteMode;
        batch->parent = std::move(parsedModule);
        if (!batch->scorer) batch->scorer = std::make_unique<LLVM24Scorer>(ttiWorker, quoteMode);
      }
    }
    auto *module = batch ? batch->parent.get() : parsedModule.get();

    if(!batch && verifyModule(*module,&errs()))return 2;
    auto*f=module->getFunction(function);if(!f||f->isDeclaration())throw std::runtime_error("function missing");
    std::unique_ptr<DebugObserver> observer;if(!debug.empty())observer=std::make_unique<DebugObserver>(debug,fullSnapshots,input,output);
    if(catalogOnly){
      if(pair||controlOnly||!observer)throw std::runtime_error("catalog-only requires debug-dir and excludes pair/control-only");
      if(verifyModule(*module,&errs()))return 2;
      observer->initial(*module);
      const char*cleanupName="darm-cfg-dce-instcombine";
      auto candidates=enumerate(*module->getFunction(function),0);json::Array entries;
      if (useDataflowExact) addDataflowCandidates(*f, candidates, heuristic);
      const auto rejected=crossLevelCatalogRejections(*f,candidates);
      for(const auto&c:candidates)entries.push_back(json::Object{{"logical_decision",c.logicalDecision},{"logical_left",c.logicalLeft},{"logical_right",c.logicalRight},{"candidate",c.key()},{"function",c.function},{"split",c.split},{"left",c.left},{"right",c.right},{"preflight_rejection",rejected.count(c.key())?"b2r_replicates_same_decision_chain_requires_opt_in":""}});
      jsonFile(debug+"/catalog.json",json::Object{{"schema","postopt-candidate-catalog-v1"},{"adjacent_only",false},{"cross_decision_leaves",false},{"source_ir",input},{"function",function},
        {"parent_hash",moduleHash(*module)},{"cleanup",cleanupName},{"opt_level",int64_t(optLevel)},{"count",int64_t(candidates.size())},{"candidates",std::move(entries)},
        {"legality","not_tested"},{"score","not_evaluated"},{"semantic_validation","not_run"}});
      writeIR(*module,output);outs()<<"catalog candidates="<<candidates.size()<<"; no trials or commits\n";return 0;
    }
    if(controlOnly){
      if(pair)throw std::runtime_error("control-only excludes explicit pair selection");
      auto round=makeRound(*module,function,0,cleanupMode);
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
      {"b2b_strategy",useDataflowExact?(heuristic?"dataflow":"dataflow-exact"):useAnchorB2B?"anchor":useArtifactB2B?"darm-artifact":"darm"},{"b2r_strategy","darm"},{"r2r_strategy","darm"},
      {"cleanup","darm-cfg-dce-instcombine"},{"phi_fold_threshold",7},
      {"initial_parent_hash",moduleHash(*module)},{"replay_parent_hash",""},
      {"semantic_validation","not_run"}});
    const Scorer &scorer=llvm24Scorer;
    if(pair){Candidate c{function,split,left,right,0};
      std::optional<RoundContext> standaloneRound;
      auto &roundStorage = batch ? batch->round : standaloneRound;
      if (!roundStorage)
        roundStorage.emplace(makeRound(*module,function,0,cleanupMode));
      const auto &round = *roundStorage;
      if(observer)observer->round(round);
      Optional<Trial> exactPlan;
      json::Object fallback;
      bool planWithAnchor = useAnchorB2B;
      if (useDataflowExact) {
        exactPlan = tryDataflowExact(*module, c, cleanupMode, dataflowSolver,
                                     dataflowCosts, ttiWorker, heuristic);
        if (exactPlan && exactPlan->dataflowExact.getString("handler") ==
                             Optional<StringRef>("anchor_fallback")) {
          fallback = std::move(exactPlan->dataflowExact);
          exactPlan.reset();
        }
        planWithAnchor = !exactPlan;
      }
      std::vector<Trial> plans;
      if (planWithAnchor)
        plans = llvm24Scorer.planAnchorB2B(*module, c, cleanupMode, observePairs);
      const bool plannedB2B = !plans.empty();
      Trial t;
      ScoreResult score;
      auto sideGain = [](const ScoreResult &result, const char *key) -> std::optional<double> {
        auto metric = result.metrics.find(key);
        if (metric == result.metrics.end() || !std::isfinite(metric->second))
          return std::nullopt;
        return metric->second;
      };
      if (plannedB2B) {
        json::Array profitability;
        const auto source = profileCall("classify_anchor_condition", [&]() {
          return anchor_condition::classifySource(anchor_condition::findBranch(*f, split));
        });
        std::set<std::string> seenCleanedIR;
        const bool traceLayouts = observer && !batch && std::getenv("FUSION_OBSERVE_B2B_DP");
        for (auto &plan : plans) {
          const std::string hash = plan.valid ? moduleHash(*plan.normalized) : "";
          const auto emission = plan.anchorStats.getString("emission").getValueOr("");
          const bool linear = emission == "linear" || emission == "guarded-linear";
          const bool duplicate = plan.valid && seenCleanedIR.count(hash);
          // A gated linear layout needs its own side quotation even when its
          // normalized IR duplicates another layout.
          if (duplicate && !traceLayouts && !linear)
            continue;
          if (traceLayouts) {
            if (plan.raw) writeIR(*plan.raw, debug + "/" + plan.mergePath + "-raw.ll");
            if (plan.normalized) writeIR(*plan.normalized, debug + "/" + plan.mergePath + "-cleaned.ll");
          }
          auto result = profileCall("evaluate_score",[&](){return evaluateTrial(*module, plan, round, scorer);});
          if (StringRef(result.reason).startswith("tti_quote_")) throw std::runtime_error(result.reason);
          const bool ttiEligible = eligible(plan, result);
          const auto rejection = plan.valid ? anchorUniformRejection(
              source, linear, sideGain(result, "uniform_gain_false"),
              sideGain(result, "uniform_gain_true")) : StringRef{};
          json::Object layout{{"layout", plan.mergePath}, {"valid", plan.valid},
              {"eligible", ttiEligible && rejection.empty()}, {"anchor", json::Object(plan.anchorStats)},
              {"score_result", scoreJson(result)}};
          layout["tti_eligible"] = ttiEligible;
          if (!rejection.empty())
            layout["uniform_gate_rejection"] = rejection;
          profitability.push_back(std::move(layout));
          if (!rejection.empty())
            continue;
          if (plan.valid && !seenCleanedIR.insert(hash).second) continue;
          if (t.mergePath.empty() ||
              ((plan.valid && !t.valid) ||
                (result.status == ScoreStatus::Scored &&
                 (score.status != ScoreStatus::Scored || result.total > score.total)))) {
            t = std::move(plan);
            score = std::move(result);
          }
        }
        if (t.mergePath.empty()) {
          t.candidate = c;
          t.reason = "anchor_uniform_gate_no_layout";
        }
        t.anchorStats["condition_source"] = source;
        if (planWithAnchor) {
          t.anchorStats["generated"] = int64_t(plans.size());
          t.anchorStats["unique_normalized"] = int64_t(seenCleanedIR.size());
        }
        t.layoutProfitability = std::move(profitability);
      }
      const bool dataflowHandled = bool(exactPlan);
      if (exactPlan) {
        t = std::move(*exactPlan);
        if (t.valid)
          score = evaluateTrial(*module, t, round, scorer);
      }
      const bool allowDarmB2B = !useAnchorB2B && !useDataflowExact;
      if (!plannedB2B && !dataflowHandled) {
        auto emitRegion = [&](bool speculate) {
          t = tryPair(*module, c, 0, cleanupMode,
                      allowDarmB2B, useArtifactB2B, speculate, observePairs);
          score = t.valid ? profileCall("evaluate_score", [&]() {
            return evaluateTrial(*module, t, round, scorer);
          }) : ScoreResult{};
        };
        emitRegion(true);
        if (t.valid && !t.r2rSpeculationSplit.empty()) {
          if (StringRef(score.reason).startswith("tti_quote_")) throw std::runtime_error(score.reason);
          const auto source = anchor_condition::classifySource(
              anchor_condition::findBranch(*f, t.r2rSpeculationSplit));
          const auto rejection = anchorUniformRejection(
              source, true,
              sideGain(score, "uniform_gain_false"), sideGain(score, "uniform_gain_true"));
          json::Object speculation{{"split", t.r2rSpeculationSplit}, {"condition_source", source},
                                   {"score_result", scoreJson(score)}, {"tti_eligible", eligible(t, score)},
                                   {"gate_rejection", rejection}};
          if (!rejection.empty())
            emitRegion(false);
          t.r2rSpeculation = std::move(speculation);
        }
      }
      if (useDataflowExact) {
        if (!fallback.empty())
          t.dataflowExact = std::move(fallback);
        if (t.dataflowExact.empty())
          t.dataflowExact["handler"] = plannedB2B ? "existing_anchor" : "existing_pipeline";
        if (heuristic)
          t.dataflowExact["strategy"] = "dataflow";
        if (t.valid) {
          try {
            if (auto rawCost = llvm24Scorer.functionCost(*t.raw->getFunction(function)))
              t.dataflowExact["raw_kernel_cost"] = *rawCost;
            else
              t.dataflowExact["raw_kernel_cost_error"] = "unknown LLVM24 instruction cost";
          } catch (const std::exception &error) {
            t.dataflowExact["raw_kernel_cost_error"] = error.what();
          }
          auto after = score.metrics.find("work_after");
          if (after != score.metrics.end())
            t.dataflowExact["cleaned_kernel_cost"] = after->second;
        }
      }
      if (StringRef(score.reason).startswith("tti_quote_")) throw std::runtime_error(score.reason);
      if(observer)jsonFile(debug+"/tti-quote-cache.json",llvm24Scorer.quoteCacheStats());
      if(observer)observer->trial(t,round,score,eligible(t,score));
      if(observer)jsonFile(debug+"/request-profile.json",profileJSON());
      if(!t.valid){errs()<<"rejected: "<<t.reason<<"\n";return 4;}
      if(score.status!=ScoreStatus::Scored)errs()<<"score unsupported; exporting legal trial: "<<score.reason<<"\n";
      writeIR(*t.normalized,output);outs()<<"pair trial verified; static_score="<<score.total<<"; eligible="<<eligible(t,score)<<"; semantic validation not run\n";return 0;
    }
    throw std::runtime_error("use decision-greedy for automatic search; fusion-search evaluates explicit pairs");
  }catch(const std::exception&e){errs()<<"error: "<<e.what()<<"\n";return 2;}
}


int main(int argc, char **argv) {
  sys::PrintStackTraceOnErrorSignal(argv[0]);
  if (argc != 3 || StringRef(argv[1]) != "--trial-queue")
    return runSearch(argc, argv);
  try {
    auto file = MemoryBuffer::getFile(argv[2]);
    if (!file) throw std::runtime_error("cannot read trial queue manifest");
    auto manifest = json::parse((*file)->getBuffer());
    if (!manifest) throw std::runtime_error(toString(manifest.takeError()));
    auto *requests = manifest->getAsArray();
    if (!requests) throw std::runtime_error("invalid trial queue manifest");
    TrialWorker batch;
    for (const auto &entry : *requests) {
      const auto *request = entry.getAsObject();
      const auto *args = request ? request->getArray("argv") : nullptr;
      const auto status = request ? request->getString("status") : None;
      if (!args || args->empty() || !status) throw std::runtime_error("invalid trial queue request");
      const std::string claim = status->str() + ".claim";
      const int fd = ::open(claim.c_str(), O_CREAT | O_EXCL | O_WRONLY | O_CLOEXEC, 0600);
      if (fd < 0) {
        if (errno == EEXIST) continue;
        throw std::runtime_error("cannot claim trial: " + claim);
      }
      ::close(fd);
      std::vector<std::string> arguments;
      for (const auto &arg : *args) {
        const auto value = arg.getAsString();
        if (!value) throw std::runtime_error("invalid trial queue argument");
        arguments.push_back(value->str());
      }
      std::vector<const char *> refs;
      for (const auto &arg : arguments) refs.push_back(arg.c_str());
      auto output = request->getString("stdout"), error = request->getString("stderr");
      if (!output || !error) throw std::runtime_error("missing trial log paths");
      outs().flush(); errs().flush();
      const int savedOut = ::dup(STDOUT_FILENO), savedErr = ::dup(STDERR_FILENO);
      int out = ::open(output->str().c_str(), O_WRONLY | O_CREAT | O_TRUNC, 0600);
      int err = ::open(error->str().c_str(), O_WRONLY | O_CREAT | O_TRUNC, 0600);
      if (savedOut < 0 || savedErr < 0 || out < 0 || err < 0 ||
          ::dup2(out, STDOUT_FILENO) < 0 || ::dup2(err, STDERR_FILENO) < 0)
        throw std::runtime_error("cannot redirect trial logs");
      ::close(out); ::close(err);
      ::alarm(120);
      const int code = runSearch(refs.size(), refs.data(), &batch);
      ::alarm(0);
      outs().flush(); errs().flush();
      ::dup2(savedOut, STDOUT_FILENO); ::dup2(savedErr, STDERR_FILENO);
      ::close(savedOut); ::close(savedErr);
      jsonFile(status->str(), json::Object{{"exit_code", code}, {"worker_pid", int64_t(::getpid())}});
      if (code != 0 && code != 4) {
        batch.round.reset(); batch.parent.reset();
        batch.context = std::make_unique<LLVMContext>();
      }
    }
    return 0;
  } catch (const std::exception &error) {
    errs() << "Trial queue: " << error.what() << "\n";
    return 2;
  }
}
