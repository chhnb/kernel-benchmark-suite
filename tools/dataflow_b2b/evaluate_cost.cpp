#include "evaluate_cost.h"

#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"

using namespace llvm;

int main(int argc, char **argv) {
  if (argc < 3) {
    errs() << "usage: evaluate_cost INPUT.ll COST_TABLE.json [--original] [--c-sl=real|abstract]\n";
    return 2;
  }
  bool original = false, real = false;
  for (int index = 3; index < argc; ++index) {
    StringRef option(argv[index]);
    if (option == "--original")
      original = true;
    else if (option == "--c-sl=real")
      real = true;
    else if (option == "--c-sl=abstract")
      real = false;
    else {
      errs() << "unknown option: " << option << '\n';
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
  if (real)
    quotes = std::make_unique<dataflow::SizeLatency>(*module);
  auto result = dataflow::evaluate(*function, *table->getAsObject(), original, quotes.get());
  if (!result) {
    outs() << json::Value(json::Object{{"status", "unsupported"},
                  {"reason", toString(result.takeError())}}) << '\n';
    return 3;
  }
  auto report = result->json();
  report["status"] = "ok";
  outs() << json::Value(std::move(report)) << '\n';
}
