#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/ADT/DenseSet.h"
#include <array>
#include <stdexcept>
using namespace llvm;

static void require(bool ok, const char *msg) {
  if (!ok) throw std::runtime_error(msg);
}
static bool speculatable(Instruction &i) {
  return (isa<BinaryOperator, SelectInst, CastInst, GetElementPtrInst, ICmpInst>(i)) &&
         !i.mayReadOrWriteMemory() && !i.mayHaveSideEffects() &&
         isSafeToSpeculativelyExecute(&i);
}

static bool collapse(BasicBlock &start, Loop &loop) {
  auto *branch=dyn_cast<BranchInst>(start.getTerminator());
  if (!branch || !branch->isConditional()) return false;
  std::array<BasicBlock *,2> side{branch->getSuccessor(0),branch->getSuccessor(1)};
  BasicBlock *join=nullptr;
  if (side[0]->getSingleSuccessor()==side[1]) join=side[1];
  else if (side[1]->getSingleSuccessor()==side[0]) join=side[0];
  else if (side[0]->getSingleSuccessor()==side[1]->getSingleSuccessor())
    join=side[0]->getSingleSuccessor();
  if (!join || join==&start || !loop.contains(join) || !join->getName().startswith("predication."))
    return false;
  if (std::distance(pred_begin(join),pred_end(join))!=2) return false;
  for (auto *arm : side)
    if (arm!=join) {
      if (!loop.contains(arm) || arm->getSinglePredecessor()!=&start ||
          !arm->getName().startswith("predication.")) return false;
      for (auto &i : *arm)
        if (!i.isTerminator() && !speculatable(i)) return false;
    }
  for (auto *arm : side)
    if (arm!=join)
      while (!arm->front().isTerminator()) arm->front().moveBefore(branch);
  IRBuilder<> b(branch);
  while (auto *phi=dyn_cast<PHINode>(&join->front())) {
    Value *v[2];
    for (unsigned i=0;i<2;++i)
      v[i]=phi->getIncomingValueForBlock(side[i]==join ? &start : side[i]);
    // A poison on a speculated, inactive path is only consumed by this select.
    auto *selection=SelectInst::Create(branch->getCondition(),v[0],v[1],"spec.result",branch);
    phi->replaceAllUsesWith(selection);
    phi->eraseFromParent();
  }
  b.CreateBr(join);
  branch->eraseFromParent();
  for (auto *arm : side)
    if (arm!=join) DeleteDeadBlock(arm);
  return true;
}

static unsigned clean(Loop &loop) {
  unsigned removed=0;
  for (auto *bb : loop.blocks())
    for (auto it=bb->begin();it!=bb->end();) {
      auto *s=dyn_cast<SelectInst>(&*it++);
      if (!s) continue;
      bool t=isa<UndefValue>(s->getTrueValue())&&!isa<PoisonValue>(s->getTrueValue());
      bool f=isa<UndefValue>(s->getFalseValue())&&!isa<PoisonValue>(s->getFalseValue());
      if (t==f) continue;
      auto *value=t?s->getFalseValue():s->getTrueValue();
      // Giving undef a concrete value is a refinement, provided the replacement
      // cannot propagate poison on the originally undef arm.
      if (!isGuaranteedNotToBePoison(value,nullptr,s)) continue;
      s->replaceAllUsesWith(value);
      s->eraseFromParent();
      ++removed;
    }
  return removed;
}

