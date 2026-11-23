; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, double %5, [8 x double]* %6) #0 {
  br i1 %0, label %15, label %8

8:                                                ; preds = %7
  %9 = fmul double %1, %2
  %10 = fadd double %9, 0x3FDED118296B2018
  %11 = fmul double %1, 0x3FEFDC5AEE1525E4
  %12 = fsub double 0x4043A793DEC20DEB, %11
  %13 = fmul double %1, %12
  %14 = fadd double %13, 0xC04B158FF790C730
  br label %15

15:                                               ; preds = %8, %7
  %16 = phi double [ %3, %7 ], [ %14, %8 ]
  %17 = phi double [ 0x407BA4300BFE5087, %7 ], [ 0xC02E8C55CA7195EF, %8 ]
  %18 = phi double [ 0x4063AA2F5D62DCD3, %7 ], [ 0x403058D46A8EC004, %8 ]
  %19 = phi double [ 0x40354F2A1256B431, %7 ], [ 0x4020675EC4F85A38, %8 ]
  %20 = phi double [ 0xC083E59B9D34A0F1, %7 ], [ 0x401A11C0BB0DC22E, %8 ]
  %21 = phi double [ 0x406113A5A6902AC1, %7 ], [ %3, %8 ]
  %22 = phi double [ %4, %7 ], [ %5, %8 ]
  %23 = phi double [ %5, %7 ], [ %10, %8 ]
  %24 = getelementptr inbounds [8 x double], [8 x double]* %6, i32 0, i32 0
  store double %16, double* %24, align 8
  %25 = getelementptr inbounds [8 x double], [8 x double]* %6, i32 0, i32 1
  store double %17, double* %25, align 8
  %26 = getelementptr inbounds [8 x double], [8 x double]* %6, i32 0, i32 2
  store double %18, double* %26, align 8
  %27 = getelementptr inbounds [8 x double], [8 x double]* %6, i32 0, i32 3
  store double %19, double* %27, align 8
  %28 = getelementptr inbounds [8 x double], [8 x double]* %6, i32 0, i32 4
  store double %20, double* %28, align 8
  %29 = getelementptr inbounds [8 x double], [8 x double]* %6, i32 0, i32 5
  store double %21, double* %29, align 8
  %30 = getelementptr inbounds [8 x double], [8 x double]* %6, i32 0, i32 6
  store double %22, double* %30, align 8
  %31 = getelementptr inbounds [8 x double], [8 x double]* %6, i32 0, i32 7
  store double %23, double* %31, align 8
  ret void
}

attributes #0 = { nofree norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
