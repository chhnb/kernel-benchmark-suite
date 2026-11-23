#pragma once
#include "cleanup_llvm.h"
#include "cost_model.h"
#include "llvm/Analysis/PostDominators.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/ValueHandle.h"

namespace dataflow::oracle {
using namespace llvm;
struct Guard {
  SmallVector<WeakVH, 16> tracked;
  json::Array quotes;
  std::string reason;
};

inline std::vector<Guard> predict(Function &fn, const json::Object &table,
                            const dataflow::SizeLatency &quotes) {
  std::vector<Guard> result;
  dataflow::canonicalPhiOrder(fn);
  for (auto &block : fn) {
    auto *branch = dyn_cast<BranchInst>(block.getTerminator());
    if (!branch || !branch->isConditional())
      continue;
    auto shape = dataflow::findGuard(*branch);
    if (!shape)
      continue;
    auto *join = shape->join;
    SmallVector<const Instruction *, 16> ops;
    SmallVector<const PHINode *, 8> phis;
    for (const auto &phi : join->phis())
      phis.push_back(&phi);
    Guard guard;
    for (auto *arm : {shape->left, shape->right}) {
      if (!arm)
        continue;
      for (auto &inst : *arm) {
        if (inst.isTerminator() || isa<DbgInfoIntrinsic>(inst))
          continue;
        ops.push_back(&inst);
        guard.tracked.push_back(WeakVH(const_cast<Instruction *>(&inst)));
        guard.quotes.push_back(quotes.quote(inst));
      }
    }
    guard.reason = dataflow::foldFailure(ops, phis, *join, *branch->getCondition(),
                                        table, &quotes);
    result.push_back(std::move(guard));
  }
  return result;
}

inline bool check(Function &fn, const json::Object &table, const SizeLatency &quotes,
                  json::Array &rows) {
  bool mismatch = false;
  auto guards = predict(fn, table, quotes);
  dataflow::runSimplifyCFG(fn, quotes);
  PostDominatorTree postdom(fn);
  for (auto &guard : guards) {
    unsigned moved = 0, removed = 0;
    for (const auto &handle : guard.tracked) {
      Value *value = handle;
      auto *inst = dyn_cast_or_null<Instruction>(value);
      if (!inst)
        ++removed;
      else if (postdom.dominates(inst->getParent(), &fn.getEntryBlock()))
        ++moved;
    }
    bool actual = moved && moved == guard.tracked.size();
    bool predicted = guard.reason.empty();
    mismatch |= actual != predicted;
    rows.push_back(json::Object{{"function", fn.getName()}, {"predicted", predicted},
                                {"actual", actual}, {"reason", guard.reason},
                                {"size_latency", std::move(guard.quotes)},
                                {"promoted", moved}, {"removed", removed}});
  }
  return !mismatch;
}
} // namespace dataflow::oracle
