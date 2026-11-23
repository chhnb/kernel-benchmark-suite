#include "evaluate_cost.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "real_cost.h"
#include "schedule_dp.h"
#include "fold_oracle.h"

#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/Local.h"
#include <chrono>
#include <functional>
#include <iostream>
#include <vector>

using namespace llvm;

namespace {
using Clock = std::chrono::steady_clock;
using Insts = SmallVector<const Instruction *, 16>;
using Cost = std::array<int64_t, 3>;

struct Diamond {
  const BranchInst *branch = nullptr;
  const BasicBlock *left = nullptr, *right = nullptr, *join = nullptr;
  Insts ops[2];
  DenseMap<const Instruction *, const Instruction *> effectBefore;
};

bool readDiamond(const Function &fn, Diamond &out) {
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
StringRef name(Recipe recipe) {
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

bool compatible(const Instruction &a, const Instruction &b, Recipe recipe) {
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

struct Candidate {
  std::unique_ptr<Module> module;
  json::Array pairs;
  bool crossed = false, commute = false, cmpSwap = false, speculate = false;
  bool sharedSelect = false, guardCluster = false, speculateSelect = false;
  bool pairedMemory = false;
  std::set<std::string> recipes;
};

Candidate emit(const Module &source, const Function &func, const Diamond &shape,
               ArrayRef<Node> nodes, const dataflow::Schedule &schedule, bool mergeExit) {
  Candidate result;
  ValueToValueMapTy map;
  auto module = CloneModule(source, map);
  auto *branch = cast<BranchInst>(map.lookup(shape.branch));
  auto *join = cast<BasicBlock>(map.lookup(shape.join));
  auto *condition = branch->getCondition();
  auto *target = cast<Function>(map.lookup(&func));
  IRBuilder<> builder(branch);
  BasicBlock *tail = join;
  Instruction *terminator = branch;
  struct Segment {
    BasicBlock *arms[2];
    BasicBlock *before;
    BasicBlock *after;
    unsigned operations[2];
  };
  struct GuardedValue {
    unsigned segment;
    unsigned side;
  };
  SmallVector<Segment, 8> segments;
  DenseMap<Value *, GuardedValue> guarded;
  DenseMap<Value *, unsigned> available;
  DenseSet<Value *> tainted;
  DenseMap<const Value *, unsigned> order;
  SmallVector<Value *, 16> generatedSelects;
  DenseMap<std::pair<Value *, Value *>, Value *> choices;
  bool speculativeSides[2] = {false, false};
  for (unsigned i = 0; i < shape.ops[1].size(); ++i)
    order[shape.ops[1][i]] = i;

  auto guardPhi = [&](unsigned segment, Value *left, Value *right) -> Value * {
    auto key = std::make_pair(left, right);
    if (auto found = choices.find(key); found != choices.end())
      return found->second;
    auto &guard = segments[segment - 1];
    auto *phi = PHINode::Create(left->getType(), 2, "", &*guard.after->getFirstInsertionPt());
    phi->addIncoming(left, guard.arms[0] ? guard.arms[0] : guard.before);
    phi->addIncoming(right, guard.arms[1] ? guard.arms[1] : guard.before);
    choices[key] = phi;
    available[phi] = segment;
    return phi;
  };
  auto escape = [&](Value *value) -> Value * {
    auto found = guarded.find(value);
    if (found == guarded.end())
      return value;
    auto placement = found->second;
    auto *padding = PoisonValue::get(value->getType());
    auto *phi = placement.side == 0 ? guardPhi(placement.segment, value, padding)
                                    : guardPhi(placement.segment, padding, value);
    tainted.insert(phi);
    return phi;
  };
  auto merge = [&](Value *left, Value *right) -> Value * {
    if (left == right)
      return left;
    if (auto *sel = dyn_cast<SelectInst>(left))
      if (sel->getCondition() == condition)
        left = sel->getTrueValue();
    if (auto *sel = dyn_cast<SelectInst>(right))
      if (sel->getCondition() == condition)
        right = sel->getFalseValue();
    if (left == right)
      return left;
    auto lGuard = guarded.find(left), rGuard = guarded.find(right);
    if (lGuard != guarded.end() && rGuard != guarded.end() &&
        lGuard->second.segment == rGuard->second.segment)
      return guardPhi(lGuard->second.segment, left, right);
    if (lGuard != guarded.end() && rGuard != guarded.end()) {
      if (lGuard->second.segment < rGuard->second.segment)
        left = escape(left);
      else
        right = escape(right);
    }
    if (auto found = guarded.find(left); found != guarded.end())
      if (available.lookup(right) < found->second.segment)
        return guardPhi(found->second.segment, left, right);
    if (auto found = guarded.find(right); found != guarded.end())
      if (available.lookup(left) < found->second.segment)
        return guardPhi(found->second.segment, left, right);
    left = escape(left);
    right = escape(right);
    auto key = std::make_pair(left, right);
    if (auto found = choices.find(key); found != choices.end())
      return found->second;

    auto notCondition = [&] {
      auto *inst = cast<Instruction>(builder.CreateNot(condition));
      inst->setMetadata("dataflow.folded.condition", MDNode::get(module->getContext(), {}));
      available[inst] = segments.size();
      return inst;
    };
    Value *value = nullptr;
    auto *l = dyn_cast<ConstantInt>(left), *r = dyn_cast<ConstantInt>(right);
    if (l && r && left->getType()->isIntegerTy(1)) {
      value = l->isOne() ? condition : notCondition();
    } else if (l && r && l->isOne() && r->isZero()) {
      value = builder.CreateZExt(condition, left->getType());
    } else if (l && r && l->isZero() && r->isOne()) {
      value = builder.CreateZExt(notCondition(), left->getType());
    } else {
      value = builder.CreateSelect(condition, left, right);
      if (isa<SelectInst>(value))
        generatedSelects.push_back(value);
    }
    if (auto *inst = dyn_cast<Instruction>(value))
      if (inst->getParent() == terminator->getParent())
        available[value] = segments.size();
    choices[key] = value;
    return value;
  };
  auto mapped = [&](const Value *value) -> Value * {
    return MapValue(value, map, RF_IgnoreMissingLocals);
  };
  auto clone = [&](const Instruction &inst) {
    auto *copy = inst.clone();
    copy->dropUnknownNonDebugMetadata();
    copy->setDebugLoc(DebugLoc());
    RemapInstruction(copy, map, RF_IgnoreMissingLocals);
    return copy;
  };

  auto finishGuard = [&] {
    auto &guard = segments.back();
    auto *end = guard.before->getTerminator();
    BranchInst::Create(guard.arms[0] ? guard.arms[0] : guard.after,
                       guard.arms[1] ? guard.arms[1] : guard.after, condition, end);
    end->eraseFromParent();
    result.guardCluster |= guard.operations[0] > 1 || guard.operations[1] > 1;
    terminator = guard.after->getTerminator();
    builder.SetInsertPoint(terminator);
  };

  bool activeGuard = false;
  for (const auto &step : schedule.steps) {
    const auto &node = nodes[step.node];
    const auto &base = *(node.left ? node.left : node.right);
    if (activeGuard && (step.opensGuard || node.recipe != Recipe::R6)) {
      finishGuard();
      activeGuard = false;
    }
    if (step.opensGuard) {
      auto *continuation = BasicBlock::Create(module->getContext(), "", target, tail);
      new UnreachableInst(module->getContext(), continuation);
      segments.push_back({{nullptr, nullptr}, terminator->getParent(), continuation, {0, 0}});
      activeGuard = true;
    }
    auto *copy = clone(base);
    if (node.recipe == Recipe::R6) {
      auto &guard = segments.back();
      unsigned side = node.right != nullptr;
      if (!guard.arms[side]) {
        guard.arms[side] = BasicBlock::Create(module->getContext(), "", target, guard.after);
        BranchInst::Create(guard.after, guard.arms[side]);
      }
      for (unsigned i = 0; i < copy->getNumOperands(); ++i) {
        auto *op = copy->getOperand(i);
        auto found = guarded.find(op);
        if (found != guarded.end() && found->second.segment != segments.size())
          copy->setOperand(i, escape(op));
      }
      copy->insertBefore(guard.arms[side]->getTerminator());
      ++guard.operations[side];
      guarded[copy] = {static_cast<unsigned>(segments.size()), side};
    } else if (node.left && node.right) {
      copy->andIRFlags(node.right);
      SmallVector<std::pair<unsigned, MDNode *>, 8> metadata;
      copy->getAllMetadataOtherThanDebugLoc(metadata);
      for (const auto &item : metadata)
        if (node.left->getMetadata(item.first) != node.right->getMetadata(item.first))
          copy->setMetadata(item.first, nullptr);
      if (auto *load = dyn_cast<LoadInst>(copy))
        load->setAlignment(std::min(load->getAlign(), cast<LoadInst>(node.right)->getAlign()));
      if (auto *store = dyn_cast<StoreInst>(copy))
        store->setAlignment(std::min(store->getAlign(), cast<StoreInst>(node.right)->getAlign()));
      for (unsigned i = 0; i < copy->getNumOperands(); ++i) {
        unsigned r = node.recipe == Recipe::R1 ? i : 1 - i;
        copy->setOperand(i, merge(mapped(node.left->getOperand(i)),
                                  mapped(node.right->getOperand(r))));
      }
      builder.Insert(copy);
      available[copy] = segments.size();
    } else {
      bool hasTaint = false;
      for (unsigned i = 0; i < copy->getNumOperands(); ++i) {
        auto *operand = escape(copy->getOperand(i));
        copy->setOperand(i, operand);
        hasTaint |= tainted.count(operand);
      }
      // An escaped operand may be poison on the opposite path. Operations
      // which can observe poison immediately cannot use that speculation.
      bool observesPoison = isa<LoadInst>(base) && hasTaint;
      if (const auto *call = dyn_cast<CallBase>(copy))
        for (unsigned i = 0; i < call->arg_size(); ++i)
          if (tainted.count(call->getArgOperand(i)) &&
              (call->paramHasAttr(i, Attribute::NoUndef) ||
               call->paramHasAttr(i, Attribute::Dereferenceable) ||
               call->paramHasAttr(i, Attribute::DereferenceableOrNull) ||
               call->getArgOperand(i)->getType()->isPointerTy()))
            observesPoison = true;
      if ((base.getOpcode() == Instruction::SDiv || base.getOpcode() == Instruction::UDiv ||
           base.getOpcode() == Instruction::SRem || base.getOpcode() == Instruction::URem) &&
          tainted.count(copy->getOperand(1)))
        observesPoison = true;
      if (observesPoison) {
        copy->deleteValue();
        return result;
      }
      builder.Insert(copy);
      available[copy] = segments.size();
      if (hasTaint)
        tainted.insert(copy);
    }
    if (node.left)
      map[node.left] = copy;
    if (node.right)
      map[node.right] = copy;
  }
  if (activeGuard)
    finishGuard();
  unsigned last = 0;
  bool hasPair = false;
  for (const auto &node : nodes) {
    result.recipes.insert(name(node.recipe).str());
    if (!node.left || !node.right) {
      if (node.recipe == Recipe::R5) {
        result.speculate = true;
        speculativeSides[node.right != nullptr] = true;
      }
      continue;
    }
    unsigned index = order.lookup(node.right);
    result.crossed |= hasPair && index < last;
    last = index;
    hasPair = true;
    result.pairedMemory |= isa<LoadInst, StoreInst>(node.left);
    result.commute |= node.recipe == Recipe::R2;
    result.cmpSwap |= node.recipe == Recipe::R3;
    result.pairs.push_back(json::Object{
        {"left", node.left->getName()}, {"right", node.right->getName()},
        {"left_index", static_cast<unsigned>(std::distance(shape.ops[0].begin(),
                                    llvm::find(shape.ops[0], node.left)))},
        {"right_index", index}, {"recipe", name(node.recipe)}});
  }
  SmallVector<PHINode *, 8> phis;
  for (const auto &phi : shape.join->phis()) {
    const auto *l = phi.getIncomingValueForBlock(shape.left);
    const auto *r = phi.getIncomingValueForBlock(shape.right);
    auto *copy = cast<PHINode>(map.lookup(&phi));
    auto *lv = mapped(l);
    auto *rv = mapped(r);
    auto *joint = merge(lv, rv);
    result.speculateSelect |= speculativeSides[0] && speculativeSides[1] && lv != rv &&
                              isa<SelectInst>(joint);
    copy->replaceAllUsesWith(joint);
    phis.push_back(copy);
  }
  for (auto *phi : phis)
    phi->eraseFromParent();
  BranchInst::Create(tail, terminator);
  terminator->eraseFromParent();
  SmallVector<BasicBlock *, 2> dead;
  for (auto *block : {shape.left, shape.right})
    if (block != shape.branch->getParent())
      dead.push_back(cast<BasicBlock>(map.lookup(block)));
  for (auto *block : dead)
    block->dropAllReferences();
  for (auto *block : dead)
    block->eraseFromParent();
  if (mergeExit)
    MergeBlockIntoPredecessor(tail);

  // Eliminate newly dead operations and selectors after folding.
  // Process the exit first so deleting unused selectors also releases their
  // input computations in the entry and guarded blocks.
  for (auto &block : llvm::reverse(*target))
    for (auto it = block.rbegin(), end = block.rend(); it != end;) {
      auto &inst = *it++;
      if (isInstructionTriviallyDead(&inst))
        inst.eraseFromParent();
    }
  for (const auto &block : *target)
    for (const auto &inst : block)
      if (llvm::is_contained(generatedSelects, &inst) && inst.getNumUses() > 1)
        result.sharedSelect = true;
  result.module = std::move(module);
  return result;
}

using ValuePair = std::pair<const Value *, const Value *>;

struct Pairing {
  SmallVector<Node, 16> nodes;
  unsigned produced, demanded, missing;
  int64_t lowerBound;
  Optional<int64_t> bestD;
};

SmallVector<unsigned, 16> dependencies(const Diamond &shape, ArrayRef<Node> nodes) {
  DenseMap<const Value *, unsigned> uses;
  for (unsigned i = 0; i < nodes.size(); ++i) {
    if (nodes[i].left) uses[nodes[i].left] = 1u << i;
    if (nodes[i].right) uses[nodes[i].right] = 1u << i;
  }
  SmallVector<unsigned, 16> graph(nodes.size(), 0);
  for (unsigned i = 0; i < nodes.size(); ++i)
    for (auto *inst : {nodes[i].left, nodes[i].right}) {
      if (!inst)
        continue;
      graph[i] |= uses.lookup(shape.effectBefore.lookup(inst));
      for (const auto &operand : inst->operands())
        graph[i] |= uses.lookup(operand.get());
    }
  return graph;
}

bool acyclic(ArrayRef<unsigned> graph) {
  unsigned done = 0;
  const unsigned full = (1u << graph.size()) - 1;
  while (done != full) {
    auto before = done;
    for (unsigned i = 0; i < graph.size(); ++i)
      if ((graph[i] & ~done) == 0)
        done |= 1u << i;
    if (before == done)
      return false;
  }
  return true;
}

struct FrontEntry {
  Cost cost;
  std::string ir;
  json::Object report;
};

bool dominates(const Cost &a, const Cost &b) {
  return a != b && a[0] <= b[0] && a[1] <= b[1] && a[2] <= b[2];
}

struct Search {
  const Module &module;
  const Function &func;
  const json::Object &costs;
  Diamond shape;
  Clock::time_point start = Clock::now();
  uint64_t candidates = 0, verified = 0;
  std::vector<FrontEntry> front;
  SmallVector<Node, 16> nodes;
  SmallPtrSet<const Instruction *, 16> usedRight;
  std::string stop;
  const dataflow::SizeLatency *quotes = nullptr;
  const dataflow::SizeLatency *oracleQuotes = nullptr;
  std::vector<Pairing> pairings;
  Pairing *current = nullptr;
  unsigned cyclic = 0, oracleCandidates = 0, oracleGuards = 0;
  unsigned rejectedFold = 0, unsupportedGeneration = 0, dpMismatches = 0;
  unsigned selectedGuards = 0;
  int64_t selectedControl = 0, splitCost = 0, armCost = 0;
  dataflow::QuoteProvider throughput;
  bool completed = false;
  StringRef outputDirectory;

  Search(const Module &m, const Function &f, const json::Object &table)
      : module(m), func(f), costs(table) {}

  bool speculate(const Instruction &inst) const {
    return dataflow::speculationFailure(inst, costs).empty();
  }

  void add(Module &input, bool original, Candidate *candidate = nullptr) {
    auto *function = input.getFunction(func.getName());
    auto result = dataflow::evaluate(*function, costs, original, quotes, true, false, throughput);
    if (!result) {
      auto reason = toString(result.takeError());
      if (!original && StringRef(reason).contains("must be speculated by SimplifyCFG"))
        ++rejectedFold;
      else
        stop = std::move(reason);
      return;
    }
    if (candidate && (result->branches != selectedGuards ||
                      result->divergenceCosts["control"] != selectedControl)) {
      ++dpMismatches;
      return;
    }
    ++verified;
    const auto cost = result->total;
    if (current && (!current->bestD || cost[0] < *current->bestD))
      current->bestD = cost[0];
    if (llvm::any_of(front, [&](const auto &other) {
          return dominates(other.cost, cost) || other.cost == cost;
        }))
      return;
    auto end = std::remove_if(front.begin(), front.end(), [&](const auto &old) {
      return dominates(cost, old.cost);
    });
    front.erase(end, front.end());
    std::string text;
    raw_string_ostream stream(text);
    input.print(stream, nullptr);
    auto report = result->json();
    report.erase("operations");
    report["original"] = original;
    if (candidate) {
      report["dp_guard_branches"] = selectedGuards;
      report["dp_control_cost"] = selectedControl;
      report["pairs"] = std::move(candidate->pairs);
      report["features"] = json::Object{{"crossed", candidate->crossed},
        {"commute", candidate->commute}, {"cmp_swap", candidate->cmpSwap},
        {"shared_select", candidate->sharedSelect}, {"guard_cluster", candidate->guardCluster},
        {"speculate_then_select", candidate->speculateSelect},
        {"speculated_operations", candidate->speculate}, {"paired_memory", candidate->pairedMemory}};
      report["pairing"] = json::Object{{"produced", current->produced}, {"demanded", current->demanded},
                                       {"missing", current->missing}, {"lower_bound", current->lowerBound}};
      json::Array recipes;
      for (const auto &recipe : candidate->recipes)
        recipes.push_back(recipe);
      report["recipes"] = std::move(recipes);
    }
    front.push_back({cost, std::move(text), std::move(report)});
  }

  void generate(unsigned index) {
    if (!stop.empty())
      return;
    if (index < nodes.size()) {
      auto &node = nodes[index];
      if (!node.left || !node.right) {
        const auto *inst = node.left ? node.left : node.right;
        if (speculate(*inst)) {
          node.recipe = Recipe::R5;
          generate(index + 1);
        }
        node.recipe = Recipe::R6;
      }
      generate(index + 1);
      return;
    }
    if (candidates == 10000000 || Clock::now() - start >= std::chrono::minutes(10)) {
      stop = "enumeration limit";
      return;
    }
    ++candidates;
    SmallVector<dataflow::Lane, 16> lanes;
    for (const auto &node : nodes)
      lanes.push_back(node.recipe != Recipe::R6 ? dataflow::Lane::Common :
                      node.left ? dataflow::Lane::Left : dataflow::Lane::Right);
    auto schedule = dataflow::minimumGuards(dependencies(shape, nodes), lanes,
                                             splitCost, armCost);
    selectedGuards = schedule.branches;
    selectedControl = schedule.controlCost;
    auto result = emit(module, func, shape, nodes, schedule, bool(throughput));
    if (!result.module) {
      ++unsupportedGeneration;
      return;
    }
    if (verifyModule(*result.module, &errs())) {
      stop = "generated candidate failed LLVM12 verifier";
      return;
    }
    bool guarded = result.recipes.count("R6");
    if (guarded) {
      if (oracleQuotes) {
        auto checked = CloneModule(*result.module);
        json::Array guards;
        bool agrees = dataflow::oracle::check(*checked->getFunction(func.getName()), costs, *oracleQuotes, guards);
        ++oracleCandidates;
        oracleGuards += guards.size();
        if (!agrees || guards.empty()) {
          SmallString<256> path(outputDirectory);
          sys::path::append(path, "fold-oracle-mismatch.ll");
          std::error_code error;
          raw_fd_ostream out(path, error);
          if (!error)
            result.module->print(out, nullptr);
          std::string detail;
          raw_string_ostream stream(detail);
          stream << json::Value(std::move(guards));
          stop = "Fold oracle disagreement: " + stream.str();
          return;
        }
      }

    }
    add(*result.module, false, &result);
  }

  void recordPairing() {
    SmallVector<Node, 16> full(nodes.begin(), nodes.end());
    for (auto *right : shape.ops[1])
      if (!usedRight.count(right))
        full.push_back({nullptr, right, Recipe::R6});
    if (!acyclic(dependencies(shape, full))) {
      ++cyclic;
      return;
    }
    DenseSet<ValuePair> produced, demanded;
    int64_t lower = 0;
    auto demand = [&](const Value *l, const Value *r) {
      demanded.insert({l, r});
      if (l == r)
        produced.insert({l, l});
    };
    SmallPtrSet<const Value *, 32> local;
    for (const auto &side : shape.ops)
      local.insert(side.begin(), side.end());
    auto keepEntry = [&](const Value *value) {
      if (!local.count(value))
        produced.insert({value, value});
    };
    keepEntry(shape.branch->getCondition());
    for (const auto &argument : func.args())
      keepEntry(&argument);
    for (const auto &side : shape.ops)
      for (const auto *inst : side)
        for (const auto &operand : inst->operands())
          keepEntry(operand.get());
    for (const auto &phi : shape.join->phis()) {
      keepEntry(phi.getIncomingValueForBlock(shape.left));
      keepEntry(phi.getIncomingValueForBlock(shape.right));
      demand(phi.getIncomingValueForBlock(shape.left),
             phi.getIncomingValueForBlock(shape.right));
    }
    for (const auto &node : full) {
      const auto &operation = *(node.left ? node.left : node.right);
      if (!throughput)
        lower += dataflow::costOf(operation, costs).getValueOr(0);
      if (!node.left || !node.right)
        continue;
      if (!node.left->getType()->isVoidTy())
        produced.insert({node.left, node.right});
      for (unsigned i = 0; i < node.left->getNumOperands(); ++i)
        demand(node.left->getOperand(i), node.right->getOperand(node.recipe == Recipe::R1 ? i : 1-i));
    }
    unsigned missing = llvm::count_if(demanded, [&](const auto &pair) { return !produced.count(pair); });
    // A missing pair may fold free or be implemented by an existing join.
    // The lower bound excludes both its charge and all guard/escape charges.
    pairings.push_back({std::move(full), static_cast<unsigned>(produced.size()),
                        static_cast<unsigned>(demanded.size()), missing, lower, None});
  }

  void enumeratePairings(unsigned index) {
    if (!stop.empty())
      return;
    if (pairings.size() >= 10000000 || Clock::now() - start >= std::chrono::minutes(10)) {
      stop = "pairing enumeration limit";
      return;
    }
    if (index == shape.ops[0].size()) {
      recordPairing();
      return;
    }
    auto *left = shape.ops[0][index];
    nodes.push_back({left, nullptr, Recipe::R6});
    enumeratePairings(index+1);
    for (auto *right : shape.ops[1]) {
      if (usedRight.count(right))
        continue;
      for (auto recipe : {Recipe::R1, Recipe::R2, Recipe::R3}) {
        if (!compatible(*left, *right, recipe))
          continue;
        usedRight.insert(right);
        nodes.back() = {left, right, recipe};
        enumeratePairings(index+1);
        usedRight.erase(right);
      }
    }
    nodes.pop_back();
  }

  void search() {
    enumeratePairings(0);
    llvm::stable_sort(pairings, [](const Pairing &a, const Pairing &b) {
      return a.lowerBound < b.lowerBound;
    });
    for (auto &plan : pairings) {
      if (!stop.empty())
        break;
      current = &plan;
      nodes = plan.nodes;
      generate(0);
    }
    current = nullptr;
    completed = stop.empty() && dpMismatches == 0 && unsupportedGeneration == 0;
  }

};

#include "ilp_bridge.h"
} // namespace

int main(int argc, char **argv) {
  if (argc < 4) {
    errs() << "usage: reference_solver INPUT.ll COST_TABLE.json OUTPUT_DIRECTORY"
              " [--c-sl=real|abstract] [--cost=abstract|real] [--tti-worker=PATH]\n";
    return 2;
  }
  bool real = false, useThroughput = false, bridge = false;
  StringRef worker = "tools/run-llvm24-tti";
  for (int i = 4; i < argc; ++i) {
    StringRef option(argv[i]);
    if (option == "--c-sl=real")
      real = true;
    else if (option == "--c-sl=abstract")
      real = false;
    else if (option == "--cost=real")
      useThroughput = true;
    else if (option == "--cost=abstract")
      useThroughput = false;
    else if (option == "--ilp-bridge")
      bridge = true;
    else if (option.consume_front("--tti-worker="))
      worker = option;
    else {
      errs() << "unknown option: " << option << '\n';
      return 2;
    }
  }
  if (useThroughput && worker.empty()) {
    errs() << "--cost=real requires --tti-worker=PATH\n";
    return 2;
  }
  LLVMContext context;
  SMDiagnostic diagnostic;
  auto module = parseIRFile(argv[1], diagnostic, context);
  if (!module) {
    diagnostic.print(argv[0], errs());
    return 1;
  }
  if (verifyModule(*module, &errs()))
    return 1;
  Function *function = nullptr;
  for (auto &fn : *module)
    if (!fn.isDeclaration()) {
      if (function || !fn.hasName()) {
        errs() << "expected a single named function definition\n";
        return 1;
      }
      function = &fn;
    }
  if (!function || function->arg_empty())
    return 1;
  auto table = dataflow::readCosts(argv[2]);
  if (!table) {
    errs() << toString(table.takeError()) << '\n';
    return 1;
  }
  const auto &costs = *table->getAsObject();
  if (auto error = sys::fs::create_directories(argv[3])) {
    errs() << error.message() << '\n';
    return 1;
  }
  Search search(*module, *function, costs);
  search.outputDirectory = argv[3];
  dataflow::SizeLatency oracleQuotes(*module);
  search.oracleQuotes = &oracleQuotes;
  if (real || useThroughput)
    search.quotes = &oracleQuotes;
  std::unique_ptr<dataflow::RealCost> throughput;
  auto request = [&](const Function &fn) { return throughput->quote(fn); };
  if (useThroughput) {
    throughput = std::make_unique<dataflow::RealCost>(worker);
    search.throughput = request;
  }
  search.splitCost = *costs.getInteger("guard_segment_control");
  auto baseline = dataflow::evaluate(*function, costs, true, search.quotes,
                                     true, false, search.throughput);
  if (baseline && useThroughput) {
    auto quotes = request(*function);
    if (!quotes) {
      errs() << toString(quotes.takeError()) << '\n';
      return 1;
    }
    Optional<int64_t> arm;
    for (const auto &block : *function)
      if (const auto *branch = dyn_cast<BranchInst>(block.getTerminator())) {
        auto cost = quotes->lookup(branch);
        if (branch->isConditional())
          search.splitCost = cost;
        else if (!arm || *arm == cost)
          arm = cost;
        else {
          errs() << "different arm branch quotes are unsupported\n";
          return 1;
        }
      }
    search.armCost = arm.getValueOr(0);
  }
  if (bridge)
    return decisionBridge(search, baseline);
  std::string limitation = "a generation alternative could not be verified";
  if (baseline) {
    search.add(*module, true);
    if (readDiamond(*function, search.shape)) {
      if (search.shape.ops[0].size() + search.shape.ops[1].size() <= 16)
        search.search();
      else
        limitation = "input exceeds the subset DP operation limit";
    } else {
      limitation = "unsupported source CFG for candidate generation";
    }
  } else {
    search.stop = toString(baseline.takeError());
  }
  if (!search.stop.empty())
    limitation = search.stop;

  llvm::sort(search.front, [](const auto &a, const auto &b) { return a.cost < b.cost; });
  json::Array front;
  json::Value conservative = nullptr;
  for (unsigned i = 0; i < search.front.size(); ++i) {
    auto &entry = search.front[i];
    std::string file = std::to_string(i) + ".ll";
    SmallString<256> path(argv[3]);
    sys::path::append(path, file);
    std::error_code error;
    raw_fd_ostream out(path, error);
    if (error) {
      errs() << error.message() << '\n';
      return 1;
    }
    out << entry.ir;
    entry.report["ir"] = file;
    if (baseline && conservative.kind() == json::Value::Null &&
        entry.cost[0] < baseline->total[0] && entry.cost[1] <= baseline->total[1] &&
        entry.cost[2] <= baseline->total[2])
      conservative = i;
    front.push_back(std::move(entry.report));
  }
  auto seconds = std::chrono::duration<double>(Clock::now() - search.start).count();
  const auto base = baseline ? json::Value(json::Array{
      baseline->total[0], baseline->total[1], baseline->total[2]}) : json::Value(nullptr);
  json::Array topK;
  if (baseline && search.stop.empty()) {
    for (unsigned k : {1u, 3u, 10u}) {
      auto best = baseline->total[0];
      for (auto &plan : ArrayRef<Pairing>(search.pairings).take_front(k))
        if (plan.bestD)
          best = std::min(best, *plan.bestD);
      topK.push_back(json::Object{{"k", k}, {"best_observed_D", best}});
    }
  }
  outs() << json::Value(json::Object{{"complete", search.completed}, {"top_k", std::move(topK)},
      {"oracle_candidates", search.oracleCandidates}, {"oracle_guards", search.oracleGuards},
      {"pairings", static_cast<int64_t>(search.pairings.size())}, {"cyclic_pairings", search.cyclic}, {"reason", search.completed ? "" : limitation}, {"dp_mismatches", search.dpMismatches},
      {"unsupported_generation", search.unsupportedGeneration}, {"rejected_fold", search.rejectedFold},
      {"original_T", base}, {"candidates", static_cast<int64_t>(search.candidates)},
      {"verified_candidates", static_cast<int64_t>(search.verified)}, {"seconds", seconds},
      {"pareto_front", std::move(front)}, {"conservative_index", std::move(conservative)}}) << '\n';
}
