; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: norecurse nounwind
define i1 @region(i1 %0, i32 %1, i32 %2, i8 addrspace(1)* %3) #0 {
  br i1 %0, label %5, label %12

5:                                                ; preds = %4
  %6 = shl nsw i32 %1, 13
  %7 = add nsw i32 %6, %2
  %8 = sext i32 %7 to i64
  %9 = getelementptr inbounds i8, i8 addrspace(1)* %3, i64 %8
  %10 = load i8, i8 addrspace(1)* %9, align 1, !tbaa !0
  %11 = icmp eq i8 %10, 0
  br label %12

12:                                               ; preds = %5, %4
  %13 = phi i1 [ %11, %5 ], [ false, %4 ]
  ret i1 %13
}

attributes #0 = { norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"omnipotent char", !2, i64 0}
!2 = !{!"Simple C++ TBAA"}
