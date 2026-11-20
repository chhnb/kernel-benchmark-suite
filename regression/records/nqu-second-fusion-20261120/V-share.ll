; ModuleID = 'build/auto-darm-release-compare/20261120-v1/NQU64/baseline.ll'
source_filename = "/data/home/chh/kernel-benchmark-suite/build/full-regression-rerun/snapshot.TxCJ3u/artifact-benchmarks/benchmarks/NQU/nqueen.hip.cpp"
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
@_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE4mask = internal unnamed_addr addrspace(3) global [64 x [10 x i32]] undef, align 16
@_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6l_mask = internal unnamed_addr addrspace(3) global [64 x [10 x i32]] undef, align 16
@_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6r_mask = internal unnamed_addr addrspace(3) global [64 x [10 x i32]] undef, align 16
@_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m = internal unnamed_addr addrspace(3) global [64 x [10 x i32]] undef, align 16
@_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum = internal unnamed_addr addrspace(3) global [64 x i32] undef, align 16

; Function Attrs: convergent norecurse nounwind
define protected amdgpu_kernel void @_Z24solve_nqueen_cuda_kerneliiPjS_S_S_i(i32 %0, i32 %1, i32 addrspace(1)* nocapture readonly %2, i32 addrspace(1)* nocapture readonly %3, i32 addrspace(1)* nocapture readonly %4, i32 addrspace(1)* nocapture %5, i32 %6) local_unnamed_addr #0 {
  %8 = tail call i32 @llvm.amdgcn.workitem.id.x() #3, !range !5
  %9 = tail call i32 @llvm.amdgcn.workgroup.id.x() #3
  %10 = tail call align 4 dereferenceable(64) i8 addrspace(4)* @llvm.amdgcn.dispatch.ptr() #3
  %11 = getelementptr i8, i8 addrspace(4)* %10, i64 4
  %12 = bitcast i8 addrspace(4)* %11 to i16 addrspace(4)*
  %13 = load i16, i16 addrspace(4)* %12, align 4, !range !6, !invariant.load !7
  %14 = zext i16 %13 to i32
  %15 = mul i32 %9, %14
  %16 = add i32 %15, %8
  %17 = shl nsw i32 -1, %0
  %18 = xor i32 %17, -1
  %19 = icmp slt i32 %16, %6
  br i1 %19, label %20, label %52

20:                                               ; preds = %7
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

unify.bb:                                         ; preds = %49, %20
  %34 = phi i32 [ %32, %20 ], [ %51, %49 ]
  %35 = phi i32 [ 0, %20 ], [ %orig.111, %49 ]
  %36 = phi i32 [ 0, %20 ], [ %orig.110, %49 ]
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
  %study.shared.previous = add nsw i32 %36, -1
  br i1 %48, label %merged.bb14, label %merged.bb15

49:                                               ; preds = %merged.bb
  %50 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 %orig.110
  %51 = load i32, i32 addrspace(3)* %50, align 4, !tbaa !8
  br label %unify.bb

52:                                               ; preds = %merged.bb, %7
  %53 = phi i32 [ 0, %7 ], [ %orig.111, %merged.bb ]
  %54 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %8
  store i32 %53, i32 addrspace(3)* %54, align 4, !tbaa !8
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %55 = icmp ult i32 %8, 32
  %56 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %8
  br i1 %55, label %57, label %63

57:                                               ; preds = %52
  %58 = add nuw nsw i32 %8, 32
  %59 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %58
  %60 = load i32, i32 addrspace(3)* %59, align 4, !tbaa !8
  %61 = load i32, i32 addrspace(3)* %56, align 4, !tbaa !8
  %62 = add i32 %61, %60
  store i32 %62, i32 addrspace(3)* %56, align 4, !tbaa !8
  br label %63

63:                                               ; preds = %57, %52
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %64 = icmp ult i32 %8, 16
  br i1 %64, label %65, label %71

65:                                               ; preds = %63
  %66 = add nuw nsw i32 %8, 16
  %67 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %66
  %68 = load i32, i32 addrspace(3)* %67, align 4, !tbaa !8
  %69 = load i32, i32 addrspace(3)* %56, align 4, !tbaa !8
  %70 = add i32 %69, %68
  store i32 %70, i32 addrspace(3)* %56, align 4, !tbaa !8
  br label %71

71:                                               ; preds = %65, %63
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %72 = icmp ult i32 %8, 8
  br i1 %72, label %73, label %79

73:                                               ; preds = %71
  %74 = add nuw nsw i32 %8, 8
  %75 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %74
  %76 = load i32, i32 addrspace(3)* %75, align 4, !tbaa !8
  %77 = load i32, i32 addrspace(3)* %56, align 4, !tbaa !8
  %78 = add i32 %77, %76
  store i32 %78, i32 addrspace(3)* %56, align 4, !tbaa !8
  br label %79

79:                                               ; preds = %73, %71
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %80 = icmp ult i32 %8, 4
  br i1 %80, label %81, label %87

81:                                               ; preds = %79
  %82 = add nuw nsw i32 %8, 4
  %83 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %82
  %84 = load i32, i32 addrspace(3)* %83, align 4, !tbaa !8
  %85 = load i32, i32 addrspace(3)* %56, align 4, !tbaa !8
  %86 = add i32 %85, %84
  store i32 %86, i32 addrspace(3)* %56, align 4, !tbaa !8
  br label %87

