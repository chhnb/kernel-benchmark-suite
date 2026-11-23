#include "dataflow_pairing.h"
#include "cost_model.h"
#include "llvm/ADT/BitVector.h"
#include "llvm/IR/IRBuilder.h"
#include <functional>
#include <numeric>

namespace dataflow::pairing {
namespace {
struct Match {
  Node node;
  unsigned left, right;
  unsigned produces;
  SmallVector<unsigned, 4> needs;
  int64_t saved;
  SmallVector<unsigned, 4> neighbors;
};

constexpr unsigned NoValuePair = ~0u;

struct Problem {
  std::vector<Match> matches;
  DenseMap<ValuePair, unsigned> ids;
  std::vector<ValuePair> values;
  std::vector<unsigned> outputs;
  std::vector<int64_t> prices;
  std::vector<BitVector> before[2];
  BitVector required[2];
  unsigned requiredCount[2]{};
  int64_t split = 0, arm[2]{};
  std::vector<std::pair<unsigned, int64_t>> escapes;

  int64_t guardCredit(unsigned left, unsigned right) const {
    bool removed[2]{requiredCount[0] && left == requiredCount[0],
                    requiredCount[1] && right == requiredCount[1]};
    unsigned mask = unsigned(removed[0]) | (unsigned(removed[1]) << 1);
    int64_t credit = (removed[0] ? arm[0] : 0) + (removed[1] ? arm[1] : 0);
    if (mask && (!requiredCount[0] || removed[0]) && (!requiredCount[1] || removed[1]))
      credit += split;
    for (const auto &[producers, price] : escapes)
      if ((producers & mask) == producers)
        credit += price;
    return credit;
  }


  unsigned value(const Value *l, const Value *r) {
    if (l == r)
      return NoValuePair;
    auto inserted = ids.try_emplace({l, r}, values.size());
    if (inserted.second)
      values.push_back({l, r});
    return inserted.first->second;
  }

  bool conflicts(unsigned a, unsigned b) const {
    return matches[a].left == matches[b].left || matches[a].right == matches[b].right;
  }

  // Contracting paired instructions creates a cycle iff a cycle exists among
  // the paired vertices in the union of the two original reachability orders.
  // Unpaired instructions can only subdivide edges of that projected graph.
  bool acyclic(ArrayRef<unsigned> selected) const {
    auto edge = [&](unsigned a, unsigned b) {
      const auto &x = matches[selected[a]], &y = matches[selected[b]];
      return before[0][y.left].test(x.left) || before[1][y.right].test(x.right);
    };
    SmallVector<unsigned, 32> degree(selected.size(), 0), ready;
    for (unsigned b = 0; b < selected.size(); ++b) {
      for (unsigned a = 0; a < selected.size(); ++a)
        degree[b] += edge(a, b);
      if (!degree[b])
        ready.push_back(b);
    }
    unsigned count = 0;
    while (!ready.empty()) {
      auto a = ready.pop_back_val();
      ++count;
      for (unsigned b = 0; b < selected.size(); ++b)
        if (edge(a, b) && --degree[b] == 0)
          ready.push_back(b);
    }
    return count == selected.size();
  }

