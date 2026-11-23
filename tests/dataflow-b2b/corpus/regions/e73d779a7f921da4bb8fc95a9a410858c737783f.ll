; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

%"struct.GC::Vector2.50.53" = type { double, double }

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, %"struct.GC::Vector2.50.53"* %1, i64 %2, double %3, [2 x double]* %4) #0 {
  br i1 %0, label %13, label %6

6:                                                ; preds = %5
  %7 = getelementptr inbounds %"struct.GC::Vector2.50.53", %"struct.GC::Vector2.50.53"* %1, i64 %2, i32 1
  %8 = getelementptr inbounds %"struct.GC::Vector2.50.53", %"struct.GC::Vector2.50.53"* %1, i64 %2, i32 0
  %9 = load double, double* %7, align 8, !tbaa.struct !0
  %10 = load double, double* %8, align 8, !tbaa.struct !5
  %11 = fdiv double %10, %3
  %12 = fdiv double %9, %3
  br label %13

13:                                               ; preds = %6, %5
  %14 = phi double [ 0.000000e+00, %5 ], [ %11, %6 ]
  %15 = phi double [ 0.000000e+00, %5 ], [ %12, %6 ]
  %16 = getelementptr inbounds [2 x double], [2 x double]* %4, i32 0, i32 0
  store double %14, double* %16, align 8
  %17 = getelementptr inbounds [2 x double], [2 x double]* %4, i32 0, i32 1
  store double %15, double* %17, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{i64 0, i64 8, !1}
!1 = !{!2, !2, i64 0}
!2 = !{!"double", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
!5 = !{i64 0, i64 8, !1, i64 8, i64 8, !1}
