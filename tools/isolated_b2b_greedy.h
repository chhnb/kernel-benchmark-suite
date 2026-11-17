#pragma once
#include "b2b_unit_capsule.h"
#include "incremental_candidate_queue.h"
#include "llvm24_scorer.h"
#include <functional>
namespace fusion {
// Experimental local cleanup only. Units allow integer/address work and ordinary
// integer memory operations; calls, atomics and volatile accesses remain excluded.
// Outside units admit only the audited pinned-GCN quote-key domain.
// External quote dependencies invalidate gains, never supply guessed prices.
// Pinned GCN/BasicTTI scalar pointer selects depend only on the legalized
// pointer type and i1 condition type; scalar PHI uses generic CF cost.
// This extension is isolated-only: default instruction quote cache unchanged.
inline std::optional<std::string> isolatedQuoteKey(const llvm::Instruction &i) {
  if(auto key=gcnQuoteKey(i))return key;
  if(i.getType()->isPointerTy()&&
     (llvm::isa<llvm::PHINode>(i)||(llvm::isa<llvm::SelectInst>(i)&&i.getOperand(0)->getType()->isIntegerTy(1)))){
    std::string key;llvm::raw_string_ostream out(key);
    out<<"gcn-throughput-6be16f356d3e-pointer:"<<i.getOpcodeName()<<":";
    i.getType()->print(out);out.flush();return key;
  }
  return std::nullopt;
}
inline bool isolatedContextFreeOpcode(unsigned opcode) {
  switch(opcode){
  case llvm::Instruction::Add:case llvm::Instruction::Sub:case llvm::Instruction::Mul:
  case llvm::Instruction::And:case llvm::Instruction::Or:case llvm::Instruction::Xor:
  case llvm::Instruction::Shl:case llvm::Instruction::LShr:case llvm::Instruction::AShr:
  case llvm::Instruction::ICmp:case llvm::Instruction::Select:case llvm::Instruction::PHI:
  case llvm::Instruction::Br:case llvm::Instruction::Ret:case llvm::Instruction::Freeze:return true;
  default:return false;
  }
}
// These supported quote keys cannot change merely because a user/operand
// is rebound at a boundary: memory value type, AS and alignment are unchanged;
// the admitted zero-argument intrinsics and pointer bitcasts are context-free.
inline bool isolatedBoundaryStableOpcode(unsigned opcode) {
  switch(opcode){
  case llvm::Instruction::Load:case llvm::Instruction::Store:
  case llvm::Instruction::Fence:case llvm::Instruction::Call:
  case llvm::Instruction::BitCast:return true;
  default:return false;
  }
}
inline void addIsolatedScoringReads(IncrementalCandidateQueue::ReadSet &reads,
    const IncrementalCandidateQueue::ReadSet &scoring,IRIdentity &ids,
    const B2BOptimizationUnit &unit) {
  for(auto &kv:scoring){
    auto id=std::stoull(kv.first.substr(12));auto *i=ids.lookup(id);
    if(unit.reads.count(id)||(unit.writes.count(id)&&!isolatedBoundaryStableOpcode(i->getOpcode())))
      reads.insert(kv);
  }
}
inline bool isolatedScalarTTIDomain(const llvm::Function &f) {
  if(f.getParent()->getTargetTriple()!="amdgcn-amd-amdhsa" ||
     f.getFnAttribute("target-cpu").getValueAsString()!="gfx906")return false;
  for(const auto &b:f)for(const auto &i:b)if(!isolatedQuoteKey(i))return false;
  return true;
}
inline IncrementalCandidateQueue::ReadSet isolatedScoringReads(
    llvm::Function &f,IRIdentity &ids) {
  IncrementalCandidateQueue::ReadSet reads;
  for(auto &b:f)for(auto &i:b)if(!isolatedContextFreeOpcode(i.getOpcode())){
    auto key=isolatedQuoteKey(i);
    if(!key)throw std::runtime_error("unsupported isolated scoring dependency");
    reads["tti-context:"+std::to_string(ids.instruction(i))]=*key;
  }
  return reads;
}
struct IsolatedGreedyStats {
  uint64_t trials=0,generations=0,layoutCleanups=0,scores=0,reusedTrials=0,commits=0;
  uint64_t enumerated=0,newCandidates=0,invalidated=0,disappeared=0;
  uint64_t fallbackTrials=0,fallbackCommits=0;
};
struct IsolatedGreedyResult {
  std::unique_ptr<llvm::Module> module;
  IsolatedGreedyStats stats;
  std::vector<std::string> identities,hashes;
  std::vector<int64_t> gains,costs;
};
inline IncrementalCandidateQueue::ReadSet isolatedReads(
    const IRDependencySnapshot &snapshot,const B2BOptimizationUnit &unit) {
  IncrementalCandidateQueue::ReadSet reads{{"context",snapshot.context},
    {"policy","isolated-pure-integer-gfx906-v6;opaque-global-inputs;ordinary-loads;scoped-quote-dependencies;stripped-instruction-metadata;opaque-ssa-inputs;fold-output-boundary;no-global-cleanup"}};
  for(auto id:unit.reads){
    const auto &record=snapshot.instructions.at(id);
    reads["instruction:"+std::to_string(id)]=(id==unit.entry||unit.inputs.count(id))?
        IRDependencySnapshot::instructionBody(record):record;
    std::string uses;
    auto found=snapshot.users.find(id);
    if(found!=snapshot.users.end())for(auto u:found->second)
      uses+=std::to_string(u.first)+":"+std::to_string(u.second)+";";
    reads["uses:"+std::to_string(id)]=std::move(uses);
  }
  return reads;
}
// Full-rescore and incremental modes share this exact algorithm and tie order.
// No original driver behavior is replaced by this experimental entry point.
inline IsolatedGreedyResult runIsolatedB2BGreedy(
    const llvm::Module &input,const std::string &function,
    const LLVM24Scorer &scorer,bool reuse,
    std::function<void(const llvm::Module &,unsigned)> observer={},
    bool siblingFallback=false) {
  IsolatedGreedyResult result;result.module=llvm::CloneModule(input);
  IncrementalCandidateQueue queue;
  std::optional<int64_t> currentCost;
  struct Saved {std::unique_ptr<B2BUnitCapsule> capsule;std::unique_ptr<llvm::Module> product;std::string exactParent;};
  std::map<std::string,Saved> saved;
  for(unsigned round=0;round<256;++round){
    auto &current=*result.module;auto *f=current.getFunction(function);
    if(!f||!isolatedScalarTTIDomain(*f))throw std::runtime_error("outside isolated TTI proof domain");
    auto replayContext=B2BReplayContext::capture(current);
    const auto &snapshot=replayContext.planning;IRIdentity ids(current);
    std::set<llvm::BasicBlock*> reachable;std::vector<llvm::BasicBlock*> pendingBlocks{&f->getEntryBlock()};
    while(!pendingBlocks.empty()){
      auto *b=pendingBlocks.back();pendingBlocks.pop_back();if(!reachable.insert(b).second)continue;
      for(auto *s:llvm::successors(b))pendingBlocks.push_back(s);
    }
    auto scoringReads=isolatedScoringReads(*f,ids);
    std::vector<IncrementalCandidateQueue::Candidate> inventory;
    std::map<std::string,B2BOptimizationUnit> units;
    std::map<std::string,Candidate> fallbacks;
    std::map<llvm::BasicBlock*,unsigned> coordinates;unsigned blockIndex=0;
    for(auto &b:*f)coordinates[&b]=blockIndex++;
    auto blockName=[&](llvm::BasicBlock *b){return "B"+std::to_string(coordinates.at(b));};
    for(auto &b:*f){
      if(!reachable.count(&b))continue;
      auto unit=B2BOptimizationUnit::discover(b,ids);
      bool local=unit.eligible()&&!ids.lookup(unit.exit)->getParent()->phis().empty();
      if(!local){
        auto *br=llvm::dyn_cast<llvm::BranchInst>(b.getTerminator());
        if(!siblingFallback||!br||!br->isConditional()||
           br->getSuccessor(0)==&b||br->getSuccessor(1)==&b||br->getSuccessor(0)==br->getSuccessor(1))continue;
        auto key="fallback:"+ids.candidate(b,*br->getSuccessor(0),*br->getSuccessor(1));
        Candidate candidate{function,blockName(&b),blockName(br->getSuccessor(0)),blockName(br->getSuccessor(1)),round};
        inventory.push_back({key,{{"exact-parent",replayContext.exactIR},{"policy","whole-function-dp1-fallback-v1"}},inventory.size()});
        fallbacks.emplace(key,std::move(candidate));continue;
      }
      auto reads=isolatedReads(snapshot,unit);
      addIsolatedScoringReads(reads,scoringReads,ids,unit);
      if(!reuse)reads["force_full_rescore"]=std::to_string(round);
      inventory.push_back({unit.identity,std::move(reads),inventory.size()});units.emplace(unit.identity,std::move(unit));
    }
    result.stats.enumerated+=inventory.size();
    auto pending=queue.synchronize(inventory);
    for(auto &ticket:pending)if(saved.count(ticket.id))++result.stats.invalidated;else ++result.stats.newCandidates;
    result.stats.reusedTrials+=inventory.size()-pending.size();
    for(auto it=saved.begin();it!=saved.end();)if(!units.count(it->first)&&!fallbacks.count(it->first)){++result.stats.disappeared;it=saved.erase(it);}else ++it;
    // Every invalidated/new item is evaluated before looking at the heap top.
    auto context=makeRound(current,function,round,0,CleanupMode::None);
    for(auto &ticket:pending){
      auto fallback=fallbacks.find(ticket.id);
      if(fallback!=fallbacks.end()){
        ++result.stats.trials;++result.stats.generations;++result.stats.fallbackTrials;
        auto source=llvm::CloneModule(current);
        for(auto &fn:*source)for(auto &bb:fn)for(auto &i:bb)i.setMetadata("fusion.incremental.identity",nullptr);
        auto layouts=planSingleBranchB2B(*source,fallback->second,1,CleanupMode::DarmCFGInstCombine,"");
        int64_t bestGain=0;std::unique_ptr<llvm::Module> best;
        for(auto &layout:layouts){
          if(layout.normalized)++result.stats.layoutCleanups;
          if(!layout.valid||!layout.normalized)continue;
          // Cleanup already ran on the whole disposable function. Assess its
          // complete parent-relative delta, including any nonlocal effects.
          layout.cleanupMode=CleanupMode::None;layout.candidate.version=round;
          ++result.stats.scores;auto score=evaluateTrial(current,layout,context,scorer);
          if(score.status!=ScoreStatus::Scored)throw std::runtime_error("incomplete fallback score");
          const int64_t before=score.metrics.at("work_before");
          if(currentCost&&*currentCost!=before)throw std::runtime_error("fallback baseline mismatch");
          currentCost=before;
          auto gain=before-int64_t(score.metrics.at("work_after"));
          if(score.profitabilityRejection.empty()&&gain>bestGain){bestGain=gain;best=llvm::CloneModule(*layout.normalized);}
        }
        saved[ticket.id]={nullptr,std::move(best),replayContext.exactIR};
        if(!queue.publish(ticket,{bestGain,ticket.id,0,true}))throw std::runtime_error("stale fallback result");
        continue;
      }
      const auto &unit=units.at(ticket.id);auto *root=ids.lookup(unit.entry)->getParent();
      auto capsule=std::make_unique<B2BUnitCapsule>(current,*root,&replayContext);
      ++result.stats.trials;++result.stats.generations;
      Candidate candidate{"unit","B0","B1","B2"};
      auto layouts=planSingleBranchB2B(*capsule->ir,candidate,1,CleanupMode::DarmCFGInstCombine,"");
      int64_t bestGain=0;std::unique_ptr<llvm::Module> best;
      bool certified=true;
      for(auto &layout:layouts){
        if(layout.normalized)++result.stats.layoutCleanups;
        if(!layout.valid||!layout.normalized)continue;
        Trial trial;trial.valid=true;trial.cleanupMode=CleanupMode::None;
        trial.candidate={function,"","", "",round};
        trial.normalized=capsule->apply(current,*layout.normalized,&replayContext);
        if(!isolatedScalarTTIDomain(*trial.normalized->getFunction(function)))
        {
          std::string unknown;
          for(auto &b:*trial.normalized->getFunction(function))for(auto &i:b)
            if(!isolatedQuoteKey(i))unknown+=std::string(i.getOpcodeName())+";";
          throw std::runtime_error("isolated product outside TTI proof domain: "+unknown);
        }
        trial.raw=llvm::CloneModule(*trial.normalized);
        trial.before=features(*f);trial.after=features(*trial.normalized->getFunction(function));trial.afterRaw=trial.after;
        ++result.stats.scores;
        auto score=evaluateTrial(current,trial,context,scorer);
        if(score.status!=ScoreStatus::Scored){certified=false;continue;}
        const int64_t before=score.metrics.at("work_before");
        if(currentCost && *currentCost!=before)throw std::runtime_error("isolated cached cost disagrees with full TTI");
        currentCost=before;
        const int64_t gain=before-score.metrics.at("work_after");
        if(gain>bestGain){bestGain=gain;best=llvm::CloneModule(*layout.normalized);}
      }
      // An incomplete score set is not a valid zero nor a valid winner.
      if(!certified)throw std::runtime_error("incomplete isolated trial scoring");
      saved[ticket.id]={std::move(capsule),std::move(best)};
      if(!queue.publish(ticket,{bestGain,ticket.id,0,true}))throw std::runtime_error("stale isolated trial result");
    }
    if(!queue.ready())throw std::runtime_error("isolated queue not fully evaluated");
    auto winner=queue.best();if(!winner)return result;
    auto &chosen=saved.at(winner->first.id);if(!chosen.product)throw std::runtime_error("missing isolated product");
    // This is commit materialization, not another trial or cleanup/score.
    if(chosen.capsule)result.module=chosen.capsule->apply(current,*chosen.product,&replayContext);
    else {
      if(chosen.exactParent!=B2BReplayContext::serialize(current))throw std::runtime_error("stale whole-parent fallback");
      // No lineage proof for this whole-function rewrite: assign a new epoch
      // above the old high-water mark and invalidate all old candidates.
      auto *next=current.getNamedMetadata("fusion.incremental.next_identity")->getOperand(0);
      auto product=llvm::CloneModule(*chosen.product);
      for(auto &fn:*product)for(auto &bb:fn)for(auto &i:bb)i.setMetadata("fusion.incremental.identity",nullptr);
      auto *counter=product->getOrInsertNamedMetadata("fusion.incremental.next_identity");
      counter->clearOperands();counter->addOperand(next);IRIdentity fresh(*product);
      if(llvm::verifyModule(*product,&llvm::errs()))throw std::runtime_error("invalid fallback product");
      result.module=std::move(product);++result.stats.fallbackCommits;
    }
    ++result.stats.commits;result.identities.push_back(winner->first.id);
    if(!currentCost)throw std::runtime_error("isolated baseline cost unavailable");
    *currentCost-=winner->second.gain;result.costs.push_back(*currentCost);
    result.gains.push_back(winner->second.gain);result.hashes.push_back(moduleHash(*result.module));
    if(observer)observer(*result.module,round);
  }
  throw std::runtime_error("isolated round budget exceeded");
}
} // namespace fusion
