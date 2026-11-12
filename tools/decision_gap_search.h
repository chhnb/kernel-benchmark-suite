#pragma once
#include "tti_memory_io.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/Program.h"
#include "llvm/Support/FormatVariadic.h"
#include <set>
#include <tuple>
#include <cstdlib>
#include <stdexcept>

namespace decision {
using namespace llvm;
struct GapSearchState {
  std::set<unsigned> Split, Speculate;
  json::Object json() const {
    json::Array A, B;
    for (auto I : Split) A.push_back(int64_t(I));
    for (auto I : Speculate) B.push_back(int64_t(I));
    return json::Object{{"split",std::move(A)}, {"speculate",std::move(B)}};
  }
  bool operator<(const GapSearchState &Other) const {
    return std::tie(Split,Speculate)<std::tie(Other.Split,Other.Speculate);
  }
};
inline json::Value readGapJSON(const std::string &Path) {
  auto B=MemoryBuffer::getFile(Path);if(!B)throw std::runtime_error("cannot read "+Path);
  auto V=json::parse((*B)->getBuffer());if(!V)throw std::runtime_error(toString(V.takeError()));
  return std::move(*V);
}
inline void writeGapJSON(const std::string &Path,const json::Value &V) {
  std::error_code E;raw_fd_ostream O(Path,E);if(E)throw std::runtime_error(E.message());
  O<<formatv("{0:2}\n",V);
}
inline GapSearchState readGapState(const std::string &Path) {
  auto V=readGapJSON(Path);auto *O=V.getAsObject();if(!O)throw std::runtime_error("invalid gap state");
  GapSearchState S;
  for(auto P:{std::make_pair("split",&S.Split),std::make_pair("speculate",&S.Speculate)}) {
    auto *A=O->getArray(P.first);if(!A)throw std::runtime_error("missing gap state array");
    for(auto &I:*A){auto N=I.getAsInteger();if(!N||*N<0||*N>10000000)throw std::runtime_error("invalid gap ID");P.second->insert(unsigned(*N));}
  }
  return S;
}
inline int gapCommand(std::vector<std::string> Args,const std::string &Out,const std::string &Err) {
  std::vector<StringRef> Refs;for(auto &A:Args)Refs.push_back(A);
  std::array<Optional<StringRef>,3> Red{{StringRef(""),StringRef(Out),StringRef(Err)}};
  return sys::ExecuteAndWait(Args[0],Refs,None,Red,120);
}
// This reference implementation measures fully materialized disposable plans.
// Thus source-position selects, live-outs, carrier PHIs and shared guards are
// priced by the same LLVM24 worker as the outer greedy scorer, without CSE or
// scoped SimplifyCFG assumptions. Only final verified candidates can be picked.
inline bool gapRootsStdout() {
  const char *Mode=std::getenv("DECISION_GAP_ROOTS_STDOUT");
  return Mode&&StringRef(Mode)=="1";
}
inline bool gapKeepCatalog() {
  const char *Mode=std::getenv("DECISION_GAP_KEEP_CATALOG");
  return !gapRootsStdout()||(Mode&&StringRef(Mode)=="1");
}
struct GapTrialResult {
  json::Value Report=nullptr;
  std::string RawIR,FinalIR;
  json::Value Catalog=nullptr;
  json::Array Roots;
  llvm::Optional<int64_t> LocalCost;
  bool ScoredOnly=false;
};
inline int searchGapPlans(int Argc,char **Argv,int Mode,
                          function_ref<int(const GapSearchState &,GapTrialResult &,bool,Optional<int64_t>)> Trial) {
 try {
  if(Mode!=0&&Mode!=3)throw std::runtime_error("gap search supports none or cost mode");
  std::string Out=Argv[5];if(sys::fs::exists(Out))throw std::runtime_error("output directory exists");
  if(auto E=sys::fs::create_directories(Out))throw std::runtime_error(E.message());
  SmallString<256> Exe(Argv[0]);sys::fs::make_absolute(Exe);
  SmallString<256> Root(Exe);for(unsigned I=0;I<3;++I)sys::path::remove_filename(Root);
  std::string Worker=std::string(Root.str())+"/tools/run-llvm24-tti";
  const char *CustomWorker=std::getenv("DECISION_TTI_WORKER");
  if(CustomWorker)Worker=CustomWorker;
  const char *KeepTrials=std::getenv("DECISION_GAP_KEEP_TRIALS");
#ifdef __linux__
  bool InMemory=!KeepTrials||StringRef(KeepTrials)!="1";
#else
  bool InMemory=false;
#endif
  if(gapRootsStdout()&&!InMemory)
    throw std::runtime_error("gap roots on stdout require in-memory search");
  auto RunPlan=[&](const std::string &Dir,const GapSearchState &S) {
    std::string StateFile=Dir+".state.json";
    writeGapJSON(StateFile,json::Value(S.json()));
    std::vector<std::string> Args(Argv,Argv+Argc);
    Args[0]=std::string(Exe.str());Args[5]=Dir;
    setenv("DECISION_GAP_STATE",StateFile.c_str(),1);
    int RC=gapCommand(Args,Dir+".stdout",Dir+".stderr");
    unsetenv("DECISION_GAP_STATE");
    return RC;
  };
  unsigned Trials=0;json::Array Trace;
  json::Value InitialRejection=nullptr;
  struct Candidate {GapSearchState State;std::string Dir;int64_t Cost;json::Value Report;std::string RawIR;};
  std::set<GapSearchState> Visited;
  auto Evaluate=[&](const GapSearchState &S,StringRef Action,
                    Optional<int64_t> UpperBound=None)->std::unique_ptr<Candidate>{
    if(!Visited.insert(S).second)return nullptr;
    if(Trials>=100000)throw std::runtime_error("gap search trial limit");
    std::string Dir=Out+"/gap-trial-"+std::to_string(Trials++);
    GapTrialResult Result;
    int RC=InMemory?Trial(S,Result,false,UpperBound):RunPlan(Dir,S);
    if(!InMemory&&sys::fs::exists(Dir+"/trial.json"))
      Result.Report=readGapJSON(Dir+"/trial.json");
    json::Object Row{{"action",Action.str()},{"directory",Dir},{"state",S.json()},{"exit_code",RC}};
    auto *Report=Result.Report.getAsObject();
    if(RC){
      if(Report)if(auto Reason=Report->getString("reason"))Row["reason"]=Reason->str();
      if(Trials==1&&Report)InitialRejection=std::move(Result.Report);
      Trace.push_back(std::move(Row));
      return nullptr;
    }
    if(Result.ScoredOnly){
      if(!UpperBound||!Result.LocalCost||*Result.LocalCost<*UpperBound)
        throw std::runtime_error("invalid score-only gap trial");
      Row["cost"]=*Result.LocalCost;
      Row["validation"]="score-only";
      Trace.push_back(std::move(Row));
      return nullptr;
    }
    if(!Report||Report->getString("status")!=Optional<StringRef>("verified"))
      throw std::runtime_error("unverified gap trial");
    if(Result.LocalCost){
      Row["cost"]=*Result.LocalCost;Trace.push_back(std::move(Row));
      return std::make_unique<Candidate>(Candidate{S,Dir,*Result.LocalCost,
          std::move(Result.Report),std::move(Result.RawIR)});
    }
    json::Value CostJSON=nullptr;
#ifdef __linux__
    if(InMemory){
      auto Parsed=json::parse(runMemoryTTI(Worker,Result.RawIR,Argv[2],!CustomWorker,120));
      if(!Parsed)throw std::runtime_error(toString(Parsed.takeError()));
      CostJSON=std::move(*Parsed);
    }else
#endif
    {
      RC=gapCommand({Worker,Dir+"/meld-raw.ll",Argv[2]},Dir+"/gap-tti.json",Dir+"/gap-tti.stderr");
      if(RC)throw std::runtime_error("gap TTI worker failed");
      CostJSON=readGapJSON(Dir+"/gap-tti.json");
    }
    auto *C=CostJSON.getAsObject();
    if(!C||C->getInteger("unknown")!=Optional<int64_t>(0)||C->getString("source_revision")!=Optional<StringRef>("6be16f356d3e")||!C->getInteger("cost"))throw std::runtime_error("gap TTI cost unknown or revision mismatch");
    int64_t Cost=*C->getInteger("cost");Row["cost"]=Cost;Trace.push_back(std::move(Row));
    return std::unique_ptr<Candidate>(new Candidate{S,Dir,Cost,std::move(Result.Report),std::move(Result.RawIR)});
  };
  auto Current=Evaluate(GapSearchState{},"all-gaps-protected");
  if(!Current){
    if(InitialRejection.getAsObject())
      writeGapJSON(Out+"/trial.json",InitialRejection);
    throw std::runtime_error("initial protected gap plan rejected");
  }
  int64_t Initial=Current->Cost;json::Array Accepted;
  for(unsigned Round=0;;++Round) {
    if(Round>=100000)throw std::runtime_error("gap search round limit");
    std::unique_ptr<Candidate> Best;
    auto Consider=[&](GapSearchState S,const std::string &Action) {
      auto C=Evaluate(S,Action,Best?Best->Cost:Current->Cost);
      if(C&&C->Cost<Current->Cost&&(!Best||C->Cost<Best->Cost))Best=std::move(C);
    };
    auto *R=Current->Report.getAsObject();auto *Matches=R->getArray("alignment_choices");auto *Gaps=R->getArray("gap_choices");
    if(!Matches||!Gaps)throw std::runtime_error("gap catalog missing");
    for(auto &V:*Matches) {
      auto *M=V.getAsObject();unsigned ID=unsigned(*M->getInteger("id"));
      auto S=Current->State;S.Split.insert(ID);Consider(S,"split-"+std::to_string(ID));
      if(Mode==3)for(unsigned Mask=1;Mask<4;++Mask) {
        S=Current->State;S.Split.insert(ID);
        if(Mask&1)S.Speculate.insert(unsigned(*M->getInteger("left_gap")));
        if(Mask&2)S.Speculate.insert(unsigned(*M->getInteger("right_gap")));
        Consider(S,"split-"+std::to_string(ID)+"-new-gap-plan-"+std::to_string(Mask));
      }
    }
    if(Mode==3)for(auto &V:*Gaps) {
      auto *G=V.getAsObject();bool On=*G->getBoolean("speculated");
      if(!On&&!*G->getBoolean("safe"))continue;
      auto S=Current->State;
      for(auto &ID:*G->getArray("ids")) {
        unsigned N=unsigned(*ID.getAsInteger());if(On)S.Speculate.erase(N);else S.Speculate.insert(N);
      }
      Consider(S,On?"protect-gap":"speculate-gap");
    }
    if(!Best)break;
    Accepted.push_back(json::Object{{"round",int64_t(Round)},{"before",Current->Cost},{"after",Best->Cost},{"directory",Best->Dir},{"state",Best->State.json()}});
    Current=std::move(Best);
  }
  if(InMemory){
    GapTrialResult Selected;
    if(Trial(Current->State,Selected,true,None))
      throw std::runtime_error("selected gap plan replay failed");
    if(Selected.LocalCost){
      if(*Selected.LocalCost!=Current->Cost)
        throw std::runtime_error("selected gap plan replay changed its throughput cost");
    }else if(Current->RawIR!=Selected.RawIR)
      throw std::runtime_error("selected gap plan replay changed raw IR");
    for(auto Artifact:{std::make_pair("meld-raw.ll",StringRef(Selected.RawIR)),
                       std::make_pair("fused.ll",StringRef(Selected.FinalIR))}){
      std::error_code E;
      raw_fd_ostream Output(Out+"/"+Artifact.first,E);
      if(E)throw std::runtime_error(E.message());
      Output<<Artifact.second;
      Output.flush();
      if(Output.has_error()){Output.clear_error();throw std::runtime_error("cannot write selected IR");}
    }
    writeGapJSON(Out+"/trial.json",Selected.Report);
    if(gapKeepCatalog())writeGapJSON(Out+"/decisions.json",Selected.Catalog);
    if(gapRootsStdout())outs()<<formatv("{0}\n",json::Value(std::move(Selected.Roots)));
  }else{
    for(auto Name:{"parent.ll","normalized.ll","meld-raw.ll","fused.ll","decisions.json","trial.json"})
      if(auto E=sys::fs::copy_file(Current->Dir+"/"+Name,Out+"/"+Name))throw std::runtime_error(E.message());
  }
  writeGapJSON(Out+"/gap-search.json",json::Value(json::Object{{"status","completed"},{"artifacts",InMemory?"selected-only":"all-trials"},{"objective","LLVM24 whole-function reciprocal-throughput TTI on raw generated plan; no cleanup assumptions"},{"initial_cost",Initial},{"final_cost",Current->Cost},{"trials",int64_t(Trials)},{"selected",InMemory?Out:Current->Dir},{"accepted",std::move(Accepted)},{"trace",std::move(Trace)}}));
  return 0;
 } catch(const std::exception &E) {errs()<<E.what()<<"\n";return 3;}
}
} // namespace decision
