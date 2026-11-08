#include "postopt_scorer.h"
#include "ir_conditions.h"
#include <openssl/sha.h>
#include <cmath>
#include <array>
using namespace llvm;
namespace fusion {
namespace {
std::string str(const json::Object &O,StringRef K){auto V=O.getString(K);if(!V)throw std::runtime_error("malformed_profile");return V->str();}
int64_t integer(const json::Object &O,StringRef K){auto V=O.getInteger(K);if(!V)throw std::runtime_error("malformed_profile");return *V;}
const json::Array &array(const json::Object&O,StringRef K){auto *A=O.getArray(K);if(!A)throw std::runtime_error("malformed_profile");return *A;}
const json::Object &object(const json::Value&V){auto *O=V.getAsObject();if(!O)throw std::runtime_error("malformed_profile");return *O;}
std::string label(const BasicBlock *B,ModuleSlotTracker &S){std::string R;raw_string_ostream OS(R);B->printAsOperand(OS,false,S);OS.flush();return R;}
}
void applyProfilePolicy(const ScoreInput&I,const RoundContext&R,const PostOptFeatures&Before,
                        const PostOptFeatures&After,const PostOptConfig&C,ScoreResult&S){
 S.metrics["profile_used"]=0;
 S.metrics["profile_condition_analysis_runs"]=0;
 auto fallback=[&](const std::string &Why){S.reason="profile_fallback:"+Why+";"+S.reason;};
 try {
  if(!C.profileReadError.empty())throw std::runtime_error(C.profileReadError);
  if(C.profileBundleText.empty())throw std::runtime_error("profile_missing");
  auto Parsed=json::parse(C.profileBundleText);if(!Parsed){consumeError(Parsed.takeError());throw std::runtime_error("profile_unreadable");}
  const auto &Bundle=object(*Parsed);if(str(Bundle,"schema")!="postopt-profile-bundle-v1")throw std::runtime_error("unsupported_bundle_schema");
  auto Workload=str(Bundle,"workload_id");auto Minimum=integer(Bundle,"min_visits");if(Minimum<=0)throw std::runtime_error("invalid_min_visits");
  auto &Parent=const_cast<Function&>(I.beforeIR);auto *Base=R.control->getFunction(R.function);auto &Variant=const_cast<Function&>(I.afterIR);
  if(!Base||Parent.getAttributes()!=Base->getAttributes()||Parent.getAttributes()!=Variant.getAttributes()||Parent.getFunctionType()!=Variant.getFunctionType())throw std::runtime_error("function_context_mismatch");
  auto CPU=Parent.getFnAttribute("target-cpu").getValueAsString();if(CPU!="gfx906")throw std::runtime_error("profile_target_unsupported");
  std::string ExpectedParent=R.parentHash;
  if(R.parentHash==C.profileParsedParent&&!C.profileSerializedParent.empty())ExpectedParent=C.profileSerializedParent;
  // Most search candidates have no exact profile. Do identity/coverage checks
  // before constructing any CFG predicate diagrams; retain the static result.
  bool Covered=false;
  for(auto &V:array(Bundle,"profiles")){
   const auto &P=object(V);if(str(P,"candidate")!=I.candidate.key())continue;
   Covered=true;
   if(str(P,"schema")!="postopt-profile-v1")throw std::runtime_error("unsupported_profile_schema");
   if(str(P,"parent_hash")!=ExpectedParent)throw std::runtime_error("stale_parent_hash");
   if(str(P,"target")!=CPU||integer(P,"wave_size")!=64)throw std::runtime_error("stale_target");
  }
  if(!Covered)throw std::runtime_error("candidate_not_covered");
  S.metrics["profile_condition_analysis_runs"]=1;
  profile_detail::Conditions X;
  // Validate all CFGs before the matcher examines memory predecessors.
  auto BO=X.order(*Base),AO=X.order(Variant),PO=X.order(Parent);
  auto BR=X.reach(BO),AR=X.reach(AO),PR=X.reach(PO);
  std::map<std::string,BasicBlock*> IDs;unsigned N=0;for(auto &B:Parent)IDs["B"+std::to_string(N++)]=&B;
  auto block=[&](const std::string &ID){auto It=IDs.find(ID);if(It==IDs.end()||!PR.count(It->second))throw std::runtime_error("profile_block_unavailable");return It->second;};
  std::map<unsigned,double> Counts{{0,0}};double Waves=0;unsigned Used=0;
  auto record=[&](unsigned Root,double Count){auto It=Counts.find(Root);if(It!=Counts.end()&&It->second!=Count)throw std::runtime_error("inconsistent_event_counts");Counts[Root]=Count;};
  for(auto &Value:array(Bundle,"profiles")){
   const auto &P=object(Value);if(str(P,"candidate")!=I.candidate.key())continue;
   if(str(P,"schema")!="postopt-profile-v1")throw std::runtime_error("unsupported_profile_schema");
   if(str(P,"parent_hash")!=ExpectedParent)throw std::runtime_error("stale_parent_hash");
   if(str(P,"target")!=CPU||integer(P,"wave_size")!=64)throw std::runtime_error("stale_target");
   const json::Object *Row=nullptr;for(auto &V:array(P,"records")){auto &O=object(V);if(str(O,"workload_id")==Workload){if(Row)throw std::runtime_error("ambiguous_workload");Row=&O;}}
   if(!Row)throw std::runtime_error("workload_not_covered");
   const auto &Raw=array(*Row,"counts");if(Raw.size()!=4)throw std::runtime_error("invalid_counters");std::array<uint64_t,4> V;
   for(unsigned J=0;J<4;++J){auto Number=Raw[J].getAsInteger();if(!Number||*Number<0||*Number>9007199254740991LL)throw std::runtime_error("invalid_counters");V[J]=*Number;}
   auto W=integer(*Row,"launched_waves");if(W<=0||W>9007199254740991LL)throw std::runtime_error("invalid_launch");
   if(Waves&&Waves!=W)throw std::runtime_error("launch_mismatch");Waves=W;
   if(V[1]>V[0]||V[2]>V[0]||V[3]>V[1]||V[3]>V[2]||V[1]-V[3]!=V[0]-V[2])throw std::runtime_error("invalid_counters");
   if(!V[0])throw std::runtime_error("region_not_executed");if(V[0]<uint64_t(Minimum))throw std::runtime_error("insufficient_visits");
   for(auto Q:V)if(Q>uint64_t(W))throw std::runtime_error("multiple_wave_visits_not_modeled");
   std::array<unsigned char,32> Bytes,Digest;for(unsigned J=0;J<4;++J)for(unsigned K=0;K<8;++K)Bytes[J*8+K]=(V[J]>>(K*8))&255;
   SHA256(Bytes.data(),Bytes.size(),Digest.data());if(toHex(ArrayRef<uint8_t>(Digest.data(),Digest.size()),true)!=str(*Row,"counter_sha256"))throw std::runtime_error("counter_hash_mismatch");
   auto Kind=P.getString("event_kind");unsigned Union,Left,Right;
   if(!Kind||*Kind=="split_branch"){
    auto *B=block(I.candidate.split);auto *T=dyn_cast<BranchInst>(B->getTerminator());if(!T||!T->isConditional())throw std::runtime_error("split_unavailable");Union=PR.at(B);auto Cond=X.expr(T->getCondition());Left=X.bdd.land(Union,Cond);Right=X.bdd.land(Union,X.bdd.neg(Cond));
   }else if(*Kind=="selected_block_union"){
    auto &Selected=array(P,"selected_blocks");if(Selected.size()!=2||!Selected[0].getAsString()||!Selected[1].getAsString())throw std::runtime_error("selected_blocks_unavailable");
    auto A=Selected[0].getAsString()->str(),B=Selected[1].getAsString()->str();
    if(!((A==I.candidate.left&&B==I.candidate.right)||(A==I.candidate.right&&B==I.candidate.left)))throw std::runtime_error("selected_blocks_mismatch");
    Left=PR.at(block(A));Right=PR.at(block(B));Union=X.bdd.lor(Left,Right);
   }else throw std::runtime_error("wrong_event_kind");
   record(Union,V[0]);record(Left,V[1]);record(Right,V[2]);++Used;
  }
  if(!Used)throw std::runtime_error("candidate_not_covered");record(1,Waves);
  auto subset=[&](unsigned A,unsigned B){return X.bdd.land(A,X.bdd.neg(B))==0;};
  for(auto &A:Counts)for(auto &B:Counts)if(subset(A.first,B.first)&&A.second>B.second)throw std::runtime_error("profile_violates_inclusion");
  auto bounds=[&](unsigned Root){auto It=Counts.find(Root);if(It!=Counts.end())return std::make_pair(It->second,It->second);double Lo=0,Hi=Waves;for(auto &KV:Counts){if(subset(KV.first,Root))Lo=std::max(Lo,KV.second);if(subset(Root,KV.first))Hi=std::min(Hi,KV.second);}if(Lo>Hi)throw std::runtime_error("inconsistent_bounds");return std::make_pair(Lo,Hi);};
  std::map<unsigned,double> Delta;double BaselineUpper=0;
  auto collect=[&](Function &F,const auto &Reach,const PostOptFeatures &Features,double Sign){
   if(!Features.targetAvailable||Features.unknown)throw std::runtime_error("unknown_static_cost");
   ModuleSlotTracker Slots(F.getParent());Slots.incorporateFunction(F);size_t Seen=0;
   for(auto &B:F){auto It=Reach.find(&B);if(It==Reach.end())continue;auto Work=Features.blockWork.find(label(&B,Slots));if(Work==Features.blockWork.end())throw std::runtime_error("block_coverage_mismatch");++Seen;double W=Work->second.work;if(!std::isfinite(W)||W<0)throw std::runtime_error("invalid_work");Delta[It->second]+=Sign*W;if(Sign>0)BaselineUpper+=W*bounds(It->second).second;}
   if(Seen!=Features.blockWork.size())throw std::runtime_error("block_coverage_mismatch");
  };
  collect(*Base,BR,Before,1);collect(Variant,AR,After,-1);
  double Lower=0,Upper=0;unsigned Unknown=0;for(auto &KV:Delta){if(KV.second==0)continue;auto B=bounds(KV.first);Lower+=KV.second*(KV.second>0?B.first:B.second);Upper+=KV.second*(KV.second>0?B.second:B.first);if(!Counts.count(KV.first))++Unknown;}
  double Gain=Lower/Waves,Relative=Lower/std::max(BaselineUpper,Waves);double Total=Relative-C.relativeThreshold-S.livenessPenalty;
  if(Gain<=C.absoluteThreshold)Total=std::min(Total,0.0);
  if(!std::isfinite(Total)||!std::isfinite(Gain)||!std::isfinite(Upper))throw std::runtime_error("nonfinite_profile_score");
  S.metrics["profile_gain_lower"]=Lower;S.metrics["profile_gain_upper"]=Upper;S.metrics["profile_launched_waves"]=Waves;
  S.metrics["profile_gain_per_wave_lower"]=Gain;S.metrics["profile_baseline_per_wave_upper"]=BaselineUpper/Waves;
  S.metrics["profile_relative_gain_lower"]=Relative;S.metrics["profile_unmeasured_terms"]=Unknown;S.metrics["profile_static_total"]=S.total;S.metrics["profile_used"]=1;
  S.total=Total;S.parentGain=Gain;S.reason=Total>0?"experimental_profile_bounds_accepted":"experimental_profile_bounds_rejected";
  S.coverage.divergence="exact_workload_profile_reconverged_wave_presence_proxy_not_schedule_proof";
 }catch(const std::exception &E){fallback(E.what());}
}
}
