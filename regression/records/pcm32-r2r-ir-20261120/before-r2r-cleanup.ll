; ModuleID = 'build/region-audit/native-exact/PCM32/10/parent.ll'
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

merged.branch.split:                              ; preds = %merged.branch.split, %unify.bb
  %14 = phi i32 [ 0, %unify.bb ], [ %126, %merged.branch.split ]
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
  br label %141

139:                                              ; preds = %693
  br i1 %10, label %140, label %811

140:                                              ; preds = %139
  br label %696

141:                                              ; preds = %693, %merged.branch.split1
  %142 = phi i32 [ 0, %merged.branch.split1 ], [ %694, %693 ]
  br i1 %133, label %143, label %unify.bb2

143:                                              ; preds = %143, %141
  %144 = phi i32 [ 0, %141 ], [ %266, %143 ]
  %145 = phi i32 [ 0, %141 ], [ %264, %143 ]
  %146 = phi i32 [ 0, %141 ], [ %262, %143 ]
  %147 = add nsw i32 %146, %13
  %148 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %147
  %149 = load i32, i32 addrspace(3)* %148, align 4, !tbaa !8
  %150 = add nsw i32 %135, %145
  %151 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %150
  %152 = load i32, i32 addrspace(3)* %151, align 4, !tbaa !8
  %153 = icmp sgt i32 %149, %152
  %154 = select i1 %153, i32 %152, i32 %149
  %155 = xor i1 %153, true
  %156 = zext i1 %155 to i32
  %157 = add nuw nsw i32 %146, %156
  %158 = zext i1 %153 to i32
  %159 = add nuw nsw i32 %145, %158
  %160 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %144
  store i32 %154, i32 addrspace(3)* %160, align 16
  %161 = or i32 %144, 1
  %162 = add nsw i32 %157, %13
  %163 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %162
  %164 = load i32, i32 addrspace(3)* %163, align 4, !tbaa !8
  %165 = add nsw i32 %135, %159
  %166 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %165
  %167 = load i32, i32 addrspace(3)* %166, align 4, !tbaa !8
  %168 = icmp sgt i32 %164, %167
  %169 = select i1 %168, i32 %167, i32 %164
  %170 = xor i1 %168, true
  %171 = zext i1 %170 to i32
  %172 = add nuw nsw i32 %157, %171
  %173 = zext i1 %168 to i32
  %174 = add nuw nsw i32 %159, %173
  %175 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %161
  store i32 %169, i32 addrspace(3)* %175, align 4
  %176 = or i32 %144, 2
  %177 = add nsw i32 %172, %13
  %178 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %177
  %179 = load i32, i32 addrspace(3)* %178, align 4, !tbaa !8
  %180 = add nsw i32 %135, %174
  %181 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %180
  %182 = load i32, i32 addrspace(3)* %181, align 4, !tbaa !8
  %183 = icmp sgt i32 %179, %182
  %184 = select i1 %183, i32 %182, i32 %179
  %185 = xor i1 %183, true
  %186 = zext i1 %185 to i32
  %187 = add nuw nsw i32 %172, %186
  %188 = zext i1 %183 to i32
  %189 = add nuw nsw i32 %174, %188
  %190 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %176
  store i32 %184, i32 addrspace(3)* %190, align 8
  %191 = or i32 %144, 3
  %192 = add nsw i32 %187, %13
  %193 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %192
  %194 = load i32, i32 addrspace(3)* %193, align 4, !tbaa !8
  %195 = add nsw i32 %135, %189
  %196 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %195
  %197 = load i32, i32 addrspace(3)* %196, align 4, !tbaa !8
  %198 = icmp sgt i32 %194, %197
  %199 = select i1 %198, i32 %197, i32 %194
  %200 = xor i1 %198, true
  %201 = zext i1 %200 to i32
  %202 = add nuw nsw i32 %187, %201
  %203 = zext i1 %198 to i32
  %204 = add nuw nsw i32 %189, %203
  %205 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %191
  store i32 %199, i32 addrspace(3)* %205, align 4
  %206 = or i32 %144, 4
  %207 = add nsw i32 %202, %13
  %208 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %207
  %209 = load i32, i32 addrspace(3)* %208, align 4, !tbaa !8
  %210 = add nsw i32 %135, %204
  %211 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %210
  %212 = load i32, i32 addrspace(3)* %211, align 4, !tbaa !8
  %213 = icmp sgt i32 %209, %212
  %214 = select i1 %213, i32 %212, i32 %209
  %215 = xor i1 %213, true
  %216 = zext i1 %215 to i32
  %217 = add nuw nsw i32 %202, %216
  %218 = zext i1 %213 to i32
  %219 = add nuw nsw i32 %204, %218
  %220 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %206
  store i32 %214, i32 addrspace(3)* %220, align 16
  %221 = or i32 %144, 5
  %222 = add nsw i32 %217, %13
  %223 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %222
  %224 = load i32, i32 addrspace(3)* %223, align 4, !tbaa !8
  %225 = add nsw i32 %135, %219
  %226 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %225
  %227 = load i32, i32 addrspace(3)* %226, align 4, !tbaa !8
  %228 = icmp sgt i32 %224, %227
  %229 = select i1 %228, i32 %227, i32 %224
  %230 = xor i1 %228, true
  %231 = zext i1 %230 to i32
  %232 = add nuw nsw i32 %217, %231
  %233 = zext i1 %228 to i32
  %234 = add nuw nsw i32 %219, %233
  %235 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %221
  store i32 %229, i32 addrspace(3)* %235, align 4
  %236 = or i32 %144, 6
  %237 = add nsw i32 %232, %13
  %238 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %237
  %239 = load i32, i32 addrspace(3)* %238, align 4, !tbaa !8
  %240 = add nsw i32 %135, %234
  %241 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %240
  %242 = load i32, i32 addrspace(3)* %241, align 4, !tbaa !8
  %243 = icmp sgt i32 %239, %242
  %244 = select i1 %243, i32 %242, i32 %239
  %245 = xor i1 %243, true
  %246 = zext i1 %245 to i32
  %247 = add nuw nsw i32 %232, %246
  %248 = zext i1 %243 to i32
  %249 = add nuw nsw i32 %234, %248
  %250 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %236
  store i32 %244, i32 addrspace(3)* %250, align 8
  %251 = or i32 %144, 7
  %252 = add nsw i32 %247, %13
  %253 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %252
  %254 = load i32, i32 addrspace(3)* %253, align 4, !tbaa !8
  %255 = add nsw i32 %135, %249
  %256 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %255
  %257 = load i32, i32 addrspace(3)* %256, align 4, !tbaa !8
  %258 = icmp sgt i32 %254, %257
  %259 = select i1 %258, i32 %257, i32 %254
  %260 = xor i1 %258, true
  %261 = zext i1 %260 to i32
  %262 = add nuw nsw i32 %247, %261
  %263 = zext i1 %258 to i32
  %264 = add nuw nsw i32 %249, %263
  %265 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %251
  store i32 %259, i32 addrspace(3)* %265, align 4
  %266 = add nuw nsw i32 %144, 8
  %267 = icmp eq i32 %266, 256
  br i1 %267, label %369, label %143, !llvm.loop !14

