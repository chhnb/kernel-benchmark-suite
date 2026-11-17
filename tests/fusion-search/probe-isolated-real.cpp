// Diagnostic only: scores every layout in the full current module. No reuse.
#include "isolated_b2b_greedy.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/FormatVariadic.h"
int main(int argc,char **argv){
 using namespace llvm;using namespace fusion;
 if(argc!=5)return 2;
 auto &options=cl::getRegisteredOptions();auto opt=options.find("two-entry-phi-node-folding-threshold");
 if(opt==options.end()||opt->second->addOccurrence(0,"two-entry-phi-node-folding-threshold","7"))return 2;
 LLVMContext ctx;SMDiagnostic err;auto m=parseIRFile(argv[1],err,ctx);
 if(!m){err.print(argv[0],errs());return 2;}auto *f=m->getFunction(argv[2]);if(!f)return 2;
 LLVM24Scorer scorer(argv[3],"off");IRIdentity ids(*m);
 auto round=makeRound(*m,argv[2],0,0,CleanupMode::None);
 json::Array results;unsigned n=0;
 for(auto &b:*f){auto unit=B2BOptimizationUnit::discover(b,ids);if(!unit.eligible())continue;
  auto *exit=ids.lookup(unit.exit)->getParent();if(exit->phis().empty())continue;
  B2BUnitCapsule capsule(*m,b);
  Trial control;control.valid=true;control.cleanupMode=CleanupMode::None;control.candidate={argv[2],"","","",0};
  control.normalized=capsule.apply(*m,*capsule.ir);control.raw=CloneModule(*control.normalized);
  control.before=features(*f);control.after=features(*control.normalized->getFunction(argv[2]));control.afterRaw=control.after;
  auto controlScore=evaluateTrial(*m,control,round,scorer);
  if(controlScore.status!=ScoreStatus::Scored)return 1;
  auto layouts=planSingleBranchB2B(*capsule.ir,{"unit","B0","B1","B2"},1,CleanupMode::DarmCFGInstCombine,"");
  for(auto &layout:layouts){if(!layout.valid||!layout.normalized)continue;
   Trial trial;trial.valid=true;trial.cleanupMode=CleanupMode::None;trial.candidate={argv[2],"","","",0};
   trial.normalized=capsule.apply(*m,*layout.normalized);trial.raw=CloneModule(*trial.normalized);
   trial.before=features(*f);trial.after=features(*trial.normalized->getFunction(argv[2]));trial.afterRaw=trial.after;
   auto score=evaluateTrial(*m,trial,round,scorer);
   if(score.status!=ScoreStatus::Scored){errs()<<"unscored layout\n";return 1;}
   std::string path=std::string(argv[4])+"/layout-"+std::to_string(n++)+".ll";std::error_code ec;
   raw_fd_ostream out(path,ec);if(ec)return 2;trial.normalized->print(out,nullptr);
   results.push_back(json::Object{{"candidate",unit.identity},{"unchanged_capsule_cost",controlScore.metrics.at("work_after")},{"plan_kind",layout.planKind},{"merge_path",layout.mergePath},{"file",path},{"before",score.metrics.at("work_before")},{"after",score.metrics.at("work_after")}});
  }
 }
 outs()<<formatv("{0:2}\n",json::Value(std::move(results)));
}
