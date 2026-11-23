; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, i1 %5, [4 x double]* %6) #0 {
  br i1 %0, label %8, label %30

8:                                                ; preds = %7
  %9 = fadd double %1, 0xC0A6DC23D7E5E636
  %10 = fmul double %2, %3
  %11 = fmul double %2, %9
  %12 = fadd double %10, 0x407EB1E0C584548E
  %13 = fadd double %11, 0x4081F4137E2FB1C7
  %14 = fmul double %2, %12
  %15 = fmul double %2, %13
  %16 = fadd double %14, 0x405A8654D41DC46C
  %17 = fadd double %15, 0x4016B9F7A03E5CA6
  %18 = fmul double %4, %16
  %19 = fmul double %2, 0x409B9068A3C78607
  %20 = fsub double 0x40990C9A56964108, %19
  %21 = fmul double %2, 0x408105AF09F369D0
  %22 = fsub double 0x40912C23C604419C, %21
  %23 = fmul double %2, %20
  %24 = fmul double %2, %22
  %25 = fadd double %23, 0x4070760E04B9BCBD
  %26 = fadd double %24, 0x403AF5DBE51CBD80
  %27 = fmul double %2, %25
  %28 = fadd double %27, 1.000000e+00
  %29 = fmul double %4, %26
  br label %64

30:                                               ; preds = %7
  %31 = fmul double %2, %3
  %32 = select i1 %5, double 0xC037479D2EDA47AB, double 0xC0321838C11B2DD4
  %33 = fadd double %1, %32
  %34 = select i1 %5, double 0x40158CCE32F91DD3, double 0xBFF1103F72ECFAA8
  %35 = fadd double %31, %34
  %36 = fmul double %2, %33
  %37 = select i1 %5, double 0x400468120D7EB3C7, double 0x3FF5040D3E43FC6C
  %38 = fadd double %36, %37
  %39 = fmul double %4, %35
  %40 = select i1 %5, double 0x40179A9AC0DA87EF, double 0x4003830831C63CF0
  %41 = fmul double %2, %40
  %42 = fsub double 0x4030441296C5FB34, %41
  %43 = fadd double %41, 0xC03ABCE1630E61C0
  %44 = select i1 %5, double %43, double %42
  %45 = select i1 %5, double 0x4000D00D57F2CBBD, double 0x401D7BFF8CC54FA6
  %46 = fmul double %2, %45
  %47 = select i1 %5, double 0xC0226B8874380C5B, double 0xC026402DD156D3FC
  %48 = fadd double %46, %47
  %49 = fmul double %2, %44
  %50 = fmul double %2, %48
  %51 = select i1 %5, double 0x402AF4FD59F9A777, double 0xC031083D20CE0F89
  %52 = fadd double %49, %51
  %53 = select i1 %5, double 0x401E18FAC448D58A, double 0x3FF51C8655DB120C
  %54 = fadd double %50, %53
  %55 = fmul double %2, %52
  %56 = fmul double %2, %54
  %57 = fadd double %55, 0x4012D71DC7267483
  %58 = select i1 %5, double %55, double %56
  %59 = fadd double %58, 1.000000e+00
  %60 = select i1 %5, double %54, double %57
  %61 = fmul double %4, %60
  %62 = select i1 %5, double %61, double %59
  %63 = select i1 %5, double %59, double %61
  br label %64

64:                                               ; preds = %30, %8
  %65 = phi double [ %28, %8 ], [ %63, %30 ]
  %66 = phi double [ %29, %8 ], [ %62, %30 ]
  %67 = phi double [ %18, %8 ], [ %38, %30 ]
  %68 = phi double [ %17, %8 ], [ %39, %30 ]
  %69 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 0
  store double %65, double* %69, align 8
  %70 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 1
  store double %66, double* %70, align 8
  %71 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 2
  store double %67, double* %71, align 8
  %72 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 3
  store double %68, double* %72, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
