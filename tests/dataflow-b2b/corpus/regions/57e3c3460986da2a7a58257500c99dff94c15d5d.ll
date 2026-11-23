; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, [16 x [16 x float]] addrspace(3)* %1, i32 %2) #0 {
  %4 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 0, i32 8
  %5 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 1, i32 8
  %6 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 2, i32 8
  %7 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 3, i32 8
  %8 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 4, i32 8
  %9 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 5, i32 8
  %10 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 6, i32 8
  %11 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 7, i32 8
  %12 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 8, i32 8
  br i1 %0, label %13, label %59

13:                                               ; preds = %3
  %14 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 8
  %15 = load float, float addrspace(3)* %14, align 16, !tbaa !1
  %16 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 0
  %17 = load float, float addrspace(3)* %16, align 16, !tbaa !1
  %18 = load float, float addrspace(3)* %4, align 16, !tbaa !1
  %19 = fmul contract float %17, %18
  %20 = fsub contract float %15, %19
  store float %20, float addrspace(3)* %14, align 16, !tbaa !1
  %21 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 1
  %22 = load float, float addrspace(3)* %21, align 4, !tbaa !1
  %23 = load float, float addrspace(3)* %5, align 16, !tbaa !1
  %24 = fmul contract float %22, %23
  %25 = fsub contract float %20, %24
  store float %25, float addrspace(3)* %14, align 16, !tbaa !1
  %26 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 2
  %27 = load float, float addrspace(3)* %26, align 8, !tbaa !1
  %28 = load float, float addrspace(3)* %6, align 16, !tbaa !1
  %29 = fmul contract float %27, %28
  %30 = fsub contract float %25, %29
  store float %30, float addrspace(3)* %14, align 16, !tbaa !1
  %31 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 3
  %32 = load float, float addrspace(3)* %31, align 4, !tbaa !1
  %33 = load float, float addrspace(3)* %7, align 16, !tbaa !1
  %34 = fmul contract float %32, %33
  %35 = fsub contract float %30, %34
  store float %35, float addrspace(3)* %14, align 16, !tbaa !1
  %36 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 4
  %37 = load float, float addrspace(3)* %36, align 16, !tbaa !1
  %38 = load float, float addrspace(3)* %8, align 16, !tbaa !1
  %39 = fmul contract float %37, %38
  %40 = fsub contract float %35, %39
  store float %40, float addrspace(3)* %14, align 16, !tbaa !1
  %41 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 5
  %42 = load float, float addrspace(3)* %41, align 4, !tbaa !1
  %43 = load float, float addrspace(3)* %9, align 16, !tbaa !1
  %44 = fmul contract float %42, %43
  %45 = fsub contract float %40, %44
  store float %45, float addrspace(3)* %14, align 16, !tbaa !1
  %46 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 6
  %47 = load float, float addrspace(3)* %46, align 8, !tbaa !1
  %48 = load float, float addrspace(3)* %10, align 16, !tbaa !1
  %49 = fmul contract float %47, %48
  %50 = fsub contract float %45, %49
  store float %50, float addrspace(3)* %14, align 16, !tbaa !1
  %51 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 7
  %52 = load float, float addrspace(3)* %51, align 4, !tbaa !1
  %53 = load float, float addrspace(3)* %11, align 16, !tbaa !1
  %54 = fmul contract float %52, %53
  %55 = fsub contract float %50, %54
  store float %55, float addrspace(3)* %14, align 16, !tbaa !1
  %56 = load float, float addrspace(3)* %12, align 16, !tbaa !1
  %57 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 8
  %58 = fdiv contract float %55, %56
  store float %58, float addrspace(3)* %57, align 16, !tbaa !1
  br label %59

59:                                               ; preds = %13, %3
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 2, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
