#include <algorithm>
#include <cstdint>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <vector>

template <class T>
void write(std::ofstream &file, const std::vector<T> &chunk) {
  file.write(reinterpret_cast<const char *>(chunk.data()), chunk.size() * sizeof(T));
  if (!file)
    throw std::runtime_error("cannot write sort fixture");
}

int main(int argc, char **argv) try {
  if (argc != 3)
    throw std::runtime_error("usage: sort-fixtures OUT PCM32|MS32");
  const std::string name = argv[2];
  const bool pcm = name == "PCM32";
  if (!pcm && name != "MS32")
    throw std::runtime_error("unknown sort fixture");
  const std::filesystem::path out = argv[1];
  if (!std::filesystem::create_directory(out))
    throw std::runtime_error("sort fixture output must be new");
  std::ofstream input(out / "input", std::ios::binary);
  std::ofstream expected(out / "reference", std::ios::binary);
  if (pcm) {
    constexpr int group = 8192, lanes = 32, total = 1 << 28;
    std::srand(0);
    std::vector<int32_t> values(group);
    for (int block = 0; block < total / group; ++block) {
      for (int offset = 0; offset < group; offset += group / lanes) {
        const int32_t first = std::rand() % total;
        for (int lane = 0; lane < group / lanes; ++lane)
          values[offset + lane] = first + lane;
      }
      write(input, values);
      std::sort(values.begin(), values.end());
      write(expected, values);
    }
  } else {
    std::srand(1);
    std::vector<int64_t> values(1 << 20);
    for (auto &value : values)
      value = std::rand() % 1024;
    write(input, values);
    std::sort(values.begin(), values.end());
    write(expected, values);
  }
  return 0;
} catch (const std::exception &error) {
  std::cerr << error.what() << '\n';
  return 1;
}
