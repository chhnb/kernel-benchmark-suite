; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: convergent norecurse nounwind
define float @region(i1 %0, float %1, float %2, float %3, i1 %4) #0 {
  br i1 %0, label %14, label %6

6:                                                ; preds = %5
  %7 = fcmp olt float %1, 0.000000e+00
  %8 = fcmp une float %2, 0x7FF0000000000000
  %9 = fadd float %3, 0x3EE0000000000000
  %10 = select i1 %4, float %9, float %3
  %11 = call float @llvm.fma.f32(float %2, float %10, float %2) #2
  %12 = select i1 %8, float %11, float %2
  %13 = select i1 %7, float 0x7FFFFFFFE0000000, float %12
  br label %14

14:                                               ; preds = %6, %5
  %15 = phi float [ 0.000000e+00, %5 ], [ %13, %6 ]
  ret float %15
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare float @llvm.fma.f32(float, float, float) #1

attributes #0 = { convergent norecurse nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { nounwind }
