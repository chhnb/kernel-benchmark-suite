#include "cleanup_llvm.h"
#include "evaluate_cost.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"

using namespace llvm;

int main(int argc, char **argv) {
  if (argc < 4 || argc > 5 || (argc == 5 && StringRef(argv[4]) != "--original")) {
    errs() << "usage: compare_cleanup_cost INPUT.ll COST_TABLE.json CLEANED.ll [--original]\n";
    return 2;
  }
  LLVMContext context;
  SMDiagnostic diagnostic;
  auto module = parseIRFile(argv[1], diagnostic, context);
  if (!module) {
    diagnostic.print(argv[0], errs());
    return 2;
  }
  if (verifyModule(*module, &errs()))
    return 2;
  auto table = dataflow::readCosts(argv[2]);
  if (!table) {
    errs() << toString(table.takeError()) << '\n';
    return 2;
  }
  Function *function = nullptr;
  for (auto &candidate : *module)
    if (!candidate.isDeclaration()) {
      if (function)
        return 2;
      function = &candidate;
    }
  if (!function)
    return 2;
  bool buffer = false;
  for (const auto &block : *function)
    if (auto *ret = dyn_cast<ReturnInst>(block.getTerminator()))
      buffer |= !dataflow::outputWrites(*ret, *function).empty();

  dataflow::SizeLatency quotes(*module);
  const auto &costs = *table->getAsObject();
  auto before = dataflow::evaluate(*function, costs, argc == 5, &quotes);
  std::string beforeIR;
  raw_string_ostream stream(beforeIR);
  function->print(stream);
  dataflow::runCleanup(*function, quotes);
  std::string afterIR;
  raw_string_ostream afterStream(afterIR);
  function->print(afterStream);
  if (verifyModule(*module, &errs())) {
    if (!before)
      consumeError(before.takeError());
    return 2;
  }
  auto after = dataflow::evaluate(*function, costs, false, &quotes, true, buffer);
  std::error_code ec;
  raw_fd_ostream out(argv[3], ec);
  if (ec) {
    errs() << ec.message() << '\n';
    if (!before)
      consumeError(before.takeError());
    if (!after)
      consumeError(after.takeError());
    return 2;
  }
  module->print(out, nullptr);
  json::Object report{{"text_changed", beforeIR != afterIR}, {"output_buffer", buffer}};
  if (before && after) {
    const auto &a = before->total;
    const auto &b = after->total;
    report["status"] = a == b ? "same_cost" : "cost_changed";
    report["before"] = json::Array{a[0], a[1], a[2]};
    report["after"] = json::Array{b[0], b[1], b[2]};
  } else {
    report["status"] = "unsupported";
    if (!before)
      report["before_error"] = toString(before.takeError());
    if (!after)
      report["after_error"] = toString(after.takeError());
  }
  outs() << json::Value(std::move(report)) << '\n';
}
