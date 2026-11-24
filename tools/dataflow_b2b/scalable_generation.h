#pragma once

#include "reference_generation.h"
#include "cleanup_llvm.h"
#include "placement_cut.h"
#include <map>

namespace {
struct GenerationGraph {
  std::vector<SmallVector<unsigned, 4>> predecessors, successors;
  std::array<std::vector<SmallVector<unsigned, 4>>, 2> armPredecessors;
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
  for (auto &arm : graph.armPredecessors)
    arm.resize(nodes.size());
  for (auto n : llvm::enumerate(nodes)) {
    auto add = [&](const Value *value, unsigned side) {
      auto parent = ids.find(value);
      auto &deps = graph.predecessors[n.index()];
      if (parent == ids.end())
        return;
      auto &arm = graph.armPredecessors[side][n.index()];
      if (!llvm::is_contained(arm, parent->second))
        arm.push_back(parent->second);
      if (!llvm::is_contained(deps, parent->second)) {
        deps.push_back(parent->second);
        graph.successors[parent->second].push_back(n.index());
      }
    };
    for (unsigned side : {0u, 1u}) {
      const auto *inst = side ? n.value().right : n.value().left;
      if (!inst)
        continue;
      add(shape.effectBefore.lookup(inst), side);
      for (const auto &operand : inst->operands())
        add(operand.get(), side);
    }
  }
  return graph;
}

std::vector<unsigned> topologicalOrder(const GenerationGraph &graph) {
  std::vector<unsigned> order, degree;
  for (auto edges : llvm::enumerate(graph.predecessors)) {
    degree.push_back(edges.value().size());
    if (edges.value().empty())
      order.push_back(edges.index());
  }
  for (unsigned i = 0; i < order.size(); ++i)
    for (auto user : graph.successors[order[i]])
      if (--degree[user] == 0)
        order.push_back(user);
  return order;
}

BitVector convexProtection(const GenerationGraph &graph, ArrayRef<unsigned> order,
                           ArrayRef<Node> nodes, const BitVector &speculated) {
  auto closed = speculated;
  for (unsigned side : {0u, 1u}) {
    const auto &deps = graph.armPredecessors[side];
    BitVector fromGuard(nodes.size()), toGuard(nodes.size());
    for (auto item : llvm::enumerate(nodes)) {
      const auto &node = item.value();
      if (bool(node.left) != bool(node.right) && bool(node.right) == bool(side) &&
          !speculated.test(item.index())) {
        fromGuard.set(item.index());
        toGuard.set(item.index());
      }
    }
    for (auto id : order)
      if (llvm::any_of(deps[id], [&](auto pred) { return fromGuard.test(pred); }))
        fromGuard.set(id);
    for (auto id : llvm::reverse(order))
      if (toGuard.test(id))
        for (auto pred : deps[id])
          toGuard.set(pred);
    fromGuard &= toGuard;
    closed.reset(fromGuard);
  }
  return closed;
}

dataflow::Schedule phasedSchedule(const GenerationGraph &graph, ArrayRef<unsigned> order,
                                  ArrayRef<Node> nodes, int64_t splitCost, int64_t armCost) {
  using dataflow::Lane;
  std::vector<unsigned> phase(nodes.size());
  unsigned longest = 0;
  auto guarded = [&](unsigned id) { return nodes[id].recipe == Recipe::R6; };
  for (auto id : order) {
    phase[id] = guarded(id) ? 1 : 0;
    for (auto parent : graph.predecessors[id]) {
      if (guarded(parent) && guarded(id))
        assert(bool(nodes[parent].left) == bool(nodes[id].left));
      phase[id] = std::max(phase[id], phase[parent] + (guarded(id) && !guarded(parent)));
    }
    longest = std::max(longest, phase[id]);
  }
  // Rank k groups the two protected arms before the common instructions at
  // k. This drains each class and realizes the longest-path lower bound.
  std::vector<std::array<SmallVector<unsigned, 8>, 3>> phases(longest + 1);
  for (auto id : order)
    phases[phase[id]][!guarded(id) ? 2 : nodes[id].left ? 0 : 1].push_back(id);
  dataflow::Schedule result{};
  for (const auto &batch : phases) {
    bool opens = true;
    for (unsigned side = 0; side < 2; ++side) {
      if (batch[side].empty())
        continue;
      result.controlCost += armCost;
      for (auto id : batch[side]) {
        result.steps.push_back({id, opens});
        if (opens) {
          result.controlCost += splitCost;
          ++result.branches;
          opens = false;
        }
      }
    }
    for (auto id : batch[2])
      result.steps.push_back({id, false});
  }
  assert(result.branches == longest && result.steps.size() == nodes.size());
  return result;
}

GenerationGraph withArmOrder(const Search &search, const GenerationGraph &graph) {
  GenerationGraph ordered = graph;
  DenseMap<const Instruction *, unsigned> ids;
  for (auto item : llvm::enumerate(search.nodes))
    for (auto *inst : {item.value().left, item.value().right})
      if (inst)
        ids[inst] = item.index();
  for (const auto &arm : search.shape.ops)
    for (unsigned i = 1; i < arm.size(); ++i) {
      auto from = ids.lookup(arm[i-1]), to = ids.lookup(arm[i]);
      auto &edges = ordered.successors[from];
      if (!llvm::is_contained(edges, to)) {
        edges.push_back(to);
        ordered.predecessors[to].push_back(from);
      }
    }
  return ordered;
}

Expected<DenseMap<Type *, int64_t>> phiCosts(const Search &search, ArrayRef<Type *> types) {
  DenseMap<Type *, int64_t> result;
  if (types.empty())
    return result;
  if (!search.throughput) {
    for (auto *type : types)
      result[type] = *search.costs.getInteger("guard_escape_merge");
    return result;
  }
  auto &context = search.func.getContext();
  Module module("dataflow-phi-quotes", context);
  module.setTargetTriple(search.module.getTargetTriple());
  module.setDataLayout(search.module.getDataLayout());
  SmallVector<Type *, 16> arguments{Type::getInt1Ty(context)};
  for (auto *type : types)
    arguments.append(2, type);
  auto *fn = Function::Create(FunctionType::get(Type::getVoidTy(context), arguments, false),
                              GlobalValue::ExternalLinkage, search.func.getName(), module);
  for (auto key : {"target-cpu", "target-features"})
    if (search.func.hasFnAttribute(key))
      fn->addFnAttr(key, search.func.getFnAttribute(key).getValueAsString());
  auto *entry = BasicBlock::Create(context, "split", fn);
  auto *left = BasicBlock::Create(context, "left", fn);
  auto *join = BasicBlock::Create(context, "join", fn);
  BranchInst::Create(left, join, fn->getArg(0), entry);
  BranchInst::Create(join, left);
  IRBuilder<> builder(join);
  SmallVector<const Instruction *, 16> phis;
  for (auto item : llvm::enumerate(types)) {
    auto *phi = builder.CreatePHI(item.value(), 2);
    phi->addIncoming(fn->getArg(2 * item.index() + 1), left);
    phi->addIncoming(fn->getArg(2 * item.index() + 2), entry);
    phis.push_back(phi);
  }
  builder.CreateRetVoid();
  auto quotes = search.throughput(*fn);
  if (!quotes)
    return quotes.takeError();
  for (auto item : llvm::enumerate(types)) {
    auto quote = quotes->find(phis[item.index()]);
    if (quote == quotes->end())
      return createStringError(inconvertibleErrorCode(), "missing LLVM24 escape quote");
    result[item.value()] = quote->second;
  }
  return result;
}

Expected<std::array<std::vector<dataflow::placement::Value>, 2>>
cutInputs(const Search &search, const BitVector &optional) {
  using CutValue = dataflow::placement::Value;
  std::array<std::vector<CutValue>, 2> sides;
  DenseMap<const Value *, unsigned> local[2];
  SmallVector<Type *, 16> escapeTypes;
  for (auto item : llvm::enumerate(search.nodes)) {
    const auto &node = item.value();
    if (node.left && node.right)
      continue;
    unsigned side = node.right != nullptr;
    const auto *inst = side ? node.right : node.left;
    local[side][inst] = sides[side].size();
    sides[side].push_back({static_cast<unsigned>(item.index()), optional.test(item.index()), 0, 0, false, {}});
    if (!inst->use_empty() && !inst->getType()->isTokenTy() &&
        !llvm::is_contained(escapeTypes, inst->getType()))
      escapeTypes.push_back(inst->getType());
  }
  dataflow::InstructionCosts prices;
  if (search.throughput) {
    auto quoted = search.throughput(search.func);
    if (!quoted)
      return quoted.takeError();
    prices = std::move(*quoted);
  }
  auto escapes = phiCosts(search, escapeTypes);
  if (!escapes)
    return escapes.takeError();
  for (unsigned side = 0; side < 2; ++side)
    for (auto &v : sides[side]) {
      const auto &node = search.nodes[v.node];
      const auto *inst = side ? node.right : node.left;
      v.instruction = search.throughput ? prices.lookup(inst) : dataflow::costOf(*inst, search.costs).getValueOr(0);
      v.escape = escapes->lookup(inst->getType());
      for (auto *consumer : inst->users()) {
        if (isa<DbgInfoIntrinsic>(consumer))
          continue;
        auto found = local[side].find(consumer);
        if (found == local[side].end())
          v.publicUse = true;
        else if (!llvm::is_contained(v.users, found->second))
          v.users.push_back(found->second);
      }
    }
  return sides;
}

struct ScaleStats {
  unsigned optional = 0, cuts = 0, foldAdjustments = 0;
  unsigned multiGuard = 0, repairs = 0, cleaned = 0, cleanupUnpriced = 0;
  std::string firstCleanupError;
  Optional<Cost> listMinimum, listPolicy;
  unsigned referenceCandidates = 0;
};

ScaleStats generateScalable(Search &search, const Cost &original, StringRef source,
                            bool definedInactiveCondition,
                            function_ref<bool(const Cost &, const Cost &)> better,
                            function_ref<void(const Candidate &, StringRef)> observe = nullptr) {
  ScaleStats stats;
  auto graph = generationGraph(search.shape, search.nodes);
  auto order = topologicalOrder(graph);
  if (order.size() != search.nodes.size()) {
    search.stop = "pairing creates a dependency cycle";
    return stats;
  }
  GenerationGraph ordered;
  std::vector<unsigned> armOrder;
  if (definedInactiveCondition) {
    ordered = withArmOrder(search, graph);
    armOrder = topologicalOrder(ordered);
  }
  BitVector optional(search.nodes.size());
  for (auto indexed : llvm::enumerate(search.nodes)) {
    const auto &node = indexed.value();
    if ((!node.left || !node.right) && search.speculate(*(node.left ? node.left : node.right)))
      optional.set(indexed.index());
  }
  stats.optional = optional.count();
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
  std::vector<Cost> rawCosts;
  std::map<std::vector<unsigned>, Optional<Cost>> seen;
  auto attempt = [&](const BitVector &speculated, StringRef placement, bool baseline = false) -> Optional<Cost> {
    if (Clock::now() - search.start >= std::chrono::minutes(10)) {
      search.stop = "generation time limit";
      return None;
    }
    std::vector<unsigned> key;
    for (auto id = speculated.find_first(); id != -1; id = speculated.find_next(id))
      key.push_back(id);
    if (baseline)
      key.push_back(search.nodes.size());
    for (auto id = optional.find_first(); id != -1; id = optional.find_next(id))
      search.nodes[id].recipe = speculated.test(id) ? Recipe::R5 : Recipe::R6;
    auto saved = seen.try_emplace(std::move(key), None);
    if (!saved.second)
      return saved.first->second;
    dataflow::Schedule schedule = phasedSchedule(graph, order, search.nodes, search.splitCost, search.armCost);
    stats.multiGuard += schedule.branches > 1;
    auto price = [&](const dataflow::Schedule &schedule) -> Optional<Cost> {
      ++search.candidates;
      Candidate candidate;
      if (baseline)
        candidate.module = CloneModule(search.module);
      else
        candidate = emit(search.module, search.func, search.shape, search.nodes, schedule,
                         bool(search.throughput), definedInactiveCondition);
      if (!candidate.module) {
        ++search.unsupportedGeneration;
        return None;
      }
      if (verifyModule(*candidate.module, &errs())) {
        search.stop = "phase schedule failed LLVM12 verifier";
        return None;
      }
      if (observe && !baseline)
        observe(candidate, placement);
      search.selectedGuards = schedule.branches;
      search.selectedControl = schedule.controlCost;
      auto rejected = search.rejectedFold;
      Optional<Cost> observed;
      search.add(*candidate.module, baseline, &candidate, false, &observed, false, nullptr, placement);
      if (observed)
        rawCosts.push_back(*observed);
      if (!search.stop.empty()) {
        if (!observe)
          return None;
        // Regional quote failures do not invalidate the emitted parent trial.
        search.stop.clear();
      }
      if (search.oracleQuotes) {
        auto cleanedModule = CloneModule(*candidate.module);
        auto &fn = *cleanedModule->getFunction(search.func.getName());
        if (search.rejectedFold != rejected)
          ++stats.foldAdjustments;
        dataflow::runCleanup(fn, *search.oracleQuotes);
        if (verifyModule(*cleanedModule, &errs())) {
          search.stop = "cleanup failed LLVM12 verifier";
          return None;
        }
        Optional<Cost> cleaned;
        search.add(*cleanedModule, false, &candidate, false, &cleaned, true, candidate.module.get(), placement);
        if (!search.stop.empty()) {
          // The project cleanup may introduce an expression of C outside the
          // evaluator's branch contract. The uncleaned candidate is still valid.
          ++stats.cleanupUnpriced;
          if (stats.firstCleanupError.empty())
            stats.firstCleanupError = search.stop;
          search.stop.clear();
        }
        if (cleaned) {
          ++stats.cleaned;
          if (!observed || rank(*cleaned, *observed))
            observed = cleaned;
        }
      }
      return observed;
    };
    auto observed = price(schedule);
    if (definedInactiveCondition && armOrder.size() == order.size() &&
        !baseline && schedule.branches > 1 && search.stop.empty()) {
      auto inOrder = phasedSchedule(ordered, armOrder, search.nodes, search.splitCost, search.armCost);
      bool different = !std::equal(schedule.steps.begin(), schedule.steps.end(), inOrder.steps.begin(),
                                   [](auto a, auto b) { return a.node == b.node && a.opensGuard == b.opensGuard; });
      if (inOrder.branches == schedule.branches && different)
        price(inOrder);
    }
    saved.first->second = observed;
    return observed;
  };

  auto consider = [&](BitVector decision, StringRef placement) {
    auto best = attempt(decision, placement);
    if (!best || !search.stop.empty() || source == "thread-pattern")
      return;
    // Only a protected operation at a public boundary can change an
    // alternation. Start from each supported placement and keep improvements.
    for (auto id = optional.find_first(); id != -1; id = optional.find_next(id)) {
      if (decision.test(id))
        continue;
      auto schedule = phasedSchedule(graph, order, search.nodes, search.splitCost, search.armCost);
      if (schedule.branches <= 1)
        break;
      auto publicNeighbor = [&](unsigned neighbor) { return search.nodes[neighbor].recipe != Recipe::R6; };
      if (llvm::none_of(graph.predecessors[id], publicNeighbor) &&
          llvm::none_of(graph.successors[id], publicNeighbor))
        continue;
      decision.set(id);
      auto next = attempt(decision, (placement + "+repair").str());
      if (next && rank(*next, *best)) {
        best = next;
        ++stats.repairs;
      } else {
        decision.reset(id);
        for (auto node = optional.find_first(); node != -1; node = optional.find_next(node))
          search.nodes[node].recipe = decision.test(node) ? Recipe::R5 : Recipe::R6;
      }
      if (!search.stop.empty())
        break;
    }
  };

  // Keep an emitted candidate for each distinct placement. The unpaired
  // case of all-protect uses the exact original instruction order and CFG.
  const bool empty = llvm::none_of(search.nodes, [](const auto &n) { return n.left && n.right; });
  consider(optional, "all-speculate");
  consider(convexProtection(graph, order, search.nodes, optional), "convex-guard");
  if (empty)
    attempt(BitVector(search.nodes.size()), "all-protect", true);
  else
    consider(BitVector(search.nodes.size()), "all-protect");
  if (optional.any() && search.stop.empty()) {
    auto input = cutInputs(search, optional);
    if (!input) {
      search.stop = toString(input.takeError());
      return stats;
    }
    auto left = dataflow::placement::scan((*input)[0], search.nodes.size());
    auto right = dataflow::placement::scan((*input)[1], search.nodes.size());
    for (const auto &a : left)
      for (const auto &b : right) {
        if (a.upper < a.lower || b.upper < b.lower ||
            static_cast<__int128>(a.lower.n) * b.lower.d +
            static_cast<__int128>(b.lower.n) * a.lower.d >
            static_cast<__int128>(a.lower.d) * b.lower.d)
          continue;
        auto placement = a.speculated;
        placement |= b.speculated;
        ++stats.cuts;
        consider(placement, "min-cut");
        consider(convexProtection(graph, order, search.nodes, placement), "min-cut+convex-guard");
        if (!search.stop.empty())
          return stats;
      }
  }
  llvm::sort(rawCosts);
  auto policy = original;
  if (!rawCosts.empty())
    stats.listMinimum = rawCosts.front();
  for (const auto &cost : rawCosts)
    if (better(cost, policy))
      policy = cost;
  stats.listPolicy = policy;
  return stats;
}
} // namespace
