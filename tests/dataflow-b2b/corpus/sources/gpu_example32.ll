; ModuleID = '/data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-corpus/upstream/customization/gpu_example/gpu_example.cpp'
source_filename = "/data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-corpus/upstream/customization/gpu_example/gpu_example.cpp"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-G1-ni:7"
target triple = "amdgcn-amd-amdhsa"

%"struct.__HIP_Coordinates<__HIP_ThreadIdx>::X" = type { i8 }
%"struct.__HIP_Coordinates<__HIP_BlockIdx>::X" = type { i8 }

$_ZN17__HIP_CoordinatesI15__HIP_ThreadIdxE1xE = comdat any

$_ZN17__HIP_CoordinatesI14__HIP_BlockIdxE1xE = comdat any

@_ZN17__HIP_CoordinatesI15__HIP_ThreadIdxE1xE = weak protected local_unnamed_addr addrspace(4) externally_initialized constant %"struct.__HIP_Coordinates<__HIP_ThreadIdx>::X" undef, comdat, align 1
@_ZN17__HIP_CoordinatesI14__HIP_BlockIdxE1xE = weak protected local_unnamed_addr addrspace(4) externally_initialized constant %"struct.__HIP_Coordinates<__HIP_BlockIdx>::X" undef, comdat, align 1
@shared_x = external hidden local_unnamed_addr addrspace(3) global [0 x i32], align 4
@shared_y = external hidden local_unnamed_addr addrspace(3) global [0 x i32], align 4
@shared_p = external hidden local_unnamed_addr addrspace(3) global [0 x i32], align 4
@shared_q = external hidden local_unnamed_addr addrspace(3) global [0 x i32], align 4

; Function Attrs: convergent norecurse nounwind
define protected amdgpu_kernel void @_Z3fooIiEvPT_S1_S1_S1_(i32 addrspace(1)* nocapture %0, i32 addrspace(1)* nocapture %1, i32 addrspace(1)* nocapture %2, i32 addrspace(1)* nocapture %3) local_unnamed_addr #0 {
  %5 = tail call i32 @llvm.amdgcn.workitem.id.x() #4, !range !4
  %6 = tail call i32 @llvm.amdgcn.workgroup.id.x() #4
  %7 = shl i32 %6, 5
  %8 = add i32 %7, %5
  %9 = zext i32 %8 to i64
  %10 = getelementptr inbounds i32, i32 addrspace(1)* %0, i64 %9
  %11 = load i32, i32 addrspace(1)* %10, align 4, !tbaa !5
  %12 = getelementptr inbounds [0 x i32], [0 x i32] addrspace(3)* @shared_x, i32 0, i32 %5
  store i32 %11, i32 addrspace(3)* %12, align 4, !tbaa !5
  %13 = getelementptr inbounds i32, i32 addrspace(1)* %1, i64 %9
  %14 = load i32, i32 addrspace(1)* %13, align 4, !tbaa !5
  %15 = getelementptr inbounds [0 x i32], [0 x i32] addrspace(3)* @shared_y, i32 0, i32 %5
  store i32 %14, i32 addrspace(3)* %15, align 4, !tbaa !5
  %16 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %9
  %17 = load i32, i32 addrspace(1)* %16, align 4, !tbaa !5
  %18 = getelementptr inbounds [0 x i32], [0 x i32] addrspace(3)* @shared_p, i32 0, i32 %5
  store i32 %17, i32 addrspace(3)* %18, align 4, !tbaa !5
  %19 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %9
  %20 = load i32, i32 addrspace(1)* %19, align 4, !tbaa !5
  %21 = getelementptr inbounds [0 x i32], [0 x i32] addrspace(3)* @shared_q, i32 0, i32 %5
  store i32 %20, i32 addrspace(3)* %21, align 4, !tbaa !5
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #4
  fence syncscope("workgroup") acquire
  %22 = and i32 %5, 1
  %23 = icmp eq i32 %22, 0
  %24 = urem i32 %5, 3
  %25 = icmp eq i32 %24, 0
  %26 = urem i32 %5, 6
  %27 = icmp eq i32 %26, 0
  br label %28

28:                                               ; preds = %4, %39
  %29 = phi i32 [ 0, %4 ], [ %40, %39 ]
  %30 = getelementptr inbounds [0 x i32], [0 x i32] addrspace(3)* @shared_y, i32 0, i32 %29
  %31 = getelementptr inbounds [0 x i32], [0 x i32] addrspace(3)* @shared_x, i32 0, i32 %29
  %32 = getelementptr inbounds [0 x i32], [0 x i32] addrspace(3)* @shared_p, i32 0, i32 %29
  %33 = getelementptr inbounds [0 x i32], [0 x i32] addrspace(3)* @shared_q, i32 0, i32 %29
  br label %42

