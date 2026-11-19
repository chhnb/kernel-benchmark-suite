#include "b2b_anchor.h"

#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/DenseSet.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/IR/Instructions.h"
#include <algorithm>
#include <array>
#include <cstdint>
#include <vector>

using namespace llvm;
namespace fusion {
namespace {
using Matches = SmallVector<AnchorMatch, 8>;
using Work = ArrayRef<Instruction *>;

struct State {
  Matches pairs;
  int64_t score = 0;
};
using Beam = SmallVector<State, 4>;

void insert(Beam &beam, State state) {
  if (llvm::any_of(beam, [&](const State &old) { return old.pairs == state.pairs; }))
    return;
  auto position = llvm::find_if(beam, [&](const State &old) {
    return state.score > old.score ||
           (state.score == old.score && state.pairs.size() > old.pairs.size());
  });
  beam.insert(position, std::move(state));
  if (beam.size() > 4)
    beam.pop_back();
}
}

SmallVector<AnchorPlan, 2> planB2BAnchors(
    Work left, Work right, BasicBlock &leftBlock, BasicBlock &rightBlock,
    BasicBlock *join, bool allowTie, function_ref<bool(Instruction &, Instruction &)> compatible,
    function_ref<int(const Instruction &)> instructionCost,
    function_ref<int(Type *)> selectCost) {
  const std::array<Work, 2> work{left, right};
  DenseMap<const Value *, unsigned> indices[2];
  for (unsigned side = 0; side != 2; ++side)
    for (unsigned k = 0; k != work[side].size(); ++k)
      indices[side].insert({work[side][k], k});

  std::vector<int> partners[2] = {
      std::vector<int>(left.size(), -1), std::vector<int>(right.size(), -1)};
  Matches proposed, cutoffs;
  unsigned conflicts = 0;
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
    if (extra > cost || (!allowTie && extra == cost)) {
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
           phi.getIncomingValueForBlock(&rightBlock), selectCost(phi.getType()));
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

  auto addedCost = [&](AnchorMatch pair, ArrayRef<AnchorMatch> pairs) {
    auto *l = left[pair.left], *r = right[pair.right];
    int cost = 0;
    for (unsigned n = 0; n < l->getNumOperands(); ++n) {
      auto *lv = l->getOperand(n), *rv = r->getOperand(n ^ unsigned(pair.swapped));
      if (lv == rv)
        continue;
      if (!llvm::any_of(pairs, [&](AnchorMatch producer) {
            return left[producer.left] == lv && right[producer.right] == rv;
          }))
        cost += selectCost(lv->getType());
    }
    return cost;
  };

  DenseSet<std::pair<unsigned, unsigned>> cutPairs;
  for (auto pair : cutoffs)
    cutPairs.insert({pair.left, pair.right});
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
  Beam beam(1);
  unsigned li = 0, ri = 0, segments = 0;
  auto align = [&](unsigned le, unsigned re) {
    if (li == le || ri == re) {
      segments += li != le || ri != re;
      return;
    }
    ++segments;
    const unsigned width = re - ri + 1;
    std::vector<Beam> row(width), next(width);
    row[0] = std::move(beam);
    for (unsigned i = li; i <= le; ++i) {
      for (unsigned j = ri; j <= re; ++j)
        for (const auto &state : row[j - ri]) {
          if (i < le)
            insert(next[j - ri], state);
          if (j < re)
            insert(row[j + 1 - ri], state);
          if (i == le || j == re || cutPairs.count({i, j}) ||
              !compatible(*left[i], *right[j]))
            continue;
          AnchorMatch pair{i, j};
          const int inputCost = addedCost(pair, state.pairs);
          const int gain = instructionCost(*left[i]) - inputCost;
          // A producer can be reached solely from a forward segment when
          // its consumers are on different PHI edges. Apply the strict
          // cutoff to that case as well, using known earlier pairings.
          auto *resultType = left[i]->getType();
          if (!allowTie && gain <= 0 && !resultType->isVoidTy() &&
              gain + selectCost(resultType) <= 0 && hasSharedConsumer(left[i], right[j]))
            continue;
          State shared = state;
          shared.score += gain;
          shared.pairs.push_back(pair);
          insert(next[j + 1 - ri], std::move(shared));
        }
      if (i != le) {
        row.swap(next);
        for (auto &cell : next)
          cell.clear();
      }
    }
    beam = std::move(row.back());
    if (beam.size() > 2)
      beam.resize(2);
  };
  for (auto anchor : anchors) {
    align(anchor.left, anchor.right);
    for (auto &state : beam) {
      state.score += instructionCost(*left[anchor.left]) - addedCost(anchor, state.pairs);
      state.pairs.push_back(anchor);
    }
    llvm::stable_sort(beam, [](const State &a, const State &b) {
      return a.score > b.score ||
             (a.score == b.score && a.pairs.size() > b.pairs.size());
    });
    li = anchor.left + 1;
    ri = anchor.right + 1;
  }
  align(left.size(), right.size());

  SmallVector<AnchorPlan, 2> result;
  for (auto &state : beam)
    result.push_back({std::move(state.pairs), anchors, cutoffs,
                      unsigned(proposed.size() - anchors.size()), conflicts, segments});
  return result;
}
}
