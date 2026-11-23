; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree norecurse nounwind willreturn
define void @region(i1 %0, double %1, double %2, double %3, double %4, double %5, double %6, double %7, double %8, double %9, double %10, [6 x double]* %11) #0 {
  br i1 %0, label %13, label %14

13:                                               ; preds = %12
  br label %14

14:                                               ; preds = %13, %12
  %15 = phi double [ %1, %13 ], [ 0.000000e+00, %12 ]
  %16 = phi double [ 0.000000e+00, %13 ], [ %2, %12 ]
  %17 = phi double [ %3, %13 ], [ %4, %12 ]
  %18 = phi double [ %5, %13 ], [ %6, %12 ]
  %19 = phi double [ %7, %13 ], [ %8, %12 ]
  %20 = phi double [ %9, %13 ], [ %10, %12 ]
  %21 = getelementptr inbounds [6 x double], [6 x double]* %11, i32 0, i32 0
  store double %15, double* %21, align 8
  %22 = getelementptr inbounds [6 x double], [6 x double]* %11, i32 0, i32 1
  store double %16, double* %22, align 8
  %23 = getelementptr inbounds [6 x double], [6 x double]* %11, i32 0, i32 2
  store double %17, double* %23, align 8
  %24 = getelementptr inbounds [6 x double], [6 x double]* %11, i32 0, i32 3
  store double %18, double* %24, align 8
  %25 = getelementptr inbounds [6 x double], [6 x double]* %11, i32 0, i32 4
  store double %19, double* %25, align 8
  %26 = getelementptr inbounds [6 x double], [6 x double]* %11, i32 0, i32 5
  store double %20, double* %26, align 8
  ret void
}

attributes #0 = { nofree norecurse nounwind willreturn "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
