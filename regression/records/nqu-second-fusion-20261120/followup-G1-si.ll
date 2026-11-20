*** IR Dump After SI annotate control flow ***
; Function Attrs: convergent norecurse nounwind
define protected amdgpu_kernel void @_Z24solve_nqueen_cuda_kerneliiPjS_S_S_i(i32 %0, i32 %1, i32 addrspace(1)* nocapture readonly %2, i32 addrspace(1)* nocapture readonly %3, i32 addrspace(1)* nocapture readonly %4, i32 addrspace(1)* nocapture %5, i32 %6) local_unnamed_addr #0 {
  %_Z24solve_nqueen_cuda_kerneliiPjS_S_S_i.kernarg.segment = call nonnull align 16 dereferenceable(104) i8 addrspace(4)* @llvm.amdgcn.kernarg.segment.ptr()
  %.kernarg.offset1 = getelementptr inbounds i8, i8 addrspace(4)* %_Z24solve_nqueen_cuda_kerneliiPjS_S_S_i.kernarg.segment, i64 4
  %.kernarg.offset1.cast = bitcast i8 addrspace(4)* %.kernarg.offset1 to i32 addrspace(4)*
  %.kernarg.offset3 = getelementptr inbounds i8, i8 addrspace(4)* %_Z24solve_nqueen_cuda_kerneliiPjS_S_S_i.kernarg.segment, i64 8
  %.kernarg.offset3.cast = bitcast i8 addrspace(4)* %.kernarg.offset3 to i32 addrspace(1)* addrspace(4)*
  %8 = bitcast i32 addrspace(1)* addrspace(4)* %.kernarg.offset3.cast to <4 x i64> addrspace(4)*, !amdgpu.uniform !5
  %9 = load <4 x i64>, <4 x i64> addrspace(4)* %8, align 8, !invariant.load !5
  %.kernarg.offset5 = getelementptr inbounds i8, i8 addrspace(4)* %_Z24solve_nqueen_cuda_kerneliiPjS_S_S_i.kernarg.segment, i64 16
  %.kernarg.offset5.cast = bitcast i8 addrspace(4)* %.kernarg.offset5 to i32 addrspace(1)* addrspace(4)*
  %.kernarg.offset7 = getelementptr inbounds i8, i8 addrspace(4)* %_Z24solve_nqueen_cuda_kerneliiPjS_S_S_i.kernarg.segment, i64 24
  %.kernarg.offset7.cast = bitcast i8 addrspace(4)* %.kernarg.offset7 to i32 addrspace(1)* addrspace(4)*
  %.kernarg.offset9 = getelementptr inbounds i8, i8 addrspace(4)* %_Z24solve_nqueen_cuda_kerneliiPjS_S_S_i.kernarg.segment, i64 32
  %.kernarg.offset9.cast = bitcast i8 addrspace(4)* %.kernarg.offset9 to i32 addrspace(1)* addrspace(4)*
  %.kernarg.offset11 = getelementptr inbounds i8, i8 addrspace(4)* %_Z24solve_nqueen_cuda_kerneliiPjS_S_S_i.kernarg.segment, i64 40
  %.kernarg.offset11.cast = bitcast i8 addrspace(4)* %.kernarg.offset11 to i32 addrspace(4)*, !amdgpu.uniform !5
  %.load12 = load i32, i32 addrspace(4)* %.kernarg.offset11.cast, align 8, !invariant.load !5
  %10 = tail call i32 @llvm.amdgcn.workitem.id.x() #6, !range !6
  %11 = tail call i32 @llvm.amdgcn.workgroup.id.x() #6
  %12 = tail call align 4 dereferenceable(64) i8 addrspace(4)* @llvm.amdgcn.dispatch.ptr() #6
  %13 = getelementptr i8, i8 addrspace(4)* %12, i64 4
  %14 = bitcast i8 addrspace(4)* %13 to i16 addrspace(4)*, !amdgpu.uniform !5
  %15 = load i16, i16 addrspace(4)* %14, align 4, !range !7, !invariant.load !5
  %16 = zext i16 %15 to i32
  %17 = mul i32 %11, %16
  %18 = add i32 %17, %10
  %19 = icmp slt i32 %18, %.load12
  %20 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %19)
  %21 = extractvalue { i1, i64 } %20, 0
  %22 = extractvalue { i1, i64 } %20, 1
  br i1 %21, label %23, label %Flow26

