; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: noinline nounwind willreturn
define void @region(i1 %0, i32 %1, double %2, i32 %3, { double, i32 }* %4) #0 {
  br i1 %0, label %6, label %12

6:                                                ; preds = %5
  %7 = add nsw i32 %1, -1022
  %8 = tail call i32 @llvm.nvvm.d2i.lo(double %2) #2
  %9 = tail call i32 @llvm.nvvm.d2i.hi(double %2) #2
  %10 = add i32 %9, -1048576
  %11 = tail call double @llvm.nvvm.lohi.i2d(i32 %8, i32 %10) #2
  br label %12

12:                                               ; preds = %6, %5
  %13 = phi double [ %11, %6 ], [ %2, %5 ]
  %14 = phi i32 [ %7, %6 ], [ %3, %5 ]
  %15 = getelementptr inbounds { double, i32 }, { double, i32 }* %4, i32 0, i32 0
  store double %13, double* %15, align 8
  %16 = getelementptr inbounds { double, i32 }, { double, i32 }* %4, i32 0, i32 1
  store i32 %14, i32* %16, align 4
  ret void
}

; Function Attrs: nounwind readnone
declare i32 @llvm.nvvm.d2i.lo(double) #1

; Function Attrs: nounwind readnone
declare i32 @llvm.nvvm.d2i.hi(double) #1

; Function Attrs: nounwind readnone
declare double @llvm.nvvm.lohi.i2d(i32, i32) #1

attributes #0 = { noinline nounwind willreturn "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { nounwind }
