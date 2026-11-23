; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: nofree norecurse nounwind willreturn
define void @region(i1 %0, double %1, [7 x double] addrspace(4)* %2, [7 x double] addrspace(4)* %3, [7 x double] addrspace(4)* %4, [7 x double] addrspace(4)* %5, [7 x double] addrspace(4)* %6, [7 x double] addrspace(4)* %7, { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }* %8) #0 {
  %10 = addrspacecast [7 x double] addrspace(4)* %2 to [7 x double]*
  %11 = getelementptr [7 x double], [7 x double]* %10, i64 0, i64 6
  %12 = addrspacecast [7 x double] addrspace(4)* %3 to [7 x double]*
  %13 = getelementptr [7 x double], [7 x double]* %12, i64 0, i64 6
  %14 = getelementptr [7 x double], [7 x double]* %10, i64 0, i64 4
  %15 = getelementptr [7 x double], [7 x double]* %12, i64 0, i64 4
  %16 = getelementptr [7 x double], [7 x double]* %10, i64 0, i64 5
  %17 = getelementptr [7 x double], [7 x double]* %12, i64 0, i64 5
  %18 = getelementptr [7 x double], [7 x double]* %10, i64 0, i64 3
  %19 = getelementptr [7 x double], [7 x double]* %12, i64 0, i64 3
  %20 = getelementptr [7 x double], [7 x double]* %10, i64 0, i64 2
  %21 = getelementptr [7 x double], [7 x double]* %12, i64 0, i64 2
  %22 = getelementptr [7 x double], [7 x double]* %10, i64 0, i64 1
  %23 = getelementptr [7 x double], [7 x double]* %12, i64 0, i64 1
  %24 = getelementptr [7 x double], [7 x double]* %10, i64 0, i64 0
  %25 = getelementptr [7 x double], [7 x double]* %12, i64 0, i64 0
  %26 = addrspacecast [7 x double] addrspace(4)* %4 to [7 x double]*
  %27 = getelementptr [7 x double], [7 x double]* %26, i64 0, i64 6
  %28 = addrspacecast [7 x double] addrspace(4)* %5 to [7 x double]*
  %29 = getelementptr [7 x double], [7 x double]* %28, i64 0, i64 6
  %30 = getelementptr [7 x double], [7 x double]* %26, i64 0, i64 4
  %31 = getelementptr [7 x double], [7 x double]* %28, i64 0, i64 4
  %32 = getelementptr [7 x double], [7 x double]* %26, i64 0, i64 5
  %33 = getelementptr [7 x double], [7 x double]* %28, i64 0, i64 5
  %34 = getelementptr [7 x double], [7 x double]* %26, i64 0, i64 3
  %35 = getelementptr [7 x double], [7 x double]* %28, i64 0, i64 3
  %36 = getelementptr [7 x double], [7 x double]* %26, i64 0, i64 2
  %37 = getelementptr [7 x double], [7 x double]* %28, i64 0, i64 2
  %38 = getelementptr [7 x double], [7 x double]* %26, i64 0, i64 1
  %39 = getelementptr [7 x double], [7 x double]* %28, i64 0, i64 1
  %40 = getelementptr [7 x double], [7 x double]* %26, i64 0, i64 0
  %41 = getelementptr [7 x double], [7 x double]* %28, i64 0, i64 0
  %42 = addrspacecast [7 x double] addrspace(4)* %6 to [7 x double]*
  %43 = getelementptr [7 x double], [7 x double]* %42, i64 0, i64 6
  %44 = getelementptr [7 x double], [7 x double]* %42, i64 0, i64 4
  %45 = getelementptr [7 x double], [7 x double]* %42, i64 0, i64 2
  %46 = getelementptr [7 x double], [7 x double]* %42, i64 0, i64 0
  %47 = getelementptr [7 x double], [7 x double]* %42, i64 0, i64 1
  %48 = getelementptr [7 x double], [7 x double]* %42, i64 0, i64 3
  %49 = getelementptr [7 x double], [7 x double]* %42, i64 0, i64 5
  %50 = addrspacecast [7 x double] addrspace(4)* %7 to [7 x double]*
  %51 = getelementptr [7 x double], [7 x double]* %50, i64 0, i64 0
  %52 = getelementptr [7 x double], [7 x double]* %50, i64 0, i64 1
  %53 = getelementptr [7 x double], [7 x double]* %50, i64 0, i64 2
  %54 = getelementptr [7 x double], [7 x double]* %50, i64 0, i64 3
  %55 = getelementptr [7 x double], [7 x double]* %50, i64 0, i64 5
  %56 = getelementptr [7 x double], [7 x double]* %50, i64 0, i64 4
  %57 = getelementptr [7 x double], [7 x double]* %50, i64 0, i64 6
  br i1 %0, label %58, label %85

