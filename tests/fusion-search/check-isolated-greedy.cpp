#include "isolated_b2b_greedy.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/CommandLine.h"
#include <cassert>
using namespace llvm;
static void save(const Module &m,const std::string &path){std::error_code e;raw_fd_ostream s(path,e);assert(!e);m.print(s,nullptr);}
int main(int argc,char **argv){
 assert(argc==4);
 const StringRef option="two-entry-phi-node-folding-threshold";
 auto &registered=cl::getRegisteredOptions();auto found=registered.find(option);
 assert(found!=registered.end());assert(!found->second->addOccurrence(0,option,"7"));
 LLVMContext ctx;SMDiagnostic err;
 auto parent=parseAssemblyString(R"(
 define i32 @f(i1 %p,i1 %q,i32 %x,i32 %y) {
 A: br i1 %p,label %AL,label %AR
 AL: %a=add i32 %x,1
 %aa=mul i32 %a,3
 br label %B
 AR: %b=add i32 %x,2
 %bb=mul i32 %b,3
 br label %B
 B: %u=phi i32 [%aa,%AL],[%bb,%AR]
 br i1 %q,label %BL,label %BR
 BL: %c=add i32 %y,3
 %cc=mul i32 %c,7
 br label %out
 BR: %d=add i32 %y,4
 %dd=mul i32 %d,7
 br label %out
 out: %v=phi i32 [%cc,%BL],[%dd,%BR]
 %sum=add i32 %u,%v
 ret i32 %sum
 })",err,ctx);assert(parent);

 parent->setTargetTriple("amdgcn-amd-amdhsa");
 parent->setDataLayout("e-p:64:64-i64:64-n32:64");
 parent->getFunction("f")->addFnAttr("target-cpu","gfx906");
 save(*parent,std::string(argv[1])+"/baseline.ll");
 fusion::LLVM24Scorer fullScorer(argv[2],"off"),cacheScorer(argv[2],"off");
 auto full=fusion::runIsolatedB2BGreedy(*parent,"f",fullScorer,false,[&](const Module &m,unsigned n){save(m,std::string(argv[1])+"/full-"+std::to_string(n)+".ll");});
 auto cached=fusion::runIsolatedB2BGreedy(*parent,"f",cacheScorer,true,[&](const Module &m,unsigned n){save(m,std::string(argv[1])+"/cached-"+std::to_string(n)+".ll");});
 assert(full.stats.commits==2);assert(cached.stats.commits==2);
 assert(full.costs==cached.costs);assert(full.costs==std::vector<int64_t>({48,33}));
 assert(full.identities==cached.identities);assert(full.gains==cached.gains);assert(full.hashes==cached.hashes);
 assert(fusion::moduleHash(*full.module)==fusion::moduleHash(*cached.module));
 assert(full.stats.trials==3);assert(cached.stats.trials==2);assert(cached.stats.reusedTrials==1);
 assert(full.stats.generations>cached.stats.generations);
 assert(full.stats.layoutCleanups>cached.stats.layoutCleanups);
 assert(full.stats.scores>cached.stats.scores);
 auto emit=[&](StringRef name,const fusion::IsolatedGreedyResult &r){
   outs()<<name<<" trials="<<r.stats.trials<<" generations="<<r.stats.generations
     <<" cleanups="<<r.stats.layoutCleanups<<" scores="<<r.stats.scores
     <<" reuse="<<r.stats.reusedTrials<<" commits="<<r.stats.commits<<" gains=";
   for(auto g:r.gains)outs()<<g<<",";outs()<<"\n";
 };
 emit("full",full);emit("cached",cached);
 // The runtime output is GPU-target IR; CPU-only semantic checks use copies
 // with the irrelevant target identity removed, preserving every instruction.
 for(auto entry:{std::make_pair("cpu-baseline.ll",parent.get()),std::make_pair("cpu-final.ll",cached.module.get())}){
   auto cpu=CloneModule(*entry.second);cpu->setTargetTriple("x86_64-unknown-linux-gnu");cpu->setDataLayout("");
   cpu->getFunction("f")->removeFnAttr("target-cpu");save(*cpu,std::string(argv[1])+"/"+entry.first);
 }
 auto memory=parseIRFile(argv[3],err,ctx);assert(memory);
 assert(!fusion::isolatedScalarTTIDomain(*memory->getFunction("choose")));
 bool rejected=false;
 try{fusion::runIsolatedB2BGreedy(*memory,"choose",cacheScorer,true);}catch(const std::runtime_error&){rejected=true;}
 assert(rejected); // No memory-dependent gain is admitted to this certificate.
 outs()<<"PASS complete isolated trial reuse with real LLVM24 TTI and exact commit-chain parity\n";
}
