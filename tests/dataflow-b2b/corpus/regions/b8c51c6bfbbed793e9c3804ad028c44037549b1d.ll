; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i1 %1, i32 %2, i32 %3, i32 %4, i1 %5, i32 %6, i32 %7, [8192 x i32] addrspace(3)* %8, i32 %9, i32 %10, i32 addrspace(3)* %11, i32 addrspace(3)* %12, { i32 addrspace(3)*, i32, i32, i32, i32 }* %13) #0 {
  br i1 %0, label %26, label %15

15:                                               ; preds = %14
  %16 = select i1 %1, i32 %2, i32 %3
  %17 = select i1 %1, i32 %4, i32 %2
  %18 = select i1 %5, i32 %16, i32 %17
  %19 = add nsw i32 %18, -1
  %20 = select i1 %1, i32 %6, i32 %7
  %21 = add nsw i32 %19, %20
  %22 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %8, i32 0, i32 %21
  %23 = load i32, i32 addrspace(3)* %22, align 4, !tbaa !0
  %24 = select i1 %1, i32 %9, i32 %23
  %25 = select i1 %1, i32 %23, i32 %10
  br label %26

26:                                               ; preds = %15, %14
  %27 = phi i32 addrspace(3)* [ %11, %14 ], [ %12, %15 ]
  %28 = phi i32 [ %10, %14 ], [ %9, %15 ]
  %29 = phi i32 [ %9, %14 ], [ %10, %15 ]
  %30 = phi i32 [ undef, %14 ], [ %24, %15 ]
  %31 = phi i32 [ undef, %14 ], [ %25, %15 ]
  %32 = getelementptr inbounds { i32 addrspace(3)*, i32, i32, i32, i32 }, { i32 addrspace(3)*, i32, i32, i32, i32 }* %13, i32 0, i32 0
  store i32 addrspace(3)* %27, i32 addrspace(3)** %32, align 4
  %33 = getelementptr inbounds { i32 addrspace(3)*, i32, i32, i32, i32 }, { i32 addrspace(3)*, i32, i32, i32, i32 }* %13, i32 0, i32 1
  store i32 %28, i32* %33, align 4
  %34 = getelementptr inbounds { i32 addrspace(3)*, i32, i32, i32, i32 }, { i32 addrspace(3)*, i32, i32, i32, i32 }* %13, i32 0, i32 2
  store i32 %29, i32* %34, align 4
  %35 = getelementptr inbounds { i32 addrspace(3)*, i32, i32, i32, i32 }, { i32 addrspace(3)*, i32, i32, i32, i32 }* %13, i32 0, i32 3
  store i32 %30, i32* %35, align 4
  %36 = getelementptr inbounds { i32 addrspace(3)*, i32, i32, i32, i32 }, { i32 addrspace(3)*, i32, i32, i32, i32 }* %13, i32 0, i32 4
  store i32 %31, i32* %36, align 4
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
