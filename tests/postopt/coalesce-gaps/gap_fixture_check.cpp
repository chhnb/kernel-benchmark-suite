#include "fusion_search.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include <stdexcept>
using namespace llvm;using namespace fusion;
int main(int argc,char**argv){try{
 if(argc!=3)throw std::runtime_error("input/output paths required");LLVMContext c;SMDiagnostic d;auto m=parseIRFile(argv[1],d,c);if(!m){d.print("fixture",errs());return 1;}
 int64_t oldBlocks=0;
 for(bool enabled:{false,true}){
  Candidate p{enabled?"gap_on":"gap_off","B0","B1","B2",0};p.coalesceGaps=enabled;auto h=moduleHash(*m);
  auto t=tryPair(*m,p,0,3,CleanupMode::None);
  if(!t.valid||moduleHash(*m)!=h||verifyModule(*t.raw,&errs()))throw std::runtime_error("invalid/parent mutated: "+t.reason);
  outs()<<p.function<<" groups="<<t.coalescedGapGroups<<" blocks="<<t.afterRaw.blocks<<"\n";
  if(enabled&&(!t.coalescedGapGroups||t.afterRaw.blocks>=oldBlocks))throw std::runtime_error("grouping was not exercised");
  oldBlocks=t.afterRaw.blocks;m=std::move(t.raw);
 }
 std::error_code ec;raw_fd_ostream out(argv[2],ec);if(ec)throw std::runtime_error(ec.message());m->print(out,nullptr);return 0;
}catch(const std::exception&e){errs()<<e.what()<<"\n";return 1;}}
