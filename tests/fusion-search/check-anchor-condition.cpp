#include "anchor_condition.h"
#include "llvm/ADT/Twine.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/SourceMgr.h"
#include <cassert>

using namespace llvm;
using namespace fusion::anchor_condition;

int main() {
  LLVMContext context;
  auto check = [&](StringRef condition, StringRef source,
                   StringRef split = "B0", bool nvptx = false) {
    const char *triple = nvptx ? "nvptx64-nvidia-cuda" : "amdgcn-amd-amdhsa";
    const char *tid = nvptx ? "llvm.nvvm.read.ptx.sreg.tid.x" : "llvm.amdgcn.workitem.id.x";
    const char *cc = nvptx ? "ptx_kernel" : "amdgpu_kernel";
    const char *cpu = nvptx ? "sm_70" : "gfx906";
    std::string ir = (Twine("target triple = \"") + triple + "\"\n"
        "declare i32 @" + tid + "()\ndeclare i32 @llvm.ctpop.i32(i32)\n"
        "define " + cc + " void @test(i32* %p, i32 %n) #0 {\n"
        "entry: %x = call i32 @" + tid + "()\n").str();
    ir += condition.str();
    ir += (Twine("\nbr i1 %c, label %yes, label %no\nyes: ret void\nno: ret void\n}\n"
        "attributes #0 = { \"target-cpu\"=\"") + cpu +
        "\" }\n").str();
    SMDiagnostic error;
    auto m = parseAssemblyString(ir, error, context);
    if (!m) error.print("check-anchor-condition", errs());
    assert(m && !verifyModule(*m));
    const auto &f = *m->getFunction("test");
    assert(classifySource(findBranch(f, split)) == source);
  };

  check("%c = icmp ult i32 %x, 8", "thread-pattern");
  check("%c = icmp ult i32 %x, %n", "thread-pattern");
  check("%bits = call i32 @llvm.ctpop.i32(i32 %x)\n%c = icmp ult i32 %bits, %n",
        "thread-pattern");
  check("%c = icmp sgt i32 %n, 0", "workgroup-uniform");
  check("%v = load i32, i32* %p\n%c = icmp ult i32 %v, 8", "data");
  check("%v = load i32, i32* %p\n%sum = add i32 %x, %v\n%c = icmp sgt i32 %sum, 0",
        "data");
  check("%choose = icmp uge i32 %x, 8\nbr i1 %choose, label %a, label %b\n"
        "a: br label %merge\nb: br label %merge\nmerge:\n"
        "%c = phi i1 [ true, %a ], [ false, %b ]",
        "data", "B3");
  check("%c = icmp ult i32 %x, 32", "thread-pattern", "B0", true);
  check("%c = icmp sgt i32 %n, 0", "workgroup-uniform", "B0", true);
}
