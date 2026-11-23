// Experiment helpers for measuring and replaying a single B2B region.
#include "dataflow_b2b/dataflow_exact.h"
#include "dataflow_b2b/real_cost.h"
#include "llvm/Analysis/InstructionSimplify.h"
#include "llvm/IR/CFG.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include <array>
#include <set>

using namespace llvm;
using namespace dataflow::extraction;
constexpr const char *Outside = "step7.outside";
constexpr const char *Predicate = "step7.predicate";
constexpr const char *ArgumentTag = "step7.argument";

static int fail(StringRef msg) { errs() << msg << "\n"; return 1; }

static int save(Module &module, StringRef path) {
  if (verifyModule(module, &errs())) return 1;
  std::error_code error;
  raw_fd_ostream out(path, error);
  if (error) return fail(error.message());
  module.print(out, nullptr);
  return 0;
}

static bool tag(dataflow::extraction::Region &region) {
  auto &fn = *region.split.getFunction();
  auto &ctx = fn.getContext();
  auto *cond = region.split.getCondition();
  if (auto *inst = dyn_cast<Instruction>(cond))
    inst->setMetadata(Predicate, MDNode::get(ctx, {}));
  else if (auto *arg = dyn_cast<llvm::Argument>(cond))
    fn.setMetadata(ArgumentTag, MDNode::get(ctx, MDString::get(ctx, Twine(arg->getArgNo()).str())));
  else
    return false;
  unsigned id = 0;
  for (auto &block : fn)
    for (auto &inst : block) {
      if (&inst == &region.split || (&block == region.join && isa<PHINode>(inst)))
        continue;
      if (is_contained(region.left, &block) || is_contained(region.right, &block))
        continue;
      if (isa<DbgInfoIntrinsic>(inst)) continue;
      inst.setMetadata(Outside, MDNode::get(ctx, MDString::get(ctx, Twine(id++).str())));
    }
  outs() << id << "\n";
  return true;
}

static std::set<unsigned> reachable(Function &fn, Value *condition, bool side) {
  auto &module = *fn.getParent();
  ValueToValueMapTy map;
  auto *clone = CloneFunction(&fn, map);
  auto cleanup = make_scope_exit([&] { clone->eraseFromParent(); });
  Value *test = map.lookup(condition);
  SmallVector<Instruction *, 64> pending;
  auto push = [&](Value *value) {
    for (auto *use : value->users())
      if (auto *inst = dyn_cast<Instruction>(use)) pending.push_back(inst);
  };
  push(test);
  test->replaceAllUsesWith(ConstantInt::get(Type::getInt1Ty(fn.getContext()), side));
  SimplifyQuery query(module.getDataLayout());
  while (!pending.empty()) {
    auto *inst = pending.pop_back_val();
    if (inst->use_empty()) continue;
    if (auto *simplified = SimplifyInstruction(inst, query))
      if (simplified != inst) {
        push(inst);
        inst->replaceAllUsesWith(simplified);
      }
  }
  DenseMap<const BasicBlock *, unsigned> ids;
  for (auto &block : *clone) ids[&block] = ids.size();
  SmallVector<BasicBlock *, 16> blocks{&clone->getEntryBlock()};
  std::set<unsigned> seen;
  while (!blocks.empty()) {
    auto *b = blocks.pop_back_val();
    if (!seen.insert(ids.lookup(b)).second) continue;
    if (auto *br = dyn_cast<BranchInst>(b->getTerminator()))
      if (br->isConditional())
        if (auto *k = dyn_cast<ConstantInt>(br->getCondition())) {
          blocks.push_back(br->getSuccessor(k->isZero()));
          continue;
        }
    for (auto *next : successors(b)) blocks.push_back(next);
  }
  return seen;
}

