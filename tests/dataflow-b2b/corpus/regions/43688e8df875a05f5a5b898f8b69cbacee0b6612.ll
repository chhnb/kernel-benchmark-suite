; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-G1-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree norecurse nounwind
define void @region(i1 %0, double addrspace(1)* %1, i64 %2, i32 %3, i32 %4, double addrspace(1)* %5, i64 %6, double %7, [2 x double]* %8) #0 {
  br i1 %0, label %10, label %13

10:                                               ; preds = %9
  %11 = getelementptr inbounds double, double addrspace(1)* %1, i64 %2
  %12 = load double, double addrspace(1)* %11, align 8, !tbaa !0
  br label %56

13:                                               ; preds = %9
  %14 = add nsw i32 %3, %4
  %15 = sext i32 %14 to i64
  %16 = getelementptr inbounds double, double addrspace(1)* %5, i64 %15
  %17 = load double, double addrspace(1)* %16, align 8, !tbaa !0
  %18 = add nsw i32 %14, -1
  %19 = sext i32 %18 to i64
  %20 = getelementptr inbounds double, double addrspace(1)* %5, i64 %19
  %21 = load double, double addrspace(1)* %20, align 8, !tbaa !0
  %22 = fadd double %17, %21
  %23 = fmul double %22, 5.000000e-01
  %24 = getelementptr inbounds double, double addrspace(1)* %5, i64 %2
  %25 = load double, double addrspace(1)* %24, align 8, !tbaa !0
  %26 = getelementptr inbounds double, double addrspace(1)* %5, i64 %6
  %27 = load double, double addrspace(1)* %26, align 8, !tbaa !0
  %28 = fadd double %25, %27
  %29 = fmul double %28, 5.000000e-01
  %30 = getelementptr inbounds double, double addrspace(1)* %1, i64 %15
  %31 = load double, double addrspace(1)* %30, align 8, !tbaa !0
  %32 = getelementptr inbounds double, double addrspace(1)* %1, i64 %2
  %33 = load double, double addrspace(1)* %32, align 8, !tbaa !0
  %34 = fadd double %31, %33
  %35 = fmul double %23, %34
  %36 = fmul double %35, 5.000000e-01
  %37 = tail call double @llvm.fabs.f64(double %23) #2
  %38 = fsub double %33, %31
  %39 = fmul double %37, %38
  %40 = fmul double %39, 5.000000e-01
  %41 = fadd double %36, %40
  %42 = sub nsw i32 %3, %4
  %43 = sext i32 %42 to i64
  %44 = getelementptr inbounds double, double addrspace(1)* %1, i64 %43
  %45 = load double, double addrspace(1)* %44, align 8, !tbaa !0
  %46 = fadd double %33, %45
  %47 = fmul double %29, %46
  %48 = fmul double %47, 5.000000e-01
  %49 = tail call double @llvm.fabs.f64(double %29) #2
  %50 = fsub double %45, %33
  %51 = fmul double %49, %50
  %52 = fmul double %51, 5.000000e-01
  %53 = fadd double %48, %52
  %54 = fsub double %41, %53
  %55 = fmul double %7, %54
  br label %56

56:                                               ; preds = %13, %10
  %57 = phi double [ %12, %10 ], [ %33, %13 ]
  %58 = phi double [ 0.000000e+00, %10 ], [ %55, %13 ]
  %59 = getelementptr inbounds [2 x double], [2 x double]* %8, i32 0, i32 0
  store double %57, double* %59, align 8
  %60 = getelementptr inbounds [2 x double], [2 x double]* %8, i32 0, i32 1
  store double %58, double* %60, align 8
  ret void
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.fabs.f64(double) #1

attributes #0 = { nofree norecurse nounwind "amdgpu-flat-work-group-size"="1,1024" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { nounwind }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
