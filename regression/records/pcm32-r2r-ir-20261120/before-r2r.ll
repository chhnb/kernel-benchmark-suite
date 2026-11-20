; ModuleID = '/data/home/chh/simplify-v2/build/simplify-fingerprint/inputs/PCM32.ll'
source_filename = "/data/home/chh/kernel-benchmark-suite/build/full-regression-rerun/snapshot.TxCJ3u/artifact-benchmarks/benchmarks/PCM/pcm.hip.cpp"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

%"struct.__HIP_Coordinates<__HIP_ThreadIdx>::X" = type { i8 }
%"struct.__HIP_Coordinates<__HIP_BlockIdx>::X" = type { i8 }
%"struct.__HIP_Coordinates<__HIP_BlockDim>::X" = type { i8 }

$_ZN17__HIP_CoordinatesI15__HIP_ThreadIdxE1xE = comdat any

$_ZN17__HIP_CoordinatesI14__HIP_BlockIdxE1xE = comdat any

$_ZN17__HIP_CoordinatesI14__HIP_BlockDimE1xE = comdat any

@_ZN17__HIP_CoordinatesI15__HIP_ThreadIdxE1xE = weak protected local_unnamed_addr addrspace(4) externally_initialized constant %"struct.__HIP_Coordinates<__HIP_ThreadIdx>::X" undef, comdat, align 1
@_ZN17__HIP_CoordinatesI14__HIP_BlockIdxE1xE = weak protected local_unnamed_addr addrspace(4) externally_initialized constant %"struct.__HIP_Coordinates<__HIP_BlockIdx>::X" undef, comdat, align 1
@_ZN17__HIP_CoordinatesI14__HIP_BlockDimE1xE = weak protected local_unnamed_addr addrspace(4) externally_initialized constant %"struct.__HIP_Coordinates<__HIP_BlockDim>::X" undef, comdat, align 1
@_ZZ3pcmPiE2sR = internal unnamed_addr addrspace(3) global [8192 x i32] undef, align 16
@_ZZ3pcmPiE2sC = internal unnamed_addr addrspace(3) global [8192 x i32] undef, align 16

; Function Attrs: convergent norecurse nounwind
define protected amdgpu_kernel void @_Z3pcmPi(i32 addrspace(1)* nocapture %0) local_unnamed_addr #0 {
unify.bb:
  %1 = tail call i32 @llvm.amdgcn.workitem.id.x() #3, !range !5
  %2 = tail call i32 @llvm.amdgcn.workgroup.id.x() #3
  %3 = tail call align 4 dereferenceable(64) i8 addrspace(4)* @llvm.amdgcn.dispatch.ptr() #3
  %4 = getelementptr i8, i8 addrspace(4)* %3, i64 4
  %5 = bitcast i8 addrspace(4)* %4 to i16 addrspace(4)*
  %6 = load i16, i16 addrspace(4)* %5, align 4, !range !6, !invariant.load !7
  %7 = zext i16 %6 to i32
  %8 = mul i32 %2, %7
  %9 = add i32 %8, %1
  %10 = icmp slt i32 %9, 268435456
  %11 = shl nsw i32 %9, 8
  %12 = select i1 %10, i32 %11, i32 undef
  %13 = shl nuw nsw i32 %1, 8
  br i1 %10, label %merged.branch.split, label %merged.branch.split1

merged.branch.split:                              ; preds = %unify.bb, %merged.branch.split
  %14 = phi i32 [ %126, %merged.branch.split ], [ 0, %unify.bb ]
  %15 = add nuw nsw i32 %14, %12
  %16 = sext i32 %15 to i64
  %17 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %16
  %18 = load i32, i32 addrspace(1)* %17, align 4, !tbaa !8
  %19 = add nuw nsw i32 %14, %13
  %20 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %19
  store i32 %18, i32 addrspace(3)* %20, align 16, !tbaa !8
  %21 = or i32 %14, 1
  %22 = add nuw nsw i32 %21, %12
  %23 = sext i32 %22 to i64
  %24 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %23
  %25 = load i32, i32 addrspace(1)* %24, align 4, !tbaa !8
  %26 = add nuw nsw i32 %21, %13
  %27 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %26
  store i32 %25, i32 addrspace(3)* %27, align 4, !tbaa !8
  %28 = or i32 %14, 2
  %29 = add nuw nsw i32 %28, %12
  %30 = sext i32 %29 to i64
  %31 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %30
  %32 = load i32, i32 addrspace(1)* %31, align 4, !tbaa !8
  %33 = add nuw nsw i32 %28, %13
  %34 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %33
  store i32 %32, i32 addrspace(3)* %34, align 8, !tbaa !8
  %35 = or i32 %14, 3
  %36 = add nuw nsw i32 %35, %12
  %37 = sext i32 %36 to i64
  %38 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %37
  %39 = load i32, i32 addrspace(1)* %38, align 4, !tbaa !8
  %40 = add nuw nsw i32 %35, %13
  %41 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %40
  store i32 %39, i32 addrspace(3)* %41, align 4, !tbaa !8
  %42 = or i32 %14, 4
  %43 = add nuw nsw i32 %42, %12
  %44 = sext i32 %43 to i64
  %45 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %44
  %46 = load i32, i32 addrspace(1)* %45, align 4, !tbaa !8
  %47 = add nuw nsw i32 %42, %13
  %48 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %47
  store i32 %46, i32 addrspace(3)* %48, align 16, !tbaa !8
  %49 = or i32 %14, 5
  %50 = add nuw nsw i32 %49, %12
  %51 = sext i32 %50 to i64
  %52 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %51
  %53 = load i32, i32 addrspace(1)* %52, align 4, !tbaa !8
  %54 = add nuw nsw i32 %49, %13
  %55 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %54
  store i32 %53, i32 addrspace(3)* %55, align 4, !tbaa !8
  %56 = or i32 %14, 6
  %57 = add nuw nsw i32 %56, %12
  %58 = sext i32 %57 to i64
  %59 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %58
  %60 = load i32, i32 addrspace(1)* %59, align 4, !tbaa !8
  %61 = add nuw nsw i32 %56, %13
  %62 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %61
  store i32 %60, i32 addrspace(3)* %62, align 8, !tbaa !8
  %63 = or i32 %14, 7
  %64 = add nuw nsw i32 %63, %12
  %65 = sext i32 %64 to i64
  %66 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %65
  %67 = load i32, i32 addrspace(1)* %66, align 4, !tbaa !8
  %68 = add nuw nsw i32 %63, %13
  %69 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %68
  store i32 %67, i32 addrspace(3)* %69, align 4, !tbaa !8
  %70 = or i32 %14, 8
  %71 = add nuw nsw i32 %70, %12
  %72 = sext i32 %71 to i64
  %73 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %72
  %74 = load i32, i32 addrspace(1)* %73, align 4, !tbaa !8
  %75 = add nuw nsw i32 %70, %13
  %76 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %75
  store i32 %74, i32 addrspace(3)* %76, align 16, !tbaa !8
  %77 = or i32 %14, 9
  %78 = add nuw nsw i32 %77, %12
  %79 = sext i32 %78 to i64
  %80 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %79
  %81 = load i32, i32 addrspace(1)* %80, align 4, !tbaa !8
  %82 = add nuw nsw i32 %77, %13
  %83 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %82
  store i32 %81, i32 addrspace(3)* %83, align 4, !tbaa !8
  %84 = or i32 %14, 10
  %85 = add nuw nsw i32 %84, %12
  %86 = sext i32 %85 to i64
  %87 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %86
  %88 = load i32, i32 addrspace(1)* %87, align 4, !tbaa !8
  %89 = add nuw nsw i32 %84, %13
  %90 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %89
  store i32 %88, i32 addrspace(3)* %90, align 8, !tbaa !8
  %91 = or i32 %14, 11
  %92 = add nuw nsw i32 %91, %12
  %93 = sext i32 %92 to i64
  %94 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %93
  %95 = load i32, i32 addrspace(1)* %94, align 4, !tbaa !8
  %96 = add nuw nsw i32 %91, %13
  %97 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %96
  store i32 %95, i32 addrspace(3)* %97, align 4, !tbaa !8
  %98 = or i32 %14, 12
  %99 = add nuw nsw i32 %98, %12
  %100 = sext i32 %99 to i64
  %101 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %100
  %102 = load i32, i32 addrspace(1)* %101, align 4, !tbaa !8
  %103 = add nuw nsw i32 %98, %13
  %104 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %103
  store i32 %102, i32 addrspace(3)* %104, align 16, !tbaa !8
  %105 = or i32 %14, 13
  %106 = add nuw nsw i32 %105, %12
  %107 = sext i32 %106 to i64
  %108 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %107
  %109 = load i32, i32 addrspace(1)* %108, align 4, !tbaa !8
  %110 = add nuw nsw i32 %105, %13
  %111 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %110
  store i32 %109, i32 addrspace(3)* %111, align 4, !tbaa !8
  %112 = or i32 %14, 14
  %113 = add nuw nsw i32 %112, %12
  %114 = sext i32 %113 to i64
  %115 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %114
  %116 = load i32, i32 addrspace(1)* %115, align 4, !tbaa !8
  %117 = add nuw nsw i32 %112, %13
  %118 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %117
  store i32 %116, i32 addrspace(3)* %118, align 8, !tbaa !8
  %119 = or i32 %14, 15
  %120 = add nuw nsw i32 %119, %12
  %121 = sext i32 %120 to i64
  %122 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %121
  %123 = load i32, i32 addrspace(1)* %122, align 4, !tbaa !8
  %124 = add nuw nsw i32 %119, %13
  %125 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %124
  store i32 %123, i32 addrspace(3)* %125, align 4, !tbaa !8
  %126 = add nuw nsw i32 %14, 16
  %127 = icmp eq i32 %126, 256
  br i1 %127, label %merged.branch.split1, label %merged.branch.split, !llvm.loop !12

