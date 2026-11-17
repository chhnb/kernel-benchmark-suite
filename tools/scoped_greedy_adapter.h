#pragma once
#include "isolated_b2b_trial.h"
#include "llvm/Support/CommandLine.h"
namespace fusion {
// Adapter only: the caller retains its candidate inventory, ordering, queue and
// commit policy. Prepared/normalized candidates are deliberately not admitted.
class ScopedGreedyAdapter {
public:
  struct Descriptor {std::string key;IncrementalCandidateQueue::ReadSet reads;};
private:
  std::string function;
  bool reuse;
  LLVM24Scorer scorer;
  llvm::Module *current=nullptr;
  std::unique_ptr<IRIdentity> ids;
  std::optional<B2BReplayContext> replay;
  std::optional<RoundContext> round;
  IncrementalCandidateQueue::ReadSet scoring;
  std::vector<llvm::BasicBlock*> blocks;
  std::map<std::string,llvm::BasicBlock*> roots;
  std::map<std::string,IsolatedB2BTrial> saved;
  unsigned version=0;
  uint64_t evaluated=0,reused=0,cleanups=0,scores=0,localCommits=0,globalCommits=0;
  std::string unavailable;
  std::map<std::string,uint64_t> invalidationKeys;
public:
  ScopedGreedyAdapter(std::string fn,std::string worker,bool cache):
      function(std::move(fn)),reuse(cache),scorer(std::move(worker),"off") {
    auto &opts=llvm::cl::getRegisteredOptions();auto it=opts.find("two-entry-phi-node-folding-threshold");
    if(it==opts.end()||it->second->addOccurrence(0,"two-entry-phi-node-folding-threshold","7"))
      throw std::runtime_error("cannot initialize isolated cleanup threshold");
  }
  void begin(llvm::Module &m,unsigned v) {
    current=&m;version=v;roots.clear();blocks.clear();replay.reset();round.reset();scoring.clear();unavailable.clear();
    ids=std::make_unique<IRIdentity>(m);
    auto *f=m.getFunction(function);for(auto &b:*f)blocks.push_back(&b);
    if(!isolatedScalarTTIDomain(*f)){unavailable="outside_scoped_tti_domain";return;}
    try { replay=B2BReplayContext::capture(m);scoring=isolatedScoringReads(*f,*ids); }
    catch(const std::exception &e){unavailable=e.what();replay.reset();}
  }
  std::optional<Descriptor> describe(llvm::StringRef split,llvm::StringRef left,llvm::StringRef right) {
    if(!replay)return std::nullopt;
    auto block=[&](llvm::StringRef name)->llvm::BasicBlock*{
      unsigned n;if(!name.consume_front("B")||name.getAsInteger(10,n)||n>=blocks.size())return nullptr;return blocks[n];};
    auto *root=block(split),*l=block(left),*r=block(right);if(!root||!l||!r)return std::nullopt;
    auto unit=B2BOptimizationUnit::discover(*root,*ids);
    if(!unit.eligible()||ids->lookup(unit.left)->getParent()!=l||ids->lookup(unit.right)->getParent()!=r||
       ids->lookup(unit.exit)->getParent()->phis().empty())return std::nullopt;
    auto reads=isolatedReads(replay->planning,unit);addIsolatedScoringReads(reads,scoring,*ids,unit);
    if(!reuse)reads["force_full_rescore"]=std::to_string(version);
    auto key="scoped:"+unit.identity;roots[key]=root;return Descriptor{key,std::move(reads)};
  }
  void evaluate(const std::string &key,int64_t parentCost) {
    if(!round)round=makeRound(*current,function,version,0,CleanupMode::None);
    auto trial=evaluateIsolatedB2B(*current,*roots.at(key),*ids,*replay,*round,scorer);
    if("scoped:"+trial.identity!=key)throw std::runtime_error("scoped trial identity mismatch");
    if(trial.parentCost&&*trial.parentCost!=parentCost)throw std::runtime_error("scoped driver parent cost mismatch");
    auto previous=saved.find(key);
    if(previous!=saved.end()){
      for(const auto &kv:trial.reads){auto it=previous->second.reads.find(kv.first);
        if(it==previous->second.reads.end()||it->second!=kv.second)++invalidationKeys[kv.first.substr(0,kv.first.find(':'))];}
      for(const auto &kv:previous->second.reads)if(!trial.reads.count(kv.first))++invalidationKeys["removed:"+kv.first.substr(0,kv.first.find(':'))];
    }
    ++evaluated;cleanups+=trial.cleanedLayouts;scores+=trial.scoredLayouts;
    saved.insert_or_assign(key,std::move(trial));
  }
  int64_t gain(const std::string &key,bool wasReused) {
    const auto &trial=saved.at(key);
    auto unit=B2BOptimizationUnit::discover(*roots.at(key),*ids);
    auto reads=isolatedReads(replay->planning,unit);addIsolatedScoringReads(reads,scoring,*ids,unit);
    if(reads!=trial.reads)throw std::runtime_error("scoped gain dependencies changed");
    if(wasReused)++reused;return trial.gain;
  }
  std::unique_ptr<llvm::Module> materialize(const std::string &key) {
    const auto &trial=saved.at(key);if(!trial.product)throw std::runtime_error("missing scoped positive plan");
    // Revalidate both gain and patch on CURRENT; never restore an old module.
    gain(key,false);auto product=trial.capsule->apply(*current,*trial.product,&*replay);
    ++localCommits;return product;
  }
  void restampWholeCommit(llvm::Module &product) {
    auto *next=current->getNamedMetadata("fusion.incremental.next_identity")->getOperand(0);
    for(auto &f:product)for(auto &b:f)for(auto &i:b)i.setMetadata("fusion.incremental.identity",nullptr);
    auto *counter=product.getOrInsertNamedMetadata("fusion.incremental.next_identity");
    counter->clearOperands();counter->addOperand(next);IRIdentity fresh(product);
    saved.clear();++globalCommits;
  }
  llvm::json::Object report() const {
    llvm::json::Object keys;for(const auto &kv:invalidationKeys)keys[kv.first]=int64_t(kv.second);
    return llvm::json::Object{{"invalidation_keys",std::move(keys)},{"policy",reuse?"scoped-reuse":"scoped-full"},{"local_trials",int64_t(evaluated)},
      {"whole_trials_reused",int64_t(reused)},{"local_layout_cleanups",int64_t(cleanups)},
      {"local_layout_scores",int64_t(scores)},{"local_commits",int64_t(localCommits)},
      {"whole_function_commits",int64_t(globalCommits)},{"local_unavailable",unavailable},
      {"local_quote_cache","off"}};
  }
};
}
