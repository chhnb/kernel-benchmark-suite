; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-G1-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i32 addrspace(3)* %1, i32 addrspace(3)* %2, [2 x i32]* %3) #0 {
  br i1 %0, label %5, label %19

5:                                                ; preds = %4
  %6 = load i32, i32 addrspace(3)* %1, align 4, !tbaa !0
  %7 = load i32, i32 addrspace(3)* %2, align 4, !tbaa !0
  %8 = mul nsw i32 %7, %6
  %9 = xor i32 %7, %6
  %10 = add i32 %9, %7
  %11 = sub i32 %8, %10
  %12 = add nsw i32 %7, %6
  %13 = or i32 %7, %6
  %14 = xor i32 %12, %13
  %15 = tail call i32 @llvm.abs.i32(i32 %12, i1 true) #2
  %16 = add nuw nsw i32 %15, 1
  %17 = sdiv i32 %14, %16
  %18 = mul nsw i32 %11, %17
  br label %19

19:                                               ; preds = %5, %4
  %20 = phi i32 [ %18, %5 ], [ 0, %4 ]
  %21 = phi i32 [ 0, %5 ], [ 0, %4 ]
  %22 = getelementptr inbounds [2 x i32], [2 x i32]* %3, i32 0, i32 0
  store i32 %20, i32* %22, align 4
  %23 = getelementptr inbounds [2 x i32], [2 x i32]* %3, i32 0, i32 1
  store i32 %21, i32* %23, align 4
  ret void
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare i32 @llvm.abs.i32(i32, i1 immarg) #1

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,1024" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { nounwind }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
