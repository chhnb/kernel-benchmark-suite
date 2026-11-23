#include "../anchor_condition.h"

#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/Analysis/PostDominators.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/ModuleSlotTracker.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/SHA1.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Transforms/Utils/ValueMapper.h"

#include <map>
#include <set>
#include <string>

using namespace llvm;

namespace {
using Blocks = SmallVector<BasicBlock *, 8>;
using BlockSet = SmallPtrSet<BasicBlock *, 16>;

struct Region {
  explicit Region(BranchInst &branch) : split(branch) {}
  BranchInst &split;
  BasicBlock *join = nullptr;
  Blocks left, right;
  StringRef kind = "other";
  bool extraPreds = false;
  bool isB2B() const {
    return kind == "b2b-diamond" || kind == "b2b-triangle";
  }
};

BasicBlock *singleArm(BasicBlock *entry, BasicBlock *split) {
  if (entry == split || entry->getSinglePredecessor() != split)
    return nullptr;
  auto *branch = dyn_cast<BranchInst>(entry->getTerminator());
  return branch && branch->isUnconditional() ? branch->getSuccessor(0)
                                              : nullptr;
}

struct Arm {
  Blocks blocks;
  BlockSet members;
  bool reachesJoin = false;
  bool hasExit = false;
};

Arm walkArm(BasicBlock *entry, BasicBlock *split, BasicBlock *join) {
  Arm arm;
  Blocks pending{entry};
  while (!pending.empty()) {
    auto *block = pending.pop_back_val();
    if (block == join) {
      arm.reachesJoin = true;
      continue;
    }
    if (block == split) {
      arm.hasExit = true;
      continue;
    }
    if (!arm.members.insert(block).second)
      continue;
    arm.blocks.push_back(block);
    auto *end = block->getTerminator();
    if (!end->getNumSuccessors())
      arm.hasExit = true;
    for (unsigned i = end->getNumSuccessors(); i > 0; --i)
      pending.push_back(end->getSuccessor(i - 1));
  }
  return arm;
}

bool isSingleEntry(const Arm &arm, BasicBlock *split, BasicBlock *entry) {
  for (auto *block : arm.blocks)
    for (auto *pred : predecessors(block))
      if (!arm.members.count(pred) && !(pred == split && block == entry))
        return false;
  return true;
}

Region classify(BranchInst &branch, PostDominatorTree &postdom) {
  Region region{branch};
  auto *split = branch.getParent();
  auto *left = branch.getSuccessor(0);
  auto *right = branch.getSuccessor(1);
  auto *afterLeft = singleArm(left, split);
  auto *afterRight = singleArm(right, split);
  if (left != right) {
    if (afterLeft && afterLeft == afterRight && afterLeft != split &&
        afterLeft != left && afterLeft != right) {
      region.left.push_back(left);
      region.right.push_back(right);
      region.join = afterLeft;
      region.kind = "b2b-diamond";
    } else if (afterLeft == right && right != split) {
      region.left.push_back(left);
      region.join = right;
      region.kind = "b2b-triangle";
    } else if (afterRight == left && left != split) {
      region.right.push_back(right);
      region.join = left;
      region.kind = "b2b-triangle";
    }
  }
  if (region.isB2B()) {
    region.extraPreds = pred_size(region.join) > 2;
    return region;
  }
  if (postdom.getNode(left) && postdom.getNode(right))
    region.join = postdom.findNearestCommonDominator(left, right);
  if (region.join == split)
    region.join = nullptr;
  auto l = walkArm(left, split, region.join);
  auto r = walkArm(right, split, region.join);
  if (region.join)
    for (auto *pred : predecessors(region.join))
      if (pred != split && !l.members.count(pred) && !r.members.count(pred))
        region.extraPreds = true;
  bool disjoint = llvm::none_of(l.blocks, [&](auto *bb) { return r.members.count(bb); });
  if (region.join && !region.extraPreds && disjoint && l.reachesJoin &&
      r.reachesJoin && !l.hasExit && !r.hasExit && isSingleEntry(l, split, left) &&
      isSingleEntry(r, split, right)) {
    unsigned big = (l.blocks.size() > 1) + (r.blocks.size() > 1);
    if (big)
      region.kind = big == 2 ? "r2r" : "b2r";
  }
  region.left = std::move(l.blocks);
  region.right = std::move(r.blocks);
  return region;
}

bool laneInput(const Instruction &instruction) {
  auto *call = dyn_cast<CallBase>(&instruction);
  auto *function = call ? call->getCalledFunction() : nullptr;
  if (!function || !function->isIntrinsic() || !call->arg_empty())
    return false;
  auto name = function->getName();
  return name.startswith("llvm.amdgcn.workitem.id.") ||
         name.startswith("llvm.amdgcn.workgroup.id.") ||
         name.startswith("llvm.nvvm.read.ptx.sreg.tid.") ||
         name.startswith("llvm.nvvm.read.ptx.sreg.ctaid.") ||
         name.startswith("llvm.nvvm.read.ptx.sreg.ntid.") ||
         name.startswith("llvm.nvvm.read.ptx.sreg.nctaid.") ||
         name == "llvm.amdgcn.dispatch.ptr" || name == "llvm.amdgcn.kernarg.segment.ptr" ||
         name == "llvm.amdgcn.implicitarg.ptr" || name == "llvm.amdgcn.queue.ptr";
}

bool unsafe(const Instruction &instruction) {
  if (laneInput(instruction))
    return false;
  if (auto *call = dyn_cast<CallBase>(&instruction))
    if (call->isConvergent())
      return true;
  return !isSafeToSpeculativelyExecute(&instruction);
}

bool semantic(const Instruction &instruction) {
  return !instruction.isTerminator() && !isa<DbgInfoIntrinsic>(instruction);
}

std::string operand(const Value &value, ModuleSlotTracker &slots) {
  std::string text;
  raw_string_ostream out(text);
  value.printAsOperand(out, false, slots);
  return text;
}

std::string digest(StringRef content) {
  SHA1 hash;
  hash.update(content);
  return toHex(hash.final(), /*LowerCase=*/true);
}

using Values = SmallVector<Value *, 8>;
struct Output {
  PHINode *phi;
  Value *left;
  Value *right;
};

SmallVector<Output, 8> outputs(const Region &region) {
  SmallVector<Output, 8> result;
  if (!region.isB2B())
    return result;
  auto *left = region.left.empty() ? region.split.getParent() : region.left.front();
  auto *right = region.right.empty() ? region.split.getParent() : region.right.front();
  for (auto &phi : region.join->phis())
    result.push_back({&phi, phi.getIncomingValueForBlock(left),
                           phi.getIncomingValueForBlock(right)});
  return result;
}

// Model a slice's inputs by first use. Constant expressions that refer to
// globals get expanded into the entry block, retaining their addressing math
// while making the underlying addresses explicit parameters.
struct Inputs {
  SmallPtrSet<const Instruction *, 32> local;
  SmallPtrSet<Value *, 16> seen;
  Values args;
  SmallVector<Function *, 8> callees;
  DenseMap<const Function *, Value *> builtins;
  SmallVector<std::pair<Value *, Value *>, 8> builtinAliases;
  SmallVector<ConstantExpr *, 8> expressions;
  std::string error;

