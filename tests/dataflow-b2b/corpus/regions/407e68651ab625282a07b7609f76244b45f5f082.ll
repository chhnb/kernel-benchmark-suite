; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, [16 x [16 x float]] addrspace(3)* %1, i32 %2) #0 {
  %4 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 0, i32 3
  %5 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 1, i32 3
  %6 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 2, i32 3
  %7 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 3, i32 3
  br i1 %0, label %8, label %29

8:                                                ; preds = %3
  %9 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 3
  %10 = load float, float addrspace(3)* %9, align 4, !tbaa !1
  %11 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 0
  %12 = load float, float addrspace(3)* %11, align 16, !tbaa !1
  %13 = load float, float addrspace(3)* %4, align 4, !tbaa !1
  %14 = fmul contract float %12, %13
  %15 = fsub contract float %10, %14
  store float %15, float addrspace(3)* %9, align 4, !tbaa !1
  %16 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 1
  %17 = load float, float addrspace(3)* %16, align 4, !tbaa !1
  %18 = load float, float addrspace(3)* %5, align 4, !tbaa !1
  %19 = fmul contract float %17, %18
  %20 = fsub contract float %15, %19
  store float %20, float addrspace(3)* %9, align 4, !tbaa !1
  %21 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 2
  %22 = load float, float addrspace(3)* %21, align 8, !tbaa !1
  %23 = load float, float addrspace(3)* %6, align 4, !tbaa !1
  %24 = fmul contract float %22, %23
  %25 = fsub contract float %20, %24
  store float %25, float addrspace(3)* %9, align 4, !tbaa !1
  %26 = load float, float addrspace(3)* %7, align 4, !tbaa !1
  %27 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 3
  %28 = fdiv contract float %25, %26
  store float %28, float addrspace(3)* %27, align 4, !tbaa !1
  br label %29

29:                                               ; preds = %8, %3
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 2, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
