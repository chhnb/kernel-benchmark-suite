#pragma once
#include "incremental_ir_identity.h"
#include "incremental_metadata.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Support/raw_ostream.h"
#include <vector>

namespace fusion {
// A conservative observation/patch-boundary checker, NOT a profitability
// certificate. In particular, unchanged writes do not prove unchanged reads.
// Tuple metadata has a complete rooted-graph representation. Specialized
// metadata remains unsupported; an observed graph does not certify pass reads.
struct IRChangeSet {
  std::set<uint64_t> added, removed, changed;
  bool contextChanged=false;
  bool within(const std::set<uint64_t> &oldWrites,
              const std::set<uint64_t> &newWrites) const {
    if(contextChanged)return false;
    for(auto id:removed)if(!oldWrites.count(id))return false;
    for(auto id:changed)if(!oldWrites.count(id)||!newWrites.count(id))return false;
    for(auto id:added)if(!newWrites.count(id))return false;
    return true;
  }
};
struct IRDependencySnapshot {
  std::string context;
  std::map<uint64_t,std::string> instructions;
  using UseSite = std::pair<uint64_t,unsigned>;
  std::map<uint64_t,std::set<UseSite>> users;
  // Rebuild after every mutation; no pointers from an older module survive.
  static IRDependencySnapshot capture(llvm::Module &source) {
    IRIdentity sourceIDs(source);
    if(sourceIDs.ambiguous())throw std::runtime_error("ambiguous incremental snapshot lineage");
    auto m=llvm::CloneModule(source);IRIdentity ids(*m);
    m->setModuleIdentifier("incremental-context"); // Artifact paths are not semantics.
    IRDependencySnapshot result;
    std::map<llvm::Instruction*,uint64_t> keys;
    for(auto &f:*m) {
      unsigned arg=0;for(auto &a:f.args())a.setName("arg"+std::to_string(arg++));
      for(auto &b:f) {
        if(b.hasAddressTaken())throw std::runtime_error("unsupported incremental blockaddress");
        b.setName("block"+std::to_string(ids.block(b)));
        for(auto &i:b) {
          auto id=ids.instruction(i);keys[&i]=id;
          if(!i.getType()->isVoidTy())i.setName("value"+std::to_string(id));

        }
      }
    }
    IncrementalMetadataGraph metadataGraph;metadataGraph.capture(*m,keys);
    // Reserve canonical names in a separate phase: LLVM may suffix a name
    // while another instruction still has that name. Clear then assign again.
    for(auto &f:*m) {
      for(auto &a:f.args())a.setName("");
      for(auto &b:f){b.setName("");for(auto &i:b)i.setName("");}
    }
    for(auto &f:*m) {
      unsigned arg=0;for(auto &a:f.args())a.setName("arg"+std::to_string(arg++));
      for(auto &b:f) {
        b.setName("block"+std::to_string(keys.at(b.getTerminator())));
        for(auto &i:b) {
          auto id=keys.at(&i);
          if(!i.getType()->isVoidTy())i.setName("value"+std::to_string(id));
          llvm::SmallVector<std::pair<unsigned,llvm::MDNode*>,4> metadata;
          i.getAllMetadata(metadata);for(auto &md:metadata)i.setMetadata(md.first,nullptr);
        }
      }
    }
    for(auto &f:*m)for(auto &b:f)for(auto &i:b){
      auto id=keys.at(&i);std::string text;llvm::raw_string_ostream stream(text);
      // Include membership: a move with identical operands is still a write.
      stream<<f.getName()<<":"<<b.getName()<<":prev="
            <<(i.getPrevNode()?keys.at(i.getPrevNode()):0)<<":";
      i.print(stream);
      auto attachment=metadataGraph.instructionAttachments.find(id);
      if(attachment!=metadataGraph.instructionAttachments.end())stream<<" |metadata="<<attachment->second;
      stream.flush();
      result.instructions.emplace(id,std::move(text));
      for(auto &u:i.uses()) {
        auto *use=llvm::dyn_cast<llvm::Instruction>(u.getUser());
        if(!use || !keys.count(use))
          throw std::runtime_error("unsupported incremental external instruction use");
        result.users[id].insert({keys.at(use),u.getOperandNo()});
      }
    }
    if(auto *counter=m->getNamedMetadata("fusion.incremental.next_identity"))counter->eraseFromParent();
    // Preserve signatures, attributes, globals, target settings and all other
    // module context. Function bodies are accounted for instruction by instruction.
    for(auto &f:*m)if(!f.isDeclaration())f.deleteBody();
    llvm::raw_string_ostream stream(result.context);m->print(stream,nullptr);stream<<"\n"<<metadataGraph.serialize();stream.flush();
    return result;
  }
  IRChangeSet changesTo(const IRDependencySnapshot &next) const {
    IRChangeSet result;result.contextChanged=context!=next.context;
    for(const auto &entry:instructions){
      auto found=next.instructions.find(entry.first);
      if(found==next.instructions.end())result.removed.insert(entry.first);
      else if(entry.second!=found->second)result.changed.insert(entry.first);
    }
    for(const auto &entry:next.instructions)
      if(!instructions.count(entry.first))result.added.insert(entry.first);
    return result;
  }
  // Explicit instruction reads AND use lists. This is suitable for a bounded
  // algorithm with a proven read contract, never for arbitrary LLVM passes.
  static std::string instructionBody(const std::string &record) {
    auto position=record.find(":prev=");
    if(position==std::string::npos)throw std::runtime_error("invalid instruction snapshot");
    auto end=record.find(':',position+6);
    if(end==std::string::npos)throw std::runtime_error("invalid instruction placement");
    return record.substr(end+1);
  }
  bool sameReads(const IRDependencySnapshot &next,const std::set<uint64_t> &reads,
                 const std::set<uint64_t> &placementIndependent={}) const {
    if(context!=next.context)return false;
    for(auto id:reads){
      auto a=instructions.find(id),b=next.instructions.find(id);
      if(a==instructions.end()||b==next.instructions.end())return false;
      if(placementIndependent.count(id)){
        if(instructionBody(a->second)!=instructionBody(b->second))return false;
      }else if(a->second!=b->second)return false;
      auto x=users.find(id),y=next.users.find(id);
      static const std::set<UseSite> empty;
      if((x==users.end()?empty:x->second)!=(y==next.users.end()?empty:y->second))return false;
    }
    return true;
  }
};
} // namespace fusion
