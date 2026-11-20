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
  %44 = phi i32 [ %70, %Flow25 ], [ 0, %7 ]
  call void @llvm.amdgcn.end.cf.i64(i64 %22)
  br label %.loopexit, !amdgpu.uniform !5

unify.bb:                                         ; preds = %23, %Flow24
  %phi.broken = phi i64 [ 0, %23 ], [ %71, %Flow24 ]
  %45 = phi i32 [ %68, %Flow24 ], [ %42, %23 ]
  %46 = phi i32 [ %70, %Flow24 ], [ 0, %23 ]
  %47 = phi i32 [ %176, %Flow24 ], [ 0, %23 ]
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
  %59 = add nuw nsw i32 %47, 1
  %60 = icmp eq i32 %59, %.load219
  %61 = or i1 %60, %58
  %.inv = xor i1 %61, true
  %62 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %.inv)
  %63 = extractvalue { i1, i64 } %62, 0
  %64 = extractvalue { i1, i64 } %62, 1
  br i1 %63, label %merged.bb32, label %Flow

65:                                               ; preds = %merged.bb34
  %66 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %10, i32 %176
  %67 = load i32, i32 addrspace(3)* %66, align 4, !tbaa !8
  br label %Flow24, !amdgpu.uniform !5

Flow24:                                           ; preds = %65, %merged.bb34
  %68 = phi i32 [ %67, %65 ], [ undef, %merged.bb34 ]
  %69 = phi i1 [ false, %65 ], [ true, %merged.bb34 ]
  call void @llvm.amdgcn.end.cf.i64(i64 %180)
  %70 = select i1 %58, i32 %46, i32 %173
  %71 = call i64 @llvm.amdgcn.if.break.i64(i1 %69, i64 %phi.broken)
  %72 = call i1 @llvm.amdgcn.loop.i64(i64 %71)
  br i1 %72, label %Flow25, label %unify.bb

Flow25:                                           ; preds = %Flow24
  call void @llvm.amdgcn.end.cf.i64(i64 %71)
  br label %Flow26, !amdgpu.uniform !5

.loopexit:                                        ; preds = %Flow26
  %73 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %10
  store i32 %44, i32 addrspace(3)* %73, align 4, !tbaa !8
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %74 = icmp ult i32 %10, 32
  %75 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %74)
  %76 = extractvalue { i1, i64 } %75, 0
  %77 = extractvalue { i1, i64 } %75, 1
  br i1 %76, label %78, label %84

78:                                               ; preds = %.loopexit
  %79 = bitcast i32 addrspace(3)* %73 to i8 addrspace(3)*
  %sunkaddr = getelementptr inbounds i8, i8 addrspace(3)* %79, i32 128
  %80 = bitcast i8 addrspace(3)* %sunkaddr to i32 addrspace(3)*
  %81 = load i32, i32 addrspace(3)* %80, align 4, !tbaa !8
  %82 = load i32, i32 addrspace(3)* %73, align 4, !tbaa !8
  %83 = add i32 %82, %81
  store i32 %83, i32 addrspace(3)* %73, align 4, !tbaa !8
  br label %84, !amdgpu.uniform !5

84:                                               ; preds = %78, %.loopexit
  call void @llvm.amdgcn.end.cf.i64(i64 %77)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %85 = icmp ult i32 %10, 16
  %86 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %85)
  %87 = extractvalue { i1, i64 } %86, 0
  %88 = extractvalue { i1, i64 } %86, 1
  br i1 %87, label %89, label %95

89:                                               ; preds = %84
  %90 = bitcast i32 addrspace(3)* %73 to i8 addrspace(3)*
  %sunkaddr14 = getelementptr inbounds i8, i8 addrspace(3)* %90, i32 64
  %91 = bitcast i8 addrspace(3)* %sunkaddr14 to i32 addrspace(3)*
  %92 = load i32, i32 addrspace(3)* %91, align 4, !tbaa !8
  %93 = load i32, i32 addrspace(3)* %73, align 4, !tbaa !8
  %94 = add i32 %93, %92
  store i32 %94, i32 addrspace(3)* %73, align 4, !tbaa !8
  br label %95, !amdgpu.uniform !5

