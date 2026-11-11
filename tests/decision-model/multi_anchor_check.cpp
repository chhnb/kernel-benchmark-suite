#include "complete_leaf_plan.h"
#include "decision_model.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include <cassert>

using namespace llvm;

int main(int argc,char **argv) {
  assert(argc==2);
  LLVMContext context;
  SMDiagnostic error;
  auto module=parseIRFile(argv[1],error,context);
  assert(module);
  auto &function=*module->getFunction("evaluate");
  auto decisions=decision::discover(function);
  BasicBlock *dispatch=nullptr;
  std::string reason;
  assert(decision::normalize(function,decisions.front(),0,reason,&dispatch));
  auto *branch=cast<BranchInst>(dispatch->getTerminator());
  auto *left=branch->getSuccessor(0),*right=branch->getSuccessor(1);

  // The directory's logical order may differ from the dispatch selector.
  auto order=[&](BasicBlock *block,int ordinal){
    auto *n=ConstantAsMetadata::get(ConstantInt::get(Type::getInt32Ty(context),ordinal));
    block->getTerminator()->setMetadata("decision.order",
      MDNode::get(context,{MDString::get(context,"reordered"),n,n}));
  };
  order(left,1);
  order(right,0);
  decisions=decision::discover(function);
  auto found=llvm::find_if(decisions,[&](const decision::Decision &d){return d.root==dispatch;});
  assert(found!=decisions.end()&&found->arms.size()==2);
  assert(found->arms[0].entry==right&&found->arms[1].entry==left);
  const auto *l=decision::armAtEntry(*found,left),*r=decision::armAtEntry(*found,right);
  assert(l&&r&&l==&found->arms[1]&&r==&found->arms[0]);
  assert(!decision::armAtEntry(*found,dispatch));

  fusion::LeafPlanOptions options{true,0,4};
  unsigned moved=0,anchors=0,groups=0;
  std::vector<std::string> pairs;
  // In a disposable clone, share the first left anchor with the
  // last right anchor. The opposite pairing would now cross it.
  ValueToValueMapTy map;
  auto crossing=CloneModule(*module,map);
  auto *leftFirst=cast<BranchInst>(left->getTerminator())->getSuccessor(0);
  auto *rightFirst=cast<BranchInst>(right->getTerminator())->getSuccessor(0);
  auto cloneBlock=[&](BasicBlock *block){return cast<BasicBlock>(map.lookup(block));};
  auto *leftLast=cloneBlock(leftFirst->getSingleSuccessor());
  auto *rightLast=cloneBlock(rightFirst->getSingleSuccessor());
  Value *choose=map.lookup(branch->getCondition());
  unsigned crossingGroups=0;
  assert(fusion::meldExclusiveBlocks(cloneBlock(leftFirst),rightLast,choose,
                                     options,crossingGroups,reason));
  assert(!fusion::meldExclusiveBlocks(leftLast,cloneBlock(rightFirst),choose,
                                      options,crossingGroups,reason));
  assert(reason=="ordered_or_crossing_anchor");
  assert(!verifyModule(*crossing,&errs()));
  assert(fusion::meldLeafPlan(function,options,
    {left,{l->blocks.begin(),l->blocks.end()}},
    {right,{r->blocks.begin(),r->blocks.end()}},
    dispatch,moved,anchors,groups,pairs,reason));
  assert(moved==2&&anchors>=2);
  assert(!verifyModule(*module,&errs()));
  module->print(outs(),nullptr);
}
