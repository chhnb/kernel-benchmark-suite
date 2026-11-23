; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind willreturn
define void @region(i1 %0, [32 x [32 x float]] addrspace(3)* %1, i32 %2, i32 %3, [32 x [32 x float]] addrspace(3)* %4, i32 %5, [4 x float addrspace(3)*]* %6) #0 {
  br i1 %0, label %8, label %14

8:                                                ; preds = %7
  %9 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 0
  %10 = add nuw nsw i32 %3, 1
  %11 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %1, i32 0, i32 %10, i32 0
  %12 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %4, i32 0, i32 %3, i32 0
  %13 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %1, i32 0, i32 %3, i32 1
  br label %22

14:                                               ; preds = %7
  %15 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 %5
  %16 = add nuw nsw i32 %3, 1
  %17 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %1, i32 0, i32 %16, i32 %5
  %18 = add nsw i32 %5, -1
  %19 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %1, i32 0, i32 %3, i32 %18
  %20 = add nuw nsw i32 %5, 1
  %21 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %1, i32 0, i32 %3, i32 %20
  br label %22

22:                                               ; preds = %14, %8
  %23 = phi float addrspace(3)* [ %11, %8 ], [ %17, %14 ]
  %24 = phi float addrspace(3)* [ %13, %8 ], [ %21, %14 ]
  %25 = phi float addrspace(3)* [ %12, %8 ], [ %19, %14 ]
  %26 = phi float addrspace(3)* [ %9, %8 ], [ %15, %14 ]
  %27 = getelementptr inbounds [4 x float addrspace(3)*], [4 x float addrspace(3)*]* %6, i32 0, i32 0
  store float addrspace(3)* %23, float addrspace(3)** %27, align 4
  %28 = getelementptr inbounds [4 x float addrspace(3)*], [4 x float addrspace(3)*]* %6, i32 0, i32 1
  store float addrspace(3)* %24, float addrspace(3)** %28, align 4
  %29 = getelementptr inbounds [4 x float addrspace(3)*], [4 x float addrspace(3)*]* %6, i32 0, i32 2
  store float addrspace(3)* %25, float addrspace(3)** %29, align 4
  %30 = getelementptr inbounds [4 x float addrspace(3)*], [4 x float addrspace(3)*]* %6, i32 0, i32 3
  store float addrspace(3)* %26, float addrspace(3)** %30, align 4
  ret void
}

attributes #0 = { convergent norecurse nounwind willreturn "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0, !1}

!0 = !{i32 3, !"llvm.amdgcn.workitem.id.y"}
!1 = !{i32 5, !"llvm.amdgcn.workitem.id.x"}
