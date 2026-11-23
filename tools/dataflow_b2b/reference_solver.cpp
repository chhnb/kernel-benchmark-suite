#include "evaluate_cost.h"

#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/Local.h"
#include <chrono>
#include <functional>
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
    for (const auto &inst : *block) {
      if (isa<PHINode>(inst))
        return false;
      if (!inst.isTerminator() && !isa<DbgInfoIntrinsic>(inst))
        out.ops[side].push_back(&inst);
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
  if (isa<LoadInst, StoreInst, CallBase, AllocaInst>(a) ||
      isa<LoadInst, StoreInst, CallBase, AllocaInst>(b))
    return false;
  if (a.getRawSubclassOptionalData() != b.getRawSubclassOptionalData())
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
  std::set<std::string> recipes;
};

Candidate emit(const Module &source, const Function &func, const Diamond &shape,
               ArrayRef<Node> nodes) {
  Candidate result;
  ValueToValueMapTy map;
  auto module = CloneModule(source, map);
  auto *branch = cast<BranchInst>(map.lookup(shape.branch));
  auto *join = cast<BasicBlock>(map.lookup(shape.join));
  auto *condition = branch->getCondition();
  auto *target = cast<Function>(map.lookup(&func));
  IRBuilder<> builder(branch);
  SmallPtrSet<const Value *, 32> pending;
  DenseMap<const Value *, unsigned> order;
  SmallVector<Value *, 16> generatedSelects;
  DenseMap<Value *, unsigned> guardedValues;
  BasicBlock *predecessors[2] = {nullptr, nullptr};
  bool guarding = false;
  bool speculativeSides[2] = {false, false};
  for (const auto &node : nodes) {
    if (node.left) pending.insert(node.left);
    if (node.right) pending.insert(node.right);
  }
  for (unsigned i = 0; i < shape.ops[1].size(); ++i)
    order[shape.ops[1][i]] = i;
  DenseMap<std::pair<Value *, Value *>, Value *> choices;
  auto notCondition = [&] {
    auto *inst = cast<Instruction>(builder.CreateNot(condition));
    inst->setMetadata("dataflow.folded.condition", MDNode::get(module->getContext(), {}));
    return inst;
  };
  auto guardPhi = [&](Value *left, Value *right) -> Value * {
    auto key = std::make_pair(left, right);
    if (auto found = choices.find(key); found != choices.end())
      return found->second;
    auto *phi = PHINode::Create(left->getType(), 2, "", &*join->getFirstInsertionPt());
    phi->addIncoming(left, predecessors[0]);
    phi->addIncoming(right, predecessors[1]);
    choices[key] = phi;
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
    bool lGuarded = guardedValues.count(left);
    bool rGuarded = guardedValues.count(right);
    auto afterGuard = [&](Value *value) {
      const auto *inst = dyn_cast<Instruction>(value);
      return inst && inst->getParent() == join;
    };
    if (lGuarded && afterGuard(right))
      left = guardPhi(left, PoisonValue::get(left->getType()));
    else if (rGuarded && afterGuard(left))
      right = guardPhi(PoisonValue::get(right->getType()), right);
    else if (lGuarded || rGuarded)
      return guardPhi(left, right);
    auto key = std::make_pair(left, right);
    if (auto found = choices.find(key); found != choices.end())
      return found->second;
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
      generatedSelects.push_back(value);
    }
    choices[key] = value;
    return value;
  };
  auto ready = [&](const Instruction *inst) {
    return !inst || llvm::none_of(inst->operands(), [&](const Use &use) {
      return pending.count(use.get());
    });
  };
  auto mapped = [&](const Value *value) -> Value * {
    return MapValue(value, map, RF_IgnoreMissingLocals);
  };
  auto escape = [&](Value *value) -> Value * {
    auto side = guardedValues.lookup(value);
    if (!side)
      return value;
    auto *padding = PoisonValue::get(value->getType());
    return side == 1 ? merge(value, padding) : merge(padding, value);
  };
  auto clone = [&](const Instruction &inst) {
    auto *copy = inst.clone();
    copy->dropUnknownNonDebugMetadata();
    copy->setDebugLoc(DebugLoc());
    RemapInstruction(copy, map, RF_IgnoreMissingLocals);
    return copy;
  };
  SmallPtrSet<const Node *, 16> emitted;
  bool invalid = false;
  auto scheduleGlobals = [&] {
    while (true) {
      size_t before = emitted.size();
      for (const auto &node : nodes) {
        if (node.recipe == Recipe::R6 || emitted.count(&node) ||
            !ready(node.left) || !ready(node.right))
          continue;
        const auto &base = *(node.left ? node.left : node.right);
        auto *copy = clone(base);
        if (node.left && node.right) {
          for (unsigned i = 0; i < copy->getNumOperands(); ++i) {
            unsigned r = node.recipe == Recipe::R1 ? i : 1 - i;
            copy->setOperand(i, merge(mapped(node.left->getOperand(i)),
                                      mapped(node.right->getOperand(r))));
          }
        } else if (guarding) {
          bool sensitive = isa<CallBase, LoadInst>(base) ||
                           base.getOpcode() == Instruction::SDiv ||
                           base.getOpcode() == Instruction::UDiv ||
                           base.getOpcode() == Instruction::SRem ||
                           base.getOpcode() == Instruction::URem;
          for (unsigned i = 0; i < base.getNumOperands(); ++i) {
            if (sensitive && guardedValues.count(copy->getOperand(i))) {
              copy->deleteValue();
              invalid = true;
              return;
            }
            copy->setOperand(i, escape(copy->getOperand(i)));
          }
        }
        builder.Insert(copy);
        if (node.left) {
          map[node.left] = copy;
          pending.erase(node.left);
        }
        if (node.right) {
          map[node.right] = copy;
          pending.erase(node.right);
        }
        emitted.insert(&node);
      }
      if (before == emitted.size())
        return;
    }
  };
  scheduleGlobals();

  BasicBlock *guards[2] = {nullptr, nullptr};
  if (llvm::any_of(nodes, [](const Node &node) { return node.recipe == Recipe::R6; })) {
    auto *entry = branch->getParent();
    guarding = true;
    for (unsigned side : {0u, 1u}) {
      Insts protectedOps;
      for (auto *inst : shape.ops[side])
        if (llvm::any_of(nodes, [&](const Node &node) {
              return node.recipe == Recipe::R6 && (side ? node.right : node.left) == inst;
            }))
          protectedOps.push_back(inst);
      result.guardCluster |= protectedOps.size() > 1;
      predecessors[side] = entry;
      if (protectedOps.empty())
        continue;
      guards[side] = BasicBlock::Create(module->getContext(), "", target, join);
      predecessors[side] = guards[side];
      for (auto *inst : protectedOps) {
        if (!ready(inst))
          return result;
        auto *copy = clone(*inst);
        guards[side]->getInstList().push_back(copy);
        map[inst] = copy;
        guardedValues[copy] = side + 1;
        pending.erase(inst);
      }
      BranchInst::Create(join, guards[side]);
    }
    builder.SetInsertPoint(&*join->getFirstInsertionPt());
    scheduleGlobals();
  }
  if (invalid || !pending.empty())
    return result;
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
  if (guarding)
    BranchInst::Create(guards[0] ? guards[0] : join, guards[1] ? guards[1] : join,
                       condition, branch);
  else
    BranchInst::Create(join, branch);
  branch->eraseFromParent();
  SmallVector<BasicBlock *, 2> dead;
  for (auto *block : {shape.left, shape.right})
    if (block != shape.branch->getParent())
      dead.push_back(cast<BasicBlock>(map.lookup(block)));
  for (auto *block : dead)
    block->dropAllReferences();
  for (auto *block : dead)
    block->eraseFromParent();

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
  bool hasWrites = false;

  bool speculate(const Instruction &inst) const {
    return !(hasWrites && isa<LoadInst>(inst)) &&
           dataflow::speculationFailure(inst, costs).empty();
  }

  void add(Module &input, bool original, Candidate *candidate = nullptr) {
    auto *function = input.getFunction(func.getName());
    auto result = dataflow::evaluate(*function, costs, original);
    if (!result) {
      stop = toString(result.takeError());
      return;
    }
    ++verified;
    const auto cost = result->total;
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
      report["pairs"] = std::move(candidate->pairs);
      report["features"] = json::Object{{"crossed", candidate->crossed},
        {"commute", candidate->commute}, {"cmp_swap", candidate->cmpSwap},
        {"shared_select", candidate->sharedSelect}, {"guard_cluster", candidate->guardCluster},
        {"speculate_then_select", candidate->speculateSelect},
        {"speculated_operations", candidate->speculate}};
      json::Array recipes;
      for (const auto &recipe : candidate->recipes)
        recipes.push_back(recipe);
      report["recipes"] = std::move(recipes);
    }
    front.push_back({cost, std::move(text), std::move(report)});
  }

  void finish(unsigned index) {
    if (!stop.empty())
      return;
    if (index != shape.ops[1].size()) {
      auto *right = shape.ops[1][index];
      if (usedRight.count(right)) {
        finish(index + 1);
        return;
      }
      nodes.push_back({nullptr, right, Recipe::R6});
      if (speculate(*right)) {
        nodes.back().recipe = Recipe::R5;
        finish(index + 1);
        nodes.back().recipe = Recipe::R6;
      }
      finish(index + 1);
      nodes.pop_back();
      return;
    }
    if (candidates == 10000000 || Clock::now() - start >= std::chrono::minutes(10)) {
      stop = "enumeration limit";
      return;
    }
    ++candidates;
    auto result = emit(module, func, shape, nodes);
    if (!result.module)
      return;
    if (verifyModule(*result.module, &errs())) {
      stop = "generated candidate failed LLVM12 verifier";
      return;
    }
    const auto *f = result.module->getFunction(func.getName());
    bool guarded = result.recipes.count("R6");
    if (guarded) {
      // The residual single guard is priced with the same Fold rule. A
      // foldable residual guard should be reached via the R5 choices instead.
      auto check = dataflow::evaluate(*f, costs, true);
      if (!check || check->folded) {
        if (!check)
          consumeError(check.takeError());
        return;
      }
    }
    add(*result.module, false, &result);
  }

  void enumerate(unsigned index) {
    if (!stop.empty())
      return;
    if (candidates == 10000000 || Clock::now() - start >= std::chrono::minutes(10)) {
      stop = "enumeration limit";
      return;
    }
    if (index == shape.ops[0].size()) {
      finish(0);
      return;
    }
    auto *left = shape.ops[0][index];
    nodes.push_back({left, nullptr, Recipe::R6});
    if (speculate(*left)) {
      nodes.back().recipe = Recipe::R5;
      enumerate(index + 1);
      nodes.back().recipe = Recipe::R6;
    }
    enumerate(index+1);
    for (auto *right : shape.ops[1]) {
      if (usedRight.count(right) || !speculate(*left) || !speculate(*right))
        continue;
      for (auto recipe : {Recipe::R1, Recipe::R2, Recipe::R3}) {
        if (!compatible(*left, *right, recipe))
          continue;
        usedRight.insert(right);
        nodes.back() = {left, right, recipe};
        enumerate(index+1);
        usedRight.erase(right);
      }
    }
    nodes.pop_back();
  }
};
} // namespace

