; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: nofree norecurse nounwind willreturn
define void @region(i1 %0, double %1, double %2, [8 x double] addrspace(4)* %3, double %4, double %5, [6 x double] addrspace(4)* %6, i1 %7, [7 x double] addrspace(4)* %8, [7 x double] addrspace(4)* %9, [7 x double] addrspace(4)* %10, [7 x double] addrspace(4)* %11, i1 %12, [7 x double] addrspace(4)* %13, [7 x double] addrspace(4)* %14, [7 x double] addrspace(4)* %15, [7 x double] addrspace(4)* %16, { double, double*, double*, double*, double*, double, double }* %17) #0 {
  %19 = addrspacecast [8 x double] addrspace(4)* %3 to [8 x double]*
  %20 = getelementptr [8 x double], [8 x double]* %19, i64 0, i64 1
  %21 = getelementptr [8 x double], [8 x double]* %19, i64 0, i64 0
  %22 = addrspacecast [6 x double] addrspace(4)* %6 to [6 x double]*
  %23 = getelementptr [6 x double], [6 x double]* %22, i64 0, i64 4
  %24 = getelementptr [6 x double], [6 x double]* %22, i64 0, i64 2
  %25 = addrspacecast [7 x double] addrspace(4)* %8 to [7 x double]*
  %26 = getelementptr [7 x double], [7 x double]* %25, i64 0, i64 0
  %27 = addrspacecast [7 x double] addrspace(4)* %9 to [7 x double]*
  %28 = getelementptr [7 x double], [7 x double]* %27, i64 0, i64 0
  %29 = addrspacecast [7 x double] addrspace(4)* %10 to [7 x double]*
  %30 = getelementptr [7 x double], [7 x double]* %29, i64 0, i64 0
  %31 = addrspacecast [7 x double] addrspace(4)* %11 to [7 x double]*
  %32 = getelementptr [7 x double], [7 x double]* %31, i64 0, i64 0
  %33 = addrspacecast [7 x double] addrspace(4)* %13 to [7 x double]*
  %34 = getelementptr [7 x double], [7 x double]* %33, i64 0, i64 6
  %35 = addrspacecast [7 x double] addrspace(4)* %14 to [7 x double]*
  %36 = getelementptr [7 x double], [7 x double]* %35, i64 0, i64 6
  %37 = addrspacecast [7 x double] addrspace(4)* %15 to [7 x double]*
  %38 = getelementptr [7 x double], [7 x double]* %37, i64 0, i64 6
  %39 = addrspacecast [7 x double] addrspace(4)* %16 to [7 x double]*
  %40 = getelementptr [7 x double], [7 x double]* %39, i64 0, i64 6
  %41 = getelementptr [7 x double], [7 x double]* %33, i64 0, i64 4
  %42 = getelementptr [7 x double], [7 x double]* %35, i64 0, i64 4
  %43 = getelementptr [7 x double], [7 x double]* %37, i64 0, i64 4
  %44 = getelementptr [7 x double], [7 x double]* %39, i64 0, i64 4
  %45 = getelementptr [7 x double], [7 x double]* %33, i64 0, i64 5
  %46 = getelementptr [7 x double], [7 x double]* %35, i64 0, i64 5
  %47 = getelementptr [7 x double], [7 x double]* %37, i64 0, i64 5
  %48 = getelementptr [7 x double], [7 x double]* %39, i64 0, i64 5
  %49 = getelementptr [7 x double], [7 x double]* %33, i64 0, i64 3
  %50 = getelementptr [7 x double], [7 x double]* %35, i64 0, i64 3
  %51 = getelementptr [7 x double], [7 x double]* %37, i64 0, i64 3
  %52 = getelementptr [7 x double], [7 x double]* %39, i64 0, i64 3
  %53 = getelementptr [7 x double], [7 x double]* %33, i64 0, i64 2
  %54 = getelementptr [7 x double], [7 x double]* %35, i64 0, i64 2
  %55 = getelementptr [7 x double], [7 x double]* %37, i64 0, i64 2
  %56 = getelementptr [7 x double], [7 x double]* %39, i64 0, i64 2
  %57 = getelementptr [7 x double], [7 x double]* %33, i64 0, i64 1
  %58 = getelementptr [7 x double], [7 x double]* %35, i64 0, i64 1
  %59 = getelementptr [7 x double], [7 x double]* %37, i64 0, i64 1
  %60 = getelementptr [7 x double], [7 x double]* %39, i64 0, i64 1
  %61 = getelementptr [7 x double], [7 x double]* %33, i64 0, i64 0
  %62 = getelementptr [7 x double], [7 x double]* %35, i64 0, i64 0
  %63 = getelementptr [7 x double], [7 x double]* %37, i64 0, i64 0
  %64 = getelementptr [7 x double], [7 x double]* %39, i64 0, i64 0
  %65 = getelementptr [6 x double], [6 x double]* %22, i64 0, i64 0
  %66 = getelementptr [6 x double], [6 x double]* %22, i64 0, i64 1
  %67 = getelementptr [6 x double], [6 x double]* %22, i64 0, i64 3
  %68 = getelementptr [6 x double], [6 x double]* %22, i64 0, i64 5
  br i1 %0, label %69, label %80

