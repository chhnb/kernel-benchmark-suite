#include "windows.h"
#include <hip/hip_runtime.h>
#include <algorithm>
#include <cmath>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

namespace fs = std::filesystem;
constexpr size_t Bytes = 256 * 256 * sizeof(float);
constexpr size_t Guard = 256, Extent = Bytes + 2 * Guard;
constexpr int Frames = 110, Windows = 12;
constexpr unsigned char Sentinel = 0xa5;
constexpr const char *Symbol = "_Z11srad_cuda_1PfS_S_S_S_S_iif";

static void hip(hipError_t status) {
  if (status != hipSuccess) throw std::runtime_error(hipGetErrorString(status));
}

static std::vector<unsigned char> padded(const fs::path &path) {
  if (fs::file_size(path) != Bytes) throw std::runtime_error("fixture size: " + path.string());
  std::ifstream input(path, std::ios::binary);
  std::vector<unsigned char> bytes(Extent, Sentinel);
  if (!input.read(reinterpret_cast<char *>(bytes.data() + Guard), Bytes))
    throw std::runtime_error("fixture read: " + path.string());
  return bytes;
}

int main(int argc, char **argv) {
  try {
    if (argc < 5 || argc > 12) throw std::runtime_error("fixture repeat csv OBJECT... (2 to 8 roles)");
    const fs::path fixture = argv[1];
    const int repeats = std::stoi(argv[2]), roles = argc - 4;
    if (repeats <= 0) throw std::runtime_error("invalid repeat count");
    const auto input = padded(fixture / "J.bin");
    const auto zero = padded(fixture / "zero.bin");
    const std::vector<std::string> names{"E", "W", "N", "S", "C"};
    std::vector<std::vector<unsigned char>> expected;
    for (const auto &name : names) expected.push_back(padded(fixture / (name + "-ref.bin")));
    hip(hipSetDevice(0));
    hipStream_t stream;
    hipEvent_t start, stop;
    hip(hipStreamCreateWithFlags(&stream, hipStreamNonBlocking));
    hip(hipEventCreate(&start));
    hip(hipEventCreate(&stop));
    unsigned char *device, *deviceInput, *deviceZero, *scratch;
    hip(hipMalloc(&device, Frames * 6 * Extent));
    hip(hipMalloc(&deviceInput, Extent));
    hip(hipMalloc(&deviceZero, Extent));
    hip(hipHostMalloc(&scratch, Frames * 6 * Extent));
    hip(hipMemcpy(deviceInput, input.data(), Extent, hipMemcpyHostToDevice));
    hip(hipMemcpy(deviceZero, zero.data(), Extent, hipMemcpyHostToDevice));
    auto ptr = [&](int i, int buffer) { return device + (i * 6 + buffer) * Extent; };
    for (int i = 0; i < Frames; ++i)
      hip(hipMemcpy(ptr(i, 4), deviceInput, Extent, hipMemcpyDeviceToDevice));

    std::vector<hipModule_t> modules(roles);
    std::vector<hipGraph_t> graphs(roles);
    std::vector<hipGraphExec_t> instances(roles);
    for (int role = 0; role < roles; ++role) {
      hip(hipModuleLoad(&modules[role], argv[4 + role]));
      hipFunction_t kernel;
      hip(hipModuleGetFunction(&kernel, modules[role], Symbol));
      hip(hipStreamBeginCapture(stream, hipStreamCaptureModeGlobal));
      for (int i = 0; i < Frames; ++i) {
        auto *e = ptr(i, 0) + Guard, *w = ptr(i, 1) + Guard;
        auto *n = ptr(i, 2) + Guard, *s = ptr(i, 3) + Guard;
        auto *j = ptr(i, 4) + Guard, *c = ptr(i, 5) + Guard;
        int rows = 256, cols = 256;
        float scalar = 0.1f;
        void *args[] = {&e, &w, &n, &s, &j, &c, &rows, &cols, &scalar};
        hip(hipModuleLaunchKernel(kernel, 8, 8, 1, 32, 32, 1, 0, stream, args, nullptr));
      }
      hip(hipStreamEndCapture(stream, &graphs[role]));
      hip(hipGraphInstantiate(&instances[role], graphs[role], nullptr, nullptr, 0));
      size_t nodes = 0;
      hip(hipGraphGetNodes(graphs[role], nullptr, &nodes));
      if (nodes != Frames) throw std::runtime_error("invalid graph node count");
    }
    auto sample = [&](int role, bool validate) {
      for (int i = 0; i < Frames; ++i)
        for (int b : {0, 1, 2, 3, 5})
          hip(hipMemcpyAsync(ptr(i, b), deviceZero, Extent, hipMemcpyDeviceToDevice, stream));
      hip(hipEventRecord(start, stream));
      hip(hipGraphLaunch(instances[role], stream));
      hip(hipEventRecord(stop, stream));
      if (validate)
        hip(hipMemcpyAsync(scratch, device, Frames * 6 * Extent, hipMemcpyDeviceToHost, stream));
      hip(hipStreamSynchronize(stream));
      float ms = 0;
      hip(hipEventElapsedTime(&ms, start, stop));
      if (!std::isfinite(ms) || ms <= 0) throw std::runtime_error("invalid event interval");
      if (validate) {
        for (int i = 0; i < Frames; ++i) {
          for (int b = 0; b < 6; ++b) {
            const auto *actual = scratch + (i * 6 + b) * Extent;
            const auto &ref = b == 4 ? input : expected[b == 5 ? 4 : b];
            if (std::memcmp(actual, ref.data(), Extent) == 0) continue;
            if (b == 4 || std::memcmp(actual, ref.data(), Guard) ||
                std::memcmp(actual + Guard + Bytes, ref.data() + Guard + Bytes, Guard))
              throw std::runtime_error("full output/guard mismatch in case " + std::to_string(i));
            for (size_t offset = Guard; offset < Guard + Bytes; offset += sizeof(float)) {
              float x, y;
              std::memcpy(&x, actual + offset, sizeof(float));
              std::memcpy(&y, ref.data() + offset, sizeof(float));
              if (!std::isfinite(x) || !std::isfinite(y) ||
                  std::abs(double(x) - y) > 3e-5 + 3e-5 * std::abs(double(y)))
                throw std::runtime_error("full output mismatch in " + names[b == 5 ? 4 : b]);
            }
          }
        }
      }
      return ms;
    };
    for (double warmed = 0; warmed < 200;) warmed += sample(0, false);
    std::ofstream csv(argv[3]);
    if (!csv) throw std::runtime_error("cannot write CSV");
    csv << std::setprecision(9) << "window,role,milliseconds,full_output_passed\n";
    for (int window = 0; window < artifactWindows(); ++window) {
      for (int n = 0; n < repeats; ++n)
        for (int offset = 0; offset < roles; ++offset) {
          int position = window / roles % 2 ? roles - 1 - offset : offset;
          const int role = (window + position) % roles;
          const float elapsed = sample(role, true);
          csv << window << ',' << role << ',' << elapsed << ",1\n";
        }
      csv.flush();
    }
    hip(hipHostFree(scratch));
    hip(hipFree(deviceZero));
    hip(hipFree(deviceInput));
    hip(hipFree(device));
    hip(hipEventDestroy(start));
    hip(hipEventDestroy(stop));
    hip(hipStreamDestroy(stream));
    for (int role = 0; role < roles; ++role) {
      hip(hipGraphExecDestroy(instances[role]));
      hip(hipGraphDestroy(graphs[role]));
      hip(hipModuleUnload(modules[role]));
    }
  } catch (const std::exception &error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
}
