#include "output_check.hpp"
#include <cassert>
#include <iostream>

template <typename T>
void check() {
    const T reference[] = {T(1.25), T(-2.5), T(3.75)};
    std::vector<unsigned char> expected(sizeof(reference));
    std::memcpy(expected.data(), reference, expected.size());
    std::vector<unsigned char> padded(2 * guardBytes + expected.size(), 0xa5);
    auto *actual = padded.data() + guardBytes;
    std::copy(expected.begin(), expected.end(), actual);
    assert(guardsMatch(padded) && floatingOutputMatches<T>(actual, expected, 0, 0));
    const T corrupt = T(17);
    std::memcpy(actual + sizeof(T), &corrupt, sizeof(T));
    assert(guardsMatch(padded) && !floatingOutputMatches<T>(actual, expected, 0, 0));
}
int main() {
    check<float>();
    check<double>();
    std::cout << "PASS f32/f64 guarded output; a single corrupted element was rejected\n";
}
