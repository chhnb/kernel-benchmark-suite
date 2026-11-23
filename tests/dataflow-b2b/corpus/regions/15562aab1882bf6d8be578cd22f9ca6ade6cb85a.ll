; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: convergent nofree nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, double %5, double %6, double %7, double %8, double %9, double %10, double %11, double %12, double %13, [15 x double]* %14) #0 {
  br i1 %0, label %16, label %17

16:                                               ; preds = %15
  br label %17

17:                                               ; preds = %16, %15
  %18 = phi double [ 1.000000e+00, %16 ], [ 1.000000e+00, %15 ]
  %19 = phi double [ 1.000000e+00, %16 ], [ 1.000000e+00, %15 ]
  %20 = phi double [ 1.000000e+00, %16 ], [ 1.000000e+00, %15 ]
  %21 = phi double [ %1, %16 ], [ %1, %15 ]
  %22 = phi double [ %2, %16 ], [ %2, %15 ]
  %23 = phi double [ %3, %16 ], [ %3, %15 ]
  %24 = phi double [ %4, %16 ], [ %4, %15 ]
  %25 = phi double [ %5, %16 ], [ %6, %15 ]
  %26 = phi double [ %7, %16 ], [ %7, %15 ]
  %27 = phi double [ %8, %16 ], [ %8, %15 ]
  %28 = phi double [ %9, %16 ], [ %9, %15 ]
  %29 = phi double [ %10, %16 ], [ %10, %15 ]
  %30 = phi double [ %11, %16 ], [ %11, %15 ]
  %31 = phi double [ %12, %16 ], [ %12, %15 ]
  %32 = phi double [ %13, %16 ], [ %13, %15 ]
  %33 = getelementptr inbounds [15 x double], [15 x double]* %14, i32 0, i32 0
  store double %18, double* %33, align 8
  %34 = getelementptr inbounds [15 x double], [15 x double]* %14, i32 0, i32 1
  store double %19, double* %34, align 8
  %35 = getelementptr inbounds [15 x double], [15 x double]* %14, i32 0, i32 2
  store double %20, double* %35, align 8
  %36 = getelementptr inbounds [15 x double], [15 x double]* %14, i32 0, i32 3
  store double %21, double* %36, align 8
  %37 = getelementptr inbounds [15 x double], [15 x double]* %14, i32 0, i32 4
  store double %22, double* %37, align 8
  %38 = getelementptr inbounds [15 x double], [15 x double]* %14, i32 0, i32 5
  store double %23, double* %38, align 8
  %39 = getelementptr inbounds [15 x double], [15 x double]* %14, i32 0, i32 6
  store double %24, double* %39, align 8
  %40 = getelementptr inbounds [15 x double], [15 x double]* %14, i32 0, i32 7
  store double %25, double* %40, align 8
  %41 = getelementptr inbounds [15 x double], [15 x double]* %14, i32 0, i32 8
  store double %26, double* %41, align 8
  %42 = getelementptr inbounds [15 x double], [15 x double]* %14, i32 0, i32 9
  store double %27, double* %42, align 8
  %43 = getelementptr inbounds [15 x double], [15 x double]* %14, i32 0, i32 10
  store double %28, double* %43, align 8
  %44 = getelementptr inbounds [15 x double], [15 x double]* %14, i32 0, i32 11
  store double %29, double* %44, align 8
  %45 = getelementptr inbounds [15 x double], [15 x double]* %14, i32 0, i32 12
  store double %30, double* %45, align 8
  %46 = getelementptr inbounds [15 x double], [15 x double]* %14, i32 0, i32 13
  store double %31, double* %46, align 8
  %47 = getelementptr inbounds [15 x double], [15 x double]* %14, i32 0, i32 14
  store double %32, double* %47, align 8
  ret void
}

attributes #0 = { convergent nofree nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
