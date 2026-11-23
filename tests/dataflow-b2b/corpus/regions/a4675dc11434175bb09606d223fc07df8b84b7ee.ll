; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i32 %1, i32 %2, i32 %3, i64 %4, [16 x [16 x float]] addrspace(3)* %5, i32 %6, float addrspace(1)* %7, [16 x [16 x float]] addrspace(3)* %8, { i64, float addrspace(3)* }* %9) #0 {
  br i1 %0, label %11, label %106

11:                                               ; preds = %10
  %12 = add nsw i32 %1, 1
  %13 = mul nsw i32 %12, %2
  %14 = add nsw i32 %13, %1
  %15 = zext i32 %3 to i64
  %16 = shl nuw nsw i64 %15, 4
  %17 = add nuw nsw i64 %4, 16
  %18 = add nuw nsw i64 %17, %16
  %19 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 1, i32 %6
  %20 = load float, float addrspace(3)* %19, align 4, !tbaa !4
  %21 = sext i32 %14 to i64
  %22 = add nsw i64 %18, %21
  %23 = getelementptr inbounds float, float addrspace(1)* %7, i64 %22
  store float %20, float addrspace(1)* %23, align 4, !tbaa !4
  %24 = add nsw i32 %14, %2
  %25 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 2, i32 %6
  %26 = load float, float addrspace(3)* %25, align 4, !tbaa !4
  %27 = sext i32 %24 to i64
  %28 = add nsw i64 %18, %27
  %29 = getelementptr inbounds float, float addrspace(1)* %7, i64 %28
  store float %26, float addrspace(1)* %29, align 4, !tbaa !4
  %30 = add nsw i32 %24, %2
  %31 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 3, i32 %6
  %32 = load float, float addrspace(3)* %31, align 4, !tbaa !4
  %33 = sext i32 %30 to i64
  %34 = add nsw i64 %18, %33
  %35 = getelementptr inbounds float, float addrspace(1)* %7, i64 %34
  store float %32, float addrspace(1)* %35, align 4, !tbaa !4
  %36 = add nsw i32 %30, %2
  %37 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 4, i32 %6
  %38 = load float, float addrspace(3)* %37, align 4, !tbaa !4
  %39 = sext i32 %36 to i64
  %40 = add nsw i64 %18, %39
  %41 = getelementptr inbounds float, float addrspace(1)* %7, i64 %40
  store float %38, float addrspace(1)* %41, align 4, !tbaa !4
  %42 = add nsw i32 %36, %2
  %43 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 5, i32 %6
  %44 = load float, float addrspace(3)* %43, align 4, !tbaa !4
  %45 = sext i32 %42 to i64
  %46 = add nsw i64 %18, %45
  %47 = getelementptr inbounds float, float addrspace(1)* %7, i64 %46
  store float %44, float addrspace(1)* %47, align 4, !tbaa !4
  %48 = add nsw i32 %42, %2
  %49 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 6, i32 %6
  %50 = load float, float addrspace(3)* %49, align 4, !tbaa !4
  %51 = sext i32 %48 to i64
  %52 = add nsw i64 %18, %51
  %53 = getelementptr inbounds float, float addrspace(1)* %7, i64 %52
  store float %50, float addrspace(1)* %53, align 4, !tbaa !4
  %54 = add nsw i32 %48, %2
  %55 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 7, i32 %6
  %56 = load float, float addrspace(3)* %55, align 4, !tbaa !4
  %57 = sext i32 %54 to i64
  %58 = add nsw i64 %18, %57
  %59 = getelementptr inbounds float, float addrspace(1)* %7, i64 %58
  store float %56, float addrspace(1)* %59, align 4, !tbaa !4
  %60 = add nsw i32 %54, %2
  %61 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 8, i32 %6
  %62 = load float, float addrspace(3)* %61, align 4, !tbaa !4
  %63 = sext i32 %60 to i64
  %64 = add nsw i64 %18, %63
  %65 = getelementptr inbounds float, float addrspace(1)* %7, i64 %64
  store float %62, float addrspace(1)* %65, align 4, !tbaa !4
  %66 = add nsw i32 %60, %2
  %67 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 9, i32 %6
  %68 = load float, float addrspace(3)* %67, align 4, !tbaa !4
  %69 = sext i32 %66 to i64
  %70 = add nsw i64 %18, %69
  %71 = getelementptr inbounds float, float addrspace(1)* %7, i64 %70
  store float %68, float addrspace(1)* %71, align 4, !tbaa !4
  %72 = add nsw i32 %66, %2
  %73 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 10, i32 %6
  %74 = load float, float addrspace(3)* %73, align 4, !tbaa !4
  %75 = sext i32 %72 to i64
  %76 = add nsw i64 %18, %75
  %77 = getelementptr inbounds float, float addrspace(1)* %7, i64 %76
  store float %74, float addrspace(1)* %77, align 4, !tbaa !4
  %78 = add nsw i32 %72, %2
  %79 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 11, i32 %6
  %80 = load float, float addrspace(3)* %79, align 4, !tbaa !4
  %81 = sext i32 %78 to i64
  %82 = add nsw i64 %18, %81
  %83 = getelementptr inbounds float, float addrspace(1)* %7, i64 %82
  store float %80, float addrspace(1)* %83, align 4, !tbaa !4
  %84 = add nsw i32 %78, %2
  %85 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 12, i32 %6
  %86 = load float, float addrspace(3)* %85, align 4, !tbaa !4
  %87 = sext i32 %84 to i64
  %88 = add nsw i64 %18, %87
  %89 = getelementptr inbounds float, float addrspace(1)* %7, i64 %88
  store float %86, float addrspace(1)* %89, align 4, !tbaa !4
  %90 = add nsw i32 %84, %2
  %91 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 13, i32 %6
  %92 = load float, float addrspace(3)* %91, align 4, !tbaa !4
  %93 = sext i32 %90 to i64
  %94 = add nsw i64 %18, %93
  %95 = getelementptr inbounds float, float addrspace(1)* %7, i64 %94
  store float %92, float addrspace(1)* %95, align 4, !tbaa !4
  %96 = add nsw i32 %90, %2
  %97 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 14, i32 %6
  %98 = load float, float addrspace(3)* %97, align 4, !tbaa !4
  %99 = sext i32 %96 to i64
  %100 = add nsw i64 %18, %99
  %101 = getelementptr inbounds float, float addrspace(1)* %7, i64 %100
  store float %98, float addrspace(1)* %101, align 4, !tbaa !4
  %102 = add nsw i32 %96, %2
  %103 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 15, i32 %6
  %104 = sext i32 %102 to i64
  %105 = add nsw i64 %18, %104
  br label %206

