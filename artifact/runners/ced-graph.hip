#include "windows.h"
#include <hip/hip_runtime.h>

#include <algorithm>
#include <array>
#include <cmath>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <stdexcept>
#include <vector>

namespace fs = std::filesystem;
using Byte = unsigned char;
constexpr int Rows = 354, Cols = 626, FrameCount = 110;
constexpr size_t Bytes = Rows * Cols, Guard = 256, Extent = Bytes + 2 * Guard;

static void checkHip(hipError_t error) {
  if (error != hipSuccess) throw std::runtime_error(hipGetErrorString(error));
}

struct Buffer {
  Byte *raw = nullptr;
  Buffer() { checkHip(hipMalloc(&raw, Extent)); }
  Buffer(const Buffer &) = delete;
  ~Buffer() { hipFree(raw); }
  Byte *data() const { return raw + Guard; }
};

static std::vector<Byte> load(const fs::path &file) {
  std::ifstream input(file, std::ios::binary | std::ios::ate);
  if (!input || input.tellg() != Bytes) throw std::runtime_error("invalid fixture " + file.string());
  std::vector<Byte> full(Extent, 165);
  input.seekg(0);
  if (!input.read(reinterpret_cast<char *>(full.data() + Guard), Bytes))
    throw std::runtime_error("incomplete fixture " + file.string());
  return full;
}

int main(int argc, char **argv) {
  try {
    if (argc < 5 || argc > 9) throw std::runtime_error("fixture first.hsaco second.hsaco repeats results.csv");
    checkHip(hipSetDevice(0));
    struct Frame {
      Buffer magnitude, theta, output;
      std::vector<Byte> inputMagnitude, inputTheta, expected;
    };
    std::array<Frame, FrameCount> frames;
    for (int i = 0; i < FrameCount; ++i) {
      auto prefix = (fs::path(argv[1]) / std::to_string(i)).string();
      auto &f = frames[i];
      f.inputMagnitude = load(prefix + "-magnitude.bin");
      f.inputTheta = load(prefix + "-theta.bin");
      f.expected = load(prefix + "-expected.bin");
      checkHip(hipMemcpy(f.magnitude.raw, f.inputMagnitude.data(), Extent, hipMemcpyHostToDevice));
      checkHip(hipMemcpy(f.theta.raw, f.inputTheta.data(), Extent, hipMemcpyHostToDevice));
    }
    const int roles = argc - 4;
    std::vector<hipModule_t> modules(roles);
    std::vector<hipFunction_t> functions(roles);
    for (int role = 0; role != roles; ++role) {
      checkHip(hipModuleLoad(&modules[role], argv[role + 2]));
      checkHip(hipModuleGetFunction(&functions[role], modules[role], "_Z19non_max_supp_kernelPKhPhS0_ii"));
    }
    hipStream_t stream;
    hipEvent_t start, end;
    checkHip(hipStreamCreateWithFlags(&stream, hipStreamNonBlocking));
    checkHip(hipEventCreate(&start));
    checkHip(hipEventCreate(&end));
    auto *scratch = static_cast<Byte *>(nullptr);
    checkHip(hipHostMalloc(&scratch, FrameCount * Extent * 3));
    std::vector<hipGraph_t> graphs(roles);
    std::vector<hipGraphExec_t> instances(roles);
    for (int role = 0; role != roles; ++role) {
      checkHip(hipStreamBeginCapture(stream, hipStreamCaptureModeGlobal));
      for (auto &f : frames) {
        Byte *m = f.magnitude.data(), *t = f.theta.data(), *o = f.output.data();
        int rows = Rows, cols = Cols;
        void *args[] = {&m, &o, &t, &rows, &cols};
        checkHip(hipModuleLaunchKernel(functions[role], 39, 22, 1, 16, 16, 1,
                                          18 * 18 * sizeof(int), stream, args, nullptr));
      }
      checkHip(hipStreamEndCapture(stream, &graphs[role]));
      checkHip(hipGraphInstantiate(&instances[role], graphs[role], nullptr, nullptr, 0));
    }
    auto train = [&](int role, bool validate) {
      for (auto &f : frames) checkHip(hipMemsetAsync(f.output.raw, 165, Extent, stream));
      checkHip(hipEventRecord(start, stream));
      checkHip(hipGraphLaunch(instances[role], stream));
      checkHip(hipEventRecord(end, stream));
      if (validate) {
        size_t index = 0;
        for (const auto &f : frames)
          for (const auto *p : {f.magnitude.raw, f.theta.raw, f.output.raw})
            checkHip(hipMemcpyAsync(scratch + index++ * Extent, p, Extent, hipMemcpyDeviceToHost, stream));
      }
      checkHip(hipStreamSynchronize(stream));
      float ms;
      checkHip(hipEventElapsedTime(&ms, start, end));
      if (!std::isfinite(ms) || ms <= 0) throw std::runtime_error("invalid event interval");
      if (validate) {
        size_t index = 0;
        for (int i = 0; i < FrameCount; ++i) {
          const auto &f = frames[i];
          for (const auto *ref : {&f.inputMagnitude, &f.inputTheta, &f.expected})
            if (!std::equal(ref->begin(), ref->end(), scratch + index++ * Extent))
              throw std::runtime_error("full output/guard mismatch in frame " + std::to_string(i));
        }
      }
      return ms;
    };
    for (double warmed = 0; warmed < 200;) warmed += train(0, false);
    const int repeat = std::stoi(argv[argc - 2]);
    std::ofstream csv(argv[argc - 1]);
    csv << std::setprecision(9) << "window,role,milliseconds,full_output_passed\n";
    for (int window = 0; window < artifactWindows(); ++window) {
      // Alternate both intra-window samples and the first role in each window.
      for (int n = 0; n < repeat; ++n)
        for (int offset = 0; offset != roles; ++offset) {
          const int role = (window + offset) % roles;
          const float elapsed = train(role, true);
          csv << window << ',' << role << ',' << elapsed << ",1\n";
        }
      csv.flush();
    }
    checkHip(hipHostFree(scratch));
    checkHip(hipEventDestroy(start));
    checkHip(hipEventDestroy(end));
    checkHip(hipStreamDestroy(stream));
    for (int role = 0; role != roles; ++role) {
      checkHip(hipGraphExecDestroy(instances[role]));
      checkHip(hipGraphDestroy(graphs[role]));
    }
    for (auto m : modules) checkHip(hipModuleUnload(m));
  } catch (const std::exception &error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
}
