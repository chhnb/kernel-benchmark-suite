; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-G1-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree norecurse nounwind
define double @region(i1 %0, i32 %1, double addrspace(1)* %2, i32 %3, i64 %4, i64 %5, double addrspace(1)* %6, double %7, double %8) #0 {
  br i1 %0, label %51, label %10

10:                                               ; preds = %9
  %11 = add nsw i32 %1, 1
  %12 = sext i32 %11 to i64
  %13 = getelementptr inbounds double, double addrspace(1)* %2, i64 %12
  %14 = load double, double addrspace(1)* %13, align 8, !tbaa !0
  %15 = add nsw i32 %3, 1
  %16 = sext i32 %15 to i64
  %17 = getelementptr inbounds double, double addrspace(1)* %2, i64 %16
  %18 = load double, double addrspace(1)* %17, align 8, !tbaa !0
  %19 = fadd double %14, %18
  %20 = fmul double %19, 5.000000e-01
  %21 = getelementptr inbounds double, double addrspace(1)* %2, i64 %4
  %22 = load double, double addrspace(1)* %21, align 8, !tbaa !0
  %23 = getelementptr inbounds double, double addrspace(1)* %2, i64 %5
  %24 = load double, double addrspace(1)* %23, align 8, !tbaa !0
  %25 = fadd double %22, %24
  %26 = fmul double %25, 5.000000e-01
  %27 = getelementptr inbounds double, double addrspace(1)* %6, i64 %12
  %28 = load double, double addrspace(1)* %27, align 8, !tbaa !0
  %29 = fadd double %7, %28
  %30 = fmul double %20, %29
  %31 = fmul double %30, 5.000000e-01
  %32 = tail call double @llvm.fabs.f64(double %20) #2
  %33 = fsub double %7, %28
  %34 = fmul double %32, %33
  %35 = fmul double %34, 5.000000e-01
  %36 = fadd double %31, %35
  %37 = add nsw i32 %1, -1
  %38 = sext i32 %37 to i64
  %39 = getelementptr inbounds double, double addrspace(1)* %6, i64 %38
  %40 = load double, double addrspace(1)* %39, align 8, !tbaa !0
  %41 = fadd double %7, %40
  %42 = fmul double %26, %41
  %43 = fmul double %42, 5.000000e-01
  %44 = tail call double @llvm.fabs.f64(double %26) #2
  %45 = fsub double %40, %7
  %46 = fmul double %44, %45
  %47 = fmul double %46, 5.000000e-01
  %48 = fadd double %43, %47
  %49 = fsub double %36, %48
  %50 = fmul double %8, %49
  br label %51

51:                                               ; preds = %10, %9
  %52 = phi double [ 0.000000e+00, %9 ], [ %50, %10 ]
  ret double %52
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
