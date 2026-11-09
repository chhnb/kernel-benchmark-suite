#include "fusion_search.h"
#include "llvm24_scorer.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include <set>
#include <algorithm>
#include <fstream>
#include <stdexcept>
using namespace llvm;using namespace fusion;
using Tags=std::set<std::string>;
static void constants(Value*v,Tags&out){
 if(auto*c=dyn_cast<ConstantFP>(v)){std::string s;raw_string_ostream o(s);c->print(o);out.insert(o.str());}
 else if(isa<ConstantVector>(v)||isa<ConstantDataVector>(v)){
  auto*c=cast<Constant>(v);unsigned n=cast<FixedVectorType>(c->getType())->getNumElements();
  for(unsigned i=0;i<n;i++)constants(c->getAggregateElement(i),out);
 }
}
static Tags tags(BasicBlock&b){Tags t;for(auto&i:b)for(auto&v:i.operands())constants(v.get(),t);return t;}
static void save(Module&m,const std::string&p){std::error_code ec;raw_fd_ostream o(p,ec);if(ec)throw std::runtime_error(ec.message());m.print(o,nullptr);}
int main(int argc,char**argv){try{
 if(argc!=4)throw std::runtime_error("input.ll output-directory");
 std::string dir=argv[2];if(sys::fs::exists(dir))throw std::runtime_error("output exists");sys::fs::create_directories(dir);
 LLVMContext ctx;SMDiagnostic err;auto m=parseIRFile(argv[1],err,ctx);if(!m)throw std::runtime_error("parse");/* Preserve the exact suite baseline; final codegen O3 is separate. */
 auto*f=m->getFunction("evaluate");std::vector<BasicBlock*> bs;std::map<std::string,int> counts;
 for(auto&b:*f){bs.push_back(&b);for(auto&t:tags(b))counts[t]++;}
 std::vector<Tags> signatures;std::vector<std::string> leafNames;
 std::ofstream mapping(dir+"/anchors.txt");
 for(int n:{89,91,93,95,97,99,101,103,105,107,109,111}){
  leafNames.push_back(bs.at(n)->getName().str());Tags unique;for(auto&t:tags(*bs.at(n)))if(counts[t]==1)unique.insert(t);
  if(unique.empty())throw std::runtime_error("no unique constants");
  mapping<<"L"<<signatures.size()<<" B"<<n<<" "<<bs.at(n)->getName().str()<<" "<<unique.size()<<" anchors\n";
  for(auto&t:unique)mapping<<t<<"\n";signatures.push_back(unique);
 }
 save(*m,dir+"/state-0.ll");
 std::vector<std::pair<std::vector<int>,std::vector<int>>> plan={
 {{4},{5}},{{6},{7}},{{4,5},{6,7}}};
 std::ofstream log(dir+"/steps.tsv");log<<"step\tleft_group\tright_group\tcandidate\tgain\tbefore_cost\tafter_cost\n";
 unsigned ver=0;LLVM24Scorer scorer("/home/chh/kernel-benchmark-suite/tools/run-llvm24-tti");
 for(auto&step:plan){
  auto find=[&](const std::vector<int>&group){
   std::vector<std::string> matches;unsigned i=0;
   if(group.size()>1){
    std::set<std::string> wanted;for(int n:group)wanted.insert(leafNames[n]);
    unsigned bi=0;for(auto &bb:*m->getFunction("evaluate")){
      if(auto *md=bb.getTerminator()->getMetadata("fusion.logical.arm")){
        std::set<std::string> actual;for(auto &v:md->operands())if(auto *str=dyn_cast<MDString>(v.get()))actual.insert(str->getString().str());
        if(actual==wanted)matches.push_back("G"+std::to_string(bi));
      }++bi;
    }
    if(matches.size()!=1)throw std::runtime_error("logical group ambiguity "+std::to_string(matches.size()));
    return matches[0];
   }
   for(auto&b:*m->getFunction("evaluate")){
    auto ts=tags(b);bool ok=true;for(int leaf:group){bool found=false;for(auto&t:signatures[leaf])found|=ts.count(t);ok&=found;}
    if(ok)matches.push_back("B"+std::to_string(i));i++;
   }
   if(matches.size()!=1)throw std::runtime_error("group anchor ambiguity "+std::to_string(matches.size()));
   return matches[0];
  };
  auto l=find(step.first),r=find(step.second);auto cs=enumerate(*m->getFunction("evaluate"),ver);
  std::vector<Candidate> matches;for(auto&c:cs)if((c.left==l&&c.right==r)||(c.left==r&&c.right==l))matches.push_back(c);
  if(matches.empty())throw std::runtime_error("candidate missing "+l+" "+r);
  Analysis analysis(*m->getFunction("evaluate"));
  std::vector<BasicBlock*> current;for(auto&b:*m->getFunction("evaluate"))current.push_back(&b);
  auto depth=[&](const Candidate&c){return analysis.dt.getNode(current.at(std::stoul(c.split.substr(1))))->getLevel();};
  std::sort(matches.begin(),matches.end(),[&](const Candidate&a,const Candidate&b){return depth(a)!=depth(b)?depth(a)>depth(b):a.key()<b.key();});
  for(auto&x:matches)errs()<<"matching "<<x.key()<<" depth "<<depth(x)<<"\n";
  auto c=matches[0];c.hybrid=true;auto round=makeRound(*m,"evaluate",ver,3,CleanupMode::ScopedCFG);auto trial=tryPair(*m,c,ver,3,CleanupMode::ScopedCFG);
  if(!trial.valid)throw std::runtime_error("rejected "+trial.reason);auto score=evaluateTrial(*m,trial,round,scorer);
  if(score.status!=ScoreStatus::Scored)throw std::runtime_error(score.reason);
  if(verifyModule(*trial.normalized,&errs()))throw std::runtime_error("verify");
  outs()<<"merge_path "<<trial.mergePath<<" replication "<<trial.replication<<"\n";
  save(*trial.raw,dir+"/raw-"+std::to_string(ver+1)+".ll");
  auto groupstr=[](const std::vector<int>&v){std::string s;for(int i:v){if(!s.empty())s+=",";s+="L"+std::to_string(i);}return s;};
  log<<ver+1<<"\t"<<groupstr(step.first)<<"\t"<<groupstr(step.second)<<"\t"<<c.key()<<"\t"<<score.staticGain<<"\t"<<score.metrics.at("work_before")<<"\t"<<score.metrics.at("work_after")<<"\n";log.flush();
  outs()<<"step "<<ver+1<<" "<<c.key()<<" gain "<<score.staticGain<<"\n";outs().flush();
  m=std::move(trial.normalized);ver++;save(*m,dir+"/state-"+std::to_string(ver)+".ll");
 }
 save(*m,dir+"/result.ll");outs()<<"3 prescribed merges complete; no score-based extra merges\n";return 0;
}catch(const std::exception&e){errs()<<e.what()<<"\n";return 1;}}
