; ModuleID = '/data/home/chh/simplify-v2-normalize/build/pcm32-r2r-variants/20261120-v1/M.ll'
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
  %128 = phi i32 [ %13, %unify.bb ], [ %13, %merged.branch.split ]
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

140:                                              ; preds = %469
  br i1 %10, label %141, label %587

141:                                              ; preds = %140
  %142 = shl nsw i32 %9, 8
  br label %472

143:                                              ; preds = %469, %merged.branch.split1
  %144 = phi i32 [ 0, %merged.branch.split1 ], [ %470, %469 ]
  br label %unify.bb3

unify.bb3:                                        ; preds = %143
  br label %merged.bb

145:                                              ; preds = %merged.branch.split62, %merged.branch.split61
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %137, label %146, label %229

146:                                              ; preds = %146, %145
  %147 = phi i32 [ 0, %145 ], [ %227, %146 ]
  %148 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %147
  %149 = load i32, i32 addrspace(3)* %148, align 16, !tbaa !8
  %150 = add nuw nsw i32 %147, %128
  %151 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %150
  store i32 %149, i32 addrspace(3)* %151, align 16, !tbaa !8
  %152 = or i32 %147, 1
  %153 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %152
  %154 = load i32, i32 addrspace(3)* %153, align 4, !tbaa !8
  %155 = add nuw nsw i32 %152, %128
  %156 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %155
  store i32 %154, i32 addrspace(3)* %156, align 4, !tbaa !8
  %157 = or i32 %147, 2
  %158 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %157
  %159 = load i32, i32 addrspace(3)* %158, align 8, !tbaa !8
  %160 = add nuw nsw i32 %157, %128
  %161 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %160
  store i32 %159, i32 addrspace(3)* %161, align 8, !tbaa !8
  %162 = or i32 %147, 3
  %163 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %162
  %164 = load i32, i32 addrspace(3)* %163, align 4, !tbaa !8
  %165 = add nuw nsw i32 %162, %128
  %166 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %165
  store i32 %164, i32 addrspace(3)* %166, align 4, !tbaa !8
  %167 = or i32 %147, 4
  %168 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %167
  %169 = load i32, i32 addrspace(3)* %168, align 16, !tbaa !8
  %170 = add nuw nsw i32 %167, %128
  %171 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %170
  store i32 %169, i32 addrspace(3)* %171, align 16, !tbaa !8
  %172 = or i32 %147, 5
  %173 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %172
  %174 = load i32, i32 addrspace(3)* %173, align 4, !tbaa !8
  %175 = add nuw nsw i32 %172, %128
  %176 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %175
  store i32 %174, i32 addrspace(3)* %176, align 4, !tbaa !8
  %177 = or i32 %147, 6
  %178 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %177
  %179 = load i32, i32 addrspace(3)* %178, align 8, !tbaa !8
  %180 = add nuw nsw i32 %177, %128
  %181 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %180
  store i32 %179, i32 addrspace(3)* %181, align 8, !tbaa !8
  %182 = or i32 %147, 7
  %183 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %182
  %184 = load i32, i32 addrspace(3)* %183, align 4, !tbaa !8
  %185 = add nuw nsw i32 %182, %128
  %186 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %185
  store i32 %184, i32 addrspace(3)* %186, align 4, !tbaa !8
  %187 = or i32 %147, 8
  %188 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %187
  %189 = load i32, i32 addrspace(3)* %188, align 16, !tbaa !8
  %190 = add nuw nsw i32 %187, %128
  %191 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %190
  store i32 %189, i32 addrspace(3)* %191, align 16, !tbaa !8
  %192 = or i32 %147, 9
  %193 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %192
  %194 = load i32, i32 addrspace(3)* %193, align 4, !tbaa !8
  %195 = add nuw nsw i32 %192, %128
  %196 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %195
  store i32 %194, i32 addrspace(3)* %196, align 4, !tbaa !8
  %197 = or i32 %147, 10
  %198 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %197
  %199 = load i32, i32 addrspace(3)* %198, align 8, !tbaa !8
  %200 = add nuw nsw i32 %197, %128
  %201 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %200
  store i32 %199, i32 addrspace(3)* %201, align 8, !tbaa !8
  %202 = or i32 %147, 11
  %203 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %202
  %204 = load i32, i32 addrspace(3)* %203, align 4, !tbaa !8
  %205 = add nuw nsw i32 %202, %128
  %206 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %205
  store i32 %204, i32 addrspace(3)* %206, align 4, !tbaa !8
  %207 = or i32 %147, 12
  %208 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %207
  %209 = load i32, i32 addrspace(3)* %208, align 16, !tbaa !8
  %210 = add nuw nsw i32 %207, %128
  %211 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %210
  store i32 %209, i32 addrspace(3)* %211, align 16, !tbaa !8
  %212 = or i32 %147, 13
  %213 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %212
  %214 = load i32, i32 addrspace(3)* %213, align 4, !tbaa !8
  %215 = add nuw nsw i32 %212, %128
  %216 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %215
  store i32 %214, i32 addrspace(3)* %216, align 4, !tbaa !8
  %217 = or i32 %147, 14
  %218 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %217
  %219 = load i32, i32 addrspace(3)* %218, align 8, !tbaa !8
  %220 = add nuw nsw i32 %217, %128
  %221 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %220
  store i32 %219, i32 addrspace(3)* %221, align 8, !tbaa !8
  %222 = or i32 %147, 15
  %223 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %222
  %224 = load i32, i32 addrspace(3)* %223, align 4, !tbaa !8
  %225 = add nuw nsw i32 %222, %128
  %226 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %225
  store i32 %224, i32 addrspace(3)* %226, align 4, !tbaa !8
  %227 = add nuw nsw i32 %147, 16
  %228 = icmp eq i32 %227, 256
  br i1 %228, label %229, label %146, !llvm.loop !14

229:                                              ; preds = %146, %145
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %138, label %230, label %355

