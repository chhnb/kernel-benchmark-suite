# 回溯 IR、块角色及循环深度

每一段保留实际指令和 SSA 名称，退出块只列入口和终结部位前的相关代码。完整 IR 含属性、全局变量和结果归约。

## 融合输出

### P

[完整 IR](P.ll)

```llvm
; 循环深度 0，进入循环
20:
  %21 = sext i32 %16 to i64
  %22 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %21
  %23 = load i32, i32 addrspace(1)* %22, align 4, !tbaa !8
  %24 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE4mask, i32 0, i32 %8, i32 0
  store i32 %23, i32 addrspace(3)* %24, align 8, !tbaa !8
  %25 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %21
  %26 = load i32, i32 addrspace(1)* %25, align 4, !tbaa !8
  %27 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6l_mask, i32 0, i32 %8, i32 0
  store i32 %26, i32 addrspace(3)* %27, align 8, !tbaa !8
  %28 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %21
  %29 = load i32, i32 addrspace(1)* %28, align 4, !tbaa !8
  %30 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6r_mask, i32 0, i32 %8, i32 0
  store i32 %29, i32 addrspace(3)* %30, align 8, !tbaa !8
  %31 = or i32 %26, %23
  %32 = or i32 %31, %29
  %33 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 0
  store i32 %32, i32 addrspace(3)* %33, align 8, !tbaa !8
  br label %unify.bb

; 循环深度 1，头
unify.bb:
  %34 = phi i32 [ %32, %20 ], [ %51, %49 ]
  %35 = phi i32 [ 0, %20 ], [ %111, %49 ]
  %36 = phi i32 [ 0, %20 ], [ %110, %49 ]
  %37 = and i32 %34, %18
  %38 = icmp eq i32 %37, %18
  %39 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 %36
  %40 = add i32 %34, 1
  %41 = xor i32 %34, -1
  %42 = and i32 %40, %41
  %43 = or i32 %40, %34
  %44 = load i32, i32 addrspace(3)* %39, align 4
  %45 = select i1 %38, i32 %44, i32 %43
  store i32 %45, i32 addrspace(3)* %39, align 4, !tbaa !8
  %46 = and i32 %42, %18
  %47 = icmp eq i32 %46, 0
  %48 = select i1 %38, i1 true, i1 %47
  br i1 %48, label %merged.bb14, label %merged.bb15

; 循环深度 1，无可用位置
merged.bb14:
  %113 = add nsw i32 %36, -1
  br label %merged.bb

; 循环深度 1，末层检查
merged.bb15:
  %114 = add nuw nsw i32 %36, 1
  %115 = icmp eq i32 %114, %1
  %116 = select i1 %38, i1 true, i1 %115
  br i1 %116, label %merged.bb17, label %merged.bb16

; 循环深度 1，向下一层推进
merged.bb16:
  %117 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE4mask, i32 0, i32 %8, i32 %36
  %118 = load i32, i32 addrspace(3)* %117, align 4, !tbaa !8
  %119 = or i32 %118, %42
  %120 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE4mask, i32 0, i32 %8, i32 %114
  %121 = load i32, i32 addrspace(3)* %120, align 4
  %122 = select i1 %38, i32 %121, i32 %119
  store i32 %122, i32 addrspace(3)* %120, align 4, !tbaa !8
  %123 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6l_mask, i32 0, i32 %8, i32 %36
  %124 = load i32, i32 addrspace(3)* %123, align 4, !tbaa !8
  %125 = or i32 %124, %42
  %126 = shl i32 %125, 1
  %127 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6l_mask, i32 0, i32 %8, i32 %114
  %128 = load i32, i32 addrspace(3)* %127, align 4
  %129 = select i1 %38, i32 %128, i32 %126
  store i32 %129, i32 addrspace(3)* %127, align 4, !tbaa !8
  %130 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6r_mask, i32 0, i32 %8, i32 %36
  %131 = load i32, i32 addrspace(3)* %130, align 4, !tbaa !8
  %132 = or i32 %131, %42
  %133 = lshr i32 %132, 1
  %134 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6r_mask, i32 0, i32 %8, i32 %114
  %135 = load i32, i32 addrspace(3)* %134, align 4
  %136 = select i1 %38, i32 %135, i32 %133
  store i32 %136, i32 addrspace(3)* %134, align 4, !tbaa !8
  %137 = or i32 %126, %119
  %138 = or i32 %137, %133
  %139 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 %114
  %140 = load i32, i32 addrspace(3)* %139, align 4
  %141 = select i1 %38, i32 %140, i32 %138
  store i32 %141, i32 addrspace(3)* %139, align 4, !tbaa !8
  br label %merged.bb

; 循环深度 1，找到解并回退
merged.bb17:
  %142 = add nsw i32 %35, 1
  %143 = add nsw i32 %36, -1
  br label %merged.bb

; 循环深度 1，回环检查
merged.bb:
  %107 = phi i32 [ %113, %merged.bb14 ], [ undef, %merged.bb16 ], [ undef, %merged.bb17 ]
  %108 = phi i32 [ %142, %merged.bb17 ], [ %35, %merged.bb16 ], [ %35, %merged.bb14 ]
  %109 = phi i32 [ %143, %merged.bb17 ], [ %114, %merged.bb16 ], [ %113, %merged.bb14 ]
  %110 = select i1 %38, i32 %107, i32 %109
  %111 = select i1 %38, i32 %35, i32 %108
  %112 = icmp sgt i32 %110, -1
  br i1 %112, label %49, label %52, !llvm.loop !12

; 循环深度 1，latch，回读下一轮状态
49:
  %50 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 %110
  %51 = load i32, i32 addrspace(3)* %50, align 4, !tbaa !8
  br label %unify.bb

; 循环深度 0，exit，进入结果归约
52:
  %53 = phi i32 [ 0, %7 ], [ %111, %merged.bb ]
  %54 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %8
  store i32 %53, i32 addrspace(3)* %54, align 4, !tbaa !8
  fence syncscope("workgroup") release
  ; 其余归约见完整 IR

```

