; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree norecurse nounwind willreturn
define void @region(i1 %0, double %1, double %2, double %3, double %4, double %5, double %6, double %7, double %8, double %9, double %10, double %11, double %12, [5 x double]* %13) #0 {
  br i1 %0, label %32, label %15

15:                                               ; preds = %14
  %16 = fsub double %1, %2
  %17 = fmul double %3, %16
  %18 = fdiv double %17, %4
  %19 = fmul double %5, %18
  %20 = fsub double %6, %19
  %21 = fmul double %7, %18
  %22 = fsub double %8, %21
  %23 = fmul double %9, %9
  %24 = fmul double %10, %23
  %25 = fsub double %24, %11
  %26 = fdiv double %25, %4
  %27 = fmul double %5, %26
  %28 = fmul double %7, %26
  %29 = fmul double %20, %27
  %30 = fmul double %22, %28
  %31 = fadd double %29, %30
  br label %32

32:                                               ; preds = %15, %14
  %33 = phi double [ %12, %14 ], [ %31, %15 ]
  %34 = phi double [ %6, %14 ], [ %20, %15 ]
  %35 = phi double [ %8, %14 ], [ %22, %15 ]
  %36 = phi double [ %5, %14 ], [ %27, %15 ]
  %37 = phi double [ %7, %14 ], [ %28, %15 ]
  %38 = getelementptr inbounds [5 x double], [5 x double]* %13, i32 0, i32 0
  store double %33, double* %38, align 8
  %39 = getelementptr inbounds [5 x double], [5 x double]* %13, i32 0, i32 1
  store double %34, double* %39, align 8
  %40 = getelementptr inbounds [5 x double], [5 x double]* %13, i32 0, i32 2
  store double %35, double* %40, align 8
  %41 = getelementptr inbounds [5 x double], [5 x double]* %13, i32 0, i32 3
  store double %36, double* %41, align 8
  %42 = getelementptr inbounds [5 x double], [5 x double]* %13, i32 0, i32 4
  store double %37, double* %42, align 8
  ret void
}

attributes #0 = { nofree norecurse nounwind willreturn "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