merged.branch.split1:                             ; preds = %unify.bb, %merged.branch.split
  %128 = phi i32 [ %13, %merged.branch.split ], [ %13, %unify.bb ]
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %129 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sR, i32 0, i32 %128
  %130 = and i32 %1, 1
  %131 = icmp ne i32 %130, 0
  %132 = icmp ult i32 %1, 31
  %133 = xor i1 %131, true
  %134 = and i1 %132, %133
  %135 = add nsw i32 %128, -256
  %136 = add nuw nsw i32 %128, 256
  %137 = icmp ult i32 %1, 32
  %138 = and i1 %132, %131
  %139 = icmp eq i32 %1, 0
  br label %143

140:                                              ; preds = %695
  br i1 %10, label %141, label %813

141:                                              ; preds = %140
  %142 = shl nsw i32 %9, 8
  br label %698

143:                                              ; preds = %695, %merged.branch.split1
  %144 = phi i32 [ 0, %merged.branch.split1 ], [ %696, %695 ]
  br i1 %134, label %145, label %unify.bb2

145:                                              ; preds = %145, %143
  %146 = phi i32 [ %268, %145 ], [ 0, %143 ]
  %147 = phi i32 [ %266, %145 ], [ 0, %143 ]
  %148 = phi i32 [ %264, %145 ], [ 0, %143 ]
  %149 = add nsw i32 %148, %128
  %150 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %149
  %151 = load i32, i32 addrspace(3)* %150, align 4, !tbaa !8
  %152 = add nsw i32 %136, %147
  %153 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %152
  %154 = load i32, i32 addrspace(3)* %153, align 4, !tbaa !8
  %155 = icmp sgt i32 %151, %154
  %156 = select i1 %155, i32 %154, i32 %151
  %157 = xor i1 %155, true
  %158 = zext i1 %157 to i32
  %159 = add nuw nsw i32 %148, %158
  %160 = zext i1 %155 to i32
  %161 = add nuw nsw i32 %147, %160
  %162 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %146
  store i32 %156, i32 addrspace(3)* %162, align 16
  %163 = or i32 %146, 1
  %164 = add nsw i32 %159, %128
  %165 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %164
  %166 = load i32, i32 addrspace(3)* %165, align 4, !tbaa !8
  %167 = add nsw i32 %136, %161
  %168 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %167
  %169 = load i32, i32 addrspace(3)* %168, align 4, !tbaa !8
  %170 = icmp sgt i32 %166, %169
  %171 = select i1 %170, i32 %169, i32 %166
  %172 = xor i1 %170, true
  %173 = zext i1 %172 to i32
  %174 = add nuw nsw i32 %159, %173
  %175 = zext i1 %170 to i32
  %176 = add nuw nsw i32 %161, %175
  %177 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %163
  store i32 %171, i32 addrspace(3)* %177, align 4
  %178 = or i32 %146, 2
  %179 = add nsw i32 %174, %128
  %180 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %179
  %181 = load i32, i32 addrspace(3)* %180, align 4, !tbaa !8
  %182 = add nsw i32 %136, %176
  %183 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %182
  %184 = load i32, i32 addrspace(3)* %183, align 4, !tbaa !8
  %185 = icmp sgt i32 %181, %184
  %186 = select i1 %185, i32 %184, i32 %181
  %187 = xor i1 %185, true
  %188 = zext i1 %187 to i32
  %189 = add nuw nsw i32 %174, %188
  %190 = zext i1 %185 to i32
  %191 = add nuw nsw i32 %176, %190
  %192 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %178
  store i32 %186, i32 addrspace(3)* %192, align 8
  %193 = or i32 %146, 3
  %194 = add nsw i32 %189, %128
  %195 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %194
  %196 = load i32, i32 addrspace(3)* %195, align 4, !tbaa !8
  %197 = add nsw i32 %136, %191
  %198 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %197
  %199 = load i32, i32 addrspace(3)* %198, align 4, !tbaa !8
  %200 = icmp sgt i32 %196, %199
  %201 = select i1 %200, i32 %199, i32 %196
  %202 = xor i1 %200, true
  %203 = zext i1 %202 to i32
  %204 = add nuw nsw i32 %189, %203
  %205 = zext i1 %200 to i32
  %206 = add nuw nsw i32 %191, %205
  %207 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %193
  store i32 %201, i32 addrspace(3)* %207, align 4
  %208 = or i32 %146, 4
  %209 = add nsw i32 %204, %128
  %210 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %209
  %211 = load i32, i32 addrspace(3)* %210, align 4, !tbaa !8
  %212 = add nsw i32 %136, %206
  %213 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %212
  %214 = load i32, i32 addrspace(3)* %213, align 4, !tbaa !8
  %215 = icmp sgt i32 %211, %214
  %216 = select i1 %215, i32 %214, i32 %211
  %217 = xor i1 %215, true
  %218 = zext i1 %217 to i32
  %219 = add nuw nsw i32 %204, %218
  %220 = zext i1 %215 to i32
  %221 = add nuw nsw i32 %206, %220
  %222 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %208
  store i32 %216, i32 addrspace(3)* %222, align 16
  %223 = or i32 %146, 5
  %224 = add nsw i32 %219, %128
  %225 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %224
  %226 = load i32, i32 addrspace(3)* %225, align 4, !tbaa !8
  %227 = add nsw i32 %136, %221
  %228 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %227
  %229 = load i32, i32 addrspace(3)* %228, align 4, !tbaa !8
  %230 = icmp sgt i32 %226, %229
  %231 = select i1 %230, i32 %229, i32 %226
  %232 = xor i1 %230, true
  %233 = zext i1 %232 to i32
  %234 = add nuw nsw i32 %219, %233
  %235 = zext i1 %230 to i32
  %236 = add nuw nsw i32 %221, %235
  %237 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %223
  store i32 %231, i32 addrspace(3)* %237, align 4
  %238 = or i32 %146, 6
  %239 = add nsw i32 %234, %128
  %240 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %239
  %241 = load i32, i32 addrspace(3)* %240, align 4, !tbaa !8
  %242 = add nsw i32 %136, %236
  %243 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %242
  %244 = load i32, i32 addrspace(3)* %243, align 4, !tbaa !8
  %245 = icmp sgt i32 %241, %244
  %246 = select i1 %245, i32 %244, i32 %241
  %247 = xor i1 %245, true
  %248 = zext i1 %247 to i32
  %249 = add nuw nsw i32 %234, %248
  %250 = zext i1 %245 to i32
  %251 = add nuw nsw i32 %236, %250
  %252 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %238
  store i32 %246, i32 addrspace(3)* %252, align 8
  %253 = or i32 %146, 7
  %254 = add nsw i32 %249, %128
  %255 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %254
  %256 = load i32, i32 addrspace(3)* %255, align 4, !tbaa !8
  %257 = add nsw i32 %136, %251
  %258 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %257
  %259 = load i32, i32 addrspace(3)* %258, align 4, !tbaa !8
  %260 = icmp sgt i32 %256, %259
  %261 = select i1 %260, i32 %259, i32 %256
  %262 = xor i1 %260, true
  %263 = zext i1 %262 to i32
  %264 = add nuw nsw i32 %249, %263
  %265 = zext i1 %260 to i32
  %266 = add nuw nsw i32 %251, %265
  %267 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %253
  store i32 %261, i32 addrspace(3)* %267, align 4
  %268 = add nuw nsw i32 %146, 8
  %269 = icmp eq i32 %268, 256
  br i1 %269, label %371, label %145, !llvm.loop !14

