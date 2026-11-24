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

// A standalone layout parsed in the parent's LLVMContext gets fresh
// identified struct types. Bind them to the original ABI through corresponding
// arguments, outputs and declarations, including recursive pointee graphs.
class RegionTypes final : public ValueMapTypeRemapper {
  DenseMap<Type *, Type *> types;

public:
  bool bind(Type *from, Type *to) {
    if (auto found = types.find(from); found != types.end())
      return found->second == to;
    if (from == to)
      return true;
    if (from->getTypeID() != to->getTypeID() ||
        from->getNumContainedTypes() != to->getNumContainedTypes())
      return false;
    if (auto *pointer = dyn_cast<PointerType>(from)) {
      if (pointer->getAddressSpace() != cast<PointerType>(to)->getAddressSpace())
        return false;
    } else if (auto *array = dyn_cast<ArrayType>(from)) {
      if (array->getNumElements() != cast<ArrayType>(to)->getNumElements())
        return false;
    } else if (auto *vector = dyn_cast<VectorType>(from)) {
      if (vector->getElementCount() != cast<VectorType>(to)->getElementCount())
        return false;
    } else if (auto *function = dyn_cast<FunctionType>(from)) {
      if (function->isVarArg() != cast<FunctionType>(to)->isVarArg())
        return false;
    } else if (auto *structure = dyn_cast<StructType>(from)) {
      auto *target = cast<StructType>(to);
      if (structure->isOpaque() || target->isOpaque() ||
          structure->isPacked() != target->isPacked())
        return false;
    } else {
      return false;
    }
    types[from] = to;
    for (auto pair : llvm::zip(from->subtypes(), to->subtypes()))
      if (!bind(std::get<0>(pair), std::get<1>(pair)))
        return false;
    return true;
  }

  Type *remapType(Type *type) override {
    if (auto found = types.find(type); found != types.end())
      return found->second;
    if (auto *pointer = dyn_cast<PointerType>(type))
      return PointerType::get(remapType(pointer->getElementType()), pointer->getAddressSpace());
    if (auto *array = dyn_cast<ArrayType>(type))
      return ArrayType::get(remapType(array->getElementType()), array->getNumElements());
    if (auto *vector = dyn_cast<VectorType>(type))
      return VectorType::get(remapType(vector->getElementType()), vector->getElementCount());
    if (auto *function = dyn_cast<FunctionType>(type)) {
      SmallVector<Type *, 8> params;
      for (auto *param : function->params())
        params.push_back(remapType(param));
      return FunctionType::get(remapType(function->getReturnType()), params, function->isVarArg());
    }
    if (auto *structure = dyn_cast<StructType>(type); structure && structure->isLiteral()) {
      SmallVector<Type *, 8> fields;
      for (auto *field : structure->elements())
        fields.push_back(remapType(field));
      return StructType::get(type->getContext(), fields, structure->isPacked());
    }
    return type;
  }
};

