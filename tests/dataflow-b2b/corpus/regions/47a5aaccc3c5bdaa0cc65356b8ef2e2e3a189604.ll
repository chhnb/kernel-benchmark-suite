; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i32 %1, i32 %2, [8192 x i32] addrspace(3)* %3, i32 %4, i32 %5, i32 %6, i32 %7, [3 x i32]* %8) #0 {
  br i1 %0, label %10, label %15

10:                                               ; preds = %9
  %11 = add nuw nsw i32 %1, 1
  %12 = add nsw i32 %2, %11
  %13 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %12
  %14 = load i32, i32 addrspace(3)* %13, align 4, !tbaa !0
  br label %20

15:                                               ; preds = %9
  %16 = add nuw nsw i32 %4, 1
  %17 = add nsw i32 %16, %5
  %18 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %17
  %19 = load i32, i32 addrspace(3)* %18, align 4, !tbaa !0
  br label %20

20:                                               ; preds = %15, %10
  %21 = phi i32 [ %14, %10 ], [ %6, %15 ]
  %22 = phi i32 [ %7, %10 ], [ %19, %15 ]
  %23 = phi i32 [ %6, %10 ], [ %7, %15 ]
  %24 = getelementptr inbounds [3 x i32], [3 x i32]* %8, i32 0, i32 0
  store i32 %21, i32* %24, align 4
  %25 = getelementptr inbounds [3 x i32], [3 x i32]* %8, i32 0, i32 1
  store i32 %22, i32* %25, align 4
  %26 = getelementptr inbounds [3 x i32], [3 x i32]* %8, i32 0, i32 2
  store i32 %23, i32* %26, align 4
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