unify.bb2:                                        ; preds = %unify.bb2, %143
  %270 = phi i32 [ %369, %unify.bb2 ], [ 0, %143 ]
  %271 = phi i32 [ %368, %unify.bb2 ], [ 255, %143 ]
  %272 = phi i32 [ %367, %unify.bb2 ], [ 255, %143 ]
  %273 = add nsw i32 %271, %128
  %274 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %273
  %275 = load i32, i32 addrspace(3)* %274, align 4, !tbaa !8
  %276 = add nsw i32 %135, %272
  %277 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %276
  %278 = load i32, i32 addrspace(3)* %277, align 4, !tbaa !8
  %279 = icmp sgt i32 %275, %278
  %280 = sub nuw nsw i32 255, %270
  %281 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %280
  %merged.select = select i1 %279, i32 %275, i32 %278
  store i32 %merged.select, i32 addrspace(3)* %281, align 4, !tbaa !8
  %merged.select3 = select i1 %279, i32 %271, i32 %272
  %282 = add nsw i32 %merged.select3, -1
  %283 = select i1 %279, i32 %272, i32 %282
  %284 = select i1 %279, i32 %282, i32 %271
  %285 = add nsw i32 %284, %128
  %286 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %285
  %287 = load i32, i32 addrspace(3)* %286, align 4, !tbaa !8
  %288 = add nsw i32 %135, %283
  %289 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %288
  %290 = load i32, i32 addrspace(3)* %289, align 4, !tbaa !8
  %291 = icmp sgt i32 %287, %290
  %292 = sub nsw i32 254, %270
  %293 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %292
  %merged.select7 = select i1 %291, i32 %287, i32 %290
  store i32 %merged.select7, i32 addrspace(3)* %293, align 8, !tbaa !8
  %merged.select8 = select i1 %291, i32 %284, i32 %283
  %294 = add nsw i32 %merged.select8, -1
  %295 = select i1 %291, i32 %283, i32 %294
  %296 = select i1 %291, i32 %294, i32 %284
  %297 = add nsw i32 %296, %128
  %298 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %297
  %299 = load i32, i32 addrspace(3)* %298, align 4, !tbaa !8
  %300 = add nsw i32 %135, %295
  %301 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %300
  %302 = load i32, i32 addrspace(3)* %301, align 4, !tbaa !8
  %303 = icmp sgt i32 %299, %302
  %304 = sub nsw i32 253, %270
  %305 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %304
  %merged.select12 = select i1 %303, i32 %299, i32 %302
  store i32 %merged.select12, i32 addrspace(3)* %305, align 4, !tbaa !8
  %merged.select13 = select i1 %303, i32 %296, i32 %295
  %306 = add nsw i32 %merged.select13, -1
  %307 = select i1 %303, i32 %295, i32 %306
  %308 = select i1 %303, i32 %306, i32 %296
  %309 = add nsw i32 %308, %128
  %310 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %309
  %311 = load i32, i32 addrspace(3)* %310, align 4, !tbaa !8
  %312 = add nsw i32 %135, %307
  %313 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %312
  %314 = load i32, i32 addrspace(3)* %313, align 4, !tbaa !8
  %315 = icmp sgt i32 %311, %314
  %316 = sub nsw i32 252, %270
  %317 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %316
  %merged.select17 = select i1 %315, i32 %311, i32 %314
  store i32 %merged.select17, i32 addrspace(3)* %317, align 16, !tbaa !8
  %merged.select18 = select i1 %315, i32 %308, i32 %307
  %318 = add nsw i32 %merged.select18, -1
  %319 = select i1 %315, i32 %307, i32 %318
  %320 = select i1 %315, i32 %318, i32 %308
  %321 = add nsw i32 %320, %128
  %322 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %321
  %323 = load i32, i32 addrspace(3)* %322, align 4, !tbaa !8
  %324 = add nsw i32 %135, %319
  %325 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %324
  %326 = load i32, i32 addrspace(3)* %325, align 4, !tbaa !8
  %327 = icmp sgt i32 %323, %326
  %328 = sub nsw i32 251, %270
  %329 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %328
  %merged.select22 = select i1 %327, i32 %323, i32 %326
  store i32 %merged.select22, i32 addrspace(3)* %329, align 4, !tbaa !8
  %merged.select23 = select i1 %327, i32 %320, i32 %319
  %330 = add nsw i32 %merged.select23, -1
  %331 = select i1 %327, i32 %319, i32 %330
  %332 = select i1 %327, i32 %330, i32 %320
  %333 = add nsw i32 %332, %128
  %334 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %333
  %335 = load i32, i32 addrspace(3)* %334, align 4, !tbaa !8
  %336 = add nsw i32 %135, %331
  %337 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %336
  %338 = load i32, i32 addrspace(3)* %337, align 4, !tbaa !8
  %339 = icmp sgt i32 %335, %338
  %340 = sub nsw i32 250, %270
  %341 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %340
  %merged.select27 = select i1 %339, i32 %335, i32 %338
  store i32 %merged.select27, i32 addrspace(3)* %341, align 8, !tbaa !8
  %merged.select28 = select i1 %339, i32 %332, i32 %331
  %342 = add nsw i32 %merged.select28, -1
  %343 = select i1 %339, i32 %331, i32 %342
  %344 = select i1 %339, i32 %342, i32 %332
  %345 = add nsw i32 %344, %128
  %346 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %345
  %347 = load i32, i32 addrspace(3)* %346, align 4, !tbaa !8
  %348 = add nsw i32 %135, %343
  %349 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %348
  %350 = load i32, i32 addrspace(3)* %349, align 4, !tbaa !8
  %351 = icmp sgt i32 %347, %350
  %352 = sub nsw i32 249, %270
  %353 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %352
  %merged.select32 = select i1 %351, i32 %347, i32 %350
  store i32 %merged.select32, i32 addrspace(3)* %353, align 4, !tbaa !8
  %merged.select33 = select i1 %351, i32 %344, i32 %343
  %354 = add nsw i32 %merged.select33, -1
  %355 = select i1 %351, i32 %343, i32 %354
  %356 = select i1 %351, i32 %354, i32 %344
  %357 = add nsw i32 %356, %128
  %358 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %357
  %359 = load i32, i32 addrspace(3)* %358, align 4, !tbaa !8
  %360 = add nsw i32 %135, %355
  %361 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %360
  %362 = load i32, i32 addrspace(3)* %361, align 4, !tbaa !8
  %363 = icmp sgt i32 %359, %362
  %364 = sub nsw i32 248, %270
  %365 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %364
  %merged.select37 = select i1 %363, i32 %359, i32 %362
  store i32 %merged.select37, i32 addrspace(3)* %365, align 16, !tbaa !8
  %merged.select38 = select i1 %363, i32 %356, i32 %355
  %366 = add nsw i32 %merged.select38, -1
  %367 = select i1 %363, i32 %355, i32 %366
  %368 = select i1 %363, i32 %366, i32 %356
  %369 = add nuw nsw i32 %270, 8
  %370 = icmp eq i32 %369, 256
  br i1 %370, label %371, label %unify.bb2, !llvm.loop !15

