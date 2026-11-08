#include <initializer_list>

#include <cmath>
#include <cstdint>
#include <cstring>
#include <cstdio>
#include <limits>
extern "C" float forward(bool, float);
extern "C" float reverse(bool, float);
static uint32_t bits(float x) { uint32_t b; std::memcpy(&b, &x, 4); return b; }
int main() {
  float xs[] = {-10.2f, -1.0f, -0.25f, -0.0f, 0.0f, 0.25f, 1.0f, 7.9f,
    std::numeric_limits<float>::infinity(), -std::numeric_limits<float>::infinity(),
    std::numeric_limits<float>::quiet_NaN()};
  for (float x : xs) for (bool p : {false, true}) {
    float a = forward(p, x), ar = (p ? std::ceil(x) : std::floor(x)) * 2;
    float b = reverse(p, x), br = (p ? std::floor(x) : std::ceil(x)) * 2;
    if (!(std::isnan(ar) ? std::isnan(a) : bits(a) == bits(ar)) ||
        !(std::isnan(br) ? std::isnan(b) : bits(b) == bits(br))) return 1;
  }
  std::puts("PASS 44 executable comparisons including signed zero, infinity and NaN");
}
