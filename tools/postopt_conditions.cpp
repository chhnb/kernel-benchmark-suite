#include "ir_conditions.h"
using namespace llvm;
using namespace fusion::profile_detail;
int main(int argc,char **argv){if(argc!=7&&argc!=8){errs()<<"usage: postopt-conditions BEFORE AFTER FUNCTION LEFT_LABEL RIGHT_LABEL MERGED_LABEL [PARENT]\n";return 2;}
 try{LLVMContext C;SMDiagnostic E;
  auto AB=MemoryBuffer::getFile(argv[1]),BB=MemoryBuffer::getFile(argv[2]);if(!AB||!BB)throw std::runtime_error("input_unreadable");
  auto digest=[](const MemoryBuffer &Buffer){auto S=Buffer.getBuffer();return toHex(SHA1::hash(ArrayRef<uint8_t>(reinterpret_cast<const uint8_t*>(S.data()),S.size())),true);};
  auto A=parseIR(AB.get()->getMemBufferRef(),E,C),B=parseIR(BB.get()->getMemBufferRef(),E,C);if(!A||!B){E.print(argv[0],errs());return 2;}if(verifyModule(*A,&errs())||verifyModule(*B,&errs()))return 2;
  auto *FA=A->getFunction(argv[3]),*FB=B->getFunction(argv[3]);if(!FA||!FB||FA->isDeclaration()||FB->isDeclaration())throw std::runtime_error("function_missing");
  if(A->getTargetTriple()!=B->getTargetTriple()||A->getDataLayoutStr()!=B->getDataLayoutStr()||FA->getFunctionType()!=FB->getFunctionType()||FA->getAttributes()!=FB->getAttributes())throw std::runtime_error("function_context_mismatch");
  Conditions X;auto OA=X.order(*FA),OB=X.order(*FB);auto RA=X.reach(OA),RB=X.reach(OB);
  auto labels=[](Function &F){std::map<std::string,const BasicBlock*> M;ModuleSlotTracker ST(F.getParent());ST.incorporateFunction(F);for(auto &BB:F){std::string S;raw_string_ostream O(S);BB.printAsOperand(O,false,ST);O.flush();M[S]=&BB;}return M;};auto LA=labels(*FA),LB=labels(*FB);
  auto lookup=[](const auto &L,StringRef S){std::string K=S.startswith("%")?S.str():"%"+S.str();auto I=L.find(K);if(I==L.end())throw std::runtime_error("block_missing");return I->second;};auto *Left=lookup(LA,argv[4]),*Right=lookup(LA,argv[5]),*Merged=lookup(LB,argv[6]);
  if(!RA.count(Left)||!RA.count(Right)||!RB.count(Merged))throw std::runtime_error("selected_block_unreachable");
  unsigned Union=X.bdd.lor(RA.at(Left),RA.at(Right));
  json::Object ParentIDs,ParentSplits;std::string ParentHash;
  std::unique_ptr<Module> Parent;
  if(argc==8){auto PB=MemoryBuffer::getFile(argv[7]);if(!PB)throw std::runtime_error("parent_unreadable");ParentHash=digest(*PB.get());Parent=parseIR(PB.get()->getMemBufferRef(),E,C);
   if(!Parent||verifyModule(*Parent,&errs()))throw std::runtime_error("parent_invalid");auto *FP=Parent->getFunction(argv[3]);
   if(!FP||FP->isDeclaration()||FP->getFunctionType()!=FA->getFunctionType()||FP->getAttributes()!=FA->getAttributes()||Parent->getTargetTriple()!=A->getTargetTriple()||Parent->getDataLayoutStr()!=A->getDataLayoutStr())throw std::runtime_error("parent_context_mismatch");
   auto RP=X.reach(X.order(*FP));unsigned I=0;
   for(auto &Block:*FP){auto ID="B"+std::to_string(I++);if(!RP.count(&Block))continue;ParentIDs[ID]=int64_t(RP.at(&Block));auto *Br=dyn_cast<BranchInst>(Block.getTerminator());if(!Br||!Br->isConditional())continue;
    auto V=RP.at(&Block),Condition=X.expr(Br->getCondition());ParentSplits[ID]=json::Object{{"visits",int64_t(V)},{"true_present",int64_t(X.bdd.land(V,Condition))},{"false_present",int64_t(X.bdd.land(V,X.bdd.neg(Condition)))}};
   }
  }
  json::Object Before,After;for(auto &KV:LA)if(RA.count(KV.second))Before[KV.first]=int64_t(RA.at(KV.second));for(auto &KV:LB)if(RB.count(KV.second))After[KV.first]=int64_t(RB.at(KV.second));
  json::Array Nodes;for(auto &N:X.bdd.nodes)Nodes.push_back(json::Array{int64_t(N.var),int64_t(N.lo),int64_t(N.hi)});
  json::Object Out{{"schema","postopt-lane-conditions-v1"},{"before_ir_sha1",digest(*AB.get())},{"after_ir_sha1",digest(*BB.get())},{"parent_ir_sha1",ParentHash},{"target_cpu",FA->getFnAttribute("target-cpu").getValueAsString().str()},{"parent_blocks",std::move(ParentIDs)},{"parent_splits",std::move(ParentSplits)},{"scope","acyclic lane predicates on defined executions; no wave independence assumption"},{"union_proven",Union==RB.at(Merged)},{"left_root",int64_t(RA.at(Left))},{"right_root",int64_t(RA.at(Right))},{"union_root",int64_t(Union)},{"merged_root",int64_t(RB.at(Merged))},{"atoms",int64_t(X.atoms.size())},{"before",std::move(Before)},{"after",std::move(After)},{"bdd_nodes",std::move(Nodes)}};outs()<<formatv("{0:2}\n",json::Value(std::move(Out)));return 0;
 }catch(const std::exception &E){errs()<<E.what()<<"\n";return 3;}}
