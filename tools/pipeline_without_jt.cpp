#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/IR/Module.h"
#include "llvm/InitializePasses.h"
#include "llvm/Pass.h"
#include "llvm/PassRegistry.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include <memory>
using namespace llvm;
static cl::opt<std::string> Input("input",cl::Required),Output("out",cl::Required),Log("log",cl::Required);
static cl::opt<unsigned> Level("level",cl::init(2));
static cl::opt<bool> Skip("skip-jump-threading",cl::init(true));
struct FilteredPM:legacy::PassManager{
 raw_ostream &log;unsigned removed=0;FilteredPM(raw_ostream&l):log(l){}
 void add(Pass*p)override{bool drop=Skip&&p->getPassName()=="Jump Threading";log<<(drop?"SKIP":"KEEP")<<"\t"<<p->getPassName()<<"\n";if(drop){++removed;delete p;}else legacy::PassManager::add(p);}
};
int main(int argc,char**argv){
 InitializeAllTargets();InitializeAllTargetMCs();InitializeAllAsmPrinters();
 auto&r=*PassRegistry::getPassRegistry();initializeCore(r);initializeScalarOpts(r);initializeIPO(r);initializeAnalysis(r);initializeTransformUtils(r);initializeInstCombine(r);initializeVectorization(r);initializeTarget(r);
 cl::ParseCommandLineOptions(argc,argv);LLVMContext c;SMDiagnostic e;auto m=parseIRFile(Input,e,c);if(!m){e.print(argv[0],errs());return 1;}
 std::string error;auto*t=TargetRegistry::lookupTarget(m->getTargetTriple(),error);if(!t){errs()<<error;return 1;}
 TargetOptions options;std::unique_ptr<TargetMachine> tm(t->createTargetMachine(m->getTargetTriple(),"gfx906","",options,Reloc::PIC_));
 std::error_code ec;raw_fd_ostream log(Log,ec);if(ec)return 2;FilteredPM pm(log);legacy::FunctionPassManager fp(m.get());
 fp.add(createTargetTransformInfoWrapperPass(tm->getTargetIRAnalysis()));pm.add(createTargetTransformInfoWrapperPass(tm->getTargetIRAnalysis()));
 PassManagerBuilder builder;builder.OptLevel=Level;builder.SizeLevel=0;builder.LoopVectorize=true;builder.SLPVectorize=true;builder.Inliner=createFunctionInliningPass(Level,0,false);tm->adjustPassManager(builder);
 builder.populateFunctionPassManager(fp);builder.populateModulePassManager(pm);
 fp.doInitialization();for(auto&f:*m)if(!f.isDeclaration())fp.run(f);fp.doFinalization();pm.run(*m);
 if(verifyModule(*m,&errs()))return 3;if(Skip&&pm.removed!=2){errs()<<"unexpected JT count "<<pm.removed<<"\n";return 4;}
 raw_fd_ostream out(Output,ec);if(ec)return 2;m->print(out,nullptr);outs()<<"removed Jump Threading passes: "<<pm.removed<<"\n";
}
