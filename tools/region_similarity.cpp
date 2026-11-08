#include "RegionAnalyzer.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/CFG.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FormatVariadic.h"
#include <map>
#include <set>
#include <vector>
#include <functional>
#include <cmath>
using namespace llvm;
struct Unit {std::string id; Region *region=nullptr; BasicBlock *entry=nullptr; BasicBlock *exit=nullptr;std::set<BasicBlock*> blocks;};
static std::string str(const json::Object&o,StringRef key){return o.getString(key).getValueOr("").str();}
static std::string operand(const Value*V){if(!V)return "<virtual-exit>";std::string s;raw_string_ostream out(s);V->printAsOperand(out,false);return out.str();}
int main(int argc,char**argv){
 if(argc!=3){errs()<<"usage: region-similarity INPUT.ll INVENTORY.json\n";return 2;}
 LLVMContext C;SMDiagnostic Err;auto M=parseIRFile(argv[1],Err,C);if(!M){Err.print(argv[0],errs());return 1;}
 auto buffer=MemoryBuffer::getFile(argv[2]);if(!buffer){errs()<<"Cannot read inventory\n";return 1;}auto parsed=json::parse((*buffer)->getBuffer());if(!parsed){errs()<<toString(parsed.takeError());return 1;}auto*root=parsed->getAsObject();if(!root)return 1;
 std::vector<const json::Object*> inputs;for(auto name:{"functions","reachable_functions"})if(auto*a=root->getArray(name))for(auto&v:*a)if(auto*o=v.getAsObject())inputs.push_back(o);
 json::Array functions;
 for(auto*input:inputs){auto*F=M->getFunction(str(*input,"name"));if(!F||F->isDeclaration())return 3;
  DominatorTree DT(*F);PostDominatorTree PDT(*F);DominanceFrontier DF;DF.analyze(DT);RegionInfo RI;RI.recalculate(*F,&DT,&PDT,&DF);
  std::map<BasicBlock*,std::string> ids;std::map<std::string,BasicBlock*> byid;unsigned n=0;for(auto&B:*F){std::string id="B"+std::to_string(n++);ids[&B]=id;byid[id]=&B;}
  auto id=[&](BasicBlock*B){return B?ids.at(B):std::string("<virtual-exit>");};
  if(input->getArray("blocks")->size()!=F->size())return 4;
  for(auto&v:*input->getArray("blocks")){auto&o=*v.getAsObject();if(!byid.count(str(o,"id"))||operand(byid.at(str(o,"id")))!=str(o,"name"))return 4;}
  std::vector<Unit> units;std::function<void(Region*)> visit=[&](Region*R){Unit u;u.id="R"+std::to_string(units.size());u.region=R;u.entry=R->getEntry();u.exit=R->getExit();for(auto*B:R->blocks())u.blocks.insert(B);units.push_back(u);for(auto&child:*R)visit(child.get());};visit(RI.getTopLevelRegion());
  auto decode=[&](const json::Array&a){std::set<BasicBlock*> ns;for(auto&v:a)ns.insert(byid.at(v.getAsString()->str()));return ns;};
  auto subset=[](const std::set<BasicBlock*>&a,const std::set<BasicBlock*>&b){for(auto*x:a)if(!b.count(x))return false;return true;};
  // A branch-side frontier consists of maximal canonical regions wholly in
  // that side, plus uncovered individual basic blocks. No order assumption.
  auto frontier=[&](const std::set<BasicBlock*>&ns){std::vector<Unit> candidates,result;std::set<BasicBlock*> covered;
   for(auto&u:units)if(u.exit&&!u.blocks.empty()&&subset(u.blocks,ns))candidates.push_back(u);
   for(auto&u:candidates){bool inside=false;for(auto&v:candidates)if(u.id!=v.id&&u.blocks.size()<v.blocks.size()&&subset(u.blocks,v.blocks)){inside=true;break;}if(!inside){result.push_back(u);covered.insert(u.blocks.begin(),u.blocks.end());}}
   for(auto&B:*F)if(ns.count(&B)&&!covered.count(&B)){Unit u;u.id=id(&B);u.entry=&B;u.exit=B.getSingleSuccessor();u.blocks.insert(&B);result.push_back(u);}return result;};
  auto names=[&](const std::set<BasicBlock*>&ns){json::Array a;for(auto&B:*F)if(ns.count(&B))a.push_back(id(&B));return a;};
  auto describe=[&](const Unit&u){return json::Object{{"id",u.id},{"kind",u.region?"canonical_region":"basic_block"},{"entry",id(u.entry)},{"entry_name",operand(u.entry)},{"exit",id(u.exit)},{"blocks",names(u.blocks)}};};
  auto cyclic=[&](const Unit&u){std::map<BasicBlock*,int> color;std::function<bool(BasicBlock*)> dfs=[&](BasicBlock*B){if(color[B]==1)return true;if(color[B]==2)return false;color[B]=1;for(auto*S:successors(B))if(u.blocks.count(S)&&dfs(S))return true;color[B]=2;return false;};for(auto*B:u.blocks)if(!color[B]&&dfs(B))return true;return false;};
  json::Array pairs,skipped;std::map<std::string,int64_t> statuses;int64_t scored=0,above=0;
  auto emit=[&](const Unit&L,const Unit&R,std::string relation,std::string context,BasicBlock*split,BasicBlock*leftStart,BasicBlock*rightStart,bool cycleContext,const std::set<BasicBlock*>&leftSide,const std::set<BasicBlock*>&rightSide){
   json::Object o{{"id","P"+std::to_string(pairs.size())},{"relation",relation},{"context",context},{"split",id(split)},{"left",describe(L)},{"right",describe(R)},{"fusion_legality","not_checked"},{"performance_benefit","not_measured"}};
   std::string status;double score=0;DenseMap<BasicBlock*,BasicBlock*> mapping;bool overlap=false;for(auto*B:L.blocks)overlap|=R.blocks.count(B)>0;
   bool exclusive=true;for(auto*B:L.blocks)exclusive&=!rightSide.count(B);for(auto*B:R.blocks)exclusive&=!leftSide.count(B);
   o["exclusive_between_sides"]=exclusive;
   if(overlap)status="overlapping_units";
   else if(!exclusive)status="nonexclusive_sides";
   else if(cycleContext||cyclic(L)||cyclic(R))status="cyclic_context_not_scored";
   else if(bool(L.region)!=bool(R.region))status="mixed_region_block_requires_mapping";
   else if(L.region){RegionComparator cmp(L.region,R.region);if(!cmp.compare())status="region_structure_mismatch";else{cmp.getMapping(mapping);std::set<BasicBlock*> values;bool complete=mapping.size()==L.blocks.size()&&L.blocks.size()==R.blocks.size();for(auto&m:mapping){complete&=L.blocks.count(m.first)&&R.blocks.count(m.second);values.insert(m.second);}complete&=values.size()==R.blocks.size();if(!complete)status="non_bijective_mapping";else{score=Utils::computeRegionSimilarity(mapping,L.exit);status="scored_region";}}}
   else{score=Utils::computeBBSimilarty(L.entry,R.entry);mapping[L.entry]=R.entry;status="scored_block";}
   bool hasScore=status=="scored_region"||status=="scored_block";if(hasScore&&!std::isfinite(score)){status="undefined_score";hasScore=false;}
   if(hasScore){scored++;above+=score>=0.2;o["similarity"]=score;o["at_least_0_2"]=score>=0.2;json::Array matches;for(auto&B:*F)if(mapping.count(&B))matches.push_back(json::Object{{"left",id(&B)},{"right",id(mapping[&B])}});o["block_mapping"]=std::move(matches);}else{o["similarity"]=nullptr;o["at_least_0_2"]=nullptr;}
   o["status"]=status;statuses[status]++;
   bool leftRequired=PDT.dominates(L.entry,leftStart),rightRequired=PDT.dominates(R.entry,rightStart);
   o["left_entry_postdominates_side_start"]=leftRequired;o["right_entry_postdominates_side_start"]=rightRequired;
   o["structural_note"]=relation=="adjacent_cascade_arms"?"Logical neighbor arms, not necessarily immediate sibling successors; restructuring/replication may be needed":(!leftRequired||!rightRequired)?"At least one unit is optional on its side; replication or another legality strategy may be needed":"No side-entry postdominance obstruction found; fusion legality still unchecked";
   pairs.push_back(std::move(o));
  };
  for(auto&value:*input->getArray("choices")){auto&choice=*value.getAsObject();auto&arms=*choice.getArray("arms");auto*split=byid.at(str(choice,"split"));bool cycle=choice.getBoolean("cyclic_or_backedge").getValueOr(false);
   for(size_t a=0;a<arms.size();a++)for(size_t b=a+1;b<arms.size();b++){auto&la=*arms[a].getAsObject();auto&ra=*arms[b].getAsObject();auto leftSide=decode(*la.getArray("blocks_until_join")),rightSide=decode(*ra.getArray("blocks_until_join"));auto left=frontier(leftSide),right=frontier(rightSide);std::string context=id(split)+":"+str(la,"edge")+"/"+str(ra,"edge");
    if(left.empty()||right.empty())skipped.push_back(json::Object{{"relation","same_split_frontiers"},{"context",context},{"reason","empty arm before join; no computation region"}});
    for(auto&L:left)for(auto&R:right)emit(L,R,"same_split_frontiers",context,split,byid.at(str(la,"entry")),byid.at(str(ra,"entry")),cycle,leftSide,rightSide);
   }
  }
  // Logical adjacency is defined by the exported conservative cascade order,
  // never by block layout or source line proximity.
  for(auto&value:*input->getArray("groups")){auto&group=*value.getAsObject();auto&arms=*group.getArray("arms");auto*head=byid.at(str(group,"head"));
   for(size_t a=0;a+1<arms.size();a++){auto&la=*arms[a].getAsObject();auto&ra=*arms[a+1].getAsObject();auto leftSide=decode(*la.getArray("blocks_until_join")),rightSide=decode(*ra.getArray("blocks_until_join"));auto left=frontier(leftSide),right=frontier(rightSide);std::string context=str(group,"id")+":"+std::to_string(a)+"/"+std::to_string(a+1);
    if(left.empty()||right.empty())skipped.push_back(json::Object{{"relation","adjacent_cascade_arms"},{"context",context},{"reason","empty arm/PHI-only fallback; no computation region"}});
    for(auto&L:left)for(auto&R:right)emit(L,R,"adjacent_cascade_arms",context,head,byid.at(str(la,"entry")),byid.at(str(ra,"entry")),false,leftSide,rightSide);
   }
  }
  json::Object counts;for(auto&kv:statuses)counts[kv.first]=kv.second;
  functions.push_back(json::Object{{"name",F->getName().str()},{"summary",json::Object{{"candidate_records",int64_t(pairs.size())},{"scored",scored},{"score_at_least_0_2",above},{"empty_arm_contexts",int64_t(skipped.size())},{"statuses",std::move(counts)}}},{"pairs",std::move(pairs)},{"skipped_contexts",std::move(skipped)}});
 }
 json::Object result{{"schema","llvm12-darm-neighbor-similarity-v1"},{"scope","Read-only native DARM opcode-cost scoring; no RegionAnalyzer candidate sorting and no fusion. Enumerates frontier cross-pairs across each split, plus neighboring cascade arms; not all possible region combinations. Repeated physical pairs in different contexts remain explicit."},{"score_definition","sum matched opcode cost minima / sum both costs; PHI savings excluded; original DARM fixed costs; maximum 0.5, not a speedup"},{"functions",std::move(functions)}};outs()<<formatv("{0:2}\n",json::Value(std::move(result)));return 0;
}
