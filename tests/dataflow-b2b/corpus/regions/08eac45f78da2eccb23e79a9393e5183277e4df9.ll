; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: nounwind readonly willreturn
define double @region(i1 %0, i32 %1, i1 %2, i32 %3, double %4) #0 {
  br i1 %0, label %6, label %12

6:                                                ; preds = %5
  %7 = icmp ne i32 %1, 1071644672
  %8 = and i1 %7, %2
  %9 = or i32 %3, -2147483648
  %10 = select i1 %8, i32 %9, i32 %3
  %11 = tail call double @llvm.nvvm.lohi.i2d(i32 0, i32 %10) #2
  br label %12

12:                                               ; preds = %6, %5
  %13 = phi double [ %11, %6 ], [ %4, %5 ]
  ret double %13
}

; Function Attrs: nounwind readnone
declare double @llvm.nvvm.lohi.i2d(i32, i32) #1

attributes #0 = { nounwind readonly willreturn "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { nounwind }
