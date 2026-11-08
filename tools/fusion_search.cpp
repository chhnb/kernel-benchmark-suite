#include "fusion_search.h"
#include "darm_pair_engine/LocalComputationFusion.h"
#include "logical_region_state.h"
#include "darm_pair_engine/RegionMelder.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Transforms/Utils/Cloning.h"
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
unsigned cleanup(Module &m,const std::string &function,unsigned level,CleanupMode mode) {
  if(mode==CleanupMode::None)return 0;
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
  std::map<std::string,BasicBlock*> blocks;
  std::map<BasicBlock*,std::string> ids;
  std::map<std::string,Unit> units;
  Inventory(Function&f,Analysis&a) {
    unsigned n=0;for(auto&b:f){auto id="B"+std::to_string(n++);blocks[id]=&b;ids[&b]=id;units[id]={&b,b.getSingleSuccessor(),nullptr,{&b}};}
    n=0;std::function<void(Region*)> visit=[&](Region*r){std::set<BasicBlock*>bs;for(auto*b:r->blocks())bs.insert(b);units["R"+std::to_string(n++)]={r->getEntry(),r->getExit(),r,bs};for(auto&c:*r)visit(c.get());};visit(a.regions.getTopLevelRegion());
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
// Loop headers, nested loops, backedges and exits remain unsupported.
static bool supportedLoopScope(BasicBlock *split,BasicBlock *join,
                               const std::set<BasicBlock*>&scope,LoopInfo &loops) {
  auto *enclosing=loops.getLoopFor(split);
  if(!enclosing){for(auto*b:scope)if(loops.getLoopFor(b))return false;return true;}
  if(loops.getLoopFor(join)!=enclosing||enclosing->getHeader()==split||
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
  t.originalSimilarity=ma.explicitSimilarity();t.originalProfitable=ma.isRegionMatchProfitable(0);
  auto ft=Clock::now();t.before=features(*f);t.featuresMs+=millis(ft);t.left=boundary(l,*f);t.right=boundary(r,*f);t.replication=ma.requireRegionReplication();
  if(t.replication&&!l.region&&(!l.entry->getUniqueSuccessor()||!r.entry->getUniqueSuccessor()))return reject("replication_requires_unique_successor");
  std::map<std::string,std::string> others;for(auto&g:*t.raw)if(&g!=f)others[g.getName().str()]=text(g);
  auto mt=Clock::now();RegionMelder melder(ma,true);if(t.logicalState)melder.onValueMapping=[&](const ValueToValueMapTy &m){t.logicalState->transfer(m);};if(c.localCopysign){
    if(l.region||r.region)return reject("local_requires_basic_blocks");
    std::string why;
    if(!fuseLocalComputations(l.entry,r.entry,melder.onValueMapping,why,c.localUnion)){t.reason=why;t.totalMs=millis(started);return t;}
    t.replication=false;
  }else melder.merge(0);canonicalPhiOrder(*t.raw,c.function);t.mergeMs=millis(mt);
  if(verifyModule(*t.raw,&errs()))return reject("raw_verifier_failed");
  for(auto&g:*t.raw)if(&g!=f)if(!others.count(g.getName().str())||others.at(g.getName().str())!=text(g))return reject("other_function_changed");
  ft=Clock::now();t.afterRaw=features(*f);t.featuresMs+=millis(ft);if(t.afterRaw.loops>t.before.loops)return reject("new_raw_loop");
  auto blockLabel=[](const Value *V){std::string S;raw_string_ostream O(S);V->printAsOperand(O,false);O.flush();return S;};
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
  t.cleanupIterations=cleanup(*t.normalized,c.function,level,mode);canonicalPhiOrder(*t.normalized,c.function);t.normalizeMs=millis(nt);
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
  if(mode==CleanupMode::DarmCFGEarlyCSE)r.cleanup+="-earlycse-memoryssa0";
  if(mode==CleanupMode::PostOptFixedPoint)r.cleanup="phi-edge-function-order-v1;earlycse-memoryssa0-instcombine-simplifycfg-default-dce-earlycse-pure-scalar-phi-triangle-v1-fixedpoint-sha1-cap32";
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
    for(auto&candidate:candidates){candidate.localCopysign=o.localCopysign;candidate.localUnion=o.localUnion;auto t=tryPair(*result.module,candidate,version,o.optLevel,o.cleanupMode,logical.get());++result.trials;
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
