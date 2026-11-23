#pragma once

#include "../fusion_search.h"
#include "region_output.h"
#include "region_extract.h"
#include "llvm/ADT/ScopeExit.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/IR/Dominators.h"
#include "llvm/Support/Program.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

namespace dataflow::exact {
using namespace llvm;
using namespace extraction;

inline std::string blockID(const BasicBlock &block) {
  return "B" + std::to_string(std::distance(block.getParent()->begin(), block.getIterator()));
}

inline BranchInst *findSplit(Function &fn, const fusion::Candidate &candidate) {
  auto split = StringRef(candidate.split);
  unsigned index;
  if (!split.consume_front("B") || split.getAsInteger(10, index) || index >= fn.size())
    return nullptr;
  auto *branch = dyn_cast<BranchInst>(std::next(fn.begin(), index)->getTerminator());
  if (!branch || !branch->isConditional())
    return nullptr;
  auto left = blockID(*branch->getSuccessor(0)), right = blockID(*branch->getSuccessor(1));
  if ((candidate.left != left || candidate.right != right) &&
      (candidate.right != left || candidate.left != right))
    return nullptr;
  return classifyB2B(*branch).isB2B() ? branch : nullptr;
}

inline constexpr unsigned exactOperationLimit = 10;

inline unsigned operationCount(const Region &region) {
  unsigned size = 0;
  for (const auto &side : {region.left, region.right})
    for (const auto *arm : side)
      size += llvm::count_if(*arm, semantic);
  return size;
}

inline void addCandidates(Function &fn, std::vector<fusion::Candidate> &candidates, bool heuristic) {
  for (auto &block : fn) {
    auto *branch = dyn_cast<BranchInst>(block.getTerminator());
    if (!branch || !branch->isConditional())
      continue;
    auto region = classifyB2B(*branch);
    if (!region.isB2B() || (!heuristic && operationCount(region) > exactOperationLimit))
      continue;
    fusion::Candidate candidate{fn.getName().str(), blockID(block),
                                blockID(*branch->getSuccessor(0)),
                                blockID(*branch->getSuccessor(1)), 0, {}, {}, {}};
    if (llvm::none_of(candidates, [&](const auto &existing) {
          return existing.key() == candidate.key() ||
              (existing.split == candidate.split && existing.left == candidate.right &&
               existing.right == candidate.left);
        }))
      candidates.push_back(std::move(candidate));
  }
}

inline bool replace(Region &region, ArrayRef<Output> outputs, ArrayRef<Value *> arguments,
                    const Function &solution, std::string &failure) {
  auto *split = region.split.getParent();
  auto &target = *split->getParent();
  Blocks arms = region.left;
  arms.append(region.right.begin(), region.right.end());
  auto bad = [&](StringRef reason) { failure = reason.str(); return false; };
  for (auto *arm : arms) {
    if (arm->hasAddressTaken() || !arm->phis().empty())
      return bad("unsupported_region_arm");
    for (const auto &inst : *arm)
      for (const auto &use : inst.uses()) {
        auto *user = dyn_cast<Instruction>(use.getUser());
        auto *phi = dyn_cast_or_null<PHINode>(user);
        if (!user || (user->getParent() != arm &&
            (!phi || phi->getParent() != region.join || phi->getIncomingBlock(use) != arm)))
          return bad("arm_value_used_outside_join");
      }
  }

  const ReturnInst *ret = nullptr;
  for (const auto &block : solution)
    if (const auto *exit = dyn_cast<ReturnInst>(block.getTerminator())) {
      if (ret)
        return bad("multiple_solution_returns");
      ret = exit;
    }
  auto writeABI = outputs.size() > 1;
  if (!ret || solution.arg_size() != arguments.size() + writeABI)
    return bad("solution_signature_mismatch");
  if (bool(ret->getReturnValue()) != (outputs.size() == 1))
    return bad("solution_return_mismatch");
  auto transport = outputWrites(*ret, solution);
  SmallVector<const Value *, 8> outputValues(outputs.size(), nullptr);
  if (outputs.size() == 1)
    outputValues[0] = ret->getReturnValue();
  if (writeABI)
    for (const auto *inst : transport)
      if (const auto *store = dyn_cast<StoreInst>(inst)) {
        auto *gep = cast<GetElementPtrInst>(store->getPointerOperand());
        auto *index = cast<ConstantInt>(gep->getOperand(gep->getNumOperands()-1));
        outputValues[index->getZExtValue()] = store->getValueOperand();
      }
  if (llvm::any_of(outputValues, [](auto *value) { return !value; }))
    return bad("solution_output_transport_mismatch");

  DominatorTree dom(target);
  for (auto tuple : llvm::zip(arguments, solution.args())) {
    auto *value = std::get<0>(tuple);
    if (value->getType() != std::get<1>(tuple).getType())
      return bad("solution_argument_type_mismatch");
    if (auto *inst = dyn_cast<Instruction>(value))
      if (!dom.dominates(inst, &region.split) &&
          (!llvm::is_contained(arms, inst->getParent()) || !laneInput(*inst) ||
           !isSafeToSpeculativelyExecute(inst)))
        return bad("region_input_not_available_at_split");
  }

  ValueToValueMapTy map;
  for (const auto &decl : *solution.getParent()) {
    if (!decl.isDeclaration())
      continue;
    auto *callee = target.getParent()->getFunction(decl.getName());
    if (!callee || callee->getFunctionType() != decl.getFunctionType())
      return bad("solution_callee_mismatch");
    map[&decl] = callee;
  }
  for (auto tuple : llvm::zip(arguments, solution.args())) {
    auto *value = std::get<0>(tuple);
    if (auto *inst = dyn_cast<Instruction>(value))
      if (llvm::is_contained(arms, inst->getParent())) {
        auto *copy = inst->clone();
        copy->insertBefore(&region.split);
        value = copy;
      }
    map[&std::get<1>(tuple)] = value;
  }
  for (const auto &block : solution)
    map[&block] = BasicBlock::Create(target.getContext(), "dataflow", &target, region.join);
  SmallVector<Instruction *, 16> copies;
  for (const auto &block : solution) {
    auto *destination = cast<BasicBlock>(map.lookup(&block));
    for (const auto &inst : block) {
      if (&inst == ret || transport.count(&inst))
        continue;
      auto *copy = inst.clone();
      destination->getInstList().push_back(copy);
      map[&inst] = copy;
      copies.push_back(copy);
    }
  }
  for (auto *copy : copies)
    RemapInstruction(copy, map, RF_IgnoreMissingLocals | RF_NoModuleLevelChanges);
  auto *entry = cast<BasicBlock>(map.lookup(&solution.getEntryBlock()));
  auto *exit = cast<BasicBlock>(map.lookup(ret->getParent()));
  for (unsigned i = 0; i < outputs.size(); ++i) {
    auto *phi = outputs[i].phi;
    for (auto *pred : {region.left.empty() ? split : region.left.front(),
                       region.right.empty() ? split : region.right.front()})
      phi->removeIncomingValue(pred, false);
    phi->addIncoming(MapValue(outputValues[i], map, RF_NoModuleLevelChanges), exit);
  }
  BranchInst::Create(region.join, exit);
  BranchInst::Create(entry, &region.split);
  region.split.eraseFromParent();
  for (auto *arm : arms)
    arm->dropAllReferences();
  for (auto *arm : arms)
    arm->eraseFromParent();
  if (entry == exit)
    exit = split;
  MergeBlockIntoPredecessor(entry);
  // No extra jump or PHI is needed when this rewrite is the only path to join.
  if (region.join->getSinglePredecessor() == exit)
    MergeBlockIntoPredecessor(region.join);
  return true;
}

inline std::unique_ptr<Module> solve(Region &region, ArrayRef<Output> outputs,
                                    Values &arguments, StringRef solver, StringRef costs,
                                    StringRef worker, json::Object &stats, std::string &failure,
                                    bool heuristic) {
  const unsigned size = operationCount(region);
  const bool fallback = !heuristic && size > exactOperationLimit;
  StringRef source = fusion::anchor_condition::classifySource(&region.split);
  stats["operations"] = size;
  stats["kind"] = region.kind;
  stats["condition_source"] = source;
  stats["handler"] = fallback ? "anchor_fallback" : heuristic ? "dataflow_solver" : "reference_solver";
  auto extracted = isolate(region, outputs, failure, &arguments);
  std::string ir;
  if (extracted) {
    raw_string_ostream stream(ir);
    extracted->print(stream, nullptr);
    stream.flush();
    stats["region_id"] = digest(region.kind.str() + "\n" + ir);
  }
  if (fallback) {
    if (!extracted)
      stats["extraction_error"] = failure;
    failure = "dataflow_exact_size_limit";
    return nullptr;
  }
  if (!extracted)
    return nullptr;
  SmallString<256> temp;
  if (auto err = sys::fs::createUniqueDirectory("dataflow-exact", temp)) {
    failure = err.message();
    return nullptr;
  }
  auto cleanup = make_scope_exit([&] { sys::fs::remove_directories(temp); });
  std::string input = (temp + "/input.ll").str();
  std::string report = (temp + "/report.json").str();
  std::string diagnostics = (temp + "/stderr").str();
  std::error_code error;
  {
    raw_fd_ostream out(input, error);
    if (error) {
      failure = error.message();
      return nullptr;
    }
    out << ir;
  }
  std::string workerArg = ("--tti-worker=" + worker).str();
  SmallVector<StringRef, 8> args{solver, input, costs, temp, "--cost=real", workerArg};
  std::string conditionArg = ("--condition-source=" + source).str();
  if (heuristic)
    args.push_back(conditionArg);
  Optional<StringRef> redirects[] = {StringRef(""), StringRef(report), StringRef(diagnostics)};
  if (sys::ExecuteAndWait(solver, args, None, redirects, 660)) {
    failure = "dataflow_exact_solver_failed";
    if (auto diagnostic = MemoryBuffer::getFile(diagnostics))
      stats["diagnostics"] = (*diagnostic)->getBuffer().str();
    return nullptr;
  }
  auto buffer = MemoryBuffer::getFile(report);
  if (!buffer) {
    failure = buffer.getError().message();
    return nullptr;
  }
  auto parsed = json::parse((*buffer)->getBuffer());
  if (!parsed) {
    failure = toString(parsed.takeError());
    return nullptr;
  }
  auto *result = parsed->getAsObject();
  if (!result || !result->getBoolean("complete").getValueOr(false)) {
    failure = "dataflow_exact_incomplete";
    if (result)
      stats["solver_reason"] = result->getString("reason").getValueOr("").str();
    return nullptr;
  }
  const auto cost = [](const json::Array &values) {
    return std::array<int64_t, 3>{*values[0].getAsInteger(), *values[1].getAsInteger(),
                                   *values[2].getAsInteger()};
  };
  auto baseline = cost(*result->getArray("original_T"));
  stats["original_T"] = json::Array(*result->getArray("original_T"));
  stats["candidates"] = *result->getInteger("candidates");
  const json::Object *chosen = nullptr;
  if (heuristic) {
    if (auto selected = result->getObject("selected")) {
      if (!selected->getBoolean("original").getValueOr(false))
        chosen = selected;
    }
    stats["pairing"] = json::Object(*result->getObject("pairing"));
    stats["winner"] = result->getString("winner").getValueOr("original").str();
  } else for (const auto &value : *result->getArray("pareto_front")) {
    const auto *entry = value.getAsObject();
    auto t = cost(*entry->getArray("T"));
    if (source == "workgroup-uniform") {
      auto peak = std::max(t[1], t[2]);
      if (peak < (chosen ? *stats.getInteger("objective") : std::max(baseline[1], baseline[2]))) {
        chosen = entry;
        stats["objective"] = peak;
      }
    } else if (source == "thread-pattern" || source == "data") {
      if (source == "data" && (t[1] > baseline[1] || t[2] > baseline[2]))
        continue;
      if (t[0] < baseline[0]) {
        chosen = entry;
        break;
      }
    }
  }
  if (!chosen) {
    stats["choice"] = "original";
    failure = "dataflow_exact_keep_original";
    return nullptr;
  }
  stats["choice"] = "fuse";
  stats["chosen"] = json::Object(*chosen);
  SMDiagnostic diagnostic;
  std::string path = (temp + "/" + chosen->getString("ir").getValueOr("")).str();
  auto solution = parseIRFile(path, diagnostic, region.split.getContext());
  if (!solution || verifyModule(*solution, &errs())) {
    failure = "dataflow_exact_invalid_solution";
    return nullptr;
  }
  return solution;
}

} // namespace dataflow::exact
