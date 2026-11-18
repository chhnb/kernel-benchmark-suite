#include "tti_quote_key.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/ModuleSlotTracker.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/SourceMgr.h"

#include <set>
#include <vector>

using namespace llvm;

int main(int argc, char **argv) {
  if (argc != 2) return 2;
  LLVMContext context;
  SMDiagnostic diagnostic;
  auto module = parseIRFile("-", diagnostic, context);
  if (!module) {
    diagnostic.print("offline-tti-layout", errs());
    return 2;
  }
  const auto *function = module->getFunction(argv[1]);
  if (!function || function->isDeclaration() || verifyModule(*module, &errs()))
    return 2;

  const auto cpu = function->getFnAttribute("target-cpu").getValueAsString();
  const auto features = function->getFnAttribute("target-features").getValueAsString();
  if (cpu.empty()) {
    errs() << "offline TTI requires target-cpu\n";
    return 2;
  }
  std::string attributes;
  raw_string_ostream attributeStream(attributes);
  for (unsigned index = 0; index <= function->arg_size(); ++index)
    attributeStream << index << ":" << function->getAttributes().getAsString(index) << ";";
  attributeStream << function->getAttributes().getAsString(AttributeList::FunctionIndex);
  attributeStream.flush();

  std::set<const BasicBlock *> reachable;
  std::vector<const BasicBlock *> pending{&function->getEntryBlock()};
  while (!pending.empty()) {
    auto *block = pending.back();
    pending.pop_back();
    if (!reachable.insert(block).second) continue;
    for (auto *successor : successors(block)) pending.push_back(successor);
  }
  const bool reusable = module->getTargetTriple() == "amdgcn-amd-amdhsa" &&
                        cpu == "gfx906" && !function->hasMetadata();
  ModuleSlotTracker slots(module.get());
  slots.incorporateFunction(*function);
  json::Array rows;
  int64_t blockIndex = 0;
  for (const auto &block : *function) {
    int64_t instructionIndex = 0;
    if (reachable.count(&block)) for (const auto &instruction : block) {
      if (isa<DbgInfoIntrinsic>(instruction)) continue;
      std::string text, reportKey;
      raw_string_ostream ir(text), key(reportKey);
      instruction.print(ir, slots);
      key << instruction.getOpcodeName();
      if (const auto *branch = dyn_cast<BranchInst>(&instruction))
        key << (branch->isConditional() ? ".conditional" : ".unconditional");
      if (const auto *call = dyn_cast<CallBase>(&instruction))
        if (const auto *callee = call->getCalledFunction()) key << ':' << callee->getName();
      key << ':';
      instruction.getType()->print(key);
      ir.flush();
      key.flush();
      auto quote = reusable ? fusion::gcnQuoteKey(instruction) : std::nullopt;
      int64_t addressSpace = -1, alignment = 0;
      if (const auto *load = dyn_cast<LoadInst>(&instruction)) {
        addressSpace = load->getPointerAddressSpace();
        alignment = load->getAlign().value();
      } else if (const auto *store = dyn_cast<StoreInst>(&instruction)) {
        addressSpace = store->getPointerAddressSpace();
        alignment = store->getAlign().value();
      }
      rows.emplace_back(json::Object{
          {"block_index", blockIndex}, {"instruction_index", instructionIndex++},
          {"key", reportKey}, {"ir", text}, {"address_space", addressSpace},
          {"alignment", alignment}, {"quote", quote ? json::Value(*quote) : json::Value(nullptr)}});
    }
    ++blockIndex;
  }
  outs() << json::Value(json::Object{{"triple", module->getTargetTriple()}, {"cpu", cpu},
      {"features", features}, {"layout", module->getDataLayoutStr()},
      {"attributes", attributes}, {"calling_conv", int64_t(function->getCallingConv())},
      {"rows", std::move(rows)}}) << '\n';
}