unify.bb2:                                        ; preds = %unify.bb2, %141
  %268 = phi i32 [ 0, %141 ], [ %367, %unify.bb2 ]
  %269 = phi i32 [ 255, %141 ], [ %366, %unify.bb2 ]
  %270 = phi i32 [ 255, %141 ], [ %365, %unify.bb2 ]
  %271 = add nsw i32 %269, %13
  %272 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %271
  %273 = load i32, i32 addrspace(3)* %272, align 4, !tbaa !8
  %274 = add nsw i32 %134, %270
  %275 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %274
  %276 = load i32, i32 addrspace(3)* %275, align 4, !tbaa !8
  %277 = icmp sgt i32 %273, %276
  %278 = sub nuw nsw i32 255, %268
  %279 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %278
  %merged.select = select i1 %277, i32 %273, i32 %276
  store i32 %merged.select, i32 addrspace(3)* %279, align 4, !tbaa !8
  %merged.select3 = select i1 %277, i32 %269, i32 %270
  %280 = add nsw i32 %merged.select3, -1
  %281 = select i1 %277, i32 %270, i32 %280
  %282 = select i1 %277, i32 %280, i32 %269
  %283 = add nsw i32 %282, %13
  %284 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %283
  %285 = load i32, i32 addrspace(3)* %284, align 4, !tbaa !8
  %286 = add nsw i32 %134, %281
  %287 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %286
  %288 = load i32, i32 addrspace(3)* %287, align 4, !tbaa !8
  %289 = icmp sgt i32 %285, %288
  %290 = sub nsw i32 254, %268
  %291 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %290
  %merged.select7 = select i1 %289, i32 %285, i32 %288
  store i32 %merged.select7, i32 addrspace(3)* %291, align 8, !tbaa !8
  %merged.select8 = select i1 %289, i32 %282, i32 %281
  %292 = add nsw i32 %merged.select8, -1
  %293 = select i1 %289, i32 %281, i32 %292
  %294 = select i1 %289, i32 %292, i32 %282
  %295 = add nsw i32 %294, %13
  %296 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %295
  %297 = load i32, i32 addrspace(3)* %296, align 4, !tbaa !8
  %298 = add nsw i32 %134, %293
  %299 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %298
  %300 = load i32, i32 addrspace(3)* %299, align 4, !tbaa !8
  %301 = icmp sgt i32 %297, %300
  %302 = sub nsw i32 253, %268
  %303 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %302
  %merged.select12 = select i1 %301, i32 %297, i32 %300
  store i32 %merged.select12, i32 addrspace(3)* %303, align 4, !tbaa !8
  %merged.select13 = select i1 %301, i32 %294, i32 %293
  %304 = add nsw i32 %merged.select13, -1
  %305 = select i1 %301, i32 %293, i32 %304
  %306 = select i1 %301, i32 %304, i32 %294
  %307 = add nsw i32 %306, %13
  %308 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %307
  %309 = load i32, i32 addrspace(3)* %308, align 4, !tbaa !8
  %310 = add nsw i32 %134, %305
  %311 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %310
  %312 = load i32, i32 addrspace(3)* %311, align 4, !tbaa !8
  %313 = icmp sgt i32 %309, %312
  %314 = sub nsw i32 252, %268
  %315 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %314
  %merged.select17 = select i1 %313, i32 %309, i32 %312
  store i32 %merged.select17, i32 addrspace(3)* %315, align 16, !tbaa !8
  %merged.select18 = select i1 %313, i32 %306, i32 %305
  %316 = add nsw i32 %merged.select18, -1
  %317 = select i1 %313, i32 %305, i32 %316
  %318 = select i1 %313, i32 %316, i32 %306
  %319 = add nsw i32 %318, %13
  %320 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %319
  %321 = load i32, i32 addrspace(3)* %320, align 4, !tbaa !8
  %322 = add nsw i32 %134, %317
  %323 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %322
  %324 = load i32, i32 addrspace(3)* %323, align 4, !tbaa !8
  %325 = icmp sgt i32 %321, %324
  %326 = sub nsw i32 251, %268
  %327 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %326
  %merged.select22 = select i1 %325, i32 %321, i32 %324
  store i32 %merged.select22, i32 addrspace(3)* %327, align 4, !tbaa !8
  %merged.select23 = select i1 %325, i32 %318, i32 %317
  %328 = add nsw i32 %merged.select23, -1
  %329 = select i1 %325, i32 %317, i32 %328
  %330 = select i1 %325, i32 %328, i32 %318
  %331 = add nsw i32 %330, %13
  %332 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %331
  %333 = load i32, i32 addrspace(3)* %332, align 4, !tbaa !8
  %334 = add nsw i32 %134, %329
  %335 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %334
  %336 = load i32, i32 addrspace(3)* %335, align 4, !tbaa !8
  %337 = icmp sgt i32 %333, %336
  %338 = sub nsw i32 250, %268
  %339 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %338
  %merged.select27 = select i1 %337, i32 %333, i32 %336
  store i32 %merged.select27, i32 addrspace(3)* %339, align 8, !tbaa !8
  %merged.select28 = select i1 %337, i32 %330, i32 %329
  %340 = add nsw i32 %merged.select28, -1
  %341 = select i1 %337, i32 %329, i32 %340
  %342 = select i1 %337, i32 %340, i32 %330
  %343 = add nsw i32 %342, %13
  %344 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %343
  %345 = load i32, i32 addrspace(3)* %344, align 4, !tbaa !8
  %346 = add nsw i32 %134, %341
  %347 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %346
  %348 = load i32, i32 addrspace(3)* %347, align 4, !tbaa !8
  %349 = icmp sgt i32 %345, %348
  %350 = sub nsw i32 249, %268
  %351 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %350
  %merged.select32 = select i1 %349, i32 %345, i32 %348
  store i32 %merged.select32, i32 addrspace(3)* %351, align 4, !tbaa !8
  %merged.select33 = select i1 %349, i32 %342, i32 %341
  %352 = add nsw i32 %merged.select33, -1
  %353 = select i1 %349, i32 %341, i32 %352
  %354 = select i1 %349, i32 %352, i32 %342
  %355 = add nsw i32 %354, %13
  %356 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %355
  %357 = load i32, i32 addrspace(3)* %356, align 4, !tbaa !8
  %358 = add nsw i32 %134, %353
  %359 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %358
  %360 = load i32, i32 addrspace(3)* %359, align 4, !tbaa !8
  %361 = icmp sgt i32 %357, %360
  %362 = sub nsw i32 248, %268
  %363 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %362
  %merged.select37 = select i1 %361, i32 %357, i32 %360
  store i32 %merged.select37, i32 addrspace(3)* %363, align 16, !tbaa !8
  %merged.select38 = select i1 %361, i32 %354, i32 %353
  %364 = add nsw i32 %merged.select38, -1
  %365 = select i1 %361, i32 %353, i32 %364
  %366 = select i1 %361, i32 %364, i32 %354
  %367 = add nuw nsw i32 %268, 8
  %368 = icmp eq i32 %367, 256
  br i1 %368, label %369, label %unify.bb2, !llvm.loop !15

