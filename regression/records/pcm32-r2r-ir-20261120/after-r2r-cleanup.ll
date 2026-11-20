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
  br label %unify.bb3

139:                                              ; preds = %465
  br i1 %10, label %140, label %583

140:                                              ; preds = %139
  br label %468

unify.bb3:                                        ; preds = %merged.branch.split1, %465
  %141 = phi i32 [ 0, %merged.branch.split1 ], [ %466, %465 ]
  br label %merged.bb

142:                                              ; preds = %142, %merged.bb9
  %143 = phi i32 [ %223, %142 ], [ 0, %merged.bb9 ]
  %144 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %143
  %145 = load i32, i32 addrspace(3)* %144, align 16, !tbaa !8
  %146 = add nuw nsw i32 %143, %13
  %147 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %146
  store i32 %145, i32 addrspace(3)* %147, align 16, !tbaa !8
  %148 = or i32 %143, 1
  %149 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %148
  %150 = load i32, i32 addrspace(3)* %149, align 4, !tbaa !8
  %151 = add nuw nsw i32 %148, %13
  %152 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %151
  store i32 %150, i32 addrspace(3)* %152, align 4, !tbaa !8
  %153 = or i32 %143, 2
  %154 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %153
  %155 = load i32, i32 addrspace(3)* %154, align 8, !tbaa !8
  %156 = add nuw nsw i32 %153, %13
  %157 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %156
  store i32 %155, i32 addrspace(3)* %157, align 8, !tbaa !8
  %158 = or i32 %143, 3
  %159 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %158
  %160 = load i32, i32 addrspace(3)* %159, align 4, !tbaa !8
  %161 = add nuw nsw i32 %158, %13
  %162 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %161
  store i32 %160, i32 addrspace(3)* %162, align 4, !tbaa !8
  %163 = or i32 %143, 4
  %164 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %163
  %165 = load i32, i32 addrspace(3)* %164, align 16, !tbaa !8
  %166 = add nuw nsw i32 %163, %13
  %167 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %166
  store i32 %165, i32 addrspace(3)* %167, align 16, !tbaa !8
  %168 = or i32 %143, 5
  %169 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %168
  %170 = load i32, i32 addrspace(3)* %169, align 4, !tbaa !8
  %171 = add nuw nsw i32 %168, %13
  %172 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %171
  store i32 %170, i32 addrspace(3)* %172, align 4, !tbaa !8
  %173 = or i32 %143, 6
  %174 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %173
  %175 = load i32, i32 addrspace(3)* %174, align 8, !tbaa !8
  %176 = add nuw nsw i32 %173, %13
  %177 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %176
  store i32 %175, i32 addrspace(3)* %177, align 8, !tbaa !8
  %178 = or i32 %143, 7
  %179 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %178
  %180 = load i32, i32 addrspace(3)* %179, align 4, !tbaa !8
  %181 = add nuw nsw i32 %178, %13
  %182 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %181
  store i32 %180, i32 addrspace(3)* %182, align 4, !tbaa !8
  %183 = or i32 %143, 8
  %184 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %183
  %185 = load i32, i32 addrspace(3)* %184, align 16, !tbaa !8
  %186 = add nuw nsw i32 %183, %13
  %187 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %186
  store i32 %185, i32 addrspace(3)* %187, align 16, !tbaa !8
  %188 = or i32 %143, 9
  %189 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %188
  %190 = load i32, i32 addrspace(3)* %189, align 4, !tbaa !8
  %191 = add nuw nsw i32 %188, %13
  %192 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %191
  store i32 %190, i32 addrspace(3)* %192, align 4, !tbaa !8
  %193 = or i32 %143, 10
  %194 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %193
  %195 = load i32, i32 addrspace(3)* %194, align 8, !tbaa !8
  %196 = add nuw nsw i32 %193, %13
  %197 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %196
  store i32 %195, i32 addrspace(3)* %197, align 8, !tbaa !8
  %198 = or i32 %143, 11
  %199 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %198
  %200 = load i32, i32 addrspace(3)* %199, align 4, !tbaa !8
  %201 = add nuw nsw i32 %198, %13
  %202 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %201
  store i32 %200, i32 addrspace(3)* %202, align 4, !tbaa !8
  %203 = or i32 %143, 12
  %204 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %203
  %205 = load i32, i32 addrspace(3)* %204, align 16, !tbaa !8
  %206 = add nuw nsw i32 %203, %13
  %207 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %206
  store i32 %205, i32 addrspace(3)* %207, align 16, !tbaa !8
  %208 = or i32 %143, 13
  %209 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %208
  %210 = load i32, i32 addrspace(3)* %209, align 4, !tbaa !8
  %211 = add nuw nsw i32 %208, %13
  %212 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %211
  store i32 %210, i32 addrspace(3)* %212, align 4, !tbaa !8
  %213 = or i32 %143, 14
  %214 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %213
  %215 = load i32, i32 addrspace(3)* %214, align 8, !tbaa !8
  %216 = add nuw nsw i32 %213, %13
  %217 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %216
  store i32 %215, i32 addrspace(3)* %217, align 8, !tbaa !8
  %218 = or i32 %143, 15
  %219 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %218
  %220 = load i32, i32 addrspace(3)* %219, align 4, !tbaa !8
  %221 = add nuw nsw i32 %218, %13
  %222 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %221
  store i32 %220, i32 addrspace(3)* %222, align 4, !tbaa !8
  %223 = add nuw nsw i32 %143, 16
  %224 = icmp eq i32 %223, 256
  br i1 %224, label %225, label %142, !llvm.loop !14

225:                                              ; preds = %142, %merged.bb9
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %137, label %226, label %351

