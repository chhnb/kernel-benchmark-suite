#pragma once

#include "llvm/ADT/StringRef.h"

#include <optional>

namespace fusion {
inline llvm::StringRef anchorUniformRejection(llvm::StringRef waveClass, bool linear,
                                               std::optional<double> falseGain,
                                               std::optional<double> trueGain,
                                               bool rejectMissing) {
  if (!linear || waveClass == "must-diverge")
    return {};
  if (waveClass == "must-uniform")
    return "must_uniform";
  if ((falseGain && *falseGain < 0) || (trueGain && *trueGain < 0))
    return "negative_uniform_gain";
  if (rejectMissing && (!falseGain || !trueGain))
    return "missing_uniform_gain";
  return {};
}
} // namespace fusion
