#pragma once
#include "incremental_ir_snapshot.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Dominators.h"

namespace fusion {
// Boundary contract for the FIRST isolated-cleanup implementation. This is
// intentionally not a certificate for the legacy whole-function cleanup.
// Eligibility does not authorize reuse until generation/cleanup/scoring are
// executed inside this contract and their write/read obligations are checked.
struct B2BOptimizationUnit {
  std::string identity, rejection;
  std::set<uint64_t> writes, reads, inputs;
  uint64_t entry=0, left=0, right=0, exit=0;
  std::set<uint64_t> placementIndependentReads() const {
    auto result=inputs;result.insert(entry);return result;
  }
  bool eligible() const {return rejection.empty();}
  static B2BOptimizationUnit discover(llvm::BasicBlock &root,IRIdentity &ids) {
    B2BOptimizationUnit unit;
    auto reject=[&](const char *why){unit.rejection=why;return unit;};
    auto *br=llvm::dyn_cast<llvm::BranchInst>(root.getTerminator());
    if(!br || !br->isConditional())return reject("not_binary_branch");
    auto *l=br->getSuccessor(0),*r=br->getSuccessor(1);
    if(l==r || l->getSinglePredecessor()!=&root || r->getSinglePredecessor()!=&root)
      return reject("arms_not_exclusive_single_entry");
    auto *join=l->getSingleSuccessor();
    if(!join || join!=r->getSingleSuccessor() || join==l || join==r || join==&root)
      return reject("not_simple_common_exit");
    if(llvm::pred_size(join)!=2)return reject("external_exit_predecessor");
    if(root.hasAddressTaken()||l->hasAddressTaken()||r->hasAddressTaken()||join->hasAddressTaken())
      return reject("address_taken_boundary");
    // Available external SSA values become opaque capsule parameters. Their
    // definitions are not cloned, moved, or given stronger argument attributes.
    llvm::DominatorTree dominators(*root.getParent());
    auto isInput=[&](llvm::Value *v){
      if(!v->getType()->isIntegerTy())return false;
      if(llvm::isa<llvm::Argument>(v)||llvm::isa<llvm::ConstantInt>(v))return true;
      auto *def=llvm::dyn_cast<llvm::Instruction>(v);
      if(!def || def->getFunction()!=root.getParent() || !dominators.dominates(def,br))return false;
      unit.inputs.insert(ids.instruction(*def));return true;
    };
    if(!isInput(br->getCondition()))return reject("unavailable_condition_definition");
    std::set<llvm::Instruction*> internal;
    for(auto *arm:{l,r})for(auto &i:*arm)if(!i.isTerminator()){
      if(!(llvm::isa<llvm::BinaryOperator>(i)||llvm::isa<llvm::ICmpInst>(i)||
           llvm::isa<llvm::SelectInst>(i)||llvm::isa<llvm::CastInst>(i)) ||
          !i.getType()->isIntegerTy() || i.mayReadOrWriteMemory() || i.mayHaveSideEffects())
        return reject("unsupported_isolated_instruction");
      internal.insert(&i);
    }
    for(auto *i:internal) {
      for(auto &operand:i->operands()) {
        auto *v=operand.get();auto *def=llvm::dyn_cast<llvm::Instruction>(v);
        if(!v->getType()->isIntegerTy() || (!isInput(v) && (!def||!internal.count(def))))
          return reject("external_operand_definition");
        if(def && internal.count(def) && def->getParent()!=i->getParent())return reject("cross_arm_operand");
      }
      for(auto &use:i->uses()) {
        auto *user=llvm::dyn_cast<llvm::Instruction>(use.getUser());
        if(!user)return reject("external_noninstruction_use");
        if(internal.count(user))continue;
        auto *phi=llvm::dyn_cast<llvm::PHINode>(user);
        if(!phi || phi->getParent()!=join)return reject("unbounded_live_out");
      }
    }
    for(auto &phi:join->phis()) {
      if(!phi.getType()->isIntegerTy()||phi.getNumIncomingValues()!=2)
        return reject("unsupported_exit_phi");
      for(unsigned i=0;i<2;++i){
        auto *v=phi.getIncomingValue(i);auto *def=llvm::dyn_cast<llvm::Instruction>(v);
        if(!isInput(v) && (!def || !internal.count(def)))return reject("external_exit_value");
        if(def && internal.count(def) && def->getParent()!=phi.getIncomingBlock(i))return reject("invalid_exit_value_side");
      }
    }
    unit.identity=ids.candidate(root,*l,*r);
    unit.entry=ids.block(root);unit.left=ids.block(*l);unit.right=ids.block(*r);unit.exit=ids.block(*join);
    unit.writes.insert(unit.entry);
    for(auto *arm:{l,r})for(auto &i:*arm)unit.writes.insert(ids.instruction(i));
    for(auto &phi:join->phis())unit.writes.insert(ids.instruction(phi));
    unit.reads=unit.writes;
    // The exit terminator is a read-only boundary. Changes to it invalidate,
    // rather than allowing cleanup to follow arbitrarily far downstream.
    unit.reads.insert(unit.exit);
    // Conservative transitive definition closure, including PHI cycles.
    // This does not claim to describe arbitrary whole-function cleanup reads.
    std::set<uint64_t> visited;
    std::vector<uint64_t> work(unit.inputs.begin(),unit.inputs.end());
    while(!work.empty()){
      auto id=work.back();work.pop_back();if(!visited.insert(id).second)continue;
      auto *def=ids.lookup(id);if(!def)return reject("ambiguous_external_definition");
      unit.reads.insert(id);
      for(auto &operand:def->operands())if(auto *dependency=llvm::dyn_cast<llvm::Instruction>(operand.get()))
        work.push_back(ids.instruction(*dependency));
    }
    // Boundary splicing may move the unchanged root prefix/exit body and
    // substitute the single output PHI in its current users. These are writes,
    // NOT extra inputs to the isolated planner. No arbitrary cleanup runs here.
    for(auto &i:root)unit.writes.insert(ids.instruction(i));
    // The block identity follows its terminator. Folding the exit retags the
    // root, so its incoming branch references are an explicit boundary write.
    for(auto *pred:llvm::predecessors(&root))unit.writes.insert(ids.block(*pred));
    for(auto &i:*join)unit.writes.insert(ids.instruction(i));
    for(auto &phi:join->phis())for(auto *user:phi.users()) {
      auto *i=llvm::dyn_cast<llvm::Instruction>(user);
      if(!i)return reject("noninstruction_output_user");
      unit.writes.insert(ids.instruction(*i));
    }
    return unit;
  }
};
} // namespace fusion