23:                                               ; preds = %7
  %.kernarg.offset13 = bitcast i8 addrspace(4)* %_Z24solve_nqueen_cuda_kerneliiPjS_S_S_i.kernarg.segment to i8 addrspace(4)*
  %.kernarg.offset.cast = bitcast i8 addrspace(4)* %.kernarg.offset13 to i32 addrspace(4)*
  %24 = bitcast i32 addrspace(4)* %.kernarg.offset.cast to <2 x i32> addrspace(4)*, !amdgpu.uniform !5
  %25 = load <2 x i32>, <2 x i32> addrspace(4)* %24, align 16, !invariant.load !5
  %.load18 = extractelement <2 x i32> %25, i32 0
  %.load219 = extractelement <2 x i32> %25, i32 1
  %.load420 = extractelement <4 x i64> %9, i32 0
  %26 = inttoptr i64 %.load420 to i32 addrspace(1)*
  %.load621 = extractelement <4 x i64> %9, i32 1
  %27 = inttoptr i64 %.load621 to i32 addrspace(1)*
  %.load822 = extractelement <4 x i64> %9, i32 2
  %28 = inttoptr i64 %.load822 to i32 addrspace(1)*
  %29 = shl nsw i32 -1, %.load18
  %30 = xor i32 %29, -1
  %31 = sext i32 %18 to i64
  %32 = getelementptr inbounds i32, i32 addrspace(1)* %26, i64 %31
  %33 = load i32, i32 addrspace(1)* %32, align 4, !tbaa !8
  %34 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE4mask, i32 0, i32 %10, i32 0
  store i32 %33, i32 addrspace(3)* %34, align 8, !tbaa !8
  %35 = getelementptr inbounds i32, i32 addrspace(1)* %27, i64 %31
  %36 = load i32, i32 addrspace(1)* %35, align 4, !tbaa !8
  %37 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6l_mask, i32 0, i32 %10, i32 0
  store i32 %36, i32 addrspace(3)* %37, align 8, !tbaa !8
  %38 = getelementptr inbounds i32, i32 addrspace(1)* %28, i64 %31
  %39 = load i32, i32 addrspace(1)* %38, align 4, !tbaa !8
  %40 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6r_mask, i32 0, i32 %10, i32 0
  store i32 %39, i32 addrspace(3)* %40, align 8, !tbaa !8
  %41 = or i32 %36, %33
  %42 = or i32 %41, %39
  %43 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %10, i32 0
  store i32 %42, i32 addrspace(3)* %43, align 8, !tbaa !8
  br label %unify.bb, !amdgpu.uniform !5

Flow26:                                           ; preds = %Flow25, %7
  %44 = phi i32 [ %69, %Flow25 ], [ 0, %7 ]
  call void @llvm.amdgcn.end.cf.i64(i64 %22)
  br label %.loopexit, !amdgpu.uniform !5

