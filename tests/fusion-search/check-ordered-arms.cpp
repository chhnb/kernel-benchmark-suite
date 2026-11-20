#include "ordered_arms.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/SourceMgr.h"
#include <cassert>

int main() {
  const char *cleaned = R"(
    define void @f(i1 %p, i1 %q, i32* %out) {
    root: br i1 %p, label %ab, label %c
    ab: store i32 1, i32* %out
        br i1 %q, label %left, label %right
    left: br label %join
    right: br label %join
    c: store i32 2, i32* %out
       br label %join, !decision.ordered_trial_boundary !0
    join: ret void, !decision.ordered_trial_boundary !1
    }
    !0 = !{i32 2}
    !1 = !{i32 -1}
  )";
  for (int scenario=0; scenario!=4; ++scenario) {
    llvm::LLVMContext ctx;
    llvm::SMDiagnostic error;
    auto m=llvm::parseAssemblyString(cleaned,error,ctx);
    assert(m);
    auto &f=*m->getFunction("f");
    auto &leaf=*std::next(f.begin(),4);
    auto &join=f.back();
    decision::OrderedArms table;
    table.start(3);
    table.atFunctionEntry=scenario!=3;
    if(scenario==1) leaf.getTerminator()->setMetadata(table.marker,nullptr);
    if(scenario==2) f.getEntryBlock().getTerminator()->setMetadata(
        table.marker,join.getTerminator()->getMetadata(table.marker));
    auto status=table.advance(f,0);
    if(scenario==0) {
      assert(status=="rebound" && table.nextDecision);
      auto catalog=decision::discover(f);
      auto &decision=catalog.at(*table.nextDecision);
      table.arrange(decision);
      assert(table.ranges[0]==std::make_pair(0u,1u));
      assert(decision.arms[0].entry->getName()=="ab");
      assert(std::string(table.shape(decision.arms[0]))=="R");
      assert(std::string(table.shape(decision.arms[1]))=="B");
    } else {
      assert(!table.nextDecision && table.retired && status!="rebound");
    }
    for(auto &bb:f) for(auto &i:bb) assert(!i.getMetadata(table.marker));
  }
}
