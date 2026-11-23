; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i32 %1, i32 %2, i32 %3, float addrspace(1)* %4, [32 x [32 x float]] addrspace(3)* %5, i32 %6, i64 %7, [32 x [32 x float]] addrspace(3)* %8, [32 x [32 x float]] addrspace(3)* %9, { float addrspace(3)*, i64 }* %10) #0 {
  br i1 %0, label %12, label %288

12:                                               ; preds = %11
  %13 = mul nsw i32 %1, %2
  %14 = add nsw i32 %13, %1
  %15 = add nsw i32 %14, %3
  %16 = sext i32 %15 to i64
  %17 = getelementptr inbounds float, float addrspace(1)* %4, i64 %16
  %18 = load float, float addrspace(1)* %17, align 4, !tbaa !4
  %19 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 0, i32 %3
  store float %18, float addrspace(3)* %19, align 4, !tbaa !4
  %20 = add nsw i32 %14, %2
  %21 = add nsw i32 %20, %3
  %22 = sext i32 %21 to i64
  %23 = getelementptr inbounds float, float addrspace(1)* %4, i64 %22
  %24 = load float, float addrspace(1)* %23, align 4, !tbaa !4
  %25 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 1, i32 %3
  store float %24, float addrspace(3)* %25, align 4, !tbaa !4
  %26 = add nsw i32 %20, %2
  %27 = add nsw i32 %26, %3
  %28 = sext i32 %27 to i64
  %29 = getelementptr inbounds float, float addrspace(1)* %4, i64 %28
  %30 = load float, float addrspace(1)* %29, align 4, !tbaa !4
  %31 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 2, i32 %3
  store float %30, float addrspace(3)* %31, align 4, !tbaa !4
  %32 = add nsw i32 %26, %2
  %33 = add nsw i32 %32, %3
  %34 = sext i32 %33 to i64
  %35 = getelementptr inbounds float, float addrspace(1)* %4, i64 %34
  %36 = load float, float addrspace(1)* %35, align 4, !tbaa !4
  %37 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 3, i32 %3
  store float %36, float addrspace(3)* %37, align 4, !tbaa !4
  %38 = add nsw i32 %32, %2
  %39 = add nsw i32 %38, %3
  %40 = sext i32 %39 to i64
  %41 = getelementptr inbounds float, float addrspace(1)* %4, i64 %40
  %42 = load float, float addrspace(1)* %41, align 4, !tbaa !4
  %43 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 4, i32 %3
  store float %42, float addrspace(3)* %43, align 4, !tbaa !4
  %44 = add nsw i32 %38, %2
  %45 = add nsw i32 %44, %3
  %46 = sext i32 %45 to i64
  %47 = getelementptr inbounds float, float addrspace(1)* %4, i64 %46
  %48 = load float, float addrspace(1)* %47, align 4, !tbaa !4
  %49 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 5, i32 %3
  store float %48, float addrspace(3)* %49, align 4, !tbaa !4
  %50 = add nsw i32 %44, %2
  %51 = add nsw i32 %50, %3
  %52 = sext i32 %51 to i64
  %53 = getelementptr inbounds float, float addrspace(1)* %4, i64 %52
  %54 = load float, float addrspace(1)* %53, align 4, !tbaa !4
  %55 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 6, i32 %3
  store float %54, float addrspace(3)* %55, align 4, !tbaa !4
  %56 = add nsw i32 %50, %2
  %57 = add nsw i32 %56, %3
  %58 = sext i32 %57 to i64
  %59 = getelementptr inbounds float, float addrspace(1)* %4, i64 %58
  %60 = load float, float addrspace(1)* %59, align 4, !tbaa !4
  %61 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 7, i32 %3
  store float %60, float addrspace(3)* %61, align 4, !tbaa !4
  %62 = add nsw i32 %56, %2
  %63 = add nsw i32 %62, %3
  %64 = sext i32 %63 to i64
  %65 = getelementptr inbounds float, float addrspace(1)* %4, i64 %64
  %66 = load float, float addrspace(1)* %65, align 4, !tbaa !4
  %67 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 8, i32 %3
  store float %66, float addrspace(3)* %67, align 4, !tbaa !4
  %68 = add nsw i32 %62, %2
  %69 = add nsw i32 %68, %3
  %70 = sext i32 %69 to i64
  %71 = getelementptr inbounds float, float addrspace(1)* %4, i64 %70
  %72 = load float, float addrspace(1)* %71, align 4, !tbaa !4
  %73 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 9, i32 %3
  store float %72, float addrspace(3)* %73, align 4, !tbaa !4
  %74 = add nsw i32 %68, %2
  %75 = add nsw i32 %74, %3
  %76 = sext i32 %75 to i64
  %77 = getelementptr inbounds float, float addrspace(1)* %4, i64 %76
  %78 = load float, float addrspace(1)* %77, align 4, !tbaa !4
  %79 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 10, i32 %3
  store float %78, float addrspace(3)* %79, align 4, !tbaa !4
  %80 = add nsw i32 %74, %2
  %81 = add nsw i32 %80, %3
  %82 = sext i32 %81 to i64
  %83 = getelementptr inbounds float, float addrspace(1)* %4, i64 %82
  %84 = load float, float addrspace(1)* %83, align 4, !tbaa !4
  %85 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 11, i32 %3
  store float %84, float addrspace(3)* %85, align 4, !tbaa !4
  %86 = add nsw i32 %80, %2
  %87 = add nsw i32 %86, %3
  %88 = sext i32 %87 to i64
  %89 = getelementptr inbounds float, float addrspace(1)* %4, i64 %88
  %90 = load float, float addrspace(1)* %89, align 4, !tbaa !4
  %91 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 12, i32 %3
  store float %90, float addrspace(3)* %91, align 4, !tbaa !4
  %92 = add nsw i32 %86, %2
  %93 = add nsw i32 %92, %3
  %94 = sext i32 %93 to i64
  %95 = getelementptr inbounds float, float addrspace(1)* %4, i64 %94
  %96 = load float, float addrspace(1)* %95, align 4, !tbaa !4
  %97 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 13, i32 %3
  store float %96, float addrspace(3)* %97, align 4, !tbaa !4
  %98 = add nsw i32 %92, %2
  %99 = add nsw i32 %98, %3
  %100 = sext i32 %99 to i64
  %101 = getelementptr inbounds float, float addrspace(1)* %4, i64 %100
  %102 = load float, float addrspace(1)* %101, align 4, !tbaa !4
  %103 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 14, i32 %3
  store float %102, float addrspace(3)* %103, align 4, !tbaa !4
  %104 = add nsw i32 %98, %2
  %105 = add nsw i32 %104, %3
  %106 = sext i32 %105 to i64
  %107 = getelementptr inbounds float, float addrspace(1)* %4, i64 %106
  %108 = load float, float addrspace(1)* %107, align 4, !tbaa !4
  %109 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 15, i32 %3
  store float %108, float addrspace(3)* %109, align 4, !tbaa !4
  %110 = zext i32 %6 to i64
  %111 = shl nuw nsw i64 %110, 5
  %112 = add nuw nsw i64 %7, 32
  %113 = add nuw nsw i64 %112, %111
  %114 = sext i32 %14 to i64
  %115 = add nsw i64 %113, %114
  %116 = getelementptr inbounds float, float addrspace(1)* %4, i64 %115
  %117 = load float, float addrspace(1)* %116, align 4, !tbaa !4
  %118 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 0, i32 %3
  store float %117, float addrspace(3)* %118, align 4, !tbaa !4
  %119 = sext i32 %20 to i64
  %120 = add nsw i64 %113, %119
  %121 = getelementptr inbounds float, float addrspace(1)* %4, i64 %120
  %122 = load float, float addrspace(1)* %121, align 4, !tbaa !4
  %123 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 1, i32 %3
  store float %122, float addrspace(3)* %123, align 4, !tbaa !4
  %124 = sext i32 %26 to i64
  %125 = add nsw i64 %113, %124
  %126 = getelementptr inbounds float, float addrspace(1)* %4, i64 %125
  %127 = load float, float addrspace(1)* %126, align 4, !tbaa !4
  %128 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 2, i32 %3
  store float %127, float addrspace(3)* %128, align 4, !tbaa !4
  %129 = sext i32 %32 to i64
  %130 = add nsw i64 %113, %129
  %131 = getelementptr inbounds float, float addrspace(1)* %4, i64 %130
  %132 = load float, float addrspace(1)* %131, align 4, !tbaa !4
  %133 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 3, i32 %3
  store float %132, float addrspace(3)* %133, align 4, !tbaa !4
  %134 = sext i32 %38 to i64
  %135 = add nsw i64 %113, %134
  %136 = getelementptr inbounds float, float addrspace(1)* %4, i64 %135
  %137 = load float, float addrspace(1)* %136, align 4, !tbaa !4
  %138 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 4, i32 %3
  store float %137, float addrspace(3)* %138, align 4, !tbaa !4
  %139 = sext i32 %44 to i64
  %140 = add nsw i64 %113, %139
  %141 = getelementptr inbounds float, float addrspace(1)* %4, i64 %140
  %142 = load float, float addrspace(1)* %141, align 4, !tbaa !4
  %143 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 5, i32 %3
  store float %142, float addrspace(3)* %143, align 4, !tbaa !4
  %144 = sext i32 %50 to i64
  %145 = add nsw i64 %113, %144
  %146 = getelementptr inbounds float, float addrspace(1)* %4, i64 %145
  %147 = load float, float addrspace(1)* %146, align 4, !tbaa !4
  %148 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 6, i32 %3
  store float %147, float addrspace(3)* %148, align 4, !tbaa !4
  %149 = sext i32 %56 to i64
  %150 = add nsw i64 %113, %149
  %151 = getelementptr inbounds float, float addrspace(1)* %4, i64 %150
  %152 = load float, float addrspace(1)* %151, align 4, !tbaa !4
  %153 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 7, i32 %3
  store float %152, float addrspace(3)* %153, align 4, !tbaa !4
  %154 = sext i32 %62 to i64
  %155 = add nsw i64 %113, %154
  %156 = getelementptr inbounds float, float addrspace(1)* %4, i64 %155
  %157 = load float, float addrspace(1)* %156, align 4, !tbaa !4
  %158 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 8, i32 %3
  store float %157, float addrspace(3)* %158, align 4, !tbaa !4
  %159 = sext i32 %68 to i64
  %160 = add nsw i64 %113, %159
  %161 = getelementptr inbounds float, float addrspace(1)* %4, i64 %160
  %162 = load float, float addrspace(1)* %161, align 4, !tbaa !4
  %163 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 9, i32 %3
  store float %162, float addrspace(3)* %163, align 4, !tbaa !4
  %164 = sext i32 %74 to i64
  %165 = add nsw i64 %113, %164
  %166 = getelementptr inbounds float, float addrspace(1)* %4, i64 %165
  %167 = load float, float addrspace(1)* %166, align 4, !tbaa !4
  %168 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 10, i32 %3
  store float %167, float addrspace(3)* %168, align 4, !tbaa !4
  %169 = sext i32 %80 to i64
  %170 = add nsw i64 %113, %169
  %171 = getelementptr inbounds float, float addrspace(1)* %4, i64 %170
  %172 = load float, float addrspace(1)* %171, align 4, !tbaa !4
  %173 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 11, i32 %3
  store float %172, float addrspace(3)* %173, align 4, !tbaa !4
  %174 = sext i32 %86 to i64
  %175 = add nsw i64 %113, %174
  %176 = getelementptr inbounds float, float addrspace(1)* %4, i64 %175
  %177 = load float, float addrspace(1)* %176, align 4, !tbaa !4
  %178 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 12, i32 %3
  store float %177, float addrspace(3)* %178, align 4, !tbaa !4
  %179 = sext i32 %92 to i64
  %180 = add nsw i64 %113, %179
  %181 = getelementptr inbounds float, float addrspace(1)* %4, i64 %180
  %182 = load float, float addrspace(1)* %181, align 4, !tbaa !4
  %183 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 13, i32 %3
  store float %182, float addrspace(3)* %183, align 4, !tbaa !4
  %184 = sext i32 %98 to i64
  %185 = add nsw i64 %113, %184
  %186 = getelementptr inbounds float, float addrspace(1)* %4, i64 %185
  %187 = load float, float addrspace(1)* %186, align 4, !tbaa !4
  %188 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 14, i32 %3
  store float %187, float addrspace(3)* %188, align 4, !tbaa !4
  %189 = sext i32 %104 to i64
  %190 = add nsw i64 %113, %189
  %191 = getelementptr inbounds float, float addrspace(1)* %4, i64 %190
  %192 = load float, float addrspace(1)* %191, align 4, !tbaa !4
  %193 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 15, i32 %3
  store float %192, float addrspace(3)* %193, align 4, !tbaa !4
  %194 = add nsw i32 %104, %2
  %195 = sext i32 %194 to i64
  %196 = add nsw i64 %113, %195
  %197 = getelementptr inbounds float, float addrspace(1)* %4, i64 %196
  %198 = load float, float addrspace(1)* %197, align 4, !tbaa !4
  %199 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 16, i32 %3
  store float %198, float addrspace(3)* %199, align 4, !tbaa !4
  %200 = add nsw i32 %194, %2
  %201 = sext i32 %200 to i64
  %202 = add nsw i64 %113, %201
  %203 = getelementptr inbounds float, float addrspace(1)* %4, i64 %202
  %204 = load float, float addrspace(1)* %203, align 4, !tbaa !4
  %205 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 17, i32 %3
  store float %204, float addrspace(3)* %205, align 4, !tbaa !4
  %206 = add nsw i32 %200, %2
  %207 = sext i32 %206 to i64
  %208 = add nsw i64 %113, %207
  %209 = getelementptr inbounds float, float addrspace(1)* %4, i64 %208
  %210 = load float, float addrspace(1)* %209, align 4, !tbaa !4
  %211 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 18, i32 %3
  store float %210, float addrspace(3)* %211, align 4, !tbaa !4
  %212 = add nsw i32 %206, %2
  %213 = sext i32 %212 to i64
  %214 = add nsw i64 %113, %213
  %215 = getelementptr inbounds float, float addrspace(1)* %4, i64 %214
  %216 = load float, float addrspace(1)* %215, align 4, !tbaa !4
  %217 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 19, i32 %3
  store float %216, float addrspace(3)* %217, align 4, !tbaa !4
  %218 = add nsw i32 %212, %2
  %219 = sext i32 %218 to i64
  %220 = add nsw i64 %113, %219
  %221 = getelementptr inbounds float, float addrspace(1)* %4, i64 %220
  %222 = load float, float addrspace(1)* %221, align 4, !tbaa !4
  %223 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 20, i32 %3
  store float %222, float addrspace(3)* %223, align 4, !tbaa !4
  %224 = add nsw i32 %218, %2
  %225 = sext i32 %224 to i64
  %226 = add nsw i64 %113, %225
  %227 = getelementptr inbounds float, float addrspace(1)* %4, i64 %226
  %228 = load float, float addrspace(1)* %227, align 4, !tbaa !4
  %229 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 21, i32 %3
  store float %228, float addrspace(3)* %229, align 4, !tbaa !4
  %230 = add nsw i32 %224, %2
  %231 = sext i32 %230 to i64
  %232 = add nsw i64 %113, %231
  %233 = getelementptr inbounds float, float addrspace(1)* %4, i64 %232
  %234 = load float, float addrspace(1)* %233, align 4, !tbaa !4
  %235 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 22, i32 %3
  store float %234, float addrspace(3)* %235, align 4, !tbaa !4
  %236 = add nsw i32 %230, %2
  %237 = sext i32 %236 to i64
  %238 = add nsw i64 %113, %237
  %239 = getelementptr inbounds float, float addrspace(1)* %4, i64 %238
  %240 = load float, float addrspace(1)* %239, align 4, !tbaa !4
  %241 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 23, i32 %3
  store float %240, float addrspace(3)* %241, align 4, !tbaa !4
  %242 = add nsw i32 %236, %2
  %243 = sext i32 %242 to i64
  %244 = add nsw i64 %113, %243
  %245 = getelementptr inbounds float, float addrspace(1)* %4, i64 %244
  %246 = load float, float addrspace(1)* %245, align 4, !tbaa !4
  %247 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 24, i32 %3
  store float %246, float addrspace(3)* %247, align 4, !tbaa !4
  %248 = add nsw i32 %242, %2
  %249 = sext i32 %248 to i64
  %250 = add nsw i64 %113, %249
  %251 = getelementptr inbounds float, float addrspace(1)* %4, i64 %250
  %252 = load float, float addrspace(1)* %251, align 4, !tbaa !4
  %253 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 25, i32 %3
  store float %252, float addrspace(3)* %253, align 4, !tbaa !4
  %254 = add nsw i32 %248, %2
  %255 = sext i32 %254 to i64
  %256 = add nsw i64 %113, %255
  %257 = getelementptr inbounds float, float addrspace(1)* %4, i64 %256
  %258 = load float, float addrspace(1)* %257, align 4, !tbaa !4
  %259 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 26, i32 %3
  store float %258, float addrspace(3)* %259, align 4, !tbaa !4
  %260 = add nsw i32 %254, %2
  %261 = sext i32 %260 to i64
  %262 = add nsw i64 %113, %261
  %263 = getelementptr inbounds float, float addrspace(1)* %4, i64 %262
  %264 = load float, float addrspace(1)* %263, align 4, !tbaa !4
  %265 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 27, i32 %3
  store float %264, float addrspace(3)* %265, align 4, !tbaa !4
  %266 = add nsw i32 %260, %2
  %267 = sext i32 %266 to i64
  %268 = add nsw i64 %113, %267
  %269 = getelementptr inbounds float, float addrspace(1)* %4, i64 %268
  %270 = load float, float addrspace(1)* %269, align 4, !tbaa !4
  %271 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 28, i32 %3
  store float %270, float addrspace(3)* %271, align 4, !tbaa !4
  %272 = add nsw i32 %266, %2
  %273 = sext i32 %272 to i64
  %274 = add nsw i64 %113, %273
  %275 = getelementptr inbounds float, float addrspace(1)* %4, i64 %274
  %276 = load float, float addrspace(1)* %275, align 4, !tbaa !4
  %277 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 29, i32 %3
  store float %276, float addrspace(3)* %277, align 4, !tbaa !4
  %278 = add nsw i32 %272, %2
  %279 = sext i32 %278 to i64
  %280 = add nsw i64 %113, %279
  %281 = getelementptr inbounds float, float addrspace(1)* %4, i64 %280
  %282 = load float, float addrspace(1)* %281, align 4, !tbaa !4
  %283 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 30, i32 %3
  store float %282, float addrspace(3)* %283, align 4, !tbaa !4
  %284 = add nsw i32 %278, %2
  %285 = sext i32 %284 to i64
  %286 = add nsw i64 %113, %285
  %287 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %8, i32 0, i32 31, i32 %3
  br label %582

