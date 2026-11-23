#include "dataflow_pairing.h"
#include "scalable_generation.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/Program.h"

namespace {
struct Options {
  StringRef worker = "tools/run-llvm24-tti";
  std::string fusion;
  StringRef source = "data";
  bool real = false, realSL = true, pairingOnly = false, compareDP = false;
};

std::string pathIn(StringRef root, const Twine &name) {
  SmallString<256> path(root);
  sys::path::append(path, name.str());
  return path.str().str();
}

Error fail(const Twine &reason) {
  return createStringError(inconvertibleErrorCode(), reason);
}

bool samePlan(ArrayRef<Node> a, ArrayRef<Node> b) {
  return a.size() == b.size() && std::equal(a.begin(), a.end(), b.begin(),
      [](const Node &x, const Node &y) {
        return x.left == y.left && x.right == y.right && x.recipe == y.recipe;
      });
}

json::Array describe(const Diamond &shape, ArrayRef<Node> pairs) {
  json::Array output;
  for (const auto &p : pairs)
    output.push_back(json::Object{
        {"opcode", p.left->getOpcodeName()}, {"recipe", name(p.recipe)},
        {"left_index", std::distance(shape.ops[0].begin(), llvm::find(shape.ops[0], p.left))},
        {"right_index", std::distance(shape.ops[1].begin(), llvm::find(shape.ops[1], p.right))}});
  return output;
}

struct Comparator {
  Optional<std::vector<Node>> plan;
  json::Object report;
};

Expected<std::vector<Node>> readPlan(const Diamond &shape, const json::Array &pairs) {
  std::vector<Node> plan;
  SmallPtrSet<const Instruction *, 16> seenLeft, seenRight;
  for (const auto &pair : pairs) {
    const auto *entry = pair.getAsObject();
    if (!entry)
      return fail("invalid emitted pair");
    auto l = entry->getInteger("left_index"), r = entry->getInteger("right_index");
    auto swap = entry->getBoolean("swapped_operands");
    if (!l || !r || !swap || *l < 0 || *r < 0 ||
        static_cast<uint64_t>(*l) >= shape.ops[0].size() ||
        static_cast<uint64_t>(*r) >= shape.ops[1].size())
      return fail("emitted pair is outside the source arms");
    auto *left = shape.ops[0][*l], *right = shape.ops[1][*r];
    auto recipe = !*swap ? Recipe::R1 : compatible(*left, *right, Recipe::R2) ? Recipe::R2 : Recipe::R3;
    if (!compatible(*left, *right, recipe))
      return fail(Twine("emitted pair (") + Twine(*l) + ", " + Twine(*r) + ") " +
                  left->getOpcodeName() + "/" + right->getOpcodeName() + " fails reference compatible");
    if (!seenLeft.insert(left).second || !seenRight.insert(right).second)
      return fail("emitted pairs are not one-to-one");
    plan.push_back({left, right, recipe});
  }
  llvm::sort(plan, [](const Node &a, const Node &b) { return a.left->comesBefore(b.left); });
  return plan;
}

Comparator collect(StringRef strategy, StringRef input, StringRef directory,
                   const Function &function, const Search &search, const Cost &original,
                   const Options &opts) {
  Comparator result;
  auto &report = result.report;
  if (search.shape.ops[0].empty() || search.shape.ops[1].empty()) {
    report["status"] = "unchanged_triangle";
    report["T"] = json::Array{original[0], original[1], original[2]};
    result.plan.emplace();
    return result;
  }
  std::string work = pathIn(directory, strategy);
  std::string cleaned = pathIn(work, "cleaned.ll");
  std::string trace = pathIn(work, "trace");
  std::string stdoutPath = pathIn(work, "stdout.txt"), stderrPath = pathIn(work, "stderr.txt");
  if (auto error = sys::fs::create_directories(work)) {
    report["reason"] = error.message();
    return result;
  }
  std::string left = "B" + std::to_string(std::distance(function.begin(), search.shape.left->getIterator()));
  std::string right = "B" + std::to_string(std::distance(function.begin(), search.shape.right->getIterator()));
  StringRef args[]{opts.fusion, "--ir", input, "--function", function.getName(),
      "--out", cleaned, "--debug-dir", trace, "--split", "B0", "--left", left, "--right", right,
      "--b2b-strategy", strategy, "--tti-worker", opts.worker, "--observe-source-pairs", "1",
      "--ir-snapshots", "compact"};
  Optional<StringRef> redirects[]{StringRef(""), StringRef(stdoutPath), StringRef(stderrPath)};
  auto code = sys::ExecuteAndWait(opts.fusion, args, None, redirects, 120);
  auto file = MemoryBuffer::getFile(pathIn(trace, "trial-0/trial.json"));
  if (!file) {
    report["reason"] = (Twine("no strategy trial report, exit ") + Twine(code)).str();
    if (auto diagnostic = MemoryBuffer::getFile(stderrPath))
      if (!(*diagnostic)->getBuffer().trim().empty())
        report["reason"] = (*diagnostic)->getBuffer().trim().str();
    return result;
  }
  auto json = json::parse((*file)->getBuffer());
  if (!json) {
    report["reason"] = toString(json.takeError());
    return result;
  }
  const auto *trial = json->getAsObject();
  if (!trial || !trial->getBoolean("valid").getValueOr(false)) {
    report["reason"] = trial ? trial->getString("reason").getValueOr("invalid strategy trial").str() :
                               "invalid strategy trial report";
    return result;
  }
  if (const auto *pairs = trial->getArray("source_pairs")) {
    report["source_pairs"] = json::Array(*pairs);
    auto plan = readPlan(search.shape, *pairs);
    if (plan)
      result.plan = std::move(*plan);
    else
      report["reason"] = toString(plan.takeError());
  } else {
    report["reason"] = "strategy did not emit complete source pairing provenance";
  }
  SMDiagnostic diagnostic;
  auto module = parseIRFile(cleaned, diagnostic, function.getContext());
  if (!module || !module->getFunction(function.getName())) {
    report["cost_reason"] = "cleaned strategy output unavailable";
    return result;
  }
  auto priced = dataflow::evaluate(*module->getFunction(function.getName()), search.costs,
      false, search.quotes, false, true, search.throughput);
  if (priced) {
    auto &t = priced->total;
    report["T"] = json::Array{t[0], t[1], t[2]};
    report["status"] = "priced";
  } else {
    report["cost_reason"] = toString(priced.takeError());
  }
  return result;
}

bool preferred(const Cost &a, const Cost &b, const Cost &original, StringRef source) {
  if (source == "data" && (a[1] > original[1] || a[2] > original[2]))
    return false;
  if (source == "workgroup-uniform")
    return std::max(a[1], a[2]) < std::max(b[1], b[2]);
  return a < b;
}

json::Object generate(Search &search, ArrayRef<Node> pairs, const FrontEntry &original,
                      StringRef directory, StringRef label, StringRef source, bool compareDP) {
  auto generationStart = Clock::now();
  search.front.clear();
  search.stop.clear();
  search.pairings.clear();
  search.nodes.clear();
  search.usedRight.clear();
  search.candidates = search.verified = search.cyclic = 0;
  search.dpMismatches = search.unsupportedGeneration = search.rejectedFold = 0;
  DenseMap<const Instruction *, Node> byLeft;
  for (auto pair : pairs) {
    byLeft.insert({pair.left, pair});
    search.usedRight.insert(pair.right);
  }
  for (auto *op : search.shape.ops[0]) {
    auto pair = byLeft.find(op);
    search.nodes.push_back(pair == byLeft.end() ? Node{op, nullptr, Recipe::R6} : pair->second);
  }
  search.recordPairing(false);
  if (search.pairings.empty())
    return json::Object{{"reason", "pairing creates a dependency cycle"}};
  auto &plan = search.pairings.front();
  search.nodes = plan.nodes;
  search.current = &plan;
  const bool small = search.shape.ops[0].size() + search.shape.ops[1].size() <= 10;
  auto prefer = [&](const Cost &a, const Cost &b) { return preferred(a, b, original.cost, source); };
  auto stats = generateScalable(search, original.cost, source, !small, prefer);
  Optional<Cost> referenceMin, referencePolicy;
  std::string discrepancy;
  if (compareDP && small && search.stop.empty()) {
    auto listed = std::move(search.front);
    auto listedCount = search.candidates, listedVerified = search.verified;
    auto listedRejected = search.rejectedFold, listedUnsupported = search.unsupportedGeneration;
    search.candidates = search.verified = search.rejectedFold = 0;
    search.dpMismatches = search.unsupportedGeneration = 0;
    search.generate(0);
    stats.referenceCandidates = search.candidates;
    llvm::sort(search.front, [](const auto &a, const auto &b) { return a.cost < b.cost; });
    auto minimum = original.cost, policy = original.cost;
    for (const auto &entry : search.front) {
      minimum = std::min(minimum, entry.cost);
      if (prefer(entry.cost, policy))
        policy = entry.cost;
    }
    if (search.stop.empty() && !search.dpMismatches) {
      referenceMin = minimum;
      referencePolicy = policy;
      auto listMin = stats.listMinimum ? std::min(original.cost, *stats.listMinimum) : original.cost;
      if (listMin[0] != minimum[0] || stats.listPolicy != referencePolicy)
        discrepancy = "grouped list search omitted a bounded DP result";
    }
    search.front = std::move(listed);
    search.candidates = listedCount;
    search.verified = listedVerified;
    search.rejectedFold = listedRejected;
    search.unsupportedGeneration = listedUnsupported;
  }
  search.current = nullptr;
  llvm::sort(search.front, [](const auto &a, const auto &b) { return a.cost < b.cost; });
  json::Array alternatives;
  FrontEntry best = original, selected = original;
  unsigned index = 0;
  for (auto &entry : search.front) {
    std::string file = (label + "-" + Twine(index++) + ".ll").str();
    std::error_code error;
    raw_fd_ostream out(pathIn(directory, file), error);
    if (error)
      return json::Object{{"reason", error.message()}};
    out << entry.ir;
    entry.report["ir"] = file;
    if (entry.cost < best.cost)
      best = entry;
    if (preferred(entry.cost, selected.cost, original.cost, source))
      selected = entry;
    alternatives.push_back(json::Object(entry.report));
  }
  json::Value generated = alternatives.empty() ? json::Value(nullptr) : alternatives.front();
  auto jsonCost = [](const Optional<Cost> &cost) -> json::Value {
    return cost ? json::Value(json::Array{(*cost)[0], (*cost)[1], (*cost)[2]}) : json::Value(nullptr);
  };
  auto ms = std::chrono::duration<double, std::milli>(Clock::now() - generationStart).count();
  if (search.front.empty() && search.stop.empty())
    search.stop = "no valid generated schedule";
  return json::Object{{"pairing", describe(search.shape, pairs)}, {"generated_minimum", std::move(generated)},
      {"generation_ms", ms}, {"speculation_groups", stats.groups}, {"fold_adjustments", stats.foldAdjustments},
      {"list_minimum", jsonCost(stats.listMinimum)}, {"list_policy", jsonCost(stats.listPolicy)},
      {"dp_minimum", jsonCost(referenceMin)}, {"dp_policy", jsonCost(referencePolicy)},
      {"discrepancy", discrepancy}, {"reference_candidates", stats.referenceCandidates}, {"minimum", std::move(best.report)},
      {"selected", std::move(selected.report)}, {"pareto_front", std::move(alternatives)},
      {"generation_complete", search.stop.empty() && search.dpMismatches == 0},
      {"reason", search.stop}, {"candidates", static_cast<int64_t>(search.candidates)},
      {"verified_candidates", static_cast<int64_t>(search.verified)},
      {"dp_mismatches", search.dpMismatches}, {"unsupported_generation", search.unsupportedGeneration},
      {"rejected_fold", search.rejectedFold}};
}

FrontEntry originalEntry(const Module &module, dataflow::CostReport &cost) {
  std::string ir;
  raw_string_ostream stream(ir);
  module.print(stream, nullptr);
  auto report = cost.json();
  report.erase("operations");
  report["original"] = true;
  report["ir"] = "original.ll";
  return {cost.total, std::move(ir), std::move(report)};
}

Cost vector(const json::Object &entry) {
  const auto &a = *entry.getArray("T");
  return {*a[0].getAsInteger(), *a[1].getAsInteger(), *a[2].getAsInteger()};
}

json::Object solve(StringRef input, StringRef directory, Search &search, const Options &opts) {
  if (!readDiamond(search.func, search.shape))
    return json::Object{{"complete", false}, {"reason", "unsupported source CFG"}};
  auto pairingStart = Clock::now();
  auto pairing = dataflow::pairing::choose(search.func, search.shape, search.costs,
                                          !opts.pairingOnly && opts.source != "thread-pattern",
                                          search.throughput);
  auto ms = std::chrono::duration<double, std::milli>(Clock::now() - pairingStart).count();
  if (!pairing)
    return json::Object{{"complete", false}, {"reason", toString(pairing.takeError())},
                        {"pairing_ms", ms}};
  json::Array components;
  for (const auto &component : pairing->components)
    components.push_back(json::Object{{"size", component.candidates},
          {"method", component.exact ? "exact" : "greedy"}, {"gain", component.gain}});
  json::Object result{{"pairing", json::Object{{"candidates", pairing->candidates},
      {"component_count", static_cast<int64_t>(pairing->components.size())}, {"components", std::move(components)},
      {"selected", describe(search.shape, pairing->selected)}, {"gain", pairing->gain}, {"ms", ms}}}};
  if (opts.pairingOnly) {
    result["complete"] = true;
    return result;
  }

  auto baseline = dataflow::evaluate(search.func, search.costs, true, search.quotes,
                                     true, false, search.throughput);
  if (!baseline) {
    result["complete"] = false;
    result["reason"] = toString(baseline.takeError());
    return result;
  }
  const auto &originalT = baseline->total;
  result["original_T"] = json::Array{originalT[0], originalT[1], originalT[2]};
  search.splitCost = *search.costs.getInteger("guard_segment_control");
  if (search.throughput) {
    auto quotes = search.throughput(search.func);
    if (!quotes) {
      result["complete"] = false;
      result["reason"] = toString(quotes.takeError());
      return result;
    }
    Optional<int64_t> arm;
    for (const auto &block : search.func)
      if (const auto *branch = dyn_cast<BranchInst>(block.getTerminator())) {
        auto cost = quotes->lookup(branch);
        if (branch->isConditional())
          search.splitCost = cost;
        else if (!arm || *arm == cost)
          arm = cost;
        else {
          result["complete"] = false;
          result["reason"] = "different arm branch quotes are unsupported";
          return result;
        }
      }
    search.armCost = arm.getValueOr(0);
  }
  const auto original = originalEntry(search.module, *baseline);
  {
    std::error_code error;
    raw_fd_ostream out(pathIn(directory, "original.ll"), error);
    if (error) {
      result["complete"] = false;
      result["reason"] = error.message();
      return result;
    }
    out << original.ir;
  }
  auto anchor = collect("anchor", input, directory, search.func, search, originalT, opts);
  auto darm = collect("darm", input, directory, search.func, search, originalT, opts);
  auto fresh = generate(search, pairing->selected, original, directory, "dataflow", opts.source, opts.compareDP);
  auto generateComparator = [&](const Comparator &other, StringRef label) {
    if (!other.plan)
      return json::Object{{"reason", other.report.getString("reason").getValueOr("pairing unavailable").str()}};
    if (samePlan(pairing->selected, *other.plan))
      return json::Object(fresh);
    return generate(search, *other.plan, original, directory, label, opts.source, opts.compareDP);
  };
  auto unifiedAnchor = generateComparator(anchor, "anchor");
  auto unifiedDarm = anchor.plan && darm.plan && samePlan(*anchor.plan, *darm.plan)
      ? json::Object(unifiedAnchor) : generateComparator(darm, "darm");
  json::Array subsetReports;
  for (auto indexed : llvm::enumerate(pairing->subsets)) {
    auto subset = generate(search, indexed.value(), original, directory,
                           "subset-" + std::to_string(indexed.index()), opts.source, opts.compareDP);
    subsetReports.push_back(std::move(subset));
  }
  json::Object withoutNetMinimum(*fresh.getObject("minimum"));
  json::Object withoutNetSelected(*fresh.getObject("selected"));
  json::Array newFront(*fresh.getArray("pareto_front"));
  for (const auto &item : subsetReports) {
    const auto &subset = *item.getAsObject();
    if (auto *entry = subset.getObject("minimum"))
      if (vector(*entry) < vector(withoutNetMinimum))
        withoutNetMinimum = json::Object(*entry);
    if (auto *entry = subset.getObject("selected"))
      if (preferred(vector(*entry), vector(withoutNetSelected), originalT, opts.source))
        withoutNetSelected = json::Object(*entry);
    if (auto *entries = subset.getArray("pareto_front"))
      for (const auto &entry : *entries)
        newFront.push_back(entry);
  }
  result["without_safety_net"] = json::Object{{"minimum", std::move(withoutNetMinimum)},
                                             {"selected", std::move(withoutNetSelected)}};
  auto newScheme = json::Object{{"minimum", json::Object(*result.getObject("without_safety_net")->getObject("minimum"))},
                                {"pareto_front", std::move(newFront)}};
  json::Object minimum(original.report), selected(original.report);
  StringRef winner = "original", minWinner = "original";
  std::vector<json::Object> front{json::Object(original.report)};
  for (const auto &[label, scheme] :
       SmallVector<std::pair<StringRef, const json::Object *>, 3>{
           {"dataflow", &newScheme}, {"anchor", &unifiedAnchor}, {"darm", &unifiedDarm}}) {
    if (auto *entry = scheme->getObject("minimum"))
      if (vector(*entry) < vector(minimum)) {
        minimum = json::Object(*entry);
        minWinner = label;
      }
    if (auto *choices = scheme->getArray("pareto_front"))
      for (const auto &entry : *choices) {
        const auto &candidate = *entry.getAsObject();
        const auto cost = vector(candidate);
        if (llvm::any_of(front, [&](const auto &old) {
              return vector(old) == cost || dominates(vector(old), cost);
            }))
          continue;
        auto end = std::remove_if(front.begin(), front.end(), [&](const auto &old) {
          return dominates(cost, vector(old));
        });
        front.erase(end, front.end());
        front.push_back(json::Object(candidate));
      }
  }
  llvm::sort(front, [](const auto &a, const auto &b) { return vector(a) < vector(b); });
  for (const auto &candidate : front)
    if (preferred(vector(candidate), vector(selected), originalT, opts.source))
      selected = json::Object(candidate);
  // Report which of the three pair sets produced the selected vector. In a
  // tie use the documented order (dataflow, anchor, DARM); original stays first.
  if (!selected.getBoolean("original").getValueOr(false))
    for (const auto &[label, scheme] :
         SmallVector<std::pair<StringRef, const json::Object *>, 3>{
             {"dataflow", &newScheme}, {"anchor", &unifiedAnchor}, {"darm", &unifiedDarm}}) {
      auto *choices = scheme->getArray("pareto_front");
      if (choices && llvm::any_of(*choices, [&](const auto &entry) {
            return vector(*entry.getAsObject()) == vector(selected);
          })) {
        winner = label;
        break;
      }
    }
  json::Array combined;
  for (auto &entry : front)
    combined.push_back(std::move(entry));
  result["complete"] = fresh.getBoolean("generation_complete").getValueOr(false) ||
                       !selected.getBoolean("original").getValueOr(false);
  if (!*result.getBoolean("complete"))
    result["reason"] = fresh.getString("reason").getValueOr("generation unavailable").str();
  result["candidates"] = fresh.getInteger("candidates").getValueOr(0) +
                         unifiedAnchor.getInteger("candidates").getValueOr(0) +
                         unifiedDarm.getInteger("candidates").getValueOr(0);
  result["minimum"] = std::move(minimum);
  result["minimum_winner"] = minWinner;
  result["selected"] = std::move(selected);
  result["winner"] = winner;
  result["pareto_front"] = std::move(combined);
  result["schemes"] = json::Object{{"dataflow", std::move(fresh)},
      {"anchor", std::move(unifiedAnchor)}, {"darm", std::move(unifiedDarm)}};
  result["subsets"] = std::move(subsetReports);
  result["original_generators"] = json::Object{{"anchor", std::move(anchor.report)},
      {"darm", std::move(darm.report)}};
  return result;
}
} // namespace

