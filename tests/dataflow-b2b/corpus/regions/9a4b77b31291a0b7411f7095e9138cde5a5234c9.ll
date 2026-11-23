; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, [16 x [16 x float]] addrspace(3)* %1, i32 %2) #0 {
  %4 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 0, i32 10
  %5 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 1, i32 10
  %6 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 2, i32 10
  %7 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 3, i32 10
  %8 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 4, i32 10
  %9 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 5, i32 10
  %10 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 6, i32 10
  %11 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 7, i32 10
  %12 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 8, i32 10
  %13 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 9, i32 10
  %14 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 10, i32 10
  br i1 %0, label %15, label %71

15:                                               ; preds = %3
  %16 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 10
  %17 = load float, float addrspace(3)* %16, align 8, !tbaa !1
  %18 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 0
  %19 = load float, float addrspace(3)* %18, align 16, !tbaa !1
  %20 = load float, float addrspace(3)* %4, align 8, !tbaa !1
  %21 = fmul contract float %19, %20
  %22 = fsub contract float %17, %21
  store float %22, float addrspace(3)* %16, align 8, !tbaa !1
  %23 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 1
  %24 = load float, float addrspace(3)* %23, align 4, !tbaa !1
  %25 = load float, float addrspace(3)* %5, align 8, !tbaa !1
  %26 = fmul contract float %24, %25
  %27 = fsub contract float %22, %26
  store float %27, float addrspace(3)* %16, align 8, !tbaa !1
  %28 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 2
  %29 = load float, float addrspace(3)* %28, align 8, !tbaa !1
  %30 = load float, float addrspace(3)* %6, align 8, !tbaa !1
  %31 = fmul contract float %29, %30
  %32 = fsub contract float %27, %31
  store float %32, float addrspace(3)* %16, align 8, !tbaa !1
  %33 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 3
  %34 = load float, float addrspace(3)* %33, align 4, !tbaa !1
  %35 = load float, float addrspace(3)* %7, align 8, !tbaa !1
  %36 = fmul contract float %34, %35
  %37 = fsub contract float %32, %36
  store float %37, float addrspace(3)* %16, align 8, !tbaa !1
  %38 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 4
  %39 = load float, float addrspace(3)* %38, align 16, !tbaa !1
  %40 = load float, float addrspace(3)* %8, align 8, !tbaa !1
  %41 = fmul contract float %39, %40
  %42 = fsub contract float %37, %41
  store float %42, float addrspace(3)* %16, align 8, !tbaa !1
  %43 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 5
  %44 = load float, float addrspace(3)* %43, align 4, !tbaa !1
  %45 = load float, float addrspace(3)* %9, align 8, !tbaa !1
  %46 = fmul contract float %44, %45
  %47 = fsub contract float %42, %46
  store float %47, float addrspace(3)* %16, align 8, !tbaa !1
  %48 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 6
  %49 = load float, float addrspace(3)* %48, align 8, !tbaa !1
  %50 = load float, float addrspace(3)* %10, align 8, !tbaa !1
  %51 = fmul contract float %49, %50
  %52 = fsub contract float %47, %51
  store float %52, float addrspace(3)* %16, align 8, !tbaa !1
  %53 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 7
  %54 = load float, float addrspace(3)* %53, align 4, !tbaa !1
  %55 = load float, float addrspace(3)* %11, align 8, !tbaa !1
  %56 = fmul contract float %54, %55
  %57 = fsub contract float %52, %56
  store float %57, float addrspace(3)* %16, align 8, !tbaa !1
  %58 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 8
  %59 = load float, float addrspace(3)* %58, align 16, !tbaa !1
  %60 = load float, float addrspace(3)* %12, align 8, !tbaa !1
  %61 = fmul contract float %59, %60
  %62 = fsub contract float %57, %61
  store float %62, float addrspace(3)* %16, align 8, !tbaa !1
  %63 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 9
  %64 = load float, float addrspace(3)* %63, align 4, !tbaa !1
  %65 = load float, float addrspace(3)* %13, align 8, !tbaa !1
  %66 = fmul contract float %64, %65
  %67 = fsub contract float %62, %66
  store float %67, float addrspace(3)* %16, align 8, !tbaa !1
  %68 = load float, float addrspace(3)* %14, align 8, !tbaa !1
  %69 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 10
  %70 = fdiv contract float %67, %68
  store float %70, float addrspace(3)* %69, align 8, !tbaa !1
  br label %71

71:                                               ; preds = %15, %3
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 2, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
