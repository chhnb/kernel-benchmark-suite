; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: convergent nofree nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, double %5, double %6, [3 x double]* %7) #0 {
  br i1 %0, label %16, label %9

9:                                                ; preds = %8
  %10 = fmul double %1, 5.000000e-01
  %11 = fmul double %2, 5.000000e-01
  %12 = fmul double %3, 5.000000e-01
  %13 = fadd double %4, %10
  %14 = fadd double %5, %11
  %15 = fadd double %6, %12
  br label %16

16:                                               ; preds = %9, %8
  %17 = phi double [ %6, %8 ], [ %15, %9 ]
  %18 = phi double [ %5, %8 ], [ %14, %9 ]
  %19 = phi double [ %4, %8 ], [ %13, %9 ]
  %20 = getelementptr inbounds [3 x double], [3 x double]* %7, i32 0, i32 0
  store double %17, double* %20, align 8
  %21 = getelementptr inbounds [3 x double], [3 x double]* %7, i32 0, i32 1
  store double %18, double* %21, align 8
  %22 = getelementptr inbounds [3 x double], [3 x double]* %7, i32 0, i32 2
  store double %19, double* %22, align 8
  ret void
}

attributes #0 = { convergent nofree nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
