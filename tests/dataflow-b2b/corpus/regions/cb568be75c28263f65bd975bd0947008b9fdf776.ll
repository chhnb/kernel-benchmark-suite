; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, [16 x [16 x float]] addrspace(3)* %1, i32 %2) #0 {
  %4 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 0, i32 7
  %5 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 1, i32 7
  %6 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 2, i32 7
  %7 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 3, i32 7
  %8 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 4, i32 7
  %9 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 5, i32 7
  %10 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 6, i32 7
  %11 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 7, i32 7
  br i1 %0, label %12, label %53

12:                                               ; preds = %3
  %13 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 7
  %14 = load float, float addrspace(3)* %13, align 4, !tbaa !1
  %15 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 0
  %16 = load float, float addrspace(3)* %15, align 16, !tbaa !1
  %17 = load float, float addrspace(3)* %4, align 4, !tbaa !1
  %18 = fmul contract float %16, %17
  %19 = fsub contract float %14, %18
  store float %19, float addrspace(3)* %13, align 4, !tbaa !1
  %20 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 1
  %21 = load float, float addrspace(3)* %20, align 4, !tbaa !1
  %22 = load float, float addrspace(3)* %5, align 4, !tbaa !1
  %23 = fmul contract float %21, %22
  %24 = fsub contract float %19, %23
  store float %24, float addrspace(3)* %13, align 4, !tbaa !1
  %25 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 2
  %26 = load float, float addrspace(3)* %25, align 8, !tbaa !1
  %27 = load float, float addrspace(3)* %6, align 4, !tbaa !1
  %28 = fmul contract float %26, %27
  %29 = fsub contract float %24, %28
  store float %29, float addrspace(3)* %13, align 4, !tbaa !1
  %30 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 3
  %31 = load float, float addrspace(3)* %30, align 4, !tbaa !1
  %32 = load float, float addrspace(3)* %7, align 4, !tbaa !1
  %33 = fmul contract float %31, %32
  %34 = fsub contract float %29, %33
  store float %34, float addrspace(3)* %13, align 4, !tbaa !1
  %35 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 4
  %36 = load float, float addrspace(3)* %35, align 16, !tbaa !1
  %37 = load float, float addrspace(3)* %8, align 4, !tbaa !1
  %38 = fmul contract float %36, %37
  %39 = fsub contract float %34, %38
  store float %39, float addrspace(3)* %13, align 4, !tbaa !1
  %40 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 5
  %41 = load float, float addrspace(3)* %40, align 4, !tbaa !1
  %42 = load float, float addrspace(3)* %9, align 4, !tbaa !1
  %43 = fmul contract float %41, %42
  %44 = fsub contract float %39, %43
  store float %44, float addrspace(3)* %13, align 4, !tbaa !1
  %45 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 6
  %46 = load float, float addrspace(3)* %45, align 8, !tbaa !1
  %47 = load float, float addrspace(3)* %10, align 4, !tbaa !1
  %48 = fmul contract float %46, %47
  %49 = fsub contract float %44, %48
  store float %49, float addrspace(3)* %13, align 4, !tbaa !1
  %50 = load float, float addrspace(3)* %11, align 4, !tbaa !1
  %51 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 7
  %52 = fdiv contract float %49, %50
  store float %52, float addrspace(3)* %51, align 4, !tbaa !1
  br label %53

53:                                               ; preds = %12, %3
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 2, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
