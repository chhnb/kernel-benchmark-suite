; ModuleID = 'build/cleanup-passes/20261120-v1/exact/trial-0/after.ll'
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
  %merged.select11 = select i1 %133, i32 %135, i32 %134
  br label %unify.bb3

139:                                              ; preds = %.loopexit20
  br i1 %10, label %.preheader, label %.loopexit

unify.bb3:                                        ; preds = %.loopexit20, %merged.branch.split1
  %140 = phi i32 [ 0, %merged.branch.split1 ], [ %454, %.loopexit20 ]
  br label %merged.bb

.preheader25:                                     ; preds = %merged.bb9, %.preheader25
  %141 = phi i32 [ %221, %.preheader25 ], [ 0, %merged.bb9 ]
  %142 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %141
  %143 = load i32, i32 addrspace(3)* %142, align 16, !tbaa !8
  %144 = add nuw nsw i32 %141, %13
  %145 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %144
  store i32 %143, i32 addrspace(3)* %145, align 16, !tbaa !8
  %146 = or i32 %141, 1
  %147 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %146
  %148 = load i32, i32 addrspace(3)* %147, align 4, !tbaa !8
  %149 = add nuw nsw i32 %146, %13
  %150 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %149
  store i32 %148, i32 addrspace(3)* %150, align 4, !tbaa !8
  %151 = or i32 %141, 2
  %152 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %151
  %153 = load i32, i32 addrspace(3)* %152, align 8, !tbaa !8
  %154 = add nuw nsw i32 %151, %13
  %155 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %154
  store i32 %153, i32 addrspace(3)* %155, align 8, !tbaa !8
  %156 = or i32 %141, 3
  %157 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %156
  %158 = load i32, i32 addrspace(3)* %157, align 4, !tbaa !8
  %159 = add nuw nsw i32 %156, %13
  %160 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %159
  store i32 %158, i32 addrspace(3)* %160, align 4, !tbaa !8
  %161 = or i32 %141, 4
  %162 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %161
  %163 = load i32, i32 addrspace(3)* %162, align 16, !tbaa !8
  %164 = add nuw nsw i32 %161, %13
  %165 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %164
  store i32 %163, i32 addrspace(3)* %165, align 16, !tbaa !8
  %166 = or i32 %141, 5
  %167 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %166
  %168 = load i32, i32 addrspace(3)* %167, align 4, !tbaa !8
  %169 = add nuw nsw i32 %166, %13
  %170 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %169
  store i32 %168, i32 addrspace(3)* %170, align 4, !tbaa !8
  %171 = or i32 %141, 6
  %172 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %171
  %173 = load i32, i32 addrspace(3)* %172, align 8, !tbaa !8
  %174 = add nuw nsw i32 %171, %13
  %175 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %174
  store i32 %173, i32 addrspace(3)* %175, align 8, !tbaa !8
  %176 = or i32 %141, 7
  %177 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %176
  %178 = load i32, i32 addrspace(3)* %177, align 4, !tbaa !8
  %179 = add nuw nsw i32 %176, %13
  %180 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %179
  store i32 %178, i32 addrspace(3)* %180, align 4, !tbaa !8
  %181 = or i32 %141, 8
  %182 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %181
  %183 = load i32, i32 addrspace(3)* %182, align 16, !tbaa !8
  %184 = add nuw nsw i32 %181, %13
  %185 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %184
  store i32 %183, i32 addrspace(3)* %185, align 16, !tbaa !8
  %186 = or i32 %141, 9
  %187 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %186
  %188 = load i32, i32 addrspace(3)* %187, align 4, !tbaa !8
  %189 = add nuw nsw i32 %186, %13
  %190 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %189
  store i32 %188, i32 addrspace(3)* %190, align 4, !tbaa !8
  %191 = or i32 %141, 10
  %192 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %191
  %193 = load i32, i32 addrspace(3)* %192, align 8, !tbaa !8
  %194 = add nuw nsw i32 %191, %13
  %195 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %194
  store i32 %193, i32 addrspace(3)* %195, align 8, !tbaa !8
  %196 = or i32 %141, 11
  %197 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %196
  %198 = load i32, i32 addrspace(3)* %197, align 4, !tbaa !8
  %199 = add nuw nsw i32 %196, %13
  %200 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %199
  store i32 %198, i32 addrspace(3)* %200, align 4, !tbaa !8
  %201 = or i32 %141, 12
  %202 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %201
  %203 = load i32, i32 addrspace(3)* %202, align 16, !tbaa !8
  %204 = add nuw nsw i32 %201, %13
  %205 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %204
  store i32 %203, i32 addrspace(3)* %205, align 16, !tbaa !8
  %206 = or i32 %141, 13
  %207 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %206
  %208 = load i32, i32 addrspace(3)* %207, align 4, !tbaa !8
  %209 = add nuw nsw i32 %206, %13
  %210 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %209
  store i32 %208, i32 addrspace(3)* %210, align 4, !tbaa !8
  %211 = or i32 %141, 14
  %212 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %211
  %213 = load i32, i32 addrspace(3)* %212, align 8, !tbaa !8
  %214 = add nuw nsw i32 %211, %13
  %215 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %214
  store i32 %213, i32 addrspace(3)* %215, align 8, !tbaa !8
  %216 = or i32 %141, 15
  %217 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %216
  %218 = load i32, i32 addrspace(3)* %217, align 4, !tbaa !8
  %219 = add nuw nsw i32 %216, %13
  %220 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %219
  store i32 %218, i32 addrspace(3)* %220, align 4, !tbaa !8
  %221 = add nuw nsw i32 %141, 16
  %222 = icmp eq i32 %221, 256
  br i1 %222, label %.loopexit26, label %.preheader25, !llvm.loop !14

.loopexit26:                                      ; preds = %.preheader25, %merged.bb9
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %137, label %.preheader21, label %347

