#pragma once

#include <algorithm>
#include <cmath>
#include <cstddef>
#include <cstring>
#include <vector>

inline constexpr std::size_t guardBytes = 256;

inline bool guardsMatch(const std::vector<unsigned char> &padded) {
    if (padded.size() < 2 * guardBytes)
        return false;
    auto guard = [](unsigned char byte) { return byte == 0xa5; };
    return std::all_of(padded.begin(), padded.begin() + guardBytes, guard) &&
           std::all_of(padded.end() - guardBytes, padded.end(), guard);
}

template <typename T>
bool floatingOutputMatches(const unsigned char *actual,
                           const std::vector<unsigned char> &expected,
                           double absoluteTolerance, double relativeTolerance) {
    for (std::size_t offset = 0; offset < expected.size(); offset += sizeof(T)) {
        T x, y;
        std::memcpy(&x, actual + offset, sizeof(T));
        std::memcpy(&y, expected.data() + offset, sizeof(T));
        if (!std::isfinite(x) || !std::isfinite(y) ||
            std::abs(double(x) - double(y)) >
                absoluteTolerance + relativeTolerance * std::abs(double(y)))
            return false;
    }
    return true;
}
