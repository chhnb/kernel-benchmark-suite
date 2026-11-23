; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i32 %1, i32 %2, i32 %3, i32 %4, i64 %5, [8 x [8 x float]] addrspace(3)* %6, float addrspace(1)* %7, { i64, i64, i32 }* %8) #0 {
  br i1 %0, label %10, label %19

10:                                               ; preds = %9
  %11 = mul nsw i32 %1, %2
  %12 = add nsw i32 %11, %3
  %13 = zext i32 %4 to i64
  %14 = shl nuw nsw i64 %13, 3
  %15 = add nuw nsw i64 %5, 8
  %16 = add nuw nsw i64 %15, %14
  %17 = sext i32 %12 to i64
  %18 = add nsw i64 %16, %17
  br label %33

19:                                               ; preds = %9
  %20 = shl i32 %4, 3
  %21 = add i32 %3, 8
  %22 = add i32 %21, %20
  %23 = mul i32 %22, %2
  %24 = add i32 %23, %3
  %25 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %6, i32 0, i32 0, i32 %1
  %26 = load float, float addrspace(3)* %25, align 4, !tbaa !3
  %27 = add nsw i32 %24, %1
  %28 = sext i32 %27 to i64
  %29 = getelementptr inbounds float, float addrspace(1)* %7, i64 %28
  store float %26, float addrspace(1)* %29, align 4, !tbaa !3
  %30 = add nsw i32 %24, %2
  %31 = add nsw i32 %30, %1
  %32 = sext i32 %31 to i64
  br label %33

33:                                               ; preds = %19, %10
  %34 = phi i64 [ %16, %10 ], [ poison, %19 ]
  %35 = phi i64 [ %18, %10 ], [ %32, %19 ]
  %36 = phi i32 [ %12, %10 ], [ %30, %19 ]
  %37 = getelementptr inbounds { i64, i64, i32 }, { i64, i64, i32 }* %8, i32 0, i32 0
  store i64 %34, i64* %37, align 8
  %38 = getelementptr inbounds { i64, i64, i32 }, { i64, i64, i32 }* %8, i32 0, i32 1
  store i64 %35, i64* %38, align 8
  %39 = getelementptr inbounds { i64, i64, i32 }, { i64, i64, i32 }* %8, i32 0, i32 2
  store i32 %36, i32* %39, align 4
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}
!dataflow.builtin.operations = !{!1, !2}

!0 = !{i32 4, !"llvm.amdgcn.workgroup.id.x"}
!1 = !{i32 0, i32 2, !"llvm.amdgcn.workgroup.id.x"}
!2 = !{i32 1, i32 0, !"llvm.amdgcn.workgroup.id.x"}
!3 = !{!4, !4, i64 0}
!4 = !{!"float", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C++ TBAA"}
