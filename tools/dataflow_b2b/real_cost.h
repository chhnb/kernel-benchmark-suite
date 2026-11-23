#pragma once

#include "../tti_cost_kind.h"
#include "../tti_memory_io.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/JSON.h"
#include <cstdlib>
#include <memory>

namespace dataflow {
using InstructionCosts = llvm::DenseMap<const llvm::Instruction *, int64_t>;

class RealCost {
  std::string worker;
#ifdef __linux__
  std::unique_ptr<decision::PersistentTTI> session;
  std::string functionName;
#endif

public:
  explicit RealCost(llvm::StringRef executable) : worker(executable.str()) {}

  llvm::Expected<InstructionCosts> quote(const llvm::Function &fn) {
    using namespace llvm;
    auto invalid = [](const Twine &reason) {
      return createStringError(inconvertibleErrorCode(), reason);
    };
#ifdef __linux__
    if (!std::getenv("KBS_TTI_TABLE") &&
        fn.getFnAttribute("target-cpu").getValueAsString().empty())
      return invalid("LLVM24 real pricing requires target-cpu");
    std::string ir;
    raw_string_ostream stream(ir);
    fn.getParent()->print(stream, nullptr);
    stream.flush();
    std::string result;
    try {
      if (std::getenv("KBS_TTI_TABLE"))
        result = decision::runMemoryTTI(worker, ir, fn.getName(), false, 60);
      else {
        if (!session || functionName != fn.getName()) {
          session = std::make_unique<decision::PersistentTTI>(worker, fn.getName(), false);
          functionName = fn.getName().str();
        }
        result = session->score(ir);
      }
    } catch (const std::exception &error) {
      return invalid(error.what());
    }
    auto parsed = json::parse(result);
    if (!parsed)
      return parsed.takeError();
    const auto *report = parsed->getAsObject();
    if (!report)
      return invalid("invalid LLVM24 worker report");
    if (!std::getenv("KBS_TTI_TABLE") &&
        (report->getString("schema") != Optional<StringRef>("llvm24-tti-v1") ||
         report->getString("source_revision") != Optional<StringRef>("6be16f356d3e") ||
         report->getString("cost_kind") != Optional<StringRef>(fusion::ttiCostKindName()) ||
         report->getString("triple") != Optional<StringRef>(fn.getParent()->getTargetTriple()) ||
         report->getString("cpu") != Optional<StringRef>(fn.getFnAttribute("target-cpu").getValueAsString()) ||
         report->getString("features") != Optional<StringRef>(fn.getFnAttribute("target-features").getValueAsString())))
      return invalid("LLVM24 worker identity or target mismatch");
    const auto *rows = report->getArray("instruction_costs");
    if (!rows)
      return invalid("missing LLVM24 instruction quotes");
    SmallPtrSet<const BasicBlock *, 16> reachable;
    SmallVector<const BasicBlock *, 16> pending{&fn.getEntryBlock()};
    while (!pending.empty()) {
      const auto *block = pending.pop_back_val();
      if (reachable.insert(block).second)
        for (const auto *successor : successors(block))
          pending.push_back(successor);
    }
    InstructionCosts costs;
    size_t position = 0;
    int64_t blockIndex = 0;
    for (const auto &block : fn) {
      int64_t index = 0;
      if (reachable.count(&block))
        for (const auto &inst : block) {
          if (isa<DbgInfoIntrinsic>(inst))
            continue;
          const auto *row = position < rows->size() ? (*rows)[position++].getAsObject() : nullptr;
          if (!row || row->getInteger("block_index") != blockIndex ||
              row->getInteger("instruction_index") != index++)
            return invalid("LLVM24 instruction quote order mismatch");
          if (auto cost = row->getInteger("accepted_cost"))
            costs.insert({&inst, *cost});
        }
      ++blockIndex;
    }
    if (position != rows->size())
      return invalid("extra LLVM24 instruction quotes");
    return costs;
#else
    return invalid("LLVM24 worker transport requires Linux");
#endif
  }
};
} // namespace dataflow
