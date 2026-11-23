; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

%"class.GC::fv::RiemannState.0" = type { %"struct.GC::Vector3", %"struct.GC::Vector3" }
%"struct.GC::Vector3" = type { double, double, double }

; Function Attrs: convergent nofree nounwind
define void @region(i1 %0, %"class.GC::fv::RiemannState.0"* %1, double %2, double %3, double %4, [5 x double]* %5) #0 {
  br i1 %0, label %7, label %18

7:                                                ; preds = %6
  %8 = getelementptr inbounds %"class.GC::fv::RiemannState.0", %"class.GC::fv::RiemannState.0"* %1, i64 0, i32 1, i32 1
  %9 = load double, double* %8, align 8, !tbaa !0
  %10 = fdiv double %2, %3
  %11 = fdiv double %9, %3
  %12 = fmul double %4, 5.000000e-01
  %13 = fmul double %12, %3
  %14 = fmul double %3, %13
  %15 = fmul double %2, %2
  %16 = fdiv double %15, %3
  %17 = fadd double %14, %16
  br label %18

18:                                               ; preds = %7, %6
  %19 = phi double [ %11, %7 ], [ 0.000000e+00, %6 ]
  %20 = phi double [ %17, %7 ], [ 0.000000e+00, %6 ]
  %21 = phi double [ %10, %7 ], [ 0.000000e+00, %6 ]
  %22 = phi double [ %2, %7 ], [ 0.000000e+00, %6 ]
  %23 = phi double [ %3, %7 ], [ 0.000000e+00, %6 ]
  %24 = getelementptr inbounds [5 x double], [5 x double]* %5, i32 0, i32 0
  store double %19, double* %24, align 8
  %25 = getelementptr inbounds [5 x double], [5 x double]* %5, i32 0, i32 1
  store double %20, double* %25, align 8
  %26 = getelementptr inbounds [5 x double], [5 x double]* %5, i32 0, i32 2
  store double %21, double* %26, align 8
  %27 = getelementptr inbounds [5 x double], [5 x double]* %5, i32 0, i32 3
  store double %22, double* %27, align 8
  %28 = getelementptr inbounds [5 x double], [5 x double]* %5, i32 0, i32 4
  store double %23, double* %28, align 8
  ret void
}

attributes #0 = { convergent nofree nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !3, i64 32}
!1 = !{!"_ZTSN2GC2fv12RiemannStateINS_7Vector3EEE", !2, i64 0, !2, i64 24}
!2 = !{!"_ZTSN2GC7Vector3E", !3, i64 0, !3, i64 8, !3, i64 16}
!3 = !{!"double", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
