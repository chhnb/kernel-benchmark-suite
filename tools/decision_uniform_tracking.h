#pragma once

#include "decision_uniform_paths.h"
#include "llvm/IR/IntrinsicInst.h"

namespace decision {
class UniformCoordinates {
 using Coordinate=std::pair<int64_t,int64_t>;
 std::map<Value*,Coordinate> positions;
 std::map<Coordinate,Value*> values;
public:
 explicit UniformCoordinates(Function &function) {
  auto add=[&](Value *value,Coordinate coord){
   positions.emplace(value,coord);values.emplace(coord,value);
  };
  for(auto &arg:function.args())add(&arg,{-1,arg.getArgNo()});
  int64_t blockIndex=0;
  for(auto &block:function){
   add(&block,{blockIndex,-1});
   int64_t instructionIndex=0;
   for(auto &i:block)
    if(!isa<DbgInfoIntrinsic>(i))add(&i,{blockIndex,instructionIndex++});
   ++blockIndex;
  }
 }
 json::Value locate(Value *value) const {
  auto found=positions.find(value);
  if(found==positions.end())return nullptr;
  return json::Array{found->second.first,found->second.second};
 }
 Value *resolve(const json::Value &coordinate) const {
  auto *pair=coordinate.getAsArray();
  if(!pair||pair->size()!=2)return nullptr;
  auto block=(*pair)[0].getAsInteger(),index=(*pair)[1].getAsInteger();
  if(!block||!index)return nullptr;
  auto found=values.find({*block,*index});
  return found==values.end()?nullptr:found->second;
 }
};

inline json::Array uniformTrack(const UniformCoordinates &coords,
                                const std::vector<WeakVH> &values) {
 json::Array result;
 for(const auto &handle:values)result.push_back(coords.locate(handle));
 return result;
}

inline std::vector<WeakVH> uniformResolve(const UniformCoordinates &coords,
                                          const json::Array &values) {
 std::vector<WeakVH> result;
 for(const auto &value:values)result.emplace_back(coords.resolve(value));
 return result;
}
}
