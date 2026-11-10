// Opt-in single-pair bridge to the existing RegionMelder. No ranking or fallback.
#include "decision_model.h"
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
int main(int argc,char **argv){
 if(argc!=6&&argc!=7){errs()<<"usage: decision-fuse input.ll function decision-index left-index NEW_DIR\n";return 2;}
 if(sys::fs::exists(argv[5])){errs()<<"output directory already exists\n";return 2;}
 LLVMContext ctx;SMDiagnostic error;auto parent=parseIRFile(argv[1],error,ctx);
 if(!parent){error.print(argv[0],errs());return 2;}
 if(verifyModule(*parent,&errs()))return 2;
 auto trial=CloneModule(*parent);auto *f=trial->getFunction(argv[2]);if(!f)return 2;
 if(sys::fs::create_directories(argv[5]))return 2;
 std::string dir=argv[5];json::Object report{{"schema","decision-fuse-trial-v1"},{"engine","RegionMelder"},{"speculation","none"},{"extra_cleanup","arm-local linear folding and identical-value empty diamonds"},{"status","started"}};
 auto finish=[&](StringRef reason,int code){report["status"]=code?"rejected":"verified";report["reason"]=reason.str();std::error_code ec;raw_fd_ostream out(dir+"/trial.json",ec,sys::fs::OF_None);out<<formatv("{0:2}\n",json::Value(std::move(report)));return code;};
 writeIR(*trial,dir+"/parent.ll");
 for(auto &bb:*f)if(!bb.getTerminator()->getMetadata("decision.origin"))bb.getTerminator()->setMetadata("decision.origin",MDNode::get(ctx,MDString::get(ctx,f->getName().str()+":"+label(&bb))));
 if(argc==7){auto buf=MemoryBuffer::getFile(argv[6]);if(!buf)return finish("order_file_unreadable",3);auto parsed=json::parse((*buf)->getBuffer());if(!parsed){consumeError(parsed.takeError());return finish("invalid_order_json",3);}auto *array=parsed->getAsArray();if(!array)return finish("order_array_required",3);
  for(auto &v:*array){auto *o=v.getAsObject();if(!o)return finish("invalid_order_entry",3);auto entry=o->getString("entry"),family=o->getString("family");auto index=o->getInteger("index");if(!entry||!family||!index)return finish("invalid_order_entry",3);for(auto &b:*f)if(label(&b)==*entry&&!b.getTerminator()->getMetadata("decision.order")){auto *n=ConstantAsMetadata::get(ConstantInt::get(Type::getInt32Ty(ctx),*index));b.getTerminator()->setMetadata("decision.order",MDNode::get(ctx,{MDString::get(ctx,*family),n,n}));}}
 }
 auto ds=decision::discover(*f);unsigned di=std::stoul(argv[3]),li=std::stoul(argv[4]);if(di>=ds.size()||li+1>=ds[di].arms.size())return finish("pair_out_of_range",3);
 report["decision"]=ds[di].id;report["left"]=ds[di].arms[li].id;report["right"]=ds[di].arms[li+1].id;
 BasicBlock *dispatch=nullptr;std::string reason;
 if(!decision::normalize(*f,ds[di],li,reason,&dispatch))return finish(reason,3);
 auto *order=dispatch->getTerminator()->getMetadata("decision.order");
 auto *origins=dispatch->getTerminator()->getMetadata("decision.merged_from");auto *identity=dispatch->getTerminator()->getMetadata("decision.origin");
 BasicBlock *bindingEntry=dispatch;
 // When the last arms of an already-normalized subdecision are fused, the
 // opaque arm must include its short-circuit evaluation prefix as well.
 {PostDominatorTree beforePDT(*f);std::set<BasicBlock*> visited;
  while(visited.insert(bindingEntry).second&&bindingEntry->getTerminator()->getMetadata("decision.short_gate")){
   auto *br=dyn_cast<BranchInst>(bindingEntry->getTerminator());auto *phi=br&&br->isConditional()?dyn_cast<PHINode>(br->getCondition()):nullptr;BasicBlock *owner=nullptr;
   if(phi)for(unsigned i=0;i<phi->getNumIncomingValues();++i){auto *v=dyn_cast<ConstantInt>(phi->getIncomingValue(i));auto *p=phi->getIncomingBlock(i);auto *pb=dyn_cast<BranchInst>(p->getTerminator());if(v&&v->isOne()&&pb&&pb->isConditional()&&beforePDT.dominates(bindingEntry,p)&&(pb->getSuccessor(0)==bindingEntry||pb->getSuccessor(1)==bindingEntry))owner=p;}
   if(!owner)break;bindingEntry=owner;
  }
 }
 writeIR(*trial,dir+"/normalized.ll");
 auto normalized=decision::discover(*f);const decision::Decision *pair=nullptr;for(auto &d:normalized)if(d.root==dispatch)pair=&d;
 if(!pair||pair->arms.size()!=2)return finish("normalized_pair_not_found",3);
 if(pair->arms[0].kind==decision::ArmKind::Unsupported||pair->arms[1].kind==decision::ArmKind::Unsupported)return finish("unsupported_normalized_arm",3);
 bool bothLinear=pair->arms[0].kind==decision::ArmKind::Linear&&pair->arms[1].kind==decision::ArmKind::Linear;
 auto *join=pair->join;std::set<BasicBlock*> scope{dispatch,join};for(auto &a:pair->arms)scope.insert(a.blocks.begin(),a.blocks.end());
 std::vector<OutsideInstruction> audit;
 for(auto &bb:*f)if(!scope.count(&bb))for(auto &i:bb){OutsideInstruction x;x.instruction=&i;{raw_string_ostream text(x.original);i.print(text);text.flush();}for(auto &op:i.operands())x.operands.emplace_back(op.get());audit.push_back(std::move(x));}
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
 if(bothLinear&&(left->getSingleSuccessor()!=join||right->getSingleSuccessor()!=join))return finish("B2B_exit_mismatch",3);
 DominatorTree dt(*f);PostDominatorTree pdt(*f);RegionAnalyzer analyzer(dispatch,dt,pdt);
 if(bothLinear)analyzer.selectExplicitBlocks(left,right);else {
  // Reuse the native similarity, but do not call a match of empty plumbing
  // a computation fusion. Restrict anchors to must-execute blocks in each arm.
  BasicBlock *bestL=nullptr,*bestR=nullptr;double best=-1;
  auto useful=[](BasicBlock *l,BasicBlock *r){for(auto &a:*l)if(!a.isTerminator()&&!isa<PHINode>(a))for(auto &b:*r)if(!b.isTerminator()&&!isa<PHINode>(b)&&InstructionMatch::match(&a,&b))return true;return false;};
  std::set<BasicBlock*> lb(pair->arms[0].blocks.begin(),pair->arms[0].blocks.end()),rb(pair->arms[1].blocks.begin(),pair->arms[1].blocks.end());
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
 RegionMelder melder(analyzer,true);melder.SpeculationMode=0;
 WeakVH dispatchHandle(dispatch);melder.merge(0);
 if(!dispatchHandle)return finish("dispatch_deleted_identity_unknown",3);
 dispatch=cast<BasicBlock>((Value*)dispatchHandle);
 // RegionMelder can replace the dispatch terminator: restore logical identity
 // on the surviving owned block, never on an arbitrary replacement value.
 dispatch->getTerminator()->setMetadata("decision.merged_from",origins);
 dispatch->getTerminator()->setMetadata("decision.origin",identity);
 if(order)dispatch->getTerminator()->setMetadata("decision.order",order);
 if(verifyModule(*trial,&errs()))return finish("post_meld_verifier_failed",3);
 writeIR(*trial,dir+"/meld-raw.ll");
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
 report["binding_entry"]=label(bindingEntry);
 writeIR(*trial,dir+"/fused.ll");
 auto rebound=decision::discover(*f);unsigned bindings=0;std::string kind;
 for(auto &d:rebound)if(d.id==ds[di].id)for(auto &a:d.arms)if(a.entry==bindingEntry&&a.kind!=decision::ArmKind::Unsupported){++bindings;kind=a.kind==decision::ArmKind::Linear?"Linear":"SESE";}
 if(bindings==0&&ds[di].arms.size()==2){
  DominatorTree dtAfter(*f);PostDominatorTree pdtAfter(*f);auto *exit=ds[di].join;bool owned=pdtAfter.dominates(exit,bindingEntry);std::set<BasicBlock*> visited;std::vector<BasicBlock*> todo{bindingEntry};bool linear=true;
  while(!todo.empty()){auto *b=todo.back();todo.pop_back();if(b==exit||!visited.insert(b).second)continue;if(!dtAfter.dominates(bindingEntry,b))owned=false;if(b->getTerminator()->getNumSuccessors()!=1)linear=false;for(auto *next:successors(b))todo.push_back(next);}
  if(owned){bindings=1;kind=linear?"Linear":"SESE";report["completed_decision"]=true;}
 }
 report["rebound_bindings"]=bindings;report["rebound_kind"]=kind;report["speculated_gap_ranges"]=melder.SpeculatedRanges;report["outside_audit"]="preserved instructions and SSA-tracked operands";
 {std::error_code ec;raw_fd_ostream out(dir+"/decisions.json",ec,sys::fs::OF_None);out<<formatv("{0:2}\n",json::Value(decision::describe(rebound)));}
 if(bindings!=1)return finish("merged_arm_binding_not_unique",3);
 return finish("fused_and_rebound",0);
}
