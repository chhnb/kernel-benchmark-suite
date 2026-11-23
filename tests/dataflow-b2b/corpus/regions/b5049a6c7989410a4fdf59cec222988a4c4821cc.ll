; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind willreturn
define void @region(i1 %0, [32 x [32 x float]] addrspace(3)* %1, i32 %2, [32 x [32 x float]] addrspace(3)* %3, i32 %4, [32 x [32 x float]] addrspace(3)* %5, i1 %6, [4 x float addrspace(3)*]* %7) #0 {
  br i1 %0, label %9, label %16

9:                                                ; preds = %8
  %10 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %1, i32 0, i32 30, i32 %2
  %11 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %3, i32 0, i32 31, i32 %2
  %12 = add nsw i32 %2, -1
  %13 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %1, i32 0, i32 31, i32 %12
  %14 = add nuw nsw i32 %2, 1
  %15 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %1, i32 0, i32 31, i32 %14
  br label %27

16:                                               ; preds = %8
  %17 = add nsw i32 %4, -1
  %18 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %1, i32 0, i32 %17, i32 %2
  %19 = add nuw nsw i32 %4, 1
  %20 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %1, i32 0, i32 %19, i32 %2
  %21 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 %4, i32 0
  %22 = add nsw i32 %2, -1
  %23 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %1, i32 0, i32 %4, i32 %22
  %24 = add nuw nsw i32 %2, 1
  %25 = select i1 %6, float addrspace(3)* %21, float addrspace(3)* %23
  %26 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %1, i32 0, i32 %4, i32 %24
  br label %27

27:                                               ; preds = %16, %9
  %28 = phi float addrspace(3)* [ %11, %9 ], [ %20, %16 ]
  %29 = phi float addrspace(3)* [ %15, %9 ], [ %26, %16 ]
  %30 = phi float addrspace(3)* [ %13, %9 ], [ %25, %16 ]
  %31 = phi float addrspace(3)* [ %10, %9 ], [ %18, %16 ]
  %32 = getelementptr inbounds [4 x float addrspace(3)*], [4 x float addrspace(3)*]* %7, i32 0, i32 0
  store float addrspace(3)* %28, float addrspace(3)** %32, align 4
  %33 = getelementptr inbounds [4 x float addrspace(3)*], [4 x float addrspace(3)*]* %7, i32 0, i32 1
  store float addrspace(3)* %29, float addrspace(3)** %33, align 4
  %34 = getelementptr inbounds [4 x float addrspace(3)*], [4 x float addrspace(3)*]* %7, i32 0, i32 2
  store float addrspace(3)* %30, float addrspace(3)** %34, align 4
  %35 = getelementptr inbounds [4 x float addrspace(3)*], [4 x float addrspace(3)*]* %7, i32 0, i32 3
  store float addrspace(3)* %31, float addrspace(3)** %35, align 4
  ret void
}

attributes #0 = { convergent norecurse nounwind willreturn "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0, !1}

!0 = !{i32 2, !"llvm.amdgcn.workitem.id.x"}
!1 = !{i32 4, !"llvm.amdgcn.workitem.id.y"}
