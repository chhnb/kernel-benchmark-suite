#pragma once
#include "llvm/IR/Function.h"
#include "llvm/Support/JSON.h"
#include <string>
#include <vector>
namespace decision {
enum class ArmKind { Linear, SESE, Unsupported };
struct Edge { llvm::BasicBlock *test; unsigned successor; };
struct Arm {
  std::string id;
  llvm::BasicBlock *entry=nullptr;
  std::vector<llvm::BasicBlock*> blocks, exitSources;
  std::vector<Edge> predicate;
  std::vector<std::vector<Edge>> alternatives;
  std::vector<std::string> mergedFrom;
  std::string orderFamily;
  int orderFirst=-1, orderLast=-1;
  ArmKind kind=ArmKind::Unsupported;
  std::string reason;
};
struct Decision {
  std::string id;
  llvm::BasicBlock *root=nullptr, *join=nullptr;
  std::vector<llvm::BasicBlock*> tests;
  std::vector<Arm> arms;
};
// Read-only; all pointers are valid only for this function snapshot.
std::vector<Decision> discover(llvm::Function &);
llvm::json::Array describe(const std::vector<Decision>&);
// Experimental adjacent chain normalization. Caller owns a disposable clone.
// Safe condition speculation within budget; no fusion. Caller discards failures.
bool normalize(llvm::Function&, const Decision&, unsigned left, std::string &reason,
               llvm::BasicBlock **dispatchOut=nullptr, unsigned conditionBudget=4);
}
