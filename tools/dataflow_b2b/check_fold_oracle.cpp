#include "fold_oracle.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"

using namespace llvm;

int main(int argc, char **argv) {
  if (argc != 3) {
    errs() << "usage: check_fold_oracle INPUT.ll COST_TABLE.json\n";
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
  dataflow::SizeLatency quotes(*module);
  json::Array rows;
  bool mismatch = false;
  for (auto &fn : *module)
    if (!fn.isDeclaration())
      mismatch |= !dataflow::oracle::check(fn, *table->getAsObject(), quotes, rows);
  if (verifyModule(*module, &errs()))
    return 2;
  outs() << json::Value(json::Object{{"status", mismatch ? "mismatch" : "ok"},
                                    {"guards", std::move(rows)}}) << '\n';
  return mismatch ? 1 : 0;
}
