#include "evaluate_cost.h"
#include "real_cost.h"

#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"

using namespace llvm;

int main(int argc, char **argv) {
  if (argc < 3) {
    errs() << "usage: evaluate_cost INPUT.ll COST_TABLE.json [--original] [--output-buffer] [--after-cleanup] [--c-sl=real|abstract] [--cost=real] [--tti-worker=PATH]\n";
    return 2;
  }
  bool original = false, real = false, outputBuffer = false, afterCleanup = false;
  bool useThroughput = false;
  StringRef worker = "tools/run-llvm24-tti";
  for (int index = 3; index < argc; ++index) {
    StringRef option(argv[index]);
    if (option == "--original")
      original = true;
    else if (option == "--output-buffer")
      outputBuffer = true;
    else if (option == "--after-cleanup")
      afterCleanup = true;
    else if (option == "--cost=real")
      useThroughput = true;
    else if (option.consume_front("--tti-worker="))
      worker = option;
    else if (option == "--c-sl=real")
      real = true;
    else if (option == "--c-sl=abstract")
      real = false;
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
  const Function *function = nullptr;
  for (const auto &candidate : *module) {
    if (candidate.isDeclaration())
      continue;
    if (function) {
      errs() << "expected a single defined function\n";
      return 1;
    }
    function = &candidate;
  }
  if (!function) {
    errs() << "expected a single defined function\n";
    return 1;
  }
  auto table = dataflow::readCosts(argv[2]);
  if (!table) {
    errs() << toString(table.takeError()) << '\n';
    return 1;
  }
  std::unique_ptr<dataflow::SizeLatency> quotes;
  if (real || useThroughput)
    quotes = std::make_unique<dataflow::SizeLatency>(*module);
  std::unique_ptr<dataflow::RealCost> throughput;
  if (useThroughput)
    throughput = std::make_unique<dataflow::RealCost>(worker);
  auto request = [&](const Function &fn) { return throughput->quote(fn); };
  auto result = dataflow::evaluate(*function, *table->getAsObject(), original,
                                   quotes.get(), !afterCleanup, outputBuffer,
                                   useThroughput ? dataflow::QuoteProvider(request) : nullptr);
  if (!result) {
    outs() << json::Value(json::Object{{"status", "unsupported"},
                  {"reason", toString(result.takeError())}}) << '\n';
    return 3;
  }
  auto report = result->json();
  report["status"] = "ok";
  outs() << json::Value(std::move(report)) << '\n';
}
