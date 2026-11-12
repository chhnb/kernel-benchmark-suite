#include <cuda.h>
#include "device.cu"
#include <array>
#include <stdexcept>
#include <string>

static void checkCuda(cudaError_t e) {
  if(e!=cudaSuccess) throw std::runtime_error(cudaGetErrorString(e));
}
static void checkDriver(CUresult e) {
  if(e!=CUDA_SUCCESS) { const char* msg=nullptr;cuGetErrorString(e,&msg);throw std::runtime_error(msg?msg:"CUDA driver error");}
}
int main(int argc,char** argv) try {
  if (argc != 5 && argc != 6) {
    std::fprintf(stderr, "usage: bench GRID MAX_GREEDY_DELTA_PCT BASELINE GREEDY [DARM]\n");
    return 2;
  }
  const int roleCount=argc-3;
  const double maximumDelta=std::stod(argv[2]);
  cudaDeviceProp gpu{};
  checkCuda(cudaGetDeviceProperties(&gpu, 0));
  if (gpu.major != 7 || gpu.minor != 0 || std::string(gpu.name).find("TITAN V") == std::string::npos)
    throw std::runtime_error("the frozen performance limits require a TITAN V");
  const int size=std::stoi(argv[1]);
  if (size <= 0 || !std::isfinite(maximumDelta)) throw std::runtime_error("invalid benchmark parameters");
  Params hp{};
  hp.nx = size;
  hp.ny = size;
  hp.nz = size;
  hp.dx = 1.f / hp.nx;
  hp.dy = 1.f / hp.ny;
  hp.dz = 1.f / hp.nz;
  hp.cfl = 0.3333f;
  hp.u_ref = 10.f;
  hp.R = 10.f;
  hp.gamma_floor = 1.1f;
  hp.Twall = 0.02f;
  hp.tau_vib = 2e-4f;
  hp.theta_v = 0.2f;
  hp.sdf_cx = 0.5f;
  hp.sdf_cy = 0.5f;
  hp.sdf_cz = 0.5f;
  hp.sdf_r = 0.25f;
  hp.inflow_r = 0.02f;
  hp.inflow_p = 0.02f;
  hp.inflow_u = 100.0f;
  hp.inflow_v = 0.0f;
  hp.inflow_w = 0.0f;
  hp.sponge_n = 24;
  hp.sponge_strength = 0.05f;
  hp.sponge_out_n = 24;
  hp.sponge_out_strength = 0.05f;


  checkCuda(cudaMemcpyToSymbol(P,&hp,sizeof(hp)));
  const size_t n=size_t(size)*size*size;
  std::array<float*,6> input{},output{};
  for(auto& p:input) checkCuda(cudaMalloc(&p,n*sizeof(float)));
  for(auto& p:output) checkCuda(cudaMalloc(&p,n*sizeof(float)));
  uint8_t* solid;
  float* maxspeed;
  checkCuda(cudaMalloc(&solid,n));
  checkCuda(cudaMalloc(&maxspeed,sizeof(float)));
  const dim3 block(8,8,4),grid((size+7)/8,(size+7)/8,(size+3)/4);
  constexpr unsigned smem=(8+2*WENO_HALO)*(8+2*WENO_HALO)*(4+2*WENO_HALO)*25;
  checkCuda(cudaFuncSetAttribute(k_step,cudaFuncAttributeMaxDynamicSharedMemorySize,smem));
  k_build_solid_mask<<<grid,block>>>(solid);
  k_init<<<grid,block>>>(input[0],input[1],input[2],input[3],input[4],input[5],solid);
  checkCuda(cudaGetLastError());checkCuda(cudaDeviceSynchronize());
  float dt=0.00015f*64.f/size,gain=1.f;
  auto referenceStep=[&]{
    checkCuda(cudaMemset(maxspeed,0,sizeof(float)));
    k_step<<<grid,block,smem>>>(input[0],input[1],input[2],input[3],input[4],input[5],
      output[0],output[1],output[2],output[3],output[4],output[5],dt,gain,maxspeed,solid);
    checkCuda(cudaGetLastError());checkCuda(cudaDeviceSynchronize());
  };
  for(int i=0;i<12;++i) {referenceStep();input.swap(output);}
  referenceStep();
  std::array<std::vector<float>,6> ref;
  for(int i=0;i<6;++i) {
    ref[i].resize(n);checkCuda(cudaMemcpy(ref[i].data(),output[i],n*sizeof(float),cudaMemcpyDeviceToHost));
  }
  const char* name="_Z6k_stepPKfS0_S0_S0_S0_S0_PfS1_S1_S1_S1_S1_ffS1_PKh";
  std::vector<CUmodule> mods(roleCount);
  std::vector<CUfunction> fns(roleCount);
  for(int i=0;i<roleCount;++i) {
    checkDriver(cuModuleLoad(&mods[i],argv[i+3]));
    checkDriver(cuModuleGetFunction(&fns[i],mods[i],name));
    checkDriver(cuFuncSetAttribute(fns[i],CU_FUNC_ATTRIBUTE_MAX_DYNAMIC_SHARED_SIZE_BYTES,smem));
    CUdeviceptr ptr;
    size_t bytes;
    checkDriver(cuModuleGetGlobal(&ptr,&bytes,mods[i],"P"));
    if(bytes!=sizeof(hp)) throw std::runtime_error("Params ABI mismatch");
    checkDriver(cuMemcpyHtoD(ptr,&hp,bytes));
  }
  void* args[]={&input[0],&input[1],&input[2],&input[3],&input[4],&input[5],
    &output[0],&output[1],&output[2],&output[3],&output[4],&output[5],&dt,&gain,&maxspeed,&solid};
  std::vector<float> got(n);
  std::array<std::vector<float>,6> llvmRef;
  float llvmMax=0;
  checkCuda(cudaMemset(maxspeed,0,sizeof(float)));
  checkDriver(cuLaunchKernel(fns[0],grid.x,grid.y,grid.z,block.x,block.y,block.z,smem,nullptr,args,nullptr));
  checkCuda(cudaDeviceSynchronize());
  for(int i=0;i<6;++i) {
    llvmRef[i].resize(n);
    checkCuda(cudaMemcpy(llvmRef[i].data(),output[i],n*sizeof(float),cudaMemcpyDeviceToHost));
    float peak=0;
    for(size_t j=0;j<n;++j) {
      if(!std::isfinite(llvmRef[i][j])||!std::isfinite(ref[i][j])) throw std::runtime_error("nonfinite reference");
      peak=std::max(peak,std::abs(llvmRef[i][j]-ref[i][j]));
    }
    std::fprintf(stderr,"LLVM versus NVCC field %d max absolute difference %.9g\n",i,peak);
  }
  checkCuda(cudaMemcpy(&llvmMax,maxspeed,sizeof(float),cudaMemcpyDeviceToHost));
  auto equal=[](float a,float b){return std::isfinite(a)&&std::isfinite(b)&&std::abs(a-b)<=3e-5f+5e-5f*std::abs(b);};
  cudaEvent_t start,stop;
  checkCuda(cudaEventCreate(&start));checkCuda(cudaEventCreate(&stop));
  std::vector<std::vector<double>> timings(roleCount);
  for(int r=0;r<23;++r)for(int slot=0;slot<roleCount;++slot) {
    const int role=(r+slot)%roleCount;
    checkCuda(cudaMemset(maxspeed,0,sizeof(float)));
    for(auto ptr:output) checkCuda(cudaMemset(ptr,0xff,n*sizeof(float)));
    checkCuda(cudaEventRecord(start));
    checkDriver(cuLaunchKernel(fns[role],grid.x,grid.y,grid.z,block.x,block.y,block.z,smem,nullptr,args,nullptr));
    checkCuda(cudaEventRecord(stop));checkCuda(cudaEventSynchronize(stop));
    float ms;checkCuda(cudaEventElapsedTime(&ms,start,stop));
    for(int i=0;i<6;++i) {
      checkCuda(cudaMemcpy(got.data(),output[i],n*sizeof(float),cudaMemcpyDeviceToHost));
      for(size_t j=0;j<n;++j) if(!equal(got[j],llvmRef[i][j])) {
        std::fprintf(stderr,"role %d field %d cell %zu: %.9g vs %.9g\n",role,i,j,got[j],llvmRef[i][j]);return 3;
      }
    }
    float m;
    checkCuda(cudaMemcpy(&m,maxspeed,sizeof(float),cudaMemcpyDeviceToHost));
    if(!equal(m,llvmMax)) throw std::runtime_error("wavespeed mismatch");
    if (r >= 3) {
      if (!(ms > 0) || !std::isfinite(ms)) throw std::runtime_error("invalid GPU timing");
      timings[role].push_back(1000.0 * ms);
      std::printf("%d,%d,%.9f\n",r,role,1000.0 * ms);
    }
  }
  auto median=[](std::vector<double> samples) {
    std::sort(samples.begin(),samples.end());
    const size_t mid=samples.size()/2;
    return samples.size()%2 ? samples[mid] : (samples[mid-1]+samples[mid])*0.5;
  };
  auto pairedDelta=[&](int role,int reference) {
    std::vector<double> deltas;
    for (size_t i=0;i<timings[role].size();++i)
      deltas.push_back(100.0*(timings[role][i]/timings[reference][i]-1.0));
    return median(deltas);
  };
  const double greedyDelta=pairedDelta(1,0);
  std::fprintf(stderr,"%d^3 baseline %.3f us, greedy %.3f us (%+.2f%% paired)\n",
               size,median(timings[0]),median(timings[1]),greedyDelta);
  if (roleCount==3) {
    std::fprintf(stderr,"DARM %.3f us (%+.2f%% paired), greedy vs DARM %+.2f%%\n",
                 median(timings[2]),pairedDelta(2,0),pairedDelta(1,2));
  }
  const bool passed=greedyDelta<=maximumDelta;
  std::fprintf(stderr,"%s (greedy delta limit %+.2f%%)\n",passed?"PASS":"FAIL",maximumDelta);
  return passed ? 0 : 4;
} catch(const std::exception& e) {
  std::fprintf(stderr,"%s\n",e.what());return 1;
}
