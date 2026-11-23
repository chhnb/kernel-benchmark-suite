// Scalar differential semantics for extracted B2B regions.
#include "llvm/ADT/APFloat.h"
#include "llvm/ADT/APInt.h"
#include "llvm/ADT/APSInt.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Operator.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/SourceMgr.h"
#include <map>
#include <set>
#include <vector>

using namespace llvm;

namespace {
enum class State { Defined, Undef, Poison };
struct Scalar {
  APInt bits = APInt(1, 0);
  State state = State::Defined;
  SmallVector<State, 4> lanes;
  Scalar() = default;
  Scalar(APInt value, State kind) : bits(std::move(value)), state(kind) {}
};

struct Cell {
  uint8_t bits;
  State state;
};

uint64_t mix(uint64_t x) {
  x ^= x >> 30;
  x *= UINT64_C(0xbf58476d1ce4e5b9);
  x ^= x >> 27;
  x *= UINT64_C(0x94d049bb133111eb);
  return x ^ (x >> 31);
}

unsigned width(Type *type, const DataLayout &dl) {
  if (auto *vec = dyn_cast<FixedVectorType>(type))
    return vec->getNumElements() * width(vec->getElementType(), dl);
  if (type->isPointerTy())
    return dl.getPointerTypeSizeInBits(type);
  if (type->isIntegerTy())
    return type->getIntegerBitWidth();
  if (type->isFloatTy())
    return 32;
  if (type->isDoubleTy())
    return 64;
  return 0;
}

struct Run {
  const Function &fn;
  const DataLayout &dl;
  uint64_t seed;
  DenseMap<const Value *, Scalar> values;
  std::map<uint64_t, Cell> writes;
  std::vector<uint64_t> effects;
  Scalar returned;
  StringRef error;
  bool invalidInput = false;
  static constexpr uint64_t ObjectSize = 1u << 20;
  uint64_t memoryLimit;

  Run(const Function &function, uint64_t inputSeed, bool condition)
      : fn(function), dl(fn.getParent()->getDataLayout()), seed(inputSeed),
        memoryLimit((fn.arg_size() + 1) * ObjectSize) {
    for (const auto &arg : fn.args()) {
      unsigned bits = width(arg.getType(), dl);
      if (!bits) {
        error = "unsupported parameter type";
        return;
      }
      auto slot = arg.getArgNo();
      uint64_t random = mix(seed + slot);
      int64_t small = static_cast<int64_t>(random % 64) - 32;
      if (small == 0) small = 1;
      APInt value(bits, small, true);
      if (arg.getType()->isPointerTy()) {
        uint64_t object = ((seed & 3) == 1 && slot > 1) ? 1 : slot;
        value = APInt(bits, object * ObjectSize + ObjectSize / 2);
      } else if (arg.getType()->isFloatTy()) {
        value = APFloat(static_cast<float>(small) / 8.0f).bitcastToAPInt();
      } else if (arg.getType()->isDoubleTy()) {
        value = APFloat(static_cast<double>(small) / 8.0).bitcastToAPInt();
      } else if (slot == 0) {
        value = APInt(bits, condition);
      }
      values[&arg] = {std::move(value), State::Defined};
    }
  }

  void invalid(StringRef why) {
    error = why;
    invalidInput = true;
  }

  Cell cell(uint64_t addr) const {
    auto found = writes.find(addr);
    return found == writes.end()
        ? Cell{static_cast<uint8_t>(mix(seed + addr)), State::Defined}
        : found->second;
  }

  Scalar get(const Value *v) {
    unsigned n = width(v->getType(), dl);
    if (!n) {
      error = "unsupported operand type";
      return {};
    }
    if (auto *c = dyn_cast<ConstantInt>(v))
      return {c->getValue(), State::Defined};
    if (auto *c = dyn_cast<ConstantFP>(v))
      return {c->getValueAPF().bitcastToAPInt(), State::Defined};
    if (isa<PoisonValue>(v))
      return {APInt(n, 0), State::Poison};
    if (isa<UndefValue>(v))
      return {APInt(n, 0), State::Undef};
    if (isa<ConstantPointerNull>(v))
      return {APInt(n, 0), State::Defined};
    if (auto it = values.find(v); it != values.end())
      return it->second;
    error = "unsupported constant or unavailable value";
    return {};
  }