int main(int argc, char **argv) {
  if (argc != 4) {
    errs() << "usage: reference_solver INPUT.ll COST_TABLE.json OUTPUT_DIRECTORY\n";
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
  Search search{*module, *function, costs, {}, Clock::now(), 0, 0, {}, {}, {}, {}, false};
  auto baseline = dataflow::evaluate(*function, costs, true);
  std::string limitation = "multi-segment R6/G1–G4 scheduling and S_loc coverage are incomplete";
  if (baseline) {
    search.add(*module, true);
    if (readDiamond(*function, search.shape)) {
      for (const auto &arm : search.shape.ops)
        search.hasWrites |= llvm::any_of(arm, [](const auto *inst) { return inst->mayWriteToMemory(); });
      search.enumerate(0);
    } else {
      limitation = "unsupported source CFG for candidate generation";
    }
  } else {
    search.stop = toString(baseline.takeError());
  }
  if (!search.stop.empty())
    limitation = search.stop;

  if (auto error = sys::fs::create_directories(argv[3])) {
    errs() << error.message() << '\n';
    return 1;
  }
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
  outs() << json::Value(json::Object{{"complete", false}, {"reason", limitation},
      {"original_T", base}, {"candidates", static_cast<int64_t>(search.candidates)},
      {"verified_candidates", static_cast<int64_t>(search.verified)}, {"seconds", seconds},
      {"pareto_front", std::move(front)}, {"conservative_index", std::move(conservative)}}) << '\n';
}
