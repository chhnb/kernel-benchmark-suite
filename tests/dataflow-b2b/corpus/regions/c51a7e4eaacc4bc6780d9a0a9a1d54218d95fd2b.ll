; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: nofree norecurse nounwind willreturn
define void @region(i1 %0, [8 x double] addrspace(4)* %1, double %2, double %3, double %4, [6 x double] addrspace(4)* %5, i1 %6, [7 x double] addrspace(4)* %7, [7 x double] addrspace(4)* %8, [7 x double] addrspace(4)* %9, [7 x double] addrspace(4)* %10, i1 %11, [7 x double] addrspace(4)* %12, [7 x double] addrspace(4)* %13, [7 x double] addrspace(4)* %14, [7 x double] addrspace(4)* %15, double %16, { double, double, double*, double*, double*, double*, double*, double }* %17) #0 {
  %19 = addrspacecast [8 x double] addrspace(4)* %1 to [8 x double]*
  %20 = getelementptr [8 x double], [8 x double]* %19, i64 0, i64 1
  %21 = getelementptr [8 x double], [8 x double]* %19, i64 0, i64 0
  %22 = addrspacecast [6 x double] addrspace(4)* %5 to [6 x double]*
  %23 = getelementptr [6 x double], [6 x double]* %22, i64 0, i64 4
  %24 = addrspacecast [7 x double] addrspace(4)* %7 to [7 x double]*
  %25 = getelementptr [7 x double], [7 x double]* %24, i64 0, i64 0
  %26 = addrspacecast [7 x double] addrspace(4)* %8 to [7 x double]*
  %27 = getelementptr [7 x double], [7 x double]* %26, i64 0, i64 0
  %28 = addrspacecast [7 x double] addrspace(4)* %9 to [7 x double]*
  %29 = getelementptr [7 x double], [7 x double]* %28, i64 0, i64 0
  %30 = addrspacecast [7 x double] addrspace(4)* %10 to [7 x double]*
  %31 = getelementptr [7 x double], [7 x double]* %30, i64 0, i64 0
  %32 = addrspacecast [7 x double] addrspace(4)* %12 to [7 x double]*
  %33 = getelementptr [7 x double], [7 x double]* %32, i64 0, i64 6
  %34 = addrspacecast [7 x double] addrspace(4)* %13 to [7 x double]*
  %35 = getelementptr [7 x double], [7 x double]* %34, i64 0, i64 6
  %36 = addrspacecast [7 x double] addrspace(4)* %14 to [7 x double]*
  %37 = getelementptr [7 x double], [7 x double]* %36, i64 0, i64 6
  %38 = addrspacecast [7 x double] addrspace(4)* %15 to [7 x double]*
  %39 = getelementptr [7 x double], [7 x double]* %38, i64 0, i64 6
  %40 = getelementptr [7 x double], [7 x double]* %32, i64 0, i64 4
  %41 = getelementptr [7 x double], [7 x double]* %34, i64 0, i64 4
  %42 = getelementptr [7 x double], [7 x double]* %36, i64 0, i64 4
  %43 = getelementptr [7 x double], [7 x double]* %38, i64 0, i64 4
  %44 = getelementptr [7 x double], [7 x double]* %32, i64 0, i64 5
  %45 = getelementptr [7 x double], [7 x double]* %34, i64 0, i64 5
  %46 = getelementptr [7 x double], [7 x double]* %36, i64 0, i64 5
  %47 = getelementptr [7 x double], [7 x double]* %38, i64 0, i64 5
  %48 = getelementptr [7 x double], [7 x double]* %32, i64 0, i64 3
  %49 = getelementptr [7 x double], [7 x double]* %34, i64 0, i64 3
  %50 = getelementptr [7 x double], [7 x double]* %36, i64 0, i64 3
  %51 = getelementptr [7 x double], [7 x double]* %38, i64 0, i64 3
  %52 = getelementptr [7 x double], [7 x double]* %32, i64 0, i64 2
  %53 = getelementptr [7 x double], [7 x double]* %34, i64 0, i64 2
  %54 = getelementptr [7 x double], [7 x double]* %36, i64 0, i64 2
  %55 = getelementptr [7 x double], [7 x double]* %38, i64 0, i64 2
  %56 = getelementptr [7 x double], [7 x double]* %32, i64 0, i64 1
  %57 = getelementptr [7 x double], [7 x double]* %34, i64 0, i64 1
  %58 = getelementptr [7 x double], [7 x double]* %36, i64 0, i64 1
  %59 = getelementptr [7 x double], [7 x double]* %38, i64 0, i64 1
  %60 = getelementptr [7 x double], [7 x double]* %32, i64 0, i64 0
  %61 = getelementptr [7 x double], [7 x double]* %34, i64 0, i64 0
  %62 = getelementptr [7 x double], [7 x double]* %36, i64 0, i64 0
  %63 = getelementptr [7 x double], [7 x double]* %38, i64 0, i64 0
  %64 = getelementptr [6 x double], [6 x double]* %22, i64 0, i64 5
  %65 = getelementptr [6 x double], [6 x double]* %22, i64 0, i64 3
  %66 = getelementptr [6 x double], [6 x double]* %22, i64 0, i64 1
  %67 = getelementptr [6 x double], [6 x double]* %22, i64 0, i64 0
  %68 = getelementptr [6 x double], [6 x double]* %22, i64 0, i64 2
  br i1 %0, label %69, label %76

