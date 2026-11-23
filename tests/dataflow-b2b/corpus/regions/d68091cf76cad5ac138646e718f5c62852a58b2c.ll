; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

%0 = type { i64, i64, i32, i32 }

; Function Attrs: convergent nofree norecurse nounwind
define void @region(i1 %0, %0 addrspace(1)* %1, i32 %2, i64 %3) #0 {
  br i1 %0, label %5, label %9

5:                                                ; preds = %4
  %6 = getelementptr inbounds %0, %0 addrspace(1)* %1, i64 0, i32 2
  %7 = getelementptr inbounds %0, %0 addrspace(1)* %1, i64 0, i32 1
  %8 = getelementptr inbounds %0, %0 addrspace(1)* %1, i64 0, i32 3
  store i32 %2, i32 addrspace(1)* %6, align 8, !tbaa !0
  store i64 %3, i64 addrspace(1)* %7, align 8, !tbaa !6
  store i32 1, i32 addrspace(1)* %8, align 4, !tbaa !7
  br label %9

9:                                                ; preds = %5, %4
  ret void
}

attributes #0 = { convergent nofree norecurse nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !5, i64 16}
!1 = !{!"", !2, i64 0, !2, i64 8, !5, i64 16, !5, i64 20}
!2 = !{!"long", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!"int", !3, i64 0}
!6 = !{!1, !2, i64 8}
!7 = !{!1, !5, i64 20}
