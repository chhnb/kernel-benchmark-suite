#include "anchor_wave_diagnostic.h"
#include "llvm/ADT/Twine.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include <cassert>

using namespace llvm;
using namespace fusion::wave_diagnostic;

int main() {
  LLVMContext context;
  auto check = [&](StringRef shape, StringRef condition, StringRef category,
                   int mixed, int total, StringRef source = "thread-pattern",
                   StringRef split = "B0", bool nvptx = false) {
    const char *triple = nvptx ? "nvptx64-nvidia-cuda" : "amdgcn-amd-amdhsa";
    const char *tid = nvptx ? "llvm.nvvm.read.ptx.sreg.tid.x" : "llvm.amdgcn.workitem.id.x";
    const char *cc = nvptx ? "ptx_kernel" : "amdgpu_kernel";
    const char *cpu = nvptx ? "sm_70" : "gfx906";
    std::string ir = (Twine("target triple = \"") + triple + "\"\n"
        "declare i32 @" + tid + "()\ndeclare i32 @llvm.ctpop.i32(i32)\n"
        "define " + cc + " void @test(i32* %p, i32 %n) #0 {\n"
        "entry: %x = call i32 @" + tid + "(), !range !0\n").str();
    ir += condition.str();
    ir += (Twine("\nbr i1 %c, label %yes, label %no\nyes: ret void\nno: ret void\n}\n"
        "attributes #0 = { \"target-cpu\"=\"") + cpu +
        "\" \"amdgpu-flat-work-group-size\"=\"1,256\" }\n!0 = !{i32 0, i32 256}\n").str();
    SMDiagnostic error;
    auto m = parseAssemblyString(ir, error, context);
    if (!m) error.print("check-anchor-wave", errs());
    assert(m && !verifyModule(*m));
    const auto &f = *m->getFunction("test");
    auto report = classify(f, findBranch(f, split), shape);
    assert(report.getString("condition_source") == source);
    assert(report.getString("classification") == category);
    assert(report.getInteger("mixed_waves").getValueOr(-1) == mixed);
    assert(report.getInteger("total_waves").getValueOr(-1) == total);
  };

  const StringRef c8 = "%c = icmp ult i32 %x, 8";
  const StringRef c64 = "%c = icmp ult i32 %x, 64";
  check("16,1,1", c8, "must-diverge", 1, 1);
  check("256,1,1", c8, "mixed", 1, 4);
  check("16,4,1", "%c = icmp eq i32 %x, 0", "must-diverge", 1, 1);
  check("128,1,1", c64, "must-uniform", 0, 2);
  check("96,2,1", c64, "mixed", 2, 3);
  check("", c8, "unknown", -1, -1);
  check("", "%c = icmp ult i32 %x, %n", "unknown", -1, -1);
  check("16,1,1", "%c = icmp ult i32 %x, %n", "unknown", -1, 1);
  check("", "%bits = call i32 @llvm.ctpop.i32(i32 %x)\n%c = icmp ult i32 %bits, %n",
        "unknown", -1, -1);
  check("", "%c = icmp sgt i32 %n, 0", "unknown", -1, -1, "workgroup-uniform");
  check("16,1,1", "%v = load i32, i32* %p\n%c = icmp ult i32 %v, 8",
        "unknown", -1, 1, "data");
  check("", "%v = load i32, i32* %p\n%sum = add i32 %x, %v\n%c = icmp sgt i32 %sum, 0",
        "unknown", -1, -1, "data");
  check("", "%choose = icmp uge i32 %x, 8\nbr i1 %choose, label %a, label %b\n"
            "a: br label %merge\nb: br label %merge\nmerge:\n"
            "%c = phi i1 [ true, %a ], [ false, %b ]",
        "unknown", -1, -1, "data", "B3");
  check("64,1,1", "%c = icmp ult i32 %x, 32", "must-uniform", 0, 2,
        "thread-pattern", "B0", true);
  check("", "%c = icmp sgt i32 %n, 0", "unknown", -1, -1,
        "workgroup-uniform", "B0", true);
}
