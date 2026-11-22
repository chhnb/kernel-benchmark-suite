#include <algorithm>
#include <array>
#include <cstdint>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <vector>

namespace {
constexpr uint32_t Columns = (1u << 15) - 1;
constexpr size_t Threads = 64;
constexpr size_t Capacity = 24576;

struct Board {
  uint32_t occupied, left, right;

  Board place(uint32_t bit) const {
    return {occupied | bit, (left | bit) << 1, (right | bit) >> 1};
  }

  uint32_t available() const { return Columns & ~(occupied | left | right); }
};

void prefixes(Board board, int rows, std::vector<Board> &result) {
  if (!rows) {
    result.push_back(board);
    return;
  }
  for (uint32_t options = board.available(); options; options &= options - 1)
    prefixes(board.place(options & -options), rows - 1, result);
}

uint32_t count(Board board) {
  if (board.occupied == Columns)
    return 1;
  uint32_t total = 0;
  for (uint32_t options = board.available(); options; options &= options - 1)
    total += count(board.place(options & -options));
  return total;
}

void write(std::ofstream &stream, uint32_t word) {
  stream.write(reinterpret_cast<const char *>(&word), sizeof(word));
}

void fixture(const std::vector<Board> &boards, std::ofstream &input,
             std::ofstream &reference) {
  for (size_t start = 0; start < boards.size(); start += Capacity) {
    const size_t end = std::min(start + Capacity, boards.size());
    for (auto field : {&Board::occupied, &Board::left, &Board::right})
      for (size_t i = start; i < end; ++i)
        write(input, boards[i].*field);
    for (size_t block = start; block < start + Capacity; block += Threads) {
      uint32_t total = 0;
      for (size_t i = block; i < std::min(block + Threads, end); ++i)
        total += count(boards[i]);
      write(reference, total);
    }
  }
}
} // namespace

int main(int argc, char **argv) try {
  if (argc != 2 || !std::filesystem::create_directory(argv[1]))
    throw std::runtime_error("usage: nqu-fixtures NEW_DIRECTORY");
  const std::filesystem::path dir = argv[1];
  std::ofstream input(dir / "input", std::ios::binary);
  std::ofstream reference(dir / "reference", std::ios::binary);
  std::vector<Board> boards;
  for (int col = 0; col < 7; ++col)
    prefixes(Board{}.place(1u << col), 4, boards);
  if (boards.size() != Capacity + 17392)
    throw std::runtime_error("NQU64 half-board fixture size differs");
  fixture(boards, input, reference);
  boards.clear();
  prefixes(Board{}.place(1u << 7), 4, boards);
  if (boards.size() != 5492)
    throw std::runtime_error("NQU64 center fixture size differs");
  fixture(boards, input, reference);
  input.close();
  reference.close();
  return !input || !reference;
} catch (const std::exception &error) {
  std::cerr << error.what() << '\n';
  return 1;
}