69:                                               ; preds = %18
  %70 = fmul double %1, %2
  %71 = load double, double* %20, align 8, !tbaa !0
  %72 = fadd double %4, %71
  %73 = load double, double* %21, align 8, !tbaa !0
  %74 = fadd double %70, %73
  %75 = fmul double %5, %72
  %76 = load double, double* %23, align 8, !tbaa !0
  %77 = fmul double %1, %76
  %78 = load double, double* %24, align 8, !tbaa !0
  %79 = fadd double %77, %78
  br label %115

80:                                               ; preds = %18
  %81 = select i1 %7, double* %26, double* %28
  %82 = select i1 %7, double* %30, double* %32
  %83 = select i1 %12, double* %81, double* %82
  %84 = load double, double* %83, align 8, !tbaa !0
  %85 = fadd double %4, %84
  %86 = fmul double %5, %2
  %87 = select i1 %7, double* %34, double* %36
  %88 = select i1 %7, double* %38, double* %40
  %89 = select i1 %12, double* %87, double* %88
  %90 = load double, double* %89, align 8, !tbaa !0
  %91 = fmul double %1, %90
  %92 = select i1 %7, double* %41, double* %42
  %93 = select i1 %7, double* %43, double* %44
  %94 = select i1 %12, double* %92, double* %93
  %95 = load double, double* %94, align 8, !tbaa !0
  %96 = fadd double %91, %95
  %97 = select i1 %7, double* %45, double* %46
  %98 = select i1 %7, double* %47, double* %48
  %99 = select i1 %12, double* %97, double* %98
  %100 = select i1 %7, double* %49, double* %50
  %101 = select i1 %7, double* %51, double* %52
  %102 = select i1 %12, double* %100, double* %101
  %103 = fmul double %1, %96
  %104 = select i1 %7, double* %53, double* %54
  %105 = select i1 %7, double* %55, double* %56
  %106 = select i1 %12, double* %104, double* %105
  %107 = load double, double* %106, align 8, !tbaa !0
  %108 = fadd double %103, %107
  %109 = select i1 %7, double* %57, double* %58
  %110 = select i1 %7, double* %59, double* %60
  %111 = select i1 %12, double* %109, double* %110
  %112 = select i1 %7, double* %61, double* %62
  %113 = select i1 %7, double* %63, double* %64
  %114 = select i1 %12, double* %112, double* %113
  br label %115

115:                                              ; preds = %80, %69
  %116 = phi double [ %79, %69 ], [ %108, %80 ]
  %117 = phi double* [ %65, %69 ], [ %114, %80 ]
  %118 = phi double* [ %66, %69 ], [ %111, %80 ]
  %119 = phi double* [ %67, %69 ], [ %102, %80 ]
  %120 = phi double* [ %68, %69 ], [ %99, %80 ]
  %121 = phi double [ %74, %69 ], [ %86, %80 ]
  %122 = phi double [ %75, %69 ], [ %85, %80 ]
  %123 = getelementptr inbounds { double, double*, double*, double*, double*, double, double }, { double, double*, double*, double*, double*, double, double }* %17, i32 0, i32 0
  store double %116, double* %123, align 8
  %124 = getelementptr inbounds { double, double*, double*, double*, double*, double, double }, { double, double*, double*, double*, double*, double, double }* %17, i32 0, i32 1
  store double* %117, double** %124, align 8
  %125 = getelementptr inbounds { double, double*, double*, double*, double*, double, double }, { double, double*, double*, double*, double*, double, double }* %17, i32 0, i32 2
  store double* %118, double** %125, align 8
  %126 = getelementptr inbounds { double, double*, double*, double*, double*, double, double }, { double, double*, double*, double*, double*, double, double }* %17, i32 0, i32 3
  store double* %119, double** %126, align 8
  %127 = getelementptr inbounds { double, double*, double*, double*, double*, double, double }, { double, double*, double*, double*, double*, double, double }* %17, i32 0, i32 4
  store double* %120, double** %127, align 8
  %128 = getelementptr inbounds { double, double*, double*, double*, double*, double, double }, { double, double*, double*, double*, double*, double, double }* %17, i32 0, i32 5
  store double %121, double* %128, align 8
  %129 = getelementptr inbounds { double, double*, double*, double*, double*, double, double }, { double, double*, double*, double*, double*, double, double }* %17, i32 0, i32 6
  store double %122, double* %129, align 8
  ret void
}

attributes #0 = { nofree norecurse nounwind willreturn "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
