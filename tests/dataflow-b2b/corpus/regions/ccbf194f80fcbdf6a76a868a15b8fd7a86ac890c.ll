; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i1 %1, float %2, float %3, float %4, float %5, float %6, i64 %7, i64 %8, i64 %9, float %10, float %11, i64 %12, float %13, { float, float, float, i64, i64, i64, float, float }* %14) #0 {
  br i1 %0, label %16, label %23

16:                                               ; preds = %15
  %17 = select i1 %1, float %2, float %3
  %18 = fadd float %17, %4
  %19 = select i1 %1, float %18, float %5
  %20 = select i1 %1, float %6, float %18
  %21 = select i1 %1, i64 %7, i64 %8
  %22 = select i1 %1, i64 %9, i64 %7
  br label %25

23:                                               ; preds = %15
  %24 = fadd float %10, %11
  br label %25

25:                                               ; preds = %23, %16
  %26 = phi float [ %19, %16 ], [ %5, %23 ]
  %27 = phi float [ %20, %16 ], [ %6, %23 ]
  %28 = phi float [ %11, %16 ], [ %24, %23 ]
  %29 = phi i64 [ %21, %16 ], [ %8, %23 ]
  %30 = phi i64 [ %22, %16 ], [ %9, %23 ]
  %31 = phi i64 [ %12, %16 ], [ %7, %23 ]
  %32 = phi float [ %4, %16 ], [ %11, %23 ]
  %33 = phi float [ %13, %16 ], [ %13, %23 ]
  %34 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %14, i32 0, i32 0
  store float %26, float* %34, align 4
  %35 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %14, i32 0, i32 1
  store float %27, float* %35, align 4
  %36 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %14, i32 0, i32 2
  store float %28, float* %36, align 4
  %37 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %14, i32 0, i32 3
  store i64 %29, i64* %37, align 8
  %38 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %14, i32 0, i32 4
  store i64 %30, i64* %38, align 8
  %39 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %14, i32 0, i32 5
  store i64 %31, i64* %39, align 8
  %40 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %14, i32 0, i32 6
  store float %32, float* %40, align 4
  %41 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %14, i32 0, i32 7
  store float %33, float* %41, align 4
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,729" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
