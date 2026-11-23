; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, double %5, [4 x double]* %6) #0 {
  br i1 %0, label %8, label %14

8:                                                ; preds = %7
  %9 = fadd double %1, 0xC024B04741F7A527
  %10 = fadd double %2, 0xBFEC1147FADC1DD1
  %11 = fmul double %3, %9
  %12 = fadd double %4, 1.000000e+00
  %13 = fmul double %3, %5
  br label %16

14:                                               ; preds = %7
  %15 = fadd double %1, 0xBFDABCA86BC1374B
  br label %16

16:                                               ; preds = %14, %8
  %17 = phi double [ %12, %8 ], [ %4, %14 ]
  %18 = phi double [ %13, %8 ], [ %5, %14 ]
  %19 = phi double [ %11, %8 ], [ %15, %14 ]
  %20 = phi double [ %10, %8 ], [ %2, %14 ]
  %21 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 0
  store double %17, double* %21, align 8
  %22 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 1
  store double %18, double* %22, align 8
  %23 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 2
  store double %19, double* %23, align 8
  %24 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 3
  store double %20, double* %24, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