.preheader21:                                     ; preds = %.loopexit26, %.preheader21
  %223 = phi i32 [ %345, %.preheader21 ], [ 0, %.loopexit26 ]
  %224 = phi i32 [ %343, %.preheader21 ], [ 0, %.loopexit26 ]
  %225 = phi i32 [ %341, %.preheader21 ], [ 0, %.loopexit26 ]
  %226 = add nsw i32 %225, %13
  %227 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %226
  %228 = load i32, i32 addrspace(3)* %227, align 4, !tbaa !8
  %229 = add nsw i32 %224, %135
  %230 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %229
  %231 = load i32, i32 addrspace(3)* %230, align 4, !tbaa !8
  %232 = icmp sgt i32 %228, %231
  %233 = select i1 %232, i32 %231, i32 %228
  %234 = xor i1 %232, true
  %235 = zext i1 %234 to i32
  %236 = add nuw nsw i32 %225, %235
  %237 = zext i1 %232 to i32
  %238 = add nuw nsw i32 %224, %237
  %239 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %223
  store i32 %233, i32 addrspace(3)* %239, align 16
  %240 = or i32 %223, 1
  %241 = add nsw i32 %236, %13
  %242 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %241
  %243 = load i32, i32 addrspace(3)* %242, align 4, !tbaa !8
  %244 = add nsw i32 %238, %135
  %245 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %244
  %246 = load i32, i32 addrspace(3)* %245, align 4, !tbaa !8
  %247 = icmp sgt i32 %243, %246
  %248 = select i1 %247, i32 %246, i32 %243
  %249 = xor i1 %247, true
  %250 = zext i1 %249 to i32
  %251 = add nuw nsw i32 %236, %250
  %252 = zext i1 %247 to i32
  %253 = add nuw nsw i32 %238, %252
  %254 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %240
  store i32 %248, i32 addrspace(3)* %254, align 4
  %255 = or i32 %223, 2
  %256 = add nsw i32 %251, %13
  %257 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %256
  %258 = load i32, i32 addrspace(3)* %257, align 4, !tbaa !8
  %259 = add nsw i32 %253, %135
  %260 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %259
  %261 = load i32, i32 addrspace(3)* %260, align 4, !tbaa !8
  %262 = icmp sgt i32 %258, %261
  %263 = select i1 %262, i32 %261, i32 %258
  %264 = xor i1 %262, true
  %265 = zext i1 %264 to i32
  %266 = add nuw nsw i32 %251, %265
  %267 = zext i1 %262 to i32
  %268 = add nuw nsw i32 %253, %267
  %269 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %255
  store i32 %263, i32 addrspace(3)* %269, align 8
  %270 = or i32 %223, 3
  %271 = add nsw i32 %266, %13
  %272 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %271
  %273 = load i32, i32 addrspace(3)* %272, align 4, !tbaa !8
  %274 = add nsw i32 %268, %135
  %275 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %274
  %276 = load i32, i32 addrspace(3)* %275, align 4, !tbaa !8
  %277 = icmp sgt i32 %273, %276
  %278 = select i1 %277, i32 %276, i32 %273
  %279 = xor i1 %277, true
  %280 = zext i1 %279 to i32
  %281 = add nuw nsw i32 %266, %280
  %282 = zext i1 %277 to i32
  %283 = add nuw nsw i32 %268, %282
  %284 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %270
  store i32 %278, i32 addrspace(3)* %284, align 4
  %285 = or i32 %223, 4
  %286 = add nsw i32 %281, %13
  %287 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %286
  %288 = load i32, i32 addrspace(3)* %287, align 4, !tbaa !8
  %289 = add nsw i32 %283, %135
  %290 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %289
  %291 = load i32, i32 addrspace(3)* %290, align 4, !tbaa !8
  %292 = icmp sgt i32 %288, %291
  %293 = select i1 %292, i32 %291, i32 %288
  %294 = xor i1 %292, true
  %295 = zext i1 %294 to i32
  %296 = add nuw nsw i32 %281, %295
  %297 = zext i1 %292 to i32
  %298 = add nuw nsw i32 %283, %297
  %299 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %285
  store i32 %293, i32 addrspace(3)* %299, align 16
  %300 = or i32 %223, 5
  %301 = add nsw i32 %296, %13
  %302 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %301
  %303 = load i32, i32 addrspace(3)* %302, align 4, !tbaa !8
  %304 = add nsw i32 %298, %135
  %305 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %304
  %306 = load i32, i32 addrspace(3)* %305, align 4, !tbaa !8
  %307 = icmp sgt i32 %303, %306
  %308 = select i1 %307, i32 %306, i32 %303
  %309 = xor i1 %307, true
  %310 = zext i1 %309 to i32
  %311 = add nuw nsw i32 %296, %310
  %312 = zext i1 %307 to i32
  %313 = add nuw nsw i32 %298, %312
  %314 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %300
  store i32 %308, i32 addrspace(3)* %314, align 4
  %315 = or i32 %223, 6
  %316 = add nsw i32 %311, %13
  %317 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %316
  %318 = load i32, i32 addrspace(3)* %317, align 4, !tbaa !8
  %319 = add nsw i32 %313, %135
  %320 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %319
  %321 = load i32, i32 addrspace(3)* %320, align 4, !tbaa !8
  %322 = icmp sgt i32 %318, %321
  %323 = select i1 %322, i32 %321, i32 %318
  %324 = xor i1 %322, true
  %325 = zext i1 %324 to i32
  %326 = add nuw nsw i32 %311, %325
  %327 = zext i1 %322 to i32
  %328 = add nuw nsw i32 %313, %327
  %329 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %315
  store i32 %323, i32 addrspace(3)* %329, align 8
  %330 = or i32 %223, 7
  %331 = add nsw i32 %326, %13
  %332 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %331
  %333 = load i32, i32 addrspace(3)* %332, align 4, !tbaa !8
  %334 = add nsw i32 %328, %135
  %335 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %334
  %336 = load i32, i32 addrspace(3)* %335, align 4, !tbaa !8
  %337 = icmp sgt i32 %333, %336
  %338 = select i1 %337, i32 %336, i32 %333
  %339 = xor i1 %337, true
  %340 = zext i1 %339 to i32
  %341 = add nuw nsw i32 %326, %340
  %342 = zext i1 %337 to i32
  %343 = add nuw nsw i32 %328, %342
  %344 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %330
  store i32 %338, i32 addrspace(3)* %344, align 4
  %345 = add nuw nsw i32 %223, 8
  %346 = icmp eq i32 %345, 256
  br i1 %346, label %.loopexit22, label %.preheader21, !llvm.loop !15

347:                                              ; preds = %.loopexit26
  br i1 %138, label %.loopexit22, label %.preheader23

.preheader23:                                     ; preds = %347, %646
  %348 = phi i32 [ %649, %646 ], [ 0, %347 ]
  %349 = phi i32 [ %648, %646 ], [ 255, %347 ]
  %350 = phi i32 [ %647, %646 ], [ 255, %347 ]
  %351 = add nsw i32 %349, %13
  %352 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %351
  %353 = load i32, i32 addrspace(3)* %352, align 4, !tbaa !8
  %354 = add nsw i32 %350, %134
  %355 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %354
  %356 = load i32, i32 addrspace(3)* %355, align 4, !tbaa !8
  %357 = icmp sgt i32 %353, %356
  %358 = sub nuw nsw i32 255, %348
  %359 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %358
  br i1 %357, label %360, label %362

360:                                              ; preds = %.preheader23
  store i32 %353, i32 addrspace(3)* %359, align 4, !tbaa !8
  %361 = add nsw i32 %349, -1
  %.pre = add nsw i32 %361, %13
  %.phi.trans.insert = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre
  %.pre54 = load i32, i32 addrspace(3)* %.phi.trans.insert, align 4, !tbaa !8
  br label %364

