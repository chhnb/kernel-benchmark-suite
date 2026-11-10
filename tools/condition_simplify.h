#pragma once
#include "llvm/IR/Constants.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/ConstantRange.h"
#include "llvm/IR/ValueHandle.h"
#include "llvm/Transforms/Utils/Local.h"
#include <set>
#include <vector>
#include <functional>
namespace decision {
// Exact partition of the scalar domain by all comparison boundaries. A cell
// has constant truth for every leaf, hence for the complete Boolean DAG.
// APFloat neighbours represent open cells exactly (no double conversion).
// NaN is its own cell; signed zeros have identical comparison truth values.
inline llvm::Value *simplifyCondition(llvm::Instruction *root) {
 using namespace llvm;
 if(!root->getType()->isIntegerTy(1))return root;
 auto constant=[](CmpInst *c)->Constant*{return dyn_cast<Constant>(c->getOperand(1))?cast<Constant>(c->getOperand(1)):dyn_cast<Constant>(c->getOperand(0));};
 auto predicate=[](CmpInst *c){return isa<Constant>(c->getOperand(1))?c->getPredicate():CmpInst::getSwappedPredicate(c->getPredicate());};
 Value *variable=nullptr;bool fp=false,valid=true;
 std::vector<CmpInst*> leaves;std::vector<WeakVH> nodes;
 std::set<Value*> seen;
 std::function<void(Value*)> collect=[&](Value *v){
  if(!valid||!seen.insert(v).second)return;
  if(seen.size()>128){valid=false;return;}
  if(auto *k=dyn_cast<ConstantInt>(v)){valid &= k->getType()->isIntegerTy(1);return;}
  auto *i=dyn_cast<Instruction>(v);if(!i){valid=false;return;}nodes.emplace_back(i);
  if(auto *c=dyn_cast<CmpInst>(i)){
   auto *k=constant(c);auto *x=c->getOperand(isa<Constant>(c->getOperand(1))?0:1);
   if(!k||(!isa<ConstantInt>(k)&&!isa<ConstantFP>(k))||x->getType()->isVectorTy()){valid=false;return;}
   if(!variable){variable=x;fp=isa<FCmpInst>(c);}else if(variable!=x||fp!=isa<FCmpInst>(c)){valid=false;return;}
   leaves.push_back(c);return;
  }
  if(auto *s=dyn_cast<SelectInst>(i)){for(auto &o:s->operands())collect(o);return;}
  if(i->getOpcode()==Instruction::And||i->getOpcode()==Instruction::Or||i->getOpcode()==Instruction::Xor){for(auto &o:i->operands())collect(o);return;}
  valid=false;
 };
 collect(root);if(!valid||!variable||leaves.empty())return root;
 std::vector<Constant*> cells;
 if(fp){
  auto *f=root->getFunction();
  auto mode=f->getFnAttribute("denormal-fp-math").getValueAsString();
  auto f32=f->getFnAttribute("denormal-fp-math-f32").getValueAsString();
  if(variable->getType()->isFloatTy()&&!f32.empty())mode=f32;
  bool ieee=mode.empty()||mode=="ieee"||mode=="ieee,ieee";
  if(!ieee)for(auto *c:leaves)
   if(cast<ConstantFP>(constant(c))->getValueAPF().isDenormal())return root;
  const auto &sem=cast<ConstantFP>(constant(leaves[0]))->getValueAPF().getSemantics();
  for(auto v:{APFloat::getInf(sem),APFloat::getInf(sem,true),APFloat::getNaN(sem),APFloat::getZero(sem)})cells.push_back(ConstantFP::get(root->getContext(),v));
  for(auto *c:leaves){auto v=cast<ConstantFP>(constant(c))->getValueAPF();cells.push_back(ConstantFP::get(root->getContext(),v));if(!v.isNaN()){auto low=v,high=v;low.next(true);high.next(false);cells.push_back(ConstantFP::get(root->getContext(),low));cells.push_back(ConstantFP::get(root->getContext(),high));}}
 }else{
  unsigned w=variable->getType()->getIntegerBitWidth();
  for(auto v:{APInt(w,0),APInt::getAllOnesValue(w),APInt::getSignedMinValue(w),APInt::getSignedMaxValue(w)})cells.push_back(ConstantInt::get(variable->getType(),v));
  for(auto *c:leaves){auto v=cast<ConstantInt>(constant(c))->getValue();for(auto p:{v,v-1,v+1})cells.push_back(ConstantInt::get(variable->getType(),p));}
 }
 auto compare=[&](CmpInst::Predicate p,Constant *x,Constant *k){
  if(!fp)return ConstantRange::makeExactICmpRegion(p,cast<ConstantInt>(k)->getValue()).contains(cast<ConstantInt>(x)->getValue());
  return cast<ConstantInt>(ConstantExpr::getCompare(p,x,k))->isOne();
 };
 std::function<bool(Value*,Constant*)> eval=[&](Value *v,Constant *cell)->bool{
  if(auto *k=dyn_cast<ConstantInt>(v))return k->isOne();
  if(auto *c=dyn_cast<CmpInst>(v))return compare(predicate(c),cell,constant(c));
  if(auto *s=dyn_cast<SelectInst>(v))return eval(s->getCondition(),cell)?eval(s->getTrueValue(),cell):eval(s->getFalseValue(),cell);
  auto *i=cast<Instruction>(v);bool a=eval(i->getOperand(0),cell),b=eval(i->getOperand(1),cell);
  return i->getOpcode()==Instruction::And?(a&&b):i->getOpcode()==Instruction::Or?(a||b):(a!=b);
 };
 std::vector<bool> truth;bool all=true,any=false;for(auto *cell:cells){bool b=eval(root,cell);truth.push_back(b);all&=b;any|=b;}
 Value *replacement=nullptr;
 if(all||!any)replacement=ConstantInt::get(root->getType(),all);
 auto matches=[&](CmpInst::Predicate p,Constant *k){for(unsigned n=0;n<cells.size();++n)if(compare(p,cells[n],k)!=truth[n])return false;return true;};
 if(!replacement)for(auto *c:leaves)if(matches(predicate(c),constant(c))){replacement=c;break;}
 if(!replacement)for(auto *c:leaves){for(unsigned p=fp?CmpInst::FIRST_FCMP_PREDICATE:CmpInst::FIRST_ICMP_PREDICATE;p<=(fp?CmpInst::LAST_FCMP_PREDICATE:CmpInst::LAST_ICMP_PREDICATE);++p)if(matches(CmpInst::Predicate(p),constant(c))){replacement=CmpInst::Create(fp?Instruction::FCmp:Instruction::ICmp,CmpInst::Predicate(p),variable,constant(c),"decision.interval",root);break;}if(replacement)break;}
 if(!replacement||replacement==root)return root;
 root->replaceAllUsesWith(replacement);
 // Delete only nodes of the inspected condition, never its external input.
 for(unsigned round=0;round<nodes.size();++round)for(auto &h:nodes)if(auto *i=dyn_cast_or_null<Instruction>((Value*)h))if(isInstructionTriviallyDead(i))i->eraseFromParent();
 return replacement;
}
}