226:                                              ; preds = %226, %225
  %227 = phi i32 [ 0, %225 ], [ %349, %226 ]
  %228 = phi i32 [ 0, %225 ], [ %347, %226 ]
  %229 = phi i32 [ 0, %225 ], [ %345, %226 ]
  %230 = add nsw i32 %229, %13
  %231 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %230
  %232 = load i32, i32 addrspace(3)* %231, align 4, !tbaa !8
  %233 = add nsw i32 %135, %228
  %234 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %233
  %235 = load i32, i32 addrspace(3)* %234, align 4, !tbaa !8
  %236 = icmp sgt i32 %232, %235
  %237 = select i1 %236, i32 %235, i32 %232
  %238 = xor i1 %236, true
  %239 = zext i1 %238 to i32
  %240 = add nuw nsw i32 %229, %239
  %241 = zext i1 %236 to i32
  %242 = add nuw nsw i32 %228, %241
  %243 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %227
  store i32 %237, i32 addrspace(3)* %243, align 16
  %244 = or i32 %227, 1
  %245 = add nsw i32 %240, %13
  %246 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %245
  %247 = load i32, i32 addrspace(3)* %246, align 4, !tbaa !8
  %248 = add nsw i32 %135, %242
  %249 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %248
  %250 = load i32, i32 addrspace(3)* %249, align 4, !tbaa !8
  %251 = icmp sgt i32 %247, %250
  %252 = select i1 %251, i32 %250, i32 %247
  %253 = xor i1 %251, true
  %254 = zext i1 %253 to i32
  %255 = add nuw nsw i32 %240, %254
  %256 = zext i1 %251 to i32
  %257 = add nuw nsw i32 %242, %256
  %258 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %244
  store i32 %252, i32 addrspace(3)* %258, align 4
  %259 = or i32 %227, 2
  %260 = add nsw i32 %255, %13
  %261 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %260
  %262 = load i32, i32 addrspace(3)* %261, align 4, !tbaa !8
  %263 = add nsw i32 %135, %257
  %264 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %263
  %265 = load i32, i32 addrspace(3)* %264, align 4, !tbaa !8
  %266 = icmp sgt i32 %262, %265
  %267 = select i1 %266, i32 %265, i32 %262
  %268 = xor i1 %266, true
  %269 = zext i1 %268 to i32
  %270 = add nuw nsw i32 %255, %269
  %271 = zext i1 %266 to i32
  %272 = add nuw nsw i32 %257, %271
  %273 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %259
  store i32 %267, i32 addrspace(3)* %273, align 8
  %274 = or i32 %227, 3
  %275 = add nsw i32 %270, %13
  %276 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %275
  %277 = load i32, i32 addrspace(3)* %276, align 4, !tbaa !8
  %278 = add nsw i32 %135, %272
  %279 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %278
  %280 = load i32, i32 addrspace(3)* %279, align 4, !tbaa !8
  %281 = icmp sgt i32 %277, %280
  %282 = select i1 %281, i32 %280, i32 %277
  %283 = xor i1 %281, true
  %284 = zext i1 %283 to i32
  %285 = add nuw nsw i32 %270, %284
  %286 = zext i1 %281 to i32
  %287 = add nuw nsw i32 %272, %286
  %288 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %274
  store i32 %282, i32 addrspace(3)* %288, align 4
  %289 = or i32 %227, 4
  %290 = add nsw i32 %285, %13
  %291 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %290
  %292 = load i32, i32 addrspace(3)* %291, align 4, !tbaa !8
  %293 = add nsw i32 %135, %287
  %294 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %293
  %295 = load i32, i32 addrspace(3)* %294, align 4, !tbaa !8
  %296 = icmp sgt i32 %292, %295
  %297 = select i1 %296, i32 %295, i32 %292
  %298 = xor i1 %296, true
  %299 = zext i1 %298 to i32
  %300 = add nuw nsw i32 %285, %299
  %301 = zext i1 %296 to i32
  %302 = add nuw nsw i32 %287, %301
  %303 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %289
  store i32 %297, i32 addrspace(3)* %303, align 16
  %304 = or i32 %227, 5
  %305 = add nsw i32 %300, %13
  %306 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %305
  %307 = load i32, i32 addrspace(3)* %306, align 4, !tbaa !8
  %308 = add nsw i32 %135, %302
  %309 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %308
  %310 = load i32, i32 addrspace(3)* %309, align 4, !tbaa !8
  %311 = icmp sgt i32 %307, %310
  %312 = select i1 %311, i32 %310, i32 %307
  %313 = xor i1 %311, true
  %314 = zext i1 %313 to i32
  %315 = add nuw nsw i32 %300, %314
  %316 = zext i1 %311 to i32
  %317 = add nuw nsw i32 %302, %316
  %318 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %304
  store i32 %312, i32 addrspace(3)* %318, align 4
  %319 = or i32 %227, 6
  %320 = add nsw i32 %315, %13
  %321 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %320
  %322 = load i32, i32 addrspace(3)* %321, align 4, !tbaa !8
  %323 = add nsw i32 %135, %317
  %324 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %323
  %325 = load i32, i32 addrspace(3)* %324, align 4, !tbaa !8
  %326 = icmp sgt i32 %322, %325
  %327 = select i1 %326, i32 %325, i32 %322
  %328 = xor i1 %326, true
  %329 = zext i1 %328 to i32
  %330 = add nuw nsw i32 %315, %329
  %331 = zext i1 %326 to i32
  %332 = add nuw nsw i32 %317, %331
  %333 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %319
  store i32 %327, i32 addrspace(3)* %333, align 8
  %334 = or i32 %227, 7
  %335 = add nsw i32 %330, %13
  %336 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %335
  %337 = load i32, i32 addrspace(3)* %336, align 4, !tbaa !8
  %338 = add nsw i32 %135, %332
  %339 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %338
  %340 = load i32, i32 addrspace(3)* %339, align 4, !tbaa !8
  %341 = icmp sgt i32 %337, %340
  %342 = select i1 %341, i32 %340, i32 %337
  %343 = xor i1 %341, true
  %344 = zext i1 %343 to i32
  %345 = add nuw nsw i32 %330, %344
  %346 = zext i1 %341 to i32
  %347 = add nuw nsw i32 %332, %346
  %348 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %334
  store i32 %342, i32 addrspace(3)* %348, align 4
  %349 = add nuw nsw i32 %227, 8
  %350 = icmp eq i32 %349, 256
  br i1 %350, label %381, label %226, !llvm.loop !15

351:                                              ; preds = %225
  br i1 %138, label %381, label %352

352:                                              ; preds = %684, %351
  %353 = phi i32 [ 0, %351 ], [ %687, %684 ]
  %354 = phi i32 [ 255, %351 ], [ %686, %684 ]
  %355 = phi i32 [ 255, %351 ], [ %685, %684 ]
  %356 = add nsw i32 %354, %13
  %357 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %356
  %358 = load i32, i32 addrspace(3)* %357, align 4, !tbaa !8
  %359 = add nsw i32 %134, %355
  %360 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %359
  %361 = load i32, i32 addrspace(3)* %360, align 4, !tbaa !8
  %362 = icmp sgt i32 %358, %361
  %363 = sub nuw nsw i32 255, %353
  %364 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %363
  br i1 %362, label %365, label %367

365:                                              ; preds = %352
  store i32 %358, i32 addrspace(3)* %364, align 4, !tbaa !8
  %366 = add nsw i32 %354, -1
  br label %369

