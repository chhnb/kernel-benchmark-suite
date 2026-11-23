; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: convergent nofree nounwind
define double @region(i1 %0, double %1, double %2, double %3, double %4, double %5, double %6) #0 {
  br i1 %0, label %8, label %11

8:                                                ; preds = %7
  %9 = fmul double %1, %2
  %10 = fmul double %3, %9
  br label %17

11:                                               ; preds = %7
  %12 = fneg double %3
  %13 = fmul double %12, %4
  %14 = fmul double %13, %1
  %15 = fmul double %14, %5
  %16 = fdiv double %15, %6
  br label %17

17:                                               ; preds = %11, %8
  %18 = phi double [ %10, %8 ], [ %16, %11 ]
  ret double %18
}

attributes #0 = { convergent nofree nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
