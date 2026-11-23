; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, [2 x double]* %4) #0 {
  br i1 %0, label %9, label %6

6:                                                ; preds = %5
  %7 = fdiv double %1, %2
  %8 = fsub double %3, %7
  br label %9

9:                                                ; preds = %6, %5
  %10 = phi double [ %3, %5 ], [ 2.000000e+00, %6 ]
  %11 = phi double [ undef, %5 ], [ %8, %6 ]
  %12 = getelementptr inbounds [2 x double], [2 x double]* %4, i32 0, i32 0
  store double %10, double* %12, align 8
  %13 = getelementptr inbounds [2 x double], [2 x double]* %4, i32 0, i32 1
  store double %11, double* %13, align 8
  ret void
}

attributes #0 = { nofree norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
