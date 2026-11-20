#include "ir_pressure.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/Module.h"
#include <algorithm>
#include <map>
#include <set>
#include <vector>
using namespace llvm;
namespace fusion {
IRPressure irPressure(const Function &f, const std::set<const Value*> *uniform) {
  IRPressure result;
  if(f.empty()) return result;
  using Live=std::set<const Value*>;
  std::set<const BasicBlock*> reachable;
  std::vector<const BasicBlock*> pending{&f.getEntryBlock()};
  while(!pending.empty()) {
    auto *b=pending.back();pending.pop_back();
    if(!reachable.insert(b).second)continue;
    for(auto*s:successors(b))pending.push_back(s);
  }
  result.reachableBlocks=reachable.size();
  auto tracked=[](const Value*v) {
    return (isa<Instruction>(v)||isa<Argument>(v))&&!v->getType()->isVoidTy()
      &&!v->getType()->isTokenTy();
  };
  std::map<const BasicBlock*,Live> in,out;
  auto transfer=[&](const BasicBlock*b,Live live) {
    for(auto it=b->rbegin();it!=b->rend();++it) {
      const Instruction &i=*it;
      if(isa<DbgInfoIntrinsic>(i))continue;
      live.erase(&i);
      if(!isa<PHINode>(i))
        for(auto &op:i.operands())if(tracked(op.get()))live.insert(op.get());
    }
    return live;
  };
  bool changed;
  do {
    changed=false;
    // Backward liveness: visit successors before predecessors where layout permits.
    // The fixed point and transfer function are unchanged.
    for(auto &bb:llvm::reverse(f)) {
      auto*b=&bb;if(!reachable.count(b))continue;
      Live next;
      for(auto*s:successors(b)) {
        auto edge=in[s];
        // PHI definitions are killed together at entry; incoming values live
        // on the predecessor edge only, never as ordinary successor uses.
        for(auto &i:*s) {
          auto*phi=dyn_cast<PHINode>(&i);if(!phi)break;
          edge.erase(phi);
          for(unsigned n=0;n<phi->getNumIncomingValues();++n)
            if(phi->getIncomingBlock(n)==b&&tracked(phi->getIncomingValue(n)))
              edge.insert(phi->getIncomingValue(n));
        }
        next.insert(edge.begin(),edge.end());
      }
      auto entry=transfer(b,next);
      if(next!=out[b]||entry!=in[b]){out[b]=std::move(next);in[b]=std::move(entry);changed=true;}
    }
  }while(changed);
  const auto&dl=f.getParent()->getDataLayout();
  std::string blockKey;
  auto measure=[&](const Live&live) {
    uint64_t slots=0, uniformSlots=0, unprovenSlots=0;
    for(auto*v:live) {
      auto*t=v->getType();
      if(!t->isSized()){result.complete=false;continue;}
      auto bits=dl.getTypeSizeInBits(t);
      if(bits.isScalable()){result.complete=false;continue;}
      auto weight=(bits.getFixedSize()+31)/32;slots+=weight;
      if(uniform&&uniform->count(v))uniformSlots+=weight;else unprovenSlots+=weight;
    }
    result.blockPeakSlots32[blockKey]=std::max(result.blockPeakSlots32[blockKey],slots);
    result.uniformPeakSlots32=std::max(result.uniformPeakSlots32,uniformSlots);
    result.unprovenPeakSlots32=std::max(result.unprovenPeakSlots32,unprovenSlots);
    result.peakSlots32=std::max(result.peakSlots32,slots);
    result.peakValues=std::max(result.peakValues,uint64_t(live.size()));
  };
  for(auto &b:f)if(reachable.count(&b)) {
    blockKey.clear();raw_string_ostream nameStream(blockKey);b.printAsOperand(nameStream,false);nameStream.flush();
    uint64_t crossing=0;for(auto*v:in[&b])crossing+=out[&b].count(v);
    result.blockCrossingValues[blockKey]=crossing;
    Live live=out[&b];measure(live);
    for(auto it=b.rbegin();it!=b.rend();++it) {
      const auto&i=*it;if(isa<DbgInfoIntrinsic>(i))continue;
      // PHIs execute simultaneously: do not measure partial PHI kills.
      if(isa<PHINode>(i)){live.erase(&i);continue;}
      live.erase(&i);
      for(auto &op:i.operands())if(tracked(op.get()))live.insert(op.get());
      measure(live);
    }
    measure(in[&b]);
  }
  return result;
}
}
