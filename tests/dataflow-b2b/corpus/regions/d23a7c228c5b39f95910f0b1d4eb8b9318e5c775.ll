; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind willreturn
define i32 @region(i1 %0, i16 %1, i16 %2, i32 %3) #0 {
  br i1 %0, label %5, label %12

5:                                                ; preds = %4
  %6 = sub i16 %1, %2
  %7 = sext i16 %6 to i32
  %8 = sdiv i32 %7, %3
  %9 = shl i32 %8, 16
  %10 = ashr exact i32 %9, 16
  %11 = sub nsw i32 0, %10
  br label %16

12:                                               ; preds = %4
  %13 = add i16 %1, %2
  %14 = sext i16 %13 to i32
  %15 = sdiv i32 %14, %3
  br label %16

16:                                               ; preds = %12, %5
  %17 = phi i32 [ %11, %5 ], [ %15, %12 ]
  ret i32 %17
}

attributes #0 = { convergent norecurse nounwind willreturn "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
