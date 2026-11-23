; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

%struct.SimConfig.0 = type { double, double, double, double, double, double, double, double, double, double, double, i32 }

; Function Attrs: norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, %struct.SimConfig.0 addrspace(4)* %5, [4 x double]* %6) #0 {
  %8 = getelementptr inbounds %struct.SimConfig.0, %struct.SimConfig.0 addrspace(4)* %5, i64 0, i32 0
  br i1 %0, label %32, label %9

9:                                                ; preds = %7
  %10 = fcmp ogt double %1, 1.000000e-25
  %11 = select i1 %10, double %1, double 1.000000e-25
  %12 = fdiv double 1.000000e+00, %11
  %13 = fmul double %2, %12
  %14 = fmul double %3, %12
  %15 = fmul double %11, 5.000000e-01
  %16 = fmul double %13, %13
  %17 = fmul double %14, %14
  %18 = fadd double %16, %17
  %19 = fmul double %15, %18
  %20 = fsub double %4, %19
  %21 = load double, double addrspace(4)* %8, align 8, !tbaa !0
  %22 = fadd double %21, -1.000000e+00
  %23 = fmul double %22, %20
  %24 = fcmp ogt double %23, 1.000000e-25
  %25 = fneg double %13
  %26 = fneg double %14
  %27 = select i1 %24, double %23, double 1.000000e-25
  %28 = fmul double %11, %25
  %29 = fmul double %11, %26
  %30 = fdiv double %27, %22
  %31 = fadd double %19, %30
  br label %32

32:                                               ; preds = %9, %7
  %33 = phi double [ %1, %7 ], [ %11, %9 ]
  %34 = phi double [ %2, %7 ], [ %28, %9 ]
  %35 = phi double [ %3, %7 ], [ %29, %9 ]
  %36 = phi double [ %4, %7 ], [ %31, %9 ]
  %37 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 0
  store double %33, double* %37, align 8
  %38 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 1
  store double %34, double* %38, align 8
  %39 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 2
  store double %35, double* %39, align 8
  %40 = getelementptr inbounds [4 x double], [4 x double]* %6, i32 0, i32 3
  store double %36, double* %40, align 8
  ret void
}

attributes #0 = { norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !2, i64 0}
!1 = !{!"_ZTS9SimConfig", !2, i64 0, !2, i64 8, !2, i64 16, !2, i64 24, !2, i64 32, !2, i64 40, !2, i64 48, !2, i64 56, !2, i64 64, !2, i64 72, !2, i64 80, !5, i64 88}
!2 = !{!"double", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
!5 = !{!"int", !3, i64 0}
