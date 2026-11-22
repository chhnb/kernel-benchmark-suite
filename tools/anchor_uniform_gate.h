#pragma once

#include "llvm/Support/JSON.h"

#include <optional>

namespace fusion {
inline bool threadPatternOptimistic(const llvm::json::Object &wave) {
  return wave.getString("condition_source").getValueOr("") == "thread-pattern" &&
         wave.getString("shape_source").getValueOr("") == "unavailable";
}

inline constexpr const char *threadPatternOptimismNotice =
    "thread-pattern condition without an exact workgroup shape; using optimistic TTI; "
    "use --anchor-wave-shape X,Y,Z for per-wave classification";

inline llvm::StringRef anchorUniformRejection(const llvm::json::Object &wave, bool linear,
                                               std::optional<double> falseGain,
                                               std::optional<double> trueGain) {
  if (!linear) return {};
  const auto source = wave.getString("condition_source").getValueOr("");
  if (source == "workgroup-uniform") return "workgroup_uniform";
  if (source == "thread-pattern") {
    const auto waveClass = wave.getString("classification").getValueOr("unknown");
    if (waveClass == "must-diverge" || threadPatternOptimistic(wave)) return {};
    if (waveClass == "must-uniform") return "must_uniform";
  }
  if ((falseGain && *falseGain < 0) || (trueGain && *trueGain < 0))
    return "negative_uniform_gain";
  if (!falseGain || !trueGain)
    return "missing_uniform_gain";
  return {};
}
} // namespace fusion