static int price(Function &fn, StringRef worker) {
  Value *cond = nullptr;
  if (auto *metadata = fn.getMetadata(ArgumentTag)) {
    unsigned index;
    if (cast<MDString>(metadata->getOperand(0))->getString().getAsInteger(10, index) ||
        index >= fn.arg_size()) return fail("invalid predicate argument metadata");
    cond = fn.getArg(index);
  }
  for (auto &block : fn)
    for (auto &inst : block)
      if (inst.getMetadata(Predicate)) {
        if (cond) return fail("predicate metadata duplicated");
        cond = &inst;
      }
  if (!cond) return fail("predicate metadata lost");
  auto left = reachable(fn, cond, true), right = reachable(fn, cond, false);
  dataflow::RealCost prices(worker);
  auto rates = prices.quote(fn);
  if (!rates) return fail(toString(rates.takeError()));
  std::map<std::string, std::array<int64_t, 3>> components;
  std::map<std::string, unsigned> operations;
  std::set<std::string> outside;
  std::array<int64_t, 3> total{};
  unsigned index = 0;
  for (const auto &block : fn) {
    bool l = left.count(index), r = right.count(index++);
    if (!l && !r) continue;
    for (const auto &inst : block) {
      if (auto *metadata = inst.getMetadata(Outside)) {
        outside.insert(cast<MDString>(metadata->getOperand(0))->getString().str());
        continue;
      }
      if (isa<DbgInfoIntrinsic>(inst) || laneInput(inst)) continue;
      auto quoted = rates->find(&inst);
      if (quoted == rates->end()) return fail("missing regional quote");
      StringRef category = isa<BranchInst>(inst) ? "control" : isa<PHINode>(inst) ? "escape" :
                           isa<SelectInst>(inst) ? "select" : "instruction";
      auto &vector = components[category.str()];
      for (unsigned s : {0u, 1u, 2u})
        if (s == 0 || (s == 1 ? l : r)) {
          vector[s] += quoted->second;
          total[s] += quoted->second;
        }
      if (isa<BranchInst>(inst)) {
        if (cast<BranchInst>(inst).isConditional()) ++operations["conditional_branches"];
      } else
        ++operations[category.str() + (l && r ? "_common" : "_protected")];
    }
  }
  auto arr = [](std::array<int64_t, 3> x) { return json::Array{x[0], x[1], x[2]}; };
  json::Object priced, counts;
  for (const auto &item : components) priced[item.first] = arr(item.second);
  for (const auto &item : operations) counts[item.first] = item.second;
  outs() << json::Value(json::Object{{"T", arr(total)}, {"components", std::move(priced)},
    {"operations", std::move(counts)}, {"outside_retained", int64_t(outside.size())}}) << "\n";
  return 0;
}

int main(int argc, char **argv) {
  if (argc < 5) return fail("usage: step7_context tag|replace|price IR FUNCTION ARGS");
  LLVMContext context;
  SMDiagnostic diagnostic;
  auto module = parseIRFile(argv[2], diagnostic, context);
  if (!module) return fail("cannot parse input IR");
  auto *fn = module->getFunction(argv[3]);
  if (!fn) return fail("input function not found");
  StringRef mode(argv[1]);
  if (mode == "price" && argc == 5) return price(*fn, argv[4]);
  if (argc < 8) return fail("missing candidate or destination");
  fusion::Candidate candidate{argv[3], argv[4], argv[5], argv[6], 0, {}, {}, {}};
  auto *branch = dataflow::exact::findSplit(*fn, candidate);
  if (!branch) return fail("candidate not directly extractable");
  auto region = classifyB2B(*branch);
  if (mode == "tag" && argc == 8) return tag(region) ? save(*module, argv[7]) : fail("cannot tag predicate");
  if (mode != "replace" || argc != 9) return fail("bad mode or arguments");
  auto output = outputs(region);
  Values args;
  std::string reason;
  auto extracted = isolate(region, output, reason, &args);
  auto solution = parseIRFile(argv[7], diagnostic, context);
  if (!extracted || !solution || !solution->getFunction("region") ||
      !dataflow::exact::replace(region, output, args, *solution->getFunction("region"), reason) ||
      verifyModule(*module, &errs()))
    return fail(reason.empty() ? "cannot verify replacement" : reason);
  auto round = fusion::makeRound(*module, fn->getName().str(), 0, fusion::CleanupMode::DarmCFGInstCombine);
  return save(*round.control, argv[8]);
}
