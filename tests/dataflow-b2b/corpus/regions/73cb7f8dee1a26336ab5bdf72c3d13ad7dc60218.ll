; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

%struct.SimConfig = type { double, double, double, double, double, double, double, double, double, double, double, i32 }

; Function Attrs: norecurse nounwind
define void @region(i1 %0, double addrspace(1)* %1, i64 %2, double addrspace(1)* %3, double addrspace(1)* %4, double addrspace(1)* %5, i64 %6, %struct.SimConfig addrspace(4)* %7, double %8, double %9, double %10, double %11, [8 x double]* %12) #0 {
  %14 = getelementptr inbounds %struct.SimConfig, %struct.SimConfig addrspace(4)* %7, i64 0, i32 0
  br i1 %0, label %15, label %24

15:                                               ; preds = %13
  %16 = getelementptr inbounds double, double addrspace(1)* %1, i64 %2
  %17 = load double, double addrspace(1)* %16, align 8, !tbaa !0
  %18 = getelementptr inbounds double, double addrspace(1)* %3, i64 %2
  %19 = load double, double addrspace(1)* %18, align 8, !tbaa !0
  %20 = getelementptr inbounds double, double addrspace(1)* %4, i64 %2
  %21 = load double, double addrspace(1)* %20, align 8, !tbaa !0
  %22 = getelementptr inbounds double, double addrspace(1)* %5, i64 %2
  %23 = load double, double addrspace(1)* %22, align 8, !tbaa !0
  br label %55

24:                                               ; preds = %13
  %25 = getelementptr inbounds double, double addrspace(1)* %1, i64 %6
  %26 = load double, double addrspace(1)* %25, align 8, !tbaa !0
  %27 = getelementptr inbounds double, double addrspace(1)* %3, i64 %6
  %28 = load double, double addrspace(1)* %27, align 8, !tbaa !0
  %29 = getelementptr inbounds double, double addrspace(1)* %4, i64 %6
  %30 = load double, double addrspace(1)* %29, align 8, !tbaa !0
  %31 = getelementptr inbounds double, double addrspace(1)* %5, i64 %6
  %32 = load double, double addrspace(1)* %31, align 8, !tbaa !0
  %33 = fcmp ogt double %26, 1.000000e-25
  %34 = select i1 %33, double %26, double 1.000000e-25
  %35 = fdiv double 1.000000e+00, %34
  %36 = fmul double %28, %35
  %37 = fmul double %30, %35
  %38 = fmul double %34, 5.000000e-01
  %39 = fmul double %36, %36
  %40 = fmul double %37, %37
  %41 = fadd double %39, %40
  %42 = fmul double %38, %41
  %43 = fsub double %32, %42
  %44 = load double, double addrspace(4)* %14, align 8, !tbaa !4
  %45 = fadd double %44, -1.000000e+00
  %46 = fmul double %45, %43
  %47 = fcmp ogt double %46, 1.000000e-25
  %48 = fneg double %36
  %49 = fneg double %37
  %50 = select i1 %47, double %46, double 1.000000e-25
  %51 = fmul double %34, %48
  %52 = fmul double %34, %49
  %53 = fdiv double %50, %45
  %54 = fadd double %42, %53
  br label %55

55:                                               ; preds = %24, %15
  %56 = phi double [ %23, %15 ], [ %54, %24 ]
  %57 = phi double [ %21, %15 ], [ %52, %24 ]
  %58 = phi double [ %19, %15 ], [ %51, %24 ]
  %59 = phi double [ %17, %15 ], [ %34, %24 ]
  %60 = phi double [ %8, %15 ], [ %8, %24 ]
  %61 = phi double [ %9, %15 ], [ %9, %24 ]
  %62 = phi double [ %10, %15 ], [ %10, %24 ]
  %63 = phi double [ %11, %15 ], [ %11, %24 ]
  %64 = getelementptr inbounds [8 x double], [8 x double]* %12, i32 0, i32 0
  store double %56, double* %64, align 8
  %65 = getelementptr inbounds [8 x double], [8 x double]* %12, i32 0, i32 1
  store double %57, double* %65, align 8
  %66 = getelementptr inbounds [8 x double], [8 x double]* %12, i32 0, i32 2
  store double %58, double* %66, align 8
  %67 = getelementptr inbounds [8 x double], [8 x double]* %12, i32 0, i32 3
  store double %59, double* %67, align 8
  %68 = getelementptr inbounds [8 x double], [8 x double]* %12, i32 0, i32 4
  store double %60, double* %68, align 8
  %69 = getelementptr inbounds [8 x double], [8 x double]* %12, i32 0, i32 5
  store double %61, double* %69, align 8
  %70 = getelementptr inbounds [8 x double], [8 x double]* %12, i32 0, i32 6
  store double %62, double* %70, align 8
  %71 = getelementptr inbounds [8 x double], [8 x double]* %12, i32 0, i32 7
  store double %63, double* %71, align 8
  ret void
}

attributes #0 = { norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
!4 = !{!5, !1, i64 0}
!5 = !{!"_ZTS9SimConfig", !1, i64 0, !1, i64 8, !1, i64 16, !1, i64 24, !1, i64 32, !1, i64 40, !1, i64 48, !1, i64 56, !1, i64 64, !1, i64 72, !1, i64 80, !6, i64 88}
!6 = !{!"int", !2, i64 0}
