#include <cuda.h>
#include <cstdio>
#include <stdexcept>
static void check(CUresult code) {
  if(code==CUDA_SUCCESS)return;
  const char *reason=nullptr;
  cuGetErrorString(code,&reason);
  throw std::runtime_error(reason?reason:"CUDA driver error");
}
int main(int argc,char **argv)try{
  if(argc!=3)return 2;
  check(cuInit(0));
  CUdevice dev;
  CUcontext ctx;
  CUmodule module;
  CUfunction function;
  check(cuDeviceGet(&dev,0));
  check(cuDevicePrimaryCtxRetain(&ctx,dev));
  check(cuCtxSetCurrent(ctx));
  check(cuModuleLoad(&module,argv[1]));
  check(cuModuleGetFunction(&function,module,argv[2]));
  int active;
  check(cuOccupancyMaxActiveBlocksPerMultiprocessor(&active,function,256,49000));
  std::printf("%d\n",active);
  check(cuModuleUnload(module));
  check(cuDevicePrimaryCtxRelease(dev));
}catch(const std::exception &e){
  std::fprintf(stderr,"%s\n",e.what());
  return 1;
}