371:                                              ; preds = %unify.bb2, %145
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %137, label %372, label %455

372:                                              ; preds = %372, %371
  %373 = phi i32 [ %453, %372 ], [ 0, %371 ]
  %374 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %373
  %375 = load i32, i32 addrspace(3)* %374, align 16, !tbaa !8
  %376 = add nuw nsw i32 %373, %128
  %377 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %376
  store i32 %375, i32 addrspace(3)* %377, align 16, !tbaa !8
  %378 = or i32 %373, 1
  %379 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %378
  %380 = load i32, i32 addrspace(3)* %379, align 4, !tbaa !8
  %381 = add nuw nsw i32 %378, %128
  %382 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %381
  store i32 %380, i32 addrspace(3)* %382, align 4, !tbaa !8
  %383 = or i32 %373, 2
  %384 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %383
  %385 = load i32, i32 addrspace(3)* %384, align 8, !tbaa !8
  %386 = add nuw nsw i32 %383, %128
  %387 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %386
  store i32 %385, i32 addrspace(3)* %387, align 8, !tbaa !8
  %388 = or i32 %373, 3
  %389 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %388
  %390 = load i32, i32 addrspace(3)* %389, align 4, !tbaa !8
  %391 = add nuw nsw i32 %388, %128
  %392 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %391
  store i32 %390, i32 addrspace(3)* %392, align 4, !tbaa !8
  %393 = or i32 %373, 4
  %394 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %393
  %395 = load i32, i32 addrspace(3)* %394, align 16, !tbaa !8
  %396 = add nuw nsw i32 %393, %128
  %397 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %396
  store i32 %395, i32 addrspace(3)* %397, align 16, !tbaa !8
  %398 = or i32 %373, 5
  %399 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %398
  %400 = load i32, i32 addrspace(3)* %399, align 4, !tbaa !8
  %401 = add nuw nsw i32 %398, %128
  %402 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %401
  store i32 %400, i32 addrspace(3)* %402, align 4, !tbaa !8
  %403 = or i32 %373, 6
  %404 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %403
  %405 = load i32, i32 addrspace(3)* %404, align 8, !tbaa !8
  %406 = add nuw nsw i32 %403, %128
  %407 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %406
  store i32 %405, i32 addrspace(3)* %407, align 8, !tbaa !8
  %408 = or i32 %373, 7
  %409 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %408
  %410 = load i32, i32 addrspace(3)* %409, align 4, !tbaa !8
  %411 = add nuw nsw i32 %408, %128
  %412 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %411
  store i32 %410, i32 addrspace(3)* %412, align 4, !tbaa !8
  %413 = or i32 %373, 8
  %414 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %413
  %415 = load i32, i32 addrspace(3)* %414, align 16, !tbaa !8
  %416 = add nuw nsw i32 %413, %128
  %417 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %416
  store i32 %415, i32 addrspace(3)* %417, align 16, !tbaa !8
  %418 = or i32 %373, 9
  %419 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %418
  %420 = load i32, i32 addrspace(3)* %419, align 4, !tbaa !8
  %421 = add nuw nsw i32 %418, %128
  %422 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %421
  store i32 %420, i32 addrspace(3)* %422, align 4, !tbaa !8
  %423 = or i32 %373, 10
  %424 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %423
  %425 = load i32, i32 addrspace(3)* %424, align 8, !tbaa !8
  %426 = add nuw nsw i32 %423, %128
  %427 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %426
  store i32 %425, i32 addrspace(3)* %427, align 8, !tbaa !8
  %428 = or i32 %373, 11
  %429 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %428
  %430 = load i32, i32 addrspace(3)* %429, align 4, !tbaa !8
  %431 = add nuw nsw i32 %428, %128
  %432 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %431
  store i32 %430, i32 addrspace(3)* %432, align 4, !tbaa !8
  %433 = or i32 %373, 12
  %434 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %433
  %435 = load i32, i32 addrspace(3)* %434, align 16, !tbaa !8
  %436 = add nuw nsw i32 %433, %128
  %437 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %436
  store i32 %435, i32 addrspace(3)* %437, align 16, !tbaa !8
  %438 = or i32 %373, 13
  %439 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %438
  %440 = load i32, i32 addrspace(3)* %439, align 4, !tbaa !8
  %441 = add nuw nsw i32 %438, %128
  %442 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %441
  store i32 %440, i32 addrspace(3)* %442, align 4, !tbaa !8
  %443 = or i32 %373, 14
  %444 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %443
  %445 = load i32, i32 addrspace(3)* %444, align 8, !tbaa !8
  %446 = add nuw nsw i32 %443, %128
  %447 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %446
  store i32 %445, i32 addrspace(3)* %447, align 8, !tbaa !8
  %448 = or i32 %373, 15
  %449 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %448
  %450 = load i32, i32 addrspace(3)* %449, align 4, !tbaa !8
  %451 = add nuw nsw i32 %448, %128
  %452 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %451
  store i32 %450, i32 addrspace(3)* %452, align 4, !tbaa !8
  %453 = add nuw nsw i32 %373, 16
  %454 = icmp eq i32 %453, 256
  br i1 %454, label %455, label %372, !llvm.loop !16

