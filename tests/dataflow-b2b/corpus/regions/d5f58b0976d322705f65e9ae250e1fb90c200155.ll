; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, float addrspace(3)* %1, [16 x [16 x float]] addrspace(3)* %2, i32 %3) #0 {
  %5 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 6, i32 0
  %6 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 6, i32 1
  %7 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 6, i32 2
  %8 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 6, i32 3
  %9 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 6, i32 4
  %10 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 6, i32 5
  br i1 %0, label %11, label %43

11:                                               ; preds = %4
  %12 = load float, float addrspace(3)* %1, align 4, !tbaa !1
  %13 = load float, float addrspace(3)* %5, align 16, !tbaa !1
  %14 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 0, i32 %3
  %15 = load float, float addrspace(3)* %14, align 4, !tbaa !1
  %16 = fmul contract float %13, %15
  %17 = fsub contract float %12, %16
  store float %17, float addrspace(3)* %1, align 4, !tbaa !1
  %18 = load float, float addrspace(3)* %6, align 4, !tbaa !1
  %19 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 1, i32 %3
  %20 = load float, float addrspace(3)* %19, align 4, !tbaa !1
  %21 = fmul contract float %18, %20
  %22 = fsub contract float %17, %21
  store float %22, float addrspace(3)* %1, align 4, !tbaa !1
  %23 = load float, float addrspace(3)* %7, align 8, !tbaa !1
  %24 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 2, i32 %3
  %25 = load float, float addrspace(3)* %24, align 4, !tbaa !1
  %26 = fmul contract float %23, %25
  %27 = fsub contract float %22, %26
  store float %27, float addrspace(3)* %1, align 4, !tbaa !1
  %28 = load float, float addrspace(3)* %8, align 4, !tbaa !1
  %29 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 3, i32 %3
  %30 = load float, float addrspace(3)* %29, align 4, !tbaa !1
  %31 = fmul contract float %28, %30
  %32 = fsub contract float %27, %31
  store float %32, float addrspace(3)* %1, align 4, !tbaa !1
  %33 = load float, float addrspace(3)* %9, align 16, !tbaa !1
  %34 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 4, i32 %3
  %35 = load float, float addrspace(3)* %34, align 4, !tbaa !1
  %36 = fmul contract float %33, %35
  %37 = fsub contract float %32, %36
  store float %37, float addrspace(3)* %1, align 4, !tbaa !1
  %38 = load float, float addrspace(3)* %10, align 4, !tbaa !1
  %39 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 5, i32 %3
  %40 = load float, float addrspace(3)* %39, align 4, !tbaa !1
  %41 = fmul contract float %38, %40
  %42 = fsub contract float %37, %41
  store float %42, float addrspace(3)* %1, align 4, !tbaa !1
  br label %43

43:                                               ; preds = %11, %4
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 3, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
