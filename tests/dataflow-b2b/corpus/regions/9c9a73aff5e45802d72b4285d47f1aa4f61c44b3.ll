; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i32 %1, i32 %2, i32 %3, float addrspace(1)* %4, [16 x [16 x float]] addrspace(3)* %5, i32 %6, i64 %7, [16 x [16 x float]] addrspace(3)* %8, [16 x [16 x float]] addrspace(3)* %9, { float addrspace(3)*, i64 }* %10) #0 {
  br i1 %0, label %12, label %152

12:                                               ; preds = %11
  %13 = mul nsw i32 %1, %2
  %14 = add nsw i32 %13, %1
  %15 = add nsw i32 %14, %3
  %16 = sext i32 %15 to i64
  %17 = getelementptr inbounds float, float addrspace(1)* %4, i64 %16
  %18 = load float, float addrspace(1)* %17, align 4, !tbaa !4
  %19 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 0, i32 %3
  store float %18, float addrspace(3)* %19, align 4, !tbaa !4
  %20 = add nsw i32 %14, %2
  %21 = add nsw i32 %20, %3
  %22 = sext i32 %21 to i64
  %23 = getelementptr inbounds float, float addrspace(1)* %4, i64 %22
  %24 = load float, float addrspace(1)* %23, align 4, !tbaa !4
  %25 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 1, i32 %3
  store float %24, float addrspace(3)* %25, align 4, !tbaa !4
  %26 = add nsw i32 %20, %2
  %27 = add nsw i32 %26, %3
  %28 = sext i32 %27 to i64
  %29 = getelementptr inbounds float, float addrspace(1)* %4, i64 %28
  %30 = load float, float addrspace(1)* %29, align 4, !tbaa !4
  %31 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 2, i32 %3
  store float %30, float addrspace(3)* %31, align 4, !tbaa !4
  %32 = add nsw i32 %26, %2
  %33 = add nsw i32 %32, %3
  %34 = sext i32 %33 to i64
  %35 = getelementptr inbounds float, float addrspace(1)* %4, i64 %34
  %36 = load float, float addrspace(1)* %35, align 4, !tbaa !4
  %37 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 3, i32 %3
  store float %36, float addrspace(3)* %37, align 4, !tbaa !4
  %38 = add nsw i32 %32, %2
  %39 = add nsw i32 %38, %3
  %40 = sext i32 %39 to i64
  %41 = getelementptr inbounds float, float addrspace(1)* %4, i64 %40
  %42 = load float, float addrspace(1)* %41, align 4, !tbaa !4
  %43 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 4, i32 %3
  store float %42, float addrspace(3)* %43, align 4, !tbaa !4
  %44 = add nsw i32 %38, %2
  %45 = add nsw i32 %44, %3
  %46 = sext i32 %45 to i64
  %47 = getelementptr inbounds float, float addrspace(1)* %4, i64 %46
  %48 = load float, float addrspace(1)* %47, align 4, !tbaa !4
  %49 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 5, i32 %3
  store float %48, float addrspace(3)* %49, align 4, !tbaa !4
  %50 = add nsw i32 %44, %2
  %51 = add nsw i32 %50, %3
  %52 = sext i32 %51 to i64
  %53 = getelementptr inbounds float, float addrspace(1)* %4, i64 %52
  %54 = load float, float addrspace(1)* %53, align 4, !tbaa !4
  %55 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 6, i32 %3
  store float %54, float addrspace(3)* %55, align 4, !tbaa !4
  %56 = add nsw i32 %50, %2
  %57 = add nsw i32 %56, %3
  %58 = sext i32 %57 to i64
  %59 = getelementptr inbounds float, float addrspace(1)* %4, i64 %58
  %60 = load float, float addrspace(1)* %59, align 4, !tbaa !4
  %61 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 7, i32 %3
  store float %60, float addrspace(3)* %61, align 4, !tbaa !4
  %62 = zext i32 %6 to i64
  %63 = shl nuw nsw i64 %62, 4
  %64 = add nuw nsw i64 %7, 16
  %65 = add nuw nsw i64 %64, %63
  %66 = sext i32 %14 to i64
  %67 = add nsw i64 %65, %66
  %68 = getelementptr inbounds float, float addrspace(1)* %4, i64 %67
  %69 = load float, float addrspace(1)* %68, align 4, !tbaa !4
  %70 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 0, i32 %3
  store float %69, float addrspace(3)* %70, align 4, !tbaa !4
  %71 = sext i32 %20 to i64
  %72 = add nsw i64 %65, %71
  %73 = getelementptr inbounds float, float addrspace(1)* %4, i64 %72
  %74 = load float, float addrspace(1)* %73, align 4, !tbaa !4
  %75 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 1, i32 %3
  store float %74, float addrspace(3)* %75, align 4, !tbaa !4
  %76 = sext i32 %26 to i64
  %77 = add nsw i64 %65, %76
  %78 = getelementptr inbounds float, float addrspace(1)* %4, i64 %77
  %79 = load float, float addrspace(1)* %78, align 4, !tbaa !4
  %80 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 2, i32 %3
  store float %79, float addrspace(3)* %80, align 4, !tbaa !4
  %81 = sext i32 %32 to i64
  %82 = add nsw i64 %65, %81
  %83 = getelementptr inbounds float, float addrspace(1)* %4, i64 %82
  %84 = load float, float addrspace(1)* %83, align 4, !tbaa !4
  %85 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 3, i32 %3
  store float %84, float addrspace(3)* %85, align 4, !tbaa !4
  %86 = sext i32 %38 to i64
  %87 = add nsw i64 %65, %86
  %88 = getelementptr inbounds float, float addrspace(1)* %4, i64 %87
  %89 = load float, float addrspace(1)* %88, align 4, !tbaa !4
  %90 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 4, i32 %3
  store float %89, float addrspace(3)* %90, align 4, !tbaa !4
  %91 = sext i32 %44 to i64
  %92 = add nsw i64 %65, %91
  %93 = getelementptr inbounds float, float addrspace(1)* %4, i64 %92
  %94 = load float, float addrspace(1)* %93, align 4, !tbaa !4
  %95 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 5, i32 %3
  store float %94, float addrspace(3)* %95, align 4, !tbaa !4
  %96 = sext i32 %50 to i64
  %97 = add nsw i64 %65, %96
  %98 = getelementptr inbounds float, float addrspace(1)* %4, i64 %97
  %99 = load float, float addrspace(1)* %98, align 4, !tbaa !4
  %100 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 6, i32 %3
  store float %99, float addrspace(3)* %100, align 4, !tbaa !4
  %101 = sext i32 %56 to i64
  %102 = add nsw i64 %65, %101
  %103 = getelementptr inbounds float, float addrspace(1)* %4, i64 %102
  %104 = load float, float addrspace(1)* %103, align 4, !tbaa !4
  %105 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 7, i32 %3
  store float %104, float addrspace(3)* %105, align 4, !tbaa !4
  %106 = add nsw i32 %56, %2
  %107 = sext i32 %106 to i64
  %108 = add nsw i64 %65, %107
  %109 = getelementptr inbounds float, float addrspace(1)* %4, i64 %108
  %110 = load float, float addrspace(1)* %109, align 4, !tbaa !4
  %111 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 8, i32 %3
  store float %110, float addrspace(3)* %111, align 4, !tbaa !4
  %112 = add nsw i32 %106, %2
  %113 = sext i32 %112 to i64
  %114 = add nsw i64 %65, %113
  %115 = getelementptr inbounds float, float addrspace(1)* %4, i64 %114
  %116 = load float, float addrspace(1)* %115, align 4, !tbaa !4
  %117 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 9, i32 %3
  store float %116, float addrspace(3)* %117, align 4, !tbaa !4
  %118 = add nsw i32 %112, %2
  %119 = sext i32 %118 to i64
  %120 = add nsw i64 %65, %119
  %121 = getelementptr inbounds float, float addrspace(1)* %4, i64 %120
  %122 = load float, float addrspace(1)* %121, align 4, !tbaa !4
  %123 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 10, i32 %3
  store float %122, float addrspace(3)* %123, align 4, !tbaa !4
  %124 = add nsw i32 %118, %2
  %125 = sext i32 %124 to i64
  %126 = add nsw i64 %65, %125
  %127 = getelementptr inbounds float, float addrspace(1)* %4, i64 %126
  %128 = load float, float addrspace(1)* %127, align 4, !tbaa !4
  %129 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 11, i32 %3
  store float %128, float addrspace(3)* %129, align 4, !tbaa !4
  %130 = add nsw i32 %124, %2
  %131 = sext i32 %130 to i64
  %132 = add nsw i64 %65, %131
  %133 = getelementptr inbounds float, float addrspace(1)* %4, i64 %132
  %134 = load float, float addrspace(1)* %133, align 4, !tbaa !4
  %135 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 12, i32 %3
  store float %134, float addrspace(3)* %135, align 4, !tbaa !4
  %136 = add nsw i32 %130, %2
  %137 = sext i32 %136 to i64
  %138 = add nsw i64 %65, %137
  %139 = getelementptr inbounds float, float addrspace(1)* %4, i64 %138
  %140 = load float, float addrspace(1)* %139, align 4, !tbaa !4
  %141 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 13, i32 %3
  store float %140, float addrspace(3)* %141, align 4, !tbaa !4
  %142 = add nsw i32 %136, %2
  %143 = sext i32 %142 to i64
  %144 = add nsw i64 %65, %143
  %145 = getelementptr inbounds float, float addrspace(1)* %4, i64 %144
  %146 = load float, float addrspace(1)* %145, align 4, !tbaa !4
  %147 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 14, i32 %3
  store float %146, float addrspace(3)* %147, align 4, !tbaa !4
  %148 = add nsw i32 %142, %2
  %149 = sext i32 %148 to i64
  %150 = add nsw i64 %65, %149
  %151 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %8, i32 0, i32 15, i32 %3
  br label %302