367:                                              ; preds = %352
  store i32 %361, i32 addrspace(3)* %364, align 4, !tbaa !8
  %368 = add nsw i32 %355, -1
  br label %369

369:                                              ; preds = %367, %365
  %370 = phi i32 [ %355, %365 ], [ %368, %367 ]
  %371 = phi i32 [ %366, %365 ], [ %354, %367 ]
  %372 = add nsw i32 %371, %13
  %373 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %372
  %374 = load i32, i32 addrspace(3)* %373, align 4, !tbaa !8
  %375 = add nsw i32 %134, %370
  %376 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %375
  %377 = load i32, i32 addrspace(3)* %376, align 4, !tbaa !8
  %378 = icmp sgt i32 %374, %377
  %379 = sub nsw i32 254, %353
  %380 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %379
  br i1 %378, label %586, label %584

381:                                              ; preds = %684, %351, %226
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %136, label %382, label %465

382:                                              ; preds = %382, %381
  %383 = phi i32 [ 0, %381 ], [ %463, %382 ]
  %384 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %383
  %385 = load i32, i32 addrspace(3)* %384, align 16, !tbaa !8
  %386 = add nuw nsw i32 %383, %13
  %387 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %386
  store i32 %385, i32 addrspace(3)* %387, align 16, !tbaa !8
  %388 = or i32 %383, 1
  %389 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %388
  %390 = load i32, i32 addrspace(3)* %389, align 4, !tbaa !8
  %391 = add nuw nsw i32 %388, %13
  %392 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %391
  store i32 %390, i32 addrspace(3)* %392, align 4, !tbaa !8
  %393 = or i32 %383, 2
  %394 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %393
  %395 = load i32, i32 addrspace(3)* %394, align 8, !tbaa !8
  %396 = add nuw nsw i32 %393, %13
  %397 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %396
  store i32 %395, i32 addrspace(3)* %397, align 8, !tbaa !8
  %398 = or i32 %383, 3
  %399 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %398
  %400 = load i32, i32 addrspace(3)* %399, align 4, !tbaa !8
  %401 = add nuw nsw i32 %398, %13
  %402 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %401
  store i32 %400, i32 addrspace(3)* %402, align 4, !tbaa !8
  %403 = or i32 %383, 4
  %404 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %403
  %405 = load i32, i32 addrspace(3)* %404, align 16, !tbaa !8
  %406 = add nuw nsw i32 %403, %13
  %407 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %406
  store i32 %405, i32 addrspace(3)* %407, align 16, !tbaa !8
  %408 = or i32 %383, 5
  %409 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %408
  %410 = load i32, i32 addrspace(3)* %409, align 4, !tbaa !8
  %411 = add nuw nsw i32 %408, %13
  %412 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %411
  store i32 %410, i32 addrspace(3)* %412, align 4, !tbaa !8
  %413 = or i32 %383, 6
  %414 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %413
  %415 = load i32, i32 addrspace(3)* %414, align 8, !tbaa !8
  %416 = add nuw nsw i32 %413, %13
  %417 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %416
  store i32 %415, i32 addrspace(3)* %417, align 8, !tbaa !8
  %418 = or i32 %383, 7
  %419 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %418
  %420 = load i32, i32 addrspace(3)* %419, align 4, !tbaa !8
  %421 = add nuw nsw i32 %418, %13
  %422 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %421
  store i32 %420, i32 addrspace(3)* %422, align 4, !tbaa !8
  %423 = or i32 %383, 8
  %424 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %423
  %425 = load i32, i32 addrspace(3)* %424, align 16, !tbaa !8
  %426 = add nuw nsw i32 %423, %13
  %427 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %426
  store i32 %425, i32 addrspace(3)* %427, align 16, !tbaa !8
  %428 = or i32 %383, 9
  %429 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %428
  %430 = load i32, i32 addrspace(3)* %429, align 4, !tbaa !8
  %431 = add nuw nsw i32 %428, %13
  %432 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %431
  store i32 %430, i32 addrspace(3)* %432, align 4, !tbaa !8
  %433 = or i32 %383, 10
  %434 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %433
  %435 = load i32, i32 addrspace(3)* %434, align 8, !tbaa !8
  %436 = add nuw nsw i32 %433, %13
  %437 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %436
  store i32 %435, i32 addrspace(3)* %437, align 8, !tbaa !8
  %438 = or i32 %383, 11
  %439 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %438
  %440 = load i32, i32 addrspace(3)* %439, align 4, !tbaa !8
  %441 = add nuw nsw i32 %438, %13
  %442 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %441
  store i32 %440, i32 addrspace(3)* %442, align 4, !tbaa !8
  %443 = or i32 %383, 12
  %444 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %443
  %445 = load i32, i32 addrspace(3)* %444, align 16, !tbaa !8
  %446 = add nuw nsw i32 %443, %13
  %447 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %446
  store i32 %445, i32 addrspace(3)* %447, align 16, !tbaa !8
  %448 = or i32 %383, 13
  %449 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %448
  %450 = load i32, i32 addrspace(3)* %449, align 4, !tbaa !8
  %451 = add nuw nsw i32 %448, %13
  %452 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %451
  store i32 %450, i32 addrspace(3)* %452, align 4, !tbaa !8
  %453 = or i32 %383, 14
  %454 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %453
  %455 = load i32, i32 addrspace(3)* %454, align 8, !tbaa !8
  %456 = add nuw nsw i32 %453, %13
  %457 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %456
  store i32 %455, i32 addrspace(3)* %457, align 8, !tbaa !8
  %458 = or i32 %383, 15
  %459 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %458
  %460 = load i32, i32 addrspace(3)* %459, align 4, !tbaa !8
  %461 = add nuw nsw i32 %458, %13
  %462 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %461
  store i32 %460, i32 addrspace(3)* %462, align 4, !tbaa !8
  %463 = add nuw nsw i32 %383, 16
  %464 = icmp eq i32 %463, 256
  br i1 %464, label %465, label %382, !llvm.loop !16

465:                                              ; preds = %382, %381
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %466 = add nuw nsw i32 %141, 1
  %467 = icmp eq i32 %466, 16
  br i1 %467, label %139, label %unify.bb3, !llvm.loop !17

