; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i32 %1, i32 %2, i32 %3, i64 %4, [32 x [32 x float]] addrspace(3)* %5, i32 %6, float addrspace(1)* %7, [32 x [32 x float]] addrspace(3)* %8, { i64, float addrspace(3)* }* %9) #0 {
  br i1 %0, label %11, label %202

11:                                               ; preds = %10
  %12 = add nsw i32 %1, 1
  %13 = mul nsw i32 %12, %2
  %14 = add nsw i32 %13, %1
  %15 = zext i32 %3 to i64
  %16 = shl nuw nsw i64 %15, 5
  %17 = add nuw nsw i64 %4, 32
  %18 = add nuw nsw i64 %17, %16
  %19 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 1, i32 %6
  %20 = load float, float addrspace(3)* %19, align 4, !tbaa !4
  %21 = sext i32 %14 to i64
  %22 = add nsw i64 %18, %21
  %23 = getelementptr inbounds float, float addrspace(1)* %7, i64 %22
  store float %20, float addrspace(1)* %23, align 4, !tbaa !4
  %24 = add nsw i32 %14, %2
  %25 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 2, i32 %6
  %26 = load float, float addrspace(3)* %25, align 4, !tbaa !4
  %27 = sext i32 %24 to i64
  %28 = add nsw i64 %18, %27
  %29 = getelementptr inbounds float, float addrspace(1)* %7, i64 %28
  store float %26, float addrspace(1)* %29, align 4, !tbaa !4
  %30 = add nsw i32 %24, %2
  %31 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 3, i32 %6
  %32 = load float, float addrspace(3)* %31, align 4, !tbaa !4
  %33 = sext i32 %30 to i64
  %34 = add nsw i64 %18, %33
  %35 = getelementptr inbounds float, float addrspace(1)* %7, i64 %34
  store float %32, float addrspace(1)* %35, align 4, !tbaa !4
  %36 = add nsw i32 %30, %2
  %37 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 4, i32 %6
  %38 = load float, float addrspace(3)* %37, align 4, !tbaa !4
  %39 = sext i32 %36 to i64
  %40 = add nsw i64 %18, %39
  %41 = getelementptr inbounds float, float addrspace(1)* %7, i64 %40
  store float %38, float addrspace(1)* %41, align 4, !tbaa !4
  %42 = add nsw i32 %36, %2
  %43 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 5, i32 %6
  %44 = load float, float addrspace(3)* %43, align 4, !tbaa !4
  %45 = sext i32 %42 to i64
  %46 = add nsw i64 %18, %45
  %47 = getelementptr inbounds float, float addrspace(1)* %7, i64 %46
  store float %44, float addrspace(1)* %47, align 4, !tbaa !4
  %48 = add nsw i32 %42, %2
  %49 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 6, i32 %6
  %50 = load float, float addrspace(3)* %49, align 4, !tbaa !4
  %51 = sext i32 %48 to i64
  %52 = add nsw i64 %18, %51
  %53 = getelementptr inbounds float, float addrspace(1)* %7, i64 %52
  store float %50, float addrspace(1)* %53, align 4, !tbaa !4
  %54 = add nsw i32 %48, %2
  %55 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 7, i32 %6
  %56 = load float, float addrspace(3)* %55, align 4, !tbaa !4
  %57 = sext i32 %54 to i64
  %58 = add nsw i64 %18, %57
  %59 = getelementptr inbounds float, float addrspace(1)* %7, i64 %58
  store float %56, float addrspace(1)* %59, align 4, !tbaa !4
  %60 = add nsw i32 %54, %2
  %61 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 8, i32 %6
  %62 = load float, float addrspace(3)* %61, align 4, !tbaa !4
  %63 = sext i32 %60 to i64
  %64 = add nsw i64 %18, %63
  %65 = getelementptr inbounds float, float addrspace(1)* %7, i64 %64
  store float %62, float addrspace(1)* %65, align 4, !tbaa !4
  %66 = add nsw i32 %60, %2
  %67 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 9, i32 %6
  %68 = load float, float addrspace(3)* %67, align 4, !tbaa !4
  %69 = sext i32 %66 to i64
  %70 = add nsw i64 %18, %69
  %71 = getelementptr inbounds float, float addrspace(1)* %7, i64 %70
  store float %68, float addrspace(1)* %71, align 4, !tbaa !4
  %72 = add nsw i32 %66, %2
  %73 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 10, i32 %6
  %74 = load float, float addrspace(3)* %73, align 4, !tbaa !4
  %75 = sext i32 %72 to i64
  %76 = add nsw i64 %18, %75
  %77 = getelementptr inbounds float, float addrspace(1)* %7, i64 %76
  store float %74, float addrspace(1)* %77, align 4, !tbaa !4
  %78 = add nsw i32 %72, %2
  %79 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 11, i32 %6
  %80 = load float, float addrspace(3)* %79, align 4, !tbaa !4
  %81 = sext i32 %78 to i64
  %82 = add nsw i64 %18, %81
  %83 = getelementptr inbounds float, float addrspace(1)* %7, i64 %82
  store float %80, float addrspace(1)* %83, align 4, !tbaa !4
  %84 = add nsw i32 %78, %2
  %85 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 12, i32 %6
  %86 = load float, float addrspace(3)* %85, align 4, !tbaa !4
  %87 = sext i32 %84 to i64
  %88 = add nsw i64 %18, %87
  %89 = getelementptr inbounds float, float addrspace(1)* %7, i64 %88
  store float %86, float addrspace(1)* %89, align 4, !tbaa !4
  %90 = add nsw i32 %84, %2
  %91 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 13, i32 %6
  %92 = load float, float addrspace(3)* %91, align 4, !tbaa !4
  %93 = sext i32 %90 to i64
  %94 = add nsw i64 %18, %93
  %95 = getelementptr inbounds float, float addrspace(1)* %7, i64 %94
  store float %92, float addrspace(1)* %95, align 4, !tbaa !4
  %96 = add nsw i32 %90, %2
  %97 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 14, i32 %6
  %98 = load float, float addrspace(3)* %97, align 4, !tbaa !4
  %99 = sext i32 %96 to i64
  %100 = add nsw i64 %18, %99
  %101 = getelementptr inbounds float, float addrspace(1)* %7, i64 %100
  store float %98, float addrspace(1)* %101, align 4, !tbaa !4
  %102 = add nsw i32 %96, %2
  %103 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 15, i32 %6
  %104 = load float, float addrspace(3)* %103, align 4, !tbaa !4
  %105 = sext i32 %102 to i64
  %106 = add nsw i64 %18, %105
  %107 = getelementptr inbounds float, float addrspace(1)* %7, i64 %106
  store float %104, float addrspace(1)* %107, align 4, !tbaa !4
  %108 = add nsw i32 %102, %2
  %109 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 16, i32 %6
  %110 = load float, float addrspace(3)* %109, align 4, !tbaa !4
  %111 = sext i32 %108 to i64
  %112 = add nsw i64 %18, %111
  %113 = getelementptr inbounds float, float addrspace(1)* %7, i64 %112
  store float %110, float addrspace(1)* %113, align 4, !tbaa !4
  %114 = add nsw i32 %108, %2
  %115 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 17, i32 %6
  %116 = load float, float addrspace(3)* %115, align 4, !tbaa !4
  %117 = sext i32 %114 to i64
  %118 = add nsw i64 %18, %117
  %119 = getelementptr inbounds float, float addrspace(1)* %7, i64 %118
  store float %116, float addrspace(1)* %119, align 4, !tbaa !4
  %120 = add nsw i32 %114, %2
  %121 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 18, i32 %6
  %122 = load float, float addrspace(3)* %121, align 4, !tbaa !4
  %123 = sext i32 %120 to i64
  %124 = add nsw i64 %18, %123
  %125 = getelementptr inbounds float, float addrspace(1)* %7, i64 %124
  store float %122, float addrspace(1)* %125, align 4, !tbaa !4
  %126 = add nsw i32 %120, %2
  %127 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 19, i32 %6
  %128 = load float, float addrspace(3)* %127, align 4, !tbaa !4
  %129 = sext i32 %126 to i64
  %130 = add nsw i64 %18, %129
  %131 = getelementptr inbounds float, float addrspace(1)* %7, i64 %130
  store float %128, float addrspace(1)* %131, align 4, !tbaa !4
  %132 = add nsw i32 %126, %2
  %133 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 20, i32 %6
  %134 = load float, float addrspace(3)* %133, align 4, !tbaa !4
  %135 = sext i32 %132 to i64
  %136 = add nsw i64 %18, %135
  %137 = getelementptr inbounds float, float addrspace(1)* %7, i64 %136
  store float %134, float addrspace(1)* %137, align 4, !tbaa !4
  %138 = add nsw i32 %132, %2
  %139 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 21, i32 %6
  %140 = load float, float addrspace(3)* %139, align 4, !tbaa !4
  %141 = sext i32 %138 to i64
  %142 = add nsw i64 %18, %141
  %143 = getelementptr inbounds float, float addrspace(1)* %7, i64 %142
  store float %140, float addrspace(1)* %143, align 4, !tbaa !4
  %144 = add nsw i32 %138, %2
  %145 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 22, i32 %6
  %146 = load float, float addrspace(3)* %145, align 4, !tbaa !4
  %147 = sext i32 %144 to i64
  %148 = add nsw i64 %18, %147
  %149 = getelementptr inbounds float, float addrspace(1)* %7, i64 %148
  store float %146, float addrspace(1)* %149, align 4, !tbaa !4
  %150 = add nsw i32 %144, %2
  %151 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 23, i32 %6
  %152 = load float, float addrspace(3)* %151, align 4, !tbaa !4
  %153 = sext i32 %150 to i64
  %154 = add nsw i64 %18, %153
  %155 = getelementptr inbounds float, float addrspace(1)* %7, i64 %154
  store float %152, float addrspace(1)* %155, align 4, !tbaa !4
  %156 = add nsw i32 %150, %2
  %157 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 24, i32 %6
  %158 = load float, float addrspace(3)* %157, align 4, !tbaa !4
  %159 = sext i32 %156 to i64
  %160 = add nsw i64 %18, %159
  %161 = getelementptr inbounds float, float addrspace(1)* %7, i64 %160
  store float %158, float addrspace(1)* %161, align 4, !tbaa !4
  %162 = add nsw i32 %156, %2
  %163 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 25, i32 %6
  %164 = load float, float addrspace(3)* %163, align 4, !tbaa !4
  %165 = sext i32 %162 to i64
  %166 = add nsw i64 %18, %165
  %167 = getelementptr inbounds float, float addrspace(1)* %7, i64 %166
  store float %164, float addrspace(1)* %167, align 4, !tbaa !4
  %168 = add nsw i32 %162, %2
  %169 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 26, i32 %6
  %170 = load float, float addrspace(3)* %169, align 4, !tbaa !4
  %171 = sext i32 %168 to i64
  %172 = add nsw i64 %18, %171
  %173 = getelementptr inbounds float, float addrspace(1)* %7, i64 %172
  store float %170, float addrspace(1)* %173, align 4, !tbaa !4
  %174 = add nsw i32 %168, %2
  %175 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 27, i32 %6
  %176 = load float, float addrspace(3)* %175, align 4, !tbaa !4
  %177 = sext i32 %174 to i64
  %178 = add nsw i64 %18, %177
  %179 = getelementptr inbounds float, float addrspace(1)* %7, i64 %178
  store float %176, float addrspace(1)* %179, align 4, !tbaa !4
  %180 = add nsw i32 %174, %2
  %181 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 28, i32 %6
  %182 = load float, float addrspace(3)* %181, align 4, !tbaa !4
  %183 = sext i32 %180 to i64
  %184 = add nsw i64 %18, %183
  %185 = getelementptr inbounds float, float addrspace(1)* %7, i64 %184
  store float %182, float addrspace(1)* %185, align 4, !tbaa !4
  %186 = add nsw i32 %180, %2
  %187 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 29, i32 %6
  %188 = load float, float addrspace(3)* %187, align 4, !tbaa !4
  %189 = sext i32 %186 to i64
  %190 = add nsw i64 %18, %189
  %191 = getelementptr inbounds float, float addrspace(1)* %7, i64 %190
  store float %188, float addrspace(1)* %191, align 4, !tbaa !4
  %192 = add nsw i32 %186, %2
  %193 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 30, i32 %6
  %194 = load float, float addrspace(3)* %193, align 4, !tbaa !4
  %195 = sext i32 %192 to i64
  %196 = add nsw i64 %18, %195
  %197 = getelementptr inbounds float, float addrspace(1)* %7, i64 %196
  store float %194, float addrspace(1)* %197, align 4, !tbaa !4
  %198 = add nsw i32 %192, %2
  %199 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 31, i32 %6
  %200 = sext i32 %198 to i64
  %201 = add nsw i64 %18, %200
  br label %398

