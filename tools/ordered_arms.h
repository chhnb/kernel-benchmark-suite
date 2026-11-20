#pragma once
#include "decision_model.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Metadata.h"
#include <algorithm>
#include <map>
#include <numeric>
#include <stdexcept>
#include <optional>
#include <set>

namespace decision {
// Only the active family persists. Block indices below are consumed on the
// exact cleaned parent they were computed on; no LLVM pointers cross commits.
struct OrderedArms {
  using Range = std::pair<unsigned, unsigned>;
  static constexpr const char *marker = "decision.ordered_trial_boundary";
  std::vector<Range> ranges;
  std::vector<unsigned> order;
  std::optional<unsigned> nextDecision;
  bool retired = false;
  bool atFunctionEntry = false;

  void start(unsigned n) {
    order.resize(n);
    std::iota(order.begin(), order.end(), 0u);
    for (unsigned i=0;i<n;++i) ranges.emplace_back(i,i);
  }
  void arrange(Decision &d) const {
    auto original=d.arms;
    for (unsigned i=0;i<order.size();++i) d.arms.at(i)=original.at(order[i]);
  }
  static void stamp(Decision &d, unsigned left) {
    auto mark=[](llvm::BasicBlock *b, int index) {
      auto &ctx=b->getContext();
      auto *value=llvm::ConstantInt::getSigned(llvm::Type::getInt32Ty(ctx),index);
      b->getTerminator()->setMetadata(marker,llvm::MDNode::get(ctx,llvm::ConstantAsMetadata::get(value)));
    };
    for (unsigned i=0;i<d.arms.size();++i)
      if(i!=left && i!=left+1) mark(d.arms[i].entry,i);
    if(d.join) mark(d.join,-1);
    if(d.root!=&d.root->getParent()->getEntryBlock()) mark(d.root,-2);
  }
  static const char *shape(const Arm &arm) {
    if(arm.kind==ArmKind::Unsupported)return "unsupported";
    return arm.blocks.size()==1 ? "B" : "R";
  }
  llvm::json::Array describe(const Decision &d) const {
    llvm::json::Array result;
    for(unsigned i=0;i<ranges.size();++i)
      result.push_back(llvm::json::Object{{"first",int64_t(ranges[i].first)},
        {"last",int64_t(ranges[i].second)},{"shape",shape(d.arms.at(i))},
        {"entry",d.arms[i].id}});
    return result;
  }
  // In the verified cleaned CFG every untouched arm must have exactly one
  // witnessed entry, in the same decision with the same witnessed exit.
  // The sole remaining arm then represents the union. Reject ambiguity.
  std::string advance(llvm::Function &f,unsigned left) {
    auto n=ranges.size();
    if(left+1>=n)throw std::runtime_error("invalid ordered pair");
    std::map<int,llvm::BasicBlock*> witness;
    bool duplicate=false;
    for(auto &b:f)for(auto &i:b)if(auto *tag=i.getMetadata(marker)){
      auto *id=llvm::mdconst::dyn_extract<llvm::ConstantInt>(tag->getOperand(0));
      if(!id || !i.isTerminator() || !witness.emplace(id->getSExtValue(),&b).second)
        duplicate=true;
      i.setMetadata(marker,nullptr);
    }
    retired=true;nextDecision.reset();
    if(n==2)return "no_remaining_neighbor";
    if(duplicate || !witness.count(-1) || (!atFunctionEntry && !witness.count(-2)))
      return "boundary_witness_lost";
    auto *root=atFunctionEntry ? &f.getEntryBlock() : witness.at(-2);
    auto decisions=discover(f);
    std::vector<unsigned> chosen;
    for(unsigned k=0;k<decisions.size();++k){
      auto &d=decisions[k];
      if(d.root!=root || d.join!=witness.at(-1) || d.arms.size()!=n-1)continue;
      std::vector<unsigned> map;
      std::set<unsigned> used;
      bool ok=true;
      for(unsigned i=0;i<n;++i){
        if(i==left || i==left+1)continue;
        auto it=witness.find(i);
        if(it==witness.end()){ok=false;break;}
        auto arm=std::find_if(d.arms.begin(),d.arms.end(),[&](const Arm &a){return a.entry==it->second;});
        if(arm==d.arms.end()){ok=false;break;}
        unsigned j=arm-d.arms.begin();
        if(!used.insert(j).second){ok=false;break;}
        map.push_back(j);
      }
      if(!ok)continue;
      unsigned merged=0;while(used.count(merged))++merged;
      if(d.arms[merged].kind==ArmKind::Unsupported)continue;
      if(nextDecision){nextDecision.reset();return "ambiguous_boundary";}
      nextDecision=k;map.insert(map.begin()+left,merged);chosen=std::move(map);
    }
    if(!nextDecision)return "no_unique_partition";
    ranges[left].second=ranges[left+1].second;
    ranges.erase(ranges.begin()+left+1);
    order=std::move(chosen);retired=false;
    return "rebound";
  }
};
}
