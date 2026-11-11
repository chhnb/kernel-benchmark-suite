#pragma once
#include "llvm/Support/JSON.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/Program.h"
#include "llvm/Support/FormatVariadic.h"
#include <set>
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
  std::string key() const {
    std::string S;raw_string_ostream O(S);O<<formatv("{0}",json::Value(json()));return O.str();
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
inline int searchGapPlans(int Argc,char **Argv,int Mode) {
 try {
  if(Mode!=0&&Mode!=3)throw std::runtime_error("gap search supports none or cost mode");
  std::string Out=Argv[5];if(sys::fs::exists(Out))throw std::runtime_error("output directory exists");
  if(auto E=sys::fs::create_directories(Out))throw std::runtime_error(E.message());
  SmallString<256> Exe(Argv[0]);sys::fs::make_absolute(Exe);
  SmallString<256> Root(Exe);for(unsigned I=0;I<3;++I)sys::path::remove_filename(Root);
  std::string Worker=std::string(Root.str())+"/tools/run-llvm24-tti";
  if(const char *P=std::getenv("DECISION_TTI_WORKER"))Worker=P;
  unsigned Trials=0;json::Array Trace;
  struct Candidate {GapSearchState State;std::string Dir;int64_t Cost;json::Value Report;};
  std::set<std::string> Visited;
  auto Evaluate=[&](const GapSearchState &S,StringRef Action)->std::unique_ptr<Candidate>{
    if(!Visited.insert(S.key()).second)return nullptr;
    if(Trials>=100000)throw std::runtime_error("gap search trial limit");
    std::string Dir=Out+"/gap-trial-"+std::to_string(Trials++),StateFile=Dir+".state.json";
    writeGapJSON(StateFile,json::Value(S.json()));
    std::vector<std::string> Args;for(int I=0;I<Argc;++I)Args.push_back(Argv[I]);Args[0]=std::string(Exe.str());Args[5]=Dir;
    // The child consumes an explicit plan and never recursively starts search.
    setenv("DECISION_GAP_STATE",StateFile.c_str(),1);
    int RC=gapCommand(Args,Dir+".stdout",Dir+".stderr");unsetenv("DECISION_GAP_STATE");
    json::Object Row{{"action",Action.str()},{"directory",Dir},{"state",S.json()},{"exit_code",RC}};
    if(RC){if(sys::fs::exists(Dir+"/trial.json")){auto V=readGapJSON(Dir+"/trial.json");if(auto *O=V.getAsObject())if(auto R=O->getString("reason"))Row["reason"]=R->str();}Trace.push_back(std::move(Row));return nullptr;}
    auto Report=readGapJSON(Dir+"/trial.json");auto *R=Report.getAsObject();
    if(!R||R->getString("status")!=Optional<StringRef>("verified"))throw std::runtime_error("unverified gap trial");
    RC=gapCommand({Worker,Dir+"/meld-raw.ll",Argv[2]},Dir+"/gap-tti.json",Dir+"/gap-tti.stderr");
    if(RC)throw std::runtime_error("gap TTI worker failed");
    auto CostJSON=readGapJSON(Dir+"/gap-tti.json");auto *C=CostJSON.getAsObject();
    if(!C||C->getInteger("unknown")!=Optional<int64_t>(0)||C->getString("source_revision")!=Optional<StringRef>("6be16f356d3e")||!C->getInteger("cost"))throw std::runtime_error("gap TTI cost unknown or revision mismatch");
    int64_t Cost=*C->getInteger("cost");Row["cost"]=Cost;Trace.push_back(std::move(Row));
    return std::unique_ptr<Candidate>(new Candidate{S,Dir,Cost,std::move(Report)});
  };
  auto Current=Evaluate(GapSearchState{},"all-gaps-protected");
  if(!Current)throw std::runtime_error("initial protected gap plan rejected");
  int64_t Initial=Current->Cost;json::Array Accepted;
  for(unsigned Round=0;;++Round) {
    if(Round>=100000)throw std::runtime_error("gap search round limit");
    std::unique_ptr<Candidate> Best;
    auto Consider=[&](GapSearchState S,const std::string &Action) {
      auto C=Evaluate(S,Action);
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
  for(auto Name:{"parent.ll","normalized.ll","meld-raw.ll","fused.ll","decisions.json","trial.json"})
    if(auto E=sys::fs::copy_file(Current->Dir+"/"+Name,Out+"/"+Name))throw std::runtime_error(E.message());
  writeGapJSON(Out+"/gap-search.json",json::Value(json::Object{{"status","completed"},{"objective","LLVM24 whole-function reciprocal-throughput TTI on raw generated plan; no cleanup assumptions"},{"initial_cost",Initial},{"final_cost",Current->Cost},{"trials",int64_t(Trials)},{"selected",Current->Dir},{"accepted",std::move(Accepted)},{"trace",std::move(Trace)}}));
  return 0;
 } catch(const std::exception &E) {errs()<<E.what()<<"\n";return 3;}
}
} // namespace decision
