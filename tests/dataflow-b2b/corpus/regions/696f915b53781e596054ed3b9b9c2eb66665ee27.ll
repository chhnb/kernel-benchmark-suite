; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: convergent norecurse nounwind
define float @region(i1 %0, float %1, float %2, float %3, float %4, float %5) #0 {
  br i1 %0, label %93, label %7

7:                                                ; preds = %6
  %8 = call float @llvm.nvvm.sqrt.approx.f(float %1) #3
  %9 = fmul float %8, 0x3FE3333340000000
  %10 = call float asm "rcp.approx.ftz.f32 $0,$1;", "=f,f"(float 0x3FFB851EC0000000) #1, !srcloc !0
  %11 = fmul float %10, 0xBFE1EB8500000000
  %12 = fmul float %11, %11
  %13 = call float @llvm.fma.f32(float %12, float 0x3F631E1FC0000000, float 0x3F8995EC60000000) #3
  %14 = call float @llvm.fma.f32(float %13, float %12, float 0x3FB55557A0000000) #3
  %15 = fmul float %12, %14
  %16 = fmul float %11, %15
  %17 = fneg float %11
  %18 = fsub float 0xBFD1EB8500000000, %11
  %19 = fmul float %18, 2.000000e+00
  %20 = call float @llvm.fma.f32(float %17, float 0xBFD1EB8500000000, float %19) #3
  %21 = fmul float %10, %20
  %22 = fadd float %11, %16
  %23 = fsub float %11, %22
  %24 = fadd float %16, %23
  %25 = fadd float %21, %24
  %26 = fadd float %22, %25
  %27 = fsub float %22, %26
  %28 = fadd float %25, %27
  %29 = fadd float %26, 0.000000e+00
  %30 = fsub float 0.000000e+00, %29
  %31 = fadd float %26, %30
  %32 = fadd float %28, %31
  %33 = fadd float %32, 0.000000e+00
  %34 = fadd float %29, %33
  %35 = fsub float %29, %34
  %36 = fadd float %33, %35
  %37 = fmul float %34, 0x3FD5555560000000
  %38 = fneg float %37
  %39 = call float @llvm.fma.f32(float %34, float 0x3FD5555560000000, float %38) #3
  %40 = call float @llvm.fma.f32(float %36, float 0x3FD5555560000000, float %39) #3
  %41 = call float @llvm.fma.f32(float %34, float 0.000000e+00, float %40) #3
  %42 = fadd float %37, %41
  %43 = fsub float %37, %42
  %44 = fadd float %41, %43
  %45 = bitcast float %42 to i32
  %46 = icmp eq i32 %45, 1118925336
  %47 = fadd float %44, 0x3EE0000000000000
  %48 = select i1 %46, float %47, float %44
  %49 = select i1 %46, float 0x40562E42E0000000, float %42
  %50 = fmul float %49, 0x3FF7154760000000
  %51 = call float @llvm.trunc.f32(float %50) #3
  %52 = call float @llvm.fabs.f32(float %51) #3
  %53 = fcmp ogt float %52, 1.260000e+02
  %54 = bitcast float %51 to i32
  %55 = and i32 %54, -2147483648
  %56 = or i32 %55, 1123811328
  %57 = bitcast i32 %56 to float
  %58 = select i1 %53, float %57, float %51
  %59 = call float @llvm.fma.f32(float %58, float 0xBFE62E4300000000, float %49) #3
  %60 = call float @llvm.fma.f32(float %58, float 0x3E205C6100000000, float %59) #3
  %61 = fmul float %60, 0x3FF7154760000000
  %62 = fadd float %58, 0x4168000FE0000000
  %63 = bitcast float %62 to i32
  %64 = shl i32 %63, 23
  %65 = bitcast i32 %64 to float
  %66 = call float @llvm.nvvm.ex2.approx.ftz.f(float %61) #3
  %67 = fmul float %66, %65
  %68 = fcmp une float %67, 0x7FF0000000000000
  %69 = call float @llvm.fma.f32(float %67, float %48, float %67) #3
  %70 = select i1 %68, float %69, float %67
  %71 = fmul float %9, %70
  %72 = fadd float %71, 2.000000e+00
  %73 = fmul float %2, 1.500000e+00
  %74 = fmul float %73, 0x3FE70A3D80000000
  %75 = fdiv float 2.000000e+00, %72
  %76 = fmul float %74, %75
  %77 = fsub float %3, %4
  %78 = fdiv float %5, %76
  %79 = call float @llvm.fma.f32(float %78, float 0x3F777313A0000000, float 5.000000e-01) #3
  %80 = call float @llvm.nvvm.saturate.f(float %79) #3
  %81 = call float @llvm.nvvm.fma.rm.f(float %80, float 2.520000e+02, float 0x4168000020000000) #3
  %82 = fadd float %81, 0xC168000FE0000000
  %83 = fneg float %82
  %84 = call float @llvm.fma.f32(float %78, float 0x3FF7154760000000, float %83) #3
  %85 = call float @llvm.fma.f32(float %78, float 0x3E54AE0C00000000, float %84) #3
  %86 = bitcast float %81 to i32
  %87 = shl i32 %86, 23
  %88 = bitcast i32 %87 to float
  %89 = call float @llvm.nvvm.ex2.approx.ftz.f(float %85) #3
  %90 = fmul float %89, %88
  %91 = fmul float %77, %90
  %92 = fsub float %3, %91
  br label %93

93:                                               ; preds = %7, %6
  %94 = phi float [ %4, %6 ], [ %92, %7 ]
  ret float %94
}

; Function Attrs: nounwind readnone
declare float @llvm.nvvm.sqrt.approx.f(float) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare float @llvm.fma.f32(float, float, float) #2

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare float @llvm.trunc.f32(float) #2

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare float @llvm.fabs.f32(float) #2

; Function Attrs: nounwind readnone
declare float @llvm.nvvm.ex2.approx.ftz.f(float) #1

; Function Attrs: nounwind readnone
declare float @llvm.nvvm.saturate.f(float) #1

; Function Attrs: nounwind readnone
declare float @llvm.nvvm.fma.rm.f(float, float, float) #1

attributes #0 = { convergent norecurse nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #3 = { nounwind }

!0 = !{i32 20968}
