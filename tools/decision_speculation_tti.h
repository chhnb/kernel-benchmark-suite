#pragma once
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Target/TargetMachine.h"
#include <memory>
#include <stdexcept>
namespace decision {
struct SpeculationTTI {
 std::unique_ptr<llvm::TargetMachine> machine;
 llvm::FunctionAnalysisManager analyses;
 std::unique_ptr<llvm::TargetTransformInfo> info;
 explicit SpeculationTTI(llvm::Function &f) {
  llvm::InitializeAllTargetInfos();llvm::InitializeAllTargets();llvm::InitializeAllTargetMCs();
  std::string error;auto triple=f.getParent()->getTargetTriple();
  auto *target=llvm::TargetRegistry::lookupTarget(triple,error);
  if(!target)throw std::runtime_error("speculation_tti_target_unavailable: "+error);
  machine.reset(target->createTargetMachine(triple,f.getFnAttribute("target-cpu").getValueAsString(),f.getFnAttribute("target-features").getValueAsString(),llvm::TargetOptions(),llvm::None,llvm::None,llvm::CodeGenOpt::Default));
  if(!machine)throw std::runtime_error("speculation_tti_machine_unavailable");
  info=std::make_unique<llvm::TargetTransformInfo>(machine->getTargetIRAnalysis().run(f,analyses));
 }
};
}
