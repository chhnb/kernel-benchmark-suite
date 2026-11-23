; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree norecurse nounwind willreturn
define void @region(i1 %0, double %1, double %2, double %3, double %4, double %5, double %6, double %7, double %8, double %9, double %10, double %11, double %12, [10 x double]* %13) #0 {
  br i1 %0, label %15, label %20

15:                                               ; preds = %14
  %16 = fsub double %1, %2
  %17 = fmul double %3, %2
  %18 = fsub double %4, %17
  %19 = fmul double %5, %16
  br label %20

20:                                               ; preds = %15, %14
  %21 = phi double [ %6, %15 ], [ %7, %14 ]
  %22 = phi double [ %1, %15 ], [ %8, %14 ]
  %23 = phi double [ %16, %15 ], [ %9, %14 ]
  %24 = phi double [ %10, %15 ], [ %11, %14 ]
  %25 = phi double [ %5, %15 ], [ %12, %14 ]
  %26 = phi double [ %16, %15 ], [ %12, %14 ]
  %27 = phi double [ %5, %15 ], [ %8, %14 ]
  %28 = phi double [ %19, %15 ], [ %9, %14 ]
  %29 = phi double [ %18, %15 ], [ %12, %14 ]
  %30 = phi double [ %16, %15 ], [ undef, %14 ]
  %31 = getelementptr inbounds [10 x double], [10 x double]* %13, i32 0, i32 0
  store double %21, double* %31, align 8
  %32 = getelementptr inbounds [10 x double], [10 x double]* %13, i32 0, i32 1
  store double %22, double* %32, align 8
  %33 = getelementptr inbounds [10 x double], [10 x double]* %13, i32 0, i32 2
  store double %23, double* %33, align 8
  %34 = getelementptr inbounds [10 x double], [10 x double]* %13, i32 0, i32 3
  store double %24, double* %34, align 8
  %35 = getelementptr inbounds [10 x double], [10 x double]* %13, i32 0, i32 4
  store double %25, double* %35, align 8
  %36 = getelementptr inbounds [10 x double], [10 x double]* %13, i32 0, i32 5
  store double %26, double* %36, align 8
  %37 = getelementptr inbounds [10 x double], [10 x double]* %13, i32 0, i32 6
  store double %27, double* %37, align 8
  %38 = getelementptr inbounds [10 x double], [10 x double]* %13, i32 0, i32 7
  store double %28, double* %38, align 8
  %39 = getelementptr inbounds [10 x double], [10 x double]* %13, i32 0, i32 8
  store double %29, double* %39, align 8
  %40 = getelementptr inbounds [10 x double], [10 x double]* %13, i32 0, i32 9
  store double %30, double* %40, align 8
  ret void
}

attributes #0 = { nofree norecurse nounwind willreturn "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
