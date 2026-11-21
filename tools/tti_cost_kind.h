#pragma once

#include "llvm/ADT/StringRef.h"

namespace fusion {
inline llvm::StringRef ttiCostKindName() {
  return "TCK_RecipThroughput";
}
}