  Scalar operation(const Instruction &inst) {
    unsigned n = width(inst.getType(), dl);
    if (!n && !inst.getType()->isVoidTy()) {
      error = "unsupported instruction result type";
      return {};
    }
    if (auto *sel = dyn_cast<SelectInst>(&inst)) {
      auto c = get(sel->getCondition());
      if (c.state != State::Defined)
        return {APInt(n, 0), c.state};
      return get((c.bits == 0) ? sel->getFalseValue() : sel->getTrueValue());
    }
    if (auto *call = dyn_cast<CallInst>(&inst)) {
      auto *callee = call->getCalledFunction();
      if (!callee || !callee->isIntrinsic()) {
        error = "ordinary or indirect call";
        return {};
      }
      StringRef name = callee->getName();
      if (name.startswith("llvm.lifetime."))
        return {};
      if (!name.startswith("llvm.amdgcn.") && !name.startswith("llvm.nvvm.")) {
        if (!(call->getType()->isFloatTy() || call->getType()->isDoubleTy()) ||
            call->arg_empty() ||
            !(name.startswith("llvm.fabs.") || name.startswith("llvm.fma.") ||
              name.startswith("llvm.ceil.") || name.startswith("llvm.floor.") ||
              name.startswith("llvm.trunc.") || name.startswith("llvm.minnum.") ||
              name.startswith("llvm.maxnum.") || name.startswith("llvm.copysign."))) {
          error = "unsupported generic LLVM intrinsic";
          return {};
        }
        auto &format = call->getType()->getFltSemantics();
        SmallVector<APFloat, 3> operands;
        for (const auto &arg : call->args()) {
          auto value = get(arg.get());
          if (!error.empty())
            return {};
          if (value.state != State::Defined)
            return {APInt(n, 0), value.state};
          operands.emplace_back(format, value.bits);
        }
        auto &v = operands[0];
        if (name.startswith("llvm.fabs."))
          v.clearSign();
        else if (name.startswith("llvm.fma."))
          v.fusedMultiplyAdd(operands[1], operands[2], APFloat::rmNearestTiesToEven);
        else if (name.startswith("llvm.ceil."))
          v.roundToIntegral(APFloat::rmTowardPositive);
        else if (name.startswith("llvm.floor."))
          v.roundToIntegral(APFloat::rmTowardNegative);
        else if (name.startswith("llvm.trunc."))
          v.roundToIntegral(APFloat::rmTowardZero);
        else if (name.startswith("llvm.minnum."))
          v = minnum(v, operands[1]);
        else if (name.startswith("llvm.maxnum."))
          v = maxnum(v, operands[1]);
        else if (v.isNegative() != operands[1].isNegative())
          v.changeSign();
        return {v.bitcastToAPInt(), State::Defined};
      }
      if (call->mayReadOrWriteMemory() && !name.equals("llvm.amdgcn.s.sendmsg") &&
          !name.startswith("llvm.amdgcn.image.sample")) {
        error = "unsupported memory behavior of target intrinsic";
        return {};
      }
      uint64_t hash = seed;
      for (unsigned char ch : name.bytes())
        hash = mix(hash ^ ch);
      for (const auto &argument : call->args()) {
        auto scalar = get(argument.get());
        if (scalar.state != State::Defined)
          return {APInt(n ? n : 1, 0), scalar.state};
        if (scalar.bits.getBitWidth() > 64) {
          error = "target intrinsic operand wider than 64 bits";
          return {};
        }
        hash = mix(hash ^ scalar.bits.getZExtValue());
      }
      if (n == 0) {
        effects.push_back(hash);
        return {};
      }
      return {APInt(n, hash), State::Defined};
    }
    if (auto *gep = dyn_cast<GetElementPtrInst>(&inst)) {
      auto pointer = get(gep->getPointerOperand());
      SmallVector<Value *, 8> indices;
      for (auto &index : gep->indices()) {
        auto value = get(index.get());
        if (value.state != State::Defined)
          return {APInt(n, 0), value.state};
        indices.push_back(ConstantInt::get(index->getType(), value.bits));
      }
      if (pointer.state != State::Defined)
        return pointer;
      auto offset = dl.getIndexedOffsetInType(gep->getSourceElementType(), indices);
      APInt result = pointer.bits + APInt(n, offset, true);
      if (gep->isInBounds() && (result.getZExtValue() >= memoryLimit ||
          result.getZExtValue() / ObjectSize != pointer.bits.getZExtValue() / ObjectSize))
        return {result, State::Poison};
      return {result, State::Defined};
    }
    if (const auto *insert = dyn_cast<InsertElementInst>(&inst)) {
      auto vec = get(insert->getOperand(0));
      auto value = get(insert->getOperand(1));
      auto index = get(insert->getOperand(2));
      const auto *type = cast<FixedVectorType>(insert->getType());
      unsigned lanes = type->getNumElements();
      if (index.state != State::Defined || index.bits.uge(lanes))
        return {APInt(n, 0), index.state == State::Undef ? State::Undef : State::Poison};
      unsigned at = index.bits.getZExtValue();
      if (vec.lanes.empty())
        vec.lanes.assign(lanes, vec.state);
      vec.bits.insertBits(value.bits, at * value.bits.getBitWidth());
      vec.lanes[at] = value.state;
      vec.state = State::Defined;
      return vec;
    }
    if (const auto *extract = dyn_cast<ExtractElementInst>(&inst)) {
      auto vec = get(extract->getOperand(0));
      auto index = get(extract->getOperand(1));
      const auto *vector = dyn_cast<FixedVectorType>(extract->getVectorOperandType());
      if (!vector) {
        error = "unsupported scalable vector";
        return {};
      }
      unsigned lanes = vector->getNumElements();
      if (index.state != State::Defined || index.bits.uge(lanes))
        return {APInt(n, 0), index.state == State::Undef ? State::Undef : State::Poison};
      unsigned at = index.bits.getZExtValue();
      return {vec.bits.extractBits(n, at * n), vec.lanes.empty() ? vec.state : vec.lanes[at]};
    }
    if (isa<LoadInst, StoreInst>(inst)) {
      auto *load = dyn_cast<LoadInst>(&inst);
      auto *store = dyn_cast<StoreInst>(&inst);
      bool ordered = load ? !load->isSimple() : !store->isSimple();
      auto pointer = get(load ? load->getPointerOperand() : store->getPointerOperand());
      unsigned bits = load ? n : width(store->getValueOperand()->getType(), dl);
      const auto *vector = dyn_cast<FixedVectorType>(load ? load->getType() : store->getValueOperand()->getType());
      unsigned laneBits = vector ? width(vector->getElementType(), dl) : bits;
      if (!bits || (vector && laneBits % 8) || !dl.isLittleEndian()) {
        error = "unsupported scalar memory access";
        return {};
      }
      unsigned size = (bits + 7) / 8;
      uint64_t address = pointer.bits.getLimitedValue();
      unsigned alignment = load ? load->getAlign().value() : store->getAlign().value();
      if (pointer.state != State::Defined || address < ObjectSize || address >= memoryLimit ||
          address % alignment || address % ObjectSize + size > ObjectSize) {
        invalid("invalid memory access");
        return {};
      }
      if (ordered) {
        unsigned ordering = static_cast<unsigned>(load ? load->getOrdering() : store->getOrdering());
        effects.push_back(mix(address ^ (static_cast<uint64_t>(size) << 48) ^
                             (static_cast<uint64_t>(ordering) << 56) ^
                             (static_cast<uint64_t>(load != nullptr) << 63)));
      }
      if (load) {
        Scalar output(APInt(bits, 0), State::Defined);
        if (vector)
          output.lanes.assign(vector->getNumElements(), State::Defined);
        for (unsigned i = 0; i < size; ++i) {
          auto actual = cell(address+i);
          output.bits.insertBits(APInt(std::min(8u, bits - 8*i), actual.bits), 8*i);
          auto &state = vector ? output.lanes[(8*i) / laneBits] : output.state;
          state = std::max(state, actual.state);
        }
        return output;
      }
      auto value = get(store->getValueOperand());
      for (unsigned i = 0; i < size; ++i) {
        auto byte = value.bits.extractBits(std::min(8u, bits - 8*i), 8*i).getZExtValue();
        auto state = value.lanes.empty() ? value.state : value.lanes[(8*i) / laneBits];
        writes[address+i] = {static_cast<uint8_t>(byte), state};
        if (ordered)
          effects.push_back(mix(byte ^ (static_cast<uint64_t>(state) << 8)));
      }
      return {};
    }
    if (inst.getType()->isVectorTy() ||
        llvm::any_of(inst.operands(), [](const Use &op) { return op->getType()->isVectorTy(); })) {
      error = "unsupported vector arithmetic";
      return {};
    }
    if (inst.getNumOperands() < 1 || inst.getNumOperands() > 2 || !n) {
      error = "unsupported opcode or operand count";
      return {};
    }
    auto a = get(inst.getOperand(0));
    Scalar b;
    if (inst.getNumOperands() == 2)
      b = get(inst.getOperand(1));
    if (!error.empty())
      return {};
    if (isa<FreezeInst>(inst))
      return {a.bits, State::Defined};
    auto undefined = std::max(a.state, b.state);
    if (undefined != State::Defined)
      return {APInt(n, 0), undefined};

    auto &x = a.bits, &y = b.bits;
    APInt v(n, 0);
    bool poison = false;
    bool uof = false, sof = false;
    switch (inst.getOpcode()) {
    case Instruction::Add:
      v = x.uadd_ov(y, uof); (void)x.sadd_ov(y, sof); break;
    case Instruction::Sub:
      v = x.usub_ov(y, uof); (void)x.ssub_ov(y, sof); break;
    case Instruction::Mul:
      v = x.umul_ov(y, uof); (void)x.smul_ov(y, sof); break;
    case Instruction::And: v = x & y; break;
    case Instruction::Or: v = x | y; break;
    case Instruction::Xor: v = x ^ y; break;
    case Instruction::SDiv: case Instruction::UDiv:
    case Instruction::SRem: case Instruction::URem:
      if ((y == 0) || ((inst.getOpcode() == Instruction::SDiv ||
                          inst.getOpcode() == Instruction::SRem) &&
                         x.isMinSignedValue() && y.isAllOnesValue())) {
        invalid("undefined integer division");
        break;
      }
      if (inst.getOpcode() == Instruction::SDiv) {
        v = x.sdiv(y);
        poison = inst.isExact() && x.srem(y) != 0;
      } else if (inst.getOpcode() == Instruction::UDiv) {
        v = x.udiv(y);
        poison = inst.isExact() && x.urem(y) != 0;
      } else
        v = inst.getOpcode() == Instruction::SRem ? x.srem(y) : x.urem(y);
      break;
    case Instruction::Shl: case Instruction::LShr: case Instruction::AShr:
      if (y.uge(n)) {
        poison = true;
        break;
      }
      if (inst.getOpcode() == Instruction::Shl) {
        v = x.ushl_ov(y, uof);
        (void)x.sshl_ov(y, sof);
      } else {
        v = inst.getOpcode() == Instruction::LShr ? x.lshr(y) : x.ashr(y);
        poison = inst.isExact() && v.shl(y) != x;
      }
      break;
    case Instruction::ZExt: case Instruction::Trunc: case Instruction::BitCast:
    case Instruction::PtrToInt: case Instruction::IntToPtr: case Instruction::AddrSpaceCast:
      v = x.zextOrTrunc(n); break;
    case Instruction::SExt: v = x.sext(n); break;
    case Instruction::ICmp: {
      auto predicate = cast<ICmpInst>(inst).getPredicate();
      const bool signedCmp = ICmpInst::isSigned(predicate);
      auto lt = signedCmp ? x.slt(y) : x.ult(y);
      auto gt = signedCmp ? x.sgt(y) : x.ugt(y);
      bool equal = x == y;
      bool result = false;
      switch (predicate) {
      case CmpInst::ICMP_EQ: result = equal; break;
      case CmpInst::ICMP_NE: result = !equal; break;
      case CmpInst::ICMP_SLT: case CmpInst::ICMP_ULT: result = lt; break;
      case CmpInst::ICMP_SLE: case CmpInst::ICMP_ULE: result = !gt; break;
      case CmpInst::ICMP_SGT: case CmpInst::ICMP_UGT: result = gt; break;
      case CmpInst::ICMP_SGE: case CmpInst::ICMP_UGE: result = !lt; break;
      default: llvm_unreachable("invalid integer predicate");
      }
      v = APInt(1, result);
      break;
    }
    case Instruction::SIToFP: case Instruction::UIToFP: {
      auto result = APFloat::getZero(inst.getType()->getFltSemantics());
      result.convertFromAPInt(x, inst.getOpcode() == Instruction::SIToFP,
                              APFloat::rmNearestTiesToEven);
      v = result.bitcastToAPInt();
      break;
    }
    case Instruction::FPToSI: case Instruction::FPToUI: {
      APFloat input(inst.getOperand(0)->getType()->getFltSemantics(), x);
      APSInt result(n, inst.getOpcode() == Instruction::FPToUI);
      bool exact = false;
      poison = input.convertToInteger(result, APFloat::rmTowardZero, &exact) & APFloat::opInvalidOp;
      v = result;
      break;
    }
    case Instruction::FPExt: case Instruction::FPTrunc: {
      APFloat input(inst.getOperand(0)->getType()->getFltSemantics(), x);
      bool losesInfo = false;
      input.convert(inst.getType()->getFltSemantics(), APFloat::rmNearestTiesToEven, &losesInfo);
      v = input.bitcastToAPInt();
      break;
    }
    case Instruction::FNeg: case Instruction::FAdd: case Instruction::FSub:
    case Instruction::FMul: case Instruction::FDiv: case Instruction::FRem:
    case Instruction::FCmp: {
      auto &semantics = inst.getOperand(0)->getType()->getFltSemantics();
      APFloat lhs(semantics, x);
      APFloat rhs = inst.getNumOperands() == 2 ? APFloat(semantics, y) : lhs;
      if (inst.getOpcode() == Instruction::FCmp) {
        auto relation = lhs.compare(rhs);
        unsigned outcome = relation == APFloat::cmpEqual ? 1 :
            relation == APFloat::cmpGreaterThan ? 2 :
            relation == APFloat::cmpLessThan ? 4 : 8;
        v = APInt(1, cast<FCmpInst>(inst).getPredicate() & outcome);
        poison = (inst.hasNoNaNs() && (lhs.isNaN() || rhs.isNaN())) ||
                 (inst.hasNoInfs() && (lhs.isInfinity() || rhs.isInfinity()));
        break;
      }
      auto mode = APFloat::rmNearestTiesToEven;
      switch (inst.getOpcode()) {
      case Instruction::FNeg: lhs.changeSign(); break;
      case Instruction::FAdd: lhs.add(rhs, mode); break;
      case Instruction::FSub: lhs.subtract(rhs, mode); break;
      case Instruction::FMul: lhs.multiply(rhs, mode); break;
      case Instruction::FDiv: lhs.divide(rhs, mode); break;
      case Instruction::FRem: lhs.mod(rhs); break;
      default: llvm_unreachable("not a floating arithmetic opcode");
      }
      poison = (inst.hasNoNaNs() && (lhs.isNaN() || rhs.isNaN())) ||
               (inst.hasNoInfs() && (lhs.isInfinity() || rhs.isInfinity()));
      v = lhs.bitcastToAPInt();
      break;
    }
    default:
      error = "unsupported scalar opcode";
    }
    if (auto *overflow = dyn_cast<OverflowingBinaryOperator>(&inst))
      poison |= (overflow->hasNoUnsignedWrap() && uof) ||
                (overflow->hasNoSignedWrap() && sof);
    return {std::move(v), poison ? State::Poison : State::Defined};
  }

