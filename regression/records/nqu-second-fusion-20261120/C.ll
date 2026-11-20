; ModuleID = '/data/home/chh/simplify-v2/build/auto-darm-release-compare/20261120-v1/NQU64/baseline.ll'
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
  br i1 %19, label %20, label %56

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

unify.bb:                                         ; preds = %53, %20
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

53:                                               ; preds = %merged.bb34
  %54 = getelementptr inbounds [64 x [10 x i32]], [64 x [10 x i32]] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE1m, i32 0, i32 %8, i32 %154
  %55 = load i32, i32 addrspace(3)* %54, align 4, !tbaa !8
  br label %unify.bb

56:                                               ; preds = %merged.bb34, %7
  %57 = phi i32 [ 0, %7 ], [ %155, %merged.bb34 ]
  %58 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %8
  store i32 %57, i32 addrspace(3)* %58, align 4, !tbaa !8
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %59 = icmp ult i32 %8, 32
  %60 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %8
  br i1 %59, label %61, label %67

61:                                               ; preds = %56
  %62 = add nuw nsw i32 %8, 32
  %63 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %62
  %64 = load i32, i32 addrspace(3)* %63, align 4, !tbaa !8
  %65 = load i32, i32 addrspace(3)* %60, align 4, !tbaa !8
  %66 = add i32 %65, %64
  store i32 %66, i32 addrspace(3)* %60, align 4, !tbaa !8
  br label %67

67:                                               ; preds = %61, %56
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %68 = icmp ult i32 %8, 16
  br i1 %68, label %69, label %75

69:                                               ; preds = %67
  %70 = add nuw nsw i32 %8, 16
  %71 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %70
  %72 = load i32, i32 addrspace(3)* %71, align 4, !tbaa !8
  %73 = load i32, i32 addrspace(3)* %60, align 4, !tbaa !8
  %74 = add i32 %73, %72
  store i32 %74, i32 addrspace(3)* %60, align 4, !tbaa !8
  br label %75

75:                                               ; preds = %69, %67
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %76 = icmp ult i32 %8, 8
  br i1 %76, label %77, label %83

77:                                               ; preds = %75
  %78 = add nuw nsw i32 %8, 8
  %79 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %78
  %80 = load i32, i32 addrspace(3)* %79, align 4, !tbaa !8
  %81 = load i32, i32 addrspace(3)* %60, align 4, !tbaa !8
  %82 = add i32 %81, %80
  store i32 %82, i32 addrspace(3)* %60, align 4, !tbaa !8
  br label %83

83:                                               ; preds = %77, %75
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %84 = icmp ult i32 %8, 4
  br i1 %84, label %85, label %91

85:                                               ; preds = %83
  %86 = add nuw nsw i32 %8, 4
  %87 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %86
  %88 = load i32, i32 addrspace(3)* %87, align 4, !tbaa !8
  %89 = load i32, i32 addrspace(3)* %60, align 4, !tbaa !8
  %90 = add i32 %89, %88
  store i32 %90, i32 addrspace(3)* %60, align 4, !tbaa !8
  br label %91

91:                                               ; preds = %85, %83
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %92 = icmp ult i32 %8, 2
  br i1 %92, label %93, label %99

93:                                               ; preds = %91
  %94 = add nuw nsw i32 %8, 2
  %95 = getelementptr inbounds [64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 %94
  %96 = load i32, i32 addrspace(3)* %95, align 4, !tbaa !8
  %97 = load i32, i32 addrspace(3)* %60, align 4, !tbaa !8
  %98 = add i32 %97, %96
  store i32 %98, i32 addrspace(3)* %60, align 4, !tbaa !8
  br label %99

99:                                               ; preds = %93, %91
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  %100 = icmp eq i32 %8, 0
  br i1 %100, label %101, label %105

101:                                              ; preds = %99
  %102 = load i32, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 1), align 4, !tbaa !8
  %103 = load i32, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 0), align 16, !tbaa !8
  %104 = add i32 %103, %102
  store i32 %104, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 0), align 16, !tbaa !8
  br label %105

105:                                              ; preds = %101, %99
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
  br i1 %100, label %106, label %110

106:                                              ; preds = %105
  %107 = sext i32 %9 to i64
  %108 = getelementptr inbounds i32, i32 addrspace(1)* %5, i64 %107
  %109 = load i32, i32 addrspace(3)* getelementptr inbounds ([64 x i32], [64 x i32] addrspace(3)* @_ZZ24solve_nqueen_cuda_kerneliiPjS_S_S_iE3sum, i32 0, i32 0), align 16, !tbaa !8
  store i32 %109, i32 addrspace(1)* %108, align 4, !tbaa !8
  br label %110

110:                                              ; preds = %106, %105
  ret void

merged.bb32:                                      ; preds = %unify.bb
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

merged.bb33:                                      ; preds = %unify.bb
  %144 = add nsw i32 %35, 1
  %145 = select i1 %48, i32 undef, i32 %144
  %146 = add nsw i32 %36, -1
  br label %merged.bb34

merged.bb34:                                      ; preds = %merged.bb32, %merged.bb33
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