230:                                              ; preds = %230, %229
  %231 = phi i32 [ 0, %229 ], [ %353, %230 ]
  %232 = phi i32 [ 0, %229 ], [ %351, %230 ]
  %233 = phi i32 [ 0, %229 ], [ %349, %230 ]
  %234 = add nsw i32 %233, %128
  %235 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %234
  %236 = load i32, i32 addrspace(3)* %235, align 4, !tbaa !8
  %237 = add nsw i32 %136, %232
  %238 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %237
  %239 = load i32, i32 addrspace(3)* %238, align 4, !tbaa !8
  %240 = icmp sgt i32 %236, %239
  %241 = select i1 %240, i32 %239, i32 %236
  %242 = xor i1 %240, true
  %243 = zext i1 %242 to i32
  %244 = add nuw nsw i32 %233, %243
  %245 = zext i1 %240 to i32
  %246 = add nuw nsw i32 %232, %245
  %247 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %231
  store i32 %241, i32 addrspace(3)* %247, align 16
  %248 = or i32 %231, 1
  %249 = add nsw i32 %244, %128
  %250 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %249
  %251 = load i32, i32 addrspace(3)* %250, align 4, !tbaa !8
  %252 = add nsw i32 %136, %246
  %253 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %252
  %254 = load i32, i32 addrspace(3)* %253, align 4, !tbaa !8
  %255 = icmp sgt i32 %251, %254
  %256 = select i1 %255, i32 %254, i32 %251
  %257 = xor i1 %255, true
  %258 = zext i1 %257 to i32
  %259 = add nuw nsw i32 %244, %258
  %260 = zext i1 %255 to i32
  %261 = add nuw nsw i32 %246, %260
  %262 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %248
  store i32 %256, i32 addrspace(3)* %262, align 4
  %263 = or i32 %231, 2
  %264 = add nsw i32 %259, %128
  %265 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %264
  %266 = load i32, i32 addrspace(3)* %265, align 4, !tbaa !8
  %267 = add nsw i32 %136, %261
  %268 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %267
  %269 = load i32, i32 addrspace(3)* %268, align 4, !tbaa !8
  %270 = icmp sgt i32 %266, %269
  %271 = select i1 %270, i32 %269, i32 %266
  %272 = xor i1 %270, true
  %273 = zext i1 %272 to i32
  %274 = add nuw nsw i32 %259, %273
  %275 = zext i1 %270 to i32
  %276 = add nuw nsw i32 %261, %275
  %277 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %263
  store i32 %271, i32 addrspace(3)* %277, align 8
  %278 = or i32 %231, 3
  %279 = add nsw i32 %274, %128
  %280 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %279
  %281 = load i32, i32 addrspace(3)* %280, align 4, !tbaa !8
  %282 = add nsw i32 %136, %276
  %283 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %282
  %284 = load i32, i32 addrspace(3)* %283, align 4, !tbaa !8
  %285 = icmp sgt i32 %281, %284
  %286 = select i1 %285, i32 %284, i32 %281
  %287 = xor i1 %285, true
  %288 = zext i1 %287 to i32
  %289 = add nuw nsw i32 %274, %288
  %290 = zext i1 %285 to i32
  %291 = add nuw nsw i32 %276, %290
  %292 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %278
  store i32 %286, i32 addrspace(3)* %292, align 4
  %293 = or i32 %231, 4
  %294 = add nsw i32 %289, %128
  %295 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %294
  %296 = load i32, i32 addrspace(3)* %295, align 4, !tbaa !8
  %297 = add nsw i32 %136, %291
  %298 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %297
  %299 = load i32, i32 addrspace(3)* %298, align 4, !tbaa !8
  %300 = icmp sgt i32 %296, %299
  %301 = select i1 %300, i32 %299, i32 %296
  %302 = xor i1 %300, true
  %303 = zext i1 %302 to i32
  %304 = add nuw nsw i32 %289, %303
  %305 = zext i1 %300 to i32
  %306 = add nuw nsw i32 %291, %305
  %307 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %293
  store i32 %301, i32 addrspace(3)* %307, align 16
  %308 = or i32 %231, 5
  %309 = add nsw i32 %304, %128
  %310 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %309
  %311 = load i32, i32 addrspace(3)* %310, align 4, !tbaa !8
  %312 = add nsw i32 %136, %306
  %313 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %312
  %314 = load i32, i32 addrspace(3)* %313, align 4, !tbaa !8
  %315 = icmp sgt i32 %311, %314
  %316 = select i1 %315, i32 %314, i32 %311
  %317 = xor i1 %315, true
  %318 = zext i1 %317 to i32
  %319 = add nuw nsw i32 %304, %318
  %320 = zext i1 %315 to i32
  %321 = add nuw nsw i32 %306, %320
  %322 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %308
  store i32 %316, i32 addrspace(3)* %322, align 4
  %323 = or i32 %231, 6
  %324 = add nsw i32 %319, %128
  %325 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %324
  %326 = load i32, i32 addrspace(3)* %325, align 4, !tbaa !8
  %327 = add nsw i32 %136, %321
  %328 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %327
  %329 = load i32, i32 addrspace(3)* %328, align 4, !tbaa !8
  %330 = icmp sgt i32 %326, %329
  %331 = select i1 %330, i32 %329, i32 %326
  %332 = xor i1 %330, true
  %333 = zext i1 %332 to i32
  %334 = add nuw nsw i32 %319, %333
  %335 = zext i1 %330 to i32
  %336 = add nuw nsw i32 %321, %335
  %337 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %323
  store i32 %331, i32 addrspace(3)* %337, align 8
  %338 = or i32 %231, 7
  %339 = add nsw i32 %334, %128
  %340 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %339
  %341 = load i32, i32 addrspace(3)* %340, align 4, !tbaa !8
  %342 = add nsw i32 %136, %336
  %343 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %342
  %344 = load i32, i32 addrspace(3)* %343, align 4, !tbaa !8
  %345 = icmp sgt i32 %341, %344
  %346 = select i1 %345, i32 %344, i32 %341
  %347 = xor i1 %345, true
  %348 = zext i1 %347 to i32
  %349 = add nuw nsw i32 %334, %348
  %350 = zext i1 %345 to i32
  %351 = add nuw nsw i32 %336, %350
  %352 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %338
  store i32 %346, i32 addrspace(3)* %352, align 4
  %353 = add nuw nsw i32 %231, 8
  %354 = icmp eq i32 %353, 256
  br i1 %354, label %385, label %230, !llvm.loop !15

355:                                              ; preds = %229
  br i1 %139, label %385, label %356

356:                                              ; preds = %688, %355
  %357 = phi i32 [ 0, %355 ], [ %691, %688 ]
  %358 = phi i32 [ 255, %355 ], [ %690, %688 ]
  %359 = phi i32 [ 255, %355 ], [ %689, %688 ]
  %360 = add nsw i32 %358, %128
  %361 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %360
  %362 = load i32, i32 addrspace(3)* %361, align 4, !tbaa !8
  %363 = add nsw i32 %135, %359
  %364 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %363
  %365 = load i32, i32 addrspace(3)* %364, align 4, !tbaa !8
  %366 = icmp sgt i32 %362, %365
  %367 = sub nuw nsw i32 255, %357
  %368 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %367
  br i1 %366, label %369, label %371

369:                                              ; preds = %356
  store i32 %362, i32 addrspace(3)* %368, align 4, !tbaa !8
  %370 = add nsw i32 %358, -1
  br label %373

371:                                              ; preds = %356
  store i32 %365, i32 addrspace(3)* %368, align 4, !tbaa !8
  %372 = add nsw i32 %359, -1
  br label %373