288:                                              ; preds = %11
  %289 = add nsw i32 %3, -32
  %290 = add nsw i32 %1, 16
  %291 = mul nsw i32 %290, %2
  %292 = add nsw i32 %291, %1
  %293 = add nsw i32 %292, %289
  %294 = sext i32 %293 to i64
  %295 = getelementptr inbounds float, float addrspace(1)* %4, i64 %294
  %296 = load float, float addrspace(1)* %295, align 4, !tbaa !4
  %297 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 16, i32 %289
  store float %296, float addrspace(3)* %297, align 4, !tbaa !4
  %298 = add nsw i32 %292, %2
  %299 = add nsw i32 %298, %289
  %300 = sext i32 %299 to i64
  %301 = getelementptr inbounds float, float addrspace(1)* %4, i64 %300
  %302 = load float, float addrspace(1)* %301, align 4, !tbaa !4
  %303 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 17, i32 %289
  store float %302, float addrspace(3)* %303, align 4, !tbaa !4
  %304 = add nsw i32 %298, %2
  %305 = add nsw i32 %304, %289
  %306 = sext i32 %305 to i64
  %307 = getelementptr inbounds float, float addrspace(1)* %4, i64 %306
  %308 = load float, float addrspace(1)* %307, align 4, !tbaa !4
  %309 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 18, i32 %289
  store float %308, float addrspace(3)* %309, align 4, !tbaa !4
  %310 = add nsw i32 %304, %2
  %311 = add nsw i32 %310, %289
  %312 = sext i32 %311 to i64
  %313 = getelementptr inbounds float, float addrspace(1)* %4, i64 %312
  %314 = load float, float addrspace(1)* %313, align 4, !tbaa !4
  %315 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 19, i32 %289
  store float %314, float addrspace(3)* %315, align 4, !tbaa !4
  %316 = add nsw i32 %310, %2
  %317 = add nsw i32 %316, %289
  %318 = sext i32 %317 to i64
  %319 = getelementptr inbounds float, float addrspace(1)* %4, i64 %318
  %320 = load float, float addrspace(1)* %319, align 4, !tbaa !4
  %321 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 20, i32 %289
  store float %320, float addrspace(3)* %321, align 4, !tbaa !4
  %322 = add nsw i32 %316, %2
  %323 = add nsw i32 %322, %289
  %324 = sext i32 %323 to i64
  %325 = getelementptr inbounds float, float addrspace(1)* %4, i64 %324
  %326 = load float, float addrspace(1)* %325, align 4, !tbaa !4
  %327 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 21, i32 %289
  store float %326, float addrspace(3)* %327, align 4, !tbaa !4
  %328 = add nsw i32 %322, %2
  %329 = add nsw i32 %328, %289
  %330 = sext i32 %329 to i64
  %331 = getelementptr inbounds float, float addrspace(1)* %4, i64 %330
  %332 = load float, float addrspace(1)* %331, align 4, !tbaa !4
  %333 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 22, i32 %289
  store float %332, float addrspace(3)* %333, align 4, !tbaa !4
  %334 = add nsw i32 %328, %2
  %335 = add nsw i32 %334, %289
  %336 = sext i32 %335 to i64
  %337 = getelementptr inbounds float, float addrspace(1)* %4, i64 %336
  %338 = load float, float addrspace(1)* %337, align 4, !tbaa !4
  %339 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 23, i32 %289
  store float %338, float addrspace(3)* %339, align 4, !tbaa !4
  %340 = add nsw i32 %334, %2
  %341 = add nsw i32 %340, %289
  %342 = sext i32 %341 to i64
  %343 = getelementptr inbounds float, float addrspace(1)* %4, i64 %342
  %344 = load float, float addrspace(1)* %343, align 4, !tbaa !4
  %345 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 24, i32 %289
  store float %344, float addrspace(3)* %345, align 4, !tbaa !4
  %346 = add nsw i32 %340, %2
  %347 = add nsw i32 %346, %289
  %348 = sext i32 %347 to i64
  %349 = getelementptr inbounds float, float addrspace(1)* %4, i64 %348
  %350 = load float, float addrspace(1)* %349, align 4, !tbaa !4
  %351 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 25, i32 %289
  store float %350, float addrspace(3)* %351, align 4, !tbaa !4
  %352 = add nsw i32 %346, %2
  %353 = add nsw i32 %352, %289
  %354 = sext i32 %353 to i64
  %355 = getelementptr inbounds float, float addrspace(1)* %4, i64 %354
  %356 = load float, float addrspace(1)* %355, align 4, !tbaa !4
  %357 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 26, i32 %289
  store float %356, float addrspace(3)* %357, align 4, !tbaa !4
  %358 = add nsw i32 %352, %2
  %359 = add nsw i32 %358, %289
  %360 = sext i32 %359 to i64
  %361 = getelementptr inbounds float, float addrspace(1)* %4, i64 %360
  %362 = load float, float addrspace(1)* %361, align 4, !tbaa !4
  %363 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 27, i32 %289
  store float %362, float addrspace(3)* %363, align 4, !tbaa !4
  %364 = add nsw i32 %358, %2
  %365 = add nsw i32 %364, %289
  %366 = sext i32 %365 to i64
  %367 = getelementptr inbounds float, float addrspace(1)* %4, i64 %366
  %368 = load float, float addrspace(1)* %367, align 4, !tbaa !4
  %369 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 28, i32 %289
  store float %368, float addrspace(3)* %369, align 4, !tbaa !4
  %370 = add nsw i32 %364, %2
  %371 = add nsw i32 %370, %289
  %372 = sext i32 %371 to i64
  %373 = getelementptr inbounds float, float addrspace(1)* %4, i64 %372
  %374 = load float, float addrspace(1)* %373, align 4, !tbaa !4
  %375 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 29, i32 %289
  store float %374, float addrspace(3)* %375, align 4, !tbaa !4
  %376 = add nsw i32 %370, %2
  %377 = add nsw i32 %376, %289
  %378 = sext i32 %377 to i64
  %379 = getelementptr inbounds float, float addrspace(1)* %4, i64 %378
  %380 = load float, float addrspace(1)* %379, align 4, !tbaa !4
  %381 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 30, i32 %289
  store float %380, float addrspace(3)* %381, align 4, !tbaa !4
  %382 = add nsw i32 %376, %2
  %383 = add nsw i32 %382, %289
  %384 = sext i32 %383 to i64
  %385 = getelementptr inbounds float, float addrspace(1)* %4, i64 %384
  %386 = load float, float addrspace(1)* %385, align 4, !tbaa !4
  %387 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %5, i32 0, i32 31, i32 %289
  store float %386, float addrspace(3)* %387, align 4, !tbaa !4
  %388 = shl i32 %6, 5
  %389 = add i32 %1, 32
  %390 = add i32 %389, %388
  %391 = mul i32 %390, %2
  %392 = add i32 %391, %1
  %393 = add nsw i32 %392, %289
  %394 = sext i32 %393 to i64
  %395 = getelementptr inbounds float, float addrspace(1)* %4, i64 %394
  %396 = load float, float addrspace(1)* %395, align 4, !tbaa !4
  %397 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 0, i32 %289
  store float %396, float addrspace(3)* %397, align 4, !tbaa !4
  %398 = add nsw i32 %392, %2
  %399 = add nsw i32 %398, %289
  %400 = sext i32 %399 to i64
  %401 = getelementptr inbounds float, float addrspace(1)* %4, i64 %400
  %402 = load float, float addrspace(1)* %401, align 4, !tbaa !4
  %403 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 1, i32 %289
  store float %402, float addrspace(3)* %403, align 4, !tbaa !4
  %404 = add nsw i32 %398, %2
  %405 = add nsw i32 %404, %289
  %406 = sext i32 %405 to i64
  %407 = getelementptr inbounds float, float addrspace(1)* %4, i64 %406
  %408 = load float, float addrspace(1)* %407, align 4, !tbaa !4
  %409 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 2, i32 %289
  store float %408, float addrspace(3)* %409, align 4, !tbaa !4
  %410 = add nsw i32 %404, %2
  %411 = add nsw i32 %410, %289
  %412 = sext i32 %411 to i64
  %413 = getelementptr inbounds float, float addrspace(1)* %4, i64 %412
  %414 = load float, float addrspace(1)* %413, align 4, !tbaa !4
  %415 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 3, i32 %289
  store float %414, float addrspace(3)* %415, align 4, !tbaa !4
  %416 = add nsw i32 %410, %2
  %417 = add nsw i32 %416, %289
  %418 = sext i32 %417 to i64
  %419 = getelementptr inbounds float, float addrspace(1)* %4, i64 %418
  %420 = load float, float addrspace(1)* %419, align 4, !tbaa !4
  %421 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 4, i32 %289
  store float %420, float addrspace(3)* %421, align 4, !tbaa !4
  %422 = add nsw i32 %416, %2
  %423 = add nsw i32 %422, %289
  %424 = sext i32 %423 to i64
  %425 = getelementptr inbounds float, float addrspace(1)* %4, i64 %424
  %426 = load float, float addrspace(1)* %425, align 4, !tbaa !4
  %427 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 5, i32 %289
  store float %426, float addrspace(3)* %427, align 4, !tbaa !4
  %428 = add nsw i32 %422, %2
  %429 = add nsw i32 %428, %289
  %430 = sext i32 %429 to i64
  %431 = getelementptr inbounds float, float addrspace(1)* %4, i64 %430
  %432 = load float, float addrspace(1)* %431, align 4, !tbaa !4
  %433 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 6, i32 %289
  store float %432, float addrspace(3)* %433, align 4, !tbaa !4
  %434 = add nsw i32 %428, %2
  %435 = add nsw i32 %434, %289
  %436 = sext i32 %435 to i64
  %437 = getelementptr inbounds float, float addrspace(1)* %4, i64 %436
  %438 = load float, float addrspace(1)* %437, align 4, !tbaa !4
  %439 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 7, i32 %289
  store float %438, float addrspace(3)* %439, align 4, !tbaa !4
  %440 = add nsw i32 %434, %2
  %441 = add nsw i32 %440, %289
  %442 = sext i32 %441 to i64
  %443 = getelementptr inbounds float, float addrspace(1)* %4, i64 %442
  %444 = load float, float addrspace(1)* %443, align 4, !tbaa !4
  %445 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 8, i32 %289
  store float %444, float addrspace(3)* %445, align 4, !tbaa !4
  %446 = add nsw i32 %440, %2
  %447 = add nsw i32 %446, %289
  %448 = sext i32 %447 to i64
  %449 = getelementptr inbounds float, float addrspace(1)* %4, i64 %448
  %450 = load float, float addrspace(1)* %449, align 4, !tbaa !4
  %451 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 9, i32 %289
  store float %450, float addrspace(3)* %451, align 4, !tbaa !4
  %452 = add nsw i32 %446, %2
  %453 = add nsw i32 %452, %289
  %454 = sext i32 %453 to i64
  %455 = getelementptr inbounds float, float addrspace(1)* %4, i64 %454
  %456 = load float, float addrspace(1)* %455, align 4, !tbaa !4
  %457 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 10, i32 %289
  store float %456, float addrspace(3)* %457, align 4, !tbaa !4
  %458 = add nsw i32 %452, %2
  %459 = add nsw i32 %458, %289
  %460 = sext i32 %459 to i64
  %461 = getelementptr inbounds float, float addrspace(1)* %4, i64 %460
  %462 = load float, float addrspace(1)* %461, align 4, !tbaa !4
  %463 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 11, i32 %289
  store float %462, float addrspace(3)* %463, align 4, !tbaa !4
  %464 = add nsw i32 %458, %2
  %465 = add nsw i32 %464, %289
  %466 = sext i32 %465 to i64
  %467 = getelementptr inbounds float, float addrspace(1)* %4, i64 %466
  %468 = load float, float addrspace(1)* %467, align 4, !tbaa !4
  %469 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 12, i32 %289
  store float %468, float addrspace(3)* %469, align 4, !tbaa !4
  %470 = add nsw i32 %464, %2
  %471 = add nsw i32 %470, %289
  %472 = sext i32 %471 to i64
  %473 = getelementptr inbounds float, float addrspace(1)* %4, i64 %472
  %474 = load float, float addrspace(1)* %473, align 4, !tbaa !4
  %475 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 13, i32 %289
  store float %474, float addrspace(3)* %475, align 4, !tbaa !4
  %476 = add nsw i32 %470, %2
  %477 = add nsw i32 %476, %289
  %478 = sext i32 %477 to i64
  %479 = getelementptr inbounds float, float addrspace(1)* %4, i64 %478
  %480 = load float, float addrspace(1)* %479, align 4, !tbaa !4
  %481 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 14, i32 %289
  store float %480, float addrspace(3)* %481, align 4, !tbaa !4
  %482 = add nsw i32 %476, %2
  %483 = add nsw i32 %482, %289
  %484 = sext i32 %483 to i64
  %485 = getelementptr inbounds float, float addrspace(1)* %4, i64 %484
  %486 = load float, float addrspace(1)* %485, align 4, !tbaa !4
  %487 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 15, i32 %289
  store float %486, float addrspace(3)* %487, align 4, !tbaa !4
  %488 = add nsw i32 %482, %2
  %489 = add nsw i32 %488, %289
  %490 = sext i32 %489 to i64
  %491 = getelementptr inbounds float, float addrspace(1)* %4, i64 %490
  %492 = load float, float addrspace(1)* %491, align 4, !tbaa !4
  %493 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 16, i32 %289
  store float %492, float addrspace(3)* %493, align 4, !tbaa !4
  %494 = add nsw i32 %488, %2
  %495 = add nsw i32 %494, %289
  %496 = sext i32 %495 to i64
  %497 = getelementptr inbounds float, float addrspace(1)* %4, i64 %496
  %498 = load float, float addrspace(1)* %497, align 4, !tbaa !4
  %499 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 17, i32 %289
  store float %498, float addrspace(3)* %499, align 4, !tbaa !4
  %500 = add nsw i32 %494, %2
  %501 = add nsw i32 %500, %289
  %502 = sext i32 %501 to i64
  %503 = getelementptr inbounds float, float addrspace(1)* %4, i64 %502
  %504 = load float, float addrspace(1)* %503, align 4, !tbaa !4
  %505 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 18, i32 %289
  store float %504, float addrspace(3)* %505, align 4, !tbaa !4
  %506 = add nsw i32 %500, %2
  %507 = add nsw i32 %506, %289
  %508 = sext i32 %507 to i64
  %509 = getelementptr inbounds float, float addrspace(1)* %4, i64 %508
  %510 = load float, float addrspace(1)* %509, align 4, !tbaa !4
  %511 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 19, i32 %289
  store float %510, float addrspace(3)* %511, align 4, !tbaa !4
  %512 = add nsw i32 %506, %2
  %513 = add nsw i32 %512, %289
  %514 = sext i32 %513 to i64
  %515 = getelementptr inbounds float, float addrspace(1)* %4, i64 %514
  %516 = load float, float addrspace(1)* %515, align 4, !tbaa !4
  %517 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 20, i32 %289
  store float %516, float addrspace(3)* %517, align 4, !tbaa !4
  %518 = add nsw i32 %512, %2
  %519 = add nsw i32 %518, %289
  %520 = sext i32 %519 to i64
  %521 = getelementptr inbounds float, float addrspace(1)* %4, i64 %520
  %522 = load float, float addrspace(1)* %521, align 4, !tbaa !4
  %523 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 21, i32 %289
  store float %522, float addrspace(3)* %523, align 4, !tbaa !4
  %524 = add nsw i32 %518, %2
  %525 = add nsw i32 %524, %289
  %526 = sext i32 %525 to i64
  %527 = getelementptr inbounds float, float addrspace(1)* %4, i64 %526
  %528 = load float, float addrspace(1)* %527, align 4, !tbaa !4
  %529 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 22, i32 %289
  store float %528, float addrspace(3)* %529, align 4, !tbaa !4
  %530 = add nsw i32 %524, %2
  %531 = add nsw i32 %530, %289
  %532 = sext i32 %531 to i64
  %533 = getelementptr inbounds float, float addrspace(1)* %4, i64 %532
  %534 = load float, float addrspace(1)* %533, align 4, !tbaa !4
  %535 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 23, i32 %289
  store float %534, float addrspace(3)* %535, align 4, !tbaa !4
  %536 = add nsw i32 %530, %2
  %537 = add nsw i32 %536, %289
  %538 = sext i32 %537 to i64
  %539 = getelementptr inbounds float, float addrspace(1)* %4, i64 %538
  %540 = load float, float addrspace(1)* %539, align 4, !tbaa !4
  %541 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 24, i32 %289
  store float %540, float addrspace(3)* %541, align 4, !tbaa !4
  %542 = add nsw i32 %536, %2
  %543 = add nsw i32 %542, %289
  %544 = sext i32 %543 to i64
  %545 = getelementptr inbounds float, float addrspace(1)* %4, i64 %544
  %546 = load float, float addrspace(1)* %545, align 4, !tbaa !4
  %547 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 25, i32 %289
  store float %546, float addrspace(3)* %547, align 4, !tbaa !4
  %548 = add nsw i32 %542, %2
  %549 = add nsw i32 %548, %289
  %550 = sext i32 %549 to i64
  %551 = getelementptr inbounds float, float addrspace(1)* %4, i64 %550
  %552 = load float, float addrspace(1)* %551, align 4, !tbaa !4
  %553 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 26, i32 %289
  store float %552, float addrspace(3)* %553, align 4, !tbaa !4
  %554 = add nsw i32 %548, %2
  %555 = add nsw i32 %554, %289
  %556 = sext i32 %555 to i64
  %557 = getelementptr inbounds float, float addrspace(1)* %4, i64 %556
  %558 = load float, float addrspace(1)* %557, align 4, !tbaa !4
  %559 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 27, i32 %289
  store float %558, float addrspace(3)* %559, align 4, !tbaa !4
  %560 = add nsw i32 %554, %2
  %561 = add nsw i32 %560, %289
  %562 = sext i32 %561 to i64
  %563 = getelementptr inbounds float, float addrspace(1)* %4, i64 %562
  %564 = load float, float addrspace(1)* %563, align 4, !tbaa !4
  %565 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 28, i32 %289
  store float %564, float addrspace(3)* %565, align 4, !tbaa !4
  %566 = add nsw i32 %560, %2
  %567 = add nsw i32 %566, %289
  %568 = sext i32 %567 to i64
  %569 = getelementptr inbounds float, float addrspace(1)* %4, i64 %568
  %570 = load float, float addrspace(1)* %569, align 4, !tbaa !4
  %571 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 29, i32 %289
  store float %570, float addrspace(3)* %571, align 4, !tbaa !4
  %572 = add nsw i32 %566, %2
  %573 = add nsw i32 %572, %289
  %574 = sext i32 %573 to i64
  %575 = getelementptr inbounds float, float addrspace(1)* %4, i64 %574
  %576 = load float, float addrspace(1)* %575, align 4, !tbaa !4
  %577 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 30, i32 %289
  store float %576, float addrspace(3)* %577, align 4, !tbaa !4
  %578 = add nsw i32 %572, %2
  %579 = add nsw i32 %578, %289
  %580 = sext i32 %579 to i64
  %581 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %9, i32 0, i32 31, i32 %289
  br label %582

582:                                              ; preds = %288, %12
  %583 = phi float addrspace(3)* [ %287, %12 ], [ %581, %288 ]
  %584 = phi i64 [ %286, %12 ], [ %580, %288 ]
  %585 = getelementptr inbounds { float addrspace(3)*, i64 }, { float addrspace(3)*, i64 }* %10, i32 0, i32 0
  store float addrspace(3)* %583, float addrspace(3)** %585, align 4
  %586 = getelementptr inbounds { float addrspace(3)*, i64 }, { float addrspace(3)*, i64 }* %10, i32 0, i32 1
  store i64 %584, i64* %586, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0, !1}
!dataflow.builtin.operations = !{!2, !3}

!0 = !{i32 3, !"llvm.amdgcn.workitem.id.x"}
!1 = !{i32 6, !"llvm.amdgcn.workgroup.id.x"}
!2 = !{i32 0, i32 113, !"llvm.amdgcn.workgroup.id.x"}
!3 = !{i32 1, i32 115, !"llvm.amdgcn.workgroup.id.x"}
!4 = !{!5, !5, i64 0}
!5 = !{!"float", !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C++ TBAA"}
