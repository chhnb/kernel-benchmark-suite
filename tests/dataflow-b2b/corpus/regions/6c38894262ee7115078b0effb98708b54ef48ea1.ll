; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, [6 x double]* %5) #0 {
  br i1 %0, label %7, label %15

7:                                                ; preds = %6
  %8 = fadd double %1, 0x3FFB3E8B8B7EC8F9
  %9 = fmul double %2, %3
  %10 = fadd double %9, %8
  %11 = fmul double %4, 0x406113A5A6902AC1
  %12 = fadd double %11, 0xC083E59B9D34A0F1
  %13 = fmul double %4, 0x4071AEC837B9190D
  %14 = fsub double 0x406A5A0FD2D4B901, %13
  br label %29

15:                                               ; preds = %6
  %16 = fmul double %4, %3
  %17 = fadd double %1, 0xC005F196AB7EF904
  %18 = fadd double %16, 0x3FDED118296B2018
  %19 = fmul double %2, %17
  %20 = fadd double %18, %19
  %21 = fmul double %4, 0x3FF51F0306685285
  %22 = fsub double 0xBFEEB82FAA589934, %21
  %23 = fmul double %4, 0x3FEFDC5AEE1525E4
  %24 = fsub double 0x4043A793DEC20DEB, %23
  %25 = fmul double %4, %22
  %26 = fmul double %4, %24
  %27 = fadd double %25, 0x401A11C0BB0DC22E
  %28 = fadd double %26, 0xC04B158FF790C730
  br label %29

29:                                               ; preds = %15, %7
  %30 = phi double [ 0x40354F2A1256B431, %7 ], [ 0x4020675EC4F85A38, %15 ]
  %31 = phi double [ 0x4063AA2F5D62DCD3, %7 ], [ 0x403058D46A8EC004, %15 ]
  %32 = phi double [ 0x407BA4300BFE5087, %7 ], [ 0xC02E8C55CA7195EF, %15 ]
  %33 = phi double [ %12, %7 ], [ %27, %15 ]
  %34 = phi double [ %14, %7 ], [ %28, %15 ]
  %35 = phi double [ %10, %7 ], [ %20, %15 ]
  %36 = getelementptr inbounds [6 x double], [6 x double]* %5, i32 0, i32 0
  store double %30, double* %36, align 8
  %37 = getelementptr inbounds [6 x double], [6 x double]* %5, i32 0, i32 1
  store double %31, double* %37, align 8
  %38 = getelementptr inbounds [6 x double], [6 x double]* %5, i32 0, i32 2
  store double %32, double* %38, align 8
  %39 = getelementptr inbounds [6 x double], [6 x double]* %5, i32 0, i32 3
  store double %33, double* %39, align 8
  %40 = getelementptr inbounds [6 x double], [6 x double]* %5, i32 0, i32 4
  store double %34, double* %40, align 8
  %41 = getelementptr inbounds [6 x double], [6 x double]* %5, i32 0, i32 5
  store double %35, double* %41, align 8
  ret void
}

attributes #0 = { nofree norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
