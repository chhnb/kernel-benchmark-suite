; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

%struct.SimConfig = type { double, double, double, double, double, double, double, double, double, double, double, i32 }

; Function Attrs: norecurse nounwind
define void @region(i1 %0, double addrspace(1)* %1, i64 %2, double addrspace(1)* %3, double addrspace(1)* %4, double addrspace(1)* %5, i32 %6, i32 %7, %struct.SimConfig addrspace(4)* %8, [4 x double]* %9) #0 {
  %11 = getelementptr inbounds %struct.SimConfig, %struct.SimConfig addrspace(4)* %8, i64 0, i32 0
  br i1 %0, label %12, label %21

12:                                               ; preds = %10
  %13 = getelementptr inbounds double, double addrspace(1)* %1, i64 %2
  %14 = load double, double addrspace(1)* %13, align 8, !tbaa !0
  %15 = getelementptr inbounds double, double addrspace(1)* %3, i64 %2
  %16 = load double, double addrspace(1)* %15, align 8, !tbaa !0
  %17 = getelementptr inbounds double, double addrspace(1)* %4, i64 %2
  %18 = load double, double addrspace(1)* %17, align 8, !tbaa !0
  %19 = getelementptr inbounds double, double addrspace(1)* %5, i64 %2
  %20 = load double, double addrspace(1)* %19, align 8, !tbaa !0
  br label %55

21:                                               ; preds = %10
  %22 = shl nsw i32 %6, 13
  %23 = add nsw i32 %22, %7
  %24 = sext i32 %23 to i64
  %25 = getelementptr inbounds double, double addrspace(1)* %1, i64 %24
  %26 = load double, double addrspace(1)* %25, align 8, !tbaa !0
  %27 = getelementptr inbounds double, double addrspace(1)* %3, i64 %24
  %28 = load double, double addrspace(1)* %27, align 8, !tbaa !0
  %29 = getelementptr inbounds double, double addrspace(1)* %4, i64 %24
  %30 = load double, double addrspace(1)* %29, align 8, !tbaa !0
  %31 = getelementptr inbounds double, double addrspace(1)* %5, i64 %24
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
  %44 = load double, double addrspace(4)* %11, align 8, !tbaa !4
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

55:                                               ; preds = %21, %12
  %56 = phi double [ %14, %12 ], [ %34, %21 ]
  %57 = phi double [ %16, %12 ], [ %51, %21 ]
  %58 = phi double [ %18, %12 ], [ %52, %21 ]
  %59 = phi double [ %20, %12 ], [ %54, %21 ]
  %60 = getelementptr inbounds [4 x double], [4 x double]* %9, i32 0, i32 0
  store double %56, double* %60, align 8
  %61 = getelementptr inbounds [4 x double], [4 x double]* %9, i32 0, i32 1
  store double %57, double* %61, align 8
  %62 = getelementptr inbounds [4 x double], [4 x double]* %9, i32 0, i32 2
  store double %58, double* %62, align 8
  %63 = getelementptr inbounds [4 x double], [4 x double]* %9, i32 0, i32 3
  store double %59, double* %63, align 8
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
