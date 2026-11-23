; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: nounwind readonly willreturn
define double @region(i1 %0, double %1) #0 {
  br i1 %0, label %3, label %8

3:                                                ; preds = %2
  %4 = tail call i32 @llvm.nvvm.d2i.hi(double %1) #2
  %5 = tail call i32 @llvm.nvvm.d2i.lo(double %1) #2
  %6 = xor i32 %4, -2147483648
  %7 = tail call double @llvm.nvvm.lohi.i2d(i32 %5, i32 %6) #2
  br label %8

8:                                                ; preds = %3, %2
  %9 = phi double [ %7, %3 ], [ %1, %2 ]
  ret double %9
}

; Function Attrs: nounwind readnone
declare i32 @llvm.nvvm.d2i.hi(double) #1

; Function Attrs: nounwind readnone
declare i32 @llvm.nvvm.d2i.lo(double) #1

; Function Attrs: nounwind readnone
declare double @llvm.nvvm.lohi.i2d(i32, i32) #1

attributes #0 = { nounwind readonly willreturn "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { nounwind }
