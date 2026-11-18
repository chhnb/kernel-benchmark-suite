#pragma once

#include "llvm/ADT/StringRef.h"
#include <cstdlib>
#include <stdexcept>

namespace fusion {
inline llvm::StringRef ttiCostKindName() {
  const char *mode = std::getenv("FUSION_TTI_COST_KIND");
  if (!mode || llvm::StringRef(mode) == "throughput")
    return "TCK_RecipThroughput";
  if (llvm::StringRef(mode) == "latency")
    return "TCK_Latency";
  throw std::invalid_argument("FUSION_TTI_COST_KIND must be throughput or latency");
}
}
