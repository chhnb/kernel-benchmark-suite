; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: nofree nounwind writeonly
define double @region(i1 %0, i32 %1, i1 %2, double %3) #0 {
  br i1 %0, label %5, label %9

5:                                                ; preds = %4
  %6 = or i32 %1, 2146435072
  %7 = select i1 %2, i32 %6, i32 %1
  %8 = tail call double @llvm.nvvm.lohi.i2d(i32 0, i32 %7) #2
  br label %9

9:                                                ; preds = %5, %4
  %10 = phi double [ %8, %5 ], [ %3, %4 ]
  ret double %10
}

; Function Attrs: nounwind readnone
declare double @llvm.nvvm.lohi.i2d(i32, i32) #1

attributes #0 = { nofree nounwind writeonly "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { nounwind }
