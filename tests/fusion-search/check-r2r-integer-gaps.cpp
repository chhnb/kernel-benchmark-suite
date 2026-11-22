#include "GuardedRanges.h"
#include "anchor_uniform_gate.h"
#include "anchor_condition.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include <cassert>

using namespace llvm;

static void checkConditionGate(LLVMContext &context) {
  SMDiagnostic error;
  auto module = parseAssemblyString(R"(
    target triple = "amdgcn-amd-amdhsa"
    declare i32 @llvm.amdgcn.workitem.id.x()
    define amdgpu_kernel void @test_wave(i32 %n, i32* %p) "target-cpu"="gfx906" {
    entry:
      %tid = call i32 @llvm.amdgcn.workitem.id.x()
      %condition = icmp ult i32 %tid, 16
      br i1 %condition, label %left, label %right
    left:
      ret void
    right:
      ret void
    }
    define amdgpu_kernel void @test_uniform(i32 %n) "target-cpu"="gfx906" {
      %condition = icmp sgt i32 %n, 0
      br i1 %condition, label %left, label %right
    left:
      ret void
    right:
      ret void
    }
    define amdgpu_kernel void @test_data(i32* %p) "target-cpu"="gfx906" {
      %v = load i32, i32* %p
      %condition = icmp sgt i32 %v, 0
      br i1 %condition, label %left, label %right
    left:
      ret void
    right:
      ret void
    }
  )", error, context);
  assert(module && !verifyModule(*module));
  auto classify = [&](StringRef fn) {
    const auto &f = *module->getFunction(fn);
    const auto *branch = cast<BranchInst>(f.getEntryBlock().getTerminator());
    return fusion::anchor_condition::classifySource(branch);
  };
  using fusion::anchorUniformRejection;
  assert(anchorUniformRejection(classify("test_wave"), true, -1, -2).empty());
  const auto uniform = classify("test_uniform");
  assert(anchorUniformRejection(uniform, true, 0, 0) == "workgroup_uniform");
  assert(anchorUniformRejection(uniform, false, -1, -2).empty());
  const auto data = classify("test_data");
  assert(anchorUniformRejection(data, true, 0, 0).empty());
  assert(anchorUniformRejection(data, true, 0, std::nullopt) == "missing_uniform_gain");
  assert(anchorUniformRejection(data, true, 0, -1) == "negative_uniform_gain");
  assert(anchorUniformRejection(data, false, -1, -2).empty());
}

int main() {
  LLVMContext context;
  checkConditionGate(context);
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
