#include "decision_model.h"
#include "condition_simplify.h"
#include "darm_pair_engine/SpeculationSafety.h"
#include "llvm/Analysis/PostDominators.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include <set>
#include <map>
#include <functional>
#include <tuple>
using namespace llvm;
namespace decision {
static std::string name(BasicBlock *b) { if(!b)return ""; std::string s; raw_string_ostream o(s); b->printAsOperand(o,false); return o.str(); }
static std::string origin(BasicBlock *b) {
 if(auto *md=b->getTerminator()->getMetadata("decision.origin"))if(md->getNumOperands()==1)if(auto *s=dyn_cast<MDString>(md->getOperand(0)))return s->getString().str();
 return b->getParent()->getName().str()+":"+name(b);
}
// This recognizes condition work, not permission to speculate it.
static bool testOnly(BasicBlock *b) {
 if(b->getTerminator()->getMetadata("decision.merged_from"))return false;
 auto *br=dyn_cast<BranchInst>(b->getTerminator());
 if(!br||!br->isConditional())return false;
 std::set<Instruction*> slice;
 std::function<void(Value*)> visit=[&](Value *v){auto *i=dyn_cast<Instruction>(v);if(!i||i->getParent()!=b||!slice.insert(i).second)return;for(auto &o:i->operands())visit(o.get());};
 visit(br->getCondition());
 if(br->getMetadata("decision.condition_prefix"))for(auto &i:*b)if(i.getType()->isIntegerTy(1))visit(&i);
 for(auto &i:*b)if(!i.isTerminator()&&(!slice.count(&i)||i.mayHaveSideEffects()||isa<PHINode>(i)))return false;
 return true;
}
std::vector<Decision> discover(Function &f) {
 DominatorTree dt(f); PostDominatorTree pdt(f); LoopInfo li(dt);
 std::vector<Decision> result;
 for(auto &root:f){
 auto *t=root.getTerminator(); auto *br=dyn_cast<BranchInst>(t);
 if(!(br&&br->isConditional())&&!isa<SwitchInst>(t))continue;
 Decision d;d.root=&root;d.id=origin(&root);
 auto *pn=pdt.getNode(&root);d.join=pn&&pn->getIDom()?pn->getIDom()->getBlock():nullptr;
 std::set<BasicBlock*> expanded;
 // A normalized group may have a multi-block short-circuit prefix.
 auto nextGate=[&](BasicBlock *from,std::vector<BasicBlock*> &prefix)->BasicBlock*{
  auto *b=dyn_cast<BranchInst>(from->getTerminator());if(!b||!b->isConditional())return nullptr;
  for(unsigned side=0;side<2;++side){auto *g=b->getSuccessor(side),*start=b->getSuccessor(1-side);auto *gb=dyn_cast<BranchInst>(g->getTerminator());
   auto *phi=gb&&gb->isConditional()?dyn_cast<PHINode>(gb->getCondition()):nullptr;
   if(!gb||!gb->getMetadata("decision.short_gate")||!phi||phi->getParent()!=g||phi->getNumIncomingValues()!=2||pred_size(g)!=2)continue;
   int index=phi->getBasicBlockIndex(from);if(index<0)continue;auto *v=dyn_cast<ConstantInt>(phi->getIncomingValue(index));if(!v||!v->isOne())continue;
   auto *end=phi->getIncomingBlock(1-index);if(end->getSingleSuccessor()!=g||!pdt.dominates(end,start))continue;
   bool safe=true;for(auto &i:*g)if(!isa<PHINode>(i)&&!i.isTerminator())safe=false;
   std::set<BasicBlock*> seen;std::vector<BasicBlock*> todo{start},nodes;
   while(!todo.empty()){auto *x=todo.back();todo.pop_back();if(x==g||!seen.insert(x).second)continue;
    if(x==from||!dt.dominates(from,x)||x->getTerminator()->getMetadata("decision.merged_from")){safe=false;break;}
    for(auto &i:*x){if(!i.isTerminator()&&i.mayHaveSideEffects())safe=false;if(auto *c=dyn_cast<CallBase>(&i))if(c->isConvergent())safe=false;}
    nodes.push_back(x);for(auto *succ:successors(x)){if(dt.dominates(succ,x))safe=false;todo.push_back(succ);}
   }
   if(safe){prefix=std::move(nodes);return g;}
  }return nullptr;
 };
 BasicBlock *effective=&root;std::set<BasicBlock*> forced;
 for(;;){std::vector<BasicBlock*> prefix;auto *next=nextGate(effective,prefix);if(!next)break;d.tests.push_back(effective);d.tests.insert(d.tests.end(),prefix.begin(),prefix.end());effective=next;}
 if(effective!=&root){auto *n=pdt.getNode(effective);d.join=n&&n->getIDom()?n->getIDom()->getBlock():nullptr;}
 std::function<void(BasicBlock*,std::vector<Edge>)> expand=[&](BasicBlock *b,std::vector<Edge> path){
 if(b!=d.join&&!b->getTerminator()->getMetadata("decision.merged_from")&&(testOnly(b)||b->getTerminator()->getMetadata("decision.short_gate"))){
  std::vector<BasicBlock*> prefix;if(auto *next=nextGate(b,prefix)){if(!expanded.insert(b).second)return;d.tests.push_back(b);d.tests.insert(d.tests.end(),prefix.begin(),prefix.end());forced.insert(next);expand(next,path);return;}
 }
 if(b==&root||b==effective||forced.count(b)||(b!=d.join&&testOnly(b)&&b->getSinglePredecessor()&&li.getLoopFor(b)==li.getLoopFor(&root)&&dt.dominates(&root,b))){
  if(!expanded.insert(b).second)return;
  d.tests.push_back(b);auto *term=b->getTerminator();
  // Switch destinations with multiple labels represent one arm, retaining all edge alternatives below.
  std::vector<unsigned> successorsOrder;for(unsigned k=0;k<term->getNumSuccessors();++k)successorsOrder.push_back(k);
  // In a one-sided cascade, place the completed arm before its continuation,
  // independently of whether the source predicate was inverted by LLVM.
  if(term->getNumSuccessors()==2&&isa<BranchInst>(term)&&testOnly(term->getSuccessor(0))&&!testOnly(term->getSuccessor(1)))std::swap(successorsOrder[0],successorsOrder[1]);
  for(unsigned k:successorsOrder){auto p=path;p.push_back({b,k});expand(term->getSuccessor(k),p);}return;
 }
 Arm a;a.entry=b;a.predicate=path;a.id=origin(b);
 a.alternatives.push_back(path);
 if(auto *md=b->getTerminator()->getMetadata("decision.merged_from"))for(auto &op:md->operands())if(auto *s=dyn_cast<MDString>(op.get()))a.mergedFrom.push_back(s->getString().str());
 if(auto *md=b->getTerminator()->getMetadata("decision.order"))if(md->getNumOperands()==3){
  if(auto *family=dyn_cast<MDString>(md->getOperand(0)))a.orderFamily=family->getString().str();
  if(auto *v=mdconst::dyn_extract<ConstantInt>(md->getOperand(1)))a.orderFirst=v->getSExtValue();
  if(auto *v=mdconst::dyn_extract<ConstantInt>(md->getOperand(2)))a.orderLast=v->getSExtValue();
 }
 if(!d.join)a.reason="no_common_postdominator";
 if(!dt.dominates(&root,b))a.reason="entry_not_owned_by_decision";
 std::set<BasicBlock*> seen;std::vector<BasicBlock*> pending{b};
 while(!pending.empty()){auto *x=pending.back();pending.pop_back();if(x==d.join||!seen.insert(x).second)continue;
  a.blocks.push_back(x);
  if(x->hasAddressTaken()||x->isEHPad()||(!isa<BranchInst>(x->getTerminator())&&!isa<SwitchInst>(x->getTerminator())))a.reason="unsupported_terminator_or_address_taken";

  if(x==&root||li.getLoopFor(x)!=li.getLoopFor(&root))a.reason="unsupported_loop_scope";
  if(x->getTerminator()->getNumSuccessors()==0)a.reason="early_exit";
  for(auto &i:*x){if(i.mayHaveSideEffects())a.reason="side_effects";if(auto *c=dyn_cast<CallBase>(&i))if(c->isConvergent())a.reason="convergent_call";}
  for(auto *s:successors(x)){
   if(s==d.join||!dt.dominates(b,s)){
    if(!is_contained(a.exitSources,x))a.exitSources.push_back(x);
    if(!is_contained(a.exitTargets,s))a.exitTargets.push_back(s);
   }else if(dt.dominates(s,x))a.reason="backedge";
   else pending.push_back(s);
  }
 }
 if(a.blocks.empty())a.reason="empty_arm";
 for(auto *x:a.blocks)for(auto *p:predecessors(x))if(!seen.count(p)&&x!=b)a.reason="multiple_entry";
 std::map<BasicBlock*,unsigned> color;
 std::function<bool(BasicBlock*)> cyclic=[&](BasicBlock *x){if(!seen.count(x))return false;if(color[x]==1)return true;if(color[x]==2)return false;color[x]=1;for(auto *s:successors(x))if(cyclic(s))return true;color[x]=2;return false;};
 if(cyclic(b))a.reason="cycle_in_arm";
 bool linear=true;for(auto *x:a.blocks)if(x->getTerminator()->getNumSuccessors()!=1)linear=false;
 a.kind=a.reason.empty()?(linear?ArmKind::Linear:ArmKind::SESE):ArmKind::Unsupported;
 d.arms.push_back(std::move(a));
 };
 expand(effective,{});
 if(isa<SwitchInst>(t)){
  for(unsigned i=0;i<d.arms.size();++i)for(unsigned j=i+1;j<d.arms.size();){
   if(d.arms[i].entry==d.arms[j].entry){d.arms[i].alternatives.insert(d.arms[i].alternatives.end(),d.arms[j].alternatives.begin(),d.arms[j].alternatives.end());d.arms.erase(d.arms.begin()+j);}else ++j;
  }
 }
 for(unsigned i=0;i<d.arms.size();++i)for(unsigned j=i+1;j<d.arms.size();++j){
  std::set<BasicBlock*> bs(d.arms[i].blocks.begin(),d.arms[i].blocks.end());
  for(auto *b:d.arms[j].blocks)if(bs.count(b)){d.arms[i].kind=d.arms[j].kind=ArmKind::Unsupported;d.arms[i].reason=d.arms[j].reason="overlapping_arms_or_shared_switch_destination";break;}
 }
 bool ordered=!d.arms.empty()&&!d.arms[0].orderFamily.empty();
 for(auto &a:d.arms)if(a.orderFamily!=d.arms[0].orderFamily||a.orderFirst<0||a.orderLast<a.orderFirst)ordered=false;
 if(ordered)std::stable_sort(d.arms.begin(),d.arms.end(),[](const Arm&a,const Arm&b){return a.orderFirst<b.orderFirst;});
 for(size_t i=1;i<d.arms.size();++i){
  auto &a=d.arms[i-1],&b=d.arms[i];
  auto *join=pdt.findNearestCommonDominator(a.entry,b.entry);
  PairBoundary pair;
  if(!join||a.exitTargets.size()!=1||b.exitTargets.size()!=1||
     a.exitTargets.front()!=join||b.exitTargets.front()!=join)
   pair.reason="pair_exit_targets_mismatch";
  else if(a.kind==ArmKind::Unsupported||b.kind==ArmKind::Unsupported)
   pair.reason="unsupported_arm";
  else pair.join=join;
  d.pairs.push_back(std::move(pair));
 }
 result.push_back(std::move(d));
 }
 // If a nested decision already owns this exact pair at its regular
 // join, keep that canonical owner. An outer test-only prefix can expose
 // the same leaves and must not preempt the established search order.
 using PairKey=std::tuple<BasicBlock*,BasicBlock*,BasicBlock*>;
 std::map<PairKey,std::vector<BasicBlock*>> canonical;
 auto key=[](const Decision &d,size_t i){
  return PairKey{d.arms[i].entry,d.arms[i+1].entry,d.pairs[i].join};
 };
 for(auto &d:result)for(size_t i=0;i<d.pairs.size();++i)
  if(d.pairs[i].join&&d.pairs[i].join==d.join)
   canonical[key(d,i)].push_back(d.root);
 for(auto &d:result)for(size_t i=0;i<d.pairs.size();++i){
  auto &pair=d.pairs[i];
  if(!pair.join||pair.join==d.join)continue;
  auto found=canonical.find(key(d,i));
  if(found!=canonical.end()&&llvm::any_of(found->second,[&](BasicBlock *root){
       return is_contained(d.tests,root);
     }))pair={nullptr,"pair_owned_by_nested_decision"};
 }
 return result;
}
json::Array describe(const std::vector<Decision>&ds){json::Array out;for(auto &d:ds){json::Array arms,tests,pairs;for(auto &pair:d.pairs)pairs.push_back(json::Object{{"join",name(pair.join)},{"reason",pair.reason}});for(auto *b:d.tests)tests.push_back(name(b));for(auto &a:d.arms){json::Array blocks,exits,targets,path,alternatives,origins;for(auto *target:a.exitTargets)targets.push_back(name(target));for(auto &id:a.mergedFrom)origins.push_back(id);for(auto &p:a.alternatives){json::Array edges;for(auto e:p)edges.push_back(json::Object{{"test",name(e.test)},{"successor",e.successor}});alternatives.push_back(std::move(edges));}for(auto *b:a.blocks)blocks.push_back(name(b));for(auto *b:a.exitSources)exits.push_back(name(b));for(auto e:a.predicate)path.push_back(json::Object{{"test",name(e.test)},{"successor",e.successor}});arms.push_back(json::Object{{"id",a.id},{"entry",name(a.entry)},{"kind",a.kind==ArmKind::Linear?"Linear":a.kind==ArmKind::SESE?"SESE":"Unsupported"},{"reason",a.reason},{"blocks",std::move(blocks)},{"exit_sources",std::move(exits)},{"exit_targets",std::move(targets)},{"ordered_predicate",std::move(path)},{"predicate_alternatives",std::move(alternatives)},{"merged_from",std::move(origins)},{"order_family",a.orderFamily},{"order_first",a.orderFirst},{"order_last",a.orderLast}});}out.push_back(json::Object{{"id",d.id},{"root",name(d.root)},{"join",name(d.join)},{"tests",std::move(tests)},{"arms",std::move(arms)},{"pairs",std::move(pairs)},{"identity_scope","persistent_origin_if_tagged_else_snapshot"}});}return out;}
bool normalize(Function &f,const Decision &d,unsigned left,std::string &reason,BasicBlock **dispatchOut,unsigned conditionBudget,std::vector<WeakVH> *conditionHoists,BasicBlock **localJoinOut){
 auto fail=[&](const char*s){reason=s;return false;};
 if(left+1>=d.arms.size())return fail("pair_out_of_range");
 auto &a=d.arms[left];auto &b=d.arms[left+1];
 auto *pairJoin=d.pairs[left].join;
 if(!pairJoin){reason=d.pairs[left].reason;return false;}
 if(localJoinOut)*localJoinOut=pairJoin;
 auto recordSplit=[&](BasicBlock *split){
  if(localJoinOut&&pairJoin!=d.join)*localJoinOut=split;
 };
 std::set<BasicBlock*> affected(d.tests.begin(),d.tests.end());
 affected.insert(a.blocks.begin(),a.blocks.end());affected.insert(b.blocks.begin(),b.blocks.end());
 affected.insert(pairJoin);
 for(auto *bb:affected)for(auto &i:*bb)if(auto *c=dyn_cast<CallBase>(&i))
  if(c->isConvergent())return fail("convergent_trial_region_not_supported");
 if(a.kind==ArmKind::Unsupported||b.kind==ArmKind::Unsupported)return fail("unsupported_arm");
 if(a.predicate.empty()||b.predicate.empty())return fail("missing_boundary");
 if(!a.orderFamily.empty()&&a.orderFamily==b.orderFamily&&a.orderLast+1!=b.orderFirst)return fail("nonadjacent_logical_ranges");
 auto attachIdentity=[&](BasicBlock *entry){
  SmallVector<Metadata*,8> origins;for(auto *arm:{&a,&b}){if(arm->mergedFrom.empty())origins.push_back(MDString::get(f.getContext(),arm->id));else for(auto &id:arm->mergedFrom)origins.push_back(MDString::get(f.getContext(),id));}
  auto &ctx=f.getContext();entry->getTerminator()->setMetadata("decision.merged_from",MDNode::get(ctx,origins));
  entry->getTerminator()->setMetadata("decision.origin",MDNode::get(ctx,MDString::get(ctx,"merge("+a.id+","+b.id+")")));
  if(!a.orderFamily.empty()&&a.orderFamily==b.orderFamily)entry->getTerminator()->setMetadata("decision.order",MDNode::get(ctx,{MDString::get(ctx,a.orderFamily),ConstantAsMetadata::get(ConstantInt::get(Type::getInt32Ty(ctx),a.orderFirst)),ConstantAsMetadata::get(ConstantInt::get(Type::getInt32Ty(ctx),b.orderLast))}));
 };
 auto foldExitPhis=[&](){for(auto it=pairJoin->begin();it!=pairJoin->end();){auto *p=dyn_cast<PHINode>(&*it++);if(p&&p->getNumIncomingValues()==1&&p->getIncomingValue(0)!=p){p->replaceAllUsesWith(p->getIncomingValue(0));p->eraseFromParent();}}};
 auto ea=a.predicate.back(),eb=b.predicate.back();
 auto *x=ea.test,*y=eb.test;auto *bx=dyn_cast<BranchInst>(x->getTerminator());auto *by=dyn_cast<BranchInst>(y->getTerminator());
 if(x==y&&bx&&bx->isConditional()&&ea.successor!=eb.successor){
  if(a.entry->getSinglePredecessor()!=x||b.entry->getSinglePredecessor()!=x)return fail("sibling_entry_not_exclusive");
  if(!a.entry->phis().empty()||!b.entry->phis().empty())return fail("sibling_entry_phi_unsupported");
  SmallVector<BasicBlock*,16> exits;for(auto *v:a.exitSources)if(!is_contained(exits,v))exits.push_back(v);for(auto *v:b.exitSources)if(!is_contained(exits,v))exits.push_back(v);
  auto *split=SplitBlockPredecessors(pairJoin,exits,".pair.join");
  if(!split)return fail("sibling_exit_split_failed");
  recordSplit(split);
  foldExitPhis();
  if(ea.successor==1){bx->setCondition(BinaryOperator::CreateNot(bx->getCondition(),"decision.left",bx));bx->swapSuccessors();}
  attachIdentity(x);if(dispatchOut)*dispatchOut=x;reason="existing_diamond";
  return !verifyFunction(f,&errs());
 }
 if(!bx||!by||!bx->isConditional()||!by->isConditional()||x==y)return fail("not_adjacent_else_if");
 DominatorTree currentDT(f);PostDominatorTree currentPDT(f);
 if(!currentDT.dominates(x,y))return fail("second_test_not_dominated_by_first");
 auto *prefixStart=bx->getSuccessor(1-ea.successor);
 if(!currentPDT.dominates(y,prefixStart))return fail("second_test_not_postdominating_prefix");
 std::set<BasicBlock*> tests(d.tests.begin(),d.tests.end()),seenPrefix;std::vector<BasicBlock*> pending{prefixStart};
 while(!pending.empty()){auto *p=pending.back();pending.pop_back();if(p==y||!seenPrefix.insert(p).second)continue;if(!tests.count(p)||p==x||!currentDT.dominates(x,p))return fail("prefix_contains_leaf_work_or_external_entry");for(auto *succ:successors(p)){if(currentDT.dominates(succ,p))return fail("cyclic_prefix");pending.push_back(succ);}}
  if(a.entry->getSinglePredecessor()!=x||b.entry->getSinglePredecessor()!=y)return fail("arm_entry_not_exclusive");
 if(!a.entry->phis().empty()||!b.entry->phis().empty())return fail("entry_phi_not_supported_yet");
 auto *rest=by->getSuccessor(1-eb.successor);
 if(rest==a.entry||rest==b.entry)return fail("overlapping_dispatch");
 // Reject side effects in the second test: preserving execution is supported,
 // but this prototype's audited condition-only scope excludes such work.
 for(auto &i:*y){if(!i.isTerminator()&&i.mayHaveSideEffects())return fail("test_side_effects");if(auto *c=dyn_cast<CallBase>(&i))if(c->isConvergent())return fail("convergent_test");}
 std::vector<BasicBlock*> exits=a.exitSources;exits.insert(exits.end(),b.exitSources.begin(),b.exitSources.end());
 std::sort(exits.begin(),exits.end());exits.erase(std::unique(exits.begin(),exits.end()),exits.end());
 auto *j=SplitBlockPredecessors(pairJoin,exits,".pair.join");
 if(!j)return fail("cannot_split_exit");
 recordSplit(j);
 foldExitPhis();
 auto &ctx=f.getContext();
 // Hoisting is permitted only for a single, exclusively owned test block.
 bool eager=prefixStart==y&&y->getSinglePredecessor()==x&&!y->hasAddressTaken()
   &&!bx->getMetadata("decision.short_gate");
 unsigned weight=0;
 for(auto &i:*y)if(!i.isTerminator()){
  eager &= !isa<PHINode>(i)&&safeToSpeculate(i);
  weight += speculationWeight(i);
  for(auto &op:i.operands())if(auto *def=dyn_cast<Instruction>(op.get()))
   if(def->getParent()!=y&&!currentDT.dominates(def,bx))eager=false;
 }
 eager &= weight<=conditionBudget;
 Value *selected=bx->getCondition();
 if(ea.successor==1)selected=BinaryOperator::CreateNot(selected,"decision.left",bx);
 if(eager){
  Value *right=by->getCondition();
  while(&y->front()!=by){
   auto &moved=y->front();
   moved.moveBefore(bx);
   if(conditionHoists)conditionHoists->emplace_back(&moved);
  }
  if(eb.successor==1)right=BinaryOperator::CreateNot(right,"decision.right",bx);
  auto *take=SelectInst::Create(selected,ConstantInt::getTrue(ctx),right,"decision.take",bx);
  auto *dispatch=BasicBlock::Create(ctx,"decision.dispatch",&f,y);
  bx->setCondition(take);bx->setSuccessor(0,dispatch);bx->setSuccessor(1,rest);
  for(auto &p:rest->phis()){int n=p.getBasicBlockIndex(y);if(n>=0)p.setIncomingBlock(n,x);}
  BranchInst::Create(a.entry,b.entry,selected,dispatch);
  bx->setMetadata("decision.condition_prefix",MDNode::get(ctx,{}));
  // Retire the old branch before simplifying its condition DAG: otherwise
  // that branch keeps the superseded comparison live during scoped DCE.
  // The new entry and dispatch already retain every still-needed condition.
  y->eraseFromParent();
  simplifyCondition(take);
  attachIdentity(dispatch);
  if(dispatchOut)*dispatchOut=dispatch;
  reason="normalized_value_condition";
  if(verifyFunction(f,&errs()))return fail("verifier_failed_discard_clone");
  return true;
 }
 auto *g=BasicBlock::Create(ctx,"decision.gate",&f,y->getNextNode());auto *dispatch=BasicBlock::Create(ctx,"decision.dispatch",&f,g->getNextNode());
 Value *cj=by->getCondition();
 if(eb.successor==1)cj=BinaryOperator::CreateNot(cj,"decision.right",by);
 // Bridge every definition whose dominance is lost, including values used in rest.
 // A recursive group can carry selectors defined in any prefix block.
 // Keep uses inside that prefix unchanged; bridge only escaping values.
 seenPrefix.insert(y);
 std::vector<Instruction*> defs;
 for(auto &bb:f)if(seenPrefix.count(&bb))for(auto &i:bb)
  if(!i.getType()->isVoidTy())defs.push_back(&i);
 std::map<Value*,Value*> bridge;
 for(auto *i:defs){bool external=false;for(auto *u:i->users())if(auto *user=dyn_cast<Instruction>(u))if(!seenPrefix.count(user->getParent())&&user->getParent()!=g)external=true;if(!external)continue;if(!currentDT.dominates(i,by))return fail("escaping_prefix_value_unavailable_at_exit");auto *p=PHINode::Create(i->getType(),2,"decision.value",g);p->addIncoming(UndefValue::get(i->getType()),x);p->addIncoming(i,y);bridge[i]=p;
  SmallVector<Use*,8> uses;for(auto &u:i->uses()){auto *user=dyn_cast<Instruction>(u.getUser());if(user&&user!=p&&!seenPrefix.count(user->getParent())&&user->getParent()!=g)uses.push_back(&u);}for(auto *u:uses)u->set(p);
 }

 auto *gate=PHINode::Create(Type::getInt1Ty(ctx),2,"decision.take",g);gate->addIncoming(ConstantInt::getTrue(ctx),x);gate->addIncoming(cj,y);
 // cj belongs to y: the incoming value itself must remain the original definition.
 bx->setSuccessor(ea.successor,g);
 bx->setMetadata("decision.condition_prefix",MDNode::get(ctx,{}));
 by->eraseFromParent();BranchInst::Create(g,y);
 for(auto &p:rest->phis()){int n=p.getBasicBlockIndex(y);if(n>=0)p.setIncomingBlock(n,g);}
 auto *gb=BranchInst::Create(dispatch,rest,gate,g);
 gb->setMetadata("decision.short_gate",MDNode::get(ctx,{}));
 auto *db=BranchInst::Create(a.entry,b.entry,selected,dispatch);
 attachIdentity(dispatch);
 if(dispatchOut)*dispatchOut=dispatch;
 reason="normalized_without_fusion";
 if(verifyFunction(f,&errs()))return fail("verifier_failed_discard_clone");
 return true;
}
}
