#pragma once

#include "fold_llvm.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Instructions.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Transforms/InstCombine/InstCombine.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Transforms/Utils/SimplifyCFGOptions.h"

namespace dataflow {
inline void configurePhiThreshold() {
  static const bool configured = [] {
    llvm::StringRef name = "two-entry-phi-node-folding-threshold";
    auto &options = llvm::cl::getRegisteredOptions();
    auto entry = options.find(name);
    return entry != options.end() && !entry->second->addOccurrence(0, name, "7");
  }();
  if (!configured)
    llvm::report_fatal_error("could not configure LLVM 12 PHI threshold");
}

inline void canonicalPhiOrder(llvm::Function &function) {
  using namespace llvm;
  DenseMap<const BasicBlock *, unsigned> order;
  for (auto &block : function)
    order[&block] = order.size();
  for (auto &block : function)
    for (auto &phi : block.phis()) {
      SmallVector<std::pair<BasicBlock *, Value *>, 8> edges;
      for (unsigned i = 0; i < phi.getNumIncomingValues(); ++i)
        edges.emplace_back(phi.getIncomingBlock(i), phi.getIncomingValue(i));
      llvm::stable_sort(edges, [&](const auto &l, const auto &r) {
        return order.lookup(l.first) < order.lookup(r.first);
      });
      for (unsigned i = 0; i < edges.size(); ++i) {
        phi.setIncomingBlock(i, edges[i].first);
        phi.setIncomingValue(i, edges[i].second);
      }
    }
}

inline void runSimplifyCFG(llvm::Function &function, const SizeLatency &quotes) {
  using namespace llvm;
  configurePhiThreshold();
  canonicalPhiOrder(function);
  auto options = SimplifyCFGOptions().setSimplifyCondBranch(false)
                    .sinkCommonInsts(false).hoistCommonInsts(false);
  bool changed;
  do {
    changed = false;
    for (auto &block : function)
      if (simplifyCFG(&block, quotes.analysis(), nullptr, options)) {
        changed = true;
        break;
      }
  } while (changed);
}

inline void runCleanup(llvm::Function &function, const SizeLatency &quotes) {
  using namespace llvm;
  runSimplifyCFG(function, quotes);
  legacy::FunctionPassManager passes(function.getParent());
  passes.add(createTargetTransformInfoWrapperPass(
      TargetIRAnalysis([&](const Function &) { return quotes.freshAnalysis(); })));
  passes.add(createEarlyCSEPass(false));
  passes.add(createDeadCodeEliminationPass());
  passes.add(createInstructionCombiningPass());
  passes.doInitialization();
  passes.run(function);
  passes.doFinalization();
}
} // namespace dataflow