inline bool replace(Region &region, ArrayRef<Output> outputs, ArrayRef<Value *> arguments,
                    const Function &solution, std::string &failure, bool rebindTypes = false) {
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

  RegionTypes types;
  auto *remap = rebindTypes ? &types : nullptr;
  DominatorTree dom(target);
  for (auto tuple : llvm::zip(arguments, solution.args())) {
    auto *value = std::get<0>(tuple);
    auto *from = std::get<1>(tuple).getType();
    if (from != value->getType() && (!remap || !types.bind(from, value->getType())))
      return bad("solution_argument_type_mismatch");
    if (auto *inst = dyn_cast<Instruction>(value))
      if (!dom.dominates(inst, &region.split) &&
          (!llvm::is_contained(arms, inst->getParent()) || !laneInput(*inst) ||
           !isSafeToSpeculativelyExecute(inst)))
        return bad("region_input_not_available_at_split");
  }

  if (remap)
    for (unsigned i = 0; i < outputs.size(); ++i)
      if (!types.bind(outputValues[i]->getType(), outputs[i].phi->getType()))
        return bad("solution_output_type_mismatch");
  ValueToValueMapTy map;
  for (const auto &decl : *solution.getParent()) {
    if (!decl.isDeclaration())
      continue;
    auto *callee = target.getParent()->getFunction(decl.getName());
    if (!callee || (callee->getFunctionType() != decl.getFunctionType() &&
                    (!remap || !types.bind(decl.getFunctionType(), callee->getFunctionType()))))
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
    RemapInstruction(copy, map, RF_IgnoreMissingLocals | RF_NoModuleLevelChanges, remap);
  auto *entry = cast<BasicBlock>(map.lookup(&solution.getEntryBlock()));
  auto *exit = cast<BasicBlock>(map.lookup(ret->getParent()));
  for (unsigned i = 0; i < outputs.size(); ++i) {
    auto *phi = outputs[i].phi;
    for (auto *pred : {region.left.empty() ? split : region.left.front(),
                       region.right.empty() ? split : region.right.front()})
      phi->removeIncomingValue(pred, false);
    phi->addIncoming(MapValue(outputValues[i], map, RF_NoModuleLevelChanges, remap), exit);
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

// Source-pair observation indexes the original arms, including lane builtins.
// Extraction lifts these builtins to arguments, so translate the indices
// before giving the plan to the region solver.
inline json::Object mapAnchorPairs(const Region &region, const json::Array *observed) {
  json::Object provenance{{"origin", "parent_ir"}};
  if (!observed) {
    provenance["reason"] = "parent anchor pairing unavailable";
    return provenance;
  }
  provenance["parent_pair_count"] = observed->size();
  std::vector<Instruction *> operations[2];
  std::vector<int> index[2];
  unsigned side = 0;
  for (const auto *blocks : {&region.left, &region.right}) {
    int next = 0;
    for (auto *block : *blocks)
      for (auto &inst : *block)
        if (semantic(inst)) {
          operations[side].push_back(&inst);
          index[side].push_back(laneInput(inst) ? -1 : next++);
        }
    ++side;
  }
  json::Array mapped;
  for (const auto &entry : *observed) {
    const auto *pair = entry.getAsObject();
    auto left = pair ? pair->getInteger("left_index") : None;
    auto right = pair ? pair->getInteger("right_index") : None;
    auto swapped = pair ? pair->getBoolean("swapped_operands") : None;
    if (!left || !right || !swapped || *left < 0 || *right < 0 ||
        static_cast<size_t>(*left) >= index[0].size() || static_cast<size_t>(*right) >= index[1].size()) {
      provenance["reason"] = "parent anchor pairing outside original arms";
      return provenance;
    }
    auto l = index[0][*left], r = index[1][*right];
    if (l < 0 || r < 0) {
      if (l < 0 && r < 0 &&
          cast<CallBase>(operations[0][*left])->getCalledFunction() ==
          cast<CallBase>(operations[1][*right])->getCalledFunction())
        continue;
      provenance["reason"] = "unmappable parent anchor builtin pair";
      return provenance;
    }
    mapped.push_back(json::Object{{"left_index", l}, {"right_index", r},
                                   {"swapped_operands", *swapped}});
  }
  provenance["mapped_pair_count"] = mapped.size();
  provenance["source_pairs"] = std::move(mapped);
  return provenance;
}

inline std::unique_ptr<Module> solve(Region &region, ArrayRef<Output> outputs,
                                    Values &arguments, StringRef solver, StringRef costs,
                                    StringRef worker, json::Object &stats, std::string &failure,
                                    bool heuristic, bool anchorUnified,
                                    const json::Array *anchorPairs = nullptr,
                                    function_ref<void(StringRef, const json::Array &)> observe = nullptr) {
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
  if (anchorUnified)
    args.push_back("--anchor-only");
  std::string contextArg;
  if (observe) {
    const auto provenance = (temp + "/anchor.json").str();
    raw_fd_ostream out(provenance, error);
    if (error) {
      failure = error.message();
      return nullptr;
    }
    out << json::Value(mapAnchorPairs(region, anchorPairs));
    contextArg = "--context-pairs=" + provenance;
    args.push_back(contextArg);
  }
  Optional<StringRef> redirects[] = {StringRef(""), StringRef(report), StringRef(diagnostics)};
  std::string executionError;
  if (int exit = sys::ExecuteAndWait(solver, args, None, redirects, 660, 0, &executionError)) {
    failure = "dataflow_exact_solver_failed";
    if (observe) {
      stats["solver_exit"] = exit;
      stats["solver_execution_error"] = executionError;
    }
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
  if (observe) {
    stats["original_T"] = json::Array(*result->getArray("original_T"));
    stats["pairing"] = json::Object(*result->getObject("pairing"));
    stats["pairing_sources"] = json::Object(*result->getObject("original_generators"));
    stats["generation_diagnostics"] = json::Object(*result->getObject("generation_diagnostics"));
    auto *layouts = result->getArray("layouts");
    stats["candidates"] = layouts->size();
    failure = layouts->empty() ? "dataflow_context_no_layout" : "dataflow_context_no_valid_layout";
    observe(temp, *layouts);
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
    if (const auto *generators = result->getObject("original_generators"))
      stats["pairing_sources"] = json::Object(*generators);
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
  auto chosenIR = chosen->getString("ir").getValueOr("");
  if (heuristic)
    chosenIR = chosen->getString("replacement_ir").getValueOr(chosenIR);
  std::string path = (temp + "/" + chosenIR).str();
  auto solution = parseIRFile(path, diagnostic, region.split.getContext());
  if (!solution || verifyModule(*solution, &errs())) {
    failure = "dataflow_exact_invalid_solution";
    return nullptr;
  }
  return solution;
}

} // namespace dataflow::exact
