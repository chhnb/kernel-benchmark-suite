; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: convergent nofree nounwind
define void @region(i1 %0, double %1, double %2, double %3, [3 x double]* %4) #0 {
  br i1 %0, label %13, label %6

6:                                                ; preds = %5
  %7 = fmul double %1, 5.000000e-01
  %8 = fadd double %7, 0.000000e+00
  %9 = fmul double %2, 5.000000e-01
  %10 = fadd double %9, 0.000000e+00
  %11 = fmul double %3, 5.000000e-01
  %12 = fadd double %11, 0.000000e+00
  br label %13

13:                                               ; preds = %6, %5
  %14 = phi double [ 0.000000e+00, %5 ], [ %12, %6 ]
  %15 = phi double [ 0.000000e+00, %5 ], [ %10, %6 ]
  %16 = phi double [ 0.000000e+00, %5 ], [ %8, %6 ]
  %17 = getelementptr inbounds [3 x double], [3 x double]* %4, i32 0, i32 0
  store double %14, double* %17, align 8
  %18 = getelementptr inbounds [3 x double], [3 x double]* %4, i32 0, i32 1
  store double %15, double* %18, align 8
  %19 = getelementptr inbounds [3 x double], [3 x double]* %4, i32 0, i32 2
  store double %16, double* %19, align 8
  ret void
}

attributes #0 = { convergent nofree nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
