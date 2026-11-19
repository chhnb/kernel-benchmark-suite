#include "tti_cost_kind.h"
#include "decision_model.h"
#include "domain_competition.h"
#include "ordered_arms.h"
#include "llvm/Analysis/PostDominators.h"
#include "decision_checkpoint.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/Program.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/FormatVariadic.h"
#include <set>
#include <chrono>
#include <cstdlib>
#include <stdexcept>
using namespace llvm;
static void save(const std::string&p,const json::Value&v){std::error_code e;raw_fd_ostream o(p,e);if(e)throw std::runtime_error(e.message());o<<formatv("{0:2}\n",v);}
static json::Value read(const std::string&p){auto b=MemoryBuffer::getFile(p);if(!b)throw std::runtime_error("missing "+p);auto v=json::parse((*b)->getBuffer());if(!v)throw std::runtime_error(toString(v.takeError()));return std::move(*v);}


static void checkQuoteFailure(const std::string &path) {
  auto file=MemoryBuffer::getFile(path);
  if(file && (*file)->getBuffer().contains("tti_quote_"))
    throw std::runtime_error("TTI quote audit failed: "+path);
}
static int run(std::vector<std::string> a,const std::string&out,const std::string&err){for(const auto&p:{out,err})if(auto e=sys::fs::remove(p))throw std::runtime_error("cannot reset child output: "+p+": "+e.message());std::vector<StringRef> refs;for(auto&s:a)refs.push_back(s);std::array<Optional<StringRef>,3> red{{StringRef(""),StringRef(out),StringRef(err)}};return sys::ExecuteAndWait(a[0],refs,None,red,120);}
static sys::ProcessInfo startTrial(const std::vector<std::string> &args,
                                   StringRef output, StringRef error) {
  std::vector<StringRef> refs(args.begin(),args.end());
  std::array<Optional<StringRef>,3> redirects{
      StringRef(""),StringRef(output),StringRef(error)};
  bool failed=false;
  auto process=sys::ExecuteNoWait(refs.front(),refs,None,redirects,0,nullptr,&failed);
  return failed?sys::ProcessInfo():process;
}
static bool eligible(const decision::Arm&a,const decision::Arm&b){return a.kind!=decision::ArmKind::Unsupported&&b.kind!=decision::ArmKind::Unsupported;}
// A clone has the same CFG. Carry the discovered decision over to its blocks.
static decision::Decision cloneDecision(const decision::Decision &source,
                                        const ValueToValueMapTy &values) {
  auto result = source;
  auto remap = [&](BasicBlock *&block) {
    if (block) {
      Value *cloned = values.lookup(block);
      block = cast<BasicBlock>(cloned);
    }
  };
  auto remapPath = [&](std::vector<decision::Edge> &path) {
    for (auto &edge : path) remap(edge.test);
  };
  remap(result.root);
  remap(result.join);
  for (auto *&test : result.tests) remap(test);
  for (auto &arm : result.arms) {
    remap(arm.entry);
    for (auto *&block : arm.blocks) remap(block);
    for (auto *&exit : arm.exitSources) remap(exit);
    remapPath(arm.predicate);
    for (auto &path : arm.alternatives) remapPath(path);
  }
  return result;
}

// Materialize the logical pair on a disposable module. Structural trials
// use block indices in that module, including any new dispatch and join.
static bool prepareArmPairs(Function &f, decision::Decision &d, unsigned left,
                            unsigned conditionBudget, std::string &reason,
                            std::vector<std::array<std::string,3>> &coordinates,
                            bool track) {
  if (track) decision::OrderedArms::stamp(d, left);
  auto *leftEntry=d.arms.at(left).entry;
  auto *rightEntry=d.arms.at(left+1).entry;
  BasicBlock *dispatch=nullptr;
  if(!decision::normalize(f,d,left,reason,&dispatch,conditionBudget))return false;
  for(unsigned index=left;index<=left+1;++index){
    const auto &arm=d.arms[index];
    if(arm.kind!=decision::ArmKind::Linear)continue;
    std::set<BasicBlock*> remaining(arm.blocks.begin(),arm.blocks.end());
    remaining.erase(arm.entry);
    while(!remaining.empty()){
      auto *next=arm.entry->getSingleSuccessor();
      if(!remaining.erase(next)||next->getSinglePredecessor()!=arm.entry||
         !MergeBlockIntoPredecessor(next)){
        reason="linear_fold_failed";
        return false;
      }
    }
  }
  auto *branch=dyn_cast<BranchInst>(dispatch->getTerminator());
  if(!branch||!branch->isConditional()||branch->getSuccessor(0)!=leftEntry||
     branch->getSuccessor(1)!=rightEntry||verifyModule(*f.getParent(),&errs())){
    reason="invalid_prepared_arm_pair";
    return false;
  }
  PostDominatorTree postdom(f);
  DenseMap<BasicBlock*,unsigned> indices;
  unsigned index=0;
  for(auto &block:f)indices[&block]=index++;
  auto id=[&](BasicBlock *block){return "B"+std::to_string(indices.lookup(block));};
  auto anchors=[&](unsigned armIndex){
    const auto &arm=d.arms[armIndex];
    std::vector<BasicBlock*> result;
    if(arm.kind==decision::ArmKind::Linear)result.push_back(arm.entry);
    else for(auto *block:arm.blocks)
      if(postdom.dominates(block,arm.entry))result.push_back(block);
    return result;
  };
  for(auto *l:anchors(left))
    for(auto *r:anchors(left+1))
      coordinates.push_back({id(dispatch),id(l),id(r)});
  if(coordinates.empty()){
    reason="no_must_execute_anchor_pair";
    return false;
  }
  return true;
}

