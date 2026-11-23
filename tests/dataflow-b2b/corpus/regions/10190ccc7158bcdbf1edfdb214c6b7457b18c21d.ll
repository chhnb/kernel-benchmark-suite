; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i32 %1, i32 %2, i32 %3, i64 %4, [8 x [8 x float]] addrspace(3)* %5, i32 %6, float addrspace(1)* %7, [8 x [8 x float]] addrspace(3)* %8, { i64, float addrspace(3)* }* %9) #0 {
  br i1 %0, label %11, label %58

11:                                               ; preds = %10
  %12 = add nsw i32 %1, 1
  %13 = mul nsw i32 %12, %2
  %14 = add nsw i32 %13, %1
  %15 = zext i32 %3 to i64
  %16 = shl nuw nsw i64 %15, 3
  %17 = add nuw nsw i64 %4, 8
  %18 = add nuw nsw i64 %17, %16
  %19 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 1, i32 %6
  %20 = load float, float addrspace(3)* %19, align 4, !tbaa !4
  %21 = sext i32 %14 to i64
  %22 = add nsw i64 %18, %21
  %23 = getelementptr inbounds float, float addrspace(1)* %7, i64 %22
  store float %20, float addrspace(1)* %23, align 4, !tbaa !4
  %24 = add nsw i32 %14, %2
  %25 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 2, i32 %6
  %26 = load float, float addrspace(3)* %25, align 4, !tbaa !4
  %27 = sext i32 %24 to i64
  %28 = add nsw i64 %18, %27
  %29 = getelementptr inbounds float, float addrspace(1)* %7, i64 %28
  store float %26, float addrspace(1)* %29, align 4, !tbaa !4
  %30 = add nsw i32 %24, %2
  %31 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 3, i32 %6
  %32 = load float, float addrspace(3)* %31, align 4, !tbaa !4
  %33 = sext i32 %30 to i64
  %34 = add nsw i64 %18, %33
  %35 = getelementptr inbounds float, float addrspace(1)* %7, i64 %34
  store float %32, float addrspace(1)* %35, align 4, !tbaa !4
  %36 = add nsw i32 %30, %2
  %37 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 4, i32 %6
  %38 = load float, float addrspace(3)* %37, align 4, !tbaa !4
  %39 = sext i32 %36 to i64
  %40 = add nsw i64 %18, %39
  %41 = getelementptr inbounds float, float addrspace(1)* %7, i64 %40
  store float %38, float addrspace(1)* %41, align 4, !tbaa !4
  %42 = add nsw i32 %36, %2
  %43 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 5, i32 %6
  %44 = load float, float addrspace(3)* %43, align 4, !tbaa !4
  %45 = sext i32 %42 to i64
  %46 = add nsw i64 %18, %45
  %47 = getelementptr inbounds float, float addrspace(1)* %7, i64 %46
  store float %44, float addrspace(1)* %47, align 4, !tbaa !4
  %48 = add nsw i32 %42, %2
  %49 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 6, i32 %6
  %50 = load float, float addrspace(3)* %49, align 4, !tbaa !4
  %51 = sext i32 %48 to i64
  %52 = add nsw i64 %18, %51
  %53 = getelementptr inbounds float, float addrspace(1)* %7, i64 %52
  store float %50, float addrspace(1)* %53, align 4, !tbaa !4
  %54 = add nsw i32 %48, %2
  %55 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 7, i32 %6
  %56 = sext i32 %54 to i64
  %57 = add nsw i64 %18, %56
  br label %110

