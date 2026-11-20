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
  %44 = phi i32 [ %67, %Flow28 ], [ 0, %7 ]
  call void @llvm.amdgcn.end.cf.i64(i64 %22)
  br label %.loopexit, !amdgpu.uniform !5

unify.bb:                                         ; preds = %23, %Flow27
  %phi.broken = phi i64 [ 0, %23 ], [ %68, %Flow27 ]
  %45 = phi i32 [ %65, %Flow27 ], [ %42, %23 ]
  %46 = phi i32 [ %67, %Flow27 ], [ 0, %23 ]
  %47 = phi i32 [ %150, %Flow27 ], [ 0, %23 ]
  %48 = and i32 %45, %30
  %49 = icmp eq i32 %48, %30
  %50 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %10, i32 %47
  %51 = add i32 %45, 1
  %52 = xor i32 %45, -1
  %53 = and i32 %51, %52
  %54 = select i1 %49, i32 0, i32 %51
  %55 = or i32 %45, %54
  store i32 %55, i32 addrspace(3)* %50, align 4, !tbaa !8
  %56 = and i32 %53, %30
  %57 = icmp eq i32 %56, 0
  %58 = or i1 %49, %57
  %.inv25 = xor i1 %58, true
  %59 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %.inv25)
  %60 = extractvalue { i1, i64 } %59, 0
  %61 = extractvalue { i1, i64 } %59, 1
  br i1 %60, label %merged.bb15, label %Flow26

62:                                               ; preds = %merged.bb
  %63 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %10, i32 %150
  %64 = load i32, i32 addrspace(3)* %63, align 4, !tbaa !8
  br label %Flow27, !amdgpu.uniform !5

Flow27:                                           ; preds = %62, %merged.bb
  %65 = phi i32 [ %64, %62 ], [ undef, %merged.bb ]
  %66 = phi i1 [ false, %62 ], [ true, %merged.bb ]
  call void @llvm.amdgcn.end.cf.i64(i64 %154)
  %67 = select i1 %49, i32 %46, i32 %148
  %68 = call i64 @llvm.amdgcn.if.break.i64(i1 %66, i64 %phi.broken)
  %69 = call i1 @llvm.amdgcn.loop.i64(i64 %68)
  br i1 %69, label %Flow28, label %unify.bb

Flow28:                                           ; preds = %Flow27
  call void @llvm.amdgcn.end.cf.i64(i64 %68)
  br label %Flow29, !amdgpu.uniform !5

.loopexit:                                        ; preds = %Flow29
  %70 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %10
  store i32 %44, i32 addrspace(3)* %70, align 4, !tbaa !8
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %71 = icmp ult i32 %10, 32
  %72 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %71)
  %73 = extractvalue { i1, i64 } %72, 0
  %74 = extractvalue { i1, i64 } %72, 1
  br i1 %73, label %75, label %81

75:                                               ; preds = %.loopexit
  %76 = bitcast i32 addrspace(3)* %70 to i8 addrspace(3)*
  %sunkaddr = getelementptr inbounds i8, i8 addrspace(3)* %76, i32 128
  %77 = bitcast i8 addrspace(3)* %sunkaddr to i32 addrspace(3)*
  %78 = load i32, i32 addrspace(3)* %77, align 4, !tbaa !8
  %79 = load i32, i32 addrspace(3)* %70, align 4, !tbaa !8
  %80 = add i32 %79, %78
  store i32 %80, i32 addrspace(3)* %70, align 4, !tbaa !8
  br label %81, !amdgpu.uniform !5

81:                                               ; preds = %75, %.loopexit
  call void @llvm.amdgcn.end.cf.i64(i64 %74)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %82 = icmp ult i32 %10, 16
  %83 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %82)
  %84 = extractvalue { i1, i64 } %83, 0
  %85 = extractvalue { i1, i64 } %83, 1
  br i1 %84, label %86, label %92

86:                                               ; preds = %81
  %87 = bitcast i32 addrspace(3)* %70 to i8 addrspace(3)*
  %sunkaddr14 = getelementptr inbounds i8, i8 addrspace(3)* %87, i32 64
  %88 = bitcast i8 addrspace(3)* %sunkaddr14 to i32 addrspace(3)*
  %89 = load i32, i32 addrspace(3)* %88, align 4, !tbaa !8
  %90 = load i32, i32 addrspace(3)* %70, align 4, !tbaa !8
  %91 = add i32 %90, %89
  store i32 %91, i32 addrspace(3)* %70, align 4, !tbaa !8
  br label %92, !amdgpu.uniform !5

