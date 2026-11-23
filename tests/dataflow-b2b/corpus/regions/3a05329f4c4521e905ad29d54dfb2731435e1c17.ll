; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, [8 x double]* %5) #0 {
  br i1 %0, label %7, label %11

7:                                                ; preds = %6
  %8 = fmul double %1, %2
  %9 = fmul double %3, 0x4071AEC837B9190D
  %10 = fsub double 0x406A5A0FD2D4B901, %9
  br label %21

11:                                               ; preds = %6
  %12 = fmul double %3, %2
  %13 = fadd double %12, 0x3FDED118296B2018
  %14 = fmul double %1, %4
  %15 = fmul double %3, 0x3FF51F0306685285
  %16 = fsub double 0xBFEEB82FAA589934, %15
  %17 = fmul double %3, 0x3FEFDC5AEE1525E4
  %18 = fsub double 0x4043A793DEC20DEB, %17
  %19 = fmul double %3, %18
  %20 = fadd double %19, 0xC04B158FF790C730
  br label %21

21:                                               ; preds = %11, %7
  %22 = phi double [ %10, %7 ], [ %20, %11 ]
  %23 = phi double [ 0x407BA4300BFE5087, %7 ], [ 0xC02E8C55CA7195EF, %11 ]
  %24 = phi double [ 0x4063AA2F5D62DCD3, %7 ], [ 0x403058D46A8EC004, %11 ]
  %25 = phi double [ 0x40354F2A1256B431, %7 ], [ 0x4020675EC4F85A38, %11 ]
  %26 = phi double [ 0xC083E59B9D34A0F1, %7 ], [ 0x401A11C0BB0DC22E, %11 ]
  %27 = phi double [ 0x406113A5A6902AC1, %7 ], [ %16, %11 ]
  %28 = phi double [ %4, %7 ], [ %14, %11 ]
  %29 = phi double [ %8, %7 ], [ %13, %11 ]
  %30 = getelementptr inbounds [8 x double], [8 x double]* %5, i32 0, i32 0
  store double %22, double* %30, align 8
  %31 = getelementptr inbounds [8 x double], [8 x double]* %5, i32 0, i32 1
  store double %23, double* %31, align 8
  %32 = getelementptr inbounds [8 x double], [8 x double]* %5, i32 0, i32 2
  store double %24, double* %32, align 8
  %33 = getelementptr inbounds [8 x double], [8 x double]* %5, i32 0, i32 3
  store double %25, double* %33, align 8
  %34 = getelementptr inbounds [8 x double], [8 x double]* %5, i32 0, i32 4
  store double %26, double* %34, align 8
  %35 = getelementptr inbounds [8 x double], [8 x double]* %5, i32 0, i32 5
  store double %27, double* %35, align 8
  %36 = getelementptr inbounds [8 x double], [8 x double]* %5, i32 0, i32 6
  store double %28, double* %36, align 8
  %37 = getelementptr inbounds [8 x double], [8 x double]* %5, i32 0, i32 7
  store double %29, double* %37, align 8
  ret void
}

attributes #0 = { nofree norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
