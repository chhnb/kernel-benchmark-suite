#pragma once

// Included after the reference generator's shared types and emitter.
struct DecisionProblem {
  struct Match { unsigned left, right; Recipe recipe; };
  Search &search;
  SmallVector<const Instruction *, 16> instructions;
  SmallVector<Match, 16> matches;
  std::vector<SmallVector<unsigned, 8>> dependencies;
  DenseMap<const Value *, unsigned> ids;

  explicit DecisionProblem(Search &s) : search(s) {
    auto &shape = search.shape;
    instructions.append(shape.ops[0].begin(), shape.ops[0].end());
    instructions.append(shape.ops[1].begin(), shape.ops[1].end());
    for (unsigned i = 0; i < instructions.size(); ++i)
      ids[instructions[i]] = i;
    dependencies.resize(instructions.size());
    for (unsigned i = 0; i < instructions.size(); ++i) {
      const auto *inst = instructions[i];
      auto add = [&](const Value *v) {
        auto found = ids.find(v);
        if (found != ids.end() && !llvm::is_contained(dependencies[i], found->second))
          dependencies[i].push_back(found->second);
      };
      add(shape.effectBefore.lookup(inst));
      for (const auto &operand : inst->operands()) add(operand.get());
    }
    for (unsigned l = 0; l < shape.ops[0].size(); ++l)
      for (unsigned r = shape.ops[0].size(); r < instructions.size(); ++r)
        for (auto recipe : {Recipe::R1, Recipe::R2, Recipe::R3})
          if (compatible(*instructions[l], *instructions[r], recipe))
            matches.push_back({l, r, recipe});
  }

  unsigned valueID(const Value *value) {
    return ids.try_emplace(value, ids.size()).first->second;
  }

  json::Object describe(dataflow::CostReport &baseline) {
    json::Array operations, pairs, outputs;
    for (unsigned i = 0; i < instructions.size(); ++i) {
      auto *inst = instructions[i];
      json::Array deps, operands;
      for (auto edge : dependencies[i]) deps.push_back(edge);
      for (const auto &operand : inst->operands()) operands.push_back(valueID(operand.get()));
      operations.push_back(json::Object{
        {"side", i < search.shape.ops[0].size() ? 0 : 1},
        {"opcode", inst->getOpcodeName()}, {"safe", search.speculate(*inst)},
        {"operands", std::move(operands)}, {"deps", std::move(deps)}});
    }
    for (const auto &match : matches) {
      const auto *left = instructions[match.left], *right = instructions[match.right];
      json::Array demand;
      for (unsigned i = 0; i < left->getNumOperands(); ++i)
        demand.push_back(json::Array{valueID(left->getOperand(i)),
            valueID(right->getOperand(match.recipe == Recipe::R1 ? i : 1 - i))});
      pairs.push_back(json::Object{{"left", match.left}, {"right", match.right},
          {"recipe", name(match.recipe)}, {"has_result", !left->getType()->isVoidTy()},
          {"demands", std::move(demand)}});
    }
    for (const auto &phi : search.shape.join->phis())
      outputs.push_back(json::Array{
        valueID(phi.getIncomingValueForBlock(search.shape.left)),
        valueID(phi.getIncomingValueForBlock(search.shape.right))});
    auto report = baseline.json();
    report.erase("operations");
    return json::Object{{"status", "ok"}, {"ops", std::move(operations)},
      {"matches", std::move(pairs)}, {"outputs", std::move(outputs)},
      {"baseline", std::move(report)}};
  }

