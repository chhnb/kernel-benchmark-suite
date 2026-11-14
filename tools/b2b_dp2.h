#pragma once

#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Instructions.h"
#include <algorithm>
#include <array>
#include <set>
#include <cstddef>
#include <iterator>
#include <memory>
#include <optional>
#include <utility>
#include <vector>

namespace fusion::dp2 {

enum class Mode { Common, Forked };
enum class Place { Common, Left, Right };
enum class Action { KeepLeft, KeepRight, SpecLeft, SpecRight, HoistLeft,
                    HoistRight, JoinSpecLeft, JoinSpecRight, MatchCommon,
                    MatchHoist, MatchJoin };
enum class Exit { MergedValues, Resplit, DirectEdges, CloseAndMergeValues };

// A virtual definition is available in its own arm or in the common block.
// The generation distinguishes values from different forks and continuations.
struct Definition {
  unsigned id;
  unsigned generation;
  Place place;
};

template <typename Key, typename Value>
class PersistentBindings {
  struct Binding {
    Key key;
    Value value;
    std::shared_ptr<const Binding> previous;
  };
  std::shared_ptr<const Binding> head;

public:
  std::optional<Value> lookup(const Key &key) const {
    for (auto node = head.get(); node; node = node->previous.get())
      if (node->key == key) return node->value;
    return std::nullopt;
  }

  void bind(Key key, Value value) {
    head = std::make_shared<Binding>(
        Binding{std::move(key), std::move(value), head});
  }
};

using Demand = std::pair<const llvm::Value *, const llvm::Value *>;

struct Recipe {
  Action action;
  unsigned left;
  unsigned right;
  std::shared_ptr<const Recipe> previous;
  std::vector<unsigned> rightOperands;
  std::vector<unsigned> selectorIds;
  std::vector<bool> pairedPhi;
  std::vector<std::pair<unsigned, unsigned>> dependencies;
  std::vector<std::pair<unsigned, unsigned>> liveThroughJoin;
};

struct Label {
  std::shared_ptr<const Recipe> plan;
  std::array<PersistentBindings<const llvm::Value *, Definition>, 2> values;
  PersistentBindings<std::pair<unsigned, unsigned>, Definition> selectors;
  unsigned generation = 0;
  std::array<unsigned, 2> pending{};
  int generatedCost = 0;
  int futureCredit = 0;

  int rank() const { return generatedCost - futureCredit; }
};

inline unsigned resolveSelector(Label &label, Definition left, Definition right,
                                unsigned &nextId) {
  if (left.id == right.id) return 0;
  const auto key = std::make_pair(left.id, right.id);
  if (auto cached = label.selectors.lookup(key)) return cached->id;
  const unsigned id = nextId++;
  label.selectors.bind(key, {id, label.generation, Place::Common});
  ++label.generatedCost;
  return id;
}

class Frontier {
  using Cell = std::array<std::optional<Label>, 2>;
  std::vector<Cell> cells;
  std::size_t columns;

public:
  Frontier(unsigned left, unsigned right)
      : cells((std::size_t(left) + 1) * (std::size_t(right) + 1)),
        columns(std::size_t(right) + 1) {}

  const std::optional<Label> &at(unsigned i, unsigned j, Mode mode) const {
    return cells[i * columns + j][static_cast<unsigned>(mode)];
  }

  void relax(unsigned i, unsigned j, Mode mode, Label candidate) {
    auto &slot = cells[i * columns + j][static_cast<unsigned>(mode)];
    // Preserve traversal order on ties so replay is independent of addresses.
    if (!slot || candidate.rank() < slot->rank())
      slot = std::move(candidate);
  }
};

class LiveDemand {
  std::array<llvm::DenseMap<const llvm::Value *, unsigned>, 2> lastUse;

public:
  void analyze(unsigned side, llvm::ArrayRef<llvm::Instruction *> work,
               llvm::ArrayRef<const llvm::Value *> outgoing) {
    auto &uses = lastUse[side];
    for (unsigned i = 0; i < work.size(); ++i)
      for (const auto &operand : work[i]->operands())
        uses[operand.get()] = i;
    for (auto *value : outgoing) uses[value] = work.size();
  }

  bool needed(unsigned side, const llvm::Value *value, unsigned cursor) const {
    const auto &uses = lastUse[side];
    auto position = uses.find(value);
    return position != uses.end() && position->second >= cursor;
  }
};

// Build occurrences in descending left cursor order. Keep only increases
// in the suffix maximum of the right cursor.
class PairDemand {
  struct Suffix {
    bool outgoing = false;
    std::vector<std::pair<unsigned, unsigned>> changes;
  };
  llvm::DenseMap<Demand, Suffix> demands;