369:                                              ; preds = %unify.bb2, %143
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %136, label %370, label %453

370:                                              ; preds = %370, %369
  %371 = phi i32 [ 0, %369 ], [ %451, %370 ]
  %372 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %371
  %373 = load i32, i32 addrspace(3)* %372, align 16, !tbaa !8
  %374 = add nuw nsw i32 %371, %13
  %375 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %374
  store i32 %373, i32 addrspace(3)* %375, align 16, !tbaa !8
  %376 = or i32 %371, 1
  %377 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %376
  %378 = load i32, i32 addrspace(3)* %377, align 4, !tbaa !8
  %379 = add nuw nsw i32 %376, %13
  %380 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %379
  store i32 %378, i32 addrspace(3)* %380, align 4, !tbaa !8
  %381 = or i32 %371, 2
  %382 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %381
  %383 = load i32, i32 addrspace(3)* %382, align 8, !tbaa !8
  %384 = add nuw nsw i32 %381, %13
  %385 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %384
  store i32 %383, i32 addrspace(3)* %385, align 8, !tbaa !8
  %386 = or i32 %371, 3
  %387 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %386
  %388 = load i32, i32 addrspace(3)* %387, align 4, !tbaa !8
  %389 = add nuw nsw i32 %386, %13
  %390 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %389
  store i32 %388, i32 addrspace(3)* %390, align 4, !tbaa !8
  %391 = or i32 %371, 4
  %392 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %391
  %393 = load i32, i32 addrspace(3)* %392, align 16, !tbaa !8
  %394 = add nuw nsw i32 %391, %13
  %395 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %394
  store i32 %393, i32 addrspace(3)* %395, align 16, !tbaa !8
  %396 = or i32 %371, 5
  %397 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %396
  %398 = load i32, i32 addrspace(3)* %397, align 4, !tbaa !8
  %399 = add nuw nsw i32 %396, %13
  %400 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %399
  store i32 %398, i32 addrspace(3)* %400, align 4, !tbaa !8
  %401 = or i32 %371, 6
  %402 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %401
  %403 = load i32, i32 addrspace(3)* %402, align 8, !tbaa !8
  %404 = add nuw nsw i32 %401, %13
  %405 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %404
  store i32 %403, i32 addrspace(3)* %405, align 8, !tbaa !8
  %406 = or i32 %371, 7
  %407 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %406
  %408 = load i32, i32 addrspace(3)* %407, align 4, !tbaa !8
  %409 = add nuw nsw i32 %406, %13
  %410 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %409
  store i32 %408, i32 addrspace(3)* %410, align 4, !tbaa !8
  %411 = or i32 %371, 8
  %412 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %411
  %413 = load i32, i32 addrspace(3)* %412, align 16, !tbaa !8
  %414 = add nuw nsw i32 %411, %13
  %415 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %414
  store i32 %413, i32 addrspace(3)* %415, align 16, !tbaa !8
  %416 = or i32 %371, 9
  %417 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %416
  %418 = load i32, i32 addrspace(3)* %417, align 4, !tbaa !8
  %419 = add nuw nsw i32 %416, %13
  %420 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %419
  store i32 %418, i32 addrspace(3)* %420, align 4, !tbaa !8
  %421 = or i32 %371, 10
  %422 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %421
  %423 = load i32, i32 addrspace(3)* %422, align 8, !tbaa !8
  %424 = add nuw nsw i32 %421, %13
  %425 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %424
  store i32 %423, i32 addrspace(3)* %425, align 8, !tbaa !8
  %426 = or i32 %371, 11
  %427 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %426
  %428 = load i32, i32 addrspace(3)* %427, align 4, !tbaa !8
  %429 = add nuw nsw i32 %426, %13
  %430 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %429
  store i32 %428, i32 addrspace(3)* %430, align 4, !tbaa !8
  %431 = or i32 %371, 12
  %432 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %431
  %433 = load i32, i32 addrspace(3)* %432, align 16, !tbaa !8
  %434 = add nuw nsw i32 %431, %13
  %435 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %434
  store i32 %433, i32 addrspace(3)* %435, align 16, !tbaa !8
  %436 = or i32 %371, 13
  %437 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %436
  %438 = load i32, i32 addrspace(3)* %437, align 4, !tbaa !8
  %439 = add nuw nsw i32 %436, %13
  %440 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %439
  store i32 %438, i32 addrspace(3)* %440, align 4, !tbaa !8
  %441 = or i32 %371, 14
  %442 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %441
  %443 = load i32, i32 addrspace(3)* %442, align 8, !tbaa !8
  %444 = add nuw nsw i32 %441, %13
  %445 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %444
  store i32 %443, i32 addrspace(3)* %445, align 8, !tbaa !8
  %446 = or i32 %371, 15
  %447 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %446
  %448 = load i32, i32 addrspace(3)* %447, align 4, !tbaa !8
  %449 = add nuw nsw i32 %446, %13
  %450 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %449
  store i32 %448, i32 addrspace(3)* %450, align 4, !tbaa !8
  %451 = add nuw nsw i32 %371, 16
  %452 = icmp eq i32 %451, 256
  br i1 %452, label %453, label %370, !llvm.loop !16

