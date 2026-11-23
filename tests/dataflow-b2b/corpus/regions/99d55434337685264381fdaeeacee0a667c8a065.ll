; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-G1-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree norecurse nounwind
define void @region(i1 %0, i32 %1, double addrspace(1)* %2, double %3, i64 %4, i64 %5, double addrspace(1)* %6, i64 %7, i32 %8, i32 %9, double %10, [2 x double]* %11) #0 {
  br i1 %0, label %52, label %13

13:                                               ; preds = %12
  %14 = add nsw i32 %1, -1
  %15 = sext i32 %14 to i64
  %16 = getelementptr inbounds double, double addrspace(1)* %2, i64 %15
  %17 = load double, double addrspace(1)* %16, align 8, !tbaa !0
  %18 = fadd double %3, %17
  %19 = fmul double %18, 5.000000e-01
  %20 = getelementptr inbounds double, double addrspace(1)* %2, i64 %4
  %21 = load double, double addrspace(1)* %20, align 8, !tbaa !0
  %22 = getelementptr inbounds double, double addrspace(1)* %2, i64 %5
  %23 = load double, double addrspace(1)* %22, align 8, !tbaa !0
  %24 = fadd double %21, %23
  %25 = fmul double %24, 5.000000e-01
  %26 = getelementptr inbounds double, double addrspace(1)* %6, i64 %7
  %27 = load double, double addrspace(1)* %26, align 8, !tbaa !0
  %28 = getelementptr inbounds double, double addrspace(1)* %6, i64 %4
  %29 = load double, double addrspace(1)* %28, align 8, !tbaa !0
  %30 = fadd double %27, %29
  %31 = fmul double %19, %30
  %32 = fmul double %31, 5.000000e-01
  %33 = tail call double @llvm.fabs.f64(double %19) #2
  %34 = fsub double %29, %27
  %35 = fmul double %33, %34
  %36 = fmul double %35, 5.000000e-01
  %37 = fadd double %32, %36
  %38 = sub nsw i32 %8, %9
  %39 = sext i32 %38 to i64
  %40 = getelementptr inbounds double, double addrspace(1)* %6, i64 %39
  %41 = load double, double addrspace(1)* %40, align 8, !tbaa !0
  %42 = fadd double %29, %41
  %43 = fmul double %25, %42
  %44 = fmul double %43, 5.000000e-01
  %45 = tail call double @llvm.fabs.f64(double %25) #2
  %46 = fsub double %41, %29
  %47 = fmul double %45, %46
  %48 = fmul double %47, 5.000000e-01
  %49 = fadd double %44, %48
  %50 = fsub double %37, %49
  %51 = fmul double %10, %50
  br label %52

52:                                               ; preds = %13, %12
  %53 = phi double [ %3, %12 ], [ %29, %13 ]
  %54 = phi double [ 0.000000e+00, %12 ], [ %51, %13 ]
  %55 = getelementptr inbounds [2 x double], [2 x double]* %11, i32 0, i32 0
  store double %53, double* %55, align 8
  %56 = getelementptr inbounds [2 x double], [2 x double]* %11, i32 0, i32 1
  store double %54, double* %56, align 8
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
