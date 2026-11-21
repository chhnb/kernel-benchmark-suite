#pragma once

#include "b2b_anchor.h"
#include "darm_pair_engine/RegionMelder.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/IR/IntrinsicInst.h"

namespace fusion {

enum class AnchorGapOrder { Native, SW, Latency };

inline llvm::RegionMelder::BlockAlignment reorderRegionGaps(
    const llvm::RegionMelder::BlockAlignment &native, llvm::BasicBlock *left,
    llvm::BasicBlock *right, AnchorGapOrder order) {
  using namespace llvm;
  if (order == AnchorGapOrder::Native) return native;

  DenseMap<Value *, unsigned> swRank;
  if (order == AnchorGapOrder::SW) {
    SmallVector<Value *, 32> l{left}, r{right};
    for (auto &i : *left) l.push_back(&i);
    for (auto &i : *right) r.push_back(&i);
    InstrMeldingProfitabilityModel model;
    SmithWaterman<Value *, SmallVectorImpl<Value *>, nullptr> sw(model);
    auto reference = sw.compute(l, r);
    unsigned rank = 0;
    for (const auto &entry : reference) {
      if (auto *v = entry.getLeft()) swRank[v] = rank;
      if (auto *v = entry.getRight()) swRank[v] = rank;
      ++rank;
    }
  }

  RegionMelder::BlockAlignment result;
  result.reserve(native.size());
  const AlignedPair<Value *> *previous = nullptr;
  for (auto first = native.begin(); first != native.end();) {
    if (first->match()) {
      previous = &*first;
      result.push_back(*first++);
      continue;
    }
    auto last = std::find_if(first, native.end(), [](const auto &p) { return p.match(); });
    SmallVector<Value *, 16> gap[2];
    SmallPtrSet<Value *, 32> pending, readDependent;
    SmallVector<Value *, 16> ordered;
    for (auto i = first; i != last; ++i) {
      auto *v = i->getLeft() ? i->getLeft() : i->getRight();
      gap[i->getLeft() ? 0 : 1].push_back(v);
      pending.insert(v);
      auto &inst = *cast<Instruction>(v);
      if (inst.mayReadOrWriteMemory() || inst.mayHaveSideEffects())
        ordered.push_back(v);
      if (inst.mayReadFromMemory()) readDependent.insert(v);
    }
    if (order == AnchorGapOrder::Latency) {
      if (previous)
        for (auto *value : {previous->getLeft(), previous->getRight()})
          if (auto *inst = dyn_cast<Instruction>(value))
            if (inst->mayReadFromMemory()) readDependent.insert(value);
      // Prioritize work independent of outstanding reads so it can overlap
      // their latency, especially when occupancy cannot hide those waits.
      bool changed;
      do {
        changed = false;
        for (const auto &side : gap)
          for (auto *value : side) {
            auto *inst = cast<Instruction>(value);
            if (!isa<PHINode>(inst) && llvm::any_of(inst->operands(), [&](const Use &use) {
                  return readDependent.contains(use.get());
                }))
              changed |= readDependent.insert(value).second;
          }
      } while (changed);
    }

    unsigned cursor[2] = {}, nextOrdered = 0;
    const auto begin = result.size();
    while (!pending.empty()) {
      int best = -1;
      unsigned bestRank = 0;
      for (int side = 0; side != 2; ++side) {
        if (cursor[side] == gap[side].size()) continue;
        auto *value = gap[side][cursor[side]];
        unsigned rank = swRank.lookup(value);
        if (order == AnchorGapOrder::Latency) {
          auto *inst = cast<Instruction>(value);
          if ((inst->mayReadOrWriteMemory() || inst->mayHaveSideEffects()) &&
              ordered[nextOrdered] != value)
            continue;
          if (!isa<PHINode>(inst) && llvm::any_of(inst->operands(), [&](const Use &use) {
                return pending.contains(use.get());
              }))
            continue;
          rank = readDependent.contains(value) ? 1 : 0;
        }
        // SW's zero-score diagonal emits its left gap before its right gap.
        if (best < 0 || rank < bestRank) { best = side; bestRank = rank; }
      }
      if (best < 0) {
        result.erase(result.begin() + begin, result.end());
        result.insert(result.end(), first, last);
        break;
      }
      auto *value = gap[best][cursor[best]++];
      pending.erase(value);
      if (nextOrdered < ordered.size() && ordered[nextOrdered] == value) ++nextOrdered;
      result.emplace_back(best == 0 ? value : nullptr, best == 1 ? value : nullptr);
    }
    first = last;
  }
  return result;
}

inline std::optional<llvm::RegionMelder::BlockAlignment> alignRegionBlocks(
    llvm::BasicBlock *left, llvm::BasicBlock *right,
    const llvm::RegionMelder::BlockMap &mapping,
    llvm::BasicBlock *leftExit, llvm::BasicBlock *rightExit, bool pairTies,
    llvm::function_ref<bool(llvm::Instruction &, llvm::Instruction &)> compatible,
    llvm::function_ref<int(const llvm::Instruction &)> instructionCost,
    llvm::function_ref<int(llvm::Type *)> selectCost,
    llvm::function_ref<int(llvm::Type *)> phiCost, std::string &fallback, int forkCost, AnchorGapOrder order) {
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
  if (order == AnchorGapOrder::Native) return result;
  return reorderRegionGaps(result, left, right, order);
}

} // namespace fusion
