; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i32 %1, i32 %2, i32 %3, float addrspace(1)* %4, [64 x [64 x float]] addrspace(3)* %5, i32 %6, i64 %7, [64 x [64 x float]] addrspace(3)* %8, [64 x [64 x float]] addrspace(3)* %9, { float addrspace(3)*, i64 }* %10) #0 {
  br i1 %0, label %12, label %560

12:                                               ; preds = %11
  %13 = mul nsw i32 %1, %2
  %14 = add nsw i32 %13, %1
  %15 = add nsw i32 %14, %3
  %16 = sext i32 %15 to i64
  %17 = getelementptr inbounds float, float addrspace(1)* %4, i64 %16
  %18 = load float, float addrspace(1)* %17, align 4, !tbaa !4
  %19 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 0, i32 %3
  store float %18, float addrspace(3)* %19, align 4, !tbaa !4
  %20 = add nsw i32 %14, %2
  %21 = add nsw i32 %20, %3
  %22 = sext i32 %21 to i64
  %23 = getelementptr inbounds float, float addrspace(1)* %4, i64 %22
  %24 = load float, float addrspace(1)* %23, align 4, !tbaa !4
  %25 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 1, i32 %3
  store float %24, float addrspace(3)* %25, align 4, !tbaa !4
  %26 = add nsw i32 %20, %2
  %27 = add nsw i32 %26, %3
  %28 = sext i32 %27 to i64
  %29 = getelementptr inbounds float, float addrspace(1)* %4, i64 %28
  %30 = load float, float addrspace(1)* %29, align 4, !tbaa !4
  %31 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 2, i32 %3
  store float %30, float addrspace(3)* %31, align 4, !tbaa !4
  %32 = add nsw i32 %26, %2
  %33 = add nsw i32 %32, %3
  %34 = sext i32 %33 to i64
  %35 = getelementptr inbounds float, float addrspace(1)* %4, i64 %34
  %36 = load float, float addrspace(1)* %35, align 4, !tbaa !4
  %37 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 3, i32 %3
  store float %36, float addrspace(3)* %37, align 4, !tbaa !4
  %38 = add nsw i32 %32, %2
  %39 = add nsw i32 %38, %3
  %40 = sext i32 %39 to i64
  %41 = getelementptr inbounds float, float addrspace(1)* %4, i64 %40
  %42 = load float, float addrspace(1)* %41, align 4, !tbaa !4
  %43 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 4, i32 %3
  store float %42, float addrspace(3)* %43, align 4, !tbaa !4
  %44 = add nsw i32 %38, %2
  %45 = add nsw i32 %44, %3
  %46 = sext i32 %45 to i64
  %47 = getelementptr inbounds float, float addrspace(1)* %4, i64 %46
  %48 = load float, float addrspace(1)* %47, align 4, !tbaa !4
  %49 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 5, i32 %3
  store float %48, float addrspace(3)* %49, align 4, !tbaa !4
  %50 = add nsw i32 %44, %2
  %51 = add nsw i32 %50, %3
  %52 = sext i32 %51 to i64
  %53 = getelementptr inbounds float, float addrspace(1)* %4, i64 %52
  %54 = load float, float addrspace(1)* %53, align 4, !tbaa !4
  %55 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 6, i32 %3
  store float %54, float addrspace(3)* %55, align 4, !tbaa !4
  %56 = add nsw i32 %50, %2
  %57 = add nsw i32 %56, %3
  %58 = sext i32 %57 to i64
  %59 = getelementptr inbounds float, float addrspace(1)* %4, i64 %58
  %60 = load float, float addrspace(1)* %59, align 4, !tbaa !4
  %61 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 7, i32 %3
  store float %60, float addrspace(3)* %61, align 4, !tbaa !4
  %62 = add nsw i32 %56, %2
  %63 = add nsw i32 %62, %3
  %64 = sext i32 %63 to i64
  %65 = getelementptr inbounds float, float addrspace(1)* %4, i64 %64
  %66 = load float, float addrspace(1)* %65, align 4, !tbaa !4
  %67 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 8, i32 %3
  store float %66, float addrspace(3)* %67, align 4, !tbaa !4
  %68 = add nsw i32 %62, %2
  %69 = add nsw i32 %68, %3
  %70 = sext i32 %69 to i64
  %71 = getelementptr inbounds float, float addrspace(1)* %4, i64 %70
  %72 = load float, float addrspace(1)* %71, align 4, !tbaa !4
  %73 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 9, i32 %3
  store float %72, float addrspace(3)* %73, align 4, !tbaa !4
  %74 = add nsw i32 %68, %2
  %75 = add nsw i32 %74, %3
  %76 = sext i32 %75 to i64
  %77 = getelementptr inbounds float, float addrspace(1)* %4, i64 %76
  %78 = load float, float addrspace(1)* %77, align 4, !tbaa !4
  %79 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 10, i32 %3
  store float %78, float addrspace(3)* %79, align 4, !tbaa !4
  %80 = add nsw i32 %74, %2
  %81 = add nsw i32 %80, %3
  %82 = sext i32 %81 to i64
  %83 = getelementptr inbounds float, float addrspace(1)* %4, i64 %82
  %84 = load float, float addrspace(1)* %83, align 4, !tbaa !4
  %85 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 11, i32 %3
  store float %84, float addrspace(3)* %85, align 4, !tbaa !4
  %86 = add nsw i32 %80, %2
  %87 = add nsw i32 %86, %3
  %88 = sext i32 %87 to i64
  %89 = getelementptr inbounds float, float addrspace(1)* %4, i64 %88
  %90 = load float, float addrspace(1)* %89, align 4, !tbaa !4
  %91 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 12, i32 %3
  store float %90, float addrspace(3)* %91, align 4, !tbaa !4
  %92 = add nsw i32 %86, %2
  %93 = add nsw i32 %92, %3
  %94 = sext i32 %93 to i64
  %95 = getelementptr inbounds float, float addrspace(1)* %4, i64 %94
  %96 = load float, float addrspace(1)* %95, align 4, !tbaa !4
  %97 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 13, i32 %3
  store float %96, float addrspace(3)* %97, align 4, !tbaa !4
  %98 = add nsw i32 %92, %2
  %99 = add nsw i32 %98, %3
  %100 = sext i32 %99 to i64
  %101 = getelementptr inbounds float, float addrspace(1)* %4, i64 %100
  %102 = load float, float addrspace(1)* %101, align 4, !tbaa !4
  %103 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 14, i32 %3
  store float %102, float addrspace(3)* %103, align 4, !tbaa !4
  %104 = add nsw i32 %98, %2
  %105 = add nsw i32 %104, %3
  %106 = sext i32 %105 to i64
  %107 = getelementptr inbounds float, float addrspace(1)* %4, i64 %106
  %108 = load float, float addrspace(1)* %107, align 4, !tbaa !4
  %109 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 15, i32 %3
  store float %108, float addrspace(3)* %109, align 4, !tbaa !4
  %110 = add nsw i32 %104, %2
  %111 = add nsw i32 %110, %3
  %112 = sext i32 %111 to i64
  %113 = getelementptr inbounds float, float addrspace(1)* %4, i64 %112
  %114 = load float, float addrspace(1)* %113, align 4, !tbaa !4
  %115 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 16, i32 %3
  store float %114, float addrspace(3)* %115, align 4, !tbaa !4
  %116 = add nsw i32 %110, %2
  %117 = add nsw i32 %116, %3
  %118 = sext i32 %117 to i64
  %119 = getelementptr inbounds float, float addrspace(1)* %4, i64 %118
  %120 = load float, float addrspace(1)* %119, align 4, !tbaa !4
  %121 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 17, i32 %3
  store float %120, float addrspace(3)* %121, align 4, !tbaa !4
  %122 = add nsw i32 %116, %2
  %123 = add nsw i32 %122, %3
  %124 = sext i32 %123 to i64
  %125 = getelementptr inbounds float, float addrspace(1)* %4, i64 %124
  %126 = load float, float addrspace(1)* %125, align 4, !tbaa !4
  %127 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 18, i32 %3
  store float %126, float addrspace(3)* %127, align 4, !tbaa !4
  %128 = add nsw i32 %122, %2
  %129 = add nsw i32 %128, %3
  %130 = sext i32 %129 to i64
  %131 = getelementptr inbounds float, float addrspace(1)* %4, i64 %130
  %132 = load float, float addrspace(1)* %131, align 4, !tbaa !4
  %133 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 19, i32 %3
  store float %132, float addrspace(3)* %133, align 4, !tbaa !4
  %134 = add nsw i32 %128, %2
  %135 = add nsw i32 %134, %3
  %136 = sext i32 %135 to i64
  %137 = getelementptr inbounds float, float addrspace(1)* %4, i64 %136
  %138 = load float, float addrspace(1)* %137, align 4, !tbaa !4
  %139 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 20, i32 %3
  store float %138, float addrspace(3)* %139, align 4, !tbaa !4
  %140 = add nsw i32 %134, %2
  %141 = add nsw i32 %140, %3
  %142 = sext i32 %141 to i64
  %143 = getelementptr inbounds float, float addrspace(1)* %4, i64 %142
  %144 = load float, float addrspace(1)* %143, align 4, !tbaa !4
  %145 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 21, i32 %3
  store float %144, float addrspace(3)* %145, align 4, !tbaa !4
  %146 = add nsw i32 %140, %2
  %147 = add nsw i32 %146, %3
  %148 = sext i32 %147 to i64
  %149 = getelementptr inbounds float, float addrspace(1)* %4, i64 %148
  %150 = load float, float addrspace(1)* %149, align 4, !tbaa !4
  %151 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 22, i32 %3
  store float %150, float addrspace(3)* %151, align 4, !tbaa !4
  %152 = add nsw i32 %146, %2
  %153 = add nsw i32 %152, %3
  %154 = sext i32 %153 to i64
  %155 = getelementptr inbounds float, float addrspace(1)* %4, i64 %154
  %156 = load float, float addrspace(1)* %155, align 4, !tbaa !4
  %157 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 23, i32 %3
  store float %156, float addrspace(3)* %157, align 4, !tbaa !4
  %158 = add nsw i32 %152, %2
  %159 = add nsw i32 %158, %3
  %160 = sext i32 %159 to i64
  %161 = getelementptr inbounds float, float addrspace(1)* %4, i64 %160
  %162 = load float, float addrspace(1)* %161, align 4, !tbaa !4
  %163 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 24, i32 %3
  store float %162, float addrspace(3)* %163, align 4, !tbaa !4
  %164 = add nsw i32 %158, %2
  %165 = add nsw i32 %164, %3
  %166 = sext i32 %165 to i64
  %167 = getelementptr inbounds float, float addrspace(1)* %4, i64 %166
  %168 = load float, float addrspace(1)* %167, align 4, !tbaa !4
  %169 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 25, i32 %3
  store float %168, float addrspace(3)* %169, align 4, !tbaa !4
  %170 = add nsw i32 %164, %2
  %171 = add nsw i32 %170, %3
  %172 = sext i32 %171 to i64
  %173 = getelementptr inbounds float, float addrspace(1)* %4, i64 %172
  %174 = load float, float addrspace(1)* %173, align 4, !tbaa !4
  %175 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 26, i32 %3
  store float %174, float addrspace(3)* %175, align 4, !tbaa !4
  %176 = add nsw i32 %170, %2
  %177 = add nsw i32 %176, %3
  %178 = sext i32 %177 to i64
  %179 = getelementptr inbounds float, float addrspace(1)* %4, i64 %178
  %180 = load float, float addrspace(1)* %179, align 4, !tbaa !4
  %181 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 27, i32 %3
  store float %180, float addrspace(3)* %181, align 4, !tbaa !4
  %182 = add nsw i32 %176, %2
  %183 = add nsw i32 %182, %3
  %184 = sext i32 %183 to i64
  %185 = getelementptr inbounds float, float addrspace(1)* %4, i64 %184
  %186 = load float, float addrspace(1)* %185, align 4, !tbaa !4
  %187 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 28, i32 %3
  store float %186, float addrspace(3)* %187, align 4, !tbaa !4
  %188 = add nsw i32 %182, %2
  %189 = add nsw i32 %188, %3
  %190 = sext i32 %189 to i64
  %191 = getelementptr inbounds float, float addrspace(1)* %4, i64 %190
  %192 = load float, float addrspace(1)* %191, align 4, !tbaa !4
  %193 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 29, i32 %3
  store float %192, float addrspace(3)* %193, align 4, !tbaa !4
  %194 = add nsw i32 %188, %2
  %195 = add nsw i32 %194, %3
  %196 = sext i32 %195 to i64
  %197 = getelementptr inbounds float, float addrspace(1)* %4, i64 %196
  %198 = load float, float addrspace(1)* %197, align 4, !tbaa !4
  %199 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 30, i32 %3
  store float %198, float addrspace(3)* %199, align 4, !tbaa !4
  %200 = add nsw i32 %194, %2
  %201 = add nsw i32 %200, %3
  %202 = sext i32 %201 to i64
  %203 = getelementptr inbounds float, float addrspace(1)* %4, i64 %202
  %204 = load float, float addrspace(1)* %203, align 4, !tbaa !4
  %205 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 31, i32 %3
  store float %204, float addrspace(3)* %205, align 4, !tbaa !4
  %206 = zext i32 %6 to i64
  %207 = shl nuw nsw i64 %206, 6
  %208 = add nuw nsw i64 %7, 64
  %209 = add nuw nsw i64 %208, %207
  %210 = sext i32 %14 to i64
  %211 = add nsw i64 %209, %210
  %212 = getelementptr inbounds float, float addrspace(1)* %4, i64 %211
  %213 = load float, float addrspace(1)* %212, align 4, !tbaa !4
  %214 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 0, i32 %3
  store float %213, float addrspace(3)* %214, align 4, !tbaa !4
  %215 = sext i32 %20 to i64
  %216 = add nsw i64 %209, %215
  %217 = getelementptr inbounds float, float addrspace(1)* %4, i64 %216
  %218 = load float, float addrspace(1)* %217, align 4, !tbaa !4
  %219 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 1, i32 %3
  store float %218, float addrspace(3)* %219, align 4, !tbaa !4
  %220 = sext i32 %26 to i64
  %221 = add nsw i64 %209, %220
  %222 = getelementptr inbounds float, float addrspace(1)* %4, i64 %221
  %223 = load float, float addrspace(1)* %222, align 4, !tbaa !4
  %224 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 2, i32 %3
  store float %223, float addrspace(3)* %224, align 4, !tbaa !4
  %225 = sext i32 %32 to i64
  %226 = add nsw i64 %209, %225
  %227 = getelementptr inbounds float, float addrspace(1)* %4, i64 %226
  %228 = load float, float addrspace(1)* %227, align 4, !tbaa !4
  %229 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 3, i32 %3
  store float %228, float addrspace(3)* %229, align 4, !tbaa !4
  %230 = sext i32 %38 to i64
  %231 = add nsw i64 %209, %230
  %232 = getelementptr inbounds float, float addrspace(1)* %4, i64 %231
  %233 = load float, float addrspace(1)* %232, align 4, !tbaa !4
  %234 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 4, i32 %3
  store float %233, float addrspace(3)* %234, align 4, !tbaa !4
  %235 = sext i32 %44 to i64
  %236 = add nsw i64 %209, %235
  %237 = getelementptr inbounds float, float addrspace(1)* %4, i64 %236
  %238 = load float, float addrspace(1)* %237, align 4, !tbaa !4
  %239 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 5, i32 %3
  store float %238, float addrspace(3)* %239, align 4, !tbaa !4
  %240 = sext i32 %50 to i64
  %241 = add nsw i64 %209, %240
  %242 = getelementptr inbounds float, float addrspace(1)* %4, i64 %241
  %243 = load float, float addrspace(1)* %242, align 4, !tbaa !4
  %244 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 6, i32 %3
  store float %243, float addrspace(3)* %244, align 4, !tbaa !4
  %245 = sext i32 %56 to i64
  %246 = add nsw i64 %209, %245
  %247 = getelementptr inbounds float, float addrspace(1)* %4, i64 %246
  %248 = load float, float addrspace(1)* %247, align 4, !tbaa !4
  %249 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 7, i32 %3
  store float %248, float addrspace(3)* %249, align 4, !tbaa !4
  %250 = sext i32 %62 to i64
  %251 = add nsw i64 %209, %250
  %252 = getelementptr inbounds float, float addrspace(1)* %4, i64 %251
  %253 = load float, float addrspace(1)* %252, align 4, !tbaa !4
  %254 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 8, i32 %3
  store float %253, float addrspace(3)* %254, align 4, !tbaa !4
  %255 = sext i32 %68 to i64
  %256 = add nsw i64 %209, %255
  %257 = getelementptr inbounds float, float addrspace(1)* %4, i64 %256
  %258 = load float, float addrspace(1)* %257, align 4, !tbaa !4
  %259 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 9, i32 %3
  store float %258, float addrspace(3)* %259, align 4, !tbaa !4
  %260 = sext i32 %74 to i64
  %261 = add nsw i64 %209, %260
  %262 = getelementptr inbounds float, float addrspace(1)* %4, i64 %261
  %263 = load float, float addrspace(1)* %262, align 4, !tbaa !4
  %264 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 10, i32 %3
  store float %263, float addrspace(3)* %264, align 4, !tbaa !4
  %265 = sext i32 %80 to i64
  %266 = add nsw i64 %209, %265
  %267 = getelementptr inbounds float, float addrspace(1)* %4, i64 %266
  %268 = load float, float addrspace(1)* %267, align 4, !tbaa !4
  %269 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 11, i32 %3
  store float %268, float addrspace(3)* %269, align 4, !tbaa !4
  %270 = sext i32 %86 to i64
  %271 = add nsw i64 %209, %270
  %272 = getelementptr inbounds float, float addrspace(1)* %4, i64 %271
  %273 = load float, float addrspace(1)* %272, align 4, !tbaa !4
  %274 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 12, i32 %3
  store float %273, float addrspace(3)* %274, align 4, !tbaa !4
  %275 = sext i32 %92 to i64
  %276 = add nsw i64 %209, %275
  %277 = getelementptr inbounds float, float addrspace(1)* %4, i64 %276
  %278 = load float, float addrspace(1)* %277, align 4, !tbaa !4
  %279 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 13, i32 %3
  store float %278, float addrspace(3)* %279, align 4, !tbaa !4
  %280 = sext i32 %98 to i64
  %281 = add nsw i64 %209, %280
  %282 = getelementptr inbounds float, float addrspace(1)* %4, i64 %281
  %283 = load float, float addrspace(1)* %282, align 4, !tbaa !4
  %284 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 14, i32 %3
  store float %283, float addrspace(3)* %284, align 4, !tbaa !4
  %285 = sext i32 %104 to i64
  %286 = add nsw i64 %209, %285
  %287 = getelementptr inbounds float, float addrspace(1)* %4, i64 %286
  %288 = load float, float addrspace(1)* %287, align 4, !tbaa !4
  %289 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 15, i32 %3
  store float %288, float addrspace(3)* %289, align 4, !tbaa !4
  %290 = sext i32 %110 to i64
  %291 = add nsw i64 %209, %290
  %292 = getelementptr inbounds float, float addrspace(1)* %4, i64 %291
  %293 = load float, float addrspace(1)* %292, align 4, !tbaa !4
  %294 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 16, i32 %3
  store float %293, float addrspace(3)* %294, align 4, !tbaa !4
  %295 = sext i32 %116 to i64
  %296 = add nsw i64 %209, %295
  %297 = getelementptr inbounds float, float addrspace(1)* %4, i64 %296
  %298 = load float, float addrspace(1)* %297, align 4, !tbaa !4
  %299 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 17, i32 %3
  store float %298, float addrspace(3)* %299, align 4, !tbaa !4
  %300 = sext i32 %122 to i64
  %301 = add nsw i64 %209, %300
  %302 = getelementptr inbounds float, float addrspace(1)* %4, i64 %301
  %303 = load float, float addrspace(1)* %302, align 4, !tbaa !4
  %304 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 18, i32 %3
  store float %303, float addrspace(3)* %304, align 4, !tbaa !4
  %305 = sext i32 %128 to i64
  %306 = add nsw i64 %209, %305
  %307 = getelementptr inbounds float, float addrspace(1)* %4, i64 %306
  %308 = load float, float addrspace(1)* %307, align 4, !tbaa !4
  %309 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 19, i32 %3
  store float %308, float addrspace(3)* %309, align 4, !tbaa !4
  %310 = sext i32 %134 to i64
  %311 = add nsw i64 %209, %310
  %312 = getelementptr inbounds float, float addrspace(1)* %4, i64 %311
  %313 = load float, float addrspace(1)* %312, align 4, !tbaa !4
  %314 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 20, i32 %3
  store float %313, float addrspace(3)* %314, align 4, !tbaa !4
  %315 = sext i32 %140 to i64
  %316 = add nsw i64 %209, %315
  %317 = getelementptr inbounds float, float addrspace(1)* %4, i64 %316
  %318 = load float, float addrspace(1)* %317, align 4, !tbaa !4
  %319 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 21, i32 %3
  store float %318, float addrspace(3)* %319, align 4, !tbaa !4
  %320 = sext i32 %146 to i64
  %321 = add nsw i64 %209, %320
  %322 = getelementptr inbounds float, float addrspace(1)* %4, i64 %321
  %323 = load float, float addrspace(1)* %322, align 4, !tbaa !4
  %324 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 22, i32 %3
  store float %323, float addrspace(3)* %324, align 4, !tbaa !4
  %325 = sext i32 %152 to i64
  %326 = add nsw i64 %209, %325
  %327 = getelementptr inbounds float, float addrspace(1)* %4, i64 %326
  %328 = load float, float addrspace(1)* %327, align 4, !tbaa !4
  %329 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 23, i32 %3
  store float %328, float addrspace(3)* %329, align 4, !tbaa !4
  %330 = sext i32 %158 to i64
  %331 = add nsw i64 %209, %330
  %332 = getelementptr inbounds float, float addrspace(1)* %4, i64 %331
  %333 = load float, float addrspace(1)* %332, align 4, !tbaa !4
  %334 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 24, i32 %3
  store float %333, float addrspace(3)* %334, align 4, !tbaa !4
  %335 = sext i32 %164 to i64
  %336 = add nsw i64 %209, %335
  %337 = getelementptr inbounds float, float addrspace(1)* %4, i64 %336
  %338 = load float, float addrspace(1)* %337, align 4, !tbaa !4
  %339 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 25, i32 %3
  store float %338, float addrspace(3)* %339, align 4, !tbaa !4
  %340 = sext i32 %170 to i64
  %341 = add nsw i64 %209, %340
  %342 = getelementptr inbounds float, float addrspace(1)* %4, i64 %341
  %343 = load float, float addrspace(1)* %342, align 4, !tbaa !4
  %344 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 26, i32 %3
  store float %343, float addrspace(3)* %344, align 4, !tbaa !4
  %345 = sext i32 %176 to i64
  %346 = add nsw i64 %209, %345
  %347 = getelementptr inbounds float, float addrspace(1)* %4, i64 %346
  %348 = load float, float addrspace(1)* %347, align 4, !tbaa !4
  %349 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 27, i32 %3
  store float %348, float addrspace(3)* %349, align 4, !tbaa !4
  %350 = sext i32 %182 to i64
  %351 = add nsw i64 %209, %350
  %352 = getelementptr inbounds float, float addrspace(1)* %4, i64 %351
  %353 = load float, float addrspace(1)* %352, align 4, !tbaa !4
  %354 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 28, i32 %3
  store float %353, float addrspace(3)* %354, align 4, !tbaa !4
  %355 = sext i32 %188 to i64
  %356 = add nsw i64 %209, %355
  %357 = getelementptr inbounds float, float addrspace(1)* %4, i64 %356
  %358 = load float, float addrspace(1)* %357, align 4, !tbaa !4
  %359 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 29, i32 %3
  store float %358, float addrspace(3)* %359, align 4, !tbaa !4
  %360 = sext i32 %194 to i64
  %361 = add nsw i64 %209, %360
  %362 = getelementptr inbounds float, float addrspace(1)* %4, i64 %361
  %363 = load float, float addrspace(1)* %362, align 4, !tbaa !4
  %364 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 30, i32 %3
  store float %363, float addrspace(3)* %364, align 4, !tbaa !4
  %365 = sext i32 %200 to i64
  %366 = add nsw i64 %209, %365
  %367 = getelementptr inbounds float, float addrspace(1)* %4, i64 %366
  %368 = load float, float addrspace(1)* %367, align 4, !tbaa !4
  %369 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 31, i32 %3
  store float %368, float addrspace(3)* %369, align 4, !tbaa !4
  %370 = add nsw i32 %200, %2
  %371 = sext i32 %370 to i64
  %372 = add nsw i64 %209, %371
  %373 = getelementptr inbounds float, float addrspace(1)* %4, i64 %372
  %374 = load float, float addrspace(1)* %373, align 4, !tbaa !4
  %375 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 32, i32 %3
  store float %374, float addrspace(3)* %375, align 4, !tbaa !4
  %376 = add nsw i32 %370, %2
  %377 = sext i32 %376 to i64
  %378 = add nsw i64 %209, %377
  %379 = getelementptr inbounds float, float addrspace(1)* %4, i64 %378
  %380 = load float, float addrspace(1)* %379, align 4, !tbaa !4
  %381 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 33, i32 %3
  store float %380, float addrspace(3)* %381, align 4, !tbaa !4
  %382 = add nsw i32 %376, %2
  %383 = sext i32 %382 to i64
  %384 = add nsw i64 %209, %383
  %385 = getelementptr inbounds float, float addrspace(1)* %4, i64 %384
  %386 = load float, float addrspace(1)* %385, align 4, !tbaa !4
  %387 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 34, i32 %3
  store float %386, float addrspace(3)* %387, align 4, !tbaa !4
  %388 = add nsw i32 %382, %2
  %389 = sext i32 %388 to i64
  %390 = add nsw i64 %209, %389
  %391 = getelementptr inbounds float, float addrspace(1)* %4, i64 %390
  %392 = load float, float addrspace(1)* %391, align 4, !tbaa !4
  %393 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 35, i32 %3
  store float %392, float addrspace(3)* %393, align 4, !tbaa !4
  %394 = add nsw i32 %388, %2
  %395 = sext i32 %394 to i64
  %396 = add nsw i64 %209, %395
  %397 = getelementptr inbounds float, float addrspace(1)* %4, i64 %396
  %398 = load float, float addrspace(1)* %397, align 4, !tbaa !4
  %399 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 36, i32 %3
  store float %398, float addrspace(3)* %399, align 4, !tbaa !4
  %400 = add nsw i32 %394, %2
  %401 = sext i32 %400 to i64
  %402 = add nsw i64 %209, %401
  %403 = getelementptr inbounds float, float addrspace(1)* %4, i64 %402
  %404 = load float, float addrspace(1)* %403, align 4, !tbaa !4
  %405 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 37, i32 %3
  store float %404, float addrspace(3)* %405, align 4, !tbaa !4
  %406 = add nsw i32 %400, %2
  %407 = sext i32 %406 to i64
  %408 = add nsw i64 %209, %407
  %409 = getelementptr inbounds float, float addrspace(1)* %4, i64 %408
  %410 = load float, float addrspace(1)* %409, align 4, !tbaa !4
  %411 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 38, i32 %3
  store float %410, float addrspace(3)* %411, align 4, !tbaa !4
  %412 = add nsw i32 %406, %2
  %413 = sext i32 %412 to i64
  %414 = add nsw i64 %209, %413
  %415 = getelementptr inbounds float, float addrspace(1)* %4, i64 %414
  %416 = load float, float addrspace(1)* %415, align 4, !tbaa !4
  %417 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 39, i32 %3
  store float %416, float addrspace(3)* %417, align 4, !tbaa !4
  %418 = add nsw i32 %412, %2
  %419 = sext i32 %418 to i64
  %420 = add nsw i64 %209, %419
  %421 = getelementptr inbounds float, float addrspace(1)* %4, i64 %420
  %422 = load float, float addrspace(1)* %421, align 4, !tbaa !4
  %423 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 40, i32 %3
  store float %422, float addrspace(3)* %423, align 4, !tbaa !4
  %424 = add nsw i32 %418, %2
  %425 = sext i32 %424 to i64
  %426 = add nsw i64 %209, %425
  %427 = getelementptr inbounds float, float addrspace(1)* %4, i64 %426
  %428 = load float, float addrspace(1)* %427, align 4, !tbaa !4
  %429 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 41, i32 %3
  store float %428, float addrspace(3)* %429, align 4, !tbaa !4
  %430 = add nsw i32 %424, %2
  %431 = sext i32 %430 to i64
  %432 = add nsw i64 %209, %431
  %433 = getelementptr inbounds float, float addrspace(1)* %4, i64 %432
  %434 = load float, float addrspace(1)* %433, align 4, !tbaa !4
  %435 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 42, i32 %3
  store float %434, float addrspace(3)* %435, align 4, !tbaa !4
  %436 = add nsw i32 %430, %2
  %437 = sext i32 %436 to i64
  %438 = add nsw i64 %209, %437
  %439 = getelementptr inbounds float, float addrspace(1)* %4, i64 %438
  %440 = load float, float addrspace(1)* %439, align 4, !tbaa !4
  %441 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 43, i32 %3
  store float %440, float addrspace(3)* %441, align 4, !tbaa !4
  %442 = add nsw i32 %436, %2
  %443 = sext i32 %442 to i64
  %444 = add nsw i64 %209, %443
  %445 = getelementptr inbounds float, float addrspace(1)* %4, i64 %444
  %446 = load float, float addrspace(1)* %445, align 4, !tbaa !4
  %447 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 44, i32 %3
  store float %446, float addrspace(3)* %447, align 4, !tbaa !4
  %448 = add nsw i32 %442, %2
  %449 = sext i32 %448 to i64
  %450 = add nsw i64 %209, %449
  %451 = getelementptr inbounds float, float addrspace(1)* %4, i64 %450
  %452 = load float, float addrspace(1)* %451, align 4, !tbaa !4
  %453 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 45, i32 %3
  store float %452, float addrspace(3)* %453, align 4, !tbaa !4
  %454 = add nsw i32 %448, %2
  %455 = sext i32 %454 to i64
  %456 = add nsw i64 %209, %455
  %457 = getelementptr inbounds float, float addrspace(1)* %4, i64 %456
  %458 = load float, float addrspace(1)* %457, align 4, !tbaa !4
  %459 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 46, i32 %3
  store float %458, float addrspace(3)* %459, align 4, !tbaa !4
  %460 = add nsw i32 %454, %2
  %461 = sext i32 %460 to i64
  %462 = add nsw i64 %209, %461
  %463 = getelementptr inbounds float, float addrspace(1)* %4, i64 %462
  %464 = load float, float addrspace(1)* %463, align 4, !tbaa !4
  %465 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 47, i32 %3
  store float %464, float addrspace(3)* %465, align 4, !tbaa !4
  %466 = add nsw i32 %460, %2
  %467 = sext i32 %466 to i64
  %468 = add nsw i64 %209, %467
  %469 = getelementptr inbounds float, float addrspace(1)* %4, i64 %468
  %470 = load float, float addrspace(1)* %469, align 4, !tbaa !4
  %471 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 48, i32 %3
  store float %470, float addrspace(3)* %471, align 4, !tbaa !4
  %472 = add nsw i32 %466, %2
  %473 = sext i32 %472 to i64
  %474 = add nsw i64 %209, %473
  %475 = getelementptr inbounds float, float addrspace(1)* %4, i64 %474
  %476 = load float, float addrspace(1)* %475, align 4, !tbaa !4
  %477 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 49, i32 %3
  store float %476, float addrspace(3)* %477, align 4, !tbaa !4
  %478 = add nsw i32 %472, %2
  %479 = sext i32 %478 to i64
  %480 = add nsw i64 %209, %479
  %481 = getelementptr inbounds float, float addrspace(1)* %4, i64 %480
  %482 = load float, float addrspace(1)* %481, align 4, !tbaa !4
  %483 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 50, i32 %3
  store float %482, float addrspace(3)* %483, align 4, !tbaa !4
  %484 = add nsw i32 %478, %2
  %485 = sext i32 %484 to i64
  %486 = add nsw i64 %209, %485
  %487 = getelementptr inbounds float, float addrspace(1)* %4, i64 %486
  %488 = load float, float addrspace(1)* %487, align 4, !tbaa !4
  %489 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 51, i32 %3
  store float %488, float addrspace(3)* %489, align 4, !tbaa !4
  %490 = add nsw i32 %484, %2
  %491 = sext i32 %490 to i64
  %492 = add nsw i64 %209, %491
  %493 = getelementptr inbounds float, float addrspace(1)* %4, i64 %492
  %494 = load float, float addrspace(1)* %493, align 4, !tbaa !4
  %495 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 52, i32 %3
  store float %494, float addrspace(3)* %495, align 4, !tbaa !4
  %496 = add nsw i32 %490, %2
  %497 = sext i32 %496 to i64
  %498 = add nsw i64 %209, %497
  %499 = getelementptr inbounds float, float addrspace(1)* %4, i64 %498
  %500 = load float, float addrspace(1)* %499, align 4, !tbaa !4
  %501 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 53, i32 %3
  store float %500, float addrspace(3)* %501, align 4, !tbaa !4
  %502 = add nsw i32 %496, %2
  %503 = sext i32 %502 to i64
  %504 = add nsw i64 %209, %503
  %505 = getelementptr inbounds float, float addrspace(1)* %4, i64 %504
  %506 = load float, float addrspace(1)* %505, align 4, !tbaa !4
  %507 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 54, i32 %3
  store float %506, float addrspace(3)* %507, align 4, !tbaa !4
  %508 = add nsw i32 %502, %2
  %509 = sext i32 %508 to i64
  %510 = add nsw i64 %209, %509
  %511 = getelementptr inbounds float, float addrspace(1)* %4, i64 %510
  %512 = load float, float addrspace(1)* %511, align 4, !tbaa !4
  %513 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 55, i32 %3
  store float %512, float addrspace(3)* %513, align 4, !tbaa !4
  %514 = add nsw i32 %508, %2
  %515 = sext i32 %514 to i64
  %516 = add nsw i64 %209, %515
  %517 = getelementptr inbounds float, float addrspace(1)* %4, i64 %516
  %518 = load float, float addrspace(1)* %517, align 4, !tbaa !4
  %519 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 56, i32 %3
  store float %518, float addrspace(3)* %519, align 4, !tbaa !4
  %520 = add nsw i32 %514, %2
  %521 = sext i32 %520 to i64
  %522 = add nsw i64 %209, %521
  %523 = getelementptr inbounds float, float addrspace(1)* %4, i64 %522
  %524 = load float, float addrspace(1)* %523, align 4, !tbaa !4
  %525 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 57, i32 %3
  store float %524, float addrspace(3)* %525, align 4, !tbaa !4
  %526 = add nsw i32 %520, %2
  %527 = sext i32 %526 to i64
  %528 = add nsw i64 %209, %527
  %529 = getelementptr inbounds float, float addrspace(1)* %4, i64 %528
  %530 = load float, float addrspace(1)* %529, align 4, !tbaa !4
  %531 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 58, i32 %3
  store float %530, float addrspace(3)* %531, align 4, !tbaa !4
  %532 = add nsw i32 %526, %2
  %533 = sext i32 %532 to i64
  %534 = add nsw i64 %209, %533
  %535 = getelementptr inbounds float, float addrspace(1)* %4, i64 %534
  %536 = load float, float addrspace(1)* %535, align 4, !tbaa !4
  %537 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 59, i32 %3
  store float %536, float addrspace(3)* %537, align 4, !tbaa !4
  %538 = add nsw i32 %532, %2
  %539 = sext i32 %538 to i64
  %540 = add nsw i64 %209, %539
  %541 = getelementptr inbounds float, float addrspace(1)* %4, i64 %540
  %542 = load float, float addrspace(1)* %541, align 4, !tbaa !4
  %543 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 60, i32 %3
  store float %542, float addrspace(3)* %543, align 4, !tbaa !4
  %544 = add nsw i32 %538, %2
  %545 = sext i32 %544 to i64
  %546 = add nsw i64 %209, %545
  %547 = getelementptr inbounds float, float addrspace(1)* %4, i64 %546
  %548 = load float, float addrspace(1)* %547, align 4, !tbaa !4
  %549 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 61, i32 %3
  store float %548, float addrspace(3)* %549, align 4, !tbaa !4
  %550 = add nsw i32 %544, %2
  %551 = sext i32 %550 to i64
  %552 = add nsw i64 %209, %551
  %553 = getelementptr inbounds float, float addrspace(1)* %4, i64 %552
  %554 = load float, float addrspace(1)* %553, align 4, !tbaa !4
  %555 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 62, i32 %3
  store float %554, float addrspace(3)* %555, align 4, !tbaa !4
  %556 = add nsw i32 %550, %2
  %557 = sext i32 %556 to i64
  %558 = add nsw i64 %209, %557
  %559 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 63, i32 %3
  br label %1142

