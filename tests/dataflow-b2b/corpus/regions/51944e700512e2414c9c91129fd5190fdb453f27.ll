; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define float @region(i1 %0, float %1) #0 {
  br i1 %0, label %3, label %31

3:                                                ; preds = %2
  %4 = insertelement <2 x float> <float poison, float 0.000000e+00>, float %1, i32 0
  %5 = bitcast <2 x float> %4 to <2 x i32>
  %6 = sub nsw <2 x i32> <i32 -2147483648, i32 -2147483648>, %5
  %7 = icmp slt <2 x i32> %5, zeroinitializer
  %8 = select <2 x i1> %7, <2 x i32> %6, <2 x i32> %5
  %9 = extractelement <2 x i32> %8, i32 0
  %10 = extractelement <2 x i32> %8, i32 1
  %11 = icmp slt i32 %9, %10
  %12 = select i1 %11, i32 1, i32 -1
  %13 = add nsw i32 %12, %9
  %14 = sub nsw i32 -2147483648, %13
  %15 = icmp slt i32 %13, 0
  %16 = select i1 %15, i32 %14, i32 %13
  %17 = fcmp uno float %1, 0.000000e+00
  %18 = bitcast float %1 to i32
  %19 = select i1 %17, i32 %18, i32 %16
  %20 = insertelement <2 x float> <float 0.000000e+00, float poison>, float %1, i32 1
  %21 = tail call <2 x float> @llvm.fabs.v2f32(<2 x float> %20) #2
  %22 = bitcast <2 x float> %21 to <2 x i32>
  %23 = extractelement <2 x i32> %22, i32 0
  %24 = extractelement <2 x i32> %22, i32 1
  %25 = or i32 %23, %24
  %26 = icmp eq i32 %25, 0
  %27 = icmp eq i32 %18, 0
  %28 = or i1 %27, %26
  %29 = bitcast i32 %19 to float
  %30 = select i1 %28, float 0.000000e+00, float %29
  br label %31

31:                                               ; preds = %3, %2
  %32 = phi float [ %30, %3 ], [ %1, %2 ]
  ret float %32
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare <2 x float> @llvm.fabs.v2f32(<2 x float>) #1

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,729" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { nounwind }
