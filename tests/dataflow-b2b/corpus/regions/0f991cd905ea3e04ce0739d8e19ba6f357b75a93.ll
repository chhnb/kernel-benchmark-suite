; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: convergent norecurse nounwind
define double @region(i1 %0, i1 %1, i1 %2, i32 %3, i32 %4, double %5) #0 {
  br i1 %0, label %7, label %11

7:                                                ; preds = %6
  %8 = and i1 %1, %2
  %9 = select i1 %8, i32 %3, i32 %4
  %10 = tail call double @llvm.nvvm.lohi.i2d(i32 0, i32 %9) #2
  br label %11

11:                                               ; preds = %7, %6
  %12 = phi double [ %10, %7 ], [ %5, %6 ]
  ret double %12
}

; Function Attrs: nounwind readnone
declare double @llvm.nvvm.lohi.i2d(i32, i32) #1

attributes #0 = { convergent norecurse nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { nounwind }