  void execute() {
    if (!error.empty())
      return;
    const BasicBlock *block = &fn.getEntryBlock(), *previous = nullptr;
    for (size_t steps = 0; steps < fn.size(); ++steps) {
      SmallVector<std::pair<const PHINode *, Scalar>, 8> phis;
      for (const auto &phi : block->phis())
        phis.emplace_back(&phi, get(phi.getIncomingValueForBlock(previous)));
      for (const auto &entry : phis)
        values[entry.first] = entry.second;
      for (const auto &inst : *block) {
        if (inst.isTerminator() || isa<PHINode>(inst))
          continue;
        auto result = operation(inst);
        if (!error.empty())
          return;
        if (!inst.getType()->isVoidTy())
          values[&inst] = std::move(result);
      }
      if (const auto *ret = dyn_cast<ReturnInst>(block->getTerminator())) {
        if (ret->getReturnValue())
          returned = get(ret->getReturnValue());
        return;
      }
      const auto *br = dyn_cast<BranchInst>(block->getTerminator());
      if (!br) {
        error = "unsupported terminator";
        return;
      }
      previous = block;
      unsigned edge = 0;
      if (br->isConditional()) {
        auto c = get(br->getCondition());
        if (c.state != State::Defined) {
          invalid("indeterminate branch condition");
          return;
        }
        edge = (c.bits == 0);
      }
      block = br->getSuccessor(edge);
    }
    error = "execution exceeded acyclic block bound";
  }
};

bool matches(const Run &a, const Run &b) {
  if (a.returned.state == State::Defined &&
      (b.returned.state != State::Defined || a.returned.bits != b.returned.bits))
    return false;
  if (a.effects != b.effects)
    return false;
  std::set<uint64_t> addresses;
  for (const auto *run : {&a, &b})
    for (const auto &entry : run->writes)
      addresses.insert(entry.first);
  for (auto address : addresses) {
    auto before = a.cell(address), after = b.cell(address);
    if (before.state == State::Defined &&
        (after.state != State::Defined || before.bits != after.bits))
      return false;
  }
  return true;
}

const Function *single(const Module &module) {
  const Function *found = nullptr;
  for (const auto &function : module)
    if (!function.isDeclaration()) {
      if (found)
        return nullptr;
      found = &function;
    }
  return found;
}
} // namespace

