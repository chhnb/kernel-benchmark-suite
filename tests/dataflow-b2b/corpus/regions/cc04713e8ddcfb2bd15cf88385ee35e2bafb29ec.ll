; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, double %5, double %6, double %7, double %8, double %9, double %10, double %11, double %12, double %13, double %14, double %15, double %16, double %17, double %18, double %19, double %20, double %21, double %22, double %23, double %24, double %25, double %26, double %27, double %28, double %29, double %30, double %31, double %32, double %33, [12 x double]* %34) #0 {
  br i1 %0, label %36, label %59

36:                                               ; preds = %35
  %37 = fcmp oeq double %1, 0x7FF0000000000000
  %38 = select i1 %37, double %2, double %3
  %39 = fcmp olt double %2, 0.000000e+00
  %40 = select i1 %39, double 0x7FF8000000000000, double %38
  %41 = fcmp oeq double %2, 0.000000e+00
  %42 = select i1 %41, double 0xFFF0000000000000, double %40
  %43 = fmul double %42, %42
  %44 = fmul double %43, %4
  %45 = fsub double %5, %44
  %46 = fmul double %43, %6
  %47 = fadd double %46, %7
  %48 = fmul double %43, %45
  %49 = fmul double %43, %47
  %50 = fadd double %48, %8
  %51 = fadd double %49, %9
  %52 = fmul double %43, %50
  %53 = fmul double %43, %51
  %54 = fadd double %52, %10
  %55 = fadd double %53, %11
  %56 = fmul double %43, %54
  %57 = fmul double %43, %12
  %58 = fsub double %13, %57
  br label %62

59:                                               ; preds = %35
  %60 = fmul double %14, %15
  %61 = fadd double %60, %16
  br label %62

62:                                               ; preds = %59, %36
  %63 = phi double [ %17, %36 ], [ %18, %59 ]
  %64 = phi double [ %19, %36 ], [ %20, %59 ]
  %65 = phi double [ %21, %36 ], [ %22, %59 ]
  %66 = phi double [ %23, %36 ], [ %24, %59 ]
  %67 = phi double [ %58, %36 ], [ %61, %59 ]
  %68 = phi double [ %25, %36 ], [ %26, %59 ]
  %69 = phi double [ %27, %36 ], [ %28, %59 ]
  %70 = phi double [ %43, %36 ], [ %14, %59 ]
  %71 = phi double [ %55, %36 ], [ %29, %59 ]
  %72 = phi double [ %42, %36 ], [ %30, %59 ]
  %73 = phi double [ %31, %36 ], [ %32, %59 ]
  %74 = phi double [ %56, %36 ], [ %33, %59 ]
  %75 = getelementptr inbounds [12 x double], [12 x double]* %34, i32 0, i32 0
  store double %63, double* %75, align 8
  %76 = getelementptr inbounds [12 x double], [12 x double]* %34, i32 0, i32 1
  store double %64, double* %76, align 8
  %77 = getelementptr inbounds [12 x double], [12 x double]* %34, i32 0, i32 2
  store double %65, double* %77, align 8
  %78 = getelementptr inbounds [12 x double], [12 x double]* %34, i32 0, i32 3
  store double %66, double* %78, align 8
  %79 = getelementptr inbounds [12 x double], [12 x double]* %34, i32 0, i32 4
  store double %67, double* %79, align 8
  %80 = getelementptr inbounds [12 x double], [12 x double]* %34, i32 0, i32 5
  store double %68, double* %80, align 8
  %81 = getelementptr inbounds [12 x double], [12 x double]* %34, i32 0, i32 6
  store double %69, double* %81, align 8
  %82 = getelementptr inbounds [12 x double], [12 x double]* %34, i32 0, i32 7
  store double %70, double* %82, align 8
  %83 = getelementptr inbounds [12 x double], [12 x double]* %34, i32 0, i32 8
  store double %71, double* %83, align 8
  %84 = getelementptr inbounds [12 x double], [12 x double]* %34, i32 0, i32 9
  store double %72, double* %84, align 8
  %85 = getelementptr inbounds [12 x double], [12 x double]* %34, i32 0, i32 10
  store double %73, double* %85, align 8
  %86 = getelementptr inbounds [12 x double], [12 x double]* %34, i32 0, i32 11
  store double %74, double* %86, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
