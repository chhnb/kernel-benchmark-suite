#pragma once
#include "fusion_search.h"
#include "llvm/IR/ValueHandle.h"
#include "llvm/Transforms/Utils/ValueMapper.h"
#include <set>
namespace fusion {
// Search-owned identities. LLVM instruction handles are evidence for a binding,
// never the identity of a logical leaf. No metadata is inserted into the IR.
struct LogicalGroup {
  std::string id, left, right, status, reason;
  unsigned first=0,last=0;
  std::set<unsigned> origins;
  std::set<llvm::BasicBlock*> blocks;
};
struct DecisionGroup {
  std::string id, root, join, variable, status, reason;
  unsigned nextGroup=0;
  std::vector<std::string> leafBlocks, guards;
  std::vector<bool> includesNaN;
  std::vector<LogicalGroup> history;
  std::vector<unsigned> active;
};
class LogicalRegionState {
  struct Evidence { unsigned origin; llvm::WeakTrackingVH value; };
  std::vector<Evidence> evidence;
  unsigned nextOrigin=0;
public:
  unsigned version=0;
  std::vector<DecisionGroup> decisions;
  static std::shared_ptr<LogicalRegionState> initialize(llvm::Function&);
  std::shared_ptr<LogicalRegionState> clone(const llvm::ValueToValueMapTy&) const;
  void transfer(const llvm::ValueToValueMapTy&);
  void rebind(llvm::Function&);
  std::vector<Candidate> filter(llvm::Function&, const std::vector<Candidate>&) const;
  bool stageMerge(const Candidate&);
  std::string json() const;
};
}
