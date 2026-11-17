#pragma once
#include "llvm/IR/Module.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/Constants.h"
#include <map>
#include <set>
#include <string>
#include <stdexcept>
#include <limits>

namespace fusion {
// Opt-in lineage for the scoped incremental path. Never infer lineage from
// B<n>, printed SSA names, structural similarity, or allocation addresses.
// Metadata is retained by parsing/cloning. A cloned instruction with the same
// tag is ambiguous: fail closed, rather than silently choosing one descendant.
// This index is a snapshot: rebuild after any structural IR mutation.
class IRIdentity {
  static constexpr const char *Tag = "fusion.incremental.identity";
  static constexpr const char *Counter = "fusion.incremental.next_identity";
  std::map<uint64_t, llvm::Instruction *> byID;
  std::set<uint64_t> duplicates;
  uint64_t next = 1;
  static uint64_t decode(const llvm::MDNode *node) {
    if (!node || node->getNumOperands()!=1)
      throw std::runtime_error("invalid incremental identity metadata");
    auto *value=llvm::mdconst::dyn_extract<llvm::ConstantInt>(node->getOperand(0));
    if (!value || value->getBitWidth()!=64 || !value->getZExtValue())
      throw std::runtime_error("invalid incremental identity value");
    return value->getZExtValue();
  }
  static llvm::MDNode *encode(llvm::LLVMContext &ctx,uint64_t value) {
    return llvm::MDNode::get(ctx,llvm::ConstantAsMetadata::get(
        llvm::ConstantInt::get(llvm::Type::getInt64Ty(ctx),value)));
  }
public:
  // Only stamp a disposable, opt-in incremental module. The stock v1 pipeline
  // and frozen byte-for-byte IR remain untouched until the path is validated.
  explicit IRIdentity(llvm::Module &module) {
    if (auto *counter=module.getNamedMetadata(Counter)) {
      if(counter->getNumOperands()!=1)
        throw std::runtime_error("invalid incremental identity counter");
      next=decode(counter->getOperand(0));
    }
    for(auto &f:module) for(auto &b:f) for(auto &i:b) {
      auto *tag=i.getMetadata(Tag);
      if(!tag)continue;
      auto id=decode(tag);
      if(id==std::numeric_limits<uint64_t>::max())
        throw std::runtime_error("incremental identity exhausted");
      next=std::max(next,id+1);
      if(!byID.emplace(id,&i).second)duplicates.insert(id);
    }
    // New instructions receive fresh IDs, including instructions whose old
    // tags were legitimately dropped by a transformation. Deleted IDs are
    // never reused, even after serialization.
    for(auto &f:module) for(auto &b:f) for(auto &i:b) {
      if(i.getMetadata(Tag))continue;
      if(next==std::numeric_limits<uint64_t>::max())
        throw std::runtime_error("incremental identity exhausted");
      i.setMetadata(Tag,encode(module.getContext(),next));
      byID.emplace(next++,&i);
    }
    auto *counter=module.getOrInsertNamedMetadata(Counter);
    counter->clearOperands();counter->addOperand(encode(module.getContext(),next));
  }
  uint64_t instruction(const llvm::Instruction &i) const {
    auto *tag=i.getMetadata(Tag);
    if(!tag)throw std::runtime_error("unstamped incremental instruction");
    auto id=decode(tag);
    auto found=byID.find(id);
    if(duplicates.count(id) || found==byID.end() || found->second!=&i)
      throw std::runtime_error("ambiguous incremental instruction identity");
    return id;
  }
  // A block is identified by its terminator lineage. Replacing a terminator
  // without preserving its tag intentionally invalidates the old identity.
  // This conservative choice cannot accidentally reuse a stale candidate.
  uint64_t block(const llvm::BasicBlock &b) const {
    if(!b.getTerminator())throw std::runtime_error("unterminated incremental block");
    return instruction(*b.getTerminator());
  }
  std::string candidate(const llvm::BasicBlock &root,
                        const llvm::BasicBlock &left,
                        const llvm::BasicBlock &right) const {
    if(root.getParent()!=left.getParent() || root.getParent()!=right.getParent())
      throw std::runtime_error("cross-function incremental candidate");
    return "b2b:"+std::to_string(block(root))+":"+
        std::to_string(block(left))+":"+std::to_string(block(right));
  }
  bool ambiguous() const {return !duplicates.empty();}
  llvm::Instruction *lookup(uint64_t id) const {
    if(duplicates.count(id))return nullptr;
    auto found=byID.find(id);return found==byID.end()?nullptr:found->second;
  }
};
} // namespace fusion