453:                                              ; preds = %370, %369
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %137, label %454, label %579

454:                                              ; preds = %454, %453
  %455 = phi i32 [ 0, %453 ], [ %577, %454 ]
  %456 = phi i32 [ 0, %453 ], [ %575, %454 ]
  %457 = phi i32 [ 0, %453 ], [ %573, %454 ]
  %458 = add nsw i32 %457, %13
  %459 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %458
  %460 = load i32, i32 addrspace(3)* %459, align 4, !tbaa !8
  %461 = add nsw i32 %135, %456
  %462 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %461
  %463 = load i32, i32 addrspace(3)* %462, align 4, !tbaa !8
  %464 = icmp sgt i32 %460, %463
  %465 = select i1 %464, i32 %463, i32 %460
  %466 = xor i1 %464, true
  %467 = zext i1 %466 to i32
  %468 = add nuw nsw i32 %457, %467
  %469 = zext i1 %464 to i32
  %470 = add nuw nsw i32 %456, %469
  %471 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %455
  store i32 %465, i32 addrspace(3)* %471, align 16
  %472 = or i32 %455, 1
  %473 = add nsw i32 %468, %13
  %474 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %473
  %475 = load i32, i32 addrspace(3)* %474, align 4, !tbaa !8
  %476 = add nsw i32 %135, %470
  %477 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %476
  %478 = load i32, i32 addrspace(3)* %477, align 4, !tbaa !8
  %479 = icmp sgt i32 %475, %478
  %480 = select i1 %479, i32 %478, i32 %475
  %481 = xor i1 %479, true
  %482 = zext i1 %481 to i32
  %483 = add nuw nsw i32 %468, %482
  %484 = zext i1 %479 to i32
  %485 = add nuw nsw i32 %470, %484
  %486 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %472
  store i32 %480, i32 addrspace(3)* %486, align 4
  %487 = or i32 %455, 2
  %488 = add nsw i32 %483, %13
  %489 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %488
  %490 = load i32, i32 addrspace(3)* %489, align 4, !tbaa !8
  %491 = add nsw i32 %135, %485
  %492 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %491
  %493 = load i32, i32 addrspace(3)* %492, align 4, !tbaa !8
  %494 = icmp sgt i32 %490, %493
  %495 = select i1 %494, i32 %493, i32 %490
  %496 = xor i1 %494, true
  %497 = zext i1 %496 to i32
  %498 = add nuw nsw i32 %483, %497
  %499 = zext i1 %494 to i32
  %500 = add nuw nsw i32 %485, %499
  %501 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %487
  store i32 %495, i32 addrspace(3)* %501, align 8
  %502 = or i32 %455, 3
  %503 = add nsw i32 %498, %13
  %504 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %503
  %505 = load i32, i32 addrspace(3)* %504, align 4, !tbaa !8
  %506 = add nsw i32 %135, %500
  %507 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %506
  %508 = load i32, i32 addrspace(3)* %507, align 4, !tbaa !8
  %509 = icmp sgt i32 %505, %508
  %510 = select i1 %509, i32 %508, i32 %505
  %511 = xor i1 %509, true
  %512 = zext i1 %511 to i32
  %513 = add nuw nsw i32 %498, %512
  %514 = zext i1 %509 to i32
  %515 = add nuw nsw i32 %500, %514
  %516 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %502
  store i32 %510, i32 addrspace(3)* %516, align 4
  %517 = or i32 %455, 4
  %518 = add nsw i32 %513, %13
  %519 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %518
  %520 = load i32, i32 addrspace(3)* %519, align 4, !tbaa !8
  %521 = add nsw i32 %135, %515
  %522 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %521
  %523 = load i32, i32 addrspace(3)* %522, align 4, !tbaa !8
  %524 = icmp sgt i32 %520, %523
  %525 = select i1 %524, i32 %523, i32 %520
  %526 = xor i1 %524, true
  %527 = zext i1 %526 to i32
  %528 = add nuw nsw i32 %513, %527
  %529 = zext i1 %524 to i32
  %530 = add nuw nsw i32 %515, %529
  %531 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %517
  store i32 %525, i32 addrspace(3)* %531, align 16
  %532 = or i32 %455, 5
  %533 = add nsw i32 %528, %13
  %534 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %533
  %535 = load i32, i32 addrspace(3)* %534, align 4, !tbaa !8
  %536 = add nsw i32 %135, %530
  %537 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %536
  %538 = load i32, i32 addrspace(3)* %537, align 4, !tbaa !8
  %539 = icmp sgt i32 %535, %538
  %540 = select i1 %539, i32 %538, i32 %535
  %541 = xor i1 %539, true
  %542 = zext i1 %541 to i32
  %543 = add nuw nsw i32 %528, %542
  %544 = zext i1 %539 to i32
  %545 = add nuw nsw i32 %530, %544
  %546 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %532
  store i32 %540, i32 addrspace(3)* %546, align 4
  %547 = or i32 %455, 6
  %548 = add nsw i32 %543, %13
  %549 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %548
  %550 = load i32, i32 addrspace(3)* %549, align 4, !tbaa !8
  %551 = add nsw i32 %135, %545
  %552 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %551
  %553 = load i32, i32 addrspace(3)* %552, align 4, !tbaa !8
  %554 = icmp sgt i32 %550, %553
  %555 = select i1 %554, i32 %553, i32 %550
  %556 = xor i1 %554, true
  %557 = zext i1 %556 to i32
  %558 = add nuw nsw i32 %543, %557
  %559 = zext i1 %554 to i32
  %560 = add nuw nsw i32 %545, %559
  %561 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %547
  store i32 %555, i32 addrspace(3)* %561, align 8
  %562 = or i32 %455, 7
  %563 = add nsw i32 %558, %13
  %564 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %563
  %565 = load i32, i32 addrspace(3)* %564, align 4, !tbaa !8
  %566 = add nsw i32 %135, %560
  %567 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %566
  %568 = load i32, i32 addrspace(3)* %567, align 4, !tbaa !8
  %569 = icmp sgt i32 %565, %568
  %570 = select i1 %569, i32 %568, i32 %565
  %571 = xor i1 %569, true
  %572 = zext i1 %571 to i32
  %573 = add nuw nsw i32 %558, %572
  %574 = zext i1 %569 to i32
  %575 = add nuw nsw i32 %560, %574
  %576 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %562
  store i32 %570, i32 addrspace(3)* %576, align 4
  %577 = add nuw nsw i32 %455, 8
  %578 = icmp eq i32 %577, 256
  br i1 %578, label %609, label %454, !llvm.loop !17

