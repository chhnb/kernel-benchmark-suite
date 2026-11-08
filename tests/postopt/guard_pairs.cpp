#include "fusion_search.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/Analysis/PostDominators.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include <stdexcept>
using namespace llvm;
using namespace fusion;
static void require(bool B, const char *S) { if (!B) throw std::runtime_error(S); }
int main(int argc, char **argv) { try {
  require(argc == 2, "output IR required");
  LLVMContext C; SMDiagnostic E;
  auto M = parseAssemblyString(R"(
declare float @llvm.ceil.f32(float) nounwind readnone speculatable willreturn
declare float @llvm.floor.f32(float) nounwind readnone speculatable willreturn
define float @forward(i1 %p, float %x) {
entry: br i1 %p, label %a, label %b
a:
 %a0 = call float @llvm.ceil.f32(float %x)
 %a1 = fmul float %a0, 2.0
 br label %j
b:
 %b0 = call float @llvm.floor.f32(float %x)
 %b1 = fmul float %b0, 2.0
 br label %j
j:
 %r = phi float [ %a1, %a ], [ %b1, %b ]
 ret float %r
}
define float @reverse(i1 %p, float %x) {
entry: br i1 %p, label %a, label %b
a:
 %a0 = call float @llvm.floor.f32(float %x)
 %a1 = fmul float %a0, 2.0
 br label %j
b:
 %b0 = call float @llvm.ceil.f32(float %x)
 %b1 = fmul float %b0, 2.0
 br label %j
j:
 %r = phi float [ %a1, %a ], [ %b1, %b ]
 ret float %r
}
)", E, C);
  require(bool(M), "parse"); require(!verifyModule(*M, &errs()), "input verifier");
  for (const char *Name : {"forward", "reverse"}) {
    Candidate P{Name, "B0", "B1", "B2", 0};
    auto Hash = moduleHash(*M);
    auto T = tryPair(*M, P, 0, 3, CleanupMode::None);
    require(T.valid, T.reason.c_str()); require(moduleHash(*M) == Hash, "parent changed");
    auto *F = T.raw->getFunction(Name);
    PostDominatorTree PD(*F);
    BasicBlock *A = nullptr, *B = nullptr;
    unsigned Calls = 0, Selects = 0;
    for (auto &BB : *F) for (auto &I : BB) {
      Selects += isa<SelectInst>(I);
      if (auto *Call = dyn_cast<CallInst>(&I)) {
        ++Calls; if (!A) A = &BB; else B = &BB;
        require(!PD.dominates(&BB, &F->getEntryBlock()), "call speculated");
      }
    }
    require(Calls == 2 && A != B, "both operations must remain separate");
    require(A->getSinglePredecessor() && A->getSinglePredecessor() == B->getSinglePredecessor(), "not one diamond");
    require(A->getSingleSuccessor() && A->getSingleSuccessor() == B->getSingleSuccessor(), "not common join");
    require(Selects == 0, "carrier selection not folded to PHI");
    M = std::move(T.raw);
  }
  std::error_code EC; raw_fd_ostream Out(argv[1], EC); require(!EC, "output"); M->print(Out, nullptr);
  outs() << "PASS complementary guards share a diamond; PHI result; no speculative calls; parent immutable\n";
} catch (const std::exception &E) { errs() << E.what() << "\n"; return 1; } }
