; ModuleID = '/data/home/chh/simplify-v2-study-nqu/build/nqu-second-fusion/20261120-v1/C.ll'
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

unify.bb:                                         ; preds = %51, %20
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

51:                                               ; preds = %merged.bb34
  %52 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 %132
  %53 = load i32, i32 addrspace(3)* %52, align 4, !tbaa !8
  br label %unify.bb

.loopexit:                                        ; preds = %merged.bb34, %7
  %54 = phi i32 [ 0, %7 ], [ %133, %merged.bb34 ]
  %55 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %8
  store i32 %54, i32 addrspace(3)* %55, align 4, !tbaa !8
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %56 = icmp ult i32 %8, 32
  br i1 %56, label %57, label %63

57:                                               ; preds = %.loopexit
  %58 = add nuw nsw i32 %8, 32
  %59 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %58
  %60 = load i32, i32 addrspace(3)* %59, align 4, !tbaa !8
  %61 = load i32, i32 addrspace(3)* %55, align 4, !tbaa !8
  %62 = add i32 %61, %60
  store i32 %62, i32 addrspace(3)* %55, align 4, !tbaa !8
  br label %63

63:                                               ; preds = %57, %.loopexit
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %64 = icmp ult i32 %8, 16
  br i1 %64, label %65, label %71

65:                                               ; preds = %63
  %66 = add nuw nsw i32 %8, 16
  %67 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %66
  %68 = load i32, i32 addrspace(3)* %67, align 4, !tbaa !8
  %69 = load i32, i32 addrspace(3)* %55, align 4, !tbaa !8
  %70 = add i32 %69, %68
  store i32 %70, i32 addrspace(3)* %55, align 4, !tbaa !8
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
  %77 = load i32, i32 addrspace(3)* %55, align 4, !tbaa !8
  %78 = add i32 %77, %76
  store i32 %78, i32 addrspace(3)* %55, align 4, !tbaa !8
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
  %85 = load i32, i32 addrspace(3)* %55, align 4, !tbaa !8
  %86 = add i32 %85, %84
  store i32 %86, i32 addrspace(3)* %55, align 4, !tbaa !8
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
  %93 = load i32, i32 addrspace(3)* %55, align 4, !tbaa !8
  %94 = add i32 %93, %92
  store i32 %94, i32 addrspace(3)* %55, align 4, !tbaa !8
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

merged.bb32:                                      ; preds = %unify.bb
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

merged.bb33:                                      ; preds = %unify.bb
  %124 = add nsw i32 %35, 1
  %125 = select i1 %47, i32 undef, i32 %124
  %126 = add nsw i32 %36, -1
  br label %merged.bb34

merged.bb34:                                      ; preds = %merged.bb33, %merged.bb32
  %127 = phi i32 [ undef, %merged.bb32 ], [ %126, %merged.bb33 ]
  %128 = phi i32 [ %48, %merged.bb32 ], [ %126, %merged.bb33 ]
  %129 = phi i32 [ %35, %merged.bb32 ], [ %125, %merged.bb33 ]
  %130 = select i1 %47, i32 %127, i32 undef
  %131 = select i1 %47, i32 %127, i32 %128
  %132 = select i1 %38, i32 %130, i32 %131
  %133 = select i1 %47, i32 %35, i32 %129
  %134 = icmp sgt i32 %132, -1
  br i1 %134, label %51, label %.loopexit, !llvm.loop !12
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