579:                                              ; preds = %453
  br i1 %138, label %609, label %580

580:                                              ; preds = %912, %579
  %581 = phi i32 [ 0, %579 ], [ %915, %912 ]
  %582 = phi i32 [ 255, %579 ], [ %914, %912 ]
  %583 = phi i32 [ 255, %579 ], [ %913, %912 ]
  %584 = add nsw i32 %582, %13
  %585 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %584
  %586 = load i32, i32 addrspace(3)* %585, align 4, !tbaa !8
  %587 = add nsw i32 %134, %583
  %588 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %587
  %589 = load i32, i32 addrspace(3)* %588, align 4, !tbaa !8
  %590 = icmp sgt i32 %586, %589
  %591 = sub nuw nsw i32 255, %581
  %592 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %591
  br i1 %590, label %593, label %595

593:                                              ; preds = %580
  store i32 %586, i32 addrspace(3)* %592, align 4, !tbaa !8
  %594 = add nsw i32 %582, -1
  br label %597

595:                                              ; preds = %580
  store i32 %589, i32 addrspace(3)* %592, align 4, !tbaa !8
  %596 = add nsw i32 %583, -1
  br label %597

597:                                              ; preds = %595, %593
  %598 = phi i32 [ %583, %593 ], [ %596, %595 ]
  %599 = phi i32 [ %594, %593 ], [ %582, %595 ]
  %600 = add nsw i32 %599, %13
  %601 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %600
  %602 = load i32, i32 addrspace(3)* %601, align 4, !tbaa !8
  %603 = add nsw i32 %134, %598
  %604 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %603
  %605 = load i32, i32 addrspace(3)* %604, align 4, !tbaa !8
  %606 = icmp sgt i32 %602, %605
  %607 = sub nsw i32 254, %581
  %608 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %607
  br i1 %606, label %814, label %812

609:                                              ; preds = %912, %579, %454
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %136, label %610, label %693