468:                                              ; preds = %468, %140
  %469 = phi i32 [ 0, %140 ], [ %581, %468 ]
  %470 = add nuw nsw i32 %469, %13
  %471 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %470
  %472 = load i32, i32 addrspace(3)* %471, align 16, !tbaa !8
  %473 = add nuw nsw i32 %469, %11
  %474 = sext i32 %473 to i64
  %475 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %474
  store i32 %472, i32 addrspace(1)* %475, align 4, !tbaa !8
  %476 = or i32 %469, 1
  %477 = add nuw nsw i32 %476, %13
  %478 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %477
  %479 = load i32, i32 addrspace(3)* %478, align 4, !tbaa !8
  %480 = add nuw nsw i32 %476, %11
  %481 = sext i32 %480 to i64
  %482 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %481
  store i32 %479, i32 addrspace(1)* %482, align 4, !tbaa !8
  %483 = or i32 %469, 2
  %484 = add nuw nsw i32 %483, %13
  %485 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %484
  %486 = load i32, i32 addrspace(3)* %485, align 8, !tbaa !8
  %487 = add nuw nsw i32 %483, %11
  %488 = sext i32 %487 to i64
  %489 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %488
  store i32 %486, i32 addrspace(1)* %489, align 4, !tbaa !8
  %490 = or i32 %469, 3
  %491 = add nuw nsw i32 %490, %13
  %492 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %491
  %493 = load i32, i32 addrspace(3)* %492, align 4, !tbaa !8
  %494 = add nuw nsw i32 %490, %11
  %495 = sext i32 %494 to i64
  %496 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %495
  store i32 %493, i32 addrspace(1)* %496, align 4, !tbaa !8
  %497 = or i32 %469, 4
  %498 = add nuw nsw i32 %497, %13
  %499 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %498
  %500 = load i32, i32 addrspace(3)* %499, align 16, !tbaa !8
  %501 = add nuw nsw i32 %497, %11
  %502 = sext i32 %501 to i64
  %503 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %502
  store i32 %500, i32 addrspace(1)* %503, align 4, !tbaa !8
  %504 = or i32 %469, 5
  %505 = add nuw nsw i32 %504, %13
  %506 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %505
  %507 = load i32, i32 addrspace(3)* %506, align 4, !tbaa !8
  %508 = add nuw nsw i32 %504, %11
  %509 = sext i32 %508 to i64
  %510 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %509
  store i32 %507, i32 addrspace(1)* %510, align 4, !tbaa !8
  %511 = or i32 %469, 6
  %512 = add nuw nsw i32 %511, %13
  %513 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %512
  %514 = load i32, i32 addrspace(3)* %513, align 8, !tbaa !8
  %515 = add nuw nsw i32 %511, %11
  %516 = sext i32 %515 to i64
  %517 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %516
  store i32 %514, i32 addrspace(1)* %517, align 4, !tbaa !8
  %518 = or i32 %469, 7
  %519 = add nuw nsw i32 %518, %13
  %520 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %519
  %521 = load i32, i32 addrspace(3)* %520, align 4, !tbaa !8
  %522 = add nuw nsw i32 %518, %11
  %523 = sext i32 %522 to i64
  %524 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %523
  store i32 %521, i32 addrspace(1)* %524, align 4, !tbaa !8
  %525 = or i32 %469, 8
  %526 = add nuw nsw i32 %525, %13
  %527 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %526
  %528 = load i32, i32 addrspace(3)* %527, align 16, !tbaa !8
  %529 = add nuw nsw i32 %525, %11
  %530 = sext i32 %529 to i64
  %531 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %530
  store i32 %528, i32 addrspace(1)* %531, align 4, !tbaa !8
  %532 = or i32 %469, 9
  %533 = add nuw nsw i32 %532, %13
  %534 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %533
  %535 = load i32, i32 addrspace(3)* %534, align 4, !tbaa !8
  %536 = add nuw nsw i32 %532, %11
  %537 = sext i32 %536 to i64
  %538 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %537
  store i32 %535, i32 addrspace(1)* %538, align 4, !tbaa !8
  %539 = or i32 %469, 10
  %540 = add nuw nsw i32 %539, %13
  %541 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %540
  %542 = load i32, i32 addrspace(3)* %541, align 8, !tbaa !8
  %543 = add nuw nsw i32 %539, %11
  %544 = sext i32 %543 to i64
  %545 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %544
  store i32 %542, i32 addrspace(1)* %545, align 4, !tbaa !8
  %546 = or i32 %469, 11
  %547 = add nuw nsw i32 %546, %13
  %548 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %547
  %549 = load i32, i32 addrspace(3)* %548, align 4, !tbaa !8
  %550 = add nuw nsw i32 %546, %11
  %551 = sext i32 %550 to i64
  %552 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %551
  store i32 %549, i32 addrspace(1)* %552, align 4, !tbaa !8
  %553 = or i32 %469, 12
  %554 = add nuw nsw i32 %553, %13
  %555 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %554
  %556 = load i32, i32 addrspace(3)* %555, align 16, !tbaa !8
  %557 = add nuw nsw i32 %553, %11
  %558 = sext i32 %557 to i64
  %559 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %558
  store i32 %556, i32 addrspace(1)* %559, align 4, !tbaa !8
  %560 = or i32 %469, 13
  %561 = add nuw nsw i32 %560, %13
  %562 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %561
  %563 = load i32, i32 addrspace(3)* %562, align 4, !tbaa !8
  %564 = add nuw nsw i32 %560, %11
  %565 = sext i32 %564 to i64
  %566 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %565
  store i32 %563, i32 addrspace(1)* %566, align 4, !tbaa !8
  %567 = or i32 %469, 14
  %568 = add nuw nsw i32 %567, %13
  %569 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %568
  %570 = load i32, i32 addrspace(3)* %569, align 8, !tbaa !8
  %571 = add nuw nsw i32 %567, %11
  %572 = sext i32 %571 to i64
  %573 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %572
  store i32 %570, i32 addrspace(1)* %573, align 4, !tbaa !8
  %574 = or i32 %469, 15
  %575 = add nuw nsw i32 %574, %13
  %576 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %575
  %577 = load i32, i32 addrspace(3)* %576, align 4, !tbaa !8
  %578 = add nuw nsw i32 %574, %11
  %579 = sext i32 %578 to i64
  %580 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %579
  store i32 %577, i32 addrspace(1)* %580, align 4, !tbaa !8
  %581 = add nuw nsw i32 %469, 16
  %582 = icmp eq i32 %581, 256
  br i1 %582, label %583, label %468, !llvm.loop !18

583:                                              ; preds = %468, %139
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  ret void

584:                                              ; preds = %369
  store i32 %377, i32 addrspace(3)* %380, align 8, !tbaa !8
  %585 = add nsw i32 %370, -1
  br label %588

