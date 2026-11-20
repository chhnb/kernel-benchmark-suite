#pragma once
#include "b2b_unit_capsule.h"
#include "incremental_candidate_queue.h"
#include "llvm24_scorer.h"
#include <functional>
namespace fusion {
// Experimental local cleanup only. Units allow integer/address work and ordinary
// integer memory operations; calls, atomics and volatile accesses remain excluded.
// Outside units admit only the audited pinned-GCN quote-key domain.
// External quote dependencies invalidate gains, never supply guessed prices.
// Pinned GCN/BasicTTI scalar pointer selects depend only on the legalized
// pointer type and i1 condition type; scalar PHI uses generic CF cost.
// This extension is isolated-only: default instruction quote cache unchanged.
inline std::optional<std::string> isolatedQuoteKey(const llvm::Instruction &i) {
  if(auto key=gcnQuoteKey(i))return key;
  if(i.getType()->isPointerTy()&&
     (llvm::isa<llvm::PHINode>(i)||(llvm::isa<llvm::SelectInst>(i)&&i.getOperand(0)->getType()->isIntegerTy(1)))){
    std::string key;llvm::raw_string_ostream out(key);
    out<<"gcn-throughput-6be16f356d3e-pointer:"<<i.getOpcodeName()<<":";
    i.getType()->print(out);out.flush();return key;
  }
  return std::nullopt;
}
inline bool isolatedContextFreeOpcode(unsigned opcode) {
  switch(opcode){
  case llvm::Instruction::Add:case llvm::Instruction::Sub:case llvm::Instruction::Mul:
  case llvm::Instruction::And:case llvm::Instruction::Or:case llvm::Instruction::Xor:
  case llvm::Instruction::Shl:case llvm::Instruction::LShr:case llvm::Instruction::AShr:
  case llvm::Instruction::ICmp:case llvm::Instruction::Select:case llvm::Instruction::PHI:
  case llvm::Instruction::Br:case llvm::Instruction::Ret:case llvm::Instruction::Freeze:return true;
  default:return false;
  }
}
// These supported quote keys cannot change merely because a user/operand
// is rebound at a boundary: memory value type, AS and alignment are unchanged;
// the admitted zero-argument intrinsics and pointer bitcasts are context-free.
inline bool isolatedBoundaryStableOpcode(unsigned opcode) {
  switch(opcode){
  case llvm::Instruction::Load:case llvm::Instruction::Store:
  case llvm::Instruction::Fence:case llvm::Instruction::Call:
  case llvm::Instruction::BitCast:return true;
  default:return false;
  }
}
inline void addIsolatedScoringReads(IncrementalCandidateQueue::ReadSet &reads,
    const IncrementalCandidateQueue::ReadSet &scoring,IRIdentity &ids,
    const B2BOptimizationUnit &unit) {
  for(auto &kv:scoring){
    auto id=std::stoull(kv.first.substr(12));auto *i=ids.lookup(id);
    if(unit.reads.count(id)||(unit.writes.count(id)&&!isolatedBoundaryStableOpcode(i->getOpcode())))
      reads.insert(kv);
  }
}
inline bool isolatedScalarTTIDomain(const llvm::Function &f) {
  if(f.getParent()->getTargetTriple()!="amdgcn-amd-amdhsa" ||
     f.getFnAttribute("target-cpu").getValueAsString()!="gfx906")return false;
  for(const auto &b:f)for(const auto &i:b)if(!isolatedQuoteKey(i))return false;
  return true;
}
inline IncrementalCandidateQueue::ReadSet isolatedScoringReads(
    llvm::Function &f,IRIdentity &ids) {
  IncrementalCandidateQueue::ReadSet reads;
  for(auto &b:f)for(auto &i:b)if(!isolatedContextFreeOpcode(i.getOpcode())){
    auto key=isolatedQuoteKey(i);
    if(!key)throw std::runtime_error("unsupported isolated scoring dependency");
    reads["tti-context:"+std::to_string(ids.instruction(i))]=*key;
  }
  return reads;
}
inline IncrementalCandidateQueue::ReadSet isolatedReads(
    const IRDependencySnapshot &snapshot,const B2BOptimizationUnit &unit) {
  IncrementalCandidateQueue::ReadSet reads{{"context",snapshot.context},
    {"policy","isolated-pure-integer-gfx906-v6;opaque-global-inputs;ordinary-loads;scoped-quote-dependencies;stripped-instruction-metadata;opaque-ssa-inputs;fold-output-boundary;no-global-cleanup"}};
  for(auto id:unit.reads){
    const auto &record=snapshot.instructions.at(id);
    reads["instruction:"+std::to_string(id)]=(id==unit.entry||unit.inputs.count(id))?
        IRDependencySnapshot::instructionBody(record):record;
    std::string uses;
    auto found=snapshot.users.find(id);
    if(found!=snapshot.users.end())for(auto u:found->second)
      uses+=std::to_string(u.first)+":"+std::to_string(u.second)+";";
    reads["uses:"+std::to_string(id)]=std::move(uses);
  }
  return reads;
}
// A scheduling-independent trial result. This is a capsule plan, never an old
// whole-module replacement. Cross-parent gain reuse requires equality of reads
// against a freshly discovered unit, plus the same cleanup/scoring policy.
struct IsolatedB2BTrial {
  std::string identity;
  IncrementalCandidateQueue::ReadSet reads;
  std::set<uint64_t> writes;
  std::unique_ptr<B2BUnitCapsule> capsule;
  std::unique_ptr<llvm::Module> product;
  std::optional<int64_t> parentCost;
  int64_t gain=0;
  uint64_t generatedLayouts=0,cleanedLayouts=0,scoredLayouts=0;
};
inline IsolatedB2BTrial evaluateIsolatedB2B(
    llvm::Module &current,llvm::BasicBlock &root,IRIdentity &ids,
    const B2BReplayContext &replayContext,const RoundContext &round,
    const LLVM24Scorer &scorer) {
  if(root.getParent()->getParent()!=&current)throw std::runtime_error("isolated root belongs to another parent");
  if(replayContext.exactIR!=B2BReplayContext::serialize(current))throw std::runtime_error("stale isolated trial parent");
  auto unit=B2BOptimizationUnit::discover(root,ids);
  if(!unit.eligible())throw std::runtime_error("ineligible isolated trial unit");
  auto *f=root.getParent();
  if(!isolatedScalarTTIDomain(*f))throw std::runtime_error("outside isolated TTI proof domain");
  IsolatedB2BTrial result;result.identity=unit.identity;result.writes=unit.writes;
  result.reads=isolatedReads(replayContext.planning,unit);
  addIsolatedScoringReads(result.reads,isolatedScoringReads(*f,ids),ids,unit);
  result.capsule=std::make_unique<B2BUnitCapsule>(current,root,&replayContext);
  Candidate candidate{"unit","B0","B1","B2"};
  auto layouts=scorer.planAnchorB2B(*result.capsule->ir,candidate,CleanupMode::DarmCFGInstCombine);
  result.generatedLayouts=layouts.size();
  for(auto &layout:layouts){
    if(layout.normalized)++result.cleanedLayouts;
    if(!layout.valid||!layout.normalized)continue;
    Trial trial;trial.valid=true;trial.cleanupMode=CleanupMode::None;
    trial.candidate={f->getName().str(),"","","",round.parentVersion};
    trial.normalized=result.capsule->apply(current,*layout.normalized,&replayContext);
    if(!isolatedScalarTTIDomain(*trial.normalized->getFunction(f->getName())))
      throw std::runtime_error("isolated product outside TTI proof domain");
    trial.raw=llvm::CloneModule(*trial.normalized);
    trial.before=features(*f);trial.after=features(*trial.normalized->getFunction(f->getName()));trial.afterRaw=trial.after;
    ++result.scoredLayouts;
    auto score=evaluateTrial(current,trial,round,scorer);
    // A partial set must never be published as a reusable zero or winner.
    if(score.status!=ScoreStatus::Scored)throw std::runtime_error("incomplete isolated trial scoring");
    const int64_t before=score.metrics.at("work_before");
    if(result.parentCost&&*result.parentCost!=before)throw std::runtime_error("isolated layout baseline mismatch");
    result.parentCost=before;
    const int64_t gain=before-score.metrics.at("work_after");
    if(gain>result.gain){result.gain=gain;result.product=llvm::CloneModule(*layout.normalized);}
  }
  return result;
}
} // namespace fusion