  void record(Demand pair, unsigned i, unsigned j) {
    if (pair.first == pair.second) return;
    auto &changes = demands[pair].changes;
    if (!changes.empty() && changes.back().second >= j) return;
    if (!changes.empty() && changes.back().first == i)
      changes.back().second = j;
    else
      changes.emplace_back(i, j);
  }

public:
  template <typename Compatible>
  PairDemand(llvm::ArrayRef<llvm::Instruction *> left,
             llvm::ArrayRef<llvm::Instruction *> right,
             llvm::ArrayRef<Demand> outgoing, Compatible compatible) {
    for (auto pair : outgoing)
      if (pair.first != pair.second) demands[pair].outgoing = true;
    for (unsigned i = left.size(); i-- > 0;)
      for (unsigned j = right.size(); j-- > 0;) {
        auto &l = *left[i], &r = *right[j];
        if (!compatible(l, r) || l.getNumOperands() != r.getNumOperands()) continue;
        for (unsigned op = 0; op < l.getNumOperands(); ++op)
          record({l.getOperand(op), r.getOperand(op)}, i, j);
        if (l.isCommutative() && r.isCommutative() && l.getNumOperands() == 2) {
          record({l.getOperand(0), r.getOperand(1)}, i, j);
          record({l.getOperand(1), r.getOperand(0)}, i, j);
        }
      }
  }

  bool future(Demand pair, unsigned i, unsigned j) const {
    auto found = demands.find(pair);
    if (found == demands.end()) return false;
    const auto &suffix = found->second;
    if (suffix.outgoing) return true;
    auto end = std::partition_point(suffix.changes.begin(), suffix.changes.end(),
                                    [i](auto point) { return point.first >= i; });
    return end != suffix.changes.begin() && std::prev(end)->second >= j;
  }

