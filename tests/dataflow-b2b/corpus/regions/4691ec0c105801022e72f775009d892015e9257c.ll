; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree norecurse nounwind
define double @region(i1 %0, i32 %1, double %2, i32 %3) #0 {
  br i1 %0, label %5, label %10

5:                                                ; preds = %4
  %6 = zext i32 %1 to i64
  %7 = shl nuw i64 1, %6
  %8 = uitofp i64 %7 to double
  %9 = fmul double %2, %8
  br label %15

10:                                               ; preds = %4
  %11 = zext i32 %3 to i64
  %12 = shl nuw i64 1, %11
  %13 = uitofp i64 %12 to double
  %14 = fdiv double %2, %13
  br label %15

15:                                               ; preds = %10, %5
  %16 = phi double [ %9, %5 ], [ %14, %10 ]
  ret double %16
}

attributes #0 = { nofree norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
