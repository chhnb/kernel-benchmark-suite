; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: nofree norecurse nounwind willreturn
define double @region(i1 %0, double %1, [7 x double] addrspace(4)* %2, [7 x double] addrspace(4)* %3, [5 x double] addrspace(4)* %4, [5 x double] addrspace(4)* %5) #0 {
  %7 = addrspacecast [7 x double] addrspace(4)* %2 to [7 x double]*
  %8 = getelementptr [7 x double], [7 x double]* %7, i64 0, i64 6
  %9 = getelementptr [7 x double], [7 x double]* %7, i64 0, i64 4
  %10 = getelementptr [7 x double], [7 x double]* %7, i64 0, i64 5
  %11 = getelementptr [7 x double], [7 x double]* %7, i64 0, i64 3
  %12 = getelementptr [7 x double], [7 x double]* %7, i64 0, i64 2
  %13 = getelementptr [7 x double], [7 x double]* %7, i64 0, i64 1
  %14 = getelementptr [7 x double], [7 x double]* %7, i64 0, i64 0
  %15 = addrspacecast [7 x double] addrspace(4)* %3 to [7 x double]*
  %16 = getelementptr [7 x double], [7 x double]* %15, i64 0, i64 6
  %17 = getelementptr [7 x double], [7 x double]* %15, i64 0, i64 4
  %18 = getelementptr [7 x double], [7 x double]* %15, i64 0, i64 5
  %19 = getelementptr [7 x double], [7 x double]* %15, i64 0, i64 3
  %20 = getelementptr [7 x double], [7 x double]* %15, i64 0, i64 2
  %21 = getelementptr [7 x double], [7 x double]* %15, i64 0, i64 1
  %22 = getelementptr [7 x double], [7 x double]* %15, i64 0, i64 0
  %23 = addrspacecast [5 x double] addrspace(4)* %4 to [5 x double]*
  %24 = getelementptr [5 x double], [5 x double]* %23, i64 0, i64 4
  %25 = getelementptr [5 x double], [5 x double]* %23, i64 0, i64 2
  %26 = getelementptr [5 x double], [5 x double]* %23, i64 0, i64 3
  %27 = getelementptr [5 x double], [5 x double]* %23, i64 0, i64 1
  %28 = getelementptr [5 x double], [5 x double]* %23, i64 0, i64 0
  %29 = addrspacecast [5 x double] addrspace(4)* %5 to [5 x double]*
  %30 = getelementptr [5 x double], [5 x double]* %29, i64 0, i64 4
  %31 = getelementptr [5 x double], [5 x double]* %29, i64 0, i64 2
  %32 = getelementptr [5 x double], [5 x double]* %29, i64 0, i64 3
  %33 = getelementptr [5 x double], [5 x double]* %29, i64 0, i64 1
  %34 = getelementptr [5 x double], [5 x double]* %29, i64 0, i64 0
  br i1 %0, label %35, label %77

35:                                               ; preds = %6
  %36 = fadd double %1, -3.200000e+01
  %37 = fmul double %36, %36
  %38 = load double, double* %8, align 8, !tbaa !0
  %39 = fmul double %37, %38
  %40 = load double, double* %9, align 8, !tbaa !0
  %41 = fadd double %39, %40
  %42 = load double, double* %10, align 8, !tbaa !0
  %43 = fmul double %37, %42
  %44 = load double, double* %11, align 8, !tbaa !0
  %45 = fadd double %43, %44
  %46 = fmul double %37, %41
  %47 = fmul double %37, %45
  %48 = load double, double* %12, align 8, !tbaa !0
  %49 = fadd double %46, %48
  %50 = load double, double* %13, align 8, !tbaa !0
  %51 = fadd double %47, %50
  %52 = fmul double %37, %49
  %53 = load double, double* %14, align 8, !tbaa !0
  %54 = fadd double %52, %53
  %55 = fmul double %36, %51
  %56 = fadd double %54, %55
  %57 = load double, double* %16, align 8, !tbaa !0
  %58 = fmul double %37, %57
  %59 = load double, double* %17, align 8, !tbaa !0
  %60 = fadd double %58, %59
  %61 = load double, double* %18, align 8, !tbaa !0
  %62 = fmul double %37, %61
  %63 = load double, double* %19, align 8, !tbaa !0
  %64 = fadd double %62, %63
  %65 = fmul double %37, %60
  %66 = fmul double %37, %64
  %67 = load double, double* %20, align 8, !tbaa !0
  %68 = fadd double %65, %67
  %69 = load double, double* %21, align 8, !tbaa !0
  %70 = fadd double %66, %69
  %71 = fmul double %37, %68
  %72 = load double, double* %22, align 8, !tbaa !0
  %73 = fadd double %71, %72
  %74 = fmul double %36, %70
  %75 = fadd double %73, %74
  %76 = fdiv double %56, %75
  br label %110

77:                                               ; preds = %6
  %78 = tail call double @llvm.sqrt.f64(double %1) #2
  %79 = fdiv double 1.000000e+00, %78
  %80 = fmul double %79, %79
  %81 = load double, double* %24, align 8, !tbaa !0
  %82 = fmul double %80, %81
  %83 = load double, double* %25, align 8, !tbaa !0
  %84 = fadd double %82, %83
  %85 = load double, double* %26, align 8, !tbaa !0
  %86 = fmul double %80, %85
  %87 = load double, double* %27, align 8, !tbaa !0
  %88 = fadd double %86, %87
  %89 = fmul double %80, %84
  %90 = load double, double* %28, align 8, !tbaa !0
  %91 = fadd double %89, %90
  %92 = fmul double %79, %88
  %93 = fadd double %91, %92
  %94 = load double, double* %30, align 8, !tbaa !0
  %95 = fmul double %80, %94
  %96 = load double, double* %31, align 8, !tbaa !0
  %97 = fadd double %95, %96
  %98 = load double, double* %32, align 8, !tbaa !0
  %99 = fmul double %80, %98
  %100 = load double, double* %33, align 8, !tbaa !0
  %101 = fadd double %99, %100
  %102 = fmul double %80, %97
  %103 = load double, double* %34, align 8, !tbaa !0
  %104 = fadd double %102, %103
  %105 = fmul double %79, %101
  %106 = fadd double %104, %105
  %107 = fdiv double %93, %106
  %108 = fmul double %79, %107
  %109 = fdiv double %108, %1
  br label %110

110:                                              ; preds = %77, %35
  %111 = phi double [ %76, %35 ], [ %109, %77 ]
  ret double %111
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.sqrt.f64(double) #1

attributes #0 = { nofree norecurse nounwind willreturn "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { nounwind }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
