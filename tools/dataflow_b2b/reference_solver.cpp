#include "reference_generation.h"

int main(int argc, char **argv) {
  if (argc < 4) {
    errs() << "usage: reference_solver INPUT.ll COST_TABLE.json OUTPUT_DIRECTORY"
              " [--c-sl=real|abstract] [--cost=abstract|real] [--tti-worker=PATH]\n";
    return 2;
  }
  bool real = false, useThroughput = false;
  StringRef worker = "tools/run-llvm24-tti";
  for (int i = 4; i < argc; ++i) {
    StringRef option(argv[i]);
    if (option == "--c-sl=real")
      real = true;
    else if (option == "--c-sl=abstract")
      real = false;
    else if (option == "--cost=real")
      useThroughput = true;
    else if (option == "--cost=abstract")
      useThroughput = false;
    else if (option.consume_front("--tti-worker="))
      worker = option;
    else {
      errs() << "unknown option: " << option << '\n';
      return 2;
    }
  }
  if (useThroughput && worker.empty()) {
    errs() << "--cost=real requires --tti-worker=PATH\n";
    return 2;
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
  auto table = dataflow::readCosts(argv[2]);
  if (!table) {
    errs() << toString(table.takeError()) << '\n';
    return 1;
  }
  const auto &costs = *table->getAsObject();
  if (auto error = sys::fs::create_directories(argv[3])) {
    errs() << error.message() << '\n';
    return 1;
  }
  Search search(*module, *function, costs);
  search.outputDirectory = argv[3];
  dataflow::SizeLatency oracleQuotes(*module);
  search.oracleQuotes = &oracleQuotes;
  if (real || useThroughput)
    search.quotes = &oracleQuotes;
  std::unique_ptr<dataflow::RealCost> throughput;
  auto request = [&](const Function &fn) { return throughput->quote(fn); };
  if (useThroughput) {
    throughput = std::make_unique<dataflow::RealCost>(worker);
    search.throughput = request;
  }
  search.splitCost = *costs.getInteger("guard_segment_control");
  auto baseline = dataflow::evaluate(*function, costs, true, search.quotes,
                                     true, false, search.throughput);
  if (baseline && useThroughput) {
    auto quotes = request(*function);
    if (!quotes) {
      errs() << toString(quotes.takeError()) << '\n';
      return 1;
    }
    Optional<int64_t> arm;
    for (const auto &block : *function)
      if (const auto *branch = dyn_cast<BranchInst>(block.getTerminator())) {
        auto cost = quotes->lookup(branch);
        if (branch->isConditional())
          search.splitCost = cost;
        else if (!arm || *arm == cost)
          arm = cost;
        else {
          errs() << "different arm branch quotes are unsupported\n";
          return 1;
        }
      }
    search.armCost = arm.getValueOr(0);
  }
  std::string limitation = "a generation alternative could not be verified";
  if (baseline) {
    search.add(*module, true);
    if (readDiamond(*function, search.shape)) {
      if (search.shape.ops[0].size() + search.shape.ops[1].size() <= 16)
        search.search();
      else
        limitation = "input exceeds the subset DP operation limit";
    } else {
      limitation = "unsupported source CFG for candidate generation";
    }
  } else {
    search.stop = toString(baseline.takeError());
  }
  if (!search.stop.empty())
    limitation = search.stop;

  llvm::sort(search.front, [](const auto &a, const auto &b) { return a.cost < b.cost; });
  json::Array front;
  json::Value conservative = nullptr;
  for (unsigned i = 0; i < search.front.size(); ++i) {
    auto &entry = search.front[i];
    std::string file = std::to_string(i) + ".ll";
    SmallString<256> path(argv[3]);
    sys::path::append(path, file);
    std::error_code error;
    raw_fd_ostream out(path, error);
    if (error) {
      errs() << error.message() << '\n';
      return 1;
    }
    out << entry.ir;
    entry.report["ir"] = file;
    if (baseline && conservative.kind() == json::Value::Null &&
        entry.cost[0] < baseline->total[0] && entry.cost[1] <= baseline->total[1] &&
        entry.cost[2] <= baseline->total[2])
      conservative = i;
    front.push_back(std::move(entry.report));
  }
  auto seconds = std::chrono::duration<double>(Clock::now() - search.start).count();
  const auto base = baseline ? json::Value(json::Array{
      baseline->total[0], baseline->total[1], baseline->total[2]}) : json::Value(nullptr);
  json::Array topK;
  if (baseline && search.stop.empty()) {
    for (unsigned k : {1u, 3u, 10u}) {
      auto best = baseline->total[0];
      for (auto &plan : ArrayRef<Pairing>(search.pairings).take_front(k))
        if (plan.bestD)
          best = std::min(best, *plan.bestD);
      topK.push_back(json::Object{{"k", k}, {"best_observed_D", best}});
    }
  }
  outs() << json::Value(json::Object{{"complete", search.completed}, {"top_k", std::move(topK)},
      {"oracle_candidates", search.oracleCandidates}, {"oracle_guards", search.oracleGuards},
      {"pairings", static_cast<int64_t>(search.pairings.size())}, {"cyclic_pairings", search.cyclic}, {"reason", search.completed ? "" : limitation}, {"dp_mismatches", search.dpMismatches},
      {"unsupported_generation", search.unsupportedGeneration}, {"rejected_fold", search.rejectedFold},
      {"original_T", base}, {"candidates", static_cast<int64_t>(search.candidates)},
      {"verified_candidates", static_cast<int64_t>(search.verified)}, {"seconds", seconds},
      {"pareto_front", std::move(front)}, {"conservative_index", std::move(conservative)}}) << '\n';
}
