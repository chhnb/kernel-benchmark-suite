#pragma once

#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Function.h"

namespace dataflow {
inline llvm::SmallPtrSet<const llvm::Instruction *, 16>
outputWrites(const llvm::ReturnInst &ret, const llvm::Function &fn, bool known = false) {
  using namespace llvm;
  SmallPtrSet<const Instruction *, 16> result;
  if (ret.getReturnValue() || !fn.arg_size())
    return result;
  const auto *output = fn.getArg(fn.arg_size() - 1);
  const auto *ptr = dyn_cast<PointerType>(output->getType());
  if (!ptr || (!output->getName().equals("out") && !ptr->getElementType()->isAggregateType()))
    return result;
  // Cleanup can fold slot zero, change pointee types or combine writes.
  // Only follow the output buffer this way when the original ABI was verified.
  if (known) {
    SmallVector<const Value *, 16> pending{output};
    while (!pending.empty()) {
      const auto *address = pending.pop_back_val();
      for (auto *user : address->users()) {
        if (const auto *store = dyn_cast<StoreInst>(user)) {
          if (!store->isSimple() || store->getPointerOperand() != address ||
              store->getValueOperand() == address)
            return {};
          result.insert(store);
        } else if (const auto *cast = dyn_cast<BitCastInst>(user)) {
          if (result.insert(cast).second)
            pending.push_back(cast);
        } else if (const auto *gep = dyn_cast<GetElementPtrInst>(user)) {
          if (gep->getPointerOperand() != address)
            return {};
          if (result.insert(gep).second)
            pending.push_back(gep);
        } else {
          return {};
        }
      }
    }
    return result;
  }
  // The extracted ABI writes numbered slots at the end of its exit block.
  SmallVector<unsigned, 8> indices;
  auto inst = ret.getPrevNode();
  while (const auto *store = dyn_cast_or_null<StoreInst>(inst)) {
    if (!store->isSimple())
      break;
    const auto *gep = dyn_cast<GetElementPtrInst>(store->getPointerOperand());
    if (!gep || gep->getPointerOperand() != output || !gep->hasOneUse())
      break;
    const auto *index = dyn_cast<ConstantInt>(gep->getOperand(gep->getNumOperands() - 1));
    if (!index || index->getValue().getActiveBits() > 16 ||
        gep->getNumIndices() != (ptr->getElementType()->isAggregateType() ? 2u : 1u))
      break;
    if (gep->getNumIndices() == 2) {
      const auto *zero = dyn_cast<ConstantInt>(gep->getOperand(1));
      if (!zero || !zero->isZero())
        break;
    }
    indices.push_back(index->getZExtValue());
    result.insert(store);
    result.insert(gep);
    inst = store->getPrevNode();
    if (inst == gep)
      inst = inst->getPrevNode();
  }
  if (indices.size() < 2 || output->getNumUses() != indices.size())
    result.clear();
  for (unsigned i = 0; i < indices.size(); ++i)
    if (indices[i] != indices.size() - 1 - i)
      result.clear();
  return result;
}

} // namespace dataflow
