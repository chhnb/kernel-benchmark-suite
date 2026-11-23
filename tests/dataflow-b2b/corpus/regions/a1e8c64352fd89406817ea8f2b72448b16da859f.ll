; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, [2 x double]* %5) #0 {
  br i1 %0, label %7, label %10

7:                                                ; preds = %6
  %8 = fsub double %1, %2
  %9 = fsub double %1, %3
  br label %10

10:                                               ; preds = %7, %6
  %11 = phi double [ %9, %7 ], [ %4, %6 ]
  %12 = phi double [ %8, %7 ], [ %1, %6 ]
  %13 = getelementptr inbounds [2 x double], [2 x double]* %5, i32 0, i32 0
  store double %11, double* %13, align 8
  %14 = getelementptr inbounds [2 x double], [2 x double]* %5, i32 0, i32 1
  store double %12, double* %14, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