95:                                               ; preds = %89, %84
  call void @llvm.amdgcn.end.cf.i64(i64 %88)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %96 = icmp ult i32 %10, 8
  %97 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %96)
  %98 = extractvalue { i1, i64 } %97, 0
  %99 = extractvalue { i1, i64 } %97, 1
  br i1 %98, label %100, label %106

100:                                              ; preds = %95
  %101 = bitcast i32 addrspace(3)* %73 to i8 addrspace(3)*
  %sunkaddr15 = getelementptr inbounds i8, i8 addrspace(3)* %101, i32 32
  %102 = bitcast i8 addrspace(3)* %sunkaddr15 to i32 addrspace(3)*
  %103 = load i32, i32 addrspace(3)* %102, align 4, !tbaa !8
  %104 = load i32, i32 addrspace(3)* %73, align 4, !tbaa !8
  %105 = add i32 %104, %103
  store i32 %105, i32 addrspace(3)* %73, align 4, !tbaa !8
  br label %106, !amdgpu.uniform !5

106:                                              ; preds = %100, %95
  call void @llvm.amdgcn.end.cf.i64(i64 %99)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %107 = icmp ult i32 %10, 4
  %108 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %107)
  %109 = extractvalue { i1, i64 } %108, 0
  %110 = extractvalue { i1, i64 } %108, 1
  br i1 %109, label %111, label %117

111:                                              ; preds = %106
  %112 = bitcast i32 addrspace(3)* %73 to i8 addrspace(3)*
  %sunkaddr16 = getelementptr inbounds i8, i8 addrspace(3)* %112, i32 16
  %113 = bitcast i8 addrspace(3)* %sunkaddr16 to i32 addrspace(3)*
  %114 = load i32, i32 addrspace(3)* %113, align 4, !tbaa !8
  %115 = load i32, i32 addrspace(3)* %73, align 4, !tbaa !8
  %116 = add i32 %115, %114
  store i32 %116, i32 addrspace(3)* %73, align 4, !tbaa !8
  br label %117, !amdgpu.uniform !5

117:                                              ; preds = %111, %106
  call void @llvm.amdgcn.end.cf.i64(i64 %110)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %118 = icmp ult i32 %10, 2
  %119 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %118)
  %120 = extractvalue { i1, i64 } %119, 0
  %121 = extractvalue { i1, i64 } %119, 1
  br i1 %120, label %122, label %128

122:                                              ; preds = %117
  %123 = bitcast i32 addrspace(3)* %73 to i8 addrspace(3)*
  %sunkaddr17 = getelementptr inbounds i8, i8 addrspace(3)* %123, i32 8
  %124 = bitcast i8 addrspace(3)* %sunkaddr17 to i32 addrspace(3)*
  %125 = load i32, i32 addrspace(3)* %124, align 4, !tbaa !8
  %126 = load i32, i32 addrspace(3)* %73, align 4, !tbaa !8
  %127 = add i32 %126, %125
  store i32 %127, i32 addrspace(3)* %73, align 4, !tbaa !8
  br label %128, !amdgpu.uniform !5

128:                                              ; preds = %122, %117
  call void @llvm.amdgcn.end.cf.i64(i64 %121)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %129 = icmp eq i32 %10, 0
  %130 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %129)
  %131 = extractvalue { i1, i64 } %130, 0
  %132 = extractvalue { i1, i64 } %130, 1
  br i1 %131, label %133, label %138

133:                                              ; preds = %128
  %134 = load <2 x i32>, <2 x i32> addrspace(3)* bitcast ([64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum to <2 x i32> addrspace(3)*), align 16, !tbaa !8
  %135 = extractelement <2 x i32> %134, i32 0
  %136 = extractelement <2 x i32> %134, i32 1
  %137 = add i32 %135, %136
  store i32 %137, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 0), align 16, !tbaa !8
  br label %138, !amdgpu.uniform !5

