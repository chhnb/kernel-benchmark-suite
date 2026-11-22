#pragma once
#include <cmath>
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
