#pragma once
#include "isolated_b2b_trial.h"
#include <functional>
namespace fusion {
struct IsolatedGreedyStats {
  uint64_t trials=0,generations=0,layoutCleanups=0,scores=0,reusedTrials=0,commits=0;
  uint64_t enumerated=0,newCandidates=0,invalidated=0,disappeared=0;
  uint64_t fallbackTrials=0,fallbackCommits=0;
  std::map<std::string,uint64_t> fallbackOutcomes;
};
struct IsolatedGreedyResult {
  std::unique_ptr<llvm::Module> module;
  IsolatedGreedyStats stats;
  std::vector<std::string> identities,hashes;
  std::vector<int64_t> gains,costs;
};
// Full-rescore and incremental modes share this exact algorithm and tie order.
// No original driver behavior is replaced by this experimental entry point.
inline IsolatedGreedyResult runIsolatedB2BGreedy(
    const llvm::Module &input,const std::string &function,
    const LLVM24Scorer &scorer,bool reuse,
    std::function<void(const llvm::Module &,unsigned)> observer={},
    bool siblingFallback=false,bool catalogFallback=false) {
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
    if(catalogFallback){
      // Whole-parent certificates deliberately invalidate on any commit.
      // This catalog includes optional block anchors (B2R/R2B), not just R IDs.
      std::set<std::string> covered;
      for(const auto &kv:fallbacks)covered.insert(kv.second.key());
      for(const auto &kv:units){
        auto *root=ids.lookup(kv.second.entry)->getParent();
        auto *br=llvm::cast<llvm::BranchInst>(root->getTerminator());
        covered.insert(Candidate{function,blockName(root),blockName(br->getSuccessor(0)),blockName(br->getSuccessor(1)),round}.key());
      }
      for(auto &resolved:resolveCandidateCatalog(*f,round)){
        auto &c=resolved.candidate;
        if(!reachable.count(resolved.split)||!covered.insert(c.key()).second)continue;
        auto endpoint=[&](llvm::BasicBlock *b){return b?std::to_string(ids.block(*b)):"none";};
        auto key="catalog:"+endpoint(resolved.split)+":"+
            (resolved.leftRegion?"R":"B")+endpoint(resolved.leftEntry)+":"+endpoint(resolved.leftExit)+":"+
            (resolved.rightRegion?"R":"B")+endpoint(resolved.rightEntry)+":"+endpoint(resolved.rightExit);
        if(fallbacks.count(key))continue;
        inventory.push_back({key,{{"exact-parent",replayContext.exactIR},{"policy","whole-function-catalog-dp1-darm-v1"}},inventory.size()});
        fallbacks.emplace(key,std::move(c));
      }
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
        // DARM handles structural/replication candidates. Never silently use
        // DARM B2B when DP1 has no layout. Rejections remain parent-specific.
        if(catalogFallback&&layouts.empty()){
          auto structural=tryPair(*source,fallback->second,round,1,
              CleanupMode::DarmCFGInstCombine,nullptr,false);
          ++result.stats.fallbackOutcomes[structural.valid?"valid:"+structural.mergePath:"reject:"+structural.reason];
          layouts.push_back(std::move(structural));
        }
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
      const auto &unit=units.at(ticket.id);
      ++result.stats.trials;++result.stats.generations;
      auto trial=evaluateIsolatedB2B(current,*ids.lookup(unit.entry)->getParent(),ids,replayContext,context,scorer);
      if(trial.identity!=ticket.id)throw std::runtime_error("isolated trial identity changed");
      result.stats.layoutCleanups+=trial.cleanedLayouts;result.stats.scores+=trial.scoredLayouts;
      if(trial.parentCost){
        if(currentCost&&*currentCost!=*trial.parentCost)throw std::runtime_error("isolated cached cost disagrees with full TTI");
        currentCost=trial.parentCost;
      }
      saved[ticket.id]={std::move(trial.capsule),std::move(trial.product)};
      if(!queue.publish(ticket,{trial.gain,ticket.id,0,true}))throw std::runtime_error("stale isolated trial result");
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
