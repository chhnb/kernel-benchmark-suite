#include "bridge.h"
#include <RegionMelder.h>

namespace darm_artifact {
std::vector<Origin> meldBlocks(
    llvm::BasicBlock *split, llvm::BasicBlock *left, llvm::BasicBlock *right,
    llvm::DominatorTree &dt, llvm::PostDominatorTree &pdt,
    const std::function<void(const llvm::ValueToValueMapTy &)> &mapping) {
  RegionAnalyzer analyzer(split, dt, pdt);
  analyzer.selectExplicitBlocks(left, right);
  RegionMelder melder(analyzer, true);
  melder.onValueMapping = mapping;
  melder.merge(0);
  std::vector<Origin> origins;
  for (const auto &origin : melder.blockOrigins())
    origins.push_back({origin.leftID, origin.rightID, origin.leftLabel,
                       origin.rightLabel, origin.merged});
  return origins;
}
}
