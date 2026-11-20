; ModuleID = 'build/cleanup-passes/20261120-v1/exact/round-0-control.ll'
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

merged.branch.split1:                             ; preds = %merged.branch.split, %unify.bb
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %128 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sR, i32 0, i32 %13
  %129 = and i32 %1, 1
  %130 = icmp ne i32 %129, 0
  %131 = icmp ult i32 %1, 31
  %132 = xor i1 %130, true
  %133 = and i1 %131, %132
  %134 = add nsw i32 %13, -256
  %135 = add nuw nsw i32 %13, 256
  %136 = icmp ult i32 %1, 32
  %137 = and i1 %131, %130
  %138 = icmp eq i32 %1, 0
  br label %140

139:                                              ; preds = %.loopexit19
  br i1 %10, label %.preheader, label %.loopexit

140:                                              ; preds = %.loopexit19, %merged.branch.split1
  %141 = phi i32 [ 0, %merged.branch.split1 ], [ %680, %.loopexit19 ]
  br i1 %133, label %.preheader26, label %unify.bb2

.preheader26:                                     ; preds = %140, %.preheader26
  %142 = phi i32 [ %264, %.preheader26 ], [ 0, %140 ]
  %143 = phi i32 [ %262, %.preheader26 ], [ 0, %140 ]
  %144 = phi i32 [ %260, %.preheader26 ], [ 0, %140 ]
  %145 = add nsw i32 %144, %13
  %146 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %145
  %147 = load i32, i32 addrspace(3)* %146, align 4, !tbaa !8
  %148 = add nsw i32 %143, %135
  %149 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %148
  %150 = load i32, i32 addrspace(3)* %149, align 4, !tbaa !8
  %151 = icmp sgt i32 %147, %150
  %152 = select i1 %151, i32 %150, i32 %147
  %153 = xor i1 %151, true
  %154 = zext i1 %153 to i32
  %155 = add nuw nsw i32 %144, %154
  %156 = zext i1 %151 to i32
  %157 = add nuw nsw i32 %143, %156
  %158 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %142
  store i32 %152, i32 addrspace(3)* %158, align 16
  %159 = or i32 %142, 1
  %160 = add nsw i32 %155, %13
  %161 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %160
  %162 = load i32, i32 addrspace(3)* %161, align 4, !tbaa !8
  %163 = add nsw i32 %157, %135
  %164 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %163
  %165 = load i32, i32 addrspace(3)* %164, align 4, !tbaa !8
  %166 = icmp sgt i32 %162, %165
  %167 = select i1 %166, i32 %165, i32 %162
  %168 = xor i1 %166, true
  %169 = zext i1 %168 to i32
  %170 = add nuw nsw i32 %155, %169
  %171 = zext i1 %166 to i32
  %172 = add nuw nsw i32 %157, %171
  %173 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %159
  store i32 %167, i32 addrspace(3)* %173, align 4
  %174 = or i32 %142, 2
  %175 = add nsw i32 %170, %13
  %176 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %175
  %177 = load i32, i32 addrspace(3)* %176, align 4, !tbaa !8
  %178 = add nsw i32 %172, %135
  %179 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %178
  %180 = load i32, i32 addrspace(3)* %179, align 4, !tbaa !8
  %181 = icmp sgt i32 %177, %180
  %182 = select i1 %181, i32 %180, i32 %177
  %183 = xor i1 %181, true
  %184 = zext i1 %183 to i32
  %185 = add nuw nsw i32 %170, %184
  %186 = zext i1 %181 to i32
  %187 = add nuw nsw i32 %172, %186
  %188 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %174
  store i32 %182, i32 addrspace(3)* %188, align 8
  %189 = or i32 %142, 3
  %190 = add nsw i32 %185, %13
  %191 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %190
  %192 = load i32, i32 addrspace(3)* %191, align 4, !tbaa !8
  %193 = add nsw i32 %187, %135
  %194 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %193
  %195 = load i32, i32 addrspace(3)* %194, align 4, !tbaa !8
  %196 = icmp sgt i32 %192, %195
  %197 = select i1 %196, i32 %195, i32 %192
  %198 = xor i1 %196, true
  %199 = zext i1 %198 to i32
  %200 = add nuw nsw i32 %185, %199
  %201 = zext i1 %196 to i32
  %202 = add nuw nsw i32 %187, %201
  %203 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %189
  store i32 %197, i32 addrspace(3)* %203, align 4
  %204 = or i32 %142, 4
  %205 = add nsw i32 %200, %13
  %206 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %205
  %207 = load i32, i32 addrspace(3)* %206, align 4, !tbaa !8
  %208 = add nsw i32 %202, %135
  %209 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %208
  %210 = load i32, i32 addrspace(3)* %209, align 4, !tbaa !8
  %211 = icmp sgt i32 %207, %210
  %212 = select i1 %211, i32 %210, i32 %207
  %213 = xor i1 %211, true
  %214 = zext i1 %213 to i32
  %215 = add nuw nsw i32 %200, %214
  %216 = zext i1 %211 to i32
  %217 = add nuw nsw i32 %202, %216
  %218 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %204
  store i32 %212, i32 addrspace(3)* %218, align 16
  %219 = or i32 %142, 5
  %220 = add nsw i32 %215, %13
  %221 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %220
  %222 = load i32, i32 addrspace(3)* %221, align 4, !tbaa !8
  %223 = add nsw i32 %217, %135
  %224 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %223
  %225 = load i32, i32 addrspace(3)* %224, align 4, !tbaa !8
  %226 = icmp sgt i32 %222, %225
  %227 = select i1 %226, i32 %225, i32 %222
  %228 = xor i1 %226, true
  %229 = zext i1 %228 to i32
  %230 = add nuw nsw i32 %215, %229
  %231 = zext i1 %226 to i32
  %232 = add nuw nsw i32 %217, %231
  %233 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %219
  store i32 %227, i32 addrspace(3)* %233, align 4
  %234 = or i32 %142, 6
  %235 = add nsw i32 %230, %13
  %236 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %235
  %237 = load i32, i32 addrspace(3)* %236, align 4, !tbaa !8
  %238 = add nsw i32 %232, %135
  %239 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %238
  %240 = load i32, i32 addrspace(3)* %239, align 4, !tbaa !8
  %241 = icmp sgt i32 %237, %240
  %242 = select i1 %241, i32 %240, i32 %237
  %243 = xor i1 %241, true
  %244 = zext i1 %243 to i32
  %245 = add nuw nsw i32 %230, %244
  %246 = zext i1 %241 to i32
  %247 = add nuw nsw i32 %232, %246
  %248 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %234
  store i32 %242, i32 addrspace(3)* %248, align 8
  %249 = or i32 %142, 7
  %250 = add nsw i32 %245, %13
  %251 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %250
  %252 = load i32, i32 addrspace(3)* %251, align 4, !tbaa !8
  %253 = add nsw i32 %247, %135
  %254 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %253
  %255 = load i32, i32 addrspace(3)* %254, align 4, !tbaa !8
  %256 = icmp sgt i32 %252, %255
  %257 = select i1 %256, i32 %255, i32 %252
  %258 = xor i1 %256, true
  %259 = zext i1 %258 to i32
  %260 = add nuw nsw i32 %245, %259
  %261 = zext i1 %256 to i32
  %262 = add nuw nsw i32 %247, %261
  %263 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %249
  store i32 %257, i32 addrspace(3)* %263, align 4
  %264 = add nuw nsw i32 %142, 8
  %265 = icmp eq i32 %264, 256
  br i1 %265, label %.loopexit27, label %.preheader26, !llvm.loop !14

