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
  br i1 %21, label %23, label %Flow29

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

Flow29:                                           ; preds = %Flow28, %7
  %44 = phi i32 [ %66, %Flow28 ], [ 0, %7 ]
  call void @llvm.amdgcn.end.cf.i64(i64 %22)
  br label %.loopexit, !amdgpu.uniform !5

unify.bb:                                         ; preds = %23, %Flow27
  %phi.broken = phi i64 [ 0, %23 ], [ %67, %Flow27 ]
  %45 = phi i32 [ %64, %Flow27 ], [ %42, %23 ]
  %46 = phi i32 [ %66, %Flow27 ], [ 0, %23 ]
  %47 = phi i32 [ %167, %Flow27 ], [ 0, %23 ]
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
  %.inv25 = xor i1 %57, true
  %58 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %.inv25)
  %59 = extractvalue { i1, i64 } %58, 0
  %60 = extractvalue { i1, i64 } %58, 1
  br i1 %59, label %merged.bb13, label %Flow26

61:                                               ; preds = %merged.bb15
  %62 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %10, i32 %167
  %63 = load i32, i32 addrspace(3)* %62, align 4, !tbaa !8
  br label %Flow27, !amdgpu.uniform !5

Flow27:                                           ; preds = %61, %merged.bb15
  %64 = phi i32 [ %63, %61 ], [ undef, %merged.bb15 ]
  %65 = phi i1 [ false, %61 ], [ true, %merged.bb15 ]
  call void @llvm.amdgcn.end.cf.i64(i64 %171)
  %66 = select i1 %49, i32 %46, i32 %165
  %67 = call i64 @llvm.amdgcn.if.break.i64(i1 %65, i64 %phi.broken)
  %68 = call i1 @llvm.amdgcn.loop.i64(i64 %67)
  br i1 %68, label %Flow28, label %unify.bb

Flow28:                                           ; preds = %Flow27
  call void @llvm.amdgcn.end.cf.i64(i64 %67)
  br label %Flow29, !amdgpu.uniform !5

.loopexit:                                        ; preds = %Flow29
  %69 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %10
  store i32 %44, i32 addrspace(3)* %69, align 4, !tbaa !8
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %70 = icmp ult i32 %10, 32
  %71 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %70)
  %72 = extractvalue { i1, i64 } %71, 0
  %73 = extractvalue { i1, i64 } %71, 1
  br i1 %72, label %74, label %80

74:                                               ; preds = %.loopexit
  %75 = bitcast i32 addrspace(3)* %69 to i8 addrspace(3)*
  %sunkaddr = getelementptr inbounds i8, i8 addrspace(3)* %75, i32 128
  %76 = bitcast i8 addrspace(3)* %sunkaddr to i32 addrspace(3)*
  %77 = load i32, i32 addrspace(3)* %76, align 4, !tbaa !8
  %78 = load i32, i32 addrspace(3)* %69, align 4, !tbaa !8
  %79 = add i32 %78, %77
  store i32 %79, i32 addrspace(3)* %69, align 4, !tbaa !8
  br label %80, !amdgpu.uniform !5

80:                                               ; preds = %74, %.loopexit
  call void @llvm.amdgcn.end.cf.i64(i64 %73)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %81 = icmp ult i32 %10, 16
  %82 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %81)
  %83 = extractvalue { i1, i64 } %82, 0
  %84 = extractvalue { i1, i64 } %82, 1
  br i1 %83, label %85, label %91

85:                                               ; preds = %80
  %86 = bitcast i32 addrspace(3)* %69 to i8 addrspace(3)*
  %sunkaddr14 = getelementptr inbounds i8, i8 addrspace(3)* %86, i32 64
  %87 = bitcast i8 addrspace(3)* %sunkaddr14 to i32 addrspace(3)*
  %88 = load i32, i32 addrspace(3)* %87, align 4, !tbaa !8
  %89 = load i32, i32 addrspace(3)* %69, align 4, !tbaa !8
  %90 = add i32 %89, %88
  store i32 %90, i32 addrspace(3)* %69, align 4, !tbaa !8
  br label %91, !amdgpu.uniform !5

91:                                               ; preds = %85, %80
  call void @llvm.amdgcn.end.cf.i64(i64 %84)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %92 = icmp ult i32 %10, 8
  %93 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %92)
  %94 = extractvalue { i1, i64 } %93, 0
  %95 = extractvalue { i1, i64 } %93, 1
  br i1 %94, label %96, label %102

