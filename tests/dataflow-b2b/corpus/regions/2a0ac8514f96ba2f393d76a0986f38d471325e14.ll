; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, i1 %5, double %6, double %7, [4 x double]* %8) #0 {
  br i1 %0, label %10, label %24

10:                                               ; preds = %9
  %11 = fadd double %1, 0x405A8654D41DC46C
  %12 = fmul double %2, %11
  %13 = fmul double %3, 0x409B9068A3C78607
  %14 = fsub double 0x40990C9A56964108, %13
  %15 = fmul double %3, 0x408105AF09F369D0
  %16 = fsub double 0x40912C23C604419C, %15
  %17 = fmul double %3, %14
  %18 = fmul double %3, %16
  %19 = fadd double %17, 0x4070760E04B9BCBD
  %20 = fadd double %18, 0x403AF5DBE51CBD80
  %21 = fmul double %3, %19
  %22 = fadd double %21, 1.000000e+00
  %23 = fmul double %2, %20
  br label %46

24:                                               ; preds = %9
  %25 = fsub double 0x4030441296C5FB34, %4
  %26 = select i1 %5, double %6, double %25
  %27 = select i1 %5, double 0x4000D00D57F2CBBD, double 0x401D7BFF8CC54FA6
  %28 = fmul double %3, %27
  %29 = select i1 %5, double 0xC0226B8874380C5B, double 0xC026402DD156D3FC
  %30 = fadd double %28, %29
  %31 = fmul double %3, %26
  %32 = fmul double %3, %30
  %33 = select i1 %5, double 0x402AF4FD59F9A777, double 0xC031083D20CE0F89
  %34 = fadd double %31, %33
  %35 = select i1 %5, double 0x401E18FAC448D58A, double 0x3FF51C8655DB120C
  %36 = fadd double %32, %35
  %37 = fmul double %3, %34
  %38 = fmul double %3, %36
  %39 = fadd double %37, 0x4012D71DC7267483
  %40 = select i1 %5, double %37, double %38
  %41 = fadd double %40, 1.000000e+00
  %42 = select i1 %5, double %36, double %39
  %43 = fmul double %2, %42
  %44 = select i1 %5, double %43, double %41
  %45 = select i1 %5, double %41, double %43
  br label %46

46:                                               ; preds = %24, %10
  %47 = phi double [ %22, %10 ], [ %45, %24 ]
  %48 = phi double [ %23, %10 ], [ %44, %24 ]
  %49 = phi double [ %12, %10 ], [ %7, %24 ]
  %50 = phi double [ %6, %10 ], [ %1, %24 ]
  %51 = getelementptr inbounds [4 x double], [4 x double]* %8, i32 0, i32 0
  store double %47, double* %51, align 8
  %52 = getelementptr inbounds [4 x double], [4 x double]* %8, i32 0, i32 1
  store double %48, double* %52, align 8
  %53 = getelementptr inbounds [4 x double], [4 x double]* %8, i32 0, i32 2
  store double %49, double* %53, align 8
  %54 = getelementptr inbounds [4 x double], [4 x double]* %8, i32 0, i32 3
  store double %50, double* %54, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
