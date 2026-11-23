; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double %1, [4 x double]* %2) #0 {
  br i1 %0, label %4, label %31

4:                                                ; preds = %3
  %5 = fadd double %1, -1.250000e-01
  %6 = fmul double %5, %5
  %7 = fmul double %6, 0x4094388834A6E4C6
  %8 = fadd double %7, 0xC0ADEA3D7D257F67
  %9 = fmul double %6, 0x40A377E7779F4961
  %10 = fadd double %9, 0xC0A6DC23D7E5E636
  %11 = fmul double %6, %8
  %12 = fmul double %6, %10
  %13 = fadd double %11, 0x407EB1E0C584548E
  %14 = fadd double %12, 0x4081F4137E2FB1C7
  %15 = fmul double %6, %13
  %16 = fmul double %6, %14
  %17 = fadd double %15, 0x405A8654D41DC46C
  %18 = fadd double %16, 0x4016B9F7A03E5CA6
  %19 = fmul double %5, %17
  %20 = fmul double %6, 0x409B9068A3C78607
  %21 = fsub double 0x40990C9A56964108, %20
  %22 = fmul double %6, 0x408105AF09F369D0
  %23 = fsub double 0x40912C23C604419C, %22
  %24 = fmul double %6, %21
  %25 = fmul double %6, %23
  %26 = fadd double %24, 0x4070760E04B9BCBD
  %27 = fadd double %25, 0x403AF5DBE51CBD80
  %28 = fmul double %6, %26
  %29 = fadd double %28, 1.000000e+00
  %30 = fmul double %5, %27
  br label %78

31:                                               ; preds = %3
  %32 = fcmp ult double %1, 3.750000e-01
  %33 = select i1 %32, double -2.500000e-01, double -3.750000e-01
  %34 = fadd double %1, %33
  %35 = fmul double %34, %34
  %36 = select i1 %32, double 0x40277F82F0DAE120, double 0x403C1881A9A265FD
  %37 = fmul double %35, %36
  %38 = select i1 %32, double 0x404307CEA86A355B, double 0x404790211A5124A0
  %39 = fsub double %38, %37
  %40 = select i1 %32, double 0x4040C02F41527F9A, double 0x40127122E53E19ED
  %41 = fmul double %35, %40
  %42 = select i1 %32, double 0xC043CD5B8EF4636A, double 0xBFF88D9974F43E7E
  %43 = fadd double %41, %42
  %44 = fmul double %35, %39
  %45 = fmul double %35, %43
  %46 = select i1 %32, double 0xC037479D2EDA47AB, double 0xC0321838C11B2DD4
  %47 = fadd double %44, %46
  %48 = select i1 %32, double 0x40158CCE32F91DD3, double 0xBFF1103F72ECFAA8
  %49 = fadd double %45, %48
  %50 = fmul double %35, %47
  %51 = select i1 %32, double 0x400468120D7EB3C7, double 0x3FF5040D3E43FC6C
  %52 = fadd double %50, %51
  %53 = fmul double %34, %49
  %54 = select i1 %32, double 0x40179A9AC0DA87EF, double 0x4003830831C63CF0
  %55 = fmul double %35, %54
  %56 = fsub double 0x4030441296C5FB34, %55
  %57 = fadd double %55, 0xC03ABCE1630E61C0
  %58 = select i1 %32, double %57, double %56
  %59 = select i1 %32, double 0x4000D00D57F2CBBD, double 0x401D7BFF8CC54FA6
  %60 = fmul double %35, %59
  %61 = select i1 %32, double 0xC0226B8874380C5B, double 0xC026402DD156D3FC
  %62 = fadd double %60, %61
  %63 = fmul double %35, %58
  %64 = fmul double %35, %62
  %65 = select i1 %32, double 0x402AF4FD59F9A777, double 0xC031083D20CE0F89
  %66 = fadd double %63, %65
  %67 = select i1 %32, double 0x401E18FAC448D58A, double 0x3FF51C8655DB120C
  %68 = fadd double %64, %67
  %69 = fmul double %35, %66
  %70 = fmul double %35, %68
  %71 = fadd double %69, 0x4012D71DC7267483
  %72 = select i1 %32, double %69, double %70
  %73 = fadd double %72, 1.000000e+00
  %74 = select i1 %32, double %68, double %71
  %75 = fmul double %34, %74
  %76 = select i1 %32, double %75, double %73
  %77 = select i1 %32, double %73, double %75
  br label %78

78:                                               ; preds = %31, %4
  %79 = phi double [ %29, %4 ], [ %77, %31 ]
  %80 = phi double [ %30, %4 ], [ %76, %31 ]
  %81 = phi double [ %19, %4 ], [ %52, %31 ]
  %82 = phi double [ %18, %4 ], [ %53, %31 ]
  %83 = getelementptr inbounds [4 x double], [4 x double]* %2, i32 0, i32 0
  store double %79, double* %83, align 8
  %84 = getelementptr inbounds [4 x double], [4 x double]* %2, i32 0, i32 1
  store double %80, double* %84, align 8
  %85 = getelementptr inbounds [4 x double], [4 x double]* %2, i32 0, i32 2
  store double %81, double* %85, align 8
  %86 = getelementptr inbounds [4 x double], [4 x double]* %2, i32 0, i32 3
  store double %82, double* %86, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