### C

[完整 IR](C.ll)

```llvm
; 循环深度 0，进入循环
20:
  %21 = sext i32 %16 to i64
  %22 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %21
  %23 = load i32, i32 addrspace(1)* %22, align 4, !tbaa !8
  %24 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE4mask, i32 0, i32 %8, i32 0
  store i32 %23, i32 addrspace(3)* %24, align 8, !tbaa !8
  %25 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %21
  %26 = load i32, i32 addrspace(1)* %25, align 4, !tbaa !8
  %27 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6l_mask, i32 0, i32 %8, i32 0
  store i32 %26, i32 addrspace(3)* %27, align 8, !tbaa !8
  %28 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %21
  %29 = load i32, i32 addrspace(1)* %28, align 4, !tbaa !8
  %30 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6r_mask, i32 0, i32 %8, i32 0
  store i32 %29, i32 addrspace(3)* %30, align 8, !tbaa !8
  %31 = or i32 %26, %23
  %32 = or i32 %31, %29
  %33 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 0
  store i32 %32, i32 addrspace(3)* %33, align 8, !tbaa !8
  br label %unify.bb

; 循环深度 1，头
unify.bb:
  %34 = phi i32 [ %32, %20 ], [ %55, %53 ]
  %35 = phi i32 [ 0, %20 ], [ %155, %53 ]
  %36 = phi i32 [ 0, %20 ], [ %154, %53 ]
  %37 = and i32 %34, %18
  %38 = icmp eq i32 %37, %18
  %39 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 %36
  %40 = add i32 %34, 1
  %41 = xor i32 %34, -1
  %42 = and i32 %40, %41
  %43 = or i32 %40, %34
  %44 = load i32, i32 addrspace(3)* %39, align 4
  %45 = select i1 %38, i32 %44, i32 %43
  store i32 %45, i32 addrspace(3)* %39, align 4, !tbaa !8
  %46 = and i32 %42, %18
  %47 = icmp eq i32 %46, 0
  %48 = select i1 %38, i1 true, i1 %47
  %49 = add nuw nsw i32 %36, 1
  %50 = icmp eq i32 %49, %1
  %51 = select i1 %38, i1 true, i1 %50
  %52 = select i1 %48, i1 true, i1 %51
  br i1 %52, label %merged.bb33, label %merged.bb32

; 循环深度 1，向下一层推进
merged.bb32:
  %111 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE4mask, i32 0, i32 %8, i32 %36
  %112 = load i32, i32 addrspace(3)* %111, align 4, !tbaa !8
  %113 = or i32 %112, %42
  %114 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE4mask, i32 0, i32 %8, i32 %49
  %115 = load i32, i32 addrspace(3)* %114, align 4
  %116 = select i1 %38, i32 %115, i32 %113
  %117 = load i32, i32 addrspace(3)* %114, align 4
  %118 = select i1 %48, i32 %117, i32 %116
  store i32 %118, i32 addrspace(3)* %114, align 4, !tbaa !8
  %119 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6l_mask, i32 0, i32 %8, i32 %36
  %120 = load i32, i32 addrspace(3)* %119, align 4, !tbaa !8
  %121 = or i32 %120, %42
  %122 = shl i32 %121, 1
  %123 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6l_mask, i32 0, i32 %8, i32 %49
  %124 = load i32, i32 addrspace(3)* %123, align 4
  %125 = select i1 %38, i32 %124, i32 %122
  %126 = load i32, i32 addrspace(3)* %123, align 4
  %127 = select i1 %48, i32 %126, i32 %125
  store i32 %127, i32 addrspace(3)* %123, align 4, !tbaa !8
  %128 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6r_mask, i32 0, i32 %8, i32 %36
  %129 = load i32, i32 addrspace(3)* %128, align 4, !tbaa !8
  %130 = or i32 %129, %42
  %131 = lshr i32 %130, 1
  %132 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6r_mask, i32 0, i32 %8, i32 %49
  %133 = load i32, i32 addrspace(3)* %132, align 4
  %134 = select i1 %38, i32 %133, i32 %131
  %135 = load i32, i32 addrspace(3)* %132, align 4
  %136 = select i1 %48, i32 %135, i32 %134
  store i32 %136, i32 addrspace(3)* %132, align 4, !tbaa !8
  %137 = or i32 %122, %113
  %138 = or i32 %137, %131
  %139 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 %49
  %140 = load i32, i32 addrspace(3)* %139, align 4
  %141 = select i1 %38, i32 %140, i32 %138
  %142 = load i32, i32 addrspace(3)* %139, align 4
  %143 = select i1 %48, i32 %142, i32 %141
  store i32 %143, i32 addrspace(3)* %139, align 4, !tbaa !8
  br label %merged.bb34

; 循环深度 1，合并的回退路径
merged.bb33:
  %144 = add nsw i32 %35, 1
  %145 = select i1 %48, i32 undef, i32 %144
  %146 = add nsw i32 %36, -1
  br label %merged.bb34

; 循环深度 1，回环检查
merged.bb34:
  %147 = phi i32 [ undef, %merged.bb32 ], [ %146, %merged.bb33 ]
  %148 = phi i32 [ %146, %merged.bb33 ], [ %49, %merged.bb32 ]
  %149 = phi i32 [ %145, %merged.bb33 ], [ %35, %merged.bb32 ]
  %150 = phi i32 [ undef, %merged.bb33 ], [ undef, %merged.bb32 ]
  %151 = select i1 %48, i32 %147, i32 %150
  %152 = select i1 %48, i32 %35, i32 %149
  %153 = select i1 %48, i32 %147, i32 %148
  %154 = select i1 %38, i32 %151, i32 %153
  %155 = select i1 %38, i32 %35, i32 %152
  %156 = icmp sgt i32 %154, -1
  br i1 %156, label %53, label %56, !llvm.loop !12

; 循环深度 1，latch，回读下一轮状态
53:
  %54 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 %154
  %55 = load i32, i32 addrspace(3)* %54, align 4, !tbaa !8
  br label %unify.bb

; 循环深度 0，exit，进入结果归约
56:
  %57 = phi i32 [ 0, %7 ], [ %155, %merged.bb34 ]
  %58 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %8
  store i32 %57, i32 addrspace(3)* %58, align 4, !tbaa !8
  fence syncscope("workgroup") release
  ; 其余归约见完整 IR

```

