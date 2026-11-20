#pragma once

#include "b2b_anchor.h"
#include "darm_pair_engine/RegionMelder.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/IR/IntrinsicInst.h"

namespace fusion {

inline std::optional<llvm::RegionMelder::BlockAlignment> alignRegionBlocks(
    llvm::BasicBlock *left, llvm::BasicBlock *right,
    const llvm::RegionMelder::BlockMap &mapping,
    llvm::BasicBlock *leftExit, llvm::BasicBlock *rightExit, bool pairTies,
    llvm::function_ref<bool(llvm::Instruction &, llvm::Instruction &)> compatible,
    llvm::function_ref<int(const llvm::Instruction &)> instructionCost,
    llvm::function_ref<int(llvm::Type *)> selectCost,
    llvm::function_ref<int(llvm::Type *)> phiCost, std::string &fallback, int forkCost) {
  using namespace llvm;
  auto *lt = dyn_cast<BranchInst>(left->getTerminator());
  auto *rt = dyn_cast<BranchInst>(right->getTerminator());
  if (!lt || !rt || lt->isConditional() != rt->isConditional()) {
    fallback = "unsupported_terminator_pair";
    return std::nullopt;
  }
  if (left->isEHPad() || right->isEHPad()) {
    fallback = "exception_pad";
    return std::nullopt;
  }
  SmallVector<Instruction *, 32> lwork, rwork;
  for (auto *block : {left, right})
    for (auto &i : *block)
      if (!isa<PHINode>(i) && !i.isTerminator())
        (block == left ? lwork : rwork).push_back(&i);

  SmallVector<AnchorSeed, 16> seeds;
  auto seed = [&](Value *lv, Value *rv, int output) {
    auto *li = dyn_cast_or_null<Instruction>(lv);
    auto *ri = dyn_cast_or_null<Instruction>(rv);
    if (li && ri && li->getParent() == left && ri->getParent() == right)
      seeds.push_back({li, ri, output});
  };
  if (lt->isConditional() && mapping.lookup(lt->getSuccessor(0)) == rt->getSuccessor(0) &&
      mapping.lookup(lt->getSuccessor(1)) == rt->getSuccessor(1))
    seed(lt->getCondition(), rt->getCondition(), selectCost(lt->getCondition()->getType()));

  auto incomingValue = [](PHINode &phi, BasicBlock *pred) -> Value * {
    int index = phi.getBasicBlockIndex(pred);
    return index < 0 ? nullptr : phi.getIncomingValue(index);
  };
  // Exit PHIs can share a successor before the exits are isolated.
  for (auto *succ : successors(left))
    if (llvm::is_contained(successors(right), succ))
      for (auto &phi : succ->phis())
        seed(incomingValue(phi, left), incomingValue(phi, right),
             phiCost(phi.getType()));
  // If the melder has isolated two exits, trace the common exit PHI through
  // the per-side forwarding PHIs to recover the original incoming values.
  auto *join = leftExit ? leftExit->getSingleSuccessor() : nullptr;
  if (join && rightExit && leftExit != rightExit && rightExit->getSingleSuccessor() == join) {
    auto incoming = [&](PHINode &phi, BasicBlock *exit, BasicBlock *block) -> Value * {
      auto *value = incomingValue(phi, exit);
      if (exit == block) return value;
      if (auto *forward = dyn_cast_or_null<PHINode>(value))
        if (forward->getParent() == exit)
          return incomingValue(*forward, block);
      return nullptr;
    };
    for (auto &phi : join->phis())
      seed(incoming(phi, leftExit, left), incoming(phi, rightExit, right), phiCost(phi.getType()));
  }

  // Use the occurrence of the same operation in the mapped consumer block.
  // A positional/operation mismatch supplies no evidence for an anchor.
  DenseMap<const Instruction *, const Instruction *> consumers;
  for (const auto &bb : *left->getParent()) {
    auto *counterpart = mapping.lookup(const_cast<BasicBlock *>(&bb));
    if (!counterpart || &bb == left) continue;
    SmallVector<Instruction *, 32> remaining;
    for (auto &i : *counterpart)
      if (!isa<PHINode, DbgInfoIntrinsic>(i)) remaining.push_back(&i);
    unsigned next = 0;
    for (const auto &i : bb) {
      if (isa<PHINode, DbgInfoIntrinsic>(i)) continue;
      auto pos = llvm::find_if(ArrayRef<Instruction *>(remaining).drop_front(next), [&](const Instruction *other) {
        return i.getNumOperands() == other->getNumOperands() && i.isSameOperationAs(other);
      });
      if (pos == remaining.end()) continue;
      consumers[&i] = *pos;
      next = unsigned(pos - remaining.begin()) + 1;
    }
  }
  for (auto *producer : lwork) {
    // Sort the discovered roots by right block instruction order. LLVM's use
    // list can be rebuilt in a different order after serialization.
    SmallPtrSet<Value *, 4> counterparts;
    for (const auto &use : producer->uses())
      if (auto *consumer = dyn_cast<Instruction>(use.getUser()))
        if (auto *other = consumers.lookup(consumer)) {
          auto *value = other->getOperand(use.getOperandNo());
          if (value->getType() == producer->getType())
            counterparts.insert(value);
        }
    for (auto *other : rwork)
      if (counterparts.contains(other))
        seed(producer, other, selectCost(producer->getType()));
  }

  // DARM consumes the original operand order. It has no representation for
  // the swapped operands that the B2B emitter can accept.
  const auto plans = planB2BAnchors(lwork, rwork, *left, *right, nullptr, pairTies,
                                   compatible, instructionCost, selectCost, phiCost, seeds, false, forkCost);
  RegionMelder::BlockAlignment result;
  result.emplace_back(left, right);
  for (auto &phi : left->phis()) result.emplace_back(&phi, nullptr);
  for (auto &phi : right->phis()) result.emplace_back(nullptr, &phi);
  unsigned l = 0, r = 0;
  for (const auto &match : plans.front().matches) {
    if (match.swapped || match.left < l || match.right < r ||
        match.left >= lwork.size() || match.right >= rwork.size()) {
      fallback = "non_monotonic_alignment";
      return std::nullopt;
    }
    while (l < match.left) result.emplace_back(lwork[l++], nullptr);
    while (r < match.right) result.emplace_back(nullptr, rwork[r++]);
    result.emplace_back(lwork[l++], rwork[r++]);
  }
  while (l < lwork.size()) result.emplace_back(lwork[l++], nullptr);
  while (r < rwork.size()) result.emplace_back(nullptr, rwork[r++]);
  result.emplace_back(lt, rt);
  return result;
}

} // namespace fusion
