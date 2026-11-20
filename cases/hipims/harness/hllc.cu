#include <cuda.h>
#include "../source/kernel.cu"
#include <vector>
#include <fstream>
#include <string>
#include <iostream>
#include <stdexcept>
#include <limits>
using namespace GC;
void ck(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
template<class T> std::vector<T> read(const std::string& path){std::ifstream f(path,std::ios::binary|std::ios::ate);if(!f)throw std::runtime_error(path);auto n=f.tellg();if(n%sizeof(T))throw std::runtime_error("size");std::vector<T> x(n/sizeof(T));f.seekg(0);f.read((char*)x.data(),n);if(!f)throw std::runtime_error("read");return x;}
template<class T> T* upload(const std::vector<T>& x){T* p;ck(cudaMalloc(&p,x.size()*sizeof(T)));ck(cudaMemcpy(p,x.data(),x.size()*sizeof(T),cudaMemcpyHostToDevice));return p;}
int main(int argc,char**argv){try{
 if(argc!=6)throw std::runtime_error("prefix oracle_prefix correctness|timing");
 std::string p=argv[1],o=argv[2],mode=argv[3];if(mode!="correctness"&&mode!="timing")throw std::runtime_error("mode");
 unsigned n,stride,width,blocks,threads;double time;std::ifstream meta(p+"meta.txt");meta>>n>>stride>>width>>blocks>>threads>>time;if(!meta||width!=4||n!=stride)throw std::runtime_error("metadata");
 auto g=read<Scalar>(p+"gravity.bin"),h=read<Scalar>(p+"h.bin"),hb=read<Scalar>(p+"h_bound.bin"),z=read<Scalar>(p+"z.bin"),zb=read<Scalar>(p+"z_bound.bin"),v=read<Scalar>(p+"volume.bin");
 auto zg=read<Vector>(p+"z_gradient.bin"),hu=read<Vector>(p+"hU.bin"),hub=read<Vector>(p+"hU_bound.bin");auto nb=read<ShortDualHandle>(p+"neighbours.bin");
 if(g.size()!=n||h.size()!=n||z.size()!=n||v.size()!=n||zg.size()!=n||hu.size()!=n||nb.size()!=4*n)throw std::runtime_error("input length");
 auto dg=upload(g),dh=upload(h),dhb=upload(hb),dz=upload(z),dzb=upload(zb),dv=upload(v);auto dzg=upload(zg),dhu=upload(hu),dhub=upload(hub);auto dnb=upload(nb);
 const double sentinel=1234567.25;std::vector<Scalar> oh(n+2,sentinel);std::vector<Vector> ou(n+2,Vector(sentinel,sentinel));auto doh=upload(oh);auto dou=upload(ou);
 auto refh=read<Scalar>(o+"h_advection.bin");auto refu=read<Vector>(o+"hU_advection.bin");if(refh.size()!=n||refu.size()!=n)throw std::runtime_error("oracle length");
 auto check=[](double a,double b){return std::isfinite(a)&&std::isfinite(b)&&std::abs(a-b)<=1e-10+1e-10*std::max(std::abs(a),std::abs(b));};
 CUmodule module;CUfunction function;if(cuModuleLoad(&module,argv[4])!=CUDA_SUCCESS||cuModuleGetFunction(&function,module,argv[5])!=CUDA_SUCCESS)throw std::runtime_error("module load");
 cudaEvent_t start,stop;ck(cudaEventCreate(&start));ck(cudaEventCreate(&stop));int count=mode=="timing"?7:1;
 for(int r=0;r<count;r++){
  ck(cudaMemset(doh+1,0xff,n*sizeof(Scalar)));ck(cudaMemset(dou+1,0xff,n*sizeof(Vector)));
  ck(cudaEventRecord(start));auto argoh=doh+1;auto argou=dou+1;void* params[]={&dg,&dh,&dhb,&dz,&dzb,&dzg,&dhu,&dhub,&n,&dnb,&stride,&dv,&argoh,&argou};if(cuLaunchKernel(function,blocks,1,1,threads,1,1,0,0,params,0)!=CUDA_SUCCESS)throw std::runtime_error("driver launch");ck(cudaGetLastError());ck(cudaEventRecord(stop));ck(cudaEventSynchronize(stop));
  float ms;ck(cudaEventElapsedTime(&ms,start,stop));ck(cudaMemcpy(oh.data(),doh,oh.size()*sizeof(Scalar),cudaMemcpyDeviceToHost));ck(cudaMemcpy(ou.data(),dou,ou.size()*sizeof(Vector),cudaMemcpyDeviceToHost));
  if(oh.front()!=sentinel||oh.back()!=sentinel||ou.front().x!=sentinel||ou.front().y!=sentinel||ou.back().x!=sentinel||ou.back().y!=sentinel)throw std::runtime_error("guard");
  for(unsigned i=0;i<n;i++)if(!check(oh[i+1],refh[i])||!check(ou[i+1].x,refu[i].x)||!check(ou[i+1].y,refu[i].y)){std::cerr<<"mismatch "<<i<<"\n";return 2;}
  std::cout<<r<<" "<<(mode=="timing"?(r<2?"warmup":"measurement"):"correctness")<<" "<<ms*1000<<" us verified "<<3*n<<"\n";
 }
 ck(cudaEventDestroy(start));ck(cudaEventDestroy(stop));for(void* a:{(void*)dg,(void*)dh,(void*)dhb,(void*)dz,(void*)dzb,(void*)dv,(void*)dzg,(void*)dhu,(void*)dhub,(void*)dnb,(void*)doh,(void*)dou})ck(cudaFree(a));
 cuModuleUnload(module);return 0;
}catch(const std::exception&e){std::cerr<<e.what()<<"\n";return 1;}}
