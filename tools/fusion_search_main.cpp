#include "fusion_search.h"
#include "postopt_scorer.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
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
 json::Object o{{"status",scored?"scored":"not_evaluable"},{"reason",s.reason},{"contributions",std::move(cs)},
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
  void initial(const Module&m)override { writeIR(m,dir+"/state-0.ll"); }
  void round(const RoundContext&r)override {
    auto stem=dir+"/round-"+std::to_string(r.parentVersion);
    writeIR(*r.control,stem+"-control.ll");
    jsonFile(stem+".json",json::Object{{"schema","incremental-score-round-v1"},{"hash_algorithm","llvm-sha1-printed-module"},{"parent_version",int64_t(r.parentVersion)},{"function",r.function},{"parent_hash",r.parentHash},{"control_hash",r.controlHash},{"llvm_version",r.llvmVersion},{"target_triple",r.targetTriple},{"data_layout",r.dataLayout},{"target_attributes",r.targetAttributes},{"cleanup",r.cleanup},{"feature_schema",r.featureSchema},{"weight_version",r.weightVersion},{"normalization_scale",r.normalizationScale},{"parent",stats(r.parentFeatures)},{"control",stats(r.controlFeatures)},{"control_ms",r.controlMs},{"control_cleanup_iterations",int64_t(r.controlCleanupIterations)}});
  }
  void trial(const Trial&t,const RoundContext&r,const ScoreResult&score,bool eligible)override {
    auto path=dir+"/trial-"+std::to_string(n++);auto ec=sys::fs::create_directory(path);if(ec)throw std::runtime_error(ec.message());
    if(t.raw)writeIR(*t.raw,path+"/after-raw.ll");if(t.normalized)writeIR(*t.normalized,path+"/after.ll");
    json::Array Origins;for(auto &P:t.blockProvenance)Origins.push_back(json::Object{
      {"left_source_id",P.leftID},{"right_source_id",P.rightID},
      {"left_alignment_label",P.leftLabel},{"right_alignment_label",P.rightLabel},
      {"raw_block",P.rawBlock},{"cleaned_block",P.cleanedBlock},
      {"coverage",P.cleanedBlock.empty()?"block_deleted_or_untracked":"surviving_block_identity_not_instruction_or_execution_mapping"}});
    jsonFile(path+"/block-provenance.json",json::Object{{"schema","melding-block-provenance-v1"},
      {"candidate",t.candidate.key()},{"parent_hash",r.parentHash},
      {"cleaned_hash",t.normalized?moduleHash(*t.normalized):""},{"blocks",std::move(Origins)}});
    jsonFile(path+"/trial.json",json::Object{{"schema","incremental-score-trial-v1"},{"candidate",t.candidate.key()},{"version",int64_t(t.candidate.version)},{"parent_hash",r.parentHash},{"control_hash",r.controlHash},{"round_context","../round-"+std::to_string(r.parentVersion)+".json"},{"valid",t.valid},{"decision",!t.valid?"reject":score.status!=ScoreStatus::Scored?"unsupported":eligible?"accept":"reject"},{"reason",t.reason},{"score_result",scoreJson(score)},{"eligible",eligible},{"cleanup_iterations",int64_t(t.cleanupIterations)},{"alignment_order","function_order_v1"},{"original_darm_similarity",t.originalSimilarity},{"original_darm_profitable",t.originalProfitable},{"replication_required",t.replication},{"orientation_swapped",t.swapped},{"left",bound(t.left)},{"right",bound(t.right)},{"after_raw",stats(t.afterRaw)},{"after",stats(t.after)},{"cleaned_hash",t.normalized?moduleHash(*t.normalized):""},{"parent_ir","../state-"+std::to_string(t.candidate.version)+".ll"},{"timings_ms",json::Object{{"merge",t.mergeMs},{"normalization",t.normalizeMs},{"features",t.featuresMs},{"trial_total",t.totalMs},{"score_with_analysis",t.scoreMs}}},{"semantic_validation","not_run"}});
  }
  void commit(unsigned version,const Candidate&c,const ScoreResult&score,const Module&m)override {
    writeIR(m,dir+"/state-"+std::to_string(version)+".ll");
    jsonFile(dir+"/commit-"+std::to_string(version)+".json",json::Object{{"candidate",c.key()},{"parent_version",int64_t(c.version)},{"version",int64_t(version)},{"score_result",scoreJson(score)},{"committed_hash",moduleHash(m)}});
  }
};
int main(int argc,char**argv) {
  sys::PrintStackTraceOnErrorSignal(argv[0]);
  try {
    std::string input,function,output,debug,split,left,right,replayParentHash,profileBundle,policy="legacy";Options options;PostOptConfig config;bool controlOnly=false,catalogOnly=false;
    for(int i=1;i<argc;++i){std::string k=argv[i];
      if(k=="--help"){outs()<<"fusion-search --ir FILE --function NAME --out FILE [--control-only 0|1] [--catalog-only 0|1 (requires debug-dir)] [--replay-parent-hash SHA1 (explicit snapshot pair only)] [--scorer legacy|v1|v2|v5] [--profile-bundle FILE (experimental v5 only)] [--work-absolute 0] [--work-relative 0] [--pressure-weight 0] [--dependency-features 0|1] [--static-alloca-cost POSITIVE_INT (disabled by default)] [--rounds 8] [--trials 256] [--threshold 0] [--opt-level 3] [--debug-dir DIR] [--require-parent-gain 1] [--cleanup postopt-fp|darm-cfg-scalar-fp|darm-cfg-earlycse|darm-cfg|o3]\nExplicit pair: add --split B# --left B#/R# --right B#/R#. IDs refer to the input state (O3-normalized only in o3 mode). Default cleanup: darm-cfg-earlycse. Final codegen O3 is separate.\n";return 0;}
      if(i+1==argc)throw std::runtime_error("missing option value");std::string v=argv[++i];
      if(k=="--control-only"){if(v!="0"&&v!="1")throw std::runtime_error("control-only must be 0 or 1");controlOnly=v=="1";}
      else if(k=="--catalog-only"){if(v!="0"&&v!="1")throw std::runtime_error("catalog-only must be 0 or 1");catalogOnly=v=="1";}
      else if(k=="--scorer"){if(v!="legacy"&&v!="v1"&&v!="v2"&&v!="v5")throw std::runtime_error("scorer must be legacy, v1, v2 or experimental v5");policy=v;}
      else if(k=="--work-absolute"||k=="--work-relative"||k=="--pressure-weight"){size_t pos=0;double n=std::stod(v,&pos);if(pos!=v.size()||!std::isfinite(n)||n<0)throw std::runtime_error("invalid postopt parameter");if(k=="--work-absolute")config.absoluteThreshold=n;else if(k=="--work-relative")config.relativeThreshold=n;else config.pressureWeight=n;}
      else if(k=="--dependency-features"){if(v!="0"&&v!="1")throw std::runtime_error("dependency-features must be 0 or 1");config.dependencyFeatures=v=="1";}
      else if(k=="--static-alloca-cost"){size_t pos=0;int n=std::stoi(v,&pos);if(pos!=v.size()||n<=0)throw std::runtime_error("static alloca cost must be a positive integer");config.staticAllocaCost=n;}
      else if(k=="--profile-bundle")profileBundle=v;
      else if(k=="--replay-parent-hash")replayParentHash=v;
      else if(k=="--ir")input=v;else if(k=="--function")function=v;else if(k=="--out")output=v;
      else if(k=="--cleanup"){if(v=="postopt-fp")options.cleanupMode=CleanupMode::PostOptFixedPoint;else if(v=="darm-cfg-scalar-fp")options.cleanupMode=CleanupMode::DarmCFGScalarFixedPoint;else if(v=="darm-cfg-earlycse")options.cleanupMode=CleanupMode::DarmCFGEarlyCSE;else if(v=="darm-cfg")options.cleanupMode=CleanupMode::DarmCFG;else if(v=="o3")options.cleanupMode=CleanupMode::O3;else throw std::runtime_error("cleanup must be postopt-fp, darm-cfg-scalar-fp, darm-cfg-earlycse, darm-cfg or o3");}
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
    LLVMContext context;SMDiagnostic error;auto buffer=MemoryBuffer::getFile(input);if(!buffer)throw std::runtime_error("cannot read input IR");auto module=parseIR(buffer.get()->getMemBufferRef(),error,context);if(!module){error.print(argv[0],errs());return 2;}
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
    if(verifyModule(*module,&errs()))return 2;
    auto*f=module->getFunction(function);if(!f||f->isDeclaration())throw std::runtime_error("function missing");
    std::unique_ptr<DebugObserver> observer;if(!debug.empty())observer=std::make_unique<DebugObserver>(debug);
    if(catalogOnly){
      if(pair||controlOnly||!observer)throw std::runtime_error("catalog-only requires debug-dir and excludes pair/control-only");
      if(options.cleanupMode==CleanupMode::O3)normalize(*module,options.optLevel);
      if(verifyModule(*module,&errs()))return 2;
      observer->initial(*module);
      const char*cleanupName=options.cleanupMode==CleanupMode::PostOptFixedPoint?"postopt-fp":options.cleanupMode==CleanupMode::O3?"o3":options.cleanupMode==CleanupMode::DarmCFGEarlyCSE?"darm-cfg-earlycse":options.cleanupMode==CleanupMode::DarmCFGScalarFixedPoint?"darm-cfg-scalar-fp":"darm-cfg";
      auto candidates=enumerate(*module->getFunction(function),0);json::Array entries;
      for(const auto&c:candidates)entries.push_back(json::Object{{"candidate",c.key()},{"function",c.function},{"split",c.split},{"left",c.left},{"right",c.right}});
      jsonFile(debug+"/catalog.json",json::Object{{"schema","postopt-candidate-catalog-v1"},{"source_ir",input},{"function",function},
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
    if(pair){if(options.cleanupMode==CleanupMode::O3&&replayParentHash.empty())normalize(*module,options.optLevel);if(verifyModule(*module,&errs()))return 2;
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
    StaticCostScorer legacyScorer;
    if(policy=="v1")config.pressureWeight=0;
    if(observer)jsonFile(debug+"/run.json",json::Object{
      {"schema","postopt-scoring-run-v1"},{"mode",pair?"explicit_pair":"greedy"},
      {"policy",policy},{"profile_bundle",profileBundle},{"profile_bundle_sha1",toHex(SHA1::hash(ArrayRef<uint8_t>(reinterpret_cast<const uint8_t*>(config.profileBundleText.data()),config.profileBundleText.size())),true)},{"function",function},{"initial_parent_hash",moduleHash(*module)},{"replay_parent_hash",replayParentHash},
      {"work_absolute",config.absoluteThreshold},{"work_relative",config.relativeThreshold},
      {"dependency_features",config.dependencyFeatures},{"pressure_weight",config.pressureWeight},{"static_alloca_cost",int64_t(config.staticAllocaCost)},{"threshold",options.threshold},
      {"require_parent_gain",options.requireParentGain},{"opt_level",int64_t(options.optLevel)},
      {"semantic_validation","not_run"}});
    PostOptScorer postScorer(config);
    const Scorer&scorer=policy=="legacy"?static_cast<const Scorer&>(legacyScorer):static_cast<const Scorer&>(postScorer);
    if(pair){Candidate c{function,split,left,right,0};const auto round=makeRound(*module,function,0,options.optLevel,options.cleanupMode);if(observer)observer->round(round);
      auto t=tryPair(*module,c,0,options.optLevel,options.cleanupMode);auto score=evaluateTrial(*module,t,round,scorer);
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