455:                                              ; preds = %372, %371
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %138, label %456, label %581

456:                                              ; preds = %456, %455
  %457 = phi i32 [ %579, %456 ], [ 0, %455 ]
  %458 = phi i32 [ %577, %456 ], [ 0, %455 ]
  %459 = phi i32 [ %575, %456 ], [ 0, %455 ]
  %460 = add nsw i32 %459, %128
  %461 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %460
  %462 = load i32, i32 addrspace(3)* %461, align 4, !tbaa !8
  %463 = add nsw i32 %136, %458
  %464 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %463
  %465 = load i32, i32 addrspace(3)* %464, align 4, !tbaa !8
  %466 = icmp sgt i32 %462, %465
  %467 = select i1 %466, i32 %465, i32 %462
  %468 = xor i1 %466, true
  %469 = zext i1 %468 to i32
  %470 = add nuw nsw i32 %459, %469
  %471 = zext i1 %466 to i32
  %472 = add nuw nsw i32 %458, %471
  %473 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %457
  store i32 %467, i32 addrspace(3)* %473, align 16
  %474 = or i32 %457, 1
  %475 = add nsw i32 %470, %128
  %476 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %475
  %477 = load i32, i32 addrspace(3)* %476, align 4, !tbaa !8
  %478 = add nsw i32 %136, %472
  %479 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %478
  %480 = load i32, i32 addrspace(3)* %479, align 4, !tbaa !8
  %481 = icmp sgt i32 %477, %480
  %482 = select i1 %481, i32 %480, i32 %477
  %483 = xor i1 %481, true
  %484 = zext i1 %483 to i32
  %485 = add nuw nsw i32 %470, %484
  %486 = zext i1 %481 to i32
  %487 = add nuw nsw i32 %472, %486
  %488 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %474
  store i32 %482, i32 addrspace(3)* %488, align 4
  %489 = or i32 %457, 2
  %490 = add nsw i32 %485, %128
  %491 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %490
  %492 = load i32, i32 addrspace(3)* %491, align 4, !tbaa !8
  %493 = add nsw i32 %136, %487
  %494 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %493
  %495 = load i32, i32 addrspace(3)* %494, align 4, !tbaa !8
  %496 = icmp sgt i32 %492, %495
  %497 = select i1 %496, i32 %495, i32 %492
  %498 = xor i1 %496, true
  %499 = zext i1 %498 to i32
  %500 = add nuw nsw i32 %485, %499
  %501 = zext i1 %496 to i32
  %502 = add nuw nsw i32 %487, %501
  %503 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %489
  store i32 %497, i32 addrspace(3)* %503, align 8
  %504 = or i32 %457, 3
  %505 = add nsw i32 %500, %128
  %506 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %505
  %507 = load i32, i32 addrspace(3)* %506, align 4, !tbaa !8
  %508 = add nsw i32 %136, %502
  %509 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %508
  %510 = load i32, i32 addrspace(3)* %509, align 4, !tbaa !8
  %511 = icmp sgt i32 %507, %510
  %512 = select i1 %511, i32 %510, i32 %507
  %513 = xor i1 %511, true
  %514 = zext i1 %513 to i32
  %515 = add nuw nsw i32 %500, %514
  %516 = zext i1 %511 to i32
  %517 = add nuw nsw i32 %502, %516
  %518 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %504
  store i32 %512, i32 addrspace(3)* %518, align 4
  %519 = or i32 %457, 4
  %520 = add nsw i32 %515, %128
  %521 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %520
  %522 = load i32, i32 addrspace(3)* %521, align 4, !tbaa !8
  %523 = add nsw i32 %136, %517
  %524 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %523
  %525 = load i32, i32 addrspace(3)* %524, align 4, !tbaa !8
  %526 = icmp sgt i32 %522, %525
  %527 = select i1 %526, i32 %525, i32 %522
  %528 = xor i1 %526, true
  %529 = zext i1 %528 to i32
  %530 = add nuw nsw i32 %515, %529
  %531 = zext i1 %526 to i32
  %532 = add nuw nsw i32 %517, %531
  %533 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %519
  store i32 %527, i32 addrspace(3)* %533, align 16
  %534 = or i32 %457, 5
  %535 = add nsw i32 %530, %128
  %536 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %535
  %537 = load i32, i32 addrspace(3)* %536, align 4, !tbaa !8
  %538 = add nsw i32 %136, %532
  %539 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %538
  %540 = load i32, i32 addrspace(3)* %539, align 4, !tbaa !8
  %541 = icmp sgt i32 %537, %540
  %542 = select i1 %541, i32 %540, i32 %537
  %543 = xor i1 %541, true
  %544 = zext i1 %543 to i32
  %545 = add nuw nsw i32 %530, %544
  %546 = zext i1 %541 to i32
  %547 = add nuw nsw i32 %532, %546
  %548 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %534
  store i32 %542, i32 addrspace(3)* %548, align 4
  %549 = or i32 %457, 6
  %550 = add nsw i32 %545, %128
  %551 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %550
  %552 = load i32, i32 addrspace(3)* %551, align 4, !tbaa !8
  %553 = add nsw i32 %136, %547
  %554 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %553
  %555 = load i32, i32 addrspace(3)* %554, align 4, !tbaa !8
  %556 = icmp sgt i32 %552, %555
  %557 = select i1 %556, i32 %555, i32 %552
  %558 = xor i1 %556, true
  %559 = zext i1 %558 to i32
  %560 = add nuw nsw i32 %545, %559
  %561 = zext i1 %556 to i32
  %562 = add nuw nsw i32 %547, %561
  %563 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %549
  store i32 %557, i32 addrspace(3)* %563, align 8
  %564 = or i32 %457, 7
  %565 = add nsw i32 %560, %128
  %566 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %565
  %567 = load i32, i32 addrspace(3)* %566, align 4, !tbaa !8
  %568 = add nsw i32 %136, %562
  %569 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %568
  %570 = load i32, i32 addrspace(3)* %569, align 4, !tbaa !8
  %571 = icmp sgt i32 %567, %570
  %572 = select i1 %571, i32 %570, i32 %567
  %573 = xor i1 %571, true
  %574 = zext i1 %573 to i32
  %575 = add nuw nsw i32 %560, %574
  %576 = zext i1 %571 to i32
  %577 = add nuw nsw i32 %562, %576
  %578 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %564
  store i32 %572, i32 addrspace(3)* %578, align 4
  %579 = add nuw nsw i32 %457, 8
  %580 = icmp eq i32 %579, 256
  br i1 %580, label %611, label %456, !llvm.loop !17

