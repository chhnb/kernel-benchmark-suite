; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent noinline norecurse nounwind
define void @region(i1 %0, i64* %1, i64 %2, i64* %3, i64 %4, i64* %5, i64* %6, i64 %7, i64* %8, i64* %9, i64 %10, i64 %11, { i64*, i64*, i64, i64, i64*, i64, i64 }* %12) #0 {
  br i1 %0, label %14, label %19

14:                                               ; preds = %13
  %15 = getelementptr inbounds i64, i64* %1, i64 %2
  %16 = load i64, i64* %15, align 8
  %17 = getelementptr inbounds i64, i64* %3, i64 %4
  store i64 %16, i64* %17, align 8
  %18 = add nsw i64 %2, 1
  store i64 %18, i64* %5, align 8
  br label %24

19:                                               ; preds = %13
  %20 = getelementptr inbounds i64, i64* %6, i64 %7
  %21 = load i64, i64* %20, align 8
  %22 = getelementptr inbounds i64, i64* %8, i64 %4
  store i64 %21, i64* %22, align 8
  %23 = add nsw i64 %7, 1
  store i64 %23, i64* %9, align 8
  br label %24

24:                                               ; preds = %19, %14
  %25 = phi i64* [ %3, %14 ], [ %8, %19 ]
  %26 = phi i64* [ %1, %14 ], [ %6, %19 ]
  %27 = phi i64 [ %7, %14 ], [ %23, %19 ]
  %28 = phi i64 [ %18, %14 ], [ %2, %19 ]
  %29 = phi i64* [ %1, %14 ], [ %6, %19 ]
  %30 = phi i64 [ %10, %14 ], [ %23, %19 ]
  %31 = phi i64 [ %18, %14 ], [ %11, %19 ]
  %32 = getelementptr inbounds { i64*, i64*, i64, i64, i64*, i64, i64 }, { i64*, i64*, i64, i64, i64*, i64, i64 }* %12, i32 0, i32 0
  store i64* %25, i64** %32, align 8
  %33 = getelementptr inbounds { i64*, i64*, i64, i64, i64*, i64, i64 }, { i64*, i64*, i64, i64, i64*, i64, i64 }* %12, i32 0, i32 1
  store i64* %26, i64** %33, align 8
  %34 = getelementptr inbounds { i64*, i64*, i64, i64, i64*, i64, i64 }, { i64*, i64*, i64, i64, i64*, i64, i64 }* %12, i32 0, i32 2
  store i64 %27, i64* %34, align 8
  %35 = getelementptr inbounds { i64*, i64*, i64, i64, i64*, i64, i64 }, { i64*, i64*, i64, i64, i64*, i64, i64 }* %12, i32 0, i32 3
  store i64 %28, i64* %35, align 8
  %36 = getelementptr inbounds { i64*, i64*, i64, i64, i64*, i64, i64 }, { i64*, i64*, i64, i64, i64*, i64, i64 }* %12, i32 0, i32 4
  store i64* %29, i64** %36, align 8
  %37 = getelementptr inbounds { i64*, i64*, i64, i64, i64*, i64, i64 }, { i64*, i64*, i64, i64, i64*, i64, i64 }* %12, i32 0, i32 5
  store i64 %30, i64* %37, align 8
  %38 = getelementptr inbounds { i64*, i64*, i64, i64, i64*, i64, i64 }, { i64*, i64*, i64, i64, i64*, i64, i64 }* %12, i32 0, i32 6
  store i64 %31, i64* %38, align 8
  ret void
}

attributes #0 = { convergent noinline norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
