; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind willreturn
define void @region(i1 %0, i32 %1, [16 x [16 x float]] addrspace(3)* %2, [16 x [16 x float]] addrspace(3)* %3, i1 %4, [16 x [16 x float]] addrspace(3)* %5, i32 %6, [2 x float addrspace(3)*]* %7) #0 {
  br i1 %0, label %9, label %13

9:                                                ; preds = %8
  %10 = add nuw nsw i32 %1, 1
  %11 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 %10, i32 15
  %12 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %3, i32 0, i32 %1, i32 15
  br label %20

13:                                               ; preds = %8
  %14 = add nuw nsw i32 %1, 1
  %15 = select i1 %4, i32 15, i32 %14
  %16 = select i1 %4, [16 x [16 x float]] addrspace(3)* %5, [16 x [16 x float]] addrspace(3)* %2
  %17 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %16, i32 0, i32 %15, i32 %6
  %18 = add nuw nsw i32 %6, 1
  %19 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 %1, i32 %18
  br label %20

20:                                               ; preds = %13, %9
  %21 = phi float addrspace(3)* [ %11, %9 ], [ %17, %13 ]
  %22 = phi float addrspace(3)* [ %12, %9 ], [ %19, %13 ]
  %23 = getelementptr inbounds [2 x float addrspace(3)*], [2 x float addrspace(3)*]* %7, i32 0, i32 0
  store float addrspace(3)* %21, float addrspace(3)** %23, align 4
  %24 = getelementptr inbounds [2 x float addrspace(3)*], [2 x float addrspace(3)*]* %7, i32 0, i32 1
  store float addrspace(3)* %22, float addrspace(3)** %24, align 4
  ret void
}

attributes #0 = { convergent norecurse nounwind willreturn "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0, !1}

!0 = !{i32 1, !"llvm.amdgcn.workitem.id.y"}
!1 = !{i32 6, !"llvm.amdgcn.workitem.id.x"}