362:                                              ; preds = %.preheader23
  store i32 %356, i32 addrspace(3)* %359, align 4, !tbaa !8
  %363 = add nsw i32 %350, -1
  %.pre28 = add nsw i32 %363, %134
  %.phi.trans.insert55 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre28
  %.pre56 = load i32, i32 addrspace(3)* %.phi.trans.insert55, align 4, !tbaa !8
  br label %364

364:                                              ; preds = %362, %360
  %365 = phi i32 [ %.pre56, %362 ], [ %356, %360 ]
  %366 = phi i32 [ %353, %362 ], [ %.pre54, %360 ]
  %367 = phi i32 [ %363, %362 ], [ %350, %360 ]
  %368 = phi i32 [ %349, %362 ], [ %361, %360 ]
  %369 = icmp sgt i32 %366, %365
  %370 = sub nuw nsw i32 254, %348
  %371 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %370
  br i1 %369, label %572, label %570

.loopexit22:                                      ; preds = %646, %.preheader21, %347
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %136, label %.preheader19, label %.loopexit20

.preheader19:                                     ; preds = %.loopexit22, %.preheader19
  %372 = phi i32 [ %452, %.preheader19 ], [ 0, %.loopexit22 ]
  %373 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %372
  %374 = load i32, i32 addrspace(3)* %373, align 16, !tbaa !8
  %375 = add nuw nsw i32 %372, %13
  %376 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %375
  store i32 %374, i32 addrspace(3)* %376, align 16, !tbaa !8
  %377 = or i32 %372, 1
  %378 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %377
  %379 = load i32, i32 addrspace(3)* %378, align 4, !tbaa !8
  %380 = add nuw nsw i32 %377, %13
  %381 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %380
  store i32 %379, i32 addrspace(3)* %381, align 4, !tbaa !8
  %382 = or i32 %372, 2
  %383 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %382
  %384 = load i32, i32 addrspace(3)* %383, align 8, !tbaa !8
  %385 = add nuw nsw i32 %382, %13
  %386 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %385
  store i32 %384, i32 addrspace(3)* %386, align 8, !tbaa !8
  %387 = or i32 %372, 3
  %388 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %387
  %389 = load i32, i32 addrspace(3)* %388, align 4, !tbaa !8
  %390 = add nuw nsw i32 %387, %13
  %391 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %390
  store i32 %389, i32 addrspace(3)* %391, align 4, !tbaa !8
  %392 = or i32 %372, 4
  %393 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %392
  %394 = load i32, i32 addrspace(3)* %393, align 16, !tbaa !8
  %395 = add nuw nsw i32 %392, %13
  %396 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %395
  store i32 %394, i32 addrspace(3)* %396, align 16, !tbaa !8
  %397 = or i32 %372, 5
  %398 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %397
  %399 = load i32, i32 addrspace(3)* %398, align 4, !tbaa !8
  %400 = add nuw nsw i32 %397, %13
  %401 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %400
  store i32 %399, i32 addrspace(3)* %401, align 4, !tbaa !8
  %402 = or i32 %372, 6
  %403 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %402
  %404 = load i32, i32 addrspace(3)* %403, align 8, !tbaa !8
  %405 = add nuw nsw i32 %402, %13
  %406 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %405
  store i32 %404, i32 addrspace(3)* %406, align 8, !tbaa !8
  %407 = or i32 %372, 7
  %408 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %407
  %409 = load i32, i32 addrspace(3)* %408, align 4, !tbaa !8
  %410 = add nuw nsw i32 %407, %13
  %411 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %410
  store i32 %409, i32 addrspace(3)* %411, align 4, !tbaa !8
  %412 = or i32 %372, 8
  %413 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %412
  %414 = load i32, i32 addrspace(3)* %413, align 16, !tbaa !8
  %415 = add nuw nsw i32 %412, %13
  %416 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %415
  store i32 %414, i32 addrspace(3)* %416, align 16, !tbaa !8
  %417 = or i32 %372, 9
  %418 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %417
  %419 = load i32, i32 addrspace(3)* %418, align 4, !tbaa !8
  %420 = add nuw nsw i32 %417, %13
  %421 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %420
  store i32 %419, i32 addrspace(3)* %421, align 4, !tbaa !8
  %422 = or i32 %372, 10
  %423 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %422
  %424 = load i32, i32 addrspace(3)* %423, align 8, !tbaa !8
  %425 = add nuw nsw i32 %422, %13
  %426 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %425
  store i32 %424, i32 addrspace(3)* %426, align 8, !tbaa !8
  %427 = or i32 %372, 11
  %428 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %427
  %429 = load i32, i32 addrspace(3)* %428, align 4, !tbaa !8
  %430 = add nuw nsw i32 %427, %13
  %431 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %430
  store i32 %429, i32 addrspace(3)* %431, align 4, !tbaa !8
  %432 = or i32 %372, 12
  %433 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %432
  %434 = load i32, i32 addrspace(3)* %433, align 16, !tbaa !8
  %435 = add nuw nsw i32 %432, %13
  %436 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %435
  store i32 %434, i32 addrspace(3)* %436, align 16, !tbaa !8
  %437 = or i32 %372, 13
  %438 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %437
  %439 = load i32, i32 addrspace(3)* %438, align 4, !tbaa !8
  %440 = add nuw nsw i32 %437, %13
  %441 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %440
  store i32 %439, i32 addrspace(3)* %441, align 4, !tbaa !8
  %442 = or i32 %372, 14
  %443 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %442
  %444 = load i32, i32 addrspace(3)* %443, align 8, !tbaa !8
  %445 = add nuw nsw i32 %442, %13
  %446 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %445
  store i32 %444, i32 addrspace(3)* %446, align 8, !tbaa !8
  %447 = or i32 %372, 15
  %448 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %447
  %449 = load i32, i32 addrspace(3)* %448, align 4, !tbaa !8
  %450 = add nuw nsw i32 %447, %13
  %451 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %450
  store i32 %449, i32 addrspace(3)* %451, align 4, !tbaa !8
  %452 = add nuw nsw i32 %372, 16
  %453 = icmp eq i32 %452, 256
  br i1 %453, label %.loopexit20, label %.preheader19, !llvm.loop !16

.loopexit20:                                      ; preds = %.preheader19, %.loopexit22
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %454 = add nuw nsw i32 %140, 1
  %455 = icmp eq i32 %454, 16
  br i1 %455, label %139, label %unify.bb3, !llvm.loop !17

