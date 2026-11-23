; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, float addrspace(3)* %1, [16 x [16 x float]] addrspace(3)* %2, i32 %3) #0 {
  %5 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 11, i32 0
  %6 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 11, i32 1
  %7 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 11, i32 2
  %8 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 11, i32 3
  %9 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 11, i32 4
  %10 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 11, i32 5
  %11 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 11, i32 6
  %12 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 11, i32 7
  %13 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 11, i32 8
  %14 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 11, i32 9
  %15 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 11, i32 10
  br i1 %0, label %16, label %73

16:                                               ; preds = %4
  %17 = load float, float addrspace(3)* %1, align 4, !tbaa !1
  %18 = load float, float addrspace(3)* %5, align 16, !tbaa !1
  %19 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 0, i32 %3
  %20 = load float, float addrspace(3)* %19, align 4, !tbaa !1
  %21 = fmul contract float %18, %20
  %22 = fsub contract float %17, %21
  store float %22, float addrspace(3)* %1, align 4, !tbaa !1
  %23 = load float, float addrspace(3)* %6, align 4, !tbaa !1
  %24 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 1, i32 %3
  %25 = load float, float addrspace(3)* %24, align 4, !tbaa !1
  %26 = fmul contract float %23, %25
  %27 = fsub contract float %22, %26
  store float %27, float addrspace(3)* %1, align 4, !tbaa !1
  %28 = load float, float addrspace(3)* %7, align 8, !tbaa !1
  %29 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 2, i32 %3
  %30 = load float, float addrspace(3)* %29, align 4, !tbaa !1
  %31 = fmul contract float %28, %30
  %32 = fsub contract float %27, %31
  store float %32, float addrspace(3)* %1, align 4, !tbaa !1
  %33 = load float, float addrspace(3)* %8, align 4, !tbaa !1
  %34 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 3, i32 %3
  %35 = load float, float addrspace(3)* %34, align 4, !tbaa !1
  %36 = fmul contract float %33, %35
  %37 = fsub contract float %32, %36
  store float %37, float addrspace(3)* %1, align 4, !tbaa !1
  %38 = load float, float addrspace(3)* %9, align 16, !tbaa !1
  %39 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 4, i32 %3
  %40 = load float, float addrspace(3)* %39, align 4, !tbaa !1
  %41 = fmul contract float %38, %40
  %42 = fsub contract float %37, %41
  store float %42, float addrspace(3)* %1, align 4, !tbaa !1
  %43 = load float, float addrspace(3)* %10, align 4, !tbaa !1
  %44 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 5, i32 %3
  %45 = load float, float addrspace(3)* %44, align 4, !tbaa !1
  %46 = fmul contract float %43, %45
  %47 = fsub contract float %42, %46
  store float %47, float addrspace(3)* %1, align 4, !tbaa !1
  %48 = load float, float addrspace(3)* %11, align 8, !tbaa !1
  %49 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 6, i32 %3
  %50 = load float, float addrspace(3)* %49, align 4, !tbaa !1
  %51 = fmul contract float %48, %50
  %52 = fsub contract float %47, %51
  store float %52, float addrspace(3)* %1, align 4, !tbaa !1
  %53 = load float, float addrspace(3)* %12, align 4, !tbaa !1
  %54 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 7, i32 %3
  %55 = load float, float addrspace(3)* %54, align 4, !tbaa !1
  %56 = fmul contract float %53, %55
  %57 = fsub contract float %52, %56
  store float %57, float addrspace(3)* %1, align 4, !tbaa !1
  %58 = load float, float addrspace(3)* %13, align 16, !tbaa !1
  %59 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 8, i32 %3
  %60 = load float, float addrspace(3)* %59, align 4, !tbaa !1
  %61 = fmul contract float %58, %60
  %62 = fsub contract float %57, %61
  store float %62, float addrspace(3)* %1, align 4, !tbaa !1
  %63 = load float, float addrspace(3)* %14, align 4, !tbaa !1
  %64 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 9, i32 %3
  %65 = load float, float addrspace(3)* %64, align 4, !tbaa !1
  %66 = fmul contract float %63, %65
  %67 = fsub contract float %62, %66
  store float %67, float addrspace(3)* %1, align 4, !tbaa !1
  %68 = load float, float addrspace(3)* %15, align 8, !tbaa !1
  %69 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 10, i32 %3
  %70 = load float, float addrspace(3)* %69, align 4, !tbaa !1
  %71 = fmul contract float %68, %70
  %72 = fsub contract float %67, %71
  store float %72, float addrspace(3)* %1, align 4, !tbaa !1
  br label %73

73:                                               ; preds = %16, %4
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 3, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
