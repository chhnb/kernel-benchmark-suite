; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i32 %1, i1 %2, i32 %3, [128 x [10 x i32]] addrspace(3)* %4, i32 %5, i32 %6, i32 %7, [128 x [10 x i32]] addrspace(3)* %8, [128 x [10 x i32]] addrspace(3)* %9, [128 x [10 x i32]] addrspace(3)* %10, [3 x i32]* %11) #0 {
  br i1 %0, label %13, label %17

13:                                               ; preds = %12
  %14 = add nsw i32 %1, 1
  %15 = select i1 %2, i32 undef, i32 %14
  %16 = add nsw i32 %3, -1
  br label %35

17:                                               ; preds = %12
  %18 = getelementptr inbounds [128 x [10 x i32]], [128 x [10 x i32]] addrspace(3)* %4, i32 0, i32 %5, i32 %3
  %19 = load i32, i32 addrspace(3)* %18, align 4, !tbaa !1
  %20 = or i32 %19, %6
  %21 = getelementptr inbounds [128 x [10 x i32]], [128 x [10 x i32]] addrspace(3)* %4, i32 0, i32 %5, i32 %7
  store i32 %20, i32 addrspace(3)* %21, align 4, !tbaa !1
  %22 = getelementptr inbounds [128 x [10 x i32]], [128 x [10 x i32]] addrspace(3)* %8, i32 0, i32 %5, i32 %3
  %23 = load i32, i32 addrspace(3)* %22, align 4, !tbaa !1
  %24 = or i32 %23, %6
  %25 = shl i32 %24, 1
  %26 = getelementptr inbounds [128 x [10 x i32]], [128 x [10 x i32]] addrspace(3)* %8, i32 0, i32 %5, i32 %7
  store i32 %25, i32 addrspace(3)* %26, align 4, !tbaa !1
  %27 = getelementptr inbounds [128 x [10 x i32]], [128 x [10 x i32]] addrspace(3)* %9, i32 0, i32 %5, i32 %3
  %28 = load i32, i32 addrspace(3)* %27, align 4, !tbaa !1
  %29 = or i32 %28, %6
  %30 = lshr i32 %29, 1
  %31 = getelementptr inbounds [128 x [10 x i32]], [128 x [10 x i32]] addrspace(3)* %9, i32 0, i32 %5, i32 %7
  store i32 %30, i32 addrspace(3)* %31, align 4, !tbaa !1
  %32 = or i32 %25, %20
  %33 = or i32 %32, %30
  %34 = getelementptr inbounds [128 x [10 x i32]], [128 x [10 x i32]] addrspace(3)* %10, i32 0, i32 %5, i32 %7
  store i32 %33, i32 addrspace(3)* %34, align 4, !tbaa !1
  br label %35

35:                                               ; preds = %17, %13
  %36 = phi i32 [ %16, %13 ], [ undef, %17 ]
  %37 = phi i32 [ %15, %13 ], [ %1, %17 ]
  %38 = phi i32 [ %16, %13 ], [ %7, %17 ]
  %39 = getelementptr inbounds [3 x i32], [3 x i32]* %11, i32 0, i32 0
  store i32 %36, i32* %39, align 4
  %40 = getelementptr inbounds [3 x i32], [3 x i32]* %11, i32 0, i32 1
  store i32 %37, i32* %40, align 4
  %41 = getelementptr inbounds [3 x i32], [3 x i32]* %11, i32 0, i32 2
  store i32 %38, i32* %41, align 4
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 5, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"int", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
