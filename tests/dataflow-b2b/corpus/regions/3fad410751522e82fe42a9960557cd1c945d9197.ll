; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-G1-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind willreturn mustprogress
define void @region(i1 %0, i32 %1, i32 %2, [0 x i32] addrspace(3)* %3, i1 %4, i32 %5, i8 addrspace(1)* %6) #0 {
  br i1 %0, label %8, label %20

8:                                                ; preds = %7
  %9 = add nuw nsw i32 %1, 1
  %10 = add nuw nsw i32 %9, %2
  %11 = getelementptr inbounds [0 x i32], [0 x i32] addrspace(3)* %3, i32 0, i32 %10
  %12 = select i1 %4, i32 -1, i32 1
  %13 = add nsw i32 %5, %12
  %14 = sext i32 %13 to i64
  %15 = getelementptr inbounds i8, i8 addrspace(1)* %6, i64 %14
  %16 = load i8, i8 addrspace(1)* %15, align 1, !tbaa !0
  %17 = zext i8 %16 to i32
  %18 = getelementptr inbounds [0 x i32], [0 x i32] addrspace(3)* %3, i32 0, i32 %2
  %19 = select i1 %4, i32 addrspace(3)* %18, i32 addrspace(3)* %11
  store i32 %17, i32 addrspace(3)* %19, align 4, !tbaa !3
  br label %20

20:                                               ; preds = %8, %7
  ret void
}

attributes #0 = { convergent norecurse nounwind willreturn mustprogress "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"omnipotent char", !2, i64 0}
!2 = !{!"Simple C++ TBAA"}
!3 = !{!4, !4, i64 0}
!4 = !{!"int", !1, i64 0}
