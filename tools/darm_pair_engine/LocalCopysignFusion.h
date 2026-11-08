#pragma once
// Compatibility include for the first copysign-only prototype.
#include "LocalComputationFusion.h"
namespace llvm {
inline bool fuseCopysignLeaves(BasicBlock *L, BasicBlock *R,
    const std::function<void(const ValueToValueMapTy&)> &transfer,
    std::string &reason, bool unionEntry=false) {
  return fuseLocalComputations(L,R,transfer,reason,unionEntry);
}
}
