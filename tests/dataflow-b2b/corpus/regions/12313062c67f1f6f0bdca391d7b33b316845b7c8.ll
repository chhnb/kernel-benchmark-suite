; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, double %5, double %6, [3 x double]* %7) #0 {
  br i1 %0, label %10, label %9

9:                                                ; preds = %8
  br label %10

10:                                               ; preds = %9, %8
  %11 = phi double [ %1, %8 ], [ %2, %9 ]
  %12 = phi double [ %3, %8 ], [ %4, %9 ]
  %13 = phi double [ %5, %8 ], [ %6, %9 ]
  %14 = getelementptr inbounds [3 x double], [3 x double]* %7, i32 0, i32 0
  store double %11, double* %14, align 8
  %15 = getelementptr inbounds [3 x double], [3 x double]* %7, i32 0, i32 1
  store double %12, double* %15, align 8
  %16 = getelementptr inbounds [3 x double], [3 x double]* %7, i32 0, i32 2
  store double %13, double* %16, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