610:                                              ; preds = %610, %609
  %611 = phi i32 [ 0, %609 ], [ %691, %610 ]
  %612 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %611
  %613 = load i32, i32 addrspace(3)* %612, align 16, !tbaa !8
  %614 = add nuw nsw i32 %611, %13
  %615 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %614
  store i32 %613, i32 addrspace(3)* %615, align 16, !tbaa !8
  %616 = or i32 %611, 1
  %617 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %616
  %618 = load i32, i32 addrspace(3)* %617, align 4, !tbaa !8
  %619 = add nuw nsw i32 %616, %13
  %620 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %619
  store i32 %618, i32 addrspace(3)* %620, align 4, !tbaa !8
  %621 = or i32 %611, 2
  %622 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %621
  %623 = load i32, i32 addrspace(3)* %622, align 8, !tbaa !8
  %624 = add nuw nsw i32 %621, %13
  %625 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %624
  store i32 %623, i32 addrspace(3)* %625, align 8, !tbaa !8
  %626 = or i32 %611, 3
  %627 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %626
  %628 = load i32, i32 addrspace(3)* %627, align 4, !tbaa !8
  %629 = add nuw nsw i32 %626, %13
  %630 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %629
  store i32 %628, i32 addrspace(3)* %630, align 4, !tbaa !8
  %631 = or i32 %611, 4
  %632 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %631
  %633 = load i32, i32 addrspace(3)* %632, align 16, !tbaa !8
  %634 = add nuw nsw i32 %631, %13
  %635 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %634
  store i32 %633, i32 addrspace(3)* %635, align 16, !tbaa !8
  %636 = or i32 %611, 5
  %637 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %636
  %638 = load i32, i32 addrspace(3)* %637, align 4, !tbaa !8
  %639 = add nuw nsw i32 %636, %13
  %640 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %639
  store i32 %638, i32 addrspace(3)* %640, align 4, !tbaa !8
  %641 = or i32 %611, 6
  %642 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %641
  %643 = load i32, i32 addrspace(3)* %642, align 8, !tbaa !8
  %644 = add nuw nsw i32 %641, %13
  %645 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %644
  store i32 %643, i32 addrspace(3)* %645, align 8, !tbaa !8
  %646 = or i32 %611, 7
  %647 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %646
  %648 = load i32, i32 addrspace(3)* %647, align 4, !tbaa !8
  %649 = add nuw nsw i32 %646, %13
  %650 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %649
  store i32 %648, i32 addrspace(3)* %650, align 4, !tbaa !8
  %651 = or i32 %611, 8
  %652 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %651
  %653 = load i32, i32 addrspace(3)* %652, align 16, !tbaa !8
  %654 = add nuw nsw i32 %651, %13
  %655 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %654
  store i32 %653, i32 addrspace(3)* %655, align 16, !tbaa !8
  %656 = or i32 %611, 9
  %657 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %656
  %658 = load i32, i32 addrspace(3)* %657, align 4, !tbaa !8
  %659 = add nuw nsw i32 %656, %13
  %660 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %659
  store i32 %658, i32 addrspace(3)* %660, align 4, !tbaa !8
  %661 = or i32 %611, 10
  %662 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %661
  %663 = load i32, i32 addrspace(3)* %662, align 8, !tbaa !8
  %664 = add nuw nsw i32 %661, %13
  %665 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %664
  store i32 %663, i32 addrspace(3)* %665, align 8, !tbaa !8
  %666 = or i32 %611, 11
  %667 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %666
  %668 = load i32, i32 addrspace(3)* %667, align 4, !tbaa !8
  %669 = add nuw nsw i32 %666, %13
  %670 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %669
  store i32 %668, i32 addrspace(3)* %670, align 4, !tbaa !8
  %671 = or i32 %611, 12
  %672 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %671
  %673 = load i32, i32 addrspace(3)* %672, align 16, !tbaa !8
  %674 = add nuw nsw i32 %671, %13
  %675 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %674
  store i32 %673, i32 addrspace(3)* %675, align 16, !tbaa !8
  %676 = or i32 %611, 13
  %677 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %676
  %678 = load i32, i32 addrspace(3)* %677, align 4, !tbaa !8
  %679 = add nuw nsw i32 %676, %13
  %680 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %679
  store i32 %678, i32 addrspace(3)* %680, align 4, !tbaa !8
  %681 = or i32 %611, 14
  %682 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %681
  %683 = load i32, i32 addrspace(3)* %682, align 8, !tbaa !8
  %684 = add nuw nsw i32 %681, %13
  %685 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %684
  store i32 %683, i32 addrspace(3)* %685, align 8, !tbaa !8
  %686 = or i32 %611, 15
  %687 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %686
  %688 = load i32, i32 addrspace(3)* %687, align 4, !tbaa !8
  %689 = add nuw nsw i32 %686, %13
  %690 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %689
  store i32 %688, i32 addrspace(3)* %690, align 4, !tbaa !8
  %691 = add nuw nsw i32 %611, 16
  %692 = icmp eq i32 %691, 256
  br i1 %692, label %693, label %610, !llvm.loop !18

693:                                              ; preds = %610, %609
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %694 = add nuw nsw i32 %142, 1
  %695 = icmp eq i32 %694, 16
  br i1 %695, label %139, label %141, !llvm.loop !19