373:                                              ; preds = %371, %369
  %374 = phi i32 [ %359, %369 ], [ %372, %371 ]
  %375 = phi i32 [ %370, %369 ], [ %358, %371 ]
  %376 = add nsw i32 %375, %128
  %377 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %376
  %378 = load i32, i32 addrspace(3)* %377, align 4, !tbaa !8
  %379 = add nsw i32 %135, %374
  %380 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %379
  %381 = load i32, i32 addrspace(3)* %380, align 4, !tbaa !8
  %382 = icmp sgt i32 %378, %381
  %383 = sub nsw i32 254, %357
  %384 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %383
  br i1 %382, label %590, label %588

385:                                              ; preds = %688, %355, %230
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %137, label %386, label %469

386:                                              ; preds = %386, %385
  %387 = phi i32 [ 0, %385 ], [ %467, %386 ]
  %388 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %387
  %389 = load i32, i32 addrspace(3)* %388, align 16, !tbaa !8
  %390 = add nuw nsw i32 %387, %128
  %391 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %390
  store i32 %389, i32 addrspace(3)* %391, align 16, !tbaa !8
  %392 = or i32 %387, 1
  %393 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %392
  %394 = load i32, i32 addrspace(3)* %393, align 4, !tbaa !8
  %395 = add nuw nsw i32 %392, %128
  %396 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %395
  store i32 %394, i32 addrspace(3)* %396, align 4, !tbaa !8
  %397 = or i32 %387, 2
  %398 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %397
  %399 = load i32, i32 addrspace(3)* %398, align 8, !tbaa !8
  %400 = add nuw nsw i32 %397, %128
  %401 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %400
  store i32 %399, i32 addrspace(3)* %401, align 8, !tbaa !8
  %402 = or i32 %387, 3
  %403 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %402
  %404 = load i32, i32 addrspace(3)* %403, align 4, !tbaa !8
  %405 = add nuw nsw i32 %402, %128
  %406 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %405
  store i32 %404, i32 addrspace(3)* %406, align 4, !tbaa !8
  %407 = or i32 %387, 4
  %408 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %407
  %409 = load i32, i32 addrspace(3)* %408, align 16, !tbaa !8
  %410 = add nuw nsw i32 %407, %128
  %411 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %410
  store i32 %409, i32 addrspace(3)* %411, align 16, !tbaa !8
  %412 = or i32 %387, 5
  %413 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %412
  %414 = load i32, i32 addrspace(3)* %413, align 4, !tbaa !8
  %415 = add nuw nsw i32 %412, %128
  %416 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %415
  store i32 %414, i32 addrspace(3)* %416, align 4, !tbaa !8
  %417 = or i32 %387, 6
  %418 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %417
  %419 = load i32, i32 addrspace(3)* %418, align 8, !tbaa !8
  %420 = add nuw nsw i32 %417, %128
  %421 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %420
  store i32 %419, i32 addrspace(3)* %421, align 8, !tbaa !8
  %422 = or i32 %387, 7
  %423 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %422
  %424 = load i32, i32 addrspace(3)* %423, align 4, !tbaa !8
  %425 = add nuw nsw i32 %422, %128
  %426 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %425
  store i32 %424, i32 addrspace(3)* %426, align 4, !tbaa !8
  %427 = or i32 %387, 8
  %428 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %427
  %429 = load i32, i32 addrspace(3)* %428, align 16, !tbaa !8
  %430 = add nuw nsw i32 %427, %128
  %431 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %430
  store i32 %429, i32 addrspace(3)* %431, align 16, !tbaa !8
  %432 = or i32 %387, 9
  %433 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %432
  %434 = load i32, i32 addrspace(3)* %433, align 4, !tbaa !8
  %435 = add nuw nsw i32 %432, %128
  %436 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %435
  store i32 %434, i32 addrspace(3)* %436, align 4, !tbaa !8
  %437 = or i32 %387, 10
  %438 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %437
  %439 = load i32, i32 addrspace(3)* %438, align 8, !tbaa !8
  %440 = add nuw nsw i32 %437, %128
  %441 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %440
  store i32 %439, i32 addrspace(3)* %441, align 8, !tbaa !8
  %442 = or i32 %387, 11
  %443 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %442
  %444 = load i32, i32 addrspace(3)* %443, align 4, !tbaa !8
  %445 = add nuw nsw i32 %442, %128
  %446 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %445
  store i32 %444, i32 addrspace(3)* %446, align 4, !tbaa !8
  %447 = or i32 %387, 12
  %448 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %447
  %449 = load i32, i32 addrspace(3)* %448, align 16, !tbaa !8
  %450 = add nuw nsw i32 %447, %128
  %451 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %450
  store i32 %449, i32 addrspace(3)* %451, align 16, !tbaa !8
  %452 = or i32 %387, 13
  %453 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %452
  %454 = load i32, i32 addrspace(3)* %453, align 4, !tbaa !8
  %455 = add nuw nsw i32 %452, %128
  %456 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %455
  store i32 %454, i32 addrspace(3)* %456, align 4, !tbaa !8
  %457 = or i32 %387, 14
  %458 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %457
  %459 = load i32, i32 addrspace(3)* %458, align 8, !tbaa !8
  %460 = add nuw nsw i32 %457, %128
  %461 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %460
  store i32 %459, i32 addrspace(3)* %461, align 8, !tbaa !8
  %462 = or i32 %387, 15
  %463 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %462
  %464 = load i32, i32 addrspace(3)* %463, align 4, !tbaa !8
  %465 = add nuw nsw i32 %462, %128
  %466 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %465
  store i32 %464, i32 addrspace(3)* %466, align 4, !tbaa !8
  %467 = add nuw nsw i32 %387, 16
  %468 = icmp eq i32 %467, 256
  br i1 %468, label %469, label %386, !llvm.loop !16

469:                                              ; preds = %386, %385
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %470 = add nuw nsw i32 %144, 1
  %471 = icmp eq i32 %470, 16
  br i1 %471, label %140, label %143, !llvm.loop !17

