#pragma once

#include "llvm/ADT/StringRef.h"

#include <optional>

namespace fusion {
inline llvm::StringRef anchorUniformRejection(llvm::StringRef source, bool linear,
                                               std::optional<double> falseGain,
                                               std::optional<double> trueGain) {
  if (!linear || source == "thread-pattern") return {};
  if (source == "workgroup-uniform") return "workgroup_uniform";
  if ((falseGain && *falseGain < 0) || (trueGain && *trueGain < 0))
    return "negative_uniform_gain";
  if (!falseGain || !trueGain)
    return "missing_uniform_gain";
  return {};
}
} // namespace fusion