.preheader:                                       ; preds = %139, %.preheader
  %456 = phi i32 [ %568, %.preheader ], [ 0, %139 ]
  %457 = add nuw nsw i32 %456, %13
  %458 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %457
  %459 = load i32, i32 addrspace(3)* %458, align 16, !tbaa !8
  %460 = add nuw nsw i32 %456, %11
  %461 = sext i32 %460 to i64
  %462 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %461
  store i32 %459, i32 addrspace(1)* %462, align 4, !tbaa !8
  %463 = or i32 %456, 1
  %464 = add nuw nsw i32 %463, %13
  %465 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %464
  %466 = load i32, i32 addrspace(3)* %465, align 4, !tbaa !8
  %467 = add nuw nsw i32 %463, %11
  %468 = sext i32 %467 to i64
  %469 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %468
  store i32 %466, i32 addrspace(1)* %469, align 4, !tbaa !8
  %470 = or i32 %456, 2
  %471 = add nuw nsw i32 %470, %13
  %472 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %471
  %473 = load i32, i32 addrspace(3)* %472, align 8, !tbaa !8
  %474 = add nuw nsw i32 %470, %11
  %475 = sext i32 %474 to i64
  %476 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %475
  store i32 %473, i32 addrspace(1)* %476, align 4, !tbaa !8
  %477 = or i32 %456, 3
  %478 = add nuw nsw i32 %477, %13
  %479 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %478
  %480 = load i32, i32 addrspace(3)* %479, align 4, !tbaa !8
  %481 = add nuw nsw i32 %477, %11
  %482 = sext i32 %481 to i64
  %483 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %482
  store i32 %480, i32 addrspace(1)* %483, align 4, !tbaa !8
  %484 = or i32 %456, 4
  %485 = add nuw nsw i32 %484, %13
  %486 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %485
  %487 = load i32, i32 addrspace(3)* %486, align 16, !tbaa !8
  %488 = add nuw nsw i32 %484, %11
  %489 = sext i32 %488 to i64
  %490 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %489
  store i32 %487, i32 addrspace(1)* %490, align 4, !tbaa !8
  %491 = or i32 %456, 5
  %492 = add nuw nsw i32 %491, %13
  %493 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %492
  %494 = load i32, i32 addrspace(3)* %493, align 4, !tbaa !8
  %495 = add nuw nsw i32 %491, %11
  %496 = sext i32 %495 to i64
  %497 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %496
  store i32 %494, i32 addrspace(1)* %497, align 4, !tbaa !8
  %498 = or i32 %456, 6
  %499 = add nuw nsw i32 %498, %13
  %500 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %499
  %501 = load i32, i32 addrspace(3)* %500, align 8, !tbaa !8
  %502 = add nuw nsw i32 %498, %11
  %503 = sext i32 %502 to i64
  %504 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %503
  store i32 %501, i32 addrspace(1)* %504, align 4, !tbaa !8
  %505 = or i32 %456, 7
  %506 = add nuw nsw i32 %505, %13
  %507 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %506
  %508 = load i32, i32 addrspace(3)* %507, align 4, !tbaa !8
  %509 = add nuw nsw i32 %505, %11
  %510 = sext i32 %509 to i64
  %511 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %510
  store i32 %508, i32 addrspace(1)* %511, align 4, !tbaa !8
  %512 = or i32 %456, 8
  %513 = add nuw nsw i32 %512, %13
  %514 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %513
  %515 = load i32, i32 addrspace(3)* %514, align 16, !tbaa !8
  %516 = add nuw nsw i32 %512, %11
  %517 = sext i32 %516 to i64
  %518 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %517
  store i32 %515, i32 addrspace(1)* %518, align 4, !tbaa !8
  %519 = or i32 %456, 9
  %520 = add nuw nsw i32 %519, %13
  %521 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %520
  %522 = load i32, i32 addrspace(3)* %521, align 4, !tbaa !8
  %523 = add nuw nsw i32 %519, %11
  %524 = sext i32 %523 to i64
  %525 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %524
  store i32 %522, i32 addrspace(1)* %525, align 4, !tbaa !8
  %526 = or i32 %456, 10
  %527 = add nuw nsw i32 %526, %13
  %528 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %527
  %529 = load i32, i32 addrspace(3)* %528, align 8, !tbaa !8
  %530 = add nuw nsw i32 %526, %11
  %531 = sext i32 %530 to i64
  %532 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %531
  store i32 %529, i32 addrspace(1)* %532, align 4, !tbaa !8
  %533 = or i32 %456, 11
  %534 = add nuw nsw i32 %533, %13
  %535 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %534
  %536 = load i32, i32 addrspace(3)* %535, align 4, !tbaa !8
  %537 = add nuw nsw i32 %533, %11
  %538 = sext i32 %537 to i64
  %539 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %538
  store i32 %536, i32 addrspace(1)* %539, align 4, !tbaa !8
  %540 = or i32 %456, 12
  %541 = add nuw nsw i32 %540, %13
  %542 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %541
  %543 = load i32, i32 addrspace(3)* %542, align 16, !tbaa !8
  %544 = add nuw nsw i32 %540, %11
  %545 = sext i32 %544 to i64
  %546 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %545
  store i32 %543, i32 addrspace(1)* %546, align 4, !tbaa !8
  %547 = or i32 %456, 13
  %548 = add nuw nsw i32 %547, %13
  %549 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %548
  %550 = load i32, i32 addrspace(3)* %549, align 4, !tbaa !8
  %551 = add nuw nsw i32 %547, %11
  %552 = sext i32 %551 to i64
  %553 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %552
  store i32 %550, i32 addrspace(1)* %553, align 4, !tbaa !8
  %554 = or i32 %456, 14
  %555 = add nuw nsw i32 %554, %13
  %556 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %555
  %557 = load i32, i32 addrspace(3)* %556, align 8, !tbaa !8
  %558 = add nuw nsw i32 %554, %11
  %559 = sext i32 %558 to i64
  %560 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %559
  store i32 %557, i32 addrspace(1)* %560, align 4, !tbaa !8
  %561 = or i32 %456, 15
  %562 = add nuw nsw i32 %561, %13
  %563 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %562
  %564 = load i32, i32 addrspace(3)* %563, align 4, !tbaa !8
  %565 = add nuw nsw i32 %561, %11
  %566 = sext i32 %565 to i64
  %567 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %566
  store i32 %564, i32 addrspace(1)* %567, align 4, !tbaa !8
  %568 = add nuw nsw i32 %456, 16
  %569 = icmp eq i32 %568, 256
  br i1 %569, label %.loopexit, label %.preheader, !llvm.loop !18

.loopexit:                                        ; preds = %.preheader, %139
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  ret void

570:                                              ; preds = %364
  store i32 %365, i32 addrspace(3)* %371, align 8, !tbaa !8
  %571 = add nsw i32 %367, -1
  %.pre32 = add nsw i32 %571, %134
  %.phi.trans.insert59 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre32
  %.pre60 = load i32, i32 addrspace(3)* %.phi.trans.insert59, align 4, !tbaa !8
  br label %574

572:                                              ; preds = %364
  store i32 %366, i32 addrspace(3)* %371, align 8, !tbaa !8
  %573 = add nsw i32 %368, -1
  %.pre30 = add nsw i32 %573, %13
  %.phi.trans.insert57 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre30
  %.pre58 = load i32, i32 addrspace(3)* %.phi.trans.insert57, align 4, !tbaa !8
  br label %574

