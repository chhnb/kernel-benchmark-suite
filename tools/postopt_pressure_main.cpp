#include "ir_pressure.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;
int main(int argc,char **argv) {
  if(argc!=3){errs()<<"usage: postopt-pressure IR FUNCTION\n";return 2;}
  LLVMContext context;SMDiagnostic error;
  auto module=parseIRFile(argv[1],error,context);
  if(!module){error.print(argv[0],errs());return 2;}
  if(verifyModule(*module,&errs()))return 2;
  auto *function=module->getFunction(argv[2]);
  if(!function||function->isDeclaration()){errs()<<"defined function required\n";return 2;}
  auto pressure=fusion::irPressure(*function);
  outs()<<"{\"peak_slots32\":"<<pressure.peakSlots32
        <<",\"peak_values\":"<<pressure.peakValues
        <<",\"reachable_blocks\":"<<pressure.reachableBlocks
        <<",\"complete\":"<<(pressure.complete?"true":"false")
        <<",\"uniformity\":\"not_requested_total_pressure_only\"}\n";
  return pressure.complete?0:3;
}
