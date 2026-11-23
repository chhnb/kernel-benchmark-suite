; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-G1-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree norecurse nounwind
define double @region(i1 %0, double %1, double %2, double %3, double %4, double %5, double %6, double %7) #0 {
  br i1 %0, label %9, label %43

9:                                                ; preds = %8
  %10 = fsub double %1, %2
  %11 = tail call double @llvm.fabs.f64(double %10) #3
  %12 = tail call double @llvm.maxnum.f64(double %3, double %4) #3
  %13 = tail call double @llvm.maxnum.f64(double %5, double %6) #3
  %14 = fsub double %12, %13
  %15 = fneg double %10
  %16 = fdiv double %15, %11
  %17 = fmul double %16, 3.500000e-01
  %18 = fmul double %17, %14
  %19 = fmul double %7, %14
  %20 = fcmp olt double %19, 0x1000000000000000
  %21 = select i1 %20, double 0x4FF0000000000000, double 1.000000e+00
  %22 = fmul double %19, %21
  %23 = tail call double @llvm.amdgcn.rsq.f64(double %22) #3
  %24 = fmul double %22, %23
  %25 = fmul double %23, 5.000000e-01
  %26 = fneg double %25
  %27 = tail call double @llvm.fma.f64(double %26, double %24, double 5.000000e-01) #3
  %28 = tail call double @llvm.fma.f64(double %25, double %27, double %25) #3
  %29 = tail call double @llvm.fma.f64(double %24, double %27, double %24) #3
  %30 = fneg double %29
  %31 = tail call double @llvm.fma.f64(double %30, double %29, double %22) #3
  %32 = tail call double @llvm.fma.f64(double %31, double %28, double %29) #3
  %33 = fneg double %32
  %34 = tail call double @llvm.fma.f64(double %33, double %32, double %22) #3
  %35 = tail call double @llvm.fma.f64(double %34, double %28, double %32) #3
  %36 = select i1 %20, double 0x37F0000000000000, double 1.000000e+00
  %37 = fmul double %36, %35
  %38 = fcmp oeq double %22, 0.000000e+00
  %39 = fcmp oeq double %22, 0x7FF0000000000000
  %40 = or i1 %38, %39
  %41 = select i1 %40, double %22, double %37
  %42 = fmul double %18, %41
  br label %43

43:                                               ; preds = %9, %8
  %44 = phi double [ %42, %9 ], [ 0.000000e+00, %8 ]
  ret double %44
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.fabs.f64(double) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.maxnum.f64(double, double) #1

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.amdgcn.rsq.f64(double) #2

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.fma.f64(double, double, double) #1

attributes #0 = { nofree norecurse nounwind "amdgpu-flat-work-group-size"="1,1024" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { nounwind readnone speculatable willreturn }
attributes #3 = { nounwind }