574:                                              ; preds = %572, %570
  %575 = phi i32 [ %365, %572 ], [ %.pre60, %570 ]
  %576 = phi i32 [ %.pre58, %572 ], [ %366, %570 ]
  %577 = phi i32 [ %367, %572 ], [ %571, %570 ]
  %578 = phi i32 [ %573, %572 ], [ %368, %570 ]
  %579 = icmp sgt i32 %576, %575
  %580 = sub nuw nsw i32 253, %348
  %581 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %580
  br i1 %579, label %584, label %582

582:                                              ; preds = %574
  store i32 %575, i32 addrspace(3)* %581, align 4, !tbaa !8
  %583 = add nsw i32 %577, -1
  %.pre36 = add nsw i32 %583, %134
  %.phi.trans.insert63 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre36
  %.pre64 = load i32, i32 addrspace(3)* %.phi.trans.insert63, align 4, !tbaa !8
  br label %586

584:                                              ; preds = %574
  store i32 %576, i32 addrspace(3)* %581, align 4, !tbaa !8
  %585 = add nsw i32 %578, -1
  %.pre34 = add nsw i32 %585, %13
  %.phi.trans.insert61 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre34
  %.pre62 = load i32, i32 addrspace(3)* %.phi.trans.insert61, align 4, !tbaa !8
  br label %586

586:                                              ; preds = %584, %582
  %587 = phi i32 [ %575, %584 ], [ %.pre64, %582 ]
  %588 = phi i32 [ %.pre62, %584 ], [ %576, %582 ]
  %589 = phi i32 [ %577, %584 ], [ %583, %582 ]
  %590 = phi i32 [ %585, %584 ], [ %578, %582 ]
  %591 = icmp sgt i32 %588, %587
  %592 = sub nuw nsw i32 252, %348
  %593 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %592
  br i1 %591, label %596, label %594

594:                                              ; preds = %586
  store i32 %587, i32 addrspace(3)* %593, align 16, !tbaa !8
  %595 = add nsw i32 %589, -1
  %.pre40 = add nsw i32 %595, %134
  %.phi.trans.insert67 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre40
  %.pre68 = load i32, i32 addrspace(3)* %.phi.trans.insert67, align 4, !tbaa !8
  br label %598

596:                                              ; preds = %586
  store i32 %588, i32 addrspace(3)* %593, align 16, !tbaa !8
  %597 = add nsw i32 %590, -1
  %.pre38 = add nsw i32 %597, %13
  %.phi.trans.insert65 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre38
  %.pre66 = load i32, i32 addrspace(3)* %.phi.trans.insert65, align 4, !tbaa !8
  br label %598

598:                                              ; preds = %596, %594
  %599 = phi i32 [ %587, %596 ], [ %.pre68, %594 ]
  %600 = phi i32 [ %.pre66, %596 ], [ %588, %594 ]
  %601 = phi i32 [ %589, %596 ], [ %595, %594 ]
  %602 = phi i32 [ %597, %596 ], [ %590, %594 ]
  %603 = icmp sgt i32 %600, %599
  %604 = sub nuw nsw i32 251, %348
  %605 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %604
  br i1 %603, label %608, label %606

606:                                              ; preds = %598
  store i32 %599, i32 addrspace(3)* %605, align 4, !tbaa !8
  %607 = add nsw i32 %601, -1
  %.pre44 = add nsw i32 %607, %134
  %.phi.trans.insert71 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre44
  %.pre72 = load i32, i32 addrspace(3)* %.phi.trans.insert71, align 4, !tbaa !8
  br label %610

608:                                              ; preds = %598
  store i32 %600, i32 addrspace(3)* %605, align 4, !tbaa !8
  %609 = add nsw i32 %602, -1
  %.pre42 = add nsw i32 %609, %13
  %.phi.trans.insert69 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre42
  %.pre70 = load i32, i32 addrspace(3)* %.phi.trans.insert69, align 4, !tbaa !8
  br label %610

610:                                              ; preds = %608, %606
  %611 = phi i32 [ %599, %608 ], [ %.pre72, %606 ]
  %612 = phi i32 [ %.pre70, %608 ], [ %600, %606 ]
  %613 = phi i32 [ %601, %608 ], [ %607, %606 ]
  %614 = phi i32 [ %609, %608 ], [ %602, %606 ]
  %615 = icmp sgt i32 %612, %611
  %616 = sub nuw nsw i32 250, %348
  %617 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %616
  br i1 %615, label %620, label %618

618:                                              ; preds = %610
  store i32 %611, i32 addrspace(3)* %617, align 8, !tbaa !8
  %619 = add nsw i32 %613, -1
  %.pre48 = add nsw i32 %619, %134
  %.phi.trans.insert75 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre48
  %.pre76 = load i32, i32 addrspace(3)* %.phi.trans.insert75, align 4, !tbaa !8
  br label %622

620:                                              ; preds = %610
  store i32 %612, i32 addrspace(3)* %617, align 8, !tbaa !8
  %621 = add nsw i32 %614, -1
  %.pre46 = add nsw i32 %621, %13
  %.phi.trans.insert73 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre46
  %.pre74 = load i32, i32 addrspace(3)* %.phi.trans.insert73, align 4, !tbaa !8
  br label %622

622:                                              ; preds = %620, %618
  %623 = phi i32 [ %611, %620 ], [ %.pre76, %618 ]
  %624 = phi i32 [ %.pre74, %620 ], [ %612, %618 ]
  %625 = phi i32 [ %613, %620 ], [ %619, %618 ]
  %626 = phi i32 [ %621, %620 ], [ %614, %618 ]
  %627 = icmp sgt i32 %624, %623
  %628 = sub nuw nsw i32 249, %348
  %629 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %628
  br i1 %627, label %632, label %630

630:                                              ; preds = %622
  store i32 %623, i32 addrspace(3)* %629, align 4, !tbaa !8
  %631 = add nsw i32 %625, -1
  %.pre52 = add nsw i32 %631, %134
  %.phi.trans.insert79 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre52
  %.pre80 = load i32, i32 addrspace(3)* %.phi.trans.insert79, align 4, !tbaa !8
  br label %634

632:                                              ; preds = %622
  store i32 %624, i32 addrspace(3)* %629, align 4, !tbaa !8
  %633 = add nsw i32 %626, -1
  %.pre50 = add nsw i32 %633, %13
  %.phi.trans.insert77 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %.pre50
  %.pre78 = load i32, i32 addrspace(3)* %.phi.trans.insert77, align 4, !tbaa !8
  br label %634

