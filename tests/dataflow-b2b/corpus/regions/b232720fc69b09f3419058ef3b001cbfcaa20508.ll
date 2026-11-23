; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i8* %1, float %2, float %3, float %4, float %5, float %6, float %7, float %8, float %9, float %10, float %11, float %12, float %13, float %14, float %15, float %16, float %17, { float, float, float, float, float, float, i32 }* %18) #0 {
  br i1 %0, label %20, label %21

20:                                               ; preds = %19
  store i8 0, i8* %1, align 1, !tbaa !0
  br label %29

21:                                               ; preds = %19
  %22 = fmul float %2, 2.000000e+00
  %23 = fmul float %3, %22
  %24 = fsub float %4, %23
  %25 = fmul float %5, %22
  %26 = fsub float %6, %25
  %27 = fmul float %7, %22
  %28 = fsub float %8, %27
  br label %29

29:                                               ; preds = %21, %20
  %30 = phi float [ %9, %20 ], [ %28, %21 ]
  %31 = phi float [ %10, %20 ], [ %26, %21 ]
  %32 = phi float [ %11, %20 ], [ %24, %21 ]
  %33 = phi float [ %12, %20 ], [ %13, %21 ]
  %34 = phi float [ %14, %20 ], [ %15, %21 ]
  %35 = phi float [ %16, %20 ], [ %17, %21 ]
  %36 = phi i32 [ 2, %20 ], [ 4, %21 ]
  %37 = getelementptr inbounds { float, float, float, float, float, float, i32 }, { float, float, float, float, float, float, i32 }* %18, i32 0, i32 0
  store float %30, float* %37, align 4
  %38 = getelementptr inbounds { float, float, float, float, float, float, i32 }, { float, float, float, float, float, float, i32 }* %18, i32 0, i32 1
  store float %31, float* %38, align 4
  %39 = getelementptr inbounds { float, float, float, float, float, float, i32 }, { float, float, float, float, float, float, i32 }* %18, i32 0, i32 2
  store float %32, float* %39, align 4
  %40 = getelementptr inbounds { float, float, float, float, float, float, i32 }, { float, float, float, float, float, float, i32 }* %18, i32 0, i32 3
  store float %33, float* %40, align 4
  %41 = getelementptr inbounds { float, float, float, float, float, float, i32 }, { float, float, float, float, float, float, i32 }* %18, i32 0, i32 4
  store float %34, float* %41, align 4
  %42 = getelementptr inbounds { float, float, float, float, float, float, i32 }, { float, float, float, float, float, float, i32 }* %18, i32 0, i32 5
  store float %35, float* %42, align 4
  %43 = getelementptr inbounds { float, float, float, float, float, float, i32 }, { float, float, float, float, float, float, i32 }* %18, i32 0, i32 6
  store i32 %36, i32* %43, align 4
  ret void
}

attributes #0 = { convergent norecurse nounwind "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"omnipotent char", !2, i64 0}
!2 = !{!"Simple C++ TBAA"}