unify.bb2:                                        ; preds = %140, %unify.bb2
  %266 = phi i32 [ %365, %unify.bb2 ], [ 0, %140 ]
  %267 = phi i32 [ %364, %unify.bb2 ], [ 255, %140 ]
  %268 = phi i32 [ %363, %unify.bb2 ], [ 255, %140 ]
  %269 = add nsw i32 %267, %13
  %270 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %269
  %271 = load i32, i32 addrspace(3)* %270, align 4, !tbaa !8
  %272 = add nsw i32 %268, %134
  %273 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %272
  %274 = load i32, i32 addrspace(3)* %273, align 4, !tbaa !8
  %275 = icmp sgt i32 %271, %274
  %276 = sub nuw nsw i32 255, %266
  %277 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %276
  %merged.select = select i1 %275, i32 %271, i32 %274
  store i32 %merged.select, i32 addrspace(3)* %277, align 4, !tbaa !8
  %merged.select3 = select i1 %275, i32 %267, i32 %268
  %278 = add nsw i32 %merged.select3, -1
  %279 = select i1 %275, i32 %268, i32 %278
  %280 = select i1 %275, i32 %278, i32 %267
  %281 = add nsw i32 %280, %13
  %282 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %281
  %283 = load i32, i32 addrspace(3)* %282, align 4, !tbaa !8
  %284 = add nsw i32 %279, %134
  %285 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %284
  %286 = load i32, i32 addrspace(3)* %285, align 4, !tbaa !8
  %287 = icmp sgt i32 %283, %286
  %288 = sub nuw nsw i32 254, %266
  %289 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %288
  %merged.select7 = select i1 %287, i32 %283, i32 %286
  store i32 %merged.select7, i32 addrspace(3)* %289, align 8, !tbaa !8
  %merged.select8 = select i1 %287, i32 %280, i32 %279
  %290 = add nsw i32 %merged.select8, -1
  %291 = select i1 %287, i32 %279, i32 %290
  %292 = select i1 %287, i32 %290, i32 %280
  %293 = add nsw i32 %292, %13
  %294 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %293
  %295 = load i32, i32 addrspace(3)* %294, align 4, !tbaa !8
  %296 = add nsw i32 %291, %134
  %297 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %296
  %298 = load i32, i32 addrspace(3)* %297, align 4, !tbaa !8
  %299 = icmp sgt i32 %295, %298
  %300 = sub nuw nsw i32 253, %266
  %301 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %300
  %merged.select12 = select i1 %299, i32 %295, i32 %298
  store i32 %merged.select12, i32 addrspace(3)* %301, align 4, !tbaa !8
  %merged.select13 = select i1 %299, i32 %292, i32 %291
  %302 = add nsw i32 %merged.select13, -1
  %303 = select i1 %299, i32 %291, i32 %302
  %304 = select i1 %299, i32 %302, i32 %292
  %305 = add nsw i32 %304, %13
  %306 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %305
  %307 = load i32, i32 addrspace(3)* %306, align 4, !tbaa !8
  %308 = add nsw i32 %303, %134
  %309 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %308
  %310 = load i32, i32 addrspace(3)* %309, align 4, !tbaa !8
  %311 = icmp sgt i32 %307, %310
  %312 = sub nuw nsw i32 252, %266
  %313 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %312
  %merged.select17 = select i1 %311, i32 %307, i32 %310
  store i32 %merged.select17, i32 addrspace(3)* %313, align 16, !tbaa !8
  %merged.select18 = select i1 %311, i32 %304, i32 %303
  %314 = add nsw i32 %merged.select18, -1
  %315 = select i1 %311, i32 %303, i32 %314
  %316 = select i1 %311, i32 %314, i32 %304
  %317 = add nsw i32 %316, %13
  %318 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %317
  %319 = load i32, i32 addrspace(3)* %318, align 4, !tbaa !8
  %320 = add nsw i32 %315, %134
  %321 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %320
  %322 = load i32, i32 addrspace(3)* %321, align 4, !tbaa !8
  %323 = icmp sgt i32 %319, %322
  %324 = sub nuw nsw i32 251, %266
  %325 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %324
  %merged.select22 = select i1 %323, i32 %319, i32 %322
  store i32 %merged.select22, i32 addrspace(3)* %325, align 4, !tbaa !8
  %merged.select23 = select i1 %323, i32 %316, i32 %315
  %326 = add nsw i32 %merged.select23, -1
  %327 = select i1 %323, i32 %315, i32 %326
  %328 = select i1 %323, i32 %326, i32 %316
  %329 = add nsw i32 %328, %13
  %330 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %329
  %331 = load i32, i32 addrspace(3)* %330, align 4, !tbaa !8
  %332 = add nsw i32 %327, %134
  %333 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %332
  %334 = load i32, i32 addrspace(3)* %333, align 4, !tbaa !8
  %335 = icmp sgt i32 %331, %334
  %336 = sub nuw nsw i32 250, %266
  %337 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %336
  %merged.select27 = select i1 %335, i32 %331, i32 %334
  store i32 %merged.select27, i32 addrspace(3)* %337, align 8, !tbaa !8
  %merged.select28 = select i1 %335, i32 %328, i32 %327
  %338 = add nsw i32 %merged.select28, -1
  %339 = select i1 %335, i32 %327, i32 %338
  %340 = select i1 %335, i32 %338, i32 %328
  %341 = add nsw i32 %340, %13
  %342 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %341
  %343 = load i32, i32 addrspace(3)* %342, align 4, !tbaa !8
  %344 = add nsw i32 %339, %134
  %345 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %344
  %346 = load i32, i32 addrspace(3)* %345, align 4, !tbaa !8
  %347 = icmp sgt i32 %343, %346
  %348 = sub nuw nsw i32 249, %266
  %349 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %348
  %merged.select32 = select i1 %347, i32 %343, i32 %346
  store i32 %merged.select32, i32 addrspace(3)* %349, align 4, !tbaa !8
  %merged.select33 = select i1 %347, i32 %340, i32 %339
  %350 = add nsw i32 %merged.select33, -1
  %351 = select i1 %347, i32 %339, i32 %350
  %352 = select i1 %347, i32 %350, i32 %340
  %353 = add nsw i32 %352, %13
  %354 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %353
  %355 = load i32, i32 addrspace(3)* %354, align 4, !tbaa !8
  %356 = add nsw i32 %351, %134
  %357 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %356
  %358 = load i32, i32 addrspace(3)* %357, align 4, !tbaa !8
  %359 = icmp sgt i32 %355, %358
  %360 = sub nuw nsw i32 248, %266
  %361 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %360
  %merged.select37 = select i1 %359, i32 %355, i32 %358
  store i32 %merged.select37, i32 addrspace(3)* %361, align 16, !tbaa !8
  %merged.select38 = select i1 %359, i32 %352, i32 %351
  %362 = add nsw i32 %merged.select38, -1
  %363 = select i1 %359, i32 %351, i32 %362
  %364 = select i1 %359, i32 %362, i32 %352
  %365 = add nuw nsw i32 %266, 8
  %366 = icmp eq i32 %365, 256
  br i1 %366, label %.loopexit27, label %unify.bb2, !llvm.loop !15

