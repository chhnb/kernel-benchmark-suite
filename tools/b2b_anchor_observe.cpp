#include "b2b_anchor_observe.h"

#include "llvm/IR/Instructions.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/raw_ostream.h"
#include <cstdlib>
#include <stdexcept>

using namespace llvm;
namespace fusion {
namespace {
using Work = ArrayRef<Instruction *>;

json::Object matchJSON(AnchorMatch pair) {
  return json::Object{{"left", int64_t(pair.left)}, {"right", int64_t(pair.right)},
                      {"swapped", pair.swapped}};
}

json::Array matchesJSON(ArrayRef<AnchorMatch> matches) {
  json::Array result;
  for (auto pair : matches)
    result.push_back(matchJSON(pair));
  return result;
}

json::Object stateJSON(ObservedAnchorState state) {
  return json::Object{{"pairs", matchesJSON(state.pairs)}, {"score", state.score},
                      {"chargedSegments", int64_t(state.chargedSegments)},
                      {"phiCharge", state.phiCharge}};
}

StringRef insertionName(AnchorInsertion result) {
  if (result == AnchorInsertion::Kept) return "inserted";
  if (result == AnchorInsertion::Duplicate) return "duplicate";
  return "beam_reject";
}

std::string operandName(const Value &value) {
  std::string text;
  raw_string_ostream stream(text);
  value.printAsOperand(stream, false);
  return stream.str();
}
} // namespace

B2BObservation::B2BObservation() : path(std::getenv("FUSION_OBSERVE_B2B_DP")) {}

void B2BObservation::conflict(AnchorMatch pair) {
  conflictingPairs.push_back(matchJSON(pair));
}

void B2BObservation::prune(ObservedAnchorState state, StringRef phase) {
  auto event = stateJSON(state);
  event["phase"] = phase;
  pruned.push_back(std::move(event));
}

void B2BObservation::evict(ObservedAnchorState state, StringRef phase, unsigned i, unsigned j) {
  auto event = stateJSON(state);
  event["phase"] = phase;
  event["left_boundary"] = int64_t(i);
  event["right_boundary"] = int64_t(j);
  pruned.push_back(std::move(event));
}

void B2BObservation::segment(unsigned li, unsigned ri, unsigned le, unsigned re, bool rejoins) {
  segmentsObserved.push_back(json::Object{
      {"left_begin", int64_t(li)}, {"left_end", int64_t(le)},
      {"right_begin", int64_t(ri)}, {"right_end", int64_t(re)}, {"rejoins", rejoins}});
}

void B2BObservation::transition(AnchorMatch pair, ObservedAnchorState state,
                                int cost, int inputs, StringRef reason) {
  auto event = matchJSON(pair);
  event["instructionCost"] = cost;
  event["inputCost"] = inputs;
  event["gain"] = cost - inputs;
  event["prior_score"] = state.score;
  event["prior_pairs"] = int64_t(state.pairs.size());
  event["outcome"] = reason;
  transitions.push_back(std::move(event));
}

void B2BObservation::transition(AnchorMatch pair, ObservedAnchorState state,
                                int cost, int inputs, AnchorInsertion outcome) {
  transition(pair, state, cost, inputs, insertionName(outcome));
}

void B2BObservation::plan(ObservedAnchorState state) {
  plans.push_back(stateJSON(state));
}

void B2BObservation::write(
    Work left, Work right, BasicBlock &leftBlock, BasicBlock &rightBlock, bool pairTies,
    bool linear, ArrayRef<AnchorMatch> proposed, ArrayRef<AnchorMatch> anchors,
    ArrayRef<AnchorMatch> cutoffs, ArrayRef<AnchorMatch> forwardCutoffs, unsigned conflicts,
    function_ref<int(const Instruction &)> instructionCost, function_ref<int(Type *)> selectCost,
    function_ref<int(Type *)> phiCost, function_ref<bool(unsigned, unsigned)> canSkip) {
  auto instructions = [&](Work arm, unsigned side) {
    json::Array list;
    auto hasTransferCost = [](Type *type) {
      return type->isFirstClassType() && type->isSized() &&
             !type->isTokenTy() && !type->isMetadataTy() && !type->isLabelTy();
    };
    for (auto item : llvm::enumerate(arm)) {
      auto &inst = *item.value();
      std::string ir, type;
      raw_string_ostream irStream(ir), typeStream(type);
      inst.print(irStream);
      inst.getType()->print(typeStream);
      json::Array operands;
      for (const auto &operand : inst.operands()) {
        std::string operandType;
        raw_string_ostream operandStream(operandType);
        operand->getType()->print(operandStream);
        auto *ty = operand->getType();
        operands.push_back(json::Object{{"value", operandName(*operand)}, {"type", operandStream.str()},
            {"anchorSelectCost", hasTransferCost(ty) ? json::Value(selectCost(ty)) : json::Value(nullptr)}});
      }
      json::Object row{{"index", int64_t(item.index())},
          {"opcode", inst.getOpcodeName()}, {"type", typeStream.str()}, {"ir", irStream.str()},
          {"anchorCost", instructionCost(inst)},
          {"anchorSelectCost", hasTransferCost(inst.getType()) ? json::Value(selectCost(inst.getType())) : json::Value(nullptr)},
          {"anchorPhiCost", hasTransferCost(inst.getType()) ? json::Value(phiCost(inst.getType())) : json::Value(nullptr)},
          {"operands", std::move(operands)}};
      if (linear) row["linear_skippable"] = canSkip(side, item.index());
      list.push_back(std::move(row));
    }
    return list;
  };
  std::error_code error;
  raw_fd_ostream trace(path, error, sys::fs::OF_Append);
  if (error)
    throw std::runtime_error("writing B2B observation: " + error.message());
  trace << json::Value(json::Object{{"mode", pairTies ? "relaxed" : "strict"},
      {"left_block", operandName(leftBlock)}, {"right_block", operandName(rightBlock)},
      {"gap", linear ? "auto" : "fork"},
      {"guarded_gap", linear}, {"select_dedup", false}, {"cutoff", "static"},
      {"gap_rank", "lazy"},
      {"left", instructions(left, 0)}, {"right", instructions(right, 1)},
      {"proposed", matchesJSON(proposed)}, {"anchors", matchesJSON(anchors)},
      {"cutoffs", matchesJSON(cutoffs)}, {"forward_cutoffs", matchesJSON(forwardCutoffs)},
      {"conflicts", int64_t(conflicts)}, {"conflicting_pairs", std::move(conflictingPairs)},
      {"transitions", std::move(transitions)}, {"pruned", std::move(pruned)},
      {"segments", std::move(segmentsObserved)}, {"plans", std::move(plans)}}) << '\n';
}
} // namespace fusion
