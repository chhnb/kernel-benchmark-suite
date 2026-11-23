; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, float addrspace(3)* %1, [8 x [8 x float]] addrspace(3)* %2, i32 %3) #0 {
  %5 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %2, i32 0, i32 3, i32 0
  %6 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %2, i32 0, i32 3, i32 1
  %7 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %2, i32 0, i32 3, i32 2
  br i1 %0, label %8, label %25

8:                                                ; preds = %4
  %9 = load float, float addrspace(3)* %1, align 4, !tbaa !1
  %10 = load float, float addrspace(3)* %5, align 16, !tbaa !1
  %11 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %2, i32 0, i32 0, i32 %3
  %12 = load float, float addrspace(3)* %11, align 4, !tbaa !1
  %13 = fmul contract float %10, %12
  %14 = fsub contract float %9, %13
  store float %14, float addrspace(3)* %1, align 4, !tbaa !1
  %15 = load float, float addrspace(3)* %6, align 4, !tbaa !1
  %16 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %2, i32 0, i32 1, i32 %3
  %17 = load float, float addrspace(3)* %16, align 4, !tbaa !1
  %18 = fmul contract float %15, %17
  %19 = fsub contract float %14, %18
  store float %19, float addrspace(3)* %1, align 4, !tbaa !1
  %20 = load float, float addrspace(3)* %7, align 8, !tbaa !1
  %21 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %2, i32 0, i32 2, i32 %3
  %22 = load float, float addrspace(3)* %21, align 4, !tbaa !1
  %23 = fmul contract float %20, %22
  %24 = fsub contract float %19, %23
  store float %24, float addrspace(3)* %1, align 4, !tbaa !1
  br label %25

25:                                               ; preds = %8, %4
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,1024" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 3, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
