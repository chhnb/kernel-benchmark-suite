; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, i1 %4, [4 x double]* %5) #0 {
  br i1 %0, label %7, label %31

7:                                                ; preds = %6
  %8 = fadd double %1, 0xC0ADEA3D7D257F67
  %9 = fmul double %2, 0x40A377E7779F4961
  %10 = fadd double %9, 0xC0A6DC23D7E5E636
  %11 = fmul double %2, %8
  %12 = fmul double %2, %10
  %13 = fadd double %11, 0x407EB1E0C584548E
  %14 = fadd double %12, 0x4081F4137E2FB1C7
  %15 = fmul double %2, %13
  %16 = fmul double %2, %14
  %17 = fadd double %15, 0x405A8654D41DC46C
  %18 = fadd double %16, 0x4016B9F7A03E5CA6
  %19 = fmul double %3, %17
  %20 = fmul double %2, 0x409B9068A3C78607
  %21 = fsub double 0x40990C9A56964108, %20
  %22 = fmul double %2, 0x408105AF09F369D0
  %23 = fsub double 0x40912C23C604419C, %22
  %24 = fmul double %2, %21
  %25 = fmul double %2, %23
  %26 = fadd double %24, 0x4070760E04B9BCBD
  %27 = fadd double %25, 0x403AF5DBE51CBD80
  %28 = fmul double %2, %26
  %29 = fadd double %28, 1.000000e+00
  %30 = fmul double %3, %27
  br label %72

31:                                               ; preds = %6
  %32 = select i1 %4, double 0x404307CEA86A355B, double 0x404790211A5124A0
  %33 = select i1 %4, double 0x40277F82F0DAE120, double 0x403C1881A9A265FD
  %34 = fmul double %2, %33
  %35 = fsub double %32, %34
  %36 = select i1 %4, double 0xC043CD5B8EF4636A, double 0xBFF88D9974F43E7E
  %37 = fadd double %1, %36
  %38 = fmul double %2, %35
  %39 = fmul double %2, %37
  %40 = select i1 %4, double 0xC037479D2EDA47AB, double 0xC0321838C11B2DD4
  %41 = fadd double %38, %40
  %42 = select i1 %4, double 0x40158CCE32F91DD3, double 0xBFF1103F72ECFAA8
  %43 = fadd double %39, %42
  %44 = fmul double %2, %41
  %45 = select i1 %4, double 0x400468120D7EB3C7, double 0x3FF5040D3E43FC6C
  %46 = fadd double %44, %45
  %47 = fmul double %3, %43
  %48 = select i1 %4, double 0x40179A9AC0DA87EF, double 0x4003830831C63CF0
  %49 = fmul double %2, %48
  %50 = fsub double 0x4030441296C5FB34, %49
  %51 = fadd double %49, 0xC03ABCE1630E61C0
  %52 = select i1 %4, double %51, double %50
  %53 = select i1 %4, double 0x4000D00D57F2CBBD, double 0x401D7BFF8CC54FA6
  %54 = fmul double %2, %53
  %55 = select i1 %4, double 0xC0226B8874380C5B, double 0xC026402DD156D3FC
  %56 = fadd double %54, %55
  %57 = fmul double %2, %52
  %58 = fmul double %2, %56
  %59 = select i1 %4, double 0x402AF4FD59F9A777, double 0xC031083D20CE0F89
  %60 = fadd double %57, %59
  %61 = select i1 %4, double 0x401E18FAC448D58A, double 0x3FF51C8655DB120C
  %62 = fadd double %58, %61
  %63 = fmul double %2, %60
  %64 = fmul double %2, %62
  %65 = fadd double %63, 0x4012D71DC7267483
  %66 = select i1 %4, double %63, double %64
  %67 = fadd double %66, 1.000000e+00
  %68 = select i1 %4, double %62, double %65
  %69 = fmul double %3, %68
  %70 = select i1 %4, double %69, double %67
  %71 = select i1 %4, double %67, double %69
  br label %72

72:                                               ; preds = %31, %7
  %73 = phi double [ %29, %7 ], [ %71, %31 ]
  %74 = phi double [ %30, %7 ], [ %70, %31 ]
  %75 = phi double [ %19, %7 ], [ %46, %31 ]
  %76 = phi double [ %18, %7 ], [ %47, %31 ]
  %77 = getelementptr inbounds [4 x double], [4 x double]* %5, i32 0, i32 0
  store double %73, double* %77, align 8
  %78 = getelementptr inbounds [4 x double], [4 x double]* %5, i32 0, i32 1
  store double %74, double* %78, align 8
  %79 = getelementptr inbounds [4 x double], [4 x double]* %5, i32 0, i32 2
  store double %75, double* %79, align 8
  %80 = getelementptr inbounds [4 x double], [4 x double]* %5, i32 0, i32 3
  store double %76, double* %80, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