.loopexit27:                                      ; preds = %unify.bb2, %.preheader26
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %136, label %.preheader24, label %.loopexit25

.preheader24:                                     ; preds = %.loopexit27, %.preheader24
  %367 = phi i32 [ %447, %.preheader24 ], [ 0, %.loopexit27 ]
  %368 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %367
  %369 = load i32, i32 addrspace(3)* %368, align 16, !tbaa !8
  %370 = add nuw nsw i32 %367, %13
  %371 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %370
  store i32 %369, i32 addrspace(3)* %371, align 16, !tbaa !8
  %372 = or i32 %367, 1
  %373 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %372
  %374 = load i32, i32 addrspace(3)* %373, align 4, !tbaa !8
  %375 = add nuw nsw i32 %372, %13
  %376 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %375
  store i32 %374, i32 addrspace(3)* %376, align 4, !tbaa !8
  %377 = or i32 %367, 2
  %378 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %377
  %379 = load i32, i32 addrspace(3)* %378, align 8, !tbaa !8
  %380 = add nuw nsw i32 %377, %13
  %381 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %380
  store i32 %379, i32 addrspace(3)* %381, align 8, !tbaa !8
  %382 = or i32 %367, 3
  %383 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %382
  %384 = load i32, i32 addrspace(3)* %383, align 4, !tbaa !8
  %385 = add nuw nsw i32 %382, %13
  %386 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %385
  store i32 %384, i32 addrspace(3)* %386, align 4, !tbaa !8
  %387 = or i32 %367, 4
  %388 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %387
  %389 = load i32, i32 addrspace(3)* %388, align 16, !tbaa !8
  %390 = add nuw nsw i32 %387, %13
  %391 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %390
  store i32 %389, i32 addrspace(3)* %391, align 16, !tbaa !8
  %392 = or i32 %367, 5
  %393 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %392
  %394 = load i32, i32 addrspace(3)* %393, align 4, !tbaa !8
  %395 = add nuw nsw i32 %392, %13
  %396 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %395
  store i32 %394, i32 addrspace(3)* %396, align 4, !tbaa !8
  %397 = or i32 %367, 6
  %398 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %397
  %399 = load i32, i32 addrspace(3)* %398, align 8, !tbaa !8
  %400 = add nuw nsw i32 %397, %13
  %401 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %400
  store i32 %399, i32 addrspace(3)* %401, align 8, !tbaa !8
  %402 = or i32 %367, 7
  %403 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %402
  %404 = load i32, i32 addrspace(3)* %403, align 4, !tbaa !8
  %405 = add nuw nsw i32 %402, %13
  %406 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %405
  store i32 %404, i32 addrspace(3)* %406, align 4, !tbaa !8
  %407 = or i32 %367, 8
  %408 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %407
  %409 = load i32, i32 addrspace(3)* %408, align 16, !tbaa !8
  %410 = add nuw nsw i32 %407, %13
  %411 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %410
  store i32 %409, i32 addrspace(3)* %411, align 16, !tbaa !8
  %412 = or i32 %367, 9
  %413 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %412
  %414 = load i32, i32 addrspace(3)* %413, align 4, !tbaa !8
  %415 = add nuw nsw i32 %412, %13
  %416 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %415
  store i32 %414, i32 addrspace(3)* %416, align 4, !tbaa !8
  %417 = or i32 %367, 10
  %418 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %417
  %419 = load i32, i32 addrspace(3)* %418, align 8, !tbaa !8
  %420 = add nuw nsw i32 %417, %13
  %421 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %420
  store i32 %419, i32 addrspace(3)* %421, align 8, !tbaa !8
  %422 = or i32 %367, 11
  %423 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %422
  %424 = load i32, i32 addrspace(3)* %423, align 4, !tbaa !8
  %425 = add nuw nsw i32 %422, %13
  %426 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %425
  store i32 %424, i32 addrspace(3)* %426, align 4, !tbaa !8
  %427 = or i32 %367, 12
  %428 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %427
  %429 = load i32, i32 addrspace(3)* %428, align 16, !tbaa !8
  %430 = add nuw nsw i32 %427, %13
  %431 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %430
  store i32 %429, i32 addrspace(3)* %431, align 16, !tbaa !8
  %432 = or i32 %367, 13
  %433 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %432
  %434 = load i32, i32 addrspace(3)* %433, align 4, !tbaa !8
  %435 = add nuw nsw i32 %432, %13
  %436 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %435
  store i32 %434, i32 addrspace(3)* %436, align 4, !tbaa !8
  %437 = or i32 %367, 14
  %438 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %437
  %439 = load i32, i32 addrspace(3)* %438, align 8, !tbaa !8
  %440 = add nuw nsw i32 %437, %13
  %441 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %440
  store i32 %439, i32 addrspace(3)* %441, align 8, !tbaa !8
  %442 = or i32 %367, 15
  %443 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %442
  %444 = load i32, i32 addrspace(3)* %443, align 4, !tbaa !8
  %445 = add nuw nsw i32 %442, %13
  %446 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %445
  store i32 %444, i32 addrspace(3)* %446, align 4, !tbaa !8
  %447 = add nuw nsw i32 %367, 16
  %448 = icmp eq i32 %447, 256
  br i1 %448, label %.loopexit25, label %.preheader24, !llvm.loop !16