92:                                               ; preds = %86, %81
  call void @llvm.amdgcn.end.cf.i64(i64 %85)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %93 = icmp ult i32 %10, 8
  %94 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %93)
  %95 = extractvalue { i1, i64 } %94, 0
  %96 = extractvalue { i1, i64 } %94, 1
  br i1 %95, label %97, label %103

97:                                               ; preds = %92
  %98 = bitcast i32 addrspace(3)* %70 to i8 addrspace(3)*
  %sunkaddr15 = getelementptr inbounds i8, i8 addrspace(3)* %98, i32 32
  %99 = bitcast i8 addrspace(3)* %sunkaddr15 to i32 addrspace(3)*
  %100 = load i32, i32 addrspace(3)* %99, align 4, !tbaa !8
  %101 = load i32, i32 addrspace(3)* %70, align 4, !tbaa !8
  %102 = add i32 %101, %100
  store i32 %102, i32 addrspace(3)* %70, align 4, !tbaa !8
  br label %103, !amdgpu.uniform !5

103:                                              ; preds = %97, %92
  call void @llvm.amdgcn.end.cf.i64(i64 %96)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %104 = icmp ult i32 %10, 4
  %105 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %104)
  %106 = extractvalue { i1, i64 } %105, 0
  %107 = extractvalue { i1, i64 } %105, 1
  br i1 %106, label %108, label %114

108:                                              ; preds = %103
  %109 = bitcast i32 addrspace(3)* %70 to i8 addrspace(3)*
  %sunkaddr16 = getelementptr inbounds i8, i8 addrspace(3)* %109, i32 16
  %110 = bitcast i8 addrspace(3)* %sunkaddr16 to i32 addrspace(3)*
  %111 = load i32, i32 addrspace(3)* %110, align 4, !tbaa !8
  %112 = load i32, i32 addrspace(3)* %70, align 4, !tbaa !8
  %113 = add i32 %112, %111
  store i32 %113, i32 addrspace(3)* %70, align 4, !tbaa !8
  br label %114, !amdgpu.uniform !5

114:                                              ; preds = %108, %103
  call void @llvm.amdgcn.end.cf.i64(i64 %107)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %115 = icmp ult i32 %10, 2
  %116 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %115)
  %117 = extractvalue { i1, i64 } %116, 0
  %118 = extractvalue { i1, i64 } %116, 1
  br i1 %117, label %119, label %125

119:                                              ; preds = %114
  %120 = bitcast i32 addrspace(3)* %70 to i8 addrspace(3)*
  %sunkaddr17 = getelementptr inbounds i8, i8 addrspace(3)* %120, i32 8
  %121 = bitcast i8 addrspace(3)* %sunkaddr17 to i32 addrspace(3)*
  %122 = load i32, i32 addrspace(3)* %121, align 4, !tbaa !8
  %123 = load i32, i32 addrspace(3)* %70, align 4, !tbaa !8
  %124 = add i32 %123, %122
  store i32 %124, i32 addrspace(3)* %70, align 4, !tbaa !8
  br label %125, !amdgpu.uniform !5

125:                                              ; preds = %119, %114
  call void @llvm.amdgcn.end.cf.i64(i64 %118)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %126 = icmp eq i32 %10, 0
  %127 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %126)
  %128 = extractvalue { i1, i64 } %127, 0
  %129 = extractvalue { i1, i64 } %127, 1
  br i1 %128, label %130, label %135

130:                                              ; preds = %125
  %131 = load <2 x i32>, <2 x i32> addrspace(3)* bitcast ([64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum to <2 x i32> addrspace(3)*), align 16, !tbaa !8
  %132 = extractelement <2 x i32> %131, i32 0
  %133 = extractelement <2 x i32> %131, i32 1
  %134 = add i32 %132, %133
  store i32 %134, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 0), align 16, !tbaa !8
  br label %135, !amdgpu.uniform !5

135:                                              ; preds = %130, %125
  call void @llvm.amdgcn.end.cf.i64(i64 %129)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %136 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %126)
  %137 = extractvalue { i1, i64 } %136, 0
  %138 = extractvalue { i1, i64 } %136, 1
  br i1 %137, label %139, label %144

139:                                              ; preds = %135
  %.load1023 = extractelement <4 x i64> %9, i32 3
  %140 = inttoptr i64 %.load1023 to i32 addrspace(1)*
  %141 = sext i32 %11 to i64
  %142 = getelementptr inbounds i32, i32 addrspace(1)* %140, i64 %141
  %143 = load i32, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 0), align 16, !tbaa !8
  store i32 %143, i32 addrspace(1)* %142, align 4, !tbaa !8
  br label %144, !amdgpu.uniform !5