  int64_t gain(ArrayRef<unsigned> selected) const {
    if (selected.empty())
      return 0;
    SmallDenseSet<unsigned, 32> produced, demanded;
    int64_t score = 0;
    for (auto output : outputs) {
      demanded.insert(output);
      score += prices[output];
    }
    unsigned covered[2]{};
    for (auto id : selected) {
      const auto &match = matches[id];
      score += match.saved;
      covered[0] += required[0].test(match.left);
      covered[1] += required[1].test(match.right);
      if (match.produces != NoValuePair)
        produced.insert(match.produces);
      demanded.insert(match.needs.begin(), match.needs.end());
    }
    for (auto demand : demanded)
      if (!produced.count(demand))
        score -= prices[demand];
    return score + guardCredit(covered[0], covered[1]);
  }
};

Error invalid(const Twine &message) {
  return createStringError(inconvertibleErrorCode(), message);
}

void buildReachability(const Diamond &shape, Problem &problem, unsigned side) {
  DenseMap<const Value *, unsigned> indices;
  const auto &ops = shape.ops[side];
  auto &before = problem.before[side];
  for (auto indexed : llvm::enumerate(ops)) {
    auto i = indexed.index();
    auto *inst = indexed.value();
    before.emplace_back(ops.size());
    auto dependency = [&](const Value *value) {
      auto found = indices.find(value);
      if (found != indices.end()) {
        before[i].set(found->second);
        before[i] |= before[found->second];
      }
    };
    dependency(shape.effectBefore.lookup(inst));
    for (const auto &operand : inst->operands())
      dependency(operand.get());
    indices[inst] = i;
  }
}

Expected<std::vector<int64_t>> quoteChoices(
    const Problem &problem, const Function &function, const json::Object &table,
    function_ref<Expected<InstructionCosts>(const Function &)> quote) {
  std::vector<int64_t> result(problem.values.size());
  if (!quote) {
    for (auto indexed : llvm::enumerate(problem.values)) {
      auto [left, right] = indexed.value();
      auto *l = dyn_cast<ConstantInt>(left), *r = dyn_cast<ConstantInt>(right);
      auto price = *table.getObject("op")->getInteger("select");
      if (l && r && left->getType()->isIntegerTy(1))
        price = *table.getInteger("select_i1_folded_to_condition");
      else if (l && r && ((l->isOne() && r->isZero()) || (l->isZero() && r->isOne())))
        price = *table.getObject("op")->getInteger("zext");
      result[indexed.index()] = price;
    }
    return result;
  }
  if (problem.values.empty())
    return result;

  // A probe uses the same operand forms within a type: constants keep their
  // exact spelling, C keeps its identity, and other values are SSA inputs.
  // Quote each form once even when thousands of distinct demands use it.
  const auto *sourceCondition = function.getArg(0);
  auto form = [&](const Value *value) {
    return value == sourceCondition || isa<Constant>(value) ? value : nullptr;
  };
  DenseMap<Type *, DenseMap<ValuePair, unsigned>> formIDs;
  std::vector<ValuePair> forms;
  std::vector<Type *> formTypes;
  std::vector<unsigned> formOf;
  for (auto [left, right] : problem.values) {
    auto *type = left->getType();
    ValuePair key{form(left), form(right)};
    auto inserted = formIDs[type].try_emplace(key, forms.size());
    if (inserted.second) {
      forms.push_back(key);
      formTypes.push_back(type);
    }
    formOf.push_back(inserted.first->second);
  }
  std::vector<int64_t> formPrices(forms.size());
  // Bound the reply size of the existing persistent quotation transport.
  constexpr unsigned quoteBatch = 128;
  for (unsigned offset = 0; offset < forms.size(); offset += quoteBatch) {
    auto values = ArrayRef<ValuePair>(forms).drop_front(offset).take_front(quoteBatch);
    // Keep real constants and type information. Independent SSA parameters
    // stand for values whose producers are chosen during scheduling.
    auto &context = function.getContext();
    Module probe("dataflow-choice-cost", context);
    probe.setDataLayout(function.getParent()->getDataLayout());
    probe.setTargetTriple(function.getParent()->getTargetTriple());
    SmallVector<Type *, 16> types{Type::getInt1Ty(context)};
    DenseMap<Type *, std::array<unsigned, 2>> dummy;
    for (unsigned i = 0; i < values.size(); ++i) {
      auto *type = formTypes[offset + i];
      if (dummy.try_emplace(type, std::array<unsigned, 2>{static_cast<unsigned>(types.size()),
                                                           static_cast<unsigned>(types.size()+1)}).second)
        types.append(2, type);
    }
    auto *fn = Function::Create(FunctionType::get(Type::getVoidTy(context), types, false),
                                GlobalValue::ExternalLinkage, function.getName(), probe);
    fn->addFnAttr("target-cpu", function.getFnAttribute("target-cpu").getValueAsString());
    if (function.hasFnAttribute("target-features"))
      fn->addFnAttr("target-features", function.getFnAttribute("target-features").getValueAsString());
    IRBuilder<> builder(BasicBlock::Create(context, "entry", fn));
    auto *condition = fn->getArg(0);
    auto map = [&](const Value *value, Type *type, unsigned side) -> Value * {
      if (!value)
        return fn->getArg(dummy.lookup(type)[side]);
      if (value == sourceCondition)
        return condition;
      return const_cast<Constant *>(cast<Constant>(value));
    };
    std::vector<SmallVector<Instruction *, 2>> groups;
    for (auto indexed : llvm::enumerate(values)) {
      auto [left, right] = indexed.value();
      auto *type = formTypes[offset + indexed.index()];
      auto &group = groups.emplace_back();
      auto *l = dyn_cast_or_null<ConstantInt>(left), *r = dyn_cast_or_null<ConstantInt>(right);
      if (l && r && ((l->isOne() && r->isZero()) || (l->isZero() && r->isOne()))) {
        Value *test = condition;
        if (l->isZero()) {
          auto *negated = cast<Instruction>(builder.CreateNot(condition));
          group.push_back(negated);
          test = negated;
        }
        if (!type->isIntegerTy(1))
          group.push_back(cast<Instruction>(builder.CreateZExt(test, type)));
      } else {
        if (auto *select = dyn_cast<Instruction>(builder.CreateSelect(condition, map(left, type, 0), map(right, type, 1))))
          group.push_back(select);
      }
    }
    builder.CreateRetVoid();
    auto quotes = quote(*fn);
    if (!quotes)
      return quotes.takeError();
    for (auto indexed : llvm::enumerate(groups))
      for (auto *inst : indexed.value()) {
        auto price = quotes->find(inst);
        if (price == quotes->end())
          return invalid(Twine("missing LLVM24 quote for selection form ") + inst->getOpcodeName());
        formPrices[offset + indexed.index()] += price->second;
      }
  }
  for (auto indexed : llvm::enumerate(formOf))
    result[indexed.index()] = formPrices[indexed.value()];
  return result;
}

std::vector<unsigned> exact(const Problem &problem, ArrayRef<unsigned> component) {
  // Ignoring all operand-selection charges gives a valid upper bound. Only
  // outputs produced by the current prefix or an unvisited match can save κ.
  DenseSet<unsigned> outputs(problem.outputs.begin(), problem.outputs.end());
  auto credit = [&](unsigned id) {
    const auto &m = problem.matches[id];
    bool output = m.produces != NoValuePair && outputs.count(m.produces);
    return m.saved + (output ? problem.prices[m.produces] : 0);
  };
  BitVector cover[2]{BitVector(problem.required[0].size()), BitVector(problem.required[1].size())};
  for (auto id : component) {
    const auto &m = problem.matches[id];
    if (problem.required[0].test(m.left)) cover[0].set(m.left);
    if (problem.required[1].test(m.right)) cover[1].set(m.right);
  }
  const auto guardUpper = problem.guardCredit(cover[0].count(), cover[1].count());
  SmallVector<int64_t, 21> remaining(component.size() + 1, 0);
  for (unsigned i = component.size(); i > 0; --i)
    remaining[i-1] = remaining[i] + std::max<int64_t>(0, credit(component[i-1]));
  std::vector<unsigned> selected, best;
  int64_t bestGain = 0;
  std::function<void(unsigned, int64_t)> visit = [&](unsigned i, int64_t gross) {
    if (gross + remaining[i] + guardUpper <= bestGain)
      return;
    if (i == component.size()) {
      auto gain = problem.gain(selected);
      if (gain > bestGain) {
        bestGain = gain;
        best = selected;
      }
      return;
    }
    auto id = component[i];
    if (llvm::none_of(selected, [&](auto chosen) { return problem.conflicts(id, chosen); })) {
      selected.push_back(id);
      if (problem.acyclic(selected))
        visit(i+1, gross + credit(id));
      selected.pop_back();
    }
    visit(i+1, gross);
  };
  visit(0, 0);
  return best;
}

std::vector<unsigned> greedy(const Problem &problem, ArrayRef<unsigned> component) {
  std::vector<unsigned> best;
  int64_t bestGain = 0;
  for (auto seed : component.take_front(3)) {
    std::vector<unsigned> selected{seed};
    auto gain = problem.gain(selected);
    while (true) {
      SmallDenseSet<unsigned, 32> adjacent;
      for (auto id : selected) {
        const auto &neighbors = problem.matches[id].neighbors;
        adjacent.insert(neighbors.begin(), neighbors.end());
      }
      SmallVector<unsigned, 32> ordered(adjacent.begin(), adjacent.end());
      llvm::sort(ordered);
      Optional<unsigned> add;
      auto improved = gain;
      for (auto id : ordered) {
        if (llvm::any_of(selected, [&](auto chosen) { return problem.conflicts(id, chosen); }))
          continue;
        selected.push_back(id);
        auto score = problem.gain(selected);
        if (score > improved && problem.acyclic(selected)) {
          improved = score;
          add = id;
        }
        selected.pop_back();
      }
      if (!add)
        break;
      selected.push_back(*add);
      gain = improved;
    }
    while (true) {
      auto improved = gain;
      std::vector<unsigned> next;
      for (unsigned i = 0; i < selected.size(); ++i) {
        auto trial = selected;
        trial.erase(trial.begin() + i);
        if (auto score = problem.gain(trial); score > improved) {
          improved = score;
          next = trial;
        }
        for (auto id : component) {
          if (!problem.conflicts(id, selected[i]) || id == selected[i] ||
              llvm::any_of(trial, [&](auto other) { return problem.conflicts(id, other); }))
            continue;
          trial.push_back(id);
          if (auto score = problem.gain(trial); score > improved && problem.acyclic(trial)) {
            improved = score;
            next = trial;
          }
          trial.pop_back();
        }
      }
      if (improved == gain)
        break;
      selected = std::move(next);
      gain = improved;
    }
    if (gain > bestGain) {
      best = std::move(selected);
      bestGain = gain;
    }
  }
  return best;
}
} // namespace

Expected<Result> choose(const Function &function, const Diamond &shape, const json::Object &table, bool subplans,
                        function_ref<Expected<InstructionCosts>(const Function &)> quote) {
  Problem problem;
  Result result;
  // Triangles have no cross-arm candidates and need no pair-graph pricing.
  if (shape.ops[0].empty() || shape.ops[1].empty())
    return result;
  InstructionCosts quotes;
  if (quote) {
    auto quoted = quote(function);
    if (!quoted)
      return quoted.takeError();
    quotes = std::move(*quoted);
  }
  auto control = [&](const Instruction *inst, int64_t fallback) {
    return quote ? quotes.lookup(inst) : fallback;
  };
  problem.split = control(shape.branch, *table.getInteger("guard_segment_control"));
  DenseMap<const Value *, unsigned> sides;
  for (unsigned side : {0u, 1u}) {
    const auto &ops = shape.ops[side];
    problem.required[side].resize(ops.size());
    for (auto op : llvm::enumerate(ops)) {
      sides[op.value()] = 1u << side;
      if (!speculationFailure(*op.value(), table).empty())
        problem.required[side].set(op.index());
    }
    problem.requiredCount[side] = problem.required[side].count();
    auto *block = side ? shape.right : shape.left;
    problem.arm[side] = control(block->getTerminator(), 0);
  }
  for (const auto &phi : shape.join->phis()) {
    auto id = problem.value(phi.getIncomingValueForBlock(shape.left),
                            phi.getIncomingValueForBlock(shape.right));
    if (id != NoValuePair && !llvm::is_contained(problem.outputs, id)) {
      problem.outputs.push_back(id);
      unsigned mask = 0;
      for (auto *block : {shape.left, shape.right}) {
        auto side = sides.lookup(phi.getIncomingValueForBlock(block));
        if (side && problem.requiredCount[side == 2])
          mask |= side;
      }
      if (mask)
        problem.escapes.emplace_back(mask, control(&phi, *table.getInteger("guard_escape_merge")));
    }
  }
  for (auto l : llvm::enumerate(shape.ops[0]))
    for (auto r : llvm::enumerate(shape.ops[1]))
      for (auto recipe : {Recipe::R1, Recipe::R2, Recipe::R3}) {
        if (!compatible(*l.value(), *r.value(), recipe))
          continue;
        auto found = quotes.find(r.value());
        auto saved = quote ? (found == quotes.end() ? None : Optional<int64_t>(found->second))
                           : costOf(*r.value(), table);
        if (!saved)
          return invalid(Twine("missing paired-operation quote for ") + r.value()->getOpcodeName());
        Match match{{l.value(), r.value(), recipe},
                    static_cast<unsigned>(l.index()), static_cast<unsigned>(r.index()),
                    l.value()->getType()->isVoidTy() ? NoValuePair : problem.value(l.value(), r.value()),
                    {}, *saved, {}};
        for (unsigned i = 0; i < l.value()->getNumOperands(); ++i) {
          auto id = problem.value(l.value()->getOperand(i), r.value()->getOperand(recipe == Recipe::R1 ? i : 1-i));
          if (id != NoValuePair && !llvm::is_contained(match.needs, id))
            match.needs.push_back(id);
        }
        problem.matches.push_back(std::move(match));
      }
  result.candidates = problem.matches.size();
  if (problem.matches.empty())
    return result;
  auto prices = quoteChoices(problem, function, table, quote);
  if (!prices)
    return prices.takeError();
  problem.prices = std::move(*prices);
  for (unsigned side : {0u, 1u})
    buildReachability(shape, problem, side);

  std::vector<SmallVector<unsigned, 2>> producers(problem.values.size());
  for (auto m : llvm::enumerate(problem.matches))
    if (m.value().produces != NoValuePair)
      producers[m.value().produces].push_back(m.index());
  for (auto m : llvm::enumerate(problem.matches))
    for (auto need : m.value().needs)
      for (auto producer : producers[need]) {
        problem.matches[producer].neighbors.push_back(m.index());
        m.value().neighbors.push_back(producer);
      }
  std::vector<std::vector<unsigned>> winners;
  BitVector seen(problem.matches.size());
  for (unsigned id = 0; id < problem.matches.size(); ++id) {
    if (seen.test(id))
      continue;
    std::vector<unsigned> component{id};
    seen.set(id);
    for (unsigned i = 0; i < component.size(); ++i)
      for (auto neighbor : problem.matches[component[i]].neighbors)
        if (!seen.test(neighbor)) {
          seen.set(neighbor);
          component.push_back(neighbor);
        }
    llvm::sort(component, [&](unsigned a, unsigned b) {
      return std::make_pair(-problem.matches[a].saved, a) <
             std::make_pair(-problem.matches[b].saved, b);
    });
    bool small = component.size() <= 20;
    auto winner = small ? exact(problem, component) : greedy(problem, component);
    result.components.push_back({static_cast<unsigned>(component.size()), small, problem.gain(winner)});
    winners.push_back(std::move(winner));
  }

  std::vector<unsigned> order(winners.size());
  std::iota(order.begin(), order.end(), 0);
  llvm::stable_sort(order, [&](unsigned a, unsigned b) {
    return result.components[a].gain > result.components[b].gain;
  });
  std::vector<unsigned> chosen;
  for (auto component : order)
    for (auto match : winners[component]) {
      if (llvm::any_of(chosen, [&](auto other) { return problem.conflicts(match, other); }))
        continue;
      chosen.push_back(match);
      if (!problem.acyclic(chosen))
        chosen.pop_back();
    }
  // A guard may be eliminated only by coordinating candidates from several
  // components. For small sets of guard-covering matches, search their union.
  std::vector<unsigned> cover;
  for (auto indexed : llvm::enumerate(problem.matches)) {
    const auto &m = indexed.value();
    if (problem.required[0].test(m.left) || problem.required[1].test(m.right)) {
      cover.push_back(indexed.index());
      if (cover.size() > 20)
        break;
    }
  }
  if (!cover.empty() && cover.size() <= 20) {
    auto coordinated = exact(problem, cover);
    for (auto id : chosen)
      if (llvm::none_of(coordinated, [&](auto other) { return problem.conflicts(id, other); })) {
        coordinated.push_back(id);
        if (!problem.acyclic(coordinated))
          coordinated.pop_back();
      }
    if (problem.gain(coordinated) > problem.gain(chosen))
      chosen = std::move(coordinated);
  }

  auto nodes = [&](std::vector<unsigned> ids) {
    llvm::sort(ids, [&](unsigned a, unsigned b) { return problem.matches[a].left < problem.matches[b].left; });
    std::vector<Node> plan;
    for (auto id : ids)
      plan.push_back(problem.matches[id].node);
    return plan;
  };
  result.gain = problem.gain(chosen);
  result.selected = nodes(chosen);
  // Follow chains of selected producers with a single dependent. A singleton
  // is also a chain. Break ties by the source candidate index.
  for (unsigned round = 0; subplans && !chosen.empty() && round < 4; ++round) {
    std::vector<unsigned> best;
    int64_t bestGain = std::numeric_limits<int64_t>::min();
    SmallDenseSet<unsigned, 32> active(chosen.begin(), chosen.end());
    for (auto id : chosen) {
      SmallDenseSet<unsigned, 8> chain;
      chain.insert(id);
      auto sink = id;
      while (true) {
        Optional<unsigned> predecessor;
        for (auto need : problem.matches[sink].needs)
          for (auto prod : producers[need])
            if (active.count(prod) && !chain.count(prod)) {
              unsigned uses = llvm::count_if(problem.matches[prod].neighbors, [&](unsigned user) {
                return active.count(user) && llvm::is_contained(problem.matches[user].needs,
                                                                 problem.matches[prod].produces);
              });
              if (uses == 1 && (!predecessor || prod < *predecessor))
                predecessor = prod;
            }
        if (!predecessor)
          break;
        sink = *predecessor;
        chain.insert(sink);
      }
      std::vector<unsigned> trial;
      for (auto other : chosen)
        if (!chain.count(other))
          trial.push_back(other);
      auto value = problem.gain(trial);
      if (value > bestGain) {
        bestGain = value;
        best = std::move(trial);
      }
    }
    chosen = std::move(best);
    result.subsets.push_back(nodes(chosen));
  }
  return result;
}
} // namespace dataflow::pairing
