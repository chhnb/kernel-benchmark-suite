; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent noinline norecurse nounwind
define void @region(i1 %0, i64* %1, i64 %2, i64 %3, i64 %4, i64 %5, { i64, i64, i1 }* %6) #0 {
  br i1 %0, label %8, label %14

8:                                                ; preds = %7
  %9 = getelementptr inbounds i64, i64* %1, i64 %2
  %10 = load i64, i64* %9, align 8
  %11 = getelementptr inbounds i64, i64* %1, i64 %3
  %12 = load i64, i64* %11, align 8
  %13 = icmp slt i64 %10, %12
  br label %14

14:                                               ; preds = %8, %7
  %15 = phi i64 [ %3, %8 ], [ %4, %7 ]
  %16 = phi i64 [ %2, %8 ], [ %5, %7 ]
  %17 = phi i1 [ %13, %8 ], [ true, %7 ]
  %18 = getelementptr inbounds { i64, i64, i1 }, { i64, i64, i1 }* %6, i32 0, i32 0
  store i64 %15, i64* %18, align 8
  %19 = getelementptr inbounds { i64, i64, i1 }, { i64, i64, i1 }* %6, i32 0, i32 1
  store i64 %16, i64* %19, align 8
  %20 = getelementptr inbounds { i64, i64, i1 }, { i64, i64, i1 }* %6, i32 0, i32 2
  store i1 %17, i1* %20, align 1
  ret void
}

attributes #0 = { convergent noinline norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
