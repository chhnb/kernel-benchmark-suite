; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i1 %1, double %2, double %3, double %4, double %5, double %6, double %7, double %8, double %9, double %10, double %11, double %12, double %13, double %14, double %15, double %16, double %17, double %18, double %19, double %20, double %21, double %22, double %23, double %24, double %25, double %26, double %27, double %28, double %29, double %30, double %31, double %32, double %33, double %34, double %35, double %36, double %37, double %38, double %39, double %40, double %41, double %42, double %43, [14 x double]* %44) #0 {
  br i1 %0, label %46, label %61

46:                                               ; preds = %45
  %47 = select i1 %1, double %2, double %3
  %48 = select i1 %1, double %4, double %5
  %49 = select i1 %1, double %6, double %7
  %50 = select i1 %1, double %8, double %9
  %51 = select i1 %1, double %10, double %11
  %52 = select i1 %1, double %12, double %13
  %53 = select i1 %1, double %14, double %15
  %54 = select i1 %1, double %16, double %17
  %55 = select i1 %1, double %18, double %19
  %56 = select i1 %1, double %20, double %21
  %57 = select i1 %1, double %22, double %23
  %58 = select i1 %1, double %24, double %25
  %59 = select i1 %1, double %26, double %27
  %60 = select i1 %1, double %28, double %29
  br label %61

61:                                               ; preds = %46, %45
  %62 = phi double [ %60, %46 ], [ %30, %45 ]
  %63 = phi double [ %59, %46 ], [ %31, %45 ]
  %64 = phi double [ %58, %46 ], [ %32, %45 ]
  %65 = phi double [ %57, %46 ], [ %33, %45 ]
  %66 = phi double [ %56, %46 ], [ %34, %45 ]
  %67 = phi double [ %55, %46 ], [ %35, %45 ]
  %68 = phi double [ %54, %46 ], [ %36, %45 ]
  %69 = phi double [ %53, %46 ], [ %37, %45 ]
  %70 = phi double [ %52, %46 ], [ %38, %45 ]
  %71 = phi double [ %51, %46 ], [ %39, %45 ]
  %72 = phi double [ %50, %46 ], [ %40, %45 ]
  %73 = phi double [ %49, %46 ], [ %41, %45 ]
  %74 = phi double [ %48, %46 ], [ %42, %45 ]
  %75 = phi double [ %47, %46 ], [ %43, %45 ]
  %76 = getelementptr inbounds [14 x double], [14 x double]* %44, i32 0, i32 0
  store double %62, double* %76, align 8
  %77 = getelementptr inbounds [14 x double], [14 x double]* %44, i32 0, i32 1
  store double %63, double* %77, align 8
  %78 = getelementptr inbounds [14 x double], [14 x double]* %44, i32 0, i32 2
  store double %64, double* %78, align 8
  %79 = getelementptr inbounds [14 x double], [14 x double]* %44, i32 0, i32 3
  store double %65, double* %79, align 8
  %80 = getelementptr inbounds [14 x double], [14 x double]* %44, i32 0, i32 4
  store double %66, double* %80, align 8
  %81 = getelementptr inbounds [14 x double], [14 x double]* %44, i32 0, i32 5
  store double %67, double* %81, align 8
  %82 = getelementptr inbounds [14 x double], [14 x double]* %44, i32 0, i32 6
  store double %68, double* %82, align 8
  %83 = getelementptr inbounds [14 x double], [14 x double]* %44, i32 0, i32 7
  store double %69, double* %83, align 8
  %84 = getelementptr inbounds [14 x double], [14 x double]* %44, i32 0, i32 8
  store double %70, double* %84, align 8
  %85 = getelementptr inbounds [14 x double], [14 x double]* %44, i32 0, i32 9
  store double %71, double* %85, align 8
  %86 = getelementptr inbounds [14 x double], [14 x double]* %44, i32 0, i32 10
  store double %72, double* %86, align 8
  %87 = getelementptr inbounds [14 x double], [14 x double]* %44, i32 0, i32 11
  store double %73, double* %87, align 8
  %88 = getelementptr inbounds [14 x double], [14 x double]* %44, i32 0, i32 12
  store double %74, double* %88, align 8
  %89 = getelementptr inbounds [14 x double], [14 x double]* %44, i32 0, i32 13
  store double %75, double* %89, align 8
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
