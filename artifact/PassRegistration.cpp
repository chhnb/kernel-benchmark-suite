#include "PassRegistration.h"
#include "llvm/PassRegistry.h"

namespace {
// This module registers the upstream legacy pass when opt loads it.
const bool Registered = [] {
  llvm::initializeCFMelder(*llvm::PassRegistry::getPassRegistry());
  return true;
}();
}
