; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, float %1, float %2, float %3, float %4, float %5, [3 x float]* %6) #0 {
  br i1 %0, label %12, label %8

8:                                                ; preds = %7
  %9 = fmul float %1, %2
  %10 = fadd float %3, %9
  %11 = tail call float @llvm.floor.f32(float %10) #2
  br label %12

12:                                               ; preds = %8, %7
  %13 = phi float [ %4, %7 ], [ %4, %8 ]
  %14 = phi float [ %5, %7 ], [ %11, %8 ]
  %15 = phi float [ %4, %7 ], [ %4, %8 ]
  %16 = getelementptr inbounds [3 x float], [3 x float]* %6, i32 0, i32 0
  store float %13, float* %16, align 4
  %17 = getelementptr inbounds [3 x float], [3 x float]* %6, i32 0, i32 1
  store float %14, float* %17, align 4
  %18 = getelementptr inbounds [3 x float], [3 x float]* %6, i32 0, i32 2
  store float %15, float* %18, align 4
  ret void
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare float @llvm.floor.f32(float) #1

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,729" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { nounwind }
