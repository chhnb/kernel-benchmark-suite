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

merged.bb:                                        ; preds = %unify.bb3, %predication.tail171
  %693 = phi i32 [ 0, %unify.bb3 ], [ %894, %predication.tail171 ]
  %694 = phi i32 [ 0, %unify.bb3 ], [ %guard.value166, %predication.tail171 ]
  %695 = phi i32 [ 0, %unify.bb3 ], [ %guard.value165, %predication.tail171 ]
  %696 = phi i32 [ 0, %unify.bb3 ], [ %894, %predication.tail171 ]
  %697 = phi i32 [ 255, %unify.bb3 ], [ %893, %predication.tail171 ]
  %698 = phi i32 [ 255, %unify.bb3 ], [ %892, %predication.tail171 ]
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
  br i1 %134, label %predication.first, label %predication.second

predication.first:                                ; preds = %merged.bb
  %706 = select i1 %705, i32 %704, i32 %701
  %707 = xor i1 %705, true
  %708 = zext i1 %707 to i32
  %709 = add nuw nsw i32 %695, %708
  %710 = zext i1 %705 to i32
  %711 = add nuw nsw i32 %694, %710
  br label %predication.join

predication.second:                               ; preds = %merged.bb
  %712 = sub nuw nsw i32 255, %696
  br label %predication.join

predication.join:                                 ; preds = %predication.first, %predication.second
  %guard.value = phi i32 [ %706, %predication.first ], [ undef, %predication.second ]
  %guard.value63 = phi i32 [ %709, %predication.first ], [ undef, %predication.second ]
  %guard.value64 = phi i32 [ %711, %predication.first ], [ undef, %predication.second ]
  %guard.value65 = phi i32 [ undef, %predication.first ], [ %712, %predication.second ]
  %merged.select15 = select i1 %134, i32 %693, i32 %guard.value65
  %713 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %merged.select15
  br i1 %134, label %predication.split, label %predication.tail

predication.split:                                ; preds = %predication.join
  store i32 %guard.value, i32 addrspace(3)* %713, align 16
  %714 = or i32 %693, 1
  %715 = add nsw i32 %guard.value63, %128
  %716 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %715
  %717 = load i32, i32 addrspace(3)* %716, align 4, !tbaa !8
  %718 = add nsw i32 %136, %guard.value64
  %719 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %718
  %720 = load i32, i32 addrspace(3)* %719, align 4, !tbaa !8
  %721 = icmp sgt i32 %717, %720
  br label %predication.tail

predication.tail:                                 ; preds = %predication.join, %predication.split
  %722 = phi i32 [ undef, %predication.join ], [ %714, %predication.split ]
  %723 = phi i32 [ undef, %predication.join ], [ %717, %predication.split ]
  %724 = phi i32 [ undef, %predication.join ], [ %720, %predication.split ]
  %725 = phi i1 [ undef, %predication.join ], [ %721, %predication.split ]
  %merged.select16 = select i1 %134, i1 %725, i1 %705
  %merged.select19 = select i1 %134, i32 %724, i32 %701
  %merged.select20 = select i1 %134, i32 %723, i32 %704
  %726 = select i1 %merged.select16, i32 %merged.select19, i32 %merged.select20
  br i1 %134, label %predication.split66, label %predication.tail67

predication.split66:                              ; preds = %predication.tail
  %727 = xor i1 %725, true
  %728 = zext i1 %727 to i32
  %729 = add nuw nsw i32 %guard.value63, %728
  %730 = zext i1 %725 to i32
  %731 = add nuw nsw i32 %guard.value64, %730
  %732 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %722
  br label %predication.tail67

