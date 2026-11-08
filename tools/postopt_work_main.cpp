// Offline inspection of the exact static-work extractor used by V1/V2.
#include "postopt_scorer.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/ModuleSlotTracker.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/SourceMgr.h"
using namespace llvm;
int main(int argc,char **argv){
 if(argc!=3){errs()<<"usage: postopt-work IR FUNCTION\n";return 2;}
 LLVMContext C;SMDiagnostic Error;auto M=parseIRFile(argv[1],Error,C);
 if(!M){Error.print(argv[0],errs());return 2;}
 if(verifyModule(*M,&errs()))return 2;
 auto *F=M->getFunction(argv[2]);if(!F||F->isDeclaration())return 2;
 auto X=fusion::postOptFeatures(*F);
 ModuleSlotTracker Slots(M.get());Slots.incorporateFunction(*F);
 auto operand=[&](const Value *V){std::string S;raw_string_ostream OS(S);V->printAsOperand(OS,false,Slots);OS.flush();return S;};
 json::Array Blocks;
 double Total=0;uint64_t Instructions=0,Unknown=0;
 for(auto &BB:*F){auto ID=operand(&BB);auto It=X.blockWork.find(ID);if(It==X.blockWork.end())continue;
  auto &W=It->second;Total+=W.work;Instructions+=W.instructions;Unknown+=W.unknown;
  json::Object Categories;for(auto &KV:W.categories)Categories[KV.first]=KV.second;
  json::Array Successors;for(auto *Next:successors(&BB))Successors.push_back(operand(Next));
  json::Object Item{{"block",ID},{"work",W.work},{"instructions",int64_t(W.instructions)},
    {"unknown",int64_t(W.unknown)},{"categories",std::move(Categories)},
    {"successors",std::move(Successors)}};
  if(auto *B=dyn_cast<BranchInst>(BB.getTerminator()))if(B->isConditional())Item["branch_condition"]=operand(B->getCondition());
  Blocks.push_back(std::move(Item));
 }
 if(Total!=X.work||Instructions!=X.instructions||Unknown!=X.unknown){errs()<<"block aggregate mismatch\n";return 3;}
 json::Object Output{{"schema","postopt-block-work-v1"},{"function",F->getName().str()},
   {"target_triple",M->getTargetTriple()},{"target_cpu",F->getFnAttribute("target-cpu").getValueAsString().str()},
   {"cost_kind","TTI_reciprocal_throughput"},{"scope","reachable static work; no execution weights"},
   {"target_available",X.targetAvailable},{"work",X.work},{"unknown",int64_t(X.unknown)},
   {"instructions",int64_t(X.instructions)},{"blocks",std::move(Blocks)}};
 outs()<<formatv("{0:2}\n",json::Value(std::move(Output)));
 return X.targetAvailable?0:3;
}
