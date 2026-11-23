; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree norecurse nounwind
define double @region(i1 %0, double %1) #0 {
  br i1 %0, label %3, label %152

3:                                                ; preds = %2
  %4 = tail call double @llvm.amdgcn.ldexp.f64(double %1, i32 512) #3
  %5 = tail call double @llvm.amdgcn.frexp.mant.f64(double %4) #3
  %6 = fcmp olt double %5, 0x3FE5555555555555
  %7 = zext i1 %6 to i32
  %8 = tail call double @llvm.amdgcn.ldexp.f64(double %5, i32 %7) #3
  %9 = tail call i32 @llvm.amdgcn.frexp.exp.i32.f64(double %4) #3
  %10 = sub nsw i32 %9, %7
  %11 = fadd double %8, -1.000000e+00
  %12 = fadd double %8, 1.000000e+00
  %13 = fsub double %12, %8
  %14 = fsub double %12, %13
  %15 = fsub double %8, %14
  %16 = fsub double 1.000000e+00, %13
  %17 = fadd double %16, %15
  %18 = tail call double @llvm.amdgcn.rcp.f64(double %12) #3
  %19 = fneg double %12
  %20 = tail call double @llvm.fma.f64(double %19, double %18, double 1.000000e+00) #3
  %21 = tail call double @llvm.fma.f64(double %20, double %18, double %18) #3
  %22 = tail call double @llvm.fma.f64(double %19, double %21, double 1.000000e+00) #3
  %23 = tail call double @llvm.fma.f64(double %22, double %21, double %21) #3
  %24 = fmul double %11, %23
  %25 = fmul double %12, %24
  %26 = fneg double %25
  %27 = tail call double @llvm.fma.f64(double %24, double %12, double %26) #3
  %28 = tail call double @llvm.fma.f64(double %24, double %17, double %27) #3
  %29 = fadd double %25, %28
  %30 = fsub double %29, %25
  %31 = fsub double %28, %30
  %32 = fsub double %11, %29
  %33 = fsub double %11, %32
  %34 = fsub double %33, %29
  %35 = fsub double %34, %31
  %36 = fadd double %32, %35
  %37 = fmul double %23, %36
  %38 = fadd double %24, %37
  %39 = fsub double %38, %24
  %40 = fsub double %37, %39
  %41 = fmul double %38, %38
  %42 = fneg double %41
  %43 = tail call double @llvm.fma.f64(double %38, double %38, double %42) #3
  %44 = fmul double %40, 2.000000e+00
  %45 = tail call double @llvm.fma.f64(double %38, double %44, double %43) #3
  %46 = tail call double @llvm.fma.f64(double %40, double %40, double %45) #3
  %47 = fadd double %41, %46
  %48 = fsub double %47, %41
  %49 = fsub double %46, %48
  %50 = tail call double @llvm.fma.f64(double %47, double 0x3FC3AB76BF559E2B, double 0x3FC385386B47B09A) #3
  %51 = tail call double @llvm.fma.f64(double %47, double %50, double 0x3FC7474DD7F4DF2E) #3
  %52 = tail call double @llvm.fma.f64(double %47, double %51, double 0x3FCC71C016291751) #3
  %53 = tail call double @llvm.fma.f64(double %47, double %52, double 0x3FD249249B27ACF1) #3
  %54 = tail call double @llvm.fma.f64(double %47, double %53, double 0x3FD99999998EF7B6) #3
  %55 = tail call double @llvm.fma.f64(double %47, double %54, double 0x3FE5555555555780) #3
  %56 = tail call double @llvm.amdgcn.ldexp.f64(double %38, i32 1) #3
  %57 = tail call double @llvm.amdgcn.ldexp.f64(double %40, i32 1) #3
  %58 = fmul double %38, %47
  %59 = fneg double %58
  %60 = tail call double @llvm.fma.f64(double %38, double %47, double %59) #3
  %61 = fmul double %40, %47
  %62 = tail call double @llvm.fma.f64(double %38, double %49, double %61) #3
  %63 = fadd double %60, %62
  %64 = fadd double %58, %63
  %65 = fsub double %64, %58
  %66 = fsub double %63, %65
  %67 = fmul double %64, %55
  %68 = fneg double %67
  %69 = tail call double @llvm.fma.f64(double %64, double %55, double %68) #3
  %70 = tail call double @llvm.fma.f64(double %66, double %55, double %69) #3
  %71 = fadd double %67, %70
  %72 = fsub double %71, %67
  %73 = fsub double %70, %72
  %74 = fadd double %56, %71
  %75 = fsub double %74, %56
  %76 = fsub double %74, %75
  %77 = fsub double %56, %76
  %78 = fsub double %71, %75
  %79 = fadd double %78, %77
  %80 = fadd double %57, %73
  %81 = fsub double %80, %57
  %82 = fsub double %80, %81
  %83 = fsub double %57, %82
  %84 = fsub double %73, %81
  %85 = fadd double %84, %83
  %86 = fadd double %80, %79
  %87 = fadd double %74, %86
  %88 = fsub double %87, %74
  %89 = fsub double %86, %88
  %90 = fadd double %85, %89
  %91 = fadd double %87, %90
  %92 = fsub double %91, %87
  %93 = fsub double %90, %92
  %94 = sitofp i32 %10 to double
  %95 = fmul double %91, 0x3FF71547652B82FE
  %96 = fneg double %95
  %97 = fmul double %91, 0x3C7777D0FFDA0D24
  %98 = insertelement <2 x double> undef, double %91, i32 0
  %99 = insertelement <2 x double> %98, double %93, i32 1
  %100 = insertelement <2 x double> undef, double %96, i32 0
  %101 = insertelement <2 x double> %100, double %97, i32 1
  %102 = tail call <2 x double> @llvm.fma.v2f64(<2 x double> %99, <2 x double> <double 0x3FF71547652B82FE, double 0x3FF71547652B82FE>, <2 x double> %101) #3
  %103 = extractelement <2 x double> %102, i32 0
  %104 = extractelement <2 x double> %102, i32 1
  %105 = fadd double %103, %104
  %106 = fadd double %95, %105
  %107 = fsub double %106, %95
  %108 = fsub double %105, %107
  %109 = fadd double %106, %94
  %110 = fsub double %109, %94
  %111 = fsub double %110, %109
  %112 = fadd double %111, %94
  %113 = fsub double %106, %110
  %114 = fadd double %113, %112
  %115 = fadd double %108, %114
  %116 = fadd double %109, %115
  %117 = tail call double @llvm.fabs.f64(double %4) #4
  %118 = fcmp oeq double %117, 0x7FF0000000000000
  %119 = select i1 %118, double %4, double %116
  %120 = fcmp olt double %4, 0.000000e+00
  %121 = select i1 %120, double 0x7FF8000000000000, double %119
  %122 = fcmp oeq double %4, 0.000000e+00
  %123 = select i1 %122, double 0xFFF0000000000000, double %121
  %124 = fmul double %123, %123
  %125 = fmul double %124, 0x3B408480D3491A50
  %126 = fsub double 0xBD241E51766A91FB, %125
  %127 = fmul double %124, 0x3C4B275AC5F91B68
  %128 = fsub double 0xBDE40A018263D493, %127
  %129 = fmul double %124, %126
  %130 = fmul double %124, %128
  %131 = fadd double %129, 0xBE91D0F7FEBA5A35
  %132 = fadd double %130, 0xBF2F1E266EB4C824
  %133 = fmul double %124, %131
  %134 = fmul double %124, %132
  %135 = fadd double %133, 0xBFBA19EDB555D8AD
  %136 = fadd double %134, 0xC030CB31255FFA09
  %137 = fmul double %123, %135
  %138 = fsub double %136, %137
  %139 = fmul double %124, 0x3BE8FEBB5A4047D7
  %140 = fadd double %139, 0x3D9463E48A976F97
  %141 = fmul double %124, 0x3CCE78F4A7F13C7D
  %142 = fadd double %141, 0x3E46680C94743FD9
  %143 = fmul double %124, %140
  %144 = fmul double %124, %142
  %145 = fadd double %143, 0x3EE71602E8EA99F3
  %146 = fadd double %144, 0x3F762C8C65771E78
  %147 = fmul double %124, %145
  %148 = fadd double %147, 1.000000e+00
  %149 = fmul double %123, %146
  %150 = fsub double %148, %149
  %151 = fdiv double %138, %150
  br label %152

152:                                              ; preds = %3, %2
  %153 = phi double [ %151, %3 ], [ 0xFFF0000000000000, %2 ]
  ret double %153
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

attributes #0 = { nofree norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #3 = { nounwind }
attributes #4 = { nounwind readnone }
