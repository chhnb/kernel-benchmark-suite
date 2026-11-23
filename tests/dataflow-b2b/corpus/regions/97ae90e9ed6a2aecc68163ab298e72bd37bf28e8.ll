; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree norecurse nounwind
define void @region(i1 %0, double %1, double %2, [2 x double]* %3) #0 {
  br i1 %0, label %5, label %11

5:                                                ; preds = %4
  %6 = fadd double %1, 0xC030F25386AA802B
  %7 = fmul double %2, 0x40199996D51EE9B7
  %8 = fsub double 0x40034649FCCCF81F, %7
  %9 = fmul double %2, %6
  %10 = fadd double %9, 0x40158CEB587D3265
  br label %19

11:                                               ; preds = %4
  %12 = fsub double 0x401B5545C0CB5BDA, %1
  %13 = fmul double %2, 0x40074E9A9F865729
  %14 = fadd double %13, 0xC016B372910B83AB
  %15 = fmul double %2, %12
  %16 = fmul double %2, %14
  %17 = fadd double %15, 0xC0138A29DF206C0B
  %18 = fadd double %16, 0x3FFC33F0B4C09D66
  br label %19

19:                                               ; preds = %11, %5
  %20 = phi double [ %8, %5 ], [ %17, %11 ]
  %21 = phi double [ %10, %5 ], [ %18, %11 ]
  %22 = getelementptr inbounds [2 x double], [2 x double]* %3, i32 0, i32 0
  store double %20, double* %22, align 8
  %23 = getelementptr inbounds [2 x double], [2 x double]* %3, i32 0, i32 1
  store double %21, double* %23, align 8
  ret void
}

attributes #0 = { nofree norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
