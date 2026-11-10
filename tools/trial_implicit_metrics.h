#pragma once
#include <array>
#include <set>
#include <vector>
#include <cstdlib>
#include "llvm/Support/Program.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/JSON.h"
#include <stdexcept>
namespace decision {
inline void recordImplicitMetrics(llvm::json::Object &report,const char *executable,
 llvm::Function &f,const std::string &dir,const std::vector<unsigned>(&before)[2],
 const std::vector<unsigned>(&after)[2],bool masksOK,std::string why){
 using namespace llvm;
 report["implicit_speculation_cost_true"]=nullptr;report["implicit_speculation_cost_false"]=nullptr;
 report["implicit_speculation_metrics_available"]=false;
 report["implicit_speculation_metric_scope"]="net cleanup delta of conservative uniform reachable-block TTI costs";
 try{
  if(!masksOK)throw std::runtime_error(why.empty()?"side_condition_unavailable":why);
  SmallString<256> exe;if(auto e=sys::fs::real_path(executable,exe))throw std::runtime_error(e.message());
  std::string worker;
  if(const char*v=std::getenv("DECISION_TTI_WORKER"))worker=v;
  else{auto root=sys::path::parent_path(sys::path::parent_path(sys::path::parent_path(exe)));worker=(root+"/tools/run-llvm24-tti").str();}
  int64_t sums[2][2]{};
  for(unsigned stage=0;stage<2;++stage){
   std::string prefix=dir+(stage?"/post-full-cleanup":"/pre-full-cleanup");
   std::string input=prefix+".ll",output=prefix+"-tti.json",error=prefix+"-tti.stderr",name=f.getName().str();
   for(auto &p:{output,error})if(auto e=sys::fs::remove(p))throw std::runtime_error(e.message());
   std::array<StringRef,3> args{{worker,input,name}};std::array<Optional<StringRef>,3> redirects{{StringRef(""),StringRef(output),StringRef(error)}};
   if(sys::ExecuteAndWait(worker,args,None,redirects,60))throw std::runtime_error("implicit_metrics_worker_failed");
   auto buffer=MemoryBuffer::getFile(output);if(!buffer)throw std::runtime_error("implicit_metrics_output_missing");
   auto parsed=json::parse((*buffer)->getBuffer());if(!parsed)throw std::runtime_error(toString(parsed.takeError()));
   auto*o=parsed->getAsObject();if(!o||o->getString("source_revision")!=Optional<StringRef>("6be16f356d3e")||o->getInteger("unknown")!=Optional<int64_t>(0))throw std::runtime_error("implicit_metrics_unknown_cost_or_worker");
   auto*rows=o->getArray("instruction_costs");if(!rows)throw std::runtime_error("implicit_metrics_rows_missing");
   for(unsigned side=0;side<2;++side){
    const auto &blocks=stage?after[side]:before[side];std::set<int64_t>wanted(blocks.begin(),blocks.end()),found;
    for(auto &v:*rows){auto*row=v.getAsObject();if(!row)throw std::runtime_error("implicit_metrics_bad_row");auto block=row->getInteger("block_index");if(!block)throw std::runtime_error("implicit_metrics_bad_block");if(wanted.count(*block)){auto cost=row->getInteger("accepted_cost");if(!cost)throw std::runtime_error("implicit_metrics_unknown_instruction");sums[stage][side]+=*cost;found.insert(*block);}}
    if(wanted!=found)throw std::runtime_error("implicit_metrics_block_coverage");
   }
  }
  report["implicit_speculation_cost_false"]=sums[1][0]-sums[0][0];report["implicit_speculation_cost_true"]=sums[1][1]-sums[0][1];
  report["implicit_speculation_metrics_available"]=true;report["implicit_speculation_metrics_reason"]="measured";
 }catch(const std::exception&e){report["implicit_speculation_metrics_reason"]=std::string(e.what());}
}
}