472:                                              ; preds = %472, %141
  %473 = phi i32 [ 0, %141 ], [ %585, %472 ]
  %474 = add nuw nsw i32 %473, %128
  %475 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %474
  %476 = load i32, i32 addrspace(3)* %475, align 16, !tbaa !8
  %477 = add nuw nsw i32 %473, %142
  %478 = sext i32 %477 to i64
  %479 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %478
  store i32 %476, i32 addrspace(1)* %479, align 4, !tbaa !8
  %480 = or i32 %473, 1
  %481 = add nuw nsw i32 %480, %128
  %482 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %481
  %483 = load i32, i32 addrspace(3)* %482, align 4, !tbaa !8
  %484 = add nuw nsw i32 %480, %142
  %485 = sext i32 %484 to i64
  %486 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %485
  store i32 %483, i32 addrspace(1)* %486, align 4, !tbaa !8
  %487 = or i32 %473, 2
  %488 = add nuw nsw i32 %487, %128
  %489 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %488
  %490 = load i32, i32 addrspace(3)* %489, align 8, !tbaa !8
  %491 = add nuw nsw i32 %487, %142
  %492 = sext i32 %491 to i64
  %493 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %492
  store i32 %490, i32 addrspace(1)* %493, align 4, !tbaa !8
  %494 = or i32 %473, 3
  %495 = add nuw nsw i32 %494, %128
  %496 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %495
  %497 = load i32, i32 addrspace(3)* %496, align 4, !tbaa !8
  %498 = add nuw nsw i32 %494, %142
  %499 = sext i32 %498 to i64
  %500 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %499
  store i32 %497, i32 addrspace(1)* %500, align 4, !tbaa !8
  %501 = or i32 %473, 4
  %502 = add nuw nsw i32 %501, %128
  %503 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %502
  %504 = load i32, i32 addrspace(3)* %503, align 16, !tbaa !8
  %505 = add nuw nsw i32 %501, %142
  %506 = sext i32 %505 to i64
  %507 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %506
  store i32 %504, i32 addrspace(1)* %507, align 4, !tbaa !8
  %508 = or i32 %473, 5
  %509 = add nuw nsw i32 %508, %128
  %510 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %509
  %511 = load i32, i32 addrspace(3)* %510, align 4, !tbaa !8
  %512 = add nuw nsw i32 %508, %142
  %513 = sext i32 %512 to i64
  %514 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %513
  store i32 %511, i32 addrspace(1)* %514, align 4, !tbaa !8
  %515 = or i32 %473, 6
  %516 = add nuw nsw i32 %515, %128
  %517 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %516
  %518 = load i32, i32 addrspace(3)* %517, align 8, !tbaa !8
  %519 = add nuw nsw i32 %515, %142
  %520 = sext i32 %519 to i64
  %521 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %520
  store i32 %518, i32 addrspace(1)* %521, align 4, !tbaa !8
  %522 = or i32 %473, 7
  %523 = add nuw nsw i32 %522, %128
  %524 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %523
  %525 = load i32, i32 addrspace(3)* %524, align 4, !tbaa !8
  %526 = add nuw nsw i32 %522, %142
  %527 = sext i32 %526 to i64
  %528 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %527
  store i32 %525, i32 addrspace(1)* %528, align 4, !tbaa !8
  %529 = or i32 %473, 8
  %530 = add nuw nsw i32 %529, %128
  %531 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %530
  %532 = load i32, i32 addrspace(3)* %531, align 16, !tbaa !8
  %533 = add nuw nsw i32 %529, %142
  %534 = sext i32 %533 to i64
  %535 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %534
  store i32 %532, i32 addrspace(1)* %535, align 4, !tbaa !8
  %536 = or i32 %473, 9
  %537 = add nuw nsw i32 %536, %128
  %538 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %537
  %539 = load i32, i32 addrspace(3)* %538, align 4, !tbaa !8
  %540 = add nuw nsw i32 %536, %142
  %541 = sext i32 %540 to i64
  %542 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %541
  store i32 %539, i32 addrspace(1)* %542, align 4, !tbaa !8
  %543 = or i32 %473, 10
  %544 = add nuw nsw i32 %543, %128
  %545 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %544
  %546 = load i32, i32 addrspace(3)* %545, align 8, !tbaa !8
  %547 = add nuw nsw i32 %543, %142
  %548 = sext i32 %547 to i64
  %549 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %548
  store i32 %546, i32 addrspace(1)* %549, align 4, !tbaa !8
  %550 = or i32 %473, 11
  %551 = add nuw nsw i32 %550, %128
  %552 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %551
  %553 = load i32, i32 addrspace(3)* %552, align 4, !tbaa !8
  %554 = add nuw nsw i32 %550, %142
  %555 = sext i32 %554 to i64
  %556 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %555
  store i32 %553, i32 addrspace(1)* %556, align 4, !tbaa !8
  %557 = or i32 %473, 12
  %558 = add nuw nsw i32 %557, %128
  %559 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %558
  %560 = load i32, i32 addrspace(3)* %559, align 16, !tbaa !8
  %561 = add nuw nsw i32 %557, %142
  %562 = sext i32 %561 to i64
  %563 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %562
  store i32 %560, i32 addrspace(1)* %563, align 4, !tbaa !8
  %564 = or i32 %473, 13
  %565 = add nuw nsw i32 %564, %128
  %566 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %565
  %567 = load i32, i32 addrspace(3)* %566, align 4, !tbaa !8
  %568 = add nuw nsw i32 %564, %142
  %569 = sext i32 %568 to i64
  %570 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %569
  store i32 %567, i32 addrspace(1)* %570, align 4, !tbaa !8
  %571 = or i32 %473, 14
  %572 = add nuw nsw i32 %571, %128
  %573 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %572
  %574 = load i32, i32 addrspace(3)* %573, align 8, !tbaa !8
  %575 = add nuw nsw i32 %571, %142
  %576 = sext i32 %575 to i64
  %577 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %576
  store i32 %574, i32 addrspace(1)* %577, align 4, !tbaa !8
  %578 = or i32 %473, 15
  %579 = add nuw nsw i32 %578, %128
  %580 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %579
  %581 = load i32, i32 addrspace(3)* %580, align 4, !tbaa !8
  %582 = add nuw nsw i32 %578, %142
  %583 = sext i32 %582 to i64
  %584 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %583
  store i32 %581, i32 addrspace(1)* %584, align 4, !tbaa !8
  %585 = add nuw nsw i32 %473, 16
  %586 = icmp eq i32 %585, 256
  br i1 %586, label %587, label %472, !llvm.loop !18

587:                                              ; preds = %472, %140
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  ret void

588:                                              ; preds = %373
  store i32 %381, i32 addrspace(3)* %384, align 8, !tbaa !8
  %589 = add nsw i32 %374, -1
  br label %592

590:                                              ; preds = %373
  store i32 %378, i32 addrspace(3)* %384, align 8, !tbaa !8
  %591 = add nsw i32 %375, -1
  br label %592

592:                                              ; preds = %590, %588
  %593 = phi i32 [ %589, %588 ], [ %374, %590 ]
  %594 = phi i32 [ %375, %588 ], [ %591, %590 ]
  %595 = add nsw i32 %594, %128
  %596 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %595
  %597 = load i32, i32 addrspace(3)* %596, align 4, !tbaa !8
  %598 = add nsw i32 %135, %593
  %599 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %598
  %600 = load i32, i32 addrspace(3)* %599, align 4, !tbaa !8
  %601 = icmp sgt i32 %597, %600
  %602 = sub nsw i32 253, %357
  %603 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %602
  br i1 %601, label %606, label %604

604:                                              ; preds = %592
  store i32 %600, i32 addrspace(3)* %603, align 4, !tbaa !8
  %605 = add nsw i32 %593, -1
  br label %608

