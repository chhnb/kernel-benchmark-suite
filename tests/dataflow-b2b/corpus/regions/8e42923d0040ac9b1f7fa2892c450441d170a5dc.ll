; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, double %5, double %6, double %7, [13 x double]* %8) #0 {
  br i1 %0, label %10, label %53

10:                                               ; preds = %9
  %11 = insertelement <2 x double> undef, double %1, i32 0
  %12 = insertelement <2 x double> %11, double %2, i32 1
  %13 = insertelement <2 x double> undef, double %3, i32 0
  %14 = insertelement <2 x double> %13, double %4, i32 1
  %15 = tail call <2 x double> @llvm.fma.v2f64(<2 x double> %12, <2 x double> <double 0x3FF71547652B82FE, double 0x3FF71547652B82FE>, <2 x double> %14) #2
  %16 = extractelement <2 x double> %15, i32 0
  %17 = extractelement <2 x double> %15, i32 1
  %18 = fadd double %16, %17
  %19 = fadd double %5, %18
  %20 = fsub double %19, %5
  %21 = fsub double %18, %20
  %22 = fadd double %19, %6
  %23 = fsub double %22, %6
  %24 = fsub double %23, %22
  %25 = fadd double %24, %6
  %26 = fsub double %19, %23
  %27 = fadd double %26, %25
  %28 = fadd double %21, %27
  %29 = fadd double %22, %28
  %30 = tail call double @llvm.fabs.f64(double %7) #3
  %31 = fcmp oeq double %30, 0x7FF0000000000000
  %32 = select i1 %31, double %7, double %29
  %33 = fcmp olt double %7, 0.000000e+00
  %34 = select i1 %33, double 0x7FF8000000000000, double %32
  %35 = fcmp oeq double %7, 0.000000e+00
  %36 = select i1 %35, double 0xFFF0000000000000, double %34
  %37 = fmul double %36, %36
  %38 = fmul double %37, 0x3C79498433579691
  %39 = fsub double 0x3E495C1E8002A2F3, %38
  %40 = fmul double %37, 0x3DE864F7A333A155
  %41 = fadd double %40, 0x3E9EABE0F5513556
  %42 = fmul double %37, %39
  %43 = fmul double %37, %41
  %44 = fadd double %42, 0x3EE98327A9C0F60B
  %45 = fadd double %43, 0x3F2EDE27BF6E2989
  %46 = fmul double %37, %44
  %47 = fmul double %37, %45
  %48 = fadd double %46, 0x3F6B2BC23526CCD2
  %49 = fadd double %47, 0x3FA0CC4805CE702A
  %50 = fmul double %37, %48
  %51 = fmul double %37, %49
  %52 = fadd double %50, 0x3FCA6EBA13EF1190
  br label %94

53:                                               ; preds = %9
  %54 = insertelement <2 x double> undef, double %1, i32 0
  %55 = insertelement <2 x double> %54, double %2, i32 1
  %56 = insertelement <2 x double> undef, double %3, i32 0
  %57 = insertelement <2 x double> %56, double %4, i32 1
  %58 = tail call <2 x double> @llvm.fma.v2f64(<2 x double> %55, <2 x double> <double 0x3FF71547652B82FE, double 0x3FF71547652B82FE>, <2 x double> %57) #2
  %59 = extractelement <2 x double> %58, i32 0
  %60 = extractelement <2 x double> %58, i32 1
  %61 = fadd double %59, %60
  %62 = fadd double %5, %61
  %63 = fsub double %62, %5
  %64 = fsub double %61, %63
  %65 = fadd double %62, %6
  %66 = fsub double %65, %6
  %67 = fsub double %66, %65
  %68 = fadd double %67, %6
  %69 = fsub double %62, %66
  %70 = fadd double %69, %68
  %71 = fadd double %64, %70
  %72 = fadd double %65, %71
  %73 = tail call double @llvm.fabs.f64(double %7) #3
  %74 = fcmp oeq double %73, 0x7FF0000000000000
  %75 = select i1 %74, double %7, double %72
  %76 = fcmp olt double %7, 0.000000e+00
  %77 = select i1 %76, double 0x7FF8000000000000, double %75
  %78 = fcmp oeq double %7, 0.000000e+00
  %79 = select i1 %78, double 0xFFF0000000000000, double %77
  %80 = fmul double %79, %79
  %81 = fmul double %80, 0x3E36A0C73E300E6B
  %82 = fadd double %81, 0x3EC7DFD742A8FC88
  %83 = fmul double %80, 0x3E79AA80A6F64859
  %84 = fadd double %83, 0x3F097D0FE1D7D8F2
  %85 = fmul double %80, %82
  %86 = fmul double %80, %84
  %87 = fadd double %85, 0x3F46894B5AD794D5
  %88 = fadd double %86, 0x3F7DB25E4C9E7FD4
  %89 = fmul double %80, %87
  %90 = fmul double %80, %88
  %91 = fadd double %89, 0x3FAC2661E760FEEA
  %92 = fadd double %90, 0x3FD12C697DF74133
  %93 = fmul double %80, %91
  br label %94

