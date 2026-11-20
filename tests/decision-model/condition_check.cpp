#include "condition_simplify.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/IR/Verifier.h"
using namespace llvm;
int main(int argc,char **argv){LLVMContext c;SMDiagnostic e;auto m=parseIRFile(argv[1],e,c);if(!m)return 2;for(auto &f:*m)for(auto &b:f)if(auto *ret=dyn_cast<ReturnInst>(b.getTerminator()))if(auto *i=dyn_cast<Instruction>(ret->getReturnValue()))decision::simplifyCondition(i);if(verifyModule(*m,&errs()))return 3;m->print(outs(),nullptr);}
