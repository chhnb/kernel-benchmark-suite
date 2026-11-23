; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, [32 x double]* %4) #0 {
  br i1 %0, label %27, label %6

6:                                                ; preds = %5
  %7 = fcmp oeq double %1, 0x7FF0000000000000
  %8 = select i1 %7, double %2, double %3
  %9 = fcmp olt double %2, 0.000000e+00
  %10 = select i1 %9, double 0x7FF8000000000000, double %8
  %11 = fcmp oeq double %2, 0.000000e+00
  %12 = select i1 %11, double 0xFFF0000000000000, double %10
  %13 = fmul double %12, %12
  %14 = fmul double %13, 0x3E36A0C73E300E6B
  %15 = fadd double %14, 0x3EC7DFD742A8FC88
  %16 = fmul double %13, 0x3E79AA80A6F64859
  %17 = fadd double %16, 0x3F097D0FE1D7D8F2
  %18 = fmul double %13, %15
  %19 = fmul double %13, %17
  %20 = fadd double %18, 0x3F46894B5AD794D5
  %21 = fadd double %19, 0x3F7DB25E4C9E7FD4
  %22 = fmul double %13, %20
  %23 = fmul double %13, %21
  %24 = fadd double %22, 0x3FAC2661E760FEEA
  %25 = fadd double %23, 0x3FD12C697DF74133
  %26 = fmul double %13, %24
  br label %27

27:                                               ; preds = %6, %5
  %28 = phi double [ %1, %5 ], [ %1, %6 ]
  %29 = phi double [ %3, %5 ], [ %3, %6 ]
  %30 = phi double [ 0x3DFAC4B4389CCCBF, %5 ], [ 0x3DFAC4B4389CCCBF, %6 ]
  %31 = phi double [ 0x3EA390F0E916846C, %5 ], [ 0x3EA390F0E916846C, %6 ]
  %32 = phi double [ 0x3E3DBF605CEF30C0, %5 ], [ 0x3E3DBF605CEF30C0, %6 ]
  %33 = phi double [ 0x3EF49382D31EBA5E, %5 ], [ 0x3EF49382D31EBA5E, %6 ]
  %34 = phi double [ 0x3F391B9374A4479C, %5 ], [ 0x3F391B9374A4479C, %6 ]
  %35 = phi double [ 0x3F756FF813B95713, %5 ], [ 0x3F756FF813B95713, %6 ]
  %36 = phi double [ 0x3FA7D057D85283A0, %5 ], [ 0x3FA7D057D85283A0, %6 ]
  %37 = phi double [ 0x3FD02ACAC9630F2A, %5 ], [ 0x3FD02ACAC9630F2A, %6 ]
  %38 = phi double [ 0x3FE4BE220CFACC02, %5 ], [ 0x3FE4BE220CFACC02, %6 ]
  %39 = phi double [ 0x3E04EA9B9D5ED2D3, %5 ], [ 0x3E04EA9B9D5ED2D3, %6 ]
  %40 = phi double [ 0x3EAF46C18AB8D809, %5 ], [ 0x3EAF46C18AB8D809, %6 ]
  %41 = phi double [ 0x3E46A463B527030B, %5 ], [ 0x3E46A463B527030B, %6 ]
  %42 = phi double [ 0x3EFFDAE904854CF0, %5 ], [ 0x3EFFDAE904854CF0, %6 ]
  %43 = phi double [ 0x3F43F5B84727219B, %5 ], [ 0x3F43F5B84727219B, %6 ]
  %44 = phi double [ 0x3F80B3A886D078D5, %5 ], [ 0x3F80B3A886D078D5, %6 ]
  %45 = phi double [ 0x3FB2BDAF5E161D54, %5 ], [ 0x3FB2BDAF5E161D54, %6 ]
  %46 = phi double [ 0x3FD98FFFB01689E6, %5 ], [ 0x3FD98FFFB01689E6, %6 ]
  %47 = phi double [ undef, %5 ], [ %26, %6 ]
  %48 = phi double [ 0x3FE45F306F7BD51E, %5 ], [ 0x3FE45F306F7BD51E, %6 ]
  %49 = phi double [ undef, %5 ], [ %12, %6 ]
  %50 = phi double [ undef, %5 ], [ %25, %6 ]
  %51 = phi double [ undef, %5 ], [ %13, %6 ]
  %52 = phi double [ 0x3E41C5A32EBEB036, %5 ], [ 0x3E41C5A32EBEB036, %6 ]
  %53 = phi double [ 0x3ED2C03A84AD3954, %5 ], [ 0x3ED2C03A84AD3954, %6 ]
  %54 = phi double [ 0x3E842875EC14B32B, %5 ], [ 0x3E842875EC14B32B, %6 ]
  %55 = phi double [ 0x3F1404C590EDED62, %5 ], [ 0x3F1404C590EDED62, %6 ]
  %56 = phi double [ 0x3F51B33174D75BD6, %5 ], [ 0x3F51B33174D75BD6, %6 ]
  %57 = phi double [ 0x3F8752E2DAA7BC3C, %5 ], [ 0x3F8752E2DAA7BC3C, %6 ]
  %58 = phi double [ 0x3FB61BE1285F7AC2, %5 ], [ 0x3FB61BE1285F7AC2, %6 ]
  %59 = phi double [ 0x3FDAF9DE32D5716C, %5 ], [ 0x3FDAF9DE32D5716C, %6 ]
  %60 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 0
  store double %28, double* %60, align 8
  %61 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 1
  store double %29, double* %61, align 8
  %62 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 2
  store double %30, double* %62, align 8
  %63 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 3
  store double %31, double* %63, align 8
  %64 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 4
  store double %32, double* %64, align 8
  %65 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 5
  store double %33, double* %65, align 8
  %66 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 6
  store double %34, double* %66, align 8
  %67 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 7
  store double %35, double* %67, align 8
  %68 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 8
  store double %36, double* %68, align 8
  %69 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 9
  store double %37, double* %69, align 8
  %70 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 10
  store double %38, double* %70, align 8
  %71 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 11
  store double %39, double* %71, align 8
  %72 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 12
  store double %40, double* %72, align 8
  %73 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 13
  store double %41, double* %73, align 8
  %74 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 14
  store double %42, double* %74, align 8
  %75 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 15
  store double %43, double* %75, align 8
  %76 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 16
  store double %44, double* %76, align 8
  %77 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 17
  store double %45, double* %77, align 8
  %78 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 18
  store double %46, double* %78, align 8
  %79 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 19
  store double %47, double* %79, align 8
  %80 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 20
  store double %48, double* %80, align 8
  %81 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 21
  store double %49, double* %81, align 8
  %82 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 22
  store double %50, double* %82, align 8
  %83 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 23
  store double %51, double* %83, align 8
  %84 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 24
  store double %52, double* %84, align 8
  %85 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 25
  store double %53, double* %85, align 8
  %86 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 26
  store double %54, double* %86, align 8
  %87 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 27
  store double %55, double* %87, align 8
  %88 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 28
  store double %56, double* %88, align 8
  %89 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 29
  store double %57, double* %89, align 8
  %90 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 30
  store double %58, double* %90, align 8
  %91 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 31
  store double %59, double* %91, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