predication.tail67:                               ; preds = %predication.tail, %predication.split66
  %733 = phi i32 [ undef, %predication.tail ], [ %729, %predication.split66 ]
  %734 = phi i32 [ undef, %predication.tail ], [ %731, %predication.split66 ]
  %735 = phi i32 addrspace(3)* [ undef, %predication.tail ], [ %732, %predication.split66 ]
  %merged.select21 = select i1 %134, i32 addrspace(3)* %735, i32 addrspace(3)* %713
  store i32 %726, i32 addrspace(3)* %merged.select21, align 4
  br i1 %134, label %predication.second69, label %predication.first68

predication.first68:                              ; preds = %predication.tail67
  %736 = select i1 %705, i32 %697, i32 %698
  %737 = add nsw i32 %736, -1
  %738 = select i1 %705, i32 %698, i32 %737
  br label %predication.join70

predication.second69:                             ; preds = %predication.tail67
  %739 = or i32 %693, 2
  br label %predication.join70

predication.join70:                               ; preds = %predication.first68, %predication.second69
  %guard.value71 = phi i32 [ %737, %predication.first68 ], [ undef, %predication.second69 ]
  %guard.value72 = phi i32 [ %738, %predication.first68 ], [ undef, %predication.second69 ]
  %guard.value73 = phi i32 [ undef, %predication.first68 ], [ %739, %predication.second69 ]
  br i1 %134, label %predication.tail75, label %predication.split74

predication.split74:                              ; preds = %predication.join70
  %740 = select i1 %705, i32 %guard.value71, i32 %697
  br label %predication.tail75

predication.tail75:                               ; preds = %predication.join70, %predication.split74
  %741 = phi i32 [ undef, %predication.join70 ], [ %740, %predication.split74 ]
  %merged.select24 = select i1 %134, i32 %733, i32 %741
  %742 = add nsw i32 %merged.select24, %128
  %743 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %742
  %744 = load i32, i32 addrspace(3)* %743, align 4, !tbaa !8
  %merged.select25 = select i1 %134, i32 %136, i32 %135
  %merged.select26 = select i1 %134, i32 %734, i32 %guard.value72
  %745 = add nsw i32 %merged.select25, %merged.select26
  %746 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %745
  %747 = load i32, i32 addrspace(3)* %746, align 4, !tbaa !8
  %748 = icmp sgt i32 %744, %747
  br i1 %134, label %predication.first76, label %predication.second77

predication.first76:                              ; preds = %predication.tail75
  %749 = select i1 %748, i32 %747, i32 %744
  %750 = xor i1 %748, true
  %751 = zext i1 %750 to i32
  %752 = add nuw nsw i32 %733, %751
  %753 = zext i1 %748 to i32
  %754 = add nuw nsw i32 %734, %753
  br label %predication.join78

predication.second77:                             ; preds = %predication.tail75
  %755 = sub nsw i32 254, %696
  br label %predication.join78

predication.join78:                               ; preds = %predication.first76, %predication.second77
  %guard.value79 = phi i32 [ %749, %predication.first76 ], [ undef, %predication.second77 ]
  %guard.value80 = phi i32 [ %752, %predication.first76 ], [ undef, %predication.second77 ]
  %guard.value81 = phi i32 [ %754, %predication.first76 ], [ undef, %predication.second77 ]
  %guard.value82 = phi i32 [ undef, %predication.first76 ], [ %755, %predication.second77 ]
  %merged.select29 = select i1 %134, i32 %guard.value73, i32 %guard.value82
  %756 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %merged.select29
  br i1 %134, label %predication.tail84, label %predication.split83

predication.split83:                              ; preds = %predication.join78
  %757 = select i1 %748, i32 %744, i32 %747
  br label %predication.tail84

predication.tail84:                               ; preds = %predication.join78, %predication.split83
  %758 = phi i32 [ undef, %predication.join78 ], [ %757, %predication.split83 ]
  %merged.select30 = select i1 %134, i32 %guard.value79, i32 %758
  store i32 %merged.select30, i32 addrspace(3)* %756, align 8
  br i1 %134, label %predication.second86, label %predication.first85

