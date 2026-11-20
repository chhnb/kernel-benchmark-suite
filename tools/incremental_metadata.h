#pragma once
#include "llvm/IR/Module.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/Constants.h"
#include "llvm/Support/raw_ostream.h"
#include <map>
#include <vector>
#include <string>
#include <stdexcept>
namespace fusion {
// Exact rooted graph for tuple metadata, including distinct identity, sharing
// and cycles. Numbering is assigned by deterministic roots, never addresses.
// Specialized metadata (DI nodes, local values, etc.) remains unsupported.
class IncrementalMetadataGraph {
  std::map<const llvm::Metadata*,unsigned> indices;
  std::vector<std::string> nodes;
  std::string roots;
  static std::string field(llvm::StringRef text){return std::to_string(text.size())+":"+text.str();}
  std::string reference(const llvm::Metadata *md) {
    using namespace llvm;
    if(!md)return "null";
    auto existing=indices.find(md);if(existing!=indices.end())return "n"+std::to_string(existing->second);
    auto id=unsigned(nodes.size());indices.emplace(md,id);nodes.emplace_back();
    std::string value;
    if(auto *s=dyn_cast<MDString>(md))value="string:"+field(s->getString());
    else if(auto *c=dyn_cast<ConstantAsMetadata>(md)){
      auto *integer=dyn_cast<ConstantInt>(c->getValue());
      if(!integer)throw std::runtime_error("unsupported incremental metadata constant");
      raw_string_ostream out(value);out<<"constant:";integer->printAsOperand(out,true);out.flush();
    }else if(auto *tuple=dyn_cast<MDTuple>(md)){
      if(tuple->isTemporary())throw std::runtime_error("temporary incremental metadata");
      value=tuple->isDistinct()?"distinct:":"uniqued:";
      value+=std::to_string(tuple->getNumOperands())+":";
      for(auto &op:tuple->operands())value+=field(reference(op.get()));
    }else throw std::runtime_error("unsupported incremental metadata kind");
    nodes[id]=std::move(value);return "n"+std::to_string(id);
  }
  std::string attachments(const llvm::GlobalObject &object,llvm::ArrayRef<llvm::StringRef> names){
    llvm::SmallVector<std::pair<unsigned,llvm::MDNode*>,4> list;object.getAllMetadata(list);
    std::map<std::string,llvm::MDNode*> ordered;
    for(auto &md:list)ordered.emplace(names[md.first].str(),md.second);
    std::string result;for(auto &md:ordered)result+=field(md.first)+field(reference(md.second));return result;
  }
public:
  std::map<uint64_t,std::string> instructionAttachments;
  void capture(llvm::Module &module,const std::map<llvm::Instruction*,uint64_t> &keys){
    using namespace llvm;
    indices.clear();nodes.clear();roots.clear();instructionAttachments.clear();
    SmallVector<StringRef,32> names;module.getContext().getMDKindNames(names);
    // Include all named/global/function roots in the SAME graph so identity
    // relationships across attachments cannot be lost by independent hashing.
    std::map<std::string,const NamedMDNode*> named;
    for(auto &md:module.named_metadata())if(md.getName()!="fusion.incremental.next_identity")named.emplace(md.getName().str(),&md);
    for(auto &md:named){std::string value;for(auto *node:md.second->operands())value+=field(reference(node));roots+="named:"+field(md.first)+field(value);}
    for(auto &g:module.globals())roots+="global:"+field(g.getName())+field(attachments(g,names));
    for(auto &f:module)roots+="function:"+field(f.getName())+field(attachments(f,names));
    std::map<uint64_t,Instruction*> ordered;
    for(auto &item:keys)ordered.emplace(item.second,item.first);
    for(auto &item:ordered){
      SmallVector<std::pair<unsigned,MDNode*>,4> list;item.second->getAllMetadata(list);
      std::map<std::string,MDNode*> metadata;
      for(auto &md:list)if(names[md.first]!="fusion.incremental.identity")metadata.emplace(names[md.first].str(),md.second);
      if(metadata.empty())continue;
      std::string value;for(auto &md:metadata)value+=field(md.first)+field(reference(md.second));
      instructionAttachments[item.first]=value;
      roots+="instruction:"+std::to_string(item.first)+":"+field(value);
    }
  }
  std::string serialize() const {
    std::string out="tuple-metadata-graph-v1:"+field(roots);
    for(unsigned i=0;i<nodes.size();++i)out+=std::to_string(i)+":"+field(nodes[i]);
    return out;
  }
};
} // namespace fusion