138:                                              ; preds = %133, %128
  call void @llvm.amdgcn.end.cf.i64(i64 %132)
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #6
  fence syncscope("workgroup") acquire
  %139 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %129)
  %140 = extractvalue { i1, i64 } %139, 0
  %141 = extractvalue { i1, i64 } %139, 1
  br i1 %140, label %142, label %147

142:                                              ; preds = %138
  %.load1023 = extractelement <4 x i64> %9, i32 3
  %143 = inttoptr i64 %.load1023 to i32 addrspace(1)*
  %144 = sext i32 %11 to i64
  %145 = getelementptr inbounds i32, i32 addrspace(1)* %143, i64 %144
  %146 = load i32, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 0), align 16, !tbaa !8
  store i32 %146, i32 addrspace(1)* %145, align 4, !tbaa !8
  br label %147, !amdgpu.uniform !5

147:                                              ; preds = %142, %138
  call void @llvm.amdgcn.end.cf.i64(i64 %141)
  ret void

merged.bb32:                                      ; preds = %unify.bb
  %148 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE4mask, i32 0, i32 %10, i32 %47
  %149 = load i32, i32 addrspace(3)* %148, align 4, !tbaa !8
  %150 = or i32 %149, %53
  %151 = getelementptr inbounds i32, i32 addrspace(3)* %148, i32 1
  store i32 %150, i32 addrspace(3)* %151, align 4, !tbaa !8
  %152 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6l_mask, i32 0, i32 %10, i32 %47
  %153 = load i32, i32 addrspace(3)* %152, align 4, !tbaa !8
  %154 = or i32 %153, %53
  %155 = shl i32 %154, 1
  %156 = getelementptr inbounds i32, i32 addrspace(3)* %152, i32 1
  store i32 %155, i32 addrspace(3)* %156, align 4, !tbaa !8
  %157 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6r_mask, i32 0, i32 %10, i32 %47
  %158 = load i32, i32 addrspace(3)* %157, align 4, !tbaa !8
  %159 = or i32 %158, %53
  %160 = lshr i32 %159, 1
  %161 = getelementptr inbounds i32, i32 addrspace(3)* %157, i32 1
  store i32 %160, i32 addrspace(3)* %161, align 4, !tbaa !8
  %162 = or i32 %155, %150
  %163 = or i32 %162, %160
  %164 = getelementptr inbounds i32, i32 addrspace(3)* %50, i32 1
  store i32 %163, i32 addrspace(3)* %164, align 4, !tbaa !8
  br label %Flow, !amdgpu.uniform !5

Flow:                                             ; preds = %merged.bb32, %unify.bb
  %165 = call { i1, i64 } @llvm.amdgcn.else.i64.i64(i64 %64)
  %166 = extractvalue { i1, i64 } %165, 0
  %167 = extractvalue { i1, i64 } %165, 1
  br i1 %166, label %merged.bb33, label %merged.bb34

merged.bb33:                                      ; preds = %Flow
  %168 = add nsw i32 %46, 1
  %169 = select i1 %58, i32 undef, i32 %168
  %170 = add nsw i32 %47, -1
  br label %merged.bb34, !amdgpu.uniform !5

merged.bb34:                                      ; preds = %merged.bb33, %Flow
  %171 = phi i32 [ %170, %merged.bb33 ], [ undef, %Flow ]
  %172 = phi i32 [ %170, %merged.bb33 ], [ %59, %Flow ]
  %173 = phi i32 [ %169, %merged.bb33 ], [ %46, %Flow ]
  call void @llvm.amdgcn.end.cf.i64(i64 %167)
  %174 = select i1 %58, i32 %171, i32 undef
  %175 = select i1 %58, i32 %171, i32 %172
  %176 = select i1 %49, i32 %174, i32 %175
  %177 = icmp sgt i32 %176, -1
  %178 = call { i1, i64 } @llvm.amdgcn.if.i64(i1 %177)
  %179 = extractvalue { i1, i64 } %178, 0
  %180 = extractvalue { i1, i64 } %178, 1
  br i1 %179, label %65, label %Flow24
}
