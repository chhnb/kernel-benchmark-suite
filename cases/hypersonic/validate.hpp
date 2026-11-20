#include "../../runner/options.hpp"
inline Options* suite_options=nullptr;
#include <vector>
#include <string>
#include <fstream>
#include <sstream>
#include <cmath>
#include <cstring>
#include <sys/stat.h>
#include <iomanip>
#include <algorithm>
static int validation_step=-1,validation_stage=0;
static void dump_bytes(const std::string &file,const void*p,size_t n){FILE*f=fopen(file.c_str(),"wb");if(!f||fwrite(p,1,n,f)!=n)exit(7);fclose(f);}
static bool same_num(double a,double b){return std::isfinite(a)&&std::isfinite(b)&&fabs(a-b)<=1e-12+1e-10*fabs(b);}
struct InputView{const void *p;size_t bytes;};
template<class Index,class Launch>
static void validate_batch(const std::string &case_name,int step,const SimConfig &cfg,const std::vector<InputView>&inputs,const double*const refptr[4],int cells,int faces,Index index,Launch launch){
 bool screen=getenv("PERF_PHASE") && std::string(getenv("PERF_PHASE"))=="screen";
 CK(hipDeviceSynchronize());std::string dir=std::string(getenv("SUITE_OUTPUT"))+"/"+case_name+"-"+std::to_string(step);mkdir(dir.c_str(),0755);
 auto fixture_equal=[&](const std::string &file,const void *ptr,size_t bytes){std::ifstream f(std::string(getenv("SUITE_INPUT"))+"/"+case_name+"-"+std::to_string(step)+"/"+file,std::ios::binary);if(!f)exit(20);std::vector<char> b(bytes);f.read(b.data(),bytes);if(size_t(f.gcount())!=bytes||memcmp(b.data(),ptr,bytes))exit(21);};
 fixture_equal("cfg.bin",&cfg,sizeof(cfg));
 std::vector<std::vector<unsigned char>> original(inputs.size());
 for(size_t j=0;j<inputs.size();j++){original[j].resize(inputs[j].bytes);CK(hipMemcpy(original[j].data(),inputs[j].p,inputs[j].bytes,hipMemcpyDeviceToHost));fixture_equal("input"+std::to_string(j)+".bin",original[j].data(),original[j].size());}
 std::vector<double> ref[4];std::vector<double> tmp(cells);std::vector<unsigned char> valid(cells,0);
 for(int t=0;t<faces;t++)valid[index(t)]=1;
 for(int k=0;k<4;k++){CK(hipMemcpy(tmp.data(),refptr[k],cells*8,hipMemcpyDeviceToHost));ref[k].resize(faces);for(int t=0;t<faces;t++)ref[k][t]=tmp[index(t)];fixture_equal("reference"+std::to_string(k)+".bin",ref[k].data(),faces*8);}
 struct Role {std::string name,path;hipModule_t mod;hipFunction_t fn;};std::vector<Role> entries;
 std::ifstream roles(getenv("SUITE_ROLES"));if(!roles)exit(8);std::ofstream log(dir+"/checks.jsonl");log<<std::setprecision(17);std::string role,path;
 while(roles>>role>>path){Role r{role,path};CK(hipModuleLoad(&r.mod,path.c_str()));CK(hipModuleGetFunction(&r.fn,r.mod,"face_kernel"));hipDeviceptr_t config;size_t cb=0;CK(hipModuleGetGlobal(&config,&cb,r.mod,"d_cfg"));if(cb!=sizeof(cfg))exit(9);CK(hipMemcpy(config,&cfg,cb,hipMemcpyHostToDevice));entries.push_back(r);}
 hipEvent_t start_event,end_event;CK(hipEventCreate(&start_event));CK(hipEventCreate(&end_event));
 for(int round=0;round<suite_options->rounds();round++)for(size_t slot=0;slot<entries.size();slot++){
  size_t order=(round/2+((round%2)?entries.size()-1-slot:slot))%entries.size();
  Role&r=entries[order];role=r.name;hipFunction_t fn=r.fn;
  double *allocation[4],*output[4];std::vector<unsigned char> poison((cells+64)*8,0xff);memset(poison.data(),0xa5,256);memset(poison.data()+(cells+32)*8,0xa5,256);
  for(int k=0;k<4;k++){CK(hipMalloc(&allocation[k],poison.size()));CK(hipMemcpy(allocation[k],poison.data(),poison.size(),hipMemcpyHostToDevice));output[k]=allocation[k]+32;}
  printf("VALIDATE %s step%d %s\n",case_name.c_str(),step,role.c_str());fflush(stdout);float elapsed_ms=0;
  if(screen)CK(hipEventRecord(start_event,0));
  launch(fn,output);
  if(screen){CK(hipEventRecord(end_event,0));CK(hipEventSynchronize(end_event));CK(hipEventElapsedTime(&elapsed_ms,start_event,end_event));}else CK(hipDeviceSynchronize());bool ok=true,guards=true,readonly=true;double maxabs=0;long mismatches=0;int negatives=0;
  std::vector<double> got(faces);std::vector<unsigned char> raw(poison.size());
  for(int k=0;k<4;k++){
   CK(hipMemcpy(raw.data(),allocation[k],raw.size(),hipMemcpyDeviceToHost));guards &= memcmp(raw.data(),poison.data(),256)==0 && memcmp(raw.data()+(cells+32)*8,poison.data()+(cells+32)*8,256)==0;
   double *v=reinterpret_cast<double*>(raw.data())+32;bool component=true;
   for(int t=0;t<faces;t++){got[t]=v[index(t)];bool pass=same_num(got[t],ref[k][t]);component &= pass;mismatches+=!pass;if(std::isfinite(got[t]))maxabs=fmax(maxabs,fabs(got[t]-ref[k][t]));}
   for(int i=0;i<cells;i++)if(!valid[i])guards &= memcmp(raw.data()+(i+32)*8,poison.data()+(i+32)*8,8)==0;
   if(!component)dump_bytes(dir+"/"+role+"-failed"+std::to_string(k)+".bin",got.data(),faces*8);
   ok &= component;CK(hipFree(allocation[k]));
  }
  std::vector<unsigned char> scan;
  for(size_t j=0;j<inputs.size();j++){scan.resize(inputs[j].bytes);CK(hipMemcpy(scan.data(),inputs[j].p,scan.size(),hipMemcpyDeviceToHost));bool good=scan==original[j];readonly &= good;if(!good)dump_bytes(dir+"/"+role+"-changedinput"+std::to_string(j)+".bin",scan.data(),scan.size());}
  log<<"{\"round\":"<<round<<",\"measurement\":"<<((suite_options->measured(round))?"true":"false")<<",\"milliseconds\":"<<elapsed_ms<<",\"slot\":"<<slot<<",";log<<"\"role\":\""<<role<<"\",\"pass\":"<<(ok?"true":"false")<<",\"guards\":"<<(guards?"true":"false")<<",\"readonly\":"<<(readonly?"true":"false")<<",\"negatives\":"<<negatives<<",\"mismatches\":"<<mismatches<<",\"maxabs\":"<<maxabs<<"}\n";log.flush();
  if(!guards||!readonly)exit(10);
  if(!ok)exit(11);
 }
 for(auto&r:entries)CK(hipModuleUnload(r.mod));CK(hipEventDestroy(start_event));CK(hipEventDestroy(end_event));
}
