; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i32 %1, i32 %2, i32 %3, float addrspace(1)* %4, [8 x [8 x float]] addrspace(3)* %5, i32 %6, i64 %7, [8 x [8 x float]] addrspace(3)* %8, [8 x [8 x float]] addrspace(3)* %9, { float addrspace(3)*, i64 }* %10) #0 {
  br i1 %0, label %12, label %106

12:                                               ; preds = %11
  %13 = mul nsw i32 %1, %2
  %14 = add nsw i32 %13, %1
  %15 = add nsw i32 %14, %3
  %16 = sext i32 %15 to i64
  %17 = getelementptr inbounds float, float addrspace(1)* %4, i64 %16
  %18 = bitcast float addrspace(1)* %17 to i32 addrspace(1)*
  %19 = load i32, i32 addrspace(1)* %18, align 4, !tbaa !4
  %20 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 0, i32 %3
  %21 = bitcast float addrspace(3)* %20 to i32 addrspace(3)*
  store i32 %19, i32 addrspace(3)* %21, align 4, !tbaa !4
  %22 = add nsw i32 %14, %2
  %23 = add nsw i32 %22, %3
  %24 = sext i32 %23 to i64
  %25 = getelementptr inbounds float, float addrspace(1)* %4, i64 %24
  %26 = bitcast float addrspace(1)* %25 to i32 addrspace(1)*
  %27 = load i32, i32 addrspace(1)* %26, align 4, !tbaa !4
  %28 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 1, i32 %3
  %29 = bitcast float addrspace(3)* %28 to i32 addrspace(3)*
  store i32 %27, i32 addrspace(3)* %29, align 4, !tbaa !4
  %30 = add nsw i32 %22, %2
  %31 = add nsw i32 %30, %3
  %32 = sext i32 %31 to i64
  %33 = getelementptr inbounds float, float addrspace(1)* %4, i64 %32
  %34 = bitcast float addrspace(1)* %33 to i32 addrspace(1)*
  %35 = load i32, i32 addrspace(1)* %34, align 4, !tbaa !4
  %36 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 2, i32 %3
  %37 = bitcast float addrspace(3)* %36 to i32 addrspace(3)*
  store i32 %35, i32 addrspace(3)* %37, align 4, !tbaa !4
  %38 = add nsw i32 %30, %2
  %39 = add nsw i32 %38, %3
  %40 = sext i32 %39 to i64
  %41 = getelementptr inbounds float, float addrspace(1)* %4, i64 %40
  %42 = bitcast float addrspace(1)* %41 to i32 addrspace(1)*
  %43 = load i32, i32 addrspace(1)* %42, align 4, !tbaa !4
  %44 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 3, i32 %3
  %45 = bitcast float addrspace(3)* %44 to i32 addrspace(3)*
  store i32 %43, i32 addrspace(3)* %45, align 4, !tbaa !4
  %46 = zext i32 %6 to i64
  %47 = shl nuw nsw i64 %46, 3
  %48 = add nuw nsw i64 %7, 8
  %49 = add nuw nsw i64 %48, %47
  %50 = sext i32 %14 to i64
  %51 = add nsw i64 %49, %50
  %52 = getelementptr inbounds float, float addrspace(1)* %4, i64 %51
  %53 = bitcast float addrspace(1)* %52 to i32 addrspace(1)*
  %54 = load i32, i32 addrspace(1)* %53, align 4, !tbaa !4
  %55 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 0, i32 %3
  %56 = bitcast float addrspace(3)* %55 to i32 addrspace(3)*
  store i32 %54, i32 addrspace(3)* %56, align 4, !tbaa !4
  %57 = sext i32 %22 to i64
  %58 = add nsw i64 %49, %57
  %59 = getelementptr inbounds float, float addrspace(1)* %4, i64 %58
  %60 = bitcast float addrspace(1)* %59 to i32 addrspace(1)*
  %61 = load i32, i32 addrspace(1)* %60, align 4, !tbaa !4
  %62 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 1, i32 %3
  %63 = bitcast float addrspace(3)* %62 to i32 addrspace(3)*
  store i32 %61, i32 addrspace(3)* %63, align 4, !tbaa !4
  %64 = sext i32 %30 to i64
  %65 = add nsw i64 %49, %64
  %66 = getelementptr inbounds float, float addrspace(1)* %4, i64 %65
  %67 = bitcast float addrspace(1)* %66 to i32 addrspace(1)*
  %68 = load i32, i32 addrspace(1)* %67, align 4, !tbaa !4
  %69 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 2, i32 %3
  %70 = bitcast float addrspace(3)* %69 to i32 addrspace(3)*
  store i32 %68, i32 addrspace(3)* %70, align 4, !tbaa !4
  %71 = sext i32 %38 to i64
  %72 = add nsw i64 %49, %71
  %73 = getelementptr inbounds float, float addrspace(1)* %4, i64 %72
  %74 = bitcast float addrspace(1)* %73 to i32 addrspace(1)*
  %75 = load i32, i32 addrspace(1)* %74, align 4, !tbaa !4
  %76 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 3, i32 %3
  %77 = bitcast float addrspace(3)* %76 to i32 addrspace(3)*
  store i32 %75, i32 addrspace(3)* %77, align 4, !tbaa !4
  %78 = add nsw i32 %38, %2
  %79 = sext i32 %78 to i64
  %80 = add nsw i64 %49, %79
  %81 = getelementptr inbounds float, float addrspace(1)* %4, i64 %80
  %82 = bitcast float addrspace(1)* %81 to i32 addrspace(1)*
  %83 = load i32, i32 addrspace(1)* %82, align 4, !tbaa !4
  %84 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 4, i32 %3
  %85 = bitcast float addrspace(3)* %84 to i32 addrspace(3)*
  store i32 %83, i32 addrspace(3)* %85, align 4, !tbaa !4
  %86 = add nsw i32 %78, %2
  %87 = sext i32 %86 to i64
  %88 = add nsw i64 %49, %87
  %89 = getelementptr inbounds float, float addrspace(1)* %4, i64 %88
  %90 = bitcast float addrspace(1)* %89 to i32 addrspace(1)*
  %91 = load i32, i32 addrspace(1)* %90, align 4, !tbaa !4
  %92 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 5, i32 %3
  %93 = bitcast float addrspace(3)* %92 to i32 addrspace(3)*
  store i32 %91, i32 addrspace(3)* %93, align 4, !tbaa !4
  %94 = add nsw i32 %86, %2
  %95 = sext i32 %94 to i64
  %96 = add nsw i64 %49, %95
  %97 = getelementptr inbounds float, float addrspace(1)* %4, i64 %96
  %98 = bitcast float addrspace(1)* %97 to i32 addrspace(1)*
  %99 = load i32, i32 addrspace(1)* %98, align 4, !tbaa !4
  %100 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 6, i32 %3
  %101 = bitcast float addrspace(3)* %100 to i32 addrspace(3)*
  store i32 %99, i32 addrspace(3)* %101, align 4, !tbaa !4
  %102 = add nsw i32 %94, %2
  %103 = sext i32 %102 to i64
  %104 = add nsw i64 %49, %103
  %105 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %8, i32 0, i32 7, i32 %3
  br label %206

