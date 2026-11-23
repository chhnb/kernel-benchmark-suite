; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i32 %1, i32 %2, i32 %3, i64 %4, [8 x [8 x float]] addrspace(3)* %5, i32 %6, float addrspace(1)* %7, [8 x [8 x float]] addrspace(3)* %8, { i64, float addrspace(3)* }* %9) #0 {
  br i1 %0, label %11, label %70

11:                                               ; preds = %10
  %12 = add nsw i32 %1, 1
  %13 = mul nsw i32 %12, %2
  %14 = add nsw i32 %13, %1
  %15 = zext i32 %3 to i64
  %16 = shl nuw nsw i64 %15, 3
  %17 = add nuw nsw i64 %4, 8
  %18 = add nuw nsw i64 %17, %16
  %19 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 1, i32 %6
  %20 = bitcast float addrspace(3)* %19 to i32 addrspace(3)*
  %21 = load i32, i32 addrspace(3)* %20, align 4, !tbaa !4
  %22 = sext i32 %14 to i64
  %23 = add nsw i64 %18, %22
  %24 = getelementptr inbounds float, float addrspace(1)* %7, i64 %23
  %25 = bitcast float addrspace(1)* %24 to i32 addrspace(1)*
  store i32 %21, i32 addrspace(1)* %25, align 4, !tbaa !4
  %26 = add nsw i32 %14, %2
  %27 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 2, i32 %6
  %28 = bitcast float addrspace(3)* %27 to i32 addrspace(3)*
  %29 = load i32, i32 addrspace(3)* %28, align 4, !tbaa !4
  %30 = sext i32 %26 to i64
  %31 = add nsw i64 %18, %30
  %32 = getelementptr inbounds float, float addrspace(1)* %7, i64 %31
  %33 = bitcast float addrspace(1)* %32 to i32 addrspace(1)*
  store i32 %29, i32 addrspace(1)* %33, align 4, !tbaa !4
  %34 = add nsw i32 %26, %2
  %35 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 3, i32 %6
  %36 = bitcast float addrspace(3)* %35 to i32 addrspace(3)*
  %37 = load i32, i32 addrspace(3)* %36, align 4, !tbaa !4
  %38 = sext i32 %34 to i64
  %39 = add nsw i64 %18, %38
  %40 = getelementptr inbounds float, float addrspace(1)* %7, i64 %39
  %41 = bitcast float addrspace(1)* %40 to i32 addrspace(1)*
  store i32 %37, i32 addrspace(1)* %41, align 4, !tbaa !4
  %42 = add nsw i32 %34, %2
  %43 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 4, i32 %6
  %44 = bitcast float addrspace(3)* %43 to i32 addrspace(3)*
  %45 = load i32, i32 addrspace(3)* %44, align 4, !tbaa !4
  %46 = sext i32 %42 to i64
  %47 = add nsw i64 %18, %46
  %48 = getelementptr inbounds float, float addrspace(1)* %7, i64 %47
  %49 = bitcast float addrspace(1)* %48 to i32 addrspace(1)*
  store i32 %45, i32 addrspace(1)* %49, align 4, !tbaa !4
  %50 = add nsw i32 %42, %2
  %51 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 5, i32 %6
  %52 = bitcast float addrspace(3)* %51 to i32 addrspace(3)*
  %53 = load i32, i32 addrspace(3)* %52, align 4, !tbaa !4
  %54 = sext i32 %50 to i64
  %55 = add nsw i64 %18, %54
  %56 = getelementptr inbounds float, float addrspace(1)* %7, i64 %55
  %57 = bitcast float addrspace(1)* %56 to i32 addrspace(1)*
  store i32 %53, i32 addrspace(1)* %57, align 4, !tbaa !4
  %58 = add nsw i32 %50, %2
  %59 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 6, i32 %6
  %60 = bitcast float addrspace(3)* %59 to i32 addrspace(3)*
  %61 = load i32, i32 addrspace(3)* %60, align 4, !tbaa !4
  %62 = sext i32 %58 to i64
  %63 = add nsw i64 %18, %62
  %64 = getelementptr inbounds float, float addrspace(1)* %7, i64 %63
  %65 = bitcast float addrspace(1)* %64 to i32 addrspace(1)*
  store i32 %61, i32 addrspace(1)* %65, align 4, !tbaa !4
  %66 = add nsw i32 %58, %2
  %67 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 7, i32 %6
  %68 = sext i32 %66 to i64
  %69 = add nsw i64 %18, %68
  br label %136

