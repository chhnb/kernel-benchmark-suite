#pragma once
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/Support/raw_ostream.h"
#include <optional>
#include <string>
namespace fusion {
// Read-set for a deliberately restricted part of pinned LLVM24 GCN TTI.
// This is NOT a key for cleanup or candidate profitability. Unsupported
// instructions force a normal complete worker query. All prices come from the
// worker; this code supplies no guessed/fallback instruction prices.
inline std::optional<std::string> gcnQuoteKey(const llvm::Instruction &i) {
  using namespace llvm;
  std::string key;
  raw_string_ostream out(key);
  auto type = [&](Type *t) { t->print(out); out << ';'; };
  auto integer = [](Type *t) { return t->isIntegerTy() && t->getIntegerBitWidth() <= 64; };
  out << "gcn-throughput-6be16f356d3e-v1:" << i.getOpcodeName() << ';';
  type(i.getType());
  switch (i.getOpcode()) {
  case Instruction::Add: case Instruction::Sub: case Instruction::Mul:
  case Instruction::And: case Instruction::Or: case Instruction::Xor:
  case Instruction::Shl: case Instruction::LShr: case Instruction::AShr:
    // GCNTTIImpl::getArithmeticInstrCost: these scalar integer cases depend
    // on legalized type and subtarget only. Exclude div/rem and floating ops.
    if (!integer(i.getType())) return std::nullopt;
    break;
  case Instruction::ICmp:
    if (!integer(i.getOperand(0)->getType())) return std::nullopt;
    type(i.getOperand(0)->getType());
    out << cast<ICmpInst>(i).getPredicate();
    break;
  case Instruction::Select:
    if (!integer(i.getType()) || !i.getOperand(0)->getType()->isIntegerTy(1)) return std::nullopt;
    break;
  case Instruction::PHI:
    if (!integer(i.getType())) return std::nullopt;
    break;
  case Instruction::Br:
    out << cast<BranchInst>(i).isConditional();
    break;
  case Instruction::Ret:
    break;
  case Instruction::Fence:
    out << unsigned(cast<FenceInst>(i).getOrdering()) << ':' << cast<FenceInst>(i).getSyncScopeID();
    break;
  case Instruction::Load: case Instruction::Store: {
    const auto *l = dyn_cast<LoadInst>(&i);
    const auto *s = dyn_cast<StoreInst>(&i);
    if ((l && !l->isSimple()) || (s && !s->isSimple())) return std::nullopt;
    auto *t = l ? l->getType() : s->getValueOperand()->getType();
    if (!integer(t)) return std::nullopt;
    const unsigned as = l ? l->getPointerAddressSpace() : s->getPointerAddressSpace();
    // Scalar AS4 takes BasicTTIImpl's type-legalization path; unlike the
    // vector case it does not inspect instruction context or operand values.
    if (as != 1 && as != 3 && as != 4) return std::nullopt;
    type(t); out << as << ':' << (l ? l->getAlign().value() : s->getAlign().value());
    break;
  }
  case Instruction::Freeze:
    break;
  case Instruction::SExt: case Instruction::ZExt: {
    if (!integer(i.getType()) || !integer(i.getOperand(0)->getType())) return std::nullopt;
    type(i.getOperand(0)->getType());
    // BasicTTIImpl: getCastContextHint and extending-load legalization.
    // GCN does not override TargetLowering::isExtFreeImpl.
    if (auto *load = dyn_cast<LoadInst>(i.getOperand(0))) {
      if (!load->isSimple()) return std::nullopt;
      out << "load:" << load->getAlign().value() << ':' << load->getPointerAddressSpace();
    } else if (isa<CallBase>(i.getOperand(0))) {
      return std::nullopt; // masked/gather intrinsic extension needs more facts
    } else out << "nonload";
    break;
  }
  case Instruction::BitCast:
    if (!i.getType()->isPointerTy() || !i.getOperand(0)->getType()->isPointerTy()) return std::nullopt;
    type(i.getOperand(0)->getType());
    break;
  case Instruction::GetElementPtr: {
    const auto &gep = cast<GetElementPtrInst>(i);
    if (!gep.getType()->isPointerTy()) return std::nullopt;
    auto *element = gep.getSourceElementType();
    for (auto *t = element;;) {
      if (auto *array = dyn_cast<ArrayType>(t)) { t = array->getElementType(); continue; }
      if (!integer(t)) return std::nullopt; // excludes opaque/recursive structs and vectors
      break;
    }
    type(element); type(gep.getPointerOperandType());
    if (auto *gv = dyn_cast<GlobalValue>(gep.getPointerOperand()->stripPointerCasts())) {
      out << "global:"; gv->print(out); out << ';';
    } else out << "register;";
    for (auto &index : gep.indices()) {
      if (!integer(index->getType())) return std::nullopt;
      type(index->getType());
      if (auto *c = dyn_cast<ConstantInt>(index.get())) c->printAsOperand(out, false);
      else out << "dynamic";
      out << ';';
    }
    // LLVM24 getInstructionCost supplies AccessType for one unique user.
    // Multiple uses by the same instruction count as one user, not one Use.
    const User *only = nullptr;
    bool many = false;
    for (const auto *user : gep.users()) {
      if (only && only != user) { many = true; break; }
      only = user;
    }
    if (only && !many) {
      if (auto *load = dyn_cast<LoadInst>(only)) type(load->getType());
      else if (auto *store = dyn_cast<StoreInst>(only)) type(store->getValueOperand()->getType());
      else if (isa<CallBase>(only) || isa<AtomicRMWInst>(only) || isa<AtomicCmpXchgInst>(only)) return std::nullopt;
      else out << "no-access-hint";
    } else out << "no-access-hint";
    break;
  }
  case Instruction::Call: {
    const auto *call = dyn_cast<IntrinsicInst>(&i);
    if (!call || call->arg_size() || call->hasOperandBundles()) return std::nullopt;
    auto name = call->getCalledFunction()->getName();
    if (name != "llvm.amdgcn.workitem.id.x" && name != "llvm.amdgcn.workgroup.id.x" &&
        name != "llvm.amdgcn.dispatch.ptr" && name != "llvm.amdgcn.s.barrier") return std::nullopt;
    out << name << ';'; out << call->getAttributes().getAsString(AttributeList::FunctionIndex) << call->getAttributes().getAsString(AttributeList::ReturnIndex);
    break;
  }
  default:
    return std::nullopt;
  }
  out.flush(); return key;
}
} // namespace fusion
