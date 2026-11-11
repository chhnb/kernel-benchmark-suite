#include <hip/hip_runtime_api.h>
#include <cstdio>
#include <cstdlib>
#include <limits>

static void check(hipError_t status) {
  if (status == hipSuccess) return;
  std::fprintf(stderr, "%s\n", hipGetErrorString(status));
  std::exit(1);
}

int main(int argc, char **argv) {
  if (argc != 4) {
    std::fprintf(stderr, "usage: %s CODE_OBJECT KERNEL WORKGROUP_SIZE\n", argv[0]);
    return 2;
  }
  char *end = nullptr;
  long size = std::strtol(argv[3], &end, 10);
  if (*end || size <= 0 || size > std::numeric_limits<int>::max()) return 2;

  check(hipInit(0));
  hipModule_t module;
  hipFunction_t function;
  int blocks;
  check(hipModuleLoad(&module, argv[1]));
  check(hipModuleGetFunction(&function, module, argv[2]));
  check(hipModuleOccupancyMaxActiveBlocksPerMultiprocessor(
      &blocks, function, static_cast<int>(size), 0));
  check(hipModuleUnload(module));
  std::printf("%d\n", blocks);
}
