#pragma once

#include "reference_generation.h"
#include "cleanup_llvm.h"
#include "placement_cut.h"
#include <map>

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
                            bool compareCleanup,
                            function_ref<bool(const Cost &, const Cost &)> better) {
  ScaleStats stats;
  auto graph = generationGraph(search.shape, search.nodes);
  auto order = topologicalOrder(graph);
  if (order.size() != search.nodes.size()) {
    search.stop = "pairing creates a dependency cycle";
    return stats;
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
  std::map<std::vector<unsigned>, Optional<Cost>> seen;
  auto attempt = [&](const BitVector &speculated, bool baseline = false) -> Optional<Cost> {
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
    ++search.candidates;
    auto candidate = emit(search.module, search.func, search.shape, search.nodes, schedule,
                          bool(search.throughput), compareCleanup);
    if (baseline)
      candidate.module = CloneModule(search.module);
    if (!candidate.module) {
      ++search.unsupportedGeneration;
      return None;
    }
    if (verifyModule(*candidate.module, &errs())) {
      search.stop = "phase schedule failed LLVM12 verifier";
      return None;
    }
    search.selectedGuards = schedule.branches;
    search.selectedControl = schedule.controlCost;
    auto rejected = search.rejectedFold;
    Optional<Cost> observed;
    if (!baseline)
      search.add(*candidate.module, false, &candidate, false, &observed);
    if (!search.stop.empty())
      return None;
    if (compareCleanup && search.oracleQuotes) {
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
      search.add(*cleanedModule, false, &candidate, false, &cleaned, true, candidate.module.get());
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
    saved.first->second = observed;
    return observed;
  };

  auto consider = [&](BitVector decision) {
    auto best = attempt(decision);
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
      auto next = attempt(decision);
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

  // All-safe speculation is the prescribed thread-pattern placement and the
  // zero-overhead extreme for the unconstrained minimum on other sources.
  consider(optional);
  if (source != "thread-pattern" && optional.any() && search.stop.empty()) {
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
        consider(std::move(placement));
        if (!search.stop.empty())
          return stats;
      }
  }
  if (compareCleanup && llvm::none_of(search.nodes, [](const auto &n) { return n.left && n.right; }))
    attempt(BitVector(search.nodes.size()), true);
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
