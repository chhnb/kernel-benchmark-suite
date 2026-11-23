; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, [16 x [16 x float]] addrspace(3)* %1, i32 %2) #0 {
  %4 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 0, i32 13
  %5 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 1, i32 13
  %6 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 2, i32 13
  %7 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 3, i32 13
  %8 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 4, i32 13
  %9 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 5, i32 13
  %10 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 6, i32 13
  %11 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 7, i32 13
  %12 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 8, i32 13
  %13 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 9, i32 13
  %14 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 10, i32 13
  %15 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 11, i32 13
  %16 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 12, i32 13
  %17 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 13, i32 13
  br i1 %0, label %18, label %89

18:                                               ; preds = %3
  %19 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 13
  %20 = load float, float addrspace(3)* %19, align 4, !tbaa !1
  %21 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 0
  %22 = load float, float addrspace(3)* %21, align 16, !tbaa !1
  %23 = load float, float addrspace(3)* %4, align 4, !tbaa !1
  %24 = fmul contract float %22, %23
  %25 = fsub contract float %20, %24
  store float %25, float addrspace(3)* %19, align 4, !tbaa !1
  %26 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 1
  %27 = load float, float addrspace(3)* %26, align 4, !tbaa !1
  %28 = load float, float addrspace(3)* %5, align 4, !tbaa !1
  %29 = fmul contract float %27, %28
  %30 = fsub contract float %25, %29
  store float %30, float addrspace(3)* %19, align 4, !tbaa !1
  %31 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 2
  %32 = load float, float addrspace(3)* %31, align 8, !tbaa !1
  %33 = load float, float addrspace(3)* %6, align 4, !tbaa !1
  %34 = fmul contract float %32, %33
  %35 = fsub contract float %30, %34
  store float %35, float addrspace(3)* %19, align 4, !tbaa !1
  %36 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 3
  %37 = load float, float addrspace(3)* %36, align 4, !tbaa !1
  %38 = load float, float addrspace(3)* %7, align 4, !tbaa !1
  %39 = fmul contract float %37, %38
  %40 = fsub contract float %35, %39
  store float %40, float addrspace(3)* %19, align 4, !tbaa !1
  %41 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 4
  %42 = load float, float addrspace(3)* %41, align 16, !tbaa !1
  %43 = load float, float addrspace(3)* %8, align 4, !tbaa !1
  %44 = fmul contract float %42, %43
  %45 = fsub contract float %40, %44
  store float %45, float addrspace(3)* %19, align 4, !tbaa !1
  %46 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 5
  %47 = load float, float addrspace(3)* %46, align 4, !tbaa !1
  %48 = load float, float addrspace(3)* %9, align 4, !tbaa !1
  %49 = fmul contract float %47, %48
  %50 = fsub contract float %45, %49
  store float %50, float addrspace(3)* %19, align 4, !tbaa !1
  %51 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 6
  %52 = load float, float addrspace(3)* %51, align 8, !tbaa !1
  %53 = load float, float addrspace(3)* %10, align 4, !tbaa !1
  %54 = fmul contract float %52, %53
  %55 = fsub contract float %50, %54
  store float %55, float addrspace(3)* %19, align 4, !tbaa !1
  %56 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 7
  %57 = load float, float addrspace(3)* %56, align 4, !tbaa !1
  %58 = load float, float addrspace(3)* %11, align 4, !tbaa !1
  %59 = fmul contract float %57, %58
  %60 = fsub contract float %55, %59
  store float %60, float addrspace(3)* %19, align 4, !tbaa !1
  %61 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 8
  %62 = load float, float addrspace(3)* %61, align 16, !tbaa !1
  %63 = load float, float addrspace(3)* %12, align 4, !tbaa !1
  %64 = fmul contract float %62, %63
  %65 = fsub contract float %60, %64
  store float %65, float addrspace(3)* %19, align 4, !tbaa !1
  %66 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 9
  %67 = load float, float addrspace(3)* %66, align 4, !tbaa !1
  %68 = load float, float addrspace(3)* %13, align 4, !tbaa !1
  %69 = fmul contract float %67, %68
  %70 = fsub contract float %65, %69
  store float %70, float addrspace(3)* %19, align 4, !tbaa !1
  %71 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 10
  %72 = load float, float addrspace(3)* %71, align 8, !tbaa !1
  %73 = load float, float addrspace(3)* %14, align 4, !tbaa !1
  %74 = fmul contract float %72, %73
  %75 = fsub contract float %70, %74
  store float %75, float addrspace(3)* %19, align 4, !tbaa !1
  %76 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 11
  %77 = load float, float addrspace(3)* %76, align 4, !tbaa !1
  %78 = load float, float addrspace(3)* %15, align 4, !tbaa !1
  %79 = fmul contract float %77, %78
  %80 = fsub contract float %75, %79
  store float %80, float addrspace(3)* %19, align 4, !tbaa !1
  %81 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 12
  %82 = load float, float addrspace(3)* %81, align 16, !tbaa !1
  %83 = load float, float addrspace(3)* %16, align 4, !tbaa !1
  %84 = fmul contract float %82, %83
  %85 = fsub contract float %80, %84
  store float %85, float addrspace(3)* %19, align 4, !tbaa !1
  %86 = load float, float addrspace(3)* %17, align 4, !tbaa !1
  %87 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 13
  %88 = fdiv contract float %85, %86
  store float %88, float addrspace(3)* %87, align 4, !tbaa !1
  br label %89

89:                                               ; preds = %18, %3
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 2, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