  // Collapse both protected arms to one schedulable unit. A cycle here means
  // a common operation has to separate protected operations.
  Optional<dataflow::Schedule> oneGuard(ArrayRef<Node> nodes, ArrayRef<dataflow::Lane> lanes) {
    const unsigned guard = nodes.size();
    DenseMap<const Instruction *, unsigned> unitOf;
    std::vector<SmallVector<unsigned, 4>> graph(guard + 1);
    bool hasGuard = false;
    for (unsigned i = 0; i < nodes.size(); ++i) {
      auto unit = lanes[i] == dataflow::Lane::Common ? i : guard;
      hasGuard |= unit == guard;
      for (const auto *inst : {nodes[i].left, nodes[i].right})
        if (inst) unitOf[inst] = unit;
    }
    for (unsigned i = 0; i < instructions.size(); ++i) {
      auto unit = unitOf.lookup(instructions[i]);
      for (unsigned predecessor : dependencies[i]) {
        auto pred = unitOf.lookup(instructions[predecessor]);
        if (unit != pred && !llvm::is_contained(graph[unit], pred))
          graph[unit].push_back(pred);
      }
    }
    std::vector<bool> done(graph.size(), false);
    unsigned remaining = nodes.size() + hasGuard;
    if (hasGuard) {
      for (unsigned i = 0; i < nodes.size(); ++i)
        if (lanes[i] != dataflow::Lane::Common) {
          done[i] = true;
          --remaining;
        }
    } else {
      done[guard] = true;
    }
    dataflow::Schedule schedule{unsigned(hasGuard), {}, 0};
    while (remaining) {
      unsigned previous = remaining;
      for (unsigned i = 0; i < graph.size(); ++i) {
        if (done[i] || !llvm::all_of(graph[i], [&](unsigned dep) { return done[dep]; }))
          continue;
        if (i == guard) {
          // Unpaired protected nodes retain original intra-arm SSA order.
          bool first = true;
          for (auto lane : {dataflow::Lane::Left, dataflow::Lane::Right})
            for (unsigned n = 0; n < lanes.size(); ++n)
              if (lanes[n] == lane) {
                schedule.steps.push_back({n, first});
                first = false;
              }
        } else
          schedule.steps.push_back({i, false});
        done[i] = true;
        --remaining;
      }
      if (previous == remaining)
        return None;
    }
    return schedule;
  }