## LLVM12 O3 后

### P

[完整 IR](P.o3.ll)

```llvm
; 循环深度 0，进入循环
20:
  %21 = sext i32 %16 to i64
  %22 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %21
  %23 = load i32, i32 addrspace(1)* %22, align 4, !tbaa !8
  %24 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE4mask, i32 0, i32 %8, i32 0
  store i32 %23, i32 addrspace(3)* %24, align 8, !tbaa !8
  %25 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %21
  %26 = load i32, i32 addrspace(1)* %25, align 4, !tbaa !8
  %27 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6l_mask, i32 0, i32 %8, i32 0
  store i32 %26, i32 addrspace(3)* %27, align 8, !tbaa !8
  %28 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %21
  %29 = load i32, i32 addrspace(1)* %28, align 4, !tbaa !8
  %30 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6r_mask, i32 0, i32 %8, i32 0
  store i32 %29, i32 addrspace(3)* %30, align 8, !tbaa !8
  %31 = or i32 %26, %23
  %32 = or i32 %31, %29
  %33 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 0
  store i32 %32, i32 addrspace(3)* %33, align 8, !tbaa !8
  br label %unify.bb

; 循环深度 1，头
unify.bb:
  %34 = phi i32 [ %32, %20 ], [ %50, %48 ]
  %35 = phi i32 [ 0, %20 ], [ %108, %48 ]
  %36 = phi i32 [ 0, %20 ], [ %107, %48 ]
  %37 = and i32 %34, %18
  %38 = icmp eq i32 %37, %18
  %39 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 %36
  %40 = add i32 %34, 1
  %41 = xor i32 %34, -1
  %42 = and i32 %40, %41
  %43 = select i1 %38, i32 0, i32 %40
  %44 = or i32 %34, %43
  store i32 %44, i32 addrspace(3)* %39, align 4, !tbaa !8
  %45 = and i32 %42, %18
  %46 = icmp eq i32 %45, 0
  %47 = or i1 %38, %46
  br i1 %47, label %merged.bb14, label %merged.bb15

; 循环深度 1，无可用位置
merged.bb14:
  %110 = add nsw i32 %36, -1
  br label %merged.bb

; 循环深度 1，末层检查
merged.bb15:
  %111 = add nuw nsw i32 %36, 1
  %112 = icmp eq i32 %111, %1
  br i1 %112, label %merged.bb17, label %merged.bb16

; 循环深度 1，向下一层推进
merged.bb16:
  %113 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE4mask, i32 0, i32 %8, i32 %36
  %114 = load i32, i32 addrspace(3)* %113, align 4, !tbaa !8
  %115 = or i32 %114, %42
  %116 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE4mask, i32 0, i32 %8, i32 %111
  store i32 %115, i32 addrspace(3)* %116, align 4, !tbaa !8
  %117 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6l_mask, i32 0, i32 %8, i32 %36
  %118 = load i32, i32 addrspace(3)* %117, align 4, !tbaa !8
  %119 = or i32 %118, %42
  %120 = shl i32 %119, 1
  %121 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6l_mask, i32 0, i32 %8, i32 %111
  store i32 %120, i32 addrspace(3)* %121, align 4, !tbaa !8
  %122 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6r_mask, i32 0, i32 %8, i32 %36
  %123 = load i32, i32 addrspace(3)* %122, align 4, !tbaa !8
  %124 = or i32 %123, %42
  %125 = lshr i32 %124, 1
  %126 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6r_mask, i32 0, i32 %8, i32 %111
  store i32 %125, i32 addrspace(3)* %126, align 4, !tbaa !8
  %127 = or i32 %120, %115
  %128 = or i32 %127, %125
  %129 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 %111
  store i32 %128, i32 addrspace(3)* %129, align 4, !tbaa !8
  br label %merged.bb

; 循环深度 1，找到解并回退
merged.bb17:
  %130 = add nsw i32 %35, 1
  %131 = add nsw i32 %36, -1
  br label %merged.bb

; 循环深度 1，回环检查
merged.bb:
  %104 = phi i32 [ %110, %merged.bb14 ], [ undef, %merged.bb16 ], [ undef, %merged.bb17 ]
  %105 = phi i32 [ %35, %merged.bb14 ], [ %35, %merged.bb16 ], [ %130, %merged.bb17 ]
  %106 = phi i32 [ %110, %merged.bb14 ], [ %111, %merged.bb16 ], [ %131, %merged.bb17 ]
  %107 = select i1 %38, i32 %104, i32 %106
  %108 = select i1 %38, i32 %35, i32 %105
  %109 = icmp sgt i32 %107, -1
  br i1 %109, label %48, label %.loopexit, !llvm.loop !12

; 循环深度 1，latch，回读下一轮状态
48:
  %49 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 %107
  %50 = load i32, i32 addrspace(3)* %49, align 4, !tbaa !8
  br label %unify.bb

; 循环深度 0，exit，进入结果归约
.loopexit:
  %51 = phi i32 [ 0, %7 ], [ %108, %merged.bb ]
  %52 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %8
  store i32 %51, i32 addrspace(3)* %52, align 4, !tbaa !8
  fence syncscope("workgroup") release
  ; 其余归约见完整 IR

```

