; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

%"struct.GC::Vector2" = type { double, double }

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double* %1, i64 %2, %"struct.GC::Vector2"* %3, %"struct.GC::Vector2"* %4, %"struct.GC::Vector2"* %5, double* %6, double* %7, double* %8, double* %9, double %10, { double, double, %"struct.GC::Vector2"*, double*, double*, double }* %11) #0 {
  br i1 %0, label %20, label %13

13:                                               ; preds = %12
  %14 = getelementptr inbounds double, double* %1, i64 %2
  %15 = load double, double* %14, align 8, !tbaa !0
  %16 = getelementptr inbounds %"struct.GC::Vector2", %"struct.GC::Vector2"* %3, i64 %2, i32 0
  %17 = load double, double* %16, align 8, !tbaa.struct !4
  %18 = getelementptr inbounds %"struct.GC::Vector2", %"struct.GC::Vector2"* %3, i64 %2, i32 1
  %19 = load double, double* %18, align 8, !tbaa.struct !5
  br label %20

20:                                               ; preds = %13, %12
  %21 = phi double [ 0.000000e+00, %12 ], [ %17, %13 ]
  %22 = phi double [ 0.000000e+00, %12 ], [ %19, %13 ]
  %23 = phi %"struct.GC::Vector2"* [ %4, %12 ], [ %5, %13 ]
  %24 = phi double* [ %6, %12 ], [ %7, %13 ]
  %25 = phi double* [ %8, %12 ], [ %9, %13 ]
  %26 = phi double [ %10, %12 ], [ %15, %13 ]
  %27 = getelementptr inbounds { double, double, %"struct.GC::Vector2"*, double*, double*, double }, { double, double, %"struct.GC::Vector2"*, double*, double*, double }* %11, i32 0, i32 0
  store double %21, double* %27, align 8
  %28 = getelementptr inbounds { double, double, %"struct.GC::Vector2"*, double*, double*, double }, { double, double, %"struct.GC::Vector2"*, double*, double*, double }* %11, i32 0, i32 1
  store double %22, double* %28, align 8
  %29 = getelementptr inbounds { double, double, %"struct.GC::Vector2"*, double*, double*, double }, { double, double, %"struct.GC::Vector2"*, double*, double*, double }* %11, i32 0, i32 2
  store %"struct.GC::Vector2"* %23, %"struct.GC::Vector2"** %29, align 8
  %30 = getelementptr inbounds { double, double, %"struct.GC::Vector2"*, double*, double*, double }, { double, double, %"struct.GC::Vector2"*, double*, double*, double }* %11, i32 0, i32 3
  store double* %24, double** %30, align 8
  %31 = getelementptr inbounds { double, double, %"struct.GC::Vector2"*, double*, double*, double }, { double, double, %"struct.GC::Vector2"*, double*, double*, double }* %11, i32 0, i32 4
  store double* %25, double** %31, align 8
  %32 = getelementptr inbounds { double, double, %"struct.GC::Vector2"*, double*, double*, double }, { double, double, %"struct.GC::Vector2"*, double*, double*, double }* %11, i32 0, i32 5
  store double %26, double* %32, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
!4 = !{i64 0, i64 8, !0, i64 8, i64 8, !0}
!5 = !{i64 0, i64 8, !0}
