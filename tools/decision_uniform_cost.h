#pragma once

#include "llvm/Support/JSON.h"
#include <map>
#include <set>
#include <utility>

namespace decision {
inline llvm::json::Value uniformCostReport(const llvm::json::Object &trial,
                                           const llvm::json::Object &before,
                                           const llvm::json::Object &after) {
 using namespace llvm;
 using Coordinate=std::pair<int64_t,int64_t>;
 struct Costs {
  std::map<int64_t,int64_t> blocks;
  std::map<Coordinate,int64_t> instructions;
 };
 auto collect=[](const json::Object &report)->Optional<Costs>{
  auto *rows=report.getArray("instruction_costs");
  if(!rows)return None;
  Costs costs;
  for(const auto &v:*rows){
   auto *row=v.getAsObject();if(!row)return None;
   auto block=row->getInteger("block_index"),index=row->getInteger("instruction_index");
   auto cost=row->getInteger("accepted_cost");
   if(!block||!index||!cost)return None;
   costs.blocks[*block]+=*cost;costs.instructions[{*block,*index}]=*cost;
  }
  return costs;
 };
 auto previous=collect(before),next=collect(after);
 auto *beforeArms=trial.getArray("uniform_before"),*afterArms=trial.getArray("uniform_after");
 if(!previous||!next||!beforeArms||!afterArms||beforeArms->size()!=afterArms->size())
  return nullptr;
 auto regionCost=[](const json::Object &arm,const Costs &costs)->Optional<int64_t>{
  auto *blocks=arm.getArray("blocks");if(!blocks)return None;
  int64_t total=0;
  for(const auto &v:*blocks){
   auto block=v.getAsInteger();if(!block)return None;
   auto it=costs.blocks.find(*block);if(it==costs.blocks.end())return None;
   total+=it->second;
  }
  return total;
 };
 auto markedCost=[&](StringRef field,const std::set<int64_t> &blocks,
                     std::set<Coordinate> &counted)->Optional<int64_t>{
  auto *marks=trial.getArray(field);if(!marks)return None;
  int64_t total=0;
  for(const auto &v:*marks){
   auto *pair=v.getAsArray();if(!pair||pair->size()!=2)return None;
   auto block=(*pair)[0].getAsInteger(),index=(*pair)[1].getAsInteger();
   if(!block||!index)return None;
   if(!blocks.count(*block)||!counted.emplace(*block,*index).second)continue;
   auto it=next->instructions.find({*block,*index});if(it==next->instructions.end())return None;
   total+=it->second;
  }
  return total;
 };
 json::Array report;
 for(size_t i=0;i<beforeArms->size();++i){
  auto *a=(*beforeArms)[i].getAsObject(),*b=(*afterArms)[i].getAsObject();
  if(!a||!b)return nullptr;
  auto id=a->getString("arm");
  if(!id||id!=b->getString("arm"))return nullptr;
  auto uBefore=regionCost(*a,*previous),uAfter=regionCost(*b,*next);
  if(!uBefore||!uAfter)return nullptr;
  std::set<int64_t> blocks;
  for(const auto &v:*b->getArray("blocks")){
   auto block=v.getAsInteger();if(!block)return nullptr;
   blocks.insert(*block);
  }
  std::set<Coordinate> counted;
  auto speculation=markedCost("uniform_approved_speculation",blocks,counted);
  auto hoists=markedCost("uniform_condition_hoists",blocks,counted);
  if(!speculation||!hoists)return nullptr;
  auto delta=*uAfter-*uBefore;
  report.push_back(json::Object{{"arm",id->str()},{"before",*uBefore},{"after",*uAfter},
   {"delta",delta},{"approved_speculation",*speculation},{"condition_hoist",*hoists},
   {"unexplained",delta-*speculation-*hoists},
   {"before_path_invariant",a->getBoolean("before_path_invariant").getValueOr(false)}});
 }
 return std::move(report);
}
}