.loopexit25:                                      ; preds = %.preheader24, %.loopexit27
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %137, label %.preheader20, label %573

.preheader20:                                     ; preds = %.loopexit25, %.preheader20
  %449 = phi i32 [ %571, %.preheader20 ], [ 0, %.loopexit25 ]
  %450 = phi i32 [ %569, %.preheader20 ], [ 0, %.loopexit25 ]
  %451 = phi i32 [ %567, %.preheader20 ], [ 0, %.loopexit25 ]
  %452 = add nsw i32 %451, %13
  %453 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %452
  %454 = load i32, i32 addrspace(3)* %453, align 4, !tbaa !8
  %455 = add nsw i32 %450, %135
  %456 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %455
  %457 = load i32, i32 addrspace(3)* %456, align 4, !tbaa !8
  %458 = icmp sgt i32 %454, %457
  %459 = select i1 %458, i32 %457, i32 %454
  %460 = xor i1 %458, true
  %461 = zext i1 %460 to i32
  %462 = add nuw nsw i32 %451, %461
  %463 = zext i1 %458 to i32
  %464 = add nuw nsw i32 %450, %463
  %465 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %449
  store i32 %459, i32 addrspace(3)* %465, align 16
  %466 = or i32 %449, 1
  %467 = add nsw i32 %462, %13
  %468 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %467
  %469 = load i32, i32 addrspace(3)* %468, align 4, !tbaa !8
  %470 = add nsw i32 %464, %135
  %471 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %470
  %472 = load i32, i32 addrspace(3)* %471, align 4, !tbaa !8
  %473 = icmp sgt i32 %469, %472
  %474 = select i1 %473, i32 %472, i32 %469
  %475 = xor i1 %473, true
  %476 = zext i1 %475 to i32
  %477 = add nuw nsw i32 %462, %476
  %478 = zext i1 %473 to i32
  %479 = add nuw nsw i32 %464, %478
  %480 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %466
  store i32 %474, i32 addrspace(3)* %480, align 4
  %481 = or i32 %449, 2
  %482 = add nsw i32 %477, %13
  %483 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %482
  %484 = load i32, i32 addrspace(3)* %483, align 4, !tbaa !8
  %485 = add nsw i32 %479, %135
  %486 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %485
  %487 = load i32, i32 addrspace(3)* %486, align 4, !tbaa !8
  %488 = icmp sgt i32 %484, %487
  %489 = select i1 %488, i32 %487, i32 %484
  %490 = xor i1 %488, true
  %491 = zext i1 %490 to i32
  %492 = add nuw nsw i32 %477, %491
  %493 = zext i1 %488 to i32
  %494 = add nuw nsw i32 %479, %493
  %495 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %481
  store i32 %489, i32 addrspace(3)* %495, align 8
  %496 = or i32 %449, 3
  %497 = add nsw i32 %492, %13
  %498 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %497
  %499 = load i32, i32 addrspace(3)* %498, align 4, !tbaa !8
  %500 = add nsw i32 %494, %135
  %501 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %500
  %502 = load i32, i32 addrspace(3)* %501, align 4, !tbaa !8
  %503 = icmp sgt i32 %499, %502
  %504 = select i1 %503, i32 %502, i32 %499
  %505 = xor i1 %503, true
  %506 = zext i1 %505 to i32
  %507 = add nuw nsw i32 %492, %506
  %508 = zext i1 %503 to i32
  %509 = add nuw nsw i32 %494, %508
  %510 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %496
  store i32 %504, i32 addrspace(3)* %510, align 4
  %511 = or i32 %449, 4
  %512 = add nsw i32 %507, %13
  %513 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %512
  %514 = load i32, i32 addrspace(3)* %513, align 4, !tbaa !8
  %515 = add nsw i32 %509, %135
  %516 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %515
  %517 = load i32, i32 addrspace(3)* %516, align 4, !tbaa !8
  %518 = icmp sgt i32 %514, %517
  %519 = select i1 %518, i32 %517, i32 %514
  %520 = xor i1 %518, true
  %521 = zext i1 %520 to i32
  %522 = add nuw nsw i32 %507, %521
  %523 = zext i1 %518 to i32
  %524 = add nuw nsw i32 %509, %523
  %525 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %511
  store i32 %519, i32 addrspace(3)* %525, align 16
  %526 = or i32 %449, 5
  %527 = add nsw i32 %522, %13
  %528 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %527
  %529 = load i32, i32 addrspace(3)* %528, align 4, !tbaa !8
  %530 = add nsw i32 %524, %135
  %531 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %530
  %532 = load i32, i32 addrspace(3)* %531, align 4, !tbaa !8
  %533 = icmp sgt i32 %529, %532
  %534 = select i1 %533, i32 %532, i32 %529
  %535 = xor i1 %533, true
  %536 = zext i1 %535 to i32
  %537 = add nuw nsw i32 %522, %536
  %538 = zext i1 %533 to i32
  %539 = add nuw nsw i32 %524, %538
  %540 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %526
  store i32 %534, i32 addrspace(3)* %540, align 4
  %541 = or i32 %449, 6
  %542 = add nsw i32 %537, %13
  %543 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %542
  %544 = load i32, i32 addrspace(3)* %543, align 4, !tbaa !8
  %545 = add nsw i32 %539, %135
  %546 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %545
  %547 = load i32, i32 addrspace(3)* %546, align 4, !tbaa !8
  %548 = icmp sgt i32 %544, %547
  %549 = select i1 %548, i32 %547, i32 %544
  %550 = xor i1 %548, true
  %551 = zext i1 %550 to i32
  %552 = add nuw nsw i32 %537, %551
  %553 = zext i1 %548 to i32
  %554 = add nuw nsw i32 %539, %553
  %555 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %541
  store i32 %549, i32 addrspace(3)* %555, align 8
  %556 = or i32 %449, 7
  %557 = add nsw i32 %552, %13
  %558 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %557
  %559 = load i32, i32 addrspace(3)* %558, align 4, !tbaa !8
  %560 = add nsw i32 %554, %135
  %561 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %560
  %562 = load i32, i32 addrspace(3)* %561, align 4, !tbaa !8
  %563 = icmp sgt i32 %559, %562
  %564 = select i1 %563, i32 %562, i32 %559
  %565 = xor i1 %563, true
  %566 = zext i1 %565 to i32
  %567 = add nuw nsw i32 %552, %566
  %568 = zext i1 %563 to i32
  %569 = add nuw nsw i32 %554, %568
  %570 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %556
  store i32 %564, i32 addrspace(3)* %570, align 4
  %571 = add nuw nsw i32 %449, 8
  %572 = icmp eq i32 %571, 256
  br i1 %572, label %.loopexit21, label %.preheader20, !llvm.loop !17

