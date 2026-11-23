; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-G1-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree norecurse nounwind
define double @region(i1 %0, double %1, double %2) #0 {
  br i1 %0, label %4, label %30

4:                                                ; preds = %3
  %5 = fmul double %1, -5.440000e-01
  %6 = fmul double %1, %2
  %7 = fcmp olt double %6, 0x1000000000000000
  %8 = select i1 %7, double 0x4FF0000000000000, double 1.000000e+00
  %9 = fmul double %6, %8
  %10 = tail call double @llvm.amdgcn.rsq.f64(double %9) #3
  %11 = fmul double %9, %10
  %12 = fmul double %10, 5.000000e-01
  %13 = fneg double %12
  %14 = tail call double @llvm.fma.f64(double %13, double %11, double 5.000000e-01) #3
  %15 = tail call double @llvm.fma.f64(double %12, double %14, double %12) #3
  %16 = tail call double @llvm.fma.f64(double %11, double %14, double %11) #3
  %17 = fneg double %16
  %18 = tail call double @llvm.fma.f64(double %17, double %16, double %9) #3
  %19 = tail call double @llvm.fma.f64(double %18, double %15, double %16) #3
  %20 = fneg double %19
  %21 = tail call double @llvm.fma.f64(double %20, double %19, double %9) #3
  %22 = tail call double @llvm.fma.f64(double %21, double %15, double %19) #3
  %23 = select i1 %7, double 0x37F0000000000000, double 1.000000e+00
  %24 = fmul double %23, %22
  %25 = fcmp oeq double %9, 0.000000e+00
  %26 = fcmp oeq double %9, 0x7FF0000000000000
  %27 = or i1 %25, %26
  %28 = select i1 %27, double %9, double %24
  %29 = fmul double %5, %28
  br label %30

30:                                               ; preds = %4, %3
  %31 = phi double [ %29, %4 ], [ 0.000000e+00, %3 ]
  ret double %31
}

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.amdgcn.rsq.f64(double) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.fma.f64(double, double, double) #2

attributes #0 = { nofree norecurse nounwind "amdgpu-flat-work-group-size"="1,1024" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #3 = { nounwind }
