#include "../../runner/gpu.hpp"

#include <array>
#include <cstdint>
#include <iomanip>

namespace {
constexpr char kernelName[] = "_Z27CUDAkernelQuantizationShortPsi";
constexpr int width = 4096, height = 4096, tile = 8;
constexpr std::array<int, 64> quantization = {
    32, 33, 51, 81, 66, 39, 34, 17,
    33, 36, 48, 47, 28, 23, 12, 12,
    51, 48, 47, 28, 23, 12, 12, 12,
    81, 47, 28, 23, 12, 12, 12, 12,
    66, 28, 23, 12, 12, 12, 12, 12,
    39, 23, 12, 12, 12, 12, 12, 12,
    34, 12, 12, 12, 12, 12, 12, 12,
    17, 12, 12, 12, 12, 12, 12, 12,
};

int16_t asSignedShort(int value) {
  auto bits = static_cast<uint16_t>(value);
  return static_cast<int16_t>(bits <= INT16_MAX ? bits : int(bits) - 65536);
}

int16_t cpuQuantize(int x, int q) {
  const int rounded = asSignedShort((x < 0 ? -x : x) + q / 2);
  const int quotient = rounded / q;
  return asSignedShort((x < 0 ? -quotient : quotient) * q);
}
}

int main(int argc, char **argv) {
  try {
    Options options(argc, argv);
    need(options.timing == "event", "DCT8 replay requires event timing");
    auto raw = readbytes(options.input);
    const size_t elements = size_t(width) * height;
    need(raw.size() == elements * sizeof(int16_t), "wrong DCT8 input size");
    std::vector<int16_t> input(elements), expected(elements), actual(elements);
    std::memcpy(input.data(), raw.data(), raw.size());
    for (int y = 0; y < height; ++y)
      for (int x = 0; x < width; ++x) {
        size_t index = size_t(y) * width + x;
        expected[index] = cpuQuantize(input[index], quantization[(y % tile) * tile + x % tile]);
      }
    init();
    Module module;
    Function entry;
    Stream stream;
    Event start, stop;
    load(&module, options.kernel.c_str());
    function(&entry, module, kernelName);
    streamCreate(&stream);
    eventCreate(&start);
    eventCreate(&stop);
    auto buffer = alloc(raw.size());
    int stride = width;
    unsigned grid[] = {width / tile, height / tile, 1};
    unsigned block[] = {tile, tile, 1};
    void *args[] = {&buffer, &stride};
    std::ofstream samples(fs::path(options.output) / "samples.csv");
    need(bool(samples), "cannot open DCT8 samples output");
    samples << "round,warmup,microseconds,full_output_passed\n";
    for (int i = 0; i < options.rounds(); ++i) {
      upload(buffer, input.data(), raw.size());
      ck(hipDeviceSynchronize());
      record(start, stream);
      launch(entry, grid, block, stream, args);
      record(stop, stream);
      auto us = 1000.0 * elapsed(start, stop);
      download(actual.data(), buffer, raw.size());
      auto diff = std::mismatch(expected.begin(), expected.end(), actual.begin());
      if (diff.first != expected.end())
        throw std::runtime_error("DCT8 CPU/GPU mismatch at element " +
                                 std::to_string(diff.first - expected.begin()));
      samples << i << ',' << !options.measured(i) << ',' << std::setprecision(9)
              << us << ",1\n";
    }
    if (options.mode == "validate") {
      std::memcpy(raw.data(), actual.data(), raw.size());
      writebytes(fs::path(options.output) / "output.bin", raw);
    }
    release(buffer);
    eventFree(start);
    eventFree(stop);
    streamFree(stream);
    unload(module);
    finish();
    std::cout << "PASS " << elements << " CPU/GPU comparisons per launch\n";
  } catch (const std::exception &error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
}
