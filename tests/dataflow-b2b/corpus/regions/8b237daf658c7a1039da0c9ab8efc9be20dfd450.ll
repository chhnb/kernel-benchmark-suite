; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, i1 %4, [5 x double]* %5) #0 {
  br i1 %0, label %41, label %7

7:                                                ; preds = %6
  %8 = fcmp oeq double %1, 0x7FF0000000000000
  %9 = select i1 %8, double %2, double %3
  %10 = fcmp olt double %2, 0.000000e+00
  %11 = select i1 %10, double 0x7FF8000000000000, double %9
  %12 = fcmp oeq double %2, 0.000000e+00
  %13 = select i1 %12, double 0xFFF0000000000000, double %11
  %14 = fmul double %13, %13
  %15 = select i1 %4, double 0x3C79498433579691, double 0x3E36A0C73E300E6B
  %16 = fmul double %14, %15
  %17 = fsub double 0x3E495C1E8002A2F3, %16
  %18 = fadd double %16, 0x3EC7DFD742A8FC88
  %19 = select i1 %4, double %17, double %18
  %20 = select i1 %4, double 0x3DE864F7A333A155, double 0x3E79AA80A6F64859
  %21 = fmul double %14, %20
  %22 = select i1 %4, double 0x3E9EABE0F5513556, double 0x3F097D0FE1D7D8F2
  %23 = fadd double %21, %22
  %24 = fmul double %14, %19
  %25 = fmul double %14, %23
  %26 = select i1 %4, double 0x3EE98327A9C0F60B, double 0x3F46894B5AD794D5
  %27 = fadd double %24, %26
  %28 = select i1 %4, double 0x3F2EDE27BF6E2989, double 0x3F7DB25E4C9E7FD4
  %29 = fadd double %25, %28
  %30 = fmul double %14, %27
  %31 = fmul double %14, %29
  %32 = select i1 %4, double 0x3F6B2BC23526CCD2, double 0x3FAC2661E760FEEA
  %33 = fadd double %30, %32
  %34 = select i1 %4, double 0x3FA0CC4805CE702A, double 0x3FD12C697DF74133
  %35 = fadd double %31, %34
  %36 = fmul double %14, %33
  %37 = select i1 %4, double %35, double %33
  %38 = fmul double %14, %37
  %39 = fadd double %36, 0x3FCA6EBA13EF1190
  %40 = select i1 %4, double %39, double undef
  br label %41

41:                                               ; preds = %7, %6
  %42 = phi double [ undef, %6 ], [ %14, %7 ]
  %43 = phi double [ undef, %6 ], [ %40, %7 ]
  %44 = phi double [ undef, %6 ], [ %13, %7 ]
  %45 = phi double [ undef, %6 ], [ %38, %7 ]
  %46 = phi double [ undef, %6 ], [ %35, %7 ]
  %47 = getelementptr inbounds [5 x double], [5 x double]* %5, i32 0, i32 0
  store double %42, double* %47, align 8
  %48 = getelementptr inbounds [5 x double], [5 x double]* %5, i32 0, i32 1
  store double %43, double* %48, align 8
  %49 = getelementptr inbounds [5 x double], [5 x double]* %5, i32 0, i32 2
  store double %44, double* %49, align 8
  %50 = getelementptr inbounds [5 x double], [5 x double]* %5, i32 0, i32 3
  store double %45, double* %50, align 8
  %51 = getelementptr inbounds [5 x double], [5 x double]* %5, i32 0, i32 4
  store double %46, double* %51, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