58:                                               ; preds = %10
  %59 = add nsw i32 %6, -8
  %60 = shl i32 %3, 3
  %61 = add i32 %1, 8
  %62 = add i32 %61, %60
  %63 = mul i32 %62, %2
  %64 = add i32 %63, %1
  %65 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 0, i32 %59
  %66 = load float, float addrspace(3)* %65, align 4, !tbaa !4
  %67 = add nsw i32 %64, %59
  %68 = sext i32 %67 to i64
  %69 = getelementptr inbounds float, float addrspace(1)* %7, i64 %68
  store float %66, float addrspace(1)* %69, align 4, !tbaa !4
  %70 = add nsw i32 %64, %2
  %71 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 1, i32 %59
  %72 = load float, float addrspace(3)* %71, align 4, !tbaa !4
  %73 = add nsw i32 %70, %59
  %74 = sext i32 %73 to i64
  %75 = getelementptr inbounds float, float addrspace(1)* %7, i64 %74
  store float %72, float addrspace(1)* %75, align 4, !tbaa !4
  %76 = add nsw i32 %70, %2
  %77 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 2, i32 %59
  %78 = load float, float addrspace(3)* %77, align 4, !tbaa !4
  %79 = add nsw i32 %76, %59
  %80 = sext i32 %79 to i64
  %81 = getelementptr inbounds float, float addrspace(1)* %7, i64 %80
  store float %78, float addrspace(1)* %81, align 4, !tbaa !4
  %82 = add nsw i32 %76, %2
  %83 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 3, i32 %59
  %84 = load float, float addrspace(3)* %83, align 4, !tbaa !4
  %85 = add nsw i32 %82, %59
  %86 = sext i32 %85 to i64
  %87 = getelementptr inbounds float, float addrspace(1)* %7, i64 %86
  store float %84, float addrspace(1)* %87, align 4, !tbaa !4
  %88 = add nsw i32 %82, %2
  %89 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 4, i32 %59
  %90 = load float, float addrspace(3)* %89, align 4, !tbaa !4
  %91 = add nsw i32 %88, %59
  %92 = sext i32 %91 to i64
  %93 = getelementptr inbounds float, float addrspace(1)* %7, i64 %92
  store float %90, float addrspace(1)* %93, align 4, !tbaa !4
  %94 = add nsw i32 %88, %2
  %95 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 5, i32 %59
  %96 = load float, float addrspace(3)* %95, align 4, !tbaa !4
  %97 = add nsw i32 %94, %59
  %98 = sext i32 %97 to i64
  %99 = getelementptr inbounds float, float addrspace(1)* %7, i64 %98
  store float %96, float addrspace(1)* %99, align 4, !tbaa !4
  %100 = add nsw i32 %94, %2
  %101 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 6, i32 %59
  %102 = load float, float addrspace(3)* %101, align 4, !tbaa !4
  %103 = add nsw i32 %100, %59
  %104 = sext i32 %103 to i64
  %105 = getelementptr inbounds float, float addrspace(1)* %7, i64 %104
  store float %102, float addrspace(1)* %105, align 4, !tbaa !4
  %106 = add nsw i32 %100, %2
  %107 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 7, i32 %59
  %108 = add nsw i32 %106, %59
  %109 = sext i32 %108 to i64
  br label %110

110:                                              ; preds = %58, %11
  %111 = phi i64 [ %57, %11 ], [ %109, %58 ]
  %112 = phi float addrspace(3)* [ %55, %11 ], [ %107, %58 ]
  %113 = getelementptr inbounds { i64, float addrspace(3)* }, { i64, float addrspace(3)* }* %9, i32 0, i32 0
  store i64 %111, i64* %113, align 8
  %114 = getelementptr inbounds { i64, float addrspace(3)* }, { i64, float addrspace(3)* }* %9, i32 0, i32 1
  store float addrspace(3)* %112, float addrspace(3)** %114, align 4
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0, !1}
!dataflow.builtin.operations = !{!2, !3}

!0 = !{i32 3, !"llvm.amdgcn.workgroup.id.x"}
!1 = !{i32 6, !"llvm.amdgcn.workitem.id.x"}
!2 = !{i32 0, i32 3, !"llvm.amdgcn.workgroup.id.x"}
!3 = !{i32 1, i32 1, !"llvm.amdgcn.workgroup.id.x"}
!4 = !{!5, !5, i64 0}
!5 = !{!"float", !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C++ TBAA"}