### C

[完整 IR](C.o3.ll)

```llvm
; 循环深度 0，进入循环
20:
  %21 = sext i32 %16 to i64
  %22 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %21
  %23 = load i32, i32 addrspace(1)* %22, align 4, !tbaa !8
  %24 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE4mask, i32 0, i32 %8, i32 0
  store i32 %23, i32 addrspace(3)* %24, align 8, !tbaa !8
  %25 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %21
  %26 = load i32, i32 addrspace(1)* %25, align 4, !tbaa !8
  %27 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6l_mask, i32 0, i32 %8, i32 0
  store i32 %26, i32 addrspace(3)* %27, align 8, !tbaa !8
  %28 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %21
  %29 = load i32, i32 addrspace(1)* %28, align 4, !tbaa !8
  %30 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6r_mask, i32 0, i32 %8, i32 0
  store i32 %29, i32 addrspace(3)* %30, align 8, !tbaa !8
  %31 = or i32 %26, %23
  %32 = or i32 %31, %29
  %33 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 0
  store i32 %32, i32 addrspace(3)* %33, align 8, !tbaa !8
  br label %unify.bb

; 循环深度 1，头
unify.bb:
  %34 = phi i32 [ %32, %20 ], [ %53, %51 ]
  %35 = phi i32 [ 0, %20 ], [ %133, %51 ]
  %36 = phi i32 [ 0, %20 ], [ %132, %51 ]
  %37 = and i32 %34, %18
  %38 = icmp eq i32 %37, %18
  %39 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 %36
  %40 = add i32 %34, 1
  %41 = xor i32 %34, -1
  %42 = and i32 %40, %41
  %43 = select i1 %38, i32 0, i32 %40
  %44 = or i32 %34, %43
  store i32 %44, i32 addrspace(3)* %39, align 4, !tbaa !8
  %45 = and i32 %42, %18
  %46 = icmp eq i32 %45, 0
  %47 = or i1 %38, %46
  %48 = add nuw nsw i32 %36, 1
  %49 = icmp eq i32 %48, %1
  %50 = or i1 %49, %47
  br i1 %50, label %merged.bb33, label %merged.bb32

; 循环深度 1，向下一层推进
merged.bb32:
  %107 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE4mask, i32 0, i32 %8, i32 %36
  %108 = load i32, i32 addrspace(3)* %107, align 4, !tbaa !8
  %109 = or i32 %108, %42
  %110 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE4mask, i32 0, i32 %8, i32 %48
  store i32 %109, i32 addrspace(3)* %110, align 4, !tbaa !8
  %111 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6l_mask, i32 0, i32 %8, i32 %36
  %112 = load i32, i32 addrspace(3)* %111, align 4, !tbaa !8
  %113 = or i32 %112, %42
  %114 = shl i32 %113, 1
  %115 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6l_mask, i32 0, i32 %8, i32 %48
  store i32 %114, i32 addrspace(3)* %115, align 4, !tbaa !8
  %116 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6r_mask, i32 0, i32 %8, i32 %36
  %117 = load i32, i32 addrspace(3)* %116, align 4, !tbaa !8
  %118 = or i32 %117, %42
  %119 = lshr i32 %118, 1
  %120 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6r_mask, i32 0, i32 %8, i32 %48
  store i32 %119, i32 addrspace(3)* %120, align 4, !tbaa !8
  %121 = or i32 %114, %109
  %122 = or i32 %121, %119
  %123 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 %48
  store i32 %122, i32 addrspace(3)* %123, align 4, !tbaa !8
  br label %merged.bb34

; 循环深度 1，合并的回退路径
merged.bb33:
  %124 = add nsw i32 %35, 1
  %125 = select i1 %47, i32 undef, i32 %124
  %126 = add nsw i32 %36, -1
  br label %merged.bb34

; 循环深度 1，回环检查
merged.bb34:
  %127 = phi i32 [ undef, %merged.bb32 ], [ %126, %merged.bb33 ]
  %128 = phi i32 [ %48, %merged.bb32 ], [ %126, %merged.bb33 ]
  %129 = phi i32 [ %35, %merged.bb32 ], [ %125, %merged.bb33 ]
  %130 = select i1 %47, i32 %127, i32 undef
  %131 = select i1 %47, i32 %127, i32 %128
  %132 = select i1 %38, i32 %130, i32 %131
  %133 = select i1 %47, i32 %35, i32 %129
  %134 = icmp sgt i32 %132, -1
  br i1 %134, label %51, label %.loopexit, !llvm.loop !12

; 循环深度 1，latch，回读下一轮状态
51:
  %52 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 %132
  %53 = load i32, i32 addrspace(3)* %52, align 4, !tbaa !8
  br label %unify.bb

; 循环深度 0，exit，进入结果归约
.loopexit:
  %54 = phi i32 [ 0, %7 ], [ %133, %merged.bb34 ]
  %55 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %8
  store i32 %54, i32 addrspace(3)* %55, align 4, !tbaa !8
  fence syncscope("workgroup") release
  ; 其余归约见完整 IR

```