606:                                              ; preds = %592
  store i32 %597, i32 addrspace(3)* %603, align 4, !tbaa !8
  %607 = add nsw i32 %594, -1
  br label %608

608:                                              ; preds = %606, %604
  %609 = phi i32 [ %605, %604 ], [ %593, %606 ]
  %610 = phi i32 [ %594, %604 ], [ %607, %606 ]
  %611 = add nsw i32 %610, %128
  %612 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %611
  %613 = load i32, i32 addrspace(3)* %612, align 4, !tbaa !8
  %614 = add nsw i32 %135, %609
  %615 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %614
  %616 = load i32, i32 addrspace(3)* %615, align 4, !tbaa !8
  %617 = icmp sgt i32 %613, %616
  %618 = sub nsw i32 252, %357
  %619 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %618
  br i1 %617, label %622, label %620

620:                                              ; preds = %608
  store i32 %616, i32 addrspace(3)* %619, align 16, !tbaa !8
  %621 = add nsw i32 %609, -1
  br label %624

622:                                              ; preds = %608
  store i32 %613, i32 addrspace(3)* %619, align 16, !tbaa !8
  %623 = add nsw i32 %610, -1
  br label %624

624:                                              ; preds = %622, %620
  %625 = phi i32 [ %621, %620 ], [ %609, %622 ]
  %626 = phi i32 [ %610, %620 ], [ %623, %622 ]
  %627 = add nsw i32 %626, %128
  %628 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %627
  %629 = load i32, i32 addrspace(3)* %628, align 4, !tbaa !8
  %630 = add nsw i32 %135, %625
  %631 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %630
  %632 = load i32, i32 addrspace(3)* %631, align 4, !tbaa !8
  %633 = icmp sgt i32 %629, %632
  %634 = sub nsw i32 251, %357
  %635 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %634
  br i1 %633, label %638, label %636

636:                                              ; preds = %624
  store i32 %632, i32 addrspace(3)* %635, align 4, !tbaa !8
  %637 = add nsw i32 %625, -1
  br label %640

638:                                              ; preds = %624
  store i32 %629, i32 addrspace(3)* %635, align 4, !tbaa !8
  %639 = add nsw i32 %626, -1
  br label %640

640:                                              ; preds = %638, %636
  %641 = phi i32 [ %637, %636 ], [ %625, %638 ]
  %642 = phi i32 [ %626, %636 ], [ %639, %638 ]
  %643 = add nsw i32 %642, %128
  %644 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %643
  %645 = load i32, i32 addrspace(3)* %644, align 4, !tbaa !8
  %646 = add nsw i32 %135, %641
  %647 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %646
  %648 = load i32, i32 addrspace(3)* %647, align 4, !tbaa !8
  %649 = icmp sgt i32 %645, %648
  %650 = sub nsw i32 250, %357
  %651 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %650
  br i1 %649, label %654, label %652

652:                                              ; preds = %640
  store i32 %648, i32 addrspace(3)* %651, align 8, !tbaa !8
  %653 = add nsw i32 %641, -1
  br label %656

654:                                              ; preds = %640
  store i32 %645, i32 addrspace(3)* %651, align 8, !tbaa !8
  %655 = add nsw i32 %642, -1
  br label %656

656:                                              ; preds = %654, %652
  %657 = phi i32 [ %653, %652 ], [ %641, %654 ]
  %658 = phi i32 [ %642, %652 ], [ %655, %654 ]
  %659 = add nsw i32 %658, %128
  %660 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %659
  %661 = load i32, i32 addrspace(3)* %660, align 4, !tbaa !8
  %662 = add nsw i32 %135, %657
  %663 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %662
  %664 = load i32, i32 addrspace(3)* %663, align 4, !tbaa !8
  %665 = icmp sgt i32 %661, %664
  %666 = sub nsw i32 249, %357
  %667 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %666
  br i1 %665, label %670, label %668

668:                                              ; preds = %656
  store i32 %664, i32 addrspace(3)* %667, align 4, !tbaa !8
  %669 = add nsw i32 %657, -1
  br label %672

670:                                              ; preds = %656
  store i32 %661, i32 addrspace(3)* %667, align 4, !tbaa !8
  %671 = add nsw i32 %658, -1
  br label %672

672:                                              ; preds = %670, %668
  %673 = phi i32 [ %669, %668 ], [ %657, %670 ]
  %674 = phi i32 [ %658, %668 ], [ %671, %670 ]
  %675 = add nsw i32 %674, %128
  %676 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %675
  %677 = load i32, i32 addrspace(3)* %676, align 4, !tbaa !8
  %678 = add nsw i32 %135, %673
  %679 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %678
  %680 = load i32, i32 addrspace(3)* %679, align 4, !tbaa !8
  %681 = icmp sgt i32 %677, %680
  %682 = sub nsw i32 248, %357
  %683 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %682
  br i1 %681, label %686, label %684

684:                                              ; preds = %672
  store i32 %680, i32 addrspace(3)* %683, align 16, !tbaa !8
  %685 = add nsw i32 %673, -1
  br label %688

686:                                              ; preds = %672
  store i32 %677, i32 addrspace(3)* %683, align 16, !tbaa !8
  %687 = add nsw i32 %674, -1
  br label %688

688:                                              ; preds = %686, %684
  %689 = phi i32 [ %685, %684 ], [ %673, %686 ]
  %690 = phi i32 [ %674, %684 ], [ %687, %686 ]
  %691 = add nuw nsw i32 %357, 8
  %692 = icmp eq i32 %691, 256
  br i1 %692, label %385, label %356, !llvm.loop !19

merged.bb:                                        ; preds = %predication.tail171, %unify.bb3
  %693 = phi i32 [ 0, %unify.bb3 ], [ %879, %predication.tail171 ]
  %694 = phi i32 [ 0, %unify.bb3 ], [ %spec.result58, %predication.tail171 ]
  %695 = phi i32 [ 0, %unify.bb3 ], [ %spec.result57, %predication.tail171 ]
  %696 = phi i32 [ 0, %unify.bb3 ], [ %879, %predication.tail171 ]
  %697 = phi i32 [ 255, %unify.bb3 ], [ %878, %predication.tail171 ]
  %698 = phi i32 [ 255, %unify.bb3 ], [ %877, %predication.tail171 ]
  %merged.select10 = select i1 %134, i32 %695, i32 %697
  %699 = add nsw i32 %merged.select10, %128
  %700 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %699
  %701 = load i32, i32 addrspace(3)* %700, align 4, !tbaa !8
  %merged.select11 = select i1 %134, i32 %136, i32 %135
  %merged.select14 = select i1 %134, i32 %694, i32 %698
  %702 = add nsw i32 %merged.select11, %merged.select14
  %703 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %702
  %704 = load i32, i32 addrspace(3)* %703, align 4, !tbaa !8
  %705 = icmp sgt i32 %701, %704
  %706 = select i1 %705, i32 %704, i32 %701
  %707 = xor i1 %705, true
  %708 = zext i1 %707 to i32
  %709 = add nuw nsw i32 %695, %708
  %710 = zext i1 %705 to i32
  %711 = add nuw nsw i32 %694, %710
  %712 = sub nuw nsw i32 255, %696
  %spec.result = select i1 %134, i32 %706, i32 undef
  %spec.result1 = select i1 %134, i32 %709, i32 undef
  %spec.result2 = select i1 %134, i32 %711, i32 undef
  %spec.result3 = select i1 %134, i32 undef, i32 %712
  br label %predication.join

