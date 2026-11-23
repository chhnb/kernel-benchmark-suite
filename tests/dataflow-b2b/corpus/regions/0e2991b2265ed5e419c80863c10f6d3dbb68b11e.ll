; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, i1 %5, [4 x double]* %6) #0 {
  br i1 %0, label %8, label %28

8:                                                ; preds = %7
  %9 = fmul double %1, %2
  %10 = fadd double %3, 0x407EB1E0C584548E
  %11 = fadd double %9, 0x4081F4137E2FB1C7
  %12 = fmul double %1, %10
  %13 = fmul double %1, %11
  %14 = fadd double %12, 0x405A8654D41DC46C
  %15 = fadd double %13, 0x4016B9F7A03E5CA6
  %16 = fmul double %4, %14
  %17 = fmul double %1, 0x409B9068A3C78607
  %18 = fsub double 0x40990C9A56964108, %17
  %19 = fmul double %1, 0x408105AF09F369D0
  %20 = fsub double 0x40912C23C604419C, %19
  %21 = fmul double %1, %18
  %22 = fmul double %1, %20
  %23 = fadd double %21, 0x4070760E04B9BCBD
  %24 = fadd double %22, 0x403AF5DBE51CBD80
  %25 = fmul double %1, %23
  %26 = fadd double %25, 1.000000e+00
  %27 = fmul double %4, %24
  br label %59

28:                                               ; preds = %7
  %29 = select i1 %5, double 0x40158CCE32F91DD3, double 0xBFF1103F72ECFAA8
  %30 = fadd double %3, %29
  %31 = fmul double %1, %2
  %32 = select i1 %5, double 0x400468120D7EB3C7, double 0x3FF5040D3E43FC6C
  %33 = fadd double %31, %32
  %34 = fmul double %4, %30
  %35 = select i1 %5, double 0x40179A9AC0DA87EF, double 0x4003830831C63CF0
  %36 = fmul double %1, %35
  %37 = fsub double 0x4030441296C5FB34, %36
  %38 = fadd double %36, 0xC03ABCE1630E61C0
  %39 = select i1 %5, double %38, double %37
  %40 = select i1 %5, double 0x4000D00D57F2CBBD, double 0x401D7BFF8CC54FA6
  %41 = fmul double %1, %40
  %42 = select i1 %5, double 0xC0226B8874380C5B, double 0xC026402DD156D3FC
  %43 = fadd double %41, %42
  %44 = fmul double %1, %39
  %45 = fmul double %1, %43
  %46 = select i1 %5, double 0x402AF4FD59F9A777, double 0xC031083D20CE0F89
  %47 = fadd double %44, %46
  %48 = select i1 %5, double 0x401E18FAC448D58A, double 0x3FF51C8655DB120C
  %49 = fadd double %45, %48
  %50 = fmul double %1, %47
  %51 = fmul double %1, %49
  %52 = fadd double %50, 0x4012D71DC7267483
  %53 = select i1 %5, double %50, double %51
  %54 = fadd double %53, 1.000000e+00
  %55 = select i1 %5, double %49, double %52
  %56 = fmul double %4, %55
  %57 = select i1 %5, double %56, double %54
  %58 = select i1 %5, double %54, double %56
  br label %59

59:                                               ; preds = %28, %8
  %60 = phi double [ %26, %8 ], [ %58, %28 ]
  %61 = phi double [ %27, %8 ], [ %57, %28 ]
  %62 = phi double [ %16, %8 ], [ %33, %28 ]
  %63 = phi double [ %15, %8 ], [ %34, %28 ]
  %64 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 0
  store double %60, double* %64, align 8
  %65 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 1
  store double %61, double* %65, align 8
  %66 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 2
  store double %62, double* %66, align 8
  %67 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 3
  store double %63, double* %67, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
