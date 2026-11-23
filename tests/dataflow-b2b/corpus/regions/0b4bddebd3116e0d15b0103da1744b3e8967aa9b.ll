; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, double %5, double %6, [3 x double]* %7) #0 {
  br i1 %0, label %16, label %9

9:                                                ; preds = %8
  %10 = fmul double %1, 5.000000e-01
  %11 = fadd double %10, %2
  %12 = fmul double %3, 5.000000e-01
  %13 = fadd double %12, %4
  %14 = fmul double %5, 5.000000e-01
  %15 = fadd double %14, %6
  br label %16

16:                                               ; preds = %9, %8
  %17 = phi double [ %6, %8 ], [ %15, %9 ]
  %18 = phi double [ %4, %8 ], [ %13, %9 ]
  %19 = phi double [ %2, %8 ], [ %11, %9 ]
  %20 = getelementptr inbounds [3 x double], [3 x double]* %7, i32 0, i32 0
  store double %17, double* %20, align 8
  %21 = getelementptr inbounds [3 x double], [3 x double]* %7, i32 0, i32 1
  store double %18, double* %21, align 8
  %22 = getelementptr inbounds [3 x double], [3 x double]* %7, i32 0, i32 2
  store double %19, double* %22, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