96:                                               ; preds = %91
  %97 = bitcast i32 addrspace(3)* %69 to i8 addrspace(3)*
  %sunkaddr15 = getelementptr inbounds i8, i8 addrspace(3)* %97, i32 32
  %98 = bitcast i8 addrspace(3)* %sunkaddr15 to i32 addrspace(3)*
  %99 = load i32, i32 addrspace(3)* %98, align 4, !tbaa !8
  %100 = load i32, i32 addrspace(3)* %69, align 4, !tbaa !8
  %101 = add i32 %100, %99
  store i32 %101, i32 addrspace(3)* %69, align 4, !tbaa !8
  br label %102, !amdgpu.uniform !5

102:                                              ; preds = %96, %91
  call void @llvm.amdgcn.end.cf.i64(i64 %95)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %103 = icmp ult i32 %10, 4
  %104 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %103)
  %105 = extractvalue { i1, i64 } %104, 0
  %106 = extractvalue { i1, i64 } %104, 1
  br i1 %105, label %107, label %113

107:                                              ; preds = %102
  %108 = bitcast i32 addrspace(3)* %69 to i8 addrspace(3)*
  %sunkaddr16 = getelementptr inbounds i8, i8 addrspace(3)* %108, i32 16
  %109 = bitcast i8 addrspace(3)* %sunkaddr16 to i32 addrspace(3)*
  %110 = load i32, i32 addrspace(3)* %109, align 4, !tbaa !8
  %111 = load i32, i32 addrspace(3)* %69, align 4, !tbaa !8
  %112 = add i32 %111, %110
  store i32 %112, i32 addrspace(3)* %69, align 4, !tbaa !8
  br label %113, !amdgpu.uniform !5

113:                                              ; preds = %107, %102
  call void @llvm.amdgcn.end.cf.i64(i64 %106)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %114 = icmp ult i32 %10, 2
  %115 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %114)
  %116 = extractvalue { i1, i64 } %115, 0
  %117 = extractvalue { i1, i64 } %115, 1
  br i1 %116, label %118, label %124

118:                                              ; preds = %113
  %119 = bitcast i32 addrspace(3)* %69 to i8 addrspace(3)*
  %sunkaddr17 = getelementptr inbounds i8, i8 addrspace(3)* %119, i32 8
  %120 = bitcast i8 addrspace(3)* %sunkaddr17 to i32 addrspace(3)*
  %121 = load i32, i32 addrspace(3)* %120, align 4, !tbaa !8
  %122 = load i32, i32 addrspace(3)* %69, align 4, !tbaa !8
  %123 = add i32 %122, %121
  store i32 %123, i32 addrspace(3)* %69, align 4, !tbaa !8
  br label %124, !amdgpu.uniform !5

124:                                              ; preds = %118, %113
  call void @llvm.amdgcn.end.cf.i64(i64 %117)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %125 = icmp eq i32 %10, 0
  %126 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %125)
  %127 = extractvalue { i1, i64 } %126, 0
  %128 = extractvalue { i1, i64 } %126, 1
  br i1 %127, label %129, label %134

129:                                              ; preds = %124
  %130 = load <2 x i32>, <2 x i32> addrspace(3)* bitcast ([64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum to <2 x i32> addrspace(3)*), align 16, !tbaa !8
  %131 = extractelement <2 x i32> %130, i32 0
  %132 = extractelement <2 x i32> %130, i32 1
  %133 = add i32 %131, %132
  store i32 %133, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 0), align 16, !tbaa !8
  br label %134, !amdgpu.uniform !5

134:                                              ; preds = %129, %124
  call void @llvm.amdgcn.end.cf.i64(i64 %128)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %135 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %125)
  %136 = extractvalue { i1, i64 } %135, 0
  %137 = extractvalue { i1, i64 } %135, 1
  br i1 %136, label %138, label %143

138:                                              ; preds = %134
  %.load1023 = extractelement <4 x i64> %9, i32 3
  %139 = inttoptr i64 %.load1023 to i32 addrspace(1)*
  %140 = sext i32 %11 to i64
  %141 = getelementptr inbounds i32, i32 addrspace(1)* %139, i64 %140
  %142 = load i32, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 0), align 16, !tbaa !8
  store i32 %142, i32 addrspace(1)* %141, align 4, !tbaa !8
  br label %143, !amdgpu.uniform !5

143:                                              ; preds = %138, %134
  call void @llvm.amdgcn.end.cf.i64(i64 %137)
  ret void

