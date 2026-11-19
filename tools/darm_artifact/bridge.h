#pragma once

#include "llvm/IR/ValueHandle.h"
#include "llvm/Transforms/Utils/ValueMapper.h"
#include <functional>
#include <string>
#include <vector>

namespace llvm {
class BasicBlock;
class DominatorTree;
class PostDominatorTree;
}

namespace darm_artifact {
struct Origin {
  std::string leftID, rightID, leftLabel, rightLabel;
  llvm::WeakVH merged;
};
std::vector<Origin> meldBlocks(
    llvm::BasicBlock *split, llvm::BasicBlock *left, llvm::BasicBlock *right,
    llvm::DominatorTree &dt, llvm::PostDominatorTree &pdt,
    const std::function<void(const llvm::ValueToValueMapTy &)> &mapping);
}