696:                                              ; preds = %696, %140
  %697 = phi i32 [ 0, %140 ], [ %809, %696 ]
  %698 = add nuw nsw i32 %697, %13
  %699 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %698
  %700 = load i32, i32 addrspace(3)* %699, align 16, !tbaa !8
  %701 = add nuw nsw i32 %697, %11
  %702 = sext i32 %701 to i64
  %703 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %702
  store i32 %700, i32 addrspace(1)* %703, align 4, !tbaa !8
  %704 = or i32 %697, 1
  %705 = add nuw nsw i32 %704, %13
  %706 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %705
  %707 = load i32, i32 addrspace(3)* %706, align 4, !tbaa !8
  %708 = add nuw nsw i32 %704, %11
  %709 = sext i32 %708 to i64
  %710 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %709
  store i32 %707, i32 addrspace(1)* %710, align 4, !tbaa !8
  %711 = or i32 %697, 2
  %712 = add nuw nsw i32 %711, %13
  %713 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %712
  %714 = load i32, i32 addrspace(3)* %713, align 8, !tbaa !8
  %715 = add nuw nsw i32 %711, %11
  %716 = sext i32 %715 to i64
  %717 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %716
  store i32 %714, i32 addrspace(1)* %717, align 4, !tbaa !8
  %718 = or i32 %697, 3
  %719 = add nuw nsw i32 %718, %13
  %720 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %719
  %721 = load i32, i32 addrspace(3)* %720, align 4, !tbaa !8
  %722 = add nuw nsw i32 %718, %11
  %723 = sext i32 %722 to i64
  %724 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %723
  store i32 %721, i32 addrspace(1)* %724, align 4, !tbaa !8
  %725 = or i32 %697, 4
  %726 = add nuw nsw i32 %725, %13
  %727 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %726
  %728 = load i32, i32 addrspace(3)* %727, align 16, !tbaa !8
  %729 = add nuw nsw i32 %725, %11
  %730 = sext i32 %729 to i64
  %731 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %730
  store i32 %728, i32 addrspace(1)* %731, align 4, !tbaa !8
  %732 = or i32 %697, 5
  %733 = add nuw nsw i32 %732, %13
  %734 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %733
  %735 = load i32, i32 addrspace(3)* %734, align 4, !tbaa !8
  %736 = add nuw nsw i32 %732, %11
  %737 = sext i32 %736 to i64
  %738 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %737
  store i32 %735, i32 addrspace(1)* %738, align 4, !tbaa !8
  %739 = or i32 %697, 6
  %740 = add nuw nsw i32 %739, %13
  %741 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %740
  %742 = load i32, i32 addrspace(3)* %741, align 8, !tbaa !8
  %743 = add nuw nsw i32 %739, %11
  %744 = sext i32 %743 to i64
  %745 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %744
  store i32 %742, i32 addrspace(1)* %745, align 4, !tbaa !8
  %746 = or i32 %697, 7
  %747 = add nuw nsw i32 %746, %13
  %748 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %747
  %749 = load i32, i32 addrspace(3)* %748, align 4, !tbaa !8
  %750 = add nuw nsw i32 %746, %11
  %751 = sext i32 %750 to i64
  %752 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %751
  store i32 %749, i32 addrspace(1)* %752, align 4, !tbaa !8
  %753 = or i32 %697, 8
  %754 = add nuw nsw i32 %753, %13
  %755 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %754
  %756 = load i32, i32 addrspace(3)* %755, align 16, !tbaa !8
  %757 = add nuw nsw i32 %753, %11
  %758 = sext i32 %757 to i64
  %759 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %758
  store i32 %756, i32 addrspace(1)* %759, align 4, !tbaa !8
  %760 = or i32 %697, 9
  %761 = add nuw nsw i32 %760, %13
  %762 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %761
  %763 = load i32, i32 addrspace(3)* %762, align 4, !tbaa !8
  %764 = add nuw nsw i32 %760, %11
  %765 = sext i32 %764 to i64
  %766 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %765
  store i32 %763, i32 addrspace(1)* %766, align 4, !tbaa !8
  %767 = or i32 %697, 10
  %768 = add nuw nsw i32 %767, %13
  %769 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %768
  %770 = load i32, i32 addrspace(3)* %769, align 8, !tbaa !8
  %771 = add nuw nsw i32 %767, %11
  %772 = sext i32 %771 to i64
  %773 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %772
  store i32 %770, i32 addrspace(1)* %773, align 4, !tbaa !8
  %774 = or i32 %697, 11
  %775 = add nuw nsw i32 %774, %13
  %776 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %775
  %777 = load i32, i32 addrspace(3)* %776, align 4, !tbaa !8
  %778 = add nuw nsw i32 %774, %11
  %779 = sext i32 %778 to i64
  %780 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %779
  store i32 %777, i32 addrspace(1)* %780, align 4, !tbaa !8
  %781 = or i32 %697, 12
  %782 = add nuw nsw i32 %781, %13
  %783 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %782
  %784 = load i32, i32 addrspace(3)* %783, align 16, !tbaa !8
  %785 = add nuw nsw i32 %781, %11
  %786 = sext i32 %785 to i64
  %787 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %786
  store i32 %784, i32 addrspace(1)* %787, align 4, !tbaa !8
  %788 = or i32 %697, 13
  %789 = add nuw nsw i32 %788, %13
  %790 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %789
  %791 = load i32, i32 addrspace(3)* %790, align 4, !tbaa !8
  %792 = add nuw nsw i32 %788, %11
  %793 = sext i32 %792 to i64
  %794 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %793
  store i32 %791, i32 addrspace(1)* %794, align 4, !tbaa !8
  %795 = or i32 %697, 14
  %796 = add nuw nsw i32 %795, %13
  %797 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %796
  %798 = load i32, i32 addrspace(3)* %797, align 8, !tbaa !8
  %799 = add nuw nsw i32 %795, %11
  %800 = sext i32 %799 to i64
  %801 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %800
  store i32 %798, i32 addrspace(1)* %801, align 4, !tbaa !8
  %802 = or i32 %697, 15
  %803 = add nuw nsw i32 %802, %13
  %804 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %803
  %805 = load i32, i32 addrspace(3)* %804, align 4, !tbaa !8
  %806 = add nuw nsw i32 %802, %11
  %807 = sext i32 %806 to i64
  %808 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %807
  store i32 %805, i32 addrspace(1)* %808, align 4, !tbaa !8
  %809 = add nuw nsw i32 %697, 16
  %810 = icmp eq i32 %809, 256
  br i1 %810, label %811, label %696, !llvm.loop !20

811:                                              ; preds = %696, %139
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  ret void

812:                                              ; preds = %597
  store i32 %605, i32 addrspace(3)* %608, align 8, !tbaa !8
  %813 = add nsw i32 %598, -1
  br label %816

814:                                              ; preds = %597
  store i32 %602, i32 addrspace(3)* %608, align 8, !tbaa !8
  %815 = add nsw i32 %599, -1
  br label %816

816:                                              ; preds = %814, %812
  %817 = phi i32 [ %813, %812 ], [ %598, %814 ]
  %818 = phi i32 [ %599, %812 ], [ %815, %814 ]
  %819 = add nsw i32 %818, %13
  %820 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %819
  %821 = load i32, i32 addrspace(3)* %820, align 4, !tbaa !8
  %822 = add nsw i32 %134, %817
  %823 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %822
  %824 = load i32, i32 addrspace(3)* %823, align 4, !tbaa !8
  %825 = icmp sgt i32 %821, %824
  %826 = sub nsw i32 253, %581
  %827 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %826
  br i1 %825, label %830, label %828

