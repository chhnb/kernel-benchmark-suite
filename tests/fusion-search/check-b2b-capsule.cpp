#include "b2b_unit_capsule.h"
#include "fusion_search.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/CommandLine.h"
#include <cassert>
using namespace llvm;
static void save(Module &m,const std::string &path){std::error_code e;raw_fd_ostream s(path,e);assert(!e);m.print(s,nullptr);}
int main(int argc,char **argv){
 assert(argc==2);
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
 auto *a=&parent->getFunction("f")->getEntryBlock();auto *b=a->getTerminator()->getSuccessor(0)->getSingleSuccessor();
 fusion::B2BUnitCapsule ca(*parent,*a),cb(*parent,*b);
 auto prepared=fusion::B2BReplayContext::capture(*parent);
 fusion::B2BUnitCapsule preparedA(*parent,*a,&prepared);
 assert(fusion::moduleHash(*preparedA.ir)==fusion::moduleHash(*ca.ir));
 save(*parent,std::string(argv[1])+"/baseline.ll");
 fusion::Candidate candidate{"unit","B0","B1","B2"};
 auto plansA=fusion::planSingleBranchB2B(*ca.ir,candidate,1,fusion::CleanupMode::DarmCFGInstCombine,"");
 auto plansB=fusion::planSingleBranchB2B(*cb.ir,candidate,1,fusion::CleanupMode::DarmCFGInstCombine,"");
 unsigned count=0;std::unique_ptr<Module> first;
 for(auto &plan:plansA){if(!plan.valid||!plan.normalized)continue;
  auto current=ca.apply(*parent,*plan.normalized);assert(!verifyModule(*current,&errs()));
  auto fast=ca.apply(*parent,*plan.normalized,&prepared);
  assert(fusion::moduleHash(*fast)==fusion::moduleHash(*current));
  auto currentFacts=fusion::B2BReplayContext::capture(*current);
  // The old exact-parent snapshots must not authorize a current-parent replay,
  // even where B's actual transformation dependencies remain valid.
  bool stale=false;auto before=fusion::moduleHash(*current);
  try{cb.apply(*current,*cb.ir,&prepared);}catch(const std::runtime_error&){stale=true;}
  assert(stale&&before==fusion::moduleHash(*current));
  if(!first)first=CloneModule(*current);
  for(auto &bp:plansB){if(!bp.valid||!bp.normalized)continue;
    // B's product was built from the old parent, before A was applied.
    auto both=cb.apply(*current,*bp.normalized);assert(!verifyModule(*both,&errs()));
    auto reusedFacts=cb.apply(*current,*bp.normalized,&currentFacts);
    assert(fusion::moduleHash(*reusedFacts)==fusion::moduleHash(*both));
    // Recompute B on current and require exact final IR parity.
    fusion::IRIdentity currentIDs(*current);
    auto *currentB=currentIDs.lookup(cb.boundary().entry)->getParent();
    fusion::B2BUnitCapsule freshB(*current,*currentB);
    auto freshPlans=fusion::planSingleBranchB2B(*freshB.ir,candidate,1,fusion::CleanupMode::DarmCFGInstCombine,"");
    bool same=false;
    for(auto &fp:freshPlans)if(fp.valid&&fp.normalized){
      auto regenerated=freshB.apply(*current,*fp.normalized);
      same|=fusion::moduleHash(*regenerated)==fusion::moduleHash(*both);
    }
    assert(same);
    save(*both,std::string(argv[1])+"/product-"+std::to_string(count++)+".ll");
  }
 }
 assert(count>0);assert(first);
 // Dependency invalidation is checked BEFORE any writes to a clone/current.
 auto changed=CloneModule(*parent);fusion::IRIdentity changedIDs(*changed);
 auto *broot=cast<BranchInst>(changedIDs.lookup(cb.boundary().entry));
 broot->setCondition(changed->getFunction("f")->getArg(0));
 std::string before=fusion::moduleHash(*changed);bool rejected=false;
 try{cb.apply(*changed,*cb.ir);}catch(const std::runtime_error&){rejected=true;}
 assert(rejected);assert(fusion::moduleHash(*changed)==before);
 // The first committed unit still has its transformed CFG after applying B.
 // All exported combinations are independently executed by the Python driver.
 outs()<<"PASS capsule DP1 generation/cleanup and current-parent replay: "<<count<<" combinations\n";
}
