#include "logical_region_state.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/FormatVariadic.h"
#include <algorithm>
#include <cmath>
#include <functional>
#include <limits>
using namespace llvm;
namespace fusion {
namespace {
using Blocks=std::set<BasicBlock*>;
std::string label(const Value*v){std::string s;raw_string_ostream o(s);v->printAsOperand(o,false);return o.str();}
Blocks scope(BasicBlock*b,BasicBlock*end){Blocks out;std::vector<BasicBlock*>q{b};while(!q.empty()){b=q.back();q.pop_back();if(b==end||!out.insert(b).second)continue;for(auto*s:successors(b))q.push_back(s);}return out;}
std::map<std::string,Blocks> units(Function&f,Analysis&a){std::map<std::string,Blocks> out;unsigned n=0;for(auto&b:f)out["B"+std::to_string(n++)]={&b};n=0;std::function<void(Region*)>visit=[&](Region*r){Blocks bs;for(auto*b:r->blocks())bs.insert(b);out["R"+std::to_string(n++)]=bs;for(auto&c:*r)visit(c.get());};visit(a.regions.getTopLevelRegion());return out;}
bool truth(FCmpInst::Predicate p,double a,double b){bool u=std::isnan(a)||std::isnan(b);switch(p){
case FCmpInst::FCMP_FALSE:return false;case FCmpInst::FCMP_TRUE:return true;
case FCmpInst::FCMP_OEQ:return !u&&a==b;case FCmpInst::FCMP_OGT:return !u&&a>b;case FCmpInst::FCMP_OGE:return !u&&a>=b;case FCmpInst::FCMP_OLT:return !u&&a<b;case FCmpInst::FCMP_OLE:return !u&&a<=b;case FCmpInst::FCMP_ONE:return !u&&a!=b;case FCmpInst::FCMP_ORD:return !u;
case FCmpInst::FCMP_UNO:return u;case FCmpInst::FCMP_UEQ:return u||a==b;case FCmpInst::FCMP_UGT:return u||a>b;case FCmpInst::FCMP_UGE:return u||a>=b;case FCmpInst::FCMP_ULT:return u||a<b;case FCmpInst::FCMP_ULE:return u||a<=b;case FCmpInst::FCMP_UNE:return u||a!=b;default:return false;}}
struct Test{Value*x;double c;FCmpInst::Predicate p;};
bool test(BasicBlock*b,Test&t){auto*br=dyn_cast<BranchInst>(b->getTerminator());auto*cmp=br&&br->isConditional()?dyn_cast<FCmpInst>(br->getCondition()):nullptr;if(!cmp||(!cmp->getOperand(0)->getType()->isFloatTy()&&!cmp->getOperand(0)->getType()->isDoubleTy()))return false;
 auto*k=dyn_cast<ConstantFP>(cmp->getOperand(1));t.p=cmp->getPredicate();t.x=cmp->getOperand(0);if(!k){k=dyn_cast<ConstantFP>(cmp->getOperand(0));t.x=cmp->getOperand(1);t.p=FCmpInst::getSwappedPredicate(t.p);}if(!k||isa<Constant>(t.x))return false;t.c=k->getType()->isFloatTy()?double(k->getValueAPF().convertToFloat()):k->getValueAPF().convertToDouble();return !std::isnan(t.c);}
}
std::shared_ptr<LogicalRegionState> LogicalRegionState::initialize(Function&f){
 auto s=std::make_shared<LogicalRegionState>();Analysis a(f);std::map<BasicBlock*,BasicBlock*> joins;
 for(auto&b:f){auto*br=dyn_cast<BranchInst>(b.getTerminator());auto*n=a.pdt.getNode(&b);if(br&&br->isConditional()&&n&&n->getIDom())joins[&b]=n->getIDom()->getBlock();}
 std::map<Instruction*,unsigned> owners;std::set<Instruction*> decisionConditions;
 for(auto&bb:f){auto*root=&bb;if(!joins.count(root))continue;auto*end=joins[root];bool nested=false;for(auto&kv:joins)if(kv.first!=root&&kv.second==end&&a.dt.dominates(kv.first,root)){nested=true;break;}if(nested)continue;
  DecisionGroup d;d.id="D"+std::to_string(s->decisions.size());d.root=label(root);d.join=label(end);d.status="unsupported";
  std::map<BasicBlock*,Test> tests;std::map<BasicBlock*,Blocks> leaves;Blocks visiting;Value*variable=nullptr;std::string reason;
  std::function<bool(BasicBlock*,unsigned)>walk=[&](BasicBlock*b,unsigned depth){if(b==end){reason="empty_arm";return false;}if(depth>128||!visiting.insert(b).second){reason="cyclic_or_shared_decision_dag";return false;}
   if(joins.count(b)&&joins[b]==end){Test t;if(!test(b,t)){reason="unsupported_predicate";return false;}if(variable&&variable!=t.x){reason="multiple_predicate_values";return false;}variable=t.x;tests[b]=t;auto*br=cast<BranchInst>(b->getTerminator());return walk(br->getSuccessor(0),depth+1)&&walk(br->getSuccessor(1),depth+1);}
   auto bs=scope(b,end);if(bs.count(root)){reason="cyclic_leaf";return false;}for(auto&kv:leaves)for(auto*x:bs)if(kv.second.count(x)){reason="overlapping_leaf_scopes";return false;}leaves[b]=std::move(bs);return true;};
  if(!walk(root,0)){d.reason=reason;s->decisions.push_back(std::move(d));continue;}
  std::vector<double> points{-std::numeric_limits<double>::infinity(),std::numeric_limits<double>::infinity()};
  for(auto&kv:tests){double c=kv.second.c;points.push_back(c);if(variable->getType()->isFloatTy()){points.push_back(std::nextafter(float(c),-std::numeric_limits<float>::infinity()));points.push_back(std::nextafter(float(c),std::numeric_limits<float>::infinity()));}else{points.push_back(std::nextafter(c,-std::numeric_limits<double>::infinity()));points.push_back(std::nextafter(c,std::numeric_limits<double>::infinity()));}}
  std::sort(points.begin(),points.end());points.erase(std::unique(points.begin(),points.end()),points.end());
  auto route=[&](double x){auto*b=root;while(tests.count(b)){auto&t=tests.at(b);b=cast<BranchInst>(b->getTerminator())->getSuccessor(truth(t.p,x,t.c)?0:1);}return b;};
  std::vector<BasicBlock*>ordered;std::set<BasicBlock*>seen;bool contiguous=true;for(double x:points){auto*b=route(x);if(ordered.empty()||ordered.back()!=b){if(!seen.insert(b).second){contiguous=false;break;}ordered.push_back(b);}}
  auto*nanLeaf=route(std::numeric_limits<double>::quiet_NaN());
  if(!contiguous||ordered.size()!=leaves.size()){d.reason=!contiguous?"noncontiguous_numeric_domain":"nan_only_or_unreachable_leaf";s->decisions.push_back(std::move(d));continue;}
  bool overlap=false;for(auto&kv:leaves)for(auto*b:kv.second)for(auto&i:*b)overlap|=owners.count(&i)!=0;
  if(overlap){d.reason="overlapping_decision_groups";s->decisions.push_back(std::move(d));continue;}
  d.status="ordered";d.reason="same_ssa_fcmp_constant_partition_float32_or_float64";d.variable=label(variable);
  for(auto &kv:tests)decisionConditions.insert(cast<Instruction>(cast<BranchInst>(kv.first->getTerminator())->getCondition()));
  for(auto&kv:tests){std::string g;raw_string_ostream o(g);kv.first->getTerminator()->print(o);o<<" ; ";cast<BranchInst>(kv.first->getTerminator())->getCondition()->print(o);d.guards.push_back(o.str());}
  std::sort(d.guards.begin(),d.guards.end());
  for(unsigned n=0;n<ordered.size();++n){auto*b=ordered[n];unsigned origin=s->nextOrigin++;LogicalGroup g;g.id=d.id+".L"+std::to_string(n);g.first=g.last=n;g.origins.insert(origin);d.history.push_back(g);d.active.push_back(n);d.leafBlocks.push_back(label(b));d.includesNaN.push_back(b==nanLeaf);for(auto*block:leaves.at(b))for(auto&i:*block)if(!i.isTerminator()&&!i.getType()->isVoidTy())owners[&i]=origin;}
  s->decisions.push_back(std::move(d));
 }
 // Track outsiders too: cleanup coalescence with a third group must not create
 // an apparently exclusive physical region. Value handles follow RAUW/deletion.
 for(auto&b:f)for(auto&i:b)if(!i.isTerminator()&&!i.getType()->isVoidTy()&&!decisionConditions.count(&i)){auto it=owners.find(&i);unsigned origin=it==owners.end()?s->nextOrigin++:it->second;s->evidence.push_back({origin,WeakTrackingVH(&i)});}
 s->rebind(f);return s;
}
std::shared_ptr<LogicalRegionState> LogicalRegionState::clone(const ValueToValueMapTy&m)const{auto out=std::make_shared<LogicalRegionState>(*this);for(auto&e:out->evidence){Value*v=e.value;if(!v)continue;auto it=m.find(v);if(it!=m.end())e.value=it->second;else if(isa<Instruction>(v))e.value=nullptr;}for(auto&d:out->decisions)for(auto&g:d.history)g.blocks.clear();return out;}
void LogicalRegionState::transfer(const ValueToValueMapTy&m){for(auto&e:evidence){Value*v=e.value;if(!v)continue;auto it=m.find(v);if(it!=m.end())e.value=it->second;}}
void LogicalRegionState::rebind(Function&f){std::map<BasicBlock*,std::set<unsigned>>blockOrigins;std::map<unsigned,Blocks>originBlocks;for(auto&e:evidence)if(auto*i=dyn_cast_or_null<Instruction>((Value*)e.value)){if(i->getFunction()!=&f)continue;blockOrigins[i->getParent()].insert(e.origin);originBlocks[e.origin].insert(i->getParent());}
 for(auto&d:decisions)for(auto ix:d.active){auto&g=d.history[ix];g.blocks.clear();bool missing=false;for(unsigned origin:g.origins){missing|=originBlocks[origin].empty();g.blocks.insert(originBlocks[origin].begin(),originBlocks[origin].end());}
  g.status="tracked_exclusive";g.reason="surviving_value_origins_exclusive; DARM_legality_rechecked_per_trial";
  if(g.blocks.empty()){g.status="eliminated_or_unresolved";g.reason="no_surviving_instruction_evidence";}
  else if(missing){g.status="unresolved";g.reason="some_leaf_origins_have_no_surviving_instruction_evidence";}
  else for(auto*b:g.blocks)for(unsigned origin:blockOrigins[b])if(!g.origins.count(origin)){g.status="shared_or_coalesced";g.reason="physical_block_contains_other_origins";}
 }
}
std::vector<Candidate> LogicalRegionState::filter(Function&f,const std::vector<Candidate>&all)const{Analysis a(f);auto u=units(f,a);std::vector<Candidate>out;for(auto c:all){if(c.version!=version||!u.count(c.left)||!u.count(c.right))continue;bool found=false;for(auto&d:decisions){if(d.status!="ordered")continue;for(unsigned n=1;n<d.active.size();++n){auto&l=d.history[d.active[n-1]];auto&r=d.history[d.active[n]];if(l.last+1!=r.first||l.status!="tracked_exclusive"||r.status!="tracked_exclusive")continue;
 if((u.at(c.left)==l.blocks&&u.at(c.right)==r.blocks)||(u.at(c.right)==l.blocks&&u.at(c.left)==r.blocks)){c.logicalDecision=d.id;c.logicalLeft=l.id;c.logicalRight=r.id;found=true;break;}}if(found)break;}if(found)out.push_back(std::move(c));}return out;}
bool LogicalRegionState::stageMerge(const Candidate&c){if(c.version!=version)return false;for(auto&d:decisions)if(d.id==c.logicalDecision)for(unsigned n=1;n<d.active.size();++n){auto&l=d.history[d.active[n-1]];auto&r=d.history[d.active[n]];if(l.id!=c.logicalLeft||r.id!=c.logicalRight||l.last+1!=r.first)continue;LogicalGroup g;g.id=d.id+".G"+std::to_string(d.nextGroup++);g.left=l.id;g.right=r.id;g.first=l.first;g.last=r.last;g.origins=l.origins;g.origins.insert(r.origins.begin(),r.origins.end());d.history.push_back(std::move(g));d.active[n-1]=d.history.size()-1;d.active.erase(d.active.begin()+n);++version;return true;}return false;}
std::string LogicalRegionState::json()const{json::Array ds;for(auto&d:decisions){json::Array leaves,guards,active,hist;for(unsigned n=0;n<d.leafBlocks.size();++n)leaves.push_back(json::Object{{"id",d.id+".L"+std::to_string(n)},{"initial_block",d.leafBlocks[n]},{"includes_nan",bool(d.includesNaN[n])}});for(auto&g:d.guards)guards.push_back(g);for(auto i:d.active)active.push_back(d.history[i].id);for(auto&g:d.history){json::Array bs,orig;std::vector<std::string>names;for(auto*b:g.blocks)names.push_back(label(b));std::sort(names.begin(),names.end());for(auto&b:names)bs.push_back(b);for(auto o:g.origins)orig.push_back(int64_t(o));hist.push_back(json::Object{{"id",g.id},{"left",g.left},{"right",g.right},{"first",int64_t(g.first)},{"last",int64_t(g.last)},{"status",g.status},{"reason",g.reason},{"blocks",std::move(bs)},{"origins",std::move(orig)}});}ds.push_back(json::Object{{"id",d.id},{"root",d.root},{"join",d.join},{"variable",d.variable},{"status",d.status},{"reason",d.reason},{"leaves",std::move(leaves)},{"initial_guards",std::move(guards)},{"active",std::move(active)},{"history",std::move(hist)}});}return formatv("{0:2}\n",json::Value(json::Object{{"schema","logical-region-state-v1"},{"version",int64_t(version)},{"binding_contract","conservative surviving instruction provenance; not a semantic equivalence proof"},{"decisions",std::move(ds)}})).str();}
}
