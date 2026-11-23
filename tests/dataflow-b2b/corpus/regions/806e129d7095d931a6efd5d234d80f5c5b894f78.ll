; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, float addrspace(3)* %1, [16 x [16 x float]] addrspace(3)* %2, i32 %3) #0 {
  %5 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 9, i32 0
  %6 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 9, i32 1
  %7 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 9, i32 2
  %8 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 9, i32 3
  %9 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 9, i32 4
  %10 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 9, i32 5
  %11 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 9, i32 6
  %12 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 9, i32 7
  %13 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 9, i32 8
  br i1 %0, label %14, label %61

14:                                               ; preds = %4
  %15 = load float, float addrspace(3)* %1, align 4, !tbaa !1
  %16 = load float, float addrspace(3)* %5, align 16, !tbaa !1
  %17 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 0, i32 %3
  %18 = load float, float addrspace(3)* %17, align 4, !tbaa !1
  %19 = fmul contract float %16, %18
  %20 = fsub contract float %15, %19
  store float %20, float addrspace(3)* %1, align 4, !tbaa !1
  %21 = load float, float addrspace(3)* %6, align 4, !tbaa !1
  %22 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 1, i32 %3
  %23 = load float, float addrspace(3)* %22, align 4, !tbaa !1
  %24 = fmul contract float %21, %23
  %25 = fsub contract float %20, %24
  store float %25, float addrspace(3)* %1, align 4, !tbaa !1
  %26 = load float, float addrspace(3)* %7, align 8, !tbaa !1
  %27 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 2, i32 %3
  %28 = load float, float addrspace(3)* %27, align 4, !tbaa !1
  %29 = fmul contract float %26, %28
  %30 = fsub contract float %25, %29
  store float %30, float addrspace(3)* %1, align 4, !tbaa !1
  %31 = load float, float addrspace(3)* %8, align 4, !tbaa !1
  %32 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 3, i32 %3
  %33 = load float, float addrspace(3)* %32, align 4, !tbaa !1
  %34 = fmul contract float %31, %33
  %35 = fsub contract float %30, %34
  store float %35, float addrspace(3)* %1, align 4, !tbaa !1
  %36 = load float, float addrspace(3)* %9, align 16, !tbaa !1
  %37 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 4, i32 %3
  %38 = load float, float addrspace(3)* %37, align 4, !tbaa !1
  %39 = fmul contract float %36, %38
  %40 = fsub contract float %35, %39
  store float %40, float addrspace(3)* %1, align 4, !tbaa !1
  %41 = load float, float addrspace(3)* %10, align 4, !tbaa !1
  %42 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 5, i32 %3
  %43 = load float, float addrspace(3)* %42, align 4, !tbaa !1
  %44 = fmul contract float %41, %43
  %45 = fsub contract float %40, %44
  store float %45, float addrspace(3)* %1, align 4, !tbaa !1
  %46 = load float, float addrspace(3)* %11, align 8, !tbaa !1
  %47 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 6, i32 %3
  %48 = load float, float addrspace(3)* %47, align 4, !tbaa !1
  %49 = fmul contract float %46, %48
  %50 = fsub contract float %45, %49
  store float %50, float addrspace(3)* %1, align 4, !tbaa !1
  %51 = load float, float addrspace(3)* %12, align 4, !tbaa !1
  %52 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 7, i32 %3
  %53 = load float, float addrspace(3)* %52, align 4, !tbaa !1
  %54 = fmul contract float %51, %53
  %55 = fsub contract float %50, %54
  store float %55, float addrspace(3)* %1, align 4, !tbaa !1
  %56 = load float, float addrspace(3)* %13, align 16, !tbaa !1
  %57 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 8, i32 %3
  %58 = load float, float addrspace(3)* %57, align 4, !tbaa !1
  %59 = fmul contract float %56, %58
  %60 = fsub contract float %55, %59
  store float %60, float addrspace(3)* %1, align 4, !tbaa !1
  br label %61

61:                                               ; preds = %14, %4
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 3, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
