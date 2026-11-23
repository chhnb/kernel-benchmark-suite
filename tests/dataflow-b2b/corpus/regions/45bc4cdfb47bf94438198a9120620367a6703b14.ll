; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i1 %1, i32 %2, [8192 x i32] addrspace(3)* %3, i32 %4, i32 %5, i32 %6, i32 %7, i32 %8, [5 x i32]* %9) #0 {
  br i1 %0, label %11, label %16

11:                                               ; preds = %10
  %12 = select i1 %1, i32 2, i32 1
  %13 = or i32 %2, %12
  %14 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %13
  %15 = load i32, i32 addrspace(3)* %14, align 4, !tbaa !0
  br label %21

16:                                               ; preds = %10
  %17 = select i1 %1, i32 1, i32 2
  %18 = or i32 %17, %4
  %19 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %18
  %20 = load i32, i32 addrspace(3)* %19, align 4, !tbaa !0
  br label %21

21:                                               ; preds = %16, %11
  %22 = phi i32 [ %15, %11 ], [ %5, %16 ]
  %23 = phi i32 [ %6, %11 ], [ %20, %16 ]
  %24 = phi i32 [ %5, %11 ], [ %6, %16 ]
  %25 = phi i32 [ %7, %11 ], [ %17, %16 ]
  %26 = phi i32 [ %12, %11 ], [ %8, %16 ]
  %27 = getelementptr inbounds [5 x i32], [5 x i32]* %9, i32 0, i32 0
  store i32 %22, i32* %27, align 4
  %28 = getelementptr inbounds [5 x i32], [5 x i32]* %9, i32 0, i32 1
  store i32 %23, i32* %28, align 4
  %29 = getelementptr inbounds [5 x i32], [5 x i32]* %9, i32 0, i32 2
  store i32 %24, i32* %29, align 4
  %30 = getelementptr inbounds [5 x i32], [5 x i32]* %9, i32 0, i32 3
  store i32 %25, i32* %30, align 4
  %31 = getelementptr inbounds [5 x i32], [5 x i32]* %9, i32 0, i32 4
  store i32 %26, i32* %31, align 4
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
