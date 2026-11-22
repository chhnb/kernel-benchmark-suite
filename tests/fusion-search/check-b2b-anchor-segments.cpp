#include "b2b_anchor.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/SourceMgr.h"
#include <cassert>
#include <memory>

using namespace llvm;
using namespace fusion;
int main() {
  LLVMContext context;
  SMDiagnostic error;
  auto module = parseAssemblyString(R"IR(
define i1 @phis(i1 %cond, double %x, double %y, double* %out0, double* %out1) {
entry:
  br i1 %cond, label %l, label %r
l:
  %d0 = fsub double %x, %y
  %d1 = fsub double %y, %x
  %independent = fmul double %x, %y
  store double %d0, double* %out0
  store double %d1, double* %out1
  %lc = fcmp olt double %x, %y
  br label %join
r:
  %other = fmul double %x, %y
  %rc = fcmp olt double %x, %y
  br label %join
join:
  %v = phi i1 [ %lc, %l ], [ %rc, %r ]
  ret i1 %v
}

define i32 @reused(i1 %cond, i32 %a, i32 %b) {
entry:
  br i1 %cond, label %l, label %r
l:
  %l0 = add i32 %a, %a
  %l1 = xor i32 %a, 2
  %l2 = sub i32 %a, 3
  br label %join
r:
  %r0 = add i32 %b, %b
  %r1 = xor i32 %b, 2
  %r2 = sub i32 %b, 3
  br label %join
join:
  %exit0 = phi i32 [ %a, %l ], [ %b, %r ]
  %exit1 = phi i32 [ %a, %l ], [ %b, %r ]
  %exit2 = phi i32 [ %l2, %l ], [ %r2, %r ]
  %res = add i32 %exit0, %exit2
  ret i32 %res
}

define i32 @cut(i1 %cond, i32 %a, i32 %b, i32 %x, i32 %y) {
entry:
  br i1 %cond, label %l, label %r
l:
  %l0 = add i32 %a, %x
  %l1 = sub i32 %a, %x
  br label %join
r:
  %r0 = add i32 %b, %y
  %r1 = sub i32 %b, %y
  br label %join
join:
  %res = phi i32 [ %l1, %l ], [ %r1, %r ]
  ret i32 %res
}
)IR", error, context);
  assert(module);
  auto &fn = *module->getFunction("phis");
  auto it = std::next(fn.begin());
  auto &l = *it++, &r = *it++, &join = *it;
  SmallVector<Instruction*, 8> left, right;
  for (auto &inst : l) if (!inst.isTerminator()) left.push_back(&inst);
  for (auto &inst : r) if (!inst.isTerminator()) right.push_back(&inst);
  for (int doublePhiCost : {0, 1}) {
    auto plans = planB2BAnchors(left, right, l, r, &join, true,
        [](Instruction &a, Instruction &b) { return a.isSameOperationAs(&b); },
        [](const Instruction &inst) { return inst.getOpcode() == Instruction::FMul ? 3 : 1; },
        [](Type *) { return 1; },
        [=](Type *type) { return type->isDoubleTy() ? doublePhiCost : 0; });
    assert(plans.front().chargedSegments == (doublePhiCost ? 1u : 2u));
    assert(llvm::any_of(plans, [](const AnchorPlan &plan) {
      return plan.matches.size() == 1 && plan.matches == plan.anchors;
    }));
  }

  auto costPlans = [&](StringRef function, AnchorScoring scoring) {
    auto &f = *module->getFunction(function);
    auto b = std::next(f.begin());
    auto &lhs = *b++, &rhs = *b++, &exit = *b;
    SmallVector<Instruction *, 8> work[2];
    for (auto &inst : lhs) if (!inst.isTerminator()) work[0].push_back(&inst);
    for (auto &inst : rhs) if (!inst.isTerminator()) work[1].push_back(&inst);
    return planB2BAnchors(work[0], work[1], lhs, rhs, &exit, true,
        [](Instruction &a, Instruction &b) { return a.isSameOperationAs(&b); },
        [=](const Instruction &inst) {
          return function == "cut" && inst.getOpcode() == Instruction::Sub ? 1 : 3;
        },
        [](Type *) { return 1; }, [](Type *) { return 0; }, true, scoring);
  };
  auto repeated = costPlans("reused", {});
  auto dedup = costPlans("reused", {true, false, false});
  auto dedupEager = costPlans("reused", {true, false, true});
  assert(repeated.front().matches.size() == 3 && repeated.front().score == 5);
  // Four uses of (a,b), plus two exit PHIs, share one select. Paired
  // producers at exit and identical constant operands add no select.
  assert(dedup.front().matches == repeated.front().matches && dedup.front().score == 8);
  assert(dedupEager.front().matches == dedup.front().matches &&
         dedupEager.front().score == dedup.front().score);

  auto fixed = costPlans("cut", {true, false, false});
  auto live = costPlans("cut", {true, true, false});
  assert(fixed.front().cutoffs.size() == 1 &&
         (fixed.front().cutoffs.front() == AnchorMatch{1, 1}));
  assert(live.front().cutoffs == fixed.front().cutoffs);
  assert(fixed.front().matches.size() == 1);
  assert(live.front().matches.size() == 2 && live.front().score == 2);

  auto gaps = [&](bool eager) {
    return planB2BAnchors(left, right, l, r, &join, true,
        [](Instruction &a, Instruction &b) { return a.isSameOperationAs(&b); },
        [](const Instruction &inst) { return inst.getOpcode() == Instruction::FMul ? 3 : 1; },
        [](Type *) { return 1; }, [](Type *) { return 0; }, false, {false, false, eager});
  };
  auto lazy = gaps(false);
  auto eager = gaps(true);
  // Eager ranking can retain a different beam, but a shared alignment must
  // have exactly the same settled fork and PHI costs.
  unsigned shared = 0;
  for (const auto &a : lazy)
    for (const auto &b : eager)
      if (a.matches == b.matches) {
        ++shared;
        assert(a.score == b.score && a.phiCharge == b.phiCharge &&
               a.chargedSegments == b.chargedSegments);
      }
  assert(shared != 0);

}
