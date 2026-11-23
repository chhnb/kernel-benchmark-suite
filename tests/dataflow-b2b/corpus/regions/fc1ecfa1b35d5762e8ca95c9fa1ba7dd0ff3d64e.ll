; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: norecurse nounwind
define float @region(i1 %0, float %1, float %2) #0 {
  br i1 %0, label %4, label %10

4:                                                ; preds = %3
  %5 = fcmp olt float %1, 3.500000e+00
  %6 = fcmp ugt float %1, 5.000000e+00
  %7 = select i1 %6, float 6.000000e+00, float 4.000000e+00
  %8 = select i1 %5, float 3.000000e+00, float %7
  %9 = tail call float @llvm.copysign.f32(float %8, float %2) #2
  br label %20

10:                                               ; preds = %3
  %11 = fcmp olt float %1, 1.750000e+00
  %12 = fcmp ugt float %1, 1.250000e+00
  %13 = fcmp olt float %1, 7.500000e-01
  %14 = fcmp ugt float %1, 2.500000e-01
  %15 = select i1 %14, float 5.000000e-01, float 0.000000e+00
  %16 = select i1 %13, float %15, float 1.000000e+00
  %17 = select i1 %12, float 1.500000e+00, float %16
  %18 = select i1 %11, float %17, float 2.000000e+00
  %19 = tail call float @llvm.copysign.f32(float %18, float %2) #2
  br label %20

20:                                               ; preds = %10, %4
  %21 = phi float [ %9, %4 ], [ %19, %10 ]
  ret float %21
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare float @llvm.copysign.f32(float, float) #1

attributes #0 = { norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { nounwind }
