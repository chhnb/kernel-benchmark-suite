#include <hip/hip_runtime.h>
#include "windows.h"

#include <algorithm>
#include <cmath>
#include <cstring>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <stdexcept>
#include <vector>

static void check(hipError_t error) {
  if (error != hipSuccess) throw std::runtime_error(hipGetErrorString(error));
}

int main(int argc, char **argv) {
  try {
    if (argc < 6 || argc > 13) throw std::runtime_error("input reference repeats results.csv OBJECT...");
    constexpr int N = 16384, Block = 8;
    constexpr size_t Bytes = size_t(N) * N * sizeof(float);
    std::vector<float> matrix(Bytes / sizeof(float));
    std::ifstream inputFile(argv[1], std::ios::binary);
    if (!inputFile.read(reinterpret_cast<char *>(matrix.data()), Bytes))
      throw std::runtime_error("cannot read full LUD8 input");
    const auto *input = reinterpret_cast<const unsigned char *>(matrix.data());
    unsigned char *device, *staging;
    // Keep host transfers out of the HIP event interval. Reuse one pinned slab
    // to avoid repeatedly registering a full pageable GiB with the HIP runtime.
    constexpr size_t ChunkBytes = 64 * 1024 * 1024;
    check(hipSetDevice(0));
    check(hipMalloc(&device, Bytes));
    check(hipHostMalloc(&staging, ChunkBytes));
    const int roles = argc - 5;
    std::vector<hipModule_t> mods(roles);
    std::vector<hipFunction_t> kernels(roles);
    for (int role = 0; role < roles; ++role) {
      check(hipModuleLoad(&mods[role], argv[5 + role]));
      check(hipModuleGetFunction(&kernels[role], mods[role], "_Z13lud_perimeterPfii"));
    }
    hipEvent_t start, stop;
    check(hipEventCreate(&start));
    check(hipEventCreate(&stop));
    auto launch = [&](int role) {
      for (size_t offset = 0; offset < Bytes; offset += ChunkBytes) {
        const size_t count = std::min(ChunkBytes, Bytes - offset);
        std::memcpy(staging, input + offset, count);
        check(hipMemcpy(device + offset, staging, count, hipMemcpyHostToDevice));
      }
      check(hipEventRecord(start));
      for (int offset = 0; offset < N - Block; offset += Block) {
        int dim = N;
        void *args[] = {&device, &dim, &offset};
        check(hipModuleLaunchKernel(kernels[role], (dim - offset) / Block - 1, 1, 1,
                                    2 * Block, 1, 1, 0, nullptr, args, nullptr));
      }
      check(hipEventRecord(stop));
      check(hipEventSynchronize(stop));
      float ms;
      check(hipEventElapsedTime(&ms, start, stop));
      if (!std::isfinite(ms) || ms <= 0) throw std::runtime_error("invalid event interval");
      return ms;
    };
    for (float warmed = 0; warmed < 200;) warmed += launch(0);
    std::vector<unsigned char> reference(Bytes);
    std::ifstream frozen(argv[2], std::ios::binary);
    if (!frozen.read(reinterpret_cast<char *>(reference.data()), Bytes))
      throw std::runtime_error("cannot read full LUD8 reference");
    const int repeat = std::stoi(argv[3]);
    std::ofstream csv(argv[4]);
    csv << std::setprecision(9) << "window,role,milliseconds,full_output_passed\n";
    for (int round = 0; round < artifactWindows(); ++round) {
      for (int offset = 0; offset < roles; ++offset) {
        const int role = (round + (round / roles % 2 ? roles - 1 - offset : offset)) % roles;
        for (int i = 0; i < repeat; ++i) {
          const float ms = launch(role);
          for (size_t offset = 0; offset < Bytes; offset += ChunkBytes) {
            const size_t count = std::min(ChunkBytes, Bytes - offset);
            check(hipMemcpy(staging, device + offset, count, hipMemcpyDeviceToHost));
            if (std::memcmp(staging, reference.data() + offset, count) != 0)
              throw std::runtime_error("full LUD8 output mismatch at chunk " + std::to_string(offset));
          }
          csv << round << ',' << role << ',' << ms << ",1\n";
        }
        csv.flush();
      }
    }
    check(hipHostFree(staging));
    check(hipEventDestroy(start));
    check(hipEventDestroy(stop));
    check(hipFree(device));
    for (auto m : mods) check(hipModuleUnload(m));
  } catch (const std::exception &error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
}
