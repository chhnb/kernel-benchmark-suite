#pragma once
#include "llvm/IR/Function.h"
#include <cstdint>
namespace fusion {
// Structural SSA depth within each reachable basic block only. PHIs are boundary
// values. No latency, cross-block path, alias/clobber or scheduling model.
struct IRDependency {
  uint64_t maxDepth=0, maxSinkDepth=0, maxSelectChain=0;
  uint64_t crossBlockUses=0, phiBoundaryUses=0, memoryOperations=0, opaqueCalls=0;
  bool cfgHasCycle=false;
};
IRDependency localDependencies(const llvm::Function&);
}