586:                                              ; preds = %369
  store i32 %374, i32 addrspace(3)* %380, align 8, !tbaa !8
  %587 = add nsw i32 %371, -1
  br label %588

588:                                              ; preds = %586, %584
  %589 = phi i32 [ %585, %584 ], [ %370, %586 ]
  %590 = phi i32 [ %371, %584 ], [ %587, %586 ]
  %591 = add nsw i32 %590, %13
  %592 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %591
  %593 = load i32, i32 addrspace(3)* %592, align 4, !tbaa !8
  %594 = add nsw i32 %134, %589
  %595 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %594
  %596 = load i32, i32 addrspace(3)* %595, align 4, !tbaa !8
  %597 = icmp sgt i32 %593, %596
  %598 = sub nsw i32 253, %353
  %599 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %598
  br i1 %597, label %602, label %600

600:                                              ; preds = %588
  store i32 %596, i32 addrspace(3)* %599, align 4, !tbaa !8
  %601 = add nsw i32 %589, -1
  br label %604

602:                                              ; preds = %588
  store i32 %593, i32 addrspace(3)* %599, align 4, !tbaa !8
  %603 = add nsw i32 %590, -1
  br label %604

604:                                              ; preds = %602, %600
  %605 = phi i32 [ %601, %600 ], [ %589, %602 ]
  %606 = phi i32 [ %590, %600 ], [ %603, %602 ]
  %607 = add nsw i32 %606, %13
  %608 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %607
  %609 = load i32, i32 addrspace(3)* %608, align 4, !tbaa !8
  %610 = add nsw i32 %134, %605
  %611 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %610
  %612 = load i32, i32 addrspace(3)* %611, align 4, !tbaa !8
  %613 = icmp sgt i32 %609, %612
  %614 = sub nsw i32 252, %353
  %615 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %614
  br i1 %613, label %618, label %616

616:                                              ; preds = %604
  store i32 %612, i32 addrspace(3)* %615, align 16, !tbaa !8
  %617 = add nsw i32 %605, -1
  br label %620

618:                                              ; preds = %604
  store i32 %609, i32 addrspace(3)* %615, align 16, !tbaa !8
  %619 = add nsw i32 %606, -1
  br label %620

620:                                              ; preds = %618, %616
  %621 = phi i32 [ %617, %616 ], [ %605, %618 ]
  %622 = phi i32 [ %606, %616 ], [ %619, %618 ]
  %623 = add nsw i32 %622, %13
  %624 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %623
  %625 = load i32, i32 addrspace(3)* %624, align 4, !tbaa !8
  %626 = add nsw i32 %134, %621
  %627 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %626
  %628 = load i32, i32 addrspace(3)* %627, align 4, !tbaa !8
  %629 = icmp sgt i32 %625, %628
  %630 = sub nsw i32 251, %353
  %631 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %630
  br i1 %629, label %634, label %632

632:                                              ; preds = %620
  store i32 %628, i32 addrspace(3)* %631, align 4, !tbaa !8
  %633 = add nsw i32 %621, -1
  br label %636

634:                                              ; preds = %620
  store i32 %625, i32 addrspace(3)* %631, align 4, !tbaa !8
  %635 = add nsw i32 %622, -1
  br label %636

636:                                              ; preds = %634, %632
  %637 = phi i32 [ %633, %632 ], [ %621, %634 ]
  %638 = phi i32 [ %622, %632 ], [ %635, %634 ]
  %639 = add nsw i32 %638, %13
  %640 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %639
  %641 = load i32, i32 addrspace(3)* %640, align 4, !tbaa !8
  %642 = add nsw i32 %134, %637
  %643 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %642
  %644 = load i32, i32 addrspace(3)* %643, align 4, !tbaa !8
  %645 = icmp sgt i32 %641, %644
  %646 = sub nsw i32 250, %353
  %647 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %646
  br i1 %645, label %650, label %648

648:                                              ; preds = %636
  store i32 %644, i32 addrspace(3)* %647, align 8, !tbaa !8
  %649 = add nsw i32 %637, -1
  br label %652

650:                                              ; preds = %636
  store i32 %641, i32 addrspace(3)* %647, align 8, !tbaa !8
  %651 = add nsw i32 %638, -1
  br label %652

652:                                              ; preds = %650, %648
  %653 = phi i32 [ %649, %648 ], [ %637, %650 ]
  %654 = phi i32 [ %638, %648 ], [ %651, %650 ]
  %655 = add nsw i32 %654, %13
  %656 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %655
  %657 = load i32, i32 addrspace(3)* %656, align 4, !tbaa !8
  %658 = add nsw i32 %134, %653
  %659 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %658
  %660 = load i32, i32 addrspace(3)* %659, align 4, !tbaa !8
  %661 = icmp sgt i32 %657, %660
  %662 = sub nsw i32 249, %353
  %663 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %662
  br i1 %661, label %666, label %664

664:                                              ; preds = %652
  store i32 %660, i32 addrspace(3)* %663, align 4, !tbaa !8
  %665 = add nsw i32 %653, -1
  br label %668

666:                                              ; preds = %652
  store i32 %657, i32 addrspace(3)* %663, align 4, !tbaa !8
  %667 = add nsw i32 %654, -1
  br label %668

668:                                              ; preds = %666, %664
  %669 = phi i32 [ %665, %664 ], [ %653, %666 ]
  %670 = phi i32 [ %654, %664 ], [ %667, %666 ]
  %671 = add nsw i32 %670, %13
  %672 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %671
  %673 = load i32, i32 addrspace(3)* %672, align 4, !tbaa !8
  %674 = add nsw i32 %134, %669
  %675 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %674
  %676 = load i32, i32 addrspace(3)* %675, align 4, !tbaa !8
  %677 = icmp sgt i32 %673, %676
  %678 = sub nsw i32 248, %353
  %679 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %678
  br i1 %677, label %682, label %680

680:                                              ; preds = %668
  store i32 %676, i32 addrspace(3)* %679, align 16, !tbaa !8
  %681 = add nsw i32 %669, -1
  br label %684

682:                                              ; preds = %668
  store i32 %673, i32 addrspace(3)* %679, align 16, !tbaa !8
  %683 = add nsw i32 %670, -1
  br label %684

684:                                              ; preds = %682, %680
  %685 = phi i32 [ %681, %680 ], [ %669, %682 ]
  %686 = phi i32 [ %670, %680 ], [ %683, %682 ]
  %687 = add nuw nsw i32 %353, 8
  %688 = icmp eq i32 %687, 256
  br i1 %688, label %381, label %352, !llvm.loop !19

