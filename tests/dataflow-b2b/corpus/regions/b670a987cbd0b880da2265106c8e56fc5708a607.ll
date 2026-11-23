; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: alwaysinline convergent nounwind
define void @region(i1 %0, float %1, float %2, float %3, float* %4) #0 {
  br i1 %0, label %6, label %7

6:                                                ; preds = %5
  tail call void @g_7_7(float %1, float %2, float %3, float* %4) #2
  br label %8

7:                                                ; preds = %5
  tail call void @g_6_6(float %1, float %2, float %3, float* %4) #2
  br label %8

8:                                                ; preds = %7, %6
  ret void
}

; Function Attrs: alwaysinline nofree nounwind writeonly
declare void @g_7_7(float, float, float, float* nocapture) #1

; Function Attrs: alwaysinline nofree nounwind writeonly
declare void @g_6_6(float, float, float, float* nocapture) #1

attributes #0 = { alwaysinline convergent nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { alwaysinline nofree nounwind writeonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { convergent nounwind }
