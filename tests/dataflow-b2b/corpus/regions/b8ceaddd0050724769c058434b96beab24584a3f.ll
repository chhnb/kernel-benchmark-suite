; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: convergent nofree nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, [5 x double]* %5) #0 {
  br i1 %0, label %7, label %16

7:                                                ; preds = %6
  %8 = fdiv double %1, %2
  %9 = fdiv double %3, %2
  %10 = fmul double %4, 5.000000e-01
  %11 = fmul double %10, %2
  %12 = fmul double %2, %11
  %13 = fmul double %1, %1
  %14 = fdiv double %13, %2
  %15 = fadd double %12, %14
  br label %16

16:                                               ; preds = %7, %6
  %17 = phi double [ %9, %7 ], [ 0.000000e+00, %6 ]
  %18 = phi double [ %15, %7 ], [ 0.000000e+00, %6 ]
  %19 = phi double [ %8, %7 ], [ 0.000000e+00, %6 ]
  %20 = phi double [ %1, %7 ], [ 0.000000e+00, %6 ]
  %21 = phi double [ %2, %7 ], [ 0.000000e+00, %6 ]
  %22 = getelementptr inbounds [5 x double], [5 x double]* %5, i32 0, i32 0
  store double %17, double* %22, align 8
  %23 = getelementptr inbounds [5 x double], [5 x double]* %5, i32 0, i32 1
  store double %18, double* %23, align 8
  %24 = getelementptr inbounds [5 x double], [5 x double]* %5, i32 0, i32 2
  store double %19, double* %24, align 8
  %25 = getelementptr inbounds [5 x double], [5 x double]* %5, i32 0, i32 3
  store double %20, double* %25, align 8
  %26 = getelementptr inbounds [5 x double], [5 x double]* %5, i32 0, i32 4
  store double %21, double* %26, align 8
  ret void
}

attributes #0 = { convergent nofree nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
