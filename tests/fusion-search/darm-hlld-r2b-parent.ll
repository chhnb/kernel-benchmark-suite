; ModuleID = '/data/home/chh/simplify-v2/build/simplify-fingerprint/inputs/HLLD.ll'
source_filename = "cases/cholla-hlld/source/src/riemann_solvers/hlld_cuda.cu"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree norecurse nounwind willreturn
define protected amdgpu_kernel void @_ZN3mhd26Calculate_HLLD_Fluxes_CUDAEPKdS1_S1_Pdidii(double addrspace(1)* nocapture readonly %0, double addrspace(1)* nocapture readonly %1, double addrspace(1)* nocapture readonly %2, double addrspace(1)* %3, i32 %4, double %5, i32 %6, i32 %7) local_unnamed_addr #0 {
  %9 = tail call i32 @llvm.amdgcn.workitem.id.x() #3, !range !5
  %10 = tail call i32 @llvm.amdgcn.workgroup.id.x() #3
  %11 = tail call align 4 dereferenceable(64) i8 addrspace(4)* @llvm.amdgcn.dispatch.ptr() #3
  %12 = getelementptr i8, i8 addrspace(4)* %11, i64 4
  %13 = bitcast i8 addrspace(4)* %12 to i16 addrspace(4)*
  %14 = load i16, i16 addrspace(4)* %13, align 4, !range !6, !invariant.load !7
  %15 = zext i16 %14 to i32
  %16 = mul i32 %10, %15
  %17 = add i32 %16, %9
  %18 = icmp slt i32 %17, %4
  br i1 %18, label %19, label %merged.branch.split

19:                                               ; preds = %8
  switch i32 %6, label %unify.bb [
    i32 2, label %21
    i32 1, label %20
  ]

20:                                               ; preds = %19
  br label %unify.bb

21:                                               ; preds = %19
  br label %unify.bb

unify.bb:                                         ; preds = %21, %20, %19
  %22 = phi i32 [ 3, %19 ], [ %6, %20 ], [ %6, %21 ]
  %23 = phi i32 [ 2, %19 ], [ 3, %20 ], [ 1, %21 ]
  %24 = phi i32 [ 1, %19 ], [ 2, %20 ], [ 3, %21 ]
  %25 = sext i32 %17 to i64
  %26 = getelementptr inbounds double, double addrspace(1)* %2, i64 %25
  %27 = load double, double addrspace(1)* %26, align 8, !tbaa !8
  %28 = getelementptr inbounds double, double addrspace(1)* %0, i64 %25
  %29 = load double, double addrspace(1)* %28, align 8, !tbaa !8
  %30 = tail call double @llvm.maxnum.f64(double %29, double 0x3BC79CA10C924223) #3
  %31 = mul nsw i32 %24, %4
  %32 = add nsw i32 %31, %17
  %33 = sext i32 %32 to i64
  %34 = getelementptr inbounds double, double addrspace(1)* %0, i64 %33
  %35 = load double, double addrspace(1)* %34, align 8, !tbaa !8
  %36 = fdiv double %35, %30
  %37 = mul nsw i32 %23, %4
  %38 = add nsw i32 %37, %17
  %39 = sext i32 %38 to i64
  %40 = getelementptr inbounds double, double addrspace(1)* %0, i64 %39
  %41 = load double, double addrspace(1)* %40, align 8, !tbaa !8
  %42 = fdiv double %41, %30
  %43 = mul nsw i32 %22, %4
  %44 = add nsw i32 %43, %17
  %45 = sext i32 %44 to i64
  %46 = getelementptr inbounds double, double addrspace(1)* %0, i64 %45
  %47 = load double, double addrspace(1)* %46, align 8, !tbaa !8
  %48 = fdiv double %47, %30
  %49 = shl nsw i32 %4, 2
  %50 = add nsw i32 %17, %49
  %51 = sext i32 %50 to i64
  %52 = getelementptr inbounds double, double addrspace(1)* %0, i64 %51
  %53 = load double, double addrspace(1)* %52, align 8, !tbaa !8
  %54 = tail call double @llvm.maxnum.f64(double %53, double 0x3BC79CA10C924223) #3
  %55 = mul nsw i32 %4, 5
  %56 = add nsw i32 %17, %55
  %57 = sext i32 %56 to i64
  %58 = getelementptr inbounds double, double addrspace(1)* %0, i64 %57
  %59 = load double, double addrspace(1)* %58, align 8, !tbaa !8
  %60 = mul nsw i32 %4, 6
  %61 = add nsw i32 %17, %60
  %62 = sext i32 %61 to i64
  %63 = getelementptr inbounds double, double addrspace(1)* %0, i64 %62
  %64 = load double, double addrspace(1)* %63, align 8, !tbaa !8
  %65 = fmul double %30, 5.000000e-01
  %66 = fmul double %36, %36
  %67 = fmul double %42, %42
  %68 = fmul double %48, %48
  %69 = fadd double %67, %68
  %70 = fadd double %66, %69
  %71 = fmul double %65, %70
  %72 = fsub double %54, %71
  %73 = fmul double %27, %27
  %74 = fmul double %59, %59
  %75 = fmul double %64, %64
  %76 = fadd double %74, %75
  %77 = fadd double %73, %76
  %78 = fmul double %77, 5.000000e-01
  %79 = fsub double %72, %78
  %80 = fadd double %5, -1.000000e+00
  %81 = fmul double %80, %79
  %82 = tail call double @llvm.maxnum.f64(double %81, double 0x3BC79CA10C924223) #3
  %83 = fadd double %78, %82
  %84 = tail call double @llvm.maxnum.f64(double %83, double 0x3BC79CA10C924223) #3
  %85 = getelementptr inbounds double, double addrspace(1)* %1, i64 %25
  %86 = load double, double addrspace(1)* %85, align 8, !tbaa !8
  %87 = tail call double @llvm.maxnum.f64(double %86, double 0x3BC79CA10C924223) #3
  %88 = getelementptr inbounds double, double addrspace(1)* %1, i64 %33
  %89 = load double, double addrspace(1)* %88, align 8, !tbaa !8
  %90 = fdiv double %89, %87
  %91 = getelementptr inbounds double, double addrspace(1)* %1, i64 %39
  %92 = load double, double addrspace(1)* %91, align 8, !tbaa !8
  %93 = fdiv double %92, %87
  %94 = getelementptr inbounds double, double addrspace(1)* %1, i64 %45
  %95 = load double, double addrspace(1)* %94, align 8, !tbaa !8
  %96 = fdiv double %95, %87
  %97 = getelementptr inbounds double, double addrspace(1)* %1, i64 %51
  %98 = load double, double addrspace(1)* %97, align 8, !tbaa !8
  %99 = tail call double @llvm.maxnum.f64(double %98, double 0x3BC79CA10C924223) #3
  %100 = getelementptr inbounds double, double addrspace(1)* %1, i64 %57
  %101 = load double, double addrspace(1)* %100, align 8, !tbaa !8
  %102 = getelementptr inbounds double, double addrspace(1)* %1, i64 %62
  %103 = load double, double addrspace(1)* %102, align 8, !tbaa !8
  %104 = fmul double %87, 5.000000e-01
  %105 = fmul double %90, %90
  %106 = fmul double %93, %93
  %107 = fmul double %96, %96
  %108 = fadd double %106, %107
  %109 = fadd double %105, %108
  %110 = fmul double %104, %109
  %111 = fsub double %99, %110
  %112 = fmul double %101, %101
  %113 = fmul double %103, %103
  %114 = fadd double %112, %113
  %115 = fadd double %73, %114
  %116 = fmul double %115, 5.000000e-01
  %117 = fsub double %111, %116
  %118 = fmul double %80, %117
  %119 = tail call double @llvm.maxnum.f64(double %118, double 0x3BC79CA10C924223) #3
  %120 = fadd double %116, %119
  %121 = tail call double @llvm.maxnum.f64(double %120, double 0x3BC79CA10C924223) #3
  %122 = fmul double %82, %5
  %123 = fadd double %77, %122
  %124 = fmul double %123, %123
  %125 = fmul double %5, 4.000000e+00
  %126 = fmul double %125, %82
  %127 = fmul double %73, %126
  %128 = fsub double %124, %127
  %129 = fcmp olt double %128, 0x1000000000000000
  %130 = select i1 %129, double 0x4FF0000000000000, double 1.000000e+00
  %131 = fmul double %128, %130
  %132 = tail call double @llvm.amdgcn.rsq.f64(double %131) #3
  %133 = fmul double %131, %132
  %134 = fmul double %132, 5.000000e-01
  %135 = fneg double %134
  %136 = tail call double @llvm.fma.f64(double %135, double %133, double 5.000000e-01) #3
  %137 = tail call double @llvm.fma.f64(double %134, double %136, double %134) #3
  %138 = tail call double @llvm.fma.f64(double %133, double %136, double %133) #3
  %139 = fneg double %138
  %140 = tail call double @llvm.fma.f64(double %139, double %138, double %131) #3
  %141 = tail call double @llvm.fma.f64(double %140, double %137, double %138) #3
  %142 = fneg double %141
  %143 = tail call double @llvm.fma.f64(double %142, double %141, double %131) #3
  %144 = tail call double @llvm.fma.f64(double %143, double %137, double %141) #3
  %145 = select i1 %129, double 0x37F0000000000000, double 1.000000e+00
  %146 = fmul double %145, %144
  %147 = fcmp oeq double %131, 0.000000e+00
  %148 = fcmp oeq double %131, 0x7FF0000000000000
  %149 = or i1 %147, %148
  %150 = select i1 %149, double %131, double %146
  %151 = fadd double %123, %150
  %152 = fmul double %30, 2.000000e+00
  %153 = fdiv double %151, %152
  %154 = fcmp olt double %153, 0x1000000000000000
  %155 = select i1 %154, double 0x4FF0000000000000, double 1.000000e+00
  %156 = fmul double %153, %155
  %157 = tail call double @llvm.amdgcn.rsq.f64(double %156) #3
  %158 = fmul double %156, %157
  %159 = fmul double %157, 5.000000e-01
  %160 = fneg double %159
  %161 = tail call double @llvm.fma.f64(double %160, double %158, double 5.000000e-01) #3
  %162 = tail call double @llvm.fma.f64(double %159, double %161, double %159) #3
  %163 = tail call double @llvm.fma.f64(double %158, double %161, double %158) #3
  %164 = fneg double %163
  %165 = tail call double @llvm.fma.f64(double %164, double %163, double %156) #3
  %166 = tail call double @llvm.fma.f64(double %165, double %162, double %163) #3
  %167 = fneg double %166
  %168 = tail call double @llvm.fma.f64(double %167, double %166, double %156) #3
  %169 = tail call double @llvm.fma.f64(double %168, double %162, double %166) #3
  %170 = select i1 %154, double 0x37F0000000000000, double 1.000000e+00
  %171 = fmul double %170, %169
  %172 = fcmp oeq double %156, 0.000000e+00
  %173 = fcmp oeq double %156, 0x7FF0000000000000
  %174 = or i1 %172, %173
  %175 = select i1 %174, double %156, double %171
  %176 = fmul double %119, %5
  %177 = fadd double %115, %176
  %178 = fmul double %177, %177
  %179 = fmul double %125, %119
  %180 = fmul double %73, %179
  %181 = fsub double %178, %180
  %182 = fcmp olt double %181, 0x1000000000000000
  %183 = select i1 %182, double 0x4FF0000000000000, double 1.000000e+00
  %184 = fmul double %181, %183
  %185 = tail call double @llvm.amdgcn.rsq.f64(double %184) #3
  %186 = fmul double %184, %185
  %187 = fmul double %185, 5.000000e-01
  %188 = fneg double %187
  %189 = tail call double @llvm.fma.f64(double %188, double %186, double 5.000000e-01) #3
  %190 = tail call double @llvm.fma.f64(double %187, double %189, double %187) #3
  %191 = tail call double @llvm.fma.f64(double %186, double %189, double %186) #3
  %192 = fneg double %191
  %193 = tail call double @llvm.fma.f64(double %192, double %191, double %184) #3
  %194 = tail call double @llvm.fma.f64(double %193, double %190, double %191) #3
  %195 = fneg double %194
  %196 = tail call double @llvm.fma.f64(double %195, double %194, double %184) #3
  %197 = tail call double @llvm.fma.f64(double %196, double %190, double %194) #3
  %198 = select i1 %182, double 0x37F0000000000000, double 1.000000e+00
  %199 = fmul double %198, %197
  %200 = fcmp oeq double %184, 0.000000e+00
  %201 = fcmp oeq double %184, 0x7FF0000000000000
  %202 = or i1 %200, %201
  %203 = select i1 %202, double %184, double %199
  %204 = fadd double %177, %203
  %205 = fmul double %87, 2.000000e+00
  %206 = fdiv double %204, %205
  %207 = fcmp olt double %206, 0x1000000000000000
  %208 = select i1 %207, double 0x4FF0000000000000, double 1.000000e+00
  %209 = fmul double %206, %208
  %210 = tail call double @llvm.amdgcn.rsq.f64(double %209) #3
  %211 = fmul double %209, %210
  %212 = fmul double %210, 5.000000e-01
  %213 = fneg double %212
  %214 = tail call double @llvm.fma.f64(double %213, double %211, double 5.000000e-01) #3
  %215 = tail call double @llvm.fma.f64(double %212, double %214, double %212) #3
  %216 = tail call double @llvm.fma.f64(double %211, double %214, double %211) #3
  %217 = fneg double %216
  %218 = tail call double @llvm.fma.f64(double %217, double %216, double %209) #3
  %219 = tail call double @llvm.fma.f64(double %218, double %215, double %216) #3
  %220 = fneg double %219
  %221 = tail call double @llvm.fma.f64(double %220, double %219, double %209) #3
  %222 = tail call double @llvm.fma.f64(double %221, double %215, double %219) #3
  %223 = select i1 %207, double 0x37F0000000000000, double 1.000000e+00
  %224 = fmul double %223, %222
  %225 = fcmp oeq double %209, 0.000000e+00
  %226 = fcmp oeq double %209, 0x7FF0000000000000
  %227 = or i1 %225, %226
  %228 = select i1 %227, double %209, double %224
  %229 = tail call double @llvm.maxnum.f64(double %175, double %228) #3
  %230 = tail call double @llvm.minnum.f64(double %36, double %90) #3
  %231 = fsub double %230, %229
  %232 = tail call double @llvm.maxnum.f64(double %36, double %90) #3
  %233 = fadd double %232, %229
  %234 = fmul double %30, %36
  %235 = fmul double %36, %234
  %236 = fadd double %235, %84
  %237 = fsub double %236, %73
  %238 = fmul double %234, %42
  %239 = fmul double %27, %59
  %240 = fsub double %238, %239
  %241 = fmul double %234, %48
  %242 = fmul double %27, %64
  %243 = fsub double %241, %242
  %244 = fmul double %36, %59
  %245 = fmul double %27, %42
  %246 = fsub double %244, %245
  %247 = fmul double %36, %64
  %248 = fmul double %27, %48
  %249 = fsub double %247, %248
  %250 = fadd double %54, %84
  %251 = fmul double %36, %250
  %252 = fmul double %27, %36
  %253 = fmul double %42, %59
  %254 = fmul double %48, %64
  %255 = fadd double %253, %254
  %256 = fadd double %252, %255
  %257 = fmul double %27, %256
  %258 = fsub double %251, %257
  %259 = fcmp ogt double %231, 0.000000e+00
  %260 = fmul double %87, %90
  %261 = fmul double %90, %260
  %262 = fadd double %261, %121
  %263 = fsub double %262, %73
  %264 = fmul double %260, %93
  %265 = fmul double %27, %101
  %266 = fsub double %264, %265
  %267 = fmul double %260, %96
  %268 = fmul double %27, %103
  %269 = fsub double %267, %268
  %270 = fmul double %90, %101
  %271 = fmul double %27, %93
  %272 = fsub double %270, %271
  %273 = fmul double %90, %103
  %274 = fmul double %27, %96
  %275 = fsub double %273, %274
  %276 = fadd double %99, %121
  %277 = fmul double %90, %276
  %278 = fmul double %27, %90
  %279 = fmul double %93, %101
  %280 = fmul double %96, %103
  %281 = fadd double %279, %280
  %282 = fadd double %278, %281
  %283 = fmul double %27, %282
  %284 = fsub double %277, %283
  %285 = fcmp olt double %233, 0.000000e+00
  %286 = or i1 %259, %285
  br i1 %286, label %merged.bb, label %merged.bb73

merged.branch.split:                              ; preds = %8
  ret void

merged.bb:                                        ; preds = %unify.bb
  %287 = getelementptr inbounds double, double addrspace(1)* %3, i64 %25
  %merged.select = select i1 %259, double %234, double %260
  store double %merged.select, double addrspace(1)* %287, align 8, !tbaa !8
  %288 = getelementptr inbounds double, double addrspace(1)* %3, i64 %33
  %merged.select90 = select i1 %259, double %237, double %263
  store double %merged.select90, double addrspace(1)* %288, align 8, !tbaa !8
  %289 = getelementptr inbounds double, double addrspace(1)* %3, i64 %39
  %merged.select91 = select i1 %259, double %240, double %266
  store double %merged.select91, double addrspace(1)* %289, align 8, !tbaa !8
  %290 = getelementptr inbounds double, double addrspace(1)* %3, i64 %45
  %merged.select92 = select i1 %259, double %243, double %269
  store double %merged.select92, double addrspace(1)* %290, align 8, !tbaa !8
  %291 = getelementptr inbounds double, double addrspace(1)* %3, i64 %51
  %merged.select93 = select i1 %259, double %258, double %284
  store double %merged.select93, double addrspace(1)* %291, align 8, !tbaa !8
  %292 = getelementptr inbounds double, double addrspace(1)* %3, i64 %57
  %merged.select94 = select i1 %259, double %246, double %272
  store double %merged.select94, double addrspace(1)* %292, align 8, !tbaa !8
  %293 = getelementptr inbounds double, double addrspace(1)* %3, i64 %62
  %merged.select95 = select i1 %259, double %249, double %275
  store double %merged.select95, double addrspace(1)* %293, align 8, !tbaa !8
  br label %merged.bb74

merged.bb73:                                      ; preds = %unify.bb
  %294 = fsub double %233, %90
  %295 = fsub double %231, %36
  %296 = fmul double %87, %294
  %297 = fmul double %90, %296
  %298 = fmul double %30, %295
  %299 = fmul double %36, %298
  %300 = fsub double %297, %299
  %301 = fsub double %300, %121
  %302 = fadd double %84, %301
  %303 = fsub double %296, %298
  %304 = fdiv double %302, %303
  %305 = fmul double %87, %84
  %306 = fmul double %305, %294
  %307 = fmul double %30, %121
  %308 = fmul double %307, %295
  %309 = fsub double %306, %308
  %310 = fmul double %30, %87
  %311 = fmul double %310, %294
  %312 = fmul double %295, %311
  %313 = fsub double %90, %36
  %314 = fmul double %313, %312
  %315 = fadd double %309, %314
  %316 = fdiv double %315, %303
  %317 = fsub double %231, %304
  %318 = fdiv double %298, %317
  %319 = fmul double %298, %317
  %320 = fsub double %319, %73
  %321 = tail call double @llvm.fabs.f64(double %320) #3
  %322 = fmul double %316, 1.000000e-08
  %323 = fcmp olt double %321, %322
  br i1 %323, label %merged.bb75, label %merged.bb76

merged.bb74:                                      ; preds = %merged.bb89, %merged.bb88, %merged.bb87, %merged.bb82, %merged.bb78, %merged.bb
  ret void

merged.bb75:                                      ; preds = %merged.bb76, %merged.bb73
  %324 = phi double [ %255, %merged.bb73 ], [ %377, %merged.bb76 ]
  %325 = phi double [ %42, %merged.bb73 ], [ %366, %merged.bb76 ]
  %326 = phi double [ %48, %merged.bb73 ], [ %368, %merged.bb76 ]
  %327 = phi double [ %59, %merged.bb73 ], [ %373, %merged.bb76 ]
  %328 = phi double [ %64, %merged.bb73 ], [ %374, %merged.bb76 ]
  %329 = fmul double %54, %295
  %330 = fmul double %36, %84
  %331 = fsub double %329, %330
  %332 = fmul double %316, %304
  %333 = fadd double %331, %332
  %334 = fmul double %27, %304
  %335 = fadd double %334, %324
  %336 = fsub double %256, %335
  %337 = fmul double %27, %336
  %338 = fadd double %333, %337
  %339 = fdiv double %338, %317
  %340 = tail call double @llvm.fabs.f64(double %27) #3
  %341 = tail call double @llvm.maxnum.f64(double %318, double 0x3BC79CA10C924223) #3
  %342 = tail call double @llvm.amdgcn.rsq.f64(double %341) #3
  %343 = fmul double %341, %342
  %344 = fmul double %342, 5.000000e-01
  %345 = fneg double %344
  %346 = tail call double @llvm.fma.f64(double %345, double %343, double 5.000000e-01) #3
  %347 = tail call double @llvm.fma.f64(double %344, double %346, double %344) #3
  %348 = tail call double @llvm.fma.f64(double %343, double %346, double %343) #3
  %349 = fneg double %348
  %350 = tail call double @llvm.fma.f64(double %349, double %348, double %341) #3
  %351 = tail call double @llvm.fma.f64(double %350, double %347, double %348) #3
  %352 = fneg double %351
  %353 = tail call double @llvm.fma.f64(double %352, double %351, double %341) #3
  %354 = tail call double @llvm.fma.f64(double %353, double %347, double %351) #3
  %355 = fcmp oeq double %341, 0x7FF0000000000000
  %356 = select i1 %355, double %341, double %354
  %357 = fdiv double %340, %356
  %358 = fsub double %304, %357
  %359 = fcmp ule double %358, 0.000000e+00
  %360 = fcmp ugt double %231, 0.000000e+00
  %361 = or i1 %360, %359
  br i1 %361, label %merged.bb77, label %merged.bb78

merged.bb76:                                      ; preds = %merged.bb73
  %362 = fsub double %304, %36
  %363 = fmul double %27, %362
  %364 = fdiv double %363, %320
  %365 = fmul double %59, %364
  %366 = fsub double %42, %365
  %367 = fmul double %64, %364
  %368 = fsub double %48, %367
  %369 = fmul double %295, %295
  %370 = fmul double %30, %369
  %371 = fsub double %370, %73
  %372 = fdiv double %371, %320
  %373 = fmul double %59, %372
  %374 = fmul double %64, %372
  %375 = fmul double %366, %373
  %376 = fmul double %368, %374
  %377 = fadd double %375, %376
  br label %merged.bb75

merged.bb77:                                      ; preds = %merged.bb75
  %378 = fsub double %233, %304
  %379 = fdiv double %296, %378
  %380 = fmul double %296, %378
  %381 = fsub double %380, %73
  %382 = tail call double @llvm.fabs.f64(double %381) #3
  %383 = fcmp olt double %382, %322
  br i1 %383, label %merged.bb79, label %merged.bb80

merged.bb78:                                      ; preds = %merged.bb75
  %384 = fsub double %318, %30
  %385 = fmul double %231, %384
  %386 = fadd double %234, %385
  %387 = fmul double %304, %318
  %388 = fsub double %387, %234
  %389 = fmul double %231, %388
  %390 = fadd double %237, %389
  %391 = fmul double %318, %325
  %392 = fmul double %30, %42
  %393 = fsub double %391, %392
  %394 = fmul double %231, %393
  %395 = fadd double %240, %394
  %396 = fmul double %318, %326
  %397 = fmul double %30, %48
  %398 = fsub double %396, %397
  %399 = fmul double %231, %398
  %400 = fadd double %243, %399
  %401 = fsub double %339, %54
  %402 = fmul double %231, %401
  %403 = fadd double %258, %402
  %404 = fsub double %327, %59
  %405 = fmul double %231, %404
  %406 = fadd double %246, %405
  %407 = fsub double %328, %64
  %408 = fmul double %231, %407
  %409 = fadd double %249, %408
  %410 = getelementptr inbounds double, double addrspace(1)* %3, i64 %25
  store double %386, double addrspace(1)* %410, align 8, !tbaa !8
  %411 = getelementptr inbounds double, double addrspace(1)* %3, i64 %33
  store double %390, double addrspace(1)* %411, align 8, !tbaa !8
  %412 = getelementptr inbounds double, double addrspace(1)* %3, i64 %39
  store double %395, double addrspace(1)* %412, align 8, !tbaa !8
  %413 = getelementptr inbounds double, double addrspace(1)* %3, i64 %45
  store double %400, double addrspace(1)* %413, align 8, !tbaa !8
  %414 = getelementptr inbounds double, double addrspace(1)* %3, i64 %51
  store double %403, double addrspace(1)* %414, align 8, !tbaa !8
  %415 = getelementptr inbounds double, double addrspace(1)* %3, i64 %57
  store double %406, double addrspace(1)* %415, align 8, !tbaa !8
  %416 = getelementptr inbounds double, double addrspace(1)* %3, i64 %62
  store double %409, double addrspace(1)* %416, align 8, !tbaa !8
  br label %merged.bb74

merged.bb79:                                      ; preds = %merged.bb80, %merged.bb77
  %417 = phi double [ %281, %merged.bb77 ], [ %467, %merged.bb80 ]
  %418 = phi double [ %93, %merged.bb77 ], [ %456, %merged.bb80 ]
  %419 = phi double [ %96, %merged.bb77 ], [ %458, %merged.bb80 ]
  %420 = phi double [ %101, %merged.bb77 ], [ %463, %merged.bb80 ]
  %421 = phi double [ %103, %merged.bb77 ], [ %464, %merged.bb80 ]
  %422 = fmul double %99, %294
  %423 = fmul double %90, %121
  %424 = fsub double %422, %423
  %425 = fadd double %424, %332
  %426 = fadd double %334, %417
  %427 = fsub double %282, %426
  %428 = fmul double %27, %427
  %429 = fadd double %425, %428
  %430 = fdiv double %429, %378
  %431 = tail call double @llvm.maxnum.f64(double %379, double 0x3BC79CA10C924223) #3
  %432 = tail call double @llvm.amdgcn.rsq.f64(double %431) #3
  %433 = fmul double %431, %432
  %434 = fmul double %432, 5.000000e-01
  %435 = fneg double %434
  %436 = tail call double @llvm.fma.f64(double %435, double %433, double 5.000000e-01) #3
  %437 = tail call double @llvm.fma.f64(double %434, double %436, double %434) #3
  %438 = tail call double @llvm.fma.f64(double %433, double %436, double %433) #3
  %439 = fneg double %438
  %440 = tail call double @llvm.fma.f64(double %439, double %438, double %431) #3
  %441 = tail call double @llvm.fma.f64(double %440, double %437, double %438) #3
  %442 = fneg double %441
  %443 = tail call double @llvm.fma.f64(double %442, double %441, double %431) #3
  %444 = tail call double @llvm.fma.f64(double %443, double %437, double %441) #3
  %445 = fcmp oeq double %431, 0x7FF0000000000000
  %446 = select i1 %445, double %431, double %444
  %447 = fdiv double %340, %446
  %448 = fadd double %304, %447
  %449 = fcmp ugt double %448, 0.000000e+00
  %450 = fcmp ult double %233, 0.000000e+00
  %451 = or i1 %450, %449
  br i1 %451, label %merged.bb81, label %merged.bb82

merged.bb80:                                      ; preds = %merged.bb77
  %452 = fsub double %304, %90
  %453 = fmul double %27, %452
  %454 = fdiv double %453, %381
  %455 = fmul double %101, %454
  %456 = fsub double %93, %455
  %457 = fmul double %103, %454
  %458 = fsub double %96, %457
  %459 = fmul double %294, %294
  %460 = fmul double %87, %459
  %461 = fsub double %460, %73
  %462 = fdiv double %461, %381
  %463 = fmul double %101, %462
  %464 = fmul double %103, %462
  %465 = fmul double %456, %463
  %466 = fmul double %458, %464
  %467 = fadd double %465, %466
  br label %merged.bb79

merged.bb81:                                      ; preds = %merged.bb79
  %468 = fmul double %73, 5.000000e-01
  %469 = fcmp olt double %468, %322
  br i1 %469, label %merged.bb83, label %merged.bb84

merged.bb82:                                      ; preds = %merged.bb79
  %470 = fsub double %379, %87
  %471 = fmul double %233, %470
  %472 = fadd double %260, %471
  %473 = fmul double %304, %379
  %474 = fsub double %473, %260
  %475 = fmul double %233, %474
  %476 = fadd double %263, %475
  %477 = fmul double %379, %418
  %478 = fmul double %87, %93
  %479 = fsub double %477, %478
  %480 = fmul double %233, %479
  %481 = fadd double %266, %480
  %482 = fmul double %379, %419
  %483 = fmul double %87, %96
  %484 = fsub double %482, %483
  %485 = fmul double %233, %484
  %486 = fadd double %269, %485
  %487 = fsub double %430, %99
  %488 = fmul double %233, %487
  %489 = fadd double %284, %488
  %490 = fsub double %420, %101
  %491 = fmul double %233, %490
  %492 = fadd double %272, %491
  %493 = fsub double %421, %103
  %494 = fmul double %233, %493
  %495 = fadd double %275, %494
  %496 = getelementptr inbounds double, double addrspace(1)* %3, i64 %25
  store double %472, double addrspace(1)* %496, align 8, !tbaa !8
  %497 = getelementptr inbounds double, double addrspace(1)* %3, i64 %33
  store double %476, double addrspace(1)* %497, align 8, !tbaa !8
  %498 = getelementptr inbounds double, double addrspace(1)* %3, i64 %39
  store double %481, double addrspace(1)* %498, align 8, !tbaa !8
  %499 = getelementptr inbounds double, double addrspace(1)* %3, i64 %45
  store double %486, double addrspace(1)* %499, align 8, !tbaa !8
  %500 = getelementptr inbounds double, double addrspace(1)* %3, i64 %51
  store double %489, double addrspace(1)* %500, align 8, !tbaa !8
  %501 = getelementptr inbounds double, double addrspace(1)* %3, i64 %57
  store double %492, double addrspace(1)* %501, align 8, !tbaa !8
  %502 = getelementptr inbounds double, double addrspace(1)* %3, i64 %62
  store double %495, double addrspace(1)* %502, align 8, !tbaa !8
  br label %merged.bb74

merged.bb83:                                      ; preds = %merged.bb81
  %503 = fcmp ult double %304, 0.000000e+00
  br i1 %503, label %merged.bb85, label %merged.bb86

merged.bb84:                                      ; preds = %merged.bb81
  %504 = fcmp olt double %318, 0x1000000000000000
  %505 = select i1 %504, double 0x4FF0000000000000, double 1.000000e+00
  %506 = fmul double %318, %505
  %507 = tail call double @llvm.amdgcn.rsq.f64(double %506) #3
  %508 = fmul double %506, %507
  %509 = fmul double %507, 5.000000e-01
  %510 = fneg double %509
  %511 = tail call double @llvm.fma.f64(double %510, double %508, double 5.000000e-01) #3
  %512 = tail call double @llvm.fma.f64(double %509, double %511, double %509) #3
  %513 = tail call double @llvm.fma.f64(double %508, double %511, double %508) #3
  %514 = fneg double %513
  %515 = tail call double @llvm.fma.f64(double %514, double %513, double %506) #3
  %516 = tail call double @llvm.fma.f64(double %515, double %512, double %513) #3
  %517 = fneg double %516
  %518 = tail call double @llvm.fma.f64(double %517, double %516, double %506) #3
  %519 = tail call double @llvm.fma.f64(double %518, double %512, double %516) #3
  %520 = select i1 %504, double 0x37F0000000000000, double 1.000000e+00
  %521 = fmul double %520, %519
  %522 = fcmp oeq double %506, 0.000000e+00
  %523 = fcmp oeq double %506, 0x7FF0000000000000
  %524 = or i1 %522, %523
  %525 = select i1 %524, double %506, double %521
  %526 = fcmp olt double %379, 0x1000000000000000
  %527 = select i1 %526, double 0x4FF0000000000000, double 1.000000e+00
  %528 = fmul double %379, %527
  %529 = tail call double @llvm.amdgcn.rsq.f64(double %528) #3
  %530 = fmul double %528, %529
  %531 = fmul double %529, 5.000000e-01
  %532 = fneg double %531
  %533 = tail call double @llvm.fma.f64(double %532, double %530, double 5.000000e-01) #3
  %534 = tail call double @llvm.fma.f64(double %531, double %533, double %531) #3
  %535 = tail call double @llvm.fma.f64(double %530, double %533, double %530) #3
  %536 = fneg double %535
  %537 = tail call double @llvm.fma.f64(double %536, double %535, double %528) #3
  %538 = tail call double @llvm.fma.f64(double %537, double %534, double %535) #3
  %539 = fneg double %538
  %540 = tail call double @llvm.fma.f64(double %539, double %538, double %528) #3
  %541 = tail call double @llvm.fma.f64(double %540, double %534, double %538) #3
  %542 = select i1 %526, double 0x37F0000000000000, double 1.000000e+00
  %543 = fmul double %542, %541
  %544 = fcmp oeq double %528, 0.000000e+00
  %545 = fcmp oeq double %528, 0x7FF0000000000000
  %546 = or i1 %544, %545
  %547 = select i1 %546, double %528, double %543
  %548 = fadd double %525, %547
  %549 = fdiv double 1.000000e+00, %548
  %550 = tail call double @llvm.copysign.f64(double 1.000000e+00, double %27) #3
  %551 = fmul double %525, %325
  %552 = fmul double %547, %418
  %553 = fadd double %551, %552
  %554 = fsub double %420, %327
  %555 = fmul double %550, %554
  %556 = fadd double %553, %555
  %557 = fmul double %549, %556
  %558 = fmul double %525, %326
  %559 = fmul double %547, %419
  %560 = fadd double %558, %559
  %561 = fsub double %421, %328
  %562 = fmul double %550, %561
  %563 = fadd double %560, %562
  %564 = fmul double %549, %563
  %565 = fmul double %525, %420
  %566 = fmul double %547, %327
  %567 = fadd double %566, %565
  %568 = fmul double %525, %547
  %569 = fmul double %550, %568
  %570 = fsub double %418, %325
  %571 = fmul double %569, %570
  %572 = fadd double %571, %567
  %573 = fmul double %549, %572
  %574 = fmul double %525, %421
  %575 = fmul double %547, %328
  %576 = fadd double %575, %574
  %577 = fsub double %419, %326
  %578 = fmul double %569, %577
  %579 = fadd double %578, %576
  %580 = fmul double %549, %579
  %581 = fmul double %557, %573
  %582 = fmul double %564, %580
  %583 = fadd double %581, %582
  %584 = fadd double %334, %583
  %585 = fmul double %550, %525
  %586 = fsub double %335, %584
  %587 = fmul double %585, %586
  %588 = fsub double %339, %587
  %589 = fmul double %550, %547
  %590 = fsub double %426, %584
  %591 = fmul double %589, %590
  %592 = fadd double %430, %591
  br label %merged.bb86

merged.bb85:                                      ; preds = %merged.bb83
  br label %merged.bb86

merged.bb86:                                      ; preds = %merged.bb85, %merged.bb84, %merged.bb83
  %593 = phi double [ %325, %merged.bb83 ], [ %557, %merged.bb84 ], [ %418, %merged.bb85 ]
  %594 = phi double [ %326, %merged.bb83 ], [ %564, %merged.bb84 ], [ %419, %merged.bb85 ]
  %595 = phi double [ %327, %merged.bb83 ], [ %573, %merged.bb84 ], [ %420, %merged.bb85 ]
  %596 = phi double [ %328, %merged.bb83 ], [ %580, %merged.bb84 ], [ %421, %merged.bb85 ]
  %597 = phi double [ %339, %merged.bb83 ], [ %588, %merged.bb84 ], [ 0.000000e+00, %merged.bb85 ]
  %598 = phi double [ 0.000000e+00, %merged.bb83 ], [ %592, %merged.bb84 ], [ %430, %merged.bb85 ]
  %599 = fcmp ule double %304, 0.000000e+00
  %600 = fcmp ugt double %358, 0.000000e+00
  %601 = or i1 %599, %600
  br i1 %601, label %merged.bb87, label %merged.bb88

merged.bb87:                                      ; preds = %merged.bb86
  %602 = fcmp ule double %448, 0.000000e+00
  %603 = fcmp ugt double %304, 0.000000e+00
  %604 = or i1 %603, %602
  br i1 %604, label %merged.bb74, label %merged.bb89

merged.bb88:                                      ; preds = %merged.bb86
  %605 = fsub double %358, %231
  %606 = fmul double %30, %231
  %607 = fsub double %234, %606
  %608 = fmul double %318, %605
  %609 = fsub double %607, %608
  %610 = fmul double %318, %358
  %611 = fadd double %610, %609
  %612 = fmul double %234, %231
  %613 = fsub double %237, %612
  %614 = fmul double %304, %318
  %615 = fmul double %614, %605
  %616 = fsub double %613, %615
  %617 = fmul double %614, %358
  %618 = fadd double %617, %616
  %619 = fmul double %30, %42
  %620 = fmul double %619, %231
  %621 = fsub double %240, %620
  %622 = fmul double %318, %325
  %623 = fmul double %605, %622
  %624 = fsub double %621, %623
  %625 = fmul double %318, %593
  %626 = fmul double %358, %625
  %627 = fadd double %624, %626
  %628 = fmul double %30, %48
  %629 = fmul double %628, %231
  %630 = fsub double %243, %629
  %631 = fmul double %318, %326
  %632 = fmul double %605, %631
  %633 = fsub double %630, %632
  %634 = fmul double %318, %594
  %635 = fmul double %358, %634
  %636 = fadd double %633, %635
  %637 = fmul double %54, %231
  %638 = fsub double %258, %637
  %639 = fmul double %605, %339
  %640 = fsub double %638, %639
  %641 = fmul double %358, %597
  %642 = fadd double %640, %641
  %643 = fmul double %59, %231
  %644 = fsub double %246, %643
  %645 = fmul double %605, %327
  %646 = fsub double %644, %645
  %647 = fmul double %358, %595
  %648 = fadd double %646, %647
  %649 = fmul double %64, %231
  %650 = fsub double %249, %649
  %651 = fmul double %605, %328
  %652 = fsub double %650, %651
  %653 = fmul double %358, %596
  %654 = fadd double %652, %653
  %655 = getelementptr inbounds double, double addrspace(1)* %3, i64 %25
  store double %611, double addrspace(1)* %655, align 8, !tbaa !8
  %656 = getelementptr inbounds double, double addrspace(1)* %3, i64 %33
  store double %618, double addrspace(1)* %656, align 8, !tbaa !8
  %657 = getelementptr inbounds double, double addrspace(1)* %3, i64 %39
  store double %627, double addrspace(1)* %657, align 8, !tbaa !8
  %658 = getelementptr inbounds double, double addrspace(1)* %3, i64 %45
  store double %636, double addrspace(1)* %658, align 8, !tbaa !8
  %659 = getelementptr inbounds double, double addrspace(1)* %3, i64 %51
  store double %642, double addrspace(1)* %659, align 8, !tbaa !8
  %660 = getelementptr inbounds double, double addrspace(1)* %3, i64 %57
  store double %648, double addrspace(1)* %660, align 8, !tbaa !8
  %661 = getelementptr inbounds double, double addrspace(1)* %3, i64 %62
  store double %654, double addrspace(1)* %661, align 8, !tbaa !8
  br label %merged.bb74

