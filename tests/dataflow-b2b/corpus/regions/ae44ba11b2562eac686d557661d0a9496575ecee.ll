; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: norecurse nounwind
define float @region(i1 %0, float %1, i32 %2) #0 {
  br i1 %0, label %4, label %6

4:                                                ; preds = %3
  %5 = fmul float %1, 0x3F60000000000000
  br label %11

6:                                                ; preds = %3
  %7 = fmul float %1, 1.250000e-01
  %8 = fadd float %7, 1.000000e+00
  %9 = add nsw i32 %2, -7
  %10 = tail call float @llvm.amdgcn.ldexp.f32(float %8, i32 %9) #2
  br label %11

11:                                               ; preds = %6, %4
  %12 = phi float [ %5, %4 ], [ %10, %6 ]
  ret float %12
}

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.amdgcn.ldexp.f32(float, i32) #1

attributes #0 = { norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { nounwind }
