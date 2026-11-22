#pragma once
#include "options.hpp"
#include <algorithm>
#include <cstdint>

struct BatchMeasurement {
 const Options &options;
 std::vector<std::string> paths;
 explicit BatchMeasurement(const Options &opts) : options(opts) {
   const char *p = std::getenv("ACCEPT_BATCH_OBJECTS");
   need(p != nullptr, "missing batch object list");
   std::ifstream stream(p);
   need(bool(stream), "opening batch object list");
   std::string line;
   while (std::getline(stream, line)) {
     need(!line.empty(), "empty object path");
     paths.push_back(line);
   }
   need(!paths.empty() && paths.size() <= 8, "1 to 8 resident roles required");
 }
 bool paired() const { return true; }
 bool extended() const { return true; }
 int windows() const { return options.windows; }
 bool reallocate() const { return false; }
 int roles() const { return int(paths.size()); }
 std::string name(int slot) const { return "state" + std::to_string(slot); }
 const std::vector<std::string> &binaries() const { return paths; }
 int role(int window, int position) const {
   return (window % roles() + (window / roles() % 2 ? roles()-1-position : position)) % roles();
 }
 void address(std::ostream &out, int window, const std::string &name, uintptr_t base) const {
   out << window << ',' << name << ",0x" << std::hex << base << std::dec << '\n';
 }
};
