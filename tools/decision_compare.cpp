#include "decision_compare.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/Analysis/DominanceFrontier.h"
#include "llvm/Analysis/PostDominators.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/CFG.h"
#include <map>
#include <set>
#include <functional>
using namespace llvm;
namespace decision {
json::Object compareLegacy(Function &f,const std::vector<Decision>&ds,const json::Object &catalog){
 DominatorTree dt(f);PostDominatorTree pdt(f);DominanceFrontier df;df.analyze(dt);RegionInfo ri;ri.recalculate(f,&dt,&pdt,&df);
 using Blocks=std::set<BasicBlock*>;
 std::map<std::string,Blocks> units;std::vector<BasicBlock*> order;
 unsigned n=0;for(auto &b:f){units["B"+std::to_string(n++)]={&b};order.push_back(&b);}
 n=0;std::function<void(Region*)> visit=[&](Region*r){Blocks bs;for(auto *b:r->blocks())bs.insert(b);units["R"+std::to_string(n++)]=bs;for(auto &c:*r)visit(c.get());};visit(ri.getTopLevelRegion());
 auto decode=[&](StringRef id)->Blocks{
  auto found=units.find(id.str());if(found!=units.end())return found->second;
  unsigned entry=0,exit=0;
  if(id.startswith("E")){auto p=id.drop_front().split('_');if(p.first.getAsInteger(10,entry)||p.second.getAsInteger(10,exit)||entry>=order.size()||exit>=order.size())return {};}
  else if(id.startswith("G")){unsigned k=0;if(id.drop_front().getAsInteger(10,k)||k>=order.size())return {};auto *t=order[k]->getTerminator();auto *pn=pdt.getNode(order[k]);if(t->getNumSuccessors()!=2||!pn||!pn->getIDom()||!pn->getIDom()->getBlock())return {};auto *e=t->getSuccessor(0),*x=pn->getIDom()->getBlock();entry=std::find(order.begin(),order.end(),e)-order.begin();exit=std::find(order.begin(),order.end(),x)-order.begin();}
  else return {};
  Blocks bs;std::vector<BasicBlock*> todo{order[entry]};while(!todo.empty()){auto *b=todo.back();todo.pop_back();if(b==order[exit]||!bs.insert(b).second)continue;for(auto *s:successors(b))todo.push_back(s);}return bs;
 };
 json::Array rows;std::map<std::string,unsigned> counts;std::set<std::string> covered;
 auto *candidates=catalog.getArray("candidates");if(!candidates)return json::Object{{"error","missing_candidates"}};
 for(auto &cv:*candidates){auto *c=cv.getAsObject();if(!c)continue;auto l=c->getString("left"),r=c->getString("right"),key=c->getString("candidate");if(!l||!r)continue;
  auto lbs=decode(*l),rbs=decode(*r);std::string status="no_same_decision",match;
  if(lbs.empty()||rbs.empty())status="unresolved_old_unit";
  else for(auto &d:ds)for(unsigned i=0;i<d.arms.size();++i)for(unsigned j=i+1;j<d.arms.size();++j){
   Blocks a(d.arms[i].blocks.begin(),d.arms[i].blocks.end()),b(d.arms[j].blocks.begin(),d.arms[j].blocks.end());
   bool exact=(a==lbs&&b==rbs)||(a==rbs&&b==lbs);
   auto subset=[](const Blocks &x,const Blocks &y){return std::includes(y.begin(),y.end(),x.begin(),x.end());};
   bool partial=(subset(lbs,a)&&subset(rbs,b))||(subset(rbs,a)&&subset(lbs,b));
   if(exact){match=d.id+":"+std::to_string(i)+":"+std::to_string(j);status=d.arms[i].kind==ArmKind::Unsupported||d.arms[j].kind==ArmKind::Unsupported?"unsupported_arm":j==i+1?"exact_adjacent":"nonadjacent";covered.insert(match);}
   else if(partial&&status=="no_same_decision")status="partial_arm_units";
  }
  ++counts[status];rows.push_back(json::Object{{"candidate",key?key->str():""},{"classification",status},{"new_pair",match}});
 }
 json::Array fresh;for(auto &d:ds)for(unsigned i=0;i+1<d.arms.size();++i){auto key=d.id+":"+std::to_string(i)+":"+std::to_string(i+1);fresh.push_back(json::Object{{"pair",key},{"supported",d.arms[i].kind!=ArmKind::Unsupported&&d.arms[i+1].kind!=ArmKind::Unsupported},{"old_exact_match",bool(covered.count(key))}});}
 json::Object summary;for(auto &p:counts)summary[p.first]=p.second;
 return json::Object{{"schema","decision-comparison-v1"},{"scope","same input IR; structural coverage only, no legality or performance claim"},{"summary",std::move(summary)},{"old_pairs",std::move(rows)},{"new_adjacent_pairs",std::move(fresh)}};
}
}
