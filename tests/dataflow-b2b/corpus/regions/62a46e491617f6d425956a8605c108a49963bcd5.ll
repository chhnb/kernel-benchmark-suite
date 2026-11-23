; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: convergent norecurse nounwind
define double @region(i1 %0, i32 %1, i32 %2, double %3) #0 {
  br i1 %0, label %5, label %10

5:                                                ; preds = %4
  %6 = icmp slt i32 %1, 0
  %7 = or i32 %2, 2146435072
  %8 = select i1 %6, i32 %7, i32 %2
  %9 = tail call double @llvm.nvvm.lohi.i2d(i32 0, i32 %8) #2
  br label %10

10:                                               ; preds = %5, %4
  %11 = phi double [ %9, %5 ], [ %3, %4 ]
  ret double %11
}

; Function Attrs: nounwind readnone
declare double @llvm.nvvm.lohi.i2d(i32, i32) #1

attributes #0 = { convergent norecurse nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { nounwind }
