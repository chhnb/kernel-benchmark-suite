; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define i64 @region(i1 %0, i32 %1, i32 %2, i32 %3, i32 %4, i64 %5, float addrspace(3)* %6, float addrspace(1)* %7, float addrspace(3)* %8, float addrspace(3)* %9, float addrspace(3)* %10, float addrspace(3)* %11, float addrspace(3)* %12, [8 x [8 x float]] addrspace(3)* %13) #0 {
  br i1 %0, label %15, label %54

15:                                               ; preds = %14
  %16 = mul nsw i32 %1, %2
  %17 = add nsw i32 %16, %3
  %18 = zext i32 %4 to i64
  %19 = shl nuw nsw i64 %18, 3
  %20 = add nuw nsw i64 %5, 8
  %21 = add nuw nsw i64 %20, %19
  %22 = load float, float addrspace(3)* %6, align 4, !tbaa !3
  %23 = sext i32 %17 to i64
  %24 = add nsw i64 %21, %23
  %25 = getelementptr inbounds float, float addrspace(1)* %7, i64 %24
  store float %22, float addrspace(1)* %25, align 4, !tbaa !3
  %26 = add nsw i32 %17, %2
  %27 = load float, float addrspace(3)* %8, align 4, !tbaa !3
  %28 = sext i32 %26 to i64
  %29 = add nsw i64 %21, %28
  %30 = getelementptr inbounds float, float addrspace(1)* %7, i64 %29
  store float %27, float addrspace(1)* %30, align 4, !tbaa !3
  %31 = add nsw i32 %26, %2
  %32 = load float, float addrspace(3)* %9, align 4, !tbaa !3
  %33 = sext i32 %31 to i64
  %34 = add nsw i64 %21, %33
  %35 = getelementptr inbounds float, float addrspace(1)* %7, i64 %34
  store float %32, float addrspace(1)* %35, align 4, !tbaa !3
  %36 = add nsw i32 %31, %2
  %37 = load float, float addrspace(3)* %10, align 4, !tbaa !3
  %38 = sext i32 %36 to i64
  %39 = add nsw i64 %21, %38
  %40 = getelementptr inbounds float, float addrspace(1)* %7, i64 %39
  store float %37, float addrspace(1)* %40, align 4, !tbaa !3
  %41 = add nsw i32 %36, %2
  %42 = load float, float addrspace(3)* %11, align 4, !tbaa !3
  %43 = sext i32 %41 to i64
  %44 = add nsw i64 %21, %43
  %45 = getelementptr inbounds float, float addrspace(1)* %7, i64 %44
  store float %42, float addrspace(1)* %45, align 4, !tbaa !3
  %46 = add nsw i32 %41, %2
  %47 = load float, float addrspace(3)* %12, align 4, !tbaa !3
  %48 = sext i32 %46 to i64
  %49 = add nsw i64 %21, %48
  %50 = getelementptr inbounds float, float addrspace(1)* %7, i64 %49
  store float %47, float addrspace(1)* %50, align 4, !tbaa !3
  %51 = add nsw i32 %46, %2
  %52 = sext i32 %51 to i64
  %53 = add nsw i64 %21, %52
  br label %98

54:                                               ; preds = %14
  %55 = shl i32 %4, 3
  %56 = add i32 %3, 8
  %57 = add i32 %56, %55
  %58 = mul i32 %57, %2
  %59 = add i32 %58, %3
  %60 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %13, i32 0, i32 0, i32 %1
  %61 = load float, float addrspace(3)* %60, align 4, !tbaa !3
  %62 = add nsw i32 %59, %1
  %63 = sext i32 %62 to i64
  %64 = getelementptr inbounds float, float addrspace(1)* %7, i64 %63
  store float %61, float addrspace(1)* %64, align 4, !tbaa !3
  %65 = add nsw i32 %59, %2
  %66 = load float, float addrspace(3)* %6, align 4, !tbaa !3
  %67 = add nsw i32 %65, %1
  %68 = sext i32 %67 to i64
  %69 = getelementptr inbounds float, float addrspace(1)* %7, i64 %68
  store float %66, float addrspace(1)* %69, align 4, !tbaa !3
  %70 = add nsw i32 %65, %2
  %71 = load float, float addrspace(3)* %8, align 4, !tbaa !3
  %72 = add nsw i32 %70, %1
  %73 = sext i32 %72 to i64
  %74 = getelementptr inbounds float, float addrspace(1)* %7, i64 %73
  store float %71, float addrspace(1)* %74, align 4, !tbaa !3
  %75 = add nsw i32 %70, %2
  %76 = load float, float addrspace(3)* %9, align 4, !tbaa !3
  %77 = add nsw i32 %75, %1
  %78 = sext i32 %77 to i64
  %79 = getelementptr inbounds float, float addrspace(1)* %7, i64 %78
  store float %76, float addrspace(1)* %79, align 4, !tbaa !3
  %80 = add nsw i32 %75, %2
  %81 = load float, float addrspace(3)* %10, align 4, !tbaa !3
  %82 = add nsw i32 %80, %1
  %83 = sext i32 %82 to i64
  %84 = getelementptr inbounds float, float addrspace(1)* %7, i64 %83
  store float %81, float addrspace(1)* %84, align 4, !tbaa !3
  %85 = add nsw i32 %80, %2
  %86 = load float, float addrspace(3)* %11, align 4, !tbaa !3
  %87 = add nsw i32 %85, %1
  %88 = sext i32 %87 to i64
  %89 = getelementptr inbounds float, float addrspace(1)* %7, i64 %88
  store float %86, float addrspace(1)* %89, align 4, !tbaa !3
  %90 = add nsw i32 %85, %2
  %91 = load float, float addrspace(3)* %12, align 4, !tbaa !3
  %92 = add nsw i32 %90, %1
  %93 = sext i32 %92 to i64
  %94 = getelementptr inbounds float, float addrspace(1)* %7, i64 %93
  store float %91, float addrspace(1)* %94, align 4, !tbaa !3
  %95 = add nsw i32 %90, %2
  %96 = add nsw i32 %95, %1
  %97 = sext i32 %96 to i64
  br label %98

98:                                               ; preds = %54, %15
  %99 = phi i64 [ %53, %15 ], [ %97, %54 ]
  ret i64 %99
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}
!dataflow.builtin.operations = !{!1, !2}

!0 = !{i32 4, !"llvm.amdgcn.workgroup.id.x"}
!1 = !{i32 0, i32 2, !"llvm.amdgcn.workgroup.id.x"}
!2 = !{i32 1, i32 0, !"llvm.amdgcn.workgroup.id.x"}
!3 = !{!4, !4, i64 0}
!4 = !{!"float", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C++ TBAA"}
