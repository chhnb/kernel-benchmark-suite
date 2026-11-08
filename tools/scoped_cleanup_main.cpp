// Experimental LLVM12 cleanup of an explicitly bounded trial scope.
// No instruction motion, new instructions, block deletion, or CFG rewrites.
#include "llvm/IRReader/IRReader.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Analysis/InstructionSimplify.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/FormatVariadic.h"
#include <set>
#include <vector>
using namespace llvm;
int main(int argc,char **argv) {
  if(argc<7){errs()<<"usage: scoped-cleanup INPUT REFERENCE FUNCTION OUTPUT REPORT BLOCK...\n";return 2;}
  LLVMContext ctx;SMDiagnostic diag;
  auto m=parseIRFile(argv[1],diag,ctx), ref=parseIRFile(argv[2],diag,ctx);
  if(!m||!ref){diag.print(argv[0],errs());return 2;}
  auto*f=m->getFunction(argv[3]);auto*rf=ref->getFunction(argv[3]);
  if(!f||!rf||verifyModule(*m,&errs()))return 2;
  std::set<std::string> original,requested;
  for(auto&b:*rf){if(!b.hasName()){errs()<<"unnamed reference blocks unsupported\n";return 2;}original.insert(b.getName().str());}
  bool emptyBlocks=false;
  for(int n=6;n<argc;++n){if(StringRef(argv[n])=="--empty-blocks"){emptyBlocks=true;continue;}if(!original.count(argv[n])){errs()<<"unknown reference boundary "<<argv[n]<<"\n";return 2;}requested.insert(argv[n]);}
  std::vector<BasicBlock*> scope;json::Array selected;
  for(auto&b:*f)if(!original.count(b.getName().str())||requested.count(b.getName().str())){
    scope.push_back(&b);selected.push_back(json::Object{{"block",b.getName().str()},{"reason",original.count(b.getName().str())?"explicit_original_boundary":"new_trial_block"}});
  }
  unsigned simplified=0,dead=0,cse=0,iterations=0,externalUses=0,removedBlocks=0;
  std::set<BasicBlock*> selectedSet(scope.begin(),scope.end());
  auto replace=[&](Instruction&i,Value*v){for(auto*u:i.users())if(auto*user=dyn_cast<Instruction>(u))if(!selectedSet.count(user->getParent()))++externalUses;i.replaceAllUsesWith(v);i.eraseFromParent();};
  for(;iterations<32;++iterations){bool changed=false;
    for(auto*b:scope){std::vector<Instruction*> available;
      for(auto it=b->begin();it!=b->end();){Instruction&i=*it++;
        if(i.isTerminator()||isa<DbgInfoIntrinsic>(i))continue;
        if(isInstructionTriviallyDead(&i)){i.eraseFromParent();++dead;changed=true;continue;}
        if(Value*v=SimplifyInstruction(&i,SimplifyQuery(m->getDataLayout(),&i))){if(v!=&i){replace(i,v);++simplified;changed=true;continue;}}
        // Only block-local, pure, non-memory expressions; never speculate calls.
        bool pure=!i.getType()->isVoidTy()&&!i.mayReadOrWriteMemory()&&!i.mayHaveSideEffects()&&!isa<PHINode>(i)&&!isa<AllocaInst>(i)&&!isa<CallBase>(i);
        Instruction*same=nullptr;if(pure)for(auto*prior:available)if(i.isIdenticalTo(prior)){same=prior;break;}
        if(same){replace(i,same);++cse;changed=true;continue;}
        if(pure)available.push_back(&i);
      }
    }
    if(emptyBlocks)for(auto it=scope.begin();it!=scope.end();++it){auto*b=*it;
      auto*br=dyn_cast<BranchInst>(b->getTerminator());
      if(b==&f->getEntryBlock()||b->hasAddressTaken()||b->size()!=1||!br||!br->isUnconditional())continue;
      auto*succ=br->getSuccessor(0);bool bounded=succ!=b&&selectedSet.count(succ);
      for(auto*pred:predecessors(b))bounded &= selectedSet.count(pred)!=0;
      if(!bounded)continue;
      if(TryToSimplifyUncondBranchFromEmptyBlock(b)){
        selectedSet.erase(b);scope.erase(it);++removedBlocks;changed=true;break;
      }
    }
    if(!changed){++iterations;break;}
  }
  if(iterations>=32){errs()<<"cleanup iteration cap\n";return 3;}
  if(verifyModule(*m,&errs()))return 3;
  std::error_code ec;raw_fd_ostream out(argv[4],ec);if(ec)return 3;m->print(out,nullptr);out.close();
  raw_fd_ostream report(argv[5],ec);if(ec)return 3;
  report<<formatv("{0:2}\n",json::Value(json::Object{{"schema","scoped-scalar-cleanup-experiment-v1"},{"scope",std::move(selected)},{"iterations",int64_t(iterations)},{"simplified",int64_t(simplified)},{"dead",int64_t(dead)},{"local_cse",int64_t(cse)},{"outside_scope_operand_replacements",int64_t(externalUses)},{"empty_blocks_removed",int64_t(removedBlocks)},{"cfg_policy",emptyBlocks?"only empty unconditional blocks with all neighbors in scope; no computation motion":"unchanged; terminators skipped; no motion or new instructions"},{"verifier_passed",true}}));
}