int main(int argc, char **argv) {
  if (argc < 4) {
    errs() << "usage: dataflow_solver INPUT.ll COST_TABLE.json OUTPUT_DIRECTORY"
              " [--cost=abstract|real] [--c-sl=abstract|real]"
              " [--condition-source=data|thread-pattern|workgroup-uniform]"
              " [--pairing-only] [--compare-dp] [--tti-worker=PATH] [--fusion-search=PATH]\n";
    return 2;
  }
  Options opts;
  SmallString<256> bin(argv[0]);
  if (auto error = sys::fs::make_absolute(bin)) {
    errs() << error.message() << '\n';
    return 2;
  }
  opts.fusion = pathIn(sys::path::parent_path(bin), "fusion-search-llvm24");
  for (int i = 4; i < argc; ++i) {
    StringRef arg(argv[i]);
    if (arg == "--cost=real")
      opts.real = true;
    else if (arg == "--cost=abstract")
      opts.real = false;
    else if (arg == "--c-sl=abstract")
      opts.realSL = false;
    else if (arg == "--c-sl=real")
      opts.realSL = true;
    else if (arg == "--pairing-only")
      opts.pairingOnly = true;
    else if (arg == "--compare-dp")
      opts.compareDP = true;
    else if (arg.consume_front("--condition-source=") &&
             (arg == "data" || arg == "thread-pattern" || arg == "workgroup-uniform"))
      opts.source = arg;
    else if (arg.consume_front("--tti-worker="))
      opts.worker = arg;
    else if (arg.consume_front("--fusion-search="))
      opts.fusion = arg.str();
    else {
      errs() << "unknown option: " << argv[i] << '\n';
      return 2;
    }
  }
  LLVMContext context;
  SMDiagnostic diagnostic;
  auto module = parseIRFile(argv[1], diagnostic, context);
  if (!module) {
    diagnostic.print(argv[0], errs());
    return 1;
  }
  if (verifyModule(*module, &errs()))
    return 1;
  Function *function = nullptr;
  for (auto &fn : *module)
    if (!fn.isDeclaration()) {
      if (function || !fn.hasName()) {
        errs() << "expected a single named function definition\n";
        return 1;
      }
      function = &fn;
    }
  if (!function || function->arg_empty())
    return 1;
  auto costs = dataflow::readCosts(argv[2]);
  if (!costs) {
    errs() << toString(costs.takeError()) << '\n';
    return 1;
  }
  if (auto error = sys::fs::create_directories(argv[3])) {
    errs() << error.message() << '\n';
    return 1;
  }
  Search search(*module, *function, *costs->getAsObject());
  search.outputDirectory = argv[3];
  dataflow::SizeLatency oracle(*module);
  if (!opts.pairingOnly) {
    search.oracleQuotes = &oracle;
    if (opts.realSL || opts.real)
      search.quotes = &oracle;
  }
  dataflow::RealCost throughput(opts.worker);
  auto request = [&](const Function &fn) { return throughput.quote(fn); };
  if (opts.real)
    search.throughput = request;
  auto report = solve(argv[1], argv[3], search, opts);
  report["seconds"] = std::chrono::duration<double>(Clock::now() - search.start).count();
  outs() << json::Value(std::move(report)) << '\n';
}
