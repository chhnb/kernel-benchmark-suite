#pragma once

#include "fold_llvm.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/Analysis/InstructionSimplify.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/IR/CFG.h"
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

struct GuardShape {
  const llvm::BasicBlock *left, *right, *join;
};

inline llvm::Optional<GuardShape> findGuard(const llvm::BranchInst &branch) {
  using namespace llvm;
  if (!branch.isConditional())
    return None;
  auto *split = branch.getParent();
  auto *left = branch.getSuccessor(0), *right = branch.getSuccessor(1);
  auto exitOf = [&](const BasicBlock *arm) -> const BasicBlock * {
    if (arm == split || arm->getSinglePredecessor() != split)
      return nullptr;
    auto *end = dyn_cast<BranchInst>(arm->getTerminator());
    return end && end->isUnconditional() ? end->getSuccessor(0) : nullptr;
  };
  auto *l = exitOf(left), *r = exitOf(right);
  const BasicBlock *join = l && (l == r || l == right) ? l : r == left ? r : nullptr;
  if (!join || join == split || left == right)
    return None;
  return GuardShape{left == join ? nullptr : left, right == join ? nullptr : right, join};
}

inline std::string foldFailure(llvm::ArrayRef<const llvm::Instruction *> operations,
                               llvm::ArrayRef<const llvm::PHINode *> phis,
                               const llvm::BasicBlock &join, const llvm::Value &condition,
                               const llvm::json::Object &table, const SizeLatency *real = nullptr) {
  using namespace llvm;
  using namespace llvm::PatternMatch;
  if (pred_size(&join) != 2)
    return "join does not have exactly two predecessors";
  if (phis.empty() || operations.empty())
    return "no PHI or no operations to speculate";
  if (phis.size() > static_cast<uint64_t>(*table.getInteger("fold_max_phis")))
    return "too many join PHIs";
  SmallPtrSet<const Instruction *, 16> work(operations.begin(), operations.end());
  SmallPtrSet<const Instruction *, 16> needed;
  SmallVector<const Value *, 16> pending;
  const PHINode *first = nullptr;
  for (auto *phi : phis) {
    if (SimplifyInstruction(const_cast<PHINode *>(phi), {join.getModule()->getDataLayout(), phi}))
      continue;
    if (!first)
      first = phi;
    pending.append(phi->incoming_values().begin(), phi->incoming_values().end());
  }
  while (!pending.empty()) {
    auto *inst = dyn_cast<Instruction>(pending.pop_back_val());
    if (!inst || !work.count(inst) || !needed.insert(inst).second)
      continue;
    for (const auto &operand : inst->operands())
      pending.push_back(operand.get());
  }
  if (needed.size() != work.size())
    return "guard operation is not a source of a remaining PHI";
  if (first && first->getType()->isIntegerTy(1)) {
    const Value *l = first->getIncomingValue(0), *r = first->getIncomingValue(1);
    auto isNot = [](const Value *v) { return match(v, m_Not(m_Value())); };
    auto invertible = [&](const Value *v) { return isNot(v) || isa<ConstantInt>(v); };
    if ((isa<BinaryOperator>(l) || isa<BinaryOperator>(r) || isa<BinaryOperator>(condition)) &&
        !(isNot(l) && invertible(r)) && !(isNot(r) && invertible(l)))
      return "binary condition or input to first remaining i1 PHI";
  }
  int64_t charge = 0;
  for (const auto *inst : operations) {
    if (!isSafeToSpeculativelyExecute(inst))
      return std::string("LLVM12 unsafe to speculate: ") + inst->getOpcodeName();
    auto cost = real ? Optional<int64_t>(real->quote(*inst)) : costOf(*inst, table);
    if (!cost || *cost < 0)
      return std::string("missing c_SL for opcode: ") + inst->getOpcodeName();
    charge += *cost;
  }
  if (operations.size() > 1 && charge > *table.getInteger("fold_threshold"))
    return "size-and-latency cost exceeds threshold";
  return "";
}
} // namespace dataflow
