#pragma once

#include "options.hpp"

#include <algorithm>
#include <array>
#include <cstdint>

struct Measurement {
 const Options &options;
 bool paired() const { return !options.reference.empty(); }
 bool extended() const { return paired() || options.allocations > 0; }
 int windows() const { return paired() ? options.windows : std::max(options.allocations, 1); }
 bool reallocate() const { return options.allocations > 0; }
 int roles() const { return paired() ? 3 : 1; }
 static constexpr std::array<const char *, 3> names{"baseline", "A", "N"};
 std::vector<std::string> binaries() const {
  if (paired()) return {options.kernel, options.reference, options.candidate};
  return {options.kernel};
 }
 int role(int window, int position) const {
  return paired() ? (window % 3 + (window / 3 % 2 ? 2 - position : position)) % 3 : 0;
 }
 void address(std::ostream &out, int window, const std::string &name, uintptr_t value) const {
  if (extended()) out << window << ',' << name << ",0x" << std::hex << value << std::dec << '\n';
 }
};
