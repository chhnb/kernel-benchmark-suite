; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: inlinehint nounwind
define i32 @region(i1 %0, float %1, float %2, float %3, float %4, float %5, float %6, float %7, float %8, float %9, float %10, float %11, float %12, float %13, float %14, float %15, float %16, float %17, float* %18, float* %19, float* %20) #0 {
  br i1 %0, label %67, label %22

22:                                               ; preds = %21
  %23 = fdiv float 1.000000e+00, %1
  %24 = fmul float %2, %3
  %25 = fmul float %4, %5
  %26 = fmul float %6, %7
  %27 = fsub float %25, %26
  %28 = fmul float %8, %27
  %29 = fsub float %24, %28
  %30 = fmul float %4, %9
  %31 = fmul float %10, %7
  %32 = fsub float %30, %31
  %33 = fmul float %11, %32
  %34 = fadd float %33, %29
  %35 = fneg float %34
  %36 = fmul float %23, %35
  %37 = fmul float %12, %27
  %38 = fmul float %2, %13
  %39 = fsub float %37, %38
  %40 = fmul float %14, %7
  %41 = fmul float %4, %15
  %42 = fsub float %40, %41
  %43 = fmul float %11, %42
  %44 = fadd float %43, %39
  %45 = fneg float %44
  %46 = fmul float %23, %45
  %47 = fsub float %31, %30
  %48 = fmul float %12, %47
  %49 = fmul float %8, %42
  %50 = fsub float %48, %49
  %51 = fmul float %2, %16
  %52 = fadd float %51, %50
  %53 = fneg float %52
  %54 = fmul float %23, %53
  %55 = fadd float %17, %36
  store float %55, float* %18, align 4, !tbaa !0
  %56 = load float, float* %19, align 4, !tbaa !0
  %57 = fadd float %46, %56
  store float %57, float* %19, align 4, !tbaa !0
  %58 = load float, float* %20, align 4, !tbaa !0
  %59 = fadd float %54, %58
  store float %59, float* %20, align 4, !tbaa !0
  %60 = tail call float @llvm.fabs.f32(float %36) #2
  %61 = tail call float @llvm.fabs.f32(float %46) #2
  %62 = fadd float %60, %61
  %63 = tail call float @llvm.fabs.f32(float %54) #2
  %64 = fadd float %63, %62
  %65 = fcmp olt float %64, 0x3EB0C6F7A0000000
  %66 = select i1 %65, i32 2, i32 0
  br label %67

67:                                               ; preds = %22, %21
  %68 = phi i32 [ 1, %21 ], [ %66, %22 ]
  ret i32 %68
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare float @llvm.fabs.f32(float) #1

attributes #0 = { inlinehint nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { nounwind }

!0 = !{!1, !1, i64 0}
!1 = !{!"float", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