unify.bb:                                         ; preds = %23, %Flow24
  %phi.broken = phi i64 [ 0, %23 ], [ %70, %Flow24 ]
  %45 = phi i32 [ %67, %Flow24 ], [ %42, %23 ]
  %46 = phi i32 [ %69, %Flow24 ], [ 0, %23 ]
  %47 = phi i32 [ %158, %Flow24 ], [ 0, %23 ]
  %48 = and i32 %45, %30
  %49 = icmp eq i32 %48, %30
  %50 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %10, i32 %47
  %51 = add i32 %45, 1
  %52 = xor i32 %45, -1
  %53 = and i32 %51, %52
  %54 = or i32 %51, %45
  store i32 %54, i32 addrspace(3)* %50, align 4, !tbaa !8
  %55 = and i32 %53, %30
  %56 = icmp ne i32 %55, 0
  %57 = or i1 %49, %56
  %decision.left = xor i1 %57, true
  %58 = add nuw nsw i32 %47, 1
  %59 = icmp eq i32 %58, %.load219
  %60 = or i1 %49, %59
  %decision.take = or i1 %60, %decision.left
  %decision.take.inv = xor i1 %decision.take, true
  %61 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %decision.take.inv)
  %62 = extractvalue { i1, i64 } %61, 0
  %63 = extractvalue { i1, i64 } %61, 1
  br i1 %62, label %merged.bb16, label %Flow

64:                                               ; preds = %merged.bb15
  %65 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %10, i32 %158
  %66 = load i32, i32 addrspace(3)* %65, align 4, !tbaa !8
  br label %Flow24, !amdgpu.uniform !5

Flow24:                                           ; preds = %64, %merged.bb15
  %67 = phi i32 [ %66, %64 ], [ undef, %merged.bb15 ]
  %68 = phi i1 [ false, %64 ], [ true, %merged.bb15 ]
  call void @llvm.amdgcn.end.cf.i64(i64 %162)
  %69 = select i1 %49, i32 %46, i32 %156
  %70 = call i64 @llvm.amdgcn.if.break.i64(i1 %68, i64 %phi.broken)
  %71 = call i1 @llvm.amdgcn.loop.i64(i64 %70)
  br i1 %71, label %Flow25, label %unify.bb

Flow25:                                           ; preds = %Flow24
  call void @llvm.amdgcn.end.cf.i64(i64 %70)
  br label %Flow26, !amdgpu.uniform !5

.loopexit:                                        ; preds = %Flow26
  %72 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %10
  store i32 %44, i32 addrspace(3)* %72, align 4, !tbaa !8
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %73 = icmp ult i32 %10, 32
  %74 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %73)
  %75 = extractvalue { i1, i64 } %74, 0
  %76 = extractvalue { i1, i64 } %74, 1
  br i1 %75, label %77, label %83

77:                                               ; preds = %.loopexit
  %78 = bitcast i32 addrspace(3)* %72 to i8 addrspace(3)*
  %sunkaddr = getelementptr inbounds i8, i8 addrspace(3)* %78, i32 128
  %79 = bitcast i8 addrspace(3)* %sunkaddr to i32 addrspace(3)*
  %80 = load i32, i32 addrspace(3)* %79, align 4, !tbaa !8
  %81 = load i32, i32 addrspace(3)* %72, align 4, !tbaa !8
  %82 = add i32 %81, %80
  store i32 %82, i32 addrspace(3)* %72, align 4, !tbaa !8
  br label %83, !amdgpu.uniform !5

83:                                               ; preds = %77, %.loopexit
  call void @llvm.amdgcn.end.cf.i64(i64 %76)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %84 = icmp ult i32 %10, 16
  %85 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %84)
  %86 = extractvalue { i1, i64 } %85, 0
  %87 = extractvalue { i1, i64 } %85, 1
  br i1 %86, label %88, label %94

88:                                               ; preds = %83
  %89 = bitcast i32 addrspace(3)* %72 to i8 addrspace(3)*
  %sunkaddr14 = getelementptr inbounds i8, i8 addrspace(3)* %89, i32 64
  %90 = bitcast i8 addrspace(3)* %sunkaddr14 to i32 addrspace(3)*
  %91 = load i32, i32 addrspace(3)* %90, align 4, !tbaa !8
  %92 = load i32, i32 addrspace(3)* %72, align 4, !tbaa !8
  %93 = add i32 %92, %91
  store i32 %93, i32 addrspace(3)* %72, align 4, !tbaa !8
  br label %94, !amdgpu.uniform !5