581:                                              ; preds = %455
  br i1 %139, label %611, label %582

582:                                              ; preds = %914, %581
  %583 = phi i32 [ %917, %914 ], [ 0, %581 ]
  %584 = phi i32 [ %916, %914 ], [ 255, %581 ]
  %585 = phi i32 [ %915, %914 ], [ 255, %581 ]
  %586 = add nsw i32 %584, %128
  %587 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %586
  %588 = load i32, i32 addrspace(3)* %587, align 4, !tbaa !8
  %589 = add nsw i32 %135, %585
  %590 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %589
  %591 = load i32, i32 addrspace(3)* %590, align 4, !tbaa !8
  %592 = icmp sgt i32 %588, %591
  %593 = sub nuw nsw i32 255, %583
  %594 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %593
  br i1 %592, label %595, label %597

595:                                              ; preds = %582
  store i32 %588, i32 addrspace(3)* %594, align 4, !tbaa !8
  %596 = add nsw i32 %584, -1
  br label %599

597:                                              ; preds = %582
  store i32 %591, i32 addrspace(3)* %594, align 4, !tbaa !8
  %598 = add nsw i32 %585, -1
  br label %599

599:                                              ; preds = %597, %595
  %600 = phi i32 [ %585, %595 ], [ %598, %597 ]
  %601 = phi i32 [ %596, %595 ], [ %584, %597 ]
  %602 = add nsw i32 %601, %128
  %603 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %602
  %604 = load i32, i32 addrspace(3)* %603, align 4, !tbaa !8
  %605 = add nsw i32 %135, %600
  %606 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %605
  %607 = load i32, i32 addrspace(3)* %606, align 4, !tbaa !8
  %608 = icmp sgt i32 %604, %607
  %609 = sub nsw i32 254, %583
  %610 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %609
  br i1 %608, label %816, label %814

611:                                              ; preds = %914, %581, %456
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %137, label %612, label %695

612:                                              ; preds = %612, %611
  %613 = phi i32 [ %693, %612 ], [ 0, %611 ]
  %614 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %613
  %615 = load i32, i32 addrspace(3)* %614, align 16, !tbaa !8
  %616 = add nuw nsw i32 %613, %128
  %617 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %616
  store i32 %615, i32 addrspace(3)* %617, align 16, !tbaa !8
  %618 = or i32 %613, 1
  %619 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %618
  %620 = load i32, i32 addrspace(3)* %619, align 4, !tbaa !8
  %621 = add nuw nsw i32 %618, %128
  %622 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %621
  store i32 %620, i32 addrspace(3)* %622, align 4, !tbaa !8
  %623 = or i32 %613, 2
  %624 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %623
  %625 = load i32, i32 addrspace(3)* %624, align 8, !tbaa !8
  %626 = add nuw nsw i32 %623, %128
  %627 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %626
  store i32 %625, i32 addrspace(3)* %627, align 8, !tbaa !8
  %628 = or i32 %613, 3
  %629 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %628
  %630 = load i32, i32 addrspace(3)* %629, align 4, !tbaa !8
  %631 = add nuw nsw i32 %628, %128
  %632 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %631
  store i32 %630, i32 addrspace(3)* %632, align 4, !tbaa !8
  %633 = or i32 %613, 4
  %634 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %633
  %635 = load i32, i32 addrspace(3)* %634, align 16, !tbaa !8
  %636 = add nuw nsw i32 %633, %128
  %637 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %636
  store i32 %635, i32 addrspace(3)* %637, align 16, !tbaa !8
  %638 = or i32 %613, 5
  %639 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %638
  %640 = load i32, i32 addrspace(3)* %639, align 4, !tbaa !8
  %641 = add nuw nsw i32 %638, %128
  %642 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %641
  store i32 %640, i32 addrspace(3)* %642, align 4, !tbaa !8
  %643 = or i32 %613, 6
  %644 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %643
  %645 = load i32, i32 addrspace(3)* %644, align 8, !tbaa !8
  %646 = add nuw nsw i32 %643, %128
  %647 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %646
  store i32 %645, i32 addrspace(3)* %647, align 8, !tbaa !8
  %648 = or i32 %613, 7
  %649 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %648
  %650 = load i32, i32 addrspace(3)* %649, align 4, !tbaa !8
  %651 = add nuw nsw i32 %648, %128
  %652 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %651
  store i32 %650, i32 addrspace(3)* %652, align 4, !tbaa !8
  %653 = or i32 %613, 8
  %654 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %653
  %655 = load i32, i32 addrspace(3)* %654, align 16, !tbaa !8
  %656 = add nuw nsw i32 %653, %128
  %657 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %656
  store i32 %655, i32 addrspace(3)* %657, align 16, !tbaa !8
  %658 = or i32 %613, 9
  %659 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %658
  %660 = load i32, i32 addrspace(3)* %659, align 4, !tbaa !8
  %661 = add nuw nsw i32 %658, %128
  %662 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %661
  store i32 %660, i32 addrspace(3)* %662, align 4, !tbaa !8
  %663 = or i32 %613, 10
  %664 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %663
  %665 = load i32, i32 addrspace(3)* %664, align 8, !tbaa !8
  %666 = add nuw nsw i32 %663, %128
  %667 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %666
  store i32 %665, i32 addrspace(3)* %667, align 8, !tbaa !8
  %668 = or i32 %613, 11
  %669 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %668
  %670 = load i32, i32 addrspace(3)* %669, align 4, !tbaa !8
  %671 = add nuw nsw i32 %668, %128
  %672 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %671
  store i32 %670, i32 addrspace(3)* %672, align 4, !tbaa !8
  %673 = or i32 %613, 12
  %674 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %673
  %675 = load i32, i32 addrspace(3)* %674, align 16, !tbaa !8
  %676 = add nuw nsw i32 %673, %128
  %677 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %676
  store i32 %675, i32 addrspace(3)* %677, align 16, !tbaa !8
  %678 = or i32 %613, 13
  %679 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %678
  %680 = load i32, i32 addrspace(3)* %679, align 4, !tbaa !8
  %681 = add nuw nsw i32 %678, %128
  %682 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %681
  store i32 %680, i32 addrspace(3)* %682, align 4, !tbaa !8
  %683 = or i32 %613, 14
  %684 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %683
  %685 = load i32, i32 addrspace(3)* %684, align 8, !tbaa !8
  %686 = add nuw nsw i32 %683, %128
  %687 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %686
  store i32 %685, i32 addrspace(3)* %687, align 8, !tbaa !8
  %688 = or i32 %613, 15
  %689 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %688
  %690 = load i32, i32 addrspace(3)* %689, align 4, !tbaa !8
  %691 = add nuw nsw i32 %688, %128
  %692 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %691
  store i32 %690, i32 addrspace(3)* %692, align 4, !tbaa !8
  %693 = add nuw nsw i32 %613, 16
  %694 = icmp eq i32 %693, 256
  br i1 %694, label %695, label %612, !llvm.loop !18

695:                                              ; preds = %612, %611
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %696 = add nuw nsw i32 %144, 1
  %697 = icmp eq i32 %696, 16
  br i1 %697, label %140, label %143, !llvm.loop !19

