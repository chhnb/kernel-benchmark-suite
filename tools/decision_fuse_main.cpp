// Opt-in single-pair bridge to the existing RegionMelder. No ranking or fallback.
#include "decision_model.h"
#include "complete_leaf_plan.h"
#include "decision_gap_search.h"
#include "trial_simplify_cfg.h"
#include "trial_full_cfg.h"
#include "trial_implicit_metrics.h"
#include "scoped_cfg_cleanup.h"
#include "ir_pressure.h"
#include "decision_speculation_tti.h"
#include "vllm_throughput_tti.h"
#include "llvm/ADT/StringMap.h"
#include "llvm/IR/ModuleSlotTracker.h"
#include "decision_side_metrics.h"
#include "decision_uniform_tracking.h"
#include <darm_pair_engine/RegionMelder.h>
#include "llvm/IRReader/IRReader.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IR/ValueHandle.h"
#include "llvm/IR/CFG.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/FormatVariadic.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include <set>
#include <cstdlib>
using namespace llvm;
static void writeIR(Module &m,StringRef path){std::error_code ec;raw_fd_ostream out(path,ec,sys::fs::OF_None);if(ec)report_fatal_error("cannot write trial IR");m.print(out,nullptr);}
static std::string label(Value *v){std::string s;raw_string_ostream o(s);v->printAsOperand(o,false);return o.str();}
struct OutsideInstruction {
 WeakVH instruction;
 std::string original;
 std::vector<WeakTrackingVH> operands;
};
// Fold only empty diamonds whose outgoing values are identical. No code
// motion, new select, speculation, or generic SimplifyCFG invocation.
static unsigned foldEmptyDiamonds(BasicBlock *entry, BasicBlock *exit) {
 unsigned count=0;
 for(;;){
  std::set<BasicBlock*> owned;std::vector<BasicBlock*> todo{entry};
  while(!todo.empty()){auto *b=todo.back();todo.pop_back();if(b==exit||!owned.insert(b).second)continue;for(auto *s:successors(b))todo.push_back(s);}
  bool changed=false;
  for(auto &bb:*entry->getParent()){auto *b=&bb;if(!owned.count(b))continue;auto *br=dyn_cast<BranchInst>(b->getTerminator());if(!br||!br->isConditional())continue;
   auto *l=br->getSuccessor(0),*r=br->getSuccessor(1);
   if(l==r||!owned.count(l)||!owned.count(r)||l->size()!=1||r->size()!=1||l->getSinglePredecessor()!=b||r->getSinglePredecessor()!=b)continue;
   auto *j=l->getSingleSuccessor();if(!j||j!=r->getSingleSuccessor()||(!owned.count(j)&&j!=exit))continue;
   bool safe=true;for(auto &p:j->phis()){int li=p.getBasicBlockIndex(l),ri=p.getBasicBlockIndex(r);if(li<0||ri<0||p.getIncomingValue(li)!=p.getIncomingValue(ri)){safe=false;break;}}
   if(!safe)continue;
   for(auto &p:j->phis()){p.setIncomingBlock(p.getBasicBlockIndex(l),b);p.removeIncomingValue(r,false);}
   auto *nb=BranchInst::Create(j,br);nb->copyMetadata(*br);br->eraseFromParent();l->eraseFromParent();r->eraseFromParent();++count;changed=true;break;
  }
  if(!changed)return count;
 }
}
// Structural gap trials share one normalized parent. The winner is replayed
// from the original input to generate the complete diagnostics.
struct PreparedDecision {
 std::unique_ptr<Module> module;
 BasicBlock *dispatch=nullptr;
 BasicBlock *binding=nullptr;
 BasicBlock *join=nullptr;
 std::vector<BasicBlock*> originalBlocks;
 std::string decision, left, right, requestedPlan;
 unsigned armCount=0;
 bool localPair=false;
};
static int runDecisionTrial(int argc,char **argv,Module &parent,
                            StringRef cleanup,int mode,unsigned budget,
                            unsigned conditionBudget,unsigned costThreshold,
                            const decision::GapSearchState *explicitState=nullptr,
                            decision::GapTrialResult *memory=nullptr,
                            bool publish=false,llvm::TargetMachine *throughputMachine=nullptr,
                            PreparedDecision *prepared=nullptr,
                            Optional<int64_t> scoreLimit=None){
 auto &ctx=parent.getContext();
 const bool reuse=prepared&&prepared->module;
 ValueToValueMapTy mapping;
 auto trial=reuse?CloneModule(*prepared->module,mapping):CloneModule(parent);auto *f=trial->getFunction(argv[2]);if(!f)return 2;
 if(!memory&&sys::fs::create_directories(argv[5]))return 2;
 std::string dir=argv[5];json::Object report{{"schema","decision-fuse-trial-v1"},{"engine","RegionMelder"},{"speculation","none"},{"extra_cleanup","arm-local linear folding and identical-value empty diamonds"},{"status","started"}};
 report["speculation"]=mode==0?"none":mode==1?"legacy":mode==2?"budget":"cost";report["speculation_budget"]=budget;report["condition_budget"]=conditionBudget;report["tti_source"]=cleanup=="full"?"LLVM12_target_TTI":"cleanup_structural_no_tti";
 report["speculation_cost_kind"]="LLVM12_TCK_SizeAndLatency";report["speculation_cost_threshold"]=costThreshold;
 report["cfg_cleanup"]=cleanup;report["implicit_speculation_allowed"]=cleanup=="full";
 auto finish=[&](StringRef reason,int code){report["status"]=code?"rejected":"verified";report["reason"]=reason.str();if(memory){memory->Report=json::Value(std::move(report));return code;}std::error_code ec;raw_fd_ostream out(dir+"/trial.json",ec,sys::fs::OF_None);out<<formatv("{0:2}\n",json::Value(std::move(report)));return code;};
 const bool diagnostics=!memory||publish||cleanup=="full";
 const char *checkpointMode=std::getenv("DECISION_CHECKPOINT_MODE");
 const bool uniformReport=(!memory||publish)&&(std::getenv("DECISION_UNIFORM_REPORT")||
     (checkpointMode&&StringRef(checkpointMode)!="off"));
 decision::UniformValueKeys uniformKeys;
 std::vector<decision::UniformArmFacts> uniformArms;
 WeakVH uniformRoot,uniformJoin;
 std::vector<WeakVH> conditionHoists,approvedSpeculation;
 std::vector<WeakVH> trackedAnchors,trackedHoists,trackedSpeculation;
 bool trackUniform=false;
 WeakTrackingVH sideCondition;
 std::vector<unsigned> sidesBefore[2],sidesAfter[2];std::string sideReason;
 bool sideBeforeOK=false;
 std::vector<WeakVH> originalBlocks;
 BasicBlock *dispatch=nullptr,*bindingEntry=nullptr,*trialExit=nullptr;
 std::string decisionID,reason,requestedPlan;
 unsigned armCount=0;
 bool localPair=false;
 if(reuse){
   auto mapBlock=[&](BasicBlock *block){return cast<BasicBlock>(mapping.lookup(block));};
   dispatch=mapBlock(prepared->dispatch);bindingEntry=mapBlock(prepared->binding);
   trialExit=mapBlock(prepared->join);localPair=prepared->localPair;armCount=prepared->armCount;decisionID=prepared->decision;
   for(auto *block:prepared->originalBlocks)originalBlocks.emplace_back(mapBlock(block));
   requestedPlan=prepared->requestedPlan;
   report["decision"]=decisionID;report["left"]=prepared->left;report["right"]=prepared->right;
 }else{
 if(cleanup=="full")for(auto &bb:*f)for(auto &i:bb)if(auto *cb=dyn_cast<CallBase>(&i))if(cb->isConvergent())return finish("full_cleanup_function_contains_convergent",3);
 if(!memory)writeIR(*trial,dir+"/parent.ll");
 ModuleSlotTracker slots(trial.get());slots.incorporateFunction(*f);
 StringMap<BasicBlock*> blocksByLabel;
 for(auto &bb:*f){
   std::string name;raw_string_ostream os(name);bb.printAsOperand(os,false,slots);os.flush();
   if(argc>=7)blocksByLabel.try_emplace(name,&bb);
   if(!bb.getTerminator()->getMetadata("decision.origin"))
     bb.getTerminator()->setMetadata("decision.origin",MDNode::get(ctx,MDString::get(ctx,(f->getName()+":"+name).str())));
 }
 if(argc>=7){auto buf=MemoryBuffer::getFile(argv[6]);if(!buf)return finish("order_file_unreadable",3);auto parsed=json::parse((*buf)->getBuffer());if(!parsed){consumeError(parsed.takeError());return finish("invalid_order_json",3);}auto *array=parsed->getAsArray();if(!array)return finish("order_array_required",3);
  for(auto &v:*array){
    auto *o=v.getAsObject();if(!o)return finish("invalid_order_entry",3);
    auto entry=o->getString("entry"),family=o->getString("family");auto index=o->getInteger("index");
    if(!entry||!family||!index)return finish("invalid_order_entry",3);
    auto *bb=blocksByLabel.lookup(*entry);
    if(!bb||bb->getTerminator()->getMetadata("decision.order"))continue;
    auto *n=ConstantAsMetadata::get(ConstantInt::get(Type::getInt32Ty(ctx),*index));
    bb->getTerminator()->setMetadata("decision.order",MDNode::get(ctx,{MDString::get(ctx,*family),n,n}));
  }
 }

 auto ds=decision::discover(*f);unsigned di=0,li=0;
 if(argc==8){
  auto buf=MemoryBuffer::getFile(argv[7]);if(!buf)return finish("pair_file_unreadable",3);
  auto parsed=json::parse((*buf)->getBuffer());if(!parsed){consumeError(parsed.takeError());return finish("invalid_pair_json",3);}
  auto *o=parsed->getAsObject();if(!o)return finish("invalid_pair_json",3);
  auto id=o->getString("decision"),left=o->getString("left"),right=o->getString("right");
  if(!id||!left||!right)return finish("invalid_pair_json",3);
  unsigned matches=0;
  for(unsigned d=0;d<ds.size();++d)if(ds[d].id==*id)
   for(unsigned l=0;l+1<ds[d].arms.size();++l)
    if(ds[d].arms[l].id==*left&&ds[d].arms[l+1].id==*right){di=d;li=l;++matches;}
  if(matches!=1)return finish("requested_pair_not_unique_or_adjacent",3);
  if(auto plan=o->getString("anchor_plan")){
   if(*plan!="single-anchor"&&*plan!="multi-anchor")
    return finish("invalid_anchor_plan",3);
   requestedPlan=plan->str();
  }
  if(uniformReport)if(auto *tracking=o->getObject("uniform_tracking")){
   decision::UniformCoordinates coords(*f);
   auto *anchors=tracking->getArray("anchors");
   auto *hoists=tracking->getArray("hoists");
   auto *speculation=tracking->getArray("speculation");
   if(!anchors||!hoists||!speculation)return finish("invalid_uniform_tracking",3);
   trackedAnchors=decision::uniformResolve(coords,*anchors);
   trackedHoists=decision::uniformResolve(coords,*hoists);
   trackedSpeculation=decision::uniformResolve(coords,*speculation);
   trackUniform=true;
  }
 }else{di=std::stoul(argv[3]);li=std::stoul(argv[4]);}
 if(di>=ds.size()||li+1>=ds[di].arms.size())return finish("pair_out_of_range",3);
 report["decision"]=ds[di].id;report["left"]=ds[di].arms[li].id;report["right"]=ds[di].arms[li+1].id;
 if(diagnostics){
   auto beforePressure=fusion::irPressure(*f);
   report["ir_pressure_before"]=json::Object{{"peak_slots32",int64_t(beforePressure.peakSlots32)},{"complete",beforePressure.complete}};
   auto *sideBranch=dyn_cast<BranchInst>(ds[di].arms[li].predicate.back().test->getTerminator());
   sideCondition=sideBranch&&sideBranch->isConditional()?sideBranch->getCondition():nullptr;
   sideBeforeOK=decision_side::sideBlocksBoth(*f,sideCondition,sidesBefore,sideReason);
 }
 decisionID=ds[di].id;armCount=ds[di].arms.size();
 if(!ds[di].pairs[li].join)return finish(ds[di].pairs[li].reason,3);
 localPair=ds[di].pairs[li].join!=ds[di].join;
 report["pair_join"]=label(ds[di].pairs[li].join);
 report["decision_join"]=label(ds[di].join);
 if(uniformReport){
   uniformRoot=ds[di].root;uniformJoin=ds[di].join;
   uniformArms=decision::uniformFacts(ds[di],uniformKeys);
   report["uniform_before"]=decision::uniformBlocks(ds[di].root,ds[di].join,uniformArms,uniformKeys,true);
 }
 for(auto &b:*f)originalBlocks.emplace_back(&b);
 if(!decision::normalize(*f,ds[di],li,reason,&dispatch,conditionBudget,uniformReport?&conditionHoists:nullptr,&trialExit))return finish(reason,3);
 bindingEntry=dispatch;
 // When the last arms of an already-normalized subdecision are fused, the
 // opaque arm must include its short-circuit evaluation prefix as well.
 {PostDominatorTree beforePDT(*f);std::set<BasicBlock*> visited;
  while(visited.insert(bindingEntry).second&&bindingEntry->getTerminator()->getMetadata("decision.short_gate")){
   auto *br=dyn_cast<BranchInst>(bindingEntry->getTerminator());auto *phi=br&&br->isConditional()?dyn_cast<PHINode>(br->getCondition()):nullptr;BasicBlock *owner=nullptr;
   if(phi)for(unsigned i=0;i<phi->getNumIncomingValues();++i){auto *v=dyn_cast<ConstantInt>(phi->getIncomingValue(i));auto *p=phi->getIncomingBlock(i);auto *pb=dyn_cast<BranchInst>(p->getTerminator());if(v&&v->isOne()&&pb&&pb->isConditional()&&beforePDT.dominates(bindingEntry,p)&&(pb->getSuccessor(0)==bindingEntry||pb->getSuccessor(1)==bindingEntry))owner=p;}
   if(!owner)break;bindingEntry=owner;
  }
 }
  if(prepared){
    ValueToValueMapTy snapshot;
    prepared->module=CloneModule(*trial,snapshot);
    auto mapBlock=[&](BasicBlock *block){return cast<BasicBlock>(snapshot.lookup(block));};
    prepared->dispatch=mapBlock(dispatch);prepared->binding=mapBlock(bindingEntry);
    prepared->join=mapBlock(trialExit);prepared->localPair=localPair;prepared->armCount=armCount;
    prepared->requestedPlan=requestedPlan;
    prepared->decision=decisionID;prepared->left=ds[di].arms[li].id;prepared->right=ds[di].arms[li+1].id;
    for(auto &handle:originalBlocks)if(auto *block=dyn_cast_or_null<BasicBlock>((Value*)handle))
      prepared->originalBlocks.push_back(mapBlock(block));
  }
 }
 auto *order=dispatch->getTerminator()->getMetadata("decision.order");
 auto *origins=dispatch->getTerminator()->getMetadata("decision.merged_from");
 auto *identity=dispatch->getTerminator()->getMetadata("decision.origin");
 if(!memory)writeIR(*trial,dir+"/normalized.ll");
 auto normalized=decision::discover(*f);const decision::Decision *pair=nullptr;for(auto &d:normalized)if(d.root==dispatch)pair=&d;
 if(!pair||pair->arms.size()!=2)return finish("normalized_pair_not_found",3);
 if(pair->arms[0].kind==decision::ArmKind::Unsupported||pair->arms[1].kind==decision::ArmKind::Unsupported)return finish("unsupported_normalized_arm",3);
 bool bothLinear=pair->arms[0].kind==decision::ArmKind::Linear&&pair->arms[1].kind==decision::ArmKind::Linear;
 auto *join=pair->join;std::set<BasicBlock*> scope{dispatch,join};for(auto &a:pair->arms)scope.insert(a.blocks.begin(),a.blocks.end());
 ModuleSlotTracker auditSlots(trial.get());auditSlots.incorporateFunction(*f);
 std::vector<OutsideInstruction> audit;
 for(auto &bb:*f)if(!scope.count(&bb))for(auto &i:bb){OutsideInstruction x;x.instruction=&i;{raw_string_ostream text(x.original);i.print(text,auditSlots);text.flush();}for(auto &op:i.operands())x.operands.emplace_back(op.get());audit.push_back(std::move(x));}
 std::map<std::string,std::string> others;
 for(auto &g:*trial)if(&g!=f){std::string s;raw_string_ostream o(s);g.print(o);others[g.getName().str()]=o.str();}
 // Canonicalize a complete Linear arm to one block without touching its join.
 unsigned folded=0;
 for(auto &a:pair->arms){if(a.kind!=decision::ArmKind::Linear)continue;auto *entry=a.entry;std::set<BasicBlock*> blocks(a.blocks.begin(),a.blocks.end());
  while(auto *next=entry->getSingleSuccessor()){
   if(!blocks.count(next))break;
   if(next==entry||next->getSinglePredecessor()!=entry)return finish("linear_arm_not_exclusive",3);
   blocks.erase(next);if(!MergeBlockIntoPredecessor(next))return finish("linear_fold_failed",3);++folded;
  }
 }
 report["linear_blocks_folded"]=folded;
 auto *branch=dyn_cast<BranchInst>(dispatch->getTerminator());if(!branch||!branch->isConditional())return finish("dispatch_lost",3);
 auto *left=branch->getSuccessor(0),*right=branch->getSuccessor(1);
 const auto *leftArm=decision::armAtEntry(*pair,left);
 const auto *rightArm=decision::armAtEntry(*pair,right);
 if(!leftArm||!rightArm||leftArm==rightArm)
  return finish("normalized_arm_entry_mismatch",3);
 if(bothLinear&&(left->getSingleSuccessor()!=join||right->getSingleSuccessor()!=join))return finish("B2B_exit_mismatch",3);
 WeakVH dispatchHandle(dispatch);
 unsigned speculatedRanges=0;
 json::Array segments;
 std::unique_ptr<decision::SpeculationTTI> speculationTTI;
 if(mode==3){try{speculationTTI=std::make_unique<decision::SpeculationTTI>(*f);}catch(const std::exception&e){return finish(e.what(),3);}}
 const bool multiAnchor=requestedPlan.empty()?localPair&&!bothLinear:requestedPlan=="multi-anchor";
 if(multiAnchor&&bothLinear)return finish("multi_anchor_requires_se_se_arm",3);
 if(!requestedPlan.empty())report["anchor_plan"]=requestedPlan;
 if(multiAnchor){
  fusion::LeafArm a{left,{leftArm->blocks.begin(),leftArm->blocks.end()}};
  fusion::LeafArm b{right,{rightArm->blocks.begin(),rightArm->blocks.end()}};
  fusion::LeafPlanTrace trace;
  fusion::LeafPlanOptions options{true,mode,int(budget),int(costThreshold),
    speculationTTI?speculationTTI->info.get():nullptr,uniformReport?&approvedSpeculation:nullptr,
    &speculatedRanges,diagnostics?&trace:nullptr};
  unsigned moved=0,anchors=0,groups=0;
  std::vector<std::string> pairs;
  try{
   if(!fusion::meldLeafPlan(*f,options,std::move(a),std::move(b),dispatch,
                           moved,anchors,groups,pairs,reason))
    return finish(reason,3);
  }catch(const std::exception &e){return finish(e.what(),3);}
  report["plan"]="complete-leaf-multi-anchor";
  report["moved_leaf_instructions"]=int64_t(moved);
  report["leaf_anchor_pairs"]=json::Array(pairs);
  report["coalesced_gap_groups"]=int64_t(groups);
  if(diagnostics){
   report["leaf_anchors"]=std::move(trace.anchors);
   report["leaf_rejected_anchors"]=std::move(trace.rejected);
   segments=std::move(trace.segments);
  }
  report["alignment_choices"]=json::Array{};
  report["gap_choices"]=json::Array{};
 }else{
 DominatorTree dt(*f);PostDominatorTree pdt(*f);RegionAnalyzer analyzer(dispatch,dt,pdt);
 if(bothLinear)analyzer.selectExplicitBlocks(left,right);else {
  // Reuse the native similarity, but do not call a match of empty plumbing
  // a computation fusion. Restrict anchors to must-execute blocks in each arm.
  BasicBlock *bestL=nullptr,*bestR=nullptr;double best=-1;
  auto useful=[](BasicBlock *l,BasicBlock *r){for(auto &a:*l)if(!a.isTerminator()&&!isa<PHINode>(a))for(auto &b:*r)if(!b.isTerminator()&&!isa<PHINode>(b)&&InstructionMatch::match(&a,&b))return true;return false;};
  std::set<BasicBlock*> lb(leftArm->blocks.begin(),leftArm->blocks.end()),rb(rightArm->blocks.begin(),rightArm->blocks.end());
  for(auto &l:*f)if(lb.count(&l)&&pdt.dominates(&l,left))for(auto &r:*f)if(rb.count(&r)&&pdt.dominates(&r,right)&&useful(&l,&r)){
   double sim=Utils::computeBBSimilarty(&l,&r);if(sim>best){best=sim;bestL=&l;bestR=&r;}
  }
  if(!bestL)return finish("no_common_computation_in_must_execute_anchors",3);
  analyzer.selectExplicitBlocks(bestL,bestR);
 }
 if(!analyzer.regionMatchSize())return finish("native_analyzer_found_no_match",3);
 report["plan"]=bothLinear?"B2B":"native-must-execute-anchors";report["similarity"]=analyzer.explicitSimilarity();
 report["replication"]=analyzer.requireRegionReplication();
 auto anchors=analyzer.getRegionMatchEntryBlocks(0);report["matched_left"]=label(anchors.first);report["matched_right"]=label(anchors.second);
 if(!scope.count(anchors.first)||!scope.count(anchors.second))return finish("native_anchor_outside_trial",3);
 RegionMelder melder(analyzer,true);melder.SpeculatedInstructions=uniformReport?&approvedSpeculation:nullptr;melder.SpeculationMode=mode;melder.SpeculationBudget=budget;melder.SpeculationTTI=speculationTTI?speculationTTI->info.get():nullptr;melder.SpeculationCostThreshold=costThreshold;
 if(explicitState){
  melder.SplitMatchIDs=explicitState->Split;melder.SpeculateGapIDs=explicitState->Speculate;melder.ExplicitGapPlan=true;
  if(mode!=3&&!melder.SpeculateGapIDs.empty())return finish("explicit_speculation_requires_cost_mode",3);
 }
 melder.CoalesceGaps=std::getenv("DECISION_COALESCE_GAPS")!=nullptr;
 try{melder.merge(0);}catch(const std::exception&E){return finish(E.what(),3);}
 report["alignment_choices"]=std::move(melder.AlignmentChoices);
 report["gap_choices"]=std::move(melder.GapChoices);
 speculatedRanges=melder.SpeculatedRanges;
 if(diagnostics)fusion::appendSegmentDecisions(melder,segments);
 }
 if(!dispatchHandle)return finish("dispatch_deleted_identity_unknown",3);
 dispatch=cast<BasicBlock>((Value*)dispatchHandle);
 // RegionMelder can replace the dispatch terminator: restore logical identity
 // on the surviving owned block, never on an arbitrary replacement value.
 dispatch->getTerminator()->setMetadata("decision.merged_from",origins);
 dispatch->getTerminator()->setMetadata("decision.origin",identity);
 if(order)dispatch->getTerminator()->setMetadata("decision.order",order);
 if(verifyModule(*trial,&errs()))return finish("post_meld_verifier_failed",3);
 if(memory){
   if(throughputMachine)memory->LocalCost=decision::scoreVllmThroughput(*f,*throughputMachine);
   if(scoreLimit&&memory->LocalCost&&*memory->LocalCost>=*scoreLimit){
     memory->ScoredOnly=true;
     return 0;
   }
   if(!memory->LocalCost||publish){
     raw_string_ostream raw(memory->RawIR);trial->print(raw,nullptr);
   }
 }
 else writeIR(*trial,dir+"/meld-raw.ll");
 report["empty_diamonds_folded"]=foldEmptyDiamonds(dispatch,join);
 // Finish only this trial's trivial PHIs now; otherwise the native global
 // post-pass would delete them during the next, unrelated trial.
 std::set<BasicBlock*> local;std::vector<BasicBlock*> todo{dispatch};
 while(!todo.empty()){auto *b=todo.back();todo.pop_back();if(!local.insert(b).second)continue;if(b!=join)for(auto *s:successors(b))todo.push_back(s);}
 unsigned trivialPhis=0;for(auto *b:local)for(auto it=b->begin();it!=b->end();){auto *p=dyn_cast<PHINode>(&*it++);if(p&&p->getNumIncomingValues()==1&&p->getIncomingValue(0)!=p){p->replaceAllUsesWith(p->getIncomingValue(0));p->eraseFromParent();++trivialPhis;}}
 report["single_input_phis_folded"]=trivialPhis;
 if(verifyModule(*trial,&errs()))return finish("local_cleanup_verifier_failed",3);
 for(auto &x:audit){auto *i=dyn_cast_or_null<Instruction>((Value*)x.instruction);if(!i||i->getNumOperands()!=x.operands.size()){report["outside_failure"]=x.original;return finish("outside_instruction_deleted_or_reshaped",3);}for(unsigned n=0;n<x.operands.size();++n)if(i->getOperand(n)!=(Value*)x.operands[n])return finish("outside_operand_changed_without_RAUW",3);}
 for(auto &g:*trial)if(&g!=f){std::string s;raw_string_ostream o(s);g.print(o);if(others[g.getName().str()]!=o.str())return finish("other_function_changed",3);}
 if(bindingEntry!=dispatch){
  dispatch->getTerminator()->setMetadata("decision.merged_from",nullptr);dispatch->getTerminator()->setMetadata("decision.order",nullptr);dispatch->getTerminator()->setMetadata("decision.origin",nullptr);
  bindingEntry->getTerminator()->setMetadata("decision.merged_from",origins);bindingEntry->getTerminator()->setMetadata("decision.origin",identity);if(order)bindingEntry->getTerminator()->setMetadata("decision.order",order);
 }
 std::set<BasicBlock*> oldBlocks;for(auto &h:originalBlocks)if(auto *b=dyn_cast_or_null<BasicBlock>((Value*)h))oldBlocks.insert(b);
 std::set<BasicBlock*> created;std::set<Instruction*> clean;
 for(auto &b:*f)if(!oldBlocks.count(&b)&&&b!=bindingEntry&&&b!=dispatch&&(!localPair||&b!=trialExit)){created.insert(&b);for(auto &i:b)clean.insert(&i);}
 for(auto &i:*dispatch)clean.insert(&i);
 // Canonicalize a selector's polarity without creating a selection PHI.
 for(auto &b:*f)if(created.count(&b)||&b==dispatch)for(auto &i:b)if(auto *sel=dyn_cast<SelectInst>(&i))if(auto *inv=dyn_cast<BinaryOperator>(sel->getCondition()))if(inv->getOpcode()==Instruction::Xor)if(auto *one=dyn_cast<ConstantInt>(inv->getOperand(1)))if(one->isOne()){
  sel->setCondition(inv->getOperand(0));auto *v=sel->getTrueValue();sel->setTrueValue(sel->getFalseValue());sel->setFalseValue(v);
  if(inv->use_empty())inv->eraseFromParent();
 }
 report["cfg_cleanup_rounds"]=fusion::cleanupScopedCFG(*f,clean,created);
 bindingEntry->getTerminator()->setMetadata("decision.merged_from",origins);bindingEntry->getTerminator()->setMetadata("decision.origin",identity);if(order)bindingEntry->getTerminator()->setMetadata("decision.order",order);
 if(!std::getenv("DECISION_DISABLE_SIMPLIFYCFG")){
  try{
   if(cleanup=="full"){
    std::vector<unsigned> before[2],after[2];std::string why;
    bool beforeOK=decision_side::sideBlocksBoth(*f,sideCondition,before,why);
    std::string preCleanup,postCleanup;
    if(memory){raw_string_ostream raw(preCleanup);trial->print(raw,nullptr);}
    else writeIR(*trial,dir+"/pre-full-cleanup.ll");
    decision::SpeculationTTI fullProvider(*f);
    DominatorTree fullDT(*f);PostDominatorTree fullPDT(*f);
    std::map<BasicBlock*,std::set<BasicBlock*>> conditionalHoists;
    for(auto &bb:*f)for(auto *node=fullDT.getNode(&bb);node;node=node->getIDom())if(node->getBlock()!=&bb&&!fullPDT.dominates(&bb,node->getBlock()))conditionalHoists[&bb].insert(node->getBlock());
    struct Prior{WeakVH inst;BasicBlock*block;};std::vector<Prior> prior;
    for(auto &bb:*f)for(auto &i:bb)if(!i.isTerminator()&&!isa<PHINode>(i))prior.push_back({WeakVH(&i),&bb});
    report["simplifycfg_changes"]=decision::simplifyTrialCFGFull(*f,bindingEntry,trialExit,fullProvider.info.get());
    bool afterOK=decision_side::sideBlocksBoth(*f,sideCondition,after,why);
    if(memory){raw_string_ostream raw(postCleanup);trial->print(raw,nullptr);}
    else writeIR(*trial,dir+"/post-full-cleanup.ll");
    json::Array moved;for(auto &p:prior)if(auto*i=dyn_cast_or_null<Instruction>((Value*)p.inst))if(i->getParent()!=p.block){std::string text;raw_string_ostream os(text);i->print(os);moved.push_back(json::Object{{"opcode",i->getOpcodeName()},{"weight",speculationWeight(*i)},{"tti_size_latency",fullProvider.info->getInstructionCost(i,TargetTransformInfo::TCK_SizeAndLatency)},{"movement",conditionalHoists[p.block].count(i->getParent())?"conditional_hoist":"structural_or_unclassified_move"},{"ir",os.str()}});}
    report["full_cleanup_moved_instructions"]=std::move(moved);
    decision::recordImplicitMetrics(report,argv[0],*f,dir,before,after,beforeOK&&afterOK,why,preCleanup,postCleanup);
   }else report["simplifycfg_changes"]=decision::simplifyTrialCFG(*f,bindingEntry,trialExit);
  }
  catch(const std::exception &e){return finish(e.what(),3);}
  bindingEntry->getTerminator()->setMetadata("decision.merged_from",origins);bindingEntry->getTerminator()->setMetadata("decision.origin",identity);if(order)bindingEntry->getTerminator()->setMetadata("decision.order",order);
 }
 if(diagnostics){
 auto pressure=fusion::irPressure(*f);report["ir_pressure"]=json::Object{{"peak_slots32",int64_t(pressure.peakSlots32)},{"peak_values",int64_t(pressure.peakValues)},{"complete",pressure.complete}};
 bool sideAfterOK=decision_side::sideBlocksBoth(*f,sideCondition,sidesAfter,sideReason);
 report["side_metrics_available"]=sideBeforeOK&&sideAfterOK;
 report["side_metrics_reason"]=sideReason;
 auto sideJSON=[](const std::vector<unsigned>&blocks){json::Array a;for(auto b:blocks)a.push_back(int64_t(b));return a;};
 for(unsigned side=0;side<2;++side){auto name=side?"true":"false";report[std::string("side_before_")+name]=sideJSON(sidesBefore[side]);report[std::string("side_after_")+name]=sideJSON(sidesAfter[side]);}
 report["segments"]=std::move(segments);
 }
 if(uniformReport){
   report["uniform_after"]=decision::uniformBlocks(
       dyn_cast_or_null<BasicBlock>((Value*)uniformRoot),
       dyn_cast_or_null<BasicBlock>((Value*)uniformJoin),uniformArms,uniformKeys,false);
   // Mark surviving instructions only after transforms that inspect metadata.
   auto *uniformMarker=MDNode::getDistinct(ctx,{});
   auto mark=[&](const std::vector<WeakVH> &instructions,StringRef kind) {
     for(const auto &handle:instructions)
       if(auto *instruction=dyn_cast_or_null<Instruction>((Value*)handle))
         instruction->setMetadata(kind,uniformMarker);
   };
   mark(approvedSpeculation,"decision.speculated");
   mark(conditionHoists,"decision.condition_hoist");
   json::Array approved,hoisted;
   unsigned blockIndex=0;
   for(auto &b:*f){
     unsigned instructionIndex=0;
     for(auto &i:b){
       if(isa<DbgInfoIntrinsic>(i))continue;
       auto coordinate=[&] {return json::Array{int64_t(blockIndex),int64_t(instructionIndex)};};
       if(i.getMetadata("decision.speculated")==uniformMarker)approved.push_back(coordinate());
       else if(i.getMetadata("decision.condition_hoist")==uniformMarker)hoisted.push_back(coordinate());
       for(auto *kind:{"decision.speculated","decision.condition_hoist"})
         if(i.getMetadata(kind)==uniformMarker)i.setMetadata(kind,nullptr);
       ++instructionIndex;
     }
     ++blockIndex;
   }
   if(trackUniform){
    decision::UniformCoordinates coords(*f);
    auto extend=[&](const std::vector<WeakVH> &previous,const json::Array &current){
     json::Array result;
     for(const auto &handle:previous)
      if(handle)result.push_back(coords.locate(handle));
     for(const auto &value:current)result.push_back(value);
     return result;
    };
    report["uniform_tracking"]=json::Object{
     {"anchors",decision::uniformTrack(coords,trackedAnchors)},
     {"hoists",extend(trackedHoists,hoisted)},
     {"speculation",extend(trackedSpeculation,approved)}};
   }
   report["uniform_approved_speculation"]=std::move(approved);
   report["uniform_condition_hoists"]=std::move(hoisted);
 }
 report["binding_entry"]=label(bindingEntry);
 if(publish){raw_string_ostream raw(memory->FinalIR);trial->print(raw,nullptr);}
 else if(!memory)writeIR(*trial,dir+"/fused.ll");
 auto rebound=decision::discover(*f);unsigned bindings=0;std::string kind;
 for(auto &d:rebound)if(d.id==decisionID)for(auto &a:d.arms)if(a.entry==bindingEntry&&a.kind!=decision::ArmKind::Unsupported){++bindings;kind=a.kind==decision::ArmKind::Linear?"Linear":"SESE";}
 if(bindings==0&&(armCount==2||localPair)){
  DominatorTree dtAfter(*f);PostDominatorTree pdtAfter(*f);auto *exit=trialExit;bool owned=pdtAfter.dominates(exit,bindingEntry);std::set<BasicBlock*> visited;std::vector<BasicBlock*> todo{bindingEntry};bool linear=true;
  while(!todo.empty()){auto *b=todo.back();todo.pop_back();if(b==exit||!visited.insert(b).second)continue;if(!dtAfter.dominates(bindingEntry,b))owned=false;if(b->getTerminator()->getNumSuccessors()!=1)linear=false;for(auto *next:successors(b))todo.push_back(next);}
  if(owned){bindings=1;kind=linear?"Linear":"SESE";if(armCount==2)report["completed_decision"]=true;}
 }
 report["rebound_bindings"]=bindings;report["rebound_kind"]=kind;report["speculated_gap_ranges"]=speculatedRanges;report["outside_audit"]="preserved instructions and SSA-tracked operands";
 if(publish){
   if(decision::gapKeepCatalog())memory->Catalog=json::Value(decision::describe(rebound));
   if(decision::gapRootsStdout())for(const auto &d:rebound)memory->Roots.push_back(label(d.root));
 }
 else if(!memory){std::error_code ec;raw_fd_ostream out(dir+"/decisions.json",ec,sys::fs::OF_None);out<<formatv("{0:2}\n",json::Value(decision::describe(rebound)));}
 if(bindings!=1)return finish("merged_arm_binding_not_unique",3);
 return finish("fused_and_rebound",0);
}

