; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: noinline nounwind willreturn
define void @region(i1 %0, double %1, i32 %2, i32 %3, i32 %4, [3 x i32]* %5) #0 {
  br i1 %0, label %7, label %12

7:                                                ; preds = %6
  %8 = tail call i32 @llvm.nvvm.d2i.hi(double %1) #2
  %9 = tail call i32 @llvm.nvvm.d2i.lo(double %1) #2
  %10 = lshr i32 %8, 20
  %11 = add nsw i32 %10, -54
  br label %12

12:                                               ; preds = %7, %6
  %13 = phi i32 [ %9, %7 ], [ %2, %6 ]
  %14 = phi i32 [ %8, %7 ], [ %3, %6 ]
  %15 = phi i32 [ %11, %7 ], [ %4, %6 ]
  %16 = getelementptr inbounds [3 x i32], [3 x i32]* %5, i32 0, i32 0
  store i32 %13, i32* %16, align 4
  %17 = getelementptr inbounds [3 x i32], [3 x i32]* %5, i32 0, i32 1
  store i32 %14, i32* %17, align 4
  %18 = getelementptr inbounds [3 x i32], [3 x i32]* %5, i32 0, i32 2
  store i32 %15, i32* %18, align 4
  ret void
}

; Function Attrs: nounwind readnone
declare i32 @llvm.nvvm.d2i.hi(double) #1

; Function Attrs: nounwind readnone
declare i32 @llvm.nvvm.d2i.lo(double) #1

attributes #0 = { noinline nounwind willreturn "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { nounwind }