202:                                              ; preds = %10
  %203 = add nsw i32 %6, -32
  %204 = shl i32 %3, 5
  %205 = add i32 %1, 32
  %206 = add i32 %205, %204
  %207 = mul i32 %206, %2
  %208 = add i32 %207, %1
  %209 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 0, i32 %203
  %210 = load float, float addrspace(3)* %209, align 4, !tbaa !4
  %211 = add nsw i32 %208, %203
  %212 = sext i32 %211 to i64
  %213 = getelementptr inbounds float, float addrspace(1)* %7, i64 %212
  store float %210, float addrspace(1)* %213, align 4, !tbaa !4
  %214 = add nsw i32 %208, %2
  %215 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 1, i32 %203
  %216 = load float, float addrspace(3)* %215, align 4, !tbaa !4
  %217 = add nsw i32 %214, %203
  %218 = sext i32 %217 to i64
  %219 = getelementptr inbounds float, float addrspace(1)* %7, i64 %218
  store float %216, float addrspace(1)* %219, align 4, !tbaa !4
  %220 = add nsw i32 %214, %2
  %221 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 2, i32 %203
  %222 = load float, float addrspace(3)* %221, align 4, !tbaa !4
  %223 = add nsw i32 %220, %203
  %224 = sext i32 %223 to i64
  %225 = getelementptr inbounds float, float addrspace(1)* %7, i64 %224
  store float %222, float addrspace(1)* %225, align 4, !tbaa !4
  %226 = add nsw i32 %220, %2
  %227 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 3, i32 %203
  %228 = load float, float addrspace(3)* %227, align 4, !tbaa !4
  %229 = add nsw i32 %226, %203
  %230 = sext i32 %229 to i64
  %231 = getelementptr inbounds float, float addrspace(1)* %7, i64 %230
  store float %228, float addrspace(1)* %231, align 4, !tbaa !4
  %232 = add nsw i32 %226, %2
  %233 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 4, i32 %203
  %234 = load float, float addrspace(3)* %233, align 4, !tbaa !4
  %235 = add nsw i32 %232, %203
  %236 = sext i32 %235 to i64
  %237 = getelementptr inbounds float, float addrspace(1)* %7, i64 %236
  store float %234, float addrspace(1)* %237, align 4, !tbaa !4
  %238 = add nsw i32 %232, %2
  %239 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 5, i32 %203
  %240 = load float, float addrspace(3)* %239, align 4, !tbaa !4
  %241 = add nsw i32 %238, %203
  %242 = sext i32 %241 to i64
  %243 = getelementptr inbounds float, float addrspace(1)* %7, i64 %242
  store float %240, float addrspace(1)* %243, align 4, !tbaa !4
  %244 = add nsw i32 %238, %2
  %245 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 6, i32 %203
  %246 = load float, float addrspace(3)* %245, align 4, !tbaa !4
  %247 = add nsw i32 %244, %203
  %248 = sext i32 %247 to i64
  %249 = getelementptr inbounds float, float addrspace(1)* %7, i64 %248
  store float %246, float addrspace(1)* %249, align 4, !tbaa !4
  %250 = add nsw i32 %244, %2
  %251 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 7, i32 %203
  %252 = load float, float addrspace(3)* %251, align 4, !tbaa !4
  %253 = add nsw i32 %250, %203
  %254 = sext i32 %253 to i64
  %255 = getelementptr inbounds float, float addrspace(1)* %7, i64 %254
  store float %252, float addrspace(1)* %255, align 4, !tbaa !4
  %256 = add nsw i32 %250, %2
  %257 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 8, i32 %203
  %258 = load float, float addrspace(3)* %257, align 4, !tbaa !4
  %259 = add nsw i32 %256, %203
  %260 = sext i32 %259 to i64
  %261 = getelementptr inbounds float, float addrspace(1)* %7, i64 %260
  store float %258, float addrspace(1)* %261, align 4, !tbaa !4
  %262 = add nsw i32 %256, %2
  %263 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 9, i32 %203
  %264 = load float, float addrspace(3)* %263, align 4, !tbaa !4
  %265 = add nsw i32 %262, %203
  %266 = sext i32 %265 to i64
  %267 = getelementptr inbounds float, float addrspace(1)* %7, i64 %266
  store float %264, float addrspace(1)* %267, align 4, !tbaa !4
  %268 = add nsw i32 %262, %2
  %269 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 10, i32 %203
  %270 = load float, float addrspace(3)* %269, align 4, !tbaa !4
  %271 = add nsw i32 %268, %203
  %272 = sext i32 %271 to i64
  %273 = getelementptr inbounds float, float addrspace(1)* %7, i64 %272
  store float %270, float addrspace(1)* %273, align 4, !tbaa !4
  %274 = add nsw i32 %268, %2
  %275 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 11, i32 %203
  %276 = load float, float addrspace(3)* %275, align 4, !tbaa !4
  %277 = add nsw i32 %274, %203
  %278 = sext i32 %277 to i64
  %279 = getelementptr inbounds float, float addrspace(1)* %7, i64 %278
  store float %276, float addrspace(1)* %279, align 4, !tbaa !4
  %280 = add nsw i32 %274, %2
  %281 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 12, i32 %203
  %282 = load float, float addrspace(3)* %281, align 4, !tbaa !4
  %283 = add nsw i32 %280, %203
  %284 = sext i32 %283 to i64
  %285 = getelementptr inbounds float, float addrspace(1)* %7, i64 %284
  store float %282, float addrspace(1)* %285, align 4, !tbaa !4
  %286 = add nsw i32 %280, %2
  %287 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 13, i32 %203
  %288 = load float, float addrspace(3)* %287, align 4, !tbaa !4
  %289 = add nsw i32 %286, %203
  %290 = sext i32 %289 to i64
  %291 = getelementptr inbounds float, float addrspace(1)* %7, i64 %290
  store float %288, float addrspace(1)* %291, align 4, !tbaa !4
  %292 = add nsw i32 %286, %2
  %293 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 14, i32 %203
  %294 = load float, float addrspace(3)* %293, align 4, !tbaa !4
  %295 = add nsw i32 %292, %203
  %296 = sext i32 %295 to i64
  %297 = getelementptr inbounds float, float addrspace(1)* %7, i64 %296
  store float %294, float addrspace(1)* %297, align 4, !tbaa !4
  %298 = add nsw i32 %292, %2
  %299 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 15, i32 %203
  %300 = load float, float addrspace(3)* %299, align 4, !tbaa !4
  %301 = add nsw i32 %298, %203
  %302 = sext i32 %301 to i64
  %303 = getelementptr inbounds float, float addrspace(1)* %7, i64 %302
  store float %300, float addrspace(1)* %303, align 4, !tbaa !4
  %304 = add nsw i32 %298, %2
  %305 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 16, i32 %203
  %306 = load float, float addrspace(3)* %305, align 4, !tbaa !4
  %307 = add nsw i32 %304, %203
  %308 = sext i32 %307 to i64
  %309 = getelementptr inbounds float, float addrspace(1)* %7, i64 %308
  store float %306, float addrspace(1)* %309, align 4, !tbaa !4
  %310 = add nsw i32 %304, %2
  %311 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 17, i32 %203
  %312 = load float, float addrspace(3)* %311, align 4, !tbaa !4
  %313 = add nsw i32 %310, %203
  %314 = sext i32 %313 to i64
  %315 = getelementptr inbounds float, float addrspace(1)* %7, i64 %314
  store float %312, float addrspace(1)* %315, align 4, !tbaa !4
  %316 = add nsw i32 %310, %2
  %317 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 18, i32 %203
  %318 = load float, float addrspace(3)* %317, align 4, !tbaa !4
  %319 = add nsw i32 %316, %203
  %320 = sext i32 %319 to i64
  %321 = getelementptr inbounds float, float addrspace(1)* %7, i64 %320
  store float %318, float addrspace(1)* %321, align 4, !tbaa !4
  %322 = add nsw i32 %316, %2
  %323 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 19, i32 %203
  %324 = load float, float addrspace(3)* %323, align 4, !tbaa !4
  %325 = add nsw i32 %322, %203
  %326 = sext i32 %325 to i64
  %327 = getelementptr inbounds float, float addrspace(1)* %7, i64 %326
  store float %324, float addrspace(1)* %327, align 4, !tbaa !4
  %328 = add nsw i32 %322, %2
  %329 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 20, i32 %203
  %330 = load float, float addrspace(3)* %329, align 4, !tbaa !4
  %331 = add nsw i32 %328, %203
  %332 = sext i32 %331 to i64
  %333 = getelementptr inbounds float, float addrspace(1)* %7, i64 %332
  store float %330, float addrspace(1)* %333, align 4, !tbaa !4
  %334 = add nsw i32 %328, %2
  %335 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 21, i32 %203
  %336 = load float, float addrspace(3)* %335, align 4, !tbaa !4
  %337 = add nsw i32 %334, %203
  %338 = sext i32 %337 to i64
  %339 = getelementptr inbounds float, float addrspace(1)* %7, i64 %338
  store float %336, float addrspace(1)* %339, align 4, !tbaa !4
  %340 = add nsw i32 %334, %2
  %341 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 22, i32 %203
  %342 = load float, float addrspace(3)* %341, align 4, !tbaa !4
  %343 = add nsw i32 %340, %203
  %344 = sext i32 %343 to i64
  %345 = getelementptr inbounds float, float addrspace(1)* %7, i64 %344
  store float %342, float addrspace(1)* %345, align 4, !tbaa !4
  %346 = add nsw i32 %340, %2
  %347 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 23, i32 %203
  %348 = load float, float addrspace(3)* %347, align 4, !tbaa !4
  %349 = add nsw i32 %346, %203
  %350 = sext i32 %349 to i64
  %351 = getelementptr inbounds float, float addrspace(1)* %7, i64 %350
  store float %348, float addrspace(1)* %351, align 4, !tbaa !4
  %352 = add nsw i32 %346, %2
  %353 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 24, i32 %203
  %354 = load float, float addrspace(3)* %353, align 4, !tbaa !4
  %355 = add nsw i32 %352, %203
  %356 = sext i32 %355 to i64
  %357 = getelementptr inbounds float, float addrspace(1)* %7, i64 %356
  store float %354, float addrspace(1)* %357, align 4, !tbaa !4
  %358 = add nsw i32 %352, %2
  %359 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 25, i32 %203
  %360 = load float, float addrspace(3)* %359, align 4, !tbaa !4
  %361 = add nsw i32 %358, %203
  %362 = sext i32 %361 to i64
  %363 = getelementptr inbounds float, float addrspace(1)* %7, i64 %362
  store float %360, float addrspace(1)* %363, align 4, !tbaa !4
  %364 = add nsw i32 %358, %2
  %365 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 26, i32 %203
  %366 = load float, float addrspace(3)* %365, align 4, !tbaa !4
  %367 = add nsw i32 %364, %203
  %368 = sext i32 %367 to i64
  %369 = getelementptr inbounds float, float addrspace(1)* %7, i64 %368
  store float %366, float addrspace(1)* %369, align 4, !tbaa !4
  %370 = add nsw i32 %364, %2
  %371 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 27, i32 %203
  %372 = load float, float addrspace(3)* %371, align 4, !tbaa !4
  %373 = add nsw i32 %370, %203
  %374 = sext i32 %373 to i64
  %375 = getelementptr inbounds float, float addrspace(1)* %7, i64 %374
  store float %372, float addrspace(1)* %375, align 4, !tbaa !4
  %376 = add nsw i32 %370, %2
  %377 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 28, i32 %203
  %378 = load float, float addrspace(3)* %377, align 4, !tbaa !4
  %379 = add nsw i32 %376, %203
  %380 = sext i32 %379 to i64
  %381 = getelementptr inbounds float, float addrspace(1)* %7, i64 %380
  store float %378, float addrspace(1)* %381, align 4, !tbaa !4
  %382 = add nsw i32 %376, %2
  %383 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 29, i32 %203
  %384 = load float, float addrspace(3)* %383, align 4, !tbaa !4
  %385 = add nsw i32 %382, %203
  %386 = sext i32 %385 to i64
  %387 = getelementptr inbounds float, float addrspace(1)* %7, i64 %386
  store float %384, float addrspace(1)* %387, align 4, !tbaa !4
  %388 = add nsw i32 %382, %2
  %389 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 30, i32 %203
  %390 = load float, float addrspace(3)* %389, align 4, !tbaa !4
  %391 = add nsw i32 %388, %203
  %392 = sext i32 %391 to i64
  %393 = getelementptr inbounds float, float addrspace(1)* %7, i64 %392
  store float %390, float addrspace(1)* %393, align 4, !tbaa !4
  %394 = add nsw i32 %388, %2
  %395 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 31, i32 %203
  %396 = add nsw i32 %394, %203
  %397 = sext i32 %396 to i64
  br label %398

398:                                              ; preds = %202, %11
  %399 = phi i64 [ %201, %11 ], [ %397, %202 ]
  %400 = phi float addrspace(3)* [ %199, %11 ], [ %395, %202 ]
  %401 = getelementptr inbounds { i64, float addrspace(3)* }, { i64, float addrspace(3)* }* %9, i32 0, i32 0
  store i64 %399, i64* %401, align 8
  %402 = getelementptr inbounds { i64, float addrspace(3)* }, { i64, float addrspace(3)* }* %9, i32 0, i32 1
  store float addrspace(3)* %400, float addrspace(3)** %402, align 4
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
