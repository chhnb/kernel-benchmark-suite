; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, [16 x [16 x float]] addrspace(3)* %1, i32 %2) #0 {
  %4 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 0, i32 14
  %5 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 1, i32 14
  %6 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 2, i32 14
  %7 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 3, i32 14
  %8 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 4, i32 14
  %9 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 5, i32 14
  %10 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 6, i32 14
  %11 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 7, i32 14
  %12 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 8, i32 14
  %13 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 9, i32 14
  %14 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 10, i32 14
  %15 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 11, i32 14
  %16 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 12, i32 14
  %17 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 13, i32 14
  %18 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 14, i32 14
  br i1 %0, label %19, label %95

19:                                               ; preds = %3
  %20 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 14
  %21 = load float, float addrspace(3)* %20, align 8, !tbaa !1
  %22 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 0
  %23 = load float, float addrspace(3)* %22, align 16, !tbaa !1
  %24 = load float, float addrspace(3)* %4, align 8, !tbaa !1
  %25 = fmul contract float %23, %24
  %26 = fsub contract float %21, %25
  store float %26, float addrspace(3)* %20, align 8, !tbaa !1
  %27 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 1
  %28 = load float, float addrspace(3)* %27, align 4, !tbaa !1
  %29 = load float, float addrspace(3)* %5, align 8, !tbaa !1
  %30 = fmul contract float %28, %29
  %31 = fsub contract float %26, %30
  store float %31, float addrspace(3)* %20, align 8, !tbaa !1
  %32 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 2
  %33 = load float, float addrspace(3)* %32, align 8, !tbaa !1
  %34 = load float, float addrspace(3)* %6, align 8, !tbaa !1
  %35 = fmul contract float %33, %34
  %36 = fsub contract float %31, %35
  store float %36, float addrspace(3)* %20, align 8, !tbaa !1
  %37 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 3
  %38 = load float, float addrspace(3)* %37, align 4, !tbaa !1
  %39 = load float, float addrspace(3)* %7, align 8, !tbaa !1
  %40 = fmul contract float %38, %39
  %41 = fsub contract float %36, %40
  store float %41, float addrspace(3)* %20, align 8, !tbaa !1
  %42 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 4
  %43 = load float, float addrspace(3)* %42, align 16, !tbaa !1
  %44 = load float, float addrspace(3)* %8, align 8, !tbaa !1
  %45 = fmul contract float %43, %44
  %46 = fsub contract float %41, %45
  store float %46, float addrspace(3)* %20, align 8, !tbaa !1
  %47 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 5
  %48 = load float, float addrspace(3)* %47, align 4, !tbaa !1
  %49 = load float, float addrspace(3)* %9, align 8, !tbaa !1
  %50 = fmul contract float %48, %49
  %51 = fsub contract float %46, %50
  store float %51, float addrspace(3)* %20, align 8, !tbaa !1
  %52 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 6
  %53 = load float, float addrspace(3)* %52, align 8, !tbaa !1
  %54 = load float, float addrspace(3)* %10, align 8, !tbaa !1
  %55 = fmul contract float %53, %54
  %56 = fsub contract float %51, %55
  store float %56, float addrspace(3)* %20, align 8, !tbaa !1
  %57 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 7
  %58 = load float, float addrspace(3)* %57, align 4, !tbaa !1
  %59 = load float, float addrspace(3)* %11, align 8, !tbaa !1
  %60 = fmul contract float %58, %59
  %61 = fsub contract float %56, %60
  store float %61, float addrspace(3)* %20, align 8, !tbaa !1
  %62 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 8
  %63 = load float, float addrspace(3)* %62, align 16, !tbaa !1
  %64 = load float, float addrspace(3)* %12, align 8, !tbaa !1
  %65 = fmul contract float %63, %64
  %66 = fsub contract float %61, %65
  store float %66, float addrspace(3)* %20, align 8, !tbaa !1
  %67 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 9
  %68 = load float, float addrspace(3)* %67, align 4, !tbaa !1
  %69 = load float, float addrspace(3)* %13, align 8, !tbaa !1
  %70 = fmul contract float %68, %69
  %71 = fsub contract float %66, %70
  store float %71, float addrspace(3)* %20, align 8, !tbaa !1
  %72 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 10
  %73 = load float, float addrspace(3)* %72, align 8, !tbaa !1
  %74 = load float, float addrspace(3)* %14, align 8, !tbaa !1
  %75 = fmul contract float %73, %74
  %76 = fsub contract float %71, %75
  store float %76, float addrspace(3)* %20, align 8, !tbaa !1
  %77 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 11
  %78 = load float, float addrspace(3)* %77, align 4, !tbaa !1
  %79 = load float, float addrspace(3)* %15, align 8, !tbaa !1
  %80 = fmul contract float %78, %79
  %81 = fsub contract float %76, %80
  store float %81, float addrspace(3)* %20, align 8, !tbaa !1
  %82 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 12
  %83 = load float, float addrspace(3)* %82, align 16, !tbaa !1
  %84 = load float, float addrspace(3)* %16, align 8, !tbaa !1
  %85 = fmul contract float %83, %84
  %86 = fsub contract float %81, %85
  store float %86, float addrspace(3)* %20, align 8, !tbaa !1
  %87 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 13
  %88 = load float, float addrspace(3)* %87, align 4, !tbaa !1
  %89 = load float, float addrspace(3)* %17, align 8, !tbaa !1
  %90 = fmul contract float %88, %89
  %91 = fsub contract float %86, %90
  store float %91, float addrspace(3)* %20, align 8, !tbaa !1
  %92 = load float, float addrspace(3)* %18, align 8, !tbaa !1
  %93 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 14
  %94 = fdiv contract float %91, %92
  store float %94, float addrspace(3)* %93, align 8, !tbaa !1
  br label %95

95:                                               ; preds = %19, %3
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 2, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