573:                                              ; preds = %.loopexit25
  br i1 %138, label %.loopexit21, label %.preheader22

.preheader22:                                     ; preds = %573, %872
  %574 = phi i32 [ %875, %872 ], [ 0, %573 ]
  %575 = phi i32 [ %874, %872 ], [ 255, %573 ]
  %576 = phi i32 [ %873, %872 ], [ 255, %573 ]
  %577 = add nsw i32 %575, %13
  %578 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %577
  %579 = load i32, i32 addrspace(3)* %578, align 4, !tbaa !8
  %580 = add nsw i32 %576, %134
  %581 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %580
  %582 = load i32, i32 addrspace(3)* %581, align 4, !tbaa !8
  %583 = icmp sgt i32 %579, %582
  %584 = sub nuw nsw i32 255, %574
  %585 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %584
  br i1 %583, label %586, label %588

586:                                              ; preds = %.preheader22
  store i32 %579, i32 addrspace(3)* %585, align 4, !tbaa !8
  %587 = add nsw i32 %575, -1
  %.pre = add nsw i32 %587, %13
  %.phi.trans.insert = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre
  %.pre57 = load i32, i32 addrspace(3)* %.phi.trans.insert, align 4, !tbaa !8
  br label %590

588:                                              ; preds = %.preheader22
  store i32 %582, i32 addrspace(3)* %585, align 4, !tbaa !8
  %589 = add nsw i32 %576, -1
  %.pre31 = add nsw i32 %589, %134
  %.phi.trans.insert58 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre31
  %.pre59 = load i32, i32 addrspace(3)* %.phi.trans.insert58, align 4, !tbaa !8
  br label %590

590:                                              ; preds = %588, %586
  %591 = phi i32 [ %.pre59, %588 ], [ %582, %586 ]
  %592 = phi i32 [ %579, %588 ], [ %.pre57, %586 ]
  %593 = phi i32 [ %589, %588 ], [ %576, %586 ]
  %594 = phi i32 [ %575, %588 ], [ %587, %586 ]
  %595 = icmp sgt i32 %592, %591
  %596 = sub nuw nsw i32 254, %574
  %597 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %596
  br i1 %595, label %798, label %796

.loopexit21:                                      ; preds = %872, %.preheader20, %573
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %136, label %.preheader18, label %.loopexit19