int main(int argc,char **argv){
 if(argc==4&&StringRef(argv[1])=="--probe-target"){
  LLVMContext ctx;SMDiagnostic error;
  auto module=parseIRFile(argv[2],error,ctx);
  if(!module){error.print(argv[0],errs());return 2;}
  auto *function=module->getFunction(argv[3]);
  if(!function||function->isDeclaration()){errs()<<"target probe function missing\n";return 2;}
  try {
   decision::SpeculationTTI target(*function);
   outs()<<formatv("{0}\n",json::Value(json::Object{
    {"triple",target.machine->getTargetTriple().str()},
    {"cpu",target.machine->getTargetCPU().str()}}));
   return 0;
  }catch(const std::exception &e){errs()<<e.what()<<"\n";return 3;}
 }
 if(std::getenv("DECISION_CFG_CLEANUP")&&std::getenv("DECISION_DISABLE_SIMPLIFYCFG")){errs()<<"DECISION_CFG_CLEANUP conflicts with legacy DECISION_DISABLE_SIMPLIFYCFG\n";return 2;}
 std::string cleanup="structural";
 if(const char *v=std::getenv("DECISION_CFG_CLEANUP")){cleanup=v;if(cleanup!="full"&&cleanup!="structural")return 2;}
 int mode=0;unsigned budget=4,conditionBudget=4,costThreshold=4;
 if(const char *v=std::getenv("DECISION_SPECULATION")){std::string m=v;if(m=="cost")mode=3;else if(m=="budget")mode=2;else if(m=="legacy")mode=1;else if(m!="none")return 2;}
 if(const char *v=std::getenv("DECISION_SPECULATION_BUDGET")){char *end=nullptr;long n=std::strtol(v,&end,10);if(!*v||*end||n<0||n>100000)return 2;budget=n;}
 if(const char *v=std::getenv("DECISION_CONDITION_BUDGET")){char *end=nullptr;long n=std::strtol(v,&end,10);if(!*v||*end||n<0||n>100000)return 2;conditionBudget=n;}
 if(const char *v=std::getenv("DECISION_COST_THRESHOLD")){char *end=nullptr;long n=std::strtol(v,&end,10);if(!*v||*end||n<0||n>100000)return 2;costThreshold=n;}
 if(argc!=6&&argc!=7&&argc!=8){errs()<<"usage: decision-fuse input.ll function decision-index left-index NEW_DIR [ORDER_JSON [PAIR_JSON]]\n";return 2;}
 if(sys::fs::exists(argv[5])){errs()<<"output directory already exists\n";return 2;}
 LLVMContext ctx;SMDiagnostic error;auto parent=parseIRFile(argv[1],error,ctx);
 if(!parent){error.print(argv[0],errs());return 2;}
 if(verifyModule(*parent,&errs()))return 2;
 const char *statePath=std::getenv("DECISION_GAP_STATE");
 PreparedDecision prepared;
 std::unique_ptr<decision::SpeculationTTI> throughputProvider;
 const char *earlyScore=std::getenv("DECISION_GAP_EARLY_SCORE");
 const bool useEarlyScore=earlyScore&&StringRef(earlyScore)=="1"&&cleanup=="structural";
 auto run=[&](const decision::GapSearchState *state,decision::GapTrialResult *memory,
              bool publish=false,Optional<int64_t> upperBound=None){
   if(memory&&std::getenv("DECISION_VLLM_LLVM24_TTI")&&!throughputProvider){
     auto *function=parent->getFunction(argv[2]);
     if(!function||function->empty())throw std::runtime_error("vLLM scoring function missing");
     throughputProvider=std::make_unique<decision::SpeculationTTI>(*function);
   }
   return runDecisionTrial(argc,argv,*parent,cleanup,mode,budget,conditionBudget,costThreshold,
                           state,memory,publish,throughputProvider?throughputProvider->machine.get():nullptr,
                           memory&&!publish&&cleanup=="structural"?&prepared:nullptr,
                           useEarlyScore?upperBound:None);
 };
 if(std::getenv("DECISION_GAP_SEARCH")&&!statePath)
   return decision::searchGapPlans(argc,argv,mode,[&](const decision::GapSearchState &state,decision::GapTrialResult &result,bool publish,Optional<int64_t> upperBound){
     return run(&state,&result,publish,upperBound);
   });
 if(!statePath)return run(nullptr,nullptr);
 try{auto state=decision::readGapState(statePath);return run(&state,nullptr);}
 catch(const std::exception &e){errs()<<e.what()<<"\n";return 3;}
}
