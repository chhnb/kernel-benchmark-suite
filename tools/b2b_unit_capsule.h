#pragma once
#include "b2b_optimization_unit.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/ValueMapper.h"
#include <functional>

namespace fusion {
// Disposable isolated IR for a pure-integer unit with scalar or tuple outputs.
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
    std::vector<llvm::PHINode*> outputs;std::vector<llvm::Type*> outputTypes;
    for(auto &phi:join->phis()){outputs.push_back(&phi);outputTypes.push_back(phi.getType());}
    if(outputs.empty())throw std::runtime_error("capsule: output_required");
    auto *returnType=outputs.size()==1?outputTypes.front():llvm::StructType::get(source.getContext(),outputTypes);
    parent=IRDependencySnapshot::capture(source);
    ir=std::make_unique<llvm::Module>("isolated-b2b",source.getContext());
    ir->setDataLayout(source.getDataLayout());ir->setTargetTriple(source.getTargetTriple());
    std::vector<llvm::Type*> types;for(auto &a:f->args())types.push_back(a.getType());
    for(auto id:unit.inputs)types.push_back(ids.lookup(id)->getType());
    auto *cf=llvm::Function::Create(llvm::FunctionType::get(returnType,types,false),
       llvm::GlobalValue::ExternalLinkage,"unit",ir.get());
    // Input attributes are intentionally not imported as hidden facts. This
    // may change optimization; isolated cleanup remains a separate path.
    llvm::ValueToValueMapTy map;unsigned index=0;
    for(auto &a:f->args()){auto *arg=cf->getArg(index++);arg->setName(a.getName());map[&a]=arg;}
    for(auto id:unit.inputs){auto *arg=cf->getArg(index++);arg->setName("input"+std::to_string(id));map[ids.lookup(id)]=arg;}
    auto *entry=llvm::BasicBlock::Create(source.getContext(),"entry",cf);
    auto *cl=llvm::BasicBlock::Create(source.getContext(),"left",cf);
    auto *cr=llvm::BasicBlock::Create(source.getContext(),"right",cf);
    auto *exit=llvm::BasicBlock::Create(source.getContext(),"exit",cf);
    map[&root]=entry;map[l]=cl;map[r]=cr;map[join]=exit;
    auto copy=[&](llvm::Instruction &i,llvm::BasicBlock *to){auto *c=i.clone();llvm::SmallVector<std::pair<unsigned,llvm::MDNode*>,4> md;c->getAllMetadata(md);for(auto &x:md)c->setMetadata(x.first,nullptr);to->getInstList().push_back(c);map[&i]=c;};
    copy(*root.getTerminator(),entry);
    for(auto &i:*l)copy(i,cl);for(auto &i:*r)copy(i,cr);
    for(auto *output:outputs)copy(*output,exit);
    for(auto &b:*cf)for(auto &i:b)llvm::RemapInstruction(&i,map,llvm::RF_NoModuleLevelChanges|llvm::RF_IgnoreMissingLocals);
    llvm::IRBuilder<> builder(exit);llvm::Value *value=map[outputs.front()];
    if(outputs.size()>1){value=llvm::UndefValue::get(returnType);
      for(unsigned i=0;i<outputs.size();++i)value=builder.CreateInsertValue(value,map[outputs[i]],{i});}
    builder.CreateRet(value);
    if(llvm::verifyModule(*ir,&llvm::errs()))throw std::runtime_error("invalid extracted capsule");
  }
  const B2BOptimizationUnit &boundary() const {return unit;}
  // Apply to a CLONE OF CURRENT, never restore a cached old parent module.
  // Failure is transactional: the caller retains current unchanged.
  std::unique_ptr<llvm::Module> apply(llvm::Module &current,const llvm::Module &product) const {
    auto result=llvm::CloneModule(current);
    auto currentFacts=IRDependencySnapshot::capture(*result);
    if(!parent.sameReads(currentFacts,unit.reads,unit.placementIndependentReads()))
      throw std::runtime_error("capsule dependencies changed");
    IRIdentity ids(*result);
    auto *rootTerm=ids.lookup(unit.entry);if(!rootTerm)throw std::runtime_error("capsule root disappeared");
    auto *root=rootTerm->getParent();auto now=B2BOptimizationUnit::discover(*root,ids);
    if(!now.eligible()||now.identity!=unit.identity||now.inputs!=unit.inputs)throw std::runtime_error("capsule boundary changed");
    auto *f=result->getFunction(function),*cf=product.getFunction("unit");
    if(!f||!cf||cf->isDeclaration()||cf->arg_size()!=f->arg_size()+unit.inputs.size())
      throw std::runtime_error("invalid capsule signature");
    auto *l=ids.lookup(unit.left)->getParent(),*r=ids.lookup(unit.right)->getParent();
    auto *join=ids.lookup(unit.exit)->getParent();
    std::vector<llvm::PHINode*> outputs;std::vector<llvm::Type*> outputTypes;
    for(auto &phi:join->phis()){outputs.push_back(&phi);outputTypes.push_back(phi.getType());}
    auto *returnType=outputs.size()==1?outputTypes.front():llvm::StructType::get(current.getContext(),outputTypes);
    if(outputs.empty() || cf->getReturnType()!=returnType || llvm::pred_size(&cf->getEntryBlock()))
      throw std::runtime_error("invalid capsule output");
    // The artifact is allowed only the same pure operation language, plus
    // internal PHIs, branches and returns. No references into another function.
    for(auto &b:*cf)for(auto &i:b){
      if(!(llvm::isa<llvm::BinaryOperator>(i)||llvm::isa<llvm::ICmpInst>(i)||
           llvm::isa<llvm::SelectInst>(i)||llvm::isa<llvm::CastInst>(i)||
           llvm::isa<llvm::StoreInst>(i)||llvm::isa<llvm::InsertValueInst>(i)||llvm::isa<llvm::ExtractValueInst>(i)||
           llvm::isa<llvm::FreezeInst>(i)||llvm::isa<llvm::PHINode>(i)||llvm::isa<llvm::BranchInst>(i)||llvm::isa<llvm::ReturnInst>(i)))
        throw std::runtime_error("unsupported capsule product instruction");
      if(!i.isTerminator()&&!i.getType()->isIntegerTy()&&!i.getType()->isPointerTy()&&!llvm::isa<llvm::InsertValueInst>(i)&&!llvm::isa<llvm::StoreInst>(i))throw std::runtime_error("unsupported capsule product type");
      if(auto *store=llvm::dyn_cast<llvm::StoreInst>(&i))
        if(!store->isSimple()||!store->getValueOperand()->getType()->isIntegerTy())
          throw std::runtime_error("unsupported capsule store");
      llvm::SmallVector<std::pair<unsigned,llvm::MDNode*>,4> metadata;i.getAllMetadata(metadata);
      for(auto &md:metadata)if(md.first!=i.getContext().getMDKindID("fusion.incremental.identity"))
        throw std::runtime_error("unsupported capsule product metadata");
    }
    // Every path in the product must reach an output; preserve reachability
    // of the original outside CFG when replacing the simple diamond.
    std::map<const llvm::BasicBlock*,unsigned> colors;
    std::function<void(const llvm::BasicBlock*)> visit=[&](const llvm::BasicBlock *b){
      if(colors[b]==1)throw std::runtime_error("cyclic capsule product");
      if(colors[b]==2)return;
      colors[b]=1;for(auto *next:llvm::successors(b))visit(next);colors[b]=2;
    };
    for(auto &b:*cf)visit(&b);
    if(llvm::verifyModule(product,&llvm::errs()))throw std::runtime_error("invalid capsule product");
    llvm::ValueToValueMapTy map;unsigned index=0;
    for(auto &a:f->args()){
      auto *formal=cf->getArg(index++);
      if(formal->getType()!=a.getType())throw std::runtime_error("capsule argument type changed");
      map[formal]=&a;
    }
    for(auto id:unit.inputs){
      auto *value=ids.lookup(id);auto *formal=cf->getArg(index++);
      if(!value||value->getType()!=formal->getType())throw std::runtime_error("capsule external input changed");
      map[formal]=value;
    }
    std::vector<llvm::BasicBlock*> blocks;
    for(auto &b:*cf){auto *copy=llvm::BasicBlock::Create(result->getContext(),"unit."+std::to_string(unit.entry)+"."+b.getName().str(),f,join);map[&b]=copy;blocks.push_back(copy);}
    llvm::SmallVector<llvm::Instruction*,8> tupleCopies;
    for(auto &b:*cf)for(auto &i:b){
      auto *copy=i.clone();
      if(llvm::isa<llvm::InsertValueInst>(copy)||llvm::isa<llvm::ExtractValueInst>(copy))tupleCopies.push_back(copy);copy->setMetadata("fusion.incremental.identity",nullptr);
      llvm::cast<llvm::BasicBlock>(map[&b])->getInstList().push_back(copy);map[&i]=copy;
    }
    for(auto *b:blocks)for(auto &i:*b)llvm::RemapInstruction(&i,map,llvm::RF_NoModuleLevelChanges|llvm::RF_IgnoreMissingLocals);
    for(auto *output:outputs)while(output->getNumIncomingValues())output->removeIncomingValue(0u,false);
    unsigned returns=0;
    for(auto *b:blocks)if(auto *ret=llvm::dyn_cast<llvm::ReturnInst>(b->getTerminator())){
      auto *v=ret->getReturnValue();if(!v)throw std::runtime_error("void capsule return");
      for(unsigned i=0;i<outputs.size();++i){
        auto *part=outputs.size()==1?v:llvm::FindInsertedValue(v,{i});
        // The planner must preserve the explicit return tuple. Do not leave
        // aggregate operations in the parent or silently invent a new ABI.
        if(!part)throw std::runtime_error("unresolved capsule output tuple");
        outputs[i]->addIncoming(part,b);
      }
      llvm::BranchInst::Create(join,ret);ret->eraseFromParent();++returns;
    }
    if(!returns)throw std::runtime_error("capsule has no output");
    auto *identity=rootTerm->getMetadata("fusion.incremental.identity");
    llvm::BranchInst::Create(blocks.front(),rootTerm);rootTerm->eraseFromParent();
    if(!llvm::MergeBlockIntoPredecessor(blocks.front()))throw std::runtime_error("capsule entry splice failed");
    root->getTerminator()->setMetadata("fusion.incremental.identity",identity);
    l->dropAllReferences();r->dropAllReferences();l->eraseFromParent();r->eraseFromParent();
    // Deterministic boundary normalization, not full-function cleanup. The
    // original exit has only the two replaced predecessors.
    // Each single-incoming output can be substituted without inspecting users.
    if(outputs.front()->getNumIncomingValues()==1) {
      for(auto *output:outputs){auto *value=output->getIncomingValue(0);
        output->replaceAllUsesWith(value);output->eraseFromParent();}
      if(!llvm::MergeBlockIntoPredecessor(join))
        throw std::runtime_error("output boundary fold failed");
    }
    // Only remove dead tuple plumbing copied from this capsule. Never run
    // whole-function DCE as part of boundary materialization.
    bool erased=true;while(erased){erased=false;
      for(auto &i:tupleCopies)if(i&&i->use_empty()){i->eraseFromParent();i=nullptr;erased=true;}
    }
    if(llvm::verifyModule(*result,&llvm::errs()))throw std::runtime_error("invalid spliced capsule");
    auto after=IRDependencySnapshot::capture(*result);auto delta=currentFacts.changesTo(after);
    auto newWrites=now.writes;newWrites.insert(delta.added.begin(),delta.added.end());
    // Metadata on rewritten instructions may be conservatively dropped.
    // Compare the complete remaining rooted graph, including named roots and
    // outside attachments. Read certificates continue to use FULL snapshots.
    auto oldBoundary=IRDependencySnapshot::capture(current,now.writes);
    auto newBoundary=IRDependencySnapshot::capture(*result,newWrites);
    delta=oldBoundary.changesTo(newBoundary);
    if(!delta.within(now.writes,newWrites)){
      for(auto id:delta.changed)if(!now.writes.count(id))
        throw std::runtime_error("capsule changed outside boundary: "+currentFacts.instructions.at(id)+" -> "+after.instructions.at(id));
      for(auto id:delta.removed)if(!now.writes.count(id))
        throw std::runtime_error("capsule removed outside boundary: "+currentFacts.instructions.at(id));
      throw std::runtime_error("capsule context escaped boundary");
    }
    return result;
  }
};
} // namespace fusion
