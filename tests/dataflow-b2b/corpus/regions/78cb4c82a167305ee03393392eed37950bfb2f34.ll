; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: norecurse nounwind
define void @region(i1 %0, i32 %1, i32 %2, i32 %3, [2 x i32]* %4) #0 {
  br i1 %0, label %8, label %6

6:                                                ; preds = %5
  %7 = and i32 %1, 7
  br label %8

8:                                                ; preds = %6, %5
  %9 = phi i32 [ %2, %5 ], [ %7, %6 ]
  %10 = phi i32 [ %3, %5 ], [ %1, %6 ]
  %11 = getelementptr inbounds [2 x i32], [2 x i32]* %4, i32 0, i32 0
  store i32 %9, i32* %11, align 4
  %12 = getelementptr inbounds [2 x i32], [2 x i32]* %4, i32 0, i32 1
  store i32 %10, i32* %12, align 4
  ret void
}

attributes #0 = { norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
