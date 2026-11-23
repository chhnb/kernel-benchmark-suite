; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, [8 x [8 x float]] addrspace(3)* %1, i32 %2) #0 {
  %4 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 0, i32 5
  %5 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 1, i32 5
  %6 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 2, i32 5
  %7 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 3, i32 5
  %8 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 4, i32 5
  %9 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 5, i32 5
  br i1 %0, label %10, label %41

10:                                               ; preds = %3
  %11 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 5
  %12 = load float, float addrspace(3)* %11, align 4, !tbaa !1
  %13 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 0
  %14 = load float, float addrspace(3)* %13, align 16, !tbaa !1
  %15 = load float, float addrspace(3)* %4, align 4, !tbaa !1
  %16 = fmul contract float %14, %15
  %17 = fsub contract float %12, %16
  store float %17, float addrspace(3)* %11, align 4, !tbaa !1
  %18 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 1
  %19 = load float, float addrspace(3)* %18, align 4, !tbaa !1
  %20 = load float, float addrspace(3)* %5, align 4, !tbaa !1
  %21 = fmul contract float %19, %20
  %22 = fsub contract float %17, %21
  store float %22, float addrspace(3)* %11, align 4, !tbaa !1
  %23 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 2
  %24 = load float, float addrspace(3)* %23, align 8, !tbaa !1
  %25 = load float, float addrspace(3)* %6, align 4, !tbaa !1
  %26 = fmul contract float %24, %25
  %27 = fsub contract float %22, %26
  store float %27, float addrspace(3)* %11, align 4, !tbaa !1
  %28 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 3
  %29 = load float, float addrspace(3)* %28, align 4, !tbaa !1
  %30 = load float, float addrspace(3)* %7, align 4, !tbaa !1
  %31 = fmul contract float %29, %30
  %32 = fsub contract float %27, %31
  store float %32, float addrspace(3)* %11, align 4, !tbaa !1
  %33 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 4
  %34 = load float, float addrspace(3)* %33, align 16, !tbaa !1
  %35 = load float, float addrspace(3)* %8, align 4, !tbaa !1
  %36 = fmul contract float %34, %35
  %37 = fsub contract float %32, %36
  store float %37, float addrspace(3)* %11, align 4, !tbaa !1
  %38 = load float, float addrspace(3)* %9, align 4, !tbaa !1
  %39 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 5
  %40 = fdiv contract float %37, %38
  store float %40, float addrspace(3)* %39, align 4, !tbaa !1
  br label %41

41:                                               ; preds = %10, %3
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,1024" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 2, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
