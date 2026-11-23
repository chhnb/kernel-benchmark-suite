; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, [8 x [8 x float]] addrspace(3)* %1, i32 %2) #0 {
  %4 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 0, i32 1
  %5 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 1, i32 1
  br i1 %0, label %6, label %17

6:                                                ; preds = %3
  %7 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 1
  %8 = load float, float addrspace(3)* %7, align 4, !tbaa !1
  %9 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 0
  %10 = load float, float addrspace(3)* %9, align 16, !tbaa !1
  %11 = load float, float addrspace(3)* %4, align 4, !tbaa !1
  %12 = fmul contract float %10, %11
  %13 = fsub contract float %8, %12
  store float %13, float addrspace(3)* %7, align 4, !tbaa !1
  %14 = load float, float addrspace(3)* %5, align 4, !tbaa !1
  %15 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 1
  %16 = fdiv contract float %13, %14
  store float %16, float addrspace(3)* %15, align 4, !tbaa !1
  br label %17

17:                                               ; preds = %6, %3
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,1024" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 2, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
