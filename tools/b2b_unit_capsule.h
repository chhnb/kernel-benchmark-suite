#pragma once
#include "b2b_optimization_unit.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/ValueMapper.h"

namespace fusion {
// Disposable isolated IR for the first single-output, pure-integer unit.
// Cleanup of this module cannot read or mutate the rest of the parent function.
// Its score is NOT automatically the parent-function score: scoring integration
// must account for boundary branches/returns and validate the relevant TTI keys.
class B2BUnitCapsule {
  B2BOptimizationUnit unit;
  IRDependencySnapshot parent;
  std::string function;
public:
  std::unique_ptr<llvm::Module> ir;
  B2BUnitCapsule(llvm::Module &source,llvm::BasicBlock &root) {
    IRIdentity ids(source);unit=B2BOptimizationUnit::discover(root,ids);
    if(!unit.eligible())throw std::runtime_error("capsule: "+unit.rejection);
    auto *f=root.getParent();function=f->getName().str();
    auto *l=ids.lookup(unit.left)->getParent(),*r=ids.lookup(unit.right)->getParent();
    auto *join=ids.lookup(unit.exit)->getParent();
    if(std::distance(join->phis().begin(),join->phis().end())!=1)
      throw std::runtime_error("capsule: single_output_required");
    auto *output=&join->front();parent=IRDependencySnapshot::capture(source);
    ir=std::make_unique<llvm::Module>("isolated-b2b",source.getContext());
    ir->setDataLayout(source.getDataLayout());ir->setTargetTriple(source.getTargetTriple());
    std::vector<llvm::Type*> types;for(auto &a:f->args())types.push_back(a.getType());
    auto *cf=llvm::Function::Create(llvm::FunctionType::get(output->getType(),types,false),
       llvm::GlobalValue::ExternalLinkage,"unit",ir.get());
    // Input attributes are intentionally not imported as hidden facts. This
    // may change optimization; isolated cleanup remains a separate path.
    llvm::ValueToValueMapTy map;unsigned index=0;
    for(auto &a:f->args()){auto *arg=cf->getArg(index++);arg->setName(a.getName());map[&a]=arg;}
    auto *entry=llvm::BasicBlock::Create(source.getContext(),"entry",cf);
    auto *cl=llvm::BasicBlock::Create(source.getContext(),"left",cf);
    auto *cr=llvm::BasicBlock::Create(source.getContext(),"right",cf);
    auto *exit=llvm::BasicBlock::Create(source.getContext(),"exit",cf);
    map[&root]=entry;map[l]=cl;map[r]=cr;map[join]=exit;
    auto copy=[&](llvm::Instruction &i,llvm::BasicBlock *to){auto *c=i.clone();to->getInstList().push_back(c);map[&i]=c;};
    copy(*root.getTerminator(),entry);
    for(auto &i:*l)copy(i,cl);for(auto &i:*r)copy(i,cr);
    copy(*output,exit);
    for(auto &b:*cf)for(auto &i:b)llvm::RemapInstruction(&i,map,llvm::RF_NoModuleLevelChanges|llvm::RF_IgnoreMissingLocals);
    llvm::ReturnInst::Create(source.getContext(),map[output],exit);
    if(llvm::verifyModule(*ir,&llvm::errs()))throw std::runtime_error("invalid extracted capsule");
  }
  const B2BOptimizationUnit &boundary() const {return unit;}
  // Apply to a CLONE OF CURRENT, never restore a cached old parent module.
  // Failure is transactional: the caller retains current unchanged.
  std::unique_ptr<llvm::Module> apply(llvm::Module &current,const llvm::Module &product) const {
    auto result=llvm::CloneModule(current);
    auto currentFacts=IRDependencySnapshot::capture(*result);
    if(!parent.sameReads(currentFacts,unit.reads))
      throw std::runtime_error("capsule dependencies changed");
    IRIdentity ids(*result);
    auto *rootTerm=ids.lookup(unit.entry);if(!rootTerm)throw std::runtime_error("capsule root disappeared");
    auto *root=rootTerm->getParent();auto now=B2BOptimizationUnit::discover(*root,ids);
    if(!now.eligible()||now.identity!=unit.identity)throw std::runtime_error("capsule boundary changed");
    auto *f=result->getFunction(function),*cf=product.getFunction("unit");
    if(!f||!cf||cf->isDeclaration()||cf->arg_size()!=f->arg_size())
      throw std::runtime_error("invalid capsule signature");
    auto *l=ids.lookup(unit.left)->getParent(),*r=ids.lookup(unit.right)->getParent();
    auto *join=ids.lookup(unit.exit)->getParent();auto *output=llvm::dyn_cast<llvm::PHINode>(&join->front());
    if(!output || cf->getReturnType()!=output->getType() || llvm::pred_size(&cf->getEntryBlock()))
      throw std::runtime_error("invalid capsule output");
    // The artifact is allowed only the same pure operation language, plus
    // internal PHIs, branches and returns. No references into another function.
    for(auto &b:*cf)for(auto &i:b){
      if(!(llvm::isa<llvm::BinaryOperator>(i)||llvm::isa<llvm::ICmpInst>(i)||
           llvm::isa<llvm::SelectInst>(i)||llvm::isa<llvm::CastInst>(i)||
           llvm::isa<llvm::FreezeInst>(i)||llvm::isa<llvm::PHINode>(i)||llvm::isa<llvm::BranchInst>(i)||llvm::isa<llvm::ReturnInst>(i)))
        throw std::runtime_error("unsupported capsule product instruction");
      if(!i.isTerminator()&&!i.getType()->isIntegerTy())throw std::runtime_error("unsupported capsule product type");
      llvm::SmallVector<std::pair<unsigned,llvm::MDNode*>,4> metadata;i.getAllMetadata(metadata);
      for(auto &md:metadata)if(md.first!=i.getContext().getMDKindID("fusion.incremental.identity"))
        throw std::runtime_error("unsupported capsule product metadata");
    }
    if(llvm::verifyModule(product,&llvm::errs()))throw std::runtime_error("invalid capsule product");
    llvm::ValueToValueMapTy map;unsigned index=0;
    for(auto &a:cf->args()){
      if(a.getType()!=f->getArg(index)->getType())throw std::runtime_error("capsule argument type changed");
      map[&a]=f->getArg(index++);
    }
    std::vector<llvm::BasicBlock*> blocks;
    for(auto &b:*cf){auto *copy=llvm::BasicBlock::Create(result->getContext(),"unit."+std::to_string(unit.entry)+"."+b.getName().str(),f,join);map[&b]=copy;blocks.push_back(copy);}
    for(auto &b:*cf)for(auto &i:b){
      auto *copy=i.clone();copy->setMetadata("fusion.incremental.identity",nullptr);
      llvm::cast<llvm::BasicBlock>(map[&b])->getInstList().push_back(copy);map[&i]=copy;
    }
    for(auto *b:blocks)for(auto &i:*b)llvm::RemapInstruction(&i,map,llvm::RF_NoModuleLevelChanges|llvm::RF_IgnoreMissingLocals);
    while(output->getNumIncomingValues())output->removeIncomingValue(0u,false);
    unsigned returns=0;
    for(auto *b:blocks)if(auto *ret=llvm::dyn_cast<llvm::ReturnInst>(b->getTerminator())){
      auto *v=ret->getReturnValue();if(!v)throw std::runtime_error("void capsule return");
      output->addIncoming(v,b);llvm::BranchInst::Create(join,ret);ret->eraseFromParent();++returns;
    }
    if(!returns)throw std::runtime_error("capsule has no output");
    auto *identity=rootTerm->getMetadata("fusion.incremental.identity");
    llvm::BranchInst::Create(blocks.front(),rootTerm);rootTerm->eraseFromParent();
    if(!llvm::MergeBlockIntoPredecessor(blocks.front()))throw std::runtime_error("capsule entry splice failed");
    root->getTerminator()->setMetadata("fusion.incremental.identity",identity);
    l->dropAllReferences();r->dropAllReferences();l->eraseFromParent();r->eraseFromParent();
    if(llvm::verifyModule(*result,&llvm::errs()))throw std::runtime_error("invalid spliced capsule");
    auto after=IRDependencySnapshot::capture(*result);auto delta=currentFacts.changesTo(after);
    auto newWrites=unit.writes;newWrites.insert(delta.added.begin(),delta.added.end());
    if(!delta.within(unit.writes,newWrites))throw std::runtime_error("capsule write escaped boundary");
    return result;
  }
};
} // namespace fusion
