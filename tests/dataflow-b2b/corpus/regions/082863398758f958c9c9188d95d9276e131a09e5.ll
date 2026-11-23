; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree norecurse nounwind willreturn
define void @region(i1 %0, double %1, double %2, double %3, double %4, double %5, double %6, double %7, double %8, double %9, double %10, double %11, double %12, double %13, double %14, double %15, double %16, [6 x double]* %17) #0 {
  br i1 %0, label %19, label %109

19:                                               ; preds = %18
  %20 = fcmp olt double %1, 0x1000000000000000
  %21 = select i1 %20, double 0x4FF0000000000000, double 1.000000e+00
  %22 = fmul double %1, %21
  %23 = tail call double @llvm.amdgcn.rsq.f64(double %22) #3
  %24 = fmul double %22, %23
  %25 = fmul double %23, 5.000000e-01
  %26 = fneg double %25
  %27 = tail call double @llvm.fma.f64(double %26, double %24, double 5.000000e-01) #3
  %28 = tail call double @llvm.fma.f64(double %25, double %27, double %25) #3
  %29 = tail call double @llvm.fma.f64(double %24, double %27, double %24) #3
  %30 = fneg double %29
  %31 = tail call double @llvm.fma.f64(double %30, double %29, double %22) #3
  %32 = tail call double @llvm.fma.f64(double %31, double %28, double %29) #3
  %33 = fneg double %32
  %34 = tail call double @llvm.fma.f64(double %33, double %32, double %22) #3
  %35 = tail call double @llvm.fma.f64(double %34, double %28, double %32) #3
  %36 = select i1 %20, double 0x37F0000000000000, double 1.000000e+00
  %37 = fmul double %36, %35
  %38 = fcmp oeq double %22, 0.000000e+00
  %39 = fcmp oeq double %22, 0x7FF0000000000000
  %40 = or i1 %38, %39
  %41 = select i1 %40, double %22, double %37
  %42 = fcmp olt double %2, 0x1000000000000000
  %43 = select i1 %42, double 0x4FF0000000000000, double 1.000000e+00
  %44 = fmul double %2, %43
  %45 = tail call double @llvm.amdgcn.rsq.f64(double %44) #3
  %46 = fmul double %44, %45
  %47 = fmul double %45, 5.000000e-01
  %48 = fneg double %47
  %49 = tail call double @llvm.fma.f64(double %48, double %46, double 5.000000e-01) #3
  %50 = tail call double @llvm.fma.f64(double %47, double %49, double %47) #3
  %51 = tail call double @llvm.fma.f64(double %46, double %49, double %46) #3
  %52 = fneg double %51
  %53 = tail call double @llvm.fma.f64(double %52, double %51, double %44) #3
  %54 = tail call double @llvm.fma.f64(double %53, double %50, double %51) #3
  %55 = fneg double %54
  %56 = tail call double @llvm.fma.f64(double %55, double %54, double %44) #3
  %57 = tail call double @llvm.fma.f64(double %56, double %50, double %54) #3
  %58 = select i1 %42, double 0x37F0000000000000, double 1.000000e+00
  %59 = fmul double %58, %57
  %60 = fcmp oeq double %44, 0.000000e+00
  %61 = fcmp oeq double %44, 0x7FF0000000000000
  %62 = or i1 %60, %61
  %63 = select i1 %62, double %44, double %59
  %64 = fadd double %41, %63
  %65 = fdiv double 1.000000e+00, %64
  %66 = tail call double @llvm.copysign.f64(double 1.000000e+00, double %3) #3
  %67 = fmul double %41, %4
  %68 = fmul double %63, %5
  %69 = fadd double %67, %68
  %70 = fsub double %6, %7
  %71 = fmul double %66, %70
  %72 = fadd double %69, %71
  %73 = fmul double %65, %72
  %74 = fmul double %41, %8
  %75 = fmul double %63, %9
  %76 = fadd double %74, %75
  %77 = fsub double %10, %11
  %78 = fmul double %66, %77
  %79 = fadd double %76, %78
  %80 = fmul double %65, %79
  %81 = fmul double %41, %6
  %82 = fmul double %63, %7
  %83 = fadd double %82, %81
  %84 = fmul double %41, %63
  %85 = fmul double %66, %84
  %86 = fsub double %5, %4
  %87 = fmul double %85, %86
  %88 = fadd double %87, %83
  %89 = fmul double %65, %88
  %90 = fmul double %41, %10
  %91 = fmul double %63, %11
  %92 = fadd double %91, %90
  %93 = fsub double %9, %8
  %94 = fmul double %85, %93
  %95 = fadd double %94, %92
  %96 = fmul double %65, %95
  %97 = fmul double %73, %89
  %98 = fmul double %80, %96
  %99 = fadd double %97, %98
  %100 = fadd double %12, %99
  %101 = fmul double %66, %41
  %102 = fsub double %13, %100
  %103 = fmul double %101, %102
  %104 = fsub double %14, %103
  %105 = fmul double %66, %63
  %106 = fsub double %15, %100
  %107 = fmul double %105, %106
  %108 = fadd double %16, %107
  br label %109

109:                                              ; preds = %19, %18
  %110 = phi double [ %108, %19 ], [ %16, %18 ]
  %111 = phi double [ %104, %19 ], [ 0.000000e+00, %18 ]
  %112 = phi double [ %96, %19 ], [ %10, %18 ]
  %113 = phi double [ %89, %19 ], [ %6, %18 ]
  %114 = phi double [ %80, %19 ], [ %9, %18 ]
  %115 = phi double [ %73, %19 ], [ %5, %18 ]
  %116 = getelementptr inbounds [6 x double], [6 x double]* %17, i32 0, i32 0
  store double %110, double* %116, align 8
  %117 = getelementptr inbounds [6 x double], [6 x double]* %17, i32 0, i32 1
  store double %111, double* %117, align 8
  %118 = getelementptr inbounds [6 x double], [6 x double]* %17, i32 0, i32 2
  store double %112, double* %118, align 8
  %119 = getelementptr inbounds [6 x double], [6 x double]* %17, i32 0, i32 3
  store double %113, double* %119, align 8
  %120 = getelementptr inbounds [6 x double], [6 x double]* %17, i32 0, i32 4
  store double %114, double* %120, align 8
  %121 = getelementptr inbounds [6 x double], [6 x double]* %17, i32 0, i32 5
  store double %115, double* %121, align 8
  ret void
}

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.amdgcn.rsq.f64(double) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.fma.f64(double, double, double) #2

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.copysign.f64(double, double) #2

attributes #0 = { nofree norecurse nounwind willreturn "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #3 = { nounwind }
