#pragma once
#include <cmath>
#include <cstdint>
#include <vector>

inline constexpr int LudDimension = 16384;
inline std::vector<float> ludMatrix() {
  constexpr float decay = -0.001f;
  std::vector<float> diagonal(LudDimension);
  for (int i = 0; i < LudDimension; ++i)
    diagonal[i] = 10.0 * std::exp(static_cast<double>(decay * i));
  std::vector<float> matrix(size_t(LudDimension) * LudDimension);
  for (int i = 0; i < LudDimension; ++i)
    for (int j = 0; j < LudDimension; ++j)
      matrix[size_t(i) * LudDimension + j] = diagonal[std::abs(i - j)];
  return matrix;
}

inline uint64_t ludFingerprint(const float *values, size_t size) {
  uint64_t state = UINT64_C(14695981039346656037);
  auto bytes = reinterpret_cast<const unsigned char *>(values);
  for (size_t i = 0; i < size; ++i)
    state = (state ^ bytes[i]) * UINT64_C(1099511628211);
  return state;
}
