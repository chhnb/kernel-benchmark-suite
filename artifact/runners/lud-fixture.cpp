#include "lud-fixture.h"
#include <fstream>

int main(int argc, char **argv) {
  if (argc != 2)
    return 2;
  auto values = ludMatrix();
  std::ofstream out(argv[1], std::ios::binary);
  out.write(reinterpret_cast<const char *>(values.data()), values.size() * sizeof(float));
  return !out;
}
