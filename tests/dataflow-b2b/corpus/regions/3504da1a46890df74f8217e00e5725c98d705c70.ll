; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: nofree norecurse nounwind willreturn
define void @region(i1 %0, double %1, double %2, [13 x double] addrspace(4)* %3, double %4, [15 x double] addrspace(4)* %5, [7 x double] addrspace(4)* %6, double %7, double %8, [7 x double] addrspace(4)* %9, { double*, double*, double*, double*, double*, double*, double, double, double, double* }* %10) #0 {
  %12 = addrspacecast [13 x double] addrspace(4)* %3 to [13 x double]*
  %13 = getelementptr [13 x double], [13 x double]* %12, i64 0, i64 6
  %14 = getelementptr [13 x double], [13 x double]* %12, i64 0, i64 5
  %15 = getelementptr [13 x double], [13 x double]* %12, i64 0, i64 4
  %16 = getelementptr [13 x double], [13 x double]* %12, i64 0, i64 3
  %17 = getelementptr [13 x double], [13 x double]* %12, i64 0, i64 2
  %18 = getelementptr [13 x double], [13 x double]* %12, i64 0, i64 1
  %19 = addrspacecast [15 x double] addrspace(4)* %5 to [15 x double]*
  %20 = getelementptr [15 x double], [15 x double]* %19, i64 0, i64 9
  %21 = addrspacecast [7 x double] addrspace(4)* %6 to [7 x double]*
  %22 = getelementptr [7 x double], [7 x double]* %21, i64 0, i64 1
  %23 = getelementptr [15 x double], [15 x double]* %19, i64 0, i64 10
  %24 = getelementptr [7 x double], [7 x double]* %21, i64 0, i64 2
  %25 = getelementptr [15 x double], [15 x double]* %19, i64 0, i64 11
  %26 = getelementptr [7 x double], [7 x double]* %21, i64 0, i64 3
  %27 = getelementptr [15 x double], [15 x double]* %19, i64 0, i64 13
  %28 = getelementptr [7 x double], [7 x double]* %21, i64 0, i64 5
  %29 = getelementptr [15 x double], [15 x double]* %19, i64 0, i64 12
  %30 = getelementptr [7 x double], [7 x double]* %21, i64 0, i64 4
  %31 = getelementptr [15 x double], [15 x double]* %19, i64 0, i64 14
  %32 = getelementptr [7 x double], [7 x double]* %21, i64 0, i64 6
  %33 = getelementptr [13 x double], [13 x double]* %12, i64 0, i64 0
  %34 = addrspacecast [7 x double] addrspace(4)* %9 to [7 x double]*
  %35 = getelementptr [7 x double], [7 x double]* %34, i64 0, i64 0
  br i1 %0, label %36, label %55

36:                                               ; preds = %11
  %37 = fmul double %1, %2
  %38 = load double, double* %13, align 8, !tbaa !0
  %39 = fadd double %4, %38
  %40 = load double, double* %14, align 8, !tbaa !0
  %41 = fadd double %37, %40
  %42 = fmul double %1, %39
  %43 = fmul double %1, %41
  %44 = load double, double* %15, align 8, !tbaa !0
  %45 = fadd double %42, %44
  %46 = load double, double* %16, align 8, !tbaa !0
  %47 = fadd double %43, %46
  %48 = fmul double %1, %45
  %49 = fmul double %1, %47
  %50 = load double, double* %17, align 8, !tbaa !0
  %51 = fadd double %48, %50
  %52 = load double, double* %18, align 8, !tbaa !0
  %53 = fadd double %49, %52
  %54 = fmul double %1, %51
  br label %55

55:                                               ; preds = %36, %11
  %56 = phi double* [ %20, %36 ], [ %22, %11 ]
  %57 = phi double* [ %23, %36 ], [ %24, %11 ]
  %58 = phi double* [ %25, %36 ], [ %26, %11 ]
  %59 = phi double* [ %27, %36 ], [ %28, %11 ]
  %60 = phi double* [ %29, %36 ], [ %30, %11 ]
  %61 = phi double* [ %31, %36 ], [ %32, %11 ]
  %62 = phi double [ %53, %36 ], [ %2, %11 ]
  %63 = phi double [ %7, %36 ], [ %8, %11 ]
  %64 = phi double [ %54, %36 ], [ %4, %11 ]
  %65 = phi double* [ %33, %36 ], [ %35, %11 ]
  %66 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double, double, double, double* }, { double*, double*, double*, double*, double*, double*, double, double, double, double* }* %10, i32 0, i32 0
  store double* %56, double** %66, align 8
  %67 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double, double, double, double* }, { double*, double*, double*, double*, double*, double*, double, double, double, double* }* %10, i32 0, i32 1
  store double* %57, double** %67, align 8
  %68 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double, double, double, double* }, { double*, double*, double*, double*, double*, double*, double, double, double, double* }* %10, i32 0, i32 2
  store double* %58, double** %68, align 8
  %69 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double, double, double, double* }, { double*, double*, double*, double*, double*, double*, double, double, double, double* }* %10, i32 0, i32 3
  store double* %59, double** %69, align 8
  %70 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double, double, double, double* }, { double*, double*, double*, double*, double*, double*, double, double, double, double* }* %10, i32 0, i32 4
  store double* %60, double** %70, align 8
  %71 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double, double, double, double* }, { double*, double*, double*, double*, double*, double*, double, double, double, double* }* %10, i32 0, i32 5
  store double* %61, double** %71, align 8
  %72 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double, double, double, double* }, { double*, double*, double*, double*, double*, double*, double, double, double, double* }* %10, i32 0, i32 6
  store double %62, double* %72, align 8
  %73 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double, double, double, double* }, { double*, double*, double*, double*, double*, double*, double, double, double, double* }* %10, i32 0, i32 7
  store double %63, double* %73, align 8
  %74 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double, double, double, double* }, { double*, double*, double*, double*, double*, double*, double, double, double, double* }* %10, i32 0, i32 8
  store double %64, double* %74, align 8
  %75 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double, double, double, double* }, { double*, double*, double*, double*, double*, double*, double, double, double, double* }* %10, i32 0, i32 9
  store double* %65, double** %75, align 8
  ret void
}

attributes #0 = { nofree norecurse nounwind willreturn "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
