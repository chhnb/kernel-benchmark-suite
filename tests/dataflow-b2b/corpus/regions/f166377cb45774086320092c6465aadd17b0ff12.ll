; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent noinline norecurse nounwind
define void @region(i1 %0, i64 %1, i64 %2, i64 %3, [3 x i64]* %4) #0 {
  br i1 %0, label %6, label %7

6:                                                ; preds = %5
  br label %8

7:                                                ; preds = %5
  br label %8

8:                                                ; preds = %7, %6
  %9 = phi i64 [ %1, %6 ], [ %2, %7 ]
  %10 = phi i64 [ %1, %6 ], [ %2, %7 ]
  %11 = phi i64 [ %3, %6 ], [ %2, %7 ]
  %12 = getelementptr inbounds [3 x i64], [3 x i64]* %4, i32 0, i32 0
  store i64 %9, i64* %12, align 8
  %13 = getelementptr inbounds [3 x i64], [3 x i64]* %4, i32 0, i32 1
  store i64 %10, i64* %13, align 8
  %14 = getelementptr inbounds [3 x i64], [3 x i64]* %4, i32 0, i32 2
  store i64 %11, i64* %14, align 8
  ret void
}

attributes #0 = { convergent noinline norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
