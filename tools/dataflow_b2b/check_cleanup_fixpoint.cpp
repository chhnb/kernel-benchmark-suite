#include "cleanup_llvm.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"

using namespace llvm;

int main(int argc, char **argv) {
  if (argc != 2) {
    errs() << "usage: check_cleanup_fixpoint INPUT.ll\n";
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
  dataflow::SizeLatency quotes(*module);
  bool changed = false;
  for (auto &fn : *module) {
    if (fn.isDeclaration())
      continue;
    std::string before, after;
    raw_string_ostream beforeStream(before), afterStream(after);
    fn.print(beforeStream);
    dataflow::runCleanup(fn, quotes);
    fn.print(afterStream);
    if (before != after) {
      changed = true;
      outs() << "Changed function " << fn.getName() << "\n--- before\n"
             << before << "\n+++ after\n" << after << '\n';
    }
  }
  if (verifyModule(*module, &errs()))
    return 2;
  if (!changed)
    outs() << "unchanged\n";
  return changed ? 1 : 0;
}
