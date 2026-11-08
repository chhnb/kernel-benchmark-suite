#include "llvm/IRReader/IRReader.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include <stdexcept>
using namespace llvm;
int main(int argc,char**argv){if(argc!=4)return 2;LLVMContext C;SMDiagnostic E;auto M=parseIRFile(argv[1],E,C);if(!M)return 3;auto*F=M->getFunction(argv[2]);if(!F)return 4;SmallVector<CallBase*,4> Calls;
for(auto&B:*F)for(auto&I:B)if(auto*CB=dyn_cast<CallBase>(&I))if(auto*G=CB->getCalledFunction())if(G->getName()=="__internal_accurate_pow")Calls.push_back(CB);
if(Calls.size()!=1)return 5;
for(auto*CB:Calls){InlineFunctionInfo IFI;if(!InlineFunction(*CB,IFI).isSuccess())return 6;}
if(verifyModule(*M,&errs()))return 7;std::error_code EC;raw_fd_ostream O(argv[3],EC);if(EC)return 8;M->print(O,nullptr);outs()<<"inlined exactly one __internal_accurate_pow call in target kernel\n";
}