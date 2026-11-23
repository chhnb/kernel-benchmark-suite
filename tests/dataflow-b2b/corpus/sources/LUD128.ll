; ModuleID = '/data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-corpus/upstream/benchmarks/LUD/lud_kernel.hip.cpp'
source_filename = "/data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-corpus/upstream/benchmarks/LUD/lud_kernel.hip.cpp"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-G1-ni:7"
target triple = "amdgcn-amd-amdhsa"

@_ZZ12lud_diagonalPfiiE6shadow = internal unnamed_addr addrspace(3) global [128 x [128 x float]] undef, align 16
@_ZZ13lud_perimeterPfiiE3dia = internal unnamed_addr addrspace(3) global [128 x [128 x float]] undef, align 16
@_ZZ13lud_perimeterPfiiE8peri_row = internal unnamed_addr addrspace(3) global [128 x [128 x float]] undef, align 16
@_ZZ13lud_perimeterPfiiE8peri_col = internal unnamed_addr addrspace(3) global [128 x [128 x float]] undef, align 16
@_ZZ12lud_internalPfiiE8peri_row = internal unnamed_addr addrspace(3) global [128 x [128 x float]] undef, align 16
@_ZZ12lud_internalPfiiE8peri_col = internal unnamed_addr addrspace(3) global [128 x [128 x float]] undef, align 16

; Function Attrs: convergent norecurse nounwind
define protected amdgpu_kernel void @_Z12lud_diagonalPfii(float addrspace(1)* nocapture %0, i32 %1, i32 %2) local_unnamed_addr #0 {
  %4 = mul nsw i32 %2, %1
  %5 = add nsw i32 %4, %2
  %6 = tail call i32 @llvm.amdgcn.workitem.id.x() #3, !range !4
  %7 = zext i32 %6 to i64
  br label %8

8:                                                ; preds = %8, %3
  %9 = phi i32 [ %5, %3 ], [ %153, %8 ]
  %10 = phi i32 [ 0, %3 ], [ %154, %8 ]
  %11 = sext i32 %9 to i64
  %12 = add nsw i64 %11, %7
  %13 = getelementptr inbounds float, float addrspace(1)* %0, i64 %12
  %14 = bitcast float addrspace(1)* %13 to i32 addrspace(1)*
  %15 = load i32, i32 addrspace(1)* %14, align 4, !tbaa !5
  %16 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %10, i32 %6
  %17 = bitcast float addrspace(3)* %16 to i32 addrspace(3)*
  store i32 %15, i32 addrspace(3)* %17, align 4, !tbaa !5
  %18 = add nsw i32 %9, %1
  %19 = or i32 %10, 1
  %20 = sext i32 %18 to i64
  %21 = add nsw i64 %20, %7
  %22 = getelementptr inbounds float, float addrspace(1)* %0, i64 %21
  %23 = bitcast float addrspace(1)* %22 to i32 addrspace(1)*
  %24 = load i32, i32 addrspace(1)* %23, align 4, !tbaa !5
  %25 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %19, i32 %6
  %26 = bitcast float addrspace(3)* %25 to i32 addrspace(3)*
  store i32 %24, i32 addrspace(3)* %26, align 4, !tbaa !5
  %27 = add nsw i32 %18, %1
  %28 = or i32 %10, 2
  %29 = sext i32 %27 to i64
  %30 = add nsw i64 %29, %7
  %31 = getelementptr inbounds float, float addrspace(1)* %0, i64 %30
  %32 = bitcast float addrspace(1)* %31 to i32 addrspace(1)*
  %33 = load i32, i32 addrspace(1)* %32, align 4, !tbaa !5
  %34 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %28, i32 %6
  %35 = bitcast float addrspace(3)* %34 to i32 addrspace(3)*
  store i32 %33, i32 addrspace(3)* %35, align 4, !tbaa !5
  %36 = add nsw i32 %27, %1
  %37 = or i32 %10, 3
  %38 = sext i32 %36 to i64
  %39 = add nsw i64 %38, %7
  %40 = getelementptr inbounds float, float addrspace(1)* %0, i64 %39
  %41 = bitcast float addrspace(1)* %40 to i32 addrspace(1)*
  %42 = load i32, i32 addrspace(1)* %41, align 4, !tbaa !5
  %43 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %37, i32 %6
  %44 = bitcast float addrspace(3)* %43 to i32 addrspace(3)*
  store i32 %42, i32 addrspace(3)* %44, align 4, !tbaa !5
  %45 = add nsw i32 %36, %1
  %46 = or i32 %10, 4
  %47 = sext i32 %45 to i64
  %48 = add nsw i64 %47, %7
  %49 = getelementptr inbounds float, float addrspace(1)* %0, i64 %48
  %50 = bitcast float addrspace(1)* %49 to i32 addrspace(1)*
  %51 = load i32, i32 addrspace(1)* %50, align 4, !tbaa !5
  %52 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %46, i32 %6
  %53 = bitcast float addrspace(3)* %52 to i32 addrspace(3)*
  store i32 %51, i32 addrspace(3)* %53, align 4, !tbaa !5
  %54 = add nsw i32 %45, %1
  %55 = or i32 %10, 5
  %56 = sext i32 %54 to i64
  %57 = add nsw i64 %56, %7
  %58 = getelementptr inbounds float, float addrspace(1)* %0, i64 %57
  %59 = bitcast float addrspace(1)* %58 to i32 addrspace(1)*
  %60 = load i32, i32 addrspace(1)* %59, align 4, !tbaa !5
  %61 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %55, i32 %6
  %62 = bitcast float addrspace(3)* %61 to i32 addrspace(3)*
  store i32 %60, i32 addrspace(3)* %62, align 4, !tbaa !5
  %63 = add nsw i32 %54, %1
  %64 = or i32 %10, 6
  %65 = sext i32 %63 to i64
  %66 = add nsw i64 %65, %7
  %67 = getelementptr inbounds float, float addrspace(1)* %0, i64 %66
  %68 = bitcast float addrspace(1)* %67 to i32 addrspace(1)*
  %69 = load i32, i32 addrspace(1)* %68, align 4, !tbaa !5
  %70 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %64, i32 %6
  %71 = bitcast float addrspace(3)* %70 to i32 addrspace(3)*
  store i32 %69, i32 addrspace(3)* %71, align 4, !tbaa !5
  %72 = add nsw i32 %63, %1
  %73 = or i32 %10, 7
  %74 = sext i32 %72 to i64
  %75 = add nsw i64 %74, %7
  %76 = getelementptr inbounds float, float addrspace(1)* %0, i64 %75
  %77 = bitcast float addrspace(1)* %76 to i32 addrspace(1)*
  %78 = load i32, i32 addrspace(1)* %77, align 4, !tbaa !5
  %79 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %73, i32 %6
  %80 = bitcast float addrspace(3)* %79 to i32 addrspace(3)*
  store i32 %78, i32 addrspace(3)* %80, align 4, !tbaa !5
  %81 = add nsw i32 %72, %1
  %82 = or i32 %10, 8
  %83 = sext i32 %81 to i64
  %84 = add nsw i64 %83, %7
  %85 = getelementptr inbounds float, float addrspace(1)* %0, i64 %84
  %86 = bitcast float addrspace(1)* %85 to i32 addrspace(1)*
  %87 = load i32, i32 addrspace(1)* %86, align 4, !tbaa !5
  %88 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %82, i32 %6
  %89 = bitcast float addrspace(3)* %88 to i32 addrspace(3)*
  store i32 %87, i32 addrspace(3)* %89, align 4, !tbaa !5
  %90 = add nsw i32 %81, %1
  %91 = or i32 %10, 9
  %92 = sext i32 %90 to i64
  %93 = add nsw i64 %92, %7
  %94 = getelementptr inbounds float, float addrspace(1)* %0, i64 %93
  %95 = bitcast float addrspace(1)* %94 to i32 addrspace(1)*
  %96 = load i32, i32 addrspace(1)* %95, align 4, !tbaa !5
  %97 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %91, i32 %6
  %98 = bitcast float addrspace(3)* %97 to i32 addrspace(3)*
  store i32 %96, i32 addrspace(3)* %98, align 4, !tbaa !5
  %99 = add nsw i32 %90, %1
  %100 = or i32 %10, 10
  %101 = sext i32 %99 to i64
  %102 = add nsw i64 %101, %7
  %103 = getelementptr inbounds float, float addrspace(1)* %0, i64 %102
  %104 = bitcast float addrspace(1)* %103 to i32 addrspace(1)*
  %105 = load i32, i32 addrspace(1)* %104, align 4, !tbaa !5
  %106 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %100, i32 %6
  %107 = bitcast float addrspace(3)* %106 to i32 addrspace(3)*
  store i32 %105, i32 addrspace(3)* %107, align 4, !tbaa !5
  %108 = add nsw i32 %99, %1
  %109 = or i32 %10, 11
  %110 = sext i32 %108 to i64
  %111 = add nsw i64 %110, %7
  %112 = getelementptr inbounds float, float addrspace(1)* %0, i64 %111
  %113 = bitcast float addrspace(1)* %112 to i32 addrspace(1)*
  %114 = load i32, i32 addrspace(1)* %113, align 4, !tbaa !5
  %115 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %109, i32 %6
  %116 = bitcast float addrspace(3)* %115 to i32 addrspace(3)*
  store i32 %114, i32 addrspace(3)* %116, align 4, !tbaa !5
  %117 = add nsw i32 %108, %1
  %118 = or i32 %10, 12
  %119 = sext i32 %117 to i64
  %120 = add nsw i64 %119, %7
  %121 = getelementptr inbounds float, float addrspace(1)* %0, i64 %120
  %122 = bitcast float addrspace(1)* %121 to i32 addrspace(1)*
  %123 = load i32, i32 addrspace(1)* %122, align 4, !tbaa !5
  %124 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %118, i32 %6
  %125 = bitcast float addrspace(3)* %124 to i32 addrspace(3)*
  store i32 %123, i32 addrspace(3)* %125, align 4, !tbaa !5
  %126 = add nsw i32 %117, %1
  %127 = or i32 %10, 13
  %128 = sext i32 %126 to i64
  %129 = add nsw i64 %128, %7
  %130 = getelementptr inbounds float, float addrspace(1)* %0, i64 %129
  %131 = bitcast float addrspace(1)* %130 to i32 addrspace(1)*
  %132 = load i32, i32 addrspace(1)* %131, align 4, !tbaa !5
  %133 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %127, i32 %6
  %134 = bitcast float addrspace(3)* %133 to i32 addrspace(3)*
  store i32 %132, i32 addrspace(3)* %134, align 4, !tbaa !5
  %135 = add nsw i32 %126, %1
  %136 = or i32 %10, 14
  %137 = sext i32 %135 to i64
  %138 = add nsw i64 %137, %7
  %139 = getelementptr inbounds float, float addrspace(1)* %0, i64 %138
  %140 = bitcast float addrspace(1)* %139 to i32 addrspace(1)*
  %141 = load i32, i32 addrspace(1)* %140, align 4, !tbaa !5
  %142 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %136, i32 %6
  %143 = bitcast float addrspace(3)* %142 to i32 addrspace(3)*
  store i32 %141, i32 addrspace(3)* %143, align 4, !tbaa !5
  %144 = add nsw i32 %135, %1
  %145 = or i32 %10, 15
  %146 = sext i32 %144 to i64
  %147 = add nsw i64 %146, %7
  %148 = getelementptr inbounds float, float addrspace(1)* %0, i64 %147
  %149 = bitcast float addrspace(1)* %148 to i32 addrspace(1)*
  %150 = load i32, i32 addrspace(1)* %149, align 4, !tbaa !5
  %151 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %145, i32 %6
  %152 = bitcast float addrspace(3)* %151 to i32 addrspace(3)*
  store i32 %150, i32 addrspace(3)* %152, align 4, !tbaa !5
  %153 = add nsw i32 %144, %1
  %154 = add nuw nsw i32 %10, 16
  %155 = icmp eq i32 %154, 128
  br i1 %155, label %156, label %8, !llvm.loop !9

156:                                              ; preds = %8
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %157 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %6, i32 0
  br label %158

158:                                              ; preds = %156, %348
  %159 = phi i32 [ 0, %156 ], [ %261, %348 ]
  %160 = add nuw i32 %159, 1
  %161 = add nsw i32 %159, -1
  %162 = icmp ugt i32 %6, %159
  br i1 %162, label %163, label %260

163:                                              ; preds = %158
  %164 = icmp eq i32 %159, 0
  br i1 %164, label %165, label %167

165:                                              ; preds = %163
  %166 = load float, float addrspace(3)* %157, align 16, !tbaa !5
  br label %254

167:                                              ; preds = %163
  %168 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %6, i32 %159
  %169 = load float, float addrspace(3)* %168, align 4, !tbaa !5
  %170 = and i32 %159, 7
  %171 = icmp ult i32 %161, 7
  br i1 %171, label %236, label %172

172:                                              ; preds = %167
  %173 = and i32 %159, 2147483640
  br label %174

174:                                              ; preds = %174, %172
  %175 = phi float [ %169, %172 ], [ %232, %174 ]
  %176 = phi i32 [ 0, %172 ], [ %233, %174 ]
  %177 = phi i32 [ %173, %172 ], [ %234, %174 ]
  %178 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %6, i32 %176
  %179 = load float, float addrspace(3)* %178, align 16, !tbaa !5
  %180 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %176, i32 %159
  %181 = load float, float addrspace(3)* %180, align 4, !tbaa !5
  %182 = fmul contract float %179, %181
  %183 = fsub contract float %175, %182
  store float %183, float addrspace(3)* %168, align 4, !tbaa !5
  %184 = or i32 %176, 1
  %185 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %6, i32 %184
  %186 = load float, float addrspace(3)* %185, align 4, !tbaa !5
  %187 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %184, i32 %159
  %188 = load float, float addrspace(3)* %187, align 4, !tbaa !5
  %189 = fmul contract float %186, %188
  %190 = fsub contract float %183, %189
  store float %190, float addrspace(3)* %168, align 4, !tbaa !5
  %191 = or i32 %176, 2
  %192 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %6, i32 %191
  %193 = load float, float addrspace(3)* %192, align 8, !tbaa !5
  %194 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %191, i32 %159
  %195 = load float, float addrspace(3)* %194, align 4, !tbaa !5
  %196 = fmul contract float %193, %195
  %197 = fsub contract float %190, %196
  store float %197, float addrspace(3)* %168, align 4, !tbaa !5
  %198 = or i32 %176, 3
  %199 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %6, i32 %198
  %200 = load float, float addrspace(3)* %199, align 4, !tbaa !5
  %201 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %198, i32 %159
  %202 = load float, float addrspace(3)* %201, align 4, !tbaa !5
  %203 = fmul contract float %200, %202
  %204 = fsub contract float %197, %203
  store float %204, float addrspace(3)* %168, align 4, !tbaa !5
  %205 = or i32 %176, 4
  %206 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %6, i32 %205
  %207 = load float, float addrspace(3)* %206, align 16, !tbaa !5
  %208 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %205, i32 %159
  %209 = load float, float addrspace(3)* %208, align 4, !tbaa !5
  %210 = fmul contract float %207, %209
  %211 = fsub contract float %204, %210
  store float %211, float addrspace(3)* %168, align 4, !tbaa !5
  %212 = or i32 %176, 5
  %213 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %6, i32 %212
  %214 = load float, float addrspace(3)* %213, align 4, !tbaa !5
  %215 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %212, i32 %159
  %216 = load float, float addrspace(3)* %215, align 4, !tbaa !5
  %217 = fmul contract float %214, %216
  %218 = fsub contract float %211, %217
  store float %218, float addrspace(3)* %168, align 4, !tbaa !5
  %219 = or i32 %176, 6
  %220 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %6, i32 %219
  %221 = load float, float addrspace(3)* %220, align 8, !tbaa !5
  %222 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %219, i32 %159
  %223 = load float, float addrspace(3)* %222, align 4, !tbaa !5
  %224 = fmul contract float %221, %223
  %225 = fsub contract float %218, %224
  store float %225, float addrspace(3)* %168, align 4, !tbaa !5
  %226 = or i32 %176, 7
  %227 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %6, i32 %226
  %228 = load float, float addrspace(3)* %227, align 4, !tbaa !5
  %229 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %226, i32 %159
  %230 = load float, float addrspace(3)* %229, align 4, !tbaa !5
  %231 = fmul contract float %228, %230
  %232 = fsub contract float %225, %231
  store float %232, float addrspace(3)* %168, align 4, !tbaa !5
  %233 = add nuw nsw i32 %176, 8
  %234 = add i32 %177, -8
  %235 = icmp eq i32 %234, 0
  br i1 %235, label %236, label %174, !llvm.loop !11

236:                                              ; preds = %174, %167
  %237 = phi float [ undef, %167 ], [ %232, %174 ]
  %238 = phi float [ %169, %167 ], [ %232, %174 ]
  %239 = phi i32 [ 0, %167 ], [ %233, %174 ]
  %240 = icmp eq i32 %170, 0
  br i1 %240, label %254, label %241

241:                                              ; preds = %236, %241
  %242 = phi float [ %250, %241 ], [ %238, %236 ]
  %243 = phi i32 [ %251, %241 ], [ %239, %236 ]
  %244 = phi i32 [ %252, %241 ], [ %170, %236 ]
  %245 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %6, i32 %243
  %246 = load float, float addrspace(3)* %245, align 4, !tbaa !5
  %247 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %243, i32 %159
  %248 = load float, float addrspace(3)* %247, align 4, !tbaa !5
  %249 = fmul contract float %246, %248
  %250 = fsub contract float %242, %249
  store float %250, float addrspace(3)* %168, align 4, !tbaa !5
  %251 = add nuw nsw i32 %243, 1
  %252 = add i32 %244, -1
  %253 = icmp eq i32 %252, 0
  br i1 %253, label %254, label %241, !llvm.loop !12

254:                                              ; preds = %236, %241, %165
  %255 = phi float [ %166, %165 ], [ %237, %236 ], [ %250, %241 ]
  %256 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %159, i32 %159
  %257 = load float, float addrspace(3)* %256, align 4, !tbaa !5
  %258 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %6, i32 %159
  %259 = fdiv contract float %255, %257
  store float %259, float addrspace(3)* %258, align 4, !tbaa !5
  br label %260

260:                                              ; preds = %254, %158
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %261 = add nuw nsw i32 %159, 1
  br i1 %162, label %262, label %348

262:                                              ; preds = %260
  %263 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %261, i32 %6
  %264 = load float, float addrspace(3)* %263, align 4, !tbaa !5
  %265 = and i32 %160, 7
  %266 = icmp ult i32 %159, 7
  br i1 %266, label %331, label %267

267:                                              ; preds = %262
  %268 = and i32 %160, -8
  br label %269

269:                                              ; preds = %269, %267
  %270 = phi float [ %264, %267 ], [ %327, %269 ]
  %271 = phi i32 [ 0, %267 ], [ %328, %269 ]
  %272 = phi i32 [ %268, %267 ], [ %329, %269 ]
  %273 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %261, i32 %271
  %274 = load float, float addrspace(3)* %273, align 16, !tbaa !5
  %275 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %271, i32 %6
  %276 = load float, float addrspace(3)* %275, align 4, !tbaa !5
  %277 = fmul contract float %274, %276
  %278 = fsub contract float %270, %277
  store float %278, float addrspace(3)* %263, align 4, !tbaa !5
  %279 = or i32 %271, 1
  %280 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %261, i32 %279
  %281 = load float, float addrspace(3)* %280, align 4, !tbaa !5
  %282 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %279, i32 %6
  %283 = load float, float addrspace(3)* %282, align 4, !tbaa !5
  %284 = fmul contract float %281, %283
  %285 = fsub contract float %278, %284
  store float %285, float addrspace(3)* %263, align 4, !tbaa !5
  %286 = or i32 %271, 2
  %287 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %261, i32 %286
  %288 = load float, float addrspace(3)* %287, align 8, !tbaa !5
  %289 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %286, i32 %6
  %290 = load float, float addrspace(3)* %289, align 4, !tbaa !5
  %291 = fmul contract float %288, %290
  %292 = fsub contract float %285, %291
  store float %292, float addrspace(3)* %263, align 4, !tbaa !5
  %293 = or i32 %271, 3
  %294 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %261, i32 %293
  %295 = load float, float addrspace(3)* %294, align 4, !tbaa !5
  %296 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %293, i32 %6
  %297 = load float, float addrspace(3)* %296, align 4, !tbaa !5
  %298 = fmul contract float %295, %297
  %299 = fsub contract float %292, %298
  store float %299, float addrspace(3)* %263, align 4, !tbaa !5
  %300 = or i32 %271, 4
  %301 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %261, i32 %300
  %302 = load float, float addrspace(3)* %301, align 16, !tbaa !5
  %303 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %300, i32 %6
  %304 = load float, float addrspace(3)* %303, align 4, !tbaa !5
  %305 = fmul contract float %302, %304
  %306 = fsub contract float %299, %305
  store float %306, float addrspace(3)* %263, align 4, !tbaa !5
  %307 = or i32 %271, 5
  %308 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %261, i32 %307
  %309 = load float, float addrspace(3)* %308, align 4, !tbaa !5
  %310 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %307, i32 %6
  %311 = load float, float addrspace(3)* %310, align 4, !tbaa !5
  %312 = fmul contract float %309, %311
  %313 = fsub contract float %306, %312
  store float %313, float addrspace(3)* %263, align 4, !tbaa !5
  %314 = or i32 %271, 6
  %315 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %261, i32 %314
  %316 = load float, float addrspace(3)* %315, align 8, !tbaa !5
  %317 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %314, i32 %6
  %318 = load float, float addrspace(3)* %317, align 4, !tbaa !5
  %319 = fmul contract float %316, %318
  %320 = fsub contract float %313, %319
  store float %320, float addrspace(3)* %263, align 4, !tbaa !5
  %321 = or i32 %271, 7
  %322 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %261, i32 %321
  %323 = load float, float addrspace(3)* %322, align 4, !tbaa !5
  %324 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %321, i32 %6
  %325 = load float, float addrspace(3)* %324, align 4, !tbaa !5
  %326 = fmul contract float %323, %325
  %327 = fsub contract float %320, %326
  store float %327, float addrspace(3)* %263, align 4, !tbaa !5
  %328 = add nuw nsw i32 %271, 8
  %329 = add i32 %272, -8
  %330 = icmp eq i32 %329, 0
  br i1 %330, label %331, label %269, !llvm.loop !14

331:                                              ; preds = %269, %262
  %332 = phi float [ %264, %262 ], [ %327, %269 ]
  %333 = phi i32 [ 0, %262 ], [ %328, %269 ]
  %334 = icmp eq i32 %265, 0
  br i1 %334, label %348, label %335

335:                                              ; preds = %331, %335
  %336 = phi float [ %344, %335 ], [ %332, %331 ]
  %337 = phi i32 [ %345, %335 ], [ %333, %331 ]
  %338 = phi i32 [ %346, %335 ], [ %265, %331 ]
  %339 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %261, i32 %337
  %340 = load float, float addrspace(3)* %339, align 4, !tbaa !5
  %341 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %337, i32 %6
  %342 = load float, float addrspace(3)* %341, align 4, !tbaa !5
  %343 = fmul contract float %340, %342
  %344 = fsub contract float %336, %343
  store float %344, float addrspace(3)* %263, align 4, !tbaa !5
  %345 = add nuw nsw i32 %337, 1
  %346 = add i32 %338, -1
  %347 = icmp eq i32 %346, 0
  br i1 %347, label %348, label %335, !llvm.loop !15

348:                                              ; preds = %331, %335, %260
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %349 = icmp eq i32 %261, 127
  br i1 %349, label %350, label %158, !llvm.loop !16

350:                                              ; preds = %348
  %351 = add nsw i32 %2, 1
  %352 = mul nsw i32 %351, %1
  %353 = add nsw i32 %352, %2
  br label %354

354:                                              ; preds = %422, %350
  %355 = phi i32 [ %353, %350 ], [ %430, %422 ]
  %356 = phi i32 [ 1, %350 ], [ %431, %422 ]
  %357 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %356, i32 %6
  %358 = bitcast float addrspace(3)* %357 to i32 addrspace(3)*
  %359 = load i32, i32 addrspace(3)* %358, align 4, !tbaa !5
  %360 = sext i32 %355 to i64
  %361 = add nsw i64 %360, %7
  %362 = getelementptr inbounds float, float addrspace(1)* %0, i64 %361
  %363 = bitcast float addrspace(1)* %362 to i32 addrspace(1)*
  store i32 %359, i32 addrspace(1)* %363, align 4, !tbaa !5
  %364 = add nsw i32 %355, %1
  %365 = add nuw nsw i32 %356, 1
  %366 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %365, i32 %6
  %367 = bitcast float addrspace(3)* %366 to i32 addrspace(3)*
  %368 = load i32, i32 addrspace(3)* %367, align 4, !tbaa !5
  %369 = sext i32 %364 to i64
  %370 = add nsw i64 %369, %7
  %371 = getelementptr inbounds float, float addrspace(1)* %0, i64 %370
  %372 = bitcast float addrspace(1)* %371 to i32 addrspace(1)*
  store i32 %368, i32 addrspace(1)* %372, align 4, !tbaa !5
  %373 = add nsw i32 %364, %1
  %374 = add nuw nsw i32 %356, 2
  %375 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %374, i32 %6
  %376 = bitcast float addrspace(3)* %375 to i32 addrspace(3)*
  %377 = load i32, i32 addrspace(3)* %376, align 4, !tbaa !5
  %378 = sext i32 %373 to i64
  %379 = add nsw i64 %378, %7
  %380 = getelementptr inbounds float, float addrspace(1)* %0, i64 %379
  %381 = bitcast float addrspace(1)* %380 to i32 addrspace(1)*
  store i32 %377, i32 addrspace(1)* %381, align 4, !tbaa !5
  %382 = add nsw i32 %373, %1
  %383 = add nuw nsw i32 %356, 3
  %384 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %383, i32 %6
  %385 = bitcast float addrspace(3)* %384 to i32 addrspace(3)*
  %386 = load i32, i32 addrspace(3)* %385, align 4, !tbaa !5
  %387 = sext i32 %382 to i64
  %388 = add nsw i64 %387, %7
  %389 = getelementptr inbounds float, float addrspace(1)* %0, i64 %388
  %390 = bitcast float addrspace(1)* %389 to i32 addrspace(1)*
  store i32 %386, i32 addrspace(1)* %390, align 4, !tbaa !5
  %391 = add nsw i32 %382, %1
  %392 = add nuw nsw i32 %356, 4
  %393 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %392, i32 %6
  %394 = bitcast float addrspace(3)* %393 to i32 addrspace(3)*
  %395 = load i32, i32 addrspace(3)* %394, align 4, !tbaa !5
  %396 = sext i32 %391 to i64
  %397 = add nsw i64 %396, %7
  %398 = getelementptr inbounds float, float addrspace(1)* %0, i64 %397
  %399 = bitcast float addrspace(1)* %398 to i32 addrspace(1)*
  store i32 %395, i32 addrspace(1)* %399, align 4, !tbaa !5
  %400 = add nsw i32 %391, %1
  %401 = add nuw nsw i32 %356, 5
  %402 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %401, i32 %6
  %403 = bitcast float addrspace(3)* %402 to i32 addrspace(3)*
  %404 = load i32, i32 addrspace(3)* %403, align 4, !tbaa !5
  %405 = sext i32 %400 to i64
  %406 = add nsw i64 %405, %7
  %407 = getelementptr inbounds float, float addrspace(1)* %0, i64 %406
  %408 = bitcast float addrspace(1)* %407 to i32 addrspace(1)*
  store i32 %404, i32 addrspace(1)* %408, align 4, !tbaa !5
  %409 = add nsw i32 %400, %1
  %410 = add nuw nsw i32 %356, 6
  %411 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %410, i32 %6
  %412 = bitcast float addrspace(3)* %411 to i32 addrspace(3)*
  %413 = load i32, i32 addrspace(3)* %412, align 4, !tbaa !5
  %414 = sext i32 %409 to i64
  %415 = add nsw i64 %414, %7
  %416 = getelementptr inbounds float, float addrspace(1)* %0, i64 %415
  %417 = bitcast float addrspace(1)* %416 to i32 addrspace(1)*
  store i32 %413, i32 addrspace(1)* %417, align 4, !tbaa !5
  %418 = add nsw i32 %409, %1
  %419 = add nuw nsw i32 %356, 7
  %420 = icmp eq i32 %419, 128
  br i1 %420, label %421, label %422, !llvm.loop !17

421:                                              ; preds = %354
  ret void

422:                                              ; preds = %354
  %423 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_diagonalPfiiE6shadow, i32 0, i32 %419, i32 %6
  %424 = bitcast float addrspace(3)* %423 to i32 addrspace(3)*
  %425 = load i32, i32 addrspace(3)* %424, align 4, !tbaa !5
  %426 = sext i32 %418 to i64
  %427 = add nsw i64 %426, %7
  %428 = getelementptr inbounds float, float addrspace(1)* %0, i64 %427
  %429 = bitcast float addrspace(1)* %428 to i32 addrspace(1)*
  store i32 %425, i32 addrspace(1)* %429, align 4, !tbaa !5
  %430 = add nsw i32 %418, %1
  %431 = add nuw nsw i32 %356, 8
  br label %354
}

; Function Attrs: convergent norecurse nounwind
define protected amdgpu_kernel void @_Z13lud_perimeterPfii(float addrspace(1)* nocapture %0, i32 %1, i32 %2) local_unnamed_addr #0 {
  %4 = tail call i32 @llvm.amdgcn.workitem.id.x() #3, !range !4
  %5 = zext i32 %4 to i64
  %6 = icmp ult i32 %4, 128
  br i1 %6, label %7, label %674

7:                                                ; preds = %3
  %8 = mul nsw i32 %2, %1
  %9 = add nsw i32 %8, %2
  %10 = add nsw i32 %9, %4
  %11 = sext i32 %10 to i64
  %12 = getelementptr inbounds float, float addrspace(1)* %0, i64 %11
  %13 = bitcast float addrspace(1)* %12 to i32 addrspace(1)*
  %14 = load i32, i32 addrspace(1)* %13, align 4, !tbaa !5
  %15 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 0, i32 %4
  %16 = bitcast float addrspace(3)* %15 to i32 addrspace(3)*
  store i32 %14, i32 addrspace(3)* %16, align 4, !tbaa !5
  %17 = add nsw i32 %9, %1
  %18 = add nsw i32 %17, %4
  %19 = sext i32 %18 to i64
  %20 = getelementptr inbounds float, float addrspace(1)* %0, i64 %19
  %21 = bitcast float addrspace(1)* %20 to i32 addrspace(1)*
  %22 = load i32, i32 addrspace(1)* %21, align 4, !tbaa !5
  %23 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 1, i32 %4
  %24 = bitcast float addrspace(3)* %23 to i32 addrspace(3)*
  store i32 %22, i32 addrspace(3)* %24, align 4, !tbaa !5
  %25 = add nsw i32 %17, %1
  %26 = add nsw i32 %25, %4
  %27 = sext i32 %26 to i64
  %28 = getelementptr inbounds float, float addrspace(1)* %0, i64 %27
  %29 = bitcast float addrspace(1)* %28 to i32 addrspace(1)*
  %30 = load i32, i32 addrspace(1)* %29, align 4, !tbaa !5
  %31 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 2, i32 %4
  %32 = bitcast float addrspace(3)* %31 to i32 addrspace(3)*
  store i32 %30, i32 addrspace(3)* %32, align 4, !tbaa !5
  %33 = add nsw i32 %25, %1
  %34 = add nsw i32 %33, %4
  %35 = sext i32 %34 to i64
  %36 = getelementptr inbounds float, float addrspace(1)* %0, i64 %35
  %37 = bitcast float addrspace(1)* %36 to i32 addrspace(1)*
  %38 = load i32, i32 addrspace(1)* %37, align 4, !tbaa !5
  %39 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 3, i32 %4
  %40 = bitcast float addrspace(3)* %39 to i32 addrspace(3)*
  store i32 %38, i32 addrspace(3)* %40, align 4, !tbaa !5
  %41 = add nsw i32 %33, %1
  %42 = add nsw i32 %41, %4
  %43 = sext i32 %42 to i64
  %44 = getelementptr inbounds float, float addrspace(1)* %0, i64 %43
  %45 = bitcast float addrspace(1)* %44 to i32 addrspace(1)*
  %46 = load i32, i32 addrspace(1)* %45, align 4, !tbaa !5
  %47 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 4, i32 %4
  %48 = bitcast float addrspace(3)* %47 to i32 addrspace(3)*
  store i32 %46, i32 addrspace(3)* %48, align 4, !tbaa !5
  %49 = add nsw i32 %41, %1
  %50 = add nsw i32 %49, %4
  %51 = sext i32 %50 to i64
  %52 = getelementptr inbounds float, float addrspace(1)* %0, i64 %51
  %53 = bitcast float addrspace(1)* %52 to i32 addrspace(1)*
  %54 = load i32, i32 addrspace(1)* %53, align 4, !tbaa !5
  %55 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 5, i32 %4
  %56 = bitcast float addrspace(3)* %55 to i32 addrspace(3)*
  store i32 %54, i32 addrspace(3)* %56, align 4, !tbaa !5
  %57 = add nsw i32 %49, %1
  %58 = add nsw i32 %57, %4
  %59 = sext i32 %58 to i64
  %60 = getelementptr inbounds float, float addrspace(1)* %0, i64 %59
  %61 = bitcast float addrspace(1)* %60 to i32 addrspace(1)*
  %62 = load i32, i32 addrspace(1)* %61, align 4, !tbaa !5
  %63 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 6, i32 %4
  %64 = bitcast float addrspace(3)* %63 to i32 addrspace(3)*
  store i32 %62, i32 addrspace(3)* %64, align 4, !tbaa !5
  %65 = add nsw i32 %57, %1
  %66 = add nsw i32 %65, %4
  %67 = sext i32 %66 to i64
  %68 = getelementptr inbounds float, float addrspace(1)* %0, i64 %67
  %69 = bitcast float addrspace(1)* %68 to i32 addrspace(1)*
  %70 = load i32, i32 addrspace(1)* %69, align 4, !tbaa !5
  %71 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 7, i32 %4
  %72 = bitcast float addrspace(3)* %71 to i32 addrspace(3)*
  store i32 %70, i32 addrspace(3)* %72, align 4, !tbaa !5
  %73 = add nsw i32 %65, %1
  %74 = add nsw i32 %73, %4
  %75 = sext i32 %74 to i64
  %76 = getelementptr inbounds float, float addrspace(1)* %0, i64 %75
  %77 = bitcast float addrspace(1)* %76 to i32 addrspace(1)*
  %78 = load i32, i32 addrspace(1)* %77, align 4, !tbaa !5
  %79 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 8, i32 %4
  %80 = bitcast float addrspace(3)* %79 to i32 addrspace(3)*
  store i32 %78, i32 addrspace(3)* %80, align 4, !tbaa !5
  %81 = add nsw i32 %73, %1
  %82 = add nsw i32 %81, %4
  %83 = sext i32 %82 to i64
  %84 = getelementptr inbounds float, float addrspace(1)* %0, i64 %83
  %85 = bitcast float addrspace(1)* %84 to i32 addrspace(1)*
  %86 = load i32, i32 addrspace(1)* %85, align 4, !tbaa !5
  %87 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 9, i32 %4
  %88 = bitcast float addrspace(3)* %87 to i32 addrspace(3)*
  store i32 %86, i32 addrspace(3)* %88, align 4, !tbaa !5
  %89 = add nsw i32 %81, %1
  %90 = add nsw i32 %89, %4
  %91 = sext i32 %90 to i64
  %92 = getelementptr inbounds float, float addrspace(1)* %0, i64 %91
  %93 = bitcast float addrspace(1)* %92 to i32 addrspace(1)*
  %94 = load i32, i32 addrspace(1)* %93, align 4, !tbaa !5
  %95 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 10, i32 %4
  %96 = bitcast float addrspace(3)* %95 to i32 addrspace(3)*
  store i32 %94, i32 addrspace(3)* %96, align 4, !tbaa !5
  %97 = add nsw i32 %89, %1
  %98 = add nsw i32 %97, %4
  %99 = sext i32 %98 to i64
  %100 = getelementptr inbounds float, float addrspace(1)* %0, i64 %99
  %101 = bitcast float addrspace(1)* %100 to i32 addrspace(1)*
  %102 = load i32, i32 addrspace(1)* %101, align 4, !tbaa !5
  %103 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 11, i32 %4
  %104 = bitcast float addrspace(3)* %103 to i32 addrspace(3)*
  store i32 %102, i32 addrspace(3)* %104, align 4, !tbaa !5
  %105 = add nsw i32 %97, %1
  %106 = add nsw i32 %105, %4
  %107 = sext i32 %106 to i64
  %108 = getelementptr inbounds float, float addrspace(1)* %0, i64 %107
  %109 = bitcast float addrspace(1)* %108 to i32 addrspace(1)*
  %110 = load i32, i32 addrspace(1)* %109, align 4, !tbaa !5
  %111 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 12, i32 %4
  %112 = bitcast float addrspace(3)* %111 to i32 addrspace(3)*
  store i32 %110, i32 addrspace(3)* %112, align 4, !tbaa !5
  %113 = add nsw i32 %105, %1
  %114 = add nsw i32 %113, %4
  %115 = sext i32 %114 to i64
  %116 = getelementptr inbounds float, float addrspace(1)* %0, i64 %115
  %117 = bitcast float addrspace(1)* %116 to i32 addrspace(1)*
  %118 = load i32, i32 addrspace(1)* %117, align 4, !tbaa !5
  %119 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 13, i32 %4
  %120 = bitcast float addrspace(3)* %119 to i32 addrspace(3)*
  store i32 %118, i32 addrspace(3)* %120, align 4, !tbaa !5
  %121 = add nsw i32 %113, %1
  %122 = add nsw i32 %121, %4
  %123 = sext i32 %122 to i64
  %124 = getelementptr inbounds float, float addrspace(1)* %0, i64 %123
  %125 = bitcast float addrspace(1)* %124 to i32 addrspace(1)*
  %126 = load i32, i32 addrspace(1)* %125, align 4, !tbaa !5
  %127 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 14, i32 %4
  %128 = bitcast float addrspace(3)* %127 to i32 addrspace(3)*
  store i32 %126, i32 addrspace(3)* %128, align 4, !tbaa !5
  %129 = add nsw i32 %121, %1
  %130 = add nsw i32 %129, %4
  %131 = sext i32 %130 to i64
  %132 = getelementptr inbounds float, float addrspace(1)* %0, i64 %131
  %133 = bitcast float addrspace(1)* %132 to i32 addrspace(1)*
  %134 = load i32, i32 addrspace(1)* %133, align 4, !tbaa !5
  %135 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 15, i32 %4
  %136 = bitcast float addrspace(3)* %135 to i32 addrspace(3)*
  store i32 %134, i32 addrspace(3)* %136, align 4, !tbaa !5
  %137 = add nsw i32 %129, %1
  %138 = add nsw i32 %137, %4
  %139 = sext i32 %138 to i64
  %140 = getelementptr inbounds float, float addrspace(1)* %0, i64 %139
  %141 = bitcast float addrspace(1)* %140 to i32 addrspace(1)*
  %142 = load i32, i32 addrspace(1)* %141, align 4, !tbaa !5
  %143 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 16, i32 %4
  %144 = bitcast float addrspace(3)* %143 to i32 addrspace(3)*
  store i32 %142, i32 addrspace(3)* %144, align 4, !tbaa !5
  %145 = add nsw i32 %137, %1
  %146 = add nsw i32 %145, %4
  %147 = sext i32 %146 to i64
  %148 = getelementptr inbounds float, float addrspace(1)* %0, i64 %147
  %149 = bitcast float addrspace(1)* %148 to i32 addrspace(1)*
  %150 = load i32, i32 addrspace(1)* %149, align 4, !tbaa !5
  %151 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 17, i32 %4
  %152 = bitcast float addrspace(3)* %151 to i32 addrspace(3)*
  store i32 %150, i32 addrspace(3)* %152, align 4, !tbaa !5
  %153 = add nsw i32 %145, %1
  %154 = add nsw i32 %153, %4
  %155 = sext i32 %154 to i64
  %156 = getelementptr inbounds float, float addrspace(1)* %0, i64 %155
  %157 = bitcast float addrspace(1)* %156 to i32 addrspace(1)*
  %158 = load i32, i32 addrspace(1)* %157, align 4, !tbaa !5
  %159 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 18, i32 %4
  %160 = bitcast float addrspace(3)* %159 to i32 addrspace(3)*
  store i32 %158, i32 addrspace(3)* %160, align 4, !tbaa !5
  %161 = add nsw i32 %153, %1
  %162 = add nsw i32 %161, %4
  %163 = sext i32 %162 to i64
  %164 = getelementptr inbounds float, float addrspace(1)* %0, i64 %163
  %165 = bitcast float addrspace(1)* %164 to i32 addrspace(1)*
  %166 = load i32, i32 addrspace(1)* %165, align 4, !tbaa !5
  %167 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 19, i32 %4
  %168 = bitcast float addrspace(3)* %167 to i32 addrspace(3)*
  store i32 %166, i32 addrspace(3)* %168, align 4, !tbaa !5
  %169 = add nsw i32 %161, %1
  %170 = add nsw i32 %169, %4
  %171 = sext i32 %170 to i64
  %172 = getelementptr inbounds float, float addrspace(1)* %0, i64 %171
  %173 = bitcast float addrspace(1)* %172 to i32 addrspace(1)*
  %174 = load i32, i32 addrspace(1)* %173, align 4, !tbaa !5
  %175 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 20, i32 %4
  %176 = bitcast float addrspace(3)* %175 to i32 addrspace(3)*
  store i32 %174, i32 addrspace(3)* %176, align 4, !tbaa !5
  %177 = add nsw i32 %169, %1
  %178 = add nsw i32 %177, %4
  %179 = sext i32 %178 to i64
  %180 = getelementptr inbounds float, float addrspace(1)* %0, i64 %179
  %181 = bitcast float addrspace(1)* %180 to i32 addrspace(1)*
  %182 = load i32, i32 addrspace(1)* %181, align 4, !tbaa !5
  %183 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 21, i32 %4
  %184 = bitcast float addrspace(3)* %183 to i32 addrspace(3)*
  store i32 %182, i32 addrspace(3)* %184, align 4, !tbaa !5
  %185 = add nsw i32 %177, %1
  %186 = add nsw i32 %185, %4
  %187 = sext i32 %186 to i64
  %188 = getelementptr inbounds float, float addrspace(1)* %0, i64 %187
  %189 = bitcast float addrspace(1)* %188 to i32 addrspace(1)*
  %190 = load i32, i32 addrspace(1)* %189, align 4, !tbaa !5
  %191 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 22, i32 %4
  %192 = bitcast float addrspace(3)* %191 to i32 addrspace(3)*
  store i32 %190, i32 addrspace(3)* %192, align 4, !tbaa !5
  %193 = add nsw i32 %185, %1
  %194 = add nsw i32 %193, %4
  %195 = sext i32 %194 to i64
  %196 = getelementptr inbounds float, float addrspace(1)* %0, i64 %195
  %197 = bitcast float addrspace(1)* %196 to i32 addrspace(1)*
  %198 = load i32, i32 addrspace(1)* %197, align 4, !tbaa !5
  %199 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 23, i32 %4
  %200 = bitcast float addrspace(3)* %199 to i32 addrspace(3)*
  store i32 %198, i32 addrspace(3)* %200, align 4, !tbaa !5
  %201 = add nsw i32 %193, %1
  %202 = add nsw i32 %201, %4
  %203 = sext i32 %202 to i64
  %204 = getelementptr inbounds float, float addrspace(1)* %0, i64 %203
  %205 = bitcast float addrspace(1)* %204 to i32 addrspace(1)*
  %206 = load i32, i32 addrspace(1)* %205, align 4, !tbaa !5
  %207 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 24, i32 %4
  %208 = bitcast float addrspace(3)* %207 to i32 addrspace(3)*
  store i32 %206, i32 addrspace(3)* %208, align 4, !tbaa !5
  %209 = add nsw i32 %201, %1
  %210 = add nsw i32 %209, %4
  %211 = sext i32 %210 to i64
  %212 = getelementptr inbounds float, float addrspace(1)* %0, i64 %211
  %213 = bitcast float addrspace(1)* %212 to i32 addrspace(1)*
  %214 = load i32, i32 addrspace(1)* %213, align 4, !tbaa !5
  %215 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 25, i32 %4
  %216 = bitcast float addrspace(3)* %215 to i32 addrspace(3)*
  store i32 %214, i32 addrspace(3)* %216, align 4, !tbaa !5
  %217 = add nsw i32 %209, %1
  %218 = add nsw i32 %217, %4
  %219 = sext i32 %218 to i64
  %220 = getelementptr inbounds float, float addrspace(1)* %0, i64 %219
  %221 = bitcast float addrspace(1)* %220 to i32 addrspace(1)*
  %222 = load i32, i32 addrspace(1)* %221, align 4, !tbaa !5
  %223 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 26, i32 %4
  %224 = bitcast float addrspace(3)* %223 to i32 addrspace(3)*
  store i32 %222, i32 addrspace(3)* %224, align 4, !tbaa !5
  %225 = add nsw i32 %217, %1
  %226 = add nsw i32 %225, %4
  %227 = sext i32 %226 to i64
  %228 = getelementptr inbounds float, float addrspace(1)* %0, i64 %227
  %229 = bitcast float addrspace(1)* %228 to i32 addrspace(1)*
  %230 = load i32, i32 addrspace(1)* %229, align 4, !tbaa !5
  %231 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 27, i32 %4
  %232 = bitcast float addrspace(3)* %231 to i32 addrspace(3)*
  store i32 %230, i32 addrspace(3)* %232, align 4, !tbaa !5
  %233 = add nsw i32 %225, %1
  %234 = add nsw i32 %233, %4
  %235 = sext i32 %234 to i64
  %236 = getelementptr inbounds float, float addrspace(1)* %0, i64 %235
  %237 = bitcast float addrspace(1)* %236 to i32 addrspace(1)*
  %238 = load i32, i32 addrspace(1)* %237, align 4, !tbaa !5
  %239 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 28, i32 %4
  %240 = bitcast float addrspace(3)* %239 to i32 addrspace(3)*
  store i32 %238, i32 addrspace(3)* %240, align 4, !tbaa !5
  %241 = add nsw i32 %233, %1
  %242 = add nsw i32 %241, %4
  %243 = sext i32 %242 to i64
  %244 = getelementptr inbounds float, float addrspace(1)* %0, i64 %243
  %245 = bitcast float addrspace(1)* %244 to i32 addrspace(1)*
  %246 = load i32, i32 addrspace(1)* %245, align 4, !tbaa !5
  %247 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 29, i32 %4
  %248 = bitcast float addrspace(3)* %247 to i32 addrspace(3)*
  store i32 %246, i32 addrspace(3)* %248, align 4, !tbaa !5
  %249 = add nsw i32 %241, %1
  %250 = add nsw i32 %249, %4
  %251 = sext i32 %250 to i64
  %252 = getelementptr inbounds float, float addrspace(1)* %0, i64 %251
  %253 = bitcast float addrspace(1)* %252 to i32 addrspace(1)*
  %254 = load i32, i32 addrspace(1)* %253, align 4, !tbaa !5
  %255 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 30, i32 %4
  %256 = bitcast float addrspace(3)* %255 to i32 addrspace(3)*
  store i32 %254, i32 addrspace(3)* %256, align 4, !tbaa !5
  %257 = add nsw i32 %249, %1
  %258 = add nsw i32 %257, %4
  %259 = sext i32 %258 to i64
  %260 = getelementptr inbounds float, float addrspace(1)* %0, i64 %259
  %261 = bitcast float addrspace(1)* %260 to i32 addrspace(1)*
  %262 = load i32, i32 addrspace(1)* %261, align 4, !tbaa !5
  %263 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 31, i32 %4
  %264 = bitcast float addrspace(3)* %263 to i32 addrspace(3)*
  store i32 %262, i32 addrspace(3)* %264, align 4, !tbaa !5
  %265 = add nsw i32 %257, %1
  %266 = add nsw i32 %265, %4
  %267 = sext i32 %266 to i64
  %268 = getelementptr inbounds float, float addrspace(1)* %0, i64 %267
  %269 = bitcast float addrspace(1)* %268 to i32 addrspace(1)*
  %270 = load i32, i32 addrspace(1)* %269, align 4, !tbaa !5
  %271 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 32, i32 %4
  %272 = bitcast float addrspace(3)* %271 to i32 addrspace(3)*
  store i32 %270, i32 addrspace(3)* %272, align 4, !tbaa !5
  %273 = add nsw i32 %265, %1
  %274 = add nsw i32 %273, %4
  %275 = sext i32 %274 to i64
  %276 = getelementptr inbounds float, float addrspace(1)* %0, i64 %275
  %277 = bitcast float addrspace(1)* %276 to i32 addrspace(1)*
  %278 = load i32, i32 addrspace(1)* %277, align 4, !tbaa !5
  %279 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 33, i32 %4
  %280 = bitcast float addrspace(3)* %279 to i32 addrspace(3)*
  store i32 %278, i32 addrspace(3)* %280, align 4, !tbaa !5
  %281 = add nsw i32 %273, %1
  %282 = add nsw i32 %281, %4
  %283 = sext i32 %282 to i64
  %284 = getelementptr inbounds float, float addrspace(1)* %0, i64 %283
  %285 = bitcast float addrspace(1)* %284 to i32 addrspace(1)*
  %286 = load i32, i32 addrspace(1)* %285, align 4, !tbaa !5
  %287 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 34, i32 %4
  %288 = bitcast float addrspace(3)* %287 to i32 addrspace(3)*
  store i32 %286, i32 addrspace(3)* %288, align 4, !tbaa !5
  %289 = add nsw i32 %281, %1
  %290 = add nsw i32 %289, %4
  %291 = sext i32 %290 to i64
  %292 = getelementptr inbounds float, float addrspace(1)* %0, i64 %291
  %293 = bitcast float addrspace(1)* %292 to i32 addrspace(1)*
  %294 = load i32, i32 addrspace(1)* %293, align 4, !tbaa !5
  %295 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 35, i32 %4
  %296 = bitcast float addrspace(3)* %295 to i32 addrspace(3)*
  store i32 %294, i32 addrspace(3)* %296, align 4, !tbaa !5
  %297 = add nsw i32 %289, %1
  %298 = add nsw i32 %297, %4
  %299 = sext i32 %298 to i64
  %300 = getelementptr inbounds float, float addrspace(1)* %0, i64 %299
  %301 = bitcast float addrspace(1)* %300 to i32 addrspace(1)*
  %302 = load i32, i32 addrspace(1)* %301, align 4, !tbaa !5
  %303 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 36, i32 %4
  %304 = bitcast float addrspace(3)* %303 to i32 addrspace(3)*
  store i32 %302, i32 addrspace(3)* %304, align 4, !tbaa !5
  %305 = add nsw i32 %297, %1
  %306 = add nsw i32 %305, %4
  %307 = sext i32 %306 to i64
  %308 = getelementptr inbounds float, float addrspace(1)* %0, i64 %307
  %309 = bitcast float addrspace(1)* %308 to i32 addrspace(1)*
  %310 = load i32, i32 addrspace(1)* %309, align 4, !tbaa !5
  %311 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 37, i32 %4
  %312 = bitcast float addrspace(3)* %311 to i32 addrspace(3)*
  store i32 %310, i32 addrspace(3)* %312, align 4, !tbaa !5
  %313 = add nsw i32 %305, %1
  %314 = add nsw i32 %313, %4
  %315 = sext i32 %314 to i64
  %316 = getelementptr inbounds float, float addrspace(1)* %0, i64 %315
  %317 = bitcast float addrspace(1)* %316 to i32 addrspace(1)*
  %318 = load i32, i32 addrspace(1)* %317, align 4, !tbaa !5
  %319 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 38, i32 %4
  %320 = bitcast float addrspace(3)* %319 to i32 addrspace(3)*
  store i32 %318, i32 addrspace(3)* %320, align 4, !tbaa !5
  %321 = add nsw i32 %313, %1
  %322 = add nsw i32 %321, %4
  %323 = sext i32 %322 to i64
  %324 = getelementptr inbounds float, float addrspace(1)* %0, i64 %323
  %325 = bitcast float addrspace(1)* %324 to i32 addrspace(1)*
  %326 = load i32, i32 addrspace(1)* %325, align 4, !tbaa !5
  %327 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 39, i32 %4
  %328 = bitcast float addrspace(3)* %327 to i32 addrspace(3)*
  store i32 %326, i32 addrspace(3)* %328, align 4, !tbaa !5
  %329 = add nsw i32 %321, %1
  %330 = add nsw i32 %329, %4
  %331 = sext i32 %330 to i64
  %332 = getelementptr inbounds float, float addrspace(1)* %0, i64 %331
  %333 = bitcast float addrspace(1)* %332 to i32 addrspace(1)*
  %334 = load i32, i32 addrspace(1)* %333, align 4, !tbaa !5
  %335 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 40, i32 %4
  %336 = bitcast float addrspace(3)* %335 to i32 addrspace(3)*
  store i32 %334, i32 addrspace(3)* %336, align 4, !tbaa !5
  %337 = add nsw i32 %329, %1
  %338 = add nsw i32 %337, %4
  %339 = sext i32 %338 to i64
  %340 = getelementptr inbounds float, float addrspace(1)* %0, i64 %339
  %341 = bitcast float addrspace(1)* %340 to i32 addrspace(1)*
  %342 = load i32, i32 addrspace(1)* %341, align 4, !tbaa !5
  %343 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 41, i32 %4
  %344 = bitcast float addrspace(3)* %343 to i32 addrspace(3)*
  store i32 %342, i32 addrspace(3)* %344, align 4, !tbaa !5
  %345 = add nsw i32 %337, %1
  %346 = add nsw i32 %345, %4
  %347 = sext i32 %346 to i64
  %348 = getelementptr inbounds float, float addrspace(1)* %0, i64 %347
  %349 = bitcast float addrspace(1)* %348 to i32 addrspace(1)*
  %350 = load i32, i32 addrspace(1)* %349, align 4, !tbaa !5
  %351 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 42, i32 %4
  %352 = bitcast float addrspace(3)* %351 to i32 addrspace(3)*
  store i32 %350, i32 addrspace(3)* %352, align 4, !tbaa !5
  %353 = add nsw i32 %345, %1
  %354 = add nsw i32 %353, %4
  %355 = sext i32 %354 to i64
  %356 = getelementptr inbounds float, float addrspace(1)* %0, i64 %355
  %357 = bitcast float addrspace(1)* %356 to i32 addrspace(1)*
  %358 = load i32, i32 addrspace(1)* %357, align 4, !tbaa !5
  %359 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 43, i32 %4
  %360 = bitcast float addrspace(3)* %359 to i32 addrspace(3)*
  store i32 %358, i32 addrspace(3)* %360, align 4, !tbaa !5
  %361 = add nsw i32 %353, %1
  %362 = add nsw i32 %361, %4
  %363 = sext i32 %362 to i64
  %364 = getelementptr inbounds float, float addrspace(1)* %0, i64 %363
  %365 = bitcast float addrspace(1)* %364 to i32 addrspace(1)*
  %366 = load i32, i32 addrspace(1)* %365, align 4, !tbaa !5
  %367 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 44, i32 %4
  %368 = bitcast float addrspace(3)* %367 to i32 addrspace(3)*
  store i32 %366, i32 addrspace(3)* %368, align 4, !tbaa !5
  %369 = add nsw i32 %361, %1
  %370 = add nsw i32 %369, %4
  %371 = sext i32 %370 to i64
  %372 = getelementptr inbounds float, float addrspace(1)* %0, i64 %371
  %373 = bitcast float addrspace(1)* %372 to i32 addrspace(1)*
  %374 = load i32, i32 addrspace(1)* %373, align 4, !tbaa !5
  %375 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 45, i32 %4
  %376 = bitcast float addrspace(3)* %375 to i32 addrspace(3)*
  store i32 %374, i32 addrspace(3)* %376, align 4, !tbaa !5
  %377 = add nsw i32 %369, %1
  %378 = add nsw i32 %377, %4
  %379 = sext i32 %378 to i64
  %380 = getelementptr inbounds float, float addrspace(1)* %0, i64 %379
  %381 = bitcast float addrspace(1)* %380 to i32 addrspace(1)*
  %382 = load i32, i32 addrspace(1)* %381, align 4, !tbaa !5
  %383 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 46, i32 %4
  %384 = bitcast float addrspace(3)* %383 to i32 addrspace(3)*
  store i32 %382, i32 addrspace(3)* %384, align 4, !tbaa !5
  %385 = add nsw i32 %377, %1
  %386 = add nsw i32 %385, %4
  %387 = sext i32 %386 to i64
  %388 = getelementptr inbounds float, float addrspace(1)* %0, i64 %387
  %389 = bitcast float addrspace(1)* %388 to i32 addrspace(1)*
  %390 = load i32, i32 addrspace(1)* %389, align 4, !tbaa !5
  %391 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 47, i32 %4
  %392 = bitcast float addrspace(3)* %391 to i32 addrspace(3)*
  store i32 %390, i32 addrspace(3)* %392, align 4, !tbaa !5
  %393 = add nsw i32 %385, %1
  %394 = add nsw i32 %393, %4
  %395 = sext i32 %394 to i64
  %396 = getelementptr inbounds float, float addrspace(1)* %0, i64 %395
  %397 = bitcast float addrspace(1)* %396 to i32 addrspace(1)*
  %398 = load i32, i32 addrspace(1)* %397, align 4, !tbaa !5
  %399 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 48, i32 %4
  %400 = bitcast float addrspace(3)* %399 to i32 addrspace(3)*
  store i32 %398, i32 addrspace(3)* %400, align 4, !tbaa !5
  %401 = add nsw i32 %393, %1
  %402 = add nsw i32 %401, %4
  %403 = sext i32 %402 to i64
  %404 = getelementptr inbounds float, float addrspace(1)* %0, i64 %403
  %405 = bitcast float addrspace(1)* %404 to i32 addrspace(1)*
  %406 = load i32, i32 addrspace(1)* %405, align 4, !tbaa !5
  %407 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 49, i32 %4
  %408 = bitcast float addrspace(3)* %407 to i32 addrspace(3)*
  store i32 %406, i32 addrspace(3)* %408, align 4, !tbaa !5
  %409 = add nsw i32 %401, %1
  %410 = add nsw i32 %409, %4
  %411 = sext i32 %410 to i64
  %412 = getelementptr inbounds float, float addrspace(1)* %0, i64 %411
  %413 = bitcast float addrspace(1)* %412 to i32 addrspace(1)*
  %414 = load i32, i32 addrspace(1)* %413, align 4, !tbaa !5
  %415 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 50, i32 %4
  %416 = bitcast float addrspace(3)* %415 to i32 addrspace(3)*
  store i32 %414, i32 addrspace(3)* %416, align 4, !tbaa !5
  %417 = add nsw i32 %409, %1
  %418 = add nsw i32 %417, %4
  %419 = sext i32 %418 to i64
  %420 = getelementptr inbounds float, float addrspace(1)* %0, i64 %419
  %421 = bitcast float addrspace(1)* %420 to i32 addrspace(1)*
  %422 = load i32, i32 addrspace(1)* %421, align 4, !tbaa !5
  %423 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 51, i32 %4
  %424 = bitcast float addrspace(3)* %423 to i32 addrspace(3)*
  store i32 %422, i32 addrspace(3)* %424, align 4, !tbaa !5
  %425 = add nsw i32 %417, %1
  %426 = add nsw i32 %425, %4
  %427 = sext i32 %426 to i64
  %428 = getelementptr inbounds float, float addrspace(1)* %0, i64 %427
  %429 = bitcast float addrspace(1)* %428 to i32 addrspace(1)*
  %430 = load i32, i32 addrspace(1)* %429, align 4, !tbaa !5
  %431 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 52, i32 %4
  %432 = bitcast float addrspace(3)* %431 to i32 addrspace(3)*
  store i32 %430, i32 addrspace(3)* %432, align 4, !tbaa !5
  %433 = add nsw i32 %425, %1
  %434 = add nsw i32 %433, %4
  %435 = sext i32 %434 to i64
  %436 = getelementptr inbounds float, float addrspace(1)* %0, i64 %435
  %437 = bitcast float addrspace(1)* %436 to i32 addrspace(1)*
  %438 = load i32, i32 addrspace(1)* %437, align 4, !tbaa !5
  %439 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 53, i32 %4
  %440 = bitcast float addrspace(3)* %439 to i32 addrspace(3)*
  store i32 %438, i32 addrspace(3)* %440, align 4, !tbaa !5
  %441 = add nsw i32 %433, %1
  %442 = add nsw i32 %441, %4
  %443 = sext i32 %442 to i64
  %444 = getelementptr inbounds float, float addrspace(1)* %0, i64 %443
  %445 = bitcast float addrspace(1)* %444 to i32 addrspace(1)*
  %446 = load i32, i32 addrspace(1)* %445, align 4, !tbaa !5
  %447 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 54, i32 %4
  %448 = bitcast float addrspace(3)* %447 to i32 addrspace(3)*
  store i32 %446, i32 addrspace(3)* %448, align 4, !tbaa !5
  %449 = add nsw i32 %441, %1
  %450 = add nsw i32 %449, %4
  %451 = sext i32 %450 to i64
  %452 = getelementptr inbounds float, float addrspace(1)* %0, i64 %451
  %453 = bitcast float addrspace(1)* %452 to i32 addrspace(1)*
  %454 = load i32, i32 addrspace(1)* %453, align 4, !tbaa !5
  %455 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 55, i32 %4
  %456 = bitcast float addrspace(3)* %455 to i32 addrspace(3)*
  store i32 %454, i32 addrspace(3)* %456, align 4, !tbaa !5
  %457 = add nsw i32 %449, %1
  %458 = add nsw i32 %457, %4
  %459 = sext i32 %458 to i64
  %460 = getelementptr inbounds float, float addrspace(1)* %0, i64 %459
  %461 = bitcast float addrspace(1)* %460 to i32 addrspace(1)*
  %462 = load i32, i32 addrspace(1)* %461, align 4, !tbaa !5
  %463 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 56, i32 %4
  %464 = bitcast float addrspace(3)* %463 to i32 addrspace(3)*
  store i32 %462, i32 addrspace(3)* %464, align 4, !tbaa !5
  %465 = add nsw i32 %457, %1
  %466 = add nsw i32 %465, %4
  %467 = sext i32 %466 to i64
  %468 = getelementptr inbounds float, float addrspace(1)* %0, i64 %467
  %469 = bitcast float addrspace(1)* %468 to i32 addrspace(1)*
  %470 = load i32, i32 addrspace(1)* %469, align 4, !tbaa !5
  %471 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 57, i32 %4
  %472 = bitcast float addrspace(3)* %471 to i32 addrspace(3)*
  store i32 %470, i32 addrspace(3)* %472, align 4, !tbaa !5
  %473 = add nsw i32 %465, %1
  %474 = add nsw i32 %473, %4
  %475 = sext i32 %474 to i64
  %476 = getelementptr inbounds float, float addrspace(1)* %0, i64 %475
  %477 = bitcast float addrspace(1)* %476 to i32 addrspace(1)*
  %478 = load i32, i32 addrspace(1)* %477, align 4, !tbaa !5
  %479 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 58, i32 %4
  %480 = bitcast float addrspace(3)* %479 to i32 addrspace(3)*
  store i32 %478, i32 addrspace(3)* %480, align 4, !tbaa !5
  %481 = add nsw i32 %473, %1
  %482 = add nsw i32 %481, %4
  %483 = sext i32 %482 to i64
  %484 = getelementptr inbounds float, float addrspace(1)* %0, i64 %483
  %485 = bitcast float addrspace(1)* %484 to i32 addrspace(1)*
  %486 = load i32, i32 addrspace(1)* %485, align 4, !tbaa !5
  %487 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 59, i32 %4
  %488 = bitcast float addrspace(3)* %487 to i32 addrspace(3)*
  store i32 %486, i32 addrspace(3)* %488, align 4, !tbaa !5
  %489 = add nsw i32 %481, %1
  %490 = add nsw i32 %489, %4
  %491 = sext i32 %490 to i64
  %492 = getelementptr inbounds float, float addrspace(1)* %0, i64 %491
  %493 = bitcast float addrspace(1)* %492 to i32 addrspace(1)*
  %494 = load i32, i32 addrspace(1)* %493, align 4, !tbaa !5
  %495 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 60, i32 %4
  %496 = bitcast float addrspace(3)* %495 to i32 addrspace(3)*
  store i32 %494, i32 addrspace(3)* %496, align 4, !tbaa !5
  %497 = add nsw i32 %489, %1
  %498 = add nsw i32 %497, %4
  %499 = sext i32 %498 to i64
  %500 = getelementptr inbounds float, float addrspace(1)* %0, i64 %499
  %501 = bitcast float addrspace(1)* %500 to i32 addrspace(1)*
  %502 = load i32, i32 addrspace(1)* %501, align 4, !tbaa !5
  %503 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 61, i32 %4
  %504 = bitcast float addrspace(3)* %503 to i32 addrspace(3)*
  store i32 %502, i32 addrspace(3)* %504, align 4, !tbaa !5
  %505 = add nsw i32 %497, %1
  %506 = add nsw i32 %505, %4
  %507 = sext i32 %506 to i64
  %508 = getelementptr inbounds float, float addrspace(1)* %0, i64 %507
  %509 = bitcast float addrspace(1)* %508 to i32 addrspace(1)*
  %510 = load i32, i32 addrspace(1)* %509, align 4, !tbaa !5
  %511 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 62, i32 %4
  %512 = bitcast float addrspace(3)* %511 to i32 addrspace(3)*
  store i32 %510, i32 addrspace(3)* %512, align 4, !tbaa !5
  %513 = add nsw i32 %505, %1
  %514 = add nsw i32 %513, %4
  %515 = sext i32 %514 to i64
  %516 = getelementptr inbounds float, float addrspace(1)* %0, i64 %515
  %517 = bitcast float addrspace(1)* %516 to i32 addrspace(1)*
  %518 = load i32, i32 addrspace(1)* %517, align 4, !tbaa !5
  %519 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 63, i32 %4
  %520 = bitcast float addrspace(3)* %519 to i32 addrspace(3)*
  store i32 %518, i32 addrspace(3)* %520, align 4, !tbaa !5
  %521 = tail call i32 @llvm.amdgcn.workgroup.id.x() #3
  %522 = zext i32 %521 to i64
  %523 = shl nuw nsw i64 %522, 7
  %524 = add nuw nsw i64 %5, 128
  %525 = add nuw nsw i64 %524, %523
  br label %526

526:                                              ; preds = %526, %7
  %527 = phi i32 [ %9, %7 ], [ %671, %526 ]
  %528 = phi i32 [ 0, %7 ], [ %672, %526 ]
  %529 = sext i32 %527 to i64
  %530 = add nsw i64 %525, %529
  %531 = getelementptr inbounds float, float addrspace(1)* %0, i64 %530
  %532 = bitcast float addrspace(1)* %531 to i32 addrspace(1)*
  %533 = load i32, i32 addrspace(1)* %532, align 4, !tbaa !5
  %534 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %528, i32 %4
  %535 = bitcast float addrspace(3)* %534 to i32 addrspace(3)*
  store i32 %533, i32 addrspace(3)* %535, align 4, !tbaa !5
  %536 = add nsw i32 %527, %1
  %537 = or i32 %528, 1
  %538 = sext i32 %536 to i64
  %539 = add nsw i64 %525, %538
  %540 = getelementptr inbounds float, float addrspace(1)* %0, i64 %539
  %541 = bitcast float addrspace(1)* %540 to i32 addrspace(1)*
  %542 = load i32, i32 addrspace(1)* %541, align 4, !tbaa !5
  %543 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %537, i32 %4
  %544 = bitcast float addrspace(3)* %543 to i32 addrspace(3)*
  store i32 %542, i32 addrspace(3)* %544, align 4, !tbaa !5
  %545 = add nsw i32 %536, %1
  %546 = or i32 %528, 2
  %547 = sext i32 %545 to i64
  %548 = add nsw i64 %525, %547
  %549 = getelementptr inbounds float, float addrspace(1)* %0, i64 %548
  %550 = bitcast float addrspace(1)* %549 to i32 addrspace(1)*
  %551 = load i32, i32 addrspace(1)* %550, align 4, !tbaa !5
  %552 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %546, i32 %4
  %553 = bitcast float addrspace(3)* %552 to i32 addrspace(3)*
  store i32 %551, i32 addrspace(3)* %553, align 4, !tbaa !5
  %554 = add nsw i32 %545, %1
  %555 = or i32 %528, 3
  %556 = sext i32 %554 to i64
  %557 = add nsw i64 %525, %556
  %558 = getelementptr inbounds float, float addrspace(1)* %0, i64 %557
  %559 = bitcast float addrspace(1)* %558 to i32 addrspace(1)*
  %560 = load i32, i32 addrspace(1)* %559, align 4, !tbaa !5
  %561 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %555, i32 %4
  %562 = bitcast float addrspace(3)* %561 to i32 addrspace(3)*
  store i32 %560, i32 addrspace(3)* %562, align 4, !tbaa !5
  %563 = add nsw i32 %554, %1
  %564 = or i32 %528, 4
  %565 = sext i32 %563 to i64
  %566 = add nsw i64 %525, %565
  %567 = getelementptr inbounds float, float addrspace(1)* %0, i64 %566
  %568 = bitcast float addrspace(1)* %567 to i32 addrspace(1)*
  %569 = load i32, i32 addrspace(1)* %568, align 4, !tbaa !5
  %570 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %564, i32 %4
  %571 = bitcast float addrspace(3)* %570 to i32 addrspace(3)*
  store i32 %569, i32 addrspace(3)* %571, align 4, !tbaa !5
  %572 = add nsw i32 %563, %1
  %573 = or i32 %528, 5
  %574 = sext i32 %572 to i64
  %575 = add nsw i64 %525, %574
  %576 = getelementptr inbounds float, float addrspace(1)* %0, i64 %575
  %577 = bitcast float addrspace(1)* %576 to i32 addrspace(1)*
  %578 = load i32, i32 addrspace(1)* %577, align 4, !tbaa !5
  %579 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %573, i32 %4
  %580 = bitcast float addrspace(3)* %579 to i32 addrspace(3)*
  store i32 %578, i32 addrspace(3)* %580, align 4, !tbaa !5
  %581 = add nsw i32 %572, %1
  %582 = or i32 %528, 6
  %583 = sext i32 %581 to i64
  %584 = add nsw i64 %525, %583
  %585 = getelementptr inbounds float, float addrspace(1)* %0, i64 %584
  %586 = bitcast float addrspace(1)* %585 to i32 addrspace(1)*
  %587 = load i32, i32 addrspace(1)* %586, align 4, !tbaa !5
  %588 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %582, i32 %4
  %589 = bitcast float addrspace(3)* %588 to i32 addrspace(3)*
  store i32 %587, i32 addrspace(3)* %589, align 4, !tbaa !5
  %590 = add nsw i32 %581, %1
  %591 = or i32 %528, 7
  %592 = sext i32 %590 to i64
  %593 = add nsw i64 %525, %592
  %594 = getelementptr inbounds float, float addrspace(1)* %0, i64 %593
  %595 = bitcast float addrspace(1)* %594 to i32 addrspace(1)*
  %596 = load i32, i32 addrspace(1)* %595, align 4, !tbaa !5
  %597 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %591, i32 %4
  %598 = bitcast float addrspace(3)* %597 to i32 addrspace(3)*
  store i32 %596, i32 addrspace(3)* %598, align 4, !tbaa !5
  %599 = add nsw i32 %590, %1
  %600 = or i32 %528, 8
  %601 = sext i32 %599 to i64
  %602 = add nsw i64 %525, %601
  %603 = getelementptr inbounds float, float addrspace(1)* %0, i64 %602
  %604 = bitcast float addrspace(1)* %603 to i32 addrspace(1)*
  %605 = load i32, i32 addrspace(1)* %604, align 4, !tbaa !5
  %606 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %600, i32 %4
  %607 = bitcast float addrspace(3)* %606 to i32 addrspace(3)*
  store i32 %605, i32 addrspace(3)* %607, align 4, !tbaa !5
  %608 = add nsw i32 %599, %1
  %609 = or i32 %528, 9
  %610 = sext i32 %608 to i64
  %611 = add nsw i64 %525, %610
  %612 = getelementptr inbounds float, float addrspace(1)* %0, i64 %611
  %613 = bitcast float addrspace(1)* %612 to i32 addrspace(1)*
  %614 = load i32, i32 addrspace(1)* %613, align 4, !tbaa !5
  %615 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %609, i32 %4
  %616 = bitcast float addrspace(3)* %615 to i32 addrspace(3)*
  store i32 %614, i32 addrspace(3)* %616, align 4, !tbaa !5
  %617 = add nsw i32 %608, %1
  %618 = or i32 %528, 10
  %619 = sext i32 %617 to i64
  %620 = add nsw i64 %525, %619
  %621 = getelementptr inbounds float, float addrspace(1)* %0, i64 %620
  %622 = bitcast float addrspace(1)* %621 to i32 addrspace(1)*
  %623 = load i32, i32 addrspace(1)* %622, align 4, !tbaa !5
  %624 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %618, i32 %4
  %625 = bitcast float addrspace(3)* %624 to i32 addrspace(3)*
  store i32 %623, i32 addrspace(3)* %625, align 4, !tbaa !5
  %626 = add nsw i32 %617, %1
  %627 = or i32 %528, 11
  %628 = sext i32 %626 to i64
  %629 = add nsw i64 %525, %628
  %630 = getelementptr inbounds float, float addrspace(1)* %0, i64 %629
  %631 = bitcast float addrspace(1)* %630 to i32 addrspace(1)*
  %632 = load i32, i32 addrspace(1)* %631, align 4, !tbaa !5
  %633 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %627, i32 %4
  %634 = bitcast float addrspace(3)* %633 to i32 addrspace(3)*
  store i32 %632, i32 addrspace(3)* %634, align 4, !tbaa !5
  %635 = add nsw i32 %626, %1
  %636 = or i32 %528, 12
  %637 = sext i32 %635 to i64
  %638 = add nsw i64 %525, %637
  %639 = getelementptr inbounds float, float addrspace(1)* %0, i64 %638
  %640 = bitcast float addrspace(1)* %639 to i32 addrspace(1)*
  %641 = load i32, i32 addrspace(1)* %640, align 4, !tbaa !5
  %642 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %636, i32 %4
  %643 = bitcast float addrspace(3)* %642 to i32 addrspace(3)*
  store i32 %641, i32 addrspace(3)* %643, align 4, !tbaa !5
  %644 = add nsw i32 %635, %1
  %645 = or i32 %528, 13
  %646 = sext i32 %644 to i64
  %647 = add nsw i64 %525, %646
  %648 = getelementptr inbounds float, float addrspace(1)* %0, i64 %647
  %649 = bitcast float addrspace(1)* %648 to i32 addrspace(1)*
  %650 = load i32, i32 addrspace(1)* %649, align 4, !tbaa !5
  %651 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %645, i32 %4
  %652 = bitcast float addrspace(3)* %651 to i32 addrspace(3)*
  store i32 %650, i32 addrspace(3)* %652, align 4, !tbaa !5
  %653 = add nsw i32 %644, %1
  %654 = or i32 %528, 14
  %655 = sext i32 %653 to i64
  %656 = add nsw i64 %525, %655
  %657 = getelementptr inbounds float, float addrspace(1)* %0, i64 %656
  %658 = bitcast float addrspace(1)* %657 to i32 addrspace(1)*
  %659 = load i32, i32 addrspace(1)* %658, align 4, !tbaa !5
  %660 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %654, i32 %4
  %661 = bitcast float addrspace(3)* %660 to i32 addrspace(3)*
  store i32 %659, i32 addrspace(3)* %661, align 4, !tbaa !5
  %662 = add nsw i32 %653, %1
  %663 = or i32 %528, 15
  %664 = sext i32 %662 to i64
  %665 = add nsw i64 %525, %664
  %666 = getelementptr inbounds float, float addrspace(1)* %0, i64 %665
  %667 = bitcast float addrspace(1)* %666 to i32 addrspace(1)*
  %668 = load i32, i32 addrspace(1)* %667, align 4, !tbaa !5
  %669 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %663, i32 %4
  %670 = bitcast float addrspace(3)* %669 to i32 addrspace(3)*
  store i32 %668, i32 addrspace(3)* %670, align 4, !tbaa !5
  %671 = add nsw i32 %662, %1
  %672 = add nuw nsw i32 %528, 16
  %673 = icmp eq i32 %672, 128
  br i1 %673, label %1344, label %526, !llvm.loop !18

674:                                              ; preds = %3
  %675 = add nsw i32 %4, -128
  %676 = add nsw i32 %2, 64
  %677 = mul nsw i32 %676, %1
  %678 = add nsw i32 %677, %2
  %679 = add nsw i32 %678, %675
  %680 = sext i32 %679 to i64
  %681 = getelementptr inbounds float, float addrspace(1)* %0, i64 %680
  %682 = bitcast float addrspace(1)* %681 to i32 addrspace(1)*
  %683 = load i32, i32 addrspace(1)* %682, align 4, !tbaa !5
  %684 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 64, i32 %675
  %685 = bitcast float addrspace(3)* %684 to i32 addrspace(3)*
  store i32 %683, i32 addrspace(3)* %685, align 4, !tbaa !5
  %686 = add nsw i32 %678, %1
  %687 = add nsw i32 %686, %675
  %688 = sext i32 %687 to i64
  %689 = getelementptr inbounds float, float addrspace(1)* %0, i64 %688
  %690 = bitcast float addrspace(1)* %689 to i32 addrspace(1)*
  %691 = load i32, i32 addrspace(1)* %690, align 4, !tbaa !5
  %692 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 65, i32 %675
  %693 = bitcast float addrspace(3)* %692 to i32 addrspace(3)*
  store i32 %691, i32 addrspace(3)* %693, align 4, !tbaa !5
  %694 = add nsw i32 %686, %1
  %695 = add nsw i32 %694, %675
  %696 = sext i32 %695 to i64
  %697 = getelementptr inbounds float, float addrspace(1)* %0, i64 %696
  %698 = bitcast float addrspace(1)* %697 to i32 addrspace(1)*
  %699 = load i32, i32 addrspace(1)* %698, align 4, !tbaa !5
  %700 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 66, i32 %675
  %701 = bitcast float addrspace(3)* %700 to i32 addrspace(3)*
  store i32 %699, i32 addrspace(3)* %701, align 4, !tbaa !5
  %702 = add nsw i32 %694, %1
  %703 = add nsw i32 %702, %675
  %704 = sext i32 %703 to i64
  %705 = getelementptr inbounds float, float addrspace(1)* %0, i64 %704
  %706 = bitcast float addrspace(1)* %705 to i32 addrspace(1)*
  %707 = load i32, i32 addrspace(1)* %706, align 4, !tbaa !5
  %708 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 67, i32 %675
  %709 = bitcast float addrspace(3)* %708 to i32 addrspace(3)*
  store i32 %707, i32 addrspace(3)* %709, align 4, !tbaa !5
  %710 = add nsw i32 %702, %1
  %711 = add nsw i32 %710, %675
  %712 = sext i32 %711 to i64
  %713 = getelementptr inbounds float, float addrspace(1)* %0, i64 %712
  %714 = bitcast float addrspace(1)* %713 to i32 addrspace(1)*
  %715 = load i32, i32 addrspace(1)* %714, align 4, !tbaa !5
  %716 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 68, i32 %675
  %717 = bitcast float addrspace(3)* %716 to i32 addrspace(3)*
  store i32 %715, i32 addrspace(3)* %717, align 4, !tbaa !5
  %718 = add nsw i32 %710, %1
  %719 = add nsw i32 %718, %675
  %720 = sext i32 %719 to i64
  %721 = getelementptr inbounds float, float addrspace(1)* %0, i64 %720
  %722 = bitcast float addrspace(1)* %721 to i32 addrspace(1)*
  %723 = load i32, i32 addrspace(1)* %722, align 4, !tbaa !5
  %724 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 69, i32 %675
  %725 = bitcast float addrspace(3)* %724 to i32 addrspace(3)*
  store i32 %723, i32 addrspace(3)* %725, align 4, !tbaa !5
  %726 = add nsw i32 %718, %1
  %727 = add nsw i32 %726, %675
  %728 = sext i32 %727 to i64
  %729 = getelementptr inbounds float, float addrspace(1)* %0, i64 %728
  %730 = bitcast float addrspace(1)* %729 to i32 addrspace(1)*
  %731 = load i32, i32 addrspace(1)* %730, align 4, !tbaa !5
  %732 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 70, i32 %675
  %733 = bitcast float addrspace(3)* %732 to i32 addrspace(3)*
  store i32 %731, i32 addrspace(3)* %733, align 4, !tbaa !5
  %734 = add nsw i32 %726, %1
  %735 = add nsw i32 %734, %675
  %736 = sext i32 %735 to i64
  %737 = getelementptr inbounds float, float addrspace(1)* %0, i64 %736
  %738 = bitcast float addrspace(1)* %737 to i32 addrspace(1)*
  %739 = load i32, i32 addrspace(1)* %738, align 4, !tbaa !5
  %740 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 71, i32 %675
  %741 = bitcast float addrspace(3)* %740 to i32 addrspace(3)*
  store i32 %739, i32 addrspace(3)* %741, align 4, !tbaa !5
  %742 = add nsw i32 %734, %1
  %743 = add nsw i32 %742, %675
  %744 = sext i32 %743 to i64
  %745 = getelementptr inbounds float, float addrspace(1)* %0, i64 %744
  %746 = bitcast float addrspace(1)* %745 to i32 addrspace(1)*
  %747 = load i32, i32 addrspace(1)* %746, align 4, !tbaa !5
  %748 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 72, i32 %675
  %749 = bitcast float addrspace(3)* %748 to i32 addrspace(3)*
  store i32 %747, i32 addrspace(3)* %749, align 4, !tbaa !5
  %750 = add nsw i32 %742, %1
  %751 = add nsw i32 %750, %675
  %752 = sext i32 %751 to i64
  %753 = getelementptr inbounds float, float addrspace(1)* %0, i64 %752
  %754 = bitcast float addrspace(1)* %753 to i32 addrspace(1)*
  %755 = load i32, i32 addrspace(1)* %754, align 4, !tbaa !5
  %756 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 73, i32 %675
  %757 = bitcast float addrspace(3)* %756 to i32 addrspace(3)*
  store i32 %755, i32 addrspace(3)* %757, align 4, !tbaa !5
  %758 = add nsw i32 %750, %1
  %759 = add nsw i32 %758, %675
  %760 = sext i32 %759 to i64
  %761 = getelementptr inbounds float, float addrspace(1)* %0, i64 %760
  %762 = bitcast float addrspace(1)* %761 to i32 addrspace(1)*
  %763 = load i32, i32 addrspace(1)* %762, align 4, !tbaa !5
  %764 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 74, i32 %675
  %765 = bitcast float addrspace(3)* %764 to i32 addrspace(3)*
  store i32 %763, i32 addrspace(3)* %765, align 4, !tbaa !5
  %766 = add nsw i32 %758, %1
  %767 = add nsw i32 %766, %675
  %768 = sext i32 %767 to i64
  %769 = getelementptr inbounds float, float addrspace(1)* %0, i64 %768
  %770 = bitcast float addrspace(1)* %769 to i32 addrspace(1)*
  %771 = load i32, i32 addrspace(1)* %770, align 4, !tbaa !5
  %772 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 75, i32 %675
  %773 = bitcast float addrspace(3)* %772 to i32 addrspace(3)*
  store i32 %771, i32 addrspace(3)* %773, align 4, !tbaa !5
  %774 = add nsw i32 %766, %1
  %775 = add nsw i32 %774, %675
  %776 = sext i32 %775 to i64
  %777 = getelementptr inbounds float, float addrspace(1)* %0, i64 %776
  %778 = bitcast float addrspace(1)* %777 to i32 addrspace(1)*
  %779 = load i32, i32 addrspace(1)* %778, align 4, !tbaa !5
  %780 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 76, i32 %675
  %781 = bitcast float addrspace(3)* %780 to i32 addrspace(3)*
  store i32 %779, i32 addrspace(3)* %781, align 4, !tbaa !5
  %782 = add nsw i32 %774, %1
  %783 = add nsw i32 %782, %675
  %784 = sext i32 %783 to i64
  %785 = getelementptr inbounds float, float addrspace(1)* %0, i64 %784
  %786 = bitcast float addrspace(1)* %785 to i32 addrspace(1)*
  %787 = load i32, i32 addrspace(1)* %786, align 4, !tbaa !5
  %788 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 77, i32 %675
  %789 = bitcast float addrspace(3)* %788 to i32 addrspace(3)*
  store i32 %787, i32 addrspace(3)* %789, align 4, !tbaa !5
  %790 = add nsw i32 %782, %1
  %791 = add nsw i32 %790, %675
  %792 = sext i32 %791 to i64
  %793 = getelementptr inbounds float, float addrspace(1)* %0, i64 %792
  %794 = bitcast float addrspace(1)* %793 to i32 addrspace(1)*
  %795 = load i32, i32 addrspace(1)* %794, align 4, !tbaa !5
  %796 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 78, i32 %675
  %797 = bitcast float addrspace(3)* %796 to i32 addrspace(3)*
  store i32 %795, i32 addrspace(3)* %797, align 4, !tbaa !5
  %798 = add nsw i32 %790, %1
  %799 = add nsw i32 %798, %675
  %800 = sext i32 %799 to i64
  %801 = getelementptr inbounds float, float addrspace(1)* %0, i64 %800
  %802 = bitcast float addrspace(1)* %801 to i32 addrspace(1)*
  %803 = load i32, i32 addrspace(1)* %802, align 4, !tbaa !5
  %804 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 79, i32 %675
  %805 = bitcast float addrspace(3)* %804 to i32 addrspace(3)*
  store i32 %803, i32 addrspace(3)* %805, align 4, !tbaa !5
  %806 = add nsw i32 %798, %1
  %807 = add nsw i32 %806, %675
  %808 = sext i32 %807 to i64
  %809 = getelementptr inbounds float, float addrspace(1)* %0, i64 %808
  %810 = bitcast float addrspace(1)* %809 to i32 addrspace(1)*
  %811 = load i32, i32 addrspace(1)* %810, align 4, !tbaa !5
  %812 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 80, i32 %675
  %813 = bitcast float addrspace(3)* %812 to i32 addrspace(3)*
  store i32 %811, i32 addrspace(3)* %813, align 4, !tbaa !5
  %814 = add nsw i32 %806, %1
  %815 = add nsw i32 %814, %675
  %816 = sext i32 %815 to i64
  %817 = getelementptr inbounds float, float addrspace(1)* %0, i64 %816
  %818 = bitcast float addrspace(1)* %817 to i32 addrspace(1)*
  %819 = load i32, i32 addrspace(1)* %818, align 4, !tbaa !5
  %820 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 81, i32 %675
  %821 = bitcast float addrspace(3)* %820 to i32 addrspace(3)*
  store i32 %819, i32 addrspace(3)* %821, align 4, !tbaa !5
  %822 = add nsw i32 %814, %1
  %823 = add nsw i32 %822, %675
  %824 = sext i32 %823 to i64
  %825 = getelementptr inbounds float, float addrspace(1)* %0, i64 %824
  %826 = bitcast float addrspace(1)* %825 to i32 addrspace(1)*
  %827 = load i32, i32 addrspace(1)* %826, align 4, !tbaa !5
  %828 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 82, i32 %675
  %829 = bitcast float addrspace(3)* %828 to i32 addrspace(3)*
  store i32 %827, i32 addrspace(3)* %829, align 4, !tbaa !5
  %830 = add nsw i32 %822, %1
  %831 = add nsw i32 %830, %675
  %832 = sext i32 %831 to i64
  %833 = getelementptr inbounds float, float addrspace(1)* %0, i64 %832
  %834 = bitcast float addrspace(1)* %833 to i32 addrspace(1)*
  %835 = load i32, i32 addrspace(1)* %834, align 4, !tbaa !5
  %836 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 83, i32 %675
  %837 = bitcast float addrspace(3)* %836 to i32 addrspace(3)*
  store i32 %835, i32 addrspace(3)* %837, align 4, !tbaa !5
  %838 = add nsw i32 %830, %1
  %839 = add nsw i32 %838, %675
  %840 = sext i32 %839 to i64
  %841 = getelementptr inbounds float, float addrspace(1)* %0, i64 %840
  %842 = bitcast float addrspace(1)* %841 to i32 addrspace(1)*
  %843 = load i32, i32 addrspace(1)* %842, align 4, !tbaa !5
  %844 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 84, i32 %675
  %845 = bitcast float addrspace(3)* %844 to i32 addrspace(3)*
  store i32 %843, i32 addrspace(3)* %845, align 4, !tbaa !5
  %846 = add nsw i32 %838, %1
  %847 = add nsw i32 %846, %675
  %848 = sext i32 %847 to i64
  %849 = getelementptr inbounds float, float addrspace(1)* %0, i64 %848
  %850 = bitcast float addrspace(1)* %849 to i32 addrspace(1)*
  %851 = load i32, i32 addrspace(1)* %850, align 4, !tbaa !5
  %852 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 85, i32 %675
  %853 = bitcast float addrspace(3)* %852 to i32 addrspace(3)*
  store i32 %851, i32 addrspace(3)* %853, align 4, !tbaa !5
  %854 = add nsw i32 %846, %1
  %855 = add nsw i32 %854, %675
  %856 = sext i32 %855 to i64
  %857 = getelementptr inbounds float, float addrspace(1)* %0, i64 %856
  %858 = bitcast float addrspace(1)* %857 to i32 addrspace(1)*
  %859 = load i32, i32 addrspace(1)* %858, align 4, !tbaa !5
  %860 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 86, i32 %675
  %861 = bitcast float addrspace(3)* %860 to i32 addrspace(3)*
  store i32 %859, i32 addrspace(3)* %861, align 4, !tbaa !5
  %862 = add nsw i32 %854, %1
  %863 = add nsw i32 %862, %675
  %864 = sext i32 %863 to i64
  %865 = getelementptr inbounds float, float addrspace(1)* %0, i64 %864
  %866 = bitcast float addrspace(1)* %865 to i32 addrspace(1)*
  %867 = load i32, i32 addrspace(1)* %866, align 4, !tbaa !5
  %868 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 87, i32 %675
  %869 = bitcast float addrspace(3)* %868 to i32 addrspace(3)*
  store i32 %867, i32 addrspace(3)* %869, align 4, !tbaa !5
  %870 = add nsw i32 %862, %1
  %871 = add nsw i32 %870, %675
  %872 = sext i32 %871 to i64
  %873 = getelementptr inbounds float, float addrspace(1)* %0, i64 %872
  %874 = bitcast float addrspace(1)* %873 to i32 addrspace(1)*
  %875 = load i32, i32 addrspace(1)* %874, align 4, !tbaa !5
  %876 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 88, i32 %675
  %877 = bitcast float addrspace(3)* %876 to i32 addrspace(3)*
  store i32 %875, i32 addrspace(3)* %877, align 4, !tbaa !5
  %878 = add nsw i32 %870, %1
  %879 = add nsw i32 %878, %675
  %880 = sext i32 %879 to i64
  %881 = getelementptr inbounds float, float addrspace(1)* %0, i64 %880
  %882 = bitcast float addrspace(1)* %881 to i32 addrspace(1)*
  %883 = load i32, i32 addrspace(1)* %882, align 4, !tbaa !5
  %884 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 89, i32 %675
  %885 = bitcast float addrspace(3)* %884 to i32 addrspace(3)*
  store i32 %883, i32 addrspace(3)* %885, align 4, !tbaa !5
  %886 = add nsw i32 %878, %1
  %887 = add nsw i32 %886, %675
  %888 = sext i32 %887 to i64
  %889 = getelementptr inbounds float, float addrspace(1)* %0, i64 %888
  %890 = bitcast float addrspace(1)* %889 to i32 addrspace(1)*
  %891 = load i32, i32 addrspace(1)* %890, align 4, !tbaa !5
  %892 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 90, i32 %675
  %893 = bitcast float addrspace(3)* %892 to i32 addrspace(3)*
  store i32 %891, i32 addrspace(3)* %893, align 4, !tbaa !5
  %894 = add nsw i32 %886, %1
  %895 = add nsw i32 %894, %675
  %896 = sext i32 %895 to i64
  %897 = getelementptr inbounds float, float addrspace(1)* %0, i64 %896
  %898 = bitcast float addrspace(1)* %897 to i32 addrspace(1)*
  %899 = load i32, i32 addrspace(1)* %898, align 4, !tbaa !5
  %900 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 91, i32 %675
  %901 = bitcast float addrspace(3)* %900 to i32 addrspace(3)*
  store i32 %899, i32 addrspace(3)* %901, align 4, !tbaa !5
  %902 = add nsw i32 %894, %1
  %903 = add nsw i32 %902, %675
  %904 = sext i32 %903 to i64
  %905 = getelementptr inbounds float, float addrspace(1)* %0, i64 %904
  %906 = bitcast float addrspace(1)* %905 to i32 addrspace(1)*
  %907 = load i32, i32 addrspace(1)* %906, align 4, !tbaa !5
  %908 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 92, i32 %675
  %909 = bitcast float addrspace(3)* %908 to i32 addrspace(3)*
  store i32 %907, i32 addrspace(3)* %909, align 4, !tbaa !5
  %910 = add nsw i32 %902, %1
  %911 = add nsw i32 %910, %675
  %912 = sext i32 %911 to i64
  %913 = getelementptr inbounds float, float addrspace(1)* %0, i64 %912
  %914 = bitcast float addrspace(1)* %913 to i32 addrspace(1)*
  %915 = load i32, i32 addrspace(1)* %914, align 4, !tbaa !5
  %916 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 93, i32 %675
  %917 = bitcast float addrspace(3)* %916 to i32 addrspace(3)*
  store i32 %915, i32 addrspace(3)* %917, align 4, !tbaa !5
  %918 = add nsw i32 %910, %1
  %919 = add nsw i32 %918, %675
  %920 = sext i32 %919 to i64
  %921 = getelementptr inbounds float, float addrspace(1)* %0, i64 %920
  %922 = bitcast float addrspace(1)* %921 to i32 addrspace(1)*
  %923 = load i32, i32 addrspace(1)* %922, align 4, !tbaa !5
  %924 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 94, i32 %675
  %925 = bitcast float addrspace(3)* %924 to i32 addrspace(3)*
  store i32 %923, i32 addrspace(3)* %925, align 4, !tbaa !5
  %926 = add nsw i32 %918, %1
  %927 = add nsw i32 %926, %675
  %928 = sext i32 %927 to i64
  %929 = getelementptr inbounds float, float addrspace(1)* %0, i64 %928
  %930 = bitcast float addrspace(1)* %929 to i32 addrspace(1)*
  %931 = load i32, i32 addrspace(1)* %930, align 4, !tbaa !5
  %932 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 95, i32 %675
  %933 = bitcast float addrspace(3)* %932 to i32 addrspace(3)*
  store i32 %931, i32 addrspace(3)* %933, align 4, !tbaa !5
  %934 = add nsw i32 %926, %1
  %935 = add nsw i32 %934, %675
  %936 = sext i32 %935 to i64
  %937 = getelementptr inbounds float, float addrspace(1)* %0, i64 %936
  %938 = bitcast float addrspace(1)* %937 to i32 addrspace(1)*
  %939 = load i32, i32 addrspace(1)* %938, align 4, !tbaa !5
  %940 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 96, i32 %675
  %941 = bitcast float addrspace(3)* %940 to i32 addrspace(3)*
  store i32 %939, i32 addrspace(3)* %941, align 4, !tbaa !5
  %942 = add nsw i32 %934, %1
  %943 = add nsw i32 %942, %675
  %944 = sext i32 %943 to i64
  %945 = getelementptr inbounds float, float addrspace(1)* %0, i64 %944
  %946 = bitcast float addrspace(1)* %945 to i32 addrspace(1)*
  %947 = load i32, i32 addrspace(1)* %946, align 4, !tbaa !5
  %948 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 97, i32 %675
  %949 = bitcast float addrspace(3)* %948 to i32 addrspace(3)*
  store i32 %947, i32 addrspace(3)* %949, align 4, !tbaa !5
  %950 = add nsw i32 %942, %1
  %951 = add nsw i32 %950, %675
  %952 = sext i32 %951 to i64
  %953 = getelementptr inbounds float, float addrspace(1)* %0, i64 %952
  %954 = bitcast float addrspace(1)* %953 to i32 addrspace(1)*
  %955 = load i32, i32 addrspace(1)* %954, align 4, !tbaa !5
  %956 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 98, i32 %675
  %957 = bitcast float addrspace(3)* %956 to i32 addrspace(3)*
  store i32 %955, i32 addrspace(3)* %957, align 4, !tbaa !5
  %958 = add nsw i32 %950, %1
  %959 = add nsw i32 %958, %675
  %960 = sext i32 %959 to i64
  %961 = getelementptr inbounds float, float addrspace(1)* %0, i64 %960
  %962 = bitcast float addrspace(1)* %961 to i32 addrspace(1)*
  %963 = load i32, i32 addrspace(1)* %962, align 4, !tbaa !5
  %964 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 99, i32 %675
  %965 = bitcast float addrspace(3)* %964 to i32 addrspace(3)*
  store i32 %963, i32 addrspace(3)* %965, align 4, !tbaa !5
  %966 = add nsw i32 %958, %1
  %967 = add nsw i32 %966, %675
  %968 = sext i32 %967 to i64
  %969 = getelementptr inbounds float, float addrspace(1)* %0, i64 %968
  %970 = bitcast float addrspace(1)* %969 to i32 addrspace(1)*
  %971 = load i32, i32 addrspace(1)* %970, align 4, !tbaa !5
  %972 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 100, i32 %675
  %973 = bitcast float addrspace(3)* %972 to i32 addrspace(3)*
  store i32 %971, i32 addrspace(3)* %973, align 4, !tbaa !5
  %974 = add nsw i32 %966, %1
  %975 = add nsw i32 %974, %675
  %976 = sext i32 %975 to i64
  %977 = getelementptr inbounds float, float addrspace(1)* %0, i64 %976
  %978 = bitcast float addrspace(1)* %977 to i32 addrspace(1)*
  %979 = load i32, i32 addrspace(1)* %978, align 4, !tbaa !5
  %980 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 101, i32 %675
  %981 = bitcast float addrspace(3)* %980 to i32 addrspace(3)*
  store i32 %979, i32 addrspace(3)* %981, align 4, !tbaa !5
  %982 = add nsw i32 %974, %1
  %983 = add nsw i32 %982, %675
  %984 = sext i32 %983 to i64
  %985 = getelementptr inbounds float, float addrspace(1)* %0, i64 %984
  %986 = bitcast float addrspace(1)* %985 to i32 addrspace(1)*
  %987 = load i32, i32 addrspace(1)* %986, align 4, !tbaa !5
  %988 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 102, i32 %675
  %989 = bitcast float addrspace(3)* %988 to i32 addrspace(3)*
  store i32 %987, i32 addrspace(3)* %989, align 4, !tbaa !5
  %990 = add nsw i32 %982, %1
  %991 = add nsw i32 %990, %675
  %992 = sext i32 %991 to i64
  %993 = getelementptr inbounds float, float addrspace(1)* %0, i64 %992
  %994 = bitcast float addrspace(1)* %993 to i32 addrspace(1)*
  %995 = load i32, i32 addrspace(1)* %994, align 4, !tbaa !5
  %996 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 103, i32 %675
  %997 = bitcast float addrspace(3)* %996 to i32 addrspace(3)*
  store i32 %995, i32 addrspace(3)* %997, align 4, !tbaa !5
  %998 = add nsw i32 %990, %1
  %999 = add nsw i32 %998, %675
  %1000 = sext i32 %999 to i64
  %1001 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1000
  %1002 = bitcast float addrspace(1)* %1001 to i32 addrspace(1)*
  %1003 = load i32, i32 addrspace(1)* %1002, align 4, !tbaa !5
  %1004 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 104, i32 %675
  %1005 = bitcast float addrspace(3)* %1004 to i32 addrspace(3)*
  store i32 %1003, i32 addrspace(3)* %1005, align 4, !tbaa !5
  %1006 = add nsw i32 %998, %1
  %1007 = add nsw i32 %1006, %675
  %1008 = sext i32 %1007 to i64
  %1009 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1008
  %1010 = bitcast float addrspace(1)* %1009 to i32 addrspace(1)*
  %1011 = load i32, i32 addrspace(1)* %1010, align 4, !tbaa !5
  %1012 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 105, i32 %675
  %1013 = bitcast float addrspace(3)* %1012 to i32 addrspace(3)*
  store i32 %1011, i32 addrspace(3)* %1013, align 4, !tbaa !5
  %1014 = add nsw i32 %1006, %1
  %1015 = add nsw i32 %1014, %675
  %1016 = sext i32 %1015 to i64
  %1017 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1016
  %1018 = bitcast float addrspace(1)* %1017 to i32 addrspace(1)*
  %1019 = load i32, i32 addrspace(1)* %1018, align 4, !tbaa !5
  %1020 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 106, i32 %675
  %1021 = bitcast float addrspace(3)* %1020 to i32 addrspace(3)*
  store i32 %1019, i32 addrspace(3)* %1021, align 4, !tbaa !5
  %1022 = add nsw i32 %1014, %1
  %1023 = add nsw i32 %1022, %675
  %1024 = sext i32 %1023 to i64
  %1025 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1024
  %1026 = bitcast float addrspace(1)* %1025 to i32 addrspace(1)*
  %1027 = load i32, i32 addrspace(1)* %1026, align 4, !tbaa !5
  %1028 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 107, i32 %675
  %1029 = bitcast float addrspace(3)* %1028 to i32 addrspace(3)*
  store i32 %1027, i32 addrspace(3)* %1029, align 4, !tbaa !5
  %1030 = add nsw i32 %1022, %1
  %1031 = add nsw i32 %1030, %675
  %1032 = sext i32 %1031 to i64
  %1033 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1032
  %1034 = bitcast float addrspace(1)* %1033 to i32 addrspace(1)*
  %1035 = load i32, i32 addrspace(1)* %1034, align 4, !tbaa !5
  %1036 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 108, i32 %675
  %1037 = bitcast float addrspace(3)* %1036 to i32 addrspace(3)*
  store i32 %1035, i32 addrspace(3)* %1037, align 4, !tbaa !5
  %1038 = add nsw i32 %1030, %1
  %1039 = add nsw i32 %1038, %675
  %1040 = sext i32 %1039 to i64
  %1041 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1040
  %1042 = bitcast float addrspace(1)* %1041 to i32 addrspace(1)*
  %1043 = load i32, i32 addrspace(1)* %1042, align 4, !tbaa !5
  %1044 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 109, i32 %675
  %1045 = bitcast float addrspace(3)* %1044 to i32 addrspace(3)*
  store i32 %1043, i32 addrspace(3)* %1045, align 4, !tbaa !5
  %1046 = add nsw i32 %1038, %1
  %1047 = add nsw i32 %1046, %675
  %1048 = sext i32 %1047 to i64
  %1049 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1048
  %1050 = bitcast float addrspace(1)* %1049 to i32 addrspace(1)*
  %1051 = load i32, i32 addrspace(1)* %1050, align 4, !tbaa !5
  %1052 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 110, i32 %675
  %1053 = bitcast float addrspace(3)* %1052 to i32 addrspace(3)*
  store i32 %1051, i32 addrspace(3)* %1053, align 4, !tbaa !5
  %1054 = add nsw i32 %1046, %1
  %1055 = add nsw i32 %1054, %675
  %1056 = sext i32 %1055 to i64
  %1057 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1056
  %1058 = bitcast float addrspace(1)* %1057 to i32 addrspace(1)*
  %1059 = load i32, i32 addrspace(1)* %1058, align 4, !tbaa !5
  %1060 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 111, i32 %675
  %1061 = bitcast float addrspace(3)* %1060 to i32 addrspace(3)*
  store i32 %1059, i32 addrspace(3)* %1061, align 4, !tbaa !5
  %1062 = add nsw i32 %1054, %1
  %1063 = add nsw i32 %1062, %675
  %1064 = sext i32 %1063 to i64
  %1065 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1064
  %1066 = bitcast float addrspace(1)* %1065 to i32 addrspace(1)*
  %1067 = load i32, i32 addrspace(1)* %1066, align 4, !tbaa !5
  %1068 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 112, i32 %675
  %1069 = bitcast float addrspace(3)* %1068 to i32 addrspace(3)*
  store i32 %1067, i32 addrspace(3)* %1069, align 4, !tbaa !5
  %1070 = add nsw i32 %1062, %1
  %1071 = add nsw i32 %1070, %675
  %1072 = sext i32 %1071 to i64
  %1073 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1072
  %1074 = bitcast float addrspace(1)* %1073 to i32 addrspace(1)*
  %1075 = load i32, i32 addrspace(1)* %1074, align 4, !tbaa !5
  %1076 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 113, i32 %675
  %1077 = bitcast float addrspace(3)* %1076 to i32 addrspace(3)*
  store i32 %1075, i32 addrspace(3)* %1077, align 4, !tbaa !5
  %1078 = add nsw i32 %1070, %1
  %1079 = add nsw i32 %1078, %675
  %1080 = sext i32 %1079 to i64
  %1081 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1080
  %1082 = bitcast float addrspace(1)* %1081 to i32 addrspace(1)*
  %1083 = load i32, i32 addrspace(1)* %1082, align 4, !tbaa !5
  %1084 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 114, i32 %675
  %1085 = bitcast float addrspace(3)* %1084 to i32 addrspace(3)*
  store i32 %1083, i32 addrspace(3)* %1085, align 4, !tbaa !5
  %1086 = add nsw i32 %1078, %1
  %1087 = add nsw i32 %1086, %675
  %1088 = sext i32 %1087 to i64
  %1089 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1088
  %1090 = bitcast float addrspace(1)* %1089 to i32 addrspace(1)*
  %1091 = load i32, i32 addrspace(1)* %1090, align 4, !tbaa !5
  %1092 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 115, i32 %675
  %1093 = bitcast float addrspace(3)* %1092 to i32 addrspace(3)*
  store i32 %1091, i32 addrspace(3)* %1093, align 4, !tbaa !5
  %1094 = add nsw i32 %1086, %1
  %1095 = add nsw i32 %1094, %675
  %1096 = sext i32 %1095 to i64
  %1097 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1096
  %1098 = bitcast float addrspace(1)* %1097 to i32 addrspace(1)*
  %1099 = load i32, i32 addrspace(1)* %1098, align 4, !tbaa !5
  %1100 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 116, i32 %675
  %1101 = bitcast float addrspace(3)* %1100 to i32 addrspace(3)*
  store i32 %1099, i32 addrspace(3)* %1101, align 4, !tbaa !5
  %1102 = add nsw i32 %1094, %1
  %1103 = add nsw i32 %1102, %675
  %1104 = sext i32 %1103 to i64
  %1105 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1104
  %1106 = bitcast float addrspace(1)* %1105 to i32 addrspace(1)*
  %1107 = load i32, i32 addrspace(1)* %1106, align 4, !tbaa !5
  %1108 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 117, i32 %675
  %1109 = bitcast float addrspace(3)* %1108 to i32 addrspace(3)*
  store i32 %1107, i32 addrspace(3)* %1109, align 4, !tbaa !5
  %1110 = add nsw i32 %1102, %1
  %1111 = add nsw i32 %1110, %675
  %1112 = sext i32 %1111 to i64
  %1113 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1112
  %1114 = bitcast float addrspace(1)* %1113 to i32 addrspace(1)*
  %1115 = load i32, i32 addrspace(1)* %1114, align 4, !tbaa !5
  %1116 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 118, i32 %675
  %1117 = bitcast float addrspace(3)* %1116 to i32 addrspace(3)*
  store i32 %1115, i32 addrspace(3)* %1117, align 4, !tbaa !5
  %1118 = add nsw i32 %1110, %1
  %1119 = add nsw i32 %1118, %675
  %1120 = sext i32 %1119 to i64
  %1121 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1120
  %1122 = bitcast float addrspace(1)* %1121 to i32 addrspace(1)*
  %1123 = load i32, i32 addrspace(1)* %1122, align 4, !tbaa !5
  %1124 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 119, i32 %675
  %1125 = bitcast float addrspace(3)* %1124 to i32 addrspace(3)*
  store i32 %1123, i32 addrspace(3)* %1125, align 4, !tbaa !5
  %1126 = add nsw i32 %1118, %1
  %1127 = add nsw i32 %1126, %675
  %1128 = sext i32 %1127 to i64
  %1129 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1128
  %1130 = bitcast float addrspace(1)* %1129 to i32 addrspace(1)*
  %1131 = load i32, i32 addrspace(1)* %1130, align 4, !tbaa !5
  %1132 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 120, i32 %675
  %1133 = bitcast float addrspace(3)* %1132 to i32 addrspace(3)*
  store i32 %1131, i32 addrspace(3)* %1133, align 4, !tbaa !5
  %1134 = add nsw i32 %1126, %1
  %1135 = add nsw i32 %1134, %675
  %1136 = sext i32 %1135 to i64
  %1137 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1136
  %1138 = bitcast float addrspace(1)* %1137 to i32 addrspace(1)*
  %1139 = load i32, i32 addrspace(1)* %1138, align 4, !tbaa !5
  %1140 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 121, i32 %675
  %1141 = bitcast float addrspace(3)* %1140 to i32 addrspace(3)*
  store i32 %1139, i32 addrspace(3)* %1141, align 4, !tbaa !5
  %1142 = add nsw i32 %1134, %1
  %1143 = add nsw i32 %1142, %675
  %1144 = sext i32 %1143 to i64
  %1145 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1144
  %1146 = bitcast float addrspace(1)* %1145 to i32 addrspace(1)*
  %1147 = load i32, i32 addrspace(1)* %1146, align 4, !tbaa !5
  %1148 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 122, i32 %675
  %1149 = bitcast float addrspace(3)* %1148 to i32 addrspace(3)*
  store i32 %1147, i32 addrspace(3)* %1149, align 4, !tbaa !5
  %1150 = add nsw i32 %1142, %1
  %1151 = add nsw i32 %1150, %675
  %1152 = sext i32 %1151 to i64
  %1153 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1152
  %1154 = bitcast float addrspace(1)* %1153 to i32 addrspace(1)*
  %1155 = load i32, i32 addrspace(1)* %1154, align 4, !tbaa !5
  %1156 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 123, i32 %675
  %1157 = bitcast float addrspace(3)* %1156 to i32 addrspace(3)*
  store i32 %1155, i32 addrspace(3)* %1157, align 4, !tbaa !5
  %1158 = add nsw i32 %1150, %1
  %1159 = add nsw i32 %1158, %675
  %1160 = sext i32 %1159 to i64
  %1161 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1160
  %1162 = bitcast float addrspace(1)* %1161 to i32 addrspace(1)*
  %1163 = load i32, i32 addrspace(1)* %1162, align 4, !tbaa !5
  %1164 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 124, i32 %675
  %1165 = bitcast float addrspace(3)* %1164 to i32 addrspace(3)*
  store i32 %1163, i32 addrspace(3)* %1165, align 4, !tbaa !5
  %1166 = add nsw i32 %1158, %1
  %1167 = add nsw i32 %1166, %675
  %1168 = sext i32 %1167 to i64
  %1169 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1168
  %1170 = bitcast float addrspace(1)* %1169 to i32 addrspace(1)*
  %1171 = load i32, i32 addrspace(1)* %1170, align 4, !tbaa !5
  %1172 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 125, i32 %675
  %1173 = bitcast float addrspace(3)* %1172 to i32 addrspace(3)*
  store i32 %1171, i32 addrspace(3)* %1173, align 4, !tbaa !5
  %1174 = add nsw i32 %1166, %1
  %1175 = add nsw i32 %1174, %675
  %1176 = sext i32 %1175 to i64
  %1177 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1176
  %1178 = bitcast float addrspace(1)* %1177 to i32 addrspace(1)*
  %1179 = load i32, i32 addrspace(1)* %1178, align 4, !tbaa !5
  %1180 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 126, i32 %675
  %1181 = bitcast float addrspace(3)* %1180 to i32 addrspace(3)*
  store i32 %1179, i32 addrspace(3)* %1181, align 4, !tbaa !5
  %1182 = add nsw i32 %1174, %1
  %1183 = add nsw i32 %1182, %675
  %1184 = sext i32 %1183 to i64
  %1185 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1184
  %1186 = bitcast float addrspace(1)* %1185 to i32 addrspace(1)*
  %1187 = load i32, i32 addrspace(1)* %1186, align 4, !tbaa !5
  %1188 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 127, i32 %675
  %1189 = bitcast float addrspace(3)* %1188 to i32 addrspace(3)*
  store i32 %1187, i32 addrspace(3)* %1189, align 4, !tbaa !5
  %1190 = tail call i32 @llvm.amdgcn.workgroup.id.x() #3
  %1191 = shl i32 %1190, 7
  %1192 = add i32 %2, 128
  %1193 = add i32 %1192, %1191
  %1194 = mul i32 %1193, %1
  %1195 = add i32 %1194, %2
  br label %1196

1196:                                             ; preds = %1196, %674
  %1197 = phi i32 [ %1195, %674 ], [ %1341, %1196 ]
  %1198 = phi i32 [ 0, %674 ], [ %1342, %1196 ]
  %1199 = add nsw i32 %1197, %675
  %1200 = sext i32 %1199 to i64
  %1201 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1200
  %1202 = bitcast float addrspace(1)* %1201 to i32 addrspace(1)*
  %1203 = load i32, i32 addrspace(1)* %1202, align 4, !tbaa !5
  %1204 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1198, i32 %675
  %1205 = bitcast float addrspace(3)* %1204 to i32 addrspace(3)*
  store i32 %1203, i32 addrspace(3)* %1205, align 4, !tbaa !5
  %1206 = add nsw i32 %1197, %1
  %1207 = or i32 %1198, 1
  %1208 = add nsw i32 %1206, %675
  %1209 = sext i32 %1208 to i64
  %1210 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1209
  %1211 = bitcast float addrspace(1)* %1210 to i32 addrspace(1)*
  %1212 = load i32, i32 addrspace(1)* %1211, align 4, !tbaa !5
  %1213 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1207, i32 %675
  %1214 = bitcast float addrspace(3)* %1213 to i32 addrspace(3)*
  store i32 %1212, i32 addrspace(3)* %1214, align 4, !tbaa !5
  %1215 = add nsw i32 %1206, %1
  %1216 = or i32 %1198, 2
  %1217 = add nsw i32 %1215, %675
  %1218 = sext i32 %1217 to i64
  %1219 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1218
  %1220 = bitcast float addrspace(1)* %1219 to i32 addrspace(1)*
  %1221 = load i32, i32 addrspace(1)* %1220, align 4, !tbaa !5
  %1222 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1216, i32 %675
  %1223 = bitcast float addrspace(3)* %1222 to i32 addrspace(3)*
  store i32 %1221, i32 addrspace(3)* %1223, align 4, !tbaa !5
  %1224 = add nsw i32 %1215, %1
  %1225 = or i32 %1198, 3
  %1226 = add nsw i32 %1224, %675
  %1227 = sext i32 %1226 to i64
  %1228 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1227
  %1229 = bitcast float addrspace(1)* %1228 to i32 addrspace(1)*
  %1230 = load i32, i32 addrspace(1)* %1229, align 4, !tbaa !5
  %1231 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1225, i32 %675
  %1232 = bitcast float addrspace(3)* %1231 to i32 addrspace(3)*
  store i32 %1230, i32 addrspace(3)* %1232, align 4, !tbaa !5
  %1233 = add nsw i32 %1224, %1
  %1234 = or i32 %1198, 4
  %1235 = add nsw i32 %1233, %675
  %1236 = sext i32 %1235 to i64
  %1237 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1236
  %1238 = bitcast float addrspace(1)* %1237 to i32 addrspace(1)*
  %1239 = load i32, i32 addrspace(1)* %1238, align 4, !tbaa !5
  %1240 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1234, i32 %675
  %1241 = bitcast float addrspace(3)* %1240 to i32 addrspace(3)*
  store i32 %1239, i32 addrspace(3)* %1241, align 4, !tbaa !5
  %1242 = add nsw i32 %1233, %1
  %1243 = or i32 %1198, 5
  %1244 = add nsw i32 %1242, %675
  %1245 = sext i32 %1244 to i64
  %1246 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1245
  %1247 = bitcast float addrspace(1)* %1246 to i32 addrspace(1)*
  %1248 = load i32, i32 addrspace(1)* %1247, align 4, !tbaa !5
  %1249 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1243, i32 %675
  %1250 = bitcast float addrspace(3)* %1249 to i32 addrspace(3)*
  store i32 %1248, i32 addrspace(3)* %1250, align 4, !tbaa !5
  %1251 = add nsw i32 %1242, %1
  %1252 = or i32 %1198, 6
  %1253 = add nsw i32 %1251, %675
  %1254 = sext i32 %1253 to i64
  %1255 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1254
  %1256 = bitcast float addrspace(1)* %1255 to i32 addrspace(1)*
  %1257 = load i32, i32 addrspace(1)* %1256, align 4, !tbaa !5
  %1258 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1252, i32 %675
  %1259 = bitcast float addrspace(3)* %1258 to i32 addrspace(3)*
  store i32 %1257, i32 addrspace(3)* %1259, align 4, !tbaa !5
  %1260 = add nsw i32 %1251, %1
  %1261 = or i32 %1198, 7
  %1262 = add nsw i32 %1260, %675
  %1263 = sext i32 %1262 to i64
  %1264 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1263
  %1265 = bitcast float addrspace(1)* %1264 to i32 addrspace(1)*
  %1266 = load i32, i32 addrspace(1)* %1265, align 4, !tbaa !5
  %1267 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1261, i32 %675
  %1268 = bitcast float addrspace(3)* %1267 to i32 addrspace(3)*
  store i32 %1266, i32 addrspace(3)* %1268, align 4, !tbaa !5
  %1269 = add nsw i32 %1260, %1
  %1270 = or i32 %1198, 8
  %1271 = add nsw i32 %1269, %675
  %1272 = sext i32 %1271 to i64
  %1273 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1272
  %1274 = bitcast float addrspace(1)* %1273 to i32 addrspace(1)*
  %1275 = load i32, i32 addrspace(1)* %1274, align 4, !tbaa !5
  %1276 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1270, i32 %675
  %1277 = bitcast float addrspace(3)* %1276 to i32 addrspace(3)*
  store i32 %1275, i32 addrspace(3)* %1277, align 4, !tbaa !5
  %1278 = add nsw i32 %1269, %1
  %1279 = or i32 %1198, 9
  %1280 = add nsw i32 %1278, %675
  %1281 = sext i32 %1280 to i64
  %1282 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1281
  %1283 = bitcast float addrspace(1)* %1282 to i32 addrspace(1)*
  %1284 = load i32, i32 addrspace(1)* %1283, align 4, !tbaa !5
  %1285 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1279, i32 %675
  %1286 = bitcast float addrspace(3)* %1285 to i32 addrspace(3)*
  store i32 %1284, i32 addrspace(3)* %1286, align 4, !tbaa !5
  %1287 = add nsw i32 %1278, %1
  %1288 = or i32 %1198, 10
  %1289 = add nsw i32 %1287, %675
  %1290 = sext i32 %1289 to i64
  %1291 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1290
  %1292 = bitcast float addrspace(1)* %1291 to i32 addrspace(1)*
  %1293 = load i32, i32 addrspace(1)* %1292, align 4, !tbaa !5
  %1294 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1288, i32 %675
  %1295 = bitcast float addrspace(3)* %1294 to i32 addrspace(3)*
  store i32 %1293, i32 addrspace(3)* %1295, align 4, !tbaa !5
  %1296 = add nsw i32 %1287, %1
  %1297 = or i32 %1198, 11
  %1298 = add nsw i32 %1296, %675
  %1299 = sext i32 %1298 to i64
  %1300 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1299
  %1301 = bitcast float addrspace(1)* %1300 to i32 addrspace(1)*
  %1302 = load i32, i32 addrspace(1)* %1301, align 4, !tbaa !5
  %1303 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1297, i32 %675
  %1304 = bitcast float addrspace(3)* %1303 to i32 addrspace(3)*
  store i32 %1302, i32 addrspace(3)* %1304, align 4, !tbaa !5
  %1305 = add nsw i32 %1296, %1
  %1306 = or i32 %1198, 12
  %1307 = add nsw i32 %1305, %675
  %1308 = sext i32 %1307 to i64
  %1309 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1308
  %1310 = bitcast float addrspace(1)* %1309 to i32 addrspace(1)*
  %1311 = load i32, i32 addrspace(1)* %1310, align 4, !tbaa !5
  %1312 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1306, i32 %675
  %1313 = bitcast float addrspace(3)* %1312 to i32 addrspace(3)*
  store i32 %1311, i32 addrspace(3)* %1313, align 4, !tbaa !5
  %1314 = add nsw i32 %1305, %1
  %1315 = or i32 %1198, 13
  %1316 = add nsw i32 %1314, %675
  %1317 = sext i32 %1316 to i64
  %1318 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1317
  %1319 = bitcast float addrspace(1)* %1318 to i32 addrspace(1)*
  %1320 = load i32, i32 addrspace(1)* %1319, align 4, !tbaa !5
  %1321 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1315, i32 %675
  %1322 = bitcast float addrspace(3)* %1321 to i32 addrspace(3)*
  store i32 %1320, i32 addrspace(3)* %1322, align 4, !tbaa !5
  %1323 = add nsw i32 %1314, %1
  %1324 = or i32 %1198, 14
  %1325 = add nsw i32 %1323, %675
  %1326 = sext i32 %1325 to i64
  %1327 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1326
  %1328 = bitcast float addrspace(1)* %1327 to i32 addrspace(1)*
  %1329 = load i32, i32 addrspace(1)* %1328, align 4, !tbaa !5
  %1330 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1324, i32 %675
  %1331 = bitcast float addrspace(3)* %1330 to i32 addrspace(3)*
  store i32 %1329, i32 addrspace(3)* %1331, align 4, !tbaa !5
  %1332 = add nsw i32 %1323, %1
  %1333 = or i32 %1198, 15
  %1334 = add nsw i32 %1332, %675
  %1335 = sext i32 %1334 to i64
  %1336 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1335
  %1337 = bitcast float addrspace(1)* %1336 to i32 addrspace(1)*
  %1338 = load i32, i32 addrspace(1)* %1337, align 4, !tbaa !5
  %1339 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1333, i32 %675
  %1340 = bitcast float addrspace(3)* %1339 to i32 addrspace(3)*
  store i32 %1338, i32 addrspace(3)* %1340, align 4, !tbaa !5
  %1341 = add nsw i32 %1332, %1
  %1342 = add nuw nsw i32 %1198, 16
  %1343 = icmp eq i32 %1342, 128
  br i1 %1343, label %1344, label %1196, !llvm.loop !19

1344:                                             ; preds = %1196, %526
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %6, label %1345, label %1438

1345:                                             ; preds = %1344, %1434
  %1346 = phi i32 [ %1437, %1434 ], [ 0, %1344 ]
  %1347 = phi i32 [ %1435, %1434 ], [ 1, %1344 ]
  %1348 = add i32 %1346, 1
  %1349 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %1347, i32 %4
  %1350 = load float, float addrspace(3)* %1349, align 4, !tbaa !5
  %1351 = and i32 %1348, 7
  %1352 = icmp ult i32 %1346, 7
  br i1 %1352, label %1417, label %1353

1353:                                             ; preds = %1345
  %1354 = and i32 %1348, -8
  br label %1355

1355:                                             ; preds = %1355, %1353
  %1356 = phi float [ %1350, %1353 ], [ %1413, %1355 ]
  %1357 = phi i32 [ 0, %1353 ], [ %1414, %1355 ]
  %1358 = phi i32 [ %1354, %1353 ], [ %1415, %1355 ]
  %1359 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 %1347, i32 %1357
  %1360 = load float, float addrspace(3)* %1359, align 16, !tbaa !5
  %1361 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %1357, i32 %4
  %1362 = load float, float addrspace(3)* %1361, align 4, !tbaa !5
  %1363 = fmul contract float %1360, %1362
  %1364 = fsub contract float %1356, %1363
  store float %1364, float addrspace(3)* %1349, align 4, !tbaa !5
  %1365 = or i32 %1357, 1
  %1366 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 %1347, i32 %1365
  %1367 = load float, float addrspace(3)* %1366, align 4, !tbaa !5
  %1368 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %1365, i32 %4
  %1369 = load float, float addrspace(3)* %1368, align 4, !tbaa !5
  %1370 = fmul contract float %1367, %1369
  %1371 = fsub contract float %1364, %1370
  store float %1371, float addrspace(3)* %1349, align 4, !tbaa !5
  %1372 = or i32 %1357, 2
  %1373 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 %1347, i32 %1372
  %1374 = load float, float addrspace(3)* %1373, align 8, !tbaa !5
  %1375 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %1372, i32 %4
  %1376 = load float, float addrspace(3)* %1375, align 4, !tbaa !5
  %1377 = fmul contract float %1374, %1376
  %1378 = fsub contract float %1371, %1377
  store float %1378, float addrspace(3)* %1349, align 4, !tbaa !5
  %1379 = or i32 %1357, 3
  %1380 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 %1347, i32 %1379
  %1381 = load float, float addrspace(3)* %1380, align 4, !tbaa !5
  %1382 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %1379, i32 %4
  %1383 = load float, float addrspace(3)* %1382, align 4, !tbaa !5
  %1384 = fmul contract float %1381, %1383
  %1385 = fsub contract float %1378, %1384
  store float %1385, float addrspace(3)* %1349, align 4, !tbaa !5
  %1386 = or i32 %1357, 4
  %1387 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 %1347, i32 %1386
  %1388 = load float, float addrspace(3)* %1387, align 16, !tbaa !5
  %1389 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %1386, i32 %4
  %1390 = load float, float addrspace(3)* %1389, align 4, !tbaa !5
  %1391 = fmul contract float %1388, %1390
  %1392 = fsub contract float %1385, %1391
  store float %1392, float addrspace(3)* %1349, align 4, !tbaa !5
  %1393 = or i32 %1357, 5
  %1394 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 %1347, i32 %1393
  %1395 = load float, float addrspace(3)* %1394, align 4, !tbaa !5
  %1396 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %1393, i32 %4
  %1397 = load float, float addrspace(3)* %1396, align 4, !tbaa !5
  %1398 = fmul contract float %1395, %1397
  %1399 = fsub contract float %1392, %1398
  store float %1399, float addrspace(3)* %1349, align 4, !tbaa !5
  %1400 = or i32 %1357, 6
  %1401 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 %1347, i32 %1400
  %1402 = load float, float addrspace(3)* %1401, align 8, !tbaa !5
  %1403 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %1400, i32 %4
  %1404 = load float, float addrspace(3)* %1403, align 4, !tbaa !5
  %1405 = fmul contract float %1402, %1404
  %1406 = fsub contract float %1399, %1405
  store float %1406, float addrspace(3)* %1349, align 4, !tbaa !5
  %1407 = or i32 %1357, 7
  %1408 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 %1347, i32 %1407
  %1409 = load float, float addrspace(3)* %1408, align 4, !tbaa !5
  %1410 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %1407, i32 %4
  %1411 = load float, float addrspace(3)* %1410, align 4, !tbaa !5
  %1412 = fmul contract float %1409, %1411
  %1413 = fsub contract float %1406, %1412
  store float %1413, float addrspace(3)* %1349, align 4, !tbaa !5
  %1414 = add nuw nsw i32 %1357, 8
  %1415 = add i32 %1358, -8
  %1416 = icmp eq i32 %1415, 0
  br i1 %1416, label %1417, label %1355, !llvm.loop !20

1417:                                             ; preds = %1355, %1345
  %1418 = phi float [ %1350, %1345 ], [ %1413, %1355 ]
  %1419 = phi i32 [ 0, %1345 ], [ %1414, %1355 ]
  %1420 = icmp eq i32 %1351, 0
  br i1 %1420, label %1434, label %1421

1421:                                             ; preds = %1417, %1421
  %1422 = phi float [ %1430, %1421 ], [ %1418, %1417 ]
  %1423 = phi i32 [ %1431, %1421 ], [ %1419, %1417 ]
  %1424 = phi i32 [ %1432, %1421 ], [ %1351, %1417 ]
  %1425 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 %1347, i32 %1423
  %1426 = load float, float addrspace(3)* %1425, align 4, !tbaa !5
  %1427 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %1423, i32 %4
  %1428 = load float, float addrspace(3)* %1427, align 4, !tbaa !5
  %1429 = fmul contract float %1426, %1428
  %1430 = fsub contract float %1422, %1429
  store float %1430, float addrspace(3)* %1349, align 4, !tbaa !5
  %1431 = add nuw nsw i32 %1423, 1
  %1432 = add i32 %1424, -1
  %1433 = icmp eq i32 %1432, 0
  br i1 %1433, label %1434, label %1421, !llvm.loop !21

1434:                                             ; preds = %1421, %1417
  %1435 = add nuw nsw i32 %1347, 1
  %1436 = icmp eq i32 %1435, 128
  %1437 = add i32 %1346, 1
  br i1 %1436, label %1542, label %1345, !llvm.loop !22

1438:                                             ; preds = %1344
  %1439 = add nsw i32 %4, -128
  %1440 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1439, i32 0
  br label %1441

1441:                                             ; preds = %1438, %1534
  %1442 = phi i32 [ 0, %1438 ], [ %1540, %1534 ]
  %1443 = icmp eq i32 %1442, 0
  br i1 %1443, label %1444, label %1446

1444:                                             ; preds = %1441
  %1445 = load float, float addrspace(3)* %1440, align 16, !tbaa !5
  br label %1534

1446:                                             ; preds = %1441
  %1447 = add nsw i32 %1442, -1
  %1448 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1439, i32 %1442
  %1449 = load float, float addrspace(3)* %1448, align 4, !tbaa !5
  %1450 = and i32 %1442, 7
  %1451 = icmp ult i32 %1447, 7
  br i1 %1451, label %1516, label %1452

1452:                                             ; preds = %1446
  %1453 = and i32 %1442, 2147483640
  br label %1454

1454:                                             ; preds = %1454, %1452
  %1455 = phi float [ %1449, %1452 ], [ %1512, %1454 ]
  %1456 = phi i32 [ 0, %1452 ], [ %1513, %1454 ]
  %1457 = phi i32 [ %1453, %1452 ], [ %1514, %1454 ]
  %1458 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1439, i32 %1456
  %1459 = load float, float addrspace(3)* %1458, align 16, !tbaa !5
  %1460 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 %1456, i32 %1442
  %1461 = load float, float addrspace(3)* %1460, align 4, !tbaa !5
  %1462 = fmul contract float %1459, %1461
  %1463 = fsub contract float %1455, %1462
  store float %1463, float addrspace(3)* %1448, align 4, !tbaa !5
  %1464 = or i32 %1456, 1
  %1465 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1439, i32 %1464
  %1466 = load float, float addrspace(3)* %1465, align 4, !tbaa !5
  %1467 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 %1464, i32 %1442
  %1468 = load float, float addrspace(3)* %1467, align 4, !tbaa !5
  %1469 = fmul contract float %1466, %1468
  %1470 = fsub contract float %1463, %1469
  store float %1470, float addrspace(3)* %1448, align 4, !tbaa !5
  %1471 = or i32 %1456, 2
  %1472 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1439, i32 %1471
  %1473 = load float, float addrspace(3)* %1472, align 8, !tbaa !5
  %1474 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 %1471, i32 %1442
  %1475 = load float, float addrspace(3)* %1474, align 4, !tbaa !5
  %1476 = fmul contract float %1473, %1475
  %1477 = fsub contract float %1470, %1476
  store float %1477, float addrspace(3)* %1448, align 4, !tbaa !5
  %1478 = or i32 %1456, 3
  %1479 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1439, i32 %1478
  %1480 = load float, float addrspace(3)* %1479, align 4, !tbaa !5
  %1481 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 %1478, i32 %1442
  %1482 = load float, float addrspace(3)* %1481, align 4, !tbaa !5
  %1483 = fmul contract float %1480, %1482
  %1484 = fsub contract float %1477, %1483
  store float %1484, float addrspace(3)* %1448, align 4, !tbaa !5
  %1485 = or i32 %1456, 4
  %1486 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1439, i32 %1485
  %1487 = load float, float addrspace(3)* %1486, align 16, !tbaa !5
  %1488 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 %1485, i32 %1442
  %1489 = load float, float addrspace(3)* %1488, align 4, !tbaa !5
  %1490 = fmul contract float %1487, %1489
  %1491 = fsub contract float %1484, %1490
  store float %1491, float addrspace(3)* %1448, align 4, !tbaa !5
  %1492 = or i32 %1456, 5
  %1493 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1439, i32 %1492
  %1494 = load float, float addrspace(3)* %1493, align 4, !tbaa !5
  %1495 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 %1492, i32 %1442
  %1496 = load float, float addrspace(3)* %1495, align 4, !tbaa !5
  %1497 = fmul contract float %1494, %1496
  %1498 = fsub contract float %1491, %1497
  store float %1498, float addrspace(3)* %1448, align 4, !tbaa !5
  %1499 = or i32 %1456, 6
  %1500 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1439, i32 %1499
  %1501 = load float, float addrspace(3)* %1500, align 8, !tbaa !5
  %1502 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 %1499, i32 %1442
  %1503 = load float, float addrspace(3)* %1502, align 4, !tbaa !5
  %1504 = fmul contract float %1501, %1503
  %1505 = fsub contract float %1498, %1504
  store float %1505, float addrspace(3)* %1448, align 4, !tbaa !5
  %1506 = or i32 %1456, 7
  %1507 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1439, i32 %1506
  %1508 = load float, float addrspace(3)* %1507, align 4, !tbaa !5
  %1509 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 %1506, i32 %1442
  %1510 = load float, float addrspace(3)* %1509, align 4, !tbaa !5
  %1511 = fmul contract float %1508, %1510
  %1512 = fsub contract float %1505, %1511
  store float %1512, float addrspace(3)* %1448, align 4, !tbaa !5
  %1513 = add nuw nsw i32 %1456, 8
  %1514 = add i32 %1457, -8
  %1515 = icmp eq i32 %1514, 0
  br i1 %1515, label %1516, label %1454, !llvm.loop !23

1516:                                             ; preds = %1454, %1446
  %1517 = phi float [ undef, %1446 ], [ %1512, %1454 ]
  %1518 = phi float [ %1449, %1446 ], [ %1512, %1454 ]
  %1519 = phi i32 [ 0, %1446 ], [ %1513, %1454 ]
  %1520 = icmp eq i32 %1450, 0
  br i1 %1520, label %1534, label %1521

1521:                                             ; preds = %1516, %1521
  %1522 = phi float [ %1530, %1521 ], [ %1518, %1516 ]
  %1523 = phi i32 [ %1531, %1521 ], [ %1519, %1516 ]
  %1524 = phi i32 [ %1532, %1521 ], [ %1450, %1516 ]
  %1525 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1439, i32 %1523
  %1526 = load float, float addrspace(3)* %1525, align 4, !tbaa !5
  %1527 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 %1523, i32 %1442
  %1528 = load float, float addrspace(3)* %1527, align 4, !tbaa !5
  %1529 = fmul contract float %1526, %1528
  %1530 = fsub contract float %1522, %1529
  store float %1530, float addrspace(3)* %1448, align 4, !tbaa !5
  %1531 = add nuw nsw i32 %1523, 1
  %1532 = add i32 %1524, -1
  %1533 = icmp eq i32 %1532, 0
  br i1 %1533, label %1534, label %1521, !llvm.loop !24

1534:                                             ; preds = %1516, %1521, %1444
  %1535 = phi float [ %1445, %1444 ], [ %1517, %1516 ], [ %1530, %1521 ]
  %1536 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE3dia, i32 0, i32 %1442, i32 %1442
  %1537 = load float, float addrspace(3)* %1536, align 4, !tbaa !5
  %1538 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1439, i32 %1442
  %1539 = fdiv contract float %1535, %1537
  store float %1539, float addrspace(3)* %1538, align 4, !tbaa !5
  %1540 = add nuw nsw i32 %1442, 1
  %1541 = icmp eq i32 %1540, 128
  br i1 %1541, label %1542, label %1441, !llvm.loop !25

1542:                                             ; preds = %1534, %1434
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %6, label %1543, label %1619

1543:                                             ; preds = %1542
  %1544 = add nsw i32 %2, 1
  %1545 = mul nsw i32 %1544, %1
  %1546 = add nsw i32 %1545, %2
  %1547 = tail call i32 @llvm.amdgcn.workgroup.id.x() #3
  %1548 = zext i32 %1547 to i64
  %1549 = shl nuw nsw i64 %1548, 7
  %1550 = add nuw nsw i64 %5, 128
  %1551 = add nuw nsw i64 %1550, %1549
  br label %1552

1552:                                             ; preds = %1776, %1543
  %1553 = phi i32 [ %1546, %1543 ], [ %1784, %1776 ]
  %1554 = phi i32 [ 1, %1543 ], [ %1785, %1776 ]
  %1555 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %1554, i32 %4
  %1556 = bitcast float addrspace(3)* %1555 to i32 addrspace(3)*
  %1557 = load i32, i32 addrspace(3)* %1556, align 4, !tbaa !5
  %1558 = sext i32 %1553 to i64
  %1559 = add nsw i64 %1551, %1558
  %1560 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1559
  %1561 = bitcast float addrspace(1)* %1560 to i32 addrspace(1)*
  store i32 %1557, i32 addrspace(1)* %1561, align 4, !tbaa !5
  %1562 = add nsw i32 %1553, %1
  %1563 = add nuw nsw i32 %1554, 1
  %1564 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %1563, i32 %4
  %1565 = bitcast float addrspace(3)* %1564 to i32 addrspace(3)*
  %1566 = load i32, i32 addrspace(3)* %1565, align 4, !tbaa !5
  %1567 = sext i32 %1562 to i64
  %1568 = add nsw i64 %1551, %1567
  %1569 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1568
  %1570 = bitcast float addrspace(1)* %1569 to i32 addrspace(1)*
  store i32 %1566, i32 addrspace(1)* %1570, align 4, !tbaa !5
  %1571 = add nsw i32 %1562, %1
  %1572 = add nuw nsw i32 %1554, 2
  %1573 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %1572, i32 %4
  %1574 = bitcast float addrspace(3)* %1573 to i32 addrspace(3)*
  %1575 = load i32, i32 addrspace(3)* %1574, align 4, !tbaa !5
  %1576 = sext i32 %1571 to i64
  %1577 = add nsw i64 %1551, %1576
  %1578 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1577
  %1579 = bitcast float addrspace(1)* %1578 to i32 addrspace(1)*
  store i32 %1575, i32 addrspace(1)* %1579, align 4, !tbaa !5
  %1580 = add nsw i32 %1571, %1
  %1581 = add nuw nsw i32 %1554, 3
  %1582 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %1581, i32 %4
  %1583 = bitcast float addrspace(3)* %1582 to i32 addrspace(3)*
  %1584 = load i32, i32 addrspace(3)* %1583, align 4, !tbaa !5
  %1585 = sext i32 %1580 to i64
  %1586 = add nsw i64 %1551, %1585
  %1587 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1586
  %1588 = bitcast float addrspace(1)* %1587 to i32 addrspace(1)*
  store i32 %1584, i32 addrspace(1)* %1588, align 4, !tbaa !5
  %1589 = add nsw i32 %1580, %1
  %1590 = add nuw nsw i32 %1554, 4
  %1591 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %1590, i32 %4
  %1592 = bitcast float addrspace(3)* %1591 to i32 addrspace(3)*
  %1593 = load i32, i32 addrspace(3)* %1592, align 4, !tbaa !5
  %1594 = sext i32 %1589 to i64
  %1595 = add nsw i64 %1551, %1594
  %1596 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1595
  %1597 = bitcast float addrspace(1)* %1596 to i32 addrspace(1)*
  store i32 %1593, i32 addrspace(1)* %1597, align 4, !tbaa !5
  %1598 = add nsw i32 %1589, %1
  %1599 = add nuw nsw i32 %1554, 5
  %1600 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %1599, i32 %4
  %1601 = bitcast float addrspace(3)* %1600 to i32 addrspace(3)*
  %1602 = load i32, i32 addrspace(3)* %1601, align 4, !tbaa !5
  %1603 = sext i32 %1598 to i64
  %1604 = add nsw i64 %1551, %1603
  %1605 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1604
  %1606 = bitcast float addrspace(1)* %1605 to i32 addrspace(1)*
  store i32 %1602, i32 addrspace(1)* %1606, align 4, !tbaa !5
  %1607 = add nsw i32 %1598, %1
  %1608 = add nuw nsw i32 %1554, 6
  %1609 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %1608, i32 %4
  %1610 = bitcast float addrspace(3)* %1609 to i32 addrspace(3)*
  %1611 = load i32, i32 addrspace(3)* %1610, align 4, !tbaa !5
  %1612 = sext i32 %1607 to i64
  %1613 = add nsw i64 %1551, %1612
  %1614 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1613
  %1615 = bitcast float addrspace(1)* %1614 to i32 addrspace(1)*
  store i32 %1611, i32 addrspace(1)* %1615, align 4, !tbaa !5
  %1616 = add nsw i32 %1607, %1
  %1617 = add nuw nsw i32 %1554, 7
  %1618 = icmp eq i32 %1617, 128
  br i1 %1618, label %1775, label %1776, !llvm.loop !26

1619:                                             ; preds = %1542
  %1620 = add nsw i32 %4, -128
  %1621 = tail call i32 @llvm.amdgcn.workgroup.id.x() #3
  %1622 = shl i32 %1621, 7
  %1623 = add i32 %2, 128
  %1624 = add i32 %1623, %1622
  %1625 = mul i32 %1624, %1
  %1626 = add i32 %1625, %2
  br label %1627

1627:                                             ; preds = %1627, %1619
  %1628 = phi i32 [ %1626, %1619 ], [ %1772, %1627 ]
  %1629 = phi i32 [ 0, %1619 ], [ %1773, %1627 ]
  %1630 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1629, i32 %1620
  %1631 = bitcast float addrspace(3)* %1630 to i32 addrspace(3)*
  %1632 = load i32, i32 addrspace(3)* %1631, align 4, !tbaa !5
  %1633 = add nsw i32 %1628, %1620
  %1634 = sext i32 %1633 to i64
  %1635 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1634
  %1636 = bitcast float addrspace(1)* %1635 to i32 addrspace(1)*
  store i32 %1632, i32 addrspace(1)* %1636, align 4, !tbaa !5
  %1637 = add nsw i32 %1628, %1
  %1638 = or i32 %1629, 1
  %1639 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1638, i32 %1620
  %1640 = bitcast float addrspace(3)* %1639 to i32 addrspace(3)*
  %1641 = load i32, i32 addrspace(3)* %1640, align 4, !tbaa !5
  %1642 = add nsw i32 %1637, %1620
  %1643 = sext i32 %1642 to i64
  %1644 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1643
  %1645 = bitcast float addrspace(1)* %1644 to i32 addrspace(1)*
  store i32 %1641, i32 addrspace(1)* %1645, align 4, !tbaa !5
  %1646 = add nsw i32 %1637, %1
  %1647 = or i32 %1629, 2
  %1648 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1647, i32 %1620
  %1649 = bitcast float addrspace(3)* %1648 to i32 addrspace(3)*
  %1650 = load i32, i32 addrspace(3)* %1649, align 4, !tbaa !5
  %1651 = add nsw i32 %1646, %1620
  %1652 = sext i32 %1651 to i64
  %1653 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1652
  %1654 = bitcast float addrspace(1)* %1653 to i32 addrspace(1)*
  store i32 %1650, i32 addrspace(1)* %1654, align 4, !tbaa !5
  %1655 = add nsw i32 %1646, %1
  %1656 = or i32 %1629, 3
  %1657 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1656, i32 %1620
  %1658 = bitcast float addrspace(3)* %1657 to i32 addrspace(3)*
  %1659 = load i32, i32 addrspace(3)* %1658, align 4, !tbaa !5
  %1660 = add nsw i32 %1655, %1620
  %1661 = sext i32 %1660 to i64
  %1662 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1661
  %1663 = bitcast float addrspace(1)* %1662 to i32 addrspace(1)*
  store i32 %1659, i32 addrspace(1)* %1663, align 4, !tbaa !5
  %1664 = add nsw i32 %1655, %1
  %1665 = or i32 %1629, 4
  %1666 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1665, i32 %1620
  %1667 = bitcast float addrspace(3)* %1666 to i32 addrspace(3)*
  %1668 = load i32, i32 addrspace(3)* %1667, align 4, !tbaa !5
  %1669 = add nsw i32 %1664, %1620
  %1670 = sext i32 %1669 to i64
  %1671 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1670
  %1672 = bitcast float addrspace(1)* %1671 to i32 addrspace(1)*
  store i32 %1668, i32 addrspace(1)* %1672, align 4, !tbaa !5
  %1673 = add nsw i32 %1664, %1
  %1674 = or i32 %1629, 5
  %1675 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1674, i32 %1620
  %1676 = bitcast float addrspace(3)* %1675 to i32 addrspace(3)*
  %1677 = load i32, i32 addrspace(3)* %1676, align 4, !tbaa !5
  %1678 = add nsw i32 %1673, %1620
  %1679 = sext i32 %1678 to i64
  %1680 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1679
  %1681 = bitcast float addrspace(1)* %1680 to i32 addrspace(1)*
  store i32 %1677, i32 addrspace(1)* %1681, align 4, !tbaa !5
  %1682 = add nsw i32 %1673, %1
  %1683 = or i32 %1629, 6
  %1684 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1683, i32 %1620
  %1685 = bitcast float addrspace(3)* %1684 to i32 addrspace(3)*
  %1686 = load i32, i32 addrspace(3)* %1685, align 4, !tbaa !5
  %1687 = add nsw i32 %1682, %1620
  %1688 = sext i32 %1687 to i64
  %1689 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1688
  %1690 = bitcast float addrspace(1)* %1689 to i32 addrspace(1)*
  store i32 %1686, i32 addrspace(1)* %1690, align 4, !tbaa !5
  %1691 = add nsw i32 %1682, %1
  %1692 = or i32 %1629, 7
  %1693 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1692, i32 %1620
  %1694 = bitcast float addrspace(3)* %1693 to i32 addrspace(3)*
  %1695 = load i32, i32 addrspace(3)* %1694, align 4, !tbaa !5
  %1696 = add nsw i32 %1691, %1620
  %1697 = sext i32 %1696 to i64
  %1698 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1697
  %1699 = bitcast float addrspace(1)* %1698 to i32 addrspace(1)*
  store i32 %1695, i32 addrspace(1)* %1699, align 4, !tbaa !5
  %1700 = add nsw i32 %1691, %1
  %1701 = or i32 %1629, 8
  %1702 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1701, i32 %1620
  %1703 = bitcast float addrspace(3)* %1702 to i32 addrspace(3)*
  %1704 = load i32, i32 addrspace(3)* %1703, align 4, !tbaa !5
  %1705 = add nsw i32 %1700, %1620
  %1706 = sext i32 %1705 to i64
  %1707 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1706
  %1708 = bitcast float addrspace(1)* %1707 to i32 addrspace(1)*
  store i32 %1704, i32 addrspace(1)* %1708, align 4, !tbaa !5
  %1709 = add nsw i32 %1700, %1
  %1710 = or i32 %1629, 9
  %1711 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1710, i32 %1620
  %1712 = bitcast float addrspace(3)* %1711 to i32 addrspace(3)*
  %1713 = load i32, i32 addrspace(3)* %1712, align 4, !tbaa !5
  %1714 = add nsw i32 %1709, %1620
  %1715 = sext i32 %1714 to i64
  %1716 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1715
  %1717 = bitcast float addrspace(1)* %1716 to i32 addrspace(1)*
  store i32 %1713, i32 addrspace(1)* %1717, align 4, !tbaa !5
  %1718 = add nsw i32 %1709, %1
  %1719 = or i32 %1629, 10
  %1720 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1719, i32 %1620
  %1721 = bitcast float addrspace(3)* %1720 to i32 addrspace(3)*
  %1722 = load i32, i32 addrspace(3)* %1721, align 4, !tbaa !5
  %1723 = add nsw i32 %1718, %1620
  %1724 = sext i32 %1723 to i64
  %1725 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1724
  %1726 = bitcast float addrspace(1)* %1725 to i32 addrspace(1)*
  store i32 %1722, i32 addrspace(1)* %1726, align 4, !tbaa !5
  %1727 = add nsw i32 %1718, %1
  %1728 = or i32 %1629, 11
  %1729 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1728, i32 %1620
  %1730 = bitcast float addrspace(3)* %1729 to i32 addrspace(3)*
  %1731 = load i32, i32 addrspace(3)* %1730, align 4, !tbaa !5
  %1732 = add nsw i32 %1727, %1620
  %1733 = sext i32 %1732 to i64
  %1734 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1733
  %1735 = bitcast float addrspace(1)* %1734 to i32 addrspace(1)*
  store i32 %1731, i32 addrspace(1)* %1735, align 4, !tbaa !5
  %1736 = add nsw i32 %1727, %1
  %1737 = or i32 %1629, 12
  %1738 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1737, i32 %1620
  %1739 = bitcast float addrspace(3)* %1738 to i32 addrspace(3)*
  %1740 = load i32, i32 addrspace(3)* %1739, align 4, !tbaa !5
  %1741 = add nsw i32 %1736, %1620
  %1742 = sext i32 %1741 to i64
  %1743 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1742
  %1744 = bitcast float addrspace(1)* %1743 to i32 addrspace(1)*
  store i32 %1740, i32 addrspace(1)* %1744, align 4, !tbaa !5
  %1745 = add nsw i32 %1736, %1
  %1746 = or i32 %1629, 13
  %1747 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1746, i32 %1620
  %1748 = bitcast float addrspace(3)* %1747 to i32 addrspace(3)*
  %1749 = load i32, i32 addrspace(3)* %1748, align 4, !tbaa !5
  %1750 = add nsw i32 %1745, %1620
  %1751 = sext i32 %1750 to i64
  %1752 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1751
  %1753 = bitcast float addrspace(1)* %1752 to i32 addrspace(1)*
  store i32 %1749, i32 addrspace(1)* %1753, align 4, !tbaa !5
  %1754 = add nsw i32 %1745, %1
  %1755 = or i32 %1629, 14
  %1756 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1755, i32 %1620
  %1757 = bitcast float addrspace(3)* %1756 to i32 addrspace(3)*
  %1758 = load i32, i32 addrspace(3)* %1757, align 4, !tbaa !5
  %1759 = add nsw i32 %1754, %1620
  %1760 = sext i32 %1759 to i64
  %1761 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1760
  %1762 = bitcast float addrspace(1)* %1761 to i32 addrspace(1)*
  store i32 %1758, i32 addrspace(1)* %1762, align 4, !tbaa !5
  %1763 = add nsw i32 %1754, %1
  %1764 = or i32 %1629, 15
  %1765 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 %1764, i32 %1620
  %1766 = bitcast float addrspace(3)* %1765 to i32 addrspace(3)*
  %1767 = load i32, i32 addrspace(3)* %1766, align 4, !tbaa !5
  %1768 = add nsw i32 %1763, %1620
  %1769 = sext i32 %1768 to i64
  %1770 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1769
  %1771 = bitcast float addrspace(1)* %1770 to i32 addrspace(1)*
  store i32 %1767, i32 addrspace(1)* %1771, align 4, !tbaa !5
  %1772 = add nsw i32 %1763, %1
  %1773 = add nuw nsw i32 %1629, 16
  %1774 = icmp eq i32 %1773, 128
  br i1 %1774, label %1775, label %1627, !llvm.loop !27

1775:                                             ; preds = %1627, %1552
  ret void

1776:                                             ; preds = %1552
  %1777 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 %1617, i32 %4
  %1778 = bitcast float addrspace(3)* %1777 to i32 addrspace(3)*
  %1779 = load i32, i32 addrspace(3)* %1778, align 4, !tbaa !5
  %1780 = sext i32 %1616 to i64
  %1781 = add nsw i64 %1551, %1780
  %1782 = getelementptr inbounds float, float addrspace(1)* %0, i64 %1781
  %1783 = bitcast float addrspace(1)* %1782 to i32 addrspace(1)*
  store i32 %1779, i32 addrspace(1)* %1783, align 4, !tbaa !5
  %1784 = add nsw i32 %1616, %1
  %1785 = add nuw nsw i32 %1554, 8
  br label %1552
}

; Function Attrs: convergent norecurse nounwind
define protected amdgpu_kernel void @_Z12lud_internalPfii(float addrspace(1)* nocapture %0, i32 %1, i32 %2) local_unnamed_addr #0 {
  %4 = sext i32 %2 to i64
  %5 = tail call i32 @llvm.amdgcn.workgroup.id.y() #3
  %6 = shl i32 %5, 7
  %7 = add i32 %2, 128
  %8 = add i32 %7, %6
  %9 = tail call i32 @llvm.amdgcn.workgroup.id.x() #3
  %10 = shl i32 %9, 7
  %11 = add i32 %7, %10
  %12 = tail call i32 @llvm.amdgcn.workitem.id.y() #3, !range !4
  %13 = zext i32 %12 to i64
  %14 = add nsw i64 %4, %13
  %15 = sext i32 %1 to i64
  %16 = mul i64 %14, %15
  %17 = sext i32 %11 to i64
  %18 = tail call i32 @llvm.amdgcn.workitem.id.x() #3, !range !4
  %19 = zext i32 %18 to i64
  %20 = add nsw i64 %17, %19
  %21 = add i64 %20, %16
  %22 = getelementptr inbounds float, float addrspace(1)* %0, i64 %21
  %23 = bitcast float addrspace(1)* %22 to i32 addrspace(1)*
  %24 = load i32, i32 addrspace(1)* %23, align 4, !tbaa !5
  %25 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 %12, i32 %18
  %26 = bitcast float addrspace(3)* %25 to i32 addrspace(3)*
  store i32 %24, i32 addrspace(3)* %26, align 4, !tbaa !5
  %27 = sext i32 %8 to i64
  %28 = add nsw i64 %27, %13
  %29 = mul i64 %28, %15
  %30 = add i64 %29, %19
  %31 = add i64 %30, %4
  %32 = getelementptr inbounds float, float addrspace(1)* %0, i64 %31
  %33 = bitcast float addrspace(1)* %32 to i32 addrspace(1)*
  %34 = load i32, i32 addrspace(1)* %33, align 4, !tbaa !5
  %35 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 %18
  %36 = bitcast float addrspace(3)* %35 to i32 addrspace(3)*
  store i32 %34, i32 addrspace(3)* %36, align 4, !tbaa !5
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %37 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 0
  %38 = load float, float addrspace(3)* %37, align 16, !tbaa !5
  %39 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 0, i32 %18
  %40 = load float, float addrspace(3)* %39, align 4, !tbaa !5
  %41 = fmul contract float %38, %40
  %42 = fadd contract float %41, 0.000000e+00
  %43 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 1
  %44 = load float, float addrspace(3)* %43, align 4, !tbaa !5
  %45 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 1, i32 %18
  %46 = load float, float addrspace(3)* %45, align 4, !tbaa !5
  %47 = fmul contract float %44, %46
  %48 = fadd contract float %42, %47
  %49 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 2
  %50 = load float, float addrspace(3)* %49, align 8, !tbaa !5
  %51 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 2, i32 %18
  %52 = load float, float addrspace(3)* %51, align 4, !tbaa !5
  %53 = fmul contract float %50, %52
  %54 = fadd contract float %48, %53
  %55 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 3
  %56 = load float, float addrspace(3)* %55, align 4, !tbaa !5
  %57 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 3, i32 %18
  %58 = load float, float addrspace(3)* %57, align 4, !tbaa !5
  %59 = fmul contract float %56, %58
  %60 = fadd contract float %54, %59
  %61 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 4
  %62 = load float, float addrspace(3)* %61, align 16, !tbaa !5
  %63 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 4, i32 %18
  %64 = load float, float addrspace(3)* %63, align 4, !tbaa !5
  %65 = fmul contract float %62, %64
  %66 = fadd contract float %60, %65
  %67 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 5
  %68 = load float, float addrspace(3)* %67, align 4, !tbaa !5
  %69 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 5, i32 %18
  %70 = load float, float addrspace(3)* %69, align 4, !tbaa !5
  %71 = fmul contract float %68, %70
  %72 = fadd contract float %66, %71
  %73 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 6
  %74 = load float, float addrspace(3)* %73, align 8, !tbaa !5
  %75 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 6, i32 %18
  %76 = load float, float addrspace(3)* %75, align 4, !tbaa !5
  %77 = fmul contract float %74, %76
  %78 = fadd contract float %72, %77
  %79 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 7
  %80 = load float, float addrspace(3)* %79, align 4, !tbaa !5
  %81 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 7, i32 %18
  %82 = load float, float addrspace(3)* %81, align 4, !tbaa !5
  %83 = fmul contract float %80, %82
  %84 = fadd contract float %78, %83
  %85 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 8
  %86 = load float, float addrspace(3)* %85, align 16, !tbaa !5
  %87 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 8, i32 %18
  %88 = load float, float addrspace(3)* %87, align 4, !tbaa !5
  %89 = fmul contract float %86, %88
  %90 = fadd contract float %84, %89
  %91 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 9
  %92 = load float, float addrspace(3)* %91, align 4, !tbaa !5
  %93 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 9, i32 %18
  %94 = load float, float addrspace(3)* %93, align 4, !tbaa !5
  %95 = fmul contract float %92, %94
  %96 = fadd contract float %90, %95
  %97 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 10
  %98 = load float, float addrspace(3)* %97, align 8, !tbaa !5
  %99 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 10, i32 %18
  %100 = load float, float addrspace(3)* %99, align 4, !tbaa !5
  %101 = fmul contract float %98, %100
  %102 = fadd contract float %96, %101
  %103 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 11
  %104 = load float, float addrspace(3)* %103, align 4, !tbaa !5
  %105 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 11, i32 %18
  %106 = load float, float addrspace(3)* %105, align 4, !tbaa !5
  %107 = fmul contract float %104, %106
  %108 = fadd contract float %102, %107
  %109 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 12
  %110 = load float, float addrspace(3)* %109, align 16, !tbaa !5
  %111 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 12, i32 %18
  %112 = load float, float addrspace(3)* %111, align 4, !tbaa !5
  %113 = fmul contract float %110, %112
  %114 = fadd contract float %108, %113
  %115 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 13
  %116 = load float, float addrspace(3)* %115, align 4, !tbaa !5
  %117 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 13, i32 %18
  %118 = load float, float addrspace(3)* %117, align 4, !tbaa !5
  %119 = fmul contract float %116, %118
  %120 = fadd contract float %114, %119
  %121 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 14
  %122 = load float, float addrspace(3)* %121, align 8, !tbaa !5
  %123 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 14, i32 %18
  %124 = load float, float addrspace(3)* %123, align 4, !tbaa !5
  %125 = fmul contract float %122, %124
  %126 = fadd contract float %120, %125
  %127 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 15
  %128 = load float, float addrspace(3)* %127, align 4, !tbaa !5
  %129 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 15, i32 %18
  %130 = load float, float addrspace(3)* %129, align 4, !tbaa !5
  %131 = fmul contract float %128, %130
  %132 = fadd contract float %126, %131
  %133 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 16
  %134 = load float, float addrspace(3)* %133, align 16, !tbaa !5
  %135 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 16, i32 %18
  %136 = load float, float addrspace(3)* %135, align 4, !tbaa !5
  %137 = fmul contract float %134, %136
  %138 = fadd contract float %132, %137
  %139 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 17
  %140 = load float, float addrspace(3)* %139, align 4, !tbaa !5
  %141 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 17, i32 %18
  %142 = load float, float addrspace(3)* %141, align 4, !tbaa !5
  %143 = fmul contract float %140, %142
  %144 = fadd contract float %138, %143
  %145 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 18
  %146 = load float, float addrspace(3)* %145, align 8, !tbaa !5
  %147 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 18, i32 %18
  %148 = load float, float addrspace(3)* %147, align 4, !tbaa !5
  %149 = fmul contract float %146, %148
  %150 = fadd contract float %144, %149
  %151 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 19
  %152 = load float, float addrspace(3)* %151, align 4, !tbaa !5
  %153 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 19, i32 %18
  %154 = load float, float addrspace(3)* %153, align 4, !tbaa !5
  %155 = fmul contract float %152, %154
  %156 = fadd contract float %150, %155
  %157 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 20
  %158 = load float, float addrspace(3)* %157, align 16, !tbaa !5
  %159 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 20, i32 %18
  %160 = load float, float addrspace(3)* %159, align 4, !tbaa !5
  %161 = fmul contract float %158, %160
  %162 = fadd contract float %156, %161
  %163 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 21
  %164 = load float, float addrspace(3)* %163, align 4, !tbaa !5
  %165 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 21, i32 %18
  %166 = load float, float addrspace(3)* %165, align 4, !tbaa !5
  %167 = fmul contract float %164, %166
  %168 = fadd contract float %162, %167
  %169 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 22
  %170 = load float, float addrspace(3)* %169, align 8, !tbaa !5
  %171 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 22, i32 %18
  %172 = load float, float addrspace(3)* %171, align 4, !tbaa !5
  %173 = fmul contract float %170, %172
  %174 = fadd contract float %168, %173
  %175 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 23
  %176 = load float, float addrspace(3)* %175, align 4, !tbaa !5
  %177 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 23, i32 %18
  %178 = load float, float addrspace(3)* %177, align 4, !tbaa !5
  %179 = fmul contract float %176, %178
  %180 = fadd contract float %174, %179
  %181 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 24
  %182 = load float, float addrspace(3)* %181, align 16, !tbaa !5
  %183 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 24, i32 %18
  %184 = load float, float addrspace(3)* %183, align 4, !tbaa !5
  %185 = fmul contract float %182, %184
  %186 = fadd contract float %180, %185
  %187 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 25
  %188 = load float, float addrspace(3)* %187, align 4, !tbaa !5
  %189 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 25, i32 %18
  %190 = load float, float addrspace(3)* %189, align 4, !tbaa !5
  %191 = fmul contract float %188, %190
  %192 = fadd contract float %186, %191
  %193 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 26
  %194 = load float, float addrspace(3)* %193, align 8, !tbaa !5
  %195 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 26, i32 %18
  %196 = load float, float addrspace(3)* %195, align 4, !tbaa !5
  %197 = fmul contract float %194, %196
  %198 = fadd contract float %192, %197
  %199 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 27
  %200 = load float, float addrspace(3)* %199, align 4, !tbaa !5
  %201 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 27, i32 %18
  %202 = load float, float addrspace(3)* %201, align 4, !tbaa !5
  %203 = fmul contract float %200, %202
  %204 = fadd contract float %198, %203
  %205 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 28
  %206 = load float, float addrspace(3)* %205, align 16, !tbaa !5
  %207 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 28, i32 %18
  %208 = load float, float addrspace(3)* %207, align 4, !tbaa !5
  %209 = fmul contract float %206, %208
  %210 = fadd contract float %204, %209
  %211 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 29
  %212 = load float, float addrspace(3)* %211, align 4, !tbaa !5
  %213 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 29, i32 %18
  %214 = load float, float addrspace(3)* %213, align 4, !tbaa !5
  %215 = fmul contract float %212, %214
  %216 = fadd contract float %210, %215
  %217 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 30
  %218 = load float, float addrspace(3)* %217, align 8, !tbaa !5
  %219 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 30, i32 %18
  %220 = load float, float addrspace(3)* %219, align 4, !tbaa !5
  %221 = fmul contract float %218, %220
  %222 = fadd contract float %216, %221
  %223 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 31
  %224 = load float, float addrspace(3)* %223, align 4, !tbaa !5
  %225 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 31, i32 %18
  %226 = load float, float addrspace(3)* %225, align 4, !tbaa !5
  %227 = fmul contract float %224, %226
  %228 = fadd contract float %222, %227
  %229 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 32
  %230 = load float, float addrspace(3)* %229, align 16, !tbaa !5
  %231 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 32, i32 %18
  %232 = load float, float addrspace(3)* %231, align 4, !tbaa !5
  %233 = fmul contract float %230, %232
  %234 = fadd contract float %228, %233
  %235 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 33
  %236 = load float, float addrspace(3)* %235, align 4, !tbaa !5
  %237 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 33, i32 %18
  %238 = load float, float addrspace(3)* %237, align 4, !tbaa !5
  %239 = fmul contract float %236, %238
  %240 = fadd contract float %234, %239
  %241 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 34
  %242 = load float, float addrspace(3)* %241, align 8, !tbaa !5
  %243 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 34, i32 %18
  %244 = load float, float addrspace(3)* %243, align 4, !tbaa !5
  %245 = fmul contract float %242, %244
  %246 = fadd contract float %240, %245
  %247 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 35
  %248 = load float, float addrspace(3)* %247, align 4, !tbaa !5
  %249 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 35, i32 %18
  %250 = load float, float addrspace(3)* %249, align 4, !tbaa !5
  %251 = fmul contract float %248, %250
  %252 = fadd contract float %246, %251
  %253 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 36
  %254 = load float, float addrspace(3)* %253, align 16, !tbaa !5
  %255 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 36, i32 %18
  %256 = load float, float addrspace(3)* %255, align 4, !tbaa !5
  %257 = fmul contract float %254, %256
  %258 = fadd contract float %252, %257
  %259 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 37
  %260 = load float, float addrspace(3)* %259, align 4, !tbaa !5
  %261 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 37, i32 %18
  %262 = load float, float addrspace(3)* %261, align 4, !tbaa !5
  %263 = fmul contract float %260, %262
  %264 = fadd contract float %258, %263
  %265 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 38
  %266 = load float, float addrspace(3)* %265, align 8, !tbaa !5
  %267 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 38, i32 %18
  %268 = load float, float addrspace(3)* %267, align 4, !tbaa !5
  %269 = fmul contract float %266, %268
  %270 = fadd contract float %264, %269
  %271 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 39
  %272 = load float, float addrspace(3)* %271, align 4, !tbaa !5
  %273 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 39, i32 %18
  %274 = load float, float addrspace(3)* %273, align 4, !tbaa !5
  %275 = fmul contract float %272, %274
  %276 = fadd contract float %270, %275
  %277 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 40
  %278 = load float, float addrspace(3)* %277, align 16, !tbaa !5
  %279 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 40, i32 %18
  %280 = load float, float addrspace(3)* %279, align 4, !tbaa !5
  %281 = fmul contract float %278, %280
  %282 = fadd contract float %276, %281
  %283 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 41
  %284 = load float, float addrspace(3)* %283, align 4, !tbaa !5
  %285 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 41, i32 %18
  %286 = load float, float addrspace(3)* %285, align 4, !tbaa !5
  %287 = fmul contract float %284, %286
  %288 = fadd contract float %282, %287
  %289 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 42
  %290 = load float, float addrspace(3)* %289, align 8, !tbaa !5
  %291 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 42, i32 %18
  %292 = load float, float addrspace(3)* %291, align 4, !tbaa !5
  %293 = fmul contract float %290, %292
  %294 = fadd contract float %288, %293
  %295 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 43
  %296 = load float, float addrspace(3)* %295, align 4, !tbaa !5
  %297 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 43, i32 %18
  %298 = load float, float addrspace(3)* %297, align 4, !tbaa !5
  %299 = fmul contract float %296, %298
  %300 = fadd contract float %294, %299
  %301 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 44
  %302 = load float, float addrspace(3)* %301, align 16, !tbaa !5
  %303 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 44, i32 %18
  %304 = load float, float addrspace(3)* %303, align 4, !tbaa !5
  %305 = fmul contract float %302, %304
  %306 = fadd contract float %300, %305
  %307 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 45
  %308 = load float, float addrspace(3)* %307, align 4, !tbaa !5
  %309 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 45, i32 %18
  %310 = load float, float addrspace(3)* %309, align 4, !tbaa !5
  %311 = fmul contract float %308, %310
  %312 = fadd contract float %306, %311
  %313 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 46
  %314 = load float, float addrspace(3)* %313, align 8, !tbaa !5
  %315 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 46, i32 %18
  %316 = load float, float addrspace(3)* %315, align 4, !tbaa !5
  %317 = fmul contract float %314, %316
  %318 = fadd contract float %312, %317
  %319 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 47
  %320 = load float, float addrspace(3)* %319, align 4, !tbaa !5
  %321 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 47, i32 %18
  %322 = load float, float addrspace(3)* %321, align 4, !tbaa !5
  %323 = fmul contract float %320, %322
  %324 = fadd contract float %318, %323
  %325 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 48
  %326 = load float, float addrspace(3)* %325, align 16, !tbaa !5
  %327 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 48, i32 %18
  %328 = load float, float addrspace(3)* %327, align 4, !tbaa !5
  %329 = fmul contract float %326, %328
  %330 = fadd contract float %324, %329
  %331 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 49
  %332 = load float, float addrspace(3)* %331, align 4, !tbaa !5
  %333 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 49, i32 %18
  %334 = load float, float addrspace(3)* %333, align 4, !tbaa !5
  %335 = fmul contract float %332, %334
  %336 = fadd contract float %330, %335
  %337 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 50
  %338 = load float, float addrspace(3)* %337, align 8, !tbaa !5
  %339 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 50, i32 %18
  %340 = load float, float addrspace(3)* %339, align 4, !tbaa !5
  %341 = fmul contract float %338, %340
  %342 = fadd contract float %336, %341
  %343 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 51
  %344 = load float, float addrspace(3)* %343, align 4, !tbaa !5
  %345 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 51, i32 %18
  %346 = load float, float addrspace(3)* %345, align 4, !tbaa !5
  %347 = fmul contract float %344, %346
  %348 = fadd contract float %342, %347
  %349 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 52
  %350 = load float, float addrspace(3)* %349, align 16, !tbaa !5
  %351 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 52, i32 %18
  %352 = load float, float addrspace(3)* %351, align 4, !tbaa !5
  %353 = fmul contract float %350, %352
  %354 = fadd contract float %348, %353
  %355 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 53
  %356 = load float, float addrspace(3)* %355, align 4, !tbaa !5
  %357 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 53, i32 %18
  %358 = load float, float addrspace(3)* %357, align 4, !tbaa !5
  %359 = fmul contract float %356, %358
  %360 = fadd contract float %354, %359
  %361 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 54
  %362 = load float, float addrspace(3)* %361, align 8, !tbaa !5
  %363 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 54, i32 %18
  %364 = load float, float addrspace(3)* %363, align 4, !tbaa !5
  %365 = fmul contract float %362, %364
  %366 = fadd contract float %360, %365
  %367 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 55
  %368 = load float, float addrspace(3)* %367, align 4, !tbaa !5
  %369 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 55, i32 %18
  %370 = load float, float addrspace(3)* %369, align 4, !tbaa !5
  %371 = fmul contract float %368, %370
  %372 = fadd contract float %366, %371
  %373 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 56
  %374 = load float, float addrspace(3)* %373, align 16, !tbaa !5
  %375 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 56, i32 %18
  %376 = load float, float addrspace(3)* %375, align 4, !tbaa !5
  %377 = fmul contract float %374, %376
  %378 = fadd contract float %372, %377
  %379 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 57
  %380 = load float, float addrspace(3)* %379, align 4, !tbaa !5
  %381 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 57, i32 %18
  %382 = load float, float addrspace(3)* %381, align 4, !tbaa !5
  %383 = fmul contract float %380, %382
  %384 = fadd contract float %378, %383
  %385 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 58
  %386 = load float, float addrspace(3)* %385, align 8, !tbaa !5
  %387 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 58, i32 %18
  %388 = load float, float addrspace(3)* %387, align 4, !tbaa !5
  %389 = fmul contract float %386, %388
  %390 = fadd contract float %384, %389
  %391 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 59
  %392 = load float, float addrspace(3)* %391, align 4, !tbaa !5
  %393 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 59, i32 %18
  %394 = load float, float addrspace(3)* %393, align 4, !tbaa !5
  %395 = fmul contract float %392, %394
  %396 = fadd contract float %390, %395
  %397 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 60
  %398 = load float, float addrspace(3)* %397, align 16, !tbaa !5
  %399 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 60, i32 %18
  %400 = load float, float addrspace(3)* %399, align 4, !tbaa !5
  %401 = fmul contract float %398, %400
  %402 = fadd contract float %396, %401
  %403 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 61
  %404 = load float, float addrspace(3)* %403, align 4, !tbaa !5
  %405 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 61, i32 %18
  %406 = load float, float addrspace(3)* %405, align 4, !tbaa !5
  %407 = fmul contract float %404, %406
  %408 = fadd contract float %402, %407
  %409 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 62
  %410 = load float, float addrspace(3)* %409, align 8, !tbaa !5
  %411 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 62, i32 %18
  %412 = load float, float addrspace(3)* %411, align 4, !tbaa !5
  %413 = fmul contract float %410, %412
  %414 = fadd contract float %408, %413
  %415 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 63
  %416 = load float, float addrspace(3)* %415, align 4, !tbaa !5
  %417 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 63, i32 %18
  %418 = load float, float addrspace(3)* %417, align 4, !tbaa !5
  %419 = fmul contract float %416, %418
  %420 = fadd contract float %414, %419
  %421 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 64
  %422 = load float, float addrspace(3)* %421, align 16, !tbaa !5
  %423 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 64, i32 %18
  %424 = load float, float addrspace(3)* %423, align 4, !tbaa !5
  %425 = fmul contract float %422, %424
  %426 = fadd contract float %420, %425
  %427 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 65
  %428 = load float, float addrspace(3)* %427, align 4, !tbaa !5
  %429 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 65, i32 %18
  %430 = load float, float addrspace(3)* %429, align 4, !tbaa !5
  %431 = fmul contract float %428, %430
  %432 = fadd contract float %426, %431
  %433 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 66
  %434 = load float, float addrspace(3)* %433, align 8, !tbaa !5
  %435 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 66, i32 %18
  %436 = load float, float addrspace(3)* %435, align 4, !tbaa !5
  %437 = fmul contract float %434, %436
  %438 = fadd contract float %432, %437
  %439 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 67
  %440 = load float, float addrspace(3)* %439, align 4, !tbaa !5
  %441 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 67, i32 %18
  %442 = load float, float addrspace(3)* %441, align 4, !tbaa !5
  %443 = fmul contract float %440, %442
  %444 = fadd contract float %438, %443
  %445 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 68
  %446 = load float, float addrspace(3)* %445, align 16, !tbaa !5
  %447 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 68, i32 %18
  %448 = load float, float addrspace(3)* %447, align 4, !tbaa !5
  %449 = fmul contract float %446, %448
  %450 = fadd contract float %444, %449
  %451 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 69
  %452 = load float, float addrspace(3)* %451, align 4, !tbaa !5
  %453 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 69, i32 %18
  %454 = load float, float addrspace(3)* %453, align 4, !tbaa !5
  %455 = fmul contract float %452, %454
  %456 = fadd contract float %450, %455
  %457 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 70
  %458 = load float, float addrspace(3)* %457, align 8, !tbaa !5
  %459 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 70, i32 %18
  %460 = load float, float addrspace(3)* %459, align 4, !tbaa !5
  %461 = fmul contract float %458, %460
  %462 = fadd contract float %456, %461
  %463 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 71
  %464 = load float, float addrspace(3)* %463, align 4, !tbaa !5
  %465 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 71, i32 %18
  %466 = load float, float addrspace(3)* %465, align 4, !tbaa !5
  %467 = fmul contract float %464, %466
  %468 = fadd contract float %462, %467
  %469 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 72
  %470 = load float, float addrspace(3)* %469, align 16, !tbaa !5
  %471 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 72, i32 %18
  %472 = load float, float addrspace(3)* %471, align 4, !tbaa !5
  %473 = fmul contract float %470, %472
  %474 = fadd contract float %468, %473
  %475 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 73
  %476 = load float, float addrspace(3)* %475, align 4, !tbaa !5
  %477 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 73, i32 %18
  %478 = load float, float addrspace(3)* %477, align 4, !tbaa !5
  %479 = fmul contract float %476, %478
  %480 = fadd contract float %474, %479
  %481 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 74
  %482 = load float, float addrspace(3)* %481, align 8, !tbaa !5
  %483 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 74, i32 %18
  %484 = load float, float addrspace(3)* %483, align 4, !tbaa !5
  %485 = fmul contract float %482, %484
  %486 = fadd contract float %480, %485
  %487 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 75
  %488 = load float, float addrspace(3)* %487, align 4, !tbaa !5
  %489 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 75, i32 %18
  %490 = load float, float addrspace(3)* %489, align 4, !tbaa !5
  %491 = fmul contract float %488, %490
  %492 = fadd contract float %486, %491
  %493 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 76
  %494 = load float, float addrspace(3)* %493, align 16, !tbaa !5
  %495 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 76, i32 %18
  %496 = load float, float addrspace(3)* %495, align 4, !tbaa !5
  %497 = fmul contract float %494, %496
  %498 = fadd contract float %492, %497
  %499 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 77
  %500 = load float, float addrspace(3)* %499, align 4, !tbaa !5
  %501 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 77, i32 %18
  %502 = load float, float addrspace(3)* %501, align 4, !tbaa !5
  %503 = fmul contract float %500, %502
  %504 = fadd contract float %498, %503
  %505 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 78
  %506 = load float, float addrspace(3)* %505, align 8, !tbaa !5
  %507 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 78, i32 %18
  %508 = load float, float addrspace(3)* %507, align 4, !tbaa !5
  %509 = fmul contract float %506, %508
  %510 = fadd contract float %504, %509
  %511 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 79
  %512 = load float, float addrspace(3)* %511, align 4, !tbaa !5
  %513 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 79, i32 %18
  %514 = load float, float addrspace(3)* %513, align 4, !tbaa !5
  %515 = fmul contract float %512, %514
  %516 = fadd contract float %510, %515
  %517 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 80
  %518 = load float, float addrspace(3)* %517, align 16, !tbaa !5
  %519 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 80, i32 %18
  %520 = load float, float addrspace(3)* %519, align 4, !tbaa !5
  %521 = fmul contract float %518, %520
  %522 = fadd contract float %516, %521
  %523 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 81
  %524 = load float, float addrspace(3)* %523, align 4, !tbaa !5
  %525 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 81, i32 %18
  %526 = load float, float addrspace(3)* %525, align 4, !tbaa !5
  %527 = fmul contract float %524, %526
  %528 = fadd contract float %522, %527
  %529 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 82
  %530 = load float, float addrspace(3)* %529, align 8, !tbaa !5
  %531 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 82, i32 %18
  %532 = load float, float addrspace(3)* %531, align 4, !tbaa !5
  %533 = fmul contract float %530, %532
  %534 = fadd contract float %528, %533
  %535 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 83
  %536 = load float, float addrspace(3)* %535, align 4, !tbaa !5
  %537 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 83, i32 %18
  %538 = load float, float addrspace(3)* %537, align 4, !tbaa !5
  %539 = fmul contract float %536, %538
  %540 = fadd contract float %534, %539
  %541 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 84
  %542 = load float, float addrspace(3)* %541, align 16, !tbaa !5
  %543 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 84, i32 %18
  %544 = load float, float addrspace(3)* %543, align 4, !tbaa !5
  %545 = fmul contract float %542, %544
  %546 = fadd contract float %540, %545
  %547 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 85
  %548 = load float, float addrspace(3)* %547, align 4, !tbaa !5
  %549 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 85, i32 %18
  %550 = load float, float addrspace(3)* %549, align 4, !tbaa !5
  %551 = fmul contract float %548, %550
  %552 = fadd contract float %546, %551
  %553 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 86
  %554 = load float, float addrspace(3)* %553, align 8, !tbaa !5
  %555 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 86, i32 %18
  %556 = load float, float addrspace(3)* %555, align 4, !tbaa !5
  %557 = fmul contract float %554, %556
  %558 = fadd contract float %552, %557
  %559 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 87
  %560 = load float, float addrspace(3)* %559, align 4, !tbaa !5
  %561 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 87, i32 %18
  %562 = load float, float addrspace(3)* %561, align 4, !tbaa !5
  %563 = fmul contract float %560, %562
  %564 = fadd contract float %558, %563
  %565 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 88
  %566 = load float, float addrspace(3)* %565, align 16, !tbaa !5
  %567 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 88, i32 %18
  %568 = load float, float addrspace(3)* %567, align 4, !tbaa !5
  %569 = fmul contract float %566, %568
  %570 = fadd contract float %564, %569
  %571 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 89
  %572 = load float, float addrspace(3)* %571, align 4, !tbaa !5
  %573 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 89, i32 %18
  %574 = load float, float addrspace(3)* %573, align 4, !tbaa !5
  %575 = fmul contract float %572, %574
  %576 = fadd contract float %570, %575
  %577 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 90
  %578 = load float, float addrspace(3)* %577, align 8, !tbaa !5
  %579 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 90, i32 %18
  %580 = load float, float addrspace(3)* %579, align 4, !tbaa !5
  %581 = fmul contract float %578, %580
  %582 = fadd contract float %576, %581
  %583 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 91
  %584 = load float, float addrspace(3)* %583, align 4, !tbaa !5
  %585 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 91, i32 %18
  %586 = load float, float addrspace(3)* %585, align 4, !tbaa !5
  %587 = fmul contract float %584, %586
  %588 = fadd contract float %582, %587
  %589 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 92
  %590 = load float, float addrspace(3)* %589, align 16, !tbaa !5
  %591 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 92, i32 %18
  %592 = load float, float addrspace(3)* %591, align 4, !tbaa !5
  %593 = fmul contract float %590, %592
  %594 = fadd contract float %588, %593
  %595 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 93
  %596 = load float, float addrspace(3)* %595, align 4, !tbaa !5
  %597 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 93, i32 %18
  %598 = load float, float addrspace(3)* %597, align 4, !tbaa !5
  %599 = fmul contract float %596, %598
  %600 = fadd contract float %594, %599
  %601 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 94
  %602 = load float, float addrspace(3)* %601, align 8, !tbaa !5
  %603 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 94, i32 %18
  %604 = load float, float addrspace(3)* %603, align 4, !tbaa !5
  %605 = fmul contract float %602, %604
  %606 = fadd contract float %600, %605
  %607 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 95
  %608 = load float, float addrspace(3)* %607, align 4, !tbaa !5
  %609 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 95, i32 %18
  %610 = load float, float addrspace(3)* %609, align 4, !tbaa !5
  %611 = fmul contract float %608, %610
  %612 = fadd contract float %606, %611
  %613 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 96
  %614 = load float, float addrspace(3)* %613, align 16, !tbaa !5
  %615 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 96, i32 %18
  %616 = load float, float addrspace(3)* %615, align 4, !tbaa !5
  %617 = fmul contract float %614, %616
  %618 = fadd contract float %612, %617
  %619 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 97
  %620 = load float, float addrspace(3)* %619, align 4, !tbaa !5
  %621 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 97, i32 %18
  %622 = load float, float addrspace(3)* %621, align 4, !tbaa !5
  %623 = fmul contract float %620, %622
  %624 = fadd contract float %618, %623
  %625 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 98
  %626 = load float, float addrspace(3)* %625, align 8, !tbaa !5
  %627 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 98, i32 %18
  %628 = load float, float addrspace(3)* %627, align 4, !tbaa !5
  %629 = fmul contract float %626, %628
  %630 = fadd contract float %624, %629
  %631 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 99
  %632 = load float, float addrspace(3)* %631, align 4, !tbaa !5
  %633 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 99, i32 %18
  %634 = load float, float addrspace(3)* %633, align 4, !tbaa !5
  %635 = fmul contract float %632, %634
  %636 = fadd contract float %630, %635
  %637 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 100
  %638 = load float, float addrspace(3)* %637, align 16, !tbaa !5
  %639 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 100, i32 %18
  %640 = load float, float addrspace(3)* %639, align 4, !tbaa !5
  %641 = fmul contract float %638, %640
  %642 = fadd contract float %636, %641
  %643 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 101
  %644 = load float, float addrspace(3)* %643, align 4, !tbaa !5
  %645 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 101, i32 %18
  %646 = load float, float addrspace(3)* %645, align 4, !tbaa !5
  %647 = fmul contract float %644, %646
  %648 = fadd contract float %642, %647
  %649 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 102
  %650 = load float, float addrspace(3)* %649, align 8, !tbaa !5
  %651 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 102, i32 %18
  %652 = load float, float addrspace(3)* %651, align 4, !tbaa !5
  %653 = fmul contract float %650, %652
  %654 = fadd contract float %648, %653
  %655 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 103
  %656 = load float, float addrspace(3)* %655, align 4, !tbaa !5
  %657 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 103, i32 %18
  %658 = load float, float addrspace(3)* %657, align 4, !tbaa !5
  %659 = fmul contract float %656, %658
  %660 = fadd contract float %654, %659
  %661 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 104
  %662 = load float, float addrspace(3)* %661, align 16, !tbaa !5
  %663 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 104, i32 %18
  %664 = load float, float addrspace(3)* %663, align 4, !tbaa !5
  %665 = fmul contract float %662, %664
  %666 = fadd contract float %660, %665
  %667 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 105
  %668 = load float, float addrspace(3)* %667, align 4, !tbaa !5
  %669 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 105, i32 %18
  %670 = load float, float addrspace(3)* %669, align 4, !tbaa !5
  %671 = fmul contract float %668, %670
  %672 = fadd contract float %666, %671
  %673 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 106
  %674 = load float, float addrspace(3)* %673, align 8, !tbaa !5
  %675 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 106, i32 %18
  %676 = load float, float addrspace(3)* %675, align 4, !tbaa !5
  %677 = fmul contract float %674, %676
  %678 = fadd contract float %672, %677
  %679 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 107
  %680 = load float, float addrspace(3)* %679, align 4, !tbaa !5
  %681 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 107, i32 %18
  %682 = load float, float addrspace(3)* %681, align 4, !tbaa !5
  %683 = fmul contract float %680, %682
  %684 = fadd contract float %678, %683
  %685 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 108
  %686 = load float, float addrspace(3)* %685, align 16, !tbaa !5
  %687 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 108, i32 %18
  %688 = load float, float addrspace(3)* %687, align 4, !tbaa !5
  %689 = fmul contract float %686, %688
  %690 = fadd contract float %684, %689
  %691 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 109
  %692 = load float, float addrspace(3)* %691, align 4, !tbaa !5
  %693 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 109, i32 %18
  %694 = load float, float addrspace(3)* %693, align 4, !tbaa !5
  %695 = fmul contract float %692, %694
  %696 = fadd contract float %690, %695
  %697 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 110
  %698 = load float, float addrspace(3)* %697, align 8, !tbaa !5
  %699 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 110, i32 %18
  %700 = load float, float addrspace(3)* %699, align 4, !tbaa !5
  %701 = fmul contract float %698, %700
  %702 = fadd contract float %696, %701
  %703 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 111
  %704 = load float, float addrspace(3)* %703, align 4, !tbaa !5
  %705 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 111, i32 %18
  %706 = load float, float addrspace(3)* %705, align 4, !tbaa !5
  %707 = fmul contract float %704, %706
  %708 = fadd contract float %702, %707
  %709 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 112
  %710 = load float, float addrspace(3)* %709, align 16, !tbaa !5
  %711 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 112, i32 %18
  %712 = load float, float addrspace(3)* %711, align 4, !tbaa !5
  %713 = fmul contract float %710, %712
  %714 = fadd contract float %708, %713
  %715 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 113
  %716 = load float, float addrspace(3)* %715, align 4, !tbaa !5
  %717 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 113, i32 %18
  %718 = load float, float addrspace(3)* %717, align 4, !tbaa !5
  %719 = fmul contract float %716, %718
  %720 = fadd contract float %714, %719
  %721 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 114
  %722 = load float, float addrspace(3)* %721, align 8, !tbaa !5
  %723 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 114, i32 %18
  %724 = load float, float addrspace(3)* %723, align 4, !tbaa !5
  %725 = fmul contract float %722, %724
  %726 = fadd contract float %720, %725
  %727 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 115
  %728 = load float, float addrspace(3)* %727, align 4, !tbaa !5
  %729 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 115, i32 %18
  %730 = load float, float addrspace(3)* %729, align 4, !tbaa !5
  %731 = fmul contract float %728, %730
  %732 = fadd contract float %726, %731
  %733 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 116
  %734 = load float, float addrspace(3)* %733, align 16, !tbaa !5
  %735 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 116, i32 %18
  %736 = load float, float addrspace(3)* %735, align 4, !tbaa !5
  %737 = fmul contract float %734, %736
  %738 = fadd contract float %732, %737
  %739 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 117
  %740 = load float, float addrspace(3)* %739, align 4, !tbaa !5
  %741 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 117, i32 %18
  %742 = load float, float addrspace(3)* %741, align 4, !tbaa !5
  %743 = fmul contract float %740, %742
  %744 = fadd contract float %738, %743
  %745 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 118
  %746 = load float, float addrspace(3)* %745, align 8, !tbaa !5
  %747 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 118, i32 %18
  %748 = load float, float addrspace(3)* %747, align 4, !tbaa !5
  %749 = fmul contract float %746, %748
  %750 = fadd contract float %744, %749
  %751 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 119
  %752 = load float, float addrspace(3)* %751, align 4, !tbaa !5
  %753 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 119, i32 %18
  %754 = load float, float addrspace(3)* %753, align 4, !tbaa !5
  %755 = fmul contract float %752, %754
  %756 = fadd contract float %750, %755
  %757 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 120
  %758 = load float, float addrspace(3)* %757, align 16, !tbaa !5
  %759 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 120, i32 %18
  %760 = load float, float addrspace(3)* %759, align 4, !tbaa !5
  %761 = fmul contract float %758, %760
  %762 = fadd contract float %756, %761
  %763 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 121
  %764 = load float, float addrspace(3)* %763, align 4, !tbaa !5
  %765 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 121, i32 %18
  %766 = load float, float addrspace(3)* %765, align 4, !tbaa !5
  %767 = fmul contract float %764, %766
  %768 = fadd contract float %762, %767
  %769 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 122
  %770 = load float, float addrspace(3)* %769, align 8, !tbaa !5
  %771 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 122, i32 %18
  %772 = load float, float addrspace(3)* %771, align 4, !tbaa !5
  %773 = fmul contract float %770, %772
  %774 = fadd contract float %768, %773
  %775 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 123
  %776 = load float, float addrspace(3)* %775, align 4, !tbaa !5
  %777 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 123, i32 %18
  %778 = load float, float addrspace(3)* %777, align 4, !tbaa !5
  %779 = fmul contract float %776, %778
  %780 = fadd contract float %774, %779
  %781 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 124
  %782 = load float, float addrspace(3)* %781, align 16, !tbaa !5
  %783 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 124, i32 %18
  %784 = load float, float addrspace(3)* %783, align 4, !tbaa !5
  %785 = fmul contract float %782, %784
  %786 = fadd contract float %780, %785
  %787 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 125
  %788 = load float, float addrspace(3)* %787, align 4, !tbaa !5
  %789 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 125, i32 %18
  %790 = load float, float addrspace(3)* %789, align 4, !tbaa !5
  %791 = fmul contract float %788, %790
  %792 = fadd contract float %786, %791
  %793 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 126
  %794 = load float, float addrspace(3)* %793, align 8, !tbaa !5
  %795 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 126, i32 %18
  %796 = load float, float addrspace(3)* %795, align 4, !tbaa !5
  %797 = fmul contract float %794, %796
  %798 = fadd contract float %792, %797
  %799 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_col, i32 0, i32 %12, i32 127
  %800 = load float, float addrspace(3)* %799, align 4, !tbaa !5
  %801 = getelementptr inbounds [128 x [128 x float]], [128 x [128 x float]] addrspace(3)* @_ZZ12lud_internalPfiiE8peri_row, i32 0, i32 127, i32 %18
  %802 = load float, float addrspace(3)* %801, align 4, !tbaa !5
  %803 = fmul contract float %800, %802
  %804 = fadd contract float %798, %803
  %805 = add i64 %20, %29
  %806 = getelementptr inbounds float, float addrspace(1)* %0, i64 %805
  %807 = load float, float addrspace(1)* %806, align 4, !tbaa !5
  %808 = fsub contract float %807, %804
  store float %808, float addrspace(1)* %806, align 4, !tbaa !5
  ret void
}

; Function Attrs: convergent nounwind willreturn
declare void @llvm.amdgcn.s.barrier() #1

; Function Attrs: nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.workitem.id.x() #2

; Function Attrs: nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.workitem.id.y() #2

; Function Attrs: nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.workgroup.id.x() #2

; Function Attrs: nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.workgroup.id.y() #2

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,1024" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { convergent nounwind willreturn }
attributes #2 = { nounwind readnone speculatable willreturn }
attributes #3 = { nounwind }

!llvm.module.flags = !{!0, !1}
!opencl.ocl.version = !{!2}
!llvm.ident = !{!3}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 1}
!2 = !{i32 2, i32 0}
!3 = !{!"clang version 12.0.0 (https://github.com/RadeonOpenCompute/llvm-project roc-4.2.0 21161 b204d7f0cae65b6cd4446eec50fc1fb675d582af)"}
!4 = !{i32 0, i32 1024}
!5 = !{!6, !6, i64 0}
!6 = !{!"float", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C++ TBAA"}
!9 = distinct !{!9, !10}
!10 = !{!"llvm.loop.mustprogress"}
!11 = distinct !{!11, !10}
!12 = distinct !{!12, !13}
!13 = !{!"llvm.loop.unroll.disable"}
!14 = distinct !{!14, !10}
!15 = distinct !{!15, !13}
!16 = distinct !{!16, !10}
!17 = distinct !{!17, !10}
!18 = distinct !{!18, !10}
!19 = distinct !{!19, !10}
!20 = distinct !{!20, !10}
!21 = distinct !{!21, !13}
!22 = distinct !{!22, !10}
!23 = distinct !{!23, !10}
!24 = distinct !{!24, !13}
!25 = distinct !{!25, !10}
!26 = distinct !{!26, !10}
!27 = distinct !{!27, !10}
