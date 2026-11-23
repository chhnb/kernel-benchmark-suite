; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: nounwind willreturn
define void @region(i1 %0, double %1, double %2, double %3, [2 x double]* %4) #0 {
  br i1 %0, label %6, label %9

6:                                                ; preds = %5
  %7 = fdiv double %1, %2
  %8 = fdiv double %3, %2
  br label %9

9:                                                ; preds = %6, %5
  %10 = phi double [ %8, %6 ], [ 0.000000e+00, %5 ]
  %11 = phi double [ %7, %6 ], [ 0.000000e+00, %5 ]
  %12 = getelementptr inbounds [2 x double], [2 x double]* %4, i32 0, i32 0
  store double %10, double* %12, align 8
  %13 = getelementptr inbounds [2 x double], [2 x double]* %4, i32 0, i32 1
  store double %11, double* %13, align 8
  ret void
}

attributes #0 = { nounwind willreturn "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
