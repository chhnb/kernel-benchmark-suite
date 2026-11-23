; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind willreturn
define void @region(i1 %0, [32 x [32 x float]] addrspace(3)* %1, i32 %2, i32 %3, i32 %4, i32 %5, i32 %6, float addrspace(1)* %7) #0 {
  br i1 %0, label %9, label %18

9:                                                ; preds = %8
  %10 = getelementptr inbounds [32 x [32 x float]], [32 x [32 x float]] addrspace(3)* %1, i32 0, i32 %2, i32 %3
  %11 = shl i32 %4, 5
  %12 = add i32 %5, -1
  %13 = add i32 %12, %6
  %14 = add i32 %13, %11
  %15 = zext i32 %14 to i64
  %16 = getelementptr inbounds float, float addrspace(1)* %7, i64 %15
  %17 = load float, float addrspace(1)* %16, align 4, !tbaa !2
  store float %17, float addrspace(3)* %10, align 4, !tbaa !2
  br label %18

18:                                               ; preds = %9, %8
  ret void
}

attributes #0 = { convergent norecurse nounwind willreturn "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0, !1}

!0 = !{i32 2, !"llvm.amdgcn.workitem.id.y"}
!1 = !{i32 3, !"llvm.amdgcn.workitem.id.x"}
!2 = !{!3, !3, i64 0}
!3 = !{!"float", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
