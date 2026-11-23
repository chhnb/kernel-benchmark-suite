; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: convergent nofree nounwind
define double @region(i1 %0, double %1, double %2, double %3, double %4) #0 {
  br i1 %0, label %6, label %8

6:                                                ; preds = %5
  %7 = fneg double %1
  br label %12

8:                                                ; preds = %5
  %9 = fmul double %1, %2
  %10 = fmul double %3, %9
  %11 = fdiv double %10, %4
  br label %12

12:                                               ; preds = %8, %6
  %13 = phi double [ %7, %6 ], [ %11, %8 ]
  ret double %13
}

attributes #0 = { convergent nofree nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