634:                                              ; preds = %632, %630
  %635 = phi i32 [ %623, %632 ], [ %.pre80, %630 ]
  %636 = phi i32 [ %.pre78, %632 ], [ %624, %630 ]
  %637 = phi i32 [ %625, %632 ], [ %631, %630 ]
  %638 = phi i32 [ %633, %632 ], [ %626, %630 ]
  %639 = icmp sgt i32 %636, %635
  %640 = sub nuw nsw i32 248, %348
  %641 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %640
  br i1 %639, label %644, label %642

642:                                              ; preds = %634
  store i32 %635, i32 addrspace(3)* %641, align 16, !tbaa !8
  %643 = add nsw i32 %637, -1
  br label %646

644:                                              ; preds = %634
  store i32 %636, i32 addrspace(3)* %641, align 16, !tbaa !8
  %645 = add nsw i32 %638, -1
  br label %646

646:                                              ; preds = %644, %642
  %647 = phi i32 [ %643, %642 ], [ %637, %644 ]
  %648 = phi i32 [ %638, %642 ], [ %645, %644 ]
  %649 = add nuw nsw i32 %348, 8
  %650 = icmp eq i32 %649, 256
  br i1 %650, label %.loopexit22, label %.preheader23, !llvm.loop !19

merged.bb:                                        ; preds = %predication.tail171, %unify.bb3
  %651 = phi i32 [ 0, %unify.bb3 ], [ %839, %predication.tail171 ]
  %652 = phi i32 [ 0, %unify.bb3 ], [ %guard.value166, %predication.tail171 ]
  %653 = phi i32 [ 0, %unify.bb3 ], [ %guard.value165, %predication.tail171 ]
  %654 = phi i32 [ 255, %unify.bb3 ], [ %838, %predication.tail171 ]
  %655 = phi i32 [ 255, %unify.bb3 ], [ %837, %predication.tail171 ]
  %merged.select10 = select i1 %133, i32 %653, i32 %654
  %656 = add nsw i32 %merged.select10, %13
  %657 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %656
  %658 = load i32, i32 addrspace(3)* %657, align 4, !tbaa !8
  %merged.select14 = select i1 %133, i32 %652, i32 %655
  %659 = add nsw i32 %merged.select14, %merged.select11
  %660 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %659
  %661 = load i32, i32 addrspace(3)* %660, align 4, !tbaa !8
  %662 = icmp sgt i32 %658, %661
  br i1 %133, label %predication.first, label %predication.second

predication.first:                                ; preds = %merged.bb
  %663 = select i1 %662, i32 %661, i32 %658
  %664 = xor i1 %662, true
  %665 = zext i1 %664 to i32
  %666 = add nuw nsw i32 %653, %665
  %667 = zext i1 %662 to i32
  %668 = add nuw nsw i32 %652, %667
  br label %predication.join

predication.second:                               ; preds = %merged.bb
  %669 = sub nuw nsw i32 255, %651
  br label %predication.join

predication.join:                                 ; preds = %predication.second, %predication.first
  %merged.select15 = phi i32 [ %651, %predication.first ], [ %669, %predication.second ]
  %guard.value = phi i32 [ %663, %predication.first ], [ undef, %predication.second ]
  %guard.value63 = phi i32 [ %666, %predication.first ], [ undef, %predication.second ]
  %guard.value64 = phi i32 [ %668, %predication.first ], [ undef, %predication.second ]
  %670 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %merged.select15
  %671 = or i32 %651, 1
  br i1 %133, label %predication.split, label %predication.tail

predication.split:                                ; preds = %predication.join
  %672 = add nsw i32 %guard.value64, %135
  %673 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %672
  %674 = add nsw i32 %guard.value63, %13
  %675 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %674
  store i32 %guard.value, i32 addrspace(3)* %670, align 16
  %676 = load i32, i32 addrspace(3)* %675, align 4, !tbaa !8
  %677 = load i32, i32 addrspace(3)* %673, align 4, !tbaa !8
  %678 = icmp sgt i32 %676, %677
  br label %predication.tail

predication.tail:                                 ; preds = %predication.split, %predication.join
  %merged.select20 = phi i32 [ %661, %predication.join ], [ %676, %predication.split ]
  %merged.select19 = phi i32 [ %658, %predication.join ], [ %677, %predication.split ]
  %merged.select16 = phi i1 [ %662, %predication.join ], [ %678, %predication.split ]
  %679 = phi i1 [ undef, %predication.join ], [ %678, %predication.split ]
  %680 = select i1 %merged.select16, i32 %merged.select19, i32 %merged.select20
  %681 = xor i1 %679, true
  %682 = zext i1 %681 to i32
  %683 = add nuw nsw i32 %guard.value63, %682
  %684 = zext i1 %679 to i32
  %685 = add nuw nsw i32 %guard.value64, %684
  %686 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %671
  %merged.select21 = select i1 %133, i32 addrspace(3)* %686, i32 addrspace(3)* %670
  store i32 %680, i32 addrspace(3)* %merged.select21, align 4
  %687 = select i1 %662, i32 %654, i32 %655
  %688 = add nsw i32 %687, -1
  %689 = select i1 %662, i32 %655, i32 %688
  %guard.value71 = select i1 %133, i32 undef, i32 %688
  %guard.value72 = select i1 %133, i32 undef, i32 %689
  %690 = select i1 %662, i32 %guard.value71, i32 %654
  %691 = select i1 %133, i32 undef, i32 %690
  %merged.select24 = select i1 %133, i32 %683, i32 %690
  %692 = add nsw i32 %merged.select24, %13
  %693 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %692
  %694 = load i32, i32 addrspace(3)* %693, align 4, !tbaa !8
  %merged.select26 = select i1 %133, i32 %685, i32 %689
  %695 = add nsw i32 %merged.select26, %merged.select11
  %696 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %695
  %697 = load i32, i32 addrspace(3)* %696, align 4, !tbaa !8
  %698 = icmp sgt i32 %694, %697
  br i1 %133, label %predication.first76, label %predication.second77

predication.first76:                              ; preds = %predication.tail
  %699 = or i32 %651, 2
  %700 = select i1 %698, i32 %697, i32 %694
  %701 = xor i1 %698, true
  %702 = zext i1 %701 to i32
  %703 = add nuw nsw i32 %683, %702
  %704 = zext i1 %698 to i32
  %705 = add nuw nsw i32 %685, %704
  br label %predication.join78

predication.second77:                             ; preds = %predication.tail
  %706 = sub nuw nsw i32 254, %651
  br label %predication.join78