Flow:                                             ; preds = %merged.bb16, %merged.bb14
  %144 = call { i1, i64 } @llvm.amdgcn.else.i64.i64(i64 %160)
  %145 = extractvalue { i1, i64 } %144, 0
  %146 = extractvalue { i1, i64 } %144, 1
  br i1 %145, label %merged.bb, label %Flow24

merged.bb:                                        ; preds = %Flow
  %147 = add nsw i32 %46, 1
  %148 = select i1 %49, i32 undef, i32 %147
  %149 = add nsw i32 %47, -1
  br label %Flow24, !amdgpu.uniform !5

merged.bb13:                                      ; preds = %unify.bb
  %150 = add nsw i32 %47, -1
  br label %Flow26, !amdgpu.uniform !5

Flow26:                                           ; preds = %merged.bb13, %unify.bb
  %151 = phi i32 [ %150, %merged.bb13 ], [ undef, %unify.bb ]
  %152 = call { i1, i64 } @llvm.amdgcn.else.i64.i64(i64 %60)
  %153 = extractvalue { i1, i64 } %152, 0
  %154 = extractvalue { i1, i64 } %152, 1
  br i1 %153, label %merged.bb14, label %merged.bb15

merged.bb14:                                      ; preds = %Flow26
  %155 = add nuw nsw i32 %47, 1
  %156 = icmp eq i32 %155, %.load219
  %157 = or i1 %49, %156
  %.inv = xor i1 %157, true
  %158 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %.inv)
  %159 = extractvalue { i1, i64 } %158, 0
  %160 = extractvalue { i1, i64 } %158, 1
  br i1 %159, label %merged.bb16, label %Flow

Flow24:                                           ; preds = %merged.bb, %Flow
  %161 = phi i32 [ %149, %merged.bb ], [ %155, %Flow ]
  %162 = phi i32 [ %148, %merged.bb ], [ %46, %Flow ]
  %163 = phi i32 [ %149, %merged.bb ], [ undef, %Flow ]
  call void @llvm.amdgcn.end.cf.i64(i64 %146)
  br label %merged.bb15, !amdgpu.uniform !5

merged.bb15:                                      ; preds = %Flow26, %Flow24
  %164 = phi i32 [ undef, %Flow26 ], [ %163, %Flow24 ]
  %165 = phi i32 [ %46, %Flow26 ], [ %162, %Flow24 ]
  %166 = phi i32 [ %151, %Flow26 ], [ %161, %Flow24 ]
  call void @llvm.amdgcn.end.cf.i64(i64 %154)
  %167 = select i1 %49, i32 %164, i32 %166
  %168 = icmp sgt i32 %167, -1
  %169 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %168)
  %170 = extractvalue { i1, i64 } %169, 0
  %171 = extractvalue { i1, i64 } %169, 1
  br i1 %170, label %61, label %Flow27

merged.bb16:                                      ; preds = %merged.bb14
  %172 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE4mask, i32 0, i32 %10, i32 %47
  %173 = load i32, i32 addrspace(3)* %172, align 4, !tbaa !8
  %174 = or i32 %173, %53
  %175 = getelementptr inbounds i32, i32 addrspace(3)* %172, i32 1
  store i32 %174, i32 addrspace(3)* %175, align 4, !tbaa !8
  %176 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6l_mask, i32 0, i32 %10, i32 %47
  %177 = load i32, i32 addrspace(3)* %176, align 4, !tbaa !8
  %178 = or i32 %177, %53
  %179 = shl i32 %178, 1
  %180 = getelementptr inbounds i32, i32 addrspace(3)* %176, i32 1
  store i32 %179, i32 addrspace(3)* %180, align 4, !tbaa !8
  %181 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6r_mask, i32 0, i32 %10, i32 %47
  %182 = load i32, i32 addrspace(3)* %181, align 4, !tbaa !8
  %183 = or i32 %182, %53
  %184 = lshr i32 %183, 1
  %185 = getelementptr inbounds i32, i32 addrspace(3)* %181, i32 1
  store i32 %184, i32 addrspace(3)* %185, align 4, !tbaa !8
  %186 = or i32 %179, %174
  %187 = or i32 %186, %184
  %188 = getelementptr inbounds i32, i32 addrspace(3)* %50, i32 1
  store i32 %187, i32 addrspace(3)* %188, align 4, !tbaa !8
  br label %Flow, !amdgpu.uniform !5
}
