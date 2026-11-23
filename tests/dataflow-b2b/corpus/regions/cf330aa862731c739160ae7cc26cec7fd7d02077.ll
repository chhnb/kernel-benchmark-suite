; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, [32 x double]* %4) #0 {
  br i1 %0, label %29, label %6

6:                                                ; preds = %5
  %7 = fcmp oeq double %1, 0x7FF0000000000000
  %8 = select i1 %7, double %2, double %3
  %9 = fcmp olt double %2, 0.000000e+00
  %10 = select i1 %9, double 0x7FF8000000000000, double %8
  %11 = fcmp oeq double %2, 0.000000e+00
  %12 = select i1 %11, double 0xFFF0000000000000, double %10
  %13 = fmul double %12, %12
  %14 = fmul double %13, 0x3C79498433579691
  %15 = fsub double 0x3E495C1E8002A2F3, %14
  %16 = fmul double %13, 0x3DE864F7A333A155
  %17 = fadd double %16, 0x3E9EABE0F5513556
  %18 = fmul double %13, %15
  %19 = fmul double %13, %17
  %20 = fadd double %18, 0x3EE98327A9C0F60B
  %21 = fadd double %19, 0x3F2EDE27BF6E2989
  %22 = fmul double %13, %20
  %23 = fmul double %13, %21
  %24 = fadd double %22, 0x3F6B2BC23526CCD2
  %25 = fadd double %23, 0x3FA0CC4805CE702A
  %26 = fmul double %13, %24
  %27 = fmul double %13, %25
  %28 = fadd double %26, 0x3FCA6EBA13EF1190
  br label %29

29:                                               ; preds = %6, %5
  %30 = phi double [ %1, %5 ], [ %1, %6 ]
  %31 = phi double [ %3, %5 ], [ %3, %6 ]
  %32 = phi double [ 0x3E5572883C081004, %5 ], [ 0x3E5572883C081004, %6 ]
  %33 = phi double [ 0x3EF19780C67DB179, %5 ], [ 0x3EF19780C67DB179, %6 ]
  %34 = phi double [ 0x3EAD6D38A29E7848, %5 ], [ 0x3EAD6D38A29E7848, %6 ]
  %35 = phi double [ 0x3F3931D0B31857FC, %5 ], [ 0x3F3931D0B31857FC, %6 ]
  %36 = phi double [ 0x3F6DC47CA5637DCD, %5 ], [ 0x3F6DC47CA5637DCD, %6 ]
  %37 = phi double [ 0x3F9D4AC2F9914DE6, %5 ], [ 0x3F9D4AC2F9914DE6, %6 ]
  %38 = phi double [ 0x3FC0EDB6A0343FA2, %5 ], [ 0x3FC0EDB6A0343FA2, %6 ]
  %39 = phi double [ 0x3FDB50BA04B5A380, %5 ], [ 0x3FDB50BA04B5A380, %6 ]
  %40 = phi double [ 0x3FE698C26DDFFE1D, %5 ], [ 0x3FE698C26DDFFE1D, %6 ]
  %41 = phi double [ 0x3E5DE5C0706A9406, %5 ], [ 0x3E5DE5C0706A9406, %6 ]
  %42 = phi double [ 0x3F004FBC687921D1, %5 ], [ 0x3F004FBC687921D1, %6 ]
  %43 = phi double [ 0x3EB3C06C21CA66A9, %5 ], [ 0x3EB3C06C21CA66A9, %6 ]
  %44 = phi double [ 0x3F41E908A5D59DEF, %5 ], [ 0x3F41E908A5D59DEF, %6 ]
  %45 = phi double [ 0x3F78B07BF251DF23, %5 ], [ 0x3F78B07BF251DF23, %6 ]
  %46 = phi double [ 0x3FA6C0CF25D026FF, %5 ], [ 0x3FA6C0CF25D026FF, %6 ]
  %47 = phi double [ 0x3FCB01CF712825D2, %5 ], [ 0x3FCB01CF712825D2, %6 ]
  %48 = phi double [ 0x3FE41A23912FC356, %5 ], [ 0x3FE41A23912FC356, %6 ]
  %49 = phi double [ undef, %5 ], [ %27, %6 ]
  %50 = phi double [ 0x3FE460008BE31186, %5 ], [ 0x3FE460008BE31186, %6 ]
  %51 = phi double [ undef, %5 ], [ %12, %6 ]
  %52 = phi double [ undef, %5 ], [ %28, %6 ]
  %53 = phi double [ undef, %5 ], [ %13, %6 ]
  %54 = phi double [ 0x3DF328AAD4028837, %5 ], [ 0x3DF328AAD4028837, %6 ]
  %55 = phi double [ 0x3EA816907A00ED43, %5 ], [ 0x3EA816907A00ED43, %6 ]
  %56 = phi double [ 0x3E53EB10DB8936AA, %5 ], [ 0x3E53EB10DB8936AA, %6 ]
  %57 = phi double [ 0x3EF409E2C6442ECB, %5 ], [ 0x3EF409E2C6442ECB, %6 ]
  %58 = phi double [ 0x3F383DD0A4891FC2, %5 ], [ 0x3F383DD0A4891FC2, %6 ]
  %59 = phi double [ 0x3F75579E42D43198, %5 ], [ 0x3F75579E42D43198, %6 ]
  %60 = phi double [ 0x3FAA6202C31DEDAF, %5 ], [ 0x3FAA6202C31DEDAF, %6 ]
  %61 = phi double [ 0x3FD4C357E0FB8D40, %5 ], [ 0x3FD4C357E0FB8D40, %6 ]
  %62 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 0
  store double %30, double* %62, align 8
  %63 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 1
  store double %31, double* %63, align 8
  %64 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 2
  store double %32, double* %64, align 8
  %65 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 3
  store double %33, double* %65, align 8
  %66 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 4
  store double %34, double* %66, align 8
  %67 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 5
  store double %35, double* %67, align 8
  %68 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 6
  store double %36, double* %68, align 8
  %69 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 7
  store double %37, double* %69, align 8
  %70 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 8
  store double %38, double* %70, align 8
  %71 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 9
  store double %39, double* %71, align 8
  %72 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 10
  store double %40, double* %72, align 8
  %73 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 11
  store double %41, double* %73, align 8
  %74 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 12
  store double %42, double* %74, align 8
  %75 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 13
  store double %43, double* %75, align 8
  %76 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 14
  store double %44, double* %76, align 8
  %77 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 15
  store double %45, double* %77, align 8
  %78 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 16
  store double %46, double* %78, align 8
  %79 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 17
  store double %47, double* %79, align 8
  %80 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 18
  store double %48, double* %80, align 8
  %81 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 19
  store double %49, double* %81, align 8
  %82 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 20
  store double %50, double* %82, align 8
  %83 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 21
  store double %51, double* %83, align 8
  %84 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 22
  store double %52, double* %84, align 8
  %85 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 23
  store double %53, double* %85, align 8
  %86 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 24
  store double %54, double* %86, align 8
  %87 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 25
  store double %55, double* %87, align 8
  %88 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 26
  store double %56, double* %88, align 8
  %89 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 27
  store double %57, double* %89, align 8
  %90 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 28
  store double %58, double* %90, align 8
  %91 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 29
  store double %59, double* %91, align 8
  %92 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 30
  store double %60, double* %92, align 8
  %93 = getelementptr inbounds [32 x double], [32 x double]* %4, i32 0, i32 31
  store double %61, double* %93, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
