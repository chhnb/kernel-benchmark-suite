#pragma once

#include "llvm/Transforms/Utils/BasicBlockUtils.h"

namespace darm_artifact {
// The packaged LLVM12 adds a DomTreeUpdater overload. The artifact's null
// analysis arguments refer to the original DominatorTree overload.
inline llvm::BasicBlock *SplitBlock(llvm::BasicBlock *block, llvm::Instruction *at,
                                    std::nullptr_t, std::nullptr_t, std::nullptr_t,
                                    const llvm::Twine &name) {
  return llvm::SplitBlock(block, at, static_cast<llvm::DominatorTree *>(nullptr),
                          nullptr, nullptr, name);
}
}
