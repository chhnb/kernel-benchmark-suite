#include "darm_pair_engine/GapPlanning.h"
#include "llvm/AsmParser/Parser.h"
#include "llvm/Support/SourceMgr.h"
#include <cassert>
using namespace llvm;
int main(){
 for(bool Dependent:{false,true}){
  LLVMContext C;SMDiagnostic E;
  std::string Text="define float @f(i1 %c,float %x) {\ne:\n %a=fadd float %x,1.0\n %m=select i1 %c,float %a,float %x\n %b=fmul float "+std::string(Dependent?"%m":"%x")+",2.0\n %r=fadd float %a,%b\n ret float %r\n}";
  auto M=parseAssemblyString(Text,E,C);assert(M);auto &F=*M->getFunction("f");
  auto It=F.front().begin();Instruction *A=&*It++;++It;Instruction *B=&*It;
  SmallVector<GapRange,2> Ranges{{A,A,true},{B,B,false}};
  DenseMap<Instruction*,bool> Choices;Choices[B]=true;
  bool Rejected=false;
  try{auto P=planGaps(F,Ranges,3,4,false,nullptr,4,&Choices);
      assert(!Dependent);assert(P.Speculated.size()==1&&P.Guards.size()==1);
  }catch(const std::runtime_error &Error){Rejected=std::string(Error.what())=="requested_gap_depends_on_protected_definition";}
  assert(Rejected==Dependent);
  Choices[A]=true;auto P=planGaps(F,Ranges,3,4,false,nullptr,4,&Choices);
  assert(P.Speculated.size()==2&&P.Guards.empty());
 }
 // Complementary adjacent runs use one guard, including a preexisting run.
 LLVMContext C;SMDiagnostic E;
 auto M=parseAssemblyString("define i32 @f(i32 %x) {e: %a=add i32 %x,1\n %b=mul i32 %x,2\n %d=sub i32 %x,3\n %r=add i32 %a,%d\n ret i32 %r\n}",E,C);assert(M);
 auto &F=*M->getFunction("f");auto I=F.front().begin();auto *A=&*I++;auto *B=&*I++;auto *D=&*I;
 SmallVector<GapRange,2> R{{A,B,true},{D,D,false}};
 auto P=planGaps(F,R,0,4,false);assert(P.Guards.size()==1&&P.Guards[0].Second.size()==1);
 // Planning is read-only and keeps a paired guard's instruction order intact.
 assert(A->getNextNode()==B&&B->getNextNode()==D);
 outs()<<"shared guard and transitive protected-definition dependency checks passed\n";
}
