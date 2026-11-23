; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, float %1, float %2, float %3, float %4, float %5, float %6, float %7, float %8, float %9, float %10, float %11, float* %12, i64 %13, i64 %14, i64 %15, i64 %16) #0 {
  br i1 %0, label %18, label %51

18:                                               ; preds = %17
  %19 = fsub float %1, %2
  %20 = fmul float %3, %19
  %21 = fsub float %4, %5
  %22 = fmul float %3, %21
  %23 = fsub float %6, %7
  %24 = fmul float %3, %23
  %25 = fmul float %1, %1
  %26 = fmul float %4, %4
  %27 = fadd float %25, %26
  %28 = fmul float %6, %6
  %29 = fadd float %28, %27
  %30 = fmul float %2, %2
  %31 = fmul float %5, %5
  %32 = fadd float %31, %30
  %33 = fmul float %7, %7
  %34 = fadd float %33, %32
  %35 = fsub float %29, %34
  %36 = fmul float %8, %35
  %37 = fsub float %9, %10
  %38 = fmul float %11, %37
  %39 = getelementptr inbounds float, float* %12, i64 %13
  %40 = atomicrmw fadd float* %39, float %20 seq_cst
  %41 = add nsw i64 %13, %14
  %42 = getelementptr inbounds float, float* %12, i64 %41
  %43 = atomicrmw fadd float* %42, float %22 seq_cst
  %44 = add nsw i64 %13, %15
  %45 = getelementptr inbounds float, float* %12, i64 %44
  %46 = atomicrmw fadd float* %45, float %24 seq_cst
  %47 = add nsw i64 %13, %16
  %48 = getelementptr inbounds float, float* %12, i64 %47
  %49 = fadd float %36, %38
  %50 = atomicrmw fadd float* %48, float %49 seq_cst
  br label %51

51:                                               ; preds = %18, %17
  ret void
}

attributes #0 = { convergent norecurse nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