87:                                               ; preds = %81, %79
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %88 = icmp ult i32 %8, 2
  br i1 %88, label %89, label %95

89:                                               ; preds = %87
  %90 = add nuw nsw i32 %8, 2
  %91 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %90
  %92 = load i32, i32 addrspace(3)* %91, align 4, !tbaa !8
  %93 = load i32, i32 addrspace(3)* %56, align 4, !tbaa !8
  %94 = add i32 %93, %92
  store i32 %94, i32 addrspace(3)* %56, align 4, !tbaa !8
  br label %95

95:                                               ; preds = %89, %87
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %96 = icmp eq i32 %8, 0
  br i1 %96, label %97, label %101

97:                                               ; preds = %95
  %98 = load i32, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 1), align 4, !tbaa !8
  %99 = load i32, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 0), align 16, !tbaa !8
  %100 = add i32 %99, %98
  store i32 %100, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 0), align 16, !tbaa !8
  br label %101

101:                                              ; preds = %97, %95
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %96, label %102, label %106

102:                                              ; preds = %101
  %103 = sext i32 %9 to i64
  %104 = getelementptr inbounds i32, i32 addrspace(1)* %5, i64 %103
  %105 = load i32, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 0), align 16, !tbaa !8
  store i32 %105, i32 addrspace(1)* %104, align 4, !tbaa !8
  br label %106

106:                                              ; preds = %102, %101
  ret void

merged.bb:                                        ; preds = %merged.bb14, %merged.bb16, %merged.bb17
  %orig.107 = phi i32 [ %study.shared.previous, %merged.bb14 ], [ undef, %merged.bb16 ], [ undef, %merged.bb17 ]
  %orig.108 = phi i32 [ %orig.142, %merged.bb17 ], [ %35, %merged.bb16 ], [ %35, %merged.bb14 ]
  %orig.109 = phi i32 [ %study.shared.previous, %merged.bb17 ], [ %orig.114, %merged.bb16 ], [ %study.shared.previous, %merged.bb14 ]
  %orig.110 = select i1 %38, i32 %orig.107, i32 %orig.109
  %orig.111 = select i1 %38, i32 %35, i32 %orig.108
  %orig.112 = icmp sgt i32 %orig.110, -1
  br i1 %orig.112, label %49, label %52, !llvm.loop !12

merged.bb14:                                      ; preds = %unify.bb
  br label %merged.bb

merged.bb15:                                      ; preds = %unify.bb
  %orig.114 = add nuw nsw i32 %36, 1
  %orig.115 = icmp eq i32 %orig.114, %1
  %orig.116 = select i1 %38, i1 true, i1 %orig.115
  br i1 %orig.116, label %merged.bb17, label %merged.bb16

merged.bb16:                                      ; preds = %merged.bb15
  %orig.117 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE4mask, i32 0, i32 %8, i32 %36
  %orig.118 = load i32, i32 addrspace(3)* %orig.117, align 4, !tbaa !8
  %orig.119 = or i32 %orig.118, %42
  %orig.120 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE4mask, i32 0, i32 %8, i32 %orig.114
  %orig.121 = load i32, i32 addrspace(3)* %orig.120, align 4
  %orig.122 = select i1 %38, i32 %orig.121, i32 %orig.119
  store i32 %orig.122, i32 addrspace(3)* %orig.120, align 4, !tbaa !8
  %orig.123 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6l_mask, i32 0, i32 %8, i32 %36
  %orig.124 = load i32, i32 addrspace(3)* %orig.123, align 4, !tbaa !8
  %orig.125 = or i32 %orig.124, %42
  %orig.126 = shl i32 %orig.125, 1
  %orig.127 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6l_mask, i32 0, i32 %8, i32 %orig.114
  %orig.128 = load i32, i32 addrspace(3)* %orig.127, align 4
  %orig.129 = select i1 %38, i32 %orig.128, i32 %orig.126
  store i32 %orig.129, i32 addrspace(3)* %orig.127, align 4, !tbaa !8
  %orig.130 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6r_mask, i32 0, i32 %8, i32 %36
  %orig.131 = load i32, i32 addrspace(3)* %orig.130, align 4, !tbaa !8
  %orig.132 = or i32 %orig.131, %42
  %orig.133 = lshr i32 %orig.132, 1
  %orig.134 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6r_mask, i32 0, i32 %8, i32 %orig.114
  %orig.135 = load i32, i32 addrspace(3)* %orig.134, align 4
  %orig.136 = select i1 %38, i32 %orig.135, i32 %orig.133
  store i32 %orig.136, i32 addrspace(3)* %orig.134, align 4, !tbaa !8
  %orig.137 = or i32 %orig.126, %orig.119
  %orig.138 = or i32 %orig.137, %orig.133
  %orig.139 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 %orig.114
  %orig.140 = load i32, i32 addrspace(3)* %orig.139, align 4
  %orig.141 = select i1 %38, i32 %orig.140, i32 %orig.138
  store i32 %orig.141, i32 addrspace(3)* %orig.139, align 4, !tbaa !8
  br label %merged.bb

merged.bb17:                                      ; preds = %merged.bb15
  %orig.142 = add nsw i32 %35, 1
  br label %merged.bb
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
