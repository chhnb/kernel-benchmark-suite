; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, float %1, float %2, [3 x float]* %3) #0 {
  br i1 %0, label %6, label %5

5:                                                ; preds = %4
  br label %6

6:                                                ; preds = %5, %4
  %7 = phi float [ %1, %4 ], [ %1, %5 ]
  %8 = phi float [ 0.000000e+00, %4 ], [ %2, %5 ]
  %9 = phi float [ %1, %4 ], [ %1, %5 ]
  %10 = getelementptr inbounds [3 x float], [3 x float]* %3, i32 0, i32 0
  store float %7, float* %10, align 4
  %11 = getelementptr inbounds [3 x float], [3 x float]* %3, i32 0, i32 1
  store float %8, float* %11, align 4
  %12 = getelementptr inbounds [3 x float], [3 x float]* %3, i32 0, i32 2
  store float %9, float* %12, align 4
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,729" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
