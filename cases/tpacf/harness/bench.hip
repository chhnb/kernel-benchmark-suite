#include <hip/hip_runtime.h>
#include "../../../runner/options.hpp"
#include <cmath>
#include <cstdint>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <set>
#include <stdexcept>
#include <string>
#include <vector>

#define H(x) do{hipError_t err=(x);if(err!=hipSuccess)throw std::runtime_error(std::string(#x)+": "+hipGetErrorString(err));}while(0)
constexpr int N=16384;constexpr size_t WORDS=size_t(N)*N/4,BYTES=WORDS*4,G=256;
struct cartesian{double*x,*y,*z;int*jk;};static_assert(sizeof(cartesian)==32,"original kernel ABI");
void save(fs::path p,const void*v,size_t n){std::ofstream f(p,std::ios::binary);f.write((const char*)v,n);if(!f)throw std::runtime_error("save "+p.string());}
template<class T>std::vector<T>load(fs::path p,size_t n){if(fs::file_size(p)!=n*sizeof(T))throw std::runtime_error("extent "+p.string());std::vector<T>v(n);std::ifstream f(p,std::ios::binary);f.read((char*)v.data(),n*sizeof(T));if(!f)throw std::runtime_error("read "+p.string());return v;}
struct Buf{unsigned char*raw=nullptr;size_t n;explicit Buf(size_t n):n(n){H(hipMalloc((void**)&raw,n+2*G));H(hipMemset(raw,0xa5,n+2*G));}void*ptr(){return raw+G;}bool guards(){unsigned char a[G],b[G];H(hipMemcpy(a,raw,G,hipMemcpyDeviceToHost));H(hipMemcpy(b,raw+G+n,G,hipMemcpyDeviceToHost));for(size_t i=0;i<G;i++)if(a[i]!=0xa5||b[i]!=0xa5)return false;return true;}~Buf(){if(raw)(void)hipFree(raw);}};
struct Role{std::string name,path;hipModule_t module{};hipFunction_t fn{};hipDeviceptr_t bounds{};};
struct Result{size_t refErrors=0,expectedErrors=0;bool inputs=true,guards=true,bounds=true;bool safe()const{return inputs&&guards&&bounds;}};
int main(int argc,char**argv){try{
 Options options(argc,argv);if(options.timing!="event")throw std::runtime_error("event only");
 bool timing=options.mode=="benchmark";fs::path fixtures=fs::canonical(options.input),out=options.output;
 if(!fs::is_regular_file(fixtures/"prepared.txt"))throw std::runtime_error("CPU fixture not prepared");
 std::vector<Role> roles{{"kernel",options.kernel}};
 // One required oracle read per process; never reread to hash/checksum or deduplicate.
 auto reference=load<uint32_t>(fixtures/"reference.bin",WORDS);auto bounds=load<double>(fixtures/"bounds.bin",63);std::vector<std::vector<double>>input;
 for(int set=0;set<2;set++)for(int c=0;c<3;c++)input.push_back(load<double>(fixtures/((set?"b":"a")+std::to_string(c)+".bin"),N));
 for(auto&v:input)for(double x:v)if(!std::isfinite(x))throw std::runtime_error("nonfinite input");for(double x:bounds)if(!std::isfinite(x))throw std::runtime_error("nonfinite bounds");
 fs::create_directories(out);{std::ofstream f(out/"fixture-directory.txt");f<<fixtures.string()<<"\n";if(!f)throw std::runtime_error("fixture binding write");}
 H(hipInit(0));H(hipSetDevice(0));hipDeviceProp_t prop{};H(hipGetDeviceProperties(&prop,0));if(prop.warpSize!=64)throw std::runtime_error("wave64 required");{std::ofstream f(out/"device.txt");f<<prop.name<<" wave="<<prop.warpSize<<"\n";}
 Buf a0(N*8),a1(N*8),a2(N*8),b0(N*8),b1(N*8),b2(N*8),output(BYTES);Buf*ins[]={&a0,&a1,&a2,&b0,&b1,&b2};for(int i=0;i<6;i++)H(hipMemcpy(ins[i]->ptr(),input[i].data(),N*8,hipMemcpyHostToDevice));
 for(auto&r:roles){H(hipModuleLoad(&r.module,r.path.c_str()));H(hipModuleGetFunction(&r.fn,r.module,"ACFKernel"));size_t n;H(hipModuleGetGlobal(&r.bounds,&n,r.module,"binbounds"));if(n!=bounds.size()*8)throw std::runtime_error("binbounds extent");H(hipMemcpy((void*)r.bounds,bounds.data(),n,hipMemcpyHostToDevice));}
 cartesian da{(double*)a0.ptr(),(double*)a1.ptr(),(double*)a2.ptr(),nullptr},db{(double*)b0.ptr(),(double*)b1.ptr(),(double*)b2.ptr(),nullptr};void*dp=output.ptr();void*args[]={&da,&db,&dp};
 auto launch=[&](Role&r){H(hipModuleLaunchKernel(r.fn,128,128,1,128,1,1,128*sizeof(double3),0,args,nullptr));H(hipGetLastError());};
 std::vector<uint32_t>got(WORDS);std::vector<double>inputCheck(N),boundsCheck(63);
 std::ofstream proof(out/"validation.csv");proof<<"role,kind,words_scanned,reference_mismatches,expected_mismatches,input_unchanged,guards,bounds_unchanged,accepted,canonical_target,failure_output\n";
 auto inspect=[&](Role&r,const std::string&kind,int negative)->Result{
  H(hipMemcpy(got.data(),dp,BYTES,hipMemcpyDeviceToHost));Result z;
  // The only complete comparison pass for this readback. XOR expected comparison
  // and uncorrupted oracle rejection count are fused into the same traversal.
  const size_t badPos=negative==1?WORDS-1:0;
  for(size_t i=0;i<WORDS;i++){uint32_t want=reference[i];z.refErrors+=got[i]!=want;if(negative>=0&&i==badPos)want^=4u;z.expectedErrors+=got[i]!=want;}
  fs::path dir=out/r.name;fs::create_directories(dir);std::string failure;
  try{
   for(int i=0;i<6;i++){H(hipMemcpy(inputCheck.data(),ins[i]->ptr(),N*8,hipMemcpyDeviceToHost));bool equal=std::memcmp(inputCheck.data(),input[i].data(),N*8)==0;z.inputs&=equal;z.guards&=ins[i]->guards();if(!equal)save(dir/(kind+"-changed-input"+std::to_string(i)+".bin"),inputCheck.data(),N*8);}
   z.guards&=output.guards();H(hipMemcpy(boundsCheck.data(),(void*)r.bounds,63*8,hipMemcpyDeviceToHost));z.bounds=std::memcmp(boundsCheck.data(),bounds.data(),63*8)==0;
  }catch(...){save(dir/(kind+"-failure.bin"),got.data(),BYTES);throw;}
  bool ok=z.safe()&&z.expectedErrors==0&&z.refErrors==size_t(negative>=0);
  if(!ok){failure=(dir/(kind+"-failure.bin")).string();save(failure,got.data(),BYTES);}
  std::string canonical=(fixtures/(negative<0?"reference.bin":"negative"+std::to_string(negative)+".bin")).string();
  proof<<r.name<<","<<kind<<","<<WORDS<<","<<z.refErrors<<","<<z.expectedErrors<<","<<z.inputs<<","<<z.guards<<","<<z.bounds<<","<<ok<<","<<(ok?canonical:"")<<","<<failure<<"\n";proof.flush();if(!proof)throw std::runtime_error("proof write failed");return z;
 };
 hipEvent_t start,stop;H(hipEventCreate(&start));H(hipEventCreate(&stop));
 std::ofstream samples(out/"samples.csv");samples<<std::setprecision(10)<<"round,warmup,microseconds,timing,full_output_passed\n";
 for(int round=0;round<options.rounds();++round){auto&r=roles[0];
  for(int i=0;i<6;i++){H(hipMemset(ins[i]->raw,0xa5,ins[i]->n+2*G));H(hipMemcpy(ins[i]->ptr(),input[i].data(),N*8,hipMemcpyHostToDevice));}
  H(hipMemset(output.raw,0xa5,output.n+2*G));H(hipMemcpy((void*)r.bounds,bounds.data(),63*8,hipMemcpyHostToDevice));
  H(hipEventRecord(start,0));launch(r);H(hipEventRecord(stop,0));H(hipEventSynchronize(stop));float ms;H(hipEventElapsedTime(&ms,start,stop));
  auto result=inspect(r,"round"+std::to_string(round),-1);
  if(!result.safe()||result.refErrors||result.expectedErrors)throw std::runtime_error("full output validation failed");
  samples<<round<<","<<(timing&&!options.measured(round))<<","<<(timing?ms*1000:0)<<",event,1\n";samples.flush();if(!samples)throw std::runtime_error("samples write");
 }
 H(hipEventDestroy(start));H(hipEventDestroy(stop));
 {std::ofstream f(out/"result.json");f<<"{\"passed\":true,\"launches\":"<<options.rounds()<<",\"words_per_launch\":"<<WORDS<<"}\n";}
 H(hipDeviceSynchronize());for(auto&r:roles)H(hipModuleUnload(r.module));return 0;
}catch(const std::exception&e){std::cerr<<"ERROR "<<e.what()<<"\n";return 2;}}
