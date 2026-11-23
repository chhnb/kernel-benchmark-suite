; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

%0 = type { i64, %1, i64, i32, i32, i64, i64, %2, [2 x i32] }
%1 = type { i64 }
%2 = type { %3 addrspace(1)* }
%3 = type { %4, [4 x i32], i64, i32, i32, i32, i32, i64, i32, [9 x i32], i64, i32, i32, [4 x i32], i64, i64, i32, i32, [2 x i32], %1, [14 x i32] }
%4 = type { i32, i32, i8 addrspace(1)*, %1, i32, i32, i64 }

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, %0 addrspace(1)* %1, i64 addrspace(1)* %2) #0 {
  br i1 %0, label %10, label %4

4:                                                ; preds = %3
  %5 = getelementptr inbounds %0, %0 addrspace(1)* %1, i64 0, i32 3
  %6 = load i32, i32 addrspace(1)* %5, align 8, !tbaa !0
  %7 = zext i32 %6 to i64
  store atomic i64 %7, i64 addrspace(1)* %2 syncscope("one-as") release, align 8
  %8 = tail call i32 @llvm.amdgcn.readfirstlane(i32 %6) #2
  %9 = and i32 %8, 255
  tail call void @llvm.amdgcn.s.sendmsg(i32 1, i32 %9) #2
  br label %10

10:                                               ; preds = %4, %3
  ret void
}

; Function Attrs: convergent nounwind readnone willreturn
declare i32 @llvm.amdgcn.readfirstlane(i32) #1

; Function Attrs: nounwind
declare void @llvm.amdgcn.s.sendmsg(i32 immarg, i32) #2

attributes #0 = { convergent norecurse nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { convergent nounwind readnone willreturn }
attributes #2 = { nounwind }

!0 = !{!1, !5, i64 24}
!1 = !{!"amd_signal_s", !2, i64 0, !3, i64 8, !2, i64 16, !5, i64 24, !5, i64 28, !2, i64 32, !2, i64 40, !3, i64 48, !3, i64 56}
!2 = !{!"long", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!"int", !3, i64 0}