106:                                              ; preds = %10
  %107 = add nsw i32 %6, -16
  %108 = shl i32 %3, 4
  %109 = add i32 %1, 16
  %110 = add i32 %109, %108
  %111 = mul i32 %110, %2
  %112 = add i32 %111, %1
  %113 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 0, i32 %107
  %114 = load float, float addrspace(3)* %113, align 4, !tbaa !4
  %115 = add nsw i32 %112, %107
  %116 = sext i32 %115 to i64
  %117 = getelementptr inbounds float, float addrspace(1)* %7, i64 %116
  store float %114, float addrspace(1)* %117, align 4, !tbaa !4
  %118 = add nsw i32 %112, %2
  %119 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 1, i32 %107
  %120 = load float, float addrspace(3)* %119, align 4, !tbaa !4
  %121 = add nsw i32 %118, %107
  %122 = sext i32 %121 to i64
  %123 = getelementptr inbounds float, float addrspace(1)* %7, i64 %122
  store float %120, float addrspace(1)* %123, align 4, !tbaa !4
  %124 = add nsw i32 %118, %2
  %125 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 2, i32 %107
  %126 = load float, float addrspace(3)* %125, align 4, !tbaa !4
  %127 = add nsw i32 %124, %107
  %128 = sext i32 %127 to i64
  %129 = getelementptr inbounds float, float addrspace(1)* %7, i64 %128
  store float %126, float addrspace(1)* %129, align 4, !tbaa !4
  %130 = add nsw i32 %124, %2
  %131 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 3, i32 %107
  %132 = load float, float addrspace(3)* %131, align 4, !tbaa !4
  %133 = add nsw i32 %130, %107
  %134 = sext i32 %133 to i64
  %135 = getelementptr inbounds float, float addrspace(1)* %7, i64 %134
  store float %132, float addrspace(1)* %135, align 4, !tbaa !4
  %136 = add nsw i32 %130, %2
  %137 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 4, i32 %107
  %138 = load float, float addrspace(3)* %137, align 4, !tbaa !4
  %139 = add nsw i32 %136, %107
  %140 = sext i32 %139 to i64
  %141 = getelementptr inbounds float, float addrspace(1)* %7, i64 %140
  store float %138, float addrspace(1)* %141, align 4, !tbaa !4
  %142 = add nsw i32 %136, %2
  %143 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 5, i32 %107
  %144 = load float, float addrspace(3)* %143, align 4, !tbaa !4
  %145 = add nsw i32 %142, %107
  %146 = sext i32 %145 to i64
  %147 = getelementptr inbounds float, float addrspace(1)* %7, i64 %146
  store float %144, float addrspace(1)* %147, align 4, !tbaa !4
  %148 = add nsw i32 %142, %2
  %149 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 6, i32 %107
  %150 = load float, float addrspace(3)* %149, align 4, !tbaa !4
  %151 = add nsw i32 %148, %107
  %152 = sext i32 %151 to i64
  %153 = getelementptr inbounds float, float addrspace(1)* %7, i64 %152
  store float %150, float addrspace(1)* %153, align 4, !tbaa !4
  %154 = add nsw i32 %148, %2
  %155 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 7, i32 %107
  %156 = load float, float addrspace(3)* %155, align 4, !tbaa !4
  %157 = add nsw i32 %154, %107
  %158 = sext i32 %157 to i64
  %159 = getelementptr inbounds float, float addrspace(1)* %7, i64 %158
  store float %156, float addrspace(1)* %159, align 4, !tbaa !4
  %160 = add nsw i32 %154, %2
  %161 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 8, i32 %107
  %162 = load float, float addrspace(3)* %161, align 4, !tbaa !4
  %163 = add nsw i32 %160, %107
  %164 = sext i32 %163 to i64
  %165 = getelementptr inbounds float, float addrspace(1)* %7, i64 %164
  store float %162, float addrspace(1)* %165, align 4, !tbaa !4
  %166 = add nsw i32 %160, %2
  %167 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 9, i32 %107
  %168 = load float, float addrspace(3)* %167, align 4, !tbaa !4
  %169 = add nsw i32 %166, %107
  %170 = sext i32 %169 to i64
  %171 = getelementptr inbounds float, float addrspace(1)* %7, i64 %170
  store float %168, float addrspace(1)* %171, align 4, !tbaa !4
  %172 = add nsw i32 %166, %2
  %173 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 10, i32 %107
  %174 = load float, float addrspace(3)* %173, align 4, !tbaa !4
  %175 = add nsw i32 %172, %107
  %176 = sext i32 %175 to i64
  %177 = getelementptr inbounds float, float addrspace(1)* %7, i64 %176
  store float %174, float addrspace(1)* %177, align 4, !tbaa !4
  %178 = add nsw i32 %172, %2
  %179 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 11, i32 %107
  %180 = load float, float addrspace(3)* %179, align 4, !tbaa !4
  %181 = add nsw i32 %178, %107
  %182 = sext i32 %181 to i64
  %183 = getelementptr inbounds float, float addrspace(1)* %7, i64 %182
  store float %180, float addrspace(1)* %183, align 4, !tbaa !4
  %184 = add nsw i32 %178, %2
  %185 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 12, i32 %107
  %186 = load float, float addrspace(3)* %185, align 4, !tbaa !4
  %187 = add nsw i32 %184, %107
  %188 = sext i32 %187 to i64
  %189 = getelementptr inbounds float, float addrspace(1)* %7, i64 %188
  store float %186, float addrspace(1)* %189, align 4, !tbaa !4
  %190 = add nsw i32 %184, %2
  %191 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 13, i32 %107
  %192 = load float, float addrspace(3)* %191, align 4, !tbaa !4
  %193 = add nsw i32 %190, %107
  %194 = sext i32 %193 to i64
  %195 = getelementptr inbounds float, float addrspace(1)* %7, i64 %194
  store float %192, float addrspace(1)* %195, align 4, !tbaa !4
  %196 = add nsw i32 %190, %2
  %197 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 14, i32 %107
  %198 = load float, float addrspace(3)* %197, align 4, !tbaa !4
  %199 = add nsw i32 %196, %107
  %200 = sext i32 %199 to i64
  %201 = getelementptr inbounds float, float addrspace(1)* %7, i64 %200
  store float %198, float addrspace(1)* %201, align 4, !tbaa !4
  %202 = add nsw i32 %196, %2
  %203 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 15, i32 %107
  %204 = add nsw i32 %202, %107
  %205 = sext i32 %204 to i64
  br label %206

206:                                              ; preds = %106, %11
  %207 = phi i64 [ %105, %11 ], [ %205, %106 ]
  %208 = phi float addrspace(3)* [ %103, %11 ], [ %203, %106 ]
  %209 = getelementptr inbounds { i64, float addrspace(3)* }, { i64, float addrspace(3)* }* %9, i32 0, i32 0
  store i64 %207, i64* %209, align 8
  %210 = getelementptr inbounds { i64, float addrspace(3)* }, { i64, float addrspace(3)* }* %9, i32 0, i32 1
  store float addrspace(3)* %208, float addrspace(3)** %210, align 4
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