698:                                              ; preds = %698, %141
  %699 = phi i32 [ 0, %141 ], [ %811, %698 ]
  %700 = add nuw nsw i32 %699, %128
  %701 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %700
  %702 = load i32, i32 addrspace(3)* %701, align 16, !tbaa !8
  %703 = add nuw nsw i32 %699, %142
  %704 = sext i32 %703 to i64
  %705 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %704
  store i32 %702, i32 addrspace(1)* %705, align 4, !tbaa !8
  %706 = or i32 %699, 1
  %707 = add nuw nsw i32 %706, %128
  %708 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %707
  %709 = load i32, i32 addrspace(3)* %708, align 4, !tbaa !8
  %710 = add nuw nsw i32 %706, %142
  %711 = sext i32 %710 to i64
  %712 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %711
  store i32 %709, i32 addrspace(1)* %712, align 4, !tbaa !8
  %713 = or i32 %699, 2
  %714 = add nuw nsw i32 %713, %128
  %715 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %714
  %716 = load i32, i32 addrspace(3)* %715, align 8, !tbaa !8
  %717 = add nuw nsw i32 %713, %142
  %718 = sext i32 %717 to i64
  %719 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %718
  store i32 %716, i32 addrspace(1)* %719, align 4, !tbaa !8
  %720 = or i32 %699, 3
  %721 = add nuw nsw i32 %720, %128
  %722 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %721
  %723 = load i32, i32 addrspace(3)* %722, align 4, !tbaa !8
  %724 = add nuw nsw i32 %720, %142
  %725 = sext i32 %724 to i64
  %726 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %725
  store i32 %723, i32 addrspace(1)* %726, align 4, !tbaa !8
  %727 = or i32 %699, 4
  %728 = add nuw nsw i32 %727, %128
  %729 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %728
  %730 = load i32, i32 addrspace(3)* %729, align 16, !tbaa !8
  %731 = add nuw nsw i32 %727, %142
  %732 = sext i32 %731 to i64
  %733 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %732
  store i32 %730, i32 addrspace(1)* %733, align 4, !tbaa !8
  %734 = or i32 %699, 5
  %735 = add nuw nsw i32 %734, %128
  %736 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %735
  %737 = load i32, i32 addrspace(3)* %736, align 4, !tbaa !8
  %738 = add nuw nsw i32 %734, %142
  %739 = sext i32 %738 to i64
  %740 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %739
  store i32 %737, i32 addrspace(1)* %740, align 4, !tbaa !8
  %741 = or i32 %699, 6
  %742 = add nuw nsw i32 %741, %128
  %743 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %742
  %744 = load i32, i32 addrspace(3)* %743, align 8, !tbaa !8
  %745 = add nuw nsw i32 %741, %142
  %746 = sext i32 %745 to i64
  %747 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %746
  store i32 %744, i32 addrspace(1)* %747, align 4, !tbaa !8
  %748 = or i32 %699, 7
  %749 = add nuw nsw i32 %748, %128
  %750 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %749
  %751 = load i32, i32 addrspace(3)* %750, align 4, !tbaa !8
  %752 = add nuw nsw i32 %748, %142
  %753 = sext i32 %752 to i64
  %754 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %753
  store i32 %751, i32 addrspace(1)* %754, align 4, !tbaa !8
  %755 = or i32 %699, 8
  %756 = add nuw nsw i32 %755, %128
  %757 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %756
  %758 = load i32, i32 addrspace(3)* %757, align 16, !tbaa !8
  %759 = add nuw nsw i32 %755, %142
  %760 = sext i32 %759 to i64
  %761 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %760
  store i32 %758, i32 addrspace(1)* %761, align 4, !tbaa !8
  %762 = or i32 %699, 9
  %763 = add nuw nsw i32 %762, %128
  %764 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %763
  %765 = load i32, i32 addrspace(3)* %764, align 4, !tbaa !8
  %766 = add nuw nsw i32 %762, %142
  %767 = sext i32 %766 to i64
  %768 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %767
  store i32 %765, i32 addrspace(1)* %768, align 4, !tbaa !8
  %769 = or i32 %699, 10
  %770 = add nuw nsw i32 %769, %128
  %771 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %770
  %772 = load i32, i32 addrspace(3)* %771, align 8, !tbaa !8
  %773 = add nuw nsw i32 %769, %142
  %774 = sext i32 %773 to i64
  %775 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %774
  store i32 %772, i32 addrspace(1)* %775, align 4, !tbaa !8
  %776 = or i32 %699, 11
  %777 = add nuw nsw i32 %776, %128
  %778 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %777
  %779 = load i32, i32 addrspace(3)* %778, align 4, !tbaa !8
  %780 = add nuw nsw i32 %776, %142
  %781 = sext i32 %780 to i64
  %782 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %781
  store i32 %779, i32 addrspace(1)* %782, align 4, !tbaa !8
  %783 = or i32 %699, 12
  %784 = add nuw nsw i32 %783, %128
  %785 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %784
  %786 = load i32, i32 addrspace(3)* %785, align 16, !tbaa !8
  %787 = add nuw nsw i32 %783, %142
  %788 = sext i32 %787 to i64
  %789 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %788
  store i32 %786, i32 addrspace(1)* %789, align 4, !tbaa !8
  %790 = or i32 %699, 13
  %791 = add nuw nsw i32 %790, %128
  %792 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %791
  %793 = load i32, i32 addrspace(3)* %792, align 4, !tbaa !8
  %794 = add nuw nsw i32 %790, %142
  %795 = sext i32 %794 to i64
  %796 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %795
  store i32 %793, i32 addrspace(1)* %796, align 4, !tbaa !8
  %797 = or i32 %699, 14
  %798 = add nuw nsw i32 %797, %128
  %799 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %798
  %800 = load i32, i32 addrspace(3)* %799, align 8, !tbaa !8
  %801 = add nuw nsw i32 %797, %142
  %802 = sext i32 %801 to i64
  %803 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %802
  store i32 %800, i32 addrspace(1)* %803, align 4, !tbaa !8
  %804 = or i32 %699, 15
  %805 = add nuw nsw i32 %804, %128
  %806 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %805
  %807 = load i32, i32 addrspace(3)* %806, align 4, !tbaa !8
  %808 = add nuw nsw i32 %804, %142
  %809 = sext i32 %808 to i64
  %810 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %809
  store i32 %807, i32 addrspace(1)* %810, align 4, !tbaa !8
  %811 = add nuw nsw i32 %699, 16
  %812 = icmp eq i32 %811, 256
  br i1 %812, label %813, label %698, !llvm.loop !20

813:                                              ; preds = %698, %140
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  ret void

814:                                              ; preds = %599
  store i32 %607, i32 addrspace(3)* %610, align 8, !tbaa !8
  %815 = add nsw i32 %600, -1
  br label %818

816:                                              ; preds = %599
  store i32 %604, i32 addrspace(3)* %610, align 8, !tbaa !8
  %817 = add nsw i32 %601, -1
  br label %818