94:                                               ; preds = %88, %83
  call void @llvm.amdgcn.end.cf.i64(i64 %87)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %95 = icmp ult i32 %10, 8
  %96 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %95)
  %97 = extractvalue { i1, i64 } %96, 0
  %98 = extractvalue { i1, i64 } %96, 1
  br i1 %97, label %99, label %105

99:                                               ; preds = %94
  %100 = bitcast i32 addrspace(3)* %72 to i8 addrspace(3)*
  %sunkaddr15 = getelementptr inbounds i8, i8 addrspace(3)* %100, i32 32
  %101 = bitcast i8 addrspace(3)* %sunkaddr15 to i32 addrspace(3)*
  %102 = load i32, i32 addrspace(3)* %101, align 4, !tbaa !8
  %103 = load i32, i32 addrspace(3)* %72, align 4, !tbaa !8
  %104 = add i32 %103, %102
  store i32 %104, i32 addrspace(3)* %72, align 4, !tbaa !8
  br label %105, !amdgpu.uniform !5

105:                                              ; preds = %99, %94
  call void @llvm.amdgcn.end.cf.i64(i64 %98)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %106 = icmp ult i32 %10, 4
  %107 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %106)
  %108 = extractvalue { i1, i64 } %107, 0
  %109 = extractvalue { i1, i64 } %107, 1
  br i1 %108, label %110, label %116

110:                                              ; preds = %105
  %111 = bitcast i32 addrspace(3)* %72 to i8 addrspace(3)*
  %sunkaddr16 = getelementptr inbounds i8, i8 addrspace(3)* %111, i32 16
  %112 = bitcast i8 addrspace(3)* %sunkaddr16 to i32 addrspace(3)*
  %113 = load i32, i32 addrspace(3)* %112, align 4, !tbaa !8
  %114 = load i32, i32 addrspace(3)* %72, align 4, !tbaa !8
  %115 = add i32 %114, %113
  store i32 %115, i32 addrspace(3)* %72, align 4, !tbaa !8
  br label %116, !amdgpu.uniform !5

116:                                              ; preds = %110, %105
  call void @llvm.amdgcn.end.cf.i64(i64 %109)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %117 = icmp ult i32 %10, 2
  %118 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %117)
  %119 = extractvalue { i1, i64 } %118, 0
  %120 = extractvalue { i1, i64 } %118, 1
  br i1 %119, label %121, label %127

121:                                              ; preds = %116
  %122 = bitcast i32 addrspace(3)* %72 to i8 addrspace(3)*
  %sunkaddr17 = getelementptr inbounds i8, i8 addrspace(3)* %122, i32 8
  %123 = bitcast i8 addrspace(3)* %sunkaddr17 to i32 addrspace(3)*
  %124 = load i32, i32 addrspace(3)* %123, align 4, !tbaa !8
  %125 = load i32, i32 addrspace(3)* %72, align 4, !tbaa !8
  %126 = add i32 %125, %124
  store i32 %126, i32 addrspace(3)* %72, align 4, !tbaa !8
  br label %127, !amdgpu.uniform !5

127:                                              ; preds = %121, %116
  call void @llvm.amdgcn.end.cf.i64(i64 %120)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %128 = icmp eq i32 %10, 0
  %129 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %128)
  %130 = extractvalue { i1, i64 } %129, 0
  %131 = extractvalue { i1, i64 } %129, 1
  br i1 %130, label %132, label %137

132:                                              ; preds = %127
  %133 = load <2 x i32>, <2 x i32> addrspace(3)* bitcast ([64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum to <2 x i32> addrspace(3)*), align 16, !tbaa !8
  %134 = extractelement <2 x i32> %133, i32 0
  %135 = extractelement <2 x i32> %133, i32 1
  %136 = add i32 %134, %135
  store i32 %136, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 0), align 16, !tbaa !8
  br label %137, !amdgpu.uniform !5