merged.bb89:                                      ; preds = %merged.bb87
  %662 = fsub double %448, %233
  %663 = fmul double %87, %233
  %664 = fsub double %260, %663
  %665 = fmul double %379, %662
  %666 = fsub double %664, %665
  %667 = fmul double %379, %448
  %668 = fadd double %667, %666
  %669 = fmul double %260, %233
  %670 = fsub double %263, %669
  %671 = fmul double %304, %379
  %672 = fmul double %671, %662
  %673 = fsub double %670, %672
  %674 = fmul double %671, %448
  %675 = fadd double %674, %673
  %676 = fmul double %87, %93
  %677 = fmul double %676, %233
  %678 = fsub double %266, %677
  %679 = fmul double %379, %418
  %680 = fmul double %662, %679
  %681 = fsub double %678, %680
  %682 = fmul double %379, %593
  %683 = fmul double %448, %682
  %684 = fadd double %681, %683
  %685 = fmul double %87, %96
  %686 = fmul double %685, %233
  %687 = fsub double %269, %686
  %688 = fmul double %379, %419
  %689 = fmul double %662, %688
  %690 = fsub double %687, %689
  %691 = fmul double %379, %594
  %692 = fmul double %448, %691
  %693 = fadd double %690, %692
  %694 = fmul double %99, %233
  %695 = fsub double %284, %694
  %696 = fmul double %662, %430
  %697 = fsub double %695, %696
  %698 = fmul double %448, %598
  %699 = fadd double %697, %698
  %700 = fmul double %101, %233
  %701 = fsub double %272, %700
  %702 = fmul double %662, %420
  %703 = fsub double %701, %702
  %704 = fmul double %448, %595
  %705 = fadd double %703, %704
  %706 = fmul double %103, %233
  %707 = fsub double %275, %706
  %708 = fmul double %662, %421
  %709 = fsub double %707, %708
  %710 = fmul double %448, %596
  %711 = fadd double %709, %710
  %712 = getelementptr inbounds double, double addrspace(1)* %3, i64 %25
  store double %668, double addrspace(1)* %712, align 8, !tbaa !8
  %713 = getelementptr inbounds double, double addrspace(1)* %3, i64 %33
  store double %675, double addrspace(1)* %713, align 8, !tbaa !8
  %714 = getelementptr inbounds double, double addrspace(1)* %3, i64 %39
  store double %684, double addrspace(1)* %714, align 8, !tbaa !8
  %715 = getelementptr inbounds double, double addrspace(1)* %3, i64 %45
  store double %693, double addrspace(1)* %715, align 8, !tbaa !8
  %716 = getelementptr inbounds double, double addrspace(1)* %3, i64 %51
  store double %699, double addrspace(1)* %716, align 8, !tbaa !8
  %717 = getelementptr inbounds double, double addrspace(1)* %3, i64 %57
  store double %705, double addrspace(1)* %717, align 8, !tbaa !8
  %718 = getelementptr inbounds double, double addrspace(1)* %3, i64 %62
  store double %711, double addrspace(1)* %718, align 8, !tbaa !8
  br label %merged.bb74
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.copysign.f64(double, double) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.fabs.f64(double) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.maxnum.f64(double, double) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.minnum.f64(double, double) #1

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.amdgcn.rsq.f64(double) #2

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.fma.f64(double, double, double) #1

; Function Attrs: nounwind readnone speculatable willreturn
declare align 4 i8 addrspace(4)* @llvm.amdgcn.dispatch.ptr() #2

; Function Attrs: nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.workgroup.id.x() #2

; Function Attrs: nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.workitem.id.x() #2

attributes #0 = { nofree norecurse nounwind willreturn "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { nounwind readnone speculatable willreturn }
attributes #3 = { nounwind }

!llvm.module.flags = !{!0, !1}
!opencl.ocl.version = !{!2}
!llvm.ident = !{!3, !4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 1}
!2 = !{i32 2, i32 0}
!3 = !{!"Ubuntu clang version 12.0.1-19ubuntu3"}
!4 = !{!"clang version 12.0.0 (/src/external/llvm-project/clang dac2bfceaa8d4a90257dc8a6d58f268e172ce00e)"}
!5 = !{i32 0, i32 1024}
!6 = !{i16 1, i16 1025}
!7 = !{}
!8 = !{!9, !9, i64 0}
!9 = !{!"double", !10, i64 0}
!10 = !{!"omnipotent char", !11, i64 0}
!11 = !{!"Simple C++ TBAA"}
