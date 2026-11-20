#include "domain_competition.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/SourceMgr.h"
#include <cassert>

int main() {
  llvm::LLVMContext ctx;
  llvm::SMDiagnostic error;
  std::string ir = "define void @test(i1 %p, i32 %x) {\n"
      "outer: br i1 %p, label %inner, label %c\n"
      "inner: br i1 %p, label %a, label %b\n";
  for (std::string name : {"a", "b", "c"}) {
    ir += name + ":\n";
    for (unsigned i = 0; i < 8; ++i)
      ir += "%" + name + std::to_string(i) + " = add i32 %x, 1\n";
    ir += "br label %next\n";
  }
  ir += "next: br i1 %p, label %x1, label %x2\n"
        "x1: br label %end\nx2: br label %end\nend: ret void\n}";
  auto module = llvm::parseAssemblyString(ir, error, ctx);
  assert(module);
  auto &function = *module->getFunction("test");
  fusion::FusionDomains domains(function, {});
  auto pair = [](const char *id, const char *split, const char *l, const char *r) {
    return llvm::json::Object{{"candidate", id}, {"split", split}, {"left", l},
                              {"right", r}, {"preflight_rejection", ""}};
  };
  llvm::json::Array catalog;
  catalog.push_back(pair("inner", "B1", "B2", "B3"));
  catalog.push_back(pair("outer", "B0", "B2", "B4"));
  catalog.push_back(pair("independent", "B5", "B6", "B7"));
  auto group = fusion::competingDomains(function, domains, catalog, {});
  assert(group.seed == "inner" && group.commonWork == 8);
  assert(group.owners.size() == 2 && !group.owners.count(domains.root("B5")));
  assert(fusion::competingDomains(function, domains, catalog, {"outer"}).owners.empty());
  (*catalog[1].getAsObject())["preflight_rejection"] = "unsupported";
  assert(fusion::competingDomains(function, domains, catalog, {}).owners.empty());
}
