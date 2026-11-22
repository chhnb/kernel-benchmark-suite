#include "GuardedRanges.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include <cassert>

using namespace llvm;

int main() {
  LLVMContext context;
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
  assert(!protectedValues.count(inst("safe")));
  assert(!cast<BinaryOperator>(inst("safe"))->hasNoSignedWrap());
  assert(protectedValues.count(inst("keep")));
  assert(protectedValues.count(inst("local")));
  assert(cast<BinaryOperator>(inst("local"))->hasNoUnsignedWrap());
  assert(protectedValues.count(inst("opposite")));
  assert(protectedValues.count(inst("wide")));
  assert(!verifyModule(*module));
}