  void scan(Value *value) {
    if (!seen.insert(value).second)
      return;
    if (auto *fn = dyn_cast<Function>(value)) {
      callees.push_back(fn);
      return;
    }
    if (auto *expr = dyn_cast<ConstantExpr>(value)) {
      size_t count = args.size() + expressions.size();
      for (auto &op : expr->operands())
        scan(op.get());
      if (count != args.size() + expressions.size() ||
          llvm::any_of(expr->operands(), [&](auto &op) {
            return llvm::is_contained(args, op.get()) ||
                   llvm::is_contained(expressions, op.get());
          }))
        expressions.push_back(expr);
      return;
    }
    if (auto *instruction = dyn_cast<Instruction>(value)) {
      if (local.count(instruction))
        return;
      if (laneInput(*instruction)) {
        auto *callee = cast<CallBase>(instruction)->getCalledFunction();
        auto inserted = builtins.try_emplace(callee, value);
        if (!inserted.second) {
          builtinAliases.push_back({value, inserted.first->second});
          return;
        }
      }
    }
    if (isa<BasicBlock>(value) || isa<BlockAddress>(value) ||
        isa<GlobalAlias>(value) || isa<GlobalIFunc>(value)) {
      error = "block address, alias or ifunc cannot be lifted";
      return;
    }
    if (auto *constant = dyn_cast<Constant>(value)) {
      if (!isa<GlobalVariable>(constant)) {
        // Standard operands here are scalars and vectors. Diagnose aggregate
        // references to globals instead of retaining cross-module operands.
        if (llvm::any_of(constant->operands(), [](auto &op) {
              return isa<GlobalValue, ConstantExpr, BlockAddress>(op.get());
            }))
          error = "aggregate constant contains a module reference";
        return;
      }
    }
    if (isa<MetadataAsValue, InlineAsm>(value))
      return;
    if (!value->getType()->isFirstClassType() || value->getType()->isTokenTy()) {
      error = "external operand has no parameter representation";
      return;
    }
    args.push_back(value);
  }
};

void copyFunctionAttributes(const Function &source, Function &target,
                            bool writesOutput) {
  AttrBuilder attrs(source.getAttributes().getFnAttributes());
  // The new signature has no meaning for source parameter/return indices.
  attrs.removeAttribute(Attribute::AllocSize);
  if (writesOutput) {
    attrs.removeAttribute(Attribute::ReadNone);
    attrs.removeAttribute(Attribute::ReadOnly);
    attrs.removeAttribute(Attribute::InaccessibleMemOnly);
    attrs.removeAttribute(Attribute::InaccessibleMemOrArgMemOnly);
    attrs.removeAttribute(Attribute::Speculatable);
  }
  target.addAttributes(AttributeList::FunctionIndex, attrs);
}

std::unique_ptr<Module> isolate(const Region &region, ArrayRef<Output> result,
                                std::string &error) {
  auto &source = *region.split.getFunction();
  auto &context = source.getContext();
  Inputs inputs;
  Blocks blocks = region.left;
  blocks.append(region.right.begin(), region.right.end());
  for (auto *block : blocks)
    for (auto &inst : *block)
      if (semantic(inst) && !laneInput(inst))
        inputs.local.insert(&inst);

  Value *condition = region.split.getCondition();
  // Even a literal condition is an input to the extracted function.
  inputs.seen.insert(condition);
  inputs.args.push_back(condition);
  for (auto *block : blocks)
    for (auto &inst : *block)
      if (inputs.local.count(&inst))
        for (auto &op : inst.operands())
          inputs.scan(op.get());
  for (const auto &output : result) {
    inputs.scan(output.left);
    inputs.scan(output.right);
  }
  if (!inputs.error.empty()) {
    error = std::move(inputs.error);
    return nullptr;
  }

  auto module = std::make_unique<Module>("dataflow-region", context);
  module->setTargetTriple(source.getParent()->getTargetTriple());
  module->setDataLayout(source.getParent()->getDataLayout());
  SmallVector<Type *, 16> types, outputTypes;
  for (auto *value : inputs.args)
    types.push_back(value->getType());
  for (const auto &output : result)
    outputTypes.push_back(output.phi->getType());
  Type *returnType = result.size() == 1 ? outputTypes.front() : Type::getVoidTy(context);
  Type *aggregate = nullptr;
  if (result.size() > 1) {
    bool uniform = llvm::all_of(outputTypes, [&](auto *ty) { return ty == outputTypes.front(); });
    aggregate = uniform ? static_cast<Type *>(ArrayType::get(outputTypes.front(), result.size()))
                        : static_cast<Type *>(StructType::get(context, outputTypes));
    types.push_back(PointerType::getUnqual(aggregate));
  }
  auto *function = Function::Create(FunctionType::get(returnType, types, false),
                                    GlobalValue::ExternalLinkage, "region", *module);
  copyFunctionAttributes(source, *function, aggregate != nullptr);
  ValueToValueMapTy mapping;
  for (auto *callee : inputs.callees) {
    auto *decl = Function::Create(callee->getFunctionType(), GlobalValue::ExternalLinkage,
                                 callee->getName(), *module);
    decl->setAttributes(callee->getAttributes());
    decl->setCallingConv(callee->getCallingConv());
    mapping[callee] = decl;
  }
  for (auto pair : llvm::zip(inputs.args, function->args())) {
    auto *input = std::get<0>(pair);
    if (input != condition || !isa<Constant>(input))
      mapping[input] = &std::get<1>(pair);
  }

  for (const auto &alias : inputs.builtinAliases)
    mapping[alias.first] = mapping.lookup(alias.second);

  // Keep the identity of lifted builtins without depending on source SSA names.
  for (unsigned index = 1; index < inputs.args.size(); ++index) {
    auto *inst = dyn_cast<Instruction>(inputs.args[index]);
    if (inst && laneInput(*inst)) {
      auto *name = MDString::get(context, cast<CallBase>(inst)->getCalledFunction()->getName());
      auto *slot = ConstantAsMetadata::get(ConstantInt::get(Type::getInt32Ty(context), index));
      module->getOrInsertNamedMetadata("dataflow.builtin.inputs")
          ->addOperand(MDNode::get(context, {slot, name}));
    }
  }
  for (unsigned side = 0; side < blocks.size(); ++side) {
    unsigned position = 0;
    for (const auto &inst : *blocks[side]) {
      if (!semantic(inst))
        continue;
      if (laneInput(inst)) {
        auto *name = MDString::get(context, cast<CallBase>(&inst)->getCalledFunction()->getName());
        auto *blockSlot = ConstantAsMetadata::get(ConstantInt::get(Type::getInt32Ty(context), side));
        auto *opSlot = ConstantAsMetadata::get(ConstantInt::get(Type::getInt32Ty(context), position));
        module->getOrInsertNamedMetadata("dataflow.builtin.operations")
            ->addOperand(MDNode::get(context, {blockSlot, opSlot, name}));
      }
      ++position;
    }
  }

  auto *entry = BasicBlock::Create(context, "", function);
  auto *left = region.left.empty() ? nullptr : BasicBlock::Create(context, "", function);
  auto *right = region.right.empty() ? nullptr : BasicBlock::Create(context, "", function);
  auto *join = BasicBlock::Create(context, "", function);
  mapping[region.split.getParent()] = entry;
  mapping[region.join] = join;
  if (left)
    mapping[region.left.front()] = left;
  if (right)
    mapping[region.right.front()] = right;
  for (auto *expr : inputs.expressions) {
    auto *inst = expr->getAsInstruction();
    RemapInstruction(inst, mapping, RF_IgnoreMissingLocals);
    entry->getInstList().push_back(inst);
    mapping[expr] = inst;
  }
  IRBuilder<> builder(entry);
  builder.CreateCondBr(function->getArg(0), left ? left : join, right ? right : join);
  SmallVector<Instruction *, 16> copies;
  for (auto *block : blocks) {
    auto *dest = cast<BasicBlock>(mapping.lookup(block));
    for (auto &inst : *block) {
      if (!inputs.local.count(&inst))
        continue;
      auto *copy = inst.clone();
      copy->setDebugLoc(DebugLoc());
      dest->getInstList().push_back(copy);
      mapping[&inst] = copy;
      copies.push_back(copy);
    }
    BranchInst::Create(join, dest);
  }
  for (auto *copy : copies)
    RemapInstruction(copy, mapping, RF_IgnoreMissingLocals);

  builder.SetInsertPoint(join);
  Values values;
  for (const auto &output : result) {
    auto *phi = builder.CreatePHI(output.phi->getType(), 2);
    auto l = MapValue(output.left, mapping, RF_IgnoreMissingLocals);
    auto r = MapValue(output.right, mapping, RF_IgnoreMissingLocals);
    phi->addIncoming(l, left ? left : entry);
    phi->addIncoming(r, right ? right : entry);
    values.push_back(phi);
  }
  if (aggregate) {
    auto *out = function->getArg(types.size() - 1);
    for (unsigned i = 0; i < values.size(); ++i) {
      auto *slot = builder.CreateInBoundsGEP(aggregate, out,
                          {builder.getInt32(0), builder.getInt32(i)});
      builder.CreateStore(values[i], slot);
    }
  }
  if (values.size() == 1)
    builder.CreateRet(values.front());
  else
    builder.CreateRetVoid();

  raw_string_ostream diagnostics(error);
  if (verifyModule(*module, &diagnostics))
    return nullptr;
  return module;
}

// Canonical operand numbers for non-B2B inventory entries. Keep printed
// modifiers, constants and types but discard spelling and numbering of local
// identifiers, which are encoded separately as def-use and block references.
std::string anonymousIR(StringRef line) {
  std::string result;
  for (size_t i = 0; i < line.size();) {
    char c = line[i++];
    if (c == '"') {
      result += c;
      while (i < line.size()) {
        char next = line[i++];
        result += next;
        if (next == '"')
          break;
      }
    } else if (c == '%' || c == '@') {
      result += c;
      if (i < line.size() && line[i] == '"') {
        ++i;
        while (i < line.size() && line[i++] != '"') {}
      } else {
        while (i < line.size() && (isAlnum(line[i]) || StringRef("-$._").contains(line[i])))
          ++i;
      }
    } else if (c == '!' && i < line.size() && isDigit(line[i])) {
      result += c;
      while (i < line.size() && isDigit(line[i]))
        ++i;
    } else if (c == '#' && i < line.size() && isDigit(line[i])) {
      while (i < line.size() && isDigit(line[i]))
        ++i;
    } else {
      result += c;
    }
  }
  return result;
}

// Type::print without a module may use an address for an unnamed identified
// struct. Number structs by first use and encode their bodies, including
// references back to recursive structs.
struct TypeEncoding {
  explicit TypeEncoding(raw_ostream &stream) : out(stream) {}
  raw_ostream &out;
  DenseMap<const StructType *, unsigned> structs;