94:                                               ; preds = %53, %10
  %95 = phi double [ 0x3FD4C357E0FB8D40, %10 ], [ 0x3FDAF9DE32D5716C, %53 ]
  %96 = phi double [ 0x3FAA6202C31DEDAF, %10 ], [ 0x3FB61BE1285F7AC2, %53 ]
  %97 = phi double [ 0x3F75579E42D43198, %10 ], [ 0x3F8752E2DAA7BC3C, %53 ]
  %98 = phi double [ 0x3F383DD0A4891FC2, %10 ], [ 0x3F51B33174D75BD6, %53 ]
  %99 = phi double [ 0x3EF409E2C6442ECB, %10 ], [ 0x3F1404C590EDED62, %53 ]
  %100 = phi double [ 0x3E53EB10DB8936AA, %10 ], [ 0x3E842875EC14B32B, %53 ]
  %101 = phi double [ 0x3EA816907A00ED43, %10 ], [ 0x3ED2C03A84AD3954, %53 ]
  %102 = phi double [ 0x3DF328AAD4028837, %10 ], [ 0x3E41C5A32EBEB036, %53 ]
  %103 = phi double [ %37, %10 ], [ %80, %53 ]
  %104 = phi double [ %52, %10 ], [ %92, %53 ]
  %105 = phi double [ %36, %10 ], [ %79, %53 ]
  %106 = phi double [ 0x3FE460008BE31186, %10 ], [ 0x3FE45F306F7BD51E, %53 ]
  %107 = phi double [ %51, %10 ], [ %93, %53 ]
  %108 = getelementptr inbounds [13 x double], [13 x double]* %8, i32 0, i32 0
  store double %95, double* %108, align 8
  %109 = getelementptr inbounds [13 x double], [13 x double]* %8, i32 0, i32 1
  store double %96, double* %109, align 8
  %110 = getelementptr inbounds [13 x double], [13 x double]* %8, i32 0, i32 2
  store double %97, double* %110, align 8
  %111 = getelementptr inbounds [13 x double], [13 x double]* %8, i32 0, i32 3
  store double %98, double* %111, align 8
  %112 = getelementptr inbounds [13 x double], [13 x double]* %8, i32 0, i32 4
  store double %99, double* %112, align 8
  %113 = getelementptr inbounds [13 x double], [13 x double]* %8, i32 0, i32 5
  store double %100, double* %113, align 8
  %114 = getelementptr inbounds [13 x double], [13 x double]* %8, i32 0, i32 6
  store double %101, double* %114, align 8
  %115 = getelementptr inbounds [13 x double], [13 x double]* %8, i32 0, i32 7
  store double %102, double* %115, align 8
  %116 = getelementptr inbounds [13 x double], [13 x double]* %8, i32 0, i32 8
  store double %103, double* %116, align 8
  %117 = getelementptr inbounds [13 x double], [13 x double]* %8, i32 0, i32 9
  store double %104, double* %117, align 8
  %118 = getelementptr inbounds [13 x double], [13 x double]* %8, i32 0, i32 10
  store double %105, double* %118, align 8
  %119 = getelementptr inbounds [13 x double], [13 x double]* %8, i32 0, i32 11
  store double %106, double* %119, align 8
  %120 = getelementptr inbounds [13 x double], [13 x double]* %8, i32 0, i32 12
  store double %107, double* %120, align 8
  ret void
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare <2 x double> @llvm.fma.v2f64(<2 x double>, <2 x double>, <2 x double>) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.fabs.f64(double) #1

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { nounwind }
attributes #3 = { nounwind readnone }
