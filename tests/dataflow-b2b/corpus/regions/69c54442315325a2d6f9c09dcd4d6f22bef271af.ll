; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i32 %1, i32 %2, i32 %3, i64 %4, [64 x [64 x float]] addrspace(3)* %5, i32 %6, float addrspace(1)* %7, [64 x [64 x float]] addrspace(3)* %8, { i64, float addrspace(3)* }* %9) #0 {
  br i1 %0, label %11, label %394

11:                                               ; preds = %10
  %12 = add nsw i32 %1, 1
  %13 = mul nsw i32 %12, %2
  %14 = add nsw i32 %13, %1
  %15 = zext i32 %3 to i64
  %16 = shl nuw nsw i64 %15, 6
  %17 = add nuw nsw i64 %4, 64
  %18 = add nuw nsw i64 %17, %16
  %19 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 1, i32 %6
  %20 = load float, float addrspace(3)* %19, align 4, !tbaa !4
  %21 = sext i32 %14 to i64
  %22 = add nsw i64 %18, %21
  %23 = getelementptr inbounds float, float addrspace(1)* %7, i64 %22
  store float %20, float addrspace(1)* %23, align 4, !tbaa !4
  %24 = add nsw i32 %14, %2
  %25 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 2, i32 %6
  %26 = load float, float addrspace(3)* %25, align 4, !tbaa !4
  %27 = sext i32 %24 to i64
  %28 = add nsw i64 %18, %27
  %29 = getelementptr inbounds float, float addrspace(1)* %7, i64 %28
  store float %26, float addrspace(1)* %29, align 4, !tbaa !4
  %30 = add nsw i32 %24, %2
  %31 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 3, i32 %6
  %32 = load float, float addrspace(3)* %31, align 4, !tbaa !4
  %33 = sext i32 %30 to i64
  %34 = add nsw i64 %18, %33
  %35 = getelementptr inbounds float, float addrspace(1)* %7, i64 %34
  store float %32, float addrspace(1)* %35, align 4, !tbaa !4
  %36 = add nsw i32 %30, %2
  %37 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 4, i32 %6
  %38 = load float, float addrspace(3)* %37, align 4, !tbaa !4
  %39 = sext i32 %36 to i64
  %40 = add nsw i64 %18, %39
  %41 = getelementptr inbounds float, float addrspace(1)* %7, i64 %40
  store float %38, float addrspace(1)* %41, align 4, !tbaa !4
  %42 = add nsw i32 %36, %2
  %43 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 5, i32 %6
  %44 = load float, float addrspace(3)* %43, align 4, !tbaa !4
  %45 = sext i32 %42 to i64
  %46 = add nsw i64 %18, %45
  %47 = getelementptr inbounds float, float addrspace(1)* %7, i64 %46
  store float %44, float addrspace(1)* %47, align 4, !tbaa !4
  %48 = add nsw i32 %42, %2
  %49 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 6, i32 %6
  %50 = load float, float addrspace(3)* %49, align 4, !tbaa !4
  %51 = sext i32 %48 to i64
  %52 = add nsw i64 %18, %51
  %53 = getelementptr inbounds float, float addrspace(1)* %7, i64 %52
  store float %50, float addrspace(1)* %53, align 4, !tbaa !4
  %54 = add nsw i32 %48, %2
  %55 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 7, i32 %6
  %56 = load float, float addrspace(3)* %55, align 4, !tbaa !4
  %57 = sext i32 %54 to i64
  %58 = add nsw i64 %18, %57
  %59 = getelementptr inbounds float, float addrspace(1)* %7, i64 %58
  store float %56, float addrspace(1)* %59, align 4, !tbaa !4
  %60 = add nsw i32 %54, %2
  %61 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 8, i32 %6
  %62 = load float, float addrspace(3)* %61, align 4, !tbaa !4
  %63 = sext i32 %60 to i64
  %64 = add nsw i64 %18, %63
  %65 = getelementptr inbounds float, float addrspace(1)* %7, i64 %64
  store float %62, float addrspace(1)* %65, align 4, !tbaa !4
  %66 = add nsw i32 %60, %2
  %67 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 9, i32 %6
  %68 = load float, float addrspace(3)* %67, align 4, !tbaa !4
  %69 = sext i32 %66 to i64
  %70 = add nsw i64 %18, %69
  %71 = getelementptr inbounds float, float addrspace(1)* %7, i64 %70
  store float %68, float addrspace(1)* %71, align 4, !tbaa !4
  %72 = add nsw i32 %66, %2
  %73 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 10, i32 %6
  %74 = load float, float addrspace(3)* %73, align 4, !tbaa !4
  %75 = sext i32 %72 to i64
  %76 = add nsw i64 %18, %75
  %77 = getelementptr inbounds float, float addrspace(1)* %7, i64 %76
  store float %74, float addrspace(1)* %77, align 4, !tbaa !4
  %78 = add nsw i32 %72, %2
  %79 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 11, i32 %6
  %80 = load float, float addrspace(3)* %79, align 4, !tbaa !4
  %81 = sext i32 %78 to i64
  %82 = add nsw i64 %18, %81
  %83 = getelementptr inbounds float, float addrspace(1)* %7, i64 %82
  store float %80, float addrspace(1)* %83, align 4, !tbaa !4
  %84 = add nsw i32 %78, %2
  %85 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 12, i32 %6
  %86 = load float, float addrspace(3)* %85, align 4, !tbaa !4
  %87 = sext i32 %84 to i64
  %88 = add nsw i64 %18, %87
  %89 = getelementptr inbounds float, float addrspace(1)* %7, i64 %88
  store float %86, float addrspace(1)* %89, align 4, !tbaa !4
  %90 = add nsw i32 %84, %2
  %91 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 13, i32 %6
  %92 = load float, float addrspace(3)* %91, align 4, !tbaa !4
  %93 = sext i32 %90 to i64
  %94 = add nsw i64 %18, %93
  %95 = getelementptr inbounds float, float addrspace(1)* %7, i64 %94
  store float %92, float addrspace(1)* %95, align 4, !tbaa !4
  %96 = add nsw i32 %90, %2
  %97 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 14, i32 %6
  %98 = load float, float addrspace(3)* %97, align 4, !tbaa !4
  %99 = sext i32 %96 to i64
  %100 = add nsw i64 %18, %99
  %101 = getelementptr inbounds float, float addrspace(1)* %7, i64 %100
  store float %98, float addrspace(1)* %101, align 4, !tbaa !4
  %102 = add nsw i32 %96, %2
  %103 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 15, i32 %6
  %104 = load float, float addrspace(3)* %103, align 4, !tbaa !4
  %105 = sext i32 %102 to i64
  %106 = add nsw i64 %18, %105
  %107 = getelementptr inbounds float, float addrspace(1)* %7, i64 %106
  store float %104, float addrspace(1)* %107, align 4, !tbaa !4
  %108 = add nsw i32 %102, %2
  %109 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 16, i32 %6
  %110 = load float, float addrspace(3)* %109, align 4, !tbaa !4
  %111 = sext i32 %108 to i64
  %112 = add nsw i64 %18, %111
  %113 = getelementptr inbounds float, float addrspace(1)* %7, i64 %112
  store float %110, float addrspace(1)* %113, align 4, !tbaa !4
  %114 = add nsw i32 %108, %2
  %115 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 17, i32 %6
  %116 = load float, float addrspace(3)* %115, align 4, !tbaa !4
  %117 = sext i32 %114 to i64
  %118 = add nsw i64 %18, %117
  %119 = getelementptr inbounds float, float addrspace(1)* %7, i64 %118
  store float %116, float addrspace(1)* %119, align 4, !tbaa !4
  %120 = add nsw i32 %114, %2
  %121 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 18, i32 %6
  %122 = load float, float addrspace(3)* %121, align 4, !tbaa !4
  %123 = sext i32 %120 to i64
  %124 = add nsw i64 %18, %123
  %125 = getelementptr inbounds float, float addrspace(1)* %7, i64 %124
  store float %122, float addrspace(1)* %125, align 4, !tbaa !4
  %126 = add nsw i32 %120, %2
  %127 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 19, i32 %6
  %128 = load float, float addrspace(3)* %127, align 4, !tbaa !4
  %129 = sext i32 %126 to i64
  %130 = add nsw i64 %18, %129
  %131 = getelementptr inbounds float, float addrspace(1)* %7, i64 %130
  store float %128, float addrspace(1)* %131, align 4, !tbaa !4
  %132 = add nsw i32 %126, %2
  %133 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 20, i32 %6
  %134 = load float, float addrspace(3)* %133, align 4, !tbaa !4
  %135 = sext i32 %132 to i64
  %136 = add nsw i64 %18, %135
  %137 = getelementptr inbounds float, float addrspace(1)* %7, i64 %136
  store float %134, float addrspace(1)* %137, align 4, !tbaa !4
  %138 = add nsw i32 %132, %2
  %139 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 21, i32 %6
  %140 = load float, float addrspace(3)* %139, align 4, !tbaa !4
  %141 = sext i32 %138 to i64
  %142 = add nsw i64 %18, %141
  %143 = getelementptr inbounds float, float addrspace(1)* %7, i64 %142
  store float %140, float addrspace(1)* %143, align 4, !tbaa !4
  %144 = add nsw i32 %138, %2
  %145 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 22, i32 %6
  %146 = load float, float addrspace(3)* %145, align 4, !tbaa !4
  %147 = sext i32 %144 to i64
  %148 = add nsw i64 %18, %147
  %149 = getelementptr inbounds float, float addrspace(1)* %7, i64 %148
  store float %146, float addrspace(1)* %149, align 4, !tbaa !4
  %150 = add nsw i32 %144, %2
  %151 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 23, i32 %6
  %152 = load float, float addrspace(3)* %151, align 4, !tbaa !4
  %153 = sext i32 %150 to i64
  %154 = add nsw i64 %18, %153
  %155 = getelementptr inbounds float, float addrspace(1)* %7, i64 %154
  store float %152, float addrspace(1)* %155, align 4, !tbaa !4
  %156 = add nsw i32 %150, %2
  %157 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 24, i32 %6
  %158 = load float, float addrspace(3)* %157, align 4, !tbaa !4
  %159 = sext i32 %156 to i64
  %160 = add nsw i64 %18, %159
  %161 = getelementptr inbounds float, float addrspace(1)* %7, i64 %160
  store float %158, float addrspace(1)* %161, align 4, !tbaa !4
  %162 = add nsw i32 %156, %2
  %163 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 25, i32 %6
  %164 = load float, float addrspace(3)* %163, align 4, !tbaa !4
  %165 = sext i32 %162 to i64
  %166 = add nsw i64 %18, %165
  %167 = getelementptr inbounds float, float addrspace(1)* %7, i64 %166
  store float %164, float addrspace(1)* %167, align 4, !tbaa !4
  %168 = add nsw i32 %162, %2
  %169 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 26, i32 %6
  %170 = load float, float addrspace(3)* %169, align 4, !tbaa !4
  %171 = sext i32 %168 to i64
  %172 = add nsw i64 %18, %171
  %173 = getelementptr inbounds float, float addrspace(1)* %7, i64 %172
  store float %170, float addrspace(1)* %173, align 4, !tbaa !4
  %174 = add nsw i32 %168, %2
  %175 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 27, i32 %6
  %176 = load float, float addrspace(3)* %175, align 4, !tbaa !4
  %177 = sext i32 %174 to i64
  %178 = add nsw i64 %18, %177
  %179 = getelementptr inbounds float, float addrspace(1)* %7, i64 %178
  store float %176, float addrspace(1)* %179, align 4, !tbaa !4
  %180 = add nsw i32 %174, %2
  %181 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 28, i32 %6
  %182 = load float, float addrspace(3)* %181, align 4, !tbaa !4
  %183 = sext i32 %180 to i64
  %184 = add nsw i64 %18, %183
  %185 = getelementptr inbounds float, float addrspace(1)* %7, i64 %184
  store float %182, float addrspace(1)* %185, align 4, !tbaa !4
  %186 = add nsw i32 %180, %2
  %187 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 29, i32 %6
  %188 = load float, float addrspace(3)* %187, align 4, !tbaa !4
  %189 = sext i32 %186 to i64
  %190 = add nsw i64 %18, %189
  %191 = getelementptr inbounds float, float addrspace(1)* %7, i64 %190
  store float %188, float addrspace(1)* %191, align 4, !tbaa !4
  %192 = add nsw i32 %186, %2
  %193 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 30, i32 %6
  %194 = load float, float addrspace(3)* %193, align 4, !tbaa !4
  %195 = sext i32 %192 to i64
  %196 = add nsw i64 %18, %195
  %197 = getelementptr inbounds float, float addrspace(1)* %7, i64 %196
  store float %194, float addrspace(1)* %197, align 4, !tbaa !4
  %198 = add nsw i32 %192, %2
  %199 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 31, i32 %6
  %200 = load float, float addrspace(3)* %199, align 4, !tbaa !4
  %201 = sext i32 %198 to i64
  %202 = add nsw i64 %18, %201
  %203 = getelementptr inbounds float, float addrspace(1)* %7, i64 %202
  store float %200, float addrspace(1)* %203, align 4, !tbaa !4
  %204 = add nsw i32 %198, %2
  %205 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 32, i32 %6
  %206 = load float, float addrspace(3)* %205, align 4, !tbaa !4
  %207 = sext i32 %204 to i64
  %208 = add nsw i64 %18, %207
  %209 = getelementptr inbounds float, float addrspace(1)* %7, i64 %208
  store float %206, float addrspace(1)* %209, align 4, !tbaa !4
  %210 = add nsw i32 %204, %2
  %211 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 33, i32 %6
  %212 = load float, float addrspace(3)* %211, align 4, !tbaa !4
  %213 = sext i32 %210 to i64
  %214 = add nsw i64 %18, %213
  %215 = getelementptr inbounds float, float addrspace(1)* %7, i64 %214
  store float %212, float addrspace(1)* %215, align 4, !tbaa !4
  %216 = add nsw i32 %210, %2
  %217 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 34, i32 %6
  %218 = load float, float addrspace(3)* %217, align 4, !tbaa !4
  %219 = sext i32 %216 to i64
  %220 = add nsw i64 %18, %219
  %221 = getelementptr inbounds float, float addrspace(1)* %7, i64 %220
  store float %218, float addrspace(1)* %221, align 4, !tbaa !4
  %222 = add nsw i32 %216, %2
  %223 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 35, i32 %6
  %224 = load float, float addrspace(3)* %223, align 4, !tbaa !4
  %225 = sext i32 %222 to i64
  %226 = add nsw i64 %18, %225
  %227 = getelementptr inbounds float, float addrspace(1)* %7, i64 %226
  store float %224, float addrspace(1)* %227, align 4, !tbaa !4
  %228 = add nsw i32 %222, %2
  %229 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 36, i32 %6
  %230 = load float, float addrspace(3)* %229, align 4, !tbaa !4
  %231 = sext i32 %228 to i64
  %232 = add nsw i64 %18, %231
  %233 = getelementptr inbounds float, float addrspace(1)* %7, i64 %232
  store float %230, float addrspace(1)* %233, align 4, !tbaa !4
  %234 = add nsw i32 %228, %2
  %235 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 37, i32 %6
  %236 = load float, float addrspace(3)* %235, align 4, !tbaa !4
  %237 = sext i32 %234 to i64
  %238 = add nsw i64 %18, %237
  %239 = getelementptr inbounds float, float addrspace(1)* %7, i64 %238
  store float %236, float addrspace(1)* %239, align 4, !tbaa !4
  %240 = add nsw i32 %234, %2
  %241 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 38, i32 %6
  %242 = load float, float addrspace(3)* %241, align 4, !tbaa !4
  %243 = sext i32 %240 to i64
  %244 = add nsw i64 %18, %243
  %245 = getelementptr inbounds float, float addrspace(1)* %7, i64 %244
  store float %242, float addrspace(1)* %245, align 4, !tbaa !4
  %246 = add nsw i32 %240, %2
  %247 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 39, i32 %6
  %248 = load float, float addrspace(3)* %247, align 4, !tbaa !4
  %249 = sext i32 %246 to i64
  %250 = add nsw i64 %18, %249
  %251 = getelementptr inbounds float, float addrspace(1)* %7, i64 %250
  store float %248, float addrspace(1)* %251, align 4, !tbaa !4
  %252 = add nsw i32 %246, %2
  %253 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 40, i32 %6
  %254 = load float, float addrspace(3)* %253, align 4, !tbaa !4
  %255 = sext i32 %252 to i64
  %256 = add nsw i64 %18, %255
  %257 = getelementptr inbounds float, float addrspace(1)* %7, i64 %256
  store float %254, float addrspace(1)* %257, align 4, !tbaa !4
  %258 = add nsw i32 %252, %2
  %259 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 41, i32 %6
  %260 = load float, float addrspace(3)* %259, align 4, !tbaa !4
  %261 = sext i32 %258 to i64
  %262 = add nsw i64 %18, %261
  %263 = getelementptr inbounds float, float addrspace(1)* %7, i64 %262
  store float %260, float addrspace(1)* %263, align 4, !tbaa !4
  %264 = add nsw i32 %258, %2
  %265 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 42, i32 %6
  %266 = load float, float addrspace(3)* %265, align 4, !tbaa !4
  %267 = sext i32 %264 to i64
  %268 = add nsw i64 %18, %267
  %269 = getelementptr inbounds float, float addrspace(1)* %7, i64 %268
  store float %266, float addrspace(1)* %269, align 4, !tbaa !4
  %270 = add nsw i32 %264, %2
  %271 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 43, i32 %6
  %272 = load float, float addrspace(3)* %271, align 4, !tbaa !4
  %273 = sext i32 %270 to i64
  %274 = add nsw i64 %18, %273
  %275 = getelementptr inbounds float, float addrspace(1)* %7, i64 %274
  store float %272, float addrspace(1)* %275, align 4, !tbaa !4
  %276 = add nsw i32 %270, %2
  %277 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 44, i32 %6
  %278 = load float, float addrspace(3)* %277, align 4, !tbaa !4
  %279 = sext i32 %276 to i64
  %280 = add nsw i64 %18, %279
  %281 = getelementptr inbounds float, float addrspace(1)* %7, i64 %280
  store float %278, float addrspace(1)* %281, align 4, !tbaa !4
  %282 = add nsw i32 %276, %2
  %283 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 45, i32 %6
  %284 = load float, float addrspace(3)* %283, align 4, !tbaa !4
  %285 = sext i32 %282 to i64
  %286 = add nsw i64 %18, %285
  %287 = getelementptr inbounds float, float addrspace(1)* %7, i64 %286
  store float %284, float addrspace(1)* %287, align 4, !tbaa !4
  %288 = add nsw i32 %282, %2
  %289 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 46, i32 %6
  %290 = load float, float addrspace(3)* %289, align 4, !tbaa !4
  %291 = sext i32 %288 to i64
  %292 = add nsw i64 %18, %291
  %293 = getelementptr inbounds float, float addrspace(1)* %7, i64 %292
  store float %290, float addrspace(1)* %293, align 4, !tbaa !4
  %294 = add nsw i32 %288, %2
  %295 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 47, i32 %6
  %296 = load float, float addrspace(3)* %295, align 4, !tbaa !4
  %297 = sext i32 %294 to i64
  %298 = add nsw i64 %18, %297
  %299 = getelementptr inbounds float, float addrspace(1)* %7, i64 %298
  store float %296, float addrspace(1)* %299, align 4, !tbaa !4
  %300 = add nsw i32 %294, %2
  %301 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 48, i32 %6
  %302 = load float, float addrspace(3)* %301, align 4, !tbaa !4
  %303 = sext i32 %300 to i64
  %304 = add nsw i64 %18, %303
  %305 = getelementptr inbounds float, float addrspace(1)* %7, i64 %304
  store float %302, float addrspace(1)* %305, align 4, !tbaa !4
  %306 = add nsw i32 %300, %2
  %307 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 49, i32 %6
  %308 = load float, float addrspace(3)* %307, align 4, !tbaa !4
  %309 = sext i32 %306 to i64
  %310 = add nsw i64 %18, %309
  %311 = getelementptr inbounds float, float addrspace(1)* %7, i64 %310
  store float %308, float addrspace(1)* %311, align 4, !tbaa !4
  %312 = add nsw i32 %306, %2
  %313 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 50, i32 %6
  %314 = load float, float addrspace(3)* %313, align 4, !tbaa !4
  %315 = sext i32 %312 to i64
  %316 = add nsw i64 %18, %315
  %317 = getelementptr inbounds float, float addrspace(1)* %7, i64 %316
  store float %314, float addrspace(1)* %317, align 4, !tbaa !4
  %318 = add nsw i32 %312, %2
  %319 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 51, i32 %6
  %320 = load float, float addrspace(3)* %319, align 4, !tbaa !4
  %321 = sext i32 %318 to i64
  %322 = add nsw i64 %18, %321
  %323 = getelementptr inbounds float, float addrspace(1)* %7, i64 %322
  store float %320, float addrspace(1)* %323, align 4, !tbaa !4
  %324 = add nsw i32 %318, %2
  %325 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 52, i32 %6
  %326 = load float, float addrspace(3)* %325, align 4, !tbaa !4
  %327 = sext i32 %324 to i64
  %328 = add nsw i64 %18, %327
  %329 = getelementptr inbounds float, float addrspace(1)* %7, i64 %328
  store float %326, float addrspace(1)* %329, align 4, !tbaa !4
  %330 = add nsw i32 %324, %2
  %331 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 53, i32 %6
  %332 = load float, float addrspace(3)* %331, align 4, !tbaa !4
  %333 = sext i32 %330 to i64
  %334 = add nsw i64 %18, %333
  %335 = getelementptr inbounds float, float addrspace(1)* %7, i64 %334
  store float %332, float addrspace(1)* %335, align 4, !tbaa !4
  %336 = add nsw i32 %330, %2
  %337 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 54, i32 %6
  %338 = load float, float addrspace(3)* %337, align 4, !tbaa !4
  %339 = sext i32 %336 to i64
  %340 = add nsw i64 %18, %339
  %341 = getelementptr inbounds float, float addrspace(1)* %7, i64 %340
  store float %338, float addrspace(1)* %341, align 4, !tbaa !4
  %342 = add nsw i32 %336, %2
  %343 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 55, i32 %6
  %344 = load float, float addrspace(3)* %343, align 4, !tbaa !4
  %345 = sext i32 %342 to i64
  %346 = add nsw i64 %18, %345
  %347 = getelementptr inbounds float, float addrspace(1)* %7, i64 %346
  store float %344, float addrspace(1)* %347, align 4, !tbaa !4
  %348 = add nsw i32 %342, %2
  %349 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 56, i32 %6
  %350 = load float, float addrspace(3)* %349, align 4, !tbaa !4
  %351 = sext i32 %348 to i64
  %352 = add nsw i64 %18, %351
  %353 = getelementptr inbounds float, float addrspace(1)* %7, i64 %352
  store float %350, float addrspace(1)* %353, align 4, !tbaa !4
  %354 = add nsw i32 %348, %2
  %355 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 57, i32 %6
  %356 = load float, float addrspace(3)* %355, align 4, !tbaa !4
  %357 = sext i32 %354 to i64
  %358 = add nsw i64 %18, %357
  %359 = getelementptr inbounds float, float addrspace(1)* %7, i64 %358
  store float %356, float addrspace(1)* %359, align 4, !tbaa !4
  %360 = add nsw i32 %354, %2
  %361 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 58, i32 %6
  %362 = load float, float addrspace(3)* %361, align 4, !tbaa !4
  %363 = sext i32 %360 to i64
  %364 = add nsw i64 %18, %363
  %365 = getelementptr inbounds float, float addrspace(1)* %7, i64 %364
  store float %362, float addrspace(1)* %365, align 4, !tbaa !4
  %366 = add nsw i32 %360, %2
  %367 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 59, i32 %6
  %368 = load float, float addrspace(3)* %367, align 4, !tbaa !4
  %369 = sext i32 %366 to i64
  %370 = add nsw i64 %18, %369
  %371 = getelementptr inbounds float, float addrspace(1)* %7, i64 %370
  store float %368, float addrspace(1)* %371, align 4, !tbaa !4
  %372 = add nsw i32 %366, %2
  %373 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 60, i32 %6
  %374 = load float, float addrspace(3)* %373, align 4, !tbaa !4
  %375 = sext i32 %372 to i64
  %376 = add nsw i64 %18, %375
  %377 = getelementptr inbounds float, float addrspace(1)* %7, i64 %376
  store float %374, float addrspace(1)* %377, align 4, !tbaa !4
  %378 = add nsw i32 %372, %2
  %379 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 61, i32 %6
  %380 = load float, float addrspace(3)* %379, align 4, !tbaa !4
  %381 = sext i32 %378 to i64
  %382 = add nsw i64 %18, %381
  %383 = getelementptr inbounds float, float addrspace(1)* %7, i64 %382
  store float %380, float addrspace(1)* %383, align 4, !tbaa !4
  %384 = add nsw i32 %378, %2
  %385 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 62, i32 %6
  %386 = load float, float addrspace(3)* %385, align 4, !tbaa !4
  %387 = sext i32 %384 to i64
  %388 = add nsw i64 %18, %387
  %389 = getelementptr inbounds float, float addrspace(1)* %7, i64 %388
  store float %386, float addrspace(1)* %389, align 4, !tbaa !4
  %390 = add nsw i32 %384, %2
  %391 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %5, i32 0, i32 63, i32 %6
  %392 = sext i32 %390 to i64
  %393 = add nsw i64 %18, %392
  br label %782

