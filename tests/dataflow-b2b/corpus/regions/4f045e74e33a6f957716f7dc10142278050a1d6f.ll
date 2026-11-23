; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, double %5, [2 x double]* %6) #0 {
  br i1 %0, label %8, label %14

8:                                                ; preds = %7
  %9 = fmul double %1, 2.000000e+00
  %10 = fadd double %2, %9
  %11 = fmul double %3, 3.000000e+00
  %12 = fsub double %10, %11
  %13 = fsub double %10, %3
  br label %20

14:                                               ; preds = %7
  %15 = fmul double %4, 2.000000e+00
  %16 = fsub double %5, %15
  %17 = fmul double %3, 3.000000e+00
  %18 = fadd double %16, %17
  %19 = fadd double %16, %3
  br label %20

20:                                               ; preds = %14, %8
  %21 = phi double [ %13, %8 ], [ %18, %14 ]
  %22 = phi double [ %12, %8 ], [ %19, %14 ]
  %23 = getelementptr inbounds [2 x double], [2 x double]* %6, i32 0, i32 0
  store double %21, double* %23, align 8
  %24 = getelementptr inbounds [2 x double], [2 x double]* %6, i32 0, i32 1
  store double %22, double* %24, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