int main(int argc, char **argv) {
  if (argc != 3) {
    errs() << "usage: interpret_region ORIGINAL.ll CANDIDATE.ll\n";
    return 2;
  }
  LLVMContext left, right;
  SMDiagnostic diag;
  auto a = parseIRFile(argv[1], diag, left), b = parseIRFile(argv[2], diag, right);
  if (!a || !b) {
    diag.print(argv[0], errs());
    return 2;
  }
  auto *f = single(*a), *g = single(*b);
  if (!f || !g || f->arg_size() != g->arg_size() || !f->arg_size() ||
      !f->getArg(0)->getType()->isIntegerTy(1) || !g->getArg(0)->getType()->isIntegerTy(1))
    return 2;
  json::Object report{{"method", "bounded-scalar-interpreter"}, {"status", "pass"}};
  for (bool condition : {true, false}) {
    unsigned samples = 0;
    for (unsigned draw = 0; draw < 10000 && samples < 1000; ++draw) {
      uint64_t seed = mix(draw + 1729);
      Run original(*f, seed, condition);
      original.execute();
      if (original.invalidInput)
        continue;
      if (!original.error.empty()) {
        report["status"] = "unsupported";
        report["reason"] = original.error;
        break;
      }
      Run candidate(*g, seed, condition);
      candidate.execute();
      if (candidate.invalidInput || (candidate.error.empty() && !matches(original, candidate))) {
        report["status"] = "mismatch";
        report["reason"] = candidate.error.empty() ? "result or memory differs" : candidate.error;
        report["seed"] = std::to_string(seed);
        report["condition"] = condition;
        break;
      }
      if (!candidate.error.empty()) {
        report["status"] = "unsupported";
        report["reason"] = candidate.error;
        break;
      }
      ++samples;
    }
    report[condition ? "true_samples" : "false_samples"] = samples;
    if (report.getString("status") != Optional<StringRef>("pass"))
      break;
    if (samples < 1000) {
      report["status"] = "unsupported";
      report["reason"] = "fewer than 1000 defined source executions on bounded inputs";
      break;
    }
  }
  outs() << json::Value(std::move(report)) << '\n';
}
