; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, double %5, double %6, double %7, double %8, double %9, double %10, double %11, double %12, double %13, double %14, double %15, double %16, double %17, [4 x double]* %18) #0 {
  br i1 %0, label %20, label %29

20:                                               ; preds = %19
  %21 = fadd double %1, %2
  %22 = fadd double %3, %4
  %23 = fadd double %5, %6
  %24 = fadd double %7, %8
  %25 = fmul double %21, 5.000000e-01
  %26 = fmul double %22, 5.000000e-01
  %27 = fmul double %23, 5.000000e-01
  %28 = fmul double %24, 5.000000e-01
  br label %60

29:                                               ; preds = %19
  %30 = fmul double %2, %9
  %31 = fmul double %4, %9
  %32 = fmul double %6, %9
  %33 = fmul double %8, %9
  %34 = fmul double %10, %9
  %35 = fsub double %11, %12
  %36 = fsub double %1, %2
  %37 = fsub double %13, %14
  %38 = fsub double %15, %16
  %39 = fmul double %35, %34
  %40 = fmul double %36, %34
  %41 = fmul double %37, %34
  %42 = fmul double %38, %34
  %43 = fdiv double 1.000000e+00, %17
  %44 = fmul double %1, %10
  %45 = fsub double %30, %44
  %46 = fmul double %3, %10
  %47 = fsub double %31, %46
  %48 = fmul double %5, %10
  %49 = fsub double %32, %48
  %50 = fmul double %7, %10
  %51 = fsub double %33, %50
  %52 = fadd double %45, %39
  %53 = fadd double %47, %40
  %54 = fadd double %49, %41
  %55 = fadd double %51, %42
  %56 = fmul double %43, %52
  %57 = fmul double %43, %53
  %58 = fmul double %43, %54
  %59 = fmul double %43, %55
  br label %60

60:                                               ; preds = %29, %20
  %61 = phi double [ %25, %20 ], [ %56, %29 ]
  %62 = phi double [ %26, %20 ], [ %57, %29 ]
  %63 = phi double [ %27, %20 ], [ %58, %29 ]
  %64 = phi double [ %28, %20 ], [ %59, %29 ]
  %65 = getelementptr inbounds [4 x double], [4 x double]* %18, i32 0, i32 0
  store double %61, double* %65, align 8
  %66 = getelementptr inbounds [4 x double], [4 x double]* %18, i32 0, i32 1
  store double %62, double* %66, align 8
  %67 = getelementptr inbounds [4 x double], [4 x double]* %18, i32 0, i32 2
  store double %63, double* %67, align 8
  %68 = getelementptr inbounds [4 x double], [4 x double]* %18, i32 0, i32 3
  store double %64, double* %68, align 8
  ret void
}

attributes #0 = { norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
