; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i32 %1, i32 %2, i32 %3, float addrspace(1)* %4, [8 x [8 x float]] addrspace(3)* %5, i32 %6, i64 %7, [8 x [8 x float]] addrspace(3)* %8, [8 x [8 x float]] addrspace(3)* %9, { float addrspace(3)*, i64 }* %10) #0 {
  br i1 %0, label %12, label %84

12:                                               ; preds = %11
  %13 = mul nsw i32 %1, %2
  %14 = add nsw i32 %13, %1
  %15 = add nsw i32 %14, %3
  %16 = sext i32 %15 to i64
  %17 = getelementptr inbounds float, float addrspace(1)* %4, i64 %16
  %18 = load float, float addrspace(1)* %17, align 4, !tbaa !4
  %19 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 0, i32 %3
  store float %18, float addrspace(3)* %19, align 4, !tbaa !4
  %20 = add nsw i32 %14, %2
  %21 = add nsw i32 %20, %3
  %22 = sext i32 %21 to i64
  %23 = getelementptr inbounds float, float addrspace(1)* %4, i64 %22
  %24 = load float, float addrspace(1)* %23, align 4, !tbaa !4
  %25 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 1, i32 %3
  store float %24, float addrspace(3)* %25, align 4, !tbaa !4
  %26 = add nsw i32 %20, %2
  %27 = add nsw i32 %26, %3
  %28 = sext i32 %27 to i64
  %29 = getelementptr inbounds float, float addrspace(1)* %4, i64 %28
  %30 = load float, float addrspace(1)* %29, align 4, !tbaa !4
  %31 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 2, i32 %3
  store float %30, float addrspace(3)* %31, align 4, !tbaa !4
  %32 = add nsw i32 %26, %2
  %33 = add nsw i32 %32, %3
  %34 = sext i32 %33 to i64
  %35 = getelementptr inbounds float, float addrspace(1)* %4, i64 %34
  %36 = load float, float addrspace(1)* %35, align 4, !tbaa !4
  %37 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 3, i32 %3
  store float %36, float addrspace(3)* %37, align 4, !tbaa !4
  %38 = zext i32 %6 to i64
  %39 = shl nuw nsw i64 %38, 3
  %40 = add nuw nsw i64 %7, 8
  %41 = add nuw nsw i64 %40, %39
  %42 = sext i32 %14 to i64
  %43 = add nsw i64 %41, %42
  %44 = getelementptr inbounds float, float addrspace(1)* %4, i64 %43
  %45 = load float, float addrspace(1)* %44, align 4, !tbaa !4
  %46 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 0, i32 %3
  store float %45, float addrspace(3)* %46, align 4, !tbaa !4
  %47 = sext i32 %20 to i64
  %48 = add nsw i64 %41, %47
  %49 = getelementptr inbounds float, float addrspace(1)* %4, i64 %48
  %50 = load float, float addrspace(1)* %49, align 4, !tbaa !4
  %51 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 1, i32 %3
  store float %50, float addrspace(3)* %51, align 4, !tbaa !4
  %52 = sext i32 %26 to i64
  %53 = add nsw i64 %41, %52
  %54 = getelementptr inbounds float, float addrspace(1)* %4, i64 %53
  %55 = load float, float addrspace(1)* %54, align 4, !tbaa !4
  %56 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 2, i32 %3
  store float %55, float addrspace(3)* %56, align 4, !tbaa !4
  %57 = sext i32 %32 to i64
  %58 = add nsw i64 %41, %57
  %59 = getelementptr inbounds float, float addrspace(1)* %4, i64 %58
  %60 = load float, float addrspace(1)* %59, align 4, !tbaa !4
  %61 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 3, i32 %3
  store float %60, float addrspace(3)* %61, align 4, !tbaa !4
  %62 = add nsw i32 %32, %2
  %63 = sext i32 %62 to i64
  %64 = add nsw i64 %41, %63
  %65 = getelementptr inbounds float, float addrspace(1)* %4, i64 %64
  %66 = load float, float addrspace(1)* %65, align 4, !tbaa !4
  %67 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 4, i32 %3
  store float %66, float addrspace(3)* %67, align 4, !tbaa !4
  %68 = add nsw i32 %62, %2
  %69 = sext i32 %68 to i64
  %70 = add nsw i64 %41, %69
  %71 = getelementptr inbounds float, float addrspace(1)* %4, i64 %70
  %72 = load float, float addrspace(1)* %71, align 4, !tbaa !4
  %73 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 5, i32 %3
  store float %72, float addrspace(3)* %73, align 4, !tbaa !4
  %74 = add nsw i32 %68, %2
  %75 = sext i32 %74 to i64
  %76 = add nsw i64 %41, %75
  %77 = getelementptr inbounds float, float addrspace(1)* %4, i64 %76
  %78 = load float, float addrspace(1)* %77, align 4, !tbaa !4
  %79 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 6, i32 %3
  store float %78, float addrspace(3)* %79, align 4, !tbaa !4
  %80 = add nsw i32 %74, %2
  %81 = sext i32 %80 to i64
  %82 = add nsw i64 %41, %81
  %83 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 7, i32 %3
  br label %162

