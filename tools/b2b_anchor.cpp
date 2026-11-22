#include "b2b_anchor.h"
#include "b2b_anchor_observe.h"

#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/DenseSet.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Analysis/ValueTracking.h"
#include <algorithm>
#include <array>
#include <cstdint>
#include <vector>

using namespace llvm;
namespace fusion {
namespace {
using Matches = SmallVector<AnchorMatch, 8>;
using Work = ArrayRef<Instruction *>;
using OperandPair = std::pair<Value *, Value *>;

struct State {
  Matches pairs;
  unsigned guardedSides = 0;
  int64_t score = 0;
  unsigned chargedSegments = 0;
  int64_t phiCharge = 0;

  ObservedAnchorState observation() const { return {pairs, score, chargedSegments, phiCharge}; }
};
using Beam = SmallVector<State, 4>;

AnchorInsertion insert(Beam &beam, State state, B2BObservation *observe = nullptr,
                 StringRef phase = {}, unsigned i = 0, unsigned j = 0) {
  if (llvm::any_of(beam, [&](const State &old) { return old.pairs == state.pairs; }))
    return AnchorInsertion::Duplicate;
  auto position = llvm::find_if(beam, [&](const State &old) {
    return state.score > old.score ||
           (state.score == old.score && state.pairs.size() > old.pairs.size());
  });
  const bool accepted = beam.size() < 4 || position != beam.end();
  beam.insert(position, std::move(state));
  if (beam.size() > 4) {
    if (observe && accepted)
      observe->evict(beam.back().observation(), phase, i, j);
    beam.pop_back();
  }
  return accepted ? AnchorInsertion::Kept : AnchorInsertion::Pruned;
}


}

SmallVector<int, 32> b2bGuardOrigins(Work work) {
  SmallVector<int, 32> origins;
  DenseMap<const Value *, int> latestRoot;
  for (auto item : llvm::enumerate(work)) {
    auto *inst = item.value();
    const auto *load = dyn_cast<LoadInst>(inst);
    const auto *store = dyn_cast<StoreInst>(inst);
    int root = (load && load->isSimple()) || (store && store->isSimple()) ? int(item.index()) : -1;
    for (const auto &operand : inst->operands()) {
      auto known = latestRoot.find(operand.get());
      if (known != latestRoot.end())
        root = std::max(root, known->second);
    }
    latestRoot[inst] = root;
    origins.push_back(root);
  }
  return origins;
}

SmallVector<AnchorPlan, 3> planB2BAnchors(
    Work left, Work right, BasicBlock &leftBlock, BasicBlock &rightBlock,
    BasicBlock *join, bool pairTies, function_ref<bool(Instruction &, Instruction &)> compatible,
    function_ref<int(const Instruction &)> instructionCost,
    function_ref<int(Type *)> selectCost, function_ref<int(Type *)> phiCost, bool linear) {
  B2BObservation observe;
  const std::array<Work, 2> work{left, right};
  DenseMap<const Value *, unsigned> indices[2];
  SmallVector<bool, 32> skippable[2];
  SmallVector<int, 32> guardOrigins[2];
  auto canSkip = [&](unsigned side, unsigned i) {
    return !linear || skippable[side][i] ||
        (linear && guardOrigins[side][i] == int(i));
  };
  if (linear)
    for (unsigned side = 0; side != 2; ++side) {
      guardOrigins[side] = b2bGuardOrigins(work[side]);
      for (auto item : llvm::enumerate(work[side])) {
        const auto *inst = item.value();
        const auto *call = dyn_cast<CallBase>(inst);
        skippable[side].push_back(!inst->mayReadOrWriteMemory() &&
                                  !(call && call->isConvergent()) &&
                                  !isa<AllocaInst>(inst) &&
                                  isSafeToSpeculativelyExecute(inst));
      }
    }

  for (unsigned side = 0; side != 2; ++side)
    for (unsigned k = 0; k != work[side].size(); ++k)
      indices[side].insert({work[side][k], k});

  Matches proposed, cutoffs;
  unsigned conflicts = 0;
  std::vector<int> partners[2] = {
      std::vector<int>(left.size(), -1), std::vector<int>(right.size(), -1)};
  auto couldPropagate = [&](Value *lv, Value *rv) {
    auto l = indices[0].find(lv), r = indices[1].find(rv);
    if (l == indices[0].end() || r == indices[1].end())
      return false;
    return partners[0][l->second] == int(r->second) ||
           (partners[0][l->second] == -1 && partners[1][r->second] == -1 &&
            compatible(*left[l->second], *right[r->second]));
  };
  auto seed = [&](Value *lv, Value *rv, int outputSelectCost) {
    auto l = indices[0].find(lv), r = indices[1].find(rv);
    if (l == indices[0].end() || r == indices[1].end() ||
        !compatible(*left[l->second], *right[r->second]))
      return;
    const auto i = l->second, j = r->second;
    if (partners[0][i] == int(j))
      return;
    if (partners[0][i] != -1 || partners[1][j] != -1) {
      ++conflicts;
      if (observe)
        observe.conflict({i, j});
      return;
    }
    auto *li = left[i], *ri = right[j];
    bool swapped = false;
    if (li->isBinaryOp() && li->isCommutative() && ri->isCommutative()) {
      auto count = [&](unsigned offset) {
        return unsigned(couldPropagate(li->getOperand(0), ri->getOperand(offset))) +
               unsigned(couldPropagate(li->getOperand(1), ri->getOperand(1 ^ offset)));
      };
      swapped = count(1) > count(0);
    }
    int inputSelectCost = 0;
    for (unsigned n = 0; n < li->getNumOperands(); ++n) {
      auto *lOp = li->getOperand(n), *rOp = ri->getOperand(n ^ unsigned(swapped));
      if (lOp != rOp && !couldPropagate(lOp, rOp))
        inputSelectCost += selectCost(lOp->getType());
    }
    const int extra = inputSelectCost - outputSelectCost;
    const int cost = instructionCost(*li);
    if (extra > cost || (!pairTies && extra == cost)) {
      cutoffs.push_back({i, j, swapped});
      return;
    }
    partners[0][i] = j;
    partners[1][j] = i;
    proposed.push_back({i, j, swapped});
  };
  if (join)
    for (auto &phi : join->phis())
      seed(phi.getIncomingValueForBlock(&leftBlock),
           phi.getIncomingValueForBlock(&rightBlock), phiCost(phi.getType()));
  for (auto *l : left)
    if (auto *store = dyn_cast<StoreInst>(l))
      for (auto *r : right)
        if (auto *other = dyn_cast<StoreInst>(r))
          if (store->getPointerOperand() == other->getPointerOperand())
            seed(store, other, 0);

  for (unsigned k = 0; k < proposed.size(); ++k) {
    const auto pair = proposed[k];
    auto *l = left[pair.left], *r = right[pair.right];
    for (unsigned n = 0; n < l->getNumOperands(); ++n) {
      auto *op = l->getOperand(n);
      auto *other = r->getOperand(n ^ unsigned(pair.swapped));
      if (op != other && indices[0].count(op) && indices[1].count(other))
        seed(op, other, selectCost(op->getType()));
    }
  }

  llvm::sort(proposed, [](auto a, auto b) { return a.left < b.left; });
  struct Chain {
    int64_t weight;
    unsigned length;
    int previous;
  };
  std::vector<Chain> chains;
  int best = -1;
  auto rank = [](const Chain &chain) {
    return std::make_pair(chain.weight, chain.length);
  };
  for (unsigned k = 0; k < proposed.size(); ++k) {
    const int cost = instructionCost(*left[proposed[k].left]);
    Chain chain{cost, 1, -1};
    for (unsigned p = 0; p < k; ++p)
      if (proposed[p].right < proposed[k].right) {
        Chain extension{chains[p].weight + cost, chains[p].length + 1, int(p)};
        if (rank(extension) > rank(chain))
          chain = extension;
      }
    chains.push_back(chain);
    if (best < 0 || rank(chain) > rank(chains[best]))
      best = k;
  }
  Matches anchors;
  for (int k = best; k >= 0; k = chains[k].previous)
    anchors.push_back(proposed[k]);
  std::reverse(anchors.begin(), anchors.end());

  auto pairedValues = [&](Value *lv, Value *rv, ArrayRef<AnchorMatch> pairs) {
    return llvm::any_of(pairs, [&](AnchorMatch producer) {
      return left[producer.left] == lv && right[producer.right] == rv;
    });
  };
  auto forInputSelect = [&](AnchorMatch pair, ArrayRef<AnchorMatch> earlier, auto visit) {
    auto *l = left[pair.left], *r = right[pair.right];
    for (unsigned n = 0; n < l->getNumOperands(); ++n) {
      auto *lv = l->getOperand(n), *rv = r->getOperand(n ^ unsigned(pair.swapped));
      if (lv != rv && !pairedValues(lv, rv, earlier))
        visit(OperandPair{lv, rv});
    }
  };
  auto addedCost = [&](AnchorMatch pair, const State &state) {
    int cost = 0;
    forInputSelect(pair, state.pairs, [&](OperandPair inputs) {
      cost += selectCost(inputs.first->getType());
    });
    return cost;
  };
  auto appendPair = [&](State &state, AnchorMatch pair, int gain) {
    state.score += gain;
    state.pairs.push_back(pair);
  };

  DenseSet<std::pair<unsigned, unsigned>> cutPairs;
  for (const auto &cut : cutoffs)
    cutPairs.insert({cut.left, cut.right});
  Beam beam(1);
  State anchorsOnly;
  bool anchorsOnlyLegal = true;
  DenseSet<std::pair<unsigned, unsigned>> seenForwardCut;
  Matches forwardCutoffs;
  auto hasSharedConsumer = [&](Instruction *l, Instruction *r) {
    return llvm::any_of(l->uses(), [&](const Use &leftUse) {
      auto *leftUser = dyn_cast<Instruction>(leftUse.getUser());
      if (!leftUser || !indices[0].count(leftUser))
        return false;
      return llvm::any_of(r->uses(), [&](const Use &rightUse) {
        auto *rightUser = dyn_cast<Instruction>(rightUse.getUser());
        return rightUser && indices[1].count(rightUser) &&
               leftUse.getOperandNo() == rightUse.getOperandNo() &&
               compatible(*leftUser, *rightUser);
      });
    });
  };
  // An arm-local use at or beyond the boundary keeps a value live.
  // Any use outside this arm also crosses the boundary.
  std::vector<unsigned> lastUse[2];
  std::vector<int> phiPrice[2];
  for (unsigned side = 0; side != 2; ++side) {
    for (auto *inst : work[side]) {
      unsigned last = indices[side].lookup(inst);
      for (const auto *user : inst->users()) {
        auto pos = indices[side].find(user);
        last = std::max(last, pos == indices[side].end() ? unsigned(work[side].size()) : pos->second);
      }
      lastUse[side].push_back(last);
      phiPrice[side].push_back(inst->getType()->isVoidTy() ? 0 : phiCost(inst->getType()));
    }
  }
  // Charge once when leaving a match, or at settlement for a fallback
  // that bypasses the grid. The PHI term still needs the end boundary.
  constexpr int ForkCharge = 2;
  auto skip = [&](State state, Beam &dest, StringRef phase, unsigned i, unsigned j,
                  unsigned side, unsigned index) {
    if (linear && guardOrigins[side][index] == int(index) &&
        !(state.guardedSides & (1u << side))) {
      state.score -= ForkCharge;
      state.guardedSides |= 1u << side;
    }
    insert(dest, std::move(state), observe ? &observe : nullptr, phase, i, j);
  };
  auto finishGap = [&](State &state, unsigned le, unsigned re, bool rejoins) {
    unsigned begin[2] = {};
    if (!state.pairs.empty()) {
      begin[0] = state.pairs.back().left + 1;
      begin[1] = state.pairs.back().right + 1;
    }
    if (begin[0] == le && begin[1] == re)
      return;
    const unsigned end[2] = {le, re};
    if (linear) {
      for (unsigned side = 0; side != 2; ++side) {
        bool hasGuard = false;
        for (unsigned k = begin[side]; k < end[side]; ++k)
          if (guardOrigins[side][k] >= int(begin[side])) {
            hasGuard = true;
            if (lastUse[side][k] >= end[side]) {
              state.phiCharge += phiPrice[side][k];
              state.score -= phiPrice[side][k];
            }
          }
        if (hasGuard) {
          ++state.chargedSegments;
          // Empty/anchors-only paths settle without going through skip().
          if (!(state.guardedSides & (1u << side)))
            state.score -= ForkCharge;
        }
      }
      state.guardedSides = 0;
      return;
    }
    ++state.chargedSegments;
    state.score -= ForkCharge;
    if (!rejoins)
      return; // The original exit PHIs already receive values from both arms.
    int64_t charge = 0;
    for (unsigned side = 0; side != 2; ++side)
      for (unsigned k = begin[side]; k < end[side]; ++k)
        if (lastUse[side][k] >= end[side])
          charge += phiPrice[side][k];
    state.phiCharge += charge;
    state.score -= charge;
  };

  unsigned li = 0, ri = 0, segments = 0;
  auto trim = [&](Beam &states, StringRef phase) {
    if (states.size() <= 2) return;
    if (observe)
      for (const auto &state : ArrayRef<State>(states).drop_front(2))
        observe.prune(state.observation(), phase);
    states.resize(2);
  };
  auto align = [&](unsigned le, unsigned re, bool rejoins) {
    if (li == le && ri == re)
      return;
    ++segments;
    if (observe)
      observe.segment(li, ri, le, re, rejoins);
    // Keep an empty alignment even if the beam prefers several matches.
    // Map-Airy commit 10 previously preferred the candidate with fewer
    // pairs after cleanup, which is not represented by pair scores alone.
    Beam empty;
    bool emptyLegal = true;
    const unsigned begin[] = {li, ri}, end[] = {le, re};
    for (unsigned side = 0; side != 2; ++side)
      for (unsigned i = begin[side]; i != end[side]; ++i)
        emptyLegal &= canSkip(side, i);
    if (emptyLegal) {
      for (auto state : beam) {
        finishGap(state, le, re, rejoins);
        insert(empty, std::move(state));
      }
      finishGap(anchorsOnly, le, re, rejoins);
    }
    anchorsOnlyLegal &= emptyLegal;
    if (li == le || ri == re) {
      beam = std::move(empty);
      return;
    }
    const unsigned width = re - ri + 1;
    std::vector<Beam> row(width), next(width);
    row[0].swap(beam);
    for (unsigned i = li; i <= le; ++i) {
      for (unsigned j = ri; j <= re; ++j) {
        for (const auto &state : row[j - ri]) {
          if (i < le && canSkip(0, i))
            skip(state, next[j - ri], "skip_left", i + 1, j, 0, i);
          if (j < re && canSkip(1, j))
            skip(state, row[j + 1 - ri], "skip_right", i, j + 1, 1, j);
          if (i == le || j == re)
            continue;
          AnchorMatch pair{i, j};
          if (cutPairs.count({i, j})) {
            if (observe)
              observe.transition(pair, state.observation(), instructionCost(*left[i]),
                               addedCost(pair, state), "cutPairs");
            continue;
          }
          if (!compatible(*left[i], *right[j]))
            continue;
          const int inputCost = addedCost(pair, state);
          const int cost = instructionCost(*left[i]);
          const int gain = cost - inputCost;
          // Producers can also be reached solely from a forward segment
          // when their consumers feed different exit PHI positions.
          auto *resultType = left[i]->getType();
          const int unpaired = resultType->isVoidTy() ? 0 : selectCost(resultType);
          const int net = gain + unpaired;
          if (!pairTies && gain <= 0 && !resultType->isVoidTy() &&
              net <= 0 && hasSharedConsumer(left[i], right[j])) {
            if (seenForwardCut.insert({i, j}).second)
              forwardCutoffs.push_back(pair);
            if (observe)
              observe.transition(pair, state.observation(), cost, inputCost, "forward_cutoff");
            continue;
          }
          State shared = state;
          finishGap(shared, i, j, true);
          appendPair(shared, pair, gain);
          const auto outcome = insert(next[j + 1 - ri], std::move(shared),
                                      observe ? &observe : nullptr, "pair", i + 1, j + 1);
          if (observe)
            observe.transition(pair, state.observation(), cost, inputCost, outcome);
        }
      }
      if (i != le) {
        row.swap(next);
        for (auto &cell : next)
          cell.clear();
      }
    }
    for (auto &state : row.back()) {
      finishGap(state, le, re, rejoins);
      insert(beam, std::move(state));
    }
    trim(beam, "segment_limit");
    if (!empty.empty())
      insert(beam, std::move(empty.front()));
  };
  auto appendAnchor = [&](State &state, AnchorMatch anchor) {
    const int cost = instructionCost(*left[anchor.left]);
    const int inputs = addedCost(anchor, state);
    if (observe)
      observe.transition(anchor, state.observation(), cost, inputs, "forced_anchor");
    appendPair(state, anchor, cost - inputs);
  };
  for (auto anchor : anchors) {
    align(anchor.left, anchor.right, true);
    for (auto &state : beam)
      appendAnchor(state, anchor);
    if (anchorsOnlyLegal)
      appendAnchor(anchorsOnly, anchor);
    llvm::stable_sort(beam, [](const State &a, const State &b) {
      return a.score > b.score ||
             (a.score == b.score && a.pairs.size() > b.pairs.size());
    });
    li = anchor.left + 1;
    ri = anchor.right + 1;
  }
  align(left.size(), right.size(), !join);

  if (linear && join) {
    auto chargeJoin = [&](State &state) {
      // Exit selects can reuse the actual input selects emitted for matches.
      DenseSet<OperandPair> charged;
      ArrayRef<AnchorMatch> pairs = state.pairs;
      for (auto item : llvm::enumerate(pairs))
        forInputSelect(item.value(), pairs.take_front(item.index()),
                       [&](OperandPair inputs) { charged.insert(inputs); });
      for (auto &phi : join->phis()) {
        auto *lv = phi.getIncomingValueForBlock(&leftBlock);
        auto *rv = phi.getIncomingValueForBlock(&rightBlock);
        if (lv != rv && !pairedValues(lv, rv, state.pairs) && charged.insert({lv, rv}).second)
          state.score -= selectCost(phi.getType());
      }
    };
    Beam ranked;
    for (auto &state : beam) {
      chargeJoin(state);
      insert(ranked, std::move(state));
    }
    beam = std::move(ranked);
    if (anchorsOnlyLegal) chargeJoin(anchorsOnly);
  }
  trim(beam, "final_limit");
  if (anchorsOnlyLegal)
    insert(beam, std::move(anchorsOnly));
  if (observe) {
    for (const auto &state : beam)
      observe.plan(state.observation());
    observe.write(left, right, leftBlock, rightBlock, pairTies, linear, proposed, anchors,
                  cutoffs, forwardCutoffs, conflicts, instructionCost, selectCost, phiCost, canSkip);
  }
  SmallVector<AnchorPlan, 3> result;
  for (auto &state : beam) {
    AnchorPlan plan{std::move(state.pairs), anchors, cutoffs, forwardCutoffs,
                    state.chargedSegments, state.phiCharge, state.score,
                    unsigned(proposed.size() - anchors.size()), conflicts, segments,
                    {}};
    if (linear) {
      unsigned begin[2] = {};
      auto describeGap = [&](unsigned le, unsigned re) {
        if (begin[0] == le && begin[1] == re) return;
        const unsigned end[] = {le, re};
        bool hasGuard = false;
        for (unsigned side = 0; side != 2; ++side)
          for (unsigned i = begin[side]; i < end[side]; ++i)
            hasGuard |= guardOrigins[side][i] >= int(begin[side]);
        plan.gapPlacements.push_back(hasGuard ? AnchorGapPlacement::HoistAndGuard
                                              : AnchorGapPlacement::Hoist);
      };
      for (auto match : plan.matches) {
        describeGap(match.left, match.right);
        begin[0] = match.left + 1;
        begin[1] = match.right + 1;
      }
      describeGap(left.size(), right.size());
    }
    result.push_back(std::move(plan));
  }
  return result;
}
}
