#include "decision_uniform_paths.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/ValueSymbolTable.h"
#include "llvm/Support/SourceMgr.h"
#include <cassert>

using namespace llvm;
using namespace decision;

int main() {
 LLVMContext ctx;
 SMDiagnostic error;
 auto m=parseAssemblyString(R"(
declare float @llvm.fabs.f32(float)
define void @floating(float %x) {
entry:
  %a = call float @llvm.fabs.f32(float %x)
  %old = fcmp ugt float %a, 2.500000e-01
  %nan = fcmp uno float %a, 0.000000e+00
  %below = fcmp olt float %a, 5.000000e-01
  %tiny = fcmp olt float %a, 2.500000e-01
  %compound = or i1 %below, %tiny
  br label %root
root:
  %b = call float @llvm.fabs.f32(float %x)
  %new = fcmp olt float %b, 7.500000e-01
  br i1 %new, label %yes, label %no
yes:
  br label %join
no:
  br label %join
join:
  ret void
}
define void @integer(i8 %x) {
entry:
  %negative = icmp slt i8 %x, 0
  br label %root
root:
  %unsigned = icmp uge i8 %x, 128
  %inverted = xor i1 %unsigned, true
  br i1 %inverted, label %no, label %yes
yes:
  br label %join
no:
  br label %join
join:
  ret void
}
define void @short_circuit(i1 %flag, i1 %other) {
root:
  br i1 %flag, label %left, label %right
left:
  br label %gate
right:
  br label %gate
gate:
  %known = phi i1 [true, %left], [false, %right]
  %take = select i1 %known, i1 true, i1 %other
  br i1 %take, label %yes, label %no
yes:
  br label %join
no:
  br label %join
join:
  ret void
}
)",error,ctx);
 if(!m){error.print("uniform paths",errs());return 1;}
 auto check=[&](StringRef name,StringRef fact,bool truth,bool yes,bool no){
  auto *function=m->getFunction(name);
  auto *root=cast<BasicBlock>(function->getValueSymbolTable()->lookup("root"));
  auto *join=cast<BasicBlock>(function->getValueSymbolTable()->lookup("join"));
  auto *value=function->getValueSymbolTable()->lookup(fact);
  auto region=uniformRegion(root,join);
  assert(region&&value);
  UniformValueKeys keys;
  UniformPath path;
  assumeUniform(value,truth,keys,path);
  auto reachable=uniformReachable(*region,path,keys,false);
  assert(reachable.count(cast<BasicBlock>(function->getValueSymbolTable()->lookup("yes")))==yes);
  assert(reachable.count(cast<BasicBlock>(function->getValueSymbolTable()->lookup("no")))==no);
 };
 check("floating","old",false,true,false);
 check("floating","nan",true,false,true);
 check("floating","compound",true,true,false);
 check("integer","negative",true,true,false);
 check("short_circuit","flag",true,true,false);
 check("short_circuit","flag",false,true,true);
 // NaN is included by UGT and excluded by OLT.
 auto *fp=m->getFunction("floating");
 auto *quarter=ConstantFP::get(Type::getFloatTy(ctx),0.25);
 CellSpace cells(Type::getFloatTy(ctx),*fp,{quarter});
 auto *nan=ConstantFP::getNaN(Type::getFloatTy(ctx));
 assert(CellSpace::compare(CmpInst::FCMP_UGT,nan,quarter));
 assert(!CellSpace::compare(CmpInst::FCMP_OLT,nan,quarter));
 assert(llvm::is_contained(cells.cells(),nan));
 outs()<<"FP cells, duplicate fabs, mixed signed comparisons and PHI/select reachability pass\n";
}
