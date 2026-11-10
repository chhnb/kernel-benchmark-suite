#pragma once
#include "decision_model.h"
namespace decision {
llvm::json::Object compareLegacy(llvm::Function&, const std::vector<Decision>&,
                                const llvm::json::Object&);
}
