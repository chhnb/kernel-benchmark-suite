; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: noinline nounwind readnone willreturn
define double @region(i1 %0, i32 %1, i32 %2, i32 %3, double %4) #0 {
  br i1 %0, label %6, label %16

6:                                                ; preds = %5
  %7 = sdiv i32 %1, 2
  %8 = shl i32 %7, 20
  %9 = add i32 %2, %8
  %10 = tail call double @llvm.nvvm.lohi.i2d(i32 %3, i32 %9) #2
  %11 = sub nsw i32 %1, %7
  %12 = shl i32 %11, 20
  %13 = add nsw i32 %12, 1072693248
  %14 = tail call double @llvm.nvvm.lohi.i2d(i32 0, i32 %13) #2
  %15 = fmul double %10, %14
  br label %16

16:                                               ; preds = %6, %5
  %17 = phi double [ %15, %6 ], [ %4, %5 ]
  ret double %17
}

; Function Attrs: nounwind readnone
declare double @llvm.nvvm.lohi.i2d(i32, i32) #1

attributes #0 = { noinline nounwind readnone willreturn "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { nounwind }
