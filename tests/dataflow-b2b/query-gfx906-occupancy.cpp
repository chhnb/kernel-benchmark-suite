#include <hip/hip_runtime.h>
#include <cstdio>
#include <cstdlib>

void check(hipError_t status) {
  if (status != hipSuccess) {
    std::fprintf(stderr, "%s\n", hipGetErrorString(status));
    std::exit(1);
  }
}
int main(int argc, char **argv) {
  if (argc < 4) return 2;
  check(hipSetDevice(0));
  hipDeviceProp_t device;
  check(hipGetDeviceProperties(&device, 0));
  int threads = std::atoi(argv[2]);
  for (int i = 3; i < argc; ++i) {
    hipModule_t module;
    hipFunction_t kernel;
    int groups;
    check(hipModuleLoad(&module, argv[i]));
    check(hipModuleGetFunction(&kernel, module, argv[1]));
    check(hipModuleOccupancyMaxActiveBlocksPerMultiprocessor(&groups, kernel, threads, 0));
    int waves = groups * ((threads + device.warpSize - 1) / device.warpSize);
    int capacity = device.maxThreadsPerMultiProcessor / device.warpSize;
    std::printf("%s %d WG/CU %d waves/CU %d max waves/CU\n", argv[i], groups, waves, capacity);
    check(hipModuleUnload(module));
  }
}