58:                                               ; preds = %9
  %59 = fcmp olt double %1, 1.600000e+01
  %60 = freeze i1 %59
  %61 = select i1 %60, double -8.000000e+00, double -1.600000e+01
  %62 = fadd double %1, %61
  %63 = fmul double %62, %62
  %64 = select i1 %60, double* %11, double* %13
  %65 = select i1 %60, double* %14, double* %15
  %66 = select i1 %60, double* %16, double* %17
  %67 = select i1 %60, double* %18, double* %19
  %68 = select i1 %60, double* %20, double* %21
  %69 = select i1 %60, double* %22, double* %23
  %70 = select i1 %60, double* %24, double* %25
  %71 = select i1 %60, double* %27, double* %29
  %72 = load double, double* %71, align 8, !tbaa !0
  %73 = fmul double %63, %72
  %74 = select i1 %60, double* %30, double* %31
  %75 = load double, double* %74, align 8, !tbaa !0
  %76 = fadd double %73, %75
  %77 = select i1 %60, double* %32, double* %33
  %78 = select i1 %60, double* %34, double* %35
  %79 = fmul double %63, %76
  %80 = select i1 %60, double* %36, double* %37
  %81 = load double, double* %80, align 8, !tbaa !0
  %82 = fadd double %79, %81
  %83 = select i1 %60, double* %38, double* %39
  %84 = select i1 %60, double* %40, double* %41
  br label %95

85:                                               ; preds = %9
  %86 = fadd double %1, -3.200000e+01
  %87 = fmul double %86, %86
  %88 = load double, double* %43, align 8, !tbaa !0
  %89 = fmul double %87, %88
  %90 = load double, double* %44, align 8, !tbaa !0
  %91 = fadd double %89, %90
  %92 = fmul double %87, %91
  %93 = load double, double* %45, align 8, !tbaa !0
  %94 = fadd double %92, %93
  br label %95

95:                                               ; preds = %85, %58
  %96 = phi double* [ %84, %58 ], [ %46, %85 ]
  %97 = phi double [ %82, %58 ], [ %94, %85 ]
  %98 = phi double* [ %83, %58 ], [ %47, %85 ]
  %99 = phi double* [ %78, %58 ], [ %48, %85 ]
  %100 = phi double* [ %77, %58 ], [ %49, %85 ]
  %101 = phi double [ %62, %58 ], [ %86, %85 ]
  %102 = phi double* [ %70, %58 ], [ %51, %85 ]
  %103 = phi double* [ %69, %58 ], [ %52, %85 ]
  %104 = phi double* [ %68, %58 ], [ %53, %85 ]
  %105 = phi double* [ %67, %58 ], [ %54, %85 ]
  %106 = phi double* [ %66, %58 ], [ %55, %85 ]
  %107 = phi double* [ %65, %58 ], [ %56, %85 ]
  %108 = phi double* [ %64, %58 ], [ %57, %85 ]
  %109 = phi double [ %63, %58 ], [ %87, %85 ]
  %110 = getelementptr inbounds { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 0
  store double* %96, double** %110, align 8
  %111 = getelementptr inbounds { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 1
  store double %97, double* %111, align 8
  %112 = getelementptr inbounds { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 2
  store double* %98, double** %112, align 8
  %113 = getelementptr inbounds { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 3
  store double* %99, double** %113, align 8
  %114 = getelementptr inbounds { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 4
  store double* %100, double** %114, align 8
  %115 = getelementptr inbounds { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 5
  store double %101, double* %115, align 8
  %116 = getelementptr inbounds { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 6
  store double* %102, double** %116, align 8
  %117 = getelementptr inbounds { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 7
  store double* %103, double** %117, align 8
  %118 = getelementptr inbounds { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 8
  store double* %104, double** %118, align 8
  %119 = getelementptr inbounds { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 9
  store double* %105, double** %119, align 8
  %120 = getelementptr inbounds { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 10
  store double* %106, double** %120, align 8
  %121 = getelementptr inbounds { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 11
  store double* %107, double** %121, align 8
  %122 = getelementptr inbounds { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 12
  store double* %108, double** %122, align 8
  %123 = getelementptr inbounds { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double, double*, double*, double*, double, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 13
  store double %109, double* %123, align 8
  ret void
}

attributes #0 = { nofree norecurse nounwind willreturn "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
