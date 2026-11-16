#include "decision_model.h"
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
#include <cstdlib>
#include <stdexcept>
using namespace llvm;
static void save(const std::string&p,const json::Value&v){std::error_code e;raw_fd_ostream o(p,e);if(e)throw std::runtime_error(e.message());o<<formatv("{0:2}\n",v);}
static json::Value read(const std::string&p){auto b=MemoryBuffer::getFile(p);if(!b)throw std::runtime_error("missing "+p);auto v=json::parse((*b)->getBuffer());if(!v)throw std::runtime_error(toString(v.takeError()));return std::move(*v);}
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
// Materialize the logical pair on a disposable module. Structural trials
// use block indices in that module, including any new dispatch and join.
static bool prepareArmPairs(Module &module, StringRef function, unsigned decisionIndex,
                              unsigned left, unsigned conditionBudget, std::string &reason,
                              std::vector<std::array<std::string,3>> &coordinates) {
  auto &f=*module.getFunction(function);
  auto decisions=decision::discover(f);
  auto &d=decisions.at(decisionIndex);
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
     branch->getSuccessor(1)!=rightEntry||verifyModule(module,&errs())){
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
 if(argc==2&&StringRef(argv[1])=="--help"){
   outs()<<"usage: decision-greedy INPUT FUNCTION [TOOL_ROOT] NEW_OUTPUT\n";
   return 0;
 }
 std::string b2rStrategy="darm", b2bStrategy;
 while (argc >= 3) {
   StringRef option(argv[argc-2]), value(argv[argc-1]);
   if (option == "--b2r-strategy" && (value == "darm" || value == "guarded"))
     b2rStrategy = value.str();
   else if (option == "--b2b-strategy" && (value == "dp1" || value == "dp2" || value == "dp3"))
     b2bStrategy = value.str();
   else if (option == "--b2r-strategy" || option == "--b2b-strategy")
     throw std::runtime_error("invalid value for " + option.str());
   else break;
   argc -= 2;
 }
 if(argc!=4&&argc!=5)
   throw std::runtime_error("usage: decision-greedy INPUT FUNCTION [TOOL_ROOT] NEW_OUTPUT [--b2r-strategy darm|guarded] [--b2b-strategy dp1|dp2|dp3]");
 const bool implicitRoot=argc==4;
 std::string root;
 if(implicitRoot){
   const auto executable=sys::fs::getMainExecutable(argv[0],reinterpret_cast<void*>(&run));
   SmallString<256> location(executable);
   for(unsigned i=0;i<3;++i)sys::path::remove_filename(location);
   root=location.str().str();
   if(!sys::fs::can_execute(root+"/build/llvm24-tti/fusion-search-llvm24")||
      !sys::fs::can_execute(root+"/tools/run-llvm24-tti")||
      !sys::fs::can_execute(root+"/build/llvm24-tti/llvm24-tti"))
     throw std::runtime_error("cannot find built fusion-search and LLVM24 TTI worker next to decision-greedy");
 }else root=argv[3];
 std::string current=argv[1],fn=argv[2],out=argv[argc-1];
 if(sys::fs::exists(out))throw std::runtime_error("output exists");
 if(auto e=sys::fs::create_directories(out))throw std::runtime_error(e.message());
 // The three-argument entry uses the shared pipeline independently of
 // legacy experiment settings inherited from the caller.
 auto experimentSetting=[&](const char *name)->const char * {
   return implicitRoot?nullptr:std::getenv(name);
 };
 auto limit=[&](const char *name,int64_t fallback){const char*v=experimentSetting(name);if(!v)return fallback;char*end=nullptr;auto n=std::strtoll(v,&end,10);if(!*v||*end||n<0||n>1000000)throw std::runtime_error(std::string("invalid ")+name);return int64_t(n);};
 const auto crossLevelB2R=limit("DECISION_CROSS_LEVEL_B2R",0);
 if(crossLevelB2R>1)throw std::runtime_error("DECISION_CROSS_LEVEL_B2R must be 0 or 1");
 const auto jobs=limit("DECISION_GREEDY_JOBS",1);
 if(jobs<1||jobs>64)throw std::runtime_error("DECISION_GREEDY_JOBS must be between 1 and 64");
 const auto structuralJobs=experimentSetting("DECISION_GREEDY_JOBS")?jobs:8;
 if(experimentSetting("DECISION_CFG_CLEANUP")&&experimentSetting("DECISION_DISABLE_SIMPLIFYCFG"))throw std::runtime_error("DECISION_CFG_CLEANUP conflicts with legacy DECISION_DISABLE_SIMPLIFYCFG");
 std::string cleanup=experimentSetting("DECISION_CFG_CLEANUP")?experimentSetting("DECISION_CFG_CLEANUP"):"structural";
 if(cleanup!="full"&&cleanup!="structural")throw std::runtime_error("invalid DECISION_CFG_CLEANUP");
 LLVMContext ctx;SMDiagnostic error;auto initial=parseIRFile(current,error,ctx);if(!initial||!initial->getFunction(fn)||verifyModule(*initial,&errs()))throw std::runtime_error("invalid input");
 auto ds=decision::discover(*initial->getFunction(fn));std::vector<std::string> targets;std::set<BasicBlock*> covered,tagged;json::Array order;
 for(auto &d:ds){bool yes=false;for(unsigned i=0;i+1<d.arms.size();++i)yes|=eligible(d.arms[i],d.arms[i+1]);if(!yes||covered.count(d.root))continue;targets.push_back(d.id);for(auto*b:d.tests)covered.insert(b);for(unsigned i=0;i<d.arms.size();++i){auto&a=d.arms[i];if(!tagged.insert(a.entry).second)continue;std::string label;raw_string_ostream stream(label);a.entry->printAsOperand(stream,false);stream.flush();order.push_back(json::Object{{"entry",label},{"family",d.id},{"index",int64_t(i)}});}}
 save(out+"/order.json",json::Value(std::move(order)));json::Array targetJSON;for(auto&t:targets)targetJSON.push_back(t);save(out+"/targets.json",json::Value(std::move(targetJSON)));
 const std::string structural=root+"/build/llvm24-tti/fusion-search-llvm24";
 const char *structuralCleanupEnv=experimentSetting("DECISION_STRUCTURAL_CLEANUP");
 const std::string structuralCleanup=structuralCleanupEnv?structuralCleanupEnv:"darm-cfg-dce";
 if(structuralCleanup!="darm-cfg-dce"&&structuralCleanup!="scoped-cfg")
   throw std::runtime_error("DECISION_STRUCTURAL_CLEANUP must be darm-cfg-dce or scoped-cfg");
 const bool structuralAvailable=sys::fs::can_execute(structural);
 // Keep explicit legacy trial settings effective until their implementation
 // is available in the shared structural trial.
 const char *speculation=experimentSetting("DECISION_SPECULATION");
 const bool useSharedTrial=structuralAvailable&&cleanup=="structural"&&
   (!speculation||StringRef(speculation)=="none"||StringRef(speculation)=="cost")&&
   !experimentSetting("DECISION_DISABLE_SIMPLIFYCFG")&&
   !experimentSetting("DECISION_GAP_SEARCH")&&!experimentSetting("DECISION_GAP_STATE")&&
   !experimentSetting("DECISION_COALESCE_GAPS");
 const auto conditionBudget=useSharedTrial?limit("DECISION_CONDITION_BUDGET",4):4;
 if(conditionBudget>100000)throw std::runtime_error("invalid DECISION_CONDITION_BUDGET");
 if(!structuralAvailable&&experimentSetting("DECISION_REQUIRE_STRUCTURAL"))
   throw std::runtime_error("structural candidate engine unavailable; build with tools/build-decision-greedy --with-structural");
 if(structuralAvailable)targets.emplace_back();
 else errs()<<"structural candidate engine unavailable: "<<structural<<"\n";
 auto cost=[&](const std::string&input,const std::string&prefix){if(run({root+"/tools/run-llvm24-tti",input,fn},prefix+".json",prefix+".stderr"))throw std::runtime_error("TTI worker failed: "+prefix);auto v=read(prefix+".json");auto*o=v.getAsObject();if(!o||o->getInteger("unknown")!=Optional<int64_t>(0)||o->getString("source_revision")!=Optional<StringRef>("6be16f356d3e"))throw std::runtime_error("TTI unknown cost or revision mismatch");auto n=o->getInteger("cost");if(!n)throw std::runtime_error("missing cost");return *n;};
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
 auto report=[&](StringRef status){save(out+"/summary.json",json::Value(json::Object{{"status",status.str()},{"search",structuralAvailable?"per-decision greedy; best positive adjacent or structural candidate":"per-decision greedy; best positive adjacent candidate; initial decision order"},{"cfg_cleanup",cleanup},{"structural_cleanup",structuralCleanup},{"structural_candidates_enabled",structuralAvailable},{"shared_arm_trials",useSharedTrial},{"cross_level_b2r",bool(crossLevelB2R)},{"b2b_strategy",b2bStrategy.empty()?"dp1":b2bStrategy},{"backend_resource_gate_enabled",false},{"uniform_loss_guard_enabled",false},{"max_uniform_loss",-1},{"max_pressure_growth",-1},{"max_pressure",-1},{"initial_cost",initialCost},{"final_cost",parentCost},{"commits",int64_t(commits)},{"trials",int64_t(trials)},{"final_ir",current},{"rounds",json::Value(json::Array(rounds))},{"stops",json::Value(json::Array(stops))}}));};
 report("running");
 std::set<std::string> attemptedStructural;
 std::string catalogParent;
 Optional<json::Value> structuralCatalog;

 for(auto &target:targets){for(unsigned iteration=0;iteration<256;++iteration){
  auto m=parseIRFile(current,error,ctx);if(!m)throw std::runtime_error("cannot read parent");
  auto catalog=decision::discover(*m->getFunction(fn));
  unsigned di=0;
  while(di<catalog.size()&&catalog[di].id!=target)++di;
  if(!target.empty()&&di==catalog.size()){stops.push_back(json::Object{{"decision",target},{"reason","decision_completed_or_absorbed"}});break;}
  if(!target.empty()) {
    unsigned identities=0;for(auto &candidate:catalog)identities+=candidate.id==target;
    if(identities!=1)throw std::runtime_error("ambiguous decision identity: "+target);
  }
  decision::Decision emptyDecision;
  auto &d=target.empty()?emptyDecision:catalog[di];
  int64_t bestCost=parentCost;
  std::string best;
  json::Array attempts, preparationRejections;
  struct Trial { unsigned left; std::string dir; int rc; };
  std::vector<Trial> evaluated;
  struct PreparedPair {
    unsigned left;
    std::string input;
    std::vector<std::array<std::string,3>> coordinates;
    bool containsRegion;
  };
  std::vector<PreparedPair> preparedPairs;
  unsigned next=0;
  while(next+1<d.arms.size()){
   std::vector<sys::ProcessInfo> running;
   const size_t start=evaluated.size();
   while(next+1<d.arms.size()&&evaluated.size()-start<size_t(jobs)){
    unsigned left=next++;
    if(!eligible(d.arms[left],d.arms[left+1]))continue;
    if(useSharedTrial){
      auto prepared=CloneModule(*m);
      std::string reason;
      std::vector<std::array<std::string,3>> coordinates;
      if(prepareArmPairs(*prepared,fn,di,left,conditionBudget,reason,coordinates)){
        const auto input=out+"/prepared-"+std::to_string(rounds.size())+"-"+std::to_string(left)+".ll";
        std::error_code ec;
        raw_fd_ostream stream(input,ec);
        if(ec)throw std::runtime_error(ec.message());
        prepared->print(stream,nullptr);
        stream.close();
        const bool containsRegion=d.arms[left].kind==decision::ArmKind::SESE||
                                  d.arms[left+1].kind==decision::ArmKind::SESE;
        preparedPairs.push_back({left,input,std::move(coordinates),containsRegion});
        continue;
      }
      preparationRejections.push_back(json::Object{
        {"left",d.arms[left].id},{"right",d.arms[left+1].id},
        {"stage","preparation_rejected"},{"reason",std::move(reason)}});
      continue;
    }
    if(trials>=100000)throw std::runtime_error("trial budget exceeded");
    std::string dir=out+"/trial-"+std::to_string(trials++);
    save(dir+".request.json",json::Value(json::Object{
         {"decision",target},{"left",d.arms[left].id},{"right",d.arms[left+1].id}}));
    std::vector<std::string> args{root+"/build/decision-fuse/decision-fuse",current,fn,
        std::to_string(di),std::to_string(left),dir,out+"/order.json",dir+".request.json"};
    if(jobs==1){
      int rc=run(std::move(args),dir+".stdout",dir+".stderr");
      evaluated.push_back({left,std::move(dir),rc});
    }else{
      running.push_back(startTrial(args,dir+".stdout",dir+".stderr"));
      evaluated.push_back({left,std::move(dir),-1});
    }
   }
   for(size_t i=0;i<running.size();++i)
    if(running[i].Pid)
      evaluated[start+i].rc=sys::Wait(running[i],120,false).ReturnCode;
  }
  // Rank in the original adjacency order so ties select the same trial.
  for(const auto &trial:evaluated){
   const auto left=trial.left;
   const auto &dir=trial.dir;
   const int rc=trial.rc;
   json::Object attempt{{"directory",dir},{"left",d.arms[left].id},
                        {"right",d.arms[left+1].id},{"exit_code",rc}};
   if(rc){attempt["stage"]="trial_failed";if(sys::fs::exists(dir+"/trial.json")){auto v=read(dir+"/trial.json");auto*r=v.getAsObject();if(r)if(auto reason=r->getString("reason"))attempt["reason"]=reason->str();}else attempt["reason"]="trial_process_failed";}
   else{auto verified=read(dir+"/trial.json");auto *actual=verified.getAsObject();
    if(!actual||actual->getString("decision")!=Optional<StringRef>(target)||actual->getString("left")!=Optional<StringRef>(d.arms[left].id)||actual->getString("right")!=Optional<StringRef>(d.arms[left+1].id))throw std::runtime_error("trial identity mismatch: "+dir);
    int64_t c;
    try {
      c=cost(dir+"/fused.ll",dir+"/tti");
    } catch(const std::runtime_error &error) {
      attempt["stage"]="score_rejected";
      attempt["reason"]=std::string(error.what());
      attempt["eligible"]=false;
      attempts.push_back(std::move(attempt));
      continue;
    }
    attempt["stage"]="scored";
    attempt["cost"]=c;
    attempt["gain"]=parentCost-c;
    for(auto key:{"ir_pressure_before","ir_pressure"})
      if(auto *pressure=actual->getObject(key))attempt[key]=json::Value(json::Object(*pressure));
    attempt["eligible"]=c<parentCost;
    if(c<bestCost){bestCost=c;best=dir;}
   }
   attempts.push_back(std::move(attempt));
  }
  if(structuralAvailable) {
    const std::string scan=out+"/structural-"+std::to_string(rounds.size());
    std::vector<std::string> args{structural,"--ir",current,"--function",fn,
      "--structural","1","--speculation",speculation?speculation:"cost","--cross-level-b2r",std::to_string(crossLevelB2R),
      "--cleanup",structuralCleanup,"--tti-worker",root+"/tools/run-llvm24-tti"};
    if(catalogParent!=current){
      auto catalogArgs=args;
      catalogArgs.insert(catalogArgs.end(),{"--catalog-only","1","--debug-dir",scan,"--out",scan+".ll"});
      if(int rc=run(std::move(catalogArgs),scan+".stdout",scan+".stderr"))
        throw std::runtime_error("structural candidate enumeration failed ("+std::to_string(rc)+"): "+scan+".stderr");
      catalogParent=current;
      structuralCatalog=read(scan+"/catalog.json");
    }
    const auto &candidates=*structuralCatalog->getAsObject()->getArray("candidates");
    json::Array normalizedCandidates;
    for(const auto &pair:preparedPairs){
      std::set<std::array<std::string,3>> coordinates(pair.coordinates.begin(),pair.coordinates.end());
      if(pair.containsRegion){
        const auto scan=pair.input+".catalog";
        auto catalogArgs=args;
        catalogArgs[2]=pair.input;
        catalogArgs.insert(catalogArgs.end(),{"--catalog-only","1","--debug-dir",scan,"--out",scan+".ll"});
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
          {"prepared_input",pair.input},{"logical_left",d.arms[pair.left].id},
          {"logical_right",d.arms[pair.left+1].id}});
    }

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
      bool batchR2R = false;
    };
    std::vector<StructuralTrial> structuralTrials;
    for(const auto *list:{&candidates, static_cast<const json::Array*>(&normalizedCandidates)})
    for(const auto &entry:*list) {
      const auto &candidate=*entry.getAsObject();
      // Compare both candidate kinds at this decision. The final structural
      // sweep also considers roots outside the initial decision catalog.
      const auto preparedInput=candidate.getString("prepared_input");
      if(!preparedInput&&!decisionSplit.empty()&&candidate.getString("split")!=Optional<StringRef>(decisionSplit))
        continue;
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
      // Keep the exact invocation and the arguments common to search and
      // replay. Replay adds --gap-replay, a fresh debug directory and output.
      if (implicitRoot || !b2bStrategy.empty())
        trialArgs.insert(trialArgs.end(), {"--b2b-strategy", b2bStrategy.empty() ? "dp1" : b2bStrategy});
      trialArgs.insert(trialArgs.end(), {"--b2r-strategy", b2rStrategy});
      json::Array replayArgs;
      for(const auto &argument:trialArgs)replayArgs.push_back(argument);
      trialArgs.insert(trialArgs.end(),{"--gap-trials","4","--debug-dir",dir+"/structural","--out",dir+"/fused.ll"});
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
        attempt["left"]=candidate.getString("logical_left")->str();
        attempt["right"]=candidate.getString("logical_right")->str();
      }
      const bool batchR2R = !preparedInput &&
          candidate.getString("left")->startswith("R") &&
          candidate.getString("right")->startswith("R");
      structuralTrials.push_back({std::move(trialArgs),dir,std::move(attempt),-1,batchR2R});
    }
    std::vector<size_t> regionTrials, individualTrials;
    for (size_t i = 0; i < structuralTrials.size(); ++i)
      (structuralTrials[i].batchR2R ? regionTrials : individualTrials).push_back(i);
    // Bound the work lost if a child crashes or times out. Completed requests
    // retain their artifacts and status; unfinished requests use the old path.
    constexpr size_t trialsPerWorker = 32;
    const size_t workers = structuralJobs;
    if (regionTrials.size() > workers) {
      for (size_t begin = 0; begin < regionTrials.size(); begin += workers * trialsPerWorker) {
        const size_t end = std::min(begin + workers * trialsPerWorker, regionTrials.size());
        std::vector<sys::ProcessInfo> running;
        for (size_t slot = 0; slot < workers && begin + slot < end; ++slot) {
          const auto base = out + "/r2r-batch-" + std::to_string(rounds.size()) +
                            "-" + std::to_string(begin + slot);
          json::Array requests;
          for (size_t i = begin + slot; i < end; i += workers) {
            auto &trial = structuralTrials[regionTrials[i]];
            json::Array argv;
            for (const auto &arg : trial.args) argv.push_back(arg);
            requests.push_back(json::Object{{"argv", std::move(argv)},
                                            {"status", trial.directory + "/batch-exit.json"}});
          }
          save(base + ".json", json::Value(std::move(requests)));
          running.push_back(startTrial({structural, "--r2r-batch", base + ".json"},
                                       base + ".stdout", base + ".stderr"));
        }
        for (const auto &process : running)
          if (process.Pid) sys::Wait(process, 120, false);
        for (size_t i = begin; i < end; ++i) {
          auto &trial = structuralTrials[regionTrials[i]];
          const auto status = trial.directory + "/batch-exit.json";
          if (sys::fs::exists(status)) {
            auto file = MemoryBuffer::getFile(status);
            auto result = file ? json::parse((*file)->getBuffer()) : json::parse("");
            const auto *record = result ? result->getAsObject() : nullptr;
            if (!result) consumeError(result.takeError());
            const auto code = record ? record->getInteger("exit_code") : None;
            if (code && (*code == 0 || *code == 4) &&
                sys::fs::exists(trial.directory + "/structural/trial-0/trial.json") &&
                (*code == 4 || sys::fs::exists(trial.directory + "/fused.ll"))) {
              trial.exitCode = *code;
              continue;
            }
          }
          if (auto ec = sys::fs::remove_directories(trial.directory + "/structural", false))
            if (ec != std::errc::no_such_file_or_directory) throw std::runtime_error(ec.message());
          if (auto ec = sys::fs::remove(trial.directory + "/fused.ll"))
            throw std::runtime_error(ec.message());
          individualTrials.push_back(regionTrials[i]);
        }
      }
    } else {
      individualTrials.insert(individualTrials.end(), regionTrials.begin(), regionTrials.end());
    }
    for (size_t begin = 0; begin < individualTrials.size(); begin += workers) {
      const size_t end = std::min(begin + workers, individualTrials.size());
      if (workers == 1) {
        auto &trial = structuralTrials[individualTrials[begin]];
        trial.exitCode=run(std::move(trial.args),trial.directory+"/stdout",trial.directory+"/stderr");
        continue;
      }
      std::vector<sys::ProcessInfo> running;
      for (size_t i = begin; i < end; ++i) {
        const auto &trial = structuralTrials[individualTrials[i]];
        running.push_back(startTrial(trial.args,trial.directory+"/stdout",trial.directory+"/stderr"));
      }
      for (size_t i = begin; i < end; ++i)
        if (const auto &process = running[i-begin]; process.Pid)
          structuralTrials[individualTrials[i]].exitCode=sys::Wait(process,120,false).ReturnCode;
    }
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
          if(!after||!before||(!attempt.get("prepared_input")&&structuralCleanup=="scoped-cfg"&&*before!=parentCost))
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
            if(trialCost<bestCost){bestCost=trialCost;best=dir;}
          }else attempt["reason"]="nonpositive_gain";
        }
      }
      attempts.push_back(std::move(attempt));
    }
  }
  json::Object record{{"decision",target},{"iteration",int64_t(iteration)},{"parent",current},{"parent_cost",parentCost},{"attempts",std::move(attempts)},{"preparation_rejections",std::move(preparationRejections)},{"selected",best}};
  if(best.empty()){rounds.push_back(std::move(record));stops.push_back(json::Object{{"decision",target},{"reason","no_positive_legal_candidate"}});report("running");break;}
  recordResources(best+"/fused.ll",best+"/resources",record);
  record["selected_cost"]=bestCost;record["score"]=double(parentCost-bestCost)/std::max<int64_t>(parentCost,1);rounds.push_back(std::move(record));parentCost=bestCost;current=best+"/fused.ll";attemptedStructural.clear();++commits;report("running");outs()<<"commit="<<commits<<" cost="<<parentCost<<" decision="<<target<<"\n";outs().flush();
  if(iteration==255)throw std::runtime_error("round budget exceeded");
 }}
 if(auto e=sys::fs::copy_file(current,out+"/final.ll"))throw std::runtime_error(e.message());current=out+"/final.ll";report("completed");return 0;
}catch(const std::exception&e){errs()<<e.what()<<"\n";return 1;}}
