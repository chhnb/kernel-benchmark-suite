; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: nofree nounwind writeonly
define void @region(i1 %0, double %1, double %2, double %3, double %4, double %5, double %6, double %7, [3 x double]* %8) #0 {
  br i1 %0, label %10, label %18

10:                                               ; preds = %9
  %11 = fmul double %1, %2
  %12 = tail call double @llvm.sqrt.f64(double %11) #2
  %13 = fmul double %12, 2.000000e+00
  %14 = fadd double %13, %3
  %15 = fmul double %4, 3.000000e+00
  %16 = fsub double %14, %15
  %17 = fsub double %14, %4
  br label %26

18:                                               ; preds = %9
  %19 = fmul double %5, %2
  %20 = tail call double @llvm.sqrt.f64(double %19) #2
  %21 = fmul double %20, 2.000000e+00
  %22 = fsub double %6, %21
  %23 = fmul double %4, 3.000000e+00
  %24 = fadd double %22, %23
  %25 = fadd double %22, %4
  br label %26

26:                                               ; preds = %18, %10
  %27 = phi double [ %17, %10 ], [ %24, %18 ]
  %28 = phi double [ %16, %10 ], [ %25, %18 ]
  %29 = phi double [ %7, %10 ], [ %7, %18 ]
  %30 = getelementptr inbounds [3 x double], [3 x double]* %8, i32 0, i32 0
  store double %27, double* %30, align 8
  %31 = getelementptr inbounds [3 x double], [3 x double]* %8, i32 0, i32 1
  store double %28, double* %31, align 8
  %32 = getelementptr inbounds [3 x double], [3 x double]* %8, i32 0, i32 2
  store double %29, double* %32, align 8
  ret void
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.sqrt.f64(double) #1

attributes #0 = { nofree nounwind writeonly "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { nounwind }