34:                                               ; preds = %39
  %35 = load i32, i32 addrspace(3)* %12, align 4, !tbaa !5
  store i32 %35, i32 addrspace(1)* %10, align 4, !tbaa !5
  %36 = load i32, i32 addrspace(3)* %15, align 4, !tbaa !5
  store i32 %36, i32 addrspace(1)* %13, align 4, !tbaa !5
  %37 = load i32, i32 addrspace(3)* %18, align 4, !tbaa !5
  store i32 %37, i32 addrspace(1)* %16, align 4, !tbaa !5
  %38 = load i32, i32 addrspace(3)* %21, align 4, !tbaa !5
  store i32 %38, i32 addrspace(1)* %19, align 4, !tbaa !5
  ret void

39:                                               ; preds = %77
  %40 = add nuw nsw i32 %29, 1
  %41 = icmp eq i32 %40, 32
  br i1 %41, label %34, label %28, !llvm.loop !9

42:                                               ; preds = %28, %77
  %43 = phi i32 [ 0, %28 ], [ %81, %77 ]
  br i1 %23, label %44, label %59

44:                                               ; preds = %42
  br i1 %27, label %45, label %77

45:                                               ; preds = %44
  %46 = load i32, i32 addrspace(3)* %30, align 4, !tbaa !5
  %47 = load i32, i32 addrspace(3)* %31, align 4, !tbaa !5
  %48 = mul nsw i32 %47, %46
  %49 = xor i32 %47, %46
  %50 = add i32 %49, %47
  %51 = sub i32 %48, %50
  %52 = add nsw i32 %47, %46
  %53 = or i32 %47, %46
  %54 = xor i32 %52, %53
  %55 = tail call i32 @llvm.abs.i32(i32 %52, i1 true) #4
  %56 = add nuw nsw i32 %55, 1
  %57 = sdiv i32 %54, %56
  %58 = mul nsw i32 %51, %57
  br label %77

59:                                               ; preds = %42
  br i1 %25, label %60, label %77

60:                                               ; preds = %59
  %61 = getelementptr inbounds [0 x i32], [0 x i32] addrspace(3)* @shared_q, i32 0, i32 %43
  %62 = load i32, i32 addrspace(3)* %61, align 4, !tbaa !5
  %63 = getelementptr inbounds [0 x i32], [0 x i32] addrspace(3)* @shared_p, i32 0, i32 %43
  %64 = load i32, i32 addrspace(3)* %63, align 4, !tbaa !5
  %65 = add i32 %62, -2
  %66 = mul i32 %64, %65
  %67 = and i32 %64, %62
  %68 = and i32 %66, %67
  %69 = shl nsw i32 %62, 1
  %70 = and i32 %69, %62
  %71 = xor i32 %64, %62
  %72 = tail call i32 @llvm.abs.i32(i32 %67, i1 true) #4
  %73 = add nuw nsw i32 %72, 1
  %74 = sdiv i32 %71, %73
  %75 = sub nsw i32 %70, %74
  %76 = mul nsw i32 %68, %75
  br label %77

77:                                               ; preds = %59, %60, %44, %45
  %78 = phi i32 [ %58, %45 ], [ 0, %44 ], [ 0, %60 ], [ 0, %59 ]
  %79 = phi i32 [ 0, %45 ], [ 0, %44 ], [ %76, %60 ], [ 0, %59 ]
  %80 = sub nsw i32 0, %78
  store i32 %80, i32 addrspace(3)* %31, align 4, !tbaa !5
  store i32 %78, i32 addrspace(3)* %30, align 4, !tbaa !5
  store i32 %79, i32 addrspace(3)* %32, align 4, !tbaa !5
  store i32 %79, i32 addrspace(3)* %33, align 4, !tbaa !5
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #4
  fence syncscope("workgroup") acquire
  %81 = add nuw nsw i32 %43, 1
  %82 = icmp eq i32 %81, 32
  br i1 %82, label %39, label %42, !llvm.loop !12
}

; Function Attrs: convergent nounwind willreturn
declare void @llvm.amdgcn.s.barrier() #1

; Function Attrs: nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.workitem.id.x() #2

; Function Attrs: nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.workgroup.id.x() #2

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare i32 @llvm.abs.i32(i32, i1 immarg) #3

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,1024" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { convergent nounwind willreturn }
attributes #2 = { nounwind readnone speculatable willreturn }
attributes #3 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0, !1}
!opencl.ocl.version = !{!2}
!llvm.ident = !{!3}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 1}
!2 = !{i32 2, i32 0}
!3 = !{!"clang version 12.0.0 (https://github.com/RadeonOpenCompute/llvm-project roc-4.2.0 21161 b204d7f0cae65b6cd4446eec50fc1fb675d582af)"}
!4 = !{i32 0, i32 1024}
!5 = !{!6, !6, i64 0}
!6 = !{!"int", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C++ TBAA"}
!9 = distinct !{!9, !10, !11}
!10 = !{!"llvm.loop.mustprogress"}
!11 = !{!"llvm.loop.unroll.disable"}
!12 = distinct !{!12, !10, !11}