predication.first85:                              ; preds = %predication.tail84
  %759 = select i1 %748, i32 %741, i32 %guard.value72
  %760 = add nsw i32 %759, -1
  %761 = select i1 %748, i32 %guard.value72, i32 %760
  br label %predication.join87

predication.second86:                             ; preds = %predication.tail84
  %762 = or i32 %693, 3
  br label %predication.join87

predication.join87:                               ; preds = %predication.first85, %predication.second86
  %guard.value88 = phi i32 [ %760, %predication.first85 ], [ undef, %predication.second86 ]
  %guard.value89 = phi i32 [ %761, %predication.first85 ], [ undef, %predication.second86 ]
  %guard.value90 = phi i32 [ undef, %predication.first85 ], [ %762, %predication.second86 ]
  br i1 %134, label %predication.tail92, label %predication.split91

predication.split91:                              ; preds = %predication.join87
  %763 = select i1 %748, i32 %guard.value88, i32 %741
  br label %predication.tail92

predication.tail92:                               ; preds = %predication.join87, %predication.split91
  %764 = phi i32 [ undef, %predication.join87 ], [ %763, %predication.split91 ]
  %merged.select31 = select i1 %134, i32 %guard.value80, i32 %764
  %765 = add nsw i32 %merged.select31, %128
  %766 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %765
  %767 = load i32, i32 addrspace(3)* %766, align 4, !tbaa !8
  %merged.select34 = select i1 %134, i32 %136, i32 %135
  %merged.select35 = select i1 %134, i32 %guard.value81, i32 %guard.value89
  %768 = add nsw i32 %merged.select34, %merged.select35
  %769 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %768
  %770 = load i32, i32 addrspace(3)* %769, align 4, !tbaa !8
  %771 = icmp sgt i32 %767, %770
  br i1 %134, label %predication.first93, label %predication.second94

predication.first93:                              ; preds = %predication.tail92
  %772 = select i1 %771, i32 %770, i32 %767
  %773 = xor i1 %771, true
  %774 = zext i1 %773 to i32
  %775 = add nuw nsw i32 %guard.value80, %774
  %776 = zext i1 %771 to i32
  %777 = add nuw nsw i32 %guard.value81, %776
  br label %predication.join95

predication.second94:                             ; preds = %predication.tail92
  %778 = sub nsw i32 253, %696
  br label %predication.join95

predication.join95:                               ; preds = %predication.first93, %predication.second94
  %guard.value96 = phi i32 [ %772, %predication.first93 ], [ undef, %predication.second94 ]
  %guard.value97 = phi i32 [ %775, %predication.first93 ], [ undef, %predication.second94 ]
  %guard.value98 = phi i32 [ %777, %predication.first93 ], [ undef, %predication.second94 ]
  %guard.value99 = phi i32 [ undef, %predication.first93 ], [ %778, %predication.second94 ]
  %merged.select36 = select i1 %134, i32 %guard.value90, i32 %guard.value99
  %779 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %merged.select36
  br i1 %134, label %predication.tail101, label %predication.split100

predication.split100:                             ; preds = %predication.join95
  %780 = select i1 %771, i32 %767, i32 %770
  br label %predication.tail101

predication.tail101:                              ; preds = %predication.join95, %predication.split100
  %781 = phi i32 [ undef, %predication.join95 ], [ %780, %predication.split100 ]
  %merged.select39 = select i1 %134, i32 %guard.value96, i32 %781
  store i32 %merged.select39, i32 addrspace(3)* %779, align 4
  br i1 %134, label %predication.second103, label %predication.first102

predication.first102:                             ; preds = %predication.tail101
  %782 = select i1 %771, i32 %764, i32 %guard.value89
  %783 = add nsw i32 %782, -1
  %784 = select i1 %771, i32 %guard.value89, i32 %783
  br label %predication.join104

predication.second103:                            ; preds = %predication.tail101
  %785 = or i32 %693, 4
  br label %predication.join104

