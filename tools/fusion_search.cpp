#include "fusion_profile.h"
#include <optional>
#include "fusion_search.h"
#include "darm_pair_engine/InstructionMatch.h"
#include "logical_region_state.h"
#include "darm_pair_engine/RegionMelder.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/ModuleSlotTracker.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/Analysis/CaptureTracking.h"
#include "llvm/Analysis/InstructionSimplify.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/SSAUpdater.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Support/SHA1.h"
#include "llvm/Config/llvm-config.h"
#include "llvm/IR/Operator.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Transforms/InstCombine/InstCombine.h"
#include <array>
#include <chrono>
#include <algorithm>
#include <cmath>
#include <functional>
#include <limits>
#include <map>
#include <set>
#include <stdexcept>
using namespace llvm;
namespace fusion {
// Arm normalization may invert a predicate to place the left arm on true.
static Value *emitB2BSelect(IRBuilder<> &builder, Value *condition,
                            Value *left, Value *right) {
  using namespace PatternMatch;
  Value *original = nullptr;
  if (match(condition, m_Not(m_Value(original))))
    return builder.CreateSelect(original, right, left);
  return builder.CreateSelect(condition, left, right);
}
static std::string name(const Value *v) {
  if(!v) return "<exit>";
  std::string s; raw_string_ostream out(s); v->printAsOperand(out,false); return out.str();
}
// Give each comparison its own function metadata slots. Include the node
// definitions so equal slot numbers cannot hide changes to the attachments.
static std::string isolatedFunctionText(const Function &f) {
  ModuleSlotTracker slots(f.getParent(), false);
  slots.incorporateFunction(f);
  std::string result;
  raw_string_ostream out(result);
  static_cast<const Value &>(f).print(out, slots);
  SmallPtrSet<const MDNode *, 16> seen;
  auto emit = [&](auto &&self, const Metadata *metadata) -> void {
    auto *node = dyn_cast_or_null<MDNode>(metadata);
    if (!node || !seen.insert(node).second) return;
    out << '\n';
    node->print(out, slots, f.getParent());
    for (const auto &operand : node->operands())
      self(self, operand.get());
  };
  SmallVector<std::pair<unsigned, MDNode *>, 4> attachments;
  f.getAllMetadata(attachments);
  for (const auto &attachment : attachments)
    emit(emit, attachment.second);
  for (const auto &block : f)
    for (const auto &inst : block) {
      for (const auto &operand : inst.operands())
        if (auto *metadata = dyn_cast<MetadataAsValue>(operand.get()))
          emit(emit, metadata->getMetadata());
      attachments.clear();
      inst.getAllMetadata(attachments);
      for (const auto &attachment : attachments)
        emit(emit, attachment.second);
    }
  return out.str();
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
  ProfileScope hashScope("serialize_and_hash");
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
// Match the original CFMelder outer cleanup, including target-aware TTI.
// RegionMelder::merge already runs internal cleanup, post-optimization,
// and (unless disabled upstream) unpredication.
// Fold a branch whose two edges meet immediately, with one edge passing
// through an empty or safely speculatable scalar block. External predecessors of Join remain untouched.
// Also admit safe, memory-free scalar instructions. Loads, stores, convergent
// calls and arbitrary calls must retain their guards.
static bool usesDarmDCE(CleanupMode mode) {
  return mode == CleanupMode::DarmCFGInstCombine;
}

static unsigned cleanup(Module &m,const std::string &function,CleanupMode mode) {
  if(mode==CleanupMode::None)return 0;
  canonicalPhiOrder(m,function);
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

  bool changed;
  do {
    changed=false;
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
  if(usesDarmDCE(mode)){
    legacy::FunctionPassManager pm(&m);
    pm.add(createTargetTransformInfoWrapperPass(tm?tm->getTargetIRAnalysis():TargetIRAnalysis()));
    pm.add(createEarlyCSEPass(false));
    if (usesDarmDCE(mode)) pm.add(createDeadCodeEliminationPass());
    if (mode==CleanupMode::DarmCFGInstCombine) pm.add(createInstructionCombiningPass());
    pm.doInitialization();pm.run(*f);pm.doFinalization();
    return 1;
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
  std::map<std::string,BasicBlock*> blocks;
  std::map<BasicBlock*,std::string> ids;
  std::map<std::string,Unit> units;
  Inventory(Function&f,Analysis&a) {
    unsigned n=0;for(auto&b:f){auto id="B"+std::to_string(n++);blocks[id]=&b;ids[&b]=id;units[id]={&b,b.getSingleSuccessor(),nullptr,{&b}};}
    n=0;std::function<void(Region*)> visit=[&](Region*r){std::set<BasicBlock*>bs;for(auto*b:r->blocks())bs.insert(b);units["R"+std::to_string(n++)]={r->getEntry(),r->getExit(),r,bs};for(auto&c:*r)visit(c.get());};visit(a.regions.getTopLevelRegion());
    // DARM can pair single-block loops whose exit includes a trailing
    // edge block. RegionInfo may canonicalize that boundary differently.
    for (auto &split : f) {
      auto *branch = dyn_cast<BranchInst>(split.getTerminator());
      auto *node = a.pdt.getNode(&split);
      if (!branch || !branch->isConditional() || !node || !node->getIDom()) continue;
      auto *exit = node->getIDom()->getBlock();
      if (!exit) continue;
      for (auto *entry : successors(&split)) {
        auto *loop = a.loops.getLoopFor(entry);
        if (!loop || loop->getHeader() != entry || loop->getNumBlocks() != 1) continue;
        auto *edge = loop->getUniqueExitBlock();
        if (!edge) continue;
        std::set<BasicBlock *> members{entry};
        if (edge != exit) {
          if (edge->getSinglePredecessor() != entry || edge->getSingleSuccessor() != exit)
            continue;
          members.insert(edge);
        }
        auto id = "H" + ids.at(entry).substr(1) + "_" + ids.at(exit).substr(1);
        if (units.count(id)) continue;
        auto region = std::make_unique<Region>(entry, exit, &a.regions, &a.dt,
                                               a.regions.getTopLevelRegion());
        units[id] = {entry, exit, region.get(), members};
        logicalRegions.push_back(std::move(region));
      }
    }
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

std::vector<Candidate> enumerate(Function&f,unsigned version) {
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
      if(bool(lu.region)!=bool(ru.region)||lu.region)continue;
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
      if(bool(inv.units.at(li).region)==bool(inv.units.at(ri).region)&&
         !inv.units.at(li).region)result.push_back({f.getName().str(),inv.ids.at(&b),li,ri,version});
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
std::vector<ResolvedCandidate> resolveCandidateCatalog(Function &f,unsigned version) {
  auto candidates=enumerate(f,version);
  Analysis analysis(f);Inventory inventory(f,analysis);
  std::vector<ResolvedCandidate> result;
  for(const auto &c:candidates){
    const auto &l=inventory.units.at(c.left),&r=inventory.units.at(c.right);
    result.push_back({c,inventory.blocks.at(c.split),l.entry,l.exit,r.entry,r.exit,
                      bool(l.region),bool(r.region)});
  }
  return result;
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
    std::set<Instruction*> slice;{
      SmallVector<Instruction*,16> work;if(auto *c=dyn_cast<Instruction>(B->getCondition()))work.push_back(c);
      while(!work.empty()){auto *i=work.pop_back_val();if(i->getParent()!=Q||!slice.insert(i).second)continue;
        for(auto &op:i->operands())if(auto *d=dyn_cast<Instruction>(op))work.push_back(d);}
    }
    unsigned hoisted=0;
    for(auto &I:*Q){if(I.isTerminator())continue;
      if(isa<PHINode>(I)||isa<CallBase>(I)||I.mayReadOrWriteMemory()||I.mayHaveSideEffects()||!isSafeToSpeculativelyExecute(&I))return false;
      if(!slice.count(&I))hoisted+=fusionInstructionWeight(I);
      for(auto &O:I.operands())if(auto *D=dyn_cast<Instruction>(O)){
        if(D->getParent()==Q){if(!D->comesBefore(&I))return false;}
        else if(!DT.dominates(D,A))return false;
      }
    }
    if(auto *C=dyn_cast<Instruction>(B->getCondition()))if(C->getParent()!=Q&&!DT.dominates(C,A))return false;
    if(hoisted>0)return false;
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
    const std::vector<Candidate> &candidates) {
  std::set<std::string> rejected;
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
        analysis.loops,false))continue;
    rejected.insert(candidate.key());
  }
  return rejected;
}
// Move only mandatory, simple-load dependency cones to a dedicated leaf
// prefix. Acyclic read-only leaves with speculatable calls cannot change the
// memory state or prevent the original mandatory loads from executing.
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

// Recognize a guarded read followed by a shared read tail. The edge case
// that originally bypassed the guard must have the same ordered read list
// as the shared tail, with the region-side bases and a common edge index.
static bool foldGuardedReadBoundary(BasicBlock &entry, Value *trialSide, DominatorTree &dt) {
  auto conditional = [](BasicBlock *block) -> BranchInst * {
    auto *br = dyn_cast<BranchInst>(block->getTerminator());
    return br && br->isConditional() ? br : nullptr;
  };
  auto *outer = conditional(&entry);
  if (!outer) return false;
  auto *choice = dyn_cast<BinaryOperator>(outer->getCondition());
  if (!choice || choice->getOpcode() != Instruction::And) return false;
  auto *edge = outer->getSuccessor(0);
  auto *guard = outer->getSuccessor(1);
  auto *guardBranch = conditional(guard);
  if (!guardBranch || edge->getSinglePredecessor() != &entry ||
      guard->getSinglePredecessor() != &entry) return false;
  Value *side = guardBranch->getCondition();
  using namespace PatternMatch;
  if (side != trialSide && !match(side, m_Not(m_Specific(trialSide)))) return false;
  Value *boundary = choice->getOperand(0) == side ? choice->getOperand(1) :
                    choice->getOperand(1) == side ? choice->getOperand(0) : nullptr;
  if (!boundary || boundary == side) return false;
  auto *mask = guardBranch->getSuccessor(0);
  auto *check = guardBranch->getSuccessor(1);
  auto *test = conditional(check);
  if (!test || mask->getSinglePredecessor() != guard ||
      mask->getTerminator()->getNumSuccessors() != 1 ||
      mask->getSingleSuccessor() != check || pred_size(check) != 2)
    return false;
  auto *shared = test->getSuccessor(1);
  auto *join = shared->getSingleSuccessor();
  if (!join || edge->getSingleSuccessor() != join ||
      edge->getTerminator()->getNumSuccessors() != 1 ||
      shared->getTerminator()->getNumSuccessors() != 1 ||
      shared->getSinglePredecessor() != check || !shared->phis().empty() ||
      !test->getSuccessor(0)->phis().empty()) return false;
  SmallPtrSet<BasicBlock *, 8> distinct;
  for (auto *block : {&entry, edge, guard, mask, check, shared, join, test->getSuccessor(0)})
    if (!distinct.insert(block).second) return false;
  auto *testAnd = dyn_cast<BinaryOperator>(test->getCondition());
  if (!testAnd || testAnd->getOpcode() != Instruction::And) return false;
  Value *tested = testAnd->getOperand(0) == side ? testAnd->getOperand(1) :
                  testAnd->getOperand(1) == side ? testAnd->getOperand(0) : nullptr;
  auto *carry = dyn_cast<PHINode>(&check->front());
  if (!carry || !carry->hasOneUse() || !testAnd->hasOneUse() ||
      testAnd->getParent() != check || !isa<UndefValue>(carry->getIncomingValueForBlock(guard)))
    return false;
  // InstCombine can move the comparison into the protected block and
  // carry the boolean instead of the load result.
  const bool carriesComparison = tested == carry;
  auto *compare = dyn_cast_or_null<ICmpInst>(
      carriesComparison ? carry->getIncomingValueForBlock(mask) : tested);
  if (!compare || !compare->hasOneUse() ||
      compare->getParent() != (carriesComparison ? mask : check) ||
      check->size() != (carriesComparison ? 3 : 4)) return false;
  Value *compared = nullptr;
  if (isa<Constant>(compare->getOperand(0))) compared = compare->getOperand(1);
  else if (isa<Constant>(compare->getOperand(1))) compared = compare->getOperand(0);
  if (!compared || (!carriesComparison && compared != carry)) return false;
  auto *read = dyn_cast<LoadInst>(carriesComparison ? compared :
                                  carry->getIncomingValueForBlock(mask));
  if (!read || read->getParent() != mask || !read->isSimple() || !read->hasOneUse())
    return false;
  for (auto &inst : *guard)
    if (!inst.isTerminator() && !safeToExecuteUnconditionally(inst)) return false;
  for (auto &inst : *mask)
    if (!inst.isTerminator() && &inst != read && !safeToExecuteUnconditionally(inst))
      return false;

  auto reads = [](BasicBlock *block, SmallVectorImpl<LoadInst *> &loads) {
    for (auto &inst : *block) {
      if (inst.isTerminator()) continue;
      if (auto *load = dyn_cast<LoadInst>(&inst)) {
        if (!load->isSimple()) return false;
        loads.push_back(load);
      } else if (!safeToExecuteUnconditionally(inst)) {
        return false;
      }
    }
    return true;
  };
  SmallVector<LoadInst *, 8> edgeReads, sharedReads;
  if (!reads(edge, edgeReads) || !reads(shared, sharedReads) ||
      edgeReads.empty() || edgeReads.size() != sharedReads.size()) return false;
  DenseMap<Value *, Value *> paired;
  Value *edgeIndex = nullptr;
  SelectInst *index = nullptr;
  for (unsigned i = 0; i < edgeReads.size(); ++i) {
    auto *left = edgeReads[i], *right = sharedReads[i];
    auto *from = dyn_cast<GetElementPtrInst>(left->getPointerOperand());
    auto *to = dyn_cast<GetElementPtrInst>(right->getPointerOperand());
    if (!from || !to || !from->isSameOperationAs(to) || from->getNumIndices() != 1 ||
        from->isInBounds() != to->isInBounds() || !left->isSameOperationAs(right))
      return false;
    SmallVector<std::pair<unsigned, MDNode *>, 4> leftMetadata, rightMetadata;
    left->getAllMetadataOtherThanDebugLoc(leftMetadata);
    right->getAllMetadataOtherThanDebugLoc(rightMetadata);
    if (leftMetadata != rightMetadata) return false;
    auto *base = dyn_cast<SelectInst>(to->getPointerOperand());
    auto *selectedIndex = dyn_cast<SelectInst>(to->getOperand(1));
    if (!base || base->getCondition() != side || base->getTrueValue() != from->getPointerOperand() ||
        !selectedIndex || selectedIndex->getParent() != shared ||
        selectedIndex->getCondition() != side ||
        (edgeIndex && edgeIndex != from->getOperand(1)) || (index && index != selectedIndex))
      return false;
    edgeIndex = from->getOperand(1);
    index = selectedIndex;
    paired[left] = right;
  }
  // Account for every outgoing value on the edge being redirected.
  SmallVector<PHINode *, 8> undefOnEdge;
  for (auto &phi : join->phis()) {
    auto *from = phi.getIncomingValueForBlock(edge);
    auto *to = phi.getIncomingValueForBlock(shared);
    if (from == to || paired.lookup(from) == to) continue;
    if (!isa<UndefValue>(from)) return false;
    undefOnEdge.push_back(&phi);
  }
  for (auto &inst : *edge)
    for (auto *user : inst.users()) {
      auto *use = dyn_cast<Instruction>(user);
      if (!use || (use->getParent() != edge &&
                   !(paired.count(&inst) && isa<PHINode>(use) && use->getParent() == join)))
        return false;
    }

  // Form both bypass indices at Entry. Any newly executed computation must
  // be speculatable even when the corresponding index is never selected.
  auto available = [&](Value *value, BasicBlock *local) {
    SmallPtrSet<Value *, 16> seen;
    SmallVector<Value *, 16> work{value};
    while (!work.empty()) {
      auto *def = dyn_cast<Instruction>(work.pop_back_val());
      if (!def || dt.dominates(def, outer) || !seen.insert(def).second) continue;
      if (def->getParent() != local || !safeToExecuteUnconditionally(*def) ||
          isa<PHINode>(def)) return false;
      work.append(def->op_begin(), def->op_end());
    }
    return true;
  };
  Value *regionIndex = index->getTrueValue();
  if (!available(edgeIndex, edge) || !available(index->getFalseValue(), shared))
    return false;
  if (auto *definition = dyn_cast<Instruction>(regionIndex))
    if (!dt.dominates(definition, guardBranch) && definition->getParent() != mask)
      return false;
  // Restrict the region index select to the matched address calculations.
  for (auto *user : index->users())
    if (llvm::none_of(sharedReads, [&](LoadInst *load) {
          return load->getPointerOperand() == user;
        })) return false;

  IRBuilder<> builder(outer);
  DenseMap<Value *, Value *> emitted;
  std::function<Value *(Value *)> emit = [&](Value *value) -> Value * {
    auto *def = dyn_cast<Instruction>(value);
    if (!def || dt.dominates(def, outer)) return value;
    if (auto *mapped = emitted.lookup(value)) return mapped;
    auto *copy = def->clone();
    for (unsigned i = 0; i < def->getNumOperands(); ++i)
      copy->setOperand(i, emit(def->getOperand(i)));
    return emitted[value] = builder.Insert(copy);
  };
  Value *atEdge = emit(edgeIndex);
  Value *atShort = emit(index->getFalseValue());
  auto *bypass = builder.CreateSelect(side, atEdge, atShort, "boundary.index");
  auto *needsMask = builder.CreateAnd(side, builder.CreateNot(boundary), "boundary.read.guard");
  outer->setCondition(needsMask);
  outer->setMetadata(LLVMContext::MD_prof, nullptr);
  outer->setSuccessor(0, guard);
  outer->setSuccessor(1, shared);
  auto *fromPath = PHINode::Create(index->getType(), 2, "boundary.shared.index", &shared->front());
  fromPath->addIncoming(bypass, &entry);
  fromPath->addIncoming(regionIndex, guard);
  fromPath->addIncoming(UndefValue::get(index->getType()), check);
  index->replaceAllUsesWith(fromPath);
  index->eraseFromParent();

  IRBuilder<> results(shared->getTerminator());
  for (auto *phi : undefOnEdge) {
    unsigned incoming = phi->getBasicBlockIndex(shared);
    phi->setIncomingValue(incoming, results.CreateSelect(choice,
        phi->getIncomingValueForBlock(edge), phi->getIncomingValue(incoming)));
  }
  auto *detour = test->getSuccessor(0);
  while (&mask->front() != mask->getTerminator())
    mask->front().moveBefore(guardBranch);
  if (!carriesComparison) {
    compare->replaceUsesOfWith(carry, read);
    compare->moveBefore(guardBranch);
  }
  BranchInst::Create(detour, shared, compare, guardBranch);
  guardBranch->eraseFromParent();
  // Disconnect the dead paths before removing their phi entries at Join.
  DeleteDeadBlocks({edge, mask, check});

  return true;
}

// Share identical trailing arithmetic by redirecting the short arm to
// the existing anchor. All other edges, including the long arm's memory
// paths, keep their original execution conditions.
static Trial tryPairImpl(const Module&parent,const Candidate&c,unsigned version,CleanupMode mode,const LogicalRegionState *logical,bool nested,bool allowB2B,B2RStrategy b2rStrategy,Trial *boundaryFold);
// Public entry. The outermost call owns the side tag and removes it from every
// IR it returns, so committed modules, debug dumps and hashes never carry it.
Trial tryPair(const Module&parent,const Candidate&c,unsigned version,unsigned level,CleanupMode mode,const LogicalRegionState *logical) {
  return tryPair(parent,c,version,level,mode,logical,true);
}
Trial tryPair(const Module&parent,const Candidate&c,unsigned version,unsigned,CleanupMode mode,const LogicalRegionState *logical,bool allowB2B,B2RStrategy b2rStrategy,Trial *boundaryFold) {
  bool nested=hasSideTag(parent.getFunction(c.function));
  Trial t=tryPairImpl(parent,c,version,mode,logical,nested,allowB2B,b2rStrategy,boundaryFold);
  if(!nested){
    stripSideTag(t.raw.get());stripSideTag(t.normalized.get());
    if (boundaryFold && boundaryFold->valid) {
      stripSideTag(boundaryFold->raw.get());
      stripSideTag(boundaryFold->normalized.get());
    }
  }
  return t;
}
static Trial tryPairImpl(const Module&parent,const Candidate&c,unsigned version,CleanupMode mode,const LogicalRegionState *logical,bool nested,bool allowB2B,B2RStrategy b2rStrategy,Trial *boundaryFold) {
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
  if(completeLeaf)return reject("v1_requires_block_or_region_pair");
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
    if(l.region||r.region||
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
  const bool guardsUnsafeWork=true;
  const bool guardedAnchors=!l.region && leftRequired && rightRequired &&
      !logical && guardsUnsafeWork;
  const bool matchedStorePair=(l.region ||
      (l.entry==br->getSuccessor(0) && r.entry==br->getSuccessor(1) &&
       l.entry->getSingleSuccessor()==join && r.entry->getSingleSuccessor()==join)) &&
      leftRequired &&
      rightRequired && !logical &&
      guardsUnsafeWork;
  // Both strategies allow ordinary accesses in the expanded block and the
  // opposite region. The strategy controls how unmatched work is emitted.
  const bool replicationWithMemory = !l.region && !logical &&
      leftRequired != rightRequired &&
      (leftRequired ? l.entry : r.entry) ==
          br->getSuccessor(leftRequired ? 0 : 1) &&
      (leftRequired ? l.entry : r.entry)->getSingleSuccessor() == join;
  const bool darmReplication = replicationWithMemory;
  std::set<StoreInst*> regionStores;
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
  bool auditRetainedEffects=false;
  auto matchedBlock = [&](BasicBlock *block) {
    return l.blocks.count(block) || r.blocks.count(block);
  };
  auto recordEffect = [&](Instruction &instruction, const char *reason) {
    raw_string_ostream detail(t.localRejectReason);
    instruction.getParent()->printAsOperand(detail, false);
    detail << ": " << instruction;
    detail.flush();
    return reject(reason);
  };
  struct ProtectedWrite {
    WeakVH instruction;
    BasicBlock *block;
    Value *value;
    Value *address;
    bool leftSide;
  };
  std::vector<ProtectedWrite> protectedWrites;
  // RegionMelder isolates the selected exits before melding. Ordinary
  // stores in the continuation stay in their original blocks.
  std::map<BasicBlock *, SmallVector<WeakVH, 4>> continuationStores;
  for(auto *block:scope) for(auto &instruction:*block) {
    if(preservedLoop&&block!=l.entry&&block!=r.entry)continue;
    if(auto *call=dyn_cast<CallBase>(&instruction))
      if(call->isConvergent()) return reject("convergent_call_in_trial_scope");
    if (darmReplication && instruction.mayReadOrWriteMemory()) {
      auto *load = dyn_cast<LoadInst>(&instruction);
      auto *store = dyn_cast<StoreInst>(&instruction);
      const bool darmBlockSide = block == (leftRequired ? l.entry : r.entry);
      const bool regionSide = (leftRequired ? rs : ls).count(block);
      if ((!darmBlockSide && !regionSide) ||
          !((load && load->isSimple()) || (store && store->isSimple()))) {
        raw_string_ostream detail(t.localRejectReason);
        block->printAsOperand(detail, false);
        detail << ": " << instruction;
        return reject("unsupported_replicated_memory_access");
      }
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
    if(l.region && !l.blocks.count(block) && !r.blocks.count(block))
      if(auto *store=dyn_cast<StoreInst>(&instruction))
        if(store->isSimple()){
          continuationStores[block].emplace_back(store);
          continue;
        }
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
    if (!matchedBlock(block) && !logical &&
        guardsUnsafeWork && !preservedLoop && !instruction.isTerminator()) {
      if (auto *store = dyn_cast<StoreInst>(&instruction)) {
        if (store->isSimple()) {
          auditRetainedEffects = true;
          continue;
        }
        return recordEffect(instruction, "nonordinary_store_cannot_be_preserved");
      }
      auditRetainedEffects = true;
      continue;
    }
    return recordEffect(instruction, "matched_effect_has_no_guarded_lowering");
  }
  if (auditRetainedEffects) {
    // The path audit tracks retained accesses by instruction identity. It
    // cannot prove their order relative to a load that the melder replaces.
    for (auto *block : scope)
      if (matchedBlock(block))
        for (auto &instruction : *block)
          if (instruction.mayReadOrWriteMemory())
            return recordEffect(instruction, "retained_effect_memory_order_unproven");
    // Include reads so the audit checks relative access order as well as the
    // execution condition of each retained effect.
    downstream.clear();
    auto retainedScope = scope;
    retainedScope.insert(split);
    for (auto *block : retainedScope) {
      if (matchedBlock(block)) continue;
      for (auto &instruction : *block) {
        if (instruction.isTerminator() ||
            !(instruction.mayReadOrWriteMemory() || instruction.mayHaveSideEffects()))
          continue;
        DownstreamAccess access{&instruction, block, {}};
        for (auto &operand : instruction.operands())
          access.operands.emplace_back(operand.get());
        downstream.push_back(std::move(access));
      }
    }
    downstreamWrite = true;
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
  // Validate ordinary accesses in the matched blocks. The emitter can
  // preserve unmatched accesses in guarded gaps, including within an R2R.
  if (!regionStores.empty())
    for (const auto &blocks : memoryBlocks)
      for (auto *block : {blocks.first, blocks.second})
        for (auto &instruction : *block)
          if (instruction.mayReadOrWriteMemory() &&
              !regionStores.count(dyn_cast<StoreInst>(&instruction)) &&
              !(isa<LoadInst>(instruction) && cast<LoadInst>(instruction).isSimple()))
            return reject("region_store_memory_sequence_mismatch");
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
  AdjacentLeafEntry leafEntry;
  bool directLeaves=!downstreamWrite&&regionStores.empty()&&bool(l.region)==bool(r.region)&&l.exit&&l.exit==r.exit&&leafEntry.prepare(l.entry,r.entry,a.dt,a.loops,bool(l.region));
  const bool guardedB2R = b2rStrategy == B2RStrategy::Guarded &&
                          (t.planKind == "B2R" || t.planKind == "R2B");
  t.mergePath=directLeaves?(l.region?"darm-adjacent-R2R":"darm-adjacent-B2B"):(guardedB2R?"guarded-":"darm-")+t.planKind;
  if(!directLeaves&&(t.planKind=="B2R"||t.planKind=="R2B")){
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
  std::map<std::string,std::string> others;for(auto&g:*t.raw)if(&g!=f)others[g.getName().str()]=isolatedFunctionText(g);
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
  if (!allowB2B && t.planKind == "B2B") return reject("dp1_b2b_layout_unavailable");
  RegionMelder melder(directLeaves?*leafAnalyzer:ma,true);
  if(t.logicalState)melder.onValueMapping=[&](const ValueToValueMapTy &m){t.logicalState->transfer(m);};
  {
    if(!regionStores.empty()){

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
    }
    // Empty replica blocks carry no accesses from the opposite arm.
    // Guard unsafe gaps that the other side could reach. Keep conditional
    // stores on their original path without an old-value load or writeback.
    melder.GuardReplicatedMemory = guardedB2R && t.replication;
    melder.NativeReplicationPredication =
        darmReplication && t.replication && !melder.GuardReplicatedMemory;
    try { melder.merge(0); }
    catch(const std::exception &error) { return reject(error.what()); }
  }
  canonicalPhiOrder(*t.raw,c.function);t.mergeMs=millis(mt);
  for(const auto &entry:continuationStores){
    Instruction *previous=nullptr;
    for(const auto &saved:entry.second){
      auto *store=dyn_cast_or_null<StoreInst>((Value*)saved);
      if(!store||store->getParent()!=entry.first||
         (previous&&!previous->comesBefore(store)))
        return reject("region_continuation_store_changed");
      previous=store;
    }
  }
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
  for(auto&g:*t.raw)if(&g!=f)if(!others.count(g.getName().str())||others.at(g.getName().str())!=isolatedFunctionText(g))return reject("other_function_changed");
  ft=Clock::now();t.afterRaw=features(*f);t.featuresMs+=millis(ft);if(t.afterRaw.loops>t.before.loops)return reject("new_raw_loop");
  auto blockLabel=[](const Value *V){std::string S;raw_string_ostream O(S);V->printAsOperand(O,false);O.flush();return S;};
  std::set<BasicBlock*> oldBlocks,rawCreated;
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
  // Do not retain CloneMap's tracking handles while cleanup mutates the clone.
  CloneMap.clear();
  t.cleanupIterations=cleanup(*t.normalized,c.function,mode);canonicalPhiOrder(*t.normalized,c.function);t.normalizeMs=millis(nt);
  for(size_t I=0;I<CleanedBlocks.size();++I)if(Value *V=CleanedBlocks[I])
    t.blockProvenance[I].cleanedBlock=blockLabel(V);
  if(verifyModule(*t.normalized,&errs()))return reject("normalized_verifier_failed");
  auto*after=t.normalized->getFunction(c.function);if(!after||after->isDeclaration())return reject("target_lost_after_normalization");
  ft=Clock::now();t.after=features(*after);t.featuresMs+=millis(ft);if(t.after.loops>t.before.loops)return reject("new_normalized_loop");
  if(t.logicalState){if(!t.logicalState->stageMerge(c))return reject("logical_state_candidate_mismatch");t.logicalState->rebind(*after);}
  finishSides(after);
  t.valid=true;t.reason="verified_ir_only";t.totalMs=millis(started);
  if (boundaryFold && guardedB2R && t.replication && !logical) {
    auto startFold = Clock::now();
    Trial alternate;
    alternate.raw = CloneModule(*t.normalized);
    auto &target = *alternate.raw->getFunction(c.function);
    std::string sideError;
    auto *trialSide = findSideCondition(target, sideError);
    if (!trialSide) return t;
    DominatorTree dt(target);
    for (auto &block : target) {
      if (!foldGuardedReadBoundary(block, trialSide, dt)) continue;
      if (verifyModule(*alternate.raw)) break;
      canonicalPhiOrder(*alternate.raw, c.function);
      alternate.afterRaw = features(target);
      alternate.normalized = CloneModule(*alternate.raw);
      alternate.cleanupIterations = cleanup(*alternate.normalized, c.function, mode);
      canonicalPhiOrder(*alternate.normalized, c.function);
      if (verifyModule(*alternate.normalized)) break;
      auto &finalTarget = *alternate.normalized->getFunction(c.function);
      alternate.after = features(finalTarget);
      if (alternate.afterRaw.loops > t.before.loops || alternate.after.loops > t.before.loops) break;
      alternate.cleanupMode = mode;
      alternate.candidate = c;
      alternate.before = t.before;
      alternate.left = t.left;
      alternate.right = t.right;
      alternate.leftContext = t.leftContext;
      alternate.rightContext = t.rightContext;
      alternate.planKind = t.planKind;
      alternate.matchedLeft = t.matchedLeft;
      alternate.matchedRight = t.matchedRight;
      alternate.replication = true;
      alternate.swapped = t.swapped;
      alternate.loopHeaderSplit = t.loopHeaderSplit;
      alternate.originalSimilarity = t.originalSimilarity;
      alternate.originalProfitable = t.originalProfitable;
      alternate.sideBeforeOk = t.sideBeforeOk;
      for (unsigned side : {0u, 1u}) alternate.sideBefore[side] = t.sideBefore[side];
      std::string why;
      if (auto *condition = findSideCondition(finalTarget, why))
        alternate.sideAfterOk = sideBlocksBoth(finalTarget, condition, alternate.sideAfter, why);
      alternate.sideReason = alternate.sideAfterOk ? t.sideReason : why;
      alternate.mergePath = t.mergePath + "-boundary-fold";
      alternate.valid = alternate.rewriteStarted = true;
      alternate.reason = "verified_ir_only";
      alternate.totalMs = millis(startFold);
      *boundaryFold = std::move(alternate);
      break;
    }
  }
  return t;
}
// A direct diamond can share arithmetic before the original split or after
// both arms. Keeping the arm blocks intact preserves their execution domains
// and the order of all memory accesses.
using B2BMatch = std::pair<Instruction *, Instruction *>;

static bool isB2BPureOperation(Instruction &inst) {
  return (isa<BinaryOperator>(inst) || isa<UnaryOperator>(inst) ||
          isa<CastInst>(inst) || isa<CmpInst>(inst) || isa<SelectInst>(inst) ||
          isa<GetElementPtrInst>(inst)) &&
      !inst.hasMetadataOtherThanDebugLoc() && safeToExecuteUnconditionally(inst);
}

static bool compatibleB2BArithmetic(Instruction &left, Instruction &right) {
  return left.isSameOperationAs(&right) &&
      left.getRawSubclassOptionalData() == right.getRawSubclassOptionalData() &&
      isB2BPureOperation(left) && isB2BPureOperation(right);
}

// Align independently hoistable computations. Skipping an instruction
// leaves it in its original arm, including all memory accesses.
static SmallVector<B2BMatch, 8> alignHoistableB2B(
    BasicBlock &left, BasicBlock &right, BranchInst &split, DominatorTree &dt) {
  auto collect = [&](BasicBlock &arm) {
    SmallVector<Instruction *, 16> result;
    for (auto &inst : arm) {
      if (!isa<BinaryOperator>(inst) || inst.use_empty() ||
          inst.hasMetadataOtherThanDebugLoc() || !safeToExecuteUnconditionally(inst))
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

// These direct intrinsics support ordered B2B pairing and guarded emission.
static bool isB2BPairableIntrinsic(const Instruction &inst) {
  const auto *call = dyn_cast<CallInst>(&inst);
  if (!call || call->hasOperandBundles() || call->isConvergent() ||
      call->isMustTailCall() || !call->doesNotThrow())
    return false;
  const auto *callee = call->getCalledFunction();
  if (!callee || !callee->isIntrinsic()) return false;
  StringRef name = callee->getName();
  if (name == "llvm.amdgcn.image.sample.lz.3d.f32.f32")
    return call->onlyReadsMemory();
  return !call->getType()->isVoidTy() && !call->getType()->isTokenTy() &&
         call->doesNotAccessMemory() && call->hasFnAttr(Attribute::WillReturn) &&
         callee->hasFnAttribute(Attribute::Speculatable);
}

static int b2bWeight(const Instruction &inst,
                     function_ref<int(const Instruction &)> intrinsicCost) {
  if (isB2BPairableIntrinsic(inst)) return intrinsicCost ? intrinsicCost(inst) : 1;
  return fusionInstructionWeight(inst);
}

static bool compatibleB2BPrefix(Instruction &left, Instruction &right) {
    if (compatibleB2BArithmetic(left, right)) return true;
    if (isB2BPairableIntrinsic(left) && isB2BPairableIntrinsic(right)) {
      const auto &l = cast<CallInst>(left);
      const auto &r = cast<CallInst>(right);
      if (l.getCalledFunction() != r.getCalledFunction() ||
          !left.isSameOperationAs(&right) ||
          left.getRawSubclassOptionalData() != right.getRawSubclassOptionalData() ||
          l.getAttributes() != r.getAttributes() ||
          left.hasMetadataOtherThanDebugLoc() || right.hasMetadataOtherThanDebugLoc())
        return false;
      for (unsigned i = 0; i < l.arg_size(); ++i)
        if (l.paramHasAttr(i, Attribute::ImmArg) &&
            l.getArgOperand(i) != r.getArgOperand(i))
          return false;
      return true;
    }
    const auto simpleMemory = [](const Instruction &inst) {
      if (auto *load = dyn_cast<LoadInst>(&inst)) return load->isSimple();
      if (auto *store = dyn_cast<StoreInst>(&inst)) return store->isSimple();
      return false;
    };
    if (!simpleMemory(left) || !simpleMemory(right) ||
        !left.isSameOperationAs(&right))
      return false;
    SmallVector<std::pair<unsigned, MDNode *>, 4> lm, rm;
    left.getAllMetadataOtherThanDebugLoc(lm);
    right.getAllMetadataOtherThanDebugLoc(rm);
    return lm == rm;
}

// Search common work and work kept on either original arm together. Two
// states at the same cursors can resolve different pairs of SSA operands.
static SmallVector<B2BMatch, 8> searchB2BCommon(
    BasicBlock &left, BasicBlock &right, BranchInst &split, DominatorTree &dt,
    bool completeCommon = false,
    SmallVectorImpl<SmallVector<B2BMatch, 8>> *finalists = nullptr,
    bool prioritizeMatches = false,
    function_ref<int(const Instruction &)> intrinsicCost = nullptr) {
  SmallVector<Instruction *, 16> l, r;
  for (auto &inst : left) if (!inst.isTerminator()) l.push_back(&inst);
  for (auto &inst : right) if (!inst.isTerminator()) r.push_back(&inst);
  const size_t columns = r.size() + 1;
  if (l.empty() || r.empty() || l.size() + 1 > 4096 / columns) return {};

  if (completeCommon && l.size() != r.size()) return {};
  auto canMakeCommon = [&](Instruction *inst) {
    // An intrinsic can require Match even when it cannot take a Spec edge.
    // The DP only consumes both cursors if the actual pair is compatible.
    return compatibleB2BArithmetic(*inst, *inst) ||
           (intrinsicCost && isB2BPairableIntrinsic(*inst) && !inst->mayReadOrWriteMemory());
  };
  if (completeCommon && (!llvm::all_of(l, canMakeCommon) || !llvm::all_of(r, canMakeCommon)))
    return {};

  struct State {
    SmallVector<B2BMatch, 8> pairs;
    SmallVector<std::pair<Value *, Value *>, 8> selects;
    int benefit = 0;
    bool forked = false;
  };
  using Bucket = SmallVector<State, 4>;
  std::vector<Bucket> table((l.size() + 1) * columns);
  auto at = [&](size_t i, size_t j) -> Bucket & { return table[i * columns + j]; };
  at(0, 0).emplace_back();
  auto insert = [completeCommon](Bucket &bucket, State state) {
    if (llvm::any_of(bucket, [&](const State &old) {
          if (old.forked != state.forked) return false;
          if (!completeCommon) return old.pairs == state.pairs;
          auto matched = [](const B2BMatch &step) { return step.first && step.second; };
          auto a = llvm::make_filter_range(old.pairs, matched);
          auto b = llvm::make_filter_range(state.pairs, matched);
          return std::equal(a.begin(), a.end(), b.begin(), b.end());
        }))
      return;
    auto pos = llvm::find_if(bucket, [&](const State &old) {
      return state.benefit > old.benefit;
    });
    bucket.insert(pos, std::move(state));
    if (bucket.size() > 8) bucket.pop_back();
  };
  auto available = [&](const State &state, Value *value, bool leftSide) {
    auto *def = dyn_cast<Instruction>(value);
    return !def || dt.dominates(def, &split) ||
        llvm::any_of(state.pairs, [&](const B2BMatch &step) {
          return (leftSide ? step.first : step.second) == def;
        });
  };
  for (size_t i = 0; i <= l.size(); ++i)
    for (size_t j = 0; j <= r.size(); ++j)
      for (const auto &state : at(i, j)) {
        State side = state;
        side.forked = true;
        if (i < l.size()) {
          if (!completeCommon) insert(at(i + 1, j), side);
        }
        if (j < r.size()) {
          if (!completeCommon) insert(at(i, j + 1), std::move(side));
        }
        if (i == l.size() || j == r.size()) continue;
        auto *li = l[i], *ri = r[j];
        if (!compatibleB2BPrefix(*li, *ri) ||
            (state.forked && li->mayReadOrWriteMemory()))
          continue;
        State shared = state;
        int benefit = prioritizeMatches ? 1 : b2bWeight(*li, intrinsicCost);
        bool legal = true;
        for (unsigned n = 0; n < li->getNumOperands(); ++n) {
          auto *lv = li->getOperand(n), *rv = ri->getOperand(n);
          if (llvm::any_of(state.pairs, [&](const B2BMatch &pair) {
                return pair.first == lv && pair.second == rv;
              }))
            continue;
          legal &= available(state, lv, true) && available(state, rv, false);
          if (lv != rv && !llvm::is_contained(shared.selects, std::make_pair(lv, rv))) {
            shared.selects.emplace_back(lv, rv);
            if (!prioritizeMatches) --benefit;
          }
        }
        if (!legal) continue;
        shared.pairs.emplace_back(li, ri);
        shared.benefit += benefit;
        insert(at(i + 1, j + 1), std::move(shared));
      }
  for (const auto &state : at(l.size(), r.size()))
    if (completeCommon || llvm::any_of(state.pairs, [](const B2BMatch &step) {
          return step.first && step.second;
        })) {
      if (!finalists) return state.pairs;
      finalists->push_back(state.pairs);
      if (finalists->size() == 4 || prioritizeMatches) break;
    }
  return {};
}

template <typename ArmRange>
static SmallVector<B2BMatch, 8> commonB2BPrefix(ArmRange &&left, ArmRange &&right,
                                                BranchInst &split, DominatorTree &dt) {
  SmallVector<B2BMatch, 8> result;
  DenseMap<Value *, Value *> earlier;
  auto l = left.begin(), r = right.begin();
  while (l != left.end() && r != right.end() && compatibleB2BPrefix(*l, *r)) {
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

// A sunk value can be used only by a later sunk instruction or on
// its original join PHI edge. Both operands must move together.
static bool canSinkB2BPair(Instruction &left, Instruction &right, BasicBlock &join,
                           ArrayRef<B2BMatch> later) {
  if (!compatibleB2BArithmetic(left, right)) return false;
  for (auto *inst : {&left, &right})
    for (const auto &use : inst->uses()) {
      if (llvm::any_of(later, [&](B2BMatch pair) {
            return use.getUser() == (inst == &left ? pair.first : pair.second);
          }))
        continue;
      auto *phi = dyn_cast<PHINode>(use.getUser());
      if (!phi || phi->getParent() != &join ||
          phi->getIncomingBlock(use) != inst->getParent())
        return false;
    }
  for (auto [l, r] : later)
    for (unsigned n = 0; n < l->getNumOperands(); ++n)
      if ((l->getOperand(n) == &left) != (r->getOperand(n) == &right))
        return false;
  for (auto &phi : join.phis())
    if ((phi.getIncomingValueForBlock(left.getParent()) == &left) !=
        (phi.getIncomingValueForBlock(right.getParent()) == &right))
      return false;
  return true;
}

static SmallVector<B2BMatch, 8> commonB2BSuffix(BasicBlock &left, BasicBlock &right,
                                                BasicBlock &join) {
  SmallVector<B2BMatch, 8> result;
  auto l = left.rbegin(), r = right.rbegin();
  while (++l != left.rend() && ++r != right.rend() &&
         canSinkB2BPair(*l, *r, join, result))
    result.emplace_back(&*l, &*r);
  std::reverse(result.begin(), result.end());
  return result;
}

// Work backwards from the exit so a match is sinkable once every use is
// either paired in the common continuation or on its original PHI edge.
static SmallVector<SmallVector<B2BMatch, 8>, 4> searchB2BJoin(
    BasicBlock &left, BasicBlock &right, BasicBlock &join,
    unsigned finalistsLimit = 4,
    function_ref<int(const Instruction &)> intrinsicCost = nullptr) {
  SmallVector<Instruction *, 16> l, r;
  for (auto &inst : llvm::reverse(left)) if (!inst.isTerminator()) l.push_back(&inst);
  for (auto &inst : llvm::reverse(right)) if (!inst.isTerminator()) r.push_back(&inst);
  const size_t columns = r.size() + 1;
  if (l.empty() || r.empty() || l.size() + 1 > 4096 / columns) return {};
  struct State {
    SmallVector<B2BMatch, 8> pairs;
    int benefit = 0;
  };
  using Bucket = SmallVector<State, 4>;
  std::vector<Bucket> table((l.size() + 1) * columns);
  auto at = [&](size_t i, size_t j) -> Bucket & { return table[i * columns + j]; };
  auto insert = [](Bucket &bucket, const State &state) {
    if (llvm::any_of(bucket, [&](const State &old) { return old.pairs == state.pairs; }))
      return;
    auto pos = llvm::find_if(bucket, [&](const State &old) {
      return old.benefit < state.benefit;
    });
    bucket.insert(pos, state);
    if (bucket.size() > 8) bucket.pop_back();
  };
  at(0, 0).emplace_back();
  for (size_t i = 0; i <= l.size(); ++i)
    for (size_t j = 0; j <= r.size(); ++j)
      for (const auto &state : at(i, j)) {
        if (i < l.size()) insert(at(i + 1, j), state);
        if (j < r.size()) insert(at(i, j + 1), state);
        if (i == l.size() || j == r.size()) continue;
        auto *li = l[i], *ri = r[j];
        if (!canSinkB2BPair(*li, *ri, join, state.pairs)) continue;
        State shared = state;
        shared.pairs.emplace_back(li, ri);
        // The emitter reuses a PHI for repeated ordered operand pairs. Charge
        // each once and subtract the transfers already needed at the exit.
        std::set<std::pair<Value *, Value *>> transfers, originalExits;
        auto charge = [&](Value *lv, Value *rv) {
          if (lv != rv && !llvm::any_of(shared.pairs, [&](const B2BMatch &pair) {
                return pair.first == lv && pair.second == rv;
              }))
            transfers.emplace(lv, rv);
        };
        shared.benefit = 0;
        for (const auto &pair : shared.pairs) {
          shared.benefit += b2bWeight(*pair.first, intrinsicCost);
          for (unsigned n = 0; n < pair.first->getNumOperands(); ++n)
            charge(pair.first->getOperand(n), pair.second->getOperand(n));
        }
        for (auto &phi : join.phis()) {
          auto *lv = phi.getIncomingValueForBlock(&left);
          auto *rv = phi.getIncomingValueForBlock(&right);
          if (lv != rv) originalExits.emplace(lv, rv);
          charge(lv, rv);
        }
        shared.benefit += int(originalExits.size()) - int(transfers.size());
        insert(at(i + 1, j + 1), shared);
      }
  SmallVector<SmallVector<B2BMatch, 8>, 4> finalists;
  for (auto &state : at(l.size(), r.size()))
    if (!state.pairs.empty()) {
      std::reverse(state.pairs.begin(), state.pairs.end());
      finalists.push_back(std::move(state.pairs));
      if (finalists.size() == finalistsLimit) break;
    }
  return finalists;
}

// Each action consumes at least one cursor. Side actions commute across arms,
// so the state records their ordered instruction ranges only through cursors
// and the positions of the shared actions.
struct B2BSegmentMatch {
  unsigned left, right;
  bool consumeLeft = true, consumeRight = true;
  bool operator==(const B2BSegmentMatch &other) const {
    return left == other.left && right == other.right &&
        consumeLeft == other.consumeLeft && consumeRight == other.consumeRight;
  }
};

using B2BSegmentedPlan = SmallVector<B2BSegmentMatch, 8>;

static SmallVector<B2BSegmentedPlan, 4>
searchB2BSegments(ArrayRef<Instruction *> left, ArrayRef<Instruction *> right,
                  bool independentExits, unsigned minSegments,
                  function_ref<int(const Instruction &)> intrinsicCost,
                  unsigned limit = 32, bool deduplicateSelects = false) {
  const size_t columns = right.size() + 1;
  if (left.empty() || right.empty() || left.size() + 1 > 4096 / columns)
    return {};
  struct State {
    SmallVector<B2BSegmentMatch, 8> matches;
    int benefit = 0;
    SmallVector<std::pair<Value *, Value *>, 8> selects;
  };
  using Beam = SmallVector<State, 4>;
  std::vector<std::array<Beam, 2>> table((left.size() + 1) * columns);
  auto at = [&](unsigned i, unsigned j, bool forked) -> Beam & {
    return table[i * columns + j][forked];
  };
  at(0, 0, false).emplace_back();
  constexpr size_t dp1LabelLimit = 32;
  auto insert = [&](unsigned i, unsigned j, bool forked, State state) {
    auto &beam = at(i, j, forked);
    if (llvm::any_of(beam, [&](const State &old) { return old.matches == state.matches; }))
      return;
    auto pos = llvm::find_if(beam, [&](const State &old) {
      return state.benefit > old.benefit;
    });
    beam.insert(pos, std::move(state));
    if (beam.size() > dp1LabelLimit) beam.pop_back();
  };
  for (unsigned i = 0; i <= left.size(); ++i)
    for (unsigned j = 0; j <= right.size(); ++j)
      for (bool forked : {false, true})
        for (const auto &state : at(i, j, forked)) {
          if (i < left.size() || j < right.size()) {
            State side = state;
            side.benefit -= !forked ? 2 : 0;
            if (i < left.size()) insert(i + 1, j, true, side);
            if (j < right.size()) insert(i, j + 1, true, std::move(side));
          }
          if (i == left.size() || j == right.size() ||
              !compatibleB2BPrefix(*left[i], *right[j]))
            continue;
          State shared = state;
          shared.benefit += b2bWeight(*left[i], intrinsicCost);
          for (unsigned n = 0; n < left[i]->getNumOperands(); ++n) {
            auto *lv = left[i]->getOperand(n);
            auto *rv = right[j]->getOperand(n);
            if (lv != rv && !llvm::any_of(state.matches, [&](B2BSegmentMatch match) {
                  return match.consumeLeft && match.consumeRight &&
                      left[match.left] == lv && right[match.right] == rv;
                })) {
              auto operands = std::make_pair(lv, rv);
              if (!deduplicateSelects || !llvm::is_contained(shared.selects, operands)) {
                --shared.benefit;
                if (deduplicateSelects) shared.selects.push_back(operands);
              }
            }
          }
          shared.matches.push_back({i, j});
          insert(i + 1, j + 1, false, std::move(shared));
        }
  SmallVector<const State *, 8> finalists;
  for (bool forked : {false, true})
    for (const auto &state : at(left.size(), right.size(), forked)) {
      if (state.matches.empty()) continue;
      unsigned segments = 0, i = 0, j = 0;
      for (auto match : state.matches) {
        segments += (i != match.left || j != match.right);
        i = match.left + match.consumeLeft;
        j = match.right + match.consumeRight;
      }
      segments += (i != left.size() || j != right.size());
      if (!independentExits && segments < minSegments) continue;
      finalists.push_back(&state);
    }
  llvm::stable_sort(finalists, [](const State *a, const State *b) {
    return a->benefit > b->benefit;
  });
  SmallVector<B2BSegmentedPlan, 4> plans;
  for (const auto *state : finalists) {
    if (llvm::is_contained(plans, state->matches)) continue;
    plans.push_back(state->matches);
    if (plans.size() == limit) break;
  }
  return plans;
}

// Both planners use the same continuation lowering. Resolving a value here
// also handles definitions copied into a segmented arm before the join.
static void emitB2BSuffix(BasicBlock &block, BasicBlock &join,
                          BasicBlock &left, BasicBlock &right,
                          BasicBlock &leftPred, BasicBlock &rightPred,
                          ArrayRef<B2BMatch> matches,
                          function_ref<Value *(unsigned, Value *)> resolve,
                          function_ref<Value *(Value *, Value *)> select = nullptr) {
  auto *exit = block.getTerminator();
  std::map<std::pair<Value *, Value *>, Value *> choices;
  auto mergeValue = [&](Value *lv, Value *rv) -> Value * {
    lv = resolve(0, lv);
    rv = resolve(1, rv);
    if (lv == rv) return lv;
    if (select) return select(lv, rv);
    auto &value = choices[{lv, rv}];
    if (!value) {
      auto *phi = PHINode::Create(lv->getType(), 2, "", &block.front());
      phi->addIncoming(lv, &leftPred);
      phi->addIncoming(rv, &rightPred);
      value = phi;
    }
    return value;
  };
  for (auto [l, r] : matches) {
    auto *shared = l->clone();
    for (unsigned n = 0; n < shared->getNumOperands(); ++n)
      shared->setOperand(n, mergeValue(l->getOperand(n), r->getOperand(n)));
    shared->insertBefore(exit);
    l->replaceAllUsesWith(shared);
    r->replaceAllUsesWith(shared);
    l->eraseFromParent();
    r->eraseFromParent();
  }
  for (auto &phi : join.phis()) {
    auto *incoming = mergeValue(phi.getIncomingValueForBlock(&left),
                                phi.getIncomingValueForBlock(&right));
    phi.removeIncomingValue(&left, false);
    phi.removeIncomingValue(&right, false);
    phi.addIncoming(incoming, &block);
  }
}

static void emitB2BSegments(BranchInst &split, BasicBlock &left,
                            BasicBlock &right, BasicBlock &join,
                            ArrayRef<B2BSegmentMatch> matches, bool resplit,
                            bool independentExits, ArrayRef<B2BMatch> suffix) {
  auto *function = split.getFunction();
  auto &context = function->getContext();
  SmallVector<Instruction *, 16> work[2];
  for (auto &inst : left)
    if (!inst.isTerminator() && llvm::none_of(suffix, [&](B2BMatch pair) { return pair.first == &inst; }))
      work[0].push_back(&inst);
  for (auto &inst : right)
    if (!inst.isTerminator() && llvm::none_of(suffix, [&](B2BMatch pair) { return pair.second == &inst; }))
      work[1].push_back(&inst);
  IRBuilder<> builder(&split);
  Value *condition = split.getCondition();
  // DP1's segmented rewrite stays within the execution domain of the
  // original conditional branch, where its condition must be defined.
  split.eraseFromParent();
  auto *common = builder.GetInsertBlock();
  builder.SetInsertPoint(common);
  DenseMap<Value *, Value *> values[2];
  std::map<std::pair<Value *, Value *>, Value *> selects;
  auto value = [&](unsigned side, Value *original) -> Value * {
    if (auto *mapped = values[side].lookup(original)) return mapped;
    return original;
  };
  BasicBlock *joinedPaths[2] = {};
  auto select = [&](Value *lv, Value *rv) -> Value * {
    if (lv == rv) return lv;
    auto &choice = selects[{lv, rv}];
    if (!choice && joinedPaths[0] && joinedPaths[1]) {
      auto *leftPhi = dyn_cast<PHINode>(lv);
      auto *rightPhi = dyn_cast<PHINode>(rv);
      if (leftPhi && rightPhi && leftPhi->getParent() == common &&
          rightPhi->getParent() == common &&
          leftPhi->getNumIncomingValues() == 2 && rightPhi->getNumIncomingValues() == 2 &&
          leftPhi->getBasicBlockIndex(joinedPaths[0]) >= 0 &&
          leftPhi->getBasicBlockIndex(joinedPaths[1]) >= 0 &&
          rightPhi->getBasicBlockIndex(joinedPaths[0]) >= 0 &&
          rightPhi->getBasicBlockIndex(joinedPaths[1]) >= 0 &&
          isa<PoisonValue>(leftPhi->getIncomingValueForBlock(joinedPaths[1])) &&
          isa<PoisonValue>(rightPhi->getIncomingValueForBlock(joinedPaths[0]))) {
        auto *insertBefore = common->getFirstNonPHI();
        auto *phi = insertBefore
            ? PHINode::Create(lv->getType(), 2, "fusion.paired", insertBefore)
            : PHINode::Create(lv->getType(), 2, "fusion.paired", common);
        phi->addIncoming(leftPhi->getIncomingValueForBlock(joinedPaths[0]), joinedPaths[0]);
        phi->addIncoming(rightPhi->getIncomingValueForBlock(joinedPaths[1]), joinedPaths[1]);
        choice = phi;
      }
    }
    if (!choice) choice = emitB2BSelect(builder, condition, lv, rv);
    return choice;
  };
  unsigned cursor[2] = {};
  auto preserve = [&](unsigned l, unsigned r, BasicBlock *terminal) {
    auto *next = terminal ? terminal :
        BasicBlock::Create(context, "fusion.common", function, &join);
    unsigned end[] = {l, r};
    BasicBlock *paths[] = {common, common};
    for (unsigned side = 0; side < 2; ++side)
      if (cursor[side] != end[side])
        paths[side] = BasicBlock::Create(context, "fusion.side", function, next);
    builder.CreateCondBr(condition, paths[0] == common ? next : paths[0],
                        paths[1] == common ? next : paths[1]);
    unsigned begin[] = {cursor[0], cursor[1]};
    for (unsigned side = 0; side < 2; ++side) {
      if (paths[side] == common) continue;
      builder.SetInsertPoint(paths[side]);
      for (; cursor[side] < end[side]; ++cursor[side]) {
        auto *inst = work[side][cursor[side]];
        auto *copy = inst->clone();
        for (unsigned n = 0; n < inst->getNumOperands(); ++n)
          copy->setOperand(n, value(side, inst->getOperand(n)));
        builder.Insert(copy);
        values[side][inst] = copy;
      }
      builder.CreateBr(next);
    }
    if (terminal) {
      joinedPaths[0] = paths[0];
      joinedPaths[1] = paths[1];
      if (terminal != &join) return;
      for (auto &phi : join.phis()) {
        auto *lv = value(0, phi.getIncomingValueForBlock(&left));
        auto *rv = value(1, phi.getIncomingValueForBlock(&right));
        phi.removeIncomingValue(&left, false);
        phi.removeIncomingValue(&right, false);
        phi.addIncoming(lv, paths[0]);
        phi.addIncoming(rv, paths[1]);
      }
      return;
    }
    for (unsigned side = 0; side < 2; ++side) {
      joinedPaths[side] = paths[side];
    }
    builder.SetInsertPoint(next);
    for (unsigned side = 0; side < 2; ++side)
      for (unsigned n = begin[side]; n < end[side]; ++n) {
        auto *inst = work[side][n];
        if (inst->getType()->isVoidTy() || llvm::all_of(inst->users(), [&](User *user) {
              return llvm::is_contained(
                  ArrayRef<Instruction *>(work[side]).slice(begin[side], end[side] - begin[side]),
                  user);
            }))
          continue;
        auto *phi = builder.CreatePHI(inst->getType(), 2);
        phi->addIncoming(values[side].lookup(inst), paths[side]);
        phi->addIncoming(PoisonValue::get(inst->getType()), paths[1 - side]);
        values[side][inst] = phi;
      }
    common = next;
  };
  for (auto match : matches) {
    if (cursor[0] != match.left || cursor[1] != match.right)
      preserve(match.left, match.right, nullptr);
    auto consume = [&](unsigned side, unsigned index) {
      auto *inst = work[side][index];
      ++cursor[side];
      return inst;
    };
    auto *l = consume(0, match.left);
    auto *r = consume(1, match.right);
    auto *shared = l->clone();
    for (unsigned n = 0; n < shared->getNumOperands(); ++n) {
      auto *lv = value(0, l->getOperand(n));
      auto *rv = value(1, r->getOperand(n));
      shared->setOperand(n, select(lv, rv));
    }
    builder.Insert(shared);
    values[0][l] = values[1][r] = shared;
  }
  const bool pending = cursor[0] != work[0].size() || cursor[1] != work[1].size();
  if (independentExits) {
    if (pending) preserve(work[0].size(), work[1].size(), nullptr);
    builder.CreateCondBr(condition, &left, &right);
    // The original terminators and outgoing edges remain in place, including
    // the incoming labels of successor PHIs.
    for (unsigned side = 0; side < 2; ++side) {
      for (auto *inst : work[side])
        if (!inst->use_empty())
          inst->replaceAllUsesWith(values[side].lookup(inst));
      for (auto *inst : llvm::reverse(work[side]))
        inst->eraseFromParent();
    }
    return;
  }
  if (!suffix.empty()) {
    auto *tail = BasicBlock::Create(context, "fusion.suffix", function, &join);
    if (pending) preserve(work[0].size(), work[1].size(), tail);
    else builder.CreateBr(tail);
    auto *exit = BranchInst::Create(&join, tail);
    // With no terminal fork, both operand streams already dominate the
    // continuation. Insert choices before the tail instructions.
    builder.SetInsertPoint(exit);
    emitB2BSuffix(*tail, join, left, right, pending ? *joinedPaths[0] : *common,
                  pending ? *joinedPaths[1] : *common, suffix, value,
                  pending ? function_ref<Value *(Value *, Value *)>() : select);
  } else if (pending) {
    preserve(work[0].size(), work[1].size(), &join);
  } else if (resplit) {
    auto *rightExit = BasicBlock::Create(context, "fusion.exit", function, &join);
    builder.CreateCondBr(condition, &join, rightExit);
    BranchInst::Create(&join, rightExit);
    for (auto &phi : join.phis()) {
      auto *lv = value(0, phi.getIncomingValueForBlock(&left));
      auto *rv = value(1, phi.getIncomingValueForBlock(&right));
      phi.removeIncomingValue(&left, false);
      phi.removeIncomingValue(&right, false);
      phi.addIncoming(lv, common);
      phi.addIncoming(rv, rightExit);
    }
  } else {
    unsigned index = 0;
    for (auto &phi : join.phis()) {
      auto *lo = phi.getIncomingValueForBlock(&left);
      auto *ro = phi.getIncomingValueForBlock(&right);
      auto *lv = value(0, lo);
      auto *rv = value(1, ro);
      auto *incoming = select(lv, rv);
      ++index;
      phi.removeIncomingValue(&left, false);
      phi.removeIncomingValue(&right, false);
      phi.addIncoming(incoming, common);
    }
    builder.CreateBr(&join);
  }
  left.dropAllReferences();
  right.dropAllReferences();
  left.eraseFromParent();
  right.eraseFromParent();
}

std::vector<Trial> planSingleBranchB2B(const Module &parent, const Candidate &c,
                                       unsigned level, CleanupMode mode,
                                       StringRef replay,
                                       function_ref<int(const Instruction &)> intrinsicCost,
                                       json::Object *recipeOut, const json::Object *recipeIn,
                                       B2BPlanner planner) {
  const bool unified = planner == B2BPlanner::Unified;
  const StringRef plannerName = unified ? "unified" : "legacy";
  ProfileScope planningScope("b2b_plan_generate_clean_total");
  std::vector<Trial> trials;
  const auto parentIdentity = moduleHash(parent);
  if (recipeIn && (recipeIn->getString("schema") != Optional<StringRef>("b2b-recipe-v4") ||
                   recipeIn->getString("planner") != Optional<StringRef>(plannerName) ||
                   recipeIn->getInteger("opt_level") != Optional<int64_t>(level)))
    throw std::runtime_error("b2b_recipe_certificate_mismatch");
  if (!usesDarmDCE(mode))
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
  const bool siblingArms = originalBranch->getSuccessor(0) == blocks[1] &&
                           originalBranch->getSuccessor(1) == blocks[2];
  const auto *originalJoin = blocks[1]->getSingleSuccessor();
  const bool independentExits =
      !originalJoin || originalJoin == blocks[0] || originalJoin == blocks[1] ||
      originalJoin == blocks[2] || blocks[2]->getSingleSuccessor() != originalJoin;

  Trial trial;
  trial.candidate = c;
  trial.cleanupMode = mode;
  ValueToValueMapTy inputMap;
  trial.raw = profileCall("clone_parent",[&](){return CloneModule(parent, inputMap);});
  auto *f = trial.raw->getFunction(c.function);
  if (profileCall("verify",[&](){return verifyModule(*trial.raw, &errs());})) return trials;
  auto *split = cast<BasicBlock>(inputMap[blocks[0]]);
  auto *left = cast<BasicBlock>(inputMap[blocks[1]]);
  auto *right = cast<BasicBlock>(inputMap[blocks[2]]);
  auto *join = independentExits ? nullptr : cast<BasicBlock>(inputMap[originalJoin]);
  trial.swapped = swapped;
  if (!siblingArms) {
    DominatorTree entryDT(*f);
    LoopInfo entryLoops(entryDT);
    AdjacentLeafEntry entry;
    if (!entry.prepare(left, right, entryDT, entryLoops, false) || entry.first != split)
      return trials;
    trial.swapped ^= left != entry.left;
    left = entry.left;
    right = entry.right;
    split = entry.apply();
    if (verifyFunction(*f, &errs())) return trials;
  }
  auto *branch = cast<BranchInst>(split->getTerminator());
  inputMap.clear();
  DominatorTree dt(*f);
  if (join && dt.dominates(join, split)) return trials;
  LoopInfo loops(dt);
  for (auto *arm : {left, right}) {
    auto *exit = dyn_cast<BranchInst>(arm->getTerminator());
    if (!exit || (!independentExits && !exit->isUnconditional()) ||
        arm->getSinglePredecessor() != split ||
        arm->hasAddressTaken() || !arm->phis().empty() ||
        loops.getLoopFor(arm) != loops.getLoopFor(split))
      return trials;
    for (auto &inst : *arm) {
      if (inst.isTerminator() || isB2BPairableIntrinsic(inst)) continue;
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
  SmallVector<Instruction *, 16> segmentWork[2];
  bool segmentUsesValid = true;
  unsigned sideIndex = 0;
  for (auto *arm : {left, right}) {
    for (auto &inst : *arm) {
      if (inst.isTerminator()) continue;
      segmentWork[sideIndex].push_back(&inst);
      for (const auto &use : inst.uses()) {
        auto *user = cast<Instruction>(use.getUser());
        auto *phi = dyn_cast<PHINode>(user);
        segmentUsesValid &= user->getParent() == arm ||
            (phi && phi->getParent() == join && phi->getIncomingBlock(use) == arm);
      }
    }
    ++sideIndex;
  }

  // Complete inputs to the current deterministic layout planners. This is a
  // planning certificate only: cleanup outcomes and TTI scores are NOT covered.
  // Record predicate outcomes rather than guessing how far LLVM's safety or
  // dominance queries inspect outside the arms. Recompute them on current IR.
  std::string plannerFacts;
  raw_string_ostream facts(plannerFacts);
  facts << "dp1-layout-facts-v1 " << independentExits << ' ' << segmentUsesValid
        << ' ' << bool(join) << ' ' << segmentWork[0].size() << ' '
        << segmentWork[1].size() << '\n';
  std::map<const Value *, unsigned> factIDs;
  auto factID = [&](const Value *value) {
    auto found = factIDs.find(value);
    if (found != factIDs.end()) return found->second;
    unsigned id = factIDs.size(); factIDs.emplace(value, id); return id;
  };
  for (auto &side : segmentWork) for (auto *inst : side) factID(inst);
  for (unsigned side = 0; side != 2; ++side) {
    auto *arm = side ? right : left;
    for (auto *inst : segmentWork[side]) {
      facts << "I " << factID(inst) << ' ' << isa<BinaryOperator>(inst) << ' '
            << isa<StoreInst>(inst) << ' ' << inst->mayReadOrWriteMemory() << ' '
            << inst->use_empty() << ' ' << inst->hasMetadataOtherThanDebugLoc() << ' '
            << safeToExecuteUnconditionally(*inst) << ' '
            << (compatibleB2BArithmetic(*inst,*inst) ||
                (intrinsicCost && isB2BPairableIntrinsic(*inst) && !inst->mayReadOrWriteMemory()))
            << ' ' << b2bWeight(*inst,intrinsicCost) << ' '
            << fusionInstructionWeight(*inst) << ' ' << inst->getNumOperands() << ':';
      for (auto &operand : inst->operands()) {
        auto *def = dyn_cast<Instruction>(operand.get());
        facts << factID(operand.get()) << '/' << (!def || dt.dominates(def,branch)) << ',';
      }
      facts << " uses:";
      // Uses matter only through membership in a paired local instruction or
      // a PHI at the join carrying this value on its original incoming edge.
      for (const auto &use : inst->uses()) {
        auto *user = dyn_cast<Instruction>(use.getUser());
        const bool local = user && (user->getParent()==left || user->getParent()==right);
        auto *phi = dyn_cast<PHINode>(use.getUser());
        const bool exitUse = phi && join && phi->getParent()==join && phi->getIncomingBlock(use)==arm;
        facts << (local ? int64_t(factID(user)) : -1) << '/' << exitUse << ',';
      }
      facts << '\n';
    }
  }
  for (auto *li : segmentWork[0]) for (auto *ri : segmentWork[1])
    facts << compatibleB2BPrefix(*li,*ri) << compatibleB2BArithmetic(*li,*ri)
          << li->isIdenticalTo(ri) << ';';
  facts << " PHI:";
  if (join) for (auto &phi : join->phis())
    facts << factID(phi.getIncomingValueForBlock(left)) << '/'
          << factID(phi.getIncomingValueForBlock(right)) << '/'
          << phi.getType()->isFirstClassType() << '/' << phi.getType()->isTokenTy() << ';';
  facts.flush();
  if (recipeIn && recipeIn->getString("planner_facts") != Optional<StringRef>(plannerFacts))
    throw std::runtime_error("b2b_recipe_dependencies_changed");

  trial.before = features(*f);
  trial.left = trial.leftContext = boundary({left, independentExits ? left->getSingleSuccessor() : join, nullptr, {left}}, *f);
  trial.right = trial.rightContext = boundary({right, independentExits ? right->getSingleSuccessor() : join, nullptr, {right}}, *f);
  trial.matchedLeft = name(left);
  trial.matchedRight = name(right);
  trial.planKind = "B2B";
  trial.loopHeaderSplit = loops.isLoopHeader(split);
  const bool tagged = tagSideCondition(*f, branch->getCondition());
  if (tagged)
    trial.sideBeforeOk = sideBlocksBoth(*f, branch->getCondition(), trial.sideBefore, trial.sideReason);

  struct Layout {
    std::string label;
    SmallVector<B2BMatch, 8> beforeSplit, afterJoin;
    SmallVector<B2BSegmentMatch, 8> segments;
    bool resplit = false, mergeExit = false;
  };
  SmallVector<Layout, 12> layouts;
  auto add = [&](StringRef label, ArrayRef<B2BMatch> before,
                 ArrayRef<B2BMatch> after) {
    if (llvm::any_of(before, [&](const B2BMatch &first) {
          return llvm::any_of(after, [&](const B2BMatch &last) {
            return first.first == last.first || first.second == last.second;
          });
        }))
      return;
    layouts.push_back({label.str(), {before.begin(), before.end()},
                       {after.begin(), after.end()}, {}});
  };
  if (!recipeIn) {
    ProfileScope layoutSearch("plan_layouts");
  if (unified) {
    constexpr unsigned forwardFinalists = 32, tailFinalists = 4;
    const bool canMergeExit = join && llvm::all_of(join->phis(), [](const PHINode &phi) {
      return phi.getType()->isFirstClassType() && !phi.getType()->isTokenTy();
    });
    SmallVector<SmallVector<B2BMatch, 8>, 6> tails(1);
    auto addTail = [&](SmallVector<B2BMatch, 8> tail) {
      if (!llvm::is_contained(tails, tail)) tails.push_back(std::move(tail));
    };
    if (join) {
      addTail(commonB2BSuffix(*left, *right, *join));
      for (auto &tail : searchB2BJoin(*left, *right, *join, tailFinalists, intrinsicCost))
        addTail(std::move(tail));
    }
    auto append = [&](Layout layout) {
      if (llvm::any_of(layouts, [&](const Layout &other) {
            return layout.beforeSplit == other.beforeSplit && layout.segments == other.segments &&
                   layout.afterJoin == other.afterJoin && layout.resplit == other.resplit &&
                   layout.mergeExit == other.mergeExit;
          }))
        return;
      layout.label = "b2b-unified-" + std::to_string(layouts.size() + 1);
      layouts.push_back(std::move(layout));
    };
    for (const auto &tail : tails) {
      SmallVector<Instruction *, 16> remaining[2];
      for (unsigned side = 0; side < 2; ++side)
        for (auto *inst : segmentWork[side])
          if (llvm::none_of(tail, [&](B2BMatch pair) {
                return (side ? pair.second : pair.first) == inst;
              }))
            remaining[side].push_back(inst);

      // Recheck dominance on the original IR. In the filtered prefix, each
      // operand must still be an earlier shared pair or dominate the split.
      // Removing instructions cannot make any discarded arm definition
      // available at the split.
      auto prefix = commonB2BPrefix(llvm::make_pointee_range(remaining[0]),
                                    llvm::make_pointee_range(remaining[1]), *branch, dt);
      if (!prefix.empty()) {
        append(Layout{"", prefix, tail, {}});
        if (tail.empty() && canMergeExit && prefix.size() == remaining[0].size() &&
            prefix.size() == remaining[1].size())
          append(Layout{"", std::move(prefix), {}, {}, false, true});
      }
      if (!tail.empty()) append(Layout{"", {}, tail, {}});

      if (!segmentUsesValid && !independentExits) continue;
      for (auto &plan : searchB2BSegments(remaining[0], remaining[1], independentExits, 1,
                                          intrinsicCost, forwardFinalists, true)) {
        const bool endsAtJoin = join && plan.back().left + 1 == remaining[0].size() &&
                                plan.back().right + 1 == remaining[1].size();
        if (endsAtJoin && !canMergeExit && !tail.empty()) continue;
        Layout layout{"", {}, tail, std::move(plan), endsAtJoin && !canMergeExit};
        append(layout);
        if (endsAtJoin && canMergeExit && tail.empty() && !join->phis().empty()) {
          layout.resplit = true;
          append(std::move(layout));
        }
      }
    }
    if (layouts.empty()) append(Layout{});
  } else {
  auto segments = (segmentUsesValid || independentExits)
      ? searchB2BSegments(segmentWork[0], segmentWork[1], independentExits, 1, intrinsicCost)
      : SmallVector<B2BSegmentedPlan, 4>();
  auto prefix = commonB2BPrefix(*left, *right, *branch, dt);
  auto suffix = join ? commonB2BSuffix(*left, *right, *join)
                     : SmallVector<B2BMatch, 8>{};
  auto aligned = alignHoistableB2B(*left, *right, *branch, dt);
  if (aligned == prefix) aligned.clear();
  auto common = searchB2BCommon(*left, *right, *branch, dt,
                                false, nullptr, false, intrinsicCost);
  if (common == prefix || common == aligned) common.clear();
  SmallVector<SmallVector<B2BMatch, 8>, 4> completeCommon;
  searchB2BCommon(*left, *right, *branch, dt, true, &completeCommon,
                  false, intrinsicCost);
  // Also retain the maximum-coverage alignment. Estimated transfer costs
  // can hide it because cleanup can fold several selects together.
  SmallVector<SmallVector<B2BMatch, 8>, 1> coverage;
  if (!completeCommon.empty())
    searchB2BCommon(*left, *right, *branch, dt, true, &coverage, true,
                    intrinsicCost);
  if (!coverage.empty() && !llvm::is_contained(completeCommon, coverage.front()))
    completeCommon.push_back(std::move(coverage.front()));
  auto joined = join ? searchB2BJoin(*left, *right, *join)
                     : SmallVector<SmallVector<B2BMatch, 8>, 4>{};


  if (!prefix.empty()) add("single-branch-prefix", prefix, {});
  if (join && !prefix.empty() && prefix.size() + 1 == left->size() &&
      prefix.size() + 1 == right->size() &&
      llvm::all_of(join->phis(), [&](const PHINode &phi) {
        return phi.getType()->isFirstClassType() && !phi.getType()->isTokenTy();
      }))
    add("single-branch-prefix-merged-exit", prefix, {});

  if (!suffix.empty()) add("single-branch-suffix", {}, suffix);
  if (!prefix.empty() && !suffix.empty())
    add("single-branch-prefix-suffix", prefix, suffix);
  for (unsigned i = 0; i < completeCommon.size(); ++i) {
    const auto &plan = completeCommon[i];
    if (plan != common && plan != prefix && plan != aligned)
      add("single-branch-complete-common-dp" + (i ? "-" + std::to_string(i + 1)
                                                  : std::string()), plan, {});
  }
  if (!aligned.empty()) add("single-branch-aligned-hoist", aligned, {});
  if (!common.empty()) add("single-branch-common-dp", common, {});
  if (!common.empty() && !suffix.empty())
    add("single-branch-common-dp-suffix", common, suffix);
  unsigned rank = 0;
  for (const auto &tail : joined) {
    if (tail == suffix) continue;
    const auto variant = rank++ == 0 ? std::string() : "-" + std::to_string(rank);
    add("single-branch-join-dp" + variant, {}, tail);
    if (!prefix.empty())
      add("single-branch-prefix-join-dp" + variant, prefix, tail);
    if (!common.empty())
      add("single-branch-common-join-dp" + variant, common, tail);
  }
  for (unsigned i = 0; i < segments.size(); ++i) {
    const auto label = std::string("single-branch-segment-dp") +
        (i ? "-" + std::to_string(i + 1) : std::string());
    const auto &plan = segments[i];
    layouts.push_back({label, {}, {}, plan});
    const auto &last = plan.back();
    if (join && !join->phis().empty() &&
        last.left + last.consumeLeft == segmentWork[0].size() &&
        last.right + last.consumeRight == segmentWork[1].size())
      layouts.push_back({label + "-resplit", {}, {}, plan});
  }
  if (layouts.empty()) add("single-branch-separate", {}, {});
  }
  } else {
    ProfileScope decode("decode_layout_recipe");
    auto *rows = recipeIn->getArray("layouts");
    if (!rows || rows->empty()) throw std::runtime_error("empty_b2b_recipe");
    auto index = [&](const json::Value &v, unsigned side) -> Instruction * {
      auto n = v.getAsInteger();
      if (!n || *n < -1 || *n >= int64_t(segmentWork[side].size()))
        throw std::runtime_error("invalid_b2b_recipe_index");
      return *n == -1 ? nullptr : segmentWork[side][*n];
    };
    for (const auto &row : *rows) {
      auto *object = row.getAsObject();
      if (!object || !object->getString("label")) throw std::runtime_error("invalid_b2b_recipe_layout");
      Layout layout; layout.label = object->getString("label")->str();
      if (unified) {
        auto resplit = object->getBoolean("resplit"), mergeExit = object->getBoolean("merge_exit");
        if (!resplit || !mergeExit) throw std::runtime_error("invalid_b2b_recipe_exit");
        layout.resplit = *resplit;
        layout.mergeExit = *mergeExit;
      }
      auto decodePairs = [&](StringRef key, SmallVectorImpl<B2BMatch> &pairs) {
        auto *array = object->getArray(key);
        if (!array) throw std::runtime_error("missing_b2b_recipe_pairs");
        for (const auto &entry : *array) {
          auto *pair = entry.getAsArray();
          if (!pair || pair->size() != 2) throw std::runtime_error("invalid_b2b_recipe_pair");
          pairs.emplace_back(index((*pair)[0], 0), index((*pair)[1], 1));
        }
      };
      decodePairs("before", layout.beforeSplit); decodePairs("after", layout.afterJoin);
      auto *segments = object->getArray("segments");
      if (!segments) throw std::runtime_error("missing_b2b_recipe_segments");
      for (const auto &entry : *segments) {
        auto *pair = entry.getAsArray();
        if (!pair || pair->size() != 2 || !index((*pair)[0],0) || !index((*pair)[1],1))
          throw std::runtime_error("invalid_b2b_recipe_segment");
        layout.segments.push_back({unsigned(*(*pair)[0].getAsInteger()), unsigned(*(*pair)[1].getAsInteger())});
      }
      layouts.push_back(std::move(layout));
    }
  }
  if (recipeOut) {
    auto number = [&](Instruction *inst, unsigned side) -> int64_t {
      if (!inst) return -1;
      auto found = llvm::find(segmentWork[side], inst);
      if (found == segmentWork[side].end()) throw std::runtime_error("nonlocal_b2b_recipe_instruction");
      return found - segmentWork[side].begin();
    };
    json::Array rows;
    for (const auto &layout : layouts) {
      auto pairs = [&](ArrayRef<B2BMatch> matches) {
        json::Array result;
        for (auto match : matches) result.push_back(json::Array{number(match.first,0), number(match.second,1)});
        return result;
      };
      json::Array segments;
      for (auto step : layout.segments) {
        if (!step.consumeLeft || !step.consumeRight) throw std::runtime_error("unsupported_recipe_action");
        segments.push_back(json::Array{int64_t(step.left), int64_t(step.right)});
      }
      json::Object row{{"label",layout.label},{"before",pairs(layout.beforeSplit)},
                       {"after",pairs(layout.afterJoin)},{"segments",std::move(segments)}};
      if (unified) {
        row["resplit"] = layout.resplit;
        row["merge_exit"] = layout.mergeExit;
      }
      rows.push_back(std::move(row));
    }
    *recipeOut = json::Object{{"schema","b2b-recipe-v4"},{"planner",plannerName},{"parent_hash",parentIdentity},{"planner_facts",plannerFacts},
        {"candidate",c.key()},{"opt_level",int64_t(level)},{"layouts",std::move(rows)}};
  }

  for (const auto &layout : layouts) {
    StringRef label = layout.label;
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
    t.insideLoop = loops.getLoopFor(split) != nullptr;
    t.sideBeforeOk = trial.sideBeforeOk;
    t.sideReason = trial.sideReason;
    for (unsigned side = 0; side < 2; ++side) t.sideBefore[side] = trial.sideBefore[side];
    ValueToValueMapTy clone;
    t.raw = profileCall("clone_layout",[&](){return CloneModule(*trial.raw, clone);});
    auto *raw = t.raw->getFunction(c.function);
    { ProfileScope emitScope("emit_layout");
    auto *rawBranch = cast<BranchInst>(clone[branch]);
    auto *rawLeft = cast<BasicBlock>(clone[left]);
    auto *rawRight = cast<BasicBlock>(clone[right]);
    auto *rawJoin = join ? cast<BasicBlock>(clone[join]) : rawRight;
    const bool segmented = !layout.segments.empty();
    const bool resplit = unified ? layout.resplit : label.endswith("-resplit");
    const bool mergeExit = unified ? layout.mergeExit : label == "single-branch-prefix-merged-exit";
    SmallVector<B2BMatch, 8> suffix;
    for (auto [l, r] : layout.afterJoin)
      suffix.emplace_back(cast<Instruction>(clone[l]), cast<Instruction>(clone[r]));
    if (unified) {
      unsigned sizes[] = {unsigned(segmentWork[0].size() - suffix.size()),
                          unsigned(segmentWork[1].size() - suffix.size())};
      unsigned cursor[2] = {unsigned(layout.beforeSplit.size()), unsigned(layout.beforeSplit.size())};
      unsigned segments = !layout.beforeSplit.empty();
      bool guarded = false;
      for (auto pair : layout.segments) {
        const bool gap = cursor[0] != pair.left || cursor[1] != pair.right;
        guarded |= gap;
        if (gap) segments += 2;
        else if (cursor[0] == 0 && cursor[1] == 0) ++segments;
        cursor[0] = pair.left + 1;
        cursor[1] = pair.right + 1;
      }
      const bool pending = cursor[0] != sizes[0] || cursor[1] != sizes[1];
      segments += pending;
      segments += !suffix.empty();
      t.b2bPlan = B2BPlanShape{segments, unsigned(suffix.size()),
                                mergeExit || (segmented && !guarded && !pending &&
                                              !resplit && !independentExits)};
    }
    t.rewriteStarted = segmented || !layout.beforeSplit.empty() || !layout.afterJoin.empty();
    if (segmented) {
      try {
        emitB2BSegments(*rawBranch, *rawLeft, *rawRight, *rawJoin, layout.segments,
                        resplit, independentExits, suffix);
      } catch (const std::runtime_error &error) {
        t.reason = error.what();
        trials.push_back(std::move(t));
        continue;
      }
    }

    if (!layout.beforeSplit.empty()) {
      IRBuilder<> builder(rawBranch);
      Value *condition = rawBranch->getCondition();
      if (mergeExit ||
          label.startswith("single-branch-complete-common-dp") ||
          llvm::any_of(layout.beforeSplit, [](B2BMatch step) {
            return step.first && step.second && step.first->mayReadOrWriteMemory();
          })) {
        condition = builder.CreateFreeze(condition);
        rawBranch->setCondition(condition);
      }
      std::map<std::pair<Value *, Value *>, Value *> selects;
      for (auto [l, r] : layout.beforeSplit) {
        if (!l || !r) {
          // Move the original instruction so existing guarded uses and later
          // shared steps both see the same definition.
          cast<Instruction>(clone[l ? l : r])->moveBefore(rawBranch);
          continue;
        }
        auto *lc = cast<Instruction>(clone[l]), *rc = cast<Instruction>(clone[r]);
        auto *shared = lc->clone();
        for (unsigned n = 0; n < shared->getNumOperands(); ++n) {
          auto *lv = lc->getOperand(n), *rv = rc->getOperand(n);
          if (lv != rv) {
            auto &choice = selects[{lv, rv}];
            if (!choice) choice = emitB2BSelect(builder, condition, lv, rv);
            shared->setOperand(n, choice);
          }
        }
        builder.Insert(shared);
        lc->replaceAllUsesWith(shared);
        rc->replaceAllUsesWith(shared);
        lc->eraseFromParent();
        rc->eraseFromParent();
      }
      if (mergeExit) {
        auto *commonBlock = rawBranch->getParent();
        for (auto &phi : rawJoin->phis()) {
          auto *lv = phi.getIncomingValueForBlock(rawLeft);
          auto *rv = phi.getIncomingValueForBlock(rawRight);
          Value *merged = lv;
          if (lv != rv) {
            auto &choice = selects[{lv, rv}];
            if (!choice) choice = emitB2BSelect(builder, condition, lv, rv);
            merged = choice;
          }
          phi.removeIncomingValue(rawLeft, false);
          phi.removeIncomingValue(rawRight, false);
          phi.addIncoming(merged, commonBlock);
        }
        builder.CreateBr(rawJoin);
        rawBranch->eraseFromParent();
        rawLeft->eraseFromParent();
        rawRight->eraseFromParent();
      }
    }

    if (!segmented && !suffix.empty()) {
      auto *merge = BasicBlock::Create(raw->getContext(), "fusion.suffix", raw, rawJoin);
      BranchInst::Create(rawJoin, merge);
      emitB2BSuffix(*merge, *rawJoin, *rawLeft, *rawRight, *rawLeft, *rawRight, suffix,
                    [](unsigned, Value *value) { return value; });
      rawLeft->getTerminator()->setSuccessor(0, merge);
      rawRight->getTerminator()->setSuccessor(0, merge);
    }
    } // layout emission
    clone.clear();
    if (profileCall("verify",[&](){return verifyModule(*t.raw, &errs());})) {
      t.reason = "raw_verifier_failed";
      trials.push_back(std::move(t));
      continue;
    }
    t.afterRaw = profileCall("features",[&](){return features(*raw);});
    t.normalized = profileCall("clone_before_cleanup",[&](){return CloneModule(*t.raw);});
    t.cleanupIterations = profileCall("cleanup",[&](){return cleanup(*t.normalized, c.function, mode);});
    auto *after = t.normalized->getFunction(c.function);
    if (!profileCall("verify",[&](){return verifyModule(*t.normalized, &errs());})) {
      t.after = profileCall("features",[&](){return features(*after);});
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

RoundContext makeRound(const Module&parent,const std::string&function,unsigned version,unsigned,CleanupMode mode) {
  ProfileScope roundScope("round_control_analysis_cleanup");
  RoundContext r;r.cleanupMode=mode;r.parentVersion=version;r.function=function;r.parentHash=moduleHash(parent);
  r.targetTriple=parent.getTargetTriple();r.dataLayout=parent.getDataLayoutStr();r.llvmVersion=LLVM_VERSION_STRING;
  r.cleanup=mode==CleanupMode::None ? "none;no_external_cleanup" :
      "darm-simplifycfg-phi7-condbranch0-sink0-hoist0;earlycse-dce-instcombine;phi-edge-function-order-v1";
  auto*f=parent.getFunction(function);if(!f||f->isDeclaration())throw std::runtime_error("round function missing");
  r.targetAttributes=attributes(f->getAttributes(),f->arg_size());
  auto start=Clock::now();r.parentFeatures=features(*f);r.control=CloneModule(parent);r.controlCleanupIterations=cleanup(*r.control,function,mode);
  canonicalPhiOrder(*r.control,function);
  if(verifyModule(*r.control,&errs()))throw std::runtime_error("control verifier failed");
  auto*control=r.control->getFunction(function);if(!control||control->isDeclaration())throw std::runtime_error("control function missing");
  r.controlFeatures=features(*control);r.normalizationScale=std::max(double(r.controlFeatures.cost),1.0);
  r.controlHash=moduleHash(*r.control);r.controlMs=millis(start);return r;
}
ScoreResult evaluateTrial(const Module&parent,Trial&t,const RoundContext&r,const Scorer&scorer) {
  ScoreResult s;
  if(!t.valid){s.reason="trial_rejected";return s;}
  if(t.cleanupMode!=r.cleanupMode){s.reason="cleanup_mode_mismatch";return s;}
  if(t.candidate.version!=r.parentVersion||t.candidate.function!=r.function||moduleHash(parent)!=r.parentHash){s.reason="round_identity_mismatch";return s;}
  auto start=Clock::now();auto*before=parent.getFunction(r.function);auto*raw=t.raw->getFunction(r.function);auto*after=t.normalized->getFunction(r.function);
  if(!scorer.evaluateWithoutAnalysis(t.candidate,*before,*after,r,&t,s)){
    Analysis ba(*before),aa(*after);
    s=scorer.evaluate({t.candidate,*before,*raw,*after,ba,aa,t.before,t.afterRaw,t.after,t.left,t.right,t.replication,&t},r);
  }
  if(s.status==ScoreStatus::Scored&&(!std::isfinite(s.total)||!std::isfinite(s.staticGain)||!std::isfinite(s.staticScore)||!std::isfinite(s.cleanupGain)||!std::isfinite(s.parentGain)||!std::isfinite(s.dependencyPenalty)||!std::isfinite(s.livenessPenalty))){s.status=ScoreStatus::NotEvaluable;s.reason="nonfinite_score";}
  t.scoreMs=millis(start);return s;
}
bool eligible(const Trial&t,const ScoreResult&s,const Options&o) {
  if(!(t.valid&&s.status==ScoreStatus::Scored&&std::isfinite(s.total)&&s.total>o.threshold&&(!o.requireParentGain||s.parentGain>0)))return false;
  if(!s.profitabilityRejection.empty())return false;
  return true;
}

}
