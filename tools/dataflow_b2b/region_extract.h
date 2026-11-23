#pragma once

#include "../anchor_condition.h"

#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/Analysis/PostDominators.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/Module.h"
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

namespace dataflow::extraction {
using namespace llvm;
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

inline BasicBlock *singleArm(BasicBlock *entry, BasicBlock *split) {
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

inline Arm walkArm(BasicBlock *entry, BasicBlock *split, BasicBlock *join) {
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

inline bool isSingleEntry(const Arm &arm, BasicBlock *split, BasicBlock *entry) {
  for (auto *block : arm.blocks)
    for (auto *pred : predecessors(block))
      if (!arm.members.count(pred) && !(pred == split && block == entry))
        return false;
  return true;
}

inline Region classifyB2B(BranchInst &branch) {
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
  }
  return region;
}

inline Region classify(BranchInst &branch, PostDominatorTree &postdom) {
  auto region = classifyB2B(branch);
  if (region.isB2B())
    return region;
  auto *split = branch.getParent();
  auto *left = branch.getSuccessor(0);
  auto *right = branch.getSuccessor(1);
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

inline bool laneInput(const Instruction &instruction) {
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

inline bool semantic(const Instruction &instruction) {
  return !instruction.isTerminator() && !isa<DbgInfoIntrinsic>(instruction);
}

inline std::string operand(const Value &value, ModuleSlotTracker &slots) {
  std::string text;
  raw_string_ostream out(text);
  value.printAsOperand(out, false, slots);
  return text;
}

inline std::string digest(StringRef content) {
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

inline SmallVector<Output, 8> outputs(const Region &region) {
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

inline void copyFunctionAttributes(const Function &source, Function &target,
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

inline std::unique_ptr<Module> isolate(const Region &region, ArrayRef<Output> result,
                                std::string &error, Values *arguments = nullptr) {
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
  if (arguments)
    *arguments = std::move(inputs.args);
  return module;
}

} // namespace dataflow::extraction
