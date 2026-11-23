; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: inlinehint nounwind
define void @region(i1 %0, i32 %1, i32* %2, i32 %3, i32* %4, i32 %5, i32* %6, i32 %7, { i1, i32 }* %8) #0 {
  br i1 %0, label %10, label %11

10:                                               ; preds = %9
  store i32 %1, i32* %2, align 4, !tbaa !0
  store i32 %3, i32* %4, align 4, !tbaa !0
  store i32 %5, i32* %6, align 4, !tbaa !0
  br label %11

11:                                               ; preds = %10, %9
  %12 = phi i1 [ true, %10 ], [ false, %9 ]
  %13 = phi i32 [ %7, %10 ], [ 5, %9 ]
  %14 = getelementptr inbounds { i1, i32 }, { i1, i32 }* %8, i32 0, i32 0
  store i1 %12, i1* %14, align 1
  %15 = getelementptr inbounds { i1, i32 }, { i1, i32 }* %8, i32 0, i32 1
  store i32 %13, i32* %15, align 4
  ret void
}

attributes #0 = { inlinehint nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