predication.join:                                 ; preds = %merged.bb
  %merged.select15 = select i1 %134, i32 %693, i32 %spec.result3
  %713 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %merged.select15
  br i1 %134, label %predication.split, label %predication.tail

predication.split:                                ; preds = %predication.join
  store i32 %spec.result, i32 addrspace(3)* %713, align 16
  %714 = or i32 %693, 1
  %715 = add nsw i32 %spec.result1, %128
  %716 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %715
  %717 = load i32, i32 addrspace(3)* %716, align 4, !tbaa !8
  %718 = add nsw i32 %136, %spec.result2
  %719 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %718
  %720 = load i32, i32 addrspace(3)* %719, align 4, !tbaa !8
  %721 = icmp sgt i32 %717, %720
  br label %predication.tail

predication.tail:                                 ; preds = %predication.split, %predication.join
  %722 = phi i32 [ undef, %predication.join ], [ %714, %predication.split ]
  %723 = phi i32 [ undef, %predication.join ], [ %717, %predication.split ]
  %724 = phi i32 [ undef, %predication.join ], [ %720, %predication.split ]
  %725 = phi i1 [ undef, %predication.join ], [ %721, %predication.split ]
  %merged.select16 = select i1 %134, i1 %725, i1 %705
  %merged.select19 = select i1 %134, i32 %724, i32 %701
  %merged.select20 = select i1 %134, i32 %723, i32 %704
  %726 = select i1 %merged.select16, i32 %merged.select19, i32 %merged.select20
  %727 = xor i1 %725, true
  %728 = zext i1 %727 to i32
  %729 = add nuw nsw i32 %spec.result1, %728
  %730 = zext i1 %725 to i32
  %731 = add nuw nsw i32 %spec.result2, %730
  %732 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %722
  %spec.result4 = select i1 %134, i32 %729, i32 undef
  %spec.result5 = select i1 %134, i32 %731, i32 undef
  %spec.result6 = select i1 %134, i32 addrspace(3)* %732, i32 addrspace(3)* undef
  br label %predication.tail67

predication.tail67:                               ; preds = %predication.tail
  %merged.select21 = select i1 %134, i32 addrspace(3)* %spec.result6, i32 addrspace(3)* %713
  store i32 %726, i32 addrspace(3)* %merged.select21, align 4
  %733 = or i32 %693, 2
  %734 = select i1 %705, i32 %697, i32 %698
  %735 = add nsw i32 %734, -1
  %736 = select i1 %705, i32 %698, i32 %735
  %spec.result7 = select i1 %134, i32 undef, i32 %735
  %spec.result8 = select i1 %134, i32 undef, i32 %736
  %spec.result9 = select i1 %134, i32 %733, i32 undef
  br label %predication.join70

predication.join70:                               ; preds = %predication.tail67
  %737 = select i1 %705, i32 %spec.result7, i32 %697
  %spec.result10 = select i1 %134, i32 undef, i32 %737
  br label %predication.tail75

predication.tail75:                               ; preds = %predication.join70
  %merged.select24 = select i1 %134, i32 %spec.result4, i32 %spec.result10
  %738 = add nsw i32 %merged.select24, %128
  %739 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %738
  %740 = load i32, i32 addrspace(3)* %739, align 4, !tbaa !8
  %merged.select25 = select i1 %134, i32 %136, i32 %135
  %merged.select26 = select i1 %134, i32 %spec.result5, i32 %spec.result8
  %741 = add nsw i32 %merged.select25, %merged.select26
  %742 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %741
  %743 = load i32, i32 addrspace(3)* %742, align 4, !tbaa !8
  %744 = icmp sgt i32 %740, %743
  %745 = select i1 %744, i32 %743, i32 %740
  %746 = xor i1 %744, true
  %747 = zext i1 %746 to i32
  %748 = add nuw nsw i32 %spec.result4, %747
  %749 = zext i1 %744 to i32
  %750 = add nuw nsw i32 %spec.result5, %749
  %751 = sub nsw i32 254, %696
  %spec.result11 = select i1 %134, i32 %745, i32 undef
  %spec.result12 = select i1 %134, i32 %748, i32 undef
  %spec.result13 = select i1 %134, i32 %750, i32 undef
  %spec.result14 = select i1 %134, i32 undef, i32 %751
  br label %predication.join78

predication.join78:                               ; preds = %predication.tail75
  %merged.select29 = select i1 %134, i32 %spec.result9, i32 %spec.result14
  %752 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %merged.select29
  %753 = select i1 %744, i32 %740, i32 %743
  %spec.result15 = select i1 %134, i32 undef, i32 %753
  br label %predication.tail84

predication.tail84:                               ; preds = %predication.join78
  %merged.select30 = select i1 %134, i32 %spec.result11, i32 %spec.result15
  store i32 %merged.select30, i32 addrspace(3)* %752, align 8
  %754 = or i32 %693, 3
  %755 = select i1 %744, i32 %spec.result10, i32 %spec.result8
  %756 = add nsw i32 %755, -1
  %757 = select i1 %744, i32 %spec.result8, i32 %756
  %spec.result16 = select i1 %134, i32 undef, i32 %756
  %spec.result17 = select i1 %134, i32 undef, i32 %757
  %spec.result18 = select i1 %134, i32 %754, i32 undef
  br label %predication.join87

predication.join87:                               ; preds = %predication.tail84
  %758 = select i1 %744, i32 %spec.result16, i32 %spec.result10
  %spec.result19 = select i1 %134, i32 undef, i32 %758
  br label %predication.tail92

