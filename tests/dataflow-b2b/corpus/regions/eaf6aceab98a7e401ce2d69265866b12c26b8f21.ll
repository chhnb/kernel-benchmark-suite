; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, float addrspace(3)* %1, [16 x [16 x float]] addrspace(3)* %2, i32 %3) #0 {
  %5 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 13, i32 0
  %6 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 13, i32 1
  %7 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 13, i32 2
  %8 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 13, i32 3
  %9 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 13, i32 4
  %10 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 13, i32 5
  %11 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 13, i32 6
  %12 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 13, i32 7
  %13 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 13, i32 8
  %14 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 13, i32 9
  %15 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 13, i32 10
  %16 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 13, i32 11
  %17 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 13, i32 12
  br i1 %0, label %18, label %85

18:                                               ; preds = %4
  %19 = load float, float addrspace(3)* %1, align 4, !tbaa !1
  %20 = load float, float addrspace(3)* %5, align 16, !tbaa !1
  %21 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 0, i32 %3
  %22 = load float, float addrspace(3)* %21, align 4, !tbaa !1
  %23 = fmul contract float %20, %22
  %24 = fsub contract float %19, %23
  store float %24, float addrspace(3)* %1, align 4, !tbaa !1
  %25 = load float, float addrspace(3)* %6, align 4, !tbaa !1
  %26 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 1, i32 %3
  %27 = load float, float addrspace(3)* %26, align 4, !tbaa !1
  %28 = fmul contract float %25, %27
  %29 = fsub contract float %24, %28
  store float %29, float addrspace(3)* %1, align 4, !tbaa !1
  %30 = load float, float addrspace(3)* %7, align 8, !tbaa !1
  %31 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 2, i32 %3
  %32 = load float, float addrspace(3)* %31, align 4, !tbaa !1
  %33 = fmul contract float %30, %32
  %34 = fsub contract float %29, %33
  store float %34, float addrspace(3)* %1, align 4, !tbaa !1
  %35 = load float, float addrspace(3)* %8, align 4, !tbaa !1
  %36 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 3, i32 %3
  %37 = load float, float addrspace(3)* %36, align 4, !tbaa !1
  %38 = fmul contract float %35, %37
  %39 = fsub contract float %34, %38
  store float %39, float addrspace(3)* %1, align 4, !tbaa !1
  %40 = load float, float addrspace(3)* %9, align 16, !tbaa !1
  %41 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 4, i32 %3
  %42 = load float, float addrspace(3)* %41, align 4, !tbaa !1
  %43 = fmul contract float %40, %42
  %44 = fsub contract float %39, %43
  store float %44, float addrspace(3)* %1, align 4, !tbaa !1
  %45 = load float, float addrspace(3)* %10, align 4, !tbaa !1
  %46 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 5, i32 %3
  %47 = load float, float addrspace(3)* %46, align 4, !tbaa !1
  %48 = fmul contract float %45, %47
  %49 = fsub contract float %44, %48
  store float %49, float addrspace(3)* %1, align 4, !tbaa !1
  %50 = load float, float addrspace(3)* %11, align 8, !tbaa !1
  %51 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 6, i32 %3
  %52 = load float, float addrspace(3)* %51, align 4, !tbaa !1
  %53 = fmul contract float %50, %52
  %54 = fsub contract float %49, %53
  store float %54, float addrspace(3)* %1, align 4, !tbaa !1
  %55 = load float, float addrspace(3)* %12, align 4, !tbaa !1
  %56 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 7, i32 %3
  %57 = load float, float addrspace(3)* %56, align 4, !tbaa !1
  %58 = fmul contract float %55, %57
  %59 = fsub contract float %54, %58
  store float %59, float addrspace(3)* %1, align 4, !tbaa !1
  %60 = load float, float addrspace(3)* %13, align 16, !tbaa !1
  %61 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 8, i32 %3
  %62 = load float, float addrspace(3)* %61, align 4, !tbaa !1
  %63 = fmul contract float %60, %62
  %64 = fsub contract float %59, %63
  store float %64, float addrspace(3)* %1, align 4, !tbaa !1
  %65 = load float, float addrspace(3)* %14, align 4, !tbaa !1
  %66 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 9, i32 %3
  %67 = load float, float addrspace(3)* %66, align 4, !tbaa !1
  %68 = fmul contract float %65, %67
  %69 = fsub contract float %64, %68
  store float %69, float addrspace(3)* %1, align 4, !tbaa !1
  %70 = load float, float addrspace(3)* %15, align 8, !tbaa !1
  %71 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 10, i32 %3
  %72 = load float, float addrspace(3)* %71, align 4, !tbaa !1
  %73 = fmul contract float %70, %72
  %74 = fsub contract float %69, %73
  store float %74, float addrspace(3)* %1, align 4, !tbaa !1
  %75 = load float, float addrspace(3)* %16, align 4, !tbaa !1
  %76 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 11, i32 %3
  %77 = load float, float addrspace(3)* %76, align 4, !tbaa !1
  %78 = fmul contract float %75, %77
  %79 = fsub contract float %74, %78
  store float %79, float addrspace(3)* %1, align 4, !tbaa !1
  %80 = load float, float addrspace(3)* %17, align 16, !tbaa !1
  %81 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 12, i32 %3
  %82 = load float, float addrspace(3)* %81, align 4, !tbaa !1
  %83 = fmul contract float %80, %82
  %84 = fsub contract float %79, %83
  store float %84, float addrspace(3)* %1, align 4, !tbaa !1
  br label %85

85:                                               ; preds = %18, %4
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 3, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