merged.bb:                                        ; preds = %predication.tail171, %unify.bb3
  %689 = phi i32 [ 0, %unify.bb3 ], [ %878, %predication.tail171 ]
  %690 = phi i32 [ 0, %unify.bb3 ], [ %guard.value166, %predication.tail171 ]
  %691 = phi i32 [ 0, %unify.bb3 ], [ %guard.value165, %predication.tail171 ]
  %692 = phi i32 [ 255, %unify.bb3 ], [ %877, %predication.tail171 ]
  %693 = phi i32 [ 255, %unify.bb3 ], [ %876, %predication.tail171 ]
  %merged.select10 = select i1 %133, i32 %691, i32 %692
  %694 = add nsw i32 %merged.select10, %13
  %695 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %694
  %696 = load i32, i32 addrspace(3)* %695, align 4, !tbaa !8
  %merged.select11 = select i1 %133, i32 %135, i32 %134
  %merged.select14 = select i1 %133, i32 %690, i32 %693
  %697 = add nsw i32 %merged.select11, %merged.select14
  %698 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %697
  %699 = load i32, i32 addrspace(3)* %698, align 4, !tbaa !8
  %700 = icmp sgt i32 %696, %699
  br i1 %133, label %predication.first, label %predication.second

predication.first:                                ; preds = %merged.bb
  %701 = select i1 %700, i32 %699, i32 %696
  %702 = xor i1 %700, true
  %703 = zext i1 %702 to i32
  %704 = add nuw nsw i32 %691, %703
  %705 = zext i1 %700 to i32
  %706 = add nuw nsw i32 %690, %705
  br label %predication.join

predication.second:                               ; preds = %merged.bb
  %707 = sub nuw nsw i32 255, %689
  br label %predication.join

predication.join:                                 ; preds = %predication.second, %predication.first
  %merged.select15 = phi i32 [ %689, %predication.first ], [ %707, %predication.second ]
  %guard.value = phi i32 [ %701, %predication.first ], [ undef, %predication.second ]
  %guard.value63 = phi i32 [ %704, %predication.first ], [ undef, %predication.second ]
  %guard.value64 = phi i32 [ %706, %predication.first ], [ undef, %predication.second ]
  %708 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %merged.select15
  br i1 %133, label %predication.split, label %predication.tail

predication.split:                                ; preds = %predication.join
  store i32 %guard.value, i32 addrspace(3)* %708, align 16
  %709 = or i32 %689, 1
  %710 = add nsw i32 %guard.value63, %13
  %711 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %710
  %712 = load i32, i32 addrspace(3)* %711, align 4, !tbaa !8
  %713 = add nsw i32 %135, %guard.value64
  %714 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %713
  %715 = load i32, i32 addrspace(3)* %714, align 4, !tbaa !8
  %716 = icmp sgt i32 %712, %715
  br label %predication.tail

predication.tail:                                 ; preds = %predication.split, %predication.join
  %merged.select20 = phi i32 [ %699, %predication.join ], [ %712, %predication.split ]
  %merged.select19 = phi i32 [ %696, %predication.join ], [ %715, %predication.split ]
  %merged.select16 = phi i1 [ %700, %predication.join ], [ %716, %predication.split ]
  %717 = phi i32 [ undef, %predication.join ], [ %709, %predication.split ]
  %718 = phi i1 [ undef, %predication.join ], [ %716, %predication.split ]
  %719 = select i1 %merged.select16, i32 %merged.select19, i32 %merged.select20
  %720 = xor i1 %718, true
  %721 = zext i1 %720 to i32
  %722 = add nuw nsw i32 %guard.value63, %721
  %723 = zext i1 %718 to i32
  %724 = add nuw nsw i32 %guard.value64, %723
  %725 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %717
  %merged.select21 = select i1 %133, i32 addrspace(3)* %725, i32 addrspace(3)* %708
  store i32 %719, i32 addrspace(3)* %merged.select21, align 4
  %726 = select i1 %700, i32 %692, i32 %693
  %727 = add nsw i32 %726, -1
  %728 = select i1 %700, i32 %693, i32 %727
  %guard.value71 = select i1 %133, i32 undef, i32 %727
  %guard.value72 = select i1 %133, i32 undef, i32 %728
  %729 = select i1 %700, i32 %guard.value71, i32 %692
  %730 = select i1 %133, i32 undef, i32 %729
  %merged.select24 = select i1 %133, i32 %722, i32 %729
  %731 = add nsw i32 %merged.select24, %13
  %732 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %731
  %733 = load i32, i32 addrspace(3)* %732, align 4, !tbaa !8
  %merged.select26 = select i1 %133, i32 %724, i32 %728
  %734 = add nsw i32 %merged.select11, %merged.select26
  %735 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %734
  %736 = load i32, i32 addrspace(3)* %735, align 4, !tbaa !8
  %737 = icmp sgt i32 %733, %736
  br i1 %133, label %predication.first76, label %predication.second77

predication.first76:                              ; preds = %predication.tail
  %738 = or i32 %689, 2
  %739 = select i1 %737, i32 %736, i32 %733
  %740 = xor i1 %737, true
  %741 = zext i1 %740 to i32
  %742 = add nuw nsw i32 %722, %741
  %743 = zext i1 %737 to i32
  %744 = add nuw nsw i32 %724, %743
  br label %predication.join78

predication.second77:                             ; preds = %predication.tail
  %745 = sub nsw i32 254, %689
  br label %predication.join78

predication.join78:                               ; preds = %predication.second77, %predication.first76
  %merged.select29 = phi i32 [ %738, %predication.first76 ], [ %745, %predication.second77 ]
  %guard.value79 = phi i32 [ %739, %predication.first76 ], [ undef, %predication.second77 ]
  %guard.value80 = phi i32 [ %742, %predication.first76 ], [ undef, %predication.second77 ]
  %guard.value81 = phi i32 [ %744, %predication.first76 ], [ undef, %predication.second77 ]
  %746 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %merged.select29
  %747 = select i1 %737, i32 %733, i32 %736
  %merged.select30 = select i1 %133, i32 %guard.value79, i32 %747
  store i32 %merged.select30, i32 addrspace(3)* %746, align 8
  %748 = select i1 %737, i32 %730, i32 %guard.value72
  %749 = add nsw i32 %748, -1
  %750 = select i1 %737, i32 %guard.value72, i32 %749
  %guard.value88 = select i1 %133, i32 undef, i32 %749
  %guard.value89 = select i1 %133, i32 undef, i32 %750
  %751 = select i1 %737, i32 %guard.value88, i32 %730
  %752 = select i1 %133, i32 undef, i32 %751
  %merged.select31 = select i1 %133, i32 %guard.value80, i32 %751
  %753 = add nsw i32 %merged.select31, %13
  %754 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %753
  %755 = load i32, i32 addrspace(3)* %754, align 4, !tbaa !8
  %merged.select35 = select i1 %133, i32 %guard.value81, i32 %750
  %756 = add nsw i32 %merged.select11, %merged.select35
  %757 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %756
  %758 = load i32, i32 addrspace(3)* %757, align 4, !tbaa !8
  %759 = icmp sgt i32 %755, %758
  br i1 %133, label %predication.first93, label %predication.second94