394:                                              ; preds = %10
  %395 = add nsw i32 %6, -64
  %396 = shl i32 %3, 6
  %397 = add i32 %1, 64
  %398 = add i32 %397, %396
  %399 = mul i32 %398, %2
  %400 = add i32 %399, %1
  %401 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 0, i32 %395
  %402 = load float, float addrspace(3)* %401, align 4, !tbaa !4
  %403 = add nsw i32 %400, %395
  %404 = sext i32 %403 to i64
  %405 = getelementptr inbounds float, float addrspace(1)* %7, i64 %404
  store float %402, float addrspace(1)* %405, align 4, !tbaa !4
  %406 = add nsw i32 %400, %2
  %407 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 1, i32 %395
  %408 = load float, float addrspace(3)* %407, align 4, !tbaa !4
  %409 = add nsw i32 %406, %395
  %410 = sext i32 %409 to i64
  %411 = getelementptr inbounds float, float addrspace(1)* %7, i64 %410
  store float %408, float addrspace(1)* %411, align 4, !tbaa !4
  %412 = add nsw i32 %406, %2
  %413 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 2, i32 %395
  %414 = load float, float addrspace(3)* %413, align 4, !tbaa !4
  %415 = add nsw i32 %412, %395
  %416 = sext i32 %415 to i64
  %417 = getelementptr inbounds float, float addrspace(1)* %7, i64 %416
  store float %414, float addrspace(1)* %417, align 4, !tbaa !4
  %418 = add nsw i32 %412, %2
  %419 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 3, i32 %395
  %420 = load float, float addrspace(3)* %419, align 4, !tbaa !4
  %421 = add nsw i32 %418, %395
  %422 = sext i32 %421 to i64
  %423 = getelementptr inbounds float, float addrspace(1)* %7, i64 %422
  store float %420, float addrspace(1)* %423, align 4, !tbaa !4
  %424 = add nsw i32 %418, %2
  %425 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 4, i32 %395
  %426 = load float, float addrspace(3)* %425, align 4, !tbaa !4
  %427 = add nsw i32 %424, %395
  %428 = sext i32 %427 to i64
  %429 = getelementptr inbounds float, float addrspace(1)* %7, i64 %428
  store float %426, float addrspace(1)* %429, align 4, !tbaa !4
  %430 = add nsw i32 %424, %2
  %431 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 5, i32 %395
  %432 = load float, float addrspace(3)* %431, align 4, !tbaa !4
  %433 = add nsw i32 %430, %395
  %434 = sext i32 %433 to i64
  %435 = getelementptr inbounds float, float addrspace(1)* %7, i64 %434
  store float %432, float addrspace(1)* %435, align 4, !tbaa !4
  %436 = add nsw i32 %430, %2
  %437 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 6, i32 %395
  %438 = load float, float addrspace(3)* %437, align 4, !tbaa !4
  %439 = add nsw i32 %436, %395
  %440 = sext i32 %439 to i64
  %441 = getelementptr inbounds float, float addrspace(1)* %7, i64 %440
  store float %438, float addrspace(1)* %441, align 4, !tbaa !4
  %442 = add nsw i32 %436, %2
  %443 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 7, i32 %395
  %444 = load float, float addrspace(3)* %443, align 4, !tbaa !4
  %445 = add nsw i32 %442, %395
  %446 = sext i32 %445 to i64
  %447 = getelementptr inbounds float, float addrspace(1)* %7, i64 %446
  store float %444, float addrspace(1)* %447, align 4, !tbaa !4
  %448 = add nsw i32 %442, %2
  %449 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 8, i32 %395
  %450 = load float, float addrspace(3)* %449, align 4, !tbaa !4
  %451 = add nsw i32 %448, %395
  %452 = sext i32 %451 to i64
  %453 = getelementptr inbounds float, float addrspace(1)* %7, i64 %452
  store float %450, float addrspace(1)* %453, align 4, !tbaa !4
  %454 = add nsw i32 %448, %2
  %455 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 9, i32 %395
  %456 = load float, float addrspace(3)* %455, align 4, !tbaa !4
  %457 = add nsw i32 %454, %395
  %458 = sext i32 %457 to i64
  %459 = getelementptr inbounds float, float addrspace(1)* %7, i64 %458
  store float %456, float addrspace(1)* %459, align 4, !tbaa !4
  %460 = add nsw i32 %454, %2
  %461 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 10, i32 %395
  %462 = load float, float addrspace(3)* %461, align 4, !tbaa !4
  %463 = add nsw i32 %460, %395
  %464 = sext i32 %463 to i64
  %465 = getelementptr inbounds float, float addrspace(1)* %7, i64 %464
  store float %462, float addrspace(1)* %465, align 4, !tbaa !4
  %466 = add nsw i32 %460, %2
  %467 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 11, i32 %395
  %468 = load float, float addrspace(3)* %467, align 4, !tbaa !4
  %469 = add nsw i32 %466, %395
  %470 = sext i32 %469 to i64
  %471 = getelementptr inbounds float, float addrspace(1)* %7, i64 %470
  store float %468, float addrspace(1)* %471, align 4, !tbaa !4
  %472 = add nsw i32 %466, %2
  %473 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 12, i32 %395
  %474 = load float, float addrspace(3)* %473, align 4, !tbaa !4
  %475 = add nsw i32 %472, %395
  %476 = sext i32 %475 to i64
  %477 = getelementptr inbounds float, float addrspace(1)* %7, i64 %476
  store float %474, float addrspace(1)* %477, align 4, !tbaa !4
  %478 = add nsw i32 %472, %2
  %479 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 13, i32 %395
  %480 = load float, float addrspace(3)* %479, align 4, !tbaa !4
  %481 = add nsw i32 %478, %395
  %482 = sext i32 %481 to i64
  %483 = getelementptr inbounds float, float addrspace(1)* %7, i64 %482
  store float %480, float addrspace(1)* %483, align 4, !tbaa !4
  %484 = add nsw i32 %478, %2
  %485 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 14, i32 %395
  %486 = load float, float addrspace(3)* %485, align 4, !tbaa !4
  %487 = add nsw i32 %484, %395
  %488 = sext i32 %487 to i64
  %489 = getelementptr inbounds float, float addrspace(1)* %7, i64 %488
  store float %486, float addrspace(1)* %489, align 4, !tbaa !4
  %490 = add nsw i32 %484, %2
  %491 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 15, i32 %395
  %492 = load float, float addrspace(3)* %491, align 4, !tbaa !4
  %493 = add nsw i32 %490, %395
  %494 = sext i32 %493 to i64
  %495 = getelementptr inbounds float, float addrspace(1)* %7, i64 %494
  store float %492, float addrspace(1)* %495, align 4, !tbaa !4
  %496 = add nsw i32 %490, %2
  %497 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 16, i32 %395
  %498 = load float, float addrspace(3)* %497, align 4, !tbaa !4
  %499 = add nsw i32 %496, %395
  %500 = sext i32 %499 to i64
  %501 = getelementptr inbounds float, float addrspace(1)* %7, i64 %500
  store float %498, float addrspace(1)* %501, align 4, !tbaa !4
  %502 = add nsw i32 %496, %2
  %503 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 17, i32 %395
  %504 = load float, float addrspace(3)* %503, align 4, !tbaa !4
  %505 = add nsw i32 %502, %395
  %506 = sext i32 %505 to i64
  %507 = getelementptr inbounds float, float addrspace(1)* %7, i64 %506
  store float %504, float addrspace(1)* %507, align 4, !tbaa !4
  %508 = add nsw i32 %502, %2
  %509 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 18, i32 %395
  %510 = load float, float addrspace(3)* %509, align 4, !tbaa !4
  %511 = add nsw i32 %508, %395
  %512 = sext i32 %511 to i64
  %513 = getelementptr inbounds float, float addrspace(1)* %7, i64 %512
  store float %510, float addrspace(1)* %513, align 4, !tbaa !4
  %514 = add nsw i32 %508, %2
  %515 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 19, i32 %395
  %516 = load float, float addrspace(3)* %515, align 4, !tbaa !4
  %517 = add nsw i32 %514, %395
  %518 = sext i32 %517 to i64
  %519 = getelementptr inbounds float, float addrspace(1)* %7, i64 %518
  store float %516, float addrspace(1)* %519, align 4, !tbaa !4
  %520 = add nsw i32 %514, %2
  %521 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 20, i32 %395
  %522 = load float, float addrspace(3)* %521, align 4, !tbaa !4
  %523 = add nsw i32 %520, %395
  %524 = sext i32 %523 to i64
  %525 = getelementptr inbounds float, float addrspace(1)* %7, i64 %524
  store float %522, float addrspace(1)* %525, align 4, !tbaa !4
  %526 = add nsw i32 %520, %2
  %527 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 21, i32 %395
  %528 = load float, float addrspace(3)* %527, align 4, !tbaa !4
  %529 = add nsw i32 %526, %395
  %530 = sext i32 %529 to i64
  %531 = getelementptr inbounds float, float addrspace(1)* %7, i64 %530
  store float %528, float addrspace(1)* %531, align 4, !tbaa !4
  %532 = add nsw i32 %526, %2
  %533 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 22, i32 %395
  %534 = load float, float addrspace(3)* %533, align 4, !tbaa !4
  %535 = add nsw i32 %532, %395
  %536 = sext i32 %535 to i64
  %537 = getelementptr inbounds float, float addrspace(1)* %7, i64 %536
  store float %534, float addrspace(1)* %537, align 4, !tbaa !4
  %538 = add nsw i32 %532, %2
  %539 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 23, i32 %395
  %540 = load float, float addrspace(3)* %539, align 4, !tbaa !4
  %541 = add nsw i32 %538, %395
  %542 = sext i32 %541 to i64
  %543 = getelementptr inbounds float, float addrspace(1)* %7, i64 %542
  store float %540, float addrspace(1)* %543, align 4, !tbaa !4
  %544 = add nsw i32 %538, %2
  %545 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 24, i32 %395
  %546 = load float, float addrspace(3)* %545, align 4, !tbaa !4
  %547 = add nsw i32 %544, %395
  %548 = sext i32 %547 to i64
  %549 = getelementptr inbounds float, float addrspace(1)* %7, i64 %548
  store float %546, float addrspace(1)* %549, align 4, !tbaa !4
  %550 = add nsw i32 %544, %2
  %551 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 25, i32 %395
  %552 = load float, float addrspace(3)* %551, align 4, !tbaa !4
  %553 = add nsw i32 %550, %395
  %554 = sext i32 %553 to i64
  %555 = getelementptr inbounds float, float addrspace(1)* %7, i64 %554
  store float %552, float addrspace(1)* %555, align 4, !tbaa !4
  %556 = add nsw i32 %550, %2
  %557 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 26, i32 %395
  %558 = load float, float addrspace(3)* %557, align 4, !tbaa !4
  %559 = add nsw i32 %556, %395
  %560 = sext i32 %559 to i64
  %561 = getelementptr inbounds float, float addrspace(1)* %7, i64 %560
  store float %558, float addrspace(1)* %561, align 4, !tbaa !4
  %562 = add nsw i32 %556, %2
  %563 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 27, i32 %395
  %564 = load float, float addrspace(3)* %563, align 4, !tbaa !4
  %565 = add nsw i32 %562, %395
  %566 = sext i32 %565 to i64
  %567 = getelementptr inbounds float, float addrspace(1)* %7, i64 %566
  store float %564, float addrspace(1)* %567, align 4, !tbaa !4
  %568 = add nsw i32 %562, %2
  %569 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 28, i32 %395
  %570 = load float, float addrspace(3)* %569, align 4, !tbaa !4
  %571 = add nsw i32 %568, %395
  %572 = sext i32 %571 to i64
  %573 = getelementptr inbounds float, float addrspace(1)* %7, i64 %572
  store float %570, float addrspace(1)* %573, align 4, !tbaa !4
  %574 = add nsw i32 %568, %2
  %575 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 29, i32 %395
  %576 = load float, float addrspace(3)* %575, align 4, !tbaa !4
  %577 = add nsw i32 %574, %395
  %578 = sext i32 %577 to i64
  %579 = getelementptr inbounds float, float addrspace(1)* %7, i64 %578
  store float %576, float addrspace(1)* %579, align 4, !tbaa !4
  %580 = add nsw i32 %574, %2
  %581 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 30, i32 %395
  %582 = load float, float addrspace(3)* %581, align 4, !tbaa !4
  %583 = add nsw i32 %580, %395
  %584 = sext i32 %583 to i64
  %585 = getelementptr inbounds float, float addrspace(1)* %7, i64 %584
  store float %582, float addrspace(1)* %585, align 4, !tbaa !4
  %586 = add nsw i32 %580, %2
  %587 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 31, i32 %395
  %588 = load float, float addrspace(3)* %587, align 4, !tbaa !4
  %589 = add nsw i32 %586, %395
  %590 = sext i32 %589 to i64
  %591 = getelementptr inbounds float, float addrspace(1)* %7, i64 %590
  store float %588, float addrspace(1)* %591, align 4, !tbaa !4
  %592 = add nsw i32 %586, %2
  %593 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 32, i32 %395
  %594 = load float, float addrspace(3)* %593, align 4, !tbaa !4
  %595 = add nsw i32 %592, %395
  %596 = sext i32 %595 to i64
  %597 = getelementptr inbounds float, float addrspace(1)* %7, i64 %596
  store float %594, float addrspace(1)* %597, align 4, !tbaa !4
  %598 = add nsw i32 %592, %2
  %599 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 33, i32 %395
  %600 = load float, float addrspace(3)* %599, align 4, !tbaa !4
  %601 = add nsw i32 %598, %395
  %602 = sext i32 %601 to i64
  %603 = getelementptr inbounds float, float addrspace(1)* %7, i64 %602
  store float %600, float addrspace(1)* %603, align 4, !tbaa !4
  %604 = add nsw i32 %598, %2
  %605 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 34, i32 %395
  %606 = load float, float addrspace(3)* %605, align 4, !tbaa !4
  %607 = add nsw i32 %604, %395
  %608 = sext i32 %607 to i64
  %609 = getelementptr inbounds float, float addrspace(1)* %7, i64 %608
  store float %606, float addrspace(1)* %609, align 4, !tbaa !4
  %610 = add nsw i32 %604, %2
  %611 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 35, i32 %395
  %612 = load float, float addrspace(3)* %611, align 4, !tbaa !4
  %613 = add nsw i32 %610, %395
  %614 = sext i32 %613 to i64
  %615 = getelementptr inbounds float, float addrspace(1)* %7, i64 %614
  store float %612, float addrspace(1)* %615, align 4, !tbaa !4
  %616 = add nsw i32 %610, %2
  %617 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 36, i32 %395
  %618 = load float, float addrspace(3)* %617, align 4, !tbaa !4
  %619 = add nsw i32 %616, %395
  %620 = sext i32 %619 to i64
  %621 = getelementptr inbounds float, float addrspace(1)* %7, i64 %620
  store float %618, float addrspace(1)* %621, align 4, !tbaa !4
  %622 = add nsw i32 %616, %2
  %623 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 37, i32 %395
  %624 = load float, float addrspace(3)* %623, align 4, !tbaa !4
  %625 = add nsw i32 %622, %395
  %626 = sext i32 %625 to i64
  %627 = getelementptr inbounds float, float addrspace(1)* %7, i64 %626
  store float %624, float addrspace(1)* %627, align 4, !tbaa !4
  %628 = add nsw i32 %622, %2
  %629 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 38, i32 %395
  %630 = load float, float addrspace(3)* %629, align 4, !tbaa !4
  %631 = add nsw i32 %628, %395
  %632 = sext i32 %631 to i64
  %633 = getelementptr inbounds float, float addrspace(1)* %7, i64 %632
  store float %630, float addrspace(1)* %633, align 4, !tbaa !4
  %634 = add nsw i32 %628, %2
  %635 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 39, i32 %395
  %636 = load float, float addrspace(3)* %635, align 4, !tbaa !4
  %637 = add nsw i32 %634, %395
  %638 = sext i32 %637 to i64
  %639 = getelementptr inbounds float, float addrspace(1)* %7, i64 %638
  store float %636, float addrspace(1)* %639, align 4, !tbaa !4
  %640 = add nsw i32 %634, %2
  %641 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 40, i32 %395
  %642 = load float, float addrspace(3)* %641, align 4, !tbaa !4
  %643 = add nsw i32 %640, %395
  %644 = sext i32 %643 to i64
  %645 = getelementptr inbounds float, float addrspace(1)* %7, i64 %644
  store float %642, float addrspace(1)* %645, align 4, !tbaa !4
  %646 = add nsw i32 %640, %2
  %647 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 41, i32 %395
  %648 = load float, float addrspace(3)* %647, align 4, !tbaa !4
  %649 = add nsw i32 %646, %395
  %650 = sext i32 %649 to i64
  %651 = getelementptr inbounds float, float addrspace(1)* %7, i64 %650
  store float %648, float addrspace(1)* %651, align 4, !tbaa !4
  %652 = add nsw i32 %646, %2
  %653 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 42, i32 %395
  %654 = load float, float addrspace(3)* %653, align 4, !tbaa !4
  %655 = add nsw i32 %652, %395
  %656 = sext i32 %655 to i64
  %657 = getelementptr inbounds float, float addrspace(1)* %7, i64 %656
  store float %654, float addrspace(1)* %657, align 4, !tbaa !4
  %658 = add nsw i32 %652, %2
  %659 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 43, i32 %395
  %660 = load float, float addrspace(3)* %659, align 4, !tbaa !4
  %661 = add nsw i32 %658, %395
  %662 = sext i32 %661 to i64
  %663 = getelementptr inbounds float, float addrspace(1)* %7, i64 %662
  store float %660, float addrspace(1)* %663, align 4, !tbaa !4
  %664 = add nsw i32 %658, %2
  %665 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 44, i32 %395
  %666 = load float, float addrspace(3)* %665, align 4, !tbaa !4
  %667 = add nsw i32 %664, %395
  %668 = sext i32 %667 to i64
  %669 = getelementptr inbounds float, float addrspace(1)* %7, i64 %668
  store float %666, float addrspace(1)* %669, align 4, !tbaa !4
  %670 = add nsw i32 %664, %2
  %671 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 45, i32 %395
  %672 = load float, float addrspace(3)* %671, align 4, !tbaa !4
  %673 = add nsw i32 %670, %395
  %674 = sext i32 %673 to i64
  %675 = getelementptr inbounds float, float addrspace(1)* %7, i64 %674
  store float %672, float addrspace(1)* %675, align 4, !tbaa !4
  %676 = add nsw i32 %670, %2
  %677 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 46, i32 %395
  %678 = load float, float addrspace(3)* %677, align 4, !tbaa !4
  %679 = add nsw i32 %676, %395
  %680 = sext i32 %679 to i64
  %681 = getelementptr inbounds float, float addrspace(1)* %7, i64 %680
  store float %678, float addrspace(1)* %681, align 4, !tbaa !4
  %682 = add nsw i32 %676, %2
  %683 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 47, i32 %395
  %684 = load float, float addrspace(3)* %683, align 4, !tbaa !4
  %685 = add nsw i32 %682, %395
  %686 = sext i32 %685 to i64
  %687 = getelementptr inbounds float, float addrspace(1)* %7, i64 %686
  store float %684, float addrspace(1)* %687, align 4, !tbaa !4
  %688 = add nsw i32 %682, %2
  %689 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 48, i32 %395
  %690 = load float, float addrspace(3)* %689, align 4, !tbaa !4
  %691 = add nsw i32 %688, %395
  %692 = sext i32 %691 to i64
  %693 = getelementptr inbounds float, float addrspace(1)* %7, i64 %692
  store float %690, float addrspace(1)* %693, align 4, !tbaa !4
  %694 = add nsw i32 %688, %2
  %695 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 49, i32 %395
  %696 = load float, float addrspace(3)* %695, align 4, !tbaa !4
  %697 = add nsw i32 %694, %395
  %698 = sext i32 %697 to i64
  %699 = getelementptr inbounds float, float addrspace(1)* %7, i64 %698
  store float %696, float addrspace(1)* %699, align 4, !tbaa !4
  %700 = add nsw i32 %694, %2
  %701 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 50, i32 %395
  %702 = load float, float addrspace(3)* %701, align 4, !tbaa !4
  %703 = add nsw i32 %700, %395
  %704 = sext i32 %703 to i64
  %705 = getelementptr inbounds float, float addrspace(1)* %7, i64 %704
  store float %702, float addrspace(1)* %705, align 4, !tbaa !4
  %706 = add nsw i32 %700, %2
  %707 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 51, i32 %395
  %708 = load float, float addrspace(3)* %707, align 4, !tbaa !4
  %709 = add nsw i32 %706, %395
  %710 = sext i32 %709 to i64
  %711 = getelementptr inbounds float, float addrspace(1)* %7, i64 %710
  store float %708, float addrspace(1)* %711, align 4, !tbaa !4
  %712 = add nsw i32 %706, %2
  %713 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 52, i32 %395
  %714 = load float, float addrspace(3)* %713, align 4, !tbaa !4
  %715 = add nsw i32 %712, %395
  %716 = sext i32 %715 to i64
  %717 = getelementptr inbounds float, float addrspace(1)* %7, i64 %716
  store float %714, float addrspace(1)* %717, align 4, !tbaa !4
  %718 = add nsw i32 %712, %2
  %719 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 53, i32 %395
  %720 = load float, float addrspace(3)* %719, align 4, !tbaa !4
  %721 = add nsw i32 %718, %395
  %722 = sext i32 %721 to i64
  %723 = getelementptr inbounds float, float addrspace(1)* %7, i64 %722
  store float %720, float addrspace(1)* %723, align 4, !tbaa !4
  %724 = add nsw i32 %718, %2
  %725 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 54, i32 %395
  %726 = load float, float addrspace(3)* %725, align 4, !tbaa !4
  %727 = add nsw i32 %724, %395
  %728 = sext i32 %727 to i64
  %729 = getelementptr inbounds float, float addrspace(1)* %7, i64 %728
  store float %726, float addrspace(1)* %729, align 4, !tbaa !4
  %730 = add nsw i32 %724, %2
  %731 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 55, i32 %395
  %732 = load float, float addrspace(3)* %731, align 4, !tbaa !4
  %733 = add nsw i32 %730, %395
  %734 = sext i32 %733 to i64
  %735 = getelementptr inbounds float, float addrspace(1)* %7, i64 %734
  store float %732, float addrspace(1)* %735, align 4, !tbaa !4
  %736 = add nsw i32 %730, %2
  %737 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 56, i32 %395
  %738 = load float, float addrspace(3)* %737, align 4, !tbaa !4
  %739 = add nsw i32 %736, %395
  %740 = sext i32 %739 to i64
  %741 = getelementptr inbounds float, float addrspace(1)* %7, i64 %740
  store float %738, float addrspace(1)* %741, align 4, !tbaa !4
  %742 = add nsw i32 %736, %2
  %743 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 57, i32 %395
  %744 = load float, float addrspace(3)* %743, align 4, !tbaa !4
  %745 = add nsw i32 %742, %395
  %746 = sext i32 %745 to i64
  %747 = getelementptr inbounds float, float addrspace(1)* %7, i64 %746
  store float %744, float addrspace(1)* %747, align 4, !tbaa !4
  %748 = add nsw i32 %742, %2
  %749 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 58, i32 %395
  %750 = load float, float addrspace(3)* %749, align 4, !tbaa !4
  %751 = add nsw i32 %748, %395
  %752 = sext i32 %751 to i64
  %753 = getelementptr inbounds float, float addrspace(1)* %7, i64 %752
  store float %750, float addrspace(1)* %753, align 4, !tbaa !4
  %754 = add nsw i32 %748, %2
  %755 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 59, i32 %395
  %756 = load float, float addrspace(3)* %755, align 4, !tbaa !4
  %757 = add nsw i32 %754, %395
  %758 = sext i32 %757 to i64
  %759 = getelementptr inbounds float, float addrspace(1)* %7, i64 %758
  store float %756, float addrspace(1)* %759, align 4, !tbaa !4
  %760 = add nsw i32 %754, %2
  %761 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 60, i32 %395
  %762 = load float, float addrspace(3)* %761, align 4, !tbaa !4
  %763 = add nsw i32 %760, %395
  %764 = sext i32 %763 to i64
  %765 = getelementptr inbounds float, float addrspace(1)* %7, i64 %764
  store float %762, float addrspace(1)* %765, align 4, !tbaa !4
  %766 = add nsw i32 %760, %2
  %767 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 61, i32 %395
  %768 = load float, float addrspace(3)* %767, align 4, !tbaa !4
  %769 = add nsw i32 %766, %395
  %770 = sext i32 %769 to i64
  %771 = getelementptr inbounds float, float addrspace(1)* %7, i64 %770
  store float %768, float addrspace(1)* %771, align 4, !tbaa !4
  %772 = add nsw i32 %766, %2
  %773 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 62, i32 %395
  %774 = load float, float addrspace(3)* %773, align 4, !tbaa !4
  %775 = add nsw i32 %772, %395
  %776 = sext i32 %775 to i64
  %777 = getelementptr inbounds float, float addrspace(1)* %7, i64 %776
  store float %774, float addrspace(1)* %777, align 4, !tbaa !4
  %778 = add nsw i32 %772, %2
  %779 = getelementptr inbounds [64 x [64 x float]], [64 x [64 x float]] addrspace(3)* %8, i32 0, i32 63, i32 %395
  %780 = add nsw i32 %778, %395
  %781 = sext i32 %780 to i64
  br label %782

782:                                              ; preds = %394, %11
  %783 = phi i64 [ %393, %11 ], [ %781, %394 ]
  %784 = phi float addrspace(3)* [ %391, %11 ], [ %779, %394 ]
  %785 = getelementptr inbounds { i64, float addrspace(3)* }, { i64, float addrspace(3)* }* %9, i32 0, i32 0
  store i64 %783, i64* %785, align 8
  %786 = getelementptr inbounds { i64, float addrspace(3)* }, { i64, float addrspace(3)* }* %9, i32 0, i32 1
  store float addrspace(3)* %784, float addrspace(3)** %786, align 4
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
