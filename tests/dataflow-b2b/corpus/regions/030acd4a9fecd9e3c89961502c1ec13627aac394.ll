; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: nofree nounwind writeonly
define double @region(i1 %0, i32 %1, double %2) #0 {
  br i1 %0, label %4, label %6

4:                                                ; preds = %3
  %5 = tail call double @llvm.nvvm.lohi.i2d(i32 0, i32 %1) #2
  br label %6

6:                                                ; preds = %4, %3
  %7 = phi double [ %5, %4 ], [ %2, %3 ]
  ret double %7
}

; Function Attrs: nounwind readnone
declare double @llvm.nvvm.lohi.i2d(i32, i32) #1

attributes #0 = { nofree nounwind writeonly "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { nounwind }
