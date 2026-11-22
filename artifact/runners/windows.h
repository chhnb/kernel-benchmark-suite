#pragma once
#include <cstdlib>
#include <stdexcept>
#include <string>

inline int artifactWindows() {
  if (auto *value = std::getenv("KBS_WINDOWS")) {
    const std::string text(value);
    size_t end = 0;
    int windows = std::stoi(text, &end);
    if (end != text.size() || windows < 1 || windows > 4096)
      throw std::runtime_error("invalid KBS_WINDOWS");
    return windows;
  }
  return 12;
}