predication.join78:                               ; preds = %predication.second77, %predication.first76
  %merged.select29 = phi i32 [ %699, %predication.first76 ], [ %706, %predication.second77 ]
  %guard.value79 = phi i32 [ %700, %predication.first76 ], [ undef, %predication.second77 ]
  %guard.value80 = phi i32 [ %703, %predication.first76 ], [ undef, %predication.second77 ]
  %guard.value81 = phi i32 [ %705, %predication.first76 ], [ undef, %predication.second77 ]
  %707 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %merged.select29
  %708 = select i1 %698, i32 %694, i32 %697
  %merged.select30 = select i1 %133, i32 %guard.value79, i32 %708
  store i32 %merged.select30, i32 addrspace(3)* %707, align 8
  %709 = select i1 %698, i32 %691, i32 %guard.value72
  %710 = add nsw i32 %709, -1
  %711 = select i1 %698, i32 %guard.value72, i32 %710
  %guard.value88 = select i1 %133, i32 undef, i32 %710
  %guard.value89 = select i1 %133, i32 undef, i32 %711
  %712 = select i1 %698, i32 %guard.value88, i32 %691
  %713 = select i1 %133, i32 undef, i32 %712
  %merged.select31 = select i1 %133, i32 %guard.value80, i32 %712
  %714 = add nsw i32 %merged.select31, %13
  %715 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %714
  %716 = load i32, i32 addrspace(3)* %715, align 4, !tbaa !8
  %merged.select35 = select i1 %133, i32 %guard.value81, i32 %711
  %717 = add nsw i32 %merged.select35, %merged.select11
  %718 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %717
  %719 = load i32, i32 addrspace(3)* %718, align 4, !tbaa !8
  %720 = icmp sgt i32 %716, %719
  br i1 %133, label %predication.first93, label %predication.second94

predication.first93:                              ; preds = %predication.join78
  %721 = or i32 %651, 3
  %722 = select i1 %720, i32 %719, i32 %716
  %723 = xor i1 %720, true
  %724 = zext i1 %723 to i32
  %725 = add nuw nsw i32 %guard.value80, %724
  %726 = zext i1 %720 to i32
  %727 = add nuw nsw i32 %guard.value81, %726
  br label %predication.join95

predication.second94:                             ; preds = %predication.join78
  %728 = sub nuw nsw i32 253, %651
  br label %predication.join95

predication.join95:                               ; preds = %predication.second94, %predication.first93
  %merged.select36 = phi i32 [ %721, %predication.first93 ], [ %728, %predication.second94 ]
  %guard.value96 = phi i32 [ %722, %predication.first93 ], [ undef, %predication.second94 ]
  %guard.value97 = phi i32 [ %725, %predication.first93 ], [ undef, %predication.second94 ]
  %guard.value98 = phi i32 [ %727, %predication.first93 ], [ undef, %predication.second94 ]
  %729 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %merged.select36
  %730 = select i1 %720, i32 %716, i32 %719
  %merged.select39 = select i1 %133, i32 %guard.value96, i32 %730
  store i32 %merged.select39, i32 addrspace(3)* %729, align 4
  %731 = select i1 %720, i32 %713, i32 %guard.value89
  %732 = add nsw i32 %731, -1
  %733 = select i1 %720, i32 %guard.value89, i32 %732
  %guard.value105 = select i1 %133, i32 undef, i32 %732
  %guard.value106 = select i1 %133, i32 undef, i32 %733
  %734 = select i1 %720, i32 %guard.value105, i32 %713
  %735 = select i1 %133, i32 undef, i32 %734
  %merged.select40 = select i1 %133, i32 %guard.value97, i32 %734
  %736 = add nsw i32 %merged.select40, %13
  %737 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %736
  %738 = load i32, i32 addrspace(3)* %737, align 4, !tbaa !8
  %merged.select42 = select i1 %133, i32 %guard.value98, i32 %733
  %739 = add nsw i32 %merged.select42, %merged.select11
  %740 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %739
  %741 = load i32, i32 addrspace(3)* %740, align 4, !tbaa !8
  %742 = icmp sgt i32 %738, %741
  br i1 %133, label %predication.first110, label %predication.second111

predication.first110:                             ; preds = %predication.join95
  %743 = or i32 %651, 4
  %744 = select i1 %742, i32 %741, i32 %738
  %745 = xor i1 %742, true
  %746 = zext i1 %745 to i32
  %747 = add nuw nsw i32 %guard.value97, %746
  %748 = zext i1 %742 to i32
  %749 = add nuw nsw i32 %guard.value98, %748
  br label %predication.join112

predication.second111:                            ; preds = %predication.join95
  %750 = sub nuw nsw i32 252, %651
  br label %predication.join112

predication.join112:                              ; preds = %predication.second111, %predication.first110
  %merged.select43 = phi i32 [ %743, %predication.first110 ], [ %750, %predication.second111 ]
  %guard.value113 = phi i32 [ %744, %predication.first110 ], [ undef, %predication.second111 ]
  %guard.value114 = phi i32 [ %747, %predication.first110 ], [ undef, %predication.second111 ]
  %guard.value115 = phi i32 [ %749, %predication.first110 ], [ undef, %predication.second111 ]
  %751 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %merged.select43
  %752 = select i1 %742, i32 %738, i32 %741
  %merged.select44 = select i1 %133, i32 %guard.value113, i32 %752
  store i32 %merged.select44, i32 addrspace(3)* %751, align 16
  %753 = select i1 %742, i32 %735, i32 %guard.value106
  %754 = add nsw i32 %753, -1
  %755 = select i1 %742, i32 %guard.value106, i32 %754
  %guard.value122 = select i1 %133, i32 undef, i32 %754
  %guard.value123 = select i1 %133, i32 undef, i32 %755
  %756 = select i1 %742, i32 %guard.value122, i32 %735
  %757 = select i1 %133, i32 undef, i32 %756
  %merged.select45 = select i1 %133, i32 %guard.value114, i32 %756
  %758 = add nsw i32 %merged.select45, %13
  %759 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %758
  %760 = load i32, i32 addrspace(3)* %759, align 4, !tbaa !8
  %merged.select47 = select i1 %133, i32 %guard.value115, i32 %755
  %761 = add nsw i32 %merged.select47, %merged.select11
  %762 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %761
  %763 = load i32, i32 addrspace(3)* %762, align 4, !tbaa !8
  %764 = icmp sgt i32 %760, %763
  br i1 %133, label %predication.first127, label %predication.second128

predication.first127:                             ; preds = %predication.join112
  %765 = or i32 %651, 5
  %766 = select i1 %764, i32 %763, i32 %760
  %767 = xor i1 %764, true
  %768 = zext i1 %767 to i32
  %769 = add nuw nsw i32 %guard.value114, %768
  %770 = zext i1 %764 to i32
  %771 = add nuw nsw i32 %guard.value115, %770
  br label %predication.join129

predication.second128:                            ; preds = %predication.join112
  %772 = sub nuw nsw i32 251, %651
  br label %predication.join129

