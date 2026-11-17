#pragma once
#include "decision_model.h"
#include "llvm/IR/Instructions.h"
#include <map>
#include <set>
#include <stdexcept>
namespace fusion {
// Scheduling ownership, NOT an independence or cached-score certificate.
// All pointers and B coordinates are valid for this parent snapshot only.
// Decision test chains belong together even when arm preparation is rejected.
// Nested decisions inside arm bodies remain separate scheduling domains;
// a cross-arm region pair belongs to its controlling split domain.
class FusionDomains {
  std::map<llvm::BasicBlock*, llvm::BasicBlock*> owner;
  std::map<std::string, llvm::BasicBlock*> coordinates;
public:
  FusionDomains(llvm::Function &f,const std::vector<decision::Decision> &decisions) {
    std::map<llvm::BasicBlock*,llvm::BasicBlock*> parent;
    for(auto &b:f) parent[&b]=&b;
    auto find=[&](llvm::BasicBlock *b) {
      while(parent.at(b)!=b)b=parent.at(b);
      return b;
    };
    // Union overlapping condition chains. Never require eligible adjacent arms:
    // structural candidates are needed precisely where preparation cannot run.
    for(const auto &d:decisions) if(d.root) for(auto *test:d.tests) {
      auto *a=find(d.root),*b=find(test);
      if(a!=b)parent[b]=a;
    }
    std::map<llvm::BasicBlock*,llvm::BasicBlock*> representative;
    unsigned index=0;
    for(auto &b:f) {
      coordinates["B"+std::to_string(index++)]=&b;
      auto *component=find(&b);
      // Preserve deterministic function order; no new tie sorting by names.
      if(!representative.count(component))representative[component]=&b;
      owner[&b]=representative[component];
    }
  }
  llvm::BasicBlock *root(llvm::BasicBlock *split) const {return owner.at(split);}
  llvm::BasicBlock *root(const std::string &split) const {
    auto it=coordinates.find(split);
    if(it==coordinates.end())throw std::runtime_error("unknown domain split: "+split);
    return root(it->second);
  }
};
}