152:                                              ; preds = %11
  %153 = add nsw i32 %3, -16
  %154 = add nsw i32 %1, 8
  %155 = mul nsw i32 %154, %2
  %156 = add nsw i32 %155, %1
  %157 = add nsw i32 %156, %153
  %158 = sext i32 %157 to i64
  %159 = getelementptr inbounds float, float addrspace(1)* %4, i64 %158
  %160 = load float, float addrspace(1)* %159, align 4, !tbaa !4
  %161 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 8, i32 %153
  store float %160, float addrspace(3)* %161, align 4, !tbaa !4
  %162 = add nsw i32 %156, %2
  %163 = add nsw i32 %162, %153
  %164 = sext i32 %163 to i64
  %165 = getelementptr inbounds float, float addrspace(1)* %4, i64 %164
  %166 = load float, float addrspace(1)* %165, align 4, !tbaa !4
  %167 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 9, i32 %153
  store float %166, float addrspace(3)* %167, align 4, !tbaa !4
  %168 = add nsw i32 %162, %2
  %169 = add nsw i32 %168, %153
  %170 = sext i32 %169 to i64
  %171 = getelementptr inbounds float, float addrspace(1)* %4, i64 %170
  %172 = load float, float addrspace(1)* %171, align 4, !tbaa !4
  %173 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 10, i32 %153
  store float %172, float addrspace(3)* %173, align 4, !tbaa !4
  %174 = add nsw i32 %168, %2
  %175 = add nsw i32 %174, %153
  %176 = sext i32 %175 to i64
  %177 = getelementptr inbounds float, float addrspace(1)* %4, i64 %176
  %178 = load float, float addrspace(1)* %177, align 4, !tbaa !4
  %179 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 11, i32 %153
  store float %178, float addrspace(3)* %179, align 4, !tbaa !4
  %180 = add nsw i32 %174, %2
  %181 = add nsw i32 %180, %153
  %182 = sext i32 %181 to i64
  %183 = getelementptr inbounds float, float addrspace(1)* %4, i64 %182
  %184 = load float, float addrspace(1)* %183, align 4, !tbaa !4
  %185 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 12, i32 %153
  store float %184, float addrspace(3)* %185, align 4, !tbaa !4
  %186 = add nsw i32 %180, %2
  %187 = add nsw i32 %186, %153
  %188 = sext i32 %187 to i64
  %189 = getelementptr inbounds float, float addrspace(1)* %4, i64 %188
  %190 = load float, float addrspace(1)* %189, align 4, !tbaa !4
  %191 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 13, i32 %153
  store float %190, float addrspace(3)* %191, align 4, !tbaa !4
  %192 = add nsw i32 %186, %2
  %193 = add nsw i32 %192, %153
  %194 = sext i32 %193 to i64
  %195 = getelementptr inbounds float, float addrspace(1)* %4, i64 %194
  %196 = load float, float addrspace(1)* %195, align 4, !tbaa !4
  %197 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 14, i32 %153
  store float %196, float addrspace(3)* %197, align 4, !tbaa !4
  %198 = add nsw i32 %192, %2
  %199 = add nsw i32 %198, %153
  %200 = sext i32 %199 to i64
  %201 = getelementptr inbounds float, float addrspace(1)* %4, i64 %200
  %202 = load float, float addrspace(1)* %201, align 4, !tbaa !4
  %203 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %5, i32 0, i32 15, i32 %153
  store float %202, float addrspace(3)* %203, align 4, !tbaa !4
  %204 = shl i32 %6, 4
  %205 = add i32 %1, 16
  %206 = add i32 %205, %204
  %207 = mul i32 %206, %2
  %208 = add i32 %207, %1
  %209 = add nsw i32 %208, %153
  %210 = sext i32 %209 to i64
  %211 = getelementptr inbounds float, float addrspace(1)* %4, i64 %210
  %212 = load float, float addrspace(1)* %211, align 4, !tbaa !4
  %213 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %9, i32 0, i32 0, i32 %153
  store float %212, float addrspace(3)* %213, align 4, !tbaa !4
  %214 = add nsw i32 %208, %2
  %215 = add nsw i32 %214, %153
  %216 = sext i32 %215 to i64
  %217 = getelementptr inbounds float, float addrspace(1)* %4, i64 %216
  %218 = load float, float addrspace(1)* %217, align 4, !tbaa !4
  %219 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %9, i32 0, i32 1, i32 %153
  store float %218, float addrspace(3)* %219, align 4, !tbaa !4
  %220 = add nsw i32 %214, %2
  %221 = add nsw i32 %220, %153
  %222 = sext i32 %221 to i64
  %223 = getelementptr inbounds float, float addrspace(1)* %4, i64 %222
  %224 = load float, float addrspace(1)* %223, align 4, !tbaa !4
  %225 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %9, i32 0, i32 2, i32 %153
  store float %224, float addrspace(3)* %225, align 4, !tbaa !4
  %226 = add nsw i32 %220, %2
  %227 = add nsw i32 %226, %153
  %228 = sext i32 %227 to i64
  %229 = getelementptr inbounds float, float addrspace(1)* %4, i64 %228
  %230 = load float, float addrspace(1)* %229, align 4, !tbaa !4
  %231 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %9, i32 0, i32 3, i32 %153
  store float %230, float addrspace(3)* %231, align 4, !tbaa !4
  %232 = add nsw i32 %226, %2
  %233 = add nsw i32 %232, %153
  %234 = sext i32 %233 to i64
  %235 = getelementptr inbounds float, float addrspace(1)* %4, i64 %234
  %236 = load float, float addrspace(1)* %235, align 4, !tbaa !4
  %237 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %9, i32 0, i32 4, i32 %153
  store float %236, float addrspace(3)* %237, align 4, !tbaa !4
  %238 = add nsw i32 %232, %2
  %239 = add nsw i32 %238, %153
  %240 = sext i32 %239 to i64
  %241 = getelementptr inbounds float, float addrspace(1)* %4, i64 %240
  %242 = load float, float addrspace(1)* %241, align 4, !tbaa !4
  %243 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %9, i32 0, i32 5, i32 %153
  store float %242, float addrspace(3)* %243, align 4, !tbaa !4
  %244 = add nsw i32 %238, %2
  %245 = add nsw i32 %244, %153
  %246 = sext i32 %245 to i64
  %247 = getelementptr inbounds float, float addrspace(1)* %4, i64 %246
  %248 = load float, float addrspace(1)* %247, align 4, !tbaa !4
  %249 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %9, i32 0, i32 6, i32 %153
  store float %248, float addrspace(3)* %249, align 4, !tbaa !4
  %250 = add nsw i32 %244, %2
  %251 = add nsw i32 %250, %153
  %252 = sext i32 %251 to i64
  %253 = getelementptr inbounds float, float addrspace(1)* %4, i64 %252
  %254 = load float, float addrspace(1)* %253, align 4, !tbaa !4
  %255 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %9, i32 0, i32 7, i32 %153
  store float %254, float addrspace(3)* %255, align 4, !tbaa !4
  %256 = add nsw i32 %250, %2
  %257 = add nsw i32 %256, %153
  %258 = sext i32 %257 to i64
  %259 = getelementptr inbounds float, float addrspace(1)* %4, i64 %258
  %260 = load float, float addrspace(1)* %259, align 4, !tbaa !4
  %261 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %9, i32 0, i32 8, i32 %153
  store float %260, float addrspace(3)* %261, align 4, !tbaa !4
  %262 = add nsw i32 %256, %2
  %263 = add nsw i32 %262, %153
  %264 = sext i32 %263 to i64
  %265 = getelementptr inbounds float, float addrspace(1)* %4, i64 %264
  %266 = load float, float addrspace(1)* %265, align 4, !tbaa !4
  %267 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %9, i32 0, i32 9, i32 %153
  store float %266, float addrspace(3)* %267, align 4, !tbaa !4
  %268 = add nsw i32 %262, %2
  %269 = add nsw i32 %268, %153
  %270 = sext i32 %269 to i64
  %271 = getelementptr inbounds float, float addrspace(1)* %4, i64 %270
  %272 = load float, float addrspace(1)* %271, align 4, !tbaa !4
  %273 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %9, i32 0, i32 10, i32 %153
  store float %272, float addrspace(3)* %273, align 4, !tbaa !4
  %274 = add nsw i32 %268, %2
  %275 = add nsw i32 %274, %153
  %276 = sext i32 %275 to i64
  %277 = getelementptr inbounds float, float addrspace(1)* %4, i64 %276
  %278 = load float, float addrspace(1)* %277, align 4, !tbaa !4
  %279 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %9, i32 0, i32 11, i32 %153
  store float %278, float addrspace(3)* %279, align 4, !tbaa !4
  %280 = add nsw i32 %274, %2
  %281 = add nsw i32 %280, %153
  %282 = sext i32 %281 to i64
  %283 = getelementptr inbounds float, float addrspace(1)* %4, i64 %282
  %284 = load float, float addrspace(1)* %283, align 4, !tbaa !4
  %285 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %9, i32 0, i32 12, i32 %153
  store float %284, float addrspace(3)* %285, align 4, !tbaa !4
  %286 = add nsw i32 %280, %2
  %287 = add nsw i32 %286, %153
  %288 = sext i32 %287 to i64
  %289 = getelementptr inbounds float, float addrspace(1)* %4, i64 %288
  %290 = load float, float addrspace(1)* %289, align 4, !tbaa !4
  %291 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %9, i32 0, i32 13, i32 %153
  store float %290, float addrspace(3)* %291, align 4, !tbaa !4
  %292 = add nsw i32 %286, %2
  %293 = add nsw i32 %292, %153
  %294 = sext i32 %293 to i64
  %295 = getelementptr inbounds float, float addrspace(1)* %4, i64 %294
  %296 = load float, float addrspace(1)* %295, align 4, !tbaa !4
  %297 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %9, i32 0, i32 14, i32 %153
  store float %296, float addrspace(3)* %297, align 4, !tbaa !4
  %298 = add nsw i32 %292, %2
  %299 = add nsw i32 %298, %153
  %300 = sext i32 %299 to i64
  %301 = getelementptr inbounds [16 x [16 x float]], [16 x [16 x float]] addrspace(3)* %9, i32 0, i32 15, i32 %153
  br label %302

302:                                              ; preds = %152, %12
  %303 = phi float addrspace(3)* [ %151, %12 ], [ %301, %152 ]
  %304 = phi i64 [ %150, %12 ], [ %300, %152 ]
  %305 = getelementptr inbounds { float addrspace(3)*, i64 }, { float addrspace(3)*, i64 }* %10, i32 0, i32 0
  store float addrspace(3)* %303, float addrspace(3)** %305, align 4
  %306 = getelementptr inbounds { float addrspace(3)*, i64 }, { float addrspace(3)*, i64 }* %10, i32 0, i32 1
  store i64 %304, i64* %306, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0, !1}
!dataflow.builtin.operations = !{!2, !3}

!0 = !{i32 3, !"llvm.amdgcn.workitem.id.x"}
!1 = !{i32 6, !"llvm.amdgcn.workgroup.id.x"}
!2 = !{i32 0, i32 57, !"llvm.amdgcn.workgroup.id.x"}
!3 = !{i32 1, i32 59, !"llvm.amdgcn.workgroup.id.x"}
!4 = !{!5, !5, i64 0}
!5 = !{!"float", !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C++ TBAA"}
