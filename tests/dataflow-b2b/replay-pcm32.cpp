#include "../../runner/gpu.hpp"

#include <algorithm>
#include <cstdint>
#include <fcntl.h>
#include <iomanip>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

namespace {
constexpr char kernelName[] = "_Z3pcmPi";
constexpr unsigned blocks = 1 << 15, threads = 32, group = 1 << 13;
constexpr size_t elements = size_t(blocks) * group;
constexpr size_t bytes = elements * sizeof(int32_t);
constexpr size_t chunk = 4 << 20;

class Fixture {
  void *address;

public:
  explicit Fixture(const fs::path &file) {
    const int fd = open(file.c_str(), O_RDONLY);
    need(fd >= 0, "cannot open " + file.string());
    struct stat info {};
    if (fstat(fd, &info) || info.st_size != bytes) {
      close(fd);
      throw std::runtime_error("wrong fixture size: " + file.string());
    }
    address = mmap(nullptr, bytes, PROT_READ, MAP_PRIVATE, fd, 0);
    close(fd);
    need(address != MAP_FAILED, "cannot map " + file.string());
  }
  Fixture(const Fixture &) = delete;
  Fixture &operator=(const Fixture &) = delete;
  ~Fixture() { munmap(address, bytes); }
  const int32_t *data() const { return static_cast<const int32_t *>(address); }
};
}

int main(int argc, char **argv) {
  try {
    Options options(argc, argv);
    need(options.timing == "event", "PCM32 replay requires event timing");
    const Fixture original(fs::path(options.input) / "PCM32.input");
    const Fixture expected(fs::path(options.input) / "PCM32.reference");
    if (options.mode == "validate") {
      std::vector<int32_t> sorted(group);
      for (size_t offset = 0; offset < elements; offset += group) {
        std::copy_n(original.data() + offset, group, sorted.begin());
        std::sort(sorted.begin(), sorted.end());
        need(std::equal(sorted.begin(), sorted.end(), expected.data() + offset),
             "PCM32 frozen reference disagrees with CPU sort");
      }
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
    auto clean = alloc(bytes), buffer = alloc(bytes);
    void *pinned = nullptr;
    ck(hipHostMalloc(&pinned, chunk));
    for (size_t offset = 0; offset < bytes; offset += chunk) {
      std::memcpy(pinned, original.data() + offset / sizeof(int32_t), chunk);
      ck(hipMemcpy(static_cast<char *>(clean) + offset, pinned, chunk, hipMemcpyHostToDevice));
    }

    unsigned grid[] = {blocks, 1, 1};
    unsigned block[] = {threads, 1, 1};
    void *args[] = {&buffer};
    std::ofstream samples(fs::path(options.output) / "samples.csv");
    need(bool(samples), "cannot open PCM32 samples output");
    samples << "round,warmup,microseconds,full_output_passed\n";
    for (int i = 0; i < options.rounds(); ++i) {
      ck(hipMemcpyAsync(buffer, clean, bytes, hipMemcpyDeviceToDevice, stream));
      record(start, stream);
      launch(entry, grid, block, stream, args);
      record(stop, stream);
      const auto us = 1000.0 * elapsed(start, stop);
      for (size_t offset = 0; offset < bytes; offset += chunk) {
        ck(hipMemcpy(pinned, static_cast<const char *>(buffer) + offset, chunk,
                     hipMemcpyDeviceToHost));
        if (std::memcmp(pinned, expected.data() + offset / sizeof(int32_t), chunk))
          throw std::runtime_error("PCM32 GPU/CPU mismatch in output chunk at byte " +
                                   std::to_string(offset));
      }
      samples << i << ',' << !options.measured(i) << ',' << std::setprecision(9)
              << us << ",1" << std::endl;
    }
    ck(hipHostFree(pinned));
    release(clean);
    release(buffer);
    eventFree(start);
    eventFree(stop);
    streamFree(stream);
    unload(module);
    finish();
    std::cout << "PASS " << elements << " CPU reference elements per launch\n";
  } catch (const std::exception &error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
}
