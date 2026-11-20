; ModuleID = '/data/home/chh/simplify-v2-study-nqu/build/nqu-second-fusion/followup/historical-dp1/trial-0/fused.ll'
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
  br i1 %19, label %20, label %54

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

unify.bb:                                         ; preds = %51, %20
  %34 = phi i32 [ %32, %20 ], [ %53, %51 ]
  %35 = phi i32 [ 0, %20 ], [ %136, %51 ]
  %36 = phi i32 [ 0, %20 ], [ %135, %51 ]
  %37 = and i32 %34, %18
  %38 = icmp eq i32 %37, %18
  %39 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 %36
  %40 = add i32 %34, 1
  %41 = xor i32 %34, -1
  %42 = and i32 %40, %41
  %43 = or i32 %40, %34
  store i32 %43, i32 addrspace(3)* %39, align 4, !tbaa !8
  %44 = and i32 %42, %18
  %45 = icmp eq i32 %44, 0
  %46 = select i1 %38, i1 false, i1 %45
  %47 = add nuw nsw i32 %36, 1
  %48 = icmp eq i32 %47, %1
  %49 = select i1 %38, i1 true, i1 %48
  %50 = select i1 %46, i1 true, i1 %49
  br i1 %50, label %merged.bb12, label %merged.bb18

51:                                               ; preds = %merged.bb19
  %52 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 %135
  %53 = load i32, i32 addrspace(3)* %52, align 4, !tbaa !8
  br label %unify.bb

54:                                               ; preds = %merged.bb19, %7
  %55 = phi i32 [ 0, %7 ], [ %136, %merged.bb19 ]
  %56 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %8
  store i32 %55, i32 addrspace(3)* %56, align 4, !tbaa !8
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %57 = icmp ult i32 %8, 32
  br i1 %57, label %58, label %64

58:                                               ; preds = %54
  %59 = add nuw nsw i32 %8, 32
  %60 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %59
  %61 = load i32, i32 addrspace(3)* %60, align 4, !tbaa !8
  %62 = load i32, i32 addrspace(3)* %56, align 4, !tbaa !8
  %63 = add i32 %62, %61
  store i32 %63, i32 addrspace(3)* %56, align 4, !tbaa !8
  br label %64

64:                                               ; preds = %58, %54
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %65 = icmp ult i32 %8, 16
  br i1 %65, label %66, label %72

66:                                               ; preds = %64
  %67 = add nuw nsw i32 %8, 16
  %68 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %67
  %69 = load i32, i32 addrspace(3)* %68, align 4, !tbaa !8
  %70 = load i32, i32 addrspace(3)* %56, align 4, !tbaa !8
  %71 = add i32 %70, %69
  store i32 %71, i32 addrspace(3)* %56, align 4, !tbaa !8
  br label %72

72:                                               ; preds = %66, %64
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %73 = icmp ult i32 %8, 8
  br i1 %73, label %74, label %80

74:                                               ; preds = %72
  %75 = add nuw nsw i32 %8, 8
  %76 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %75
  %77 = load i32, i32 addrspace(3)* %76, align 4, !tbaa !8
  %78 = load i32, i32 addrspace(3)* %56, align 4, !tbaa !8
  %79 = add i32 %78, %77
  store i32 %79, i32 addrspace(3)* %56, align 4, !tbaa !8
  br label %80

80:                                               ; preds = %74, %72
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %81 = icmp ult i32 %8, 4
  br i1 %81, label %82, label %88

82:                                               ; preds = %80
  %83 = add nuw nsw i32 %8, 4
  %84 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %83
  %85 = load i32, i32 addrspace(3)* %84, align 4, !tbaa !8
  %86 = load i32, i32 addrspace(3)* %56, align 4, !tbaa !8
  %87 = add i32 %86, %85
  store i32 %87, i32 addrspace(3)* %56, align 4, !tbaa !8
  br label %88

