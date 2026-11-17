#include "isolated_b2b_greedy.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FormatVariadic.h"
int main(int argc,char **argv){
 if(argc!=3)return 2;llvm::LLVMContext ctx;llvm::SMDiagnostic error;
 auto m=llvm::parseIRFile(argv[1],error,ctx);if(!m){error.print(argv[0],llvm::errs());return 1;}
 auto *f=m->getFunction(argv[2]);if(!f)return 1;
 fusion::IRIdentity ids(*m);unsigned roots=0,admitted=0,roundtrips=0;std::map<std::string,unsigned> reasons,replayErrors;
 for(auto &b:*f){auto *br=llvm::dyn_cast<llvm::BranchInst>(b.getTerminator());if(!br||!br->isConditional())continue;++roots;
  auto unit=fusion::B2BOptimizationUnit::discover(b,ids);
  if(!unit.eligible()){++reasons[unit.rejection];continue;}
  auto *exit=ids.lookup(unit.exit)->getParent();
  if(std::distance(exit->phis().begin(),exit->phis().end())!=1){++reasons["single_output_required"];continue;}
  ++admitted;
  try {fusion::B2BUnitCapsule capsule(*m,b);auto replay=capsule.apply(*m,*capsule.ir);
   if(llvm::verifyModule(*replay,&llvm::errs()))throw std::runtime_error("roundtrip verifier failed");
   ++roundtrips;
  }catch(const std::runtime_error &e){++replayErrors[e.what()];}
 }
 std::string snapshotError;
 if(admitted)try{fusion::IRDependencySnapshot::capture(*m);}catch(const std::runtime_error &e){snapshotError=e.what();}
 llvm::json::Object unknown;std::map<std::string,unsigned> opcodes;
 for(auto &b:*f)for(auto &i:b)if(!fusion::gcnQuoteKey(i))++opcodes[i.getOpcodeName()];
 for(auto &p:opcodes)unknown[p.first]=int64_t(p.second);
 llvm::json::Object replayWhy;for(auto &p:replayErrors)replayWhy[p.first]=int64_t(p.second);
 llvm::json::Object why;for(auto &p:reasons)why[p.first]=int64_t(p.second);
 llvm::outs()<<llvm::formatv("{0:2}\n",llvm::json::Value(llvm::json::Object{{"function",f->getName().str()},{"conditional_roots",int64_t(roots)},{"isolatable_units",int64_t(admitted)},{"whole_function_tti_domain",fusion::isolatedScalarTTIDomain(*f)},{"rejections",std::move(why)},{"snapshot_error",snapshotError},{"verified_capsule_roundtrips",int64_t(roundtrips)},{"capsule_roundtrip_errors",std::move(replayWhy)},{"unknown_quote_opcodes",std::move(unknown)}}));
}