  void write(Type *type) {
    if (auto *ptr = dyn_cast<PointerType>(type)) {
      out << "ptr" << ptr->getAddressSpace() << '(';
      write(ptr->getElementType());
      out << ')';
    } else if (auto *array = dyn_cast<ArrayType>(type)) {
      out << "array" << array->getNumElements() << '(';
      write(array->getElementType());
      out << ')';
    } else if (auto *vector = dyn_cast<VectorType>(type)) {
      auto count = vector->getElementCount();
      out << (count.isScalable() ? "scalable" : "vector") << count.getKnownMinValue() << '(';
      write(vector->getElementType());
      out << ')';
    } else if (auto *structure = dyn_cast<StructType>(type)) {
      auto entry = structs.try_emplace(structure, structs.size());
      out << "struct" << entry.first->second;
      if (!entry.second)
        return;
      if (structure->isOpaque()) {
        out << "(opaque)";
        return;
      }
      out << (structure->isPacked() ? "<(" : "(");
      for (auto *element : structure->elements()) {
        write(element);
        out << ',';
      }
      out << (structure->isPacked() ? ")>" : ")");
    } else if (auto *function = dyn_cast<FunctionType>(type)) {
      out << "fn(";
      write(function->getReturnType());
      for (auto *parameter : function->params()) {
        out << ',';
        write(parameter);
      }
      out << (function->isVarArg() ? ",...)" : ")");
    } else {
      type->print(out);
    }
  }
};

std::string structure(const Region &region, ModuleSlotTracker &slots) {
  std::string storage;
  raw_string_ostream out(storage);
  const auto &function = *region.split.getFunction();
  const auto &module = *function.getParent();
  out << region.kind << '\n' << module.getTargetTriple() << '\n'
      << module.getDataLayoutStr() << '\n' << region.extraPreds << '\n';
  out << function.getAttributes().getAsString(AttributeList::FunctionIndex);
  out << '\n';

  TypeEncoding types(out);
  DenseMap<const Value *, unsigned> ids;
  auto writeOperand = [&](const Value *value) {
    types.write(value->getType());
    out << ':';
    if (auto *constant = dyn_cast<Constant>(value)) {
      if (!isa<GlobalVariable>(constant)) {
        constant->printAsOperand(out, false, slots);
        out << ' ';
        return;
      }
    }
    auto item = ids.try_emplace(value, ids.size());
    out << 'v' << item.first->second << ' ';
  };
  auto writeInstruction = [&](const Instruction &instruction) {
    std::string text;
    raw_string_ostream line(text);
    instruction.print(line, slots);
    out << anonymousIR(line.str()) << " | ";
    if (!instruction.getType()->isVoidTy())
      writeOperand(&instruction);
    for (auto &op : instruction.operands())
      writeOperand(op.get());
    if (auto *phi = dyn_cast<PHINode>(&instruction))
      for (auto *block : phi->blocks())
        writeOperand(block);
    if (auto *call = dyn_cast<CallBase>(&instruction)) {
      auto attrs = call->getAttributes();
      out << attrs.getAsString(AttributeList::FunctionIndex) << ' ';
      for (unsigned index = 0; index <= call->arg_size(); ++index)
        out << index << '=' << attrs.getAsString(index) << ' ';
    }
    out << '\n';
  };

  writeOperand(region.split.getParent());
  if (region.join)
    writeOperand(region.join);
  writeInstruction(region.split);
  for (const auto &side : {ArrayRef<BasicBlock *>(region.left), ArrayRef<BasicBlock *>(region.right)}) {
    out << "side\n";
    for (const auto *block : side) {
      writeOperand(block);
      out << '\n';
      for (const auto &instruction : *block)
        if (!isa<DbgInfoIntrinsic>(instruction))
          writeInstruction(instruction);
    }
  }
  if (region.join) {
    SmallPtrSet<const BasicBlock *, 16> local;
    local.insert(region.split.getParent());
    local.insert(region.left.begin(), region.left.end());
    local.insert(region.right.begin(), region.right.end());
    for (const auto &phi : region.join->phis()) {
      types.write(phi.getType());
      out << ' ';
      for (unsigned i = 0; i < phi.getNumIncomingValues(); ++i)
        if (local.count(phi.getIncomingBlock(i))) {
          writeOperand(phi.getIncomingBlock(i));
          writeOperand(phi.getIncomingValue(i));
        }
      out << '\n';
    }
  }
  return storage;
}

struct Stats {
  unsigned left = 0, right = 0, loads = 0, stores = 0, common = 0;
  bool convergent = false, unportable = false;
  json::Value folds = nullptr;
  std::string foldReason = "outside B2B";
  unsigned numOutputs = 0;
};

Stats measure(const Region &region, ArrayRef<Output> result, const json::Object &costs) {
  Stats stats;
  std::map<unsigned, unsigned> leftOpcodes;
  SmallPtrSet<const Instruction *, 32> visited;
  std::set<std::string> missing;
  int64_t charge = 0;
  for (bool left : {true, false}) {
    for (auto *block : left ? region.left : region.right) {
      for (auto &inst : *block) {
        if (!semantic(inst))
          continue;
        ++(left ? stats.left : stats.right);
        auto &count = leftOpcodes[inst.getOpcode()];
        if (left)
          ++count;
        else if (count) {
          --count;
          ++stats.common;
        }
        if (!visited.insert(&inst).second)
          continue;
        stats.loads += isa<LoadInst>(inst);
        stats.stores += isa<StoreInst>(inst);
        if (auto *call = dyn_cast<CallBase>(&inst))
          stats.convergent |= call->isConvergent();
        stats.unportable |= unsafe(inst);
        if (auto cost = costs.getInteger(inst.getOpcodeName()))
          charge += *cost;
        else
          missing.insert(inst.getOpcodeName());
      }
    }
  }
  if (region.join)
    for (const auto &phi : region.join->phis()) {
      (void)phi;
      ++stats.numOutputs;
    }
  if (!region.isB2B())
    return stats;

  stats.numOutputs = result.size();
  int64_t maxPhis = *costs.getInteger("fold_max_phis");
  int64_t threshold = *costs.getInteger("fold_threshold");
  auto isBinaryExceptNot = [](const Value *value) {
    const auto *bin = dyn_cast<BinaryOperator>(value);
    return bin && !PatternMatch::match(bin, PatternMatch::m_Not(PatternMatch::m_Value()));
  };
  bool badI1 = llvm::any_of(result, [&](const Output &output) {
    return output.phi->getType()->isIntegerTy(1) &&
           (isBinaryExceptNot(output.left) || isBinaryExceptNot(output.right));
  });
  // LLVM's join-arity restriction is on PHI nodes, not incoming edges.
  if (stats.unportable)
    stats.foldReason = "operation is unsafe to speculate";
  else if (stats.numOutputs > static_cast<unsigned>(maxPhis))
    stats.foldReason = "too many join PHIs";
  else if (badI1)
    stats.foldReason = "binary incoming value to i1 PHI";
  else if (visited.size() > 1 && charge > threshold)
    stats.foldReason = "known size-and-latency cost already exceeds threshold";
  else if (!missing.empty()) {
    stats.foldReason = "missing c_SL for";
    for (const auto &opcode : missing)
      stats.foldReason += " " + opcode;
    return stats;
  } else {
    stats.foldReason = charge > threshold ? "single-operation budget exception" : "within budget";
    stats.folds = true;
    return stats;
  }
  stats.folds = false;
  return stats;
}

json::Object graph(const Region &region) {
  DenseMap<const BasicBlock *, unsigned> ids;
  auto id = [&](const BasicBlock *block) {
    return ids.try_emplace(block, ids.size()).first->second;
  };
  auto *split = region.split.getParent();
  id(split);
  unsigned join = region.join ? id(region.join) : 0;
  json::Array left, right, edges;
  for (auto *block : region.left)
    left.push_back(id(block));
  for (auto *block : region.right)
    right.push_back(id(block));
  SmallPtrSet<const BasicBlock *, 16> seen;
  auto addEdges = [&](const BasicBlock *block) {
    if (!seen.insert(block).second)
      return;
    for (auto *successor : successors(block))
      edges.push_back(json::Array{id(block), id(successor)});
  };
  addEdges(split);
  for (auto *block : region.left)
    addEdges(block);
  for (auto *block : region.right)
    addEdges(block);
  return json::Object{{"split", 0}, {"join", region.join ? json::Value(join) : json::Value(nullptr)},
          {"left", std::move(left)}, {"right", std::move(right)}, {"edges", std::move(edges)}};
}

} // namespace