88:                                               ; preds = %82, %80
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %89 = icmp ult i32 %8, 2
  br i1 %89, label %90, label %96

90:                                               ; preds = %88
  %91 = add nuw nsw i32 %8, 2
  %92 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %91
  %93 = load i32, i32 addrspace(3)* %92, align 4, !tbaa !8
  %94 = load i32, i32 addrspace(3)* %56, align 4, !tbaa !8
  %95 = add i32 %94, %93
  store i32 %95, i32 addrspace(3)* %56, align 4, !tbaa !8
  br label %96

96:                                               ; preds = %90, %88
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %97 = icmp eq i32 %8, 0
  br i1 %97, label %98, label %102

98:                                               ; preds = %96
  %99 = load i32, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 1), align 4, !tbaa !8
  %100 = load i32, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 0), align 16, !tbaa !8
  %101 = add i32 %100, %99
  store i32 %101, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 0), align 16, !tbaa !8
  br label %102

102:                                              ; preds = %98, %96
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %97, label %103, label %107

103:                                              ; preds = %102
  %104 = sext i32 %9 to i64
  %105 = getelementptr inbounds i32, i32 addrspace(1)* %5, i64 %104
  %106 = load i32, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 0), align 16, !tbaa !8
  store i32 %106, i32 addrspace(1)* %105, align 4, !tbaa !8
  br label %107

107:                                              ; preds = %103, %102
  ret void

merged.bb12:                                      ; preds = %unify.bb
  %108 = add nsw i32 %35, 1
  %109 = select i1 %38, i32 undef, i32 %108
  %110 = select i1 %46, i32 undef, i32 %109
  %111 = add nsw i32 %36, -1
  br label %merged.bb19

merged.bb18:                                      ; preds = %unify.bb
  %112 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE4mask, i32 0, i32 %8, i32 %36
  %113 = load i32, i32 addrspace(3)* %112, align 4, !tbaa !8
  %114 = or i32 %113, %42
  %115 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE4mask, i32 0, i32 %8, i32 %47
  store i32 %114, i32 addrspace(3)* %115, align 4, !tbaa !8
  %116 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6l_mask, i32 0, i32 %8, i32 %36
  %117 = load i32, i32 addrspace(3)* %116, align 4, !tbaa !8
  %118 = or i32 %117, %42
  %119 = shl i32 %118, 1
  %120 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6l_mask, i32 0, i32 %8, i32 %47
  store i32 %119, i32 addrspace(3)* %120, align 4, !tbaa !8
  %121 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6r_mask, i32 0, i32 %8, i32 %36
  %122 = load i32, i32 addrspace(3)* %121, align 4, !tbaa !8
  %123 = or i32 %122, %42
  %124 = lshr i32 %123, 1
  %125 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE6r_mask, i32 0, i32 %8, i32 %47
  store i32 %124, i32 addrspace(3)* %125, align 4, !tbaa !8
  %126 = or i32 %119, %114
  %127 = or i32 %126, %124
  %128 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 %47
  store i32 %127, i32 addrspace(3)* %128, align 4, !tbaa !8
  br label %merged.bb19

merged.bb19:                                      ; preds = %merged.bb18, %merged.bb12
  %129 = phi i32 [ %111, %merged.bb12 ], [ undef, %merged.bb18 ]
  %130 = phi i32 [ %111, %merged.bb12 ], [ %47, %merged.bb18 ]
  %131 = phi i32 [ %110, %merged.bb12 ], [ %35, %merged.bb18 ]
  %132 = select i1 %46, i32 undef, i32 %129
  %133 = select i1 %46, i32 %35, i32 %131
  %134 = select i1 %46, i32 %129, i32 %130
  %135 = select i1 %38, i32 %132, i32 %134
  %136 = select i1 %38, i32 %35, i32 %133
  %137 = icmp sgt i32 %135, -1
  br i1 %137, label %51, label %54, !llvm.loop !12
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
