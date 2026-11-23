; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, i1 %5, [4 x double]* %6) #0 {
  br i1 %0, label %8, label %26

8:                                                ; preds = %7
  %9 = fadd double %1, 0x4081F4137E2FB1C7
  %10 = fmul double %2, %3
  %11 = fmul double %2, %9
  %12 = fadd double %10, 0x405A8654D41DC46C
  %13 = fadd double %11, 0x4016B9F7A03E5CA6
  %14 = fmul double %4, %12
  %15 = fmul double %2, 0x409B9068A3C78607
  %16 = fsub double 0x40990C9A56964108, %15
  %17 = fmul double %2, 0x408105AF09F369D0
  %18 = fsub double 0x40912C23C604419C, %17
  %19 = fmul double %2, %16
  %20 = fmul double %2, %18
  %21 = fadd double %19, 0x4070760E04B9BCBD
  %22 = fadd double %20, 0x403AF5DBE51CBD80
  %23 = fmul double %2, %21
  %24 = fadd double %23, 1.000000e+00
  %25 = fmul double %4, %22
  br label %54

26:                                               ; preds = %7
  %27 = select i1 %5, double 0x400468120D7EB3C7, double 0x3FF5040D3E43FC6C
  %28 = fadd double %1, %27
  %29 = fmul double %4, %3
  %30 = select i1 %5, double 0x40179A9AC0DA87EF, double 0x4003830831C63CF0
  %31 = fmul double %2, %30
  %32 = fsub double 0x4030441296C5FB34, %31
  %33 = fadd double %31, 0xC03ABCE1630E61C0
  %34 = select i1 %5, double %33, double %32
  %35 = select i1 %5, double 0x4000D00D57F2CBBD, double 0x401D7BFF8CC54FA6
  %36 = fmul double %2, %35
  %37 = select i1 %5, double 0xC0226B8874380C5B, double 0xC026402DD156D3FC
  %38 = fadd double %36, %37
  %39 = fmul double %2, %34
  %40 = fmul double %2, %38
  %41 = select i1 %5, double 0x402AF4FD59F9A777, double 0xC031083D20CE0F89
  %42 = fadd double %39, %41
  %43 = select i1 %5, double 0x401E18FAC448D58A, double 0x3FF51C8655DB120C
  %44 = fadd double %40, %43
  %45 = fmul double %2, %42
  %46 = fmul double %2, %44
  %47 = fadd double %45, 0x4012D71DC7267483
  %48 = select i1 %5, double %45, double %46
  %49 = fadd double %48, 1.000000e+00
  %50 = select i1 %5, double %44, double %47
  %51 = fmul double %4, %50
  %52 = select i1 %5, double %51, double %49
  %53 = select i1 %5, double %49, double %51
  br label %54

54:                                               ; preds = %26, %8
  %55 = phi double [ %24, %8 ], [ %53, %26 ]
  %56 = phi double [ %25, %8 ], [ %52, %26 ]
  %57 = phi double [ %14, %8 ], [ %28, %26 ]
  %58 = phi double [ %13, %8 ], [ %29, %26 ]
  %59 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 0
  store double %55, double* %59, align 8
  %60 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 1
  store double %56, double* %60, align 8
  %61 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 2
  store double %57, double* %61, align 8
  %62 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 3
  store double %58, double* %62, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
