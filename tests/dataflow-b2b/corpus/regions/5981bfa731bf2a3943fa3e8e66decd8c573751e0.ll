; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, [8 x [8 x float]] addrspace(3)* %1, i32 %2) #0 {
  %4 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 0, i32 6
  %5 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 1, i32 6
  %6 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 2, i32 6
  %7 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 3, i32 6
  %8 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 4, i32 6
  %9 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 5, i32 6
  %10 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 6, i32 6
  br i1 %0, label %11, label %47

11:                                               ; preds = %3
  %12 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 6
  %13 = load float, float addrspace(3)* %12, align 8, !tbaa !1
  %14 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 0
  %15 = load float, float addrspace(3)* %14, align 16, !tbaa !1
  %16 = load float, float addrspace(3)* %4, align 8, !tbaa !1
  %17 = fmul contract float %15, %16
  %18 = fsub contract float %13, %17
  store float %18, float addrspace(3)* %12, align 8, !tbaa !1
  %19 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 1
  %20 = load float, float addrspace(3)* %19, align 4, !tbaa !1
  %21 = load float, float addrspace(3)* %5, align 8, !tbaa !1
  %22 = fmul contract float %20, %21
  %23 = fsub contract float %18, %22
  store float %23, float addrspace(3)* %12, align 8, !tbaa !1
  %24 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 2
  %25 = load float, float addrspace(3)* %24, align 8, !tbaa !1
  %26 = load float, float addrspace(3)* %6, align 8, !tbaa !1
  %27 = fmul contract float %25, %26
  %28 = fsub contract float %23, %27
  store float %28, float addrspace(3)* %12, align 8, !tbaa !1
  %29 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 3
  %30 = load float, float addrspace(3)* %29, align 4, !tbaa !1
  %31 = load float, float addrspace(3)* %7, align 8, !tbaa !1
  %32 = fmul contract float %30, %31
  %33 = fsub contract float %28, %32
  store float %33, float addrspace(3)* %12, align 8, !tbaa !1
  %34 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 4
  %35 = load float, float addrspace(3)* %34, align 16, !tbaa !1
  %36 = load float, float addrspace(3)* %8, align 8, !tbaa !1
  %37 = fmul contract float %35, %36
  %38 = fsub contract float %33, %37
  store float %38, float addrspace(3)* %12, align 8, !tbaa !1
  %39 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 5
  %40 = load float, float addrspace(3)* %39, align 4, !tbaa !1
  %41 = load float, float addrspace(3)* %9, align 8, !tbaa !1
  %42 = fmul contract float %40, %41
  %43 = fsub contract float %38, %42
  store float %43, float addrspace(3)* %12, align 8, !tbaa !1
  %44 = load float, float addrspace(3)* %10, align 8, !tbaa !1
  %45 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 6
  %46 = fdiv contract float %43, %44
  store float %46, float addrspace(3)* %45, align 8, !tbaa !1
  br label %47

47:                                               ; preds = %11, %3
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 2, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
