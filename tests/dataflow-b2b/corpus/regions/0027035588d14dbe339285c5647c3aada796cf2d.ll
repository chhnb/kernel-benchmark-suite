; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: convergent norecurse nounwind
define double @region(i1 %0, double %1, double %2, double %3, double %4, double %5, double %6) #0 {
  br i1 %0, label %8, label %11

8:                                                ; preds = %7
  %9 = fmul double %1, 2.000000e+00
  %10 = fsub double %2, %9
  br label %15

11:                                               ; preds = %7
  %12 = fsub double %3, %4
  %13 = fsub double %5, %6
  %14 = call double @llvm.minnum.f64(double %12, double %13) #2
  br label %15

15:                                               ; preds = %11, %8
  %16 = phi double [ %10, %8 ], [ %14, %11 ]
  ret double %16
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.minnum.f64(double, double) #1

attributes #0 = { convergent norecurse nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { nounwind }