predication.join104:                              ; preds = %predication.first102, %predication.second103
  %guard.value105 = phi i32 [ %783, %predication.first102 ], [ undef, %predication.second103 ]
  %guard.value106 = phi i32 [ %784, %predication.first102 ], [ undef, %predication.second103 ]
  %guard.value107 = phi i32 [ undef, %predication.first102 ], [ %785, %predication.second103 ]
  br i1 %134, label %predication.tail109, label %predication.split108

predication.split108:                             ; preds = %predication.join104
  %786 = select i1 %771, i32 %guard.value105, i32 %764
  br label %predication.tail109

predication.tail109:                              ; preds = %predication.join104, %predication.split108
  %787 = phi i32 [ undef, %predication.join104 ], [ %786, %predication.split108 ]
  %merged.select40 = select i1 %134, i32 %guard.value97, i32 %787
  %788 = add nsw i32 %merged.select40, %128
  %789 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %788
  %790 = load i32, i32 addrspace(3)* %789, align 4, !tbaa !8
  %merged.select41 = select i1 %134, i32 %136, i32 %135
  %merged.select42 = select i1 %134, i32 %guard.value98, i32 %guard.value106
  %791 = add nsw i32 %merged.select41, %merged.select42
  %792 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %791
  %793 = load i32, i32 addrspace(3)* %792, align 4, !tbaa !8
  %794 = icmp sgt i32 %790, %793
  br i1 %134, label %predication.first110, label %predication.second111

predication.first110:                             ; preds = %predication.tail109
  %795 = select i1 %794, i32 %793, i32 %790
  %796 = xor i1 %794, true
  %797 = zext i1 %796 to i32
  %798 = add nuw nsw i32 %guard.value97, %797
  %799 = zext i1 %794 to i32
  %800 = add nuw nsw i32 %guard.value98, %799
  br label %predication.join112

predication.second111:                            ; preds = %predication.tail109
  %801 = sub nsw i32 252, %696
  br label %predication.join112

predication.join112:                              ; preds = %predication.first110, %predication.second111
  %guard.value113 = phi i32 [ %795, %predication.first110 ], [ undef, %predication.second111 ]
  %guard.value114 = phi i32 [ %798, %predication.first110 ], [ undef, %predication.second111 ]
  %guard.value115 = phi i32 [ %800, %predication.first110 ], [ undef, %predication.second111 ]
  %guard.value116 = phi i32 [ undef, %predication.first110 ], [ %801, %predication.second111 ]
  %merged.select43 = select i1 %134, i32 %guard.value107, i32 %guard.value116
  %802 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %merged.select43
  br i1 %134, label %predication.tail118, label %predication.split117

predication.split117:                             ; preds = %predication.join112
  %803 = select i1 %794, i32 %790, i32 %793
  br label %predication.tail118

predication.tail118:                              ; preds = %predication.join112, %predication.split117
  %804 = phi i32 [ undef, %predication.join112 ], [ %803, %predication.split117 ]
  %merged.select44 = select i1 %134, i32 %guard.value113, i32 %804
  store i32 %merged.select44, i32 addrspace(3)* %802, align 16
  br i1 %134, label %predication.second120, label %predication.first119

predication.first119:                             ; preds = %predication.tail118
  %805 = select i1 %794, i32 %787, i32 %guard.value106
  %806 = add nsw i32 %805, -1
  %807 = select i1 %794, i32 %guard.value106, i32 %806
  br label %predication.join121

predication.second120:                            ; preds = %predication.tail118
  %808 = or i32 %693, 5
  br label %predication.join121

predication.join121:                              ; preds = %predication.first119, %predication.second120
  %guard.value122 = phi i32 [ %806, %predication.first119 ], [ undef, %predication.second120 ]
  %guard.value123 = phi i32 [ %807, %predication.first119 ], [ undef, %predication.second120 ]
  %guard.value124 = phi i32 [ undef, %predication.first119 ], [ %808, %predication.second120 ]
  br i1 %134, label %predication.tail126, label %predication.split125