  template <typename Available>
  int credit(const Label &label, unsigned i, unsigned j, Available available) const {
    std::set<unsigned> ready;
    for (const auto &entry : demands) {
      const auto &pair = entry.first;
      if (!future(pair, i, j)) continue;
      auto l = label.values[0].lookup(pair.first);
      auto r = label.values[1].lookup(pair.second);
      if (l && r && l->place == Place::Common && r->place == Place::Common &&
          l->id == r->id) {
        ready.insert(l->id);
        continue;
      }
      if (!l) l = available(pair.first);
      if (!r) r = available(pair.second);
      if (!l || !r) continue;
      auto selected = label.selectors.lookup({l->id, r->id});
      if (selected && selected->place == Place::Common)
        ready.insert(selected->id);
    }
    return ready.size();
  }
};

// Resolve a source value in the current virtual placement. Arm definitions
// from a closed fork require a transport at its continuation.
template <typename Available>
std::optional<Definition> resolve(const Label &label, unsigned side,
                                  const llvm::Value *value, Available available) {
  if (auto def = label.values[side].lookup(value)) return def;
  return available(value);
}

struct Terminal {
  Label label;
  Exit exit;
  std::vector<unsigned> exitSelectorIds;
  std::vector<bool> exitPairedPhi;
};

template <typename Compatible, typename Speculatable, typename Available, typename Weight>
std::vector<Terminal> plan(llvm::ArrayRef<llvm::Instruction *> left,
                           llvm::ArrayRef<llvm::Instruction *> right,
                           llvm::ArrayRef<Demand> outgoing, Compatible compatible,
                           Speculatable speculatable, Available available, Weight weight) {
  Frontier table(left.size(), right.size());
  PairDemand demand(left, right, outgoing, compatible);
  LiveDemand live;
  for (unsigned side = 0; side < 2; ++side) {
    std::vector<const llvm::Value *> exits;
    for (auto pair : outgoing) exits.push_back(side ? pair.second : pair.first);
    live.analyze(side, side ? right : left, exits);
  }
  table.relax(0, 0, Mode::Common, {});
  std::vector<Terminal> result;
  unsigned nextId = 1;
  const auto common = Place::Common;
  llvm::ArrayRef<llvm::Instruction *> work[] = {left, right};
  const unsigned length[] = {unsigned(left.size()), unsigned(right.size())};
  // Unit costs for virtual CFG edges, independent of the final TTI score.
  constexpr int jumpCost = 1;
  constexpr int branchCost = 1;
  auto finish = [&](Label label, Mode mode) {
    // Every terminal layout delivers the same original edge values.
    for (auto pair : outgoing) {
      auto left = resolve(label, 0, pair.first, available);
      auto right = resolve(label, 1, pair.second, available);
      auto validOnEdge = [&](std::optional<Definition> def, Place arm) {
        return def && (def->place == common ||
                       (mode == Mode::Forked && def->place == arm &&
                        def->generation == label.generation));
      };
      if (!validOnEdge(left, Place::Left) || !validOnEdge(right, Place::Right))
        return;
    }
    if (mode == Mode::Forked) {
      result.push_back({label, Exit::DirectEdges});
    }
    std::vector<unsigned> choices;
    Label merged = label;
    std::vector<bool> pairedPhi;
    for (auto pair : outgoing) {
      auto l = resolve(merged, 0, pair.first, available);
      auto r = resolve(merged, 1, pair.second, available);
      pairedPhi.push_back(mode == Mode::Forked &&
          l->id != r->id && !merged.selectors.lookup({l->id, r->id}) &&
          (l->place != common || r->place != common));
      choices.push_back(resolveSelector(merged, *l, *r, nextId));
    }
    merged.generatedCost += jumpCost;
    result.push_back({std::move(merged),
        mode == Mode::Forked ? Exit::CloseAndMergeValues : Exit::MergedValues,
        std::move(choices), std::move(pairedPhi)});
    if (mode == Mode::Forked) return;
    label.generatedCost += branchCost + jumpCost;
    result.push_back({std::move(label), Exit::Resplit});
  };
  for (unsigned i = 0; i <= length[0]; ++i)
    for (unsigned j = 0; j <= length[1]; ++j)
      for (Mode mode : {Mode::Common, Mode::Forked}) {
        const auto &slot = table.at(i, j, mode);
        if (!slot) continue;
        const Label &parent = *slot;
        const unsigned cursor[] = {i, j};
        if (i == length[0] && j == length[1]) {
          if (!parent.plan) finish(parent, mode);
          continue;
        }
        auto publish = [&](Label label, Action action, unsigned ni, unsigned nj,
                           Mode next, std::vector<unsigned> rightOperands = {},
                           std::vector<std::pair<unsigned, unsigned>> dependencies = {},
                           std::vector<unsigned> selectorIds = {},
                           std::vector<bool> pairedPhi = {}) {
          std::vector<std::pair<unsigned, unsigned>> transfers;
          if (mode == Mode::Forked && next == Mode::Common) {
            for (unsigned side = 0; side < 2; ++side)
              for (unsigned index = 0; index < cursor[side]; ++index) {
                auto *value = work[side][index];
                auto def = label.values[side].lookup(value);
                if (value->getType()->isVoidTy() || !def ||
                    def->place == common || def->generation != label.generation ||
                    !live.needed(side, value, cursor[side])) continue;
                bool needsSideValue = live.needed(side, value, side ? nj : ni);
                auto *current = cursor[side] < (side ? nj : ni)
                    ? work[side][cursor[side]] : nullptr;
                for (unsigned op = 0; current && !needsSideValue && op < current->getNumOperands(); ++op) {
                  if (current->getOperand(op) != value) continue;
                  bool paired = false;
                  for (unsigned n = 0; n < pairedPhi.size(); ++n)
                    if (pairedPhi[n] && (side ? rightOperands[n] : n) == op)
                      paired = true;
                  needsSideValue = !paired;
                }
                if (!needsSideValue) continue;
                def->place = common;
                label.values[side].bind(value, *def);
                transfers.emplace_back(side, index);
                ++label.generatedCost;
              }
          }
          for (auto [side, index] : dependencies) {
            (void)index;
            if (--label.pending[side] == 0) label.generatedCost -= jumpCost;
          }
          if (next == Mode::Forked && !label.pending[0] && !label.pending[1]) {
            label.generatedCost -= branchCost;
            next = Mode::Common;
          }
          if (next == Mode::Common) label.pending = {};
          label.plan = std::make_shared<Recipe>(Recipe{action, i, j, parent.plan,
              std::move(rightOperands), std::move(selectorIds), std::move(pairedPhi),
              std::move(dependencies), std::move(transfers)});
          if (ni == length[0] && nj == length[1]) {
            finish(std::move(label), next);
            return;
          }
          label.futureCredit = demand.credit(label, ni, nj, available);
          table.relax(ni, nj, next, std::move(label));
        };
        auto hoistDependency = [&](auto &&self, Label &label, unsigned side,
                                   const llvm::Value *value, auto &dependencies)
            -> std::optional<Definition> {
          auto def = resolve(label, side, value, available);
          if (!def || def->place == common) return def;
          auto *inst = llvm::dyn_cast<llvm::Instruction>(value);
          if (def->generation != label.generation || !inst)
            return std::nullopt;
          auto position = std::find(work[side].begin(), work[side].begin() + cursor[side],
                                    inst);
          if (position == work[side].begin() + cursor[side] || !speculatable(**position)) return std::nullopt;
          for (const auto &operand : inst->operands())
            if (!self(self, label, side, operand.get(), dependencies))
              return std::nullopt;
          def->place = common;
          label.values[side].bind(value, *def);
          dependencies.emplace_back(side, position - work[side].begin());
          return def;
        };
        for (unsigned side = 0; side < 2; ++side) {
          if (cursor[side] == length[side]) continue;
          auto *inst = work[side][cursor[side]];
          for (unsigned placement = 0; placement < 3; ++placement) {
            const bool keep = placement == 0, hoist = placement == 2;
            if (hoist && mode != Mode::Forked) continue;
            if (!keep && !speculatable(*inst)) continue;
            Label label = parent;
            std::vector<std::pair<unsigned, unsigned>> dependencies;
            const Place place = !keep ? common : side ? Place::Right : Place::Left;
            if (keep && mode == Mode::Common) {
              ++label.generation;
              label.generatedCost += branchCost;
            }
            if (keep && label.pending[side]++ == 0)
              label.generatedCost += jumpCost;
            bool legal = true;
            for (const auto &operand : inst->operands()) {
              auto def = hoist ? hoistDependency(hoistDependency, label, side, operand.get(), dependencies)
                               : resolve(parent, side, operand.get(), available);
              if (!def || (hoist && def->place != common)) { legal = false; break; }
            }
            if (!legal) continue;
            label.generatedCost += weight(*inst);
            label.values[side].bind(inst, {nextId++, label.generation, place});
            const auto action = keep ? (side ? Action::KeepRight : Action::KeepLeft) :
                hoist ? (side ? Action::HoistRight : Action::HoistLeft) :
                mode == Mode::Common ? (side ? Action::SpecRight : Action::SpecLeft) :
                                       (side ? Action::JoinSpecRight : Action::JoinSpecLeft);
            publish(std::move(label), action, i + !side, j + side,
                    keep || hoist ? Mode::Forked : Mode::Common, {}, std::move(dependencies));
          }
        }
        if (i == length[0] || j == length[1] || !compatible(*left[i], *right[j]))
          continue;
        auto *l = left[i], *r = right[j];
        for (bool hoist : {false, true}) {
          if (hoist && (mode != Mode::Forked || !speculatable(*l) || !speculatable(*r)))
            continue;
        for (bool swap : {false, true}) {
          if (swap && !(l->isCommutative() && r->isCommutative() &&
                        l->getNumOperands() == 2)) continue;
          Label label = parent;
          std::vector<std::pair<unsigned, unsigned>> dependencies;
          bool legal = true;
          std::vector<unsigned> rightOperands;
          std::vector<unsigned> selectorIds;
          std::vector<bool> pairedPhi;
          for (unsigned n = 0; n < l->getNumOperands(); ++n) {
            rightOperands.push_back(swap ? 1 - n : n);
            Demand pair{l->getOperand(n), r->getOperand(rightOperands.back())};
            auto a = hoist ? hoistDependency(hoistDependency, label, 0, pair.first, dependencies)
                           : resolve(parent, 0, pair.first, available);
            auto b = hoist ? hoistDependency(hoistDependency, label, 1, pair.second, dependencies)
                           : resolve(parent, 1, pair.second, available);
            if (!a || !b || (hoist && (a->place != common || b->place != common))) { legal = false; break; }
            pairedPhi.push_back(mode == Mode::Forked && !hoist &&
                a->id != b->id && !label.selectors.lookup({a->id, b->id}) &&
                (a->place != common || b->place != common));
            selectorIds.push_back(resolveSelector(label, *a, *b, nextId));
          }
          if (!legal) continue;
          Definition shared{nextId++, label.generation, common};
          label.values[0].bind(l, shared);
          label.values[1].bind(r, shared);
          label.generatedCost += weight(*l);
          publish(std::move(label), mode == Mode::Common ? Action::MatchCommon :
                  hoist ? Action::MatchHoist : Action::MatchJoin,
                  i + 1, j + 1, hoist ? Mode::Forked : Mode::Common, std::move(rightOperands), std::move(dependencies), std::move(selectorIds), std::move(pairedPhi));
        }
        }
      }
  return result;
}

} // namespace fusion::dp2
