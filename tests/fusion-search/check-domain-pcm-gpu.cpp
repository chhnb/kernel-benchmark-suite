#include <hip/hip_runtime.h>
#include <algorithm>
#include <vector>
#include <random>
#include <cstdio>
#include <cstdlib>
#define H(expr) do { auto e=(expr);if(e!=hipSuccess){fprintf(stderr,"%s: %s\n",#expr,hipGetErrorString(e));exit(1);} }while(0)
int main(int argc,char**argv){
 if(argc!=3)return 2;H(hipSetDevice(0));
 const int blocks=16,group=8192,n=blocks*group;
 std::vector<int> input(n),reference(n),old(n),now(n);int *device;H(hipMalloc(&device,n*sizeof(int)));
 hipModule_t mods[2];hipFunction_t funcs[2];
 for(int k=0;k<2;k++){H(hipModuleLoad(&mods[k],argv[k+1]));H(hipModuleGetFunction(&funcs[k],mods[k],"_Z3pcmPi"));}
 for(unsigned seed=0;seed<4;seed++){
  std::mt19937 rng(seed);for(int&i:input)i=int(rng()%100000);
  // Each lane starts with a sorted 32-element subsequence, as in artifact.
  for(int j=0;j<n;j+=32)std::sort(input.begin()+j,input.begin()+j+32);
  reference=input;for(int j=0;j<n;j+=group)std::sort(reference.begin()+j,reference.begin()+j+group);
  for(int k=0;k<2;k++){
   H(hipMemcpy(device,input.data(),n*sizeof(int),hipMemcpyHostToDevice));void*args[]={&device};
   H(hipModuleLaunchKernel(funcs[k],blocks,1,1,256,1,1,0,nullptr,args,nullptr));H(hipDeviceSynchronize());
   auto &out=k?now:old;H(hipMemcpy(out.data(),device,n*sizeof(int),hipMemcpyDeviceToHost));
  }
  if(old!=now){fprintf(stderr,"baseline/new mismatch seed %u\n",seed);return 1;}
  if(now!=reference){fprintf(stderr,"CPU sort mismatch seed %u\n",seed);return 1;}
  printf("PASS seed %u: %d output elements identical to baseline and CPU sort\n",seed,n);
 }
 H(hipFree(device));for(auto m:mods)H(hipModuleUnload(m));
}