predication.first93:                              ; preds = %predication.join78
  %760 = or i32 %689, 3
  %761 = select i1 %759, i32 %758, i32 %755
  %762 = xor i1 %759, true
  %763 = zext i1 %762 to i32
  %764 = add nuw nsw i32 %guard.value80, %763
  %765 = zext i1 %759 to i32
  %766 = add nuw nsw i32 %guard.value81, %765
  br label %predication.join95

predication.second94:                             ; preds = %predication.join78
  %767 = sub nsw i32 253, %689
  br label %predication.join95

predication.join95:                               ; preds = %predication.second94, %predication.first93
  %merged.select36 = phi i32 [ %760, %predication.first93 ], [ %767, %predication.second94 ]
  %guard.value96 = phi i32 [ %761, %predication.first93 ], [ undef, %predication.second94 ]
  %guard.value97 = phi i32 [ %764, %predication.first93 ], [ undef, %predication.second94 ]
  %guard.value98 = phi i32 [ %766, %predication.first93 ], [ undef, %predication.second94 ]
  %768 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %merged.select36
  %769 = select i1 %759, i32 %755, i32 %758
  %merged.select39 = select i1 %133, i32 %guard.value96, i32 %769
  store i32 %merged.select39, i32 addrspace(3)* %768, align 4
  %770 = select i1 %759, i32 %752, i32 %guard.value89
  %771 = add nsw i32 %770, -1
  %772 = select i1 %759, i32 %guard.value89, i32 %771
  %guard.value105 = select i1 %133, i32 undef, i32 %771
  %guard.value106 = select i1 %133, i32 undef, i32 %772
  %773 = select i1 %759, i32 %guard.value105, i32 %752
  %774 = select i1 %133, i32 undef, i32 %773
  %merged.select40 = select i1 %133, i32 %guard.value97, i32 %773
  %775 = add nsw i32 %merged.select40, %13
  %776 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %775
  %777 = load i32, i32 addrspace(3)* %776, align 4, !tbaa !8
  %merged.select42 = select i1 %133, i32 %guard.value98, i32 %772
  %778 = add nsw i32 %merged.select11, %merged.select42
  %779 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %778
  %780 = load i32, i32 addrspace(3)* %779, align 4, !tbaa !8
  %781 = icmp sgt i32 %777, %780
  br i1 %133, label %predication.first110, label %predication.second111

predication.first110:                             ; preds = %predication.join95
  %782 = or i32 %689, 4
  %783 = select i1 %781, i32 %780, i32 %777
  %784 = xor i1 %781, true
  %785 = zext i1 %784 to i32
  %786 = add nuw nsw i32 %guard.value97, %785
  %787 = zext i1 %781 to i32
  %788 = add nuw nsw i32 %guard.value98, %787
  br label %predication.join112

predication.second111:                            ; preds = %predication.join95
  %789 = sub nsw i32 252, %689
  br label %predication.join112

predication.join112:                              ; preds = %predication.second111, %predication.first110
  %merged.select43 = phi i32 [ %782, %predication.first110 ], [ %789, %predication.second111 ]
  %guard.value113 = phi i32 [ %783, %predication.first110 ], [ undef, %predication.second111 ]
  %guard.value114 = phi i32 [ %786, %predication.first110 ], [ undef, %predication.second111 ]
  %guard.value115 = phi i32 [ %788, %predication.first110 ], [ undef, %predication.second111 ]
  %790 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %merged.select43
  %791 = select i1 %781, i32 %777, i32 %780
  %merged.select44 = select i1 %133, i32 %guard.value113, i32 %791
  store i32 %merged.select44, i32 addrspace(3)* %790, align 16
  %792 = select i1 %781, i32 %774, i32 %guard.value106
  %793 = add nsw i32 %792, -1
  %794 = select i1 %781, i32 %guard.value106, i32 %793
  %guard.value122 = select i1 %133, i32 undef, i32 %793
  %guard.value123 = select i1 %133, i32 undef, i32 %794
  %795 = select i1 %781, i32 %guard.value122, i32 %774
  %796 = select i1 %133, i32 undef, i32 %795
  %merged.select45 = select i1 %133, i32 %guard.value114, i32 %795
  %797 = add nsw i32 %merged.select45, %13
  %798 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %797
  %799 = load i32, i32 addrspace(3)* %798, align 4, !tbaa !8
  %merged.select47 = select i1 %133, i32 %guard.value115, i32 %794
  %800 = add nsw i32 %merged.select11, %merged.select47
  %801 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %800
  %802 = load i32, i32 addrspace(3)* %801, align 4, !tbaa !8
  %803 = icmp sgt i32 %799, %802
  br i1 %133, label %predication.first127, label %predication.second128

predication.first127:                             ; preds = %predication.join112
  %804 = or i32 %689, 5
  %805 = select i1 %803, i32 %802, i32 %799
  %806 = xor i1 %803, true
  %807 = zext i1 %806 to i32
  %808 = add nuw nsw i32 %guard.value114, %807
  %809 = zext i1 %803 to i32
  %810 = add nuw nsw i32 %guard.value115, %809
  br label %predication.join129

predication.second128:                            ; preds = %predication.join112
  %811 = sub nsw i32 251, %689
  br label %predication.join129

