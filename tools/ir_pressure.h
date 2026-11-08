#pragma once
#include "llvm/IR/Function.h"
#include <cstdint>
#include <set>
#include <map>
#include <string>
namespace fusion {
// Conservative whole-function SSA liveness. Slots are 32-bit IR storage units,
// not allocated registers. An optional proved-uniform value set partitions pressure.
struct IRPressure {
  uint64_t peakSlots32=0, peakValues=0, reachableBlocks=0;
  uint64_t uniformPeakSlots32=0, unprovenPeakSlots32=0;
  std::map<std::string,uint64_t> blockPeakSlots32, blockCrossingValues;
  bool complete=true;
};
IRPressure irPressure(const llvm::Function &, const std::set<const llvm::Value*> *uniform=nullptr);
}