69:                                               ; preds = %18
  %70 = load double, double* %20, align 8, !tbaa !0
  %71 = fadd double %2, %70
  %72 = load double, double* %21, align 8, !tbaa !0
  %73 = fadd double %3, %72
  %74 = fmul double %4, %71
  %75 = load double, double* %23, align 8, !tbaa !0
  br label %107

76:                                               ; preds = %18
  %77 = select i1 %6, double* %25, double* %27
  %78 = select i1 %6, double* %29, double* %31
  %79 = select i1 %11, double* %77, double* %78
  %80 = load double, double* %79, align 8, !tbaa !0
  %81 = fadd double %2, %80
  %82 = select i1 %6, double* %33, double* %35
  %83 = select i1 %6, double* %37, double* %39
  %84 = select i1 %11, double* %82, double* %83
  %85 = load double, double* %84, align 8, !tbaa !0
  %86 = fmul double %16, %85
  %87 = select i1 %6, double* %40, double* %41
  %88 = select i1 %6, double* %42, double* %43
  %89 = select i1 %11, double* %87, double* %88
  %90 = load double, double* %89, align 8, !tbaa !0
  %91 = fadd double %86, %90
  %92 = select i1 %6, double* %44, double* %45
  %93 = select i1 %6, double* %46, double* %47
  %94 = select i1 %11, double* %92, double* %93
  %95 = select i1 %6, double* %48, double* %49
  %96 = select i1 %6, double* %50, double* %51
  %97 = select i1 %11, double* %95, double* %96
  %98 = select i1 %6, double* %52, double* %53
  %99 = select i1 %6, double* %54, double* %55
  %100 = select i1 %11, double* %98, double* %99
  %101 = select i1 %6, double* %56, double* %57
  %102 = select i1 %6, double* %58, double* %59
  %103 = select i1 %11, double* %101, double* %102
  %104 = select i1 %6, double* %60, double* %61
  %105 = select i1 %6, double* %62, double* %63
  %106 = select i1 %11, double* %104, double* %105
  br label %107

107:                                              ; preds = %76, %69
  %108 = phi double [ %74, %69 ], [ %81, %76 ]
  %109 = phi double [ %73, %69 ], [ %3, %76 ]
  %110 = phi double* [ %64, %69 ], [ %94, %76 ]
  %111 = phi double* [ %65, %69 ], [ %97, %76 ]
  %112 = phi double* [ %66, %69 ], [ %103, %76 ]
  %113 = phi double* [ %67, %69 ], [ %106, %76 ]
  %114 = phi double* [ %68, %69 ], [ %100, %76 ]
  %115 = phi double [ %75, %69 ], [ %91, %76 ]
  %116 = getelementptr inbounds { double, double, double*, double*, double*, double*, double*, double }, { double, double, double*, double*, double*, double*, double*, double }* %17, i32 0, i32 0
  store double %108, double* %116, align 8
  %117 = getelementptr inbounds { double, double, double*, double*, double*, double*, double*, double }, { double, double, double*, double*, double*, double*, double*, double }* %17, i32 0, i32 1
  store double %109, double* %117, align 8
  %118 = getelementptr inbounds { double, double, double*, double*, double*, double*, double*, double }, { double, double, double*, double*, double*, double*, double*, double }* %17, i32 0, i32 2
  store double* %110, double** %118, align 8
  %119 = getelementptr inbounds { double, double, double*, double*, double*, double*, double*, double }, { double, double, double*, double*, double*, double*, double*, double }* %17, i32 0, i32 3
  store double* %111, double** %119, align 8
  %120 = getelementptr inbounds { double, double, double*, double*, double*, double*, double*, double }, { double, double, double*, double*, double*, double*, double*, double }* %17, i32 0, i32 4
  store double* %112, double** %120, align 8
  %121 = getelementptr inbounds { double, double, double*, double*, double*, double*, double*, double }, { double, double, double*, double*, double*, double*, double*, double }* %17, i32 0, i32 5
  store double* %113, double** %121, align 8
  %122 = getelementptr inbounds { double, double, double*, double*, double*, double*, double*, double }, { double, double, double*, double*, double*, double*, double*, double }* %17, i32 0, i32 6
  store double* %114, double** %122, align 8
  %123 = getelementptr inbounds { double, double, double*, double*, double*, double*, double*, double }, { double, double, double*, double*, double*, double*, double*, double }* %17, i32 0, i32 7
  store double %115, double* %123, align 8
  ret void
}

attributes #0 = { nofree norecurse nounwind willreturn "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
