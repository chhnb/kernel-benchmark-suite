#include "b2b_anchor.h"

#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/DenseSet.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/raw_ostream.h"
#include <algorithm>
#include <array>
#include <cstdint>
#include <cstdlib>
#include <stdexcept>
#include <vector>

using namespace llvm;
namespace fusion {
namespace {
using Matches = SmallVector<AnchorMatch, 8>;
using Work = ArrayRef<Instruction *>;
using OperandPair = std::pair<Value *, Value *>;
using NewCharges = SmallVector<OperandPair, 4>;

struct State {
  Matches pairs;
  DenseSet<OperandPair> charged;
  unsigned guardedSides = 0;
  int64_t score = 0;
  unsigned chargedSegments = 0;
  int64_t phiCharge = 0;
};
using Beam = SmallVector<State, 4>;

enum class Insertion { Duplicate, Pruned, Kept };

json::Object matchJSON(AnchorMatch pair) {
  return json::Object{{"left", int64_t(pair.left)}, {"right", int64_t(pair.right)},
                      {"swapped", pair.swapped}};
}

json::Array matchesJSON(ArrayRef<AnchorMatch> matches) {
  json::Array result;
  for (auto pair : matches)
    result.push_back(matchJSON(pair));
  return result;
}

json::Object stateJSON(const State &state) {
  return json::Object{{"pairs", matchesJSON(state.pairs)}, {"score", state.score},
                      {"chargedSegments", int64_t(state.chargedSegments)},
                      {"phiCharge", state.phiCharge}};
}

Insertion insert(Beam &beam, State state, json::Array *pruned = nullptr,
                 StringRef phase = {}, unsigned i = 0, unsigned j = 0) {
  if (llvm::any_of(beam, [&](const State &old) { return old.pairs == state.pairs; }))
    return Insertion::Duplicate;
  auto position = llvm::find_if(beam, [&](const State &old) {
    return state.score > old.score ||
           (state.score == old.score && state.pairs.size() > old.pairs.size());
  });
  const bool accepted = beam.size() < 4 || position != beam.end();
  beam.insert(position, std::move(state));
  if (beam.size() > 4) {
    if (pruned && accepted) {
      auto event = stateJSON(beam.back());
      event["phase"] = phase;
      event["left_boundary"] = int64_t(i);
      event["right_boundary"] = int64_t(j);
      pruned->push_back(std::move(event));
    }
    beam.pop_back();
  }
  return accepted ? Insertion::Kept : Insertion::Pruned;
}

StringRef insertionName(Insertion result) {
  if (result == Insertion::Kept) return "inserted";
  if (result == Insertion::Duplicate) return "duplicate";
  return "beam_reject";
}

std::string operandName(const Value &value) {
  std::string text;
  raw_string_ostream stream(text);
  value.printAsOperand(stream, false);
  return stream.str();
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
    function_ref<int(Type *)> selectCost, function_ref<int(Type *)> phiCost, bool linear,
    AnchorScoring scoring) {
  const bool guarded = scoring.guardedGap && linear;
  // G0 retained an independent unguarded beam. A unified traversal must
  // preserve its pruning history even when memory-skipping states rank higher.
  const unsigned projections = scoring.unifiedGap && guarded ? 2 : 1;
  auto allowsGuard = [&](unsigned projection) { return guarded && (projections == 1 || projection == 1); };
  const char *tracePath = std::getenv("FUSION_OBSERVE_B2B_DP");
  const bool observe = tracePath && *tracePath;
  json::Array transitions, pruned, conflictingPairs, segmentsObserved;
  const std::array<Work, 2> work{left, right};
  DenseMap<const Value *, unsigned> indices[2];
  SmallVector<bool, 32> skippable[2];
  SmallVector<int, 32> guardOrigins[2];
  auto canSkip = [&](unsigned side, unsigned i, unsigned projection) {
    return !linear || skippable[side][i] ||
        (allowsGuard(projection) && guardOrigins[side][i] == int(i));
  };
  if (linear)
    for (unsigned side = 0; side != 2; ++side) {
      if (guarded)
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
        conflictingPairs.push_back(matchJSON({i, j}));
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
  auto addedCost = [&](AnchorMatch pair, const State &state, NewCharges &newCharges) {
    int cost = 0;
    forInputSelect(pair, state.pairs, [&](OperandPair inputs) {
      if (scoring.selectDedup) {
        if (state.charged.count(inputs) || llvm::is_contained(newCharges, inputs))
          return;
        newCharges.push_back(inputs);
      }
      cost += selectCost(inputs.first->getType());
    });
    return cost;
  };
  auto appendPair = [&](State &state, AnchorMatch pair, const NewCharges &charges, int gain) {
    for (auto inputs : charges)
      state.charged.insert(inputs);
    state.score += gain;
    state.pairs.push_back(pair);
  };

  DenseSet<std::pair<unsigned, unsigned>> cutPairs;
  for (const auto &cut : cutoffs)
    cutPairs.insert({cut.left, cut.right});
  struct Projection {
    Beam beam = Beam(1);
    State anchorsOnly;
    bool anchorsOnlyLegal = true;
    DenseSet<std::pair<unsigned, unsigned>> seenForwardCut;
    Matches forwardCutoffs;
  };
  SmallVector<Projection, 2> runs(projections);
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
  for (unsigned side = 0; (!linear || guarded) && side != 2; ++side) {
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
                  unsigned side, unsigned index, unsigned projection) {
    if (allowsGuard(projection) && guardOrigins[side][index] == int(index) &&
        !(state.guardedSides & (1u << side))) {
      state.score -= ForkCharge;
      state.guardedSides |= 1u << side;
    }
    insert(dest, std::move(state), observe ? &pruned : nullptr, phase, i, j);
  };
  auto finishGap = [&](State &state, unsigned le, unsigned re, bool rejoins, unsigned projection) {
    const bool guarded = allowsGuard(projection);
    if (linear && !guarded) return;
    unsigned begin[2] = {};
    if (!state.pairs.empty()) {
      begin[0] = state.pairs.back().left + 1;
      begin[1] = state.pairs.back().right + 1;
    }
    if (begin[0] == le && begin[1] == re)
      return;
    const unsigned end[2] = {le, re};
    if (guarded) {
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
  auto recordTransition = [&](AnchorMatch pair, const State &state,
                              int cost, int inputs, StringRef reason) {
    auto event = matchJSON(pair);
    event["instructionCost"] = cost;
    event["inputCost"] = inputs;
    event["gain"] = cost - inputs;
    event["prior_score"] = state.score;
    event["prior_pairs"] = int64_t(state.pairs.size());
    event["outcome"] = reason;
    transitions.push_back(std::move(event));
  };
  auto trim = [&](Beam &states, StringRef phase) {
    if (states.size() <= 2) return;
    if (observe)
      for (const auto &state : ArrayRef<State>(states).drop_front(2)) {
        auto event = stateJSON(state);
        event["phase"] = phase;
        pruned.push_back(std::move(event));
      }
    states.resize(2);
  };
  auto align = [&](unsigned le, unsigned re, bool rejoins) {
    if (li == le && ri == re)
      return;
    ++segments;
    if (observe)
      segmentsObserved.push_back(json::Object{
          {"left_begin", int64_t(li)}, {"left_end", int64_t(le)},
          {"right_begin", int64_t(ri)}, {"right_end", int64_t(re)}, {"rejoins", rejoins}});
    // Keep an empty alignment even if the beam prefers several matches.
    // Map-Airy commit 10 previously preferred the candidate with fewer
    // pairs after cleanup, which is not represented by pair scores alone.
    using Cell = SmallVector<Beam, 1>;
    Cell empty(projections);
    for (unsigned projection = 0; projection != projections; ++projection) {
      auto &run = runs[projection];
      bool emptyLegal = true;
      const unsigned begin[] = {li, ri}, end[] = {le, re};
      for (unsigned side = 0; side != 2; ++side)
        for (unsigned i = begin[side]; i != end[side]; ++i)
          emptyLegal &= canSkip(side, i, projection);
      if (emptyLegal) {
        for (auto state : run.beam) {
          finishGap(state, le, re, rejoins, projection);
          insert(empty[projection], std::move(state));
        }
        finishGap(run.anchorsOnly, le, re, rejoins, projection);
      }
      run.anchorsOnlyLegal &= emptyLegal;
    }
    if (li == le || ri == re) {
      for (unsigned projection = 0; projection != projections; ++projection)
        runs[projection].beam = std::move(empty[projection]);
      return;
    }
    const unsigned width = re - ri + 1;
    std::vector<Cell> row(width, Cell(projections)), next(width, Cell(projections));
    for (unsigned projection = 0; projection != projections; ++projection)
      row[0][projection].swap(runs[projection].beam);
    for (unsigned i = li; i <= le; ++i) {
      for (unsigned j = ri; j <= re; ++j) {
        for (unsigned projection = 0; projection != projections; ++projection) {
          auto &run = runs[projection];
          for (const auto &state : row[j - ri][projection]) {
            if (i < le && canSkip(0, i, projection))
              skip(state, next[j - ri][projection], "skip_left", i + 1, j, 0, i, projection);
            if (j < re && canSkip(1, j, projection))
              skip(state, row[j + 1 - ri][projection], "skip_right", i, j + 1, 1, j, projection);
            if (i == le || j == re)
              continue;
            AnchorMatch pair{i, j};
            NewCharges newCharges;
            if (cutPairs.count({i, j})) {
              if (observe)
                recordTransition(pair, state, instructionCost(*left[i]),
                                 addedCost(pair, state, newCharges), "cutPairs");
              continue;
            }
            if (!compatible(*left[i], *right[j]))
              continue;
            const int inputCost = addedCost(pair, state, newCharges);
            const int cost = instructionCost(*left[i]);
            const int gain = cost - inputCost;
            // Producers can also be reached solely from a forward segment
            // when their consumers feed different exit PHI positions.
            auto *resultType = left[i]->getType();
            const int unpaired = resultType->isVoidTy() ? 0 : selectCost(resultType);
            const int net = gain + unpaired;
            if (!pairTies && gain <= 0 && !resultType->isVoidTy() &&
                net <= 0 && hasSharedConsumer(left[i], right[j])) {
              if (run.seenForwardCut.insert({i, j}).second)
                run.forwardCutoffs.push_back(pair);
              if (observe)
                recordTransition(pair, state, cost, inputCost, "forward_cutoff");
              continue;
            }
            State shared = state;
            finishGap(shared, i, j, true, projection);
            appendPair(shared, pair, newCharges, gain);
            const auto outcome = insert(next[j + 1 - ri][projection], std::move(shared),
                                        observe ? &pruned : nullptr, "pair", i + 1, j + 1);
            if (observe)
              recordTransition(pair, state, cost, inputCost, insertionName(outcome));
          }
        }
      }
      if (i != le) {
        row.swap(next);
        for (auto &cell : next)
          for (auto &beam : cell)
            beam.clear();
      }
    }
    for (unsigned projection = 0; projection != projections; ++projection) {
      auto &beam = runs[projection].beam;
      for (auto &state : row.back()[projection]) {
        finishGap(state, le, re, rejoins, projection);
        insert(beam, std::move(state));
      }
      trim(beam, "segment_limit");
      if (!empty[projection].empty())
        insert(beam, std::move(empty[projection].front()));
    }
  };
  auto appendAnchor = [&](State &state, AnchorMatch anchor) {
    const int cost = instructionCost(*left[anchor.left]);
    NewCharges newCharges;
    const int inputs = addedCost(anchor, state, newCharges);
    if (observe)
      recordTransition(anchor, state, cost, inputs, "forced_anchor");
    appendPair(state, anchor, newCharges, cost - inputs);
  };
  for (auto anchor : anchors) {
    align(anchor.left, anchor.right, true);
    for (auto &run : runs) {
      for (auto &state : run.beam)
        appendAnchor(state, anchor);
      if (run.anchorsOnlyLegal)
        appendAnchor(run.anchorsOnly, anchor);
      llvm::stable_sort(run.beam, [](const State &a, const State &b) {
        return a.score > b.score ||
               (a.score == b.score && a.pairs.size() > b.pairs.size());
      });
    }
    li = anchor.left + 1;
    ri = anchor.right + 1;
  }
  align(left.size(), right.size(), !join);

  if (linear && join) {
    auto chargeJoin = [&](State &state) {
      // With dedup disabled, replay the matched instructions to find the
      // actual input selects that the emitter could reuse at the exit.
      if (!scoring.selectDedup) {
        ArrayRef<AnchorMatch> pairs = state.pairs;
        for (auto item : llvm::enumerate(pairs))
          forInputSelect(item.value(), pairs.take_front(item.index()),
                         [&](OperandPair inputs) { state.charged.insert(inputs); });
      }
      for (auto &phi : join->phis()) {
        auto *lv = phi.getIncomingValueForBlock(&leftBlock);
        auto *rv = phi.getIncomingValueForBlock(&rightBlock);
        if (lv != rv && !pairedValues(lv, rv, state.pairs) && state.charged.insert({lv, rv}).second)
          state.score -= selectCost(phi.getType());
      }
    };
    for (auto &run : runs) {
      Beam ranked;
      for (auto &state : run.beam) {
        chargeJoin(state);
        insert(ranked, std::move(state));
      }
      run.beam = std::move(ranked);
      if (run.anchorsOnlyLegal) chargeJoin(run.anchorsOnly);
    }
  }
  for (auto &run : runs) {
    trim(run.beam, "final_limit");
    if (run.anchorsOnlyLegal)
      insert(run.beam, std::move(run.anchorsOnly));
  }
  if (observe) {
    auto instructions = [&](Work arm, unsigned side) {
      json::Array list;
      auto hasTransferCost = [](Type *type) {
        return type->isFirstClassType() && type->isSized() &&
               !type->isTokenTy() && !type->isMetadataTy() && !type->isLabelTy();
      };
      for (auto item : llvm::enumerate(arm)) {
        auto &inst = *item.value();
        std::string ir, type;
        raw_string_ostream irStream(ir), typeStream(type);
        inst.print(irStream);
        inst.getType()->print(typeStream);
        json::Array operands;
        for (const auto &operand : inst.operands()) {
          std::string operandType;
          raw_string_ostream operandStream(operandType);
          operand->getType()->print(operandStream);
          auto *ty = operand->getType();
          operands.push_back(json::Object{{"value", operandName(*operand)}, {"type", operandStream.str()},
              {"anchorSelectCost", hasTransferCost(ty) ? json::Value(selectCost(ty)) : json::Value(nullptr)}});
        }
        json::Object row{{"index", int64_t(item.index())},
            {"opcode", inst.getOpcodeName()}, {"type", typeStream.str()}, {"ir", irStream.str()},
            {"anchorCost", instructionCost(inst)},
            {"anchorSelectCost", hasTransferCost(inst.getType()) ? json::Value(selectCost(inst.getType())) : json::Value(nullptr)},
            {"anchorPhiCost", hasTransferCost(inst.getType()) ? json::Value(phiCost(inst.getType())) : json::Value(nullptr)},
            {"operands", std::move(operands)}};
        if (linear) row["linear_skippable"] = canSkip(side, item.index(), projections - 1);
        list.push_back(std::move(row));
      }
      return list;
    };
    json::Array plans;
    for (const auto &run : runs)
      for (const auto &state : run.beam)
        plans.push_back(stateJSON(state));
    std::error_code error;
    raw_fd_ostream trace(tracePath, error, sys::fs::OF_Append);
    if (error)
      throw std::runtime_error("writing B2B observation: " + error.message());
    trace << json::Value(json::Object{{"mode", pairTies ? "relaxed" : "strict"},
        {"left_block", operandName(leftBlock)}, {"right_block", operandName(rightBlock)},
        {"gap", scoring.unifiedGap ? "auto" : linear ? "linear" : "fork"},
        {"guarded_gap", guarded}, {"select_dedup", scoring.selectDedup}, {"cutoff", "static"},
        {"gap_rank", "lazy"},
        {"left", instructions(left, 0)}, {"right", instructions(right, 1)},
        {"proposed", matchesJSON(proposed)}, {"anchors", matchesJSON(anchors)},
        {"cutoffs", matchesJSON(cutoffs)}, {"forward_cutoffs", matchesJSON(runs.back().forwardCutoffs)},
        {"conflicts", int64_t(conflicts)}, {"conflicting_pairs", std::move(conflictingPairs)},
        {"transitions", std::move(transitions)}, {"pruned", std::move(pruned)},
        {"segments", std::move(segmentsObserved)}, {"plans", std::move(plans)}}) << '\n';
  }
  SmallVector<AnchorPlan, 3> result;
  for (unsigned projection = 0; projection != projections; ++projection) {
    auto &run = runs[projection];
    for (auto &state : run.beam) {
      AnchorPlan plan{std::move(state.pairs), anchors, cutoffs, run.forwardCutoffs,
                      state.chargedSegments, state.phiCharge, state.score,
                      unsigned(proposed.size() - anchors.size()), conflicts, segments,
                      allowsGuard(projection), {}};
      if (scoring.unifiedGap) {
        unsigned begin[2] = {};
        auto describeGap = [&](unsigned le, unsigned re) {
          if (begin[0] == le && begin[1] == re) return;
          const unsigned end[] = {le, re};
          bool hasGuard = false;
          if (plan.guardedProjection)
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
  }
  return result;
}
}
