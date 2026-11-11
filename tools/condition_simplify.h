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
inline llvm::Constant *comparisonConstant(llvm::CmpInst *C) {
 return llvm::dyn_cast<llvm::Constant>(C->getOperand(
     llvm::isa<llvm::Constant>(C->getOperand(1))?1:0));
}
inline llvm::Value *comparisonVariable(llvm::CmpInst *C) {
 return C->getOperand(llvm::isa<llvm::Constant>(C->getOperand(1))?0:1);
}
inline llvm::CmpInst::Predicate comparisonPredicate(llvm::CmpInst *C) {
 return llvm::isa<llvm::Constant>(C->getOperand(1))?C->getPredicate():
        llvm::CmpInst::getSwappedPredicate(C->getPredicate());
}

// Representatives for exact scalar comparison cells. Neighbours cover the
// open intervals without conversion to double. NaN has its own cell, and
// positive and negative zero have identical comparison truth values.
class CellSpace {
 std::vector<llvm::Constant*> Cells;
public:
 CellSpace(llvm::Type *type, const llvm::Function &function,
           const std::vector<llvm::Constant*> &bounds) {
  using namespace llvm;
  if(bounds.empty())return;
  auto &ctx=type->getContext();
  if(type->isFloatingPointTy()){
   auto mode=function.getFnAttribute("denormal-fp-math").getValueAsString();
   auto f32=function.getFnAttribute("denormal-fp-math-f32").getValueAsString();
   if(type->isFloatTy()&&!f32.empty())mode=f32;
   if(!mode.empty()&&mode!="ieee"&&mode!="ieee,ieee")
    for(auto *k:bounds)if(cast<ConstantFP>(k)->getValueAPF().isDenormal())return;
   const auto &sem=cast<ConstantFP>(bounds.front())->getValueAPF().getSemantics();
   for(auto v:{APFloat::getInf(sem),APFloat::getInf(sem,true),APFloat::getNaN(sem),APFloat::getZero(sem)})
    Cells.push_back(ConstantFP::get(ctx,v));
   for(auto *k:bounds){
    auto v=cast<ConstantFP>(k)->getValueAPF();Cells.push_back(ConstantFP::get(ctx,v));
    if(!v.isNaN()){auto low=v,high=v;low.next(true);high.next(false);
     Cells.push_back(ConstantFP::get(ctx,low));Cells.push_back(ConstantFP::get(ctx,high));}
   }
  }else if(type->isIntegerTy()){
   unsigned w=type->getIntegerBitWidth();
   for(auto v:{APInt(w,0),APInt::getAllOnesValue(w),APInt::getSignedMinValue(w),APInt::getSignedMaxValue(w)})
    Cells.push_back(ConstantInt::get(type,v));
   for(auto *k:bounds){
    auto v=cast<ConstantInt>(k)->getValue();
    for(auto p:{v,v-1,v+1})Cells.push_back(ConstantInt::get(type,p));
   }
  }
 }
 const std::vector<llvm::Constant*> &cells() const {return Cells;}
 static bool compare(llvm::CmpInst::Predicate p,llvm::Constant *x,llvm::Constant *k) {
  using namespace llvm;
  if(CmpInst::isIntPredicate(p))
   return ConstantRange::makeExactICmpRegion(p,cast<ConstantInt>(k)->getValue())
      .contains(cast<ConstantInt>(x)->getValue());
  return cast<ConstantInt>(ConstantExpr::getCompare(p,x,k))->isOne();
 }
};

inline llvm::Value *simplifyCondition(llvm::Instruction *root) {
 using namespace llvm;
 if(!root->getType()->isIntegerTy(1))return root;
 auto constant=comparisonConstant;
 auto predicate=comparisonPredicate;
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
 std::vector<Constant*> bounds;
 for(auto *c:leaves)bounds.push_back(constant(c));
 CellSpace space(variable->getType(),*root->getFunction(),bounds);
 const auto &cells=space.cells();
 if(cells.empty())return root;
 auto compare=CellSpace::compare;
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
