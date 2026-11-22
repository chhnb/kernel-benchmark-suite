#pragma once

#include "llvm/IR/Instructions.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/JSON.h"
#include "llvm/ADT/Triple.h"
#include <array>
#include <optional>

namespace fusion {
namespace wave_diagnostic {
using Shape = std::array<unsigned, 3>;

inline std::optional<llvm::APInt> evaluate(const llvm::Value *v, const Shape &ids,
                                          bool amd, unsigned depth = 0) {
  using namespace llvm;
  if (depth >= 32 || !v->getType()->isIntegerTy()) return std::nullopt;
  if (const auto *n = dyn_cast<ConstantInt>(v)) return n->getValue();
  if (const auto *call = dyn_cast<CallInst>(v)) {
    const auto *callee = call->getCalledFunction();
    if (!callee || !callee->isIntrinsic()) return std::nullopt;
    auto symbol = callee->getName();
    auto prefix = amd ? "llvm.amdgcn.workitem.id." : "llvm.nvvm.read.ptx.sreg.tid.";
    if (!symbol.consume_front(prefix) || symbol.size() != 1) return std::nullopt;
    auto dimension = StringRef("xyz").find(symbol.front());
    if (dimension >= ids.size()) return std::nullopt;
    APInt id(v->getType()->getIntegerBitWidth(), ids[dimension]);
    if (const auto *range = call->getMetadata(LLVMContext::MD_range)) {
      if (range->getNumOperands() != 2) return std::nullopt;
      const auto *low = mdconst::dyn_extract<ConstantInt>(range->getOperand(0));
      const auto *high = mdconst::dyn_extract<ConstantInt>(range->getOperand(1));
      if (!low || !high || low->getBitWidth() != id.getBitWidth() ||
          high->getBitWidth() != id.getBitWidth() || id.ult(low->getValue()) ||
          id.uge(high->getValue()))
        return std::nullopt;
    }
    return id;
  }
  const auto *inst = dyn_cast<Instruction>(v);
  if (!inst) return std::nullopt;
  auto operand = [&](unsigned i) { return evaluate(inst->getOperand(i), ids, amd, depth + 1); };
  if (isa<FreezeInst>(inst)) return operand(0);
  if (const auto *cast = dyn_cast<CastInst>(inst)) {
    const auto input = operand(0);
    if (!input) return std::nullopt;
    unsigned bits = cast->getType()->getIntegerBitWidth();
    if (isa<TruncInst>(cast)) return input->trunc(bits);
    if (isa<SExtInst>(cast)) return input->sext(bits);
    if (isa<ZExtInst>(cast)) return input->zext(bits);
    return std::nullopt;
  }
  if (isa<SelectInst>(inst)) {
    auto cond = operand(0), lhs = operand(1), rhs = operand(2);
    if (!cond || !lhs || !rhs) return std::nullopt;
    return *cond == 0 ? rhs : lhs;
  }
  const auto *operation = dyn_cast<BinaryOperator>(inst);
  const auto *compare = dyn_cast<ICmpInst>(inst);
  if (!operation && !compare) return std::nullopt;
  auto lhs = operand(0), rhs = operand(1);
  if (!lhs || !rhs || lhs->getBitWidth() != rhs->getBitWidth()) return std::nullopt;
  if (compare) {
    switch (compare->getPredicate()) {
    case ICmpInst::ICMP_EQ: return APInt(1, *lhs == *rhs);
    case ICmpInst::ICMP_NE: return APInt(1, *lhs != *rhs);
    case ICmpInst::ICMP_UGT: return APInt(1, lhs->ugt(*rhs));
    case ICmpInst::ICMP_UGE: return APInt(1, lhs->uge(*rhs));
    case ICmpInst::ICMP_ULT: return APInt(1, lhs->ult(*rhs));
    case ICmpInst::ICMP_ULE: return APInt(1, lhs->ule(*rhs));
    case ICmpInst::ICMP_SGT: return APInt(1, lhs->sgt(*rhs));
    case ICmpInst::ICMP_SGE: return APInt(1, lhs->sge(*rhs));
    case ICmpInst::ICMP_SLT: return APInt(1, lhs->slt(*rhs));
    case ICmpInst::ICMP_SLE: return APInt(1, lhs->sle(*rhs));
    default: return std::nullopt;
    }
  }
  bool signedOverflow = false, unsignedOverflow = false;
  APInt result;
  switch (operation->getOpcode()) {
  case Instruction::Add:
    result = lhs->sadd_ov(*rhs, signedOverflow);
    lhs->uadd_ov(*rhs, unsignedOverflow);
    break;
  case Instruction::Sub:
    result = lhs->ssub_ov(*rhs, signedOverflow);
    lhs->usub_ov(*rhs, unsignedOverflow);
    break;
  case Instruction::Mul:
    result = lhs->smul_ov(*rhs, signedOverflow);
    lhs->umul_ov(*rhs, unsignedOverflow);
    break;
  case Instruction::And: return *lhs & *rhs;
  case Instruction::Or: return *lhs | *rhs;
  case Instruction::Xor: return *lhs ^ *rhs;
  default: return std::nullopt;
  }
  if ((operation->hasNoSignedWrap() && signedOverflow) ||
      (operation->hasNoUnsignedWrap() && unsignedOverflow))
    return std::nullopt;
  return result;
}

inline llvm::json::Object classify(const llvm::Function &f, const llvm::BranchInst *branch,
                                   llvm::StringRef launch) {
  using namespace llvm;
  Shape shape{};
  bool exact = false;
  StringRef source = "unavailable";
  if (!launch.empty()) {
    SmallVector<StringRef, 3> dimensions;
    launch.split(dimensions, ',');
    exact = dimensions.size() == 3;
    if (exact)
      for (unsigned i = 0; i != 3; ++i)
        exact &= !dimensions[i].getAsInteger(10, shape[i]);
    source = "external_launch";
  } else if (auto *required = f.getMetadata("reqd_work_group_size")) {
    exact = required->getNumOperands() == 3;
    if (exact)
      for (unsigned i = 0; i != 3; ++i) {
        const auto *value = mdconst::dyn_extract<ConstantInt>(required->getOperand(i));
        if (!value || value->getValue().getActiveBits() > 32) exact = false;
        else shape[i] = value->getZExtValue();
      }
    source = "reqd_work_group_size";
  }
  exact &= llvm::all_of(shape, [](unsigned n) { return n && n <= 1024; });
  unsigned threads = exact ? shape[0] * shape[1] * shape[2] : 0;
  exact &= threads <= 1024;

  Triple triple(f.getParent()->getTargetTriple());
  auto cpu = f.getFnAttribute("target-cpu");
  auto features = f.getFnAttribute("target-features");
  unsigned width = triple.isNVPTX() ? 32 : 0;
  if (triple.isAMDGPU() && cpu.isStringAttribute() && cpu.getValueAsString() == "gfx906" &&
      (!features.isStringAttribute() || !features.getValueAsString().contains("+wavefrontsize32")))
    width = 64;
  json::Object report{{"classification", "unknown"},
      {"shape", exact ? json::Value(json::Array{shape[0], shape[1], shape[2]}) : json::Value(nullptr)},
      {"shape_source", exact ? source : "unavailable"},
      {"wave_size", width ? json::Value(width) : json::Value(nullptr)},
      {"total_waves", exact && width ? json::Value((threads + width - 1) / width) : json::Value(nullptr)},
      {"mixed_waves", nullptr}};
  if (!exact || !width || !branch || !branch->isConditional()) {
    report["reason"] = !exact ? "exact_shape_unavailable" :
        !width ? "wave_size_unavailable" : "no_conditional_branch";
    return report;
  }

  unsigned mixed = 0, directions = 0;
  for (unsigned linear = 0; linear != threads; ++linear) {
    Shape ids{linear % shape[0], linear / shape[0] % shape[1], linear / (shape[0] * shape[1])};
    auto value = evaluate(branch->getCondition(), ids, triple.isAMDGPU());
    if (!value) {
      report["reason"] = "condition_not_statically_evaluable";
      return report;
    }
    directions |= *value == 0 ? 1 : 2;
    if ((linear + 1) % width == 0 || linear + 1 == threads) {
      mixed += directions == 3;
      directions = 0;
    }
  }
  report["mixed_waves"] = mixed;
  report["classification"] = mixed == (threads + width - 1) / width ? "must-diverge" :
                             mixed == 0 ? "must-uniform" : "mixed";
  return report;
}
} // namespace wave_diagnostic
} // namespace fusion
