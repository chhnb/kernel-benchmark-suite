; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-G1-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind mustprogress
define i32 @region(i1 %0, i1 %1, i1 %2, i1 %3, i1 %4, i1 %5, i1 %6, i1 %7, i1 %8) #0 {
  br i1 %0, label %10, label %19

10:                                               ; preds = %9
  %11 = select i1 %1, i32 124, i32 120
  %12 = select i1 %2, i32 %11, i32 116
  %13 = select i1 %3, i32 %12, i32 112
  %14 = select i1 %4, i32 %13, i32 108
  %15 = select i1 %5, i32 %14, i32 104
  %16 = select i1 %6, i32 %15, i32 100
  %17 = select i1 %7, i32 %16, i32 96
  %18 = select i1 %8, i32 %17, i32 92
  br label %19

19:                                               ; preds = %10, %9
  %20 = phi i32 [ %18, %10 ], [ 88, %9 ]
  ret i32 %20
}

attributes #0 = { convergent norecurse nounwind mustprogress "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
