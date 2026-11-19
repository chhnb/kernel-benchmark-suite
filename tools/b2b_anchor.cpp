#include "b2b_anchor.h"

#include "llvm/ADT/DenseMap.h"
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

SmallVector<AnchorPlan, 4> planB2BAnchors(
    Work left, Work right, BasicBlock &leftBlock, BasicBlock &rightBlock,
    BasicBlock *join, function_ref<bool(Instruction &, Instruction &)> compatible,
    function_ref<int(const Instruction &)> instructionCost,
    function_ref<int(Type *)> selectCost) {
  const std::array<Work, 2> work{left, right};
  DenseMap<const Value *, unsigned> indices[2];
  for (unsigned side = 0; side != 2; ++side)
    for (unsigned k = 0; k != work[side].size(); ++k)
      indices[side].insert({work[side][k], k});

  std::vector<int> partners[2] = {
      std::vector<int>(left.size(), -1), std::vector<int>(right.size(), -1)};
  Matches proposed;
  unsigned conflicts = 0;
  auto seed = [&](Value *lv, Value *rv) {
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
    partners[0][i] = j;
    partners[1][j] = i;
    proposed.push_back({i, j});
  };
  if (join)
    for (auto &phi : join->phis())
      seed(phi.getIncomingValueForBlock(&leftBlock),
           phi.getIncomingValueForBlock(&rightBlock));
  for (auto *l : left)
    if (auto *store = dyn_cast<StoreInst>(l))
      for (auto *r : right)
        if (auto *other = dyn_cast<StoreInst>(r))
          if (store->getPointerOperand() == other->getPointerOperand())
            seed(store, other);

  auto couldPropagate = [&](Value *lv, Value *rv) {
    auto l = indices[0].find(lv), r = indices[1].find(rv);
    if (l == indices[0].end() || r == indices[1].end())
      return false;
    return partners[0][l->second] == int(r->second) ||
           (partners[0][l->second] == -1 && partners[1][r->second] == -1 &&
            compatible(*left[l->second], *right[r->second]));
  };
  for (unsigned k = 0; k < proposed.size(); ++k) {
    auto *l = left[proposed[k].left], *r = right[proposed[k].right];
    bool swapped = false;
    if (l->isBinaryOp() && l->isCommutative() && r->isCommutative()) {
      auto count = [&](unsigned offset) {
        return unsigned(couldPropagate(l->getOperand(0), r->getOperand(offset))) +
               unsigned(couldPropagate(l->getOperand(1), r->getOperand(1 ^ offset)));
      };
      swapped = count(1) > count(0);
    }
    proposed[k].swapped = swapped;
    for (unsigned n = 0; n < l->getNumOperands(); ++n)
      seed(l->getOperand(n), r->getOperand(n ^ unsigned(swapped)));
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
          if (i == le || j == re || !compatible(*left[i], *right[j]))
            continue;
          State shared = state;
          AnchorMatch pair{i, j};
          shared.score += instructionCost(*left[i]) - addedCost(pair, state.pairs);
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

  SmallVector<AnchorPlan, 4> result;
  auto add = [&](Matches pairs, unsigned pruned) {
    if (!llvm::any_of(result, [&](const AnchorPlan &plan) { return plan.matches == pairs; }))
      result.push_back({std::move(pairs), unsigned(anchors.size()),
                        unsigned(proposed.size() - anchors.size()), conflicts, segments, pruned});
  };
  for (const auto &state : beam) {
    add(state.pairs, 0);
    Matches pruned = state.pairs;
    size_t previous;
    do {
      previous = pruned.size();
      for (unsigned j = pruned.size(); j > 0; --j) {
        auto pair = pruned[j - 1];
        if (addedCost(pair, pruned) >= instructionCost(*left[pair.left]))
          pruned.erase(pruned.begin() + j - 1);
      }
    } while (pruned.size() != previous);
    add(pruned, state.pairs.size() - pruned.size());
  }
  return result;
}
}