predication.join129:                              ; preds = %predication.second128, %predication.first127
  %merged.select48 = phi i32 [ %765, %predication.first127 ], [ %772, %predication.second128 ]
  %guard.value130 = phi i32 [ %766, %predication.first127 ], [ undef, %predication.second128 ]
  %guard.value131 = phi i32 [ %769, %predication.first127 ], [ undef, %predication.second128 ]
  %guard.value132 = phi i32 [ %771, %predication.first127 ], [ undef, %predication.second128 ]
  %773 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %merged.select48
  %774 = select i1 %764, i32 %760, i32 %763
  %merged.select49 = select i1 %133, i32 %guard.value130, i32 %774
  store i32 %merged.select49, i32 addrspace(3)* %773, align 4
  %775 = select i1 %764, i32 %757, i32 %guard.value123
  %776 = add nsw i32 %775, -1
  %777 = select i1 %764, i32 %guard.value123, i32 %776
  %guard.value139 = select i1 %133, i32 undef, i32 %776
  %guard.value140 = select i1 %133, i32 undef, i32 %777
  %778 = select i1 %764, i32 %guard.value139, i32 %757
  %779 = select i1 %133, i32 undef, i32 %778
  %merged.select50 = select i1 %133, i32 %guard.value131, i32 %778
  %780 = add nsw i32 %merged.select50, %13
  %781 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %780
  %782 = load i32, i32 addrspace(3)* %781, align 4, !tbaa !8
  %merged.select52 = select i1 %133, i32 %guard.value132, i32 %777
  %783 = add nsw i32 %merged.select52, %merged.select11
  %784 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %783
  %785 = load i32, i32 addrspace(3)* %784, align 4, !tbaa !8
  %786 = icmp sgt i32 %782, %785
  br i1 %133, label %predication.first144, label %predication.second145

predication.first144:                             ; preds = %predication.join129
  %787 = or i32 %651, 6
  %788 = select i1 %786, i32 %785, i32 %782
  %789 = xor i1 %786, true
  %790 = zext i1 %789 to i32
  %791 = add nuw nsw i32 %guard.value131, %790
  %792 = zext i1 %786 to i32
  %793 = add nuw nsw i32 %guard.value132, %792
  br label %predication.join146

predication.second145:                            ; preds = %predication.join129
  %794 = sub nuw nsw i32 250, %651
  br label %predication.join146

predication.join146:                              ; preds = %predication.second145, %predication.first144
  %merged.select53 = phi i32 [ %787, %predication.first144 ], [ %794, %predication.second145 ]
  %guard.value147 = phi i32 [ %788, %predication.first144 ], [ undef, %predication.second145 ]
  %guard.value148 = phi i32 [ %791, %predication.first144 ], [ undef, %predication.second145 ]
  %guard.value149 = phi i32 [ %793, %predication.first144 ], [ undef, %predication.second145 ]
  %795 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %merged.select53
  %796 = select i1 %786, i32 %782, i32 %785
  %merged.select54 = select i1 %133, i32 %guard.value147, i32 %796
  store i32 %merged.select54, i32 addrspace(3)* %795, align 8
  %797 = select i1 %786, i32 %779, i32 %guard.value140
  %798 = add nsw i32 %797, -1
  %799 = select i1 %786, i32 %guard.value140, i32 %798
  %guard.value156 = select i1 %133, i32 undef, i32 %798
  %guard.value157 = select i1 %133, i32 undef, i32 %799
  %800 = select i1 %786, i32 %guard.value156, i32 %779
  %801 = select i1 %133, i32 undef, i32 %800
  %merged.select55 = select i1 %133, i32 %guard.value148, i32 %800
  %802 = add nsw i32 %merged.select55, %13
  %803 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %802
  %804 = load i32, i32 addrspace(3)* %803, align 4, !tbaa !8
  %merged.select57 = select i1 %133, i32 %guard.value149, i32 %799
  %805 = add nsw i32 %merged.select57, %merged.select11
  %806 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %805
  %807 = load i32, i32 addrspace(3)* %806, align 4, !tbaa !8
  %808 = icmp sgt i32 %804, %807
  br i1 %133, label %predication.first161, label %predication.second162

predication.first161:                             ; preds = %predication.join146
  %809 = or i32 %651, 7
  %810 = select i1 %808, i32 %807, i32 %804
  %811 = xor i1 %808, true
  %812 = zext i1 %811 to i32
  %813 = add nuw nsw i32 %guard.value148, %812
  %814 = zext i1 %808 to i32
  %815 = add nuw nsw i32 %guard.value149, %814
  br label %predication.join163

predication.second162:                            ; preds = %predication.join146
  %816 = sub nuw nsw i32 249, %651
  br label %predication.join163

predication.join163:                              ; preds = %predication.second162, %predication.first161
  %merged.select58 = phi i32 [ %809, %predication.first161 ], [ %816, %predication.second162 ]
  %guard.value164 = phi i32 [ %810, %predication.first161 ], [ undef, %predication.second162 ]
  %guard.value165 = phi i32 [ %813, %predication.first161 ], [ undef, %predication.second162 ]
  %guard.value166 = phi i32 [ %815, %predication.first161 ], [ undef, %predication.second162 ]
  %817 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %merged.select58
  %818 = select i1 %808, i32 %804, i32 %807
  %merged.select59 = select i1 %133, i32 %guard.value164, i32 %818
  store i32 %merged.select59, i32 addrspace(3)* %817, align 4
  br i1 %133, label %predication.tail171, label %predication.split170

predication.split170:                             ; preds = %predication.join163
  %819 = select i1 %808, i32 %801, i32 %guard.value157
  %820 = add nsw i32 %819, -1
  %821 = select i1 %808, i32 %guard.value157, i32 %820
  %822 = select i1 %808, i32 %820, i32 %801
  %823 = add nsw i32 %822, %13
  %824 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %823
  %825 = load i32, i32 addrspace(3)* %824, align 4, !tbaa !8
  %826 = add nsw i32 %821, %134
  %827 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %826
  %828 = load i32, i32 addrspace(3)* %827, align 4, !tbaa !8
  %829 = icmp sgt i32 %825, %828
  %830 = sub nuw nsw i32 248, %651
  %831 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %830
  %832 = select i1 %829, i32 %825, i32 %828
  store i32 %832, i32 addrspace(3)* %831, align 16, !tbaa !8
  %833 = select i1 %829, i32 %822, i32 %821
  %834 = add nsw i32 %833, -1
  %835 = select i1 %829, i32 %821, i32 %834
  %836 = select i1 %829, i32 %834, i32 %822
  br label %predication.tail171

predication.tail171:                              ; preds = %predication.split170, %predication.join163
  %837 = phi i32 [ undef, %predication.join163 ], [ %835, %predication.split170 ]
  %838 = phi i32 [ undef, %predication.join163 ], [ %836, %predication.split170 ]
  %839 = add nuw nsw i32 %651, 8
  %840 = icmp eq i32 %839, 256
  br i1 %840, label %merged.bb9, label %merged.bb, !llvm.loop !20

merged.bb9:                                       ; preds = %predication.tail171
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %136, label %.preheader25, label %.loopexit26
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
