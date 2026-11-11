#pragma once

#include "condition_simplify.h"
#include "decision_model.h"
#include "llvm/ADT/BitVector.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/IntrinsicInst.h"
#include <map>
#include <set>

namespace decision {
using namespace llvm;

enum class PathTruth { Unknown, False, True };
inline PathTruth pathTruth(bool value) {
 return value?PathTruth::True:PathTruth::False;
}

// IDs for opaque values are tied to live values in this trial. Duplicate
// deterministic pure expressions share a key even before CSE.
class UniformValueKeys {
 DenseMap<Value*,unsigned> indices;
 std::vector<WeakVH> values;
public:
 const std::vector<WeakVH> &anchors() const { return values; }

 void bind(std::vector<WeakVH> anchors) {
  values=std::move(anchors);
  for(unsigned i=0;i<values.size();++i)
   if(auto *value=static_cast<Value*>(values[i]))indices[value]=i;
 }

 std::string get(Value *value) {
  if(auto *call=dyn_cast<IntrinsicInst>(value))
   if(call->getIntrinsicID()==Intrinsic::fabs&&call->arg_size()==1&&
      !call->getFastMathFlags().any()&&!isa<UndefValue>(call->getArgOperand(0)))
    return "fabs("+get(call->getArgOperand(0))+")";
  if(auto *cast=dyn_cast<CastInst>(value))if(!isa<UndefValue>(cast->getOperand(0))){
   std::string type;raw_string_ostream stream(type);
   cast->getType()->print(stream);stream.flush();
   return std::string(cast->getOpcodeName())+"("+type+","+get(cast->getOperand(0))+")";
  }
  auto it=indices.find(value);
  if(it!=indices.end()&&values[it->second]==value)return std::to_string(it->second);
  unsigned id=values.size();values.emplace_back(value);indices[value]=id;
  return std::to_string(id);
 }
};

struct UniformAtom {
 std::string key;
 CmpInst::Predicate predicate;
 Constant *constant;
};

inline Optional<UniformAtom> uniformAtom(Value *v,UniformValueKeys &keys) {
 auto *cmp=dyn_cast<CmpInst>(v);
 if(!cmp)return None;
 auto *bound=comparisonConstant(cmp);
 auto *input=comparisonVariable(cmp);
 if(!bound||(!isa<ConstantInt>(bound)&&!isa<ConstantFP>(bound))||
    input->getType()->isVectorTy()||isa<UndefValue>(input))return None;
 return UniformAtom{keys.get(input),comparisonPredicate(cmp),bound};
}

struct UniformFormula {
 std::string key;
 std::vector<Constant*> bounds;
 std::function<bool(Constant*)> evaluate;
};

// Apply an entire predicate edge when its Boolean DAG compares one scalar.
// Different scalar domains are not correlated.
inline Optional<UniformFormula> uniformFormula(Value *value,UniformValueKeys &keys,
                                               unsigned &budget) {
 if(!budget||!value->getType()->isIntegerTy(1))return None;
 --budget;
 if(auto *constant=dyn_cast<ConstantInt>(value)){
  bool bit=constant->isOne();
  return UniformFormula{{},{},[bit](Constant*){return bit;}};
 }
 if(auto atom=uniformAtom(value,keys))
  return UniformFormula{atom->key,{atom->constant},[atom](Constant *cell){
    return CellSpace::compare(atom->predicate,cell,atom->constant);
  }};
 unsigned opcode;
 if(auto *op=dyn_cast<BinaryOperator>(value))opcode=op->getOpcode();
 else if(isa<SelectInst>(value))opcode=Instruction::Select;
 else return None;
 if(opcode!=Instruction::And&&opcode!=Instruction::Or&&
    opcode!=Instruction::Xor&&opcode!=Instruction::Select)return None;
 std::string key;
 std::vector<Constant*> bounds;
 std::vector<std::function<bool(Constant*)>> terms;
 for(auto &operand:cast<Instruction>(value)->operands()){
  auto part=uniformFormula(operand,keys,budget);
  if(!part||(!key.empty()&&!part->key.empty()&&key!=part->key))return None;
  if(key.empty())key=part->key;
  bounds.insert(bounds.end(),part->bounds.begin(),part->bounds.end());
  terms.push_back(std::move(part->evaluate));
 }
 return UniformFormula{std::move(key),std::move(bounds),[opcode,terms=std::move(terms)](Constant *cell){
  bool a=terms[0](cell);
  if(opcode==Instruction::Select)return terms[a?1:2](cell);
  bool b=terms[1](cell);
  if(opcode==Instruction::And)return a&&b;
  if(opcode==Instruction::Or)return a||b;
  return a!=b;
 }};
}

struct UniformPath {
 std::vector<std::pair<UniformAtom,bool>> atoms;
 std::vector<std::pair<UniformFormula,bool>> formulas;
 std::vector<std::pair<WeakVH,bool>> arguments;
 std::map<BasicBlock*,unsigned> originalEdges;
};

inline void assumeUniform(Value *value,bool expected,UniformValueKeys &keys,
                          UniformPath &path) {
 if(auto atom=uniformAtom(value,keys)){
  path.atoms.emplace_back(*atom,expected);return;
 }
 if(isa<Argument>(value)){
  path.arguments.emplace_back(WeakVH(value),expected);return;
 }
 unsigned budget=128;
 if(auto formula=uniformFormula(value,keys,budget))if(!formula->key.empty()){
  path.formulas.emplace_back(std::move(*formula),expected);
  return;
 }
 auto *op=dyn_cast<BinaryOperator>(value);
 if(!op||!op->getType()->isIntegerTy(1))return;
 auto opcode=op->getOpcode();
 if((opcode==Instruction::And&&expected)||(opcode==Instruction::Or&&!expected)){
  assumeUniform(op->getOperand(0),expected,keys,path);
  assumeUniform(op->getOperand(1),expected,keys,path);
 }else if(opcode==Instruction::Xor)
  for(unsigned i=0;i<2;++i)if(auto *constant=dyn_cast<ConstantInt>(op->getOperand(i))){
   assumeUniform(op->getOperand(1-i),expected!=constant->isOne(),keys,path);
   break;
  }
}

struct UniformArmFacts {
 std::string id;
 std::vector<UniformPath> paths;
 std::set<BasicBlock*> originalBlocks;
};
inline std::vector<UniformArmFacts> uniformFacts(const Decision &decision,
                                                 UniformValueKeys &keys) {
 std::vector<UniformArmFacts> result;
 for(const auto &arm:decision.arms){
  UniformArmFacts facts;facts.id=arm.id;
  facts.originalBlocks.insert(arm.blocks.begin(),arm.blocks.end());
  // The original path includes the shared suffix up to the decision join.
  // Private arm ownership is narrower than the accounting scope.
  auto suffix=arm.exitTargets;
  while(!suffix.empty()){
   auto *block=suffix.back();suffix.pop_back();
   if(block==decision.join||!facts.originalBlocks.insert(block).second)continue;
   for(auto *next:successors(block))suffix.push_back(next);
  }
  for(const auto &edges:arm.alternatives){
   UniformPath path;
   for(const auto &edge:edges){
    path.originalEdges[edge.test]=edge.successor;
    facts.originalBlocks.insert(edge.test);
    auto *term=edge.test->getTerminator();
    if(auto *br=dyn_cast<BranchInst>(term)){
     if(br->isConditional())assumeUniform(br->getCondition(),edge.successor==0,keys,path);
    }else if(auto *sw=dyn_cast<SwitchInst>(term)){
     auto *value=sw->getCondition();
     for(auto c:sw->cases()){
      const bool chosen=c.getSuccessorIndex()==edge.successor;
      if(chosen||edge.successor==0)
       path.atoms.emplace_back(UniformAtom{keys.get(value),CmpInst::ICMP_EQ,c.getCaseValue()},chosen);
     }
    }
   }
   facts.paths.push_back(std::move(path));
  }
  result.push_back(std::move(facts));
 }
 return result;
}

// Only count blocks between the decision root and its original join. A DAG
// order ensures every reachable incoming edge is known before evaluating a PHI.
// Unsupported cyclic or leaking regions are reported as unavailable.
inline Optional<std::vector<BasicBlock*>> uniformRegion(BasicBlock *root,
                                                        BasicBlock *join) {
 if(!root||!join||root==join)return None;
 DenseMap<BasicBlock*,unsigned> mark;
 std::vector<BasicBlock*> order;
 std::function<bool(BasicBlock*)> visit=[&](BasicBlock *b){
  if(b==join)return true;
  unsigned state=mark.lookup(b);
  if(state)return state==2;
  mark[b]=1;
  if(!b->getTerminator()->getNumSuccessors())return false;
  for(auto *next:successors(b))if(!visit(next))return false;
  mark[b]=2;order.push_back(b);return true;
 };
 if(!visit(root))return None;
 std::reverse(order.begin(),order.end());
 return order;
}

inline std::set<BasicBlock*> uniformReachable(
 const std::vector<BasicBlock*> &region,const UniformPath &facts,
 UniformValueKeys &keys,bool original) {
 std::map<std::string,std::vector<Constant*>> bounds;
 DenseMap<Value*,UniformAtom> atoms;
 auto &f=*region.front()->getParent();
 for(auto *b:region)for(auto &i:*b)if(auto atom=uniformAtom(&i,keys)){
  bounds[atom->key].push_back(atom->constant);atoms.insert({&i,*atom});
 }
 for(const auto &fact:facts.atoms)bounds[fact.first.key].push_back(fact.first.constant);
 for(const auto &fact:facts.formulas){
  auto &values=bounds[fact.first.key];
  values.insert(values.end(),fact.first.bounds.begin(),fact.first.bounds.end());
 }
 struct Domain {CellSpace space;BitVector possible;};
 std::map<std::string,Domain> domains;
 for(const auto &entry:bounds){
  CellSpace space(entry.second.front()->getType(),f,entry.second);
  auto count=space.cells().size();
  domains.emplace(entry.first,Domain{std::move(space),BitVector(count,true)});
 }
 for(const auto &fact:facts.atoms){
  const auto &atom=fact.first;
  auto &domain=domains.at(atom.key);
  for(int i=domain.possible.find_first();i>=0;i=domain.possible.find_next(i))
   if(CellSpace::compare(atom.predicate,domain.space.cells()[i],atom.constant)!=fact.second)
    domain.possible.reset(i);
 }
 for(const auto &fact:facts.formulas){
  auto &domain=domains.at(fact.first.key);
  for(int i=domain.possible.find_first();i>=0;i=domain.possible.find_next(i))
   if(fact.first.evaluate(domain.space.cells()[i])!=fact.second)
    domain.possible.reset(i);
 }
 for(const auto &entry:domains)
  if(!entry.second.space.cells().empty()&&entry.second.possible.none())return {};
 std::set<std::pair<BasicBlock*,BasicBlock*>> edges;
 std::set<BasicBlock*> reachable{region.front()},processed;
 DenseMap<Value*,PathTruth> memo;
 for(const auto &fact:facts.arguments)
  if(auto *arg=dyn_cast_or_null<Argument>((Value*)fact.first))
   memo[f.getArg(arg->getArgNo())]=pathTruth(fact.second);
 std::function<PathTruth(Value*)> eval=[&](Value *v)->PathTruth{
  if(auto *k=dyn_cast<ConstantInt>(v))return pathTruth(k->isOne());
  auto known=memo.find(v);if(known!=memo.end())return known->second;
  auto atom=atoms.find(v);
  if(atom!=atoms.end()){
   auto &domain=domains.at(atom->second.key);
   bool any=false,all=true;
   for(int i=domain.possible.find_first();i>=0;i=domain.possible.find_next(i)){
    bool value=CellSpace::compare(atom->second.predicate,domain.space.cells()[i],atom->second.constant);
    any|=value;all&=value;
   }
   return domain.possible.none()||any!=all?PathTruth::Unknown:pathTruth(any);
  }
  if(auto *phi=dyn_cast<PHINode>(v)){
   if(!processed.count(phi->getParent()))return PathTruth::Unknown;
   Optional<PathTruth> value;
   for(unsigned i=0;i<phi->getNumIncomingValues();++i){
    auto *pred=phi->getIncomingBlock(i);
    // A predecessor outside the decision is possible at its root.
    if(!edges.count({pred,phi->getParent()})&&phi->getParent()!=region.front())continue;
    auto incoming=eval(phi->getIncomingValue(i));
    if(value&&*value!=incoming)return PathTruth::Unknown;
    value=incoming;
   }
   return value.getValueOr(PathTruth::Unknown);
  }
  if(auto *sel=dyn_cast<SelectInst>(v)){
   auto cond=eval(sel->getCondition());
   if(cond==PathTruth::True)return eval(sel->getTrueValue());
   if(cond==PathTruth::False)return eval(sel->getFalseValue());
   auto a=eval(sel->getTrueValue()),b=eval(sel->getFalseValue());
   return a==b?a:PathTruth::Unknown;
  }
  if(auto *op=dyn_cast<BinaryOperator>(v))if(op->getType()->isIntegerTy(1)){
   auto a=eval(op->getOperand(0)),b=eval(op->getOperand(1));
   switch(op->getOpcode()){
    case Instruction::And:
     if(a==PathTruth::False||b==PathTruth::False)return PathTruth::False;
     break;
    case Instruction::Or:
     if(a==PathTruth::True||b==PathTruth::True)return PathTruth::True;
     break;
    case Instruction::Xor:break;
    default:return PathTruth::Unknown;
   }
   if(a==PathTruth::Unknown||b==PathTruth::Unknown)return PathTruth::Unknown;
   if(op->getOpcode()==Instruction::Xor)return pathTruth(a!=b);
   return a;
  }
  return PathTruth::Unknown;
 };
 std::set<BasicBlock*> scope(region.begin(),region.end());
 for(auto *b:region){
  if(!reachable.count(b))continue;
  processed.insert(b);
  // Evaluate i1 definitions in SSA order. This also bounds repeated DAG walks.
  for(auto &i:*b)if(i.getType()->isIntegerTy(1))memo[&i]=eval(&i);
  auto *t=b->getTerminator();
  Optional<unsigned> selected;
  auto known=facts.originalEdges.find(b);
  if(original&&known!=facts.originalEdges.end())selected=known->second;
  else if(auto *br=dyn_cast<BranchInst>(t))if(br->isConditional()){
   auto cond=eval(br->getCondition());
   if(cond!=PathTruth::Unknown)selected=cond==PathTruth::True?0:1;
  }
  for(unsigned i=0;i<t->getNumSuccessors();++i){
   auto *next=t->getSuccessor(i);
   if((!selected||*selected==i)&&scope.count(next)){
    edges.insert({b,next});reachable.insert(next);
   }
  }
 }
 return reachable;
}

inline json::Value uniformBlocks(BasicBlock *root,BasicBlock *join,
                                 const std::vector<UniformArmFacts> &arms,
                                 UniformValueKeys &keys,bool original) {
 auto region=uniformRegion(root,join);
 if(!region)return nullptr;
 DenseMap<BasicBlock*,unsigned> indices;
 unsigned index=0;for(auto &block:*root->getParent())indices[&block]=index++;
 json::Array result;
 for(const auto &arm:arms){
  std::set<BasicBlock*> blocks;
  for(const auto &facts:arm.paths){
   auto reachable=uniformReachable(*region,facts,keys,original);
   blocks.insert(reachable.begin(),reachable.end());
  }
  json::Array indicesJSON;
  for(auto *block:*region)if(blocks.count(block))indicesJSON.push_back(int64_t(indices.lookup(block)));
  json::Object record{{"arm",arm.id},{"blocks",std::move(indicesJSON)}};
  if(original)record["before_path_invariant"]=blocks==arm.originalBlocks;
  result.push_back(std::move(record));
 }
 return result;
}
} // namespace decision
