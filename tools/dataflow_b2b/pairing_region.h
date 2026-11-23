#pragma once

#include "llvm/IR/IntrinsicInst.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallVector.h"

namespace dataflow::pairing {
using namespace llvm;
using Insts = SmallVector<const Instruction *, 16>;
using ValuePair = std::pair<const Value *, const Value *>;

struct Diamond {
  const BranchInst *branch = nullptr;
  const BasicBlock *left = nullptr, *right = nullptr, *join = nullptr;
  Insts ops[2];
  DenseMap<const Instruction *, const Instruction *> effectBefore;
};

inline bool readDiamond(const Function &fn, Diamond &out) {
  auto *br = dyn_cast<BranchInst>(fn.getEntryBlock().getTerminator());
  if (!br || !br->isConditional() || br->getCondition() != fn.getArg(0))
    return false;
  auto *left = br->getSuccessor(0), *right = br->getSuccessor(1);
  auto exit = [&](const BasicBlock *block) -> const BasicBlock * {
    auto *end = dyn_cast<BranchInst>(block->getTerminator());
    return end && end->isUnconditional() &&
           block->getSinglePredecessor() == br->getParent() ? end->getSuccessor(0) : nullptr;
  };
  auto *lExit = exit(left), *rExit = exit(right);
  if (left == right)
    return false;
  bool diamond = lExit && lExit == rExit;
  if (diamond)
    out.join = lExit;
  else if (lExit == right)
    out.join = right;
  else if (rExit == left)
    out.join = left;
  else
    return false;

  if (!isa<ReturnInst>(out.join->getTerminator()) || fn.size() != (diamond ? 4 : 3))
    return false;
  out.branch = br;
  out.left = left == out.join ? br->getParent() : left;
  out.right = right == out.join ? br->getParent() : right;
  for (unsigned side : {0u, 1u}) {
    auto *block = side ? out.right : out.left;
    if (block == br->getParent())
      continue;
    const Instruction *lastEffect = nullptr;
    for (const auto &inst : *block) {
      if (isa<PHINode>(inst))
        return false;
      if (!inst.isTerminator() && !isa<DbgInfoIntrinsic>(inst)) {
        out.ops[side].push_back(&inst);
        if (inst.mayReadOrWriteMemory() || inst.mayHaveSideEffects()) {
          if (lastEffect)
            out.effectBefore[&inst] = lastEffect;
          lastEffect = &inst;
        }
      }
    }
  }
  return true;
}

enum class Recipe { R1, R2, R3, R5, R6 };
inline StringRef name(Recipe recipe) {
  switch (recipe) {
  case Recipe::R1: return "R1";
  case Recipe::R2: return "R2";
  case Recipe::R3: return "R3";
  case Recipe::R5: return "R5";
  case Recipe::R6: return "R6";
  }
  llvm_unreachable("invalid recipe");
}

struct Node {
  const Instruction *left;
  const Instruction *right;
  Recipe recipe;
};

inline bool compatible(const Instruction &a, const Instruction &b, Recipe recipe) {
  if (a.getOpcode() != b.getOpcode() || a.getType() != b.getType() ||
      a.getNumOperands() != b.getNumOperands() || isa<AllocaInst>(a) ||
      a.getType()->isTokenTy())
    return false;
  if (const auto *l = dyn_cast<LoadInst>(&a)) {
    const auto &r = cast<LoadInst>(b);
    return recipe == Recipe::R1 && l->isSimple() && r.isSimple() &&
           l->getPointerAddressSpace() == r.getPointerAddressSpace();
  }
  if (const auto *l = dyn_cast<StoreInst>(&a)) {
    const auto &r = cast<StoreInst>(b);
    return recipe == Recipe::R1 && l->isSimple() && r.isSimple() &&
           l->getPointerAddressSpace() == r.getPointerAddressSpace() &&
           l->getValueOperand()->getType() == r.getValueOperand()->getType();
  }
  if (const auto *l = dyn_cast<CallInst>(&a)) {
    const auto &r = cast<CallInst>(b);
    const auto *callee = l->getCalledFunction();
    if (recipe != Recipe::R1 || !callee || !callee->isIntrinsic() ||
        r.getCalledFunction() != callee || l->isConvergent() || r.isConvergent() ||
        l->hasOperandBundles() || r.hasOperandBundles() ||
        l->isMustTailCall() || r.isMustTailCall() || l->getAttributes() != r.getAttributes() ||
        l->getCallingConv() != r.getCallingConv())
      return false;
    for (unsigned i = 0; i < l->arg_size(); ++i)
      if ((l->paramHasAttr(i, Attribute::ImmArg) || r.paramHasAttr(i, Attribute::ImmArg)) &&
          l->getArgOperand(i) != r.getArgOperand(i))
        return false;
    return true;
  }
  if (isa<CallBase>(a))
    return false;
  if (recipe == Recipe::R1)
    return a.isSameOperationAs(&b);
  if (recipe == Recipe::R2)
    return a.isCommutative() && a.getNumOperands() == 2 && a.isSameOperationAs(&b);
  auto *l = dyn_cast<CmpInst>(&a), *r = dyn_cast<CmpInst>(&b);
  if (!l || !r || l->getOpcode() != r->getOpcode() ||
      l->getPredicate() == r->getPredicate() ||
      l->getPredicate() != CmpInst::getSwappedPredicate(r->getPredicate()))
    return false;
  auto *swapped = r->clone();
  cast<CmpInst>(swapped)->swapOperands();
  bool equal = l->isSameOperationAs(swapped);
  swapped->deleteValue();
  return equal;
}

} // namespace dataflow::pairing
