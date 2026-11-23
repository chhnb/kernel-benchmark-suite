; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, [16 x [16 x float]] addrspace(3)* %1, i32 %2) #0 {
  %4 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 0, i32 9
  %5 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 1, i32 9
  %6 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 2, i32 9
  %7 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 3, i32 9
  %8 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 4, i32 9
  %9 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 5, i32 9
  %10 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 6, i32 9
  %11 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 7, i32 9
  %12 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 8, i32 9
  %13 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 9, i32 9
  br i1 %0, label %14, label %65

14:                                               ; preds = %3
  %15 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 9
  %16 = load float, float addrspace(3)* %15, align 4, !tbaa !1
  %17 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 0
  %18 = load float, float addrspace(3)* %17, align 16, !tbaa !1
  %19 = load float, float addrspace(3)* %4, align 4, !tbaa !1
  %20 = fmul contract float %18, %19
  %21 = fsub contract float %16, %20
  store float %21, float addrspace(3)* %15, align 4, !tbaa !1
  %22 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 1
  %23 = load float, float addrspace(3)* %22, align 4, !tbaa !1
  %24 = load float, float addrspace(3)* %5, align 4, !tbaa !1
  %25 = fmul contract float %23, %24
  %26 = fsub contract float %21, %25
  store float %26, float addrspace(3)* %15, align 4, !tbaa !1
  %27 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 2
  %28 = load float, float addrspace(3)* %27, align 8, !tbaa !1
  %29 = load float, float addrspace(3)* %6, align 4, !tbaa !1
  %30 = fmul contract float %28, %29
  %31 = fsub contract float %26, %30
  store float %31, float addrspace(3)* %15, align 4, !tbaa !1
  %32 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 3
  %33 = load float, float addrspace(3)* %32, align 4, !tbaa !1
  %34 = load float, float addrspace(3)* %7, align 4, !tbaa !1
  %35 = fmul contract float %33, %34
  %36 = fsub contract float %31, %35
  store float %36, float addrspace(3)* %15, align 4, !tbaa !1
  %37 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 4
  %38 = load float, float addrspace(3)* %37, align 16, !tbaa !1
  %39 = load float, float addrspace(3)* %8, align 4, !tbaa !1
  %40 = fmul contract float %38, %39
  %41 = fsub contract float %36, %40
  store float %41, float addrspace(3)* %15, align 4, !tbaa !1
  %42 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 5
  %43 = load float, float addrspace(3)* %42, align 4, !tbaa !1
  %44 = load float, float addrspace(3)* %9, align 4, !tbaa !1
  %45 = fmul contract float %43, %44
  %46 = fsub contract float %41, %45
  store float %46, float addrspace(3)* %15, align 4, !tbaa !1
  %47 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 6
  %48 = load float, float addrspace(3)* %47, align 8, !tbaa !1
  %49 = load float, float addrspace(3)* %10, align 4, !tbaa !1
  %50 = fmul contract float %48, %49
  %51 = fsub contract float %46, %50
  store float %51, float addrspace(3)* %15, align 4, !tbaa !1
  %52 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 7
  %53 = load float, float addrspace(3)* %52, align 4, !tbaa !1
  %54 = load float, float addrspace(3)* %11, align 4, !tbaa !1
  %55 = fmul contract float %53, %54
  %56 = fsub contract float %51, %55
  store float %56, float addrspace(3)* %15, align 4, !tbaa !1
  %57 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 8
  %58 = load float, float addrspace(3)* %57, align 16, !tbaa !1
  %59 = load float, float addrspace(3)* %12, align 4, !tbaa !1
  %60 = fmul contract float %58, %59
  %61 = fsub contract float %56, %60
  store float %61, float addrspace(3)* %15, align 4, !tbaa !1
  %62 = load float, float addrspace(3)* %13, align 4, !tbaa !1
  %63 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 9
  %64 = fdiv contract float %61, %62
  store float %64, float addrspace(3)* %63, align 4, !tbaa !1
  br label %65

65:                                               ; preds = %14, %3
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 2, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