560:                                              ; preds = %11
  %561 = add nsw i32 %3, -64
  %562 = add nsw i32 %1, 32
  %563 = mul nsw i32 %562, %2
  %564 = add nsw i32 %563, %1
  %565 = add nsw i32 %564, %561
  %566 = sext i32 %565 to i64
  %567 = getelementptr inbounds float, float addrspace(1)* %4, i64 %566
  %568 = load float, float addrspace(1)* %567, align 4, !tbaa !4
  %569 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 32, i32 %561
  store float %568, float addrspace(3)* %569, align 4, !tbaa !4
  %570 = add nsw i32 %564, %2
  %571 = add nsw i32 %570, %561
  %572 = sext i32 %571 to i64
  %573 = getelementptr inbounds float, float addrspace(1)* %4, i64 %572
  %574 = load float, float addrspace(1)* %573, align 4, !tbaa !4
  %575 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 33, i32 %561
  store float %574, float addrspace(3)* %575, align 4, !tbaa !4
  %576 = add nsw i32 %570, %2
  %577 = add nsw i32 %576, %561
  %578 = sext i32 %577 to i64
  %579 = getelementptr inbounds float, float addrspace(1)* %4, i64 %578
  %580 = load float, float addrspace(1)* %579, align 4, !tbaa !4
  %581 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 34, i32 %561
  store float %580, float addrspace(3)* %581, align 4, !tbaa !4
  %582 = add nsw i32 %576, %2
  %583 = add nsw i32 %582, %561
  %584 = sext i32 %583 to i64
  %585 = getelementptr inbounds float, float addrspace(1)* %4, i64 %584
  %586 = load float, float addrspace(1)* %585, align 4, !tbaa !4
  %587 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 35, i32 %561
  store float %586, float addrspace(3)* %587, align 4, !tbaa !4
  %588 = add nsw i32 %582, %2
  %589 = add nsw i32 %588, %561
  %590 = sext i32 %589 to i64
  %591 = getelementptr inbounds float, float addrspace(1)* %4, i64 %590
  %592 = load float, float addrspace(1)* %591, align 4, !tbaa !4
  %593 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 36, i32 %561
  store float %592, float addrspace(3)* %593, align 4, !tbaa !4
  %594 = add nsw i32 %588, %2
  %595 = add nsw i32 %594, %561
  %596 = sext i32 %595 to i64
  %597 = getelementptr inbounds float, float addrspace(1)* %4, i64 %596
  %598 = load float, float addrspace(1)* %597, align 4, !tbaa !4
  %599 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 37, i32 %561
  store float %598, float addrspace(3)* %599, align 4, !tbaa !4
  %600 = add nsw i32 %594, %2
  %601 = add nsw i32 %600, %561
  %602 = sext i32 %601 to i64
  %603 = getelementptr inbounds float, float addrspace(1)* %4, i64 %602
  %604 = load float, float addrspace(1)* %603, align 4, !tbaa !4
  %605 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 38, i32 %561
  store float %604, float addrspace(3)* %605, align 4, !tbaa !4
  %606 = add nsw i32 %600, %2
  %607 = add nsw i32 %606, %561
  %608 = sext i32 %607 to i64
  %609 = getelementptr inbounds float, float addrspace(1)* %4, i64 %608
  %610 = load float, float addrspace(1)* %609, align 4, !tbaa !4
  %611 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 39, i32 %561
  store float %610, float addrspace(3)* %611, align 4, !tbaa !4
  %612 = add nsw i32 %606, %2
  %613 = add nsw i32 %612, %561
  %614 = sext i32 %613 to i64
  %615 = getelementptr inbounds float, float addrspace(1)* %4, i64 %614
  %616 = load float, float addrspace(1)* %615, align 4, !tbaa !4
  %617 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 40, i32 %561
  store float %616, float addrspace(3)* %617, align 4, !tbaa !4
  %618 = add nsw i32 %612, %2
  %619 = add nsw i32 %618, %561
  %620 = sext i32 %619 to i64
  %621 = getelementptr inbounds float, float addrspace(1)* %4, i64 %620
  %622 = load float, float addrspace(1)* %621, align 4, !tbaa !4
  %623 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 41, i32 %561
  store float %622, float addrspace(3)* %623, align 4, !tbaa !4
  %624 = add nsw i32 %618, %2
  %625 = add nsw i32 %624, %561
  %626 = sext i32 %625 to i64
  %627 = getelementptr inbounds float, float addrspace(1)* %4, i64 %626
  %628 = load float, float addrspace(1)* %627, align 4, !tbaa !4
  %629 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 42, i32 %561
  store float %628, float addrspace(3)* %629, align 4, !tbaa !4
  %630 = add nsw i32 %624, %2
  %631 = add nsw i32 %630, %561
  %632 = sext i32 %631 to i64
  %633 = getelementptr inbounds float, float addrspace(1)* %4, i64 %632
  %634 = load float, float addrspace(1)* %633, align 4, !tbaa !4
  %635 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 43, i32 %561
  store float %634, float addrspace(3)* %635, align 4, !tbaa !4
  %636 = add nsw i32 %630, %2
  %637 = add nsw i32 %636, %561
  %638 = sext i32 %637 to i64
  %639 = getelementptr inbounds float, float addrspace(1)* %4, i64 %638
  %640 = load float, float addrspace(1)* %639, align 4, !tbaa !4
  %641 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 44, i32 %561
  store float %640, float addrspace(3)* %641, align 4, !tbaa !4
  %642 = add nsw i32 %636, %2
  %643 = add nsw i32 %642, %561
  %644 = sext i32 %643 to i64
  %645 = getelementptr inbounds float, float addrspace(1)* %4, i64 %644
  %646 = load float, float addrspace(1)* %645, align 4, !tbaa !4
  %647 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 45, i32 %561
  store float %646, float addrspace(3)* %647, align 4, !tbaa !4
  %648 = add nsw i32 %642, %2
  %649 = add nsw i32 %648, %561
  %650 = sext i32 %649 to i64
  %651 = getelementptr inbounds float, float addrspace(1)* %4, i64 %650
  %652 = load float, float addrspace(1)* %651, align 4, !tbaa !4
  %653 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 46, i32 %561
  store float %652, float addrspace(3)* %653, align 4, !tbaa !4
  %654 = add nsw i32 %648, %2
  %655 = add nsw i32 %654, %561
  %656 = sext i32 %655 to i64
  %657 = getelementptr inbounds float, float addrspace(1)* %4, i64 %656
  %658 = load float, float addrspace(1)* %657, align 4, !tbaa !4
  %659 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 47, i32 %561
  store float %658, float addrspace(3)* %659, align 4, !tbaa !4
  %660 = add nsw i32 %654, %2
  %661 = add nsw i32 %660, %561
  %662 = sext i32 %661 to i64
  %663 = getelementptr inbounds float, float addrspace(1)* %4, i64 %662
  %664 = load float, float addrspace(1)* %663, align 4, !tbaa !4
  %665 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 48, i32 %561
  store float %664, float addrspace(3)* %665, align 4, !tbaa !4
  %666 = add nsw i32 %660, %2
  %667 = add nsw i32 %666, %561
  %668 = sext i32 %667 to i64
  %669 = getelementptr inbounds float, float addrspace(1)* %4, i64 %668
  %670 = load float, float addrspace(1)* %669, align 4, !tbaa !4
  %671 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 49, i32 %561
  store float %670, float addrspace(3)* %671, align 4, !tbaa !4
  %672 = add nsw i32 %666, %2
  %673 = add nsw i32 %672, %561
  %674 = sext i32 %673 to i64
  %675 = getelementptr inbounds float, float addrspace(1)* %4, i64 %674
  %676 = load float, float addrspace(1)* %675, align 4, !tbaa !4
  %677 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 50, i32 %561
  store float %676, float addrspace(3)* %677, align 4, !tbaa !4
  %678 = add nsw i32 %672, %2
  %679 = add nsw i32 %678, %561
  %680 = sext i32 %679 to i64
  %681 = getelementptr inbounds float, float addrspace(1)* %4, i64 %680
  %682 = load float, float addrspace(1)* %681, align 4, !tbaa !4
  %683 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 51, i32 %561
  store float %682, float addrspace(3)* %683, align 4, !tbaa !4
  %684 = add nsw i32 %678, %2
  %685 = add nsw i32 %684, %561
  %686 = sext i32 %685 to i64
  %687 = getelementptr inbounds float, float addrspace(1)* %4, i64 %686
  %688 = load float, float addrspace(1)* %687, align 4, !tbaa !4
  %689 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 52, i32 %561
  store float %688, float addrspace(3)* %689, align 4, !tbaa !4
  %690 = add nsw i32 %684, %2
  %691 = add nsw i32 %690, %561
  %692 = sext i32 %691 to i64
  %693 = getelementptr inbounds float, float addrspace(1)* %4, i64 %692
  %694 = load float, float addrspace(1)* %693, align 4, !tbaa !4
  %695 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 53, i32 %561
  store float %694, float addrspace(3)* %695, align 4, !tbaa !4
  %696 = add nsw i32 %690, %2
  %697 = add nsw i32 %696, %561
  %698 = sext i32 %697 to i64
  %699 = getelementptr inbounds float, float addrspace(1)* %4, i64 %698
  %700 = load float, float addrspace(1)* %699, align 4, !tbaa !4
  %701 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 54, i32 %561
  store float %700, float addrspace(3)* %701, align 4, !tbaa !4
  %702 = add nsw i32 %696, %2
  %703 = add nsw i32 %702, %561
  %704 = sext i32 %703 to i64
  %705 = getelementptr inbounds float, float addrspace(1)* %4, i64 %704
  %706 = load float, float addrspace(1)* %705, align 4, !tbaa !4
  %707 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 55, i32 %561
  store float %706, float addrspace(3)* %707, align 4, !tbaa !4
  %708 = add nsw i32 %702, %2
  %709 = add nsw i32 %708, %561
  %710 = sext i32 %709 to i64
  %711 = getelementptr inbounds float, float addrspace(1)* %4, i64 %710
  %712 = load float, float addrspace(1)* %711, align 4, !tbaa !4
  %713 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 56, i32 %561
  store float %712, float addrspace(3)* %713, align 4, !tbaa !4
  %714 = add nsw i32 %708, %2
  %715 = add nsw i32 %714, %561
  %716 = sext i32 %715 to i64
  %717 = getelementptr inbounds float, float addrspace(1)* %4, i64 %716
  %718 = load float, float addrspace(1)* %717, align 4, !tbaa !4
  %719 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 57, i32 %561
  store float %718, float addrspace(3)* %719, align 4, !tbaa !4
  %720 = add nsw i32 %714, %2
  %721 = add nsw i32 %720, %561
  %722 = sext i32 %721 to i64
  %723 = getelementptr inbounds float, float addrspace(1)* %4, i64 %722
  %724 = load float, float addrspace(1)* %723, align 4, !tbaa !4
  %725 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 58, i32 %561
  store float %724, float addrspace(3)* %725, align 4, !tbaa !4
  %726 = add nsw i32 %720, %2
  %727 = add nsw i32 %726, %561
  %728 = sext i32 %727 to i64
  %729 = getelementptr inbounds float, float addrspace(1)* %4, i64 %728
  %730 = load float, float addrspace(1)* %729, align 4, !tbaa !4
  %731 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 59, i32 %561
  store float %730, float addrspace(3)* %731, align 4, !tbaa !4
  %732 = add nsw i32 %726, %2
  %733 = add nsw i32 %732, %561
  %734 = sext i32 %733 to i64
  %735 = getelementptr inbounds float, float addrspace(1)* %4, i64 %734
  %736 = load float, float addrspace(1)* %735, align 4, !tbaa !4
  %737 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 60, i32 %561
  store float %736, float addrspace(3)* %737, align 4, !tbaa !4
  %738 = add nsw i32 %732, %2
  %739 = add nsw i32 %738, %561
  %740 = sext i32 %739 to i64
  %741 = getelementptr inbounds float, float addrspace(1)* %4, i64 %740
  %742 = load float, float addrspace(1)* %741, align 4, !tbaa !4
  %743 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 61, i32 %561
  store float %742, float addrspace(3)* %743, align 4, !tbaa !4
  %744 = add nsw i32 %738, %2
  %745 = add nsw i32 %744, %561
  %746 = sext i32 %745 to i64
  %747 = getelementptr inbounds float, float addrspace(1)* %4, i64 %746
  %748 = load float, float addrspace(1)* %747, align 4, !tbaa !4
  %749 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 62, i32 %561
  store float %748, float addrspace(3)* %749, align 4, !tbaa !4
  %750 = add nsw i32 %744, %2
  %751 = add nsw i32 %750, %561
  %752 = sext i32 %751 to i64
  %753 = getelementptr inbounds float, float addrspace(1)* %4, i64 %752
  %754 = load float, float addrspace(1)* %753, align 4, !tbaa !4
  %755 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 63, i32 %561
  store float %754, float addrspace(3)* %755, align 4, !tbaa !4
  %756 = shl i32 %6, 6
  %757 = add i32 %1, 64
  %758 = add i32 %757, %756
  %759 = mul i32 %758, %2
  %760 = add i32 %759, %1
  %761 = add nsw i32 %760, %561
  %762 = sext i32 %761 to i64
  %763 = getelementptr inbounds float, float addrspace(1)* %4, i64 %762
  %764 = load float, float addrspace(1)* %763, align 4, !tbaa !4
  %765 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 0, i32 %561
  store float %764, float addrspace(3)* %765, align 4, !tbaa !4
  %766 = add nsw i32 %760, %2
  %767 = add nsw i32 %766, %561
  %768 = sext i32 %767 to i64
  %769 = getelementptr inbounds float, float addrspace(1)* %4, i64 %768
  %770 = load float, float addrspace(1)* %769, align 4, !tbaa !4
  %771 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 1, i32 %561
  store float %770, float addrspace(3)* %771, align 4, !tbaa !4
  %772 = add nsw i32 %766, %2
  %773 = add nsw i32 %772, %561
  %774 = sext i32 %773 to i64
  %775 = getelementptr inbounds float, float addrspace(1)* %4, i64 %774
  %776 = load float, float addrspace(1)* %775, align 4, !tbaa !4
  %777 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 2, i32 %561
  store float %776, float addrspace(3)* %777, align 4, !tbaa !4
  %778 = add nsw i32 %772, %2
  %779 = add nsw i32 %778, %561
  %780 = sext i32 %779 to i64
  %781 = getelementptr inbounds float, float addrspace(1)* %4, i64 %780
  %782 = load float, float addrspace(1)* %781, align 4, !tbaa !4
  %783 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 3, i32 %561
  store float %782, float addrspace(3)* %783, align 4, !tbaa !4
  %784 = add nsw i32 %778, %2
  %785 = add nsw i32 %784, %561
  %786 = sext i32 %785 to i64
  %787 = getelementptr inbounds float, float addrspace(1)* %4, i64 %786
  %788 = load float, float addrspace(1)* %787, align 4, !tbaa !4
  %789 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 4, i32 %561
  store float %788, float addrspace(3)* %789, align 4, !tbaa !4
  %790 = add nsw i32 %784, %2
  %791 = add nsw i32 %790, %561
  %792 = sext i32 %791 to i64
  %793 = getelementptr inbounds float, float addrspace(1)* %4, i64 %792
  %794 = load float, float addrspace(1)* %793, align 4, !tbaa !4
  %795 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 5, i32 %561
  store float %794, float addrspace(3)* %795, align 4, !tbaa !4
  %796 = add nsw i32 %790, %2
  %797 = add nsw i32 %796, %561
  %798 = sext i32 %797 to i64
  %799 = getelementptr inbounds float, float addrspace(1)* %4, i64 %798
  %800 = load float, float addrspace(1)* %799, align 4, !tbaa !4
  %801 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 6, i32 %561
  store float %800, float addrspace(3)* %801, align 4, !tbaa !4
  %802 = add nsw i32 %796, %2
  %803 = add nsw i32 %802, %561
  %804 = sext i32 %803 to i64
  %805 = getelementptr inbounds float, float addrspace(1)* %4, i64 %804
  %806 = load float, float addrspace(1)* %805, align 4, !tbaa !4
  %807 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 7, i32 %561
  store float %806, float addrspace(3)* %807, align 4, !tbaa !4
  %808 = add nsw i32 %802, %2
  %809 = add nsw i32 %808, %561
  %810 = sext i32 %809 to i64
  %811 = getelementptr inbounds float, float addrspace(1)* %4, i64 %810
  %812 = load float, float addrspace(1)* %811, align 4, !tbaa !4
  %813 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 8, i32 %561
  store float %812, float addrspace(3)* %813, align 4, !tbaa !4
  %814 = add nsw i32 %808, %2
  %815 = add nsw i32 %814, %561
  %816 = sext i32 %815 to i64
  %817 = getelementptr inbounds float, float addrspace(1)* %4, i64 %816
  %818 = load float, float addrspace(1)* %817, align 4, !tbaa !4
  %819 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 9, i32 %561
  store float %818, float addrspace(3)* %819, align 4, !tbaa !4
  %820 = add nsw i32 %814, %2
  %821 = add nsw i32 %820, %561
  %822 = sext i32 %821 to i64
  %823 = getelementptr inbounds float, float addrspace(1)* %4, i64 %822
  %824 = load float, float addrspace(1)* %823, align 4, !tbaa !4
  %825 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 10, i32 %561
  store float %824, float addrspace(3)* %825, align 4, !tbaa !4
  %826 = add nsw i32 %820, %2
  %827 = add nsw i32 %826, %561
  %828 = sext i32 %827 to i64
  %829 = getelementptr inbounds float, float addrspace(1)* %4, i64 %828
  %830 = load float, float addrspace(1)* %829, align 4, !tbaa !4
  %831 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 11, i32 %561
  store float %830, float addrspace(3)* %831, align 4, !tbaa !4
  %832 = add nsw i32 %826, %2
  %833 = add nsw i32 %832, %561
  %834 = sext i32 %833 to i64
  %835 = getelementptr inbounds float, float addrspace(1)* %4, i64 %834
  %836 = load float, float addrspace(1)* %835, align 4, !tbaa !4
  %837 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 12, i32 %561
  store float %836, float addrspace(3)* %837, align 4, !tbaa !4
  %838 = add nsw i32 %832, %2
  %839 = add nsw i32 %838, %561
  %840 = sext i32 %839 to i64
  %841 = getelementptr inbounds float, float addrspace(1)* %4, i64 %840
  %842 = load float, float addrspace(1)* %841, align 4, !tbaa !4
  %843 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 13, i32 %561
  store float %842, float addrspace(3)* %843, align 4, !tbaa !4
  %844 = add nsw i32 %838, %2
  %845 = add nsw i32 %844, %561
  %846 = sext i32 %845 to i64
  %847 = getelementptr inbounds float, float addrspace(1)* %4, i64 %846
  %848 = load float, float addrspace(1)* %847, align 4, !tbaa !4
  %849 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 14, i32 %561
  store float %848, float addrspace(3)* %849, align 4, !tbaa !4
  %850 = add nsw i32 %844, %2
  %851 = add nsw i32 %850, %561
  %852 = sext i32 %851 to i64
  %853 = getelementptr inbounds float, float addrspace(1)* %4, i64 %852
  %854 = load float, float addrspace(1)* %853, align 4, !tbaa !4
  %855 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 15, i32 %561
  store float %854, float addrspace(3)* %855, align 4, !tbaa !4
  %856 = add nsw i32 %850, %2
  %857 = add nsw i32 %856, %561
  %858 = sext i32 %857 to i64
  %859 = getelementptr inbounds float, float addrspace(1)* %4, i64 %858
  %860 = load float, float addrspace(1)* %859, align 4, !tbaa !4
  %861 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 16, i32 %561
  store float %860, float addrspace(3)* %861, align 4, !tbaa !4
  %862 = add nsw i32 %856, %2
  %863 = add nsw i32 %862, %561
  %864 = sext i32 %863 to i64
  %865 = getelementptr inbounds float, float addrspace(1)* %4, i64 %864
  %866 = load float, float addrspace(1)* %865, align 4, !tbaa !4
  %867 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 17, i32 %561
  store float %866, float addrspace(3)* %867, align 4, !tbaa !4
  %868 = add nsw i32 %862, %2
  %869 = add nsw i32 %868, %561
  %870 = sext i32 %869 to i64
  %871 = getelementptr inbounds float, float addrspace(1)* %4, i64 %870
  %872 = load float, float addrspace(1)* %871, align 4, !tbaa !4
  %873 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 18, i32 %561
  store float %872, float addrspace(3)* %873, align 4, !tbaa !4
  %874 = add nsw i32 %868, %2
  %875 = add nsw i32 %874, %561
  %876 = sext i32 %875 to i64
  %877 = getelementptr inbounds float, float addrspace(1)* %4, i64 %876
  %878 = load float, float addrspace(1)* %877, align 4, !tbaa !4
  %879 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 19, i32 %561
  store float %878, float addrspace(3)* %879, align 4, !tbaa !4
  %880 = add nsw i32 %874, %2
  %881 = add nsw i32 %880, %561
  %882 = sext i32 %881 to i64
  %883 = getelementptr inbounds float, float addrspace(1)* %4, i64 %882
  %884 = load float, float addrspace(1)* %883, align 4, !tbaa !4
  %885 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 20, i32 %561
  store float %884, float addrspace(3)* %885, align 4, !tbaa !4
  %886 = add nsw i32 %880, %2
  %887 = add nsw i32 %886, %561
  %888 = sext i32 %887 to i64
  %889 = getelementptr inbounds float, float addrspace(1)* %4, i64 %888
  %890 = load float, float addrspace(1)* %889, align 4, !tbaa !4
  %891 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 21, i32 %561
  store float %890, float addrspace(3)* %891, align 4, !tbaa !4
  %892 = add nsw i32 %886, %2
  %893 = add nsw i32 %892, %561
  %894 = sext i32 %893 to i64
  %895 = getelementptr inbounds float, float addrspace(1)* %4, i64 %894
  %896 = load float, float addrspace(1)* %895, align 4, !tbaa !4
  %897 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 22, i32 %561
  store float %896, float addrspace(3)* %897, align 4, !tbaa !4
  %898 = add nsw i32 %892, %2
  %899 = add nsw i32 %898, %561
  %900 = sext i32 %899 to i64
  %901 = getelementptr inbounds float, float addrspace(1)* %4, i64 %900
  %902 = load float, float addrspace(1)* %901, align 4, !tbaa !4
  %903 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 23, i32 %561
  store float %902, float addrspace(3)* %903, align 4, !tbaa !4
  %904 = add nsw i32 %898, %2
  %905 = add nsw i32 %904, %561
  %906 = sext i32 %905 to i64
  %907 = getelementptr inbounds float, float addrspace(1)* %4, i64 %906
  %908 = load float, float addrspace(1)* %907, align 4, !tbaa !4
  %909 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 24, i32 %561
  store float %908, float addrspace(3)* %909, align 4, !tbaa !4
  %910 = add nsw i32 %904, %2
  %911 = add nsw i32 %910, %561
  %912 = sext i32 %911 to i64
  %913 = getelementptr inbounds float, float addrspace(1)* %4, i64 %912
  %914 = load float, float addrspace(1)* %913, align 4, !tbaa !4
  %915 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 25, i32 %561
  store float %914, float addrspace(3)* %915, align 4, !tbaa !4
  %916 = add nsw i32 %910, %2
  %917 = add nsw i32 %916, %561
  %918 = sext i32 %917 to i64
  %919 = getelementptr inbounds float, float addrspace(1)* %4, i64 %918
  %920 = load float, float addrspace(1)* %919, align 4, !tbaa !4
  %921 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 26, i32 %561
  store float %920, float addrspace(3)* %921, align 4, !tbaa !4
  %922 = add nsw i32 %916, %2
  %923 = add nsw i32 %922, %561
  %924 = sext i32 %923 to i64
  %925 = getelementptr inbounds float, float addrspace(1)* %4, i64 %924
  %926 = load float, float addrspace(1)* %925, align 4, !tbaa !4
  %927 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 27, i32 %561
  store float %926, float addrspace(3)* %927, align 4, !tbaa !4
  %928 = add nsw i32 %922, %2
  %929 = add nsw i32 %928, %561
  %930 = sext i32 %929 to i64
  %931 = getelementptr inbounds float, float addrspace(1)* %4, i64 %930
  %932 = load float, float addrspace(1)* %931, align 4, !tbaa !4
  %933 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 28, i32 %561
  store float %932, float addrspace(3)* %933, align 4, !tbaa !4
  %934 = add nsw i32 %928, %2
  %935 = add nsw i32 %934, %561
  %936 = sext i32 %935 to i64
  %937 = getelementptr inbounds float, float addrspace(1)* %4, i64 %936
  %938 = load float, float addrspace(1)* %937, align 4, !tbaa !4
  %939 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 29, i32 %561
  store float %938, float addrspace(3)* %939, align 4, !tbaa !4
  %940 = add nsw i32 %934, %2
  %941 = add nsw i32 %940, %561
  %942 = sext i32 %941 to i64
  %943 = getelementptr inbounds float, float addrspace(1)* %4, i64 %942
  %944 = load float, float addrspace(1)* %943, align 4, !tbaa !4
  %945 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 30, i32 %561
  store float %944, float addrspace(3)* %945, align 4, !tbaa !4
  %946 = add nsw i32 %940, %2
  %947 = add nsw i32 %946, %561
  %948 = sext i32 %947 to i64
  %949 = getelementptr inbounds float, float addrspace(1)* %4, i64 %948
  %950 = load float, float addrspace(1)* %949, align 4, !tbaa !4
  %951 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 31, i32 %561
  store float %950, float addrspace(3)* %951, align 4, !tbaa !4
  %952 = add nsw i32 %946, %2
  %953 = add nsw i32 %952, %561
  %954 = sext i32 %953 to i64
  %955 = getelementptr inbounds float, float addrspace(1)* %4, i64 %954
  %956 = load float, float addrspace(1)* %955, align 4, !tbaa !4
  %957 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 32, i32 %561
  store float %956, float addrspace(3)* %957, align 4, !tbaa !4
  %958 = add nsw i32 %952, %2
  %959 = add nsw i32 %958, %561
  %960 = sext i32 %959 to i64
  %961 = getelementptr inbounds float, float addrspace(1)* %4, i64 %960
  %962 = load float, float addrspace(1)* %961, align 4, !tbaa !4
  %963 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 33, i32 %561
  store float %962, float addrspace(3)* %963, align 4, !tbaa !4
  %964 = add nsw i32 %958, %2
  %965 = add nsw i32 %964, %561
  %966 = sext i32 %965 to i64
  %967 = getelementptr inbounds float, float addrspace(1)* %4, i64 %966
  %968 = load float, float addrspace(1)* %967, align 4, !tbaa !4
  %969 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 34, i32 %561
  store float %968, float addrspace(3)* %969, align 4, !tbaa !4
  %970 = add nsw i32 %964, %2
  %971 = add nsw i32 %970, %561
  %972 = sext i32 %971 to i64
  %973 = getelementptr inbounds float, float addrspace(1)* %4, i64 %972
  %974 = load float, float addrspace(1)* %973, align 4, !tbaa !4
  %975 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 35, i32 %561
  store float %974, float addrspace(3)* %975, align 4, !tbaa !4
  %976 = add nsw i32 %970, %2
  %977 = add nsw i32 %976, %561
  %978 = sext i32 %977 to i64
  %979 = getelementptr inbounds float, float addrspace(1)* %4, i64 %978
  %980 = load float, float addrspace(1)* %979, align 4, !tbaa !4
  %981 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 36, i32 %561
  store float %980, float addrspace(3)* %981, align 4, !tbaa !4
  %982 = add nsw i32 %976, %2
  %983 = add nsw i32 %982, %561
  %984 = sext i32 %983 to i64
  %985 = getelementptr inbounds float, float addrspace(1)* %4, i64 %984
  %986 = load float, float addrspace(1)* %985, align 4, !tbaa !4
  %987 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 37, i32 %561
  store float %986, float addrspace(3)* %987, align 4, !tbaa !4
  %988 = add nsw i32 %982, %2
  %989 = add nsw i32 %988, %561
  %990 = sext i32 %989 to i64
  %991 = getelementptr inbounds float, float addrspace(1)* %4, i64 %990
  %992 = load float, float addrspace(1)* %991, align 4, !tbaa !4
  %993 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 38, i32 %561
  store float %992, float addrspace(3)* %993, align 4, !tbaa !4
  %994 = add nsw i32 %988, %2
  %995 = add nsw i32 %994, %561
  %996 = sext i32 %995 to i64
  %997 = getelementptr inbounds float, float addrspace(1)* %4, i64 %996
  %998 = load float, float addrspace(1)* %997, align 4, !tbaa !4
  %999 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 39, i32 %561
  store float %998, float addrspace(3)* %999, align 4, !tbaa !4
  %1000 = add nsw i32 %994, %2
  %1001 = add nsw i32 %1000, %561
  %1002 = sext i32 %1001 to i64
  %1003 = getelementptr inbounds float, float addrspace(1)* %4, i64 %1002
  %1004 = load float, float addrspace(1)* %1003, align 4, !tbaa !4
  %1005 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 40, i32 %561
  store float %1004, float addrspace(3)* %1005, align 4, !tbaa !4
  %1006 = add nsw i32 %1000, %2
  %1007 = add nsw i32 %1006, %561
  %1008 = sext i32 %1007 to i64
  %1009 = getelementptr inbounds float, float addrspace(1)* %4, i64 %1008
  %1010 = load float, float addrspace(1)* %1009, align 4, !tbaa !4
  %1011 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 41, i32 %561
  store float %1010, float addrspace(3)* %1011, align 4, !tbaa !4
  %1012 = add nsw i32 %1006, %2
  %1013 = add nsw i32 %1012, %561
  %1014 = sext i32 %1013 to i64
  %1015 = getelementptr inbounds float, float addrspace(1)* %4, i64 %1014
  %1016 = load float, float addrspace(1)* %1015, align 4, !tbaa !4
  %1017 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 42, i32 %561
  store float %1016, float addrspace(3)* %1017, align 4, !tbaa !4
  %1018 = add nsw i32 %1012, %2
  %1019 = add nsw i32 %1018, %561
  %1020 = sext i32 %1019 to i64
  %1021 = getelementptr inbounds float, float addrspace(1)* %4, i64 %1020
  %1022 = load float, float addrspace(1)* %1021, align 4, !tbaa !4
  %1023 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 43, i32 %561
  store float %1022, float addrspace(3)* %1023, align 4, !tbaa !4
  %1024 = add nsw i32 %1018, %2
  %1025 = add nsw i32 %1024, %561
  %1026 = sext i32 %1025 to i64
  %1027 = getelementptr inbounds float, float addrspace(1)* %4, i64 %1026
  %1028 = load float, float addrspace(1)* %1027, align 4, !tbaa !4
  %1029 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 44, i32 %561
  store float %1028, float addrspace(3)* %1029, align 4, !tbaa !4
  %1030 = add nsw i32 %1024, %2
  %1031 = add nsw i32 %1030, %561
  %1032 = sext i32 %1031 to i64
  %1033 = getelementptr inbounds float, float addrspace(1)* %4, i64 %1032
  %1034 = load float, float addrspace(1)* %1033, align 4, !tbaa !4
  %1035 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 45, i32 %561
  store float %1034, float addrspace(3)* %1035, align 4, !tbaa !4
  %1036 = add nsw i32 %1030, %2
  %1037 = add nsw i32 %1036, %561
  %1038 = sext i32 %1037 to i64
  %1039 = getelementptr inbounds float, float addrspace(1)* %4, i64 %1038
  %1040 = load float, float addrspace(1)* %1039, align 4, !tbaa !4
  %1041 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 46, i32 %561
  store float %1040, float addrspace(3)* %1041, align 4, !tbaa !4
  %1042 = add nsw i32 %1036, %2
  %1043 = add nsw i32 %1042, %561
  %1044 = sext i32 %1043 to i64
  %1045 = getelementptr inbounds float, float addrspace(1)* %4, i64 %1044
  %1046 = load float, float addrspace(1)* %1045, align 4, !tbaa !4
  %1047 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 47, i32 %561
  store float %1046, float addrspace(3)* %1047, align 4, !tbaa !4
  %1048 = add nsw i32 %1042, %2
  %1049 = add nsw i32 %1048, %561
  %1050 = sext i32 %1049 to i64
  %1051 = getelementptr inbounds float, float addrspace(1)* %4, i64 %1050
  %1052 = load float, float addrspace(1)* %1051, align 4, !tbaa !4
  %1053 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 48, i32 %561
  store float %1052, float addrspace(3)* %1053, align 4, !tbaa !4
  %1054 = add nsw i32 %1048, %2
  %1055 = add nsw i32 %1054, %561
  %1056 = sext i32 %1055 to i64
  %1057 = getelementptr inbounds float, float addrspace(1)* %4, i64 %1056
  %1058 = load float, float addrspace(1)* %1057, align 4, !tbaa !4
  %1059 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 49, i32 %561
  store float %1058, float addrspace(3)* %1059, align 4, !tbaa !4
  %1060 = add nsw i32 %1054, %2
  %1061 = add nsw i32 %1060, %561
  %1062 = sext i32 %1061 to i64
  %1063 = getelementptr inbounds float, float addrspace(1)* %4, i64 %1062
  %1064 = load float, float addrspace(1)* %1063, align 4, !tbaa !4
  %1065 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 50, i32 %561
  store float %1064, float addrspace(3)* %1065, align 4, !tbaa !4
  %1066 = add nsw i32 %1060, %2
  %1067 = add nsw i32 %1066, %561
  %1068 = sext i32 %1067 to i64
  %1069 = getelementptr inbounds float, float addrspace(1)* %4, i64 %1068
  %1070 = load float, float addrspace(1)* %1069, align 4, !tbaa !4
  %1071 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 51, i32 %561
  store float %1070, float addrspace(3)* %1071, align 4, !tbaa !4
  %1072 = add nsw i32 %1066, %2
  %1073 = add nsw i32 %1072, %561
  %1074 = sext i32 %1073 to i64
  %1075 = getelementptr inbounds float, float addrspace(1)* %4, i64 %1074
  %1076 = load float, float addrspace(1)* %1075, align 4, !tbaa !4
  %1077 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 52, i32 %561
  store float %1076, float addrspace(3)* %1077, align 4, !tbaa !4
  %1078 = add nsw i32 %1072, %2
  %1079 = add nsw i32 %1078, %561
  %1080 = sext i32 %1079 to i64
  %1081 = getelementptr inbounds float, float addrspace(1)* %4, i64 %1080
  %1082 = load float, float addrspace(1)* %1081, align 4, !tbaa !4
  %1083 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 53, i32 %561
  store float %1082, float addrspace(3)* %1083, align 4, !tbaa !4
  %1084 = add nsw i32 %1078, %2
  %1085 = add nsw i32 %1084, %561
  %1086 = sext i32 %1085 to i64
  %1087 = getelementptr inbounds float, float addrspace(1)* %4, i64 %1086
  %1088 = load float, float addrspace(1)* %1087, align 4, !tbaa !4
  %1089 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 54, i32 %561
  store float %1088, float addrspace(3)* %1089, align 4, !tbaa !4
  %1090 = add nsw i32 %1084, %2
  %1091 = add nsw i32 %1090, %561
  %1092 = sext i32 %1091 to i64
  %1093 = getelementptr inbounds float, float addrspace(1)* %4, i64 %1092
  %1094 = load float, float addrspace(1)* %1093, align 4, !tbaa !4
  %1095 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 55, i32 %561
  store float %1094, float addrspace(3)* %1095, align 4, !tbaa !4
  %1096 = add nsw i32 %1090, %2
  %1097 = add nsw i32 %1096, %561
  %1098 = sext i32 %1097 to i64
  %1099 = getelementptr inbounds float, float addrspace(1)* %4, i64 %1098
  %1100 = load float, float addrspace(1)* %1099, align 4, !tbaa !4
  %1101 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 56, i32 %561
  store float %1100, float addrspace(3)* %1101, align 4, !tbaa !4
  %1102 = add nsw i32 %1096, %2
  %1103 = add nsw i32 %1102, %561
  %1104 = sext i32 %1103 to i64
  %1105 = getelementptr inbounds float, float addrspace(1)* %4, i64 %1104
  %1106 = load float, float addrspace(1)* %1105, align 4, !tbaa !4
  %1107 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 57, i32 %561
  store float %1106, float addrspace(3)* %1107, align 4, !tbaa !4
  %1108 = add nsw i32 %1102, %2
  %1109 = add nsw i32 %1108, %561
  %1110 = sext i32 %1109 to i64
  %1111 = getelementptr inbounds float, float addrspace(1)* %4, i64 %1110
  %1112 = load float, float addrspace(1)* %1111, align 4, !tbaa !4
  %1113 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 58, i32 %561
  store float %1112, float addrspace(3)* %1113, align 4, !tbaa !4
  %1114 = add nsw i32 %1108, %2
  %1115 = add nsw i32 %1114, %561
  %1116 = sext i32 %1115 to i64
  %1117 = getelementptr inbounds float, float addrspace(1)* %4, i64 %1116
  %1118 = load float, float addrspace(1)* %1117, align 4, !tbaa !4
  %1119 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 59, i32 %561
  store float %1118, float addrspace(3)* %1119, align 4, !tbaa !4
  %1120 = add nsw i32 %1114, %2
  %1121 = add nsw i32 %1120, %561
  %1122 = sext i32 %1121 to i64
  %1123 = getelementptr inbounds float, float addrspace(1)* %4, i64 %1122
  %1124 = load float, float addrspace(1)* %1123, align 4, !tbaa !4
  %1125 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 60, i32 %561
  store float %1124, float addrspace(3)* %1125, align 4, !tbaa !4
  %1126 = add nsw i32 %1120, %2
  %1127 = add nsw i32 %1126, %561
  %1128 = sext i32 %1127 to i64
  %1129 = getelementptr inbounds float, float addrspace(1)* %4, i64 %1128
  %1130 = load float, float addrspace(1)* %1129, align 4, !tbaa !4
  %1131 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 61, i32 %561
  store float %1130, float addrspace(3)* %1131, align 4, !tbaa !4
  %1132 = add nsw i32 %1126, %2
  %1133 = add nsw i32 %1132, %561
  %1134 = sext i32 %1133 to i64
  %1135 = getelementptr inbounds float, float addrspace(1)* %4, i64 %1134
  %1136 = load float, float addrspace(1)* %1135, align 4, !tbaa !4
  %1137 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 62, i32 %561
  store float %1136, float addrspace(3)* %1137, align 4, !tbaa !4
  %1138 = add nsw i32 %1132, %2
  %1139 = add nsw i32 %1138, %561
  %1140 = sext i32 %1139 to i64
  %1141 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %9, i32 0, i32 63, i32 %561
  br label %1142

1142:                                             ; preds = %560, %12
  %1143 = phi float addrspace(3)* [ %559, %12 ], [ %1141, %560 ]
  %1144 = phi i64 [ %558, %12 ], [ %1140, %560 ]
  %1145 = getelementptr inbounds { float addrspace(3)*, i64 }, { float addrspace(3)*, i64 }* %10, i32 0, i32 0
  store float addrspace(3)* %1143, float addrspace(3)** %1145, align 4
  %1146 = getelementptr inbounds { float addrspace(3)*, i64 }, { float addrspace(3)*, i64 }* %10, i32 0, i32 1
  store i64 %1144, i64* %1146, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0, !1}
!dataflow.builtin.operations = !{!2, !3}

!0 = !{i32 3, !"llvm.amdgcn.workitem.id.x"}
!1 = !{i32 6, !"llvm.amdgcn.workgroup.id.x"}
!2 = !{i32 0, i32 225, !"llvm.amdgcn.workgroup.id.x"}
!3 = !{i32 1, i32 227, !"llvm.amdgcn.workgroup.id.x"}
!4 = !{!5, !5, i64 0}
!5 = !{!"float", !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C++ TBAA"}
