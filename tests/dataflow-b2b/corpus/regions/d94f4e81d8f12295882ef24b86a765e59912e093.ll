; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: norecurse nounwind
define void @region(i1 %0, i32 %1, i32 %2, i32 %3, i32 %4, i32 %5, [2 x i32]* %6) #0 {
  br i1 %0, label %15, label %8

8:                                                ; preds = %7
  %9 = sdiv i32 %1, %2
  %10 = add nsw i32 %9, %3
  %11 = mul i32 %9, %2
  %12 = sub i32 %1, %11
  %13 = shl nsw i32 %12, 2
  %14 = add nsw i32 %4, %13
  br label %15

15:                                               ; preds = %8, %7
  %16 = phi i32 [ %5, %7 ], [ %10, %8 ]
  %17 = phi i32 [ %1, %7 ], [ %14, %8 ]
  %18 = getelementptr inbounds [2 x i32], [2 x i32]* %6, i32 0, i32 0
  store i32 %16, i32* %18, align 4
  %19 = getelementptr inbounds [2 x i32], [2 x i32]* %6, i32 0, i32 1
  store i32 %17, i32* %19, align 4
  ret void
}

attributes #0 = { norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