predication.split125:                             ; preds = %predication.join121
  %809 = select i1 %794, i32 %guard.value122, i32 %787
  br label %predication.tail126

predication.tail126:                              ; preds = %predication.join121, %predication.split125
  %810 = phi i32 [ undef, %predication.join121 ], [ %809, %predication.split125 ]
  %merged.select45 = select i1 %134, i32 %guard.value114, i32 %810
  %811 = add nsw i32 %merged.select45, %128
  %812 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %811
  %813 = load i32, i32 addrspace(3)* %812, align 4, !tbaa !8
  %merged.select46 = select i1 %134, i32 %136, i32 %135
  %merged.select47 = select i1 %134, i32 %guard.value115, i32 %guard.value123
  %814 = add nsw i32 %merged.select46, %merged.select47
  %815 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %814
  %816 = load i32, i32 addrspace(3)* %815, align 4, !tbaa !8
  %817 = icmp sgt i32 %813, %816
  br i1 %134, label %predication.first127, label %predication.second128

predication.first127:                             ; preds = %predication.tail126
  %818 = select i1 %817, i32 %816, i32 %813
  %819 = xor i1 %817, true
  %820 = zext i1 %819 to i32
  %821 = add nuw nsw i32 %guard.value114, %820
  %822 = zext i1 %817 to i32
  %823 = add nuw nsw i32 %guard.value115, %822
  br label %predication.join129

predication.second128:                            ; preds = %predication.tail126
  %824 = sub nsw i32 251, %696
  br label %predication.join129

predication.join129:                              ; preds = %predication.first127, %predication.second128
  %guard.value130 = phi i32 [ %818, %predication.first127 ], [ undef, %predication.second128 ]
  %guard.value131 = phi i32 [ %821, %predication.first127 ], [ undef, %predication.second128 ]
  %guard.value132 = phi i32 [ %823, %predication.first127 ], [ undef, %predication.second128 ]
  %guard.value133 = phi i32 [ undef, %predication.first127 ], [ %824, %predication.second128 ]
  %merged.select48 = select i1 %134, i32 %guard.value124, i32 %guard.value133
  %825 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %merged.select48
  br i1 %134, label %predication.tail135, label %predication.split134

predication.split134:                             ; preds = %predication.join129
  %826 = select i1 %817, i32 %813, i32 %816
  br label %predication.tail135

predication.tail135:                              ; preds = %predication.join129, %predication.split134
  %827 = phi i32 [ undef, %predication.join129 ], [ %826, %predication.split134 ]
  %merged.select49 = select i1 %134, i32 %guard.value130, i32 %827
  store i32 %merged.select49, i32 addrspace(3)* %825, align 4
  br i1 %134, label %predication.second137, label %predication.first136

predication.first136:                             ; preds = %predication.tail135
  %828 = select i1 %817, i32 %810, i32 %guard.value123
  %829 = add nsw i32 %828, -1
  %830 = select i1 %817, i32 %guard.value123, i32 %829
  br label %predication.join138

predication.second137:                            ; preds = %predication.tail135
  %831 = or i32 %693, 6
  br label %predication.join138

predication.join138:                              ; preds = %predication.first136, %predication.second137
  %guard.value139 = phi i32 [ %829, %predication.first136 ], [ undef, %predication.second137 ]
  %guard.value140 = phi i32 [ %830, %predication.first136 ], [ undef, %predication.second137 ]
  %guard.value141 = phi i32 [ undef, %predication.first136 ], [ %831, %predication.second137 ]
  br i1 %134, label %predication.tail143, label %predication.split142

predication.split142:                             ; preds = %predication.join138
  %832 = select i1 %817, i32 %guard.value139, i32 %810
  br label %predication.tail143

