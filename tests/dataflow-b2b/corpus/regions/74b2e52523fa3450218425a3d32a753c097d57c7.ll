; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

%"struct.GC::Vector2" = type { double, double }

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double* %1, i64 %2, double* %3, double* %4, double* %5, double* %6, %"struct.GC::Vector2"* %7, %"struct.GC::Vector2"* %8, double %9, { double*, double*, %"struct.GC::Vector2"*, double }* %10) #0 {
  br i1 %0, label %15, label %12

12:                                               ; preds = %11
  %13 = getelementptr inbounds double, double* %1, i64 %2
  %14 = load double, double* %13, align 8, !tbaa !0
  br label %15

15:                                               ; preds = %12, %11
  %16 = phi double* [ %3, %11 ], [ %4, %12 ]
  %17 = phi double* [ %5, %11 ], [ %6, %12 ]
  %18 = phi %"struct.GC::Vector2"* [ %7, %11 ], [ %8, %12 ]
  %19 = phi double [ %9, %11 ], [ %14, %12 ]
  %20 = getelementptr inbounds { double*, double*, %"struct.GC::Vector2"*, double }, { double*, double*, %"struct.GC::Vector2"*, double }* %10, i32 0, i32 0
  store double* %16, double** %20, align 8
  %21 = getelementptr inbounds { double*, double*, %"struct.GC::Vector2"*, double }, { double*, double*, %"struct.GC::Vector2"*, double }* %10, i32 0, i32 1
  store double* %17, double** %21, align 8
  %22 = getelementptr inbounds { double*, double*, %"struct.GC::Vector2"*, double }, { double*, double*, %"struct.GC::Vector2"*, double }* %10, i32 0, i32 2
  store %"struct.GC::Vector2"* %18, %"struct.GC::Vector2"** %22, align 8
  %23 = getelementptr inbounds { double*, double*, %"struct.GC::Vector2"*, double }, { double*, double*, %"struct.GC::Vector2"*, double }* %10, i32 0, i32 3
  store double %19, double* %23, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
