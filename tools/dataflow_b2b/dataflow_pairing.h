#pragma once

#include "pairing_region.h"
#include "real_cost.h"

namespace dataflow::pairing {
struct ComponentReport {
  unsigned candidates;
  bool exact;
  int64_t gain;
};

struct Result {
  unsigned candidates = 0;
  std::vector<ComponentReport> components;
  std::vector<Node> selected;
  int64_t gain = 0;
  std::vector<std::vector<Node>> subsets;
};

// The provider is empty in the abstract mode, as in evaluate_cost.
llvm::Expected<Result> choose(const llvm::Function &function, const Diamond &shape,
                              const llvm::json::Object &table, bool subplans,
                              llvm::function_ref<llvm::Expected<InstructionCosts>(
                                  const llvm::Function &)> quote = nullptr);
} // namespace dataflow::pairing