predication.tail143:                              ; preds = %predication.join138, %predication.split142
  %833 = phi i32 [ undef, %predication.join138 ], [ %832, %predication.split142 ]
  %merged.select50 = select i1 %134, i32 %guard.value131, i32 %833
  %834 = add nsw i32 %merged.select50, %128
  %835 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %834
  %836 = load i32, i32 addrspace(3)* %835, align 4, !tbaa !8
  %merged.select51 = select i1 %134, i32 %136, i32 %135
  %merged.select52 = select i1 %134, i32 %guard.value132, i32 %guard.value140
  %837 = add nsw i32 %merged.select51, %merged.select52
  %838 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %837
  %839 = load i32, i32 addrspace(3)* %838, align 4, !tbaa !8
  %840 = icmp sgt i32 %836, %839
  br i1 %134, label %predication.first144, label %predication.second145

predication.first144:                             ; preds = %predication.tail143
  %841 = select i1 %840, i32 %839, i32 %836
  %842 = xor i1 %840, true
  %843 = zext i1 %842 to i32
  %844 = add nuw nsw i32 %guard.value131, %843
  %845 = zext i1 %840 to i32
  %846 = add nuw nsw i32 %guard.value132, %845
  br label %predication.join146

predication.second145:                            ; preds = %predication.tail143
  %847 = sub nsw i32 250, %696
  br label %predication.join146

predication.join146:                              ; preds = %predication.first144, %predication.second145
  %guard.value147 = phi i32 [ %841, %predication.first144 ], [ undef, %predication.second145 ]
  %guard.value148 = phi i32 [ %844, %predication.first144 ], [ undef, %predication.second145 ]
  %guard.value149 = phi i32 [ %846, %predication.first144 ], [ undef, %predication.second145 ]
  %guard.value150 = phi i32 [ undef, %predication.first144 ], [ %847, %predication.second145 ]
  %merged.select53 = select i1 %134, i32 %guard.value141, i32 %guard.value150
  %848 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %merged.select53
  br i1 %134, label %predication.tail152, label %predication.split151

predication.split151:                             ; preds = %predication.join146
  %849 = select i1 %840, i32 %836, i32 %839
  br label %predication.tail152

predication.tail152:                              ; preds = %predication.join146, %predication.split151
  %850 = phi i32 [ undef, %predication.join146 ], [ %849, %predication.split151 ]
  %merged.select54 = select i1 %134, i32 %guard.value147, i32 %850
  store i32 %merged.select54, i32 addrspace(3)* %848, align 8
  br i1 %134, label %predication.second154, label %predication.first153

predication.first153:                             ; preds = %predication.tail152
  %851 = select i1 %840, i32 %833, i32 %guard.value140
  %852 = add nsw i32 %851, -1
  %853 = select i1 %840, i32 %guard.value140, i32 %852
  br label %predication.join155

predication.second154:                            ; preds = %predication.tail152
  %854 = or i32 %693, 7
  br label %predication.join155

predication.join155:                              ; preds = %predication.first153, %predication.second154
  %guard.value156 = phi i32 [ %852, %predication.first153 ], [ undef, %predication.second154 ]
  %guard.value157 = phi i32 [ %853, %predication.first153 ], [ undef, %predication.second154 ]
  %guard.value158 = phi i32 [ undef, %predication.first153 ], [ %854, %predication.second154 ]
  br i1 %134, label %predication.tail160, label %predication.split159

predication.split159:                             ; preds = %predication.join155
  %855 = select i1 %840, i32 %guard.value156, i32 %833
  br label %predication.tail160

