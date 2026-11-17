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
 assert(argc==4||argc==5);const bool external=argc==5&&StringRef(argv[4])=="external";
 const bool memoryContext=argc==5&&StringRef(argv[4])=="memory";
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

 if(external){
   auto *f=parent->getFunction("f");auto *a=cast<BranchInst>(f->getEntryBlock().getTerminator());
   auto *b=cast<BranchInst>(a->getSuccessor(0)->getSingleSuccessor()->getTerminator());
   auto *pc=new ICmpInst(a,ICmpInst::ICMP_NE,f->getArg(2),ConstantInt::get(Type::getInt32Ty(ctx),0),"pc");
   auto *qc=new ICmpInst(a,ICmpInst::ICMP_SLT,f->getArg(3),ConstantInt::get(Type::getInt32Ty(ctx),3),"qc");
   a->setCondition(pc);b->setCondition(qc);
 }
 if(memoryContext){
   auto *f=parent->getFunction("f");auto *term=f->getEntryBlock().getTerminator();
   auto *g=new GlobalVariable(*parent,Type::getInt32Ty(ctx),false,GlobalValue::InternalLinkage,
       ConstantInt::get(Type::getInt32Ty(ctx),0),"sink",nullptr,GlobalValue::NotThreadLocal,1);
   new StoreInst(f->getArg(2),g,term);
   auto *load=new LoadInst(Type::getInt32Ty(ctx),g,"outside.load",term);
   auto *ret=cast<ReturnInst>(f->back().getTerminator());
   auto *sum=BinaryOperator::CreateAdd(ret->getReturnValue(),load,"memory.sum",ret);ret->setOperand(0,sum);
   fusion::IRIdentity identities(*parent);
   auto reads=fusion::isolatedScoringReads(*f,identities);
   fusion::IncrementalCandidateQueue queue;
   auto ticket=queue.synchronize({{"unit",reads,0}}).front();
   queue.publish(ticket,{20,"plan",0,true});
   assert(queue.synchronize({{"unit",reads,0}}).empty());
   load->setAlignment(Align(8));
   auto changed=fusion::isolatedScoringReads(*f,identities);
   assert(reads!=changed);
   assert(queue.synchronize({{"unit",changed,0}}).size()==1);
   assert(!queue.ready()&&!queue.best());
   assert(!queue.publish(ticket,{99,"stale",0,true}));
   load->setAlignment(Align(4));
   assert(reads==fusion::isolatedScoringReads(*f,identities));
 }
 parent->setTargetTriple("amdgcn-amd-amdhsa");
 parent->setDataLayout("e-p:64:64-i64:64-n32:64");
 parent->getFunction("f")->addFnAttr("target-cpu","gfx906");
 save(*parent,std::string(argv[1])+"/baseline.ll");
 fusion::LLVM24Scorer fullScorer(argv[2],"off"),cacheScorer(argv[2],"off");
 auto full=fusion::runIsolatedB2BGreedy(*parent,"f",fullScorer,false,[&](const Module &m,unsigned n){save(m,std::string(argv[1])+"/full-"+std::to_string(n)+".ll");});
 auto cached=fusion::runIsolatedB2BGreedy(*parent,"f",cacheScorer,true,[&](const Module &m,unsigned n){save(m,std::string(argv[1])+"/cached-"+std::to_string(n)+".ll");});
 assert(full.stats.commits==2);assert(cached.stats.commits==2);
 assert(full.costs==cached.costs);if(!memoryContext)assert(full.costs==(external?std::vector<int64_t>({45,25}):std::vector<int64_t>({43,23})));
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
 if(external){
   auto changed=CloneModule(*parent);auto *f=changed->getFunction("f");
   auto *root=f->getEntryBlock().getTerminator()->getSuccessor(0)->getSingleSuccessor();
   auto *condition=cast<ICmpInst>(cast<BranchInst>(root->getTerminator())->getCondition());
   auto *base=BinaryOperator::CreateAdd(f->getArg(3),ConstantInt::get(Type::getInt32Ty(ctx),1),"condition.base",condition);
   condition->setOperand(0,base);
   fusion::B2BUnitCapsule capsule(*changed,*root);
   base->setOperand(1,ConstantInt::get(Type::getInt32Ty(ctx),2));
   auto before=fusion::moduleHash(*changed);bool invalidated=false;
   try{capsule.apply(*changed,*capsule.ir);}catch(const std::runtime_error&){invalidated=true;}
   assert(invalidated);assert(fusion::moduleHash(*changed)==before);
 }
 auto memory=parseIRFile(argv[3],err,ctx);assert(memory);
 assert(fusion::isolatedScalarTTIDomain(*memory->getFunction("choose")));
 auto excluded=fusion::runIsolatedB2BGreedy(*memory,"choose",cacheScorer,true);
 assert(excluded.stats.trials==0 && excluded.stats.commits==0);
 // External memory is admitted, but the memory-bearing arms are not pure units.
 // This does not reuse the global-cleanup 18 -> 21 gain certificate.
 outs()<<"PASS complete isolated trial reuse with real LLVM24 TTI and exact commit-chain parity\n";
}
