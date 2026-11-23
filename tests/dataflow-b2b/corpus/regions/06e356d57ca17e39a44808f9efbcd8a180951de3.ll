; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, double %5, double %6, double %7, [5 x double]* %8) #0 {
  br i1 %0, label %10, label %23

10:                                               ; preds = %9
  %11 = fmul double %1, %2
  %12 = fmul double %3, %4
  %13 = fadd double %11, %12
  %14 = fmul double %5, %13
  %15 = fdiv double %6, %5
  %16 = fdiv double %14, %5
  %17 = fmul double %7, 5.000000e-01
  %18 = fmul double %5, %17
  %19 = fmul double %5, %18
  %20 = fmul double %6, %6
  %21 = fdiv double %20, %5
  %22 = fadd double %19, %21
  br label %23

23:                                               ; preds = %10, %9
  %24 = phi double [ %16, %10 ], [ 0.000000e+00, %9 ]
  %25 = phi double [ %22, %10 ], [ 0.000000e+00, %9 ]
  %26 = phi double [ %15, %10 ], [ 0.000000e+00, %9 ]
  %27 = phi double [ %6, %10 ], [ 0.000000e+00, %9 ]
  %28 = phi double [ %5, %10 ], [ 0.000000e+00, %9 ]
  %29 = getelementptr inbounds [5 x double], [5 x double]* %8, i32 0, i32 0
  store double %24, double* %29, align 8
  %30 = getelementptr inbounds [5 x double], [5 x double]* %8, i32 0, i32 1
  store double %25, double* %30, align 8
  %31 = getelementptr inbounds [5 x double], [5 x double]* %8, i32 0, i32 2
  store double %26, double* %31, align 8
  %32 = getelementptr inbounds [5 x double], [5 x double]* %8, i32 0, i32 3
  store double %27, double* %32, align 8
  %33 = getelementptr inbounds [5 x double], [5 x double]* %8, i32 0, i32 4
  store double %28, double* %33, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