struct Event { Instruction *inst; BasicBlock *pred; };
struct Trace {
  SmallVector<Event,256> events;
  DenseMap<Value *, Value *> values;
  unsigned pos=0;
  Value *value(Value *v, Loop &loop) {
    auto *i=dyn_cast<Instruction>(v);
    if (!i || !loop.contains(i->getParent()) || isa<PHINode>(i)&&i->getParent()==loop.getHeader())
      return v;
    auto *mapped=values.lookup(v);
    require(mapped,"unavailable path operand");
    return mapped;
  }
};
static Trace trace(Loop &loop, Value *guard, bool take) {
  Trace path;
  auto *latch=loop.getLoopLatch();
  auto *block=loop.getHeader();
  BasicBlock *pred=nullptr;
  DenseSet<BasicBlock *> seen;
  while (true) {
    require(loop.contains(block)&&seen.insert(block).second,"unexpected internal loop");
    for (auto &i : *block)
      if (!i.isTerminator() && (block!=loop.getHeader() || !isa<PHINode>(i)))
        path.events.push_back({&i,pred});
    if (block==latch) return path;
    auto *br=dyn_cast<BranchInst>(block->getTerminator());
    require(br&&(!br->isConditional()||br->getCondition()==guard),"unrecognized loop path branch");
    pred=block;
    block=br->getSuccessor(br->isConditional()&&!take ? 1 : 0);
  }
}
static unsigned nextMemory(Trace &p, Loop &l, Value *guard, bool take, IRBuilder<> &b) {
  while (p.pos<p.events.size()) {
    auto e=p.events[p.pos];
    auto *i=e.inst;
    if (isa<LoadInst>(i)) return 1;
    if (isa<StoreInst>(i)) return 2;
    ++p.pos;
    if (auto *phi=dyn_cast<PHINode>(i))
      p.values[i]=p.value(phi->getIncomingValueForBlock(e.pred),l);
    else if (auto *s=dyn_cast<SelectInst>(i);s&&s->getCondition()==guard)
      p.values[i]=p.value(take?s->getTrueValue():s->getFalseValue(),l);
    else {
      require(speculatable(*i),"unexpected non-speculatable operation on trace");
      auto *copy=i->clone();
      for (unsigned k=0;k<copy->getNumOperands();++k)
        copy->setOperand(k,p.value(copy->getOperand(k),l));
      b.Insert(copy);
      p.values[i]=copy;
    }
  }
  return 0;
}
static void align(Loop &l) {
  auto *head=l.getHeader();
  auto *latch=l.getLoopLatch();
  auto *exit=l.getExitBlock();
  require(head->getName()=="merged.bb"&&latch&&exit,"unexpected loop");
  auto *headBr=cast<BranchInst>(head->getTerminator());
  SmallVector<Instruction *,32> oldHeader;
  for (auto &i : *head)
    if (!isa<PHINode>(i) && !i.isTerminator()) oldHeader.push_back(&i);
  auto *guard=headBr->getCondition();
  auto *latchBr=cast<BranchInst>(latch->getTerminator());
  auto t=trace(l,guard,true), f=trace(l,guard,false);
  auto *body=BasicBlock::Create(head->getContext(),"aligned.body",head->getParent(),exit);
  IRBuilder<> b(body);
  auto select=[&](Value *a,Value *z) {require(a->getType()==z->getType(),"different types");return b.CreateSelect(guard,a,z);};
  auto pathValues=[&](Value *v) {return select(t.value(v,l),f.value(v,l));};
  unsigned reads=0,writes=0;
  while (true) {
    unsigned a=nextMemory(t,l,guard,true,b),z=nextMemory(f,l,guard,false,b);
    require(a==z,"memory ordering differs across lanes");
    if (!a) break;
    auto *left=t.events[t.pos++].inst,*right=f.events[f.pos++].inst;
    if (a==1) {
      auto *x=cast<LoadInst>(left),*y=cast<LoadInst>(right);
      require(x->isSimple()&&y->isSimple()&&x->getType()==y->getType()&&
              x->getPointerAddressSpace()==3&&y->getPointerAddressSpace()==3,"unsupported load");
      auto *ptr=select(t.value(x->getPointerOperand(),l),f.value(y->getPointerOperand(),l));
      auto *result=b.CreateAlignedLoad(x->getType(),ptr,std::min(x->getAlign(),y->getAlign()));
      t.values[x]=f.values[y]=result;
      ++reads;
    } else {
      auto *x=cast<StoreInst>(left),*y=cast<StoreInst>(right);
      require(x->isSimple()&&y->isSimple()&&x->getPointerAddressSpace()==3&&
              y->getPointerAddressSpace()==3,"unsupported store");
      auto *ptr=select(t.value(x->getPointerOperand(),l),f.value(y->getPointerOperand(),l));
      auto *val=select(t.value(x->getValueOperand(),l),f.value(y->getValueOperand(),l));
      b.CreateAlignedStore(val,ptr,std::min(x->getAlign(),y->getAlign()));
      ++writes;
    }
  }
  require(reads==16&&writes==8,"unexpected memory counts");
  auto *test=pathValues(latchBr->getCondition());
  for (auto &phi : head->phis()) {
    auto n=phi.getBasicBlockIndex(latch);
    require(n>=0,"header lacks backedge");
    phi.addIncoming(pathValues(phi.getIncomingValue(n)),body);
  }
  for (auto &phi : exit->phis()) {
    auto n=phi.getBasicBlockIndex(latch);
    if (n>=0) {
      phi.addIncoming(pathValues(phi.getIncomingValue(n)),body);
    }
  }
  auto *newBr=b.CreateCondBr(test,latchBr->getSuccessor(0),latchBr->getSuccessor(1));
  newBr->copyMetadata(*latchBr);
  BranchInst::Create(body,headBr);
  headBr->eraseFromParent();
  EliminateUnreachableBlocks(*head->getParent());
  for (auto *inst : llvm::reverse(oldHeader)) {
    require(inst->use_empty(),"old header instruction still in use");
    inst->eraseFromParent();
  }
  errs()<<"shared loads="<<reads<<" stores="<<writes<<"\n";
}
int main(int argc,char **argv) try {
  require(argc==4,"usage: variants input variant output");
  LLVMContext context; SMDiagnostic error;
  auto m=parseIRFile(argv[1],error,context);
  require(bool(m),"parse failed");
  auto *f=m->getFunction("_Z3pcmPi");
  auto findLoop=[&](DominatorTree &dt,LoopInfo &li) {
    for (auto &bb : *f)
      if (bb.getName()=="merged.bb") return li.getLoopFor(&bb);
    return static_cast<Loop *>(nullptr);
  };
  StringRef mode=argv[2];
  if (mode=="spec"||mode=="spec-clean") {
    unsigned n=0;
    for (;;) {
      DominatorTree dt(*f); LoopInfo li(dt);
      auto *loop=findLoop(dt,li);
      require(loop,"missing merged loop");
      bool changed=false;
      for (auto *bb : loop->blocks())
        if (collapse(*bb,*loop)) {changed=true;++n;break;}
      if (!changed) break;
    }
    errs()<<"pure diamonds/triangles collapsed="<<n<<"\n";
  }
  DominatorTree dt(*f); LoopInfo li(dt);
  auto *loop=findLoop(dt,li);
  require(loop,"missing merged loop");
  if (mode=="align") align(*loop);
  if (mode=="clean"||mode=="spec-clean") errs()<<"safe literal undef selects removed="<<clean(*loop)<<"\n";
  require(!verifyModule(*m,&errs()),"invalid output");
  std::error_code ec; raw_fd_ostream out(argv[3],ec);
  require(!ec,"cannot open output");
  m->print(out,nullptr);
  return 0;
} catch(const std::exception &e) {errs()<<e.what()<<'\n';return 2;}
