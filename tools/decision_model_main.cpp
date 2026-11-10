#include "decision_model.h"
#include "decision_compare.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/FormatVariadic.h"
#include "llvm/Transforms/Utils/Cloning.h"
using namespace llvm;
int main(int argc,char **argv){
 if(argc!=3&&argc!=6&&argc!=5){errs()<<"usage: decision-model input.ll function [decision-index left-index output.ll]\n";return 2;}
 LLVMContext c;SMDiagnostic err;auto m=parseIRFile(argv[1],err,c);if(!m){err.print(argv[0],errs());return 1;}
 if(verifyModule(*m,&errs()))return 2;
 auto *f=m->getFunction(argv[2]);if(!f||f->isDeclaration())return 2;
 auto ds=decision::discover(*f);
 if(argc==5){
  if(StringRef(argv[3])!="--compare")return 2;
  auto buf=MemoryBuffer::getFile(argv[4]);if(!buf)return 2;
  auto j=json::parse((*buf)->getBuffer());if(!j){consumeError(j.takeError());return 2;}auto *o=j->getAsObject();if(!o)return 2;
  outs()<<formatv("{0:2}\n",json::Value(decision::compareLegacy(*f,ds,*o)));return 0;
 }
 if(argc==6&&sys::fs::exists(argv[5])){errs()<<"output already exists\n";return 2;}
 if(argc==6){unsigned di=std::stoul(argv[3]),left=std::stoul(argv[4]);if(di>=ds.size())return 2;
  auto trial=CloneModule(*m);auto *tf=trial->getFunction(argv[2]);
  // Only the disposable trial receives provenance; discovery stays read-only.
  for(auto &bb:*tf)if(!bb.getTerminator()->getMetadata("decision.origin")){
   std::string label;raw_string_ostream stream(label);bb.printAsOperand(stream,false);stream.flush();
   bb.getTerminator()->setMetadata("decision.origin",MDNode::get(c,MDString::get(c,tf->getName().str()+":"+label)));
  }
  auto td=decision::discover(*tf);std::string why;
  if(!decision::normalize(*tf,td[di],left,why)){errs()<<why<<"\n";return 3;}
  std::error_code ec;raw_fd_ostream out(argv[5],ec,sys::fs::OF_None);if(ec){errs()<<ec.message();return 1;}trial->print(out,nullptr);
  outs()<<formatv("{0:2}\n",json::Value(decision::describe(decision::discover(*tf))));
 }else outs()<<formatv("{0:2}\n",json::Value(decision::describe(ds)));
}
