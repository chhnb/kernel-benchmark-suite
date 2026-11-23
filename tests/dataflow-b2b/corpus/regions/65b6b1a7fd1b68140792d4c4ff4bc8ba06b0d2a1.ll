; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind willreturn
define void @region(i1 %0, [32 x [32 x float]] addrspace(3)* %1, i32 %2, [32 x [32 x float]] addrspace(3)* %3, i1 %4, i32 %5, [32 x [32 x float]] addrspace(3)* %6, [32 x [32 x float]] addrspace(3)* %7, [32 x [32 x float]] addrspace(3)* %8, i1 %9, i1 %10, [4 x float addrspace(3)*]* %11) #0 {
  br i1 %0, label %13, label %30

13:                                               ; preds = %12
  %14 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %1, i32 0, i32 0, i32 %2
  %15 = getelementptr [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %3, i32 0, i32 1, i32 %2
  %16 = select i1 %4, i32 %2, i32 %5
  %17 = add nsw i32 %16, -1
  %18 = select i1 %4, i32 0, i32 %17
  %19 = select i1 %4, i32 %17, i32 31
  %20 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %3, i32 0, i32 %18, i32 %19
  %21 = add nuw nsw i32 %16, 1
  %22 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %3, i32 0, i32 %21, i32 31
  %23 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %3, i32 0, i32 %5, i32 30
  %24 = select i1 %4, [32 x [32 x float]] addrspace(3)* %3, [32 x [32 x float]] addrspace(3)* %6
  %25 = select i1 %4, i32 %21, i32 31
  %26 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %24, i32 0, i32 %5, i32 %25
  %27 = select i1 %4, float addrspace(3)* %15, float addrspace(3)* %22
  %28 = select i1 %4, float addrspace(3)* %20, float addrspace(3)* %23
  %29 = select i1 %4, float addrspace(3)* %14, float addrspace(3)* %20
  br label %45

30:                                               ; preds = %12
  %31 = add nsw i32 %5, -1
  %32 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %3, i32 0, i32 %31, i32 %2
  %33 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %7, i32 0, i32 31, i32 %2
  %34 = add nuw nsw i32 %5, 1
  %35 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %3, i32 0, i32 %34, i32 %2
  %36 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 %5, i32 0
  %37 = select i1 %9, float addrspace(3)* poison, float addrspace(3)* %36
  %38 = add nsw i32 %2, -1
  %39 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %3, i32 0, i32 %5, i32 %38
  %40 = add nuw nsw i32 %2, 1
  %41 = select i1 %10, float addrspace(3)* %37, float addrspace(3)* %39
  %42 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %3, i32 0, i32 %5, i32 %40
  %43 = select i1 %9, float addrspace(3)* %33, float addrspace(3)* %35
  %44 = select i1 %9, float addrspace(3)* %39, float addrspace(3)* %41
  br label %45

45:                                               ; preds = %30, %13
  %46 = phi float addrspace(3)* [ %27, %13 ], [ %43, %30 ]
  %47 = phi float addrspace(3)* [ %26, %13 ], [ %42, %30 ]
  %48 = phi float addrspace(3)* [ %28, %13 ], [ %44, %30 ]
  %49 = phi float addrspace(3)* [ %29, %13 ], [ %32, %30 ]
  %50 = getelementptr inbounds [4 x float addrspace(3)*], [4 x float addrspace(3)*]* %11, i32 0, i32 0
  store float addrspace(3)* %46, float addrspace(3)** %50, align 4
  %51 = getelementptr inbounds [4 x float addrspace(3)*], [4 x float addrspace(3)*]* %11, i32 0, i32 1
  store float addrspace(3)* %47, float addrspace(3)** %51, align 4
  %52 = getelementptr inbounds [4 x float addrspace(3)*], [4 x float addrspace(3)*]* %11, i32 0, i32 2
  store float addrspace(3)* %48, float addrspace(3)** %52, align 4
  %53 = getelementptr inbounds [4 x float addrspace(3)*], [4 x float addrspace(3)*]* %11, i32 0, i32 3
  store float addrspace(3)* %49, float addrspace(3)** %53, align 4
  ret void
}

attributes #0 = { convergent norecurse nounwind willreturn "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0, !1}

!0 = !{i32 2, !"llvm.amdgcn.workitem.id.x"}
!1 = !{i32 5, !"llvm.amdgcn.workitem.id.y"}
