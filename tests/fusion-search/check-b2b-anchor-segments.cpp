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
}