predication.tail92:                               ; preds = %predication.join87
  %merged.select31 = select i1 %134, i32 %spec.result12, i32 %spec.result19
  %759 = add nsw i32 %merged.select31, %128
  %760 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %759
  %761 = load i32, i32 addrspace(3)* %760, align 4, !tbaa !8
  %merged.select34 = select i1 %134, i32 %136, i32 %135
  %merged.select35 = select i1 %134, i32 %spec.result13, i32 %spec.result17
  %762 = add nsw i32 %merged.select34, %merged.select35
  %763 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %762
  %764 = load i32, i32 addrspace(3)* %763, align 4, !tbaa !8
  %765 = icmp sgt i32 %761, %764
  %766 = select i1 %765, i32 %764, i32 %761
  %767 = xor i1 %765, true
  %768 = zext i1 %767 to i32
  %769 = add nuw nsw i32 %spec.result12, %768
  %770 = zext i1 %765 to i32
  %771 = add nuw nsw i32 %spec.result13, %770
  %772 = sub nsw i32 253, %696
  %spec.result20 = select i1 %134, i32 %766, i32 undef
  %spec.result21 = select i1 %134, i32 %769, i32 undef
  %spec.result22 = select i1 %134, i32 %771, i32 undef
  %spec.result23 = select i1 %134, i32 undef, i32 %772
  br label %predication.join95

predication.join95:                               ; preds = %predication.tail92
  %merged.select36 = select i1 %134, i32 %spec.result18, i32 %spec.result23
  %773 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %merged.select36
  %774 = select i1 %765, i32 %761, i32 %764
  %spec.result24 = select i1 %134, i32 undef, i32 %774
  br label %predication.tail101

predication.tail101:                              ; preds = %predication.join95
  %merged.select39 = select i1 %134, i32 %spec.result20, i32 %spec.result24
  store i32 %merged.select39, i32 addrspace(3)* %773, align 4
  %775 = or i32 %693, 4
  %776 = select i1 %765, i32 %spec.result19, i32 %spec.result17
  %777 = add nsw i32 %776, -1
  %778 = select i1 %765, i32 %spec.result17, i32 %777
  %spec.result25 = select i1 %134, i32 undef, i32 %777
  %spec.result26 = select i1 %134, i32 undef, i32 %778
  %spec.result27 = select i1 %134, i32 %775, i32 undef
  br label %predication.join104

predication.join104:                              ; preds = %predication.tail101
  %779 = select i1 %765, i32 %spec.result25, i32 %spec.result19
  %spec.result28 = select i1 %134, i32 undef, i32 %779
  br label %predication.tail109

predication.tail109:                              ; preds = %predication.join104
  %merged.select40 = select i1 %134, i32 %spec.result21, i32 %spec.result28
  %780 = add nsw i32 %merged.select40, %128
  %781 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %780
  %782 = load i32, i32 addrspace(3)* %781, align 4, !tbaa !8
  %merged.select41 = select i1 %134, i32 %136, i32 %135
  %merged.select42 = select i1 %134, i32 %spec.result22, i32 %spec.result26
  %783 = add nsw i32 %merged.select41, %merged.select42
  %784 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %783
  %785 = load i32, i32 addrspace(3)* %784, align 4, !tbaa !8
  %786 = icmp sgt i32 %782, %785
  %787 = select i1 %786, i32 %785, i32 %782
  %788 = xor i1 %786, true
  %789 = zext i1 %788 to i32
  %790 = add nuw nsw i32 %spec.result21, %789
  %791 = zext i1 %786 to i32
  %792 = add nuw nsw i32 %spec.result22, %791
  %793 = sub nsw i32 252, %696
  %spec.result29 = select i1 %134, i32 %787, i32 undef
  %spec.result30 = select i1 %134, i32 %790, i32 undef
  %spec.result31 = select i1 %134, i32 %792, i32 undef
  %spec.result32 = select i1 %134, i32 undef, i32 %793
  br label %predication.join112

predication.join112:                              ; preds = %predication.tail109
  %merged.select43 = select i1 %134, i32 %spec.result27, i32 %spec.result32
  %794 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %merged.select43
  %795 = select i1 %786, i32 %782, i32 %785
  %spec.result33 = select i1 %134, i32 undef, i32 %795
  br label %predication.tail118

predication.tail118:                              ; preds = %predication.join112
  %merged.select44 = select i1 %134, i32 %spec.result29, i32 %spec.result33
  store i32 %merged.select44, i32 addrspace(3)* %794, align 16
  %796 = or i32 %693, 5
  %797 = select i1 %786, i32 %spec.result28, i32 %spec.result26
  %798 = add nsw i32 %797, -1
  %799 = select i1 %786, i32 %spec.result26, i32 %798
  %spec.result34 = select i1 %134, i32 undef, i32 %798
  %spec.result35 = select i1 %134, i32 undef, i32 %799
  %spec.result36 = select i1 %134, i32 %796, i32 undef
  br label %predication.join121

predication.join121:                              ; preds = %predication.tail118
  %800 = select i1 %786, i32 %spec.result34, i32 %spec.result28
  %spec.result37 = select i1 %134, i32 undef, i32 %800
  br label %predication.tail126

predication.tail126:                              ; preds = %predication.join121
  %merged.select45 = select i1 %134, i32 %spec.result30, i32 %spec.result37
  %801 = add nsw i32 %merged.select45, %128
  %802 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %801
  %803 = load i32, i32 addrspace(3)* %802, align 4, !tbaa !8
  %merged.select46 = select i1 %134, i32 %136, i32 %135
  %merged.select47 = select i1 %134, i32 %spec.result31, i32 %spec.result35
  %804 = add nsw i32 %merged.select46, %merged.select47
  %805 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %804
  %806 = load i32, i32 addrspace(3)* %805, align 4, !tbaa !8
  %807 = icmp sgt i32 %803, %806
  %808 = select i1 %807, i32 %806, i32 %803
  %809 = xor i1 %807, true
  %810 = zext i1 %809 to i32
  %811 = add nuw nsw i32 %spec.result30, %810
  %812 = zext i1 %807 to i32
  %813 = add nuw nsw i32 %spec.result31, %812
  %814 = sub nsw i32 251, %696
  %spec.result38 = select i1 %134, i32 %808, i32 undef
  %spec.result39 = select i1 %134, i32 %811, i32 undef
  %spec.result40 = select i1 %134, i32 %813, i32 undef
  %spec.result41 = select i1 %134, i32 undef, i32 %814
  br label %predication.join129

predication.join129:                              ; preds = %predication.tail126
  %merged.select48 = select i1 %134, i32 %spec.result36, i32 %spec.result41
  %815 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %merged.select48
  %816 = select i1 %807, i32 %803, i32 %806
  %spec.result42 = select i1 %134, i32 undef, i32 %816
  br label %predication.tail135

predication.tail135:                              ; preds = %predication.join129
  %merged.select49 = select i1 %134, i32 %spec.result38, i32 %spec.result42
  store i32 %merged.select49, i32 addrspace(3)* %815, align 4
  %817 = or i32 %693, 6
  %818 = select i1 %807, i32 %spec.result37, i32 %spec.result35
  %819 = add nsw i32 %818, -1
  %820 = select i1 %807, i32 %spec.result35, i32 %819
  %spec.result43 = select i1 %134, i32 undef, i32 %819
  %spec.result44 = select i1 %134, i32 undef, i32 %820
  %spec.result45 = select i1 %134, i32 %817, i32 undef
  br label %predication.join138