int main(int argc, char **argv) {
  if (argc != 4) {
    errs() << "usage: extract_regions INPUT.ll COST_TABLE.json OUTPUT_DIRECTORY\n";
    return 2;
  }
  LLVMContext context;
  SMDiagnostic diag;
  auto module = parseIRFile(argv[1], diag, context);
  if (!module) {
    diag.print(argv[0], errs());
    return 1;
  }
  if (verifyModule(*module, &errs()))
    return 1;

  auto costFile = MemoryBuffer::getFile(argv[2]);
  if (!costFile) {
    errs() << costFile.getError().message() << '\n';
    return 1;
  }
  auto costTable = json::parse(costFile.get()->getBuffer());
  if (!costTable) {
    errs() << toString(costTable.takeError()) << '\n';
    return 1;
  }
  auto *root = costTable->getAsObject();
  auto *op = root ? root->getObject("op") : nullptr;
  if (!op || !root->getInteger("fold_max_phis") || !root->getInteger("fold_threshold")) {
    errs() << "invalid cost table\n";
    return 1;
  }
  json::Object costs;
  for (const auto &item : *op) {
    auto value = item.second.getAsInteger();
    if (!value || *value < 0) {
      errs() << "invalid opcode cost\n";
      return 1;
    }
    costs[item.first] = *value;
  }
  costs["fold_max_phis"] = *root->getInteger("fold_max_phis");
  costs["fold_threshold"] = *root->getInteger("fold_threshold");
  if (auto error = sys::fs::create_directories(argv[3])) {
    errs() << error.message() << '\n';
    return 1;
  }

  ModuleSlotTracker slots(module.get());
  for (auto &function : *module) {
    if (function.isDeclaration())
      continue;
    slots.incorporateFunction(function);
    PostDominatorTree postdom(function);
    for (auto &block : function) {
      auto *branch = dyn_cast<BranchInst>(block.getTerminator());
      if (!branch || !branch->isConditional())
        continue;
      auto region = classify(*branch, postdom);
      auto result = outputs(region);
      auto stats = measure(region, result, costs);
      std::string text, error, id;
      if (region.isB2B()) {
        if (auto out = isolate(region, result, error)) {
          raw_string_ostream stream(text);
          out->print(stream, nullptr);
        }
      }
      id = digest(text.empty() ? structure(region, slots) : region.kind.str() + "\n" + text);
      if (!text.empty()) {
        SmallString<256> filename(argv[3]);
        sys::path::append(filename, id + ".ll");
        if (!sys::fs::exists(filename)) {
          std::error_code ec;
          raw_fd_ostream file(filename, ec);
          if (ec) {
            errs() << ec.message() << '\n';
            return 1;
          }
          file << text;
        }
      }
      json::Object occurrence{
          {"function", function.hasName() ? function.getName().str() : operand(function, slots)},
          {"block", operand(block, slots)},
          {"join", region.join ? json::Value(operand(*region.join, slots)) : json::Value(nullptr)},
          {"join_has_other_preds", region.extraPreds},
          {"condition_source", fusion::anchor_condition::classifySource(branch)}};
      json::Object entry{
          {"id", id}, {"kind", region.kind},
          {"left_ops", stats.left}, {"right_ops", stats.right},
          {"structure", graph(region)},
          {"num_outputs", stats.numOutputs}, {"loads", stats.loads},
          {"stores", stats.stores}, {"convergent", stats.convergent},
          {"unsafe_to_speculate", stats.unportable}, {"common_opcodes", stats.common},
          {"size_bucket", stats.left + stats.right <= 10 ? "small" :
                          stats.left + stats.right <= 50 ? "medium" : "large"},
          {"original_folds", std::move(stats.folds)}, {"fold_reason", stats.foldReason},
          {"occurrence", std::move(occurrence)}};
      if (!text.empty())
        entry["ir"] = id + ".ll";
      if (!error.empty())
        entry["extraction_error"] = error;
      outs() << json::Value(std::move(entry)) << '\n';
    }
  }
}
