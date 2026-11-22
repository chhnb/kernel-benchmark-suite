#pragma once

#include "llvm12_compat.h"
#include "llvm/Transforms/Utils/Local.h"

namespace llvm {
using darm_artifact::SplitBlock;

// The artifact fork placed SimplifyCFGOptions before the updater argument.
inline bool simplifyCFG(BasicBlock *block, const TargetTransformInfo &tti,
                        const SimplifyCFGOptions &options) {
  return llvm::simplifyCFG(block, tti, nullptr, options);
}

class PassRegistry;
void initializeCFMelderLegacyPassPass(PassRegistry &);
void initializeCFMelder(PassRegistry &);
}
