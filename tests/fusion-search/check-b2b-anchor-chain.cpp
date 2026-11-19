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
define i64 @chain(i1 %cond, i32* %p, i32* %index) {
entry:
  br i1 %cond, label %l, label %r
l:
  %li = load i32, i32* %index
  %lp = getelementptr i32, i32* %p, i32 %li
  %lo = ptrtoint i32* %lp to i64
  br label %join
r:
  %ri = load i32, i32* %index
  %rp = getelementptr i32, i32* %p, i32 %ri
  %ro = ptrtoint i32* %rp to i64
  br label %join
join:
  %v = phi i64 [ %lo, %l ], [ %ro, %r ]
  ret i64 %v
}
define double @add(i1 %cond, float %a, float %b, float %c, float %d) {
entry:
  br i1 %cond, label %l, label %r
l:
  %ls = fadd float %a, %b
  %lo = fpext float %ls to double
  br label %join
r:
  %rs = fadd float %c, %d
  %ro = fpext float %rs to double
  br label %join
join:
  %v = phi double [ %lo, %l ], [ %ro, %r ]
  ret double %v
}
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
)IR", error, context);
  assert(module);
  for (auto &fn : *module) {
    auto it = std::next(fn.begin());
    auto &l = *it++, &r = *it++, &join = *it;
    SmallVector<Instruction*, 8> left, right;
    for (auto &inst : l) if (!inst.isTerminator()) left.push_back(&inst);
    for (auto &inst : r) if (!inst.isTerminator()) right.push_back(&inst);
    if (fn.getName() == "phis") {
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
      continue;
    }
    for (bool pairTies : {false, true}) {
      auto plans = planB2BAnchors(left, right, l, r, &join, pairTies,
          [](Instruction &a, Instruction &b) { return a.isSameOperationAs(&b); },
          [](const Instruction &inst) {
            return isa<GetElementPtrInst>(inst) ? 0 : isa<LoadInst>(inst) ? 3 :
                   isa<FPExtInst>(inst) ? 2 : 1;
          }, [](Type *) { return 1; }, [](Type *) { return 1; });
      assert(!plans.empty());
      const auto &best = plans.front();
      if (fn.getName() == "chain") {
        assert(best.anchors.size() == 3 && best.cutoffs.empty());
        assert(isa<LoadInst>(left[best.anchors[0].left]));
        assert(isa<GetElementPtrInst>(left[best.anchors[1].left]));
      } else if (pairTies) {
        assert(best.matches.size() == 2 && best.cutoffs.empty());
        assert(left[best.matches.front().left]->getOpcode() == Instruction::FAdd);
      } else {
        assert(best.matches.size() == 1 && best.cutoffs.size() == 1);
        const auto &cut = best.cutoffs.front();
        assert(left[cut.match.left]->getOpcode() == Instruction::FAdd);
        assert(cut.value == -cut.outputSelectCost);
      }
    }
  }
}
