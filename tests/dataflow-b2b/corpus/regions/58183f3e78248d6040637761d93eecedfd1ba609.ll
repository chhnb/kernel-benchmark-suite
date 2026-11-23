; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, float addrspace(3)* %1, [16 x [16 x float]] addrspace(3)* %2, i32 %3) #0 {
  %5 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 15, i32 0
  %6 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 15, i32 1
  %7 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 15, i32 2
  %8 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 15, i32 3
  %9 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 15, i32 4
  %10 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 15, i32 5
  %11 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 15, i32 6
  %12 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 15, i32 7
  %13 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 15, i32 8
  %14 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 15, i32 9
  %15 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 15, i32 10
  %16 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 15, i32 11
  %17 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 15, i32 12
  %18 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 15, i32 13
  %19 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 15, i32 14
  br i1 %0, label %20, label %97

20:                                               ; preds = %4
  %21 = load float, float addrspace(3)* %1, align 4, !tbaa !1
  %22 = load float, float addrspace(3)* %5, align 16, !tbaa !1
  %23 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 0, i32 %3
  %24 = load float, float addrspace(3)* %23, align 4, !tbaa !1
  %25 = fmul contract float %22, %24
  %26 = fsub contract float %21, %25
  store float %26, float addrspace(3)* %1, align 4, !tbaa !1
  %27 = load float, float addrspace(3)* %6, align 4, !tbaa !1
  %28 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 1, i32 %3
  %29 = load float, float addrspace(3)* %28, align 4, !tbaa !1
  %30 = fmul contract float %27, %29
  %31 = fsub contract float %26, %30
  store float %31, float addrspace(3)* %1, align 4, !tbaa !1
  %32 = load float, float addrspace(3)* %7, align 8, !tbaa !1
  %33 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 2, i32 %3
  %34 = load float, float addrspace(3)* %33, align 4, !tbaa !1
  %35 = fmul contract float %32, %34
  %36 = fsub contract float %31, %35
  store float %36, float addrspace(3)* %1, align 4, !tbaa !1
  %37 = load float, float addrspace(3)* %8, align 4, !tbaa !1
  %38 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 3, i32 %3
  %39 = load float, float addrspace(3)* %38, align 4, !tbaa !1
  %40 = fmul contract float %37, %39
  %41 = fsub contract float %36, %40
  store float %41, float addrspace(3)* %1, align 4, !tbaa !1
  %42 = load float, float addrspace(3)* %9, align 16, !tbaa !1
  %43 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 4, i32 %3
  %44 = load float, float addrspace(3)* %43, align 4, !tbaa !1
  %45 = fmul contract float %42, %44
  %46 = fsub contract float %41, %45
  store float %46, float addrspace(3)* %1, align 4, !tbaa !1
  %47 = load float, float addrspace(3)* %10, align 4, !tbaa !1
  %48 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 5, i32 %3
  %49 = load float, float addrspace(3)* %48, align 4, !tbaa !1
  %50 = fmul contract float %47, %49
  %51 = fsub contract float %46, %50
  store float %51, float addrspace(3)* %1, align 4, !tbaa !1
  %52 = load float, float addrspace(3)* %11, align 8, !tbaa !1
  %53 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 6, i32 %3
  %54 = load float, float addrspace(3)* %53, align 4, !tbaa !1
  %55 = fmul contract float %52, %54
  %56 = fsub contract float %51, %55
  store float %56, float addrspace(3)* %1, align 4, !tbaa !1
  %57 = load float, float addrspace(3)* %12, align 4, !tbaa !1
  %58 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 7, i32 %3
  %59 = load float, float addrspace(3)* %58, align 4, !tbaa !1
  %60 = fmul contract float %57, %59
  %61 = fsub contract float %56, %60
  store float %61, float addrspace(3)* %1, align 4, !tbaa !1
  %62 = load float, float addrspace(3)* %13, align 16, !tbaa !1
  %63 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 8, i32 %3
  %64 = load float, float addrspace(3)* %63, align 4, !tbaa !1
  %65 = fmul contract float %62, %64
  %66 = fsub contract float %61, %65
  store float %66, float addrspace(3)* %1, align 4, !tbaa !1
  %67 = load float, float addrspace(3)* %14, align 4, !tbaa !1
  %68 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 9, i32 %3
  %69 = load float, float addrspace(3)* %68, align 4, !tbaa !1
  %70 = fmul contract float %67, %69
  %71 = fsub contract float %66, %70
  store float %71, float addrspace(3)* %1, align 4, !tbaa !1
  %72 = load float, float addrspace(3)* %15, align 8, !tbaa !1
  %73 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 10, i32 %3
  %74 = load float, float addrspace(3)* %73, align 4, !tbaa !1
  %75 = fmul contract float %72, %74
  %76 = fsub contract float %71, %75
  store float %76, float addrspace(3)* %1, align 4, !tbaa !1
  %77 = load float, float addrspace(3)* %16, align 4, !tbaa !1
  %78 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 11, i32 %3
  %79 = load float, float addrspace(3)* %78, align 4, !tbaa !1
  %80 = fmul contract float %77, %79
  %81 = fsub contract float %76, %80
  store float %81, float addrspace(3)* %1, align 4, !tbaa !1
  %82 = load float, float addrspace(3)* %17, align 16, !tbaa !1
  %83 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 12, i32 %3
  %84 = load float, float addrspace(3)* %83, align 4, !tbaa !1
  %85 = fmul contract float %82, %84
  %86 = fsub contract float %81, %85
  store float %86, float addrspace(3)* %1, align 4, !tbaa !1
  %87 = load float, float addrspace(3)* %18, align 4, !tbaa !1
  %88 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 13, i32 %3
  %89 = load float, float addrspace(3)* %88, align 4, !tbaa !1
  %90 = fmul contract float %87, %89
  %91 = fsub contract float %86, %90
  store float %91, float addrspace(3)* %1, align 4, !tbaa !1
  %92 = load float, float addrspace(3)* %19, align 8, !tbaa !1
  %93 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %2, i32 0, i32 14, i32 %3
  %94 = load float, float addrspace(3)* %93, align 4, !tbaa !1
  %95 = fmul contract float %92, %94
  %96 = fsub contract float %91, %95
  store float %96, float addrspace(3)* %1, align 4, !tbaa !1
  br label %97

97:                                               ; preds = %20, %4
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 3, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
