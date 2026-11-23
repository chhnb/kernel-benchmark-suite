; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: nofree norecurse nounwind willreturn
define void @region(i1 %0, double %1, double %2, [15 x double] addrspace(4)* %3, double %4, [7 x double] addrspace(4)* %5, { double, double, double* }* %6) #0 {
  %8 = addrspacecast [15 x double] addrspace(4)* %3 to [15 x double]*
  %9 = getelementptr [15 x double], [15 x double]* %8, i64 0, i64 8
  %10 = getelementptr [15 x double], [15 x double]* %8, i64 0, i64 7
  %11 = getelementptr [15 x double], [15 x double]* %8, i64 0, i64 6
  %12 = getelementptr [15 x double], [15 x double]* %8, i64 0, i64 5
  %13 = getelementptr [15 x double], [15 x double]* %8, i64 0, i64 4
  %14 = getelementptr [15 x double], [15 x double]* %8, i64 0, i64 3
  %15 = getelementptr [15 x double], [15 x double]* %8, i64 0, i64 2
  %16 = getelementptr [15 x double], [15 x double]* %8, i64 0, i64 1
  %17 = getelementptr [15 x double], [15 x double]* %8, i64 0, i64 0
  %18 = addrspacecast [7 x double] addrspace(4)* %5 to [7 x double]*
  %19 = getelementptr [7 x double], [7 x double]* %18, i64 0, i64 0
  br i1 %0, label %20, label %45

20:                                               ; preds = %7
  %21 = fmul double %1, %2
  %22 = load double, double* %9, align 8, !tbaa !0
  %23 = fadd double %4, %22
  %24 = load double, double* %10, align 8, !tbaa !0
  %25 = fadd double %21, %24
  %26 = fmul double %1, %23
  %27 = fmul double %1, %25
  %28 = load double, double* %11, align 8, !tbaa !0
  %29 = fadd double %26, %28
  %30 = load double, double* %12, align 8, !tbaa !0
  %31 = fadd double %27, %30
  %32 = fmul double %1, %29
  %33 = fmul double %1, %31
  %34 = load double, double* %13, align 8, !tbaa !0
  %35 = fadd double %32, %34
  %36 = load double, double* %14, align 8, !tbaa !0
  %37 = fadd double %33, %36
  %38 = fmul double %1, %35
  %39 = fmul double %1, %37
  %40 = load double, double* %15, align 8, !tbaa !0
  %41 = fadd double %38, %40
  %42 = load double, double* %16, align 8, !tbaa !0
  %43 = fadd double %39, %42
  %44 = fmul double %1, %41
  br label %45

45:                                               ; preds = %20, %7
  %46 = phi double [ %43, %20 ], [ %2, %7 ]
  %47 = phi double [ %44, %20 ], [ %4, %7 ]
  %48 = phi double* [ %17, %20 ], [ %19, %7 ]
  %49 = getelementptr inbounds { double, double, double* }, { double, double, double* }* %6, i32 0, i32 0
  store double %46, double* %49, align 8
  %50 = getelementptr inbounds { double, double, double* }, { double, double, double* }* %6, i32 0, i32 1
  store double %47, double* %50, align 8
  %51 = getelementptr inbounds { double, double, double* }, { double, double, double* }* %6, i32 0, i32 2
  store double* %48, double** %51, align 8
  ret void
}

attributes #0 = { nofree norecurse nounwind willreturn "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