137:                                              ; preds = %132, %127
  call void @llvm.amdgcn.end.cf.i64(i64 %131)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %138 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %128)
  %139 = extractvalue { i1, i64 } %138, 0
  %140 = extractvalue { i1, i64 } %138, 1
  br i1 %139, label %141, label %146

141:                                              ; preds = %137
  %.load1023 = extractelement <4 x i64> %9, i32 3
  %142 = inttoptr i64 %.load1023 to i32 addrspace(1)*
  %143 = sext i32 %11 to i64
  %144 = getelementptr inbounds i32, i32 addrspace(1)* %142, i64 %143
  %145 = load i32, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 0), align 16, !tbaa !8
  store i32 %145, i32 addrspace(1)* %144, align 4, !tbaa !8
  br label %146, !amdgpu.uniform !5

146:                                              ; preds = %141, %137
  call void @llvm.amdgcn.end.cf.i64(i64 %140)
  ret void

Flow:                                             ; preds = %merged.bb16, %unify.bb
  %147 = call { i1, i64 } @llvm.amdgcn.else.i64.i64(i64 %63)
  %148 = extractvalue { i1, i64 } %147, 0
  %149 = extractvalue { i1, i64 } %147, 1
  br i1 %148, label %decision.dispatch, label %merged.bb15

decision.dispatch:                                ; preds = %Flow
  %150 = add nsw i32 %46, 1
  %151 = select i1 %49, i32 undef, i32 %150
  %152 = add nsw i32 %47, -1
  %153 = select i1 %57, i32 %152, i32 undef
  %154 = select i1 %57, i32 %151, i32 %46
  br label %merged.bb15, !amdgpu.uniform !5

merged.bb15:                                      ; preds = %decision.dispatch, %Flow
  %155 = phi i32 [ %153, %decision.dispatch ], [ undef, %Flow ]
  %156 = phi i32 [ %154, %decision.dispatch ], [ %46, %Flow ]
  %157 = phi i32 [ %152, %decision.dispatch ], [ %58, %Flow ]
  call void @llvm.amdgcn.end.cf.i64(i64 %149)
  %158 = select i1 %49, i32 %155, i32 %157
  %159 = icmp sgt i32 %158, -1
  %160 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %159)
  %161 = extractvalue { i1, i64 } %160, 0
  %162 = extractvalue { i1, i64 } %160, 1
  br i1 %161, label %64, label %Flow24

merged.bb16:                                      ; preds = %unify.bb
  %163 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE4mask, i32 0, i32 %10, i32 %47
  %164 = load i32, i32 addrspace(3)* %163, align 4, !tbaa !8
  %165 = or i32 %164, %53
  %166 = getelementptr inbounds i32, i32 addrspace(3)* %163, i32 1
  store i32 %165, i32 addrspace(3)* %166, align 4, !tbaa !8
  %167 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6l_mask, i32 0, i32 %10, i32 %47
  %168 = load i32, i32 addrspace(3)* %167, align 4, !tbaa !8
  %169 = or i32 %168, %53
  %170 = shl i32 %169, 1
  %171 = getelementptr inbounds i32, i32 addrspace(3)* %167, i32 1
  store i32 %170, i32 addrspace(3)* %171, align 4, !tbaa !8
  %172 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6r_mask, i32 0, i32 %10, i32 %47
  %173 = load i32, i32 addrspace(3)* %172, align 4, !tbaa !8
  %174 = or i32 %173, %53
  %175 = lshr i32 %174, 1
  %176 = getelementptr inbounds i32, i32 addrspace(3)* %172, i32 1
  store i32 %175, i32 addrspace(3)* %176, align 4, !tbaa !8
  %177 = or i32 %170, %165
  %178 = or i32 %177, %175
  %179 = getelementptr inbounds i32, i32 addrspace(3)* %50, i32 1
  store i32 %178, i32 addrspace(3)* %179, align 4, !tbaa !8
  br label %Flow, !amdgpu.uniform !5
}
