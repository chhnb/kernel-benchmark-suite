; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-G1-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind willreturn mustprogress
define i8 @region(i1 %0, i32 %1, i32 %2, [0 x i32] addrspace(3)* %3, i32 %4, i8 %5) #0 {
  br i1 %0, label %7, label %13

7:                                                ; preds = %6
  %8 = add nuw nsw i32 %1, %2
  %9 = getelementptr inbounds [0 x i32], [0 x i32] addrspace(3)* %3, i32 0, i32 %8
  %10 = load i32, i32 addrspace(3)* %9, align 4, !tbaa !1
  %11 = icmp sgt i32 %4, %10
  %12 = select i1 %11, i8 %5, i8 0
  br label %13

13:                                               ; preds = %7, %6
  %14 = phi i8 [ %12, %7 ], [ 0, %6 ]
  ret i8 %14
}

attributes #0 = { convergent norecurse nounwind willreturn mustprogress "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 2, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"int", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
