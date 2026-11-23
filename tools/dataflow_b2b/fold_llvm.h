#pragma once

#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Target/TargetMachine.h"

namespace dataflow {
class SizeLatency {
  std::unique_ptr<llvm::TargetMachine> machine;
  llvm::Module context;
  std::unique_ptr<llvm::TargetTransformInfo> tti;

public:
  explicit SizeLatency(const llvm::Module &source)
      : context("dataflow-gfx906-tti", source.getContext()) {
    using namespace llvm;
    static const bool initialized = [] {
      InitializeAllTargetInfos();
      InitializeAllTargets();
      InitializeAllTargetMCs();
      return true;
    }();
    (void)initialized;
    std::string error;
    const auto *target = TargetRegistry::lookupTarget("amdgcn-amd-amdhsa", error);
    if (!target)
      report_fatal_error(Twine(error));
    machine.reset(target->createTargetMachine("amdgcn-amd-amdhsa", "gfx906",
                                    "+sramecc,-xnack", TargetOptions(), None));
    if (!machine)
      report_fatal_error("could not create gfx906 target machine");
    context.setTargetTriple("amdgcn-amd-amdhsa");
    context.setDataLayout(source.getDataLayout());
    auto *f = Function::Create(FunctionType::get(Type::getVoidTy(source.getContext()), false),
                               GlobalValue::ExternalLinkage, "quote", context);
    tti = std::make_unique<TargetTransformInfo>(machine->getTargetTransformInfo(*f));
  }

  const llvm::TargetTransformInfo &analysis() const { return *tti; }
  llvm::TargetTransformInfo freshAnalysis() const {
    return machine->getTargetTransformInfo(*context.getFunction("quote"));
  }

  int quote(const llvm::Instruction &inst) const {
    return tti->getUserCost(&inst, llvm::TargetTransformInfo::TCK_SizeAndLatency);
  }
};
} // namespace dataflow
