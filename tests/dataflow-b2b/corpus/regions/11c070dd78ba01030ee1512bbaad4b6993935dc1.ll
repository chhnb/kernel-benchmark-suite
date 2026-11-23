; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, i1 %5, [4 x double]* %6) #0 {
  br i1 %0, label %8, label %24

8:                                                ; preds = %7
  %9 = fmul double %1, %2
  %10 = fadd double %3, 0x405A8654D41DC46C
  %11 = fadd double %9, 0x4016B9F7A03E5CA6
  %12 = fmul double %4, %10
  %13 = fmul double %1, 0x409B9068A3C78607
  %14 = fsub double 0x40990C9A56964108, %13
  %15 = fmul double %1, 0x408105AF09F369D0
  %16 = fsub double 0x40912C23C604419C, %15
  %17 = fmul double %1, %14
  %18 = fmul double %1, %16
  %19 = fadd double %17, 0x4070760E04B9BCBD
  %20 = fadd double %18, 0x403AF5DBE51CBD80
  %21 = fmul double %1, %19
  %22 = fadd double %21, 1.000000e+00
  %23 = fmul double %4, %20
  br label %49

24:                                               ; preds = %7
  %25 = select i1 %5, double 0x40179A9AC0DA87EF, double 0x4003830831C63CF0
  %26 = fmul double %1, %25
  %27 = fsub double 0x4030441296C5FB34, %26
  %28 = fadd double %26, 0xC03ABCE1630E61C0
  %29 = select i1 %5, double %28, double %27
  %30 = select i1 %5, double 0x4000D00D57F2CBBD, double 0x401D7BFF8CC54FA6
  %31 = fmul double %1, %30
  %32 = select i1 %5, double 0xC0226B8874380C5B, double 0xC026402DD156D3FC
  %33 = fadd double %31, %32
  %34 = fmul double %1, %29
  %35 = fmul double %1, %33
  %36 = select i1 %5, double 0x402AF4FD59F9A777, double 0xC031083D20CE0F89
  %37 = fadd double %34, %36
  %38 = select i1 %5, double 0x401E18FAC448D58A, double 0x3FF51C8655DB120C
  %39 = fadd double %35, %38
  %40 = fmul double %1, %37
  %41 = fmul double %1, %39
  %42 = fadd double %40, 0x4012D71DC7267483
  %43 = select i1 %5, double %40, double %41
  %44 = fadd double %43, 1.000000e+00
  %45 = select i1 %5, double %39, double %42
  %46 = fmul double %4, %45
  %47 = select i1 %5, double %46, double %44
  %48 = select i1 %5, double %44, double %46
  br label %49

49:                                               ; preds = %24, %8
  %50 = phi double [ %22, %8 ], [ %48, %24 ]
  %51 = phi double [ %23, %8 ], [ %47, %24 ]
  %52 = phi double [ %12, %8 ], [ %2, %24 ]
  %53 = phi double [ %11, %8 ], [ %3, %24 ]
  %54 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 0
  store double %50, double* %54, align 8
  %55 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 1
  store double %51, double* %55, align 8
  %56 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 2
  store double %52, double* %56, align 8
  %57 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 3
  store double %53, double* %57, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
