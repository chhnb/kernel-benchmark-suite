#pragma once

#include "cost_model.h"
#include "region_output.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/DenseSet.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/ModuleSlotTracker.h"
#include <array>
#include <map>


namespace dataflow {
using InstructionCosts = llvm::DenseMap<const llvm::Instruction *, int64_t>;
using QuoteProvider =
    llvm::function_ref<llvm::Expected<InstructionCosts>(const llvm::Function &)>;
struct CostReport {
  std::array<int64_t, 3> total{};
  unsigned guards = 0, branches = 0, escapes = 0, selects = 0;
  bool folded = false;
  llvm::json::Array operations;
  std::map<std::string, int64_t> divergenceCosts;

  llvm::json::Object json() {
    using namespace llvm;
    json::Object components;
    for (const auto &term : divergenceCosts)
      components[term.first] = term.second;
    return json::Object{{"D_components", std::move(components)}, {"T", json::Array{total[0], total[1], total[2]}},
                        {"guard_segments", guards}, {"guard_branches", branches},
                        {"escaping_values", escapes}, {"selects", selects},
                        {"original_folded", folded}, {"operations", std::move(operations)}};
  }
};

inline llvm::Expected<CostReport> evaluate(const llvm::Function &fn,
                                           const llvm::json::Object &table,
                                           bool original, const SizeLatency *real = nullptr,
                                           bool enforceFold = true, bool knownOutputBuffer = false,
                                           QuoteProvider throughput = nullptr) {
  using namespace llvm;
  using namespace llvm::PatternMatch;
  auto unsupported = [](const Twine &why) {
    return createStringError(inconvertibleErrorCode(), Twine("unsupported: ") + why);
  };
  if (fn.arg_empty() || !fn.getArg(0)->getType()->isIntegerTy(1))
    return unsupported("first argument must be i1 C");
  const auto *condition = fn.getArg(0);
  DenseMap<const BasicBlock *, unsigned> masks;
  SmallPtrSet<const BranchInst *, 8> guards;
  const ReturnInst *ret = nullptr;
  for (unsigned side : {1u, 2u}) {
    SmallPtrSet<const BasicBlock *, 16> path;
    const auto *block = &fn.getEntryBlock();
    while (true) {
      if (!path.insert(block).second)
        return unsupported("cyclic control flow");
      masks[block] |= side;
      const auto *term = block->getTerminator();
      if (const auto *exit = dyn_cast<ReturnInst>(term)) {
        if (ret && ret != exit)
          return unsupported("multiple return blocks");
        ret = exit;
        break;
      }
      const auto *branch = dyn_cast<BranchInst>(term);
      if (!branch)
        return unsupported(Twine("terminator ") + term->getOpcodeName());
      unsigned next = 0;
      if (branch->isConditional()) {
        auto *test = branch->getCondition();
        bool inverted = match(test, m_Not(m_Specific(condition)));
        if (test != condition && !inverted)
          return unsupported("conditional branch on a value other than C");
        next = (side == 2) != inverted;
        if (branch->getSuccessor(0) != branch->getSuccessor(1))
          guards.insert(branch);
      }
      block = branch->getSuccessor(next);
    }
  }
  if (original && guards.size() != 1)
    return unsupported("original region must have one conditional branch");
  const auto writes = outputWrites(*ret, fn, knownOutputBuffer);
  CostReport report;
  for (const auto *branch : guards) {
    auto shape = findGuard(*branch);
    if (!shape)
      return unsupported("guard must reconverge in a local B2B join");
    SmallVector<const Instruction *, 16> ops;
    SmallVector<const PHINode *, 8> phis;
    for (const auto &phi : shape->join->phis())
      phis.push_back(&phi);
    for (auto *arm : {shape->left, shape->right})
      if (arm)
        for (const auto &inst : *arm)
          if (!inst.isTerminator() && !isa<DbgInfoIntrinsic>(inst))
            ops.push_back(&inst);
    bool folds = foldFailure(ops, phis, *shape->join, *branch->getCondition(), table, real).empty();
    if (original)
      report.folded = folds;
    else if (folds && enforceFold)
      return unsupported(Twine("retained guard on ") + branch->getParent()->getName() +
                         " must be speculated by SimplifyCFG");
  }
  ModuleSlotTracker slots(fn.getParent());
  slots.incorporateFunction(fn);
  auto charge = [&](StringRef kind, const Instruction &inst, unsigned mask, int64_t cost) {
    std::string spelling;
    raw_string_ostream stream(spelling);
    inst.print(stream, slots);
    report.operations.push_back(json::Object{
        {"kind", kind}, {"ir", stream.str()}, {"cost", cost},
        {"scenarios", mask == 3 ? "DLR" : mask == 1 ? "DL" : "DR"}});
    report.divergenceCosts[kind.str()] += cost;
    report.total[0] += cost;
    if (mask & 1) report.total[1] += cost;
    if (mask & 2) report.total[2] += cost;
  };
  if (throughput) {
    auto prices = throughput(fn);
    if (!prices)
      return prices.takeError();
    for (const auto &block : fn) {
      unsigned mask = masks.lookup(&block);
      if (!mask)
        continue;
      for (const auto &inst : block) {
        if (isa<ReturnInst, DbgInfoIntrinsic>(inst) || writes.count(&inst))
          continue;
        auto price = prices->find(&inst);
        if (price == prices->end())
          return unsupported(Twine("missing LLVM24 quote for ") + inst.getOpcodeName());
        StringRef kind = "instruction";
        if (const auto *branch = dyn_cast<BranchInst>(&inst)) {
          kind = "control";
          if (guards.count(branch) && mask == 3) {
            ++report.branches;
            for (const auto *successor : successors(&block))
              report.guards += masks.lookup(successor) != 3;
          }
        } else if (isa<PHINode>(inst)) {
          kind = "escape";
          ++report.escapes;
        } else if (isa<SelectInst>(inst)) {
          kind = "select";
          ++report.selects;
        } else if (isa<LoadInst, StoreInst>(inst)) {
          kind = "memory";
        }
        charge(kind, inst, mask, price->second);
      }
    }
    return report;
  }
  if (!report.folded) {
    for (const auto &block : fn) {
      auto *branch = dyn_cast<BranchInst>(block.getTerminator());
      if (!branch || !guards.count(branch) || masks.lookup(&block) != 3)
        continue;
      unsigned segments = 0;
      for (auto *successor : successors(&block))
        segments += masks.lookup(successor) != 3;
      if (segments) {
        ++report.branches;
        report.guards += segments;
        charge("control", *branch, 3, *table.getInteger("guard_segment_control"));
      }
    }
  }

  auto foldedSelect = [&](const Value *l, const Value *r) -> Optional<int64_t> {
    if (l == r)
      return 0;
    const auto *a = dyn_cast<ConstantInt>(l);
    const auto *b = dyn_cast<ConstantInt>(r);
    if (a && b && l->getType()->isIntegerTy(1))
      return *table.getInteger("select_i1_folded_to_condition");
    if (a && b && ((a->isOne() && b->isZero()) || (a->isZero() && b->isOne())))
      return table.getObject("op")->getInteger("zext");
    return None;
  };

  DenseSet<std::pair<const Value *, const Value *>> demandPairs;
  for (const auto &block : fn) {
    unsigned mask = masks.lookup(&block);
    if (!mask)
      continue;
    if (report.folded)
      mask = 3;
    for (const auto &inst : block) {
      if (inst.isTerminator() || isa<DbgInfoIntrinsic>(inst) || writes.count(&inst))
        continue;
      if (const auto *phi = dyn_cast<PHINode>(&inst)) {
        const auto *a = phi->getIncomingValue(0);
        const auto *b = phi->getIncomingValue(1);
        if (a == b || phi->use_empty())
          continue;
        if (report.folded) {
          const auto *branch = *guards.begin();
          const auto *trueArm = branch->getSuccessor(0);
          if (trueArm == phi->getParent())
            trueArm = branch->getParent();
          if (phi->getIncomingBlock(0) != trueArm)
            std::swap(a, b);
          auto key = std::make_pair(a, b);
          if (demandPairs.insert(key).second) {
            auto fold = foldedSelect(a, b);
            ++report.selects;
            charge("folded-join", inst, 3, fold.getValueOr(*table.getObject("op")->getInteger("select")));
          }
        } else {
          ++report.escapes;
          charge("escape", inst, 3, *table.getInteger("guard_escape_merge"));
        }
        continue;
      }
      const auto *sel = dyn_cast<SelectInst>(&inst);
      if (sel) {
        auto *a = sel->getTrueValue(), *b = sel->getFalseValue();
        bool inverted = match(sel->getCondition(), m_Not(m_Specific(condition)));
        bool demand = !original && mask == 3 &&
                      (sel->getCondition() == condition || inverted);
        if (demand) {
          if (inverted)
            std::swap(a, b);
          if (demandPairs.insert({a, b}).second && a != b)
            ++report.selects;
          else
            continue;
        }
        if (auto fold = foldedSelect(a, b)) {
          charge("simplified-select", inst, mask, *fold);
          continue;
        }
      }
      if (inst.getMetadata("dataflow.folded.condition") &&
          match(&inst, m_Not(m_Specific(condition)))) {
        charge("folded-condition", inst, mask, *table.getInteger("select_i1_folded_to_condition"));
        continue;
      }
      auto cost = costOf(inst, table);
      if (!cost)
        return unsupported(Twine("missing abstract cost for ") + inst.getOpcodeName());
      StringRef kind = isa<LoadInst, StoreInst>(inst) ? "memory" :
                       sel ? "select" : "instruction";
      charge(kind, inst, mask, *cost);
    }
  }
  return report;
}
} // namespace dataflow
