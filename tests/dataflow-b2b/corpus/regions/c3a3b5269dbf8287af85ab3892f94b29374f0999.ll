; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i32 %1, i32 %2, [256 x [10 x i32]] addrspace(3)* %3, i32 %4, i32 %5, i32 %6, [256 x [10 x i32]] addrspace(3)* %7, [256 x [10 x i32]] addrspace(3)* %8, [256 x [10 x i32]] addrspace(3)* %9, [2 x i32]* %10) #0 {
  br i1 %0, label %12, label %15

12:                                               ; preds = %11
  %13 = add nsw i32 %1, 1
  %14 = add nsw i32 %2, -1
  br label %33

15:                                               ; preds = %11
  %16 = getelementptr inbounds [256 x [10 x i32]], [256 x [10 x i32]] addrspace(3)* %3, i32 0, i32 %4, i32 %2
  %17 = load i32, i32 addrspace(3)* %16, align 4, !tbaa !1
  %18 = or i32 %17, %5
  %19 = getelementptr inbounds [256 x [10 x i32]], [256 x [10 x i32]] addrspace(3)* %3, i32 0, i32 %4, i32 %6
  store i32 %18, i32 addrspace(3)* %19, align 4, !tbaa !1
  %20 = getelementptr inbounds [256 x [10 x i32]], [256 x [10 x i32]] addrspace(3)* %7, i32 0, i32 %4, i32 %2
  %21 = load i32, i32 addrspace(3)* %20, align 4, !tbaa !1
  %22 = or i32 %21, %5
  %23 = shl i32 %22, 1
  %24 = getelementptr inbounds [256 x [10 x i32]], [256 x [10 x i32]] addrspace(3)* %7, i32 0, i32 %4, i32 %6
  store i32 %23, i32 addrspace(3)* %24, align 4, !tbaa !1
  %25 = getelementptr inbounds [256 x [10 x i32]], [256 x [10 x i32]] addrspace(3)* %8, i32 0, i32 %4, i32 %2
  %26 = load i32, i32 addrspace(3)* %25, align 4, !tbaa !1
  %27 = or i32 %26, %5
  %28 = lshr i32 %27, 1
  %29 = getelementptr inbounds [256 x [10 x i32]], [256 x [10 x i32]] addrspace(3)* %8, i32 0, i32 %4, i32 %6
  store i32 %28, i32 addrspace(3)* %29, align 4, !tbaa !1
  %30 = or i32 %23, %18
  %31 = or i32 %30, %28
  %32 = getelementptr inbounds [256 x [10 x i32]], [256 x [10 x i32]] addrspace(3)* %9, i32 0, i32 %4, i32 %6
  store i32 %31, i32 addrspace(3)* %32, align 4, !tbaa !1
  br label %33

33:                                               ; preds = %15, %12
  %34 = phi i32 [ %14, %12 ], [ %6, %15 ]
  %35 = phi i32 [ %13, %12 ], [ %1, %15 ]
  %36 = getelementptr inbounds [2 x i32], [2 x i32]* %10, i32 0, i32 0
  store i32 %34, i32* %36, align 4
  %37 = getelementptr inbounds [2 x i32], [2 x i32]* %10, i32 0, i32 1
  store i32 %35, i32* %37, align 4
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 4, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"int", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
