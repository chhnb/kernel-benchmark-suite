; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, double %5, double %6, double %7, double %8, double %9, double %10, double %11, double %12, double %13, double %14, double %15, double %16, double %17, double %18, double %19, double %20, double %21, double %22, double %23, double %24, [4 x double]* %25) #0 {
  br i1 %0, label %27, label %40

27:                                               ; preds = %26
  %28 = fsub double %1, %2
  %29 = fmul double %3, %28
  %30 = fadd double %4, %29
  %31 = fsub double %5, %4
  %32 = fmul double %3, %31
  %33 = fadd double %6, %32
  %34 = fsub double %7, %8
  %35 = fmul double %3, %34
  %36 = fadd double %9, %35
  %37 = fsub double %10, %11
  %38 = fmul double %3, %37
  %39 = fadd double %12, %38
  br label %53

40:                                               ; preds = %26
  %41 = fsub double %13, %14
  %42 = fmul double %15, %41
  %43 = fadd double %16, %42
  %44 = fsub double %17, %16
  %45 = fmul double %15, %44
  %46 = fadd double %18, %45
  %47 = fsub double %19, %20
  %48 = fmul double %15, %47
  %49 = fadd double %21, %48
  %50 = fsub double %22, %23
  %51 = fmul double %15, %50
  %52 = fadd double %24, %51
  br label %53

53:                                               ; preds = %40, %27
  %54 = phi double [ %30, %27 ], [ %43, %40 ]
  %55 = phi double [ %33, %27 ], [ %46, %40 ]
  %56 = phi double [ %36, %27 ], [ %49, %40 ]
  %57 = phi double [ %39, %27 ], [ %52, %40 ]
  %58 = getelementptr inbounds [4 x double], [4 x double]* %25, i32 0, i32 0
  store double %54, double* %58, align 8
  %59 = getelementptr inbounds [4 x double], [4 x double]* %25, i32 0, i32 1
  store double %55, double* %59, align 8
  %60 = getelementptr inbounds [4 x double], [4 x double]* %25, i32 0, i32 2
  store double %56, double* %60, align 8
  %61 = getelementptr inbounds [4 x double], [4 x double]* %25, i32 0, i32 3
  store double %57, double* %61, align 8
  ret void
}

attributes #0 = { norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