828:                                              ; preds = %816
  store i32 %824, i32 addrspace(3)* %827, align 4, !tbaa !8
  %829 = add nsw i32 %817, -1
  br label %832

830:                                              ; preds = %816
  store i32 %821, i32 addrspace(3)* %827, align 4, !tbaa !8
  %831 = add nsw i32 %818, -1
  br label %832

832:                                              ; preds = %830, %828
  %833 = phi i32 [ %829, %828 ], [ %817, %830 ]
  %834 = phi i32 [ %818, %828 ], [ %831, %830 ]
  %835 = add nsw i32 %834, %13
  %836 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %835
  %837 = load i32, i32 addrspace(3)* %836, align 4, !tbaa !8
  %838 = add nsw i32 %134, %833
  %839 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %838
  %840 = load i32, i32 addrspace(3)* %839, align 4, !tbaa !8
  %841 = icmp sgt i32 %837, %840
  %842 = sub nsw i32 252, %581
  %843 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %842
  br i1 %841, label %846, label %844

844:                                              ; preds = %832
  store i32 %840, i32 addrspace(3)* %843, align 16, !tbaa !8
  %845 = add nsw i32 %833, -1
  br label %848

846:                                              ; preds = %832
  store i32 %837, i32 addrspace(3)* %843, align 16, !tbaa !8
  %847 = add nsw i32 %834, -1
  br label %848

848:                                              ; preds = %846, %844
  %849 = phi i32 [ %845, %844 ], [ %833, %846 ]
  %850 = phi i32 [ %834, %844 ], [ %847, %846 ]
  %851 = add nsw i32 %850, %13
  %852 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %851
  %853 = load i32, i32 addrspace(3)* %852, align 4, !tbaa !8
  %854 = add nsw i32 %134, %849
  %855 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %854
  %856 = load i32, i32 addrspace(3)* %855, align 4, !tbaa !8
  %857 = icmp sgt i32 %853, %856
  %858 = sub nsw i32 251, %581
  %859 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %858
  br i1 %857, label %862, label %860

860:                                              ; preds = %848
  store i32 %856, i32 addrspace(3)* %859, align 4, !tbaa !8
  %861 = add nsw i32 %849, -1
  br label %864

862:                                              ; preds = %848
  store i32 %853, i32 addrspace(3)* %859, align 4, !tbaa !8
  %863 = add nsw i32 %850, -1
  br label %864

864:                                              ; preds = %862, %860
  %865 = phi i32 [ %861, %860 ], [ %849, %862 ]
  %866 = phi i32 [ %850, %860 ], [ %863, %862 ]
  %867 = add nsw i32 %866, %13
  %868 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %867
  %869 = load i32, i32 addrspace(3)* %868, align 4, !tbaa !8
  %870 = add nsw i32 %134, %865
  %871 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %870
  %872 = load i32, i32 addrspace(3)* %871, align 4, !tbaa !8
  %873 = icmp sgt i32 %869, %872
  %874 = sub nsw i32 250, %581
  %875 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %874
  br i1 %873, label %878, label %876

876:                                              ; preds = %864
  store i32 %872, i32 addrspace(3)* %875, align 8, !tbaa !8
  %877 = add nsw i32 %865, -1
  br label %880

878:                                              ; preds = %864
  store i32 %869, i32 addrspace(3)* %875, align 8, !tbaa !8
  %879 = add nsw i32 %866, -1
  br label %880

880:                                              ; preds = %878, %876
  %881 = phi i32 [ %877, %876 ], [ %865, %878 ]
  %882 = phi i32 [ %866, %876 ], [ %879, %878 ]
  %883 = add nsw i32 %882, %13
  %884 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %883
  %885 = load i32, i32 addrspace(3)* %884, align 4, !tbaa !8
  %886 = add nsw i32 %134, %881
  %887 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %886
  %888 = load i32, i32 addrspace(3)* %887, align 4, !tbaa !8
  %889 = icmp sgt i32 %885, %888
  %890 = sub nsw i32 249, %581
  %891 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %890
  br i1 %889, label %894, label %892

892:                                              ; preds = %880
  store i32 %888, i32 addrspace(3)* %891, align 4, !tbaa !8
  %893 = add nsw i32 %881, -1
  br label %896

894:                                              ; preds = %880
  store i32 %885, i32 addrspace(3)* %891, align 4, !tbaa !8
  %895 = add nsw i32 %882, -1
  br label %896

896:                                              ; preds = %894, %892
  %897 = phi i32 [ %893, %892 ], [ %881, %894 ]
  %898 = phi i32 [ %882, %892 ], [ %895, %894 ]
  %899 = add nsw i32 %898, %13
  %900 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %899
  %901 = load i32, i32 addrspace(3)* %900, align 4, !tbaa !8
  %902 = add nsw i32 %134, %897
  %903 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %902
  %904 = load i32, i32 addrspace(3)* %903, align 4, !tbaa !8
  %905 = icmp sgt i32 %901, %904
  %906 = sub nsw i32 248, %581
  %907 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %906
  br i1 %905, label %910, label %908

908:                                              ; preds = %896
  store i32 %904, i32 addrspace(3)* %907, align 16, !tbaa !8
  %909 = add nsw i32 %897, -1
  br label %912

910:                                              ; preds = %896
  store i32 %901, i32 addrspace(3)* %907, align 16, !tbaa !8
  %911 = add nsw i32 %898, -1
  br label %912

912:                                              ; preds = %910, %908
  %913 = phi i32 [ %909, %908 ], [ %897, %910 ]
  %914 = phi i32 [ %898, %908 ], [ %911, %910 ]
  %915 = add nuw nsw i32 %581, 8
  %916 = icmp eq i32 %915, 256
  br i1 %916, label %609, label %580, !llvm.loop !21
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
