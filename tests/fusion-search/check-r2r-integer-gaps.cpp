#include "GuardedRanges.h"
#include "anchor_uniform_gate.h"
#include "anchor_wave_diagnostic.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include <cassert>

using namespace llvm;

static void checkWaveGate(LLVMContext &context) {
  SMDiagnostic error;
  auto module = parseAssemblyString(R"(
    target triple = "amdgcn-amd-amdhsa"
    declare i32 @llvm.amdgcn.workitem.id.x()
    define amdgpu_kernel void @test_wave() "target-cpu"="gfx906" {
    entry:
      %tid = call i32 @llvm.amdgcn.workitem.id.x()
      %condition = icmp ult i32 %tid, 16
      br i1 %condition, label %left, label %right
    left:
      ret void
    right:
      ret void
    }
  )", error, context);
  assert(module && !verifyModule(*module));
  const auto &f = *module->getFunction("test_wave");
  const auto *branch = cast<BranchInst>(f.getEntryBlock().getTerminator());
  auto classify = [&](StringRef shape) {
    return fusion::wave_diagnostic::classify(f, branch, shape)
        .getString("classification").getValueOr("").str();
  };
  // Without a launch shape, a losing speculative layout is rejected and
  // the guarded layout remains eligible for ordinary TTI comparison.
  assert(classify("32,1,1") == "must-diverge");
  assert(fusion::anchorUniformRejection(classify("32,1,1"), true, -1, -2).empty());
  assert(classify("") == "unknown");
  assert(fusion::anchorUniformRejection(classify(""), true, -1, -2) ==
         "negative_uniform_gain");
  assert(fusion::anchorUniformRejection(classify(""), false, -1, -2).empty());
}

int main() {
  LLVMContext context;
  checkWaveGate(context);
  SMDiagnostic parseError;
  auto module = parseAssemblyString(R"(
    define i32 @test(i1 %cond, i32 %input, i32* %ptr) {
      %safe = add nsw i32 %input, 4
      %keep = load i32, i32* %ptr
      %local = sub nuw i32 %keep, 1
      %opposite = add i32 %input, 9
      %wide = xor i32 %opposite, %local
      %masked = select i1 %cond, i32 %safe, i32 %input
      %out = add i32 %wide, %masked
      ret i32 %out
    }
  )", parseError, context);
  assert(module && !verifyModule(*module));
  auto &f = *module->getFunction("test");
  auto inst = [&](StringRef name) -> Instruction * {
    for (auto &I : f.front())
      if (I.getName() == name)
        return &I;
    llvm_unreachable("missing fixture instruction");
  };
  SmallVector<GapRange, 8> gaps{
      {inst("safe"), inst("safe"), true},
      {inst("keep"), inst("keep"), true},
      {inst("local"), inst("local"), true},
      {inst("opposite"), inst("opposite"), false},
      {inst("wide"), inst("wide"), true},
  };
  auto plan = planGaps(gaps, f.getArg(0));
  SmallPtrSet<const Instruction *, 8> protectedValues;
  for (auto &g : plan.Guards) {
    protectedValues.insert(g.First.Instructions.begin(), g.First.Instructions.end());
    protectedValues.insert(g.Second.begin(), g.Second.end());
  }
  assert(plan.SpeculatedIntegerGaps);
  assert(!protectedValues.count(inst("safe")));
  assert(!cast<BinaryOperator>(inst("safe"))->hasNoSignedWrap());
  assert(protectedValues.count(inst("keep")));
  assert(protectedValues.count(inst("local")));
  assert(cast<BinaryOperator>(inst("local"))->hasNoUnsignedWrap());
  assert(protectedValues.count(inst("opposite")));
  assert(protectedValues.count(inst("wide")));
  assert(!verifyModule(*module));
}