int main(int argc,char**argv){try{
 using Clock=std::chrono::steady_clock;
 const auto started=Clock::now();auto phaseStarted=started;
 std::map<std::string,double> phaseMilliseconds;
 std::map<std::string,int64_t> phaseCalls;
 auto mark=[&](const std::string &phase){auto now=Clock::now();phaseMilliseconds[phase]+=std::chrono::duration<double,std::milli>(now-phaseStarted).count();++phaseCalls[phase];phaseStarted=now;};
 auto timingReport=[&](){json::Object phases;for(const auto &kv:phaseMilliseconds)phases[kv.first]=json::Object{{"milliseconds",kv.second},{"calls",phaseCalls[kv.first]}};return phases;};

 if(argc==2&&StringRef(argv[1])=="--help"){
   outs()<<"usage: decision-greedy INPUT FUNCTION [TOOL_ROOT] NEW_OUTPUT [--b2b-strategy dp1|darm] [--b2r-strategy darm|guarded] [--domain-schedule ordered] [--ir-snapshots full|compact] [--tti-quote-cache off|audit|on]\n";
   outs()<<"Default schedule: ordered for whole-function trials (Auto Greedy v2).\n";
   return 0;
 }
 std::string b2bStrategy="dp1", b2rStrategy="darm", quoteMode="on", snapshotMode;
 while (argc >= 3) {
   StringRef option(argv[argc-2]), value(argv[argc-1]);
   if(option == "--domain-schedule" && value == "ordered") { argc-=2;continue; }
   if (option == "--ir-snapshots" && (value == "full" || value == "compact"))
     snapshotMode = value.str();
   else if (option == "--b2r-strategy" && (value == "darm" || value == "guarded"))
     b2rStrategy = value.str();
   else if (option == "--tti-quote-cache" && (value == "off" || value == "audit" || value == "on"))
     quoteMode = value.str();
   else if (option == "--b2b-strategy" && (value == "dp1" || value == "darm"))
     b2bStrategy = value.str();
   else if (option == "--ir-snapshots" || option == "--domain-schedule" || option == "--b2r-strategy" || option == "--b2b-strategy" || option == "--tti-quote-cache")
     throw std::runtime_error("invalid value for " + option.str());
   else break;
   argc -= 2;
 }
 if(argc!=4&&argc!=5)
   throw std::runtime_error("usage: decision-greedy INPUT FUNCTION [TOOL_ROOT] NEW_OUTPUT [--b2b-strategy dp1|darm] [--b2r-strategy darm|guarded] [--domain-schedule ordered] [--ir-snapshots full|compact] [--tti-quote-cache off|audit|on]");
 if(snapshotMode.empty())snapshotMode="compact";
 const bool implicitRoot=argc==4;
 std::string root;
 const char *ttiMode=std::getenv("FUSION_TTI_MODE");
 const bool strictTTI=ttiMode&&StringRef(ttiMode)=="strict";
 const bool offlineTTI=strictTTI||(ttiMode&&StringRef(ttiMode)=="offline");
 if(implicitRoot){
   const auto executable=sys::fs::getMainExecutable(argv[0],reinterpret_cast<void*>(&run));
   SmallString<256> location(executable);
   for(unsigned i=0;i<3;++i)sys::path::remove_filename(location);
   root=location.str().str();
   if(!sys::fs::can_execute(root+"/build/llvm24-tti/fusion-search-llvm24")||
      !sys::fs::can_execute(root+"/tools/run-llvm24-tti")||
      (!offlineTTI&&!sys::fs::can_execute(root+"/build/llvm24-tti/llvm24-tti")))
     throw std::runtime_error("cannot find built fusion-search and selected TTI provider next to decision-greedy");
 }else root=argv[3];
 std::string current=argv[1],fn=argv[2],out=argv[argc-1];
 if(sys::fs::exists(out))throw std::runtime_error("output exists");
 if(auto e=sys::fs::create_directories(out))throw std::runtime_error(e.message());
 const std::string strictTTIErrors=out+"/offline-tti-errors.log";
 if(strictTTI&&setenv("FUSION_TTI_STRICT_ERRORS",strictTTIErrors.c_str(),1))
   throw std::runtime_error("cannot configure strict offline TTI errors");
 if(offlineTTI&&setenv("FUSION_TTI_WARNINGS",(out+"/offline-tti-warnings.log").c_str(),0))
   throw std::runtime_error("cannot configure offline TTI warnings");
 int64_t structuralJobs=16;
 if (const char *value=std::getenv("DECISION_GREEDY_JOBS")) {
   if (StringRef(value).getAsInteger(10,structuralJobs) || structuralJobs<1 || structuralJobs>64)
     throw std::runtime_error("DECISION_GREEDY_JOBS must be between 1 and 64");
 }
 constexpr unsigned conditionBudget=4;
 LLVMContext ctx;SMDiagnostic error;auto initial=parseIRFile(current,error,ctx);if(!initial||!initial->getFunction(fn)||verifyModule(*initial,&errs()))throw std::runtime_error("invalid input");
 auto writeModule=[&](const Module &module,const std::string &path){std::error_code ec;raw_fd_ostream stream(path,ec);if(ec)throw std::runtime_error(ec.message());module.print(stream,nullptr);};
 auto ds=decision::discover(*initial->getFunction(fn));std::vector<std::string> targets;std::set<BasicBlock*> covered,tagged;json::Array order;
 for(auto &d:ds){bool yes=false;for(unsigned i=0;i+1<d.arms.size();++i)yes|=eligible(d.arms[i],d.arms[i+1]);if(!yes||covered.count(d.root))continue;targets.push_back(d.id);for(auto*b:d.tests)covered.insert(b);for(unsigned i=0;i<d.arms.size();++i){auto&a=d.arms[i];if(!tagged.insert(a.entry).second)continue;std::string label;raw_string_ostream stream(label);a.entry->printAsOperand(stream,false);stream.flush();order.push_back(json::Object{{"entry",label},{"family",d.id},{"index",int64_t(i)}});}}
 save(out+"/order.json",json::Value(std::move(order)));json::Array targetJSON;for(auto&t:targets)targetJSON.push_back(t);save(out+"/targets.json",json::Value(std::move(targetJSON)));
 const std::string structural=root+"/build/llvm24-tti/fusion-search-llvm24";
 const std::string structuralCleanup="darm-cfg-dce-instcombine";
 if(!sys::fs::can_execute(structural))
   throw std::runtime_error("structural candidate engine unavailable: "+structural);
 targets.emplace_back();
 auto cost=[&](const std::string&input,const std::string&prefix){if(run({root+"/tools/run-llvm24-tti",input,fn},prefix+".json",prefix+".stderr"))throw std::runtime_error("TTI worker failed: "+prefix);auto v=read(prefix+".json");auto*o=v.getAsObject();if(!o||o->getInteger("unknown")!=Optional<int64_t>(0)||o->getString("source_revision")!=Optional<StringRef>("6be16f356d3e"))throw std::runtime_error("TTI unknown cost or revision mismatch");if(o->getString("cost_kind")!=Optional<StringRef>(fusion::ttiCostKindName()))throw std::runtime_error("TTI cost kind mismatch");auto n=o->getInteger("cost");if(!n)throw std::runtime_error("missing cost");return *n;};
 int64_t parentCost=cost(current,out+"/initial-tti"),initialCost=parentCost;unsigned commits=0,trials=0;json::Array rounds,stops;
 const char *checkpoint=std::getenv("DECISION_CHECKPOINT_TOOL");
 auto recordResources=[&](const std::string &ir,const std::string &prefix,json::Object &record){
   if(!checkpoint)return;
   try {
     if(run({checkpoint,ir,fn},prefix+".json",prefix+".stderr"))
       throw std::runtime_error("backend checkpoint failed");
     record["backend_resources"]=decision::BackendResources::parse(read(prefix+".json")).report();
   } catch(const std::exception &error) {
     record["backend_resources_error"]=std::string(error.what());
   }
 };
 unsigned reusedSweepSnapshots=0;
 auto report=[&](StringRef status){save(out+"/summary.json",json::Value(json::Object{{"status",status.str()},{"driver_phase_timings",timingReport()},{"elapsed_ms",std::chrono::duration<double,std::milli>(Clock::now()-started).count()},{"domain_schedule","ordered"},{"ir_snapshots",snapshotMode},{"trial_policy","whole-function"},{"scoped_trials",nullptr},{"search","per-decision greedy; best positive adjacent or structural candidate"},{"cfg_cleanup","structural"},{"structural_cleanup",structuralCleanup},{"structural_candidates_enabled",true},{"shared_arm_trials",true},{"cross_level_b2r",false},{"reused_sweep_snapshots",int64_t(reusedSweepSnapshots)},{"pipeline_version","v2"},{"candidate_jobs",structuralJobs},{"candidate_scheduler","continuous-queue"},{"persistent_trial_workers",true},{"condition_budget",conditionBudget},{"phi_fold_threshold",7},{"r2r_enumeration","darm-alignment"},{"b2b_strategy",b2bStrategy},{"b2r_strategy",b2rStrategy},{"tti_quote_cache",quoteMode},{"tti_cost_kind",fusion::ttiCostKindName()},{"initial_cost",initialCost},{"final_cost",parentCost},{"commits",int64_t(commits)},{"trials",int64_t(trials)},{"final_ir",current},{"rounds",json::Value(json::Array(rounds))},{"stops",json::Value(json::Array(stops))}}));};
 report("running");
 std::map<std::string,std::string> b2bRecipes;
 std::set<std::string> attemptedStructural;
 std::set<unsigned> attemptedPreparation; // Decision indices in this parent snapshot.
 std::string catalogParent;
 Optional<json::Value> structuralCatalog;

 mark("initialization");
 bool boundaryTagsAvailable=true;
 for(auto &bb:*initial->getFunction(fn))for(auto &i:bb)
   if(i.getMetadata(decision::OrderedArms::marker))boundaryTagsAvailable=false;
 for(auto &target:targets){decision::OrderedArms table;
 // Only a sweep round without a commit may hand this immutable snapshot
 // to the next round. Candidate attempts remain specific to each round.
 std::unique_ptr<Module> sweepParent;
 std::vector<decision::Decision> sweepCatalog;
 std::optional<fusion::FusionDomains> sweepDomains;
 for(unsigned iteration=0;iteration<100000u;++iteration){
  const bool reuseSweepSnapshot=bool(sweepParent);
  if(reuseSweepSnapshot)++reusedSweepSnapshots;
  auto m=reuseSweepSnapshot ? std::move(sweepParent)
       : parseIRFile(current,error,ctx);
  if(!m)throw std::runtime_error("cannot read parent");
  auto catalog=reuseSweepSnapshot ? std::move(sweepCatalog)
                                  : decision::discover(*m->getFunction(fn));
  unsigned di=0;
  while(di<catalog.size()&&catalog[di].id!=target)++di;
  const bool bound=table.nextDecision.has_value();
  if(bound)di=*table.nextDecision;
  if(!target.empty()&&di>=catalog.size()){stops.push_back(json::Object{{"decision",target},{"reason","decision_completed_or_absorbed"}});break;}
  if(!target.empty()) {
    unsigned identities=0;for(auto &candidate:catalog)identities+=candidate.id==target;
    if(!bound && identities!=1)throw std::runtime_error("ambiguous decision identity: "+target);
  }
  const bool track=boundaryTagsAvailable && !target.empty() && !table.retired;
  if(track){
    if(table.order.empty())table.start(catalog[di].arms.size());
    table.atFunctionEntry=catalog[di].root==&m->getFunction(fn)->getEntryBlock();
    table.arrange(catalog[di]);
  }
  mark("parse_and_discover");
  const std::string scan=out+"/structural-"+std::to_string(rounds.size());
  std::vector<std::string> args{structural,"--ir",current,"--function",fn,
    "--structural","1",
    "--cleanup",structuralCleanup,"--tti-worker",root+"/tools/run-llvm24-tti","--tti-quote-cache",quoteMode};
  if(catalogParent!=current){
    auto catalogArgs=args;
    catalogArgs.insert(catalogArgs.end(),{"--catalog-only","1","--darm-region-candidates","1","--debug-dir",scan,"--out",scan+".ll"});
    if(int rc=run(std::move(catalogArgs),scan+".stdout",scan+".stderr"))
      throw std::runtime_error("structural candidate enumeration failed ("+std::to_string(rc)+"): "+scan+".stderr");
    catalogParent=current;
    structuralCatalog=read(scan+"/catalog.json");
  }
  const auto &candidates=*structuralCatalog->getAsObject()->getArray("candidates");
  mark("enumerate_catalog");
  auto domains=reuseSweepSnapshot ? std::move(*sweepDomains)
                                  : fusion::FusionDomains(*m->getFunction(fn),catalog);
  sweepDomains.reset();
  BasicBlock *activeDomain=nullptr;
  fusion::CompetingDomains competition;
  if(target.empty())
    competition=fusion::competingDomains(*m->getFunction(fn),domains,candidates,attemptedStructural);
  auto activeOwner=[&](BasicBlock *owner) {
    return competition.owners.empty() ? owner==activeDomain : competition.owners.count(owner)!=0;
  };
  if(target.empty()) {
    for(const auto &entry:candidates) {
      const auto &c=*entry.getAsObject();
      if(auto reason=c.getString("preflight_rejection"))if(!reason->empty())continue;
      if(attemptedStructural.count(c.getString("candidate")->str()))continue;
      auto *owner=domains.root(c.getString("split")->str());
      if(!competition.owners.empty() && !activeOwner(owner))continue;
      activeDomain=owner;break;
    }
  }
  // Re-discover maximal preparation targets from the current parent, including
  // decisions that appeared after the initial target list was built.
  std::vector<unsigned> prepare;
  if(!target.empty()){
    activeDomain=domains.root(catalog[di].root);
    prepare.push_back(di);
  }else {
    std::set<BasicBlock*> coveredTests;
    for(unsigned i=0;i<catalog.size();++i){
      auto &decision=catalog[i];
      if(coveredTests.count(decision.root))continue;
      if(std::adjacent_find(decision.arms.begin(),decision.arms.end(),eligible)==decision.arms.end())continue;
      coveredTests.insert(decision.tests.begin(),decision.tests.end());
      if(attemptedPreparation.count(i))continue;
      auto *owner=domains.root(decision.root);
      if(!activeDomain)activeDomain=owner;
      if(activeOwner(owner))prepare.push_back(i);
    }
  }
  decision::Decision emptyDecision;
  auto &d=target.empty()?emptyDecision:catalog[di];
  int64_t bestCost=parentCost;
  std::string best;
  Optional<unsigned> bestPreparedOrdinal;
  json::Array attempts, preparationRejections;
  struct PreparedPair {
    unsigned owner, left;
    std::string input;
    std::vector<std::array<std::string,3>> coordinates;
    bool containsRegion;
  };
  std::vector<PreparedPair> preparedPairs;
  for(unsigned owner:prepare){
    attemptedPreparation.insert(owner);
    auto &d=catalog[owner];
    for (unsigned left=0; left+1<d.arms.size(); ++left) {
      if(!eligible(d.arms[left],d.arms[left+1]))continue;
      ValueToValueMapTy values;
      auto prepared=CloneModule(*m, values);
      auto clonedDecision=cloneDecision(d, values);
      std::string reason;
      std::vector<std::array<std::string,3>> coordinates;
      if(prepareArmPairs(*prepared->getFunction(fn),clonedDecision,left,conditionBudget,reason,coordinates,track)){
        const std::string decisionSuffix="-"+std::to_string(owner);
        const auto input=out+"/prepared-"+std::to_string(rounds.size())+decisionSuffix+"-"+std::to_string(left)+".ll";
        std::error_code ec;
        raw_fd_ostream stream(input,ec);
        if(ec)throw std::runtime_error(ec.message());
        prepared->print(stream,nullptr);
        stream.close();
        const bool containsRegion=d.arms[left].kind==decision::ArmKind::SESE||
                                  d.arms[left+1].kind==decision::ArmKind::SESE;
        preparedPairs.push_back({owner,left,input,std::move(coordinates),containsRegion});
        continue;
      }
      preparationRejections.push_back(json::Object{
        {"left",d.arms[left].id},{"right",d.arms[left+1].id},
        {"stage","preparation_rejected"},{"reason",std::move(reason)}});
    }
  }
  {
    mark("prepare_arms");
    json::Array normalizedCandidates;
    for(const auto &pair:preparedPairs){
      const auto &d=catalog[pair.owner];
      std::set<std::array<std::string,3>> coordinates(pair.coordinates.begin(),pair.coordinates.end());
      if(pair.containsRegion){
        const auto scan=pair.input+".catalog";
        auto catalogArgs=args;
        catalogArgs[2]=pair.input;
        catalogArgs.insert(catalogArgs.end(),{"--catalog-only","1","--darm-region-candidates","1","--debug-dir",scan,"--out",scan+".ll"});
        if(int rc=run(std::move(catalogArgs),scan+".stdout",scan+".stderr"))
          throw std::runtime_error("prepared candidate enumeration failed ("+std::to_string(rc)+"): "+scan+".stderr");
        auto inventory=read(scan+"/catalog.json");
        for(const auto &entry:*inventory.getAsObject()->getArray("candidates")){
          const auto &candidate=*entry.getAsObject();
          const auto split=*candidate.getString("split");
          const auto left=*candidate.getString("left");
          const auto right=*candidate.getString("right");
          if(auto reason=candidate.getString("preflight_rejection"))
            if(!reason->empty())continue;
          if(split==pair.coordinates.front()[0]&&
             (left.startswith("R")||right.startswith("R")))
            coordinates.insert({split.str(),left.str(),right.str()});
        }
      }
      for(const auto &ids:coordinates)
        normalizedCandidates.push_back(json::Object{
          {"candidate",fn+":"+ids[0]+":"+ids[1]+":"+ids[2]},
          {"split",ids[0]},{"left",ids[1]},{"right",ids[2]},
          {"prepared_input",pair.input},{"prepared_decision",d.id},{"prepared_ordinal",int64_t(pair.left)},{"logical_left",d.arms[pair.left].id},
          {"logical_right",d.arms[pair.left+1].id}});
    }

    mark("enumerate_prepared_catalog");
    std::string decisionSplit;
    if(d.root) {
      unsigned index=0;
      for(auto &block:*m->getFunction(fn)) {
        if(&block==d.root)break;
        ++index;
      }
      decisionSplit="B"+std::to_string(index);
    }
    struct StructuralTrial {
      std::vector<std::string> args;
      std::string directory;
      json::Object attempt;
      int exitCode = -1;
      Optional<unsigned> preparedOrdinal;
    };
    std::vector<StructuralTrial> structuralTrials;
    std::vector<const json::Object *> roundCandidates;
    for (const auto &entry : candidates) {
      const auto &candidate = *entry.getAsObject();
      const auto split = candidate.getString("split")->str();
      if (!decisionSplit.empty() && split != decisionSplit) continue;
      if (target.empty() &&
          (!activeDomain || !activeOwner(domains.root(split)))) continue;
      roundCandidates.push_back(&candidate);
    }
    for (const auto &entry : normalizedCandidates)
      roundCandidates.push_back(entry.getAsObject());
    for (const auto *entry : roundCandidates) {
      const auto &candidate = *entry;
      const auto preparedInput = candidate.getString("prepared_input");
      const auto candidateKey=candidate.getString("candidate")->str();
      if(!preparedInput&&!attemptedStructural.insert(candidateKey).second)continue;
      if(auto reason=candidate.getString("preflight_rejection"))if(!reason->empty())continue;
      if(trials>=100000)throw std::runtime_error("trial budget exceeded");
      const std::string dir=out+"/trial-"+std::to_string(trials++);
      if(auto ec=sys::fs::create_directory(dir))throw std::runtime_error(ec.message());
      auto trialArgs=args;
      if(preparedInput)trialArgs[2]=preparedInput->str();
      for(auto key:{"split","left","right"}) {
        trialArgs.push_back(std::string("--")+key);
        trialArgs.push_back(candidate.getString(key)->str());
      }
      // Keep the exact invocation and the arguments needed for trial replay.
      trialArgs.insert(trialArgs.end(), {"--b2b-strategy", b2bStrategy, "--b2r-strategy", b2rStrategy});
      // IDs locate a prior recipe; current planner facts certify its reuse.
      if (b2bStrategy=="dp1" && !preparedInput) {
        auto recipe=b2bRecipes.find(candidateKey);
        if(recipe!=b2bRecipes.end())
          trialArgs.insert(trialArgs.end(),{"--b2b-recipe-cache",recipe->second});
      }
      json::Array replayArgs;
      for(const auto &argument:trialArgs)replayArgs.push_back(argument);
      // Replay the saved request with the standalone tool's full diagnostics.
      if (snapshotMode == "compact")
        trialArgs.insert(trialArgs.end(),{"--ir-snapshots","compact"});
      trialArgs.insert(trialArgs.end(),{"--debug-dir",dir+"/structural","--out",dir+"/fused.ll"});
      json::Array invocation;
      for(const auto &argument:trialArgs)invocation.push_back(argument);
      json::Object request{{"decision",target},{"parent",current},
        {"candidate",candidateKey},{"argv",std::move(invocation)},
        {"replay_args",std::move(replayArgs)}};
      if(preparedInput){
        request["logical_left"]=candidate.getString("logical_left")->str();
        request["logical_right"]=candidate.getString("logical_right")->str();
      }
      save(dir+"/request.json",std::move(request));
      json::Object attempt{{"directory",dir},{"kind","structural"},
        {"candidate",candidateKey},{"eligible",false},{"stage","enumerated"}};
      if(preparedInput){
        attempt["prepared_input"]=preparedInput->str();
        attempt["prepared_decision"]=candidate.getString("prepared_decision")->str();
        attempt["prepared_ordinal"]=*candidate.getInteger("prepared_ordinal");
        attempt["left"]=candidate.getString("logical_left")->str();
        attempt["right"]=candidate.getString("logical_right")->str();
      }
      structuralTrials.push_back({std::move(trialArgs),dir,std::move(attempt),-1});
      if (preparedInput)
        structuralTrials.back().preparedOrdinal = *candidate.getInteger("prepared_ordinal");
    }
    const size_t externalPending=structuralTrials.size();

    // All worker processes pull from the same immutable manifest. An atomic
    // per-request claim makes completion immediately release a slot, without
    // a batch barrier or a static partition. TTI and parent IR caches are local
    // to each worker; LLVM IR is never shared across threads or processes.
    mark("domain_queue_and_requests");
    if (externalPending) {
      const auto base = out + "/trial-queue-" + std::to_string(rounds.size());
      json::Array requests;
      for (const auto &trial : structuralTrials) {
        json::Array argv;
        for (const auto &arg : trial.args) argv.push_back(arg);
        requests.push_back(json::Object{{"argv", std::move(argv)},
            {"status", trial.directory + "/queue-exit.json"},
            {"stdout", trial.directory + "/stdout"},
            {"stderr", trial.directory + "/stderr"}});
      }
      save(base + ".json", json::Value(std::move(requests)));
      std::vector<sys::ProcessInfo> running;
      for (size_t slot = 0; slot < std::min(size_t(structuralJobs), externalPending); ++slot) {
        const auto log = base + "-" + std::to_string(slot);
        running.push_back(startTrial({structural, "--trial-queue", base + ".json"},
                                     log + ".stdout", log + ".stderr"));
      }
      // Each request has its own timeout inside the worker. Waiting for one
      // process here does not block other workers from taking more requests.
      for (const auto &process : running)
        if (process.Pid) sys::Wait(process, 0, true);
      for (auto &trial : structuralTrials) {
        checkQuoteFailure(trial.directory + "/stderr");
        const auto status = trial.directory + "/queue-exit.json";
        if (sys::fs::exists(status)) {
          auto file = MemoryBuffer::getFile(status);
          auto result = file ? json::parse((*file)->getBuffer()) : json::parse("");
          const auto *record = result ? result->getAsObject() : nullptr;
          const auto code = record ? record->getInteger("exit_code") : None;
          if (!result) consumeError(result.takeError());
          if (code && (*code == 0 || *code == 4) &&
              sys::fs::exists(trial.directory + "/structural/trial-0/trial.json") &&
              (*code == 4 || sys::fs::exists(trial.directory + "/fused.ll"))) {
            trial.exitCode = *code;
            continue;
          }
        }
        // A crashing/timed-out worker may leave a claimed request unfinished.
        // Retry only that request in an isolated process, preserving completed
        // results. This exceptional recovery path retains the 120s timeout.
        if (auto ec = sys::fs::remove_directories(trial.directory + "/structural", false))
          if (ec != std::errc::no_such_file_or_directory) throw std::runtime_error(ec.message());
        if (auto ec = sys::fs::remove(trial.directory + "/fused.ll"))
          throw std::runtime_error(ec.message());
        trial.attempt["queue_recovery"] = true;
        trial.exitCode = run(trial.args, trial.directory + "/stdout", trial.directory + "/stderr");
        checkQuoteFailure(trial.directory + "/stderr");
      }
    }
    mark("trial_workers_wall");
    // Candidate order breaks score ties, independently of process completion.
    for (auto &trial : structuralTrials) {
      const auto &dir = trial.directory;
      auto &attempt = trial.attempt;
      const int rc = trial.exitCode;
      attempt["exit_code"] = rc;
      const std::string details=dir+"/structural/trial-0";
      if(!sys::fs::exists(details+"/trial.json")) {
        attempt["reason"]="trial_process_failed";
        attempt["stage"]="trial_failed";
      } else {
        auto result=read(details+"/trial.json");
        const auto &actual=*result.getAsObject();
        if(actual.getString("candidate")!=attempt.getString("candidate"))
          throw std::runtime_error("structural trial identity mismatch: "+dir);
        const auto *score=actual.getObject("score_result");
        if(rc) {
          attempt["reason"]=actual.getString("reason")->str();
          attempt["stage"]=actual.getBoolean("rewrite_started")==Optional<bool>(true)?"rewrite_failed":"legality_rejected";
        } else if(score->getString("status")!=Optional<StringRef>("scored")) {
          attempt["reason"]=score->getString("reason")->str();
          attempt["stage"]="score_rejected";
        }
        else {
          const auto &metrics=*score->getObject("metrics");
          const auto after=metrics.getNumber("work_after");
          const auto before=metrics.getNumber("work_before");
          if(!after||!before)
            throw std::runtime_error("structural control cost mismatch: "+dir);
          const int64_t trialCost=*after;
          attempt["stage"]="scored";
          attempt["cost"]=trialCost;
          attempt["control_cost"]=*before;
          attempt["gain"]=*before-trialCost;
          if(sys::fs::exists(details+"/pressure.json"))
            attempt["ir_pressure"]=read(details+"/pressure.json");
          for(auto key:{"uniform_gain_false","uniform_gain_true"})
            if(auto value=metrics.getNumber(key))attempt[key]=*value;
          const auto rejection=score->getString("profitability_rejection");
          if(rejection&&!rejection->empty())
            attempt["reason"]=rejection->str();
          else if(trialCost<*before&&trialCost<parentCost){
            attempt["eligible"]=true;

          }else attempt["reason"]="nonpositive_gain";
        }
      }
      const auto recipePath=dir+"/structural/b2b-recipe.json";
      if (rc==0 && sys::fs::exists(recipePath) && !attempt.getString("prepared_input"))
        b2bRecipes[attempt.getString("candidate")->str()]=recipePath;
      if(sys::fs::exists(dir+"/structural/b2b-recipe-cache.json"))
        attempt["plan_cache"]=read(dir+"/structural/b2b-recipe-cache.json");
      const bool canCommit = attempt.getBoolean("eligible") == Optional<bool>(true);
      const auto cost = attempt.getInteger("cost");
      if (canCommit && cost && *cost < bestCost) {
        // Results are visited in enumeration order, so the first tie wins.
        bestCost = *cost;
        best = dir;
        bestPreparedOrdinal = trial.preparedOrdinal;
      }
      attempts.push_back(std::move(attempt));
    }
  }
  mark("read_scores_and_select");
  json::Object record{{"decision",target},{"iteration",int64_t(iteration)},{"parent",current},{"parent_cost",parentCost},{"attempts",std::move(attempts)},{"preparation_rejections",std::move(preparationRejections)},{"selected",best}};
  {
    if(!competition.owners.empty()) {
      record["competition_seed"]=competition.seed;
      record["competition_common_work"]=int64_t(competition.commonWork);
      record["competition_domains"]=int64_t(competition.owners.size());
    }
    json::Array preparedDecisions;
    for(unsigned index:prepare)preparedDecisions.push_back(catalog[index].id);
    record["prepared_decisions"]=std::move(preparedDecisions);
    if(activeDomain){
      std::string label;
      raw_string_ostream name(label);
      activeDomain->printAsOperand(name,false);
      record["active_domain"]=name.str();
    }
  }
  if(best.empty() && target.empty() && (!prepare.empty() || !record.getArray("attempts")->empty())) {
    record["domain_exhausted"]=true;
    rounds.push_back(std::move(record));report("running");mark("record_and_commit");
    sweepParent=std::move(m);
    sweepCatalog=std::move(catalog);
    sweepDomains=std::move(domains);
    continue;
  }
  if(best.empty()){rounds.push_back(std::move(record));stops.push_back(json::Object{{"decision",target},{"reason","no_positive_legal_candidate"}});report("running");mark("record_and_commit");break;}
  if(track){
    record["ordered_arms"]=table.describe(catalog[di]);
    if(bestPreparedOrdinal){
      auto cleaned=parseIRFile(best+"/fused.ll",error,ctx);
      if(!cleaned)throw std::runtime_error("cannot bind ordered winner");
      record["ordered_left"]=int64_t(*bestPreparedOrdinal);
      record["ordered_update"]=table.advance(*cleaned->getFunction(fn),*bestPreparedOrdinal);
      if(verifyModule(*cleaned,&errs()))throw std::runtime_error("invalid ordered winner");
      writeModule(*cleaned,best+"/fused.ll");
    }else{
      table.retired=true;table.nextDecision.reset();
      record["ordered_update"]="structural_winner_rediscover";
    }
  }
  recordResources(best+"/fused.ll",best+"/resources",record);
  record["selected_cost"]=bestCost;record["score"]=double(parentCost-bestCost)/std::max<int64_t>(parentCost,1);rounds.push_back(std::move(record));parentCost=bestCost;current=best+"/fused.ll";attemptedStructural.clear();attemptedPreparation.clear();++commits;report("running");outs()<<"commit="<<commits<<" cost="<<parentCost<<" decision="<<target<<"\n";outs().flush();mark("record_and_commit");
  if(iteration==99999u)throw std::runtime_error("round budget exceeded");
 }}
 if(strictTTI&&sys::fs::exists(strictTTIErrors)){
   report("offline_tti_error");
   throw std::runtime_error("offline TTI replay incomplete; see "+strictTTIErrors);
 }
 if(auto e=sys::fs::copy_file(current,out+"/final.ll"))throw std::runtime_error(e.message());current=out+"/final.ll";report("completed");return 0;
}catch(const std::exception&e){errs()<<e.what()<<"\n";return 1;}}