144:                                              ; preds = %139, %135
  call void @llvm.amdgcn.end.cf.i64(i64 %138)
  ret void

Flow24:                                           ; preds = %merged.bb17, %Flow
  %145 = phi i32 [ %187, %merged.bb17 ], [ %161, %Flow ]
  %146 = phi i32 [ %186, %merged.bb17 ], [ %46, %Flow ]
  call void @llvm.amdgcn.end.cf.i64(i64 %185)
  br label %Flow26, !amdgpu.uniform !5

merged.bb:                                        ; preds = %merged.bb14, %Flow26
  %147 = phi i32 [ %160, %merged.bb14 ], [ undef, %Flow26 ]
  %148 = phi i32 [ %46, %merged.bb14 ], [ %156, %Flow26 ]
  %149 = phi i32 [ %160, %merged.bb14 ], [ %155, %Flow26 ]
  call void @llvm.amdgcn.end.cf.i64(i64 %159)
  %150 = select i1 %49, i32 %147, i32 %149
  %151 = icmp sgt i32 %150, -1
  %152 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %151)
  %153 = extractvalue { i1, i64 } %152, 0
  %154 = extractvalue { i1, i64 } %152, 1
  br i1 %153, label %62, label %Flow27

Flow26:                                           ; preds = %Flow24, %unify.bb
  %155 = phi i32 [ %145, %Flow24 ], [ undef, %unify.bb ]
  %156 = phi i32 [ %146, %Flow24 ], [ undef, %unify.bb ]
  %157 = call { i1, i64 } @llvm.amdgcn.else.i64.i64(i64 %61)
  %158 = extractvalue { i1, i64 } %157, 0
  %159 = extractvalue { i1, i64 } %157, 1
  br i1 %158, label %merged.bb14, label %merged.bb

merged.bb14:                                      ; preds = %Flow26
  %160 = add nsw i32 %47, -1
  br label %merged.bb, !amdgpu.uniform !5

merged.bb15:                                      ; preds = %unify.bb
  %161 = add nuw nsw i32 %47, 1
  %162 = icmp eq i32 %161, %.load219
  %.inv = xor i1 %162, true
  %163 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %.inv)
  %164 = extractvalue { i1, i64 } %163, 0
  %165 = extractvalue { i1, i64 } %163, 1
  br i1 %164, label %merged.bb16, label %Flow

merged.bb16:                                      ; preds = %merged.bb15
  %166 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE4mask, i32 0, i32 %10, i32 %47
  %167 = load i32, i32 addrspace(3)* %166, align 4, !tbaa !8
  %168 = or i32 %167, %53
  %169 = getelementptr inbounds i32, i32 addrspace(3)* %166, i32 1
  store i32 %168, i32 addrspace(3)* %169, align 4, !tbaa !8
  %170 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6l_mask, i32 0, i32 %10, i32 %47
  %171 = load i32, i32 addrspace(3)* %170, align 4, !tbaa !8
  %172 = or i32 %171, %53
  %173 = shl i32 %172, 1
  %174 = getelementptr inbounds i32, i32 addrspace(3)* %170, i32 1
  store i32 %173, i32 addrspace(3)* %174, align 4, !tbaa !8
  %175 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6r_mask, i32 0, i32 %10, i32 %47
  %176 = load i32, i32 addrspace(3)* %175, align 4, !tbaa !8
  %177 = or i32 %176, %53
  %178 = lshr i32 %177, 1
  %179 = getelementptr inbounds i32, i32 addrspace(3)* %175, i32 1
  store i32 %178, i32 addrspace(3)* %179, align 4, !tbaa !8
  %180 = or i32 %173, %168
  %181 = or i32 %180, %178
  %182 = getelementptr inbounds i32, i32 addrspace(3)* %50, i32 1
  store i32 %181, i32 addrspace(3)* %182, align 4, !tbaa !8
  br label %Flow, !amdgpu.uniform !5

Flow:                                             ; preds = %merged.bb16, %merged.bb15
  %183 = call { i1, i64 } @llvm.amdgcn.else.i64.i64(i64 %165)
  %184 = extractvalue { i1, i64 } %183, 0
  %185 = extractvalue { i1, i64 } %183, 1
  br i1 %184, label %merged.bb17, label %Flow24

merged.bb17:                                      ; preds = %Flow
  %186 = add nsw i32 %46, 1
  %187 = add nsw i32 %47, -1
  br label %Flow24, !amdgpu.uniform !5
}
