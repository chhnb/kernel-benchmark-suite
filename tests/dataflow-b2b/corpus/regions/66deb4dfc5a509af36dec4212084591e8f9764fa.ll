; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

%struct.SimConfig.0.10 = type { double, double, double, double, double, double, double, double, double, double, double, i32 }

; Function Attrs: norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, %struct.SimConfig.0.10 addrspace(4)* %5, double %6, double %7, double %8, double %9, [8 x double]* %10) #0 {
  %12 = getelementptr inbounds %struct.SimConfig.0.10, %struct.SimConfig.0.10 addrspace(4)* %5, i64 0, i32 0
  br i1 %0, label %36, label %13

13:                                               ; preds = %11
  %14 = fcmp ogt double %1, 1.000000e-25
  %15 = select i1 %14, double %1, double 1.000000e-25
  %16 = fdiv double 1.000000e+00, %15
  %17 = fmul double %2, %16
  %18 = fmul double %3, %16
  %19 = fmul double %15, 5.000000e-01
  %20 = fmul double %17, %17
  %21 = fmul double %18, %18
  %22 = fadd double %20, %21
  %23 = fmul double %19, %22
  %24 = fsub double %4, %23
  %25 = load double, double addrspace(4)* %12, align 8, !tbaa !0
  %26 = fadd double %25, -1.000000e+00
  %27 = fmul double %26, %24
  %28 = fcmp ogt double %27, 1.000000e-25
  %29 = fneg double %17
  %30 = fneg double %18
  %31 = select i1 %28, double %27, double 1.000000e-25
  %32 = fmul double %15, %29
  %33 = fmul double %15, %30
  %34 = fdiv double %31, %26
  %35 = fadd double %23, %34
  br label %36

36:                                               ; preds = %13, %11
  %37 = phi double [ %4, %11 ], [ %35, %13 ]
  %38 = phi double [ %3, %11 ], [ %33, %13 ]
  %39 = phi double [ %2, %11 ], [ %32, %13 ]
  %40 = phi double [ %1, %11 ], [ %15, %13 ]
  %41 = phi double [ %6, %11 ], [ %6, %13 ]
  %42 = phi double [ %7, %11 ], [ %7, %13 ]
  %43 = phi double [ %8, %11 ], [ %8, %13 ]
  %44 = phi double [ %9, %11 ], [ %9, %13 ]
  %45 = getelementptr inbounds [8 x double], [8 x double]* %10, i32 0, i32 0
  store double %37, double* %45, align 8
  %46 = getelementptr inbounds [8 x double], [8 x double]* %10, i32 0, i32 1
  store double %38, double* %46, align 8
  %47 = getelementptr inbounds [8 x double], [8 x double]* %10, i32 0, i32 2
  store double %39, double* %47, align 8
  %48 = getelementptr inbounds [8 x double], [8 x double]* %10, i32 0, i32 3
  store double %40, double* %48, align 8
  %49 = getelementptr inbounds [8 x double], [8 x double]* %10, i32 0, i32 4
  store double %41, double* %49, align 8
  %50 = getelementptr inbounds [8 x double], [8 x double]* %10, i32 0, i32 5
  store double %42, double* %50, align 8
  %51 = getelementptr inbounds [8 x double], [8 x double]* %10, i32 0, i32 6
  store double %43, double* %51, align 8
  %52 = getelementptr inbounds [8 x double], [8 x double]* %10, i32 0, i32 7
  store double %44, double* %52, align 8
  ret void
}

attributes #0 = { norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !2, i64 0}
!1 = !{!"_ZTS9SimConfig", !2, i64 0, !2, i64 8, !2, i64 16, !2, i64 24, !2, i64 32, !2, i64 40, !2, i64 48, !2, i64 56, !2, i64 64, !2, i64 72, !2, i64 80, !5, i64 88}
!2 = !{!"double", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
!5 = !{!"int", !3, i64 0}
