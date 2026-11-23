; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, float addrspace(3)* %1, [16 x [16 x float]] addrspace(3)* %2, i32 %3) #0 {
  %5 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 12, i32 0
  %6 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 12, i32 1
  %7 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 12, i32 2
  %8 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 12, i32 3
  %9 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 12, i32 4
  %10 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 12, i32 5
  %11 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 12, i32 6
  %12 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 12, i32 7
  %13 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 12, i32 8
  %14 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 12, i32 9
  %15 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 12, i32 10
  %16 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 12, i32 11
  br i1 %0, label %17, label %79

17:                                               ; preds = %4
  %18 = load float, float addrspace(3)* %1, align 4, !tbaa !1
  %19 = load float, float addrspace(3)* %5, align 16, !tbaa !1
  %20 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 0, i32 %3
  %21 = load float, float addrspace(3)* %20, align 4, !tbaa !1
  %22 = fmul contract float %19, %21
  %23 = fsub contract float %18, %22
  store float %23, float addrspace(3)* %1, align 4, !tbaa !1
  %24 = load float, float addrspace(3)* %6, align 4, !tbaa !1
  %25 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 1, i32 %3
  %26 = load float, float addrspace(3)* %25, align 4, !tbaa !1
  %27 = fmul contract float %24, %26
  %28 = fsub contract float %23, %27
  store float %28, float addrspace(3)* %1, align 4, !tbaa !1
  %29 = load float, float addrspace(3)* %7, align 8, !tbaa !1
  %30 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 2, i32 %3
  %31 = load float, float addrspace(3)* %30, align 4, !tbaa !1
  %32 = fmul contract float %29, %31
  %33 = fsub contract float %28, %32
  store float %33, float addrspace(3)* %1, align 4, !tbaa !1
  %34 = load float, float addrspace(3)* %8, align 4, !tbaa !1
  %35 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 3, i32 %3
  %36 = load float, float addrspace(3)* %35, align 4, !tbaa !1
  %37 = fmul contract float %34, %36
  %38 = fsub contract float %33, %37
  store float %38, float addrspace(3)* %1, align 4, !tbaa !1
  %39 = load float, float addrspace(3)* %9, align 16, !tbaa !1
  %40 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 4, i32 %3
  %41 = load float, float addrspace(3)* %40, align 4, !tbaa !1
  %42 = fmul contract float %39, %41
  %43 = fsub contract float %38, %42
  store float %43, float addrspace(3)* %1, align 4, !tbaa !1
  %44 = load float, float addrspace(3)* %10, align 4, !tbaa !1
  %45 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 5, i32 %3
  %46 = load float, float addrspace(3)* %45, align 4, !tbaa !1
  %47 = fmul contract float %44, %46
  %48 = fsub contract float %43, %47
  store float %48, float addrspace(3)* %1, align 4, !tbaa !1
  %49 = load float, float addrspace(3)* %11, align 8, !tbaa !1
  %50 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 6, i32 %3
  %51 = load float, float addrspace(3)* %50, align 4, !tbaa !1
  %52 = fmul contract float %49, %51
  %53 = fsub contract float %48, %52
  store float %53, float addrspace(3)* %1, align 4, !tbaa !1
  %54 = load float, float addrspace(3)* %12, align 4, !tbaa !1
  %55 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 7, i32 %3
  %56 = load float, float addrspace(3)* %55, align 4, !tbaa !1
  %57 = fmul contract float %54, %56
  %58 = fsub contract float %53, %57
  store float %58, float addrspace(3)* %1, align 4, !tbaa !1
  %59 = load float, float addrspace(3)* %13, align 16, !tbaa !1
  %60 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 8, i32 %3
  %61 = load float, float addrspace(3)* %60, align 4, !tbaa !1
  %62 = fmul contract float %59, %61
  %63 = fsub contract float %58, %62
  store float %63, float addrspace(3)* %1, align 4, !tbaa !1
  %64 = load float, float addrspace(3)* %14, align 4, !tbaa !1
  %65 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 9, i32 %3
  %66 = load float, float addrspace(3)* %65, align 4, !tbaa !1
  %67 = fmul contract float %64, %66
  %68 = fsub contract float %63, %67
  store float %68, float addrspace(3)* %1, align 4, !tbaa !1
  %69 = load float, float addrspace(3)* %15, align 8, !tbaa !1
  %70 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 10, i32 %3
  %71 = load float, float addrspace(3)* %70, align 4, !tbaa !1
  %72 = fmul contract float %69, %71
  %73 = fsub contract float %68, %72
  store float %73, float addrspace(3)* %1, align 4, !tbaa !1
  %74 = load float, float addrspace(3)* %16, align 4, !tbaa !1
  %75 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 11, i32 %3
  %76 = load float, float addrspace(3)* %75, align 4, !tbaa !1
  %77 = fmul contract float %74, %76
  %78 = fsub contract float %73, %77
  store float %78, float addrspace(3)* %1, align 4, !tbaa !1
  br label %79

79:                                               ; preds = %17, %4
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 3, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
