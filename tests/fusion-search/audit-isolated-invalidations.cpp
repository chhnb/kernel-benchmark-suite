#include "isolated_b2b_greedy.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FormatVariadic.h"
#include <fstream>
using namespace llvm;using namespace fusion;
int main(int argc,char **argv){
 if(argc!=4)return 2;SMDiagnostic error;
 std::map<std::string,IncrementalCandidateQueue::ReadSet> previous;
 std::map<std::string,unsigned> reasons;unsigned retained=0,changed=0;
 for(unsigned step=0;step<=unsigned(std::stoi(argv[3]));++step){
  LLVMContext ctx;
  auto path=std::string(argv[1])+(step?"/full-"+std::to_string(step-1)+".ll":"/input.ll");
  auto m=parseIRFile(path,error,ctx);if(!m){error.print(argv[0],errs());return 2;}
  auto *f=m->getFunction(argv[2]);if(!f)return 2;
  auto snapshot=IRDependencySnapshot::isolatedPlanning(*m);IRIdentity ids(*m);auto scoring=isolatedScoringReads(*f,ids);
  std::map<std::string,IncrementalCandidateQueue::ReadSet> current;
  for(auto &b:*f){auto unit=B2BOptimizationUnit::discover(b,ids);if(!unit.eligible())continue;
   auto *exit=ids.lookup(unit.exit)->getParent();if(exit->phis().empty())continue;
   auto reads=isolatedReads(snapshot,unit);addIsolatedScoringReads(reads,scoring,ids,unit);
   auto old=previous.find(unit.identity);
   if(old!=previous.end()){
    ++retained;std::set<std::string> families;
    for(auto &kv:reads){auto it=old->second.find(kv.first);if(it==old->second.end()||it->second!=kv.second)families.insert(kv.first.substr(0,kv.first.find(':')));}
    for(auto &kv:old->second)if(!reads.count(kv.first))families.insert(kv.first.substr(0,kv.first.find(':')));
    if(families.count("context")&&changed==0){
     std::ofstream(std::string(argv[1])+"/context-before.txt")<<old->second.at("context");
     std::ofstream(std::string(argv[1])+"/context-after.txt")<<reads.at("context");
    }
    if(!families.empty())++changed;for(auto &family:families)++reasons[family];
   }
   current.emplace(unit.identity,std::move(reads));
  }
  previous=std::move(current);
 }
 json::Object why;for(auto &kv:reasons)why[kv.first]=int64_t(kv.second);
 outs()<<formatv("{0:2}\n",json::Value(json::Object{{"retained",int64_t(retained)},{"invalidated",int64_t(changed)},{"read_families",std::move(why)}}));
}