818:                                              ; preds = %816, %814
  %819 = phi i32 [ %600, %816 ], [ %815, %814 ]
  %820 = phi i32 [ %817, %816 ], [ %601, %814 ]
  %821 = add nsw i32 %820, %128
  %822 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %821
  %823 = load i32, i32 addrspace(3)* %822, align 4, !tbaa !8
  %824 = add nsw i32 %135, %819
  %825 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %824
  %826 = load i32, i32 addrspace(3)* %825, align 4, !tbaa !8
  %827 = icmp sgt i32 %823, %826
  %828 = sub nsw i32 253, %583
  %829 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %828
  br i1 %827, label %832, label %830

830:                                              ; preds = %818
  store i32 %826, i32 addrspace(3)* %829, align 4, !tbaa !8
  %831 = add nsw i32 %819, -1
  br label %834

832:                                              ; preds = %818
  store i32 %823, i32 addrspace(3)* %829, align 4, !tbaa !8
  %833 = add nsw i32 %820, -1
  br label %834

834:                                              ; preds = %832, %830
  %835 = phi i32 [ %819, %832 ], [ %831, %830 ]
  %836 = phi i32 [ %833, %832 ], [ %820, %830 ]
  %837 = add nsw i32 %836, %128
  %838 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %837
  %839 = load i32, i32 addrspace(3)* %838, align 4, !tbaa !8
  %840 = add nsw i32 %135, %835
  %841 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %840
  %842 = load i32, i32 addrspace(3)* %841, align 4, !tbaa !8
  %843 = icmp sgt i32 %839, %842
  %844 = sub nsw i32 252, %583
  %845 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %844
  br i1 %843, label %848, label %846

846:                                              ; preds = %834
  store i32 %842, i32 addrspace(3)* %845, align 16, !tbaa !8
  %847 = add nsw i32 %835, -1
  br label %850

848:                                              ; preds = %834
  store i32 %839, i32 addrspace(3)* %845, align 16, !tbaa !8
  %849 = add nsw i32 %836, -1
  br label %850

850:                                              ; preds = %848, %846
  %851 = phi i32 [ %835, %848 ], [ %847, %846 ]
  %852 = phi i32 [ %849, %848 ], [ %836, %846 ]
  %853 = add nsw i32 %852, %128
  %854 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %853
  %855 = load i32, i32 addrspace(3)* %854, align 4, !tbaa !8
  %856 = add nsw i32 %135, %851
  %857 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %856
  %858 = load i32, i32 addrspace(3)* %857, align 4, !tbaa !8
  %859 = icmp sgt i32 %855, %858
  %860 = sub nsw i32 251, %583
  %861 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %860
  br i1 %859, label %864, label %862

862:                                              ; preds = %850
  store i32 %858, i32 addrspace(3)* %861, align 4, !tbaa !8
  %863 = add nsw i32 %851, -1
  br label %866

864:                                              ; preds = %850
  store i32 %855, i32 addrspace(3)* %861, align 4, !tbaa !8
  %865 = add nsw i32 %852, -1
  br label %866

866:                                              ; preds = %864, %862
  %867 = phi i32 [ %851, %864 ], [ %863, %862 ]
  %868 = phi i32 [ %865, %864 ], [ %852, %862 ]
  %869 = add nsw i32 %868, %128
  %870 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %869
  %871 = load i32, i32 addrspace(3)* %870, align 4, !tbaa !8
  %872 = add nsw i32 %135, %867
  %873 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %872
  %874 = load i32, i32 addrspace(3)* %873, align 4, !tbaa !8
  %875 = icmp sgt i32 %871, %874
  %876 = sub nsw i32 250, %583
  %877 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %876
  br i1 %875, label %880, label %878

878:                                              ; preds = %866
  store i32 %874, i32 addrspace(3)* %877, align 8, !tbaa !8
  %879 = add nsw i32 %867, -1
  br label %882

880:                                              ; preds = %866
  store i32 %871, i32 addrspace(3)* %877, align 8, !tbaa !8
  %881 = add nsw i32 %868, -1
  br label %882

882:                                              ; preds = %880, %878
  %883 = phi i32 [ %867, %880 ], [ %879, %878 ]
  %884 = phi i32 [ %881, %880 ], [ %868, %878 ]
  %885 = add nsw i32 %884, %128
  %886 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %885
  %887 = load i32, i32 addrspace(3)* %886, align 4, !tbaa !8
  %888 = add nsw i32 %135, %883
  %889 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %888
  %890 = load i32, i32 addrspace(3)* %889, align 4, !tbaa !8
  %891 = icmp sgt i32 %887, %890
  %892 = sub nsw i32 249, %583
  %893 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %892
  br i1 %891, label %896, label %894

894:                                              ; preds = %882
  store i32 %890, i32 addrspace(3)* %893, align 4, !tbaa !8
  %895 = add nsw i32 %883, -1
  br label %898

896:                                              ; preds = %882
  store i32 %887, i32 addrspace(3)* %893, align 4, !tbaa !8
  %897 = add nsw i32 %884, -1
  br label %898

898:                                              ; preds = %896, %894
  %899 = phi i32 [ %883, %896 ], [ %895, %894 ]
  %900 = phi i32 [ %897, %896 ], [ %884, %894 ]
  %901 = add nsw i32 %900, %128
  %902 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %901
  %903 = load i32, i32 addrspace(3)* %902, align 4, !tbaa !8
  %904 = add nsw i32 %135, %899
  %905 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %904
  %906 = load i32, i32 addrspace(3)* %905, align 4, !tbaa !8
  %907 = icmp sgt i32 %903, %906
  %908 = sub nsw i32 248, %583
  %909 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %908
  br i1 %907, label %912, label %910

910:                                              ; preds = %898
  store i32 %906, i32 addrspace(3)* %909, align 16, !tbaa !8
  %911 = add nsw i32 %899, -1
  br label %914

912:                                              ; preds = %898
  store i32 %903, i32 addrspace(3)* %909, align 16, !tbaa !8
  %913 = add nsw i32 %900, -1
  br label %914

914:                                              ; preds = %912, %910
  %915 = phi i32 [ %899, %912 ], [ %911, %910 ]
  %916 = phi i32 [ %913, %912 ], [ %900, %910 ]
  %917 = add nuw nsw i32 %583, 8
  %918 = icmp eq i32 %917, 256
  br i1 %918, label %611, label %582, !llvm.loop !21
}

; Function Attrs: convergent nounwind willreturn
declare void @llvm.amdgcn.s.barrier() #1

; Function Attrs: nounwind readnone speculatable willreturn
declare align 4 i8 addrspace(4)* @llvm.amdgcn.dispatch.ptr() #2

; Function Attrs: nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.workgroup.id.x() #2

; Function Attrs: nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.workitem.id.x() #2

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { convergent nounwind willreturn }
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
!9 = !{!"int", !10, i64 0}
!10 = !{!"omnipotent char", !11, i64 0}
!11 = !{!"Simple C++ TBAA"}
!12 = distinct !{!12, !13}
!13 = !{!"llvm.loop.mustprogress"}
!14 = distinct !{!14, !13}
!15 = distinct !{!15, !13}
!16 = distinct !{!16, !13}
!17 = distinct !{!17, !13}
!18 = distinct !{!18, !13}
!19 = distinct !{!19, !13}
!20 = distinct !{!20, !13}
!21 = distinct !{!21, !13}
