#include "b2b_dp2.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/SourceMgr.h"
#include <cassert>

using namespace llvm;
using namespace fusion::dp2;

int main() {
  LLVMContext context;
  SMDiagnostic error;
  auto module = parseAssemblyString(R"(
    define i32 @test(i32 %a, i32 %b, i32* %mem) {
    entry:
      ret i32 0
    left:
      store i32 7, i32* %mem
      %seed = sub i32 %a, 1
      %l = add i32 %seed, %a
      ret i32 %l
    right:
      %r = add i32 %b, %b
      ret i32 %r
    }
  )", error, context);
  assert(module);
  auto &f = *module->getFunction("test");
  auto &l = *std::next(f.begin());
  auto &r = *std::next(f.begin(), 2);
  auto *seed = &*std::next(l.begin());
  SmallVector<Instruction *, 3> left{&l.front(), seed, &*std::next(l.begin(), 2)};
  SmallVector<Instruction *, 1> right{&r.front()};
  auto compatible = [](Instruction &a, Instruction &b) {
    return a.getOpcode() == Instruction::Add && b.getOpcode() == Instruction::Add;
  };
  auto available = [&](const Value *v) -> std::optional<Definition> {
    if (auto *arg = dyn_cast<Argument>(v))
      return Definition{~arg->getArgNo(), 0, Place::Common};
    if (auto *constant = dyn_cast<ConstantInt>(v))
      return Definition{unsigned(10000 + constant->getZExtValue()), 0, Place::Common};
    return std::nullopt;
  };
  auto weight = [](Instruction &) { return 1; };
  auto terminal = plan(left, right, {}, compatible,
      [](Instruction &i) { return isa<BinaryOperator>(i); }, available, weight);
  bool matched = false;
  for (const auto &out : terminal) {
    if (out.label.plan->action != Action::MatchHoist) continue;
    matched = true;
    assert(out.exit == Exit::DirectEdges || out.exit == Exit::CloseAndMergeValues);
    assert(out.label.plan->dependencies.size() == 1);
    assert(out.label.plan->dependencies.front() == std::make_pair(0u, 1u));
    auto a = out.label.values[0].lookup(left.back());
    auto b = out.label.values[1].lookup(right.back());
    assert(a && b && a->id == b->id);
  }
  assert(matched);
  // A source instruction excluded from the candidate and unavailable in the
  // common block must never be silently substituted with its original SSA.
  SmallVector<Instruction *, 1> missing{left.back()};
  assert(plan(missing, right, {}, compatible,
      [](Instruction &i) { return isa<BinaryOperator>(i); }, available, weight).empty());

  const Demand unavailableExit{r.getTerminator(), f.getArg(1)};
  assert(plan(left, right, {unavailableExit}, compatible,
      [](Instruction &i) { return isa<BinaryOperator>(i); }, available, weight).empty());

  // Force the loads to remain in their original arms. The current match
  // consumes their results and no later instruction needs either side value.
  auto memory = parseAssemblyString(R"(
    define void @memory(i32* %p, i32* %q) {
    left:
      %a = load i32, i32* %p
      %l = add i32 %a, 1
      ret void
    right:
      %b = load i32, i32* %q
      %r = add i32 %b, 1
      ret void
    }
  )", error, context);
  assert(memory);
  auto &mf = *memory->getFunction("memory");
  auto &ml = mf.front(), &mr = mf.back();
  SmallVector<Instruction *, 2> mlw{&ml.front(), &*std::next(ml.begin())};
  SmallVector<Instruction *, 2> mrw{&mr.front(), &*std::next(mr.begin())};
  bool paired = false;
  for (const auto &out : plan(mlw, mrw, {}, compatible,
      [](Instruction &i) { return isa<BinaryOperator>(i); }, available, weight)) {
    const auto &action = *out.label.plan;
    if (action.action != Action::MatchJoin || action.rightOperands.front() != 0) continue;
    paired = true;
    assert(action.pairedPhi.size() == 2 && action.pairedPhi[0] && !action.pairedPhi[1]);
    assert(action.liveThroughJoin.empty());
  }
  assert(paired);

  Label label;
  const Demand pair{f.getArg(0), f.getArg(1)};
  PairDemand demand(left, right, {}, compatible);
  assert(demand.future(pair, 2, 0));
  assert(!demand.future(pair, 3, 0));
  assert(demand.credit(label, 0, 0, available) == 0);
  label.selectors.bind({available(pair.first)->id, available(pair.second)->id}, {1, 0, Place::Common});
  assert(demand.credit(label, 0, 0, available) == 1);
}
