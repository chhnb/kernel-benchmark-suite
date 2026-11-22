#include "windows.h"
// Use the artifact's input generation, launch geometry and timed workload
// with a selectable HSACO. Check the full sorted result for every run.
#include <hip/hip_runtime.h>

#include <algorithm>
#include <array>
#include <cstdio>
#include <fstream>
#include <cstdlib>
#include <cstring>
#include <stdexcept>
#include <string>
#include <vector>

#define HIP(call) do { const auto rc = (call); if (rc != hipSuccess) \
  throw std::runtime_error(std::string(#call) + ": " + hipGetErrorString(rc)); } while (0)

constexpr int Threads = 32;
constexpr int MSBlocks = 1024;
constexpr long MSElements = 1L << 20;
constexpr int PCMBlocks = 1 << 15;
constexpr int PCMGroup = 1 << 13;

template<class T>
void measure(bool pcm, int repeat, int warmup, int count, const char *const *paths,
             const char *inputPath, const char *referencePath) {
  const size_t n = pcm ? size_t(PCMBlocks) * PCMGroup : MSElements;
  const size_t bytes = n * sizeof(T);
  std::vector<T> input(n), reference(n), actual(pcm ? 0 : n);
  for (auto [path, destination] : {std::pair{inputPath, input.data()},
                                   std::pair{referencePath, reference.data()}}) {
    std::ifstream file(path, std::ios::binary);
    if (!file.read(reinterpret_cast<char*>(destination), bytes)
        || file.peek() != std::char_traits<char>::eof())
      throw std::runtime_error(std::string("invalid frozen fixture: ") + path);
  }
  const std::array<const char*, 8> names{"baseline", "A", "D", "Dprime", "E", "F", "G", "H"};
  const char *symbol = pcm ? "_Z3pcmPi" : "_Z13gpu_mergesortPlS_lllP4dim3S1_";
  std::array<hipModule_t, 8> modules{};
  std::array<hipFunction_t, 8> functions{};
  HIP(hipSetDevice(0));
  for (int k = 0; k < count; ++k) {
    HIP(hipModuleLoad(&modules[k], paths[k]));
    HIP(hipModuleGetFunction(&functions[k], modules[k], symbol));
  }
  T *first = nullptr, *second = nullptr;
  dim3 *devThreads = nullptr, *devBlocks = nullptr;
  const dim3 threads(Threads), blocks(MSBlocks);
  HIP(hipMalloc(&first, bytes));
  constexpr size_t ChunkElements = 1 << 20;
  T *initial = nullptr, *staging = nullptr;
  if (pcm) {
    HIP(hipMalloc(&initial, bytes));
    HIP(hipHostMalloc(&staging, ChunkElements * sizeof(T)));
    for (size_t offset = 0; offset < n; offset += ChunkElements) {
      const auto length = std::min(ChunkElements, n - offset);
      std::copy_n(input.data() + offset, length, staging);
      HIP(hipMemcpy(initial + offset, staging, length * sizeof(T), hipMemcpyHostToDevice));
    }
  }
  auto resetInput = [&] {
    if (pcm) {
      HIP(hipMemcpy(first, initial, bytes, hipMemcpyDeviceToDevice));
    } else {
      HIP(hipMemcpy(first, input.data(), bytes, hipMemcpyHostToDevice));
    }
  };
  if (!pcm) {
    HIP(hipMalloc(&second, bytes));
    HIP(hipMalloc(&devThreads, sizeof(threads)));
    HIP(hipMalloc(&devBlocks, sizeof(blocks)));
    HIP(hipMemcpy(devThreads, &threads, sizeof(threads), hipMemcpyHostToDevice));
    HIP(hipMemcpy(devBlocks, &blocks, sizeof(blocks), hipMemcpyHostToDevice));
  }
  hipEvent_t start, stop;
  HIP(hipEventCreate(&start));
  HIP(hipEventCreate(&stop));
  if (pcm) {
    for (float warmed = 0; warmed < 200;) {
      resetInput();
      HIP(hipEventRecord(start));
      void *args[]{&first};
      HIP(hipModuleLaunchKernel(functions[0], PCMBlocks, 1, 1, Threads, 1, 1,
                                0, nullptr, args, nullptr));
      HIP(hipEventRecord(stop));
      HIP(hipEventSynchronize(stop));
      float ms;
      HIP(hipEventElapsedTime(&ms, start, stop));
      warmed += ms;
    }
  }
  std::puts("round,role,microseconds,full_output_passed");
  for (int round = 0; round < artifactWindows(); ++round) {
    std::array<double, 8> times{};
    for (int pos = 0; pos < count; ++pos) {
      constexpr int BalancedOrder[]{0, 1, 3, 2};
      const int role = count == 4 ? (round + BalancedOrder[pos]) % count
                                 : (round / 2 + (round % 2 ? count - 1 - pos : pos)) % count;
      std::vector<double> samples;
      for (int trial = -warmup; trial < repeat; ++trial) {
      resetInput();
      T *a = first, *b = second;
      HIP(hipEventRecord(start));
      if (pcm) {
        void *args[]{&a};
        HIP(hipModuleLaunchKernel(functions[role], PCMBlocks, 1, 1,
                                  Threads, 1, 1, 0, nullptr, args, nullptr));
      } else {
        long size = MSElements;
        for (long width = 2; width < (size << 1); width <<= 1) {
          long slices = size / (long(MSBlocks) * Threads * width) + 1;
          void *args[]{&a, &b, &size, &width, &slices, &devThreads, &devBlocks};
          HIP(hipModuleLaunchKernel(functions[role], MSBlocks, 1, 1,
                                    Threads, 1, 1, 0, nullptr, args, nullptr));
          std::swap(a, b);
        }
      }
      HIP(hipEventRecord(stop));
      HIP(hipEventSynchronize(stop));
      float milliseconds = 0;
      HIP(hipEventElapsedTime(&milliseconds, start, stop));
      size_t mismatch = n;
      if (pcm) {
        for (size_t offset = 0; offset < n; offset += ChunkElements) {
          const auto length = std::min(ChunkElements, n - offset);
          HIP(hipMemcpy(staging, a + offset, length * sizeof(T), hipMemcpyDeviceToHost));
          const auto at = std::mismatch(staging, staging + length,
                                        reference.data() + offset).first;
          if (at != staging + length) {
            mismatch = offset + size_t(at - staging);
            break;
          }
        }
      } else {
        HIP(hipMemcpy(actual.data(), a, bytes, hipMemcpyDeviceToHost));
        mismatch = std::mismatch(actual.begin(), actual.end(), reference.begin()).first -
                   actual.begin();
      }
      if (mismatch != n) {
        std::fprintf(stderr, "output mismatch: round=%d role=%s index=%zu\n",
                     round + 1, names[role], mismatch);
        std::exit(4);
      }
      if (trial >= 0) samples.push_back(1000. * milliseconds);
      }
      std::sort(samples.begin(), samples.end());
      times[role] = (samples[(repeat - 1) / 2] + samples[repeat / 2]) / 2.;
      std::printf("%d,%s,%.9f,1\n", round + 1, names[role], times[role]);
      std::fflush(stdout);
    }
  }
  HIP(hipEventDestroy(start));
  HIP(hipEventDestroy(stop));
  if (pcm) {
    HIP(hipHostFree(staging));
    HIP(hipFree(initial));
  }
  HIP(hipFree(first));
  if (!pcm) {
    HIP(hipFree(second));
    HIP(hipFree(devThreads));
    HIP(hipFree(devBlocks));
  }
  for (int k = 0; k < count; ++k) HIP(hipModuleUnload(modules[k]));
}

int main(int argc, char **argv) {
  if ((argc < 7 || argc > 14) || (std::strcmp(argv[1], "MS32") && std::strcmp(argv[1], "PCM32"))) return 2;
  const int repeat = std::atoi(argv[2]), warmup = std::atoi(argv[3]);
  if (repeat <= 0 || warmup < 0) return 2;
  try {
    if (!std::strcmp(argv[1], "PCM32")) measure<int>(true, repeat, warmup, argc - 6, argv + 6, argv[4], argv[5]);
    else measure<long>(false, repeat, warmup, argc - 6, argv + 6, argv[4], argv[5]);
  } catch (const std::exception &error) {
    std::fprintf(stderr, "%s\n", error.what());
    return 3;
  }
}
