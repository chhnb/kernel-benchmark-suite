#pragma once

#include "llvm/Support/CommandLine.h"
#include <stdexcept>

namespace fusion {

// LLVM12 SimplifyCFG reads the registered PHI fold limit. Initialize it once
// in every process that runs the structural cleanup.
inline void configureDarmCFGCleanup() {
  static const bool configured = [] {
    const llvm::StringRef name = "two-entry-phi-node-folding-threshold";
    auto &registered = llvm::cl::getRegisteredOptions();
    auto option = registered.find(name);
    return option != registered.end() && !option->second->addOccurrence(0, name, "7");
  }();
  if (!configured)
    throw std::runtime_error("cannot configure v1 PHI fold threshold");
}

}
