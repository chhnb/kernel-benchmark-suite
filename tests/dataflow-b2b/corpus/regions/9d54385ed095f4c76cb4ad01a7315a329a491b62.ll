; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double %1, double %2, i1 %3, [4 x double]* %4) #0 {
  br i1 %0, label %6, label %31

6:                                                ; preds = %5
  %7 = fmul double %1, 0x4094388834A6E4C6
  %8 = fadd double %7, 0xC0ADEA3D7D257F67
  %9 = fmul double %1, 0x40A377E7779F4961
  %10 = fadd double %9, 0xC0A6DC23D7E5E636
  %11 = fmul double %1, %8
  %12 = fmul double %1, %10
  %13 = fadd double %11, 0x407EB1E0C584548E
  %14 = fadd double %12, 0x4081F4137E2FB1C7
  %15 = fmul double %1, %13
  %16 = fmul double %1, %14
  %17 = fadd double %15, 0x405A8654D41DC46C
  %18 = fadd double %16, 0x4016B9F7A03E5CA6
  %19 = fmul double %2, %17
  %20 = fmul double %1, 0x409B9068A3C78607
  %21 = fsub double 0x40990C9A56964108, %20
  %22 = fmul double %1, 0x408105AF09F369D0
  %23 = fsub double 0x40912C23C604419C, %22
  %24 = fmul double %1, %21
  %25 = fmul double %1, %23
  %26 = fadd double %24, 0x4070760E04B9BCBD
  %27 = fadd double %25, 0x403AF5DBE51CBD80
  %28 = fmul double %1, %26
  %29 = fadd double %28, 1.000000e+00
  %30 = fmul double %2, %27
  br label %74

31:                                               ; preds = %5
  %32 = select i1 %3, double 0x40277F82F0DAE120, double 0x403C1881A9A265FD
  %33 = fmul double %1, %32
  %34 = select i1 %3, double 0x404307CEA86A355B, double 0x404790211A5124A0
  %35 = fsub double %34, %33
  %36 = select i1 %3, double 0x4040C02F41527F9A, double 0x40127122E53E19ED
  %37 = fmul double %1, %36
  %38 = select i1 %3, double 0xC043CD5B8EF4636A, double 0xBFF88D9974F43E7E
  %39 = fadd double %37, %38
  %40 = fmul double %1, %35
  %41 = fmul double %1, %39
  %42 = select i1 %3, double 0xC037479D2EDA47AB, double 0xC0321838C11B2DD4
  %43 = fadd double %40, %42
  %44 = select i1 %3, double 0x40158CCE32F91DD3, double 0xBFF1103F72ECFAA8
  %45 = fadd double %41, %44
  %46 = fmul double %1, %43
  %47 = select i1 %3, double 0x400468120D7EB3C7, double 0x3FF5040D3E43FC6C
  %48 = fadd double %46, %47
  %49 = fmul double %2, %45
  %50 = select i1 %3, double 0x40179A9AC0DA87EF, double 0x4003830831C63CF0
  %51 = fmul double %1, %50
  %52 = fsub double 0x4030441296C5FB34, %51
  %53 = fadd double %51, 0xC03ABCE1630E61C0
  %54 = select i1 %3, double %53, double %52
  %55 = select i1 %3, double 0x4000D00D57F2CBBD, double 0x401D7BFF8CC54FA6
  %56 = fmul double %1, %55
  %57 = select i1 %3, double 0xC0226B8874380C5B, double 0xC026402DD156D3FC
  %58 = fadd double %56, %57
  %59 = fmul double %1, %54
  %60 = fmul double %1, %58
  %61 = select i1 %3, double 0x402AF4FD59F9A777, double 0xC031083D20CE0F89
  %62 = fadd double %59, %61
  %63 = select i1 %3, double 0x401E18FAC448D58A, double 0x3FF51C8655DB120C
  %64 = fadd double %60, %63
  %65 = fmul double %1, %62
  %66 = fmul double %1, %64
  %67 = fadd double %65, 0x4012D71DC7267483
  %68 = select i1 %3, double %65, double %66
  %69 = fadd double %68, 1.000000e+00
  %70 = select i1 %3, double %64, double %67
  %71 = fmul double %2, %70
  %72 = select i1 %3, double %71, double %69
  %73 = select i1 %3, double %69, double %71
  br label %74

74:                                               ; preds = %31, %6
  %75 = phi double [ %29, %6 ], [ %73, %31 ]
  %76 = phi double [ %30, %6 ], [ %72, %31 ]
  %77 = phi double [ %19, %6 ], [ %48, %31 ]
  %78 = phi double [ %18, %6 ], [ %49, %31 ]
  %79 = getelementptr inbounds [4 x double], [4 x double]* %4, i32 0, i32 0
  store double %75, double* %79, align 8
  %80 = getelementptr inbounds [4 x double], [4 x double]* %4, i32 0, i32 1
  store double %76, double* %80, align 8
  %81 = getelementptr inbounds [4 x double], [4 x double]* %4, i32 0, i32 2
  store double %77, double* %81, align 8
  %82 = getelementptr inbounds [4 x double], [4 x double]* %4, i32 0, i32 3
  store double %78, double* %82, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
