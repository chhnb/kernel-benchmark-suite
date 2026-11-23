; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double %1, [2 x double]* %2) #0 {
  br i1 %0, label %4, label %148

4:                                                ; preds = %3
  %5 = tail call double @llvm.amdgcn.ldexp.f64(double %1, i32 3) #3
  %6 = tail call double @llvm.amdgcn.frexp.mant.f64(double %5) #3
  %7 = fcmp olt double %6, 0x3FE5555555555555
  %8 = zext i1 %7 to i32
  %9 = tail call double @llvm.amdgcn.ldexp.f64(double %6, i32 %8) #3
  %10 = tail call i32 @llvm.amdgcn.frexp.exp.i32.f64(double %5) #3
  %11 = sub nsw i32 %10, %8
  %12 = fadd double %9, -1.000000e+00
  %13 = fadd double %9, 1.000000e+00
  %14 = fsub double %13, %9
  %15 = fsub double %13, %14
  %16 = fsub double %9, %15
  %17 = fsub double 1.000000e+00, %14
  %18 = fadd double %17, %16
  %19 = tail call double @llvm.amdgcn.rcp.f64(double %13) #3
  %20 = fneg double %13
  %21 = tail call double @llvm.fma.f64(double %20, double %19, double 1.000000e+00) #3
  %22 = tail call double @llvm.fma.f64(double %21, double %19, double %19) #3
  %23 = tail call double @llvm.fma.f64(double %20, double %22, double 1.000000e+00) #3
  %24 = tail call double @llvm.fma.f64(double %23, double %22, double %22) #3
  %25 = fmul double %12, %24
  %26 = fmul double %13, %25
  %27 = fneg double %26
  %28 = tail call double @llvm.fma.f64(double %25, double %13, double %27) #3
  %29 = tail call double @llvm.fma.f64(double %25, double %18, double %28) #3
  %30 = fadd double %26, %29
  %31 = fsub double %30, %26
  %32 = fsub double %29, %31
  %33 = fsub double %12, %30
  %34 = fsub double %12, %33
  %35 = fsub double %34, %30
  %36 = fsub double %35, %32
  %37 = fadd double %33, %36
  %38 = fmul double %24, %37
  %39 = fadd double %25, %38
  %40 = fsub double %39, %25
  %41 = fsub double %38, %40
  %42 = fmul double %39, %39
  %43 = fneg double %42
  %44 = tail call double @llvm.fma.f64(double %39, double %39, double %43) #3
  %45 = fmul double %41, 2.000000e+00
  %46 = tail call double @llvm.fma.f64(double %39, double %45, double %44) #3
  %47 = tail call double @llvm.fma.f64(double %41, double %41, double %46) #3
  %48 = fadd double %42, %47
  %49 = fsub double %48, %42
  %50 = fsub double %47, %49
  %51 = tail call double @llvm.fma.f64(double %48, double 0x3FC3AB76BF559E2B, double 0x3FC385386B47B09A) #3
  %52 = tail call double @llvm.fma.f64(double %48, double %51, double 0x3FC7474DD7F4DF2E) #3
  %53 = tail call double @llvm.fma.f64(double %48, double %52, double 0x3FCC71C016291751) #3
  %54 = tail call double @llvm.fma.f64(double %48, double %53, double 0x3FD249249B27ACF1) #3
  %55 = tail call double @llvm.fma.f64(double %48, double %54, double 0x3FD99999998EF7B6) #3
  %56 = tail call double @llvm.fma.f64(double %48, double %55, double 0x3FE5555555555780) #3
  %57 = tail call double @llvm.amdgcn.ldexp.f64(double %39, i32 1) #3
  %58 = tail call double @llvm.amdgcn.ldexp.f64(double %41, i32 1) #3
  %59 = fmul double %39, %48
  %60 = fneg double %59
  %61 = tail call double @llvm.fma.f64(double %39, double %48, double %60) #3
  %62 = fmul double %41, %48
  %63 = tail call double @llvm.fma.f64(double %39, double %50, double %62) #3
  %64 = fadd double %61, %63
  %65 = fadd double %59, %64
  %66 = fsub double %65, %59
  %67 = fsub double %64, %66
  %68 = fmul double %65, %56
  %69 = fneg double %68
  %70 = tail call double @llvm.fma.f64(double %65, double %56, double %69) #3
  %71 = tail call double @llvm.fma.f64(double %67, double %56, double %70) #3
  %72 = fadd double %68, %71
  %73 = fsub double %72, %68
  %74 = fsub double %71, %73
  %75 = fadd double %57, %72
  %76 = fsub double %75, %57
  %77 = fsub double %75, %76
  %78 = fsub double %57, %77
  %79 = fsub double %72, %76
  %80 = fadd double %79, %78
  %81 = fadd double %58, %74
  %82 = fsub double %81, %58
  %83 = fsub double %81, %82
  %84 = fsub double %58, %83
  %85 = fsub double %74, %82
  %86 = fadd double %85, %84
  %87 = fadd double %81, %80
  %88 = fadd double %75, %87
  %89 = fsub double %88, %75
  %90 = fsub double %87, %89
  %91 = fadd double %86, %90
  %92 = fadd double %88, %91
  %93 = fsub double %92, %88
  %94 = fsub double %91, %93
  %95 = sitofp i32 %11 to double
  %96 = fmul double %92, 0x3FF71547652B82FE
  %97 = fneg double %96
  %98 = fmul double %92, 0x3C7777D0FFDA0D24
  %99 = insertelement <2 x double> undef, double %92, i32 0
  %100 = insertelement <2 x double> %99, double %94, i32 1
  %101 = insertelement <2 x double> undef, double %97, i32 0
  %102 = insertelement <2 x double> %101, double %98, i32 1
  %103 = tail call <2 x double> @llvm.fma.v2f64(<2 x double> %100, <2 x double> <double 0x3FF71547652B82FE, double 0x3FF71547652B82FE>, <2 x double> %102) #3
  %104 = extractelement <2 x double> %103, i32 0
  %105 = extractelement <2 x double> %103, i32 1
  %106 = fadd double %104, %105
  %107 = fadd double %96, %106
  %108 = fsub double %107, %96
  %109 = fsub double %106, %108
  %110 = fadd double %107, %95
  %111 = fsub double %110, %95
  %112 = fsub double %111, %110
  %113 = fadd double %112, %95
  %114 = fsub double %107, %111
  %115 = fadd double %114, %113
  %116 = fadd double %109, %115
  %117 = fadd double %110, %116
  %118 = tail call double @llvm.fabs.f64(double %5) #4
  %119 = fcmp oeq double %118, 0x7FF0000000000000
  %120 = select i1 %119, double %5, double %117
  %121 = fcmp olt double %5, 0.000000e+00
  %122 = select i1 %121, double 0x7FF8000000000000, double %120
  %123 = fcmp oeq double %5, 0.000000e+00
  %124 = select i1 %123, double 0xFFF0000000000000, double %122
  %125 = fmul double %124, %124
  %126 = fmul double %125, 0x3EDBD077F856B461
  %127 = fsub double 0x3F78C25CB1F33D41, %126
  %128 = fmul double %125, 0x3F40AF40801BC234
  %129 = fadd double %128, 0x3FA89B8093A2295C
  %130 = fmul double %125, %127
  %131 = fmul double %125, %129
  %132 = fadd double %130, 0x3FCF140D06064BE5
  %133 = fadd double %131, 0x3FE570FCC3570002
  %134 = fmul double %125, %132
  %135 = fadd double %134, 0x3FE6B9F7A03E5CA5
  %136 = fmul double %124, %133
  %137 = fsub double %135, %136
  %138 = fmul double %125, 0x3F44ACEECE75B689
  %139 = fadd double %138, 0x3FB48180AD0CAC24
  %140 = fmul double %125, 0x3F8497E40449A14F
  %141 = fadd double %140, 0x3FD7722E0F8ACAA8
  %142 = fmul double %125, %139
  %143 = fmul double %125, %141
  %144 = fadd double %142, 0x3FED6593E87A041B
  %145 = fadd double %143, 1.000000e+00
  %146 = fmul double %124, %144
  %147 = fsub double %145, %146
  br label %148

148:                                              ; preds = %4, %3
  %149 = phi double [ %137, %4 ], [ 2.000000e+00, %3 ]
  %150 = phi double [ %147, %4 ], [ 0x400921FB54442D18, %3 ]
  %151 = getelementptr inbounds [2 x double], [2 x double]* %2, i32 0, i32 0
  store double %149, double* %151, align 8
  %152 = getelementptr inbounds [2 x double], [2 x double]* %2, i32 0, i32 1
  store double %150, double* %152, align 8
  ret void
}

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.amdgcn.ldexp.f64(double, i32) #1

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.amdgcn.frexp.mant.f64(double) #1

; Function Attrs: nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.frexp.exp.i32.f64(double) #1

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.amdgcn.rcp.f64(double) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.fma.f64(double, double, double) #2

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare <2 x double> @llvm.fma.v2f64(<2 x double>, <2 x double>, <2 x double>) #2

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.fabs.f64(double) #2

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #3 = { nounwind }
attributes #4 = { nounwind readnone }
