; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, [8 x [8 x float]] addrspace(3)* %1, i32 %2) #0 {
  %4 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 0, i32 4
  %5 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 1, i32 4
  %6 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 2, i32 4
  %7 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 3, i32 4
  %8 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 4, i32 4
  br i1 %0, label %9, label %35

9:                                                ; preds = %3
  %10 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 4
  %11 = load float, float addrspace(3)* %10, align 16, !tbaa !1
  %12 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 0
  %13 = load float, float addrspace(3)* %12, align 16, !tbaa !1
  %14 = load float, float addrspace(3)* %4, align 16, !tbaa !1
  %15 = fmul contract float %13, %14
  %16 = fsub contract float %11, %15
  store float %16, float addrspace(3)* %10, align 16, !tbaa !1
  %17 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 1
  %18 = load float, float addrspace(3)* %17, align 4, !tbaa !1
  %19 = load float, float addrspace(3)* %5, align 16, !tbaa !1
  %20 = fmul contract float %18, %19
  %21 = fsub contract float %16, %20
  store float %21, float addrspace(3)* %10, align 16, !tbaa !1
  %22 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 2
  %23 = load float, float addrspace(3)* %22, align 8, !tbaa !1
  %24 = load float, float addrspace(3)* %6, align 16, !tbaa !1
  %25 = fmul contract float %23, %24
  %26 = fsub contract float %21, %25
  store float %26, float addrspace(3)* %10, align 16, !tbaa !1
  %27 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 3
  %28 = load float, float addrspace(3)* %27, align 4, !tbaa !1
  %29 = load float, float addrspace(3)* %7, align 16, !tbaa !1
  %30 = fmul contract float %28, %29
  %31 = fsub contract float %26, %30
  store float %31, float addrspace(3)* %10, align 16, !tbaa !1
  %32 = load float, float addrspace(3)* %8, align 16, !tbaa !1
  %33 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 4
  %34 = fdiv contract float %31, %32
  store float %34, float addrspace(3)* %33, align 16, !tbaa !1
  br label %35

35:                                               ; preds = %9, %3
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 2, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