70:                                               ; preds = %10
  %71 = add nsw i32 %6, -8
  %72 = shl i32 %3, 3
  %73 = add i32 %1, 8
  %74 = add i32 %73, %72
  %75 = mul i32 %74, %2
  %76 = add i32 %75, %1
  %77 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 0, i32 %71
  %78 = bitcast float addrspace(3)* %77 to i32 addrspace(3)*
  %79 = load i32, i32 addrspace(3)* %78, align 4, !tbaa !4
  %80 = add nsw i32 %76, %71
  %81 = sext i32 %80 to i64
  %82 = getelementptr inbounds float, float addrspace(1)* %7, i64 %81
  %83 = bitcast float addrspace(1)* %82 to i32 addrspace(1)*
  store i32 %79, i32 addrspace(1)* %83, align 4, !tbaa !4
  %84 = add nsw i32 %76, %2
  %85 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 1, i32 %71
  %86 = bitcast float addrspace(3)* %85 to i32 addrspace(3)*
  %87 = load i32, i32 addrspace(3)* %86, align 4, !tbaa !4
  %88 = add nsw i32 %84, %71
  %89 = sext i32 %88 to i64
  %90 = getelementptr inbounds float, float addrspace(1)* %7, i64 %89
  %91 = bitcast float addrspace(1)* %90 to i32 addrspace(1)*
  store i32 %87, i32 addrspace(1)* %91, align 4, !tbaa !4
  %92 = add nsw i32 %84, %2
  %93 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 2, i32 %71
  %94 = bitcast float addrspace(3)* %93 to i32 addrspace(3)*
  %95 = load i32, i32 addrspace(3)* %94, align 4, !tbaa !4
  %96 = add nsw i32 %92, %71
  %97 = sext i32 %96 to i64
  %98 = getelementptr inbounds float, float addrspace(1)* %7, i64 %97
  %99 = bitcast float addrspace(1)* %98 to i32 addrspace(1)*
  store i32 %95, i32 addrspace(1)* %99, align 4, !tbaa !4
  %100 = add nsw i32 %92, %2
  %101 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 3, i32 %71
  %102 = bitcast float addrspace(3)* %101 to i32 addrspace(3)*
  %103 = load i32, i32 addrspace(3)* %102, align 4, !tbaa !4
  %104 = add nsw i32 %100, %71
  %105 = sext i32 %104 to i64
  %106 = getelementptr inbounds float, float addrspace(1)* %7, i64 %105
  %107 = bitcast float addrspace(1)* %106 to i32 addrspace(1)*
  store i32 %103, i32 addrspace(1)* %107, align 4, !tbaa !4
  %108 = add nsw i32 %100, %2
  %109 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 4, i32 %71
  %110 = bitcast float addrspace(3)* %109 to i32 addrspace(3)*
  %111 = load i32, i32 addrspace(3)* %110, align 4, !tbaa !4
  %112 = add nsw i32 %108, %71
  %113 = sext i32 %112 to i64
  %114 = getelementptr inbounds float, float addrspace(1)* %7, i64 %113
  %115 = bitcast float addrspace(1)* %114 to i32 addrspace(1)*
  store i32 %111, i32 addrspace(1)* %115, align 4, !tbaa !4
  %116 = add nsw i32 %108, %2
  %117 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 5, i32 %71
  %118 = bitcast float addrspace(3)* %117 to i32 addrspace(3)*
  %119 = load i32, i32 addrspace(3)* %118, align 4, !tbaa !4
  %120 = add nsw i32 %116, %71
  %121 = sext i32 %120 to i64
  %122 = getelementptr inbounds float, float addrspace(1)* %7, i64 %121
  %123 = bitcast float addrspace(1)* %122 to i32 addrspace(1)*
  store i32 %119, i32 addrspace(1)* %123, align 4, !tbaa !4
  %124 = add nsw i32 %116, %2
  %125 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 6, i32 %71
  %126 = bitcast float addrspace(3)* %125 to i32 addrspace(3)*
  %127 = load i32, i32 addrspace(3)* %126, align 4, !tbaa !4
  %128 = add nsw i32 %124, %71
  %129 = sext i32 %128 to i64
  %130 = getelementptr inbounds float, float addrspace(1)* %7, i64 %129
  %131 = bitcast float addrspace(1)* %130 to i32 addrspace(1)*
  store i32 %127, i32 addrspace(1)* %131, align 4, !tbaa !4
  %132 = add nsw i32 %124, %2
  %133 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 7, i32 %71
  %134 = add nsw i32 %132, %71
  %135 = sext i32 %134 to i64
  br label %136

136:                                              ; preds = %70, %11
  %137 = phi i64 [ %69, %11 ], [ %135, %70 ]
  %138 = phi float addrspace(3)* [ %67, %11 ], [ %133, %70 ]
  %139 = getelementptr inbounds { i64, float addrspace(3)* }, { i64, float addrspace(3)* }* %9, i32 0, i32 0
  store i64 %137, i64* %139, align 8
  %140 = getelementptr inbounds { i64, float addrspace(3)* }, { i64, float addrspace(3)* }* %9, i32 0, i32 1
  store float addrspace(3)* %138, float addrspace(3)** %140, align 4
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,1024" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

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
