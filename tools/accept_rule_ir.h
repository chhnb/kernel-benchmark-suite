#pragma once

#include "llvm/ADT/BitVector.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/IR/Module.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/UniformityAnalysis.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/ModuleSlotTracker.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Support/FormatVariadic.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Target/TargetMachine.h"
#include <algorithm>
#include <array>
#include <cmath>
#include <stdexcept>
#include <vector>

namespace fusion {

inline llvm::json::Object reportIRResidency(const llvm::Function &kernel) {
  using namespace llvm;
  const auto &module = *kernel.getParent();
  const auto cpu = kernel.getFnAttribute("target-cpu").getValueAsString();
  unsigned workgroup = 0;
  StringRef source = "missing";
  if (auto *size = kernel.getMetadata("reqd_work_group_size")) {
    unsigned product = 1;
    if (size->getNumOperands() == 3) {
      for (const auto &operand : size->operands()) {
        auto *dimension = mdconst::dyn_extract<ConstantInt>(operand.get());
        const auto value = dimension ? dimension->getValue().getLimitedValue(1025) : 0;
        if (!value || product > 1024 / value) {
          product = 0;
          break;
        }
        product *= value;
      }
      if (product) {
        workgroup = product;
        source = "reqd_work_group_size";
      }
    }
  }
  if (!workgroup) {
    const auto range = kernel.getFnAttribute("amdgpu-flat-work-group-size").getValueAsString();
    const auto bounds = range.split(',');
    unsigned lower = 0, upper = 0;
    if (!bounds.first.trim().getAsInteger(10, lower) &&
        !bounds.second.trim().getAsInteger(10, upper) &&
        lower > 0 && lower <= upper && upper <= 1024) {
      workgroup = upper;
      source = "amdgpu-flat-work-group-size";
    }
  }

  // Follow operand references and reachable function bodies. Unused LDS
  // from a different kernel in the same module does not consume this CU.
  SmallPtrSet<const Value *, 32> visited;
  SmallVector<const Value *, 32> pending{&kernel};
  uint64_t bytes = 0;
  while (!pending.empty()) {
    const auto *value = pending.pop_back_val();
    if (!visited.insert(value).second)
      continue;
    if (auto *global = dyn_cast<GlobalVariable>(value)) {
      if (global->getAddressSpace() == 3 && global->hasInitializer() &&
          global->getValueType()->isSized()) {
        const auto size = module.getDataLayout().getTypeAllocSize(global->getValueType());
        if (!size.isScalable())
          bytes += size.getFixedValue();
      }
    }
    if (auto *function = dyn_cast<Function>(value))
      for (const auto &block : *function)
        for (const auto &instruction : block)
          pending.push_back(&instruction);
    if (auto *user = dyn_cast<User>(value))
      for (const auto &operand : user->operands())
        pending.push_back(operand.get());
  }
  return json::Object{{"gfx906", module.getTargetTriple().isAMDGCN() && cpu == "gfx906"},
          {"static_lds_bytes", int64_t(bytes)},
          {"workgroup_size", workgroup ? json::Value(workgroup) : json::Value(nullptr)},
          {"workgroup_source", source}};
}

inline int reportAcceptanceIR(llvm::StringRef function,
                              llvm::TargetMachine &target,
                              llvm::Module &module) {
  using namespace llvm;
  auto *f = module.getFunction(function);
  if (!f || f->isDeclaration())
    throw std::runtime_error("acceptance IR function is unavailable");
  LoopAnalysisManager loopAnalyses;
  FunctionAnalysisManager analyses;
  CGSCCAnalysisManager sccAnalyses;
  ModuleAnalysisManager moduleAnalyses;
  analyses.registerPass([&] { return target.getTargetIRAnalysis(); });
  PassBuilder builder(module.getContext(), &target);
  builder.registerLoopAnalyses(loopAnalyses);
  builder.registerFunctionAnalyses(analyses);
  builder.registerCGSCCAnalyses(sccAnalyses);
  builder.registerModuleAnalyses(moduleAnalyses);
  builder.crossRegisterProxies(loopAnalyses, analyses, sccAnalyses, moduleAnalyses);
  const auto &loops = analyses.getResult<LoopAnalysis>(*f);
  auto &scev = analyses.getResult<ScalarEvolutionAnalysis>(*f);
  const auto &uniformity = analyses.getResult<UniformityInfoAnalysis>(*f);
  auto &dom = analyses.getResult<DominatorTreeAnalysis>(*f);

  DenseMap<const Value *, unsigned> indices;
  std::vector<uint64_t> widths;
  auto allocate = [&](const Value &value) {
    auto *type = value.getType();
    if (!type->isSized() || type->isTokenTy())
      return;
    const auto bits = module.getDataLayout().getTypeSizeInBits(type);
    if (bits.isScalable())
      throw std::runtime_error("scalable divergent value has no fixed register width");
    indices[&value] = widths.size();
    widths.push_back(std::max<uint64_t>(1, (bits.getFixedValue() + 31) / 32));
  };
  auto divergentValue = [&](const Value &value) {
    return uniformity.isDivergentAtDef(&value) ||
           llvm::any_of(value.uses(), [&](const Use &use) {
             return uniformity.isDivergentAtUse(use);
           });
  };
  for (const auto &arg : f->args())
    if (divergentValue(arg))
      allocate(arg);
  for (const auto &block : *f)
    if (dom.isReachableFromEntry(&block))
      for (const auto &instruction : block)
        if (!instruction.getType()->isVoidTy() && divergentValue(instruction))
          allocate(instruction);

  DenseMap<const BasicBlock *, BitVector> liveIn;
  for (const auto &block : *f)
    liveIn.try_emplace(&block, widths.size());
  auto mark = [&](BitVector &live, const Value *value, bool present) {
    if (auto it = indices.find(value); it != indices.end()) {
      if (present)
        live.set(it->second);
      else
        live.reset(it->second);
    }
  };
  auto liveOut = [&](const BasicBlock &block) {
    BitVector live(widths.size());
    for (const auto *successor : successors(&block)) {
      live |= liveIn.lookup(successor);
      for (const auto &phi : successor->phis())
        mark(live, phi.getIncomingValueForBlock(&block), true);
    }
    return live;
  };
  auto transfer = [&](BitVector &live, const Instruction &instruction) {
    mark(live, &instruction, false);
    if (!isa<PHINode>(instruction) && !isa<DbgInfoIntrinsic>(instruction))
      for (const auto &operand : instruction.operands())
        mark(live, operand.get(), true);
  };

  bool changed;
  do {
    changed = false;
    for (const auto &block : llvm::reverse(*f)) {
      if (!dom.isReachableFromEntry(&block))
        continue;
      auto live = liveOut(block);
      for (const auto &instruction : llvm::reverse(block))
        transfer(live, instruction);
      auto &previous = liveIn[&block];
      if (live != previous) {
        previous = std::move(live);
        changed = true;
      }
    }
  } while (changed);

  json::Object tripCounts;
  DenseMap<const Loop *, double> loopWeights;
  ModuleSlotTracker slots(&module);
  slots.incorporateFunction(*f);
  for (const auto *loop : loops.getLoopsInPreorder()) {
    const auto trip = scev.getSmallConstantTripCount(loop);
    std::string label;
    raw_string_ostream name(label);
    loop->getHeader()->printAsOperand(name, false, slots);
    tripCounts[label] = trip;
    const auto *outer = loop->getParentLoop();
    loopWeights[loop] = (outer ? loopWeights.lookup(outer) : 1) * (trip ? trip : 8);
  }

  std::array<double, 5> counts{};
  uint64_t pressure = 0;
  auto sample = [&](const BitVector &live) {
    uint64_t registers = 0;
    for (const auto index : live.set_bits())
      registers += widths[index];
    pressure = std::max(pressure, registers);
  };
  for (const auto &block : *f) {
    const auto *loop = loops.getLoopFor(&block);
    if (!loop)
      continue;
    const double weight = loopWeights.lookup(loop);
    auto live = liveOut(block);
    sample(live);
    for (const auto &instruction : llvm::reverse(block)) {
      if (isa<PHINode>(instruction))
        break;
      transfer(live, instruction);
      sample(live);
      if (isa<DbgInfoIntrinsic>(instruction))
        continue;
      if (instruction.isTerminator()) {
        if ((isa<SwitchInst>(instruction) || isa<CondBrInst>(instruction)) &&
            uniformity.isDivergentTerminator(&instruction))
          counts[4] += weight;
        continue;
      }
      if (instruction.mayReadOrWriteMemory()) {
        bool lds = false, global = false;
        const Value *address = nullptr;
        if (auto *load = dyn_cast<LoadInst>(&instruction))
          address = load->getPointerOperand();
        else if (auto *store = dyn_cast<StoreInst>(&instruction))
          address = store->getPointerOperand();
        else if (auto *rmw = dyn_cast<AtomicRMWInst>(&instruction))
          address = rmw->getPointerOperand();
        else if (auto *cx = dyn_cast<AtomicCmpXchgInst>(&instruction))
          address = cx->getPointerOperand();
        auto countAddress = [&](const Value *pointer) {
          if (auto *type = dyn_cast<PointerType>(pointer->getType())) {
            lds |= type->getAddressSpace() == 3;
            global |= type->getAddressSpace() == 1;
          }
        };
        if (address)
          countAddress(address);
        else if (auto *call = dyn_cast<CallBase>(&instruction))
          for (const auto &arg : call->args())
            countAddress(arg.get());
        counts[0] += lds ? weight : 0;
        counts[1] += global ? weight : 0;
        if (lds || global)
          continue;
      }
      const bool divergent = instruction.getType()->isVoidTy()
          ? llvm::any_of(instruction.operands(), [&](const Use &use) {
              return uniformity.isDivergentAtUse(use);
            })
          : uniformity.isDivergentAtDef(&instruction);
      counts[divergent ? 2 : 3] += weight;
    }
  }
  const double work = counts[0] + counts[1] + counts[2] + counts[4];
  if (!std::isfinite(work) || !std::isfinite(counts[3]))
    throw std::runtime_error("loop weights exceed finite range");
  outs() << formatv("{0}\n", json::Value(json::Object{
      {"lds", counts[0]}, {"global", counts[1]}, {"divergent", counts[2]},
      {"uniform", counts[3]}, {"divergent_branch", counts[4]},
      {"work", work}, {"vgpr_peak", int64_t(pressure)},
      {"trip_counts", std::move(tripCounts)},
      {"residency", reportIRResidency(*f)}
  }));
  return 0;
}

} // namespace fusion