106:                                              ; preds = %11
  %107 = add nsw i32 %3, -8
  %108 = add nsw i32 %1, 4
  %109 = mul nsw i32 %108, %2
  %110 = add nsw i32 %109, %1
  %111 = add nsw i32 %110, %107
  %112 = sext i32 %111 to i64
  %113 = getelementptr inbounds float, float addrspace(1)* %4, i64 %112
  %114 = bitcast float addrspace(1)* %113 to i32 addrspace(1)*
  %115 = load i32, i32 addrspace(1)* %114, align 4, !tbaa !4
  %116 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 4, i32 %107
  %117 = bitcast float addrspace(3)* %116 to i32 addrspace(3)*
  store i32 %115, i32 addrspace(3)* %117, align 4, !tbaa !4
  %118 = add nsw i32 %110, %2
  %119 = add nsw i32 %118, %107
  %120 = sext i32 %119 to i64
  %121 = getelementptr inbounds float, float addrspace(1)* %4, i64 %120
  %122 = bitcast float addrspace(1)* %121 to i32 addrspace(1)*
  %123 = load i32, i32 addrspace(1)* %122, align 4, !tbaa !4
  %124 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 5, i32 %107
  %125 = bitcast float addrspace(3)* %124 to i32 addrspace(3)*
  store i32 %123, i32 addrspace(3)* %125, align 4, !tbaa !4
  %126 = add nsw i32 %118, %2
  %127 = add nsw i32 %126, %107
  %128 = sext i32 %127 to i64
  %129 = getelementptr inbounds float, float addrspace(1)* %4, i64 %128
  %130 = bitcast float addrspace(1)* %129 to i32 addrspace(1)*
  %131 = load i32, i32 addrspace(1)* %130, align 4, !tbaa !4
  %132 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 6, i32 %107
  %133 = bitcast float addrspace(3)* %132 to i32 addrspace(3)*
  store i32 %131, i32 addrspace(3)* %133, align 4, !tbaa !4
  %134 = add nsw i32 %126, %2
  %135 = add nsw i32 %134, %107
  %136 = sext i32 %135 to i64
  %137 = getelementptr inbounds float, float addrspace(1)* %4, i64 %136
  %138 = bitcast float addrspace(1)* %137 to i32 addrspace(1)*
  %139 = load i32, i32 addrspace(1)* %138, align 4, !tbaa !4
  %140 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %5, i32 0, i32 7, i32 %107
  %141 = bitcast float addrspace(3)* %140 to i32 addrspace(3)*
  store i32 %139, i32 addrspace(3)* %141, align 4, !tbaa !4
  %142 = shl i32 %6, 3
  %143 = add i32 %1, 8
  %144 = add i32 %143, %142
  %145 = mul i32 %144, %2
  %146 = add i32 %145, %1
  %147 = add nsw i32 %146, %107
  %148 = sext i32 %147 to i64
  %149 = getelementptr inbounds float, float addrspace(1)* %4, i64 %148
  %150 = bitcast float addrspace(1)* %149 to i32 addrspace(1)*
  %151 = load i32, i32 addrspace(1)* %150, align 4, !tbaa !4
  %152 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %9, i32 0, i32 0, i32 %107
  %153 = bitcast float addrspace(3)* %152 to i32 addrspace(3)*
  store i32 %151, i32 addrspace(3)* %153, align 4, !tbaa !4
  %154 = add nsw i32 %146, %2
  %155 = add nsw i32 %154, %107
  %156 = sext i32 %155 to i64
  %157 = getelementptr inbounds float, float addrspace(1)* %4, i64 %156
  %158 = bitcast float addrspace(1)* %157 to i32 addrspace(1)*
  %159 = load i32, i32 addrspace(1)* %158, align 4, !tbaa !4
  %160 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %9, i32 0, i32 1, i32 %107
  %161 = bitcast float addrspace(3)* %160 to i32 addrspace(3)*
  store i32 %159, i32 addrspace(3)* %161, align 4, !tbaa !4
  %162 = add nsw i32 %154, %2
  %163 = add nsw i32 %162, %107
  %164 = sext i32 %163 to i64
  %165 = getelementptr inbounds float, float addrspace(1)* %4, i64 %164
  %166 = bitcast float addrspace(1)* %165 to i32 addrspace(1)*
  %167 = load i32, i32 addrspace(1)* %166, align 4, !tbaa !4
  %168 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %9, i32 0, i32 2, i32 %107
  %169 = bitcast float addrspace(3)* %168 to i32 addrspace(3)*
  store i32 %167, i32 addrspace(3)* %169, align 4, !tbaa !4
  %170 = add nsw i32 %162, %2
  %171 = add nsw i32 %170, %107
  %172 = sext i32 %171 to i64
  %173 = getelementptr inbounds float, float addrspace(1)* %4, i64 %172
  %174 = bitcast float addrspace(1)* %173 to i32 addrspace(1)*
  %175 = load i32, i32 addrspace(1)* %174, align 4, !tbaa !4
  %176 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %9, i32 0, i32 3, i32 %107
  %177 = bitcast float addrspace(3)* %176 to i32 addrspace(3)*
  store i32 %175, i32 addrspace(3)* %177, align 4, !tbaa !4
  %178 = add nsw i32 %170, %2
  %179 = add nsw i32 %178, %107
  %180 = sext i32 %179 to i64
  %181 = getelementptr inbounds float, float addrspace(1)* %4, i64 %180
  %182 = bitcast float addrspace(1)* %181 to i32 addrspace(1)*
  %183 = load i32, i32 addrspace(1)* %182, align 4, !tbaa !4
  %184 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %9, i32 0, i32 4, i32 %107
  %185 = bitcast float addrspace(3)* %184 to i32 addrspace(3)*
  store i32 %183, i32 addrspace(3)* %185, align 4, !tbaa !4
  %186 = add nsw i32 %178, %2
  %187 = add nsw i32 %186, %107
  %188 = sext i32 %187 to i64
  %189 = getelementptr inbounds float, float addrspace(1)* %4, i64 %188
  %190 = bitcast float addrspace(1)* %189 to i32 addrspace(1)*
  %191 = load i32, i32 addrspace(1)* %190, align 4, !tbaa !4
  %192 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %9, i32 0, i32 5, i32 %107
  %193 = bitcast float addrspace(3)* %192 to i32 addrspace(3)*
  store i32 %191, i32 addrspace(3)* %193, align 4, !tbaa !4
  %194 = add nsw i32 %186, %2
  %195 = add nsw i32 %194, %107
  %196 = sext i32 %195 to i64
  %197 = getelementptr inbounds float, float addrspace(1)* %4, i64 %196
  %198 = bitcast float addrspace(1)* %197 to i32 addrspace(1)*
  %199 = load i32, i32 addrspace(1)* %198, align 4, !tbaa !4
  %200 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %9, i32 0, i32 6, i32 %107
  %201 = bitcast float addrspace(3)* %200 to i32 addrspace(3)*
  store i32 %199, i32 addrspace(3)* %201, align 4, !tbaa !4
  %202 = add nsw i32 %194, %2
  %203 = add nsw i32 %202, %107
  %204 = sext i32 %203 to i64
  %205 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %9, i32 0, i32 7, i32 %107
  br label %206

206:                                              ; preds = %106, %12
  %207 = phi float addrspace(3)* [ %105, %12 ], [ %205, %106 ]
  %208 = phi i64 [ %104, %12 ], [ %204, %106 ]
  %209 = getelementptr inbounds { float addrspace(3)*, i64 }, { float addrspace(3)*, i64 }* %10, i32 0, i32 0
  store float addrspace(3)* %207, float addrspace(3)** %209, align 4
  %210 = getelementptr inbounds { float addrspace(3)*, i64 }, { float addrspace(3)*, i64 }* %10, i32 0, i32 1
  store i64 %208, i64* %210, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,1024" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0, !1}
!dataflow.builtin.operations = !{!2, !3}

!0 = !{i32 3, !"llvm.amdgcn.workitem.id.x"}
!1 = !{i32 6, !"llvm.amdgcn.workgroup.id.x"}
!2 = !{i32 0, i32 37, !"llvm.amdgcn.workgroup.id.x"}
!3 = !{i32 1, i32 39, !"llvm.amdgcn.workgroup.id.x"}
!4 = !{!5, !5, i64 0}
!5 = !{!"float", !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C++ TBAA"}