.preheader18:                                     ; preds = %.loopexit21, %.preheader18
  %598 = phi i32 [ %678, %.preheader18 ], [ 0, %.loopexit21 ]
  %599 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %598
  %600 = load i32, i32 addrspace(3)* %599, align 16, !tbaa !8
  %601 = add nuw nsw i32 %598, %13
  %602 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %601
  store i32 %600, i32 addrspace(3)* %602, align 16, !tbaa !8
  %603 = or i32 %598, 1
  %604 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %603
  %605 = load i32, i32 addrspace(3)* %604, align 4, !tbaa !8
  %606 = add nuw nsw i32 %603, %13
  %607 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %606
  store i32 %605, i32 addrspace(3)* %607, align 4, !tbaa !8
  %608 = or i32 %598, 2
  %609 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %608
  %610 = load i32, i32 addrspace(3)* %609, align 8, !tbaa !8
  %611 = add nuw nsw i32 %608, %13
  %612 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %611
  store i32 %610, i32 addrspace(3)* %612, align 8, !tbaa !8
  %613 = or i32 %598, 3
  %614 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %613
  %615 = load i32, i32 addrspace(3)* %614, align 4, !tbaa !8
  %616 = add nuw nsw i32 %613, %13
  %617 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %616
  store i32 %615, i32 addrspace(3)* %617, align 4, !tbaa !8
  %618 = or i32 %598, 4
  %619 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %618
  %620 = load i32, i32 addrspace(3)* %619, align 16, !tbaa !8
  %621 = add nuw nsw i32 %618, %13
  %622 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %621
  store i32 %620, i32 addrspace(3)* %622, align 16, !tbaa !8
  %623 = or i32 %598, 5
  %624 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %623
  %625 = load i32, i32 addrspace(3)* %624, align 4, !tbaa !8
  %626 = add nuw nsw i32 %623, %13
  %627 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %626
  store i32 %625, i32 addrspace(3)* %627, align 4, !tbaa !8
  %628 = or i32 %598, 6
  %629 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %628
  %630 = load i32, i32 addrspace(3)* %629, align 8, !tbaa !8
  %631 = add nuw nsw i32 %628, %13
  %632 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %631
  store i32 %630, i32 addrspace(3)* %632, align 8, !tbaa !8
  %633 = or i32 %598, 7
  %634 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %633
  %635 = load i32, i32 addrspace(3)* %634, align 4, !tbaa !8
  %636 = add nuw nsw i32 %633, %13
  %637 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %636
  store i32 %635, i32 addrspace(3)* %637, align 4, !tbaa !8
  %638 = or i32 %598, 8
  %639 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %638
  %640 = load i32, i32 addrspace(3)* %639, align 16, !tbaa !8
  %641 = add nuw nsw i32 %638, %13
  %642 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %641
  store i32 %640, i32 addrspace(3)* %642, align 16, !tbaa !8
  %643 = or i32 %598, 9
  %644 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %643
  %645 = load i32, i32 addrspace(3)* %644, align 4, !tbaa !8
  %646 = add nuw nsw i32 %643, %13
  %647 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %646
  store i32 %645, i32 addrspace(3)* %647, align 4, !tbaa !8
  %648 = or i32 %598, 10
  %649 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %648
  %650 = load i32, i32 addrspace(3)* %649, align 8, !tbaa !8
  %651 = add nuw nsw i32 %648, %13
  %652 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %651
  store i32 %650, i32 addrspace(3)* %652, align 8, !tbaa !8
  %653 = or i32 %598, 11
  %654 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %653
  %655 = load i32, i32 addrspace(3)* %654, align 4, !tbaa !8
  %656 = add nuw nsw i32 %653, %13
  %657 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %656
  store i32 %655, i32 addrspace(3)* %657, align 4, !tbaa !8
  %658 = or i32 %598, 12
  %659 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %658
  %660 = load i32, i32 addrspace(3)* %659, align 16, !tbaa !8
  %661 = add nuw nsw i32 %658, %13
  %662 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %661
  store i32 %660, i32 addrspace(3)* %662, align 16, !tbaa !8
  %663 = or i32 %598, 13
  %664 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %663
  %665 = load i32, i32 addrspace(3)* %664, align 4, !tbaa !8
  %666 = add nuw nsw i32 %663, %13
  %667 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %666
  store i32 %665, i32 addrspace(3)* %667, align 4, !tbaa !8
  %668 = or i32 %598, 14
  %669 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %668
  %670 = load i32, i32 addrspace(3)* %669, align 8, !tbaa !8
  %671 = add nuw nsw i32 %668, %13
  %672 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %671
  store i32 %670, i32 addrspace(3)* %672, align 8, !tbaa !8
  %673 = or i32 %598, 15
  %674 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %673
  %675 = load i32, i32 addrspace(3)* %674, align 4, !tbaa !8
  %676 = add nuw nsw i32 %673, %13
  %677 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %676
  store i32 %675, i32 addrspace(3)* %677, align 4, !tbaa !8
  %678 = add nuw nsw i32 %598, 16
  %679 = icmp eq i32 %678, 256
  br i1 %679, label %.loopexit19, label %.preheader18, !llvm.loop !18

.loopexit19:                                      ; preds = %.preheader18, %.loopexit21
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %680 = add nuw nsw i32 %141, 1
  %681 = icmp eq i32 %680, 16
  br i1 %681, label %139, label %140, !llvm.loop !19

