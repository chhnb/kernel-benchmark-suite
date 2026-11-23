#pragma once

#include "reference_generation.h"
#include "cleanup_llvm.h"
#include "llvm/ADT/BitVector.h"
#include <numeric>
#include <set>

namespace {
struct GenerationGraph {
  std::vector<SmallVector<unsigned, 4>> predecessors, successors;
};

GenerationGraph generationGraph(const Diamond &shape, ArrayRef<Node> nodes) {
  DenseMap<const Value *, unsigned> ids;
  for (auto n : llvm::enumerate(nodes))
    for (const auto *i : {n.value().left, n.value().right})
      if (i)
        ids[i] = n.index();
  GenerationGraph graph;
  graph.predecessors.resize(nodes.size());
  graph.successors.resize(nodes.size());
  for (auto n : llvm::enumerate(nodes)) {
    auto add = [&](const Value *value) {
      auto parent = ids.find(value);
      auto &deps = graph.predecessors[n.index()];
      if (parent != ids.end() && !llvm::is_contained(deps, parent->second)) {
        deps.push_back(parent->second);
        graph.successors[parent->second].push_back(n.index());
      }
    };
    for (const auto *inst : {n.value().left, n.value().right}) {
      if (!inst)
        continue;
      add(shape.effectBefore.lookup(inst));
      for (const auto &operand : inst->operands())
        add(operand.get());
    }
  }
  return graph;
}

Optional<dataflow::Schedule> listSchedule(const GenerationGraph &graph, ArrayRef<Node> nodes,
                                          bool commonFirst, int64_t splitCost, int64_t armCost) {
  using dataflow::Lane;
  std::array<std::set<unsigned>, 3> ready;
  std::vector<unsigned> degree(nodes.size());
  auto lane = [&](unsigned i) {
    return nodes[i].recipe != Recipe::R6 ? Lane::Common : nodes[i].left ? Lane::Left : Lane::Right;
  };
  for (unsigned i = 0; i < nodes.size(); ++i) {
    degree[i] = graph.predecessors[i].size();
    if (!degree[i])
      ready[static_cast<unsigned>(lane(i))].insert(i);
  }
  dataflow::Schedule schedule{};
  Lane previous = Lane::Common;
  while (schedule.steps.size() != nodes.size()) {
    Lane next = Lane::Common;
    auto available = [&](Lane side) { return !ready[static_cast<unsigned>(side)].empty(); };
    if (previous != Lane::Common && available(previous))
      next = previous;
    else if (previous == Lane::Left && available(Lane::Right))
      next = Lane::Right;
    else if ((previous == Lane::Right || commonFirst) && available(Lane::Common))
      next = Lane::Common;
    else if (available(Lane::Left))
      next = Lane::Left;
    else if (available(Lane::Right))
      next = Lane::Right;
    else if (!available(Lane::Common))
      return None;
    auto &queue = ready[static_cast<unsigned>(next)];
    unsigned id = *queue.begin();
    queue.erase(queue.begin());
    bool opens = next != Lane::Common && previous != next &&
                 !(previous == Lane::Left && next == Lane::Right);
    schedule.steps.push_back({id, opens});
    if (opens) {
      ++schedule.branches;
      schedule.controlCost += splitCost + armCost;
    } else if (previous == Lane::Left && next == Lane::Right) {
      schedule.controlCost += armCost;
    }
    previous = next;
    for (auto dependent : graph.successors[id])
      if (--degree[dependent] == 0)
        ready[static_cast<unsigned>(lane(dependent))].insert(dependent);
  }
  return schedule;
}

std::vector<SmallVector<unsigned, 4>> speculationGroups(const Search &search,
                                                          const GenerationGraph &graph) {
  BitVector pending(search.nodes.size());
  for (auto n : llvm::enumerate(search.nodes))
    if ((!n.value().left || !n.value().right) &&
        search.speculate(*(n.value().left ? n.value().left : n.value().right)))
      pending.set(n.index());
  std::vector<SmallVector<unsigned, 4>> groups;
  while (pending.any()) {
    auto start = pending.find_first();
    pending.reset(start);
    auto &group = groups.emplace_back();
    group.push_back(start);
    for (unsigned i = 0; i < group.size(); ++i)
      for (auto edges : {ArrayRef<unsigned>(graph.predecessors[group[i]]),
                         ArrayRef<unsigned>(graph.successors[group[i]])})
        for (auto dependency : edges)
          if (pending.test(dependency) &&
              bool(search.nodes[dependency].left) == bool(search.nodes[start].left)) {
            pending.reset(dependency);
            group.push_back(dependency);
          }
  }
  return groups;
}

struct ScaleStats {
  unsigned groups = 0;
  unsigned foldAdjustments = 0;
  Optional<Cost> listMinimum, listPolicy;
  unsigned referenceCandidates = 0;
};

ScaleStats generateScalable(Search &search, const Cost &original, StringRef source,
                            bool materializeFold,
                            function_ref<bool(const Cost &, const Cost &)> better) {
  ScaleStats stats;
  auto graph = generationGraph(search.shape, search.nodes);
  if (!listSchedule(graph, search.nodes, true, search.splitCost, search.armCost)) {
    search.stop = "pairing creates a dependency cycle";
    return stats;
  }
  const auto groups = speculationGroups(search, graph);
  stats.groups = groups.size();
  auto rank = [&](const Cost &a, const Cost &b) {
    if (source == "data") {
      auto admissible = [&](const Cost &t) { return t[1] <= original[1] && t[2] <= original[2]; };
      if (admissible(a) != admissible(b))
        return admissible(a);
      if (!admissible(a))
        return a < b;
    }
    return better(a, b);
  };
  auto attempt = [&](const BitVector &speculated) -> Optional<Cost> {
    if (Clock::now() - search.start >= std::chrono::minutes(10)) {
      search.stop = "generation time limit";
      return None;
    }
    for (unsigned i = 0; i < groups.size(); ++i)
      for (auto node : groups[i])
        search.nodes[node].recipe = speculated.test(i) ? Recipe::R5 : Recipe::R6;
    Optional<Cost> local;
    std::vector<dataflow::Scheduled> previous;
    bool havePrevious = false;
    for (bool commonFirst : {true, false}) {
      auto schedule = listSchedule(graph, search.nodes, commonFirst, search.splitCost, search.armCost);
      if (!schedule)
        continue;
      if (havePrevious && previous.size() == schedule->steps.size() &&
          std::equal(previous.begin(), previous.end(), schedule->steps.begin(),
                     [](auto a, auto b) { return a.node == b.node && a.opensGuard == b.opensGuard; }))
        continue;
      previous.assign(schedule->steps.begin(), schedule->steps.end());
      havePrevious = true;
      ++search.candidates;
      auto candidate = emit(search.module, search.func, search.shape, search.nodes, *schedule,
                            bool(search.throughput));
      if (!candidate.module) {
        ++search.unsupportedGeneration;
        continue;
      }
      if (verifyModule(*candidate.module, &errs())) {
        search.stop = "list schedule failed LLVM12 verifier";
        return None;
      }
      search.selectedGuards = schedule->branches;
      search.selectedControl = schedule->controlCost;
      auto count = search.rejectedFold;
      Optional<Cost> observed;
      search.add(*candidate.module, false, &candidate, false, &observed);
      if (search.rejectedFold != count && materializeFold && search.oracleQuotes) {
        // Let the same LLVM pass materialize mandatory Fold decisions for
        // grouped alternatives that cannot express them independently.
        auto &fn = *candidate.module->getFunction(search.func.getName());
        dataflow::runSimplifyCFG(fn, *search.oracleQuotes);
        if (verifyModule(*candidate.module, &errs())) {
          search.stop = "mandatory Fold failed LLVM12 verifier";
          return None;
        }
        ++stats.foldAdjustments;
        search.add(*candidate.module, false, &candidate, false, &observed);
      }
      if (!search.stop.empty())
        return None;
      if (observed && (!local || rank(*observed, *local)))
        local = observed;
    }
    return local;
  };
  if (groups.size() <= 12) {
    BitVector mask(groups.size());
    for (unsigned bits = 0; bits < (1u << groups.size()) && search.stop.empty(); ++bits) {
      for (unsigned i = 0; i < groups.size(); ++i)
        if (bits & (1u << i))
          mask.set(i);
        else
          mask.reset(i);
      attempt(mask);
    }
  } else {
    BitVector active(groups.size(), true);
    auto incumbent = attempt(active);
    BitVector guarded(groups.size());
    auto other = attempt(guarded);
    if (other && (!incumbent || rank(*other, *incumbent))) {
      active = std::move(guarded);
      incumbent = other;
    }
    for (unsigned i = 0; i < groups.size() && search.stop.empty(); ++i) {
      active.flip(i);
      auto candidate = attempt(active);
      if (candidate && (!incumbent || rank(*candidate, *incumbent)))
        incumbent = candidate;
      else
        active.flip(i);
    }
  }
  llvm::sort(search.front, [](const auto &a, const auto &b) { return a.cost < b.cost; });
  auto policy = original;
  for (const auto &entry : search.front) {
    if (!stats.listMinimum || entry.cost < *stats.listMinimum)
      stats.listMinimum = entry.cost;
    if (better(entry.cost, policy))
      policy = entry.cost;
  }
  stats.listPolicy = policy;
  return stats;
}
} // namespace
