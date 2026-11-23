#pragma once

#include "llvm/Analysis/ValueTracking.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/MemoryBuffer.h"

namespace dataflow {
inline llvm::Expected<llvm::json::Value> readCosts(llvm::StringRef path) {
  auto file = llvm::MemoryBuffer::getFile(path);
  if (!file)
    return llvm::errorCodeToError(file.getError());
  auto result = llvm::json::parse(file.get()->getBuffer());
  if (!result)
    return result.takeError();
  auto *root = result->getAsObject();
  if (!root || !root->getObject("op") || !root->getObject("intrinsic"))
    return llvm::createStringError(llvm::inconvertibleErrorCode(), "missing cost tables");
  for (auto key : {"fold_threshold", "fold_max_phis", "guard_segment_control",
                   "guard_escape_merge", "select_i1_folded_to_condition"})
    if (!root->getInteger(key) || *root->getInteger(key) < 0)
      return llvm::createStringError(llvm::inconvertibleErrorCode(), "invalid cost field %s", key);
  return result;
}

inline llvm::Optional<int64_t> costOf(const llvm::Instruction &inst,
                                     const llvm::json::Object &table) {
  using namespace llvm;
  if (const auto *call = dyn_cast<CallBase>(&inst)) {
    const auto *callee = call->getCalledFunction();
    if (callee && callee->isIntrinsic())
      return table.getObject("intrinsic")->getInteger(callee->getName());
    return None;
  }
  return table.getObject("op")->getInteger(inst.getOpcodeName());
}

inline std::string speculationFailure(const llvm::Instruction &inst,
                                      const llvm::json::Object &table) {
  using namespace llvm;
  if (const auto *call = dyn_cast<CallBase>(&inst)) {
    const auto *callee = call->getCalledFunction();
    if (!callee || !callee->isIntrinsic())
      return "ordinary or indirect call";
    if (!costOf(inst, table))
      return "unknown intrinsic: " + callee->getName().str();
    if (call->isConvergent())
      return "convergent intrinsic: " + callee->getName().str();
  }
  return isSafeToSpeculativelyExecute(&inst) ? "" :
      std::string("LLVM12 unsafe to speculate: ") + inst.getOpcodeName();
}

inline bool disallowedI1Input(const llvm::Value *value) {
  using namespace llvm;
  using namespace llvm::PatternMatch;
  return value->getType()->isIntegerTy(1) && isa<BinaryOperator>(value) &&
         !match(value, m_Not(m_Value()));
}

inline std::string foldFailure(llvm::ArrayRef<const llvm::Instruction *> operations,
                               llvm::ArrayRef<const llvm::Value *> inputs,
                               unsigned phis, const llvm::json::Object &table) {
  int64_t charge = 0;
  for (const auto *inst : operations) {
    if (auto reason = speculationFailure(*inst, table); !reason.empty())
      return reason;
    auto cost = costOf(*inst, table);
    if (!cost)
      return std::string("missing c_SL for opcode: ") + inst->getOpcodeName();
    charge += *cost;
  }
  if (phis > *table.getInteger("fold_max_phis"))
    return "too many join PHIs";
  if (llvm::any_of(inputs, disallowedI1Input))
    return "binary incoming value to i1 PHI";
  if (operations.size() > 1 && charge > *table.getInteger("fold_threshold"))
    return "size-and-latency cost exceeds threshold";
  return "";
}
} // namespace dataflow