predication.join138:                              ; preds = %predication.tail135
  %821 = select i1 %807, i32 %spec.result43, i32 %spec.result37
  %spec.result46 = select i1 %134, i32 undef, i32 %821
  br label %predication.tail143

predication.tail143:                              ; preds = %predication.join138
  %merged.select50 = select i1 %134, i32 %spec.result39, i32 %spec.result46
  %822 = add nsw i32 %merged.select50, %128
  %823 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %822
  %824 = load i32, i32 addrspace(3)* %823, align 4, !tbaa !8
  %merged.select51 = select i1 %134, i32 %136, i32 %135
  %merged.select52 = select i1 %134, i32 %spec.result40, i32 %spec.result44
  %825 = add nsw i32 %merged.select51, %merged.select52
  %826 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %825
  %827 = load i32, i32 addrspace(3)* %826, align 4, !tbaa !8
  %828 = icmp sgt i32 %824, %827
  %829 = select i1 %828, i32 %827, i32 %824
  %830 = xor i1 %828, true
  %831 = zext i1 %830 to i32
  %832 = add nuw nsw i32 %spec.result39, %831
  %833 = zext i1 %828 to i32
  %834 = add nuw nsw i32 %spec.result40, %833
  %835 = sub nsw i32 250, %696
  %spec.result47 = select i1 %134, i32 %829, i32 undef
  %spec.result48 = select i1 %134, i32 %832, i32 undef
  %spec.result49 = select i1 %134, i32 %834, i32 undef
  %spec.result50 = select i1 %134, i32 undef, i32 %835
  br label %predication.join146

predication.join146:                              ; preds = %predication.tail143
  %merged.select53 = select i1 %134, i32 %spec.result45, i32 %spec.result50
  %836 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %merged.select53
  %837 = select i1 %828, i32 %824, i32 %827
  %spec.result51 = select i1 %134, i32 undef, i32 %837
  br label %predication.tail152

predication.tail152:                              ; preds = %predication.join146
  %merged.select54 = select i1 %134, i32 %spec.result47, i32 %spec.result51
  store i32 %merged.select54, i32 addrspace(3)* %836, align 8
  %838 = or i32 %693, 7
  %839 = select i1 %828, i32 %spec.result46, i32 %spec.result44
  %840 = add nsw i32 %839, -1
  %841 = select i1 %828, i32 %spec.result44, i32 %840
  %spec.result52 = select i1 %134, i32 undef, i32 %840
  %spec.result53 = select i1 %134, i32 undef, i32 %841
  %spec.result54 = select i1 %134, i32 %838, i32 undef
  br label %predication.join155

predication.join155:                              ; preds = %predication.tail152
  %842 = select i1 %828, i32 %spec.result52, i32 %spec.result46
  %spec.result55 = select i1 %134, i32 undef, i32 %842
  br label %predication.tail160

predication.tail160:                              ; preds = %predication.join155
  %merged.select55 = select i1 %134, i32 %spec.result48, i32 %spec.result55
  %843 = add nsw i32 %merged.select55, %128
  %844 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %843
  %845 = load i32, i32 addrspace(3)* %844, align 4, !tbaa !8
  %merged.select56 = select i1 %134, i32 %136, i32 %135
  %merged.select57 = select i1 %134, i32 %spec.result49, i32 %spec.result53
  %846 = add nsw i32 %merged.select56, %merged.select57
  %847 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %846
  %848 = load i32, i32 addrspace(3)* %847, align 4, !tbaa !8
  %849 = icmp sgt i32 %845, %848
  %850 = select i1 %849, i32 %848, i32 %845
  %851 = xor i1 %849, true
  %852 = zext i1 %851 to i32
  %853 = add nuw nsw i32 %spec.result48, %852
  %854 = zext i1 %849 to i32
  %855 = add nuw nsw i32 %spec.result49, %854
  %856 = sub nsw i32 249, %696
  %spec.result56 = select i1 %134, i32 %850, i32 undef
  %spec.result57 = select i1 %134, i32 %853, i32 undef
  %spec.result58 = select i1 %134, i32 %855, i32 undef
  %spec.result59 = select i1 %134, i32 undef, i32 %856
  br label %predication.join163

predication.join163:                              ; preds = %predication.tail160
  %merged.select58 = select i1 %134, i32 %spec.result54, i32 %spec.result59
  %857 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %merged.select58
  %858 = select i1 %849, i32 %845, i32 %848
  %spec.result60 = select i1 %134, i32 undef, i32 %858
  br label %predication.tail169

predication.tail169:                              ; preds = %predication.join163
  %merged.select59 = select i1 %134, i32 %spec.result56, i32 %spec.result60
  store i32 %merged.select59, i32 addrspace(3)* %857, align 4
  br i1 %134, label %predication.tail171, label %predication.split170

predication.split170:                             ; preds = %predication.tail169
  %859 = select i1 %849, i32 %spec.result55, i32 %spec.result53
  %860 = add nsw i32 %859, -1
  %861 = select i1 %849, i32 %spec.result53, i32 %860
  %862 = select i1 %849, i32 %860, i32 %spec.result55
  %863 = add nsw i32 %862, %128
  %864 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %863
  %865 = load i32, i32 addrspace(3)* %864, align 4, !tbaa !8
  %866 = add nsw i32 %135, %861
  %867 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %866
  %868 = load i32, i32 addrspace(3)* %867, align 4, !tbaa !8
  %869 = icmp sgt i32 %865, %868
  %870 = sub nsw i32 248, %696
  %871 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %870
  %872 = select i1 %869, i32 %865, i32 %868
  store i32 %872, i32 addrspace(3)* %871, align 16, !tbaa !8
  %873 = select i1 %869, i32 %862, i32 %861
  %874 = add nsw i32 %873, -1
  %875 = select i1 %869, i32 %861, i32 %874
  %876 = select i1 %869, i32 %874, i32 %862
  br label %predication.tail171

predication.tail171:                              ; preds = %predication.split170, %predication.tail169
  %877 = phi i32 [ undef, %predication.tail169 ], [ %875, %predication.split170 ]
  %878 = phi i32 [ undef, %predication.tail169 ], [ %876, %predication.split170 ]
  %merged.select60 = select i1 %134, i32 %693, i32 %696
  %879 = add nuw nsw i32 %merged.select60, 8
  %880 = icmp eq i32 %879, 256
  br i1 %880, label %merged.bb9, label %merged.bb, !llvm.loop !20

merged.bb9:                                       ; preds = %predication.tail171
  br i1 %134, label %merged.branch.split61, label %merged.branch.split62

merged.branch.split61:                            ; preds = %merged.bb9
  br label %145

merged.branch.split62:                            ; preds = %merged.bb9
  br label %145
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