predication.tail160:                              ; preds = %predication.join155, %predication.split159
  %856 = phi i32 [ undef, %predication.join155 ], [ %855, %predication.split159 ]
  %merged.select55 = select i1 %134, i32 %guard.value148, i32 %856
  %857 = add nsw i32 %merged.select55, %128
  %858 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %857
  %859 = load i32, i32 addrspace(3)* %858, align 4, !tbaa !8
  %merged.select56 = select i1 %134, i32 %136, i32 %135
  %merged.select57 = select i1 %134, i32 %guard.value149, i32 %guard.value157
  %860 = add nsw i32 %merged.select56, %merged.select57
  %861 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %860
  %862 = load i32, i32 addrspace(3)* %861, align 4, !tbaa !8
  %863 = icmp sgt i32 %859, %862
  br i1 %134, label %predication.first161, label %predication.second162

predication.first161:                             ; preds = %predication.tail160
  %864 = select i1 %863, i32 %862, i32 %859
  %865 = xor i1 %863, true
  %866 = zext i1 %865 to i32
  %867 = add nuw nsw i32 %guard.value148, %866
  %868 = zext i1 %863 to i32
  %869 = add nuw nsw i32 %guard.value149, %868
  br label %predication.join163

predication.second162:                            ; preds = %predication.tail160
  %870 = sub nsw i32 249, %696
  br label %predication.join163

predication.join163:                              ; preds = %predication.first161, %predication.second162
  %guard.value164 = phi i32 [ %864, %predication.first161 ], [ undef, %predication.second162 ]
  %guard.value165 = phi i32 [ %867, %predication.first161 ], [ undef, %predication.second162 ]
  %guard.value166 = phi i32 [ %869, %predication.first161 ], [ undef, %predication.second162 ]
  %guard.value167 = phi i32 [ undef, %predication.first161 ], [ %870, %predication.second162 ]
  %merged.select58 = select i1 %134, i32 %guard.value158, i32 %guard.value167
  %871 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %merged.select58
  br i1 %134, label %predication.tail169, label %predication.split168

predication.split168:                             ; preds = %predication.join163
  %872 = select i1 %863, i32 %859, i32 %862
  br label %predication.tail169

predication.tail169:                              ; preds = %predication.join163, %predication.split168
  %873 = phi i32 [ undef, %predication.join163 ], [ %872, %predication.split168 ]
  %merged.select59 = select i1 %134, i32 %guard.value164, i32 %873
  store i32 %merged.select59, i32 addrspace(3)* %871, align 4
  br i1 %134, label %predication.tail171, label %predication.split170

predication.split170:                             ; preds = %predication.tail169
  %874 = select i1 %863, i32 %856, i32 %guard.value157
  %875 = add nsw i32 %874, -1
  %876 = select i1 %863, i32 %guard.value157, i32 %875
  %877 = select i1 %863, i32 %875, i32 %856
  %878 = add nsw i32 %877, %128
  %879 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %878
  %880 = load i32, i32 addrspace(3)* %879, align 4, !tbaa !8
  %881 = add nsw i32 %135, %876
  %882 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %881
  %883 = load i32, i32 addrspace(3)* %882, align 4, !tbaa !8
  %884 = icmp sgt i32 %880, %883
  %885 = sub nsw i32 248, %696
  %886 = getelementptr inbounds i32, i32 addrspace(3)* %129, i32 %885
  %887 = select i1 %884, i32 %880, i32 %883
  store i32 %887, i32 addrspace(3)* %886, align 16, !tbaa !8
  %888 = select i1 %884, i32 %877, i32 %876
  %889 = add nsw i32 %888, -1
  %890 = select i1 %884, i32 %876, i32 %889
  %891 = select i1 %884, i32 %889, i32 %877
  br label %predication.tail171

predication.tail171:                              ; preds = %predication.tail169, %predication.split170
  %892 = phi i32 [ undef, %predication.tail169 ], [ %890, %predication.split170 ]
  %893 = phi i32 [ undef, %predication.tail169 ], [ %891, %predication.split170 ]
  %merged.select60 = select i1 %134, i32 %693, i32 %696
  %894 = add nuw nsw i32 %merged.select60, 8
  %895 = icmp eq i32 %894, 256
  br i1 %895, label %merged.bb9, label %merged.bb, !llvm.loop !20

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
