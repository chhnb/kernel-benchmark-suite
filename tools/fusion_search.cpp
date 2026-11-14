#include "decision_speculation_tti.h"
#include "scoped_cfg_cleanup.h"
#include "fusion_search.h"
#include "darm_pair_engine/LocalComputationFusion.h"
#include "logical_region_state.h"
#include "darm_pair_engine/RegionMelder.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/Analysis/CaptureTracking.h"
#include "llvm/Analysis/InstructionSimplify.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/SSAUpdater.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Support/SHA1.h"
#include "llvm/Config/llvm-config.h"
#include "llvm/IR/Operator.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Transforms/InstCombine/InstCombine.h"
#include <chrono>
#include <algorithm>
#include <cmath>
#include <functional>
#include <map>
#include <set>
#include <stdexcept>
using namespace llvm;
namespace fusion {
static std::string name(const Value *v) {
  if(!v) return "<exit>";
  std::string s; raw_string_ostream out(s); v->printAsOperand(out,false); return out.str();
}
static std::string text(const Value &v) {
  std::string s; raw_string_ostream out(s); v.print(out); return out.str();
}
// PHI edge ordering is semantically irrelevant, but pointer-map insertion
// order must not leak into reproducibility IDs or downstream pass traversal.
static unsigned cleanupProductionScopedCFG(Function &f, const std::set<Instruction*> &local,
                                  const std::set<BasicBlock*> &created, bool scalarTriangles=false) {
  std::set<Instruction*> permitted=local;
  std::vector<WeakVH> blocks, work;
  for(auto &b:f)if(created.count(&b)){
    blocks.emplace_back(&b);
    for(auto &i:b)permitted.insert(&i);
    for(auto *p:predecessors(&b))permitted.insert(p->getTerminator());
    for(auto *s:successors(&b))for(auto &phi:s->phis())permitted.insert(&phi);
  }
  struct Protected {WeakVH inst;BasicBlock *parent;unsigned opcode;std::vector<WeakTrackingVH> operands;};
  std::vector<Protected> outside;
  for(auto &b:f)for(auto &i:b){
    if(permitted.count(&i)){work.emplace_back(&i);continue;}
    Protected p{WeakVH(&i),&b,i.getOpcode(),{}};
    for(auto &op:i.operands())p.operands.emplace_back(op.get());
    outside.push_back(std::move(p));
  }
  auto audit=[&](){for(auto &p:outside){auto *i=dyn_cast_or_null<Instruction>((Value*)p.inst);
    if(!i||i->getParent()!=p.parent||i->getOpcode()!=p.opcode||i->getNumOperands()!=p.operands.size())throw std::runtime_error("scoped_cfg_changed_outside_instruction");
    for(unsigned n=0;n<p.operands.size();++n)if(i->getOperand(n)!=(Value*)p.operands[n])throw std::runtime_error("scoped_cfg_changed_outside_operand");
  }};
  for(unsigned round=1;round<=32;++round){
    auto before=moduleHash(*f.getParent());
    std::set<Instruction*> scalar;
    for(auto &h:work)if(auto *i=dyn_cast_or_null<Instruction>((Value*)h))if(!i->isTerminator())scalar.insert(i);
    cleanupScoped(f,scalar);
    std::set<BasicBlock*> live;
    for(auto &h:blocks)if(auto *b=dyn_cast_or_null<BasicBlock>((Value*)h))live.insert(b);
    if(scalarTriangles && foldScopedScalarTriangle(f,live,permitted,work)){
      audit();if(verifyFunction(f,&errs()))throw std::runtime_error("scoped_triangle_invalid_ir");
      continue;
    }
    // Fold only conditions implied by dominating edges, within new blocks.
    foldProvenBranch(f,&live);
    for(auto &h:blocks){auto *head=dyn_cast_or_null<BasicBlock>((Value*)h);if(!head)continue;
      auto *br=dyn_cast<BranchInst>(head->getTerminator());if(!br||!br->isConditional())continue;
      auto *a=br->getSuccessor(0),*b=br->getSuccessor(1);
      if(a==b||!live.count(a)||!live.count(b)||a->size()!=1||b->size()!=1||
         a->getSinglePredecessor()!=head||b->getSinglePredecessor()!=head)continue;
      auto *join=a->getSingleSuccessor();if(!join||join!=b->getSingleSuccessor()||join==head)continue;
      bool safe=true;for(auto &phi:join->phis())safe&=permitted.count(&phi)&&phi.getBasicBlockIndex(a)>=0&&phi.getBasicBlockIndex(b)>=0;
      if(!safe)continue;
      IRBuilder<> builder(br);
      for(auto &phi:join->phis()){
        auto *v=builder.CreateSelect(br->getCondition(),phi.getIncomingValueForBlock(a),phi.getIncomingValueForBlock(b),"scoped.exit.select");
        if(auto *i=dyn_cast<Instruction>(v))if(i->getParent()==head){work.emplace_back(i);permitted.insert(i);}
        phi.removeIncomingValue(a,false);phi.removeIncomingValue(b,false);phi.addIncoming(v,head);
      }
      BranchInst::Create(join,br);br->eraseFromParent();
      a->eraseFromParent();b->eraseFromParent();break;
    }
    // Bypass only newly-created branch-only blocks. LLVM's utility handles
    // PHI edge compatibility, including multiple edges from one predecessor.
    for(auto &h:blocks){auto *b=dyn_cast_or_null<BasicBlock>((Value*)h);if(!b||b==&f.getEntryBlock()||b->size()!=1)continue;
      auto *br=dyn_cast<BranchInst>(b->getTerminator());if(!br||!br->isUnconditional()||br->getSuccessor(0)==b)continue;
      bool safe=true;
      for(auto *p:predecessors(b))safe&=created.count(p)||permitted.count(p->getTerminator());
      for(auto &phi:br->getSuccessor(0)->phis())safe&=permitted.count(&phi);
      if(safe&&TryToSimplifyUncondBranchFromEmptyBlock(b))break;
    }
    // Join a newly-created block to its sole unconditional predecessor.
    // This only removes a straight-line boundary; no conditional is crossed.
    for(auto &h:blocks){auto *b=dyn_cast_or_null<BasicBlock>((Value*)h);if(!b)continue;
      auto *pred=b->getSinglePredecessor();if(!pred||pred==b)continue;
      auto *br=dyn_cast<BranchInst>(pred->getTerminator());if(!br||!br->isUnconditional())continue;
      if(!created.count(pred)&&!permitted.count(br))continue;
      if(MergeBlockIntoPredecessor(b))break;
    }
    audit();if(verifyFunction(f,&errs()))throw std::runtime_error("scoped_cfg_invalid_ir");
    if(moduleHash(*f.getParent())==before)return round;
  }
  throw std::runtime_error("scoped_cfg_did_not_converge");
}

static void canonicalPhiOrder(Module &m, StringRef selectedFunction) {
  for(auto &f:m) {
    if(f.getName()!=selectedFunction)continue;
    std::map<const BasicBlock*,unsigned> order;
    unsigned n=0;for(auto &b:f)order[&b]=n++;
    for(auto &b:f)for(auto &phi:b.phis()) {
      std::vector<std::pair<BasicBlock*,Value*>> edges;
      for(unsigned i=0;i<phi.getNumIncomingValues();++i)
        edges.emplace_back(phi.getIncomingBlock(i),phi.getIncomingValue(i));
      std::stable_sort(edges.begin(),edges.end(),[&](const auto&a,const auto&b){return order.at(a.first)<order.at(b.first);});
      for(unsigned i=0;i<edges.size();++i){phi.setIncomingBlock(i,edges[i].first);phi.setIncomingValue(i,edges[i].second);}
    }
  }
}
Analysis::Analysis(Function &f):dt(f),pdt(f),loops(dt) {
  df.analyze(dt); regions.recalculate(f,&dt,&pdt,&df);
}
using Clock=std::chrono::steady_clock;
static double millis(Clock::time_point start) {
  return std::chrono::duration<double,std::milli>(Clock::now()-start).count();
}
std::string moduleHash(const Module&m) {
  std::string s;raw_string_ostream out(s);m.print(out,nullptr);out.flush();
  SHA1 hash;hash.update(s);auto bytes=hash.final();std::string hex;
  const char*digits="0123456789abcdef";
  for(unsigned char c:bytes){hex+=digits[c>>4];hex+=digits[c&15];}return hex;
}
static std::string typeName(Type*t) {std::string s;raw_string_ostream out(s);t->print(out);return out.str();}
static std::string attributes(AttributeList a,unsigned nargs) {
  std::string s="fn:"+a.getAsString(AttributeList::FunctionIndex)+";ret:"+a.getAsString(AttributeList::ReturnIndex);
  for(unsigned i=0;i<nargs;++i)s+=";arg"+std::to_string(i)+":"+a.getAsString(i+1);return s;
}
static OperationKey operation(Instruction&i) {
  OperationKey k;k.opcode=i.getOpcodeName();Type*t=i.getType();
  // Preserve both effective data type and all operand types, e.g. cmp result i1.
  if(auto*store=dyn_cast<StoreInst>(&i))t=store->getValueOperand()->getType();
  if(isa<CmpInst>(i))t=i.getOperand(0)->getType();
  k.type=typeName(t);k.attributes="result="+typeName(i.getType());
  for(auto&op:i.operands())k.operandTypes+=typeName(op->getType())+";";
  if(auto *v=dyn_cast<VectorType>(t)) {
    auto count=v->getElementCount();
#ifdef FUSION_PACKAGED_LLVM12
    k.lanes=count.getKnownMinValue();k.scalable=count.isScalable();
#else
    k.lanes=count.Min;k.scalable=count.Scalable;
#endif
    t=v->getElementType();
  }
  k.category=t->isIntegerTy()?"integer":t->isFloatingPointTy()?"floating":t->isPointerTy()?"pointer":t->isVoidTy()?"void":"other";
  if(t->isIntegerTy())k.scalarBits=t->getIntegerBitWidth();
  else if(t->isFloatingPointTy())k.scalarBits=t->getPrimitiveSizeInBits().getFixedSize();
  else if(t->isPointerTy())k.scalarBits=i.getModule()->getDataLayout().getPointerSizeInBits(t->getPointerAddressSpace());
  if(auto*fp=dyn_cast<FPMathOperator>(&i)){
    auto f=fp->getFastMathFlags();k.attributes+=";fmf="+std::to_string(f.allowReassoc())+std::to_string(f.noNaNs())+std::to_string(f.noInfs())+std::to_string(f.noSignedZeros())+std::to_string(f.allowReciprocal())+std::to_string(f.allowContract())+std::to_string(f.approxFunc());
  }
  if(auto*o=dyn_cast<OverflowingBinaryOperator>(&i))k.attributes+=";nuw="+std::to_string(o->hasNoUnsignedWrap())+";nsw="+std::to_string(o->hasNoSignedWrap());
  if(auto*o=dyn_cast<PossiblyExactOperator>(&i))k.attributes+=";exact="+std::to_string(o->isExact());
  if(auto*c=dyn_cast<CmpInst>(&i))k.attributes+=";predicate="+std::to_string(c->getPredicate());
  if(auto*g=dyn_cast<GetElementPtrInst>(&i))k.attributes+=";inbounds="+std::to_string(g->isInBounds());
  if(auto*l=dyn_cast<LoadInst>(&i))k.attributes+=";volatile="+std::to_string(l->isVolatile())+";ordering="+std::to_string(int(l->getOrdering()))+";align="+std::to_string(l->getAlign().value());
  if(auto*s=dyn_cast<StoreInst>(&i))k.attributes+=";volatile="+std::to_string(s->isVolatile())+";ordering="+std::to_string(int(s->getOrdering()))+";align="+std::to_string(s->getAlign().value());
  if(auto*c=dyn_cast<CallBase>(&i)){
    auto*callee=dyn_cast<Function>(c->getCalledOperand()->stripPointerCasts());
    k.callee=callee?((callee->isIntrinsic()?"intrinsic:":"function:")+callee->getName().str()):"indirect_or_inline_asm";
    auto attrs=attributes(c->getAttributes(),c->arg_size());
    k.attributes+=";calling_conv="+std::to_string(c->getCallingConv())+";call_attributes="+attrs;
  }
  k.legacyWeight=InstructionMatch::getInstructionCost(&i);return k;
}

Features features(Function &f) {
  Features x; x.blocks=f.size(); DominatorTree dt(f); LoopInfo li(dt);
  std::function<void(Loop*)> visit=[&](Loop*l){++x.loops;for(auto*c:l->getSubLoops())visit(c);};
  for(auto*l:li)visit(l);
  for(auto&b:f) for(auto&i:b) {
    ++x.instructions;auto k=operation(i);x.cost+=k.legacyWeight;++x.operations[k];
    x.phis+=isa<PHINode>(i);x.selects+=isa<SelectInst>(i);
    if(auto*br=dyn_cast<BranchInst>(&i))x.branches+=br->isConditional();
  }
  return x;
}
void normalize(Module &m,unsigned level) {
  legacy::PassManager pm; PassManagerBuilder builder;
  builder.OptLevel=level; builder.SizeLevel=0;
  builder.LoopVectorize=level>1; builder.SLPVectorize=level>1;
  builder.populateModulePassManager(pm); pm.run(m);
}
// Match the original CFMelder outer cleanup, including target-aware TTI.
// RegionMelder::merge already runs internal cleanup, post-optimization,
// and (unless disabled upstream) unpredication.
// Fold a branch whose two edges meet immediately, with one edge passing
// through an empty or safely speculatable scalar block. External predecessors of Join remain untouched.
// Also admit safe, memory-free scalar instructions. Loads, stores, convergent
// calls and arbitrary calls must retain their guards.
static bool foldEmptyPhiTriangle(Function &f) {
  for(auto &bb:f){
    auto *br=dyn_cast<BranchInst>(bb.getTerminator());
    if(!br||!br->isConditional())continue;
    for(unsigned side=0;side<2;++side){
      auto *empty=br->getSuccessor(side),*join=br->getSuccessor(1-side);
      if(empty==join||empty==&bb||join==&bb||empty->hasAddressTaken()||
         empty->getSinglePredecessor()!=&bb||empty->getSingleSuccessor()!=join)continue;
      bool supported=true;
      for(auto &i:*empty){
        if(i.isTerminator())continue;
        bool scalar=isa<CmpInst>(i)||isa<BinaryOperator>(i)||isa<SelectInst>(i)||isa<CastInst>(i);
        if(auto *intrinsic=dyn_cast<IntrinsicInst>(&i))
          scalar=intrinsic->getIntrinsicID()==Intrinsic::fabs||intrinsic->getIntrinsicID()==Intrinsic::copysign;
        supported &= scalar && !i.mayReadOrWriteMemory() && isSafeToSpeculativelyExecute(&i);
      }
      for(auto &phi:join->phis())
        supported &= phi.getBasicBlockIndex(&bb)>=0 && phi.getBasicBlockIndex(empty)>=0;
      if(!supported)continue;
      while(empty->size()>1)empty->front().moveBefore(br);
      IRBuilder<> builder(br);
      for(auto &phi:join->phis()){
        auto *direct=phi.getIncomingValueForBlock(&bb);
        auto *viaEmpty=phi.getIncomingValueForBlock(empty);
        auto *value=builder.CreateSelect(br->getCondition(),side==0?viaEmpty:direct,
                                        side==0?direct:viaEmpty,"postopt.edge.select");
        phi.removeIncomingValue(empty,false);
        phi.setIncomingValue(phi.getBasicBlockIndex(&bb),value);
      }
      BranchInst::Create(join,br);br->eraseFromParent();empty->eraseFromParent();
      return true;
    }
  }
  return false;
}
// Fold only branch predicates proven by dominating edges. No instruction is
// speculated, and arbitrary arithmetic, memory and call predicates are opaque.

unsigned cleanup(Module &m,const std::string &function,unsigned level,CleanupMode mode) {
  if(mode==CleanupMode::None||mode==CleanupMode::ScopedLocal||mode==CleanupMode::ScopedCFG||mode==CleanupMode::ScopedCFGTriangles)return 0;
  canonicalPhiOrder(m,function);
  if(mode==CleanupMode::O3){normalize(m,level);return 0;}
  auto*f=m.getFunction(function);if(!f)throw std::runtime_error("cleanup function missing");
  static const bool initialized=[](){InitializeAllTargetInfos();InitializeAllTargets();InitializeAllTargetMCs();return true;}();
  (void)initialized;
  static std::map<std::string,std::unique_ptr<TargetMachine>> machines;
  auto triple=m.getTargetTriple();
  if(!machines.count(triple)){
    std::string error;const auto*target=TargetRegistry::lookupTarget(triple,error);
    machines[triple]=std::unique_ptr<TargetMachine>(target?target->createTargetMachine(triple,"","",TargetOptions(),None,None,CodeGenOpt::Default):nullptr);
  }
  auto*tm=machines.at(triple).get();FunctionAnalysisManager fam;
  auto tti=tm?tm->getTargetIRAnalysis().run(*f,fam):TargetIRAnalysis().run(*f,fam);
  // Score and commit the same fixed point, including CFG simplification after
  // scalar rewrites. Keep the legacy DARM cleanup modes reproducible.
  if(mode==CleanupMode::PostOptFixedPoint){
    std::set<std::string> seen;
    for(unsigned iteration=1;iteration<=32;++iteration){
      auto before=moduleHash(m);
      if(!seen.insert(before).second)throw std::runtime_error("postopt_cleanup_cycle");
      legacy::FunctionPassManager pm(&m);
      pm.add(createTargetTransformInfoWrapperPass(tm?tm->getTargetIRAnalysis():TargetIRAnalysis()));
      pm.add(createEarlyCSEPass(false));
      pm.add(createInstructionCombiningPass());
      pm.add(createCFGSimplificationPass());
      pm.add(createDeadCodeEliminationPass());
      pm.add(createEarlyCSEPass(false));
      pm.doInitialization();pm.run(*f);pm.doFinalization();
      while(foldEmptyPhiTriangle(*f)){}
      if(verifyModule(m,&errs()))throw std::runtime_error("invalid_postopt_cleanup_ir");
      if(moduleHash(m)==before)return iteration;
    }
    throw std::runtime_error("postopt_cleanup_did_not_converge_in_32_iterations");
  }
  bool changed;
  do {
    changed=false;
    if(mode==CleanupMode::StructuralCFG&&foldProvenBranch(*f)){changed=true;continue;}
    for(auto&b:make_range(f->begin(),f->end())){
      if(simplifyCFG(&b,tti,
#ifdef FUSION_PACKAGED_LLVM12
          nullptr,
#endif
          SimplifyCFGOptions().setSimplifyCondBranch(false).sinkCommonInsts(false).hoistCommonInsts(false))){
        changed=true;break;
      }
    }
  }while(changed);
  if(mode==CleanupMode::DarmCFGEarlyCSE||mode==CleanupMode::DarmCFGRedundancy){
    legacy::FunctionPassManager pm(&m);
    pm.add(createTargetTransformInfoWrapperPass(tm?tm->getTargetIRAnalysis():TargetIRAnalysis()));
    pm.add(createEarlyCSEPass(false));
    if(mode==CleanupMode::DarmCFGRedundancy)pm.add(createDeadCodeEliminationPass());
    pm.doInitialization();pm.run(*f);pm.doFinalization();
    return 1;
  }
  if(mode==CleanupMode::DarmCFGScalarFixedPoint){
    std::set<std::string> seen;
    for(unsigned iteration=1;iteration<=32;++iteration){
      auto before=moduleHash(m);
      if(!seen.insert(before).second)throw std::runtime_error("scalar_cleanup_cycle");
      legacy::FunctionPassManager pm(&m);
      pm.add(createTargetTransformInfoWrapperPass(tm?tm->getTargetIRAnalysis():TargetIRAnalysis()));
      pm.add(createEarlyCSEPass(false));pm.add(createInstructionCombiningPass());
      pm.doInitialization();pm.run(*f);pm.doFinalization();
      if(moduleHash(m)==before)return iteration;
    }
    throw std::runtime_error("scalar_cleanup_did_not_converge_in_32_iterations");
  }
  return 0;
}
struct Unit {BasicBlock*entry;BasicBlock*exit;Region*region;std::set<BasicBlock*>blocks;};
// Conservative IR decision identity: comparisons against constants must use
// the identical SSA discriminator. Do not equate x with 1-x or infer source
// ownership for compound/unknown predicates. Those require explicit opt-in.
static Value *decisionDiscriminator(BasicBlock *b) {
  auto *br=dyn_cast<BranchInst>(b->getTerminator());
  auto *cmp=br&&br->isConditional()?dyn_cast<CmpInst>(br->getCondition()):nullptr;
  if(!cmp)return nullptr;
  auto *a=cmp->getOperand(0),*c=cmp->getOperand(1);
  if(isa<Constant>(a)==isa<Constant>(c))return nullptr;
  return isa<Constant>(a)?c:a;
}
// True when v is computed from d through SSA operands (including PHIs).
static bool dependsOn(Value *v,Value *d) {
  if(!v||!d)return false;
  std::set<Value*> seen;SmallVector<Value*,16> work{v};
  while(!work.empty()){
    auto *x=work.pop_back_val();if(x==d)return true;
    auto *i=dyn_cast<Instruction>(x);if(!i||!seen.insert(i).second||seen.size()>256)continue;
    for(auto &op:i->operands())work.push_back(op.get());
  }
  return false;
}
// A complete leaf is a leaf of the decision only if no branch inside it tests
// the decision's own discriminator. Otherwise the unit is a sub-decision
// (for example a whole lower subtree of a balanced x<a / x<b tree), and pairing
// it with a single opposite leaf is a cross-level fusion. Only the default
// enumeration is restricted; --cross-decision-leaves 1 keeps the capability.
static bool containsSubDecision(const std::set<BasicBlock*> &blocks,Value *discriminator) {
  for(auto *b:blocks){
    auto *t=b->getTerminator();Value *cond=nullptr;
    if(auto *br=dyn_cast<BranchInst>(t))cond=br->isConditional()?br->getCondition():nullptr;
    else if(auto *sw=dyn_cast<SwitchInst>(t))cond=sw->getCondition();
    if(cond&&dependsOn(cond,discriminator))return true;
  }
  return false;
}
// B2R/R2B: the optional block is reached only through further branches on
// the same side. If one of those branches tests the split's discriminator,
// DARM's region replication re-evaluates that decision chain on the other
// path (one compare, select and branch per level) and every lane of the
// region side pays the operand selects. Adjacent else-if leaves are not
// affected: they are normalized into one diamond before this check applies.
static bool optionalBehindSameDecision(BasicBlock *opt,BasicBlock *sideEntry,Value *discriminator,Analysis &a) {
  if(!discriminator||a.pdt.dominates(opt,sideEntry))return false;
  auto *node=a.dt.getNode(opt);
  for(auto *n=node?node->getIDom():nullptr;n;n=n->getIDom()){
    auto *x=n->getBlock();
    if(!a.dt.dominates(sideEntry,x))break;
    auto *t=x->getTerminator();Value *cond=nullptr;
    if(auto *br=dyn_cast<BranchInst>(t))cond=br->isConditional()?br->getCondition():nullptr;
    else if(auto *sw=dyn_cast<SwitchInst>(t))cond=sw->getCondition();
    if(cond&&!a.pdt.dominates(opt,x)&&dependsOn(cond,discriminator))return true;
  }
  return false;
}
struct Inventory {
  std::vector<std::unique_ptr<Region>> logicalRegions;
  std::vector<std::tuple<std::string,std::string,std::string>> leafPairs;
  std::set<std::tuple<std::string,std::string,std::string>> sameDecisionLeafPairs;
  // Same discriminator, but one side is itself a sub-decision of it.
  std::set<std::tuple<std::string,std::string,std::string>> crossLevelLeafPairs;
  std::map<std::string,BasicBlock*> blocks;
  std::map<BasicBlock*,std::string> ids;
  std::map<std::string,Unit> units;
  Inventory(Function&f,Analysis&a) {
    unsigned n=0;for(auto&b:f){auto id="B"+std::to_string(n++);blocks[id]=&b;ids[&b]=id;units[id]={&b,b.getSingleSuccessor(),nullptr,{&b}};}
    n=0;std::function<void(Region*)> visit=[&](Region*r){std::set<BasicBlock*>bs;for(auto*b:r->blocks())bs.insert(b);units["R"+std::to_string(n++)]={r->getEntry(),r->getExit(),r,bs};for(auto&c:*r)visit(c.get());};visit(a.regions.getTopLevelRegion());
    // A logical fusion arm includes its non-canonical trailing computation,
    // not merely the canonical RegionInfo prefix ending at an internal join.
    for(auto &b:f){
      auto *br=dyn_cast<BranchInst>(b.getTerminator());
      if(!br||!br->isConditional()||!br->getMetadata("fusion.logical.arm"))continue;
      auto *pn=a.pdt.getNode(&b);
      if(!pn||!pn->getIDom()||!pn->getIDom()->getBlock()||a.loops.getLoopFor(&b))continue;
      auto *entry=br->getSuccessor(0),*exit=pn->getIDom()->getBlock();
      if(entry==exit||entry->getSinglePredecessor()!=&b)continue;
      std::set<BasicBlock*> bs;std::vector<BasicBlock*> todo{entry};bool safe=true;
      while(!todo.empty()){
        auto *bb=todo.back();todo.pop_back();if(bb==exit||!bs.insert(bb).second)continue;
        if(!a.dt.dominates(entry,bb)||a.loops.getLoopFor(bb)){safe=false;break;}
        for(auto *succ:successors(bb))todo.push_back(succ);
      }
      if(!safe||bs.size()<2)continue;
      auto reg=std::make_unique<Region>(entry,exit,&a.regions,&a.dt,a.regions.getTopLevelRegion());
      units["G"+ids.at(&b).substr(1)]={entry,exit,reg.get(),bs};logicalRegions.push_back(std::move(reg));
    }
    // Complete adjacent SESE arms, even when another arm returns early.
    // The common exit is derived from the selected entries, not the whole
    // classifier's postdominator. E<entry>_<exit> includes trailing blocks.
    auto makeLeaf=[&](BasicBlock *entry,BasicBlock *exit)->std::string {
      if(!entry||!exit||entry==exit||!a.pdt.dominates(exit,entry))return {};
      std::set<BasicBlock*> bs;std::vector<BasicBlock*> todo{entry};
      while(!todo.empty()){
        auto *bb=todo.back();todo.pop_back();if(bb==exit||!bs.insert(bb).second)continue;
        if(!a.dt.dominates(entry,bb)||a.loops.getLoopFor(bb)||bb->hasAddressTaken())return {};
        auto *br=dyn_cast<BranchInst>(bb->getTerminator());if(!br)return {};
        for(auto &i:*bb)if(i.mayHaveSideEffects()||i.mayWriteToMemory())return {};
        for(auto *succ:successors(bb))todo.push_back(succ);
      }
      for(auto *bb:bs)if(bb!=entry)for(auto *pred:predecessors(bb))if(!bs.count(pred))return {};
      auto id="E"+ids.at(entry).substr(1)+"_"+ids.at(exit).substr(1);
      if(!units.count(id)){
        Region *reg=nullptr;
        if(bs.size()>1){auto r=std::make_unique<Region>(entry,exit,&a.regions,&a.dt,a.regions.getTopLevelRegion());reg=r.get();logicalRegions.push_back(std::move(r));}
        units[id]={entry,exit,reg,bs};
      }
      return id;
    };
    for(auto &p:f){auto *pb=dyn_cast<BranchInst>(p.getTerminator());if(!pb||!pb->isConditional())continue;
      for(unsigned side=0;side<2;++side){
        auto *q=pb->getSuccessor(1-side),*l=pb->getSuccessor(side);
        auto *qb=dyn_cast<BranchInst>(q->getTerminator());
        if(!qb||!qb->isConditional()||q->getSinglePredecessor()!=&p||l->getSinglePredecessor()!=&p)continue;
        for(auto *r:successors(q)){
          if(r==l||r->getSinglePredecessor()!=q)continue;
          auto *exit=a.pdt.findNearestCommonDominator(l,r);
          auto li=makeLeaf(l,exit),ri=makeLeaf(r,exit);
          if(li.empty()||ri.empty()||(units.at(li).blocks.size()==1&&units.at(ri).blocks.size()==1))continue;
          bool overlap=false;for(auto *bb:units.at(li).blocks)overlap|=units.at(ri).blocks.count(bb);
          if(!overlap){
            auto pair=std::make_tuple(ids.at(&p),li,ri);leafPairs.push_back(pair);
            auto *discriminator=decisionDiscriminator(&p);
            if(discriminator && discriminator==decisionDiscriminator(q)){
              if(containsSubDecision(units.at(li).blocks,discriminator)||
                 containsSubDecision(units.at(ri).blocks,discriminator))
                crossLevelLeafPairs.insert(pair);
              else sameDecisionLeafPairs.insert(pair);
            }
          }
        }
      }
    }

  }
};
static std::set<BasicBlock*> reachable(BasicBlock*start,BasicBlock*join) {
  std::set<BasicBlock*> seen;std::vector<BasicBlock*> todo{start};
  while(!todo.empty()){auto*b=todo.back();todo.pop_back();if(b==join||!seen.insert(b).second)continue;for(auto*s:successors(b))todo.push_back(s);}return seen;
}
static bool subset(const std::set<BasicBlock*>&a,const std::set<BasicBlock*>&b) {
  for(auto*x:a)if(!b.count(x))return false;return true;
}
static bool belongs(const Unit&u,const std::set<BasicBlock*>&a,const std::set<BasicBlock*>&b) {
  if(u.blocks.empty()||!subset(u.blocks,a))return false;
  for(auto*x:u.blocks)if(b.count(x))return false;return true;
}
// Only a single-entry, single-exit acyclic scope inside one unchanged loop.
// The split may be the header: its PHIs and incoming/back edges are outside
// the transformed scope. Nested loops, backedges and exits inside scope remain unsupported.
static bool supportedLoopScope(BasicBlock *split,BasicBlock *join,
                               const std::set<BasicBlock*>&scope,LoopInfo &loops) {
  auto *enclosing=loops.getLoopFor(split);
  if(!enclosing){for(auto*b:scope)if(loops.getLoopFor(b))return false;return true;}
  if(loops.getLoopFor(join)!=enclosing||
     enclosing->getHeader()==join||scope.count(split)||scope.count(join))return false;
  std::map<BasicBlock*,unsigned> indegree;
  for(auto*b:scope){
    if(loops.getLoopFor(b)!=enclosing||b==enclosing->getHeader())return false;
    indegree[b]=0;
    for(auto*p:predecessors(b)){
      if(scope.count(p))++indegree[b];else if(p!=split)return false;
    }
    for(auto*s:successors(b))if(!scope.count(s)&&s!=join)return false;
  }
  std::vector<BasicBlock*> ready;
  for(auto&kv:indegree)if(!kv.second)ready.push_back(kv.first);
  unsigned visited=0;
  while(!ready.empty()){
    auto*b=ready.back();ready.pop_back();++visited;
    for(auto*s:successors(b))if(scope.count(s)&&!--indegree[s])ready.push_back(s);
  }
  return visited==scope.size();
}
// Pair sibling single-block loops only when the region mapping preserves
// both the backedge and the exit edge. The ordinary acyclic gate still
// handles all other candidate shapes.
static bool supportedSingleBlockLoopPair(BasicBlock *split, BasicBlock *join,
                                        const Unit &left, const Unit &right,
                                        const std::set<BasicBlock*> &scope,
                                        LoopInfo &loops) {
  if(!left.region || !right.region || scope.size()!=2 ||
     left.blocks.size()!=1 || right.blocks.size()!=1 ||
     left.exit!=join || right.exit!=join)return false;
  auto *dispatch=cast<BranchInst>(split->getTerminator());
  if(dispatch->getSuccessor(0)!=left.entry || dispatch->getSuccessor(1)!=right.entry)
    return false;
  auto backedge=[&](BasicBlock *block)->int {
    auto *loop=loops.getLoopFor(block);
    auto *branch=dyn_cast<BranchInst>(block->getTerminator());
    if(!loop || loop->getHeader()!=block || loop->getNumBlocks()!=1 ||
       loop->getParentLoop()!=loops.getLoopFor(split) ||
       loops.getLoopFor(join)!=loops.getLoopFor(split) ||
       !branch || !branch->isConditional())return -1;
    for(auto *pred:predecessors(block))
      if(pred!=split && pred!=block)return -1;
    for(unsigned index=0;index<2;++index)
      if(branch->getSuccessor(index)==block && branch->getSuccessor(1-index)==join)
        return index;
    return -1;
  };
  const int leftEdge=backedge(left.entry);
  return leftEdge>=0 && leftEdge==backedge(right.entry);
}
static Boundary boundary(const Unit&u,Function&f) {
  Boundary v;v.entry=name(u.entry);v.exit=name(u.exit);std::set<std::string> ins,outs;
  for(auto&b:f)if(u.blocks.count(&b)){v.blocks.push_back(name(&b));for(auto&i:b){
    for(auto&op:i.operands()){auto*x=op.get();auto*def=dyn_cast<Instruction>(x);if((def&&!u.blocks.count(def->getParent()))||isa<Argument>(x))ins.insert(name(x));}
    for(auto*x:i.users())if(auto*use=dyn_cast<Instruction>(x))if(!u.blocks.count(use->getParent()))outs.insert(name(&i));
  }}v.liveIns.assign(ins.begin(),ins.end());v.liveOuts.assign(outs.begin(),outs.end());return v;
}
static bool blocksAnchorDiscovery(const Instruction &instruction) {
  if (const auto *store = dyn_cast<StoreInst>(&instruction))
    return !store->isSimple();
  return instruction.mayHaveSideEffects() || instruction.mayWriteToMemory();
}

std::vector<Candidate> enumerate(Function&f,unsigned version,bool crossDecisionLeaves) {
  Analysis a(f); Inventory inv(f,a);std::vector<Candidate> result;
  auto frontier=[&](const std::set<BasicBlock*>&side,const std::set<BasicBlock*>&opposite){
    std::vector<std::string> rs,out;std::set<BasicBlock*>covered;
    for(auto&kv:inv.units)if(kv.first[0]!='E'&&kv.second.region&&kv.second.exit&&belongs(kv.second,side,opposite))rs.push_back(kv.first);
    for(auto&id:rs){bool nested=false;auto&u=inv.units.at(id);for(auto&other:rs){auto&v=inv.units.at(other);if(u.blocks.size()<v.blocks.size()&&subset(u.blocks,v.blocks)){nested=true;break;}}if(!nested){out.push_back(id);covered.insert(u.blocks.begin(),u.blocks.end());}}
    for(auto&b:f)if(side.count(&b)&&!opposite.count(&b)&&!covered.count(&b))out.push_back(inv.ids.at(&b));return out;
  };
  for(auto&b:f){auto*br=dyn_cast<BranchInst>(b.getTerminator());auto*node=a.pdt.getNode(&b);
    if(!br||!br->isConditional()||!node||!node->getIDom()||!node->getIDom()->getBlock()||!Utils::isValidMergeLocation(b,a.pdt))continue;
    auto*join=node->getIDom()->getBlock();auto l=reachable(br->getSuccessor(0),join),r=reachable(br->getSuccessor(1),join);
    // Record DARM choices before trial legality checks so coverage reports
    // can distinguish an unsupported transform from a missing candidate.
    // DARM's list matcher requires each side's child regions to be a chain
    // under dominance. Parallel siblings are legal IR but unsupported by it.
    auto* container=a.regions.getRegionFor(&b);
    bool darmOrdered=container!=nullptr;
    if(container) {
      std::vector<BasicBlock*> entries[2];
      for(auto &child:*container) for(unsigned side=0;side<2;++side)
        if(a.dt.dominates(br->getSuccessor(side),child->getEntry()))
          entries[side].push_back(child->getEntry());
      // Block-to-region matching uses a block traversal, so its region list
      // can contain incomparable entries. Region-to-region alignment needs chains.
      if(!entries[0].empty()&&!entries[1].empty())
        for(const auto &side:entries)
          for(size_t i=0;i<side.size();++i)for(size_t j=i+1;j<side.size();++j)
            if(!a.dt.dominates(side[i],side[j])&&!a.dt.dominates(side[j],side[i]))
              darmOrdered=false;
    }
    if(darmOrdered) {
      RegionAnalyzer darm(&b,a.dt,a.pdt);
      darm.computeRegionMatch();
      auto unitId=[&](BasicBlock*entry,BasicBlock*exit)->std::string {
        if(!exit)return inv.ids.at(entry);
        for(auto&kv:inv.units)if(kv.first[0]!='E' && kv.second.region && kv.second.entry==entry && kv.second.exit==exit)return kv.first;
        return {};
      };
      for(unsigned i=0;i<darm.regionMatchSize();++i) {
        // Similarity is diagnostic; the search scorer decides profitability.
        auto entries=darm.getRegionMatchEntryBlocks(i),exits=darm.getRegionMatchExitBlocks(i);
        auto li=unitId(entries.first,exits.first),ri=unitId(entries.second,exits.second);
        if(!li.empty()&&!ri.empty())result.push_back({f.getName().str(),inv.ids.at(&b),li,ri,version});
      }
    } // Original DARM matcher is optional; retain our other candidate families.
    // An ordinary store elsewhere on an arm may stay on its original path.
    // Trial legality depends on the selected anchors and the emitted CFG.
    auto scope=l;scope.insert(r.begin(),r.end());bool unsupported=!supportedLoopScope(&b,join,scope,a.loops);
    for (auto *block : scope)
      for (const auto &instruction : *block)
        unsupported |= blocksAnchorDiscovery(instruction);
    if(unsupported)continue;
    // Canonical frontiers can hide a previously fused computation behind
    // PHI/select join blocks. Also enumerate exclusive computation blocks,
    // including blocks inside those canonical regions. Do not infer logical
    // adjacency from block layout or from generated block names.
    auto computation=[](BasicBlock*block){
      if(!block->getSingleSuccessor())return false;
      for(auto&i:*block){
        if(isa<BinaryOperator>(i)&&!i.getType()->isIntOrIntVectorTy(1))return true;
        if(auto*c=dyn_cast<CallBase>(&i))if(!c->mayHaveSideEffects()&&!c->mayReadOrWriteMemory())return true;
      }return false;
    };
    std::vector<BasicBlock*> lc,rc;
    for(auto&block:f){
      if(!computation(&block))continue;
      if(l.count(&block)&&!r.count(&block))lc.push_back(&block);
      if(r.count(&block)&&!l.count(&block))rc.push_back(&block);
    }
    for(auto*lb:lc)for(auto*rb:rc){
      if(!a.pdt.dominates(lb,br->getSuccessor(0))&&!a.pdt.dominates(rb,br->getSuccessor(1)))continue;
      result.push_back({f.getName().str(),inv.ids.at(&b),inv.ids.at(lb),inv.ids.at(rb),version});
    }
    auto left=frontier(l,r),right=frontier(r,l);
    for(auto&li:left)for(auto&ri:right){auto&lu=inv.units.at(li);auto&ru=inv.units.at(ri);
      if(bool(lu.region)!=bool(ru.region))continue;
      if(!lu.region&&!a.pdt.dominates(lu.entry,br->getSuccessor(0))&&!a.pdt.dominates(ru.entry,br->getSuccessor(1)))continue;
      result.push_back({f.getName().str(),inv.ids.at(&b),li,ri,version});
    }
  }
  // Add neighbors in direct first-match cascades. Use each earlier arm's
  // own split, not the group head: later neighbors may share the same head side.
  std::map<BasicBlock*,BasicBlock*> joins,next;
  for(auto&b:f){auto*n=a.pdt.getNode(&b);if(n&&n->getIDom())joins[&b]=n->getIDom()->getBlock();}
  for(auto&b:f){auto*br=dyn_cast<BranchInst>(b.getTerminator());if(!br||!br->isConditional()||!joins[&b])continue;
    std::vector<BasicBlock*> continuations;
    for(unsigned i=0;i<2;++i){auto*child=br->getSuccessor(i);auto*cb=dyn_cast<BranchInst>(child->getTerminator());
      if(!cb||!cb->isConditional()||joins[child]!=joins[&b]||!a.dt.dominates(&b,child)||a.dt.dominates(child,&b))continue;
      auto sibling=reachable(br->getSuccessor(1-i),joins[&b]),descendants=reachable(child,joins[&b]);
      if(!sibling.count(child)&&!sibling.count(&b)&&!descendants.count(&b))continuations.push_back(child);
    }if(continuations.size()==1)next[&b]=continuations[0];
  }
  for(auto&b:f)if(next.count(&b)){
    auto*child=next.at(&b);auto*br=cast<BranchInst>(b.getTerminator());auto*cb=cast<BranchInst>(child->getTerminator());
    auto*earlier=br->getSuccessor(br->getSuccessor(0)==child?1:0);
    auto*later=cb->getSuccessor(0);
    if(next.count(child)&&later==next.at(child))later=cb->getSuccessor(1);
    auto ls=reachable(earlier,joins[&b]),rs=reachable(later,joins[&b]);
    for(auto&li:frontier(ls,rs))for(auto&ri:frontier(rs,ls))
      if(bool(inv.units.at(li).region)==bool(inv.units.at(ri).region))result.push_back({f.getName().str(),inv.ids.at(&b),li,ri,version});
  }
  for(auto &pair:inv.leafPairs)if(crossDecisionLeaves||inv.sameDecisionLeafPairs.count(pair))result.push_back({f.getName().str(),std::get<0>(pair),std::get<1>(pair),std::get<2>(pair),version});
  std::sort(result.begin(),result.end(),[](const Candidate&a,const Candidate&b){return a.key()<b.key();});
  result.erase(std::unique(result.begin(),result.end(),[](const Candidate&a,const Candidate&b){return a.key()==b.key();}),result.end());return result;
}
// Conservative CFG adjacency: whole arms of a common-join decision group.
// A one-sided continuation is ordered as first-match arm, then continuation;
// a two-sided tree uses successor order. Never infer order from B/R numbers.
std::vector<Candidate> enumerateAdjacent(Function&f,unsigned version) {
  auto state=LogicalRegionState::initialize(f);state->version=version;
  return state->filter(f,enumerate(f,version));
}
// Adjacent logical leaves need not be opposite immediate branch successors.
// Normalize just their entry chain into a diamond; never clone the remaining
// else-if suffix. Validation is separate from mutation for rejected trials.
struct AdjacentLeafEntry {
  BasicBlock *first=nullptr,*second=nullptr,*left=nullptr,*right=nullptr,*tail=nullptr;
  BranchInst *a=nullptr,*b=nullptr;
  bool hitA=false,hitB=false;
  // apply() hoists the second decision block above the first test, so every
  // lane evaluates it. The instructions computing that decision's own
  // condition must be evaluated to choose a leaf; anything else in the block
  // is leaf work. None: no leaf work may be hoisted. Legacy: any safe work.
  // Budget: safe work up to the budget.
  bool prepare(BasicBlock *L,BasicBlock *R,DominatorTree &DT,LoopInfo &LI,bool regions=false,
               SpeculationMode mode=SpeculationMode::Legacy,int budget=4) {
    auto *P=L->getSinglePredecessor(),*Q=R->getSinglePredecessor();
    if(!P||!Q||P==Q)return false;
    if(P->getSinglePredecessor()==Q){std::swap(L,R);std::swap(P,Q);}
    auto *A=dyn_cast<BranchInst>(P->getTerminator()),*B=dyn_cast<BranchInst>(Q->getTerminator());
    if(!A||!B||!A->isConditional()||!B->isConditional()||Q->getSinglePredecessor()!=P)return false;
    if(LI.getLoopFor(P)||LI.getLoopFor(Q)||Q->hasAddressTaken())return false;
    bool HA=A->getSuccessor(0)==L,HB=B->getSuccessor(0)==R;
    if(A->getSuccessor(HA?0:1)!=L||A->getSuccessor(HA?1:0)!=Q||B->getSuccessor(HB?0:1)!=R)return false;
    auto *Tail=B->getSuccessor(HB?1:0);
    if(Tail==P||Tail==Q||Tail==L||Tail==R)return false;
    auto *LB=dyn_cast<BranchInst>(L->getTerminator()),*RB=dyn_cast<BranchInst>(R->getTerminator());
    if(!regions&&(!LB||!RB||!LB->isUnconditional()||!RB->isUnconditional()||LB->getSuccessor(0)!=RB->getSuccessor(0)))return false;
    if(!L->phis().empty()||!R->phis().empty()||L->hasAddressTaken()||R->hasAddressTaken())return false;
    // Only speculate safe, memory-free entry expressions. Operands must
    // already dominate P or be earlier instructions of this same entry.
    std::set<Instruction*> slice;{
      SmallVector<Instruction*,16> work;if(auto *c=dyn_cast<Instruction>(B->getCondition()))work.push_back(c);
      while(!work.empty()){auto *i=work.pop_back_val();if(i->getParent()!=Q||!slice.insert(i).second)continue;
        for(auto &op:i->operands())if(auto *d=dyn_cast<Instruction>(op))work.push_back(d);}
    }
    unsigned hoisted=0;
    for(auto &I:*Q){if(I.isTerminator())continue;
      if(isa<PHINode>(I)||isa<CallBase>(I)||I.mayReadOrWriteMemory()||I.mayHaveSideEffects()||!isSafeToSpeculativelyExecute(&I))return false;
      if(!slice.count(&I))hoisted+=speculationWeight(I);
      for(auto &O:I.operands())if(auto *D=dyn_cast<Instruction>(O)){
        if(D->getParent()==Q){if(!D->comesBefore(&I))return false;}
        else if(!DT.dominates(D,A))return false;
      }
    }
    if(auto *C=dyn_cast<Instruction>(B->getCondition()))if(C->getParent()!=Q&&!DT.dominates(C,A))return false;
    if((mode==SpeculationMode::None||mode==SpeculationMode::Cost)&&hoisted>0)return false;
    if(mode==SpeculationMode::Budget&&hoisted>unsigned(budget))return false;
    first=P;second=Q;left=L;right=R;tail=Tail;a=A;b=B;hitA=HA;hitB=HB;return true;
  }
  BasicBlock *apply() {
    auto *Gate=BasicBlock::Create(first->getContext(),"leaf.union",first->getParent(),left);
    IRBuilder<> Build(a);
    // select, rather than or, masks poison on the originally untaken second
    // test. Its value was not observed when the first leaf was selected.
    auto *Choose=hitA?a->getCondition():Build.CreateNot(a->getCondition(),"leaf.choose");
    for(auto I=second->begin();!I->isTerminator();){auto *Move=&*I++;Move->moveBefore(a);}
    auto *Other=hitB?b->getCondition():Build.CreateNot(b->getCondition(),"leaf.other");
    auto *Enter=Build.CreateSelect(Choose,Build.getTrue(),Other,"leaf.enter");
    BranchInst::Create(left,right,Choose,Gate);
    for(auto &Phi:tail->phis())Phi.replaceIncomingBlockWith(second,first);
    auto *UnionBranch=BranchInst::Create(Gate,tail,Enter,a);
    SmallVector<Metadata*,8> Members;
    for(auto pair:{std::make_pair(a,left),std::make_pair(b,right)}){
      auto *Old=pair.first->getSuccessor(0)==pair.second?pair.first->getMetadata("fusion.logical.arm"):nullptr;
      if(Old)for(auto &M:Old->operands())Members.push_back(M.get());
      else Members.push_back(MDString::get(first->getContext(),pair.second->hasName()?pair.second->getName().str():name(pair.second)));
    }
    UnionBranch->setMetadata("fusion.logical.arm",MDNode::get(first->getContext(),Members));
    a->eraseFromParent();
    second->eraseFromParent();return Gate;
  }
};
std::set<std::string> crossLevelCatalogRejections(Function &f,
    const std::vector<Candidate> &candidates,const Options &options) {
  std::set<std::string> rejected;
  if(options.crossLevelB2R||!options.hybrid||options.adjacentOnly)return rejected;
  Analysis analysis(f);
  Inventory inventory(f,analysis);
  for(const auto &candidate:candidates){
    if(!StringRef(candidate.left).startswith("B")||
       !StringRef(candidate.right).startswith("B"))continue;
    auto *split=inventory.blocks.at(candidate.split);
    auto *branch=dyn_cast<BranchInst>(split->getTerminator());
    auto *node=analysis.pdt.getNode(split);
    if(!branch||!branch->isConditional()||!node||!node->getIDom()||
       !node->getIDom()->getBlock())continue;
    auto *discriminator=decisionDiscriminator(split);
    if(!discriminator)continue;
    auto left=inventory.units.at(candidate.left),right=inventory.units.at(candidate.right);
    auto *join=node->getIDom()->getBlock();
    const auto ls=reachable(branch->getSuccessor(0),join);
    const auto rs=reachable(branch->getSuccessor(1),join);
    if(belongs(left,rs,ls)&&belongs(right,ls,rs))std::swap(left,right);
    if(!belongs(left,ls,rs)||!belongs(right,rs,ls))continue;
    if(!optionalBehindSameDecision(left.entry,branch->getSuccessor(0),discriminator,analysis)&&
       !optionalBehindSameDecision(right.entry,branch->getSuccessor(1),discriminator,analysis))continue;
    AdjacentLeafEntry direct;
    if(left.exit&&left.exit==right.exit&&direct.prepare(left.entry,right.entry,analysis.dt,
        analysis.loops,false,options.speculation,options.speculationBudget))continue;
    rejected.insert(candidate.key());
  }
  return rejected;
}
// Move only mandatory, simple-load dependency cones to a dedicated leaf
// prefix. Acyclic read-only leaves with speculatable calls cannot change the
// memory state or prevent the original mandatory loads from executing.
static unsigned hoistLeafLoads(Unit &u, Function &f, BasicBlock *gate) {
  Analysis a(f);
  for(auto *b:u.blocks)for(auto &i:*b){
    if(i.isTerminator()||isa<PHINode>(i))continue;
    if(auto *ld=dyn_cast<LoadInst>(&i)){if(!ld->isSimple())return 0;continue;}
    if(i.mayReadOrWriteMemory()||i.mayHaveSideEffects())return 0;
    if(auto *call=dyn_cast<CallBase>(&i))
      if(call->isConvergent()||!isSafeToSpeculativelyExecute(call))return 0;
  }
  SmallVector<Instruction*,32> ordered;
  std::set<Instruction*> selected;
  std::function<bool(Instruction*,SmallVectorImpl<Instruction*>&,std::set<Instruction*>&)> collect;
  collect=[&](Instruction *i,SmallVectorImpl<Instruction*>&pending,std::set<Instruction*>&seen){
    if(selected.count(i)||seen.count(i))return true;
    if(!u.blocks.count(i->getParent()))return a.dt.dominates(i,gate->getTerminator());
    if(!a.pdt.dominates(i->getParent(),u.entry)||isa<PHINode>(i)||i->isTerminator())return false;
    auto *ld=dyn_cast<LoadInst>(i);
    if(ld ? !ld->isSimple() : (isa<CallBase>(i)||i->mayReadOrWriteMemory()||!isSafeToSpeculativelyExecute(i)))return false;
    for(auto &op:i->operands())if(auto *d=dyn_cast<Instruction>(op))if(!collect(d,pending,seen))return false;
    seen.insert(i);pending.push_back(i);return true;
  };
  for(auto &b:f)if(u.blocks.count(&b)&&a.pdt.dominates(&b,u.entry))for(auto &i:b)if(isa<LoadInst>(i)){
    SmallVector<Instruction*,16> pending;std::set<Instruction*> seen;
    if(collect(&i,pending,seen))for(auto *p:pending)if(selected.insert(p).second)ordered.push_back(p);
  }
  if(ordered.empty())return 0;
  auto *prefix=BasicBlock::Create(f.getContext(),"leaf.load.prefix",&f,u.entry);
  auto *end=BranchInst::Create(u.entry,prefix);
  auto *branch=cast<BranchInst>(gate->getTerminator());
  for(unsigned j=0;j<2;++j)if(branch->getSuccessor(j)==u.entry)branch->setSuccessor(j,prefix);
  for(auto *i:ordered)i->moveBefore(end);
  u.blocks.insert(prefix);u.entry=prefix;
  return ordered.size();
}

// Two mutually exclusive straight-line blocks can share a DARM diamond even
// when neither postdominates its enclosing leaf. Keep entry proxies and return
// stubs: only lanes that originally executed an anchor reach its body. SSAUpdater
// carries path-specific values across the new join; no optional load is hoisted.
static bool meldExclusiveBlocks(BasicBlock *left,BasicBlock *right,Value *choose,
                                bool coalesce,unsigned &groups,std::string &why,
                                SpeculationMode mode=SpeculationMode::Legacy,int budget=4) {
  auto &f=*left->getParent();
  auto *lb=dyn_cast<BranchInst>(left->getTerminator());
  auto *rb=dyn_cast<BranchInst>(right->getTerminator());
  if(!lb||!rb||!lb->isUnconditional()||!rb->isUnconditional()||left==right){why="non_straight_anchor";return false;}
  auto reaches=[](BasicBlock *from,BasicBlock *to){
    std::set<BasicBlock*> seen;SmallVector<BasicBlock*,16> work{from};
    while(!work.empty()){auto *b=work.pop_back_val();if(b==to)return true;if(!seen.insert(b).second)continue;
      for(auto *s:successors(b))work.push_back(s);
    }return false;
  };
  if(reaches(left,right)||reaches(right,left)){why="ordered_or_crossing_anchor";return false;}
  for(auto *b:{left,right}){
    if(b->hasAddressTaken()){why="address_taken_anchor";return false;}
    for(auto &i:*b){
      if(i.mayHaveSideEffects()||i.mayWriteToMemory()||i.getType()->isTokenTy()){
        why="side_effect_anchor";return false;
      }
      if(auto *ld=dyn_cast<LoadInst>(&i))if(!ld->isSimple()){why="side_effect_anchor";return false;}
      if(auto *call=dyn_cast<CallBase>(&i))if(call->isConvergent()||call->cannotDuplicate()){
        why="side_effect_anchor";return false;
      }
    }
  }
  auto &ctx=f.getContext();auto *lexit=lb->getSuccessor(0),*rexit=rb->getSuccessor(0);
  auto *lbody=SplitBlock(left,left->getFirstNonPHI());
  auto *rbody=SplitBlock(right,right->getFirstNonPHI());
  auto *gate=BasicBlock::Create(ctx,"anchor.union",&f,lbody);
  auto *join=BasicBlock::Create(ctx,"anchor.return",&f,lexit);
  auto *ltail=BasicBlock::Create(ctx,"anchor.left.return",&f,lexit);
  auto *rtail=BasicBlock::Create(ctx,"anchor.right.return",&f,rexit);
  BranchInst::Create(lexit,ltail);BranchInst::Create(rexit,rtail);
  for(auto &phi:lexit->phis())phi.replaceIncomingBlockWith(lbody,ltail);
  for(auto &phi:rexit->phis())phi.replaceIncomingBlockWith(rbody,rtail);
  cast<BranchInst>(left->getTerminator())->setSuccessor(0,gate);
  cast<BranchInst>(right->getTerminator())->setSuccessor(0,gate);
  // Reuse the original leaf selector. It dominates all anchors and preserves
  // the established divergent predicate rather than reconstructing identity
  // from a new multi-entry PHI. This also avoids redundant selector PHIs.
  BranchInst::Create(lbody,rbody,choose,gate);
  cast<BranchInst>(lbody->getTerminator())->setSuccessor(0,join);
  cast<BranchInst>(rbody->getTerminator())->setSuccessor(0,join);
  BranchInst::Create(ltail,rtail,choose,join);
  DominatorTree dt(f);
  // Record uses before inserting PHIs; otherwise newly created PHI operands
  // would be visited twice. Undefined inputs occur only on the opposite path.
  std::vector<std::pair<Instruction*,SmallVector<Use*,8>>> repair;
  for(auto &b:f)for(auto &i:b){
    SmallVector<Use*,8> uses;
    for(auto &use:i.uses())if(isa<Instruction>(use.getUser())&&!dt.dominates(&i,use))uses.push_back(&use);
    if(!uses.empty())repair.emplace_back(&i,std::move(uses));
  }
  for(auto &item:repair){
    SSAUpdater updater;updater.Initialize(item.first->getType(),"anchor.live");
    updater.AddAvailableValue(item.first->getParent(),item.first);
    for(auto *use:item.second)updater.RewriteUse(*use);
  }
  if(verifyFunction(f,&errs())){why="anchor_ssa_verifier_failed";return false;}
  Analysis a(f);RegionAnalyzer ma(gate,a.dt,a.pdt);ma.selectExplicitBlocks(lbody,rbody);
  RegionMelder melder(ma,true);melder.CoalesceGaps=coalesce;melder.SpeculationMode=int(mode);melder.SpeculationBudget=budget;melder.merge(0);groups+=melder.CoalescedGapGroups;
  if(verifyFunction(f,&errs())){why="anchor_meld_verifier_failed";return false;}
  return true;
}

static bool meldLeafPlan(Module &m,const Candidate &c,Unit l,Unit r,BasicBlock *gate,
                         unsigned &moved,unsigned &anchors,unsigned &groups,std::vector<std::string> &pairs,std::string &why) {
  auto &f=*m.getFunction(c.function);
  for(auto *u:{&l,&r})for(auto *b:u->blocks)for(auto &i:*b)
    if(auto *call=dyn_cast<CallBase>(&i))if(call->isConvergent()||call->cannotDuplicate()){
      why="leaf_plan_convergence_sensitive_call";return false;
    }
  auto *branch=cast<BranchInst>(gate->getTerminator());
  Value *choose=branch->getCondition();
  if(branch->getSuccessor(0)!=l.entry)choose=IRBuilder<>(branch).CreateNot(choose,"leaf.plan.choose");
  WeakTrackingVH selector(choose);
  moved=hoistLeafLoads(l,f,gate);
  moved+=hoistLeafLoads(r,f,gate);
  if(verifyFunction(f,&errs())){why="leaf_load_motion_verifier_failed";return false;}
  struct Pair {WeakVH left,right;double score;unsigned order;std::string label;};
  std::vector<Pair> plan;unsigned order=0;
  for(auto &lb:f)if(l.blocks.count(&lb)&&lb.getSingleSuccessor())
    for(auto &rb:f)if(r.blocks.count(&rb)&&rb.getSingleSuccessor()){
      auto count=[](BasicBlock &b){unsigned n=0;for(auto &i:b)if(!isa<PHINode>(i)&&!i.isTerminator())++n;return n;};
      unsigned n=std::min(count(lb),count(rb));if(!n)continue;
      double sim=Utils::computeBBSimilarty(&lb,&rb);if(sim<=0)continue;
      plan.push_back({WeakVH(&lb),WeakVH(&rb),sim*n,order++,name(&lb)+" + "+name(&rb)});
    }
  std::stable_sort(plan.begin(),plan.end(),[](const Pair &a,const Pair &b){return a.score>b.score;});
  std::set<BasicBlock*> used;
  // No cleanup between anchors: score and clean the whole composite trial.
  for(auto &p:plan){
    auto *lb=dyn_cast_or_null<BasicBlock>((Value*)p.left),*rb=dyn_cast_or_null<BasicBlock>((Value*)p.right);
    if(!lb||!rb||used.count(lb)||used.count(rb))continue;
    std::string reason;
    if(!meldExclusiveBlocks(lb,rb,selector,c.coalesceGaps,groups,reason,c.speculation,c.speculationBudget)){
      if(reason=="ordered_or_crossing_anchor"||reason=="non_straight_anchor"||reason=="address_taken_anchor"||reason=="side_effect_anchor")continue;
      why=reason;return false;
    }
    used.insert(lb);used.insert(rb);++anchors;pairs.push_back(p.label);
  }
  if(!anchors){why="no_compatible_multi_anchor";return false;}
  return true;
}

// ---- Uniform-wave side reachability (static, no probabilities) ----
// The split condition is tagged in the trial clone so it can be found again
// after CloneModule and cleanup. Instruction conditions carry instruction
// metadata; argument conditions carry function metadata with the arg number.
static const char *SideTag="fusion.side.condition";
static const char *SideArgTag="fusion.side.condition.arg";
static bool hasSideTag(const Function *f) {
  if(!f)return false;
  if(f->getMetadata(SideArgTag))return true;
  for(auto &b:*f)for(auto &i:b)if(i.getMetadata(SideTag))return true;
  return false;
}
static void stripSideTag(Module *m) {
  if(!m)return;
  for(auto &f:*m){f.setMetadata(SideArgTag,nullptr);for(auto &b:f)for(auto &i:b)if(i.getMetadata(SideTag))i.setMetadata(SideTag,nullptr);}
}
static bool tagSideCondition(Function &f,Value *cond) {
  auto &ctx=f.getContext();
  if(auto *i=dyn_cast<Instruction>(cond)){i->setMetadata(SideTag,MDNode::get(ctx,{}));return true;}
  if(auto *a=dyn_cast<Argument>(cond)){
    f.setMetadata(SideArgTag,MDNode::get(ctx,{ConstantAsMetadata::get(ConstantInt::get(Type::getInt32Ty(ctx),a->getArgNo()))}));
    return true;
  }
  return false; // constants need no tracking; callers handle them directly
}
static Value *findSideCondition(Function &f,std::string &why) {
  if(auto *md=f.getMetadata(SideArgTag)){
    auto *c=mdconst::dyn_extract<ConstantInt>(md->getOperand(0));
    if(!c||c->getZExtValue()>=f.arg_size()){why="side_condition_bad_argument";return nullptr;}
    return f.getArg(c->getZExtValue());
  }
  Value *found=nullptr;
  for(auto &b:f)for(auto &i:b)if(i.getMetadata(SideTag)){
    if(found){why="side_condition_duplicated";return nullptr;}
    found=&i;
  }
  if(!found)why="side_condition_lost";
  return found;
}
// Blocks reachable when the split condition is fixed to `value`. Only branch
// and switch conditions that fold after substituting the constant are pruned;
// every other branch keeps both successors. The clone is discarded, so
// simplified instructions are never removed from the cost accounting: costs
// are summed later over these block indices of the real function.
static bool sideBlocks(Function &f,Value *cond,bool value,std::vector<unsigned> &out,std::string &why) {
  out.clear();
  if(!cond||!cond->getType()->isIntegerTy(1)){why="side_condition_not_i1";return false;}
  ValueToValueMapTy vm;Function *clone=CloneFunction(&f,vm);
  struct Erase{Function *f;~Erase(){f->eraseFromParent();}} erase{clone};
  Value *c=cond;if(!isa<Constant>(cond))c=vm.lookup(cond);
  if(!c){why="side_condition_unmapped";return false;}
  auto *k=ConstantInt::get(Type::getInt1Ty(f.getContext()),value);
  SimplifyQuery query(f.getParent()->getDataLayout());
  SmallVector<Instruction*,64> work;
  auto users=[&](Value *v){for(auto *u:v->users())if(auto *i=dyn_cast<Instruction>(u))work.push_back(i);};
  if(!isa<Constant>(c)){users(c);c->replaceAllUsesWith(k);}
  for(unsigned guard=0;!work.empty();){
    if(++guard>200000){why="side_simplification_budget";return false;}
    auto *i=work.pop_back_val();
    if(auto *v=SimplifyInstruction(i,query))if(v!=i){users(i);i->replaceAllUsesWith(v);}
  }
  std::map<BasicBlock*,unsigned> index;unsigned n=0;for(auto &b:*clone)index[&b]=n++;
  std::set<BasicBlock*> seen;SmallVector<BasicBlock*,32> todo{&clone->getEntryBlock()};
  while(!todo.empty()){
    auto *b=todo.pop_back_val();if(!seen.insert(b).second)continue;
    auto *t=b->getTerminator();
    if(auto *br=dyn_cast<BranchInst>(t))if(br->isConditional())if(auto *ci=dyn_cast<ConstantInt>(br->getCondition())){
      todo.push_back(br->getSuccessor(ci->isZero()?1:0));continue;
    }
    if(auto *sw=dyn_cast<SwitchInst>(t))if(auto *ci=dyn_cast<ConstantInt>(sw->getCondition())){
      todo.push_back(sw->findCaseValue(ci)->getCaseSuccessor());continue;
    }
    for(auto *s:successors(b))todo.push_back(s);
  }
  for(auto *b:seen)out.push_back(index.at(b));
  std::sort(out.begin(),out.end());
  return true;
}
static bool sideBlocksBoth(Function &f,Value *cond,std::vector<unsigned> (&sides)[2],std::string &why) {
  return sideBlocks(f,cond,false,sides[0],why)&&sideBlocks(f,cond,true,sides[1],why);
}

// Share identical trailing arithmetic by redirecting the short arm to
// the existing anchor. All other edges, including the long arm's memory
// paths, keep their original execution conditions.
static bool shareReplicatedAnchor(BasicBlock *split, BasicBlock *shortArm,
                                  BasicBlock *anchor, BasicBlock *join,
                                  DominatorTree &dt) {
  auto *branch = cast<BranchInst>(split->getTerminator());
  auto *shortExit = dyn_cast<BranchInst>(shortArm->getTerminator());
  auto *anchorExit = dyn_cast<BranchInst>(anchor->getTerminator());
  if (!shortExit || !shortExit->isUnconditional() ||
      !anchorExit || !anchorExit->isUnconditional() ||
      shortArm->getSinglePredecessor() != split ||
      shortExit->getSuccessor(0) != join ||
      anchorExit->getSuccessor(0) != join || anchor->hasAddressTaken() ||
      shortArm->hasAddressTaken() || shortArm->size() != anchor->size())
    return false;

  DenseMap<Value *, Value *> matches;
  auto other = anchor->begin();
  for (auto &inst : *shortArm) {
    if (inst.isTerminator()) break;
    auto *match = &*other++;
    if (!isa<BinaryOperator>(inst) || !inst.isIdenticalTo(match) ||
        inst.hasMetadataOtherThanDebugLoc() ||
        match->hasMetadataOtherThanDebugLoc())
      return false;
    for (auto &operand : inst.operands())
      if (auto *def = dyn_cast<Instruction>(operand.get()))
        if (!dt.dominates(def, branch)) return false;
    for (auto *value : {&inst, match}) {
      for (const auto &use : value->uses()) {
        auto *phi = dyn_cast<PHINode>(use.getUser());
        if (!phi || phi->getParent() != join ||
            phi->getIncomingBlock(use.getOperandNo()) != value->getParent())
          return false;
      }
    }
    matches[&inst] = match;
  }
  if (matches.empty()) return false;
  for (auto &phi : join->phis()) {
    auto *shortValue = phi.getIncomingValueForBlock(shortArm);
    auto *anchorValue = phi.getIncomingValueForBlock(anchor);
    if (shortValue != anchorValue && matches.lookup(shortValue) != anchorValue)
      return false;
  }
  for (auto &phi : join->phis()) phi.removeIncomingValue(shortArm, false);
  branch->setSuccessor(branch->getSuccessor(0) == shortArm ? 0 : 1, anchor);
  shortArm->eraseFromParent();
  return true;
}

// Extract identical integer computations from two tails without changing
// any incoming edge. Each old result must be used only on its own exit edge.
static bool hoistCommonTailArithmetic(BasicBlock &left, BasicBlock &right,
                                      BasicBlock &split, BasicBlock &join,
                                      Analysis &analysis) {
  auto *loop = analysis.loops.getLoopFor(&split);
  auto *dominator = analysis.dt.findNearestCommonDominator(&left, &right);
  if (!loop || !dominator || dominator == &left || dominator == &right ||
      analysis.loops.getLoopFor(dominator) != loop ||
      !analysis.dt.dominates(dominator, &split) ||
      analysis.loops.getLoopFor(&left) != loop ||
      analysis.loops.getLoopFor(&right) != loop ||
      analysis.loops.getLoopFor(&join) != loop)
    return false;

  auto tail = [&](BasicBlock &block) {
    auto *branch = dyn_cast<BranchInst>(block.getTerminator());
    return branch && branch->isUnconditional() &&
        branch->getSuccessor(0) == &join;
  };
  if (!tail(left) || !tail(right)) return false;

  auto *insert = dominator->getTerminator();
  auto movable = [&](const Instruction &inst) {
    switch (inst.getOpcode()) {
    case Instruction::Add: case Instruction::Sub: case Instruction::Mul:
    case Instruction::And: case Instruction::Or: case Instruction::Xor:
      break;
    default:
      return false;
    }
    if (inst.use_empty() || inst.hasMetadataOtherThanDebugLoc()) return false;
    for (const auto &operand : inst.operands())
      if (auto *def = dyn_cast<Instruction>(operand.get()))
        if (!analysis.dt.dominates(def, insert)) return false;
    for (const auto &use : inst.uses()) {
      auto *phi = dyn_cast<PHINode>(use.getUser());
      if (!phi || phi->getParent() != &join ||
          phi->getIncomingBlock(use) != inst.getParent())
        return false;
    }
    return true;
  };

  bool changed = false;
  for (auto &inst : make_early_inc_range(left)) {
    if (!movable(inst)) continue;
    auto match = llvm::find_if(right, [&](Instruction &other) {
      return inst.isIdenticalTo(&other) && movable(other);
    });
    if (match == right.end()) continue;
    inst.moveBefore(insert);
    // The shared instruction now executes on additional source paths.
    inst.setDebugLoc(DebugLoc());
    match->replaceAllUsesWith(&inst);
    match->eraseFromParent();
    changed = true;
  }
  return changed;
}

static Trial tryPairImpl(const Module&parent,const Candidate&c,unsigned version,unsigned level,CleanupMode mode,const LogicalRegionState *logical,bool nested);
// Public entry. The outermost call owns the side tag and removes it from every
// IR it returns, so committed modules, debug dumps and hashes never carry it.
Trial tryPair(const Module&parent,const Candidate&c,unsigned version,unsigned level,CleanupMode mode,const LogicalRegionState *logical) {
  bool nested=hasSideTag(parent.getFunction(c.function));
  Trial t=tryPairImpl(parent,c,version,level,mode,logical,nested);
  if(!nested){stripSideTag(t.raw.get());stripSideTag(t.normalized.get());}
  return t;
}
static Trial tryPairImpl(const Module&parent,const Candidate&c,unsigned version,unsigned level,CleanupMode mode,const LogicalRegionState *logical,bool nested) {
  auto started=Clock::now();Trial t;t.candidate=c;t.cleanupMode=mode;auto reject=[&](const char*reason){t.reason=reason;t.totalMs=millis(started);return std::move(t);};
  // After-side reachability on the final cleaned IR, before the tag is stripped.
  auto finishSides=[&](Function *after){
    std::string why;Value *cond=findSideCondition(*after,why);
    if(cond)t.sideAfterOk=sideBlocksBoth(*after,cond,t.sideAfter,why);
    if(!t.sideAfterOk&&t.sideReason.empty())t.sideReason=why;
  };
  if(c.version!=version)return reject("stale_candidate_version");
  ValueToValueMapTy parentMap;
  t.raw=CloneModule(parent,parentMap);if(logical)t.logicalState=logical->clone(parentMap);parentMap.clear();auto*f=t.raw->getFunction(c.function);
  if(!f||f->isDeclaration())return reject("function_missing");
  if(verifyModule(*t.raw,&errs()))return reject("input_verifier_failed");
  Analysis a(*f);Inventory inv(*f,a);
  if(!inv.blocks.count(c.split)||!inv.units.count(c.left)||!inv.units.count(c.right))return reject("unknown_block_or_region_id");
  auto*split=inv.blocks.at(c.split);auto*br=dyn_cast<BranchInst>(split->getTerminator());auto*node=a.pdt.getNode(split);
  bool completeLeaf=!c.left.empty()&&c.left[0]=='E'&&!c.right.empty()&&c.right[0]=='E';
  if(!br||!br->isConditional())return reject("unsupported_split_location");
  // Outermost trial: tag the split condition and record before-side blocks on
  // the still-unmodified clone (block indices equal the parent's).
  if(!nested){
    std::string why;
    if(!tagSideCondition(*f,br->getCondition()))t.sideReason="side_condition_constant";
    else t.sideBeforeOk=sideBlocksBoth(*f,br->getCondition(),t.sideBefore,why);
    if(!t.sideBeforeOk&&t.sideReason.empty())t.sideReason=why;
  }
  if(!completeLeaf&&(!node||!node->getIDom()||!node->getIDom()->getBlock()||!Utils::isValidMergeLocation(*split,a.pdt)))return reject("unsupported_split_location");
  Unit l=inv.units.at(c.left),r=inv.units.at(c.right);
  if(completeLeaf){
    auto key=std::make_tuple(c.split,c.left,c.right);
    auto reverse=std::make_tuple(c.split,c.right,c.left);
    if(!c.crossDecisionLeaves && !inv.sameDecisionLeafPairs.count(key) &&
       !inv.sameDecisionLeafPairs.count(reverse))
      return reject(inv.crossLevelLeafPairs.count(key)||inv.crossLevelLeafPairs.count(reverse)?
        "complete_leaf_cross_level_requires_opt_in":"complete_leaf_cross_or_unknown_decision_requires_opt_in");
    if(logical)return reject("complete_leaf_requires_structural_enumeration");
    if(!c.hybrid)return reject("complete_leaf_requires_structural_mode");
    if(!l.exit||l.exit!=r.exit)return reject("complete_leaf_exit_mismatch");
    for(auto *bb:l.blocks)if(r.blocks.count(bb))return reject("overlapping_pair");
    AdjacentLeafEntry entry;
    if(!entry.prepare(l.entry,r.entry,a.dt,a.loops,true,c.speculation,c.speculationBudget)||entry.first!=split)
      return reject("complete_leaf_entry_not_normalizable");
    auto leftBoundary=boundary(l,*f),rightBoundary=boundary(r,*f);
    auto before=features(*f);
    auto localBefore=snapshotLocal(*f);
    std::vector<WeakVH> priorBlocks;for(auto &b:*f)priorBlocks.emplace_back(&b);
    auto *gate=entry.apply();
    if(c.completeLeafPlan){
      t.before=before;t.left=leftBoundary;t.right=rightBoundary;
      t.leftContext=leftBoundary;t.rightContext=rightBoundary;
      t.mergePath="darm-complete-leaf/multi-anchor";t.planKind="multi-B2B";
      auto mt=Clock::now();std::string why;
      if(!meldLeafPlan(*t.raw,c,l,r,gate,t.movedLeafInstructions,t.leafAnchors,t.coalescedGapGroups,t.leafAnchorPairs,why)){
        t.reason=why;t.totalMs=millis(started);return t;
      }
      canonicalPhiOrder(*t.raw,c.function);t.mergeMs=millis(mt);
      if(verifyModule(*t.raw,&errs()))return reject("raw_verifier_failed");
      t.afterRaw=features(*f);if(t.afterRaw.loops>t.before.loops)return reject("new_raw_loop");
      auto rawScope=changedLocal(*f,localBefore);std::set<BasicBlock*> oldBlocks,created;
      for(auto &h:priorBlocks)if(auto *b=dyn_cast_or_null<BasicBlock>((Value*)h))oldBlocks.insert(b);
      for(auto &b:*f)if(!oldBlocks.count(&b))created.insert(&b);
      ValueToValueMapTy map;auto nt=Clock::now();t.normalized=CloneModule(*t.raw,map);
      std::set<Instruction*> cleanScope;std::set<BasicBlock*> cleanCreated;
      for(auto *i:rawScope)if(auto *v=dyn_cast_or_null<Instruction>(map.lookup(i)))cleanScope.insert(v);
      for(auto *b:created)if(auto *v=dyn_cast_or_null<BasicBlock>(map.lookup(b)))cleanCreated.insert(v);
      map.clear();
      t.cleanupIterations=(mode==CleanupMode::ScopedCFG||mode==CleanupMode::ScopedCFGTriangles)?cleanupProductionScopedCFG(*t.normalized->getFunction(c.function),cleanScope,cleanCreated,mode==CleanupMode::ScopedCFGTriangles):mode==CleanupMode::ScopedLocal?cleanupScoped(*t.normalized->getFunction(c.function),cleanScope):cleanup(*t.normalized,c.function,level,mode);
      canonicalPhiOrder(*t.normalized,c.function);t.normalizeMs=millis(nt);
      if(verifyModule(*t.normalized,&errs()))return reject("normalized_verifier_failed");
      t.after=features(*t.normalized->getFunction(c.function));if(t.after.loops>t.before.loops)return reject("new_normalized_loop");
      for(auto &g:parent)if(g.getName()!=c.function){
        auto *raw=t.raw->getFunction(g.getName()),*after=t.normalized->getFunction(g.getName());
        if(!raw||!after||text(g)!=text(*raw)||text(g)!=text(*after))return reject("other_function_changed");
      }
      finishSides(t.normalized->getFunction(c.function));
      t.valid=true;t.reason="verified_ir_only";t.totalMs=millis(started);return t;
    }
    if(verifyModule(*t.raw,&errs()))return reject("complete_leaf_gate_verifier_failed");
    Analysis ga(*f);Inventory gi(*f,ga);
    // Use native DARM alignment/replication within this isolated diamond.
    // Different outer shapes do not require a fictitious region bijection:
    // align a block pair, with at least one mandatory block. Unmatched CFG
    // stays guarded; the opposite single block can be replicated by DARM.
    BasicBlock *bl=nullptr,*brMatch=nullptr;double best=-1;
    const auto &leftBlocks=entry.left==l.entry?l.blocks:r.blocks;
    const auto &rightBlocks=entry.left==l.entry?r.blocks:l.blocks;
    for(auto &lb:*f)if(leftBlocks.count(&lb))for(auto &rb:*f)if(rightBlocks.count(&rb)){
      bool lr=ga.pdt.dominates(&lb,entry.left),rr=ga.pdt.dominates(&rb,entry.right);
      if(!lr&&!rr)continue;
      // RegionReplicator cannot move an expanded block's predecessor PHIs
      // into the opposite topology. Keep such joins as retained context.
      if((!lr&&!rb.phis().empty())||(!rr&&!lb.phis().empty()))continue;
      if((!lr&&!rb.getUniqueSuccessor())||(!rr&&!lb.getUniqueSuccessor()))continue;
      double sim=Utils::computeBBSimilarty(&lb,&rb);
      if(sim>best){best=sim;bl=&lb;brMatch=&rb;}
    }
    if(!bl||!brMatch||best<=0)return reject("complete_leaf_no_native_block_match");
    Candidate inner{c.function,gi.ids.at(gate),gi.ids.at(bl),gi.ids.at(brMatch),version};
    // Native RegionMelder handles conditional terminators and optional blocks.
    // Disable local dispatch: this is a complete-region scoped trial.
    inner.coalesceGaps=c.coalesceGaps;
    // The outer complete-leaf boundary already decided cross-level admission.
    inner.crossLevelB2R=c.crossLevelB2R||c.crossDecisionLeaves;inner.speculation=c.speculation;inner.speculationBudget=c.speculationBudget;
    auto out=tryPair(*t.raw,inner,version,level,mode,nullptr);
    out.candidate=c;out.before=before;
    out.left=leftBoundary;out.right=rightBoundary;
    out.leftContext=leftBoundary;out.rightContext=rightBoundary;
    out.mergePath="darm-complete-leaf/"+out.mergePath;
    // The inner trial starts from the gated clone; its before-sides would use
    // the wrong parent. Keep this trial's (pre-gate) sides instead.
    for(unsigned s=0;s<2;++s)out.sideBefore[s]=t.sideBefore[s];
    out.sideBeforeOk=t.sideBeforeOk;if(!t.sideReason.empty())out.sideReason=t.sideReason;
    out.totalMs=millis(started);
    return out;
  }
  if(bool(l.region)!=bool(r.region))return reject("mixed_granularity_not_supported");
  for(auto*b:l.blocks)if(r.blocks.count(b))return reject("overlapping_pair");
  auto*join=node->getIDom()->getBlock();auto ls=reachable(br->getSuccessor(0),join),rs=reachable(br->getSuccessor(1),join);
  if(belongs(l,rs,ls)&&belongs(r,ls,rs)){std::swap(l,r);t.swapped=true;}
  else if(!belongs(l,ls,rs)||!belongs(r,rs,ls))return reject("pair_not_exclusive_on_opposite_sides");
  t.left=boundary(l,*f);
  t.right=boundary(r,*f);
  auto scope=ls;
  scope.insert(rs.begin(),rs.end());
  // Merge only the two entry blocks. A downstream loop on one arm can
  // stay on that arm when neither entry needs replication.
  auto loopEntryPair=[&](const Unit &loopSide,const Unit &bypass) {
    if(l.region||r.region||c.speculation!=SpeculationMode::None||
       loopSide.entry->getSinglePredecessor()!=split||
       bypass.entry->getSinglePredecessor()!=split||
       a.loops.getLoopFor(loopSide.entry)!=a.loops.getLoopFor(split)||
       a.loops.getLoopFor(bypass.entry)!=a.loops.getLoopFor(split)||
       bypass.entry->getSingleSuccessor()!=join)return false;
    auto *header=loopSide.entry->getSingleSuccessor();
    if(!header)return false;
    auto *loop=a.loops.getLoopFor(header);
    if(!loop||loop->getHeader()!=header||loop->getLoopPreheader()!=loopSide.entry||
       loop->getParentLoop()!=a.loops.getLoopFor(split)||
       loop->getUniqueExitBlock()!=join||loop->getNumBlocks()+2!=scope.size())
      return false;
    for(auto *block:loop->blocks())if(!scope.count(block))return false;
    for(auto *entry:{loopSide.entry,bypass.entry})
      for(auto &instruction:*entry)
        if(!instruction.isTerminator()&&
           (instruction.mayReadOrWriteMemory()||instruction.mayHaveSideEffects()||
            isa<CallBase>(instruction)))return false;
    return true;
  };
  const bool preservedLoop=loopEntryPair(l,r)||loopEntryPair(r,l);
  const bool siblingLoops=supportedSingleBlockLoopPair(split,join,l,r,scope,a.loops);
  if(!preservedLoop && !supportedLoopScope(split,join,scope,a.loops) && !siblingLoops) {
    // A shared tail left by an earlier fusion may have a bypass edge.
    // Match pure computations without giving RegionMelder that shared block.
    auto externalPredecessor = [&](BasicBlock *block) {
      return llvm::any_of(predecessors(block), [&](BasicBlock *pred) {
        return pred != split && !scope.count(pred);
      });
    };
    if (!l.region && !logical && !nested && c.hybrid &&
        c.speculation == SpeculationMode::Cost &&
        mode == CleanupMode::DarmCFGRedundancy &&
        c.splitMatches.empty() && !c.explicitGapPlan &&
        (externalPredecessor(l.entry) || externalPredecessor(r.entry))) {
      t.before = features(*f);
      if (hoistCommonTailArithmetic(*l.entry, *r.entry, *split, *join, a)) {
        t.rewriteStarted = true;
        t.mergePath = "common-tail-arithmetic";
        const bool leftRequired = a.pdt.dominates(l.entry, br->getSuccessor(0));
        const bool rightRequired = a.pdt.dominates(r.entry, br->getSuccessor(1));
        t.planKind = !rightRequired ? "B2R" : !leftRequired ? "R2B" : "B2B";
        t.matchedLeft = t.left.entry;
        t.matchedRight = t.right.entry;
        t.leftContext = t.left;
        t.rightContext = t.right;
        t.loopHeaderSplit = a.loops.isLoopHeader(split);
        if (verifyModule(*t.raw, &errs())) return reject("raw_verifier_failed");
        t.afterRaw = features(*f);
        t.normalized = CloneModule(*t.raw);
        t.cleanupIterations = cleanup(*t.normalized, c.function, level, mode);
        if (verifyModule(*t.normalized, &errs()))
          return reject("normalized_verifier_failed");
        auto *after = t.normalized->getFunction(c.function);
        t.after = features(*after);
        finishSides(after);
        t.valid = true;
        t.reason = "verified_ir_only";
        t.totalMs = millis(started);
        return t;
      }
    }
    auto *enclosing=a.loops.getLoopFor(split);
    if(a.loops.getLoopFor(join)!=enclosing)
      t.localRejectReason="split_and_join_in_different_loops";
    else {
      t.localRejectReason="scope_has_backedge_or_external_edge";
      for(auto *block:scope)if(a.loops.getLoopFor(block)!=enclosing) {
        t.localRejectReason="scope_contains_different_loop";
        break;
      }
    }
    return reject("loop_in_trial_scope_not_supported");
  }
  const bool leftRequired=a.pdt.dominates(l.entry,br->getSuccessor(0));
  const bool rightRequired=a.pdt.dominates(r.entry,br->getSuccessor(1));
  const bool guardsUnsafeWork=c.speculation==SpeculationMode::None||c.speculation==SpeculationMode::Cost;
  const bool guardedAnchors=!l.region && leftRequired && rightRequired &&
      !logical && !c.localCopysign && guardsUnsafeWork;
  const bool matchedStorePair=(l.region ||
      (l.entry==br->getSuccessor(0) && r.entry==br->getSuccessor(1) &&
       l.entry->getSingleSuccessor()==join && r.entry->getSingleSuccessor()==join)) &&
      leftRequired &&
      rightRequired && !logical && !c.localCopysign &&
      guardsUnsafeWork;
  // Only admit ordinary accesses on the side whose CFG is replicated.
  // Cost/none verify guarded emission; explicit legacy mode reproduces
  // DARM's read/select/write predication for the same structural match.
  const bool replicationWithMemory = !l.region && !logical &&
      !c.localCopysign && leftRequired != rightRequired &&
      (leftRequired ? l.entry : r.entry) ==
          br->getSuccessor(leftRequired ? 0 : 1) &&
      (leftRequired ? l.entry : r.entry)->getSingleSuccessor() == join;
  const bool guardedReplication = replicationWithMemory && guardsUnsafeWork;
  const bool legacyReplication = replicationWithMemory &&
      c.speculation == SpeculationMode::Legacy;
  std::map<BasicBlock *, SmallVector<Instruction *, 8>> replicatedMemory;
  std::set<StoreInst*> regionStores;
  std::vector<std::vector<std::pair<Instruction*,Instruction*>>> matchedMemory;
  size_t matchedStoreCount=0;
  const bool auditDownstream=guardedAnchors&&!preservedLoop&&
      l.entry==br->getSuccessor(0)&&r.entry==br->getSuccessor(1);
  struct DownstreamAccess {
    WeakVH instruction;
    BasicBlock *block;
    SmallVector<WeakTrackingVH,4> operands;
  };
  std::vector<DownstreamAccess> downstream;
  struct DownstreamPath {
    std::vector<std::pair<WeakTrackingVH,bool>> conditions;
    std::vector<unsigned> accesses;
  };
  std::vector<DownstreamPath> paths;
  bool downstreamWrite=false;
  struct ProtectedWrite {
    WeakVH instruction;
    BasicBlock *block;
    Value *value;
    Value *address;
    bool leftSide;
  };
  std::vector<ProtectedWrite> protectedWrites;
  for(auto *block:scope) for(auto &instruction:*block) {
    if(preservedLoop&&block!=l.entry&&block!=r.entry)continue;
    if(auto *call=dyn_cast<CallBase>(&instruction))
      if(call->isConvergent()) return reject("convergent_call_in_trial_scope");
    if ((guardedReplication || legacyReplication) && instruction.mayReadOrWriteMemory()) {
      auto *load = dyn_cast<LoadInst>(&instruction);
      auto *store = dyn_cast<StoreInst>(&instruction);
      if (!(leftRequired ? rs : ls).count(block) ||
          block == (leftRequired ? r.entry : l.entry) ||
          !((load && load->isSimple()) || (store && store->isSimple())))
        return reject("unsupported_replicated_memory_access");
      if (guardedReplication)
        replicatedMemory[block].push_back(&instruction);
      continue;
    }
    if(auditDownstream&&block!=l.entry&&block!=r.entry&&instruction.mayReadOrWriteMemory()){
      auto *load=dyn_cast<LoadInst>(&instruction);
      auto *store=dyn_cast<StoreInst>(&instruction);
      if((load&&load->isSimple())||(store&&store->isSimple())){
        DownstreamAccess access{&instruction,block,{}};
        for(auto &operand:instruction.operands())access.operands.emplace_back(operand.get());
        downstream.push_back(std::move(access));
        downstreamWrite|=store!=nullptr;
        continue;
      }
      return reject("unsupported_downstream_memory_access");
    }
    if(!instruction.mayHaveSideEffects()&&!instruction.mayWriteToMemory())continue;
    if(guardedAnchors) {
      if(auto *intrinsic=dyn_cast<IntrinsicInst>(&instruction))
        if(intrinsic->getIntrinsicID()==Intrinsic::lifetime_start ||
           intrinsic->getIntrinsicID()==Intrinsic::lifetime_end)continue;
      if(auto *store=dyn_cast<StoreInst>(&instruction)) {
        auto *object=dyn_cast<AllocaInst>(getUnderlyingObject(store->getPointerOperand()));
        if(block!=l.entry && block!=r.entry && ls.count(block)!=rs.count(block) &&
           store->isSimple() &&
           object && object->getFunction()==f && !PointerMayBeCaptured(object,true,true)) {
          protectedWrites.push_back({store,block,store->getValueOperand(),
                                     store->getPointerOperand(),ls.count(block)!=0});
          continue;
        }
      }
    }
    if(matchedStorePair)
      if(auto *store=dyn_cast<StoreInst>(&instruction))
        if(store->isSimple() &&
           (!l.region || store->getPointerAddressSpace()==3) &&
           (l.blocks.count(block)||r.blocks.count(block))){
          regionStores.insert(store);
          continue;
        }
    return reject("side_effect_in_trial_scope_not_supported");
  }
  if(downstreamWrite){
    // Enumerate the original acyclic paths. Record the decisions and the
    // sequence of untouched accesses, including accesses at shared tails.
    std::function<bool(BasicBlock*,DownstreamPath,unsigned)> capture=
      [&](BasicBlock *block,DownstreamPath path,unsigned depth){
        if(paths.size()>=64||depth>64)return false;
        if(block==join){paths.push_back(std::move(path));return true;}
        for(unsigned i=0;i<downstream.size();++i)
          if(downstream[i].block==block)path.accesses.push_back(i);
        auto *branch=dyn_cast<BranchInst>(block->getTerminator());
        if(!branch)return false;
        if(!branch->isConditional())return capture(branch->getSuccessor(0),std::move(path),depth+1);
        auto *condition=branch->getCondition();
        for(const auto &known:path.conditions)
          if((Value*)known.first==condition)
            return capture(branch->getSuccessor(known.second?0:1),std::move(path),depth+1);
        if(auto *constant=dyn_cast<ConstantInt>(condition))
          return capture(branch->getSuccessor(constant->isOne()?0:1),std::move(path),depth+1);
        path.conditions.emplace_back(condition,true);
        if(!capture(branch->getSuccessor(0),path,depth+1))return false;
        path.conditions.back().second=false;
        return capture(branch->getSuccessor(1),std::move(path),depth+1);
      };
    if(!capture(split,{},0))return reject("downstream_paths_not_supported");
  }
  if(!l.region&&!leftRequired&&!rightRequired)
    return reject("both_selected_blocks_optional_replication_not_supported");
  SmallVector<std::pair<BasicBlock*,BasicBlock*>,8> memoryBlocks;
  RegionAnalyzer ma(split,a.dt,a.pdt);
  if(l.region){if(!l.exit||!r.exit)return reject("region_without_exit");
    RegionComparator cmp(l.region,r.region);if(!cmp.compare())return reject("region_structure_mismatch");
    DenseMap<BasicBlock*,BasicBlock*>mapping;cmp.getMapping(mapping);std::set<BasicBlock*>values;
    for(auto&kv:mapping){if(!l.blocks.count(kv.first)||!r.blocks.count(kv.second))return reject("non_bijective_region_mapping");values.insert(kv.second);}
    if(mapping.size()!=l.blocks.size()||values.size()!=r.blocks.size()||l.blocks.size()!=r.blocks.size())return reject("non_bijective_region_mapping");
    for(const auto &blocks:mapping)
      memoryBlocks.emplace_back(blocks.first,blocks.second);
    if(!ma.selectExplicitRegions(l.region,r.region))return reject("region_structure_mismatch");
  }else{
    ma.selectExplicitBlocks(l.entry,r.entry);
    memoryBlocks.emplace_back(l.entry,r.entry);
  }
  // A direct diamond can retain unmatched accesses in guarded gaps. Verify
  // their original order and the emitted guard before accepting the rewrite.
  const bool directGuardedMemory = !l.region && matchedStorePair &&
      !regionStores.empty() && !siblingLoops;
  if (!regionStores.empty() && (siblingLoops || directGuardedMemory)) {
    for(const auto &blocks:memoryBlocks)
      for(auto *block:{blocks.first,blocks.second})
        for(auto &instruction:*block)
          if(instruction.mayReadOrWriteMemory() &&
             !regionStores.count(dyn_cast<StoreInst>(&instruction)) &&
             !(isa<LoadInst>(instruction)&&cast<LoadInst>(instruction).isSimple()))
            return reject("region_store_memory_sequence_mismatch");
  }else if(!regionStores.empty()){
    // Match the complete memory sequence in each corresponding block.
    // Loads and stores must remain in their original per-path order.
    for(const auto &blocks:memoryBlocks){
      SmallVector<Instruction*,8> leftMemory,rightMemory;
      for(auto &instruction:*blocks.first)
        if(instruction.mayReadOrWriteMemory())leftMemory.push_back(&instruction);
      for(auto &instruction:*blocks.second)
        if(instruction.mayReadOrWriteMemory())rightMemory.push_back(&instruction);
      if(leftMemory.size()!=rightMemory.size())
        return reject("region_store_memory_sequence_mismatch");
      std::vector<std::pair<Instruction*,Instruction*>> sequence;
      for(unsigned index=0;index<leftMemory.size();++index){
        auto *left=leftMemory[index],*right=rightMemory[index];
        if(!InstructionMatch::match(left,right))
          return reject("region_store_memory_sequence_mismatch");
        if(auto *store=dyn_cast<StoreInst>(left)){
          auto *other=cast<StoreInst>(right);
          if(!regionStores.count(store)||!regionStores.count(other))
            return reject("region_store_memory_sequence_mismatch");
          ++matchedStoreCount;
        }else if(!isa<LoadInst>(left)||!cast<LoadInst>(left)->isSimple()||
                 !cast<LoadInst>(right)->isSimple())
          return reject("region_store_memory_sequence_mismatch");
        sequence.emplace_back(left,right);
      }
      if(!sequence.empty())matchedMemory.push_back(std::move(sequence));
    }
    if(matchedStoreCount*2!=regionStores.size())
      return reject("region_store_memory_sequence_mismatch");
  }
  // Classify from path structure, not the B/R spelling of the matched IDs.
  // A block inside an optional arm is a B2R/R2B match even when both IDs are B.
  t.planKind=l.region?"R2R":"B2B";
  t.matchedLeft=name(l.entry);t.matchedRight=name(r.entry);
  auto context=[&](const Unit &u,BasicBlock *path)->Boundary {
    if(u.region||a.pdt.dominates(u.entry,path))return boundary(u,*f);
    Region *region=a.regions.getRegionFor(u.entry);
    while(region&&!region->isTopLevelRegion()&&!a.dt.dominates(region->getEntry(),path))region=region->getParent();
    if(!region||region->isTopLevelRegion())return boundary(u,*f);
    std::set<BasicBlock*> bs;for(auto *block:region->blocks())bs.insert(block);
    return boundary({region->getEntry(),region->getExit(),region,bs},*f);
  };
  t.leftContext=context(l,br->getSuccessor(0));t.rightContext=context(r,br->getSuccessor(1));
  if(!l.region){
    bool leftRequired=a.pdt.dominates(l.entry,br->getSuccessor(0));
    bool rightRequired=a.pdt.dominates(r.entry,br->getSuccessor(1));
    if(!rightRequired)t.planKind="B2R";
    else if(!leftRequired)t.planKind="R2B";
  }
  t.loopHeaderSplit=a.loops.isLoopHeader(split);
  // Structural mode picks an engine before mutation. Use the local engine only
  // for direct, closed pure B2B computations; all region/replication work goes
  // to RegionMelder. No failure-driven fallback or second clone is involved.
  bool useLocal=c.localCopysign;
  if(c.hybrid){
    if(logical)return reject("structural_mode_requires_general_cfg_enumeration");
    auto pure=[](BasicBlock *block){
      for(auto &i:*block){
        if(i.mayReadOrWriteMemory()||i.mayHaveSideEffects())return false;
        if(auto *call=dyn_cast<CallBase>(&i)){
          auto *callee=call->getCalledFunction();
          if(!callee||callee->getIntrinsicID()!=Intrinsic::copysign)return false;
        }
      }return true;
    };
    useLocal=t.planKind=="B2B"&&l.entry->getSingleSuccessor()==r.entry->getSingleSuccessor()
      &&l.entry->getSingleSuccessor()&&pure(l.entry)&&pure(r.entry);
    if(useLocal){
      // Pure does not imply a closed single-result computation (HLLC has
      // select roots and multiple live-outs). Dispatch those directly to
      // RegionMelder rather than rejecting them in the local engine.
      LocalComputation leftLocal,rightLocal;
      useLocal=describeLocalComputation(l.entry,leftLocal)&&describeLocalComputation(r.entry,rightLocal)
        &&leftLocal.root->isSameOperationAs(rightLocal.root)
        &&leftLocal.root->getRawSubclassOptionalData()==rightLocal.root->getRawSubclassOptionalData();
      // The local engine is if-conversion: both operand trees run on every
      // lane and only the root is shared. With a budget, hand heavy trees to
      // RegionMelder, which guards unmatched instructions instead.
      if(useLocal&&guardsUnsafeWork)useLocal=false;
      if(useLocal&&c.speculation==SpeculationMode::Budget){
        auto weight=[](BasicBlock *b){unsigned w=0;for(auto &i:*b)if(!i.isTerminator()&&!isa<PHINode>(i))w+=speculationWeight(i);return w;};
        unsigned extra=std::max(weight(l.entry),weight(r.entry))-speculationWeight(*leftLocal.root);
        if(extra>unsigned(c.speculationBudget))useLocal=false;
      }
    }
  }
  AdjacentLeafEntry leafEntry;
  bool directLeaves=!downstreamWrite&&regionStores.empty()&&c.hybrid&&!useLocal&&bool(l.region)==bool(r.region)&&l.exit&&l.exit==r.exit&&leafEntry.prepare(l.entry,r.entry,a.dt,a.loops,bool(l.region),c.speculation,c.speculationBudget);
  t.mergePath=directLeaves?(l.region?"darm-adjacent-R2R":"darm-adjacent-B2B"):useLocal?"local-compute":"darm-"+t.planKind;
  if(!directLeaves&&!useLocal&&!c.crossLevelB2R&&(t.planKind=="B2R"||t.planKind=="R2B")){
    auto *d=decisionDiscriminator(split);
    if(optionalBehindSameDecision(r.entry,br->getSuccessor(1),d,a)||optionalBehindSameDecision(l.entry,br->getSuccessor(0),d,a))
      return reject("b2r_replicates_same_decision_chain_requires_opt_in");
  }
  t.originalSimilarity=ma.explicitSimilarity();t.originalProfitable=ma.isRegionMatchProfitable(0);
  auto ft=Clock::now();t.before=features(*f);t.featuresMs+=millis(ft);t.replication=ma.requireRegionReplication();
  if(t.replication&&downstreamWrite)return reject("downstream_write_replication_not_supported");
  if(t.replication&&preservedLoop)return reject("loop_entry_replication_not_supported");
  if(t.replication&&!regionStores.empty())
    return reject("region_store_replication_not_supported");
  if(t.replication&&!l.region){
    // Only the expanded block needs one successor. The matched block inside
    // the opposite region may branch; RegionReplicator copies that topology.
    auto *expanded=a.pdt.dominates(l.entry,br->getSuccessor(0))?l.entry:r.entry;
    if(!expanded->getUniqueSuccessor())return reject("replication_requires_unique_successor");
  }
  std::map<std::string,std::string> others;for(auto&g:*t.raw)if(&g!=f)others[g.getName().str()]=text(g);
  bool scoped=mode==CleanupMode::ScopedLocal||mode==CleanupMode::ScopedCFG||mode==CleanupMode::ScopedCFGTriangles;
  auto localBefore=scoped?snapshotLocal(*f):std::vector<LocalSnapshot>{};
  std::vector<WeakVH> priorBlocks; if(mode==CleanupMode::ScopedCFG||mode==CleanupMode::ScopedCFGTriangles)for(auto &b:*f)priorBlocks.emplace_back(&b);
  auto mt=Clock::now();
  WeakVH originalSplit(split), originalJoin(join);
  WeakVH originalCondition(br->getCondition());
  std::unique_ptr<Analysis> leafAnalysis;
  std::unique_ptr<RegionAnalyzer> leafAnalyzer;
  std::unique_ptr<Region> leftLogicalRegion,rightLogicalRegion;
  t.rewriteStarted=true;
  if(directLeaves){
    auto *gate=leafEntry.apply();
    BasicBlock *leftExit=l.exit,*rightExit=r.exit;
    if(l.region){
      auto separateExit=[&](const std::set<BasicBlock*> &blocks,const char *suffix){
        SmallVector<BasicBlock*,16> preds;
        for(auto *pred:predecessors(l.exit))if(blocks.count(pred))preds.push_back(pred);
        return SplitBlockPredecessors(l.exit,preds,suffix);
      };
      bool sameOrder=leafEntry.left==l.entry;
      leftExit=separateExit(sameOrder?l.blocks:r.blocks,".leaf.left.exit");
      rightExit=separateExit(sameOrder?r.blocks:l.blocks,".leaf.right.exit");
    }
    leafAnalysis=std::make_unique<Analysis>(*f);
    leafAnalyzer=std::make_unique<RegionAnalyzer>(gate,leafAnalysis->dt,leafAnalysis->pdt);
    if(l.region){
      leftLogicalRegion=std::make_unique<Region>(leafEntry.left,leftExit,&leafAnalysis->regions,&leafAnalysis->dt,leafAnalysis->regions.getTopLevelRegion());
      rightLogicalRegion=std::make_unique<Region>(leafEntry.right,rightExit,&leafAnalysis->regions,&leafAnalysis->dt,leafAnalysis->regions.getTopLevelRegion());
      if(!leafAnalyzer->selectExplicitRegions(leftLogicalRegion.get(),rightLogicalRegion.get()))return reject("adjacent_region_reconstruction_failed");
    }else leafAnalyzer->selectExplicitBlocks(leafEntry.left,leafEntry.right);
    t.planKind=l.region?"R2R":"B2B";t.replication=false;
    t.leftContext=t.left;t.rightContext=t.right;
  }
  std::unique_ptr<decision::SpeculationTTI> speculationTTI;
  if(c.speculation==SpeculationMode::Cost){
    try {
      speculationTTI=std::make_unique<decision::SpeculationTTI>(*f);
    } catch(const std::runtime_error &) {
      // With no target cost, the gap planner keeps conditional execution.
    }
  }
  const bool sharedAnchor = t.replication && guardedReplication &&
      !replicatedMemory.empty() && c.splitMatches.empty() && !c.explicitGapPlan &&
      shareReplicatedAnchor(split, leftRequired ? l.entry : r.entry,
                           leftRequired ? r.entry : l.entry, join, a.dt);
  if (sharedAnchor) {
    t.mergePath = "shared-anchor-" + t.planKind;
    t.replication = false;
  }
  RegionMelder melder(directLeaves?*leafAnalyzer:ma,!sharedAnchor);melder.CoalesceGaps=c.coalesceGaps;melder.SpeculationMode=int(c.speculation);melder.SpeculationBudget=c.speculationBudget;melder.SpeculationTTI=speculationTTI?speculationTTI->info.get():nullptr;if(t.logicalState)melder.onValueMapping=[&](const ValueToValueMapTy &m){t.logicalState->transfer(m);};if(useLocal){
    if(l.region||r.region)return reject("local_requires_basic_blocks");
    std::string why;
    if(!fuseLocalComputations(l.entry,r.entry,melder.onValueMapping,why,c.localUnion||c.hybrid)){t.reason=why;t.totalMs=millis(started);return t;}
    t.replication=false;
  }else if (!sharedAnchor) {
    if (!replicatedMemory.empty()) {
      melder.GuardReplicatedMemory = true;
      melder.onValueMapping = [&](const ValueToValueMapTy &mapping) {
        SmallPtrSet<Instruction *, 16> emitted;
        for (const auto &block : replicatedMemory) {
          Instruction *previous = nullptr;
          for (auto *original : block.second) {
            auto *memory = dyn_cast_or_null<Instruction>((Value *)mapping.lookup(original));
            if (!memory || memory->getOpcode() != original->getOpcode() ||
                !emitted.insert(memory).second ||
                !melder.hasGuardedGap(memory, !leftRequired))
              throw std::runtime_error("replicated_memory_not_guarded");
            if (previous && (previous->getParent() != memory->getParent() ||
                             !previous->comesBefore(memory)))
              throw std::runtime_error("replicated_memory_order_changed");
            previous = memory;
          }
        }
      };
    } else if(!regionStores.empty() && (siblingLoops || directGuardedMemory)){
      melder.onValueMapping=[&](const ValueToValueMapTy &mapping){
        for(const auto &blocks:memoryBlocks){
          std::set<Instruction*> emitted[2];
          for(unsigned side=0;side<2;++side){
            Instruction *previous=nullptr;
            for(auto &original:*(side==0?blocks.first:blocks.second)){
              if(!original.mayReadOrWriteMemory())continue;
              auto *memory=dyn_cast_or_null<Instruction>((Value*)mapping.lookup(&original));
              if(!memory||memory->getOpcode()!=original.getOpcode()||
                 !emitted[side].insert(memory).second)
                throw std::runtime_error("guarded_memory_mapping_invalid");
              if(previous&&(previous->getParent()!=memory->getParent()||
                            !previous->comesBefore(memory)))
                throw std::runtime_error("region_memory_meld_order_changed");
              previous=memory;
            }
          }
          for(unsigned side=0;side<2;++side)
            for(auto *memory:emitted[side])
              if(!emitted[1-side].count(memory)&&!melder.hasGuardedGap(memory,side==0))
                throw std::runtime_error("unmatched_memory_not_guarded");
        }
      };
    }else if(!matchedMemory.empty()){
      melder.onValueMapping=[&](const ValueToValueMapTy &mapping){
        std::set<Instruction*> emitted;
        for(const auto &sequence:matchedMemory){
          Instruction *previous=nullptr;
          for(const auto &pair:sequence){
            Value *left=mapping.lookup(pair.first);
            Value *right=mapping.lookup(pair.second);
            auto *memory=dyn_cast_or_null<Instruction>(left);
            if(!memory||left!=right||memory->getOpcode()!=pair.first->getOpcode()||
               !emitted.insert(memory).second)
              throw std::runtime_error("region_memory_not_melded_in_pairs");
            if(previous&&(previous->getParent()!=memory->getParent()||
                          !previous->comesBefore(memory)))
              throw std::runtime_error("region_memory_meld_order_changed");
            previous=memory;
          }
        }
      };
    }
    melder.NativeReplicationPredication = legacyReplication && t.replication;
    melder.SplitMatchIDs=c.splitMatches;
    melder.SpeculateGapIDs=c.speculateGaps;
    melder.ExplicitGapPlan=c.explicitGapPlan;
    try { melder.merge(0); }
    catch(const std::exception &error) { return reject(error.what()); }
  }
  t.alignmentChoices=std::move(melder.AlignmentChoices);
  t.gapChoices=std::move(melder.GapChoices);
  t.coalescedGapGroups=melder.CoalescedGapGroups;canonicalPhiOrder(*t.raw,c.function);t.mergeMs=millis(mt);
  if(downstreamWrite){
    auto *start=dyn_cast_or_null<BasicBlock>((Value*)originalSplit);
    auto *end=dyn_cast_or_null<BasicBlock>((Value*)originalJoin);
    if(!start||!end)return reject("downstream_boundary_lost");
    DenseMap<Instruction*,unsigned> accessIds;
    for(unsigned i=0;i<downstream.size();++i){
      const auto &saved=downstream[i];
      auto *inst=dyn_cast_or_null<Instruction>((Value*)saved.instruction);
      if(!inst||inst->getParent()!=saved.block||inst->getNumOperands()!=saved.operands.size())
        return reject("downstream_access_changed");
      for(unsigned op=0;op<saved.operands.size();++op)
        if(inst->getOperand(op)!=(Value*)saved.operands[op])
          return reject("downstream_access_operand_changed");
      accessIds[inst]=i;
    }
    for(const auto &path:paths){
      DenseMap<Value*,bool> conditions;
      for(const auto &entry:path.conditions){
        Value *condition=entry.first;
        if(!condition||(conditions.count(condition)&&conditions.lookup(condition)!=entry.second))
          return reject("downstream_condition_changed");
        conditions[condition]=entry.second;
      }
      BasicBlock *block=start,*pred=nullptr;
      std::vector<unsigned> accesses;
      for(unsigned depth=0;block!=end&&depth<128;++depth){
        for(auto &inst:*block){
          if(auto *phi=dyn_cast<PHINode>(&inst)){
            if(pred&&phi->getBasicBlockIndex(pred)>=0){
              auto *value=phi->getIncomingValueForBlock(pred);
              if(auto *constant=dyn_cast<ConstantInt>(value))conditions[phi]=constant->isOne();
              else if(conditions.count(value))conditions[phi]=conditions.lookup(value);
            }
          }
          auto access=accessIds.find(&inst);
          if(access!=accessIds.end())accesses.push_back(access->second);
          else if (!inst.isTerminator() &&
                   (inst.mayHaveSideEffects() || inst.mayWriteToMemory())) {
            raw_string_ostream detail(t.localRejectReason);
            block->printAsOperand(detail, false);
            detail << ": ";
            inst.print(detail);
            detail.flush();
            return reject("unexpected_downstream_effect");
          }
        }
        auto *branch=dyn_cast<BranchInst>(block->getTerminator());
        if(!branch)return reject("downstream_branch_changed");
        unsigned edge=0;
        if(branch->isConditional()){
          auto *condition=branch->getCondition();
          if(auto *constant=dyn_cast<ConstantInt>(condition))edge=!constant->isOne();
          else if(conditions.count(condition))edge=!conditions.lookup(condition);
          else return reject("downstream_condition_unresolved");
        }
        pred=block;
        block=branch->getSuccessor(edge);
      }
      if(block!=end||accesses!=path.accesses)return reject("downstream_access_path_changed");
    }
  }
  if(!protectedWrites.empty()) {
    auto *savedSplit=dyn_cast_or_null<BasicBlock>((Value*)originalSplit);
    auto *savedJoin=dyn_cast_or_null<BasicBlock>((Value*)originalJoin);
    if(!savedSplit || !savedJoin) return reject("protected_write_boundary_lost");
    auto *guard=dyn_cast<BranchInst>(savedSplit->getTerminator());
    if(!guard || !guard->isConditional() || guard->getCondition()!=(Value*)originalCondition)
      return reject("protected_write_guard_lost");
    auto leftAfter=reachable(guard->getSuccessor(0),savedJoin);
    auto rightAfter=reachable(guard->getSuccessor(1),savedJoin);
    for(const auto &write:protectedWrites) {
      if(leftAfter.count(write.block)!=unsigned(write.leftSide) ||
         rightAfter.count(write.block)==unsigned(write.leftSide))
        return reject("protected_write_guard_changed");
    }
  }
  for(const auto &write:protectedWrites) {
    auto *store=dyn_cast_or_null<StoreInst>((Value*)write.instruction);
    if(!store || store->getParent()!=write.block ||
       store->getValueOperand()!=write.value || store->getPointerOperand()!=write.address)
      return reject("protected_write_changed");
  }
  if(verifyModule(*t.raw,&errs()))return reject("raw_verifier_failed");
  for(auto&g:*t.raw)if(&g!=f)if(!others.count(g.getName().str())||others.at(g.getName().str())!=text(g))return reject("other_function_changed");
  ft=Clock::now();t.afterRaw=features(*f);t.featuresMs+=millis(ft);if(t.afterRaw.loops>t.before.loops)return reject("new_raw_loop");
  auto blockLabel=[](const Value *V){std::string S;raw_string_ostream O(S);V->printAsOperand(O,false);O.flush();return S;};
  auto rawLocalScope=scoped?changedLocal(*f,localBefore):std::set<Instruction*>{};
  std::set<BasicBlock*> oldBlocks,rawCreated;
  if(mode==CleanupMode::ScopedCFG||mode==CleanupMode::ScopedCFGTriangles){for(auto &h:priorBlocks)if(auto *b=dyn_cast_or_null<BasicBlock>((Value*)h))oldBlocks.insert(b);for(auto &b:*f)if(!oldBlocks.count(&b))rawCreated.insert(&b);}
  ValueToValueMapTy CloneMap;
  auto nt=Clock::now();t.normalized=CloneModule(*t.raw,CloneMap);
  if(t.logicalState)t.logicalState=t.logicalState->clone(CloneMap);
  std::vector<WeakVH> CleanedBlocks;
  for(auto &Origin:melder.blockOrigins()) {
    BlockProvenance P;P.leftID=Origin.leftID;P.rightID=Origin.rightID;
    P.leftLabel=Origin.leftLabel;P.rightLabel=Origin.rightLabel;
    Value *Raw=Origin.merged;Value *Cleaned=nullptr;
    if(Raw){P.rawBlock=blockLabel(Raw);auto It=CloneMap.find(Raw);if(It!=CloneMap.end())Cleaned=It->second;}
    t.blockProvenance.push_back(std::move(P));CleanedBlocks.push_back(WeakVH(Cleaned));
  }
  std::set<Instruction*> cleanLocalScope;
  for(auto*i:rawLocalScope)if(auto *mapped=dyn_cast_or_null<Instruction>(CloneMap.lookup(i)))cleanLocalScope.insert(mapped);
  std::set<BasicBlock*> cleanCreated;
  for(auto *b:rawCreated)if(auto *mapped=dyn_cast_or_null<BasicBlock>(CloneMap.lookup(b)))cleanCreated.insert(mapped);
  // Do not retain CloneMap's tracking handles while cleanup mutates the clone.
  CloneMap.clear();
  t.cleanupIterations=(mode==CleanupMode::ScopedCFG||mode==CleanupMode::ScopedCFGTriangles)?cleanupProductionScopedCFG(*t.normalized->getFunction(c.function),cleanLocalScope,cleanCreated,mode==CleanupMode::ScopedCFGTriangles):mode==CleanupMode::ScopedLocal?cleanupScoped(*t.normalized->getFunction(c.function),cleanLocalScope):cleanup(*t.normalized,c.function,level,mode);canonicalPhiOrder(*t.normalized,c.function);t.normalizeMs=millis(nt);
  for(size_t I=0;I<CleanedBlocks.size();++I)if(Value *V=CleanedBlocks[I])
    t.blockProvenance[I].cleanedBlock=blockLabel(V);
  if(verifyModule(*t.normalized,&errs()))return reject("normalized_verifier_failed");
  auto*after=t.normalized->getFunction(c.function);if(!after||after->isDeclaration())return reject("target_lost_after_normalization");
  ft=Clock::now();t.after=features(*after);t.featuresMs+=millis(ft);if(t.after.loops>t.before.loops)return reject("new_normalized_loop");
  if(t.logicalState){if(!t.logicalState->stageMerge(c))return reject("logical_state_candidate_mismatch");t.logicalState->rebind(*after);}
  finishSides(after);
  t.valid=true;t.reason="verified_ir_only";t.totalMs=millis(started);return t;
}
// A direct diamond can share arithmetic before the original split or after
// both arms. Keeping the arm blocks intact preserves their execution domains
// and the order of all memory accesses.
using B2BMatch = std::pair<Instruction *, Instruction *>;

static bool compatibleB2BArithmetic(Instruction &left, Instruction &right) {
  return isa<BinaryOperator>(left) && left.isSameOperationAs(&right) &&
      left.getRawSubclassOptionalData() == right.getRawSubclassOptionalData() &&
      !left.hasMetadataOtherThanDebugLoc() && !right.hasMetadataOtherThanDebugLoc() &&
      safeToSpeculate(left) && safeToSpeculate(right);
}

// Align independently hoistable computations. Skipping an instruction
// leaves it in its original arm, including all memory accesses.
static SmallVector<B2BMatch, 8> alignHoistableB2B(
    BasicBlock &left, BasicBlock &right, BranchInst &split, DominatorTree &dt) {
  auto collect = [&](BasicBlock &arm) {
    SmallVector<Instruction *, 16> result;
    for (auto &inst : arm) {
      if (!isa<BinaryOperator>(inst) || inst.use_empty() ||
          inst.hasMetadataOtherThanDebugLoc() || !safeToSpeculate(inst))
        continue;
      if (llvm::all_of(inst.operands(), [&](const Use &operand) {
            auto *def = dyn_cast<Instruction>(operand.get());
            return !def || dt.dominates(def, &split);
          }))
        result.push_back(&inst);
    }
    return result;
  };
  const auto l = collect(left), r = collect(right);
  constexpr size_t maxCells = 16384;
  const size_t columns = r.size() + 1;
  if (l.empty() || r.empty() || l.size() + 1 > maxCells / columns)
    return {};
  std::vector<unsigned> scores((l.size() + 1) * columns);
  auto at = [&](size_t i, size_t j) -> unsigned & {
    return scores[i * columns + j];
  };
  auto match = [&](size_t i, size_t j) {
    return r[j]->isIdenticalTo(l[i]);
  };
  for (size_t i = l.size(); i-- > 0;)
    for (size_t j = r.size(); j-- > 0;)
      at(i, j) = match(i, j) ? 1 + at(i + 1, j + 1)
                             : std::max(at(i + 1, j), at(i, j + 1));

  SmallVector<B2BMatch, 8> result;
  for (size_t i = 0, j = 0; i < l.size() && j < r.size();) {
    if (match(i, j)) {
      result.emplace_back(l[i++], r[j++]);
    } else if (at(i + 1, j) >= at(i, j + 1)) {
      ++i;
    } else {
      ++j;
    }
  }
  return result;
}

static SmallVector<B2BMatch, 8> commonB2BPrefix(BasicBlock &left, BasicBlock &right,
                                                BranchInst &split, DominatorTree &dt) {
  SmallVector<B2BMatch, 8> result;
  DenseMap<Value *, Value *> earlier;
  auto l = left.begin(), r = right.begin();
  while (compatibleB2BArithmetic(*l, *r)) {
    bool available = true;
    for (unsigned n = 0; n < l->getNumOperands(); ++n) {
      auto *lv = l->getOperand(n), *rv = r->getOperand(n);
      if (earlier.lookup(lv) == rv) continue;
      for (auto *value : {lv, rv})
        if (auto *def = dyn_cast<Instruction>(value))
          available &= dt.dominates(def, &split);
    }
    if (!available) break;
    result.emplace_back(&*l, &*r);
    earlier[&*l] = &*r;
    ++l;
    ++r;
  }
  return result;
}

static SmallVector<B2BMatch, 8> commonB2BSuffix(BasicBlock &left, BasicBlock &right,
                                                BasicBlock &join) {
  SmallVector<B2BMatch, 8> result;
  DenseMap<Value *, Value *> later;
  auto l = left.rbegin(), r = right.rbegin();
  while (++l != left.rend() && ++r != right.rend() &&
         compatibleB2BArithmetic(*l, *r)) {
    bool usable = true;
    for (auto *inst : {&*l, &*r})
      for (const auto &use : inst->uses()) {
        if (later.count(use.getUser())) continue;
        auto *phi = dyn_cast<PHINode>(use.getUser());
        usable &= phi && phi->getParent() == &join &&
            phi->getIncomingBlock(use) == inst->getParent();
      }
    // A suffix value has no definition on an incoming edge of the new merge.
    // Every such use must resolve to the same shared value on both sides.
    for (const auto &match : result)
      for (unsigned n = 0; n < match.first->getNumOperands(); ++n)
        usable &= (match.first->getOperand(n) == &*l) ==
                  (match.second->getOperand(n) == &*r);
    for (auto &phi : join.phis())
      usable &= (phi.getIncomingValueForBlock(&left) == &*l) ==
                (phi.getIncomingValueForBlock(&right) == &*r);
    if (!usable) break;
    result.emplace_back(&*l, &*r);
    later[&*l] = &*r;
    later[&*r] = &*l;
  }
  std::reverse(result.begin(), result.end());
  return result;
}

std::vector<Trial> planSingleBranchB2B(const Module &parent, const Candidate &c,
                                       unsigned level, CleanupMode mode,
                                       StringRef replay) {
  std::vector<Trial> trials;
  if (!c.hybrid || c.speculation != SpeculationMode::Cost || c.localCopysign ||
      c.explicitGapPlan || !c.splitMatches.empty() || c.coalesceGaps ||
      mode != CleanupMode::DarmCFGRedundancy)
    return trials;

  // Reject other candidate shapes before cloning or building analyses.
  unsigned splitIndex, leftIndex, rightIndex;
  if (!StringRef(c.split).startswith("B") ||
      !StringRef(c.left).startswith("B") || !StringRef(c.right).startswith("B"))
    return trials;
  if (StringRef(c.split).drop_front().getAsInteger(10, splitIndex) ||
      StringRef(c.left).drop_front().getAsInteger(10, leftIndex) ||
      StringRef(c.right).drop_front().getAsInteger(10, rightIndex) ||
      splitIndex == leftIndex || splitIndex == rightIndex || leftIndex == rightIndex)
    return trials;

  const auto *source = parent.getFunction(c.function);
  if (!source) return trials;
  const BasicBlock *blocks[3] = {};
  unsigned index = 0;
  for (const auto &bb : *source) {
    if (index == splitIndex) blocks[0] = &bb;
    if (index == leftIndex) blocks[1] = &bb;
    if (index == rightIndex) blocks[2] = &bb;
    ++index;
  }
  if (!blocks[0] || !blocks[1] || !blocks[2]) return trials;
  const auto *originalBranch = dyn_cast<BranchInst>(blocks[0]->getTerminator());
  if (!originalBranch || !originalBranch->isConditional()) return trials;
  const bool swapped = originalBranch->getSuccessor(0) == blocks[2];
  if (swapped) std::swap(blocks[1], blocks[2]);
  if (originalBranch->getSuccessor(0) != blocks[1] ||
      originalBranch->getSuccessor(1) != blocks[2])
    return trials;
  const auto *originalJoin = blocks[1]->getSingleSuccessor();
  if (!originalJoin || originalJoin == blocks[0] || originalJoin == blocks[1] ||
      originalJoin == blocks[2] || blocks[2]->getSingleSuccessor() != originalJoin)
    return trials;

  Trial trial;
  trial.candidate = c;
  trial.cleanupMode = mode;
  ValueToValueMapTy inputMap;
  trial.raw = CloneModule(parent, inputMap);
  auto *f = trial.raw->getFunction(c.function);
  if (verifyModule(*trial.raw, &errs())) return trials;
  auto *split = cast<BasicBlock>(inputMap[blocks[0]]);
  auto *left = cast<BasicBlock>(inputMap[blocks[1]]);
  auto *right = cast<BasicBlock>(inputMap[blocks[2]]);
  auto *join = cast<BasicBlock>(inputMap[originalJoin]);
  auto *branch = cast<BranchInst>(split->getTerminator());
  inputMap.clear();
  trial.swapped = swapped;
  DominatorTree dt(*f);
  if (dt.dominates(join, split)) return trials;
  LoopInfo loops(dt);
  for (auto *arm : {left, right}) {
    auto *exit = dyn_cast<BranchInst>(arm->getTerminator());
    if (!exit || !exit->isUnconditional() || arm->getSinglePredecessor() != split ||
        arm->hasAddressTaken() || !arm->phis().empty() ||
        loops.getLoopFor(arm) != loops.getLoopFor(split))
      return trials;
    for (auto &inst : *arm) {
      if (inst.isTerminator()) continue;
      if (auto *load = dyn_cast<LoadInst>(&inst)) {
        if (!load->isSimple()) return trials;
      } else if (auto *store = dyn_cast<StoreInst>(&inst)) {
        if (!store->isSimple()) return trials;
      } else if (inst.mayHaveSideEffects() || inst.mayReadOrWriteMemory() ||
                 isa<CallBase>(inst) || isa<AllocaInst>(inst) ||
                 inst.getType()->isTokenTy()) {
        return trials;
      }
    }
  }
  auto prefix = commonB2BPrefix(*left, *right, *branch, dt);
  auto suffix = commonB2BSuffix(*left, *right, *join);
  auto aligned = alignHoistableB2B(*left, *right, *branch, dt);
  if (aligned == prefix) aligned.clear();

  trial.before = features(*f);
  trial.left = trial.leftContext = boundary({left, join, nullptr, {left}}, *f);
  trial.right = trial.rightContext = boundary({right, join, nullptr, {right}}, *f);
  trial.matchedLeft = name(left);
  trial.matchedRight = name(right);
  trial.planKind = "B2B";
  trial.loopHeaderSplit = loops.isLoopHeader(split);
  const bool tagged = tagSideCondition(*f, branch->getCondition());
  if (tagged)
    trial.sideBeforeOk = sideBlocksBoth(*f, branch->getCondition(), trial.sideBefore, trial.sideReason);

  // The no-sharing layout is the unchanged diamond. Only emit it when there
  // is no sharing opportunity, so it consumes no competing plan slot.
  for (unsigned layout : {1u, 2u, 3u, 4u, 0u}) {
    const bool usePrefix = layout & 1;
    const bool useSuffix = layout & 2;
    if ((usePrefix && prefix.empty()) || (useSuffix && suffix.empty()) ||
        (layout == 4 && aligned.empty()) ||
        (!layout && (!prefix.empty() || !suffix.empty() || !aligned.empty())))
      continue;
    if (layout == 3 &&
        prefix.size() + suffix.size() > std::min(left->size(), right->size()) - 1)
      continue;
    StringRef label = layout == 3 ? "single-branch-prefix-suffix" :
                      usePrefix ? "single-branch-prefix" :
                      useSuffix ? "single-branch-suffix" :
                      layout == 4 ? "single-branch-aligned-hoist" : "single-branch-separate";
    if (!replay.empty() && replay != label) continue;

    Trial t;
    t.candidate = c;
    t.cleanupMode = mode;
    t.before = trial.before;
    t.left = t.leftContext = trial.left;
    t.right = t.rightContext = trial.right;
    t.matchedLeft = trial.matchedLeft;
    t.matchedRight = trial.matchedRight;
    t.planKind = trial.planKind;
    t.mergePath = label.str();
    t.swapped = trial.swapped;
    t.loopHeaderSplit = trial.loopHeaderSplit;
    t.sideBeforeOk = trial.sideBeforeOk;
    t.sideReason = trial.sideReason;
    for (unsigned side = 0; side < 2; ++side) t.sideBefore[side] = trial.sideBefore[side];
    ValueToValueMapTy clone;
    t.raw = CloneModule(*trial.raw, clone);
    auto *raw = t.raw->getFunction(c.function);
    auto *rawBranch = cast<BranchInst>(clone[branch]);
    auto *rawLeft = cast<BasicBlock>(clone[left]);
    auto *rawRight = cast<BasicBlock>(clone[right]);
    auto *rawJoin = cast<BasicBlock>(clone[join]);
    t.rewriteStarted = layout != 0;

    if (usePrefix || layout == 4) {
      IRBuilder<> builder(rawBranch);
      std::map<std::pair<Value *, Value *>, Value *> selects;
      for (auto [l, r] : (usePrefix ? prefix : aligned)) {
        auto *lc = cast<Instruction>(clone[l]), *rc = cast<Instruction>(clone[r]);
        auto *shared = lc->clone();
        for (unsigned n = 0; n < shared->getNumOperands(); ++n) {
          auto *lv = lc->getOperand(n), *rv = rc->getOperand(n);
          if (lv != rv) {
            auto &choice = selects[{lv, rv}];
            if (!choice) choice = builder.CreateSelect(rawBranch->getCondition(), lv, rv);
            shared->setOperand(n, choice);
          }
        }
        builder.Insert(shared);
        lc->replaceAllUsesWith(shared);
        rc->replaceAllUsesWith(shared);
        lc->eraseFromParent();
        rc->eraseFromParent();
      }
    }

    if (useSuffix) {
      auto *merge = BasicBlock::Create(raw->getContext(), "fusion.suffix", raw, rawJoin);
      auto *exit = BranchInst::Create(rawJoin, merge);
      std::map<std::pair<Value *, Value *>, Value *> choices;
      auto mergeValue = [&](Value *lv, Value *rv) -> Value * {
        if (lv == rv) return lv;
        auto &value = choices[{lv, rv}];
        if (!value) {
          auto *phi = PHINode::Create(lv->getType(), 2, "", &merge->front());
          phi->addIncoming(lv, rawLeft);
          phi->addIncoming(rv, rawRight);
          value = phi;
        }
        return value;
      };
      for (auto [l, r] : suffix) {
        auto *lc = cast<Instruction>(clone[l]), *rc = cast<Instruction>(clone[r]);
        auto *shared = lc->clone();
        for (unsigned n = 0; n < shared->getNumOperands(); ++n)
          shared->setOperand(n, mergeValue(lc->getOperand(n), rc->getOperand(n)));
        shared->insertBefore(exit);
        lc->replaceAllUsesWith(shared);
        rc->replaceAllUsesWith(shared);
        lc->eraseFromParent();
        rc->eraseFromParent();
      }
      for (auto &phi : rawJoin->phis()) {
        auto *value = mergeValue(phi.getIncomingValueForBlock(rawLeft),
                                 phi.getIncomingValueForBlock(rawRight));
        phi.removeIncomingValue(rawLeft, false);
        phi.removeIncomingValue(rawRight, false);
        phi.addIncoming(value, merge);
      }
      rawLeft->getTerminator()->setSuccessor(0, merge);
      rawRight->getTerminator()->setSuccessor(0, merge);
    }
    clone.clear();
    if (verifyModule(*t.raw, &errs())) {
      t.reason = "raw_verifier_failed";
      trials.push_back(std::move(t));
      continue;
    }
    t.afterRaw = features(*raw);
    t.normalized = CloneModule(*t.raw);
    t.cleanupIterations = cleanup(*t.normalized, c.function, level, mode);
    auto *after = t.normalized->getFunction(c.function);
    if (!verifyModule(*t.normalized, &errs())) {
      t.after = features(*after);
      if (auto *cond = findSideCondition(*after, t.sideReason))
        t.sideAfterOk = sideBlocksBoth(*after, cond, t.sideAfter, t.sideReason);
      t.valid = t.after.loops <= t.before.loops;
    }
    stripSideTag(t.raw.get());
    stripSideTag(t.normalized.get());
    t.reason = t.valid ? "verified_ir_only" : "single_branch_cleanup_failed";
    trials.push_back(std::move(t));
  }
  return trials;
}

RoundContext makeRound(const Module&parent,const std::string&function,unsigned version,unsigned level,CleanupMode mode) {
  RoundContext r;r.cleanupMode=mode;r.parentVersion=version;r.function=function;r.parentHash=moduleHash(parent);
  r.targetTriple=parent.getTargetTriple();r.dataLayout=parent.getDataLayoutStr();r.llvmVersion=LLVM_VERSION_STRING;
  r.cleanup=mode==CleanupMode::O3?"legacy-PassManagerBuilder-O"+std::to_string(level)+"-loopvec1-slpvec1":"darm-simplifycfg-fixedpoint-condbranch0-sink0-hoist0-targettti";
  r.cleanup+=";phi-edge-function-order-v1";
  if(mode==CleanupMode::StructuralCFG)r.cleanup+=";dominating-edge-boolean-guard-fold-v1";
  if(mode==CleanupMode::DarmCFGRedundancy)r.cleanup+="-earlycse-memoryssa0-dce";
  if(mode==CleanupMode::DarmCFGEarlyCSE)r.cleanup+="-earlycse-memoryssa0";
  if(mode==CleanupMode::PostOptFixedPoint)r.cleanup="phi-edge-function-order-v1;earlycse-memoryssa0-instcombine-simplifycfg-default-dce-earlycse-pure-scalar-phi-triangle-v1-fixedpoint-sha1-cap32";
  if(mode==CleanupMode::ScopedLocal)r.cleanup="changed-instructions-only;simplify-local-cse-dce;no-cfg-motion;protected-outside-audit;control-noop";
  if(mode==CleanupMode::ScopedCFG||mode==CleanupMode::ScopedCFGTriangles)r.cleanup="trial-created-blocks-only;empty-block-bypass-empty-diamond-proven-branch;boundary-terminators-and-phis;outside-audit;control-no-created-blocks-noop";
  if(mode==CleanupMode::ScopedCFGTriangles)r.cleanup+=";short-safe-integer-triangle-max5";
  if(mode==CleanupMode::None)r.cleanup="none;no_external_cleanup";
  if(mode==CleanupMode::DarmCFGScalarFixedPoint)r.cleanup+="-earlycse-instcombine-fixedpoint-sha1-cap32";
  auto*f=parent.getFunction(function);if(!f||f->isDeclaration())throw std::runtime_error("round function missing");
  r.targetAttributes=attributes(f->getAttributes(),f->arg_size());
  auto start=Clock::now();r.parentFeatures=features(*f);r.control=CloneModule(parent);r.controlCleanupIterations=cleanup(*r.control,function,level,mode);
  canonicalPhiOrder(*r.control,function);
  if(verifyModule(*r.control,&errs()))throw std::runtime_error("control verifier failed");
  auto*control=r.control->getFunction(function);if(!control||control->isDeclaration())throw std::runtime_error("control function missing");
  r.controlFeatures=features(*control);r.normalizationScale=std::max(double(r.controlFeatures.cost),1.0);
  r.controlHash=moduleHash(*r.control);r.controlMs=millis(start);return r;
}
ScoreResult StaticCostScorer::evaluate(const ScoreInput&i,const RoundContext&r)const {
  ScoreResult s;
  if(i.candidate.version!=r.parentVersion||i.candidate.function!=r.function){s.reason="round_identity_mismatch";return s;}
  std::set<OperationKey> keys;for(auto&kv:r.controlFeatures.operations)keys.insert(kv.first);for(auto&kv:i.after.operations)keys.insert(kv.first);
  int64_t contributionSum=0,controlCost=0,afterCost=0;
  for(auto&k:keys){auto b=r.controlFeatures.operations.find(k),a=i.after.operations.find(k);
    int64_t bn=b==r.controlFeatures.operations.end()?0:b->second,an=a==i.after.operations.end()?0:a->second;
    int64_t gain=(bn-an)*k.legacyWeight;controlCost+=bn*k.legacyWeight;afterCost+=an*k.legacyWeight;contributionSum+=gain;
    s.contributions.push_back({k,bn,an,gain});
  }
  if(controlCost!=r.controlFeatures.cost||afterCost!=i.after.cost||contributionSum!=controlCost-afterCost){s.reason="classified_cost_mismatch";s.coverage.legacyCountsComplete=false;return s;}
  s.staticGain=contributionSum;s.cleanupGain=r.parentFeatures.cost-controlCost;s.parentGain=r.parentFeatures.cost-afterCost;
  s.staticScore=s.staticGain/r.normalizationScale;s.total=s.staticScore;
  s.coverage.legacyCountsComplete=true;s.status=ScoreStatus::Scored;s.reason="legacy_static_proxy_only";return s;
}
ScoreResult evaluateTrial(const Module&parent,Trial&t,const RoundContext&r,const Scorer&scorer) {
  ScoreResult s;
  if(!t.valid){s.reason="trial_rejected";return s;}
  if(t.cleanupMode!=r.cleanupMode){s.reason="cleanup_mode_mismatch";return s;}
  if(t.candidate.version!=r.parentVersion||t.candidate.function!=r.function||moduleHash(parent)!=r.parentHash){s.reason="round_identity_mismatch";return s;}
  auto start=Clock::now();auto*before=parent.getFunction(r.function);auto*raw=t.raw->getFunction(r.function);auto*after=t.normalized->getFunction(r.function);
  Analysis ba(*before),aa(*after);
  s=scorer.evaluate({t.candidate,*before,*raw,*after,ba,aa,t.before,t.afterRaw,t.after,t.left,t.right,t.replication,&t},r);
  if(s.status==ScoreStatus::Scored&&(!std::isfinite(s.total)||!std::isfinite(s.staticGain)||!std::isfinite(s.staticScore)||!std::isfinite(s.cleanupGain)||!std::isfinite(s.parentGain)||!std::isfinite(s.dependencyPenalty)||!std::isfinite(s.livenessPenalty))){s.status=ScoreStatus::NotEvaluable;s.reason="nonfinite_score";}
  t.scoreMs=millis(start);return s;
}
bool eligible(const Trial&t,const ScoreResult&s,const Options&o) {
  if(!(t.valid&&s.status==ScoreStatus::Scored&&std::isfinite(s.total)&&s.total>o.threshold&&(!o.requireParentGain||s.parentGain>0)))return false;
  if(o.maxUniformLoss>=0){
    // Conservative: without side metrics the guard cannot be checked.
    auto ok=s.metrics.find("side_metrics_available");
    if(ok==s.metrics.end()||ok->second!=1)return false;
    double worst=std::min(s.metrics.at("uniform_gain_false"),s.metrics.at("uniform_gain_true"));
    if(worst< -o.maxUniformLoss)return false;
  }
  return true;
}
Result greedy(const Module&input,const std::string&function,const Options&o,const Scorer&scorer,Observer*observer) {
  Result result;result.module=CloneModule(input);if(o.cleanupMode==CleanupMode::O3)normalize(*result.module,o.optLevel);
  if(verifyModule(*result.module,&errs()))throw std::runtime_error("initial normalization failed verification");
  if(observer)observer->initial(*result.module);
  std::shared_ptr<LogicalRegionState> logical;
  if(o.adjacentOnly){logical=LogicalRegionState::initialize(*result.module->getFunction(function));if(observer)observer->logical(0,logical->json());}
  std::set<std::string> committedStates{moduleHash(*result.module)};
  for(unsigned version=0;version<o.maxRounds;++version){
    auto*f=result.module->getFunction(function);if(!f||f->isDeclaration())throw std::runtime_error("function missing");
    auto candidates=enumerate(*f,version,o.crossDecisionLeaves);if(logical)candidates=logical->filter(*f,candidates);if(candidates.empty()){result.stop="no_supported_candidates";return result;}
    if(candidates.size()>o.maxTrials-result.trials){result.stop="trial_budget_before_complete_round";return result;}
    const auto round=makeRound(*result.module,function,version,o.optLevel,o.cleanupMode);if(observer)observer->round(round);
    Trial best;ScoreResult bestResult;double bestScore=o.threshold;bool anyScored=false;
    for(auto&candidate:candidates){candidate.localCopysign=o.localCopysign;candidate.localUnion=o.localUnion;candidate.hybrid=o.hybrid;candidate.coalesceGaps=o.coalesceGaps;candidate.completeLeafPlan=o.completeLeafPlan;candidate.crossDecisionLeaves=o.crossDecisionLeaves;candidate.crossLevelB2R=o.crossLevelB2R;candidate.speculation=o.speculation;candidate.speculationBudget=o.speculationBudget;Trial t;++result.trials;
      // A failing candidate (cleanup non-convergence, audit, invalid IR) is a
      // rejected trial, not a failed search. The parent module is never mutated.
      try{t=tryPair(*result.module,candidate,version,o.optLevel,o.cleanupMode,logical.get());}
      catch(const std::exception&e){t=Trial();t.candidate=candidate;t.cleanupMode=o.cleanupMode;t.reason=std::string("trial_exception:")+e.what();}
      ScoreResult score;
      try{score=evaluateTrial(*result.module,t,round,scorer);}
      catch(const std::exception&e){score=ScoreResult();score.reason=std::string("score_exception:")+e.what();}bool accept=eligible(t,score,o);anyScored|=score.status==ScoreStatus::Scored;
      if(observer)observer->trial(t,round,score,accept);
      if(accept&&score.total>bestScore){bestScore=score.total;bestResult=std::move(score);best=std::move(t);}
    }
    if(!best.valid){result.stop=anyScored?"no_positive_candidate":"no_evaluable_candidate";return result;}
    if(!committedStates.insert(moduleHash(*best.normalized)).second){result.stop="repeated_committed_state";return result;}
    if(logical){logical=std::move(best.logicalState);if(observer)observer->logical(version+1,logical->json());}
    result.module=std::move(best.normalized);++result.commits;
    if(observer)observer->commit(version+1,best.candidate,bestResult,*result.module);
  }
  result.stop="round_budget";return result;
}

}
