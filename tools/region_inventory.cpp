#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/DebugInfoMetadata.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Analysis/PostDominators.h"
#include "llvm/Analysis/DominanceFrontier.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/FormatVariadic.h"
#include <map>
#include <set>
#include <vector>
#include <functional>
using namespace llvm;
static std::string operand(const Value *V){if(!V)return "<virtual-exit>";std::string s;raw_string_ostream o(s);V->printAsOperand(o,false);return o.str();}
static std::string instruction(const Instruction *I){std::string s;raw_string_ostream o(s);I->print(o);return o.str();}
static std::set<BasicBlock*> reachable(BasicBlock *start,BasicBlock *stop){std::set<BasicBlock*> seen;std::vector<BasicBlock*> todo{start};while(!todo.empty()){auto *b=todo.back();todo.pop_back();if(b==stop||!seen.insert(b).second)continue;for(auto *s:successors(b))todo.push_back(s);}return seen;}
int main(int argc,char**argv){
 if(argc<2||argc>3){errs()<<"usage: region-inventory INPUT.ll [function-name-substring]\n";return 2;}
 LLVMContext C;SMDiagnostic Err;auto M=parseIRFile(argv[1],Err,C);if(!M){Err.print(argv[0],errs());return 1;}
 std::set<Function*> kernels;
 if(auto*N=M->getNamedMetadata("nvvm.annotations"))for(auto*op:N->operands())if(op->getNumOperands()>=2){auto*s=dyn_cast<MDString>(op->getOperand(1));auto*v=dyn_cast<ValueAsMetadata>(op->getOperand(0));if(s&&s->getString()=="kernel"&&v)if(auto*f=dyn_cast<Function>(v->getValue()))kernels.insert(f);}
 json::Array functions;
 for(auto&F:*M){if(F.isDeclaration()||(argc==3&&!F.getName().contains(argv[2])))continue;
  DominatorTree DT(F);PostDominatorTree PDT(F);DominanceFrontier DF;DF.analyze(DT);RegionInfo RI;RI.recalculate(F,&DT,&PDT,&DF);LoopInfo LI(DT);
  std::map<BasicBlock*,std::string> ids;int nb=0;for(auto&B:F)ids[&B]="B"+std::to_string(nb++);
  auto id=[&](BasicBlock*B){return B?ids.at(B):std::string("<virtual-exit>");};
  auto arr=[&](const std::set<BasicBlock*>& set){json::Array a;for(auto&B:F)if(set.count(&B))a.push_back(id(&B));return a;};
  json::Array blocks,choices,regions,groups;int conds=0,switches=0,selects=0,backedges=0,loops=0,regionCount=0;
  std::map<BasicBlock*,BasicBlock*> joins,next;std::map<BasicBlock*,int> incoming;
  for(auto&B:F){json::Array succ,pred,selectList;auto*T=B.getTerminator();for(auto*S:successors(&B)){succ.push_back(id(S));if(DT.dominates(S,&B))backedges++;}for(auto*P:predecessors(&B))pred.push_back(id(P));
   for(auto&I:B)if(isa<SelectInst>(I)){selects++;selectList.push_back(instruction(&I));}
   auto*node=PDT.getNode(&B);BasicBlock*J=node&&node->getIDom()?node->getIDom()->getBlock():nullptr;joins[&B]=J;
   json::Object block{{"id",id(&B)},{"name",operand(&B)},{"instruction_count",int64_t(B.size())},{"successors",std::move(succ)},{"predecessors",std::move(pred)},{"terminator",instruction(T)},{"selects",std::move(selectList)},{"loop_depth",int64_t(LI.getLoopDepth(&B))},{"immediate_postdominator",id(J)}};
   blocks.push_back(std::move(block));
   auto*Br=dyn_cast<BranchInst>(T);bool conditional=Br&&Br->isConditional();auto*Sw=dyn_cast<SwitchInst>(T);if(conditional)conds++;if(Sw)switches++;if(!conditional&&!Sw)continue;
   json::Array arms;std::set<BasicBlock*> unionMembers;bool edgeBack=false;std::vector<std::set<BasicBlock*>> members;
   for(unsigned i=0;i<T->getNumSuccessors();i++){auto*S=T->getSuccessor(i);auto nodes=reachable(S,J);edgeBack|=DT.dominates(S,&B)||nodes.count(&B);unionMembers.insert(nodes.begin(),nodes.end());members.push_back(nodes);
    std::string edge=conditional?(i==0?"true":"false"):(i==0?"default":operand((Sw->case_begin()+(i-1))->getCaseValue()));
    arms.push_back(json::Object{{"edge",edge},{"entry",id(S)},{"blocks_until_join",arr(nodes)}});
   }
   bool shared=false;for(size_t a=0;a<members.size();a++)for(size_t b=a+1;b<members.size();b++)for(auto*B:members[a])shared|=members[b].count(B)>0;
   Value*condition=conditional?Br->getCondition():Sw->getCondition();std::string expr=operand(condition);if(auto*I=dyn_cast<Instruction>(condition))expr=instruction(I);
   json::Object ch{{"split",id(&B)},{"kind",conditional?"conditional_branch":"switch"},{"condition",expr},{"join",id(J)},{"arms",std::move(arms)},{"cyclic_or_backedge",edgeBack},{"shared_arm_blocks",shared},{"loop_depth",int64_t(LI.getLoopDepth(&B))}};
   if(auto dl=T->getDebugLoc())ch["source_location"]=json::Object{{"file",dl->getFilename().str()},{"line",int64_t(dl.getLine())}};
   choices.push_back(std::move(ch));
  }
  std::function<void(Region*,std::string,int)> visit=[&](Region*R,std::string parent,int depth){std::string rid="R"+std::to_string(regionCount++);std::set<BasicBlock*> ns;for(auto*B:R->blocks())ns.insert(B);regions.push_back(json::Object{{"id",rid},{"parent",parent},{"depth",depth},{"entry",id(R->getEntry())},{"exit",id(R->getExit())},{"blocks",arr(ns)}});for(auto&child:*R)visit(child.get(),rid,depth+1);};visit(RI.getTopLevelRegion(),"",0);
  // Conservative direct-edge first-match cascades. A continuation must have
  // the same immediate postdominator; its sibling arm must not reach it before
  // that join. Cyclic tests are excluded. These are IR structures, not source IDs.
  for(auto&B:F){auto*Br=dyn_cast<BranchInst>(B.getTerminator());if(!Br||!Br->isConditional()||!joins[&B])continue;std::vector<BasicBlock*> candidates;
   for(unsigned i=0;i<2;i++){auto*S=Br->getSuccessor(i);auto*SB=dyn_cast<BranchInst>(S->getTerminator());if(!SB||!SB->isConditional()||joins[S]!=joins[&B]||!DT.dominates(&B,S)||DT.dominates(S,&B))continue;
    auto a=reachable(Br->getSuccessor(1-i),joins[&B]);auto b=reachable(S,joins[&B]);if(a.count(S)||a.count(&B)||b.count(&B))continue;candidates.push_back(S);
   }if(candidates.size()==1){next[&B]=candidates[0];incoming[candidates[0]]++;}
  }
  for(auto&B:F)if(next.count(&B)&&incoming[&B]==0){std::vector<BasicBlock*> chain;std::set<BasicBlock*> seen;auto*cur=&B;while(cur&&seen.insert(cur).second){chain.push_back(cur);cur=next.count(cur)?next[cur]:nullptr;}if(chain.size()<2)continue;json::Array tests,arms;for(size_t i=0;i<chain.size();i++){auto*T=cast<BranchInst>(chain[i]->getTerminator());tests.push_back(id(chain[i]));for(unsigned j=0;j<2;j++){auto*S=T->getSuccessor(j);if(i+1<chain.size()&&S==chain[i+1])continue;arms.push_back(json::Object{{"test",id(chain[i])},{"edge",j==0?"true":"false"},{"entry",id(S)},{"blocks_until_join",arr(reachable(S,joins[&B]))}});}}
   groups.push_back(json::Object{{"id","G"+std::to_string(groups.size())},{"kind","direct_first_match_cascade"},{"head",id(&B)},{"join",id(joins[&B])},{"tests",std::move(tests)},{"arms",std::move(arms)},{"source_equivalence","not inferred without source/debug evidence"}});
  }
  for(auto*L:LI.getLoopsInPreorder()){(void)L;loops++;}
  json::Array callees;std::set<std::string> names;for(auto&B:F)for(auto&I:B)if(auto*CB=dyn_cast<CallBase>(&I))if(auto*CF=CB->getCalledFunction())if(!CF->isIntrinsic())names.insert(CF->getName().str());for(auto&n:names)callees.push_back(n);
  json::Object f{{"name",F.getName().str()},{"kernel",kernels.count(&F)>0||F.getCallingConv()==CallingConv::AMDGPU_KERNEL},{"summary",json::Object{{"blocks",nb},{"conditional_branches",conds},{"switches",switches},{"selects",selects},{"canonical_regions_including_root",regionCount},{"loops",loops},{"backedges",backedges},{"multiway_cascades",int64_t(groups.size())}}},{"blocks",std::move(blocks)},{"choices",std::move(choices)},{"regions",std::move(regions)},{"groups",std::move(groups)},{"callees",std::move(callees)}};functions.push_back(std::move(f));
 }
 json::Object result{{"schema","llvm12-region-inventory-v1"},{"input",argv[1]},{"scope","Read-only LLVM12 analysis. Canonical RegionInfo tree; all branch/switch choices; selects separate. Cascades are conservative structural groups, not semantic source branches. No fusion legality or profitability implied."},{"functions",std::move(functions)}};
 outs()<<formatv("{0:2}\n",json::Value(std::move(result)));return 0;
}