.preheader:                                       ; preds = %139, %.preheader
  %682 = phi i32 [ %794, %.preheader ], [ 0, %139 ]
  %683 = add nuw nsw i32 %682, %13
  %684 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %683
  %685 = load i32, i32 addrspace(3)* %684, align 16, !tbaa !8
  %686 = add nuw nsw i32 %682, %11
  %687 = sext i32 %686 to i64
  %688 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %687
  store i32 %685, i32 addrspace(1)* %688, align 4, !tbaa !8
  %689 = or i32 %682, 1
  %690 = add nuw nsw i32 %689, %13
  %691 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %690
  %692 = load i32, i32 addrspace(3)* %691, align 4, !tbaa !8
  %693 = add nuw nsw i32 %689, %11
  %694 = sext i32 %693 to i64
  %695 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %694
  store i32 %692, i32 addrspace(1)* %695, align 4, !tbaa !8
  %696 = or i32 %682, 2
  %697 = add nuw nsw i32 %696, %13
  %698 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %697
  %699 = load i32, i32 addrspace(3)* %698, align 8, !tbaa !8
  %700 = add nuw nsw i32 %696, %11
  %701 = sext i32 %700 to i64
  %702 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %701
  store i32 %699, i32 addrspace(1)* %702, align 4, !tbaa !8
  %703 = or i32 %682, 3
  %704 = add nuw nsw i32 %703, %13
  %705 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %704
  %706 = load i32, i32 addrspace(3)* %705, align 4, !tbaa !8
  %707 = add nuw nsw i32 %703, %11
  %708 = sext i32 %707 to i64
  %709 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %708
  store i32 %706, i32 addrspace(1)* %709, align 4, !tbaa !8
  %710 = or i32 %682, 4
  %711 = add nuw nsw i32 %710, %13
  %712 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %711
  %713 = load i32, i32 addrspace(3)* %712, align 16, !tbaa !8
  %714 = add nuw nsw i32 %710, %11
  %715 = sext i32 %714 to i64
  %716 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %715
  store i32 %713, i32 addrspace(1)* %716, align 4, !tbaa !8
  %717 = or i32 %682, 5
  %718 = add nuw nsw i32 %717, %13
  %719 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %718
  %720 = load i32, i32 addrspace(3)* %719, align 4, !tbaa !8
  %721 = add nuw nsw i32 %717, %11
  %722 = sext i32 %721 to i64
  %723 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %722
  store i32 %720, i32 addrspace(1)* %723, align 4, !tbaa !8
  %724 = or i32 %682, 6
  %725 = add nuw nsw i32 %724, %13
  %726 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %725
  %727 = load i32, i32 addrspace(3)* %726, align 8, !tbaa !8
  %728 = add nuw nsw i32 %724, %11
  %729 = sext i32 %728 to i64
  %730 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %729
  store i32 %727, i32 addrspace(1)* %730, align 4, !tbaa !8
  %731 = or i32 %682, 7
  %732 = add nuw nsw i32 %731, %13
  %733 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %732
  %734 = load i32, i32 addrspace(3)* %733, align 4, !tbaa !8
  %735 = add nuw nsw i32 %731, %11
  %736 = sext i32 %735 to i64
  %737 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %736
  store i32 %734, i32 addrspace(1)* %737, align 4, !tbaa !8
  %738 = or i32 %682, 8
  %739 = add nuw nsw i32 %738, %13
  %740 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %739
  %741 = load i32, i32 addrspace(3)* %740, align 16, !tbaa !8
  %742 = add nuw nsw i32 %738, %11
  %743 = sext i32 %742 to i64
  %744 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %743
  store i32 %741, i32 addrspace(1)* %744, align 4, !tbaa !8
  %745 = or i32 %682, 9
  %746 = add nuw nsw i32 %745, %13
  %747 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %746
  %748 = load i32, i32 addrspace(3)* %747, align 4, !tbaa !8
  %749 = add nuw nsw i32 %745, %11
  %750 = sext i32 %749 to i64
  %751 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %750
  store i32 %748, i32 addrspace(1)* %751, align 4, !tbaa !8
  %752 = or i32 %682, 10
  %753 = add nuw nsw i32 %752, %13
  %754 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %753
  %755 = load i32, i32 addrspace(3)* %754, align 8, !tbaa !8
  %756 = add nuw nsw i32 %752, %11
  %757 = sext i32 %756 to i64
  %758 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %757
  store i32 %755, i32 addrspace(1)* %758, align 4, !tbaa !8
  %759 = or i32 %682, 11
  %760 = add nuw nsw i32 %759, %13
  %761 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %760
  %762 = load i32, i32 addrspace(3)* %761, align 4, !tbaa !8
  %763 = add nuw nsw i32 %759, %11
  %764 = sext i32 %763 to i64
  %765 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %764
  store i32 %762, i32 addrspace(1)* %765, align 4, !tbaa !8
  %766 = or i32 %682, 12
  %767 = add nuw nsw i32 %766, %13
  %768 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %767
  %769 = load i32, i32 addrspace(3)* %768, align 16, !tbaa !8
  %770 = add nuw nsw i32 %766, %11
  %771 = sext i32 %770 to i64
  %772 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %771
  store i32 %769, i32 addrspace(1)* %772, align 4, !tbaa !8
  %773 = or i32 %682, 13
  %774 = add nuw nsw i32 %773, %13
  %775 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %774
  %776 = load i32, i32 addrspace(3)* %775, align 4, !tbaa !8
  %777 = add nuw nsw i32 %773, %11
  %778 = sext i32 %777 to i64
  %779 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %778
  store i32 %776, i32 addrspace(1)* %779, align 4, !tbaa !8
  %780 = or i32 %682, 14
  %781 = add nuw nsw i32 %780, %13
  %782 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %781
  %783 = load i32, i32 addrspace(3)* %782, align 8, !tbaa !8
  %784 = add nuw nsw i32 %780, %11
  %785 = sext i32 %784 to i64
  %786 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %785
  store i32 %783, i32 addrspace(1)* %786, align 4, !tbaa !8
  %787 = or i32 %682, 15
  %788 = add nuw nsw i32 %787, %13
  %789 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %788
  %790 = load i32, i32 addrspace(3)* %789, align 4, !tbaa !8
  %791 = add nuw nsw i32 %787, %11
  %792 = sext i32 %791 to i64
  %793 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %792
  store i32 %790, i32 addrspace(1)* %793, align 4, !tbaa !8
  %794 = add nuw nsw i32 %682, 16
  %795 = icmp eq i32 %794, 256
  br i1 %795, label %.loopexit, label %.preheader, !llvm.loop !20

.loopexit:                                        ; preds = %.preheader, %139
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  ret void

796:                                              ; preds = %590
  store i32 %591, i32 addrspace(3)* %597, align 8, !tbaa !8
  %797 = add nsw i32 %593, -1
  %.pre35 = add nsw i32 %797, %134
  %.phi.trans.insert62 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre35
  %.pre63 = load i32, i32 addrspace(3)* %.phi.trans.insert62, align 4, !tbaa !8
  br label %800

798:                                              ; preds = %590
  store i32 %592, i32 addrspace(3)* %597, align 8, !tbaa !8
  %799 = add nsw i32 %594, -1
  %.pre33 = add nsw i32 %799, %13
  %.phi.trans.insert60 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre33
  %.pre61 = load i32, i32 addrspace(3)* %.phi.trans.insert60, align 4, !tbaa !8
  br label %800

800:                                              ; preds = %798, %796
  %801 = phi i32 [ %591, %798 ], [ %.pre63, %796 ]
  %802 = phi i32 [ %.pre61, %798 ], [ %592, %796 ]
  %803 = phi i32 [ %593, %798 ], [ %797, %796 ]
  %804 = phi i32 [ %799, %798 ], [ %594, %796 ]
  %805 = icmp sgt i32 %802, %801
  %806 = sub nuw nsw i32 253, %574
  %807 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %806
  br i1 %805, label %810, label %808

808:                                              ; preds = %800
  store i32 %801, i32 addrspace(3)* %807, align 4, !tbaa !8
  %809 = add nsw i32 %803, -1
  %.pre39 = add nsw i32 %809, %134
  %.phi.trans.insert66 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre39
  %.pre67 = load i32, i32 addrspace(3)* %.phi.trans.insert66, align 4, !tbaa !8
  br label %812

810:                                              ; preds = %800
  store i32 %802, i32 addrspace(3)* %807, align 4, !tbaa !8
  %811 = add nsw i32 %804, -1
  %.pre37 = add nsw i32 %811, %13
  %.phi.trans.insert64 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre37
  %.pre65 = load i32, i32 addrspace(3)* %.phi.trans.insert64, align 4, !tbaa !8
  br label %812