predication.join129:                              ; preds = %predication.second128, %predication.first127
  %merged.select48 = phi i32 [ %804, %predication.first127 ], [ %811, %predication.second128 ]
  %guard.value130 = phi i32 [ %805, %predication.first127 ], [ undef, %predication.second128 ]
  %guard.value131 = phi i32 [ %808, %predication.first127 ], [ undef, %predication.second128 ]
  %guard.value132 = phi i32 [ %810, %predication.first127 ], [ undef, %predication.second128 ]
  %812 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %merged.select48
  %813 = select i1 %803, i32 %799, i32 %802
  %merged.select49 = select i1 %133, i32 %guard.value130, i32 %813
  store i32 %merged.select49, i32 addrspace(3)* %812, align 4
  %814 = select i1 %803, i32 %796, i32 %guard.value123
  %815 = add nsw i32 %814, -1
  %816 = select i1 %803, i32 %guard.value123, i32 %815
  %guard.value139 = select i1 %133, i32 undef, i32 %815
  %guard.value140 = select i1 %133, i32 undef, i32 %816
  %817 = select i1 %803, i32 %guard.value139, i32 %796
  %818 = select i1 %133, i32 undef, i32 %817
  %merged.select50 = select i1 %133, i32 %guard.value131, i32 %817
  %819 = add nsw i32 %merged.select50, %13
  %820 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %819
  %821 = load i32, i32 addrspace(3)* %820, align 4, !tbaa !8
  %merged.select52 = select i1 %133, i32 %guard.value132, i32 %816
  %822 = add nsw i32 %merged.select11, %merged.select52
  %823 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %822
  %824 = load i32, i32 addrspace(3)* %823, align 4, !tbaa !8
  %825 = icmp sgt i32 %821, %824
  br i1 %133, label %predication.first144, label %predication.second145

predication.first144:                             ; preds = %predication.join129
  %826 = or i32 %689, 6
  %827 = select i1 %825, i32 %824, i32 %821
  %828 = xor i1 %825, true
  %829 = zext i1 %828 to i32
  %830 = add nuw nsw i32 %guard.value131, %829
  %831 = zext i1 %825 to i32
  %832 = add nuw nsw i32 %guard.value132, %831
  br label %predication.join146

predication.second145:                            ; preds = %predication.join129
  %833 = sub nsw i32 250, %689
  br label %predication.join146

predication.join146:                              ; preds = %predication.second145, %predication.first144
  %merged.select53 = phi i32 [ %826, %predication.first144 ], [ %833, %predication.second145 ]
  %guard.value147 = phi i32 [ %827, %predication.first144 ], [ undef, %predication.second145 ]
  %guard.value148 = phi i32 [ %830, %predication.first144 ], [ undef, %predication.second145 ]
  %guard.value149 = phi i32 [ %832, %predication.first144 ], [ undef, %predication.second145 ]
  %834 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %merged.select53
  %835 = select i1 %825, i32 %821, i32 %824
  %merged.select54 = select i1 %133, i32 %guard.value147, i32 %835
  store i32 %merged.select54, i32 addrspace(3)* %834, align 8
  %836 = select i1 %825, i32 %818, i32 %guard.value140
  %837 = add nsw i32 %836, -1
  %838 = select i1 %825, i32 %guard.value140, i32 %837
  %guard.value156 = select i1 %133, i32 undef, i32 %837
  %guard.value157 = select i1 %133, i32 undef, i32 %838
  %839 = select i1 %825, i32 %guard.value156, i32 %818
  %840 = select i1 %133, i32 undef, i32 %839
  %merged.select55 = select i1 %133, i32 %guard.value148, i32 %839
  %841 = add nsw i32 %merged.select55, %13
  %842 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %841
  %843 = load i32, i32 addrspace(3)* %842, align 4, !tbaa !8
  %merged.select57 = select i1 %133, i32 %guard.value149, i32 %838
  %844 = add nsw i32 %merged.select11, %merged.select57
  %845 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %844
  %846 = load i32, i32 addrspace(3)* %845, align 4, !tbaa !8
  %847 = icmp sgt i32 %843, %846
  br i1 %133, label %predication.first161, label %predication.second162

predication.first161:                             ; preds = %predication.join146
  %848 = or i32 %689, 7
  %849 = select i1 %847, i32 %846, i32 %843
  %850 = xor i1 %847, true
  %851 = zext i1 %850 to i32
  %852 = add nuw nsw i32 %guard.value148, %851
  %853 = zext i1 %847 to i32
  %854 = add nuw nsw i32 %guard.value149, %853
  br label %predication.join163

predication.second162:                            ; preds = %predication.join146
  %855 = sub nsw i32 249, %689
  br label %predication.join163

predication.join163:                              ; preds = %predication.second162, %predication.first161
  %merged.select58 = phi i32 [ %848, %predication.first161 ], [ %855, %predication.second162 ]
  %guard.value164 = phi i32 [ %849, %predication.first161 ], [ undef, %predication.second162 ]
  %guard.value165 = phi i32 [ %852, %predication.first161 ], [ undef, %predication.second162 ]
  %guard.value166 = phi i32 [ %854, %predication.first161 ], [ undef, %predication.second162 ]
  %856 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %merged.select58
  %857 = select i1 %847, i32 %843, i32 %846
  %merged.select59 = select i1 %133, i32 %guard.value164, i32 %857
  store i32 %merged.select59, i32 addrspace(3)* %856, align 4
  br i1 %133, label %predication.tail171, label %predication.split170

predication.split170:                             ; preds = %predication.join163
  %858 = select i1 %847, i32 %840, i32 %guard.value157
  %859 = add nsw i32 %858, -1
  %860 = select i1 %847, i32 %guard.value157, i32 %859
  %861 = select i1 %847, i32 %859, i32 %840
  %862 = add nsw i32 %861, %13
  %863 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %862
  %864 = load i32, i32 addrspace(3)* %863, align 4, !tbaa !8
  %865 = add nsw i32 %134, %860
  %866 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* @_ZZ3pcmPiE2sC, i32 0, i32 %865
  %867 = load i32, i32 addrspace(3)* %866, align 4, !tbaa !8
  %868 = icmp sgt i32 %864, %867
  %869 = sub nsw i32 248, %689
  %870 = getelementptr inbounds i32, i32 addrspace(3)* %128, i32 %869
  %871 = select i1 %868, i32 %864, i32 %867
  store i32 %871, i32 addrspace(3)* %870, align 16, !tbaa !8
  %872 = select i1 %868, i32 %861, i32 %860
  %873 = add nsw i32 %872, -1
  %874 = select i1 %868, i32 %860, i32 %873
  %875 = select i1 %868, i32 %873, i32 %861
  br label %predication.tail171

predication.tail171:                              ; preds = %predication.split170, %predication.join163
  %876 = phi i32 [ undef, %predication.join163 ], [ %874, %predication.split170 ]
  %877 = phi i32 [ undef, %predication.join163 ], [ %875, %predication.split170 ]
  %878 = add nuw nsw i32 %689, 8
  %879 = icmp eq i32 %878, 256
  br i1 %879, label %merged.bb9, label %merged.bb, !llvm.loop !20

merged.bb9:                                       ; preds = %predication.tail171
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %136, label %142, label %225
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
