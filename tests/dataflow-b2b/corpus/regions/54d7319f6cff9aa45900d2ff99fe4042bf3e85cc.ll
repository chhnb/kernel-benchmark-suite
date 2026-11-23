; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i1 %1, float %2, float %3, float %4, i64 %5, i64 %6, i64 %7, float %8, i64 %9, float %10, float %11, { float, float, float, i64, i64, i64, float, float }* %12) #0 {
  br i1 %0, label %14, label %19

14:                                               ; preds = %13
  %15 = select i1 %1, float %2, float %3
  %16 = select i1 %1, float %4, float %2
  %17 = select i1 %1, i64 %5, i64 %6
  %18 = select i1 %1, i64 %7, i64 %5
  br label %19

19:                                               ; preds = %14, %13
  %20 = phi float [ %15, %14 ], [ %3, %13 ]
  %21 = phi float [ %16, %14 ], [ %4, %13 ]
  %22 = phi float [ %8, %14 ], [ %2, %13 ]
  %23 = phi i64 [ %17, %14 ], [ %6, %13 ]
  %24 = phi i64 [ %18, %14 ], [ %7, %13 ]
  %25 = phi i64 [ %9, %14 ], [ %5, %13 ]
  %26 = phi float [ %10, %14 ], [ %8, %13 ]
  %27 = phi float [ %11, %14 ], [ %11, %13 ]
  %28 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %12, i32 0, i32 0
  store float %20, float* %28, align 4
  %29 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %12, i32 0, i32 1
  store float %21, float* %29, align 4
  %30 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %12, i32 0, i32 2
  store float %22, float* %30, align 4
  %31 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %12, i32 0, i32 3
  store i64 %23, i64* %31, align 8
  %32 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %12, i32 0, i32 4
  store i64 %24, i64* %32, align 8
  %33 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %12, i32 0, i32 5
  store i64 %25, i64* %33, align 8
  %34 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %12, i32 0, i32 6
  store float %26, float* %34, align 4
  %35 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %12, i32 0, i32 7
  store float %27, float* %35, align 4
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,729" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
