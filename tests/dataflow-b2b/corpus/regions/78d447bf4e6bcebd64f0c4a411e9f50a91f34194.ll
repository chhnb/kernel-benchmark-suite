; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double %1, double %2, [27 x double]* %3) #0 {
  br i1 %0, label %6, label %5

5:                                                ; preds = %4
  br label %6

6:                                                ; preds = %5, %4
  %7 = phi double [ 0x3E5572883C081004, %4 ], [ 0x3DFAC4B4389CCCBF, %5 ]
  %8 = phi double [ 0x3EF19780C67DB179, %4 ], [ 0x3EA390F0E916846C, %5 ]
  %9 = phi double [ 0x3EAD6D38A29E7848, %4 ], [ 0x3E3DBF605CEF30C0, %5 ]
  %10 = phi double [ 0x3F3931D0B31857FC, %4 ], [ 0x3EF49382D31EBA5E, %5 ]
  %11 = phi double [ 0x3F6DC47CA5637DCD, %4 ], [ 0x3F391B9374A4479C, %5 ]
  %12 = phi double [ 0x3F9D4AC2F9914DE6, %4 ], [ 0x3F756FF813B95713, %5 ]
  %13 = phi double [ 0x3FC0EDB6A0343FA2, %4 ], [ 0x3FA7D057D85283A0, %5 ]
  %14 = phi double [ 0x3FDB50BA04B5A380, %4 ], [ 0x3FD02ACAC9630F2A, %5 ]
  %15 = phi double [ 0x3FE698C26DDFFE1D, %4 ], [ 0x3FE4BE220CFACC02, %5 ]
  %16 = phi double [ 0x3E5DE5C0706A9406, %4 ], [ 0x3E04EA9B9D5ED2D3, %5 ]
  %17 = phi double [ 0x3F004FBC687921D1, %4 ], [ 0x3EAF46C18AB8D809, %5 ]
  %18 = phi double [ 0x3EB3C06C21CA66A9, %4 ], [ 0x3E46A463B527030B, %5 ]
  %19 = phi double [ 0x3F41E908A5D59DEF, %4 ], [ 0x3EFFDAE904854CF0, %5 ]
  %20 = phi double [ 0x3F78B07BF251DF23, %4 ], [ 0x3F43F5B84727219B, %5 ]
  %21 = phi double [ 0x3FA6C0CF25D026FF, %4 ], [ 0x3F80B3A886D078D5, %5 ]
  %22 = phi double [ 0x3FCB01CF712825D2, %4 ], [ 0x3FB2BDAF5E161D54, %5 ]
  %23 = phi double [ 0x3FE41A23912FC356, %4 ], [ 0x3FD98FFFB01689E6, %5 ]
  %24 = phi double [ 0x3FE460008BE31186, %4 ], [ 0x3FE45F306F7BD51E, %5 ]
  %25 = phi double [ %1, %4 ], [ %2, %5 ]
  %26 = phi double [ 0x3DF328AAD4028837, %4 ], [ 0x3E41C5A32EBEB036, %5 ]
  %27 = phi double [ 0x3EA816907A00ED43, %4 ], [ 0x3ED2C03A84AD3954, %5 ]
  %28 = phi double [ 0x3E53EB10DB8936AA, %4 ], [ 0x3E842875EC14B32B, %5 ]
  %29 = phi double [ 0x3EF409E2C6442ECB, %4 ], [ 0x3F1404C590EDED62, %5 ]
  %30 = phi double [ 0x3F383DD0A4891FC2, %4 ], [ 0x3F51B33174D75BD6, %5 ]
  %31 = phi double [ 0x3F75579E42D43198, %4 ], [ 0x3F8752E2DAA7BC3C, %5 ]
  %32 = phi double [ 0x3FAA6202C31DEDAF, %4 ], [ 0x3FB61BE1285F7AC2, %5 ]
  %33 = phi double [ 0x3FD4C357E0FB8D40, %4 ], [ 0x3FDAF9DE32D5716C, %5 ]
  %34 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 0
  store double %7, double* %34, align 8
  %35 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 1
  store double %8, double* %35, align 8
  %36 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 2
  store double %9, double* %36, align 8
  %37 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 3
  store double %10, double* %37, align 8
  %38 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 4
  store double %11, double* %38, align 8
  %39 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 5
  store double %12, double* %39, align 8
  %40 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 6
  store double %13, double* %40, align 8
  %41 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 7
  store double %14, double* %41, align 8
  %42 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 8
  store double %15, double* %42, align 8
  %43 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 9
  store double %16, double* %43, align 8
  %44 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 10
  store double %17, double* %44, align 8
  %45 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 11
  store double %18, double* %45, align 8
  %46 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 12
  store double %19, double* %46, align 8
  %47 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 13
  store double %20, double* %47, align 8
  %48 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 14
  store double %21, double* %48, align 8
  %49 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 15
  store double %22, double* %49, align 8
  %50 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 16
  store double %23, double* %50, align 8
  %51 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 17
  store double %24, double* %51, align 8
  %52 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 18
  store double %25, double* %52, align 8
  %53 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 19
  store double %26, double* %53, align 8
  %54 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 20
  store double %27, double* %54, align 8
  %55 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 21
  store double %28, double* %55, align 8
  %56 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 22
  store double %29, double* %56, align 8
  %57 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 23
  store double %30, double* %57, align 8
  %58 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 24
  store double %31, double* %58, align 8
  %59 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 25
  store double %32, double* %59, align 8
  %60 = getelementptr inbounds [27 x double], [27 x double]* %3, i32 0, i32 26
  store double %33, double* %60, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
