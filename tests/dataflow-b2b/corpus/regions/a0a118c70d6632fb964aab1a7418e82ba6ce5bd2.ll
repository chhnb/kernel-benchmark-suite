; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: convergent norecurse nounwind
define double @region(i1 %0, double %1, double %2, double %3, double %4, double %5) #0 {
  br i1 %0, label %12, label %7

7:                                                ; preds = %6
  %8 = tail call double @llvm.minnum.f64(double %1, double %2) #2
  %9 = fmul double %3, %4
  %10 = fdiv double %9, %5
  %11 = tail call double @llvm.maxnum.f64(double %8, double %10) #2
  br label %12

12:                                               ; preds = %7, %6
  %13 = phi double [ %1, %6 ], [ %11, %7 ]
  ret double %13
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.minnum.f64(double, double) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.maxnum.f64(double, double) #1

attributes #0 = { convergent norecurse nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { nounwind }