812:                                              ; preds = %810, %808
  %813 = phi i32 [ %801, %810 ], [ %.pre67, %808 ]
  %814 = phi i32 [ %.pre65, %810 ], [ %802, %808 ]
  %815 = phi i32 [ %803, %810 ], [ %809, %808 ]
  %816 = phi i32 [ %811, %810 ], [ %804, %808 ]
  %817 = icmp sgt i32 %814, %813
  %818 = sub nuw nsw i32 252, %574
  %819 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %818
  br i1 %817, label %822, label %820

820:                                              ; preds = %812
  store i32 %813, i32 addrspace(3)* %819, align 16, !tbaa !8
  %821 = add nsw i32 %815, -1
  %.pre43 = add nsw i32 %821, %134
  %.phi.trans.insert70 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre43
  %.pre71 = load i32, i32 addrspace(3)* %.phi.trans.insert70, align 4, !tbaa !8
  br label %824

822:                                              ; preds = %812
  store i32 %814, i32 addrspace(3)* %819, align 16, !tbaa !8
  %823 = add nsw i32 %816, -1
  %.pre41 = add nsw i32 %823, %13
  %.phi.trans.insert68 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre41
  %.pre69 = load i32, i32 addrspace(3)* %.phi.trans.insert68, align 4, !tbaa !8
  br label %824

824:                                              ; preds = %822, %820
  %825 = phi i32 [ %813, %822 ], [ %.pre71, %820 ]
  %826 = phi i32 [ %.pre69, %822 ], [ %814, %820 ]
  %827 = phi i32 [ %815, %822 ], [ %821, %820 ]
  %828 = phi i32 [ %823, %822 ], [ %816, %820 ]
  %829 = icmp sgt i32 %826, %825
  %830 = sub nuw nsw i32 251, %574
  %831 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %830
  br i1 %829, label %834, label %832

832:                                              ; preds = %824
  store i32 %825, i32 addrspace(3)* %831, align 4, !tbaa !8
  %833 = add nsw i32 %827, -1
  %.pre47 = add nsw i32 %833, %134
  %.phi.trans.insert74 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre47
  %.pre75 = load i32, i32 addrspace(3)* %.phi.trans.insert74, align 4, !tbaa !8
  br label %836

834:                                              ; preds = %824
  store i32 %826, i32 addrspace(3)* %831, align 4, !tbaa !8
  %835 = add nsw i32 %828, -1
  %.pre45 = add nsw i32 %835, %13
  %.phi.trans.insert72 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre45
  %.pre73 = load i32, i32 addrspace(3)* %.phi.trans.insert72, align 4, !tbaa !8
  br label %836

836:                                              ; preds = %834, %832
  %837 = phi i32 [ %825, %834 ], [ %.pre75, %832 ]
  %838 = phi i32 [ %.pre73, %834 ], [ %826, %832 ]
  %839 = phi i32 [ %827, %834 ], [ %833, %832 ]
  %840 = phi i32 [ %835, %834 ], [ %828, %832 ]
  %841 = icmp sgt i32 %838, %837
  %842 = sub nuw nsw i32 250, %574
  %843 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %842
  br i1 %841, label %846, label %844

844:                                              ; preds = %836
  store i32 %837, i32 addrspace(3)* %843, align 8, !tbaa !8
  %845 = add nsw i32 %839, -1
  %.pre51 = add nsw i32 %845, %134
  %.phi.trans.insert78 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre51
  %.pre79 = load i32, i32 addrspace(3)* %.phi.trans.insert78, align 4, !tbaa !8
  br label %848

846:                                              ; preds = %836
  store i32 %838, i32 addrspace(3)* %843, align 8, !tbaa !8
  %847 = add nsw i32 %840, -1
  %.pre49 = add nsw i32 %847, %13
  %.phi.trans.insert76 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre49
  %.pre77 = load i32, i32 addrspace(3)* %.phi.trans.insert76, align 4, !tbaa !8
  br label %848

848:                                              ; preds = %846, %844
  %849 = phi i32 [ %837, %846 ], [ %.pre79, %844 ]
  %850 = phi i32 [ %.pre77, %846 ], [ %838, %844 ]
  %851 = phi i32 [ %839, %846 ], [ %845, %844 ]
  %852 = phi i32 [ %847, %846 ], [ %840, %844 ]
  %853 = icmp sgt i32 %850, %849
  %854 = sub nuw nsw i32 249, %574
  %855 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %854
  br i1 %853, label %858, label %856

856:                                              ; preds = %848
  store i32 %849, i32 addrspace(3)* %855, align 4, !tbaa !8
  %857 = add nsw i32 %851, -1
  %.pre55 = add nsw i32 %857, %134
  %.phi.trans.insert82 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre55
  %.pre83 = load i32, i32 addrspace(3)* %.phi.trans.insert82, align 4, !tbaa !8
  br label %860

858:                                              ; preds = %848
  store i32 %850, i32 addrspace(3)* %855, align 4, !tbaa !8
  %859 = add nsw i32 %852, -1
  %.pre53 = add nsw i32 %859, %13
  %.phi.trans.insert80 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre53
  %.pre81 = load i32, i32 addrspace(3)* %.phi.trans.insert80, align 4, !tbaa !8
  br label %860

860:                                              ; preds = %858, %856
  %861 = phi i32 [ %849, %858 ], [ %.pre83, %856 ]
  %862 = phi i32 [ %.pre81, %858 ], [ %850, %856 ]
  %863 = phi i32 [ %851, %858 ], [ %857, %856 ]
  %864 = phi i32 [ %859, %858 ], [ %852, %856 ]
  %865 = icmp sgt i32 %862, %861
  %866 = sub nuw nsw i32 248, %574
  %867 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %866
  br i1 %865, label %870, label %868

868:                                              ; preds = %860
  store i32 %861, i32 addrspace(3)* %867, align 16, !tbaa !8
  %869 = add nsw i32 %863, -1
  br label %872

870:                                              ; preds = %860
  store i32 %862, i32 addrspace(3)* %867, align 16, !tbaa !8
  %871 = add nsw i32 %864, -1
  br label %872

872:                                              ; preds = %870, %868
  %873 = phi i32 [ %869, %868 ], [ %863, %870 ]
  %874 = phi i32 [ %864, %868 ], [ %871, %870 ]
  %875 = add nuw nsw i32 %574, 8
  %876 = icmp eq i32 %875, 256
  br i1 %876, label %.loopexit21, label %.preheader22, !llvm.loop !21
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
