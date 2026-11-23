; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, float %1, float %2, float %3, float %4, [3 x float]* %5) #0 {
  br i1 %0, label %11, label %7

7:                                                ; preds = %6
  %8 = fmul float %1, %2
  %9 = fadd float %3, %8
  %10 = tail call float @llvm.ceil.f32(float %9) #2
  br label %11

11:                                               ; preds = %7, %6
  %12 = phi float [ %4, %6 ], [ %4, %7 ]
  %13 = phi float [ 0.000000e+00, %6 ], [ %10, %7 ]
  %14 = phi float [ %4, %6 ], [ %4, %7 ]
  %15 = getelementptr inbounds [3 x float], [3 x float]* %5, i32 0, i32 0
  store float %12, float* %15, align 4
  %16 = getelementptr inbounds [3 x float], [3 x float]* %5, i32 0, i32 1
  store float %13, float* %16, align 4
  %17 = getelementptr inbounds [3 x float], [3 x float]* %5, i32 0, i32 2
  store float %14, float* %17, align 4
  ret void
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare float @llvm.ceil.f32(float) #1

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,729" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { nounwind }
