; ModuleID = '/data/home/chh/simplify-v2-study-nqu/build/nqu-second-fusion/20261120-v1/P.ll'
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
  br i1 %19, label %20, label %.loopexit

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

unify.bb:                                         ; preds = %48, %20
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

48:                                               ; preds = %merged.bb
  %49 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 %107
  %50 = load i32, i32 addrspace(3)* %49, align 4, !tbaa !8
  br label %unify.bb

.loopexit:                                        ; preds = %merged.bb, %7
  %51 = phi i32 [ 0, %7 ], [ %108, %merged.bb ]
  %52 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %8
  store i32 %51, i32 addrspace(3)* %52, align 4, !tbaa !8
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %53 = icmp ult i32 %8, 32
  br i1 %53, label %54, label %60

54:                                               ; preds = %.loopexit
  %55 = add nuw nsw i32 %8, 32
  %56 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %55
  %57 = load i32, i32 addrspace(3)* %56, align 4, !tbaa !8
  %58 = load i32, i32 addrspace(3)* %52, align 4, !tbaa !8
  %59 = add i32 %58, %57
  store i32 %59, i32 addrspace(3)* %52, align 4, !tbaa !8
  br label %60

60:                                               ; preds = %54, %.loopexit
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %61 = icmp ult i32 %8, 16
  br i1 %61, label %62, label %68

62:                                               ; preds = %60
  %63 = add nuw nsw i32 %8, 16
  %64 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %63
  %65 = load i32, i32 addrspace(3)* %64, align 4, !tbaa !8
  %66 = load i32, i32 addrspace(3)* %52, align 4, !tbaa !8
  %67 = add i32 %66, %65
  store i32 %67, i32 addrspace(3)* %52, align 4, !tbaa !8
  br label %68

68:                                               ; preds = %62, %60
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %69 = icmp ult i32 %8, 8
  br i1 %69, label %70, label %76

70:                                               ; preds = %68
  %71 = add nuw nsw i32 %8, 8
  %72 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %71
  %73 = load i32, i32 addrspace(3)* %72, align 4, !tbaa !8
  %74 = load i32, i32 addrspace(3)* %52, align 4, !tbaa !8
  %75 = add i32 %74, %73
  store i32 %75, i32 addrspace(3)* %52, align 4, !tbaa !8
  br label %76

76:                                               ; preds = %70, %68
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %77 = icmp ult i32 %8, 4
  br i1 %77, label %78, label %84

78:                                               ; preds = %76
  %79 = add nuw nsw i32 %8, 4
  %80 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %79
  %81 = load i32, i32 addrspace(3)* %80, align 4, !tbaa !8
  %82 = load i32, i32 addrspace(3)* %52, align 4, !tbaa !8
  %83 = add i32 %82, %81
  store i32 %83, i32 addrspace(3)* %52, align 4, !tbaa !8
  br label %84

84:                                               ; preds = %78, %76
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %85 = icmp ult i32 %8, 2
  br i1 %85, label %86, label %92

86:                                               ; preds = %84
  %87 = add nuw nsw i32 %8, 2
  %88 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %87
  %89 = load i32, i32 addrspace(3)* %88, align 4, !tbaa !8
  %90 = load i32, i32 addrspace(3)* %52, align 4, !tbaa !8
  %91 = add i32 %90, %89
  store i32 %91, i32 addrspace(3)* %52, align 4, !tbaa !8
  br label %92

92:                                               ; preds = %86, %84
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %93 = icmp eq i32 %8, 0
  br i1 %93, label %94, label %98

94:                                               ; preds = %92
  %95 = load i32, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 1), align 4, !tbaa !8
  %96 = load i32, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 0), align 16, !tbaa !8
  %97 = add i32 %96, %95
  store i32 %97, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 0), align 16, !tbaa !8
  br label %98

98:                                               ; preds = %94, %92
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %93, label %99, label %103

99:                                               ; preds = %98
  %100 = sext i32 %9 to i64
  %101 = getelementptr inbounds i32, i32 addrspace(1)* %5, i64 %100
  %102 = load i32, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 0), align 16, !tbaa !8
  store i32 %102, i32 addrspace(1)* %101, align 4, !tbaa !8
  br label %103

103:                                              ; preds = %99, %98
  ret void

merged.bb:                                        ; preds = %merged.bb17, %merged.bb16, %merged.bb14
  %104 = phi i32 [ %110, %merged.bb14 ], [ undef, %merged.bb16 ], [ undef, %merged.bb17 ]
  %105 = phi i32 [ %35, %merged.bb14 ], [ %35, %merged.bb16 ], [ %130, %merged.bb17 ]
  %106 = phi i32 [ %110, %merged.bb14 ], [ %111, %merged.bb16 ], [ %131, %merged.bb17 ]
  %107 = select i1 %38, i32 %104, i32 %106
  %108 = select i1 %38, i32 %35, i32 %105
  %109 = icmp sgt i32 %107, -1
  br i1 %109, label %48, label %.loopexit, !llvm.loop !12

merged.bb14:                                      ; preds = %unify.bb
  %110 = add nsw i32 %36, -1
  br label %merged.bb

merged.bb15:                                      ; preds = %unify.bb
  %111 = add nuw nsw i32 %36, 1
  %112 = icmp eq i32 %111, %1
  br i1 %112, label %merged.bb17, label %merged.bb16

merged.bb16:                                      ; preds = %merged.bb15
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

merged.bb17:                                      ; preds = %merged.bb15
  %130 = add nsw i32 %35, 1
  %131 = add nsw i32 %36, -1
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
