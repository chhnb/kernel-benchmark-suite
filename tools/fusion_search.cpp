#include "fusion_search.h"
#include "darm_pair_engine/LocalComputationFusion.h"
#include "logical_region_state.h"
#include "darm_pair_engine/RegionMelder.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/Analysis/InstructionSimplify.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Transforms/Utils/Cloning.h"
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
  if(auto*v=dyn_cast<VectorType>(t)){k.lanes=v->getElementCount().Min;k.scalable=v->getElementCount().Scalable;t=v->getElementType();}
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
static bool foldProvenBranch(Function &f, const std::set<BasicBlock*> *allowed=nullptr) {
  DominatorTree dt(f);
  for(auto &b:f){
    if(allowed&&!allowed->count(&b))continue;
    auto *br=dyn_cast<BranchInst>(b.getTerminator());if(!br||!br->isConditional())continue;
    std::map<Value*,bool> facts;
    std::function<void(Value*,bool,unsigned)> add=[&](Value *v,bool truth,unsigned depth){
      if(depth>16)return;facts[v]=truth;
      if(auto *sel=dyn_cast<SelectInst>(v)){
        auto *t=dyn_cast<ConstantInt>(sel->getTrueValue());auto *ff=dyn_cast<ConstantInt>(sel->getFalseValue());
        if(t&&t->isOne()!=truth){add(sel->getCondition(),false,depth+1);add(sel->getFalseValue(),truth,depth+1);}
        if(ff&&ff->isOne()!=truth){add(sel->getCondition(),true,depth+1);add(sel->getTrueValue(),truth,depth+1);}
      }
    };
    auto *node=dt.getNode(&b);
    for(auto *parent=node?node->getIDom():nullptr;parent;parent=parent->getIDom()){
      auto *pb=dyn_cast<BranchInst>(parent->getBlock()->getTerminator());
      if(!pb||!pb->isConditional()||pb->getSuccessor(0)==pb->getSuccessor(1))continue;
      for(unsigned side=0;side<2;++side){
        BasicBlockEdge edge(parent->getBlock(),pb->getSuccessor(side));
        if(dt.dominates(edge,&b))add(pb->getCondition(),side==0,0);
      }
    }
    auto it=facts.find(br->getCondition());if(it==facts.end())continue;
    br->setCondition(ConstantInt::get(Type::getInt1Ty(f.getContext()),it->second));
    ConstantFoldTerminator(&b,allowed==nullptr);return true;
  }return false;
}
// Candidate-only cleanup. Never move instructions, rewrite terminators or
// visit unchanged neighboring computations. RAUW of a permitted value may
// update its users, but those users are not added to the optimization scope.
struct LocalSnapshot {
  WeakVH instruction;
  BasicBlock *parent;
  std::vector<Value*> operands;
  std::vector<std::pair<Value*,BasicBlock*>> phiEdges;
};
static std::vector<LocalSnapshot> snapshotLocal(Function &f) {
  std::vector<LocalSnapshot> out;
  for(auto &b:f)for(auto &i:b){LocalSnapshot s{WeakVH(&i),&b,{}};
    for(auto &op:i.operands())s.operands.push_back(op.get());
    if(auto*p=dyn_cast<PHINode>(&i))for(unsigned n=0;n<p->getNumIncomingValues();++n)s.phiEdges.emplace_back(p->getIncomingValue(n),p->getIncomingBlock(n));
    out.push_back(std::move(s));}
  return out;
}
static std::set<Instruction*> changedLocal(Function &f,const std::vector<LocalSnapshot>&before) {
  std::set<Instruction*> unchanged;
  for(auto &s:before)if(auto *i=dyn_cast_or_null<Instruction>((Value*)s.instruction)){
    bool same=i->getParent()==s.parent&&i->getNumOperands()==s.operands.size();
    if(same){
      if(auto*p=dyn_cast<PHINode>(i)){
        for(unsigned n=0;n<p->getNumIncomingValues();++n)
          same&=std::find(s.phiEdges.begin(),s.phiEdges.end(),std::make_pair(p->getIncomingValue(n),p->getIncomingBlock(n)))!=s.phiEdges.end();
      }else for(unsigned n=0;n<s.operands.size();++n)same&=i->getOperand(n)==s.operands[n];
    }
    if(same)unchanged.insert(i);
  }
  std::set<Instruction*> changed;
  for(auto &b:f)for(auto &i:b)if(!i.isTerminator()&&!unchanged.count(&i))changed.insert(&i);
  return changed;
}
static unsigned cleanupScoped(Function &f,const std::set<Instruction*>&scope) {
  struct Protected {WeakVH inst;BasicBlock *parent;unsigned opcode;std::vector<WeakTrackingVH> operands;};
  std::vector<Protected> protectedInsts;std::vector<WeakVH> work;
  for(auto &b:f)for(auto &i:b){
    if(scope.count(&i)){work.push_back(WeakVH(&i));continue;}
    Protected p{WeakVH(&i),&b,i.getOpcode(),{}};for(auto &op:i.operands())p.operands.emplace_back(op.get());protectedInsts.push_back(std::move(p));
  }
  auto check=[&](){for(auto &p:protectedInsts){auto*i=dyn_cast_or_null<Instruction>((Value*)p.inst);
    if(!i||i->getParent()!=p.parent||i->getOpcode()!=p.opcode||i->getNumOperands()!=p.operands.size())throw std::runtime_error("scoped_cleanup_changed_protected_instruction");
    for(unsigned n=0;n<p.operands.size();++n)if(i->getOperand(n)!=(Value*)p.operands[n])throw std::runtime_error("scoped_cleanup_changed_protected_operand");
  }};
  SimplifyQuery query(f.getParent()->getDataLayout());
  unsigned rounds=0;
  for(;rounds<32;++rounds){bool changed=false;
    for(auto &handle:work){auto*i=dyn_cast_or_null<Instruction>((Value*)handle);if(!i)continue;
      if(auto*v=SimplifyInstruction(i,query)){if(v!=i){i->replaceAllUsesWith(v);if(isInstructionTriviallyDead(i)){i->eraseFromParent();changed=true;continue;}}}
      if(isInstructionTriviallyDead(i)){i->eraseFromParent();changed=true;continue;}
      // Common expressions only among allowed, earlier instructions in this BB.
      if(i->isTerminator()||isa<PHINode>(i)||i->mayReadOrWriteMemory()||i->mayHaveSideEffects())continue;
      if(auto*c=dyn_cast<CallBase>(i))if(c->isConvergent())continue;
      for(auto &prior:*i->getParent()){if(&prior==i)break;
        if(scope.count(&prior)&&prior.isIdenticalTo(i)){i->replaceAllUsesWith(&prior);i->eraseFromParent();changed=true;break;}}
    }
    check();if(!changed)return rounds+1;
  }
  throw std::runtime_error("scoped_cleanup_did_not_converge");
}
// CFG edits are restricted to blocks created by this trial. Boundary
// predecessor terminators and successor PHIs are the only additional edit
// sites. No generic SimplifyCFG, speculation, or recursive DCE.
static unsigned cleanupScopedCFG(Function &f, const std::set<Instruction*> &local,
                                  const std::set<BasicBlock*> &created) {
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

unsigned cleanup(Module &m,const std::string &function,unsigned level,CleanupMode mode) {
  if(mode==CleanupMode::None||mode==CleanupMode::ScopedLocal||mode==CleanupMode::ScopedCFG)return 0;
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
      if(simplifyCFG(&b,tti,SimplifyCFGOptions().setSimplifyCondBranch(false).sinkCommonInsts(false).hoistCommonInsts(false))){
        changed=true;break;
      }
    }
  }while(changed);
  if(mode==CleanupMode::DarmCFGEarlyCSE){
    legacy::FunctionPassManager pm(&m);
    pm.add(createTargetTransformInfoWrapperPass(tm?tm->getTargetIRAnalysis():TargetIRAnalysis()));
    pm.add(createEarlyCSEPass(false));
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
struct Inventory {
  std::vector<std::unique_ptr<Region>> logicalRegions;
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
static Boundary boundary(const Unit&u,Function&f) {
  Boundary v;v.entry=name(u.entry);v.exit=name(u.exit);std::set<std::string> ins,outs;
  for(auto&b:f)if(u.blocks.count(&b)){v.blocks.push_back(name(&b));for(auto&i:b){
    for(auto&op:i.operands()){auto*x=op.get();auto*def=dyn_cast<Instruction>(x);if((def&&!u.blocks.count(def->getParent()))||isa<Argument>(x))ins.insert(name(x));}
    for(auto*x:i.users())if(auto*use=dyn_cast<Instruction>(x))if(!u.blocks.count(use->getParent()))outs.insert(name(&i));
  }}v.liveIns.assign(ins.begin(),ins.end());v.liveOuts.assign(outs.begin(),outs.end());return v;
}
std::vector<Candidate> enumerate(Function&f,unsigned version) {
  Analysis a(f); Inventory inv(f,a);std::vector<Candidate> result;
  auto frontier=[&](const std::set<BasicBlock*>&side,const std::set<BasicBlock*>&opposite){
    std::vector<std::string> rs,out;std::set<BasicBlock*>covered;
    for(auto&kv:inv.units)if(kv.second.region&&kv.second.exit&&belongs(kv.second,side,opposite))rs.push_back(kv.first);
    for(auto&id:rs){bool nested=false;auto&u=inv.units.at(id);for(auto&other:rs){auto&v=inv.units.at(other);if(u.blocks.size()<v.blocks.size()&&subset(u.blocks,v.blocks)){nested=true;break;}}if(!nested){out.push_back(id);covered.insert(u.blocks.begin(),u.blocks.end());}}
    for(auto&b:f)if(side.count(&b)&&!opposite.count(&b)&&!covered.count(&b))out.push_back(inv.ids.at(&b));return out;
  };
  for(auto&b:f){auto*br=dyn_cast<BranchInst>(b.getTerminator());auto*node=a.pdt.getNode(&b);
    if(!br||!br->isConditional()||!node||!node->getIDom()||!node->getIDom()->getBlock()||!Utils::isValidMergeLocation(b,a.pdt))continue;
    auto*join=node->getIDom()->getBlock();auto l=reachable(br->getSuccessor(0),join),r=reachable(br->getSuccessor(1),join);
    // Same conservative scope as tryPair; do not spend trials on known rejects.
    auto scope=l;scope.insert(r.begin(),r.end());bool unsupported=!supportedLoopScope(&b,join,scope,a.loops);
    for(auto*x:scope){for(auto&i:*x)unsupported|=i.mayHaveSideEffects()||i.mayWriteToMemory();}
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
    // Keep the original DARM policy's supported choices in our candidate set.
    // A selected computation block may have a conditional terminator, so the
    // single-successor computation frontier above is not a complete superset.
    // DARM's list matcher requires each side's child regions to be a chain
    // under dominance. Parallel siblings are legal IR but unsupported by it.
    bool darmOrdered=true;
    auto* container=a.regions.getRegionFor(&b);
    for(unsigned side=0;side<2;++side) {
      std::vector<BasicBlock*> entries;
      for(auto& child:*container)if(a.dt.dominates(br->getSuccessor(side),child->getEntry()))entries.push_back(child->getEntry());
      for(size_t i=0;i<entries.size();++i)for(size_t j=i+1;j<entries.size();++j)
        if(!a.dt.dominates(entries[i],entries[j])&&!a.dt.dominates(entries[j],entries[i]))darmOrdered=false;
    }
    if(darmOrdered) {
    RegionAnalyzer darm(&b,a.dt,a.pdt);
    darm.computeRegionMatch();
    auto unitId=[&](BasicBlock*entry,BasicBlock*exit)->std::string {
      if(!exit)return inv.ids.at(entry);
      for(auto&kv:inv.units)if(kv.second.region && kv.second.entry==entry && kv.second.exit==exit)return kv.first;
      return {};
    };
    for(unsigned i=0;i<darm.regionMatchSize();++i) {
      if(!darm.isRegionMatchProfitable(i))continue;
      auto entries=darm.getRegionMatchEntryBlocks(i),exits=darm.getRegionMatchExitBlocks(i);
      auto li=unitId(entries.first,exits.first),ri=unitId(entries.second,exits.second);
      if(!li.empty()&&!ri.empty())result.push_back({f.getName().str(),inv.ids.at(&b),li,ri,version});
    }
    } // Original DARM matcher is optional; retain our other candidate families.
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
  bool prepare(BasicBlock *L,BasicBlock *R,DominatorTree &DT,LoopInfo &LI,bool regions=false) {
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
    for(auto &I:*Q){if(I.isTerminator())continue;
      if(isa<PHINode>(I)||isa<CallBase>(I)||I.mayReadOrWriteMemory()||I.mayHaveSideEffects()||!isSafeToSpeculativelyExecute(&I))return false;
      for(auto &O:I.operands())if(auto *D=dyn_cast<Instruction>(O)){
        if(D->getParent()==Q){if(!D->comesBefore(&I))return false;}
        else if(!DT.dominates(D,A))return false;
      }
    }
    if(auto *C=dyn_cast<Instruction>(B->getCondition()))if(C->getParent()!=Q&&!DT.dominates(C,A))return false;
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
Trial tryPair(const Module&parent,const Candidate&c,unsigned version,unsigned level,CleanupMode mode,const LogicalRegionState *logical) {
  auto started=Clock::now();Trial t;t.candidate=c;t.cleanupMode=mode;auto reject=[&](const char*reason){t.reason=reason;t.totalMs=millis(started);return std::move(t);};
  if(c.version!=version)return reject("stale_candidate_version");
  ValueToValueMapTy parentMap;
  t.raw=CloneModule(parent,parentMap);if(logical)t.logicalState=logical->clone(parentMap);parentMap.clear();auto*f=t.raw->getFunction(c.function);
  if(!f||f->isDeclaration())return reject("function_missing");
  if(verifyModule(*t.raw,&errs()))return reject("input_verifier_failed");
  Analysis a(*f);Inventory inv(*f,a);
  if(!inv.blocks.count(c.split)||!inv.units.count(c.left)||!inv.units.count(c.right))return reject("unknown_block_or_region_id");
  auto*split=inv.blocks.at(c.split);auto*br=dyn_cast<BranchInst>(split->getTerminator());auto*node=a.pdt.getNode(split);
  if(!br||!br->isConditional()||!node||!node->getIDom()||!node->getIDom()->getBlock()||!Utils::isValidMergeLocation(*split,a.pdt))return reject("unsupported_split_location");
  Unit l=inv.units.at(c.left),r=inv.units.at(c.right);
  if(bool(l.region)!=bool(r.region))return reject("mixed_granularity_not_supported");
  for(auto*b:l.blocks)if(r.blocks.count(b))return reject("overlapping_pair");
  auto*join=node->getIDom()->getBlock();auto ls=reachable(br->getSuccessor(0),join),rs=reachable(br->getSuccessor(1),join);
  if(belongs(l,rs,ls)&&belongs(r,ls,rs)){std::swap(l,r);t.swapped=true;}
  else if(!belongs(l,ls,rs)||!belongs(r,rs,ls))return reject("pair_not_exclusive_on_opposite_sides");
  auto scope=ls;scope.insert(rs.begin(),rs.end());if(!supportedLoopScope(split,join,scope,a.loops))return reject("loop_in_trial_scope_not_supported");for(auto*b:scope){for(auto&i:*b)if(i.mayHaveSideEffects()||i.mayWriteToMemory())return reject("side_effect_in_trial_scope_not_supported");}
  if(!l.region&&!a.pdt.dominates(l.entry,br->getSuccessor(0))&&!a.pdt.dominates(r.entry,br->getSuccessor(1)))return reject("both_selected_blocks_optional_replication_not_supported");
  RegionAnalyzer ma(split,a.dt,a.pdt);
  if(l.region){if(!l.exit||!r.exit)return reject("region_without_exit");
    RegionComparator cmp(l.region,r.region);if(!cmp.compare())return reject("region_structure_mismatch");
    DenseMap<BasicBlock*,BasicBlock*>mapping;cmp.getMapping(mapping);std::set<BasicBlock*>values;
    for(auto&kv:mapping){if(!l.blocks.count(kv.first)||!r.blocks.count(kv.second))return reject("non_bijective_region_mapping");values.insert(kv.second);}
    if(mapping.size()!=l.blocks.size()||values.size()!=r.blocks.size()||l.blocks.size()!=r.blocks.size())return reject("non_bijective_region_mapping");
    if(!ma.selectExplicitRegions(l.region,r.region))return reject("region_structure_mismatch");
  }else ma.selectExplicitBlocks(l.entry,r.entry);
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
    }
  }
  AdjacentLeafEntry leafEntry;
  bool directLeaves=c.hybrid&&!useLocal&&bool(l.region)==bool(r.region)&&l.exit&&l.exit==r.exit&&leafEntry.prepare(l.entry,r.entry,a.dt,a.loops,bool(l.region));
  t.mergePath=directLeaves?(l.region?"darm-adjacent-R2R":"darm-adjacent-B2B"):useLocal?"local-compute":"darm-"+t.planKind;
  t.originalSimilarity=ma.explicitSimilarity();t.originalProfitable=ma.isRegionMatchProfitable(0);
  auto ft=Clock::now();t.before=features(*f);t.featuresMs+=millis(ft);t.left=boundary(l,*f);t.right=boundary(r,*f);t.replication=ma.requireRegionReplication();
  if(t.replication&&!l.region){
    // Only the expanded block needs one successor. The matched block inside
    // the opposite region may branch; RegionReplicator copies that topology.
    auto *expanded=a.pdt.dominates(l.entry,br->getSuccessor(0))?l.entry:r.entry;
    if(!expanded->getUniqueSuccessor())return reject("replication_requires_unique_successor");
  }
  std::map<std::string,std::string> others;for(auto&g:*t.raw)if(&g!=f)others[g.getName().str()]=text(g);
  bool scoped=mode==CleanupMode::ScopedLocal||mode==CleanupMode::ScopedCFG;
  auto localBefore=scoped?snapshotLocal(*f):std::vector<LocalSnapshot>{};
  std::vector<WeakVH> priorBlocks; if(mode==CleanupMode::ScopedCFG)for(auto &b:*f)priorBlocks.emplace_back(&b);
  auto mt=Clock::now();
  std::unique_ptr<Analysis> leafAnalysis;
  std::unique_ptr<RegionAnalyzer> leafAnalyzer;
  std::unique_ptr<Region> leftLogicalRegion,rightLogicalRegion;
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
  RegionMelder melder(directLeaves?*leafAnalyzer:ma,true);if(t.logicalState)melder.onValueMapping=[&](const ValueToValueMapTy &m){t.logicalState->transfer(m);};if(useLocal){
    if(l.region||r.region)return reject("local_requires_basic_blocks");
    std::string why;
    if(!fuseLocalComputations(l.entry,r.entry,melder.onValueMapping,why,c.localUnion||c.hybrid)){t.reason=why;t.totalMs=millis(started);return t;}
    t.replication=false;
  }else melder.merge(0);canonicalPhiOrder(*t.raw,c.function);t.mergeMs=millis(mt);
  if(verifyModule(*t.raw,&errs()))return reject("raw_verifier_failed");
  for(auto&g:*t.raw)if(&g!=f)if(!others.count(g.getName().str())||others.at(g.getName().str())!=text(g))return reject("other_function_changed");
  ft=Clock::now();t.afterRaw=features(*f);t.featuresMs+=millis(ft);if(t.afterRaw.loops>t.before.loops)return reject("new_raw_loop");
  auto blockLabel=[](const Value *V){std::string S;raw_string_ostream O(S);V->printAsOperand(O,false);O.flush();return S;};
  auto rawLocalScope=scoped?changedLocal(*f,localBefore):std::set<Instruction*>{};
  std::set<BasicBlock*> oldBlocks,rawCreated;
  if(mode==CleanupMode::ScopedCFG){for(auto &h:priorBlocks)if(auto *b=dyn_cast_or_null<BasicBlock>((Value*)h))oldBlocks.insert(b);for(auto &b:*f)if(!oldBlocks.count(&b))rawCreated.insert(&b);}
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
  t.cleanupIterations=mode==CleanupMode::ScopedCFG?cleanupScopedCFG(*t.normalized->getFunction(c.function),cleanLocalScope,cleanCreated):mode==CleanupMode::ScopedLocal?cleanupScoped(*t.normalized->getFunction(c.function),cleanLocalScope):cleanup(*t.normalized,c.function,level,mode);canonicalPhiOrder(*t.normalized,c.function);t.normalizeMs=millis(nt);
  for(size_t I=0;I<CleanedBlocks.size();++I)if(Value *V=CleanedBlocks[I])
    t.blockProvenance[I].cleanedBlock=blockLabel(V);
  if(verifyModule(*t.normalized,&errs()))return reject("normalized_verifier_failed");
  auto*after=t.normalized->getFunction(c.function);if(!after||after->isDeclaration())return reject("target_lost_after_normalization");
  ft=Clock::now();t.after=features(*after);t.featuresMs+=millis(ft);if(t.after.loops>t.before.loops)return reject("new_normalized_loop");
  if(t.logicalState){if(!t.logicalState->stageMerge(c))return reject("logical_state_candidate_mismatch");t.logicalState->rebind(*after);}
  t.valid=true;t.reason="verified_ir_only";t.totalMs=millis(started);return t;
}
RoundContext makeRound(const Module&parent,const std::string&function,unsigned version,unsigned level,CleanupMode mode) {
  RoundContext r;r.cleanupMode=mode;r.parentVersion=version;r.function=function;r.parentHash=moduleHash(parent);
  r.targetTriple=parent.getTargetTriple();r.dataLayout=parent.getDataLayoutStr();r.llvmVersion=LLVM_VERSION_STRING;
  r.cleanup=mode==CleanupMode::O3?"legacy-PassManagerBuilder-O"+std::to_string(level)+"-loopvec1-slpvec1":"darm-simplifycfg-fixedpoint-condbranch0-sink0-hoist0-targettti";
  r.cleanup+=";phi-edge-function-order-v1";
  if(mode==CleanupMode::StructuralCFG)r.cleanup+=";dominating-edge-boolean-guard-fold-v1";
  if(mode==CleanupMode::DarmCFGEarlyCSE)r.cleanup+="-earlycse-memoryssa0";
  if(mode==CleanupMode::PostOptFixedPoint)r.cleanup="phi-edge-function-order-v1;earlycse-memoryssa0-instcombine-simplifycfg-default-dce-earlycse-pure-scalar-phi-triangle-v1-fixedpoint-sha1-cap32";
  if(mode==CleanupMode::ScopedLocal)r.cleanup="changed-instructions-only;simplify-local-cse-dce;no-cfg-motion;protected-outside-audit;control-noop";
  if(mode==CleanupMode::ScopedCFG)r.cleanup="trial-created-blocks-only;empty-block-bypass-empty-diamond-proven-branch;boundary-terminators-and-phis;outside-audit;control-no-created-blocks-noop";
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
  s=scorer.evaluate({t.candidate,*before,*raw,*after,ba,aa,t.before,t.afterRaw,t.after,t.left,t.right,t.replication},r);
  if(s.status==ScoreStatus::Scored&&(!std::isfinite(s.total)||!std::isfinite(s.staticGain)||!std::isfinite(s.staticScore)||!std::isfinite(s.cleanupGain)||!std::isfinite(s.parentGain)||!std::isfinite(s.dependencyPenalty)||!std::isfinite(s.livenessPenalty))){s.status=ScoreStatus::NotEvaluable;s.reason="nonfinite_score";}
  t.scoreMs=millis(start);return s;
}
bool eligible(const Trial&t,const ScoreResult&s,const Options&o) {
  return t.valid&&s.status==ScoreStatus::Scored&&std::isfinite(s.total)&&s.total>o.threshold&&(!o.requireParentGain||s.parentGain>0);
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
    auto candidates=enumerate(*f,version);if(logical)candidates=logical->filter(*f,candidates);if(candidates.empty()){result.stop="no_supported_candidates";return result;}
    if(candidates.size()>o.maxTrials-result.trials){result.stop="trial_budget_before_complete_round";return result;}
    const auto round=makeRound(*result.module,function,version,o.optLevel,o.cleanupMode);if(observer)observer->round(round);
    Trial best;ScoreResult bestResult;double bestScore=o.threshold;bool anyScored=false;
    for(auto&candidate:candidates){candidate.localCopysign=o.localCopysign;candidate.localUnion=o.localUnion;candidate.hybrid=o.hybrid;auto t=tryPair(*result.module,candidate,version,o.optLevel,o.cleanupMode,logical.get());++result.trials;
      auto score=evaluateTrial(*result.module,t,round,scorer);bool accept=eligible(t,score,o);anyScored|=score.status==ScoreStatus::Scored;
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