  json::Object evaluate(const json::Object &request) {
    auto fail = [](StringRef explanation, StringRef status = "error") {
      return json::Object{{"status", status.str()}, {"reason", explanation.str()}};
    };
    auto *chosen = request.getArray("matches"), *guards = request.getArray("guards");
    if (!chosen || !guards)
      return fail("expected matches and guards");
    DenseMap<unsigned, unsigned> selection;
    DenseSet<unsigned> protectedOps;
    for (const auto &item : *chosen) {
      auto index = item.getAsInteger();
      if (!index || *index < 0 || size_t(*index) >= matches.size())
        return fail("invalid match index");
      const auto &match = matches[*index];
      if (!selection.try_emplace(match.left, *index).second ||
          !selection.try_emplace(match.right, *index).second)
        return fail("non-disjoint matches");
    }
    for (const auto &item : *guards) {
      auto index = item.getAsInteger();
      if (!index || *index < 0 || size_t(*index) >= instructions.size() ||
          selection.count(*index))
        return fail("invalid protected operation");
      protectedOps.insert(*index);
    }
    SmallVector<Node, 16> nodes;
    SmallVector<dataflow::Lane, 16> lanes;
    unsigned split = search.shape.ops[0].size();
    for (unsigned i = 0; i < instructions.size(); ++i) {
      auto match = selection.find(i);
      if (match != selection.end()) {
        if (i < split) {
          const auto &pair = matches[match->second];
          nodes.push_back({instructions[i], instructions[pair.right], pair.recipe});
          lanes.push_back(dataflow::Lane::Common);
        }
      } else {
        bool guard = protectedOps.count(i);
        if (!guard && !search.speculate(*instructions[i]))
          return fail("unsafe speculation");
        nodes.push_back({i < split ? instructions[i] : nullptr,
                         i >= split ? instructions[i] : nullptr, guard ? Recipe::R6 : Recipe::R5});
        lanes.push_back(!guard ? dataflow::Lane::Common :
                        i < split ? dataflow::Lane::Left : dataflow::Lane::Right);
      }
    }
    dataflow::Schedule schedule;
    if (nodes.size() <= 16) {
      auto graph = ::dependencies(search.shape, nodes);
      if (!acyclic(graph))
        return fail("cyclic paired dependency graph");
      schedule = dataflow::minimumGuards(graph, lanes, search.splitCost, search.armCost);
      if (schedule.branches > 1)
        return fail("protected operations separated by a common operation", "multi_guard");
    } else {
      auto simple = oneGuard(nodes, lanes);
      if (!simple)
        return fail("protected operations separated by a common operation", "multi_guard");
      schedule = std::move(*simple);
    }
    auto emitted = emit(search.module, search.func, search.shape, nodes, schedule,
                        bool(search.throughput));
    if (!emitted.module)
      return fail("unsafe observation of escaped poison", "invalid_generation");
    if (verifyModule(*emitted.module, &errs()))
      return fail("candidate failed LLVM12 verifier");
    auto result = dataflow::evaluate(*emitted.module->getFunction(search.func.getName()),
                                    search.costs, false, search.quotes, true, false,
                                    search.throughput);
    if (!result) {
      auto error = toString(result.takeError());
      return fail(error, StringRef(error).contains("must be speculated by SimplifyCFG")
                         ? "mandatory_fold" : "error");
    }
    if (auto destination = request.getString("emit")) {
      std::error_code error;
      raw_fd_ostream out(*destination, error);
      if (error)
        return fail(error.message());
      emitted.module->print(out, nullptr);
    }
    auto report = result->json();
    json::Object components;
    for (auto key : {"instruction", "select", "control", "escape"})
      components[key] = json::Array{0, 0, 0};
    for (const auto &value : *report.getArray("operations")) {
      const auto &op = *value.getAsObject();
      auto category = *op.getString("kind"), scenarios = *op.getString("scenarios");
      if (category == "memory") category = "instruction";
      if (category == "folded-condition" || category == "simplified-select" ||
          category == "folded-join") category = "select";
      auto &vec = *components.getArray(category);
      StringRef tags("DLR");
      for (unsigned i = 0; i < tags.size(); ++i)
        if (scenarios.contains(tags[i]))
          vec[i] = *vec[i].getAsInteger() + *op.getInteger("cost");
    }
    report.erase("operations");
    report["component_vectors"] = std::move(components);
    report["status"] = "ok";
    report["pairs"] = std::move(emitted.pairs);
    report["features"] = json::Object{
      {"crossed", emitted.crossed}, {"commute", emitted.commute}, {"cmp_swap", emitted.cmpSwap},
      {"shared_select", emitted.sharedSelect}, {"paired_memory", emitted.pairedMemory},
      {"speculate_then_select", emitted.speculateSelect}, {"multiple_guards", result->branches > 1}};
    json::Array recipes;
    for (const auto &recipe : emitted.recipes) recipes.push_back(recipe);
    report["recipes"] = std::move(recipes);
    return report;
  }
};

static void quotedLine(json::Object result) {
  outs() << json::Value(std::move(result)) << '\n';
  outs().flush();
}

static int decisionBridge(Search &search, Expected<dataflow::CostReport> &baseline) {
  if (!baseline) {
    quotedLine(json::Object{{"status", "unsupported"}, {"reason", toString(baseline.takeError())}});
    return 0;
  }
  if (!readDiamond(search.func, search.shape)) {
    quotedLine(json::Object{{"status", "unsupported"}, {"reason", "unsupported source CFG"}});
    return 0;
  }
  DecisionProblem problem(search);
  quotedLine(problem.describe(*baseline));
  for (std::string line; std::getline(std::cin, line);) {
    auto parsed = json::parse(line);
    if (!parsed) {
      quotedLine(json::Object{{"status", "error"}, {"reason", toString(parsed.takeError())}});
      continue;
    }
    const auto *object = parsed->getAsObject();
    quotedLine(object ? problem.evaluate(*object) :
                        json::Object{{"status", "error"}, {"reason", "expected JSON object"}});
  }
  return 0;
}