84:                                               ; preds = %11
  %85 = add nsw i32 %3, -8
  %86 = add nsw i32 %1, 4
  %87 = mul nsw i32 %86, %2
  %88 = add nsw i32 %87, %1
  %89 = add nsw i32 %88, %85
  %90 = sext i32 %89 to i64
  %91 = getelementptr inbounds float, float addrspace(1)* %4, i64 %90
  %92 = load float, float addrspace(1)* %91, align 4, !tbaa !4
  %93 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 4, i32 %85
  store float %92, float addrspace(3)* %93, align 4, !tbaa !4
  %94 = add nsw i32 %88, %2
  %95 = add nsw i32 %94, %85
  %96 = sext i32 %95 to i64
  %97 = getelementptr inbounds float, float addrspace(1)* %4, i64 %96
  %98 = load float, float addrspace(1)* %97, align 4, !tbaa !4
  %99 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 5, i32 %85
  store float %98, float addrspace(3)* %99, align 4, !tbaa !4
  %100 = add nsw i32 %94, %2
  %101 = add nsw i32 %100, %85
  %102 = sext i32 %101 to i64
  %103 = getelementptr inbounds float, float addrspace(1)* %4, i64 %102
  %104 = load float, float addrspace(1)* %103, align 4, !tbaa !4
  %105 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 6, i32 %85
  store float %104, float addrspace(3)* %105, align 4, !tbaa !4
  %106 = add nsw i32 %100, %2
  %107 = add nsw i32 %106, %85
  %108 = sext i32 %107 to i64
  %109 = getelementptr inbounds float, float addrspace(1)* %4, i64 %108
  %110 = load float, float addrspace(1)* %109, align 4, !tbaa !4
  %111 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 7, i32 %85
  store float %110, float addrspace(3)* %111, align 4, !tbaa !4
  %112 = shl i32 %6, 3
  %113 = add i32 %1, 8
  %114 = add i32 %113, %112
  %115 = mul i32 %114, %2
  %116 = add i32 %115, %1
  %117 = add nsw i32 %116, %85
  %118 = sext i32 %117 to i64
  %119 = getelementptr inbounds float, float addrspace(1)* %4, i64 %118
  %120 = load float, float addrspace(1)* %119, align 4, !tbaa !4
  %121 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %9, i32 0, i32 0, i32 %85
  store float %120, float addrspace(3)* %121, align 4, !tbaa !4
  %122 = add nsw i32 %116, %2
  %123 = add nsw i32 %122, %85
  %124 = sext i32 %123 to i64
  %125 = getelementptr inbounds float, float addrspace(1)* %4, i64 %124
  %126 = load float, float addrspace(1)* %125, align 4, !tbaa !4
  %127 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %9, i32 0, i32 1, i32 %85
  store float %126, float addrspace(3)* %127, align 4, !tbaa !4
  %128 = add nsw i32 %122, %2
  %129 = add nsw i32 %128, %85
  %130 = sext i32 %129 to i64
  %131 = getelementptr inbounds float, float addrspace(1)* %4, i64 %130
  %132 = load float, float addrspace(1)* %131, align 4, !tbaa !4
  %133 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %9, i32 0, i32 2, i32 %85
  store float %132, float addrspace(3)* %133, align 4, !tbaa !4
  %134 = add nsw i32 %128, %2
  %135 = add nsw i32 %134, %85
  %136 = sext i32 %135 to i64
  %137 = getelementptr inbounds float, float addrspace(1)* %4, i64 %136
  %138 = load float, float addrspace(1)* %137, align 4, !tbaa !4
  %139 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %9, i32 0, i32 3, i32 %85
  store float %138, float addrspace(3)* %139, align 4, !tbaa !4
  %140 = add nsw i32 %134, %2
  %141 = add nsw i32 %140, %85
  %142 = sext i32 %141 to i64
  %143 = getelementptr inbounds float, float addrspace(1)* %4, i64 %142
  %144 = load float, float addrspace(1)* %143, align 4, !tbaa !4
  %145 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %9, i32 0, i32 4, i32 %85
  store float %144, float addrspace(3)* %145, align 4, !tbaa !4
  %146 = add nsw i32 %140, %2
  %147 = add nsw i32 %146, %85
  %148 = sext i32 %147 to i64
  %149 = getelementptr inbounds float, float addrspace(1)* %4, i64 %148
  %150 = load float, float addrspace(1)* %149, align 4, !tbaa !4
  %151 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %9, i32 0, i32 5, i32 %85
  store float %150, float addrspace(3)* %151, align 4, !tbaa !4
  %152 = add nsw i32 %146, %2
  %153 = add nsw i32 %152, %85
  %154 = sext i32 %153 to i64
  %155 = getelementptr inbounds float, float addrspace(1)* %4, i64 %154
  %156 = load float, float addrspace(1)* %155, align 4, !tbaa !4
  %157 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %9, i32 0, i32 6, i32 %85
  store float %156, float addrspace(3)* %157, align 4, !tbaa !4
  %158 = add nsw i32 %152, %2
  %159 = add nsw i32 %158, %85
  %160 = sext i32 %159 to i64
  %161 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %9, i32 0, i32 7, i32 %85
  br label %162

162:                                              ; preds = %84, %12
  %163 = phi float addrspace(3)* [ %83, %12 ], [ %161, %84 ]
  %164 = phi i64 [ %82, %12 ], [ %160, %84 ]
  %165 = getelementptr inbounds { float addrspace(3)*, i64 }, { float addrspace(3)*, i64 }* %10, i32 0, i32 0
  store float addrspace(3)* %163, float addrspace(3)** %165, align 4
  %166 = getelementptr inbounds { float addrspace(3)*, i64 }, { float addrspace(3)*, i64 }* %10, i32 0, i32 1
  store i64 %164, i64* %166, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0, !1}
!dataflow.builtin.operations = !{!2, !3}

!0 = !{i32 3, !"llvm.amdgcn.workitem.id.x"}
!1 = !{i32 6, !"llvm.amdgcn.workgroup.id.x"}
!2 = !{i32 0, i32 29, !"llvm.amdgcn.workgroup.id.x"}
!3 = !{i32 1, i32 31, !"llvm.amdgcn.workgroup.id.x"}
!4 = !{!5, !5, i64 0}
!5 = !{!"float", !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C++ TBAA"}
