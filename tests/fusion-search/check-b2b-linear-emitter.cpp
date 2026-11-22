#include "fusion_search.h"

#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/raw_ostream.h"

#include <cassert>
#include <iterator>

using namespace fusion;
using namespace llvm;

int main(int argc, char **argv) {
  assert(argc == 2);
  LLVMContext context;
  SMDiagnostic error;
  auto module = parseAssemblyFile(argv[1], error, context);
  if (!module) {
    error.print(argv[0], errs());
    return 1;
  }
  auto &function = *module->getFunction("auto_guard_reference");
  function.setName("auto_guard_fused");
  auto &entry = function.getEntryBlock();
  auto &split = cast<BranchInst>(*entry.getTerminator());
  auto &left = *split.getSuccessor(0);
  auto &right = *split.getSuccessor(1);
  const AnchorMatch matches[] = {{3, 3}, {5, 4}};
  const AnchorGapPlacement gaps[] = {
      AnchorGapPlacement::Guard, AnchorGapPlacement::Hoist, AnchorGapPlacement::Guard};
  emitB2BLinear(split, left, right, left.getSingleSuccessor(), matches, true, false, gaps);
  if (verifyModule(*module, &errs()))
    return 1;

  // The first gap guards both arms with one branch, retaining memory order
  // and keeping their pure calculations inside the chosen arm.
  auto &first = cast<BranchInst>(*entry.getTerminator());
  assert(isa<FreezeInst>(first.getCondition()));
  auto *join = first.getSuccessor(0)->getSingleSuccessor();
  assert(join && first.getSuccessor(1)->getSingleSuccessor() == join);
  for (unsigned side = 0; side != 2; ++side) {
    auto &arm = *first.getSuccessor(side);
    assert(arm.size() == 4 && isa<StoreInst>(arm.front()));
    assert(isa<LoadInst>(*std::next(arm.begin())));
    assert(isa<BinaryOperator>(*std::next(arm.begin(), 2)));
    auto &phi = cast<PHINode>(*std::next(join->begin(), side));
    assert(isa<PoisonValue>(phi.getIncomingValueForBlock(first.getSuccessor(1 - side))));
    assert(phi.getIncomingValueForBlock(&arm) == &*std::next(arm.begin(), 2));
  }

  auto &last = cast<BranchInst>(*join->getTerminator());
  auto *oneSide = last.getSuccessor(0), *continuation = last.getSuccessor(1);
  assert(last.getCondition() == first.getCondition());
  assert(oneSide->getSingleSuccessor() == continuation);
  SmallVector<unsigned, 4> nonPhi;
  for (auto &inst : *join)
    if (!isa<PHINode>(inst))
      nonPhi.push_back(inst.getOpcode());
  assert((nonPhi == SmallVector<unsigned, 4>{
      Instruction::Load, Instruction::Mul, Instruction::Select, Instruction::Store, Instruction::Br}));
  assert(isa<StoreInst>(*std::prev(oneSide->end(), 2)));
  auto &exitValue = cast<PHINode>(continuation->front());
  assert(isa<PoisonValue>(exitValue.getIncomingValueForBlock(join)));
  assert(exitValue.getIncomingValueForBlock(oneSide) == &oneSide->front());
  module->print(outs(), nullptr);
}
