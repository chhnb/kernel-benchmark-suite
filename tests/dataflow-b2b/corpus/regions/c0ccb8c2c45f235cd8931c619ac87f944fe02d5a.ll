; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: nofree norecurse nounwind willreturn
define void @region(i1 %0, [8 x double] addrspace(4)* %1, double %2, double %3, double %4, double %5, [6 x double] addrspace(4)* %6, i1 %7, [7 x double] addrspace(4)* %8, [7 x double] addrspace(4)* %9, [7 x double] addrspace(4)* %10, [7 x double] addrspace(4)* %11, i1 %12, [7 x double] addrspace(4)* %13, [7 x double] addrspace(4)* %14, [7 x double] addrspace(4)* %15, [7 x double] addrspace(4)* %16, { double, double*, double*, double*, double*, double, double }* %17) #0 {
  %19 = addrspacecast [8 x double] addrspace(4)* %1 to [8 x double]*
  %20 = getelementptr [8 x double], [8 x double]* %19, i64 0, i64 3
  %21 = getelementptr [8 x double], [8 x double]* %19, i64 0, i64 2
  %22 = getelementptr [8 x double], [8 x double]* %19, i64 0, i64 1
  %23 = getelementptr [8 x double], [8 x double]* %19, i64 0, i64 0
  %24 = addrspacecast [6 x double] addrspace(4)* %6 to [6 x double]*
  %25 = getelementptr [6 x double], [6 x double]* %24, i64 0, i64 4
  %26 = getelementptr [6 x double], [6 x double]* %24, i64 0, i64 2
  %27 = addrspacecast [7 x double] addrspace(4)* %8 to [7 x double]*
  %28 = getelementptr [7 x double], [7 x double]* %27, i64 0, i64 2
  %29 = addrspacecast [7 x double] addrspace(4)* %9 to [7 x double]*
  %30 = getelementptr [7 x double], [7 x double]* %29, i64 0, i64 2
  %31 = addrspacecast [7 x double] addrspace(4)* %10 to [7 x double]*
  %32 = getelementptr [7 x double], [7 x double]* %31, i64 0, i64 2
  %33 = addrspacecast [7 x double] addrspace(4)* %11 to [7 x double]*
  %34 = getelementptr [7 x double], [7 x double]* %33, i64 0, i64 2
  %35 = getelementptr [7 x double], [7 x double]* %27, i64 0, i64 1
  %36 = getelementptr [7 x double], [7 x double]* %29, i64 0, i64 1
  %37 = getelementptr [7 x double], [7 x double]* %31, i64 0, i64 1
  %38 = getelementptr [7 x double], [7 x double]* %33, i64 0, i64 1
  %39 = getelementptr [7 x double], [7 x double]* %27, i64 0, i64 0
  %40 = getelementptr [7 x double], [7 x double]* %29, i64 0, i64 0
  %41 = getelementptr [7 x double], [7 x double]* %31, i64 0, i64 0
  %42 = getelementptr [7 x double], [7 x double]* %33, i64 0, i64 0
  %43 = addrspacecast [7 x double] addrspace(4)* %13 to [7 x double]*
  %44 = getelementptr [7 x double], [7 x double]* %43, i64 0, i64 6
  %45 = addrspacecast [7 x double] addrspace(4)* %14 to [7 x double]*
  %46 = getelementptr [7 x double], [7 x double]* %45, i64 0, i64 6
  %47 = addrspacecast [7 x double] addrspace(4)* %15 to [7 x double]*
  %48 = getelementptr [7 x double], [7 x double]* %47, i64 0, i64 6
  %49 = addrspacecast [7 x double] addrspace(4)* %16 to [7 x double]*
  %50 = getelementptr [7 x double], [7 x double]* %49, i64 0, i64 6
  %51 = getelementptr [7 x double], [7 x double]* %43, i64 0, i64 4
  %52 = getelementptr [7 x double], [7 x double]* %45, i64 0, i64 4
  %53 = getelementptr [7 x double], [7 x double]* %47, i64 0, i64 4
  %54 = getelementptr [7 x double], [7 x double]* %49, i64 0, i64 4
  %55 = getelementptr [7 x double], [7 x double]* %43, i64 0, i64 5
  %56 = getelementptr [7 x double], [7 x double]* %45, i64 0, i64 5
  %57 = getelementptr [7 x double], [7 x double]* %47, i64 0, i64 5
  %58 = getelementptr [7 x double], [7 x double]* %49, i64 0, i64 5
  %59 = getelementptr [7 x double], [7 x double]* %43, i64 0, i64 3
  %60 = getelementptr [7 x double], [7 x double]* %45, i64 0, i64 3
  %61 = getelementptr [7 x double], [7 x double]* %47, i64 0, i64 3
  %62 = getelementptr [7 x double], [7 x double]* %49, i64 0, i64 3
  %63 = getelementptr [7 x double], [7 x double]* %43, i64 0, i64 2
  %64 = getelementptr [7 x double], [7 x double]* %45, i64 0, i64 2
  %65 = getelementptr [7 x double], [7 x double]* %47, i64 0, i64 2
  %66 = getelementptr [7 x double], [7 x double]* %49, i64 0, i64 2
  %67 = getelementptr [7 x double], [7 x double]* %43, i64 0, i64 1
  %68 = getelementptr [7 x double], [7 x double]* %45, i64 0, i64 1
  %69 = getelementptr [7 x double], [7 x double]* %47, i64 0, i64 1
  %70 = getelementptr [7 x double], [7 x double]* %49, i64 0, i64 1
  %71 = getelementptr [7 x double], [7 x double]* %43, i64 0, i64 0
  %72 = getelementptr [7 x double], [7 x double]* %45, i64 0, i64 0
  %73 = getelementptr [7 x double], [7 x double]* %47, i64 0, i64 0
  %74 = getelementptr [7 x double], [7 x double]* %49, i64 0, i64 0
  %75 = getelementptr [6 x double], [6 x double]* %24, i64 0, i64 0
  %76 = getelementptr [6 x double], [6 x double]* %24, i64 0, i64 1
  %77 = getelementptr [6 x double], [6 x double]* %24, i64 0, i64 3
  %78 = getelementptr [6 x double], [6 x double]* %24, i64 0, i64 5
  br i1 %0, label %79, label %95

79:                                               ; preds = %18
  %80 = load double, double* %20, align 8, !tbaa !0
  %81 = fadd double %2, %80
  %82 = load double, double* %21, align 8, !tbaa !0
  %83 = fadd double %3, %82
  %84 = fmul double %4, %81
  %85 = fmul double %4, %83
  %86 = load double, double* %22, align 8, !tbaa !0
  %87 = fadd double %84, %86
  %88 = load double, double* %23, align 8, !tbaa !0
  %89 = fadd double %85, %88
  %90 = fmul double %5, %87
  %91 = load double, double* %25, align 8, !tbaa !0
  %92 = fmul double %4, %91
  %93 = load double, double* %26, align 8, !tbaa !0
  %94 = fadd double %92, %93
  br label %141

95:                                               ; preds = %18
  %96 = select i1 %7, double* %28, double* %30
  %97 = select i1 %7, double* %32, double* %34
  %98 = select i1 %12, double* %96, double* %97
  %99 = load double, double* %98, align 8, !tbaa !0
  %100 = fadd double %2, %99
  %101 = select i1 %7, double* %35, double* %36
  %102 = select i1 %7, double* %37, double* %38
  %103 = select i1 %12, double* %101, double* %102
  %104 = load double, double* %103, align 8, !tbaa !0
  %105 = fadd double %3, %104
  %106 = fmul double %4, %100
  %107 = select i1 %7, double* %39, double* %40
  %108 = select i1 %7, double* %41, double* %42
  %109 = select i1 %12, double* %107, double* %108
  %110 = load double, double* %109, align 8, !tbaa !0
  %111 = fadd double %106, %110
  %112 = fmul double %5, %105
  %113 = select i1 %7, double* %44, double* %46
  %114 = select i1 %7, double* %48, double* %50
  %115 = select i1 %12, double* %113, double* %114
  %116 = load double, double* %115, align 8, !tbaa !0
  %117 = fmul double %4, %116
  %118 = select i1 %7, double* %51, double* %52
  %119 = select i1 %7, double* %53, double* %54
  %120 = select i1 %12, double* %118, double* %119
  %121 = load double, double* %120, align 8, !tbaa !0
  %122 = fadd double %117, %121
  %123 = select i1 %7, double* %55, double* %56
  %124 = select i1 %7, double* %57, double* %58
  %125 = select i1 %12, double* %123, double* %124
  %126 = select i1 %7, double* %59, double* %60
  %127 = select i1 %7, double* %61, double* %62
  %128 = select i1 %12, double* %126, double* %127
  %129 = fmul double %4, %122
  %130 = select i1 %7, double* %63, double* %64
  %131 = select i1 %7, double* %65, double* %66
  %132 = select i1 %12, double* %130, double* %131
  %133 = load double, double* %132, align 8, !tbaa !0
  %134 = fadd double %129, %133
  %135 = select i1 %7, double* %67, double* %68
  %136 = select i1 %7, double* %69, double* %70
  %137 = select i1 %12, double* %135, double* %136
  %138 = select i1 %7, double* %71, double* %72
  %139 = select i1 %7, double* %73, double* %74
  %140 = select i1 %12, double* %138, double* %139
  br label %141

141:                                              ; preds = %95, %79
  %142 = phi double [ %94, %79 ], [ %134, %95 ]
  %143 = phi double* [ %75, %79 ], [ %140, %95 ]
  %144 = phi double* [ %76, %79 ], [ %137, %95 ]
  %145 = phi double* [ %77, %79 ], [ %128, %95 ]
  %146 = phi double* [ %78, %79 ], [ %125, %95 ]
  %147 = phi double [ %89, %79 ], [ %112, %95 ]
  %148 = phi double [ %90, %79 ], [ %111, %95 ]
  %149 = getelementptr inbounds { double, double*, double*, double*, double*, double, double }, { double, double*, double*, double*, double*, double, double }* %17, i32 0, i32 0
  store double %142, double* %149, align 8
  %150 = getelementptr inbounds { double, double*, double*, double*, double*, double, double }, { double, double*, double*, double*, double*, double, double }* %17, i32 0, i32 1
  store double* %143, double** %150, align 8
  %151 = getelementptr inbounds { double, double*, double*, double*, double*, double, double }, { double, double*, double*, double*, double*, double, double }* %17, i32 0, i32 2
  store double* %144, double** %151, align 8
  %152 = getelementptr inbounds { double, double*, double*, double*, double*, double, double }, { double, double*, double*, double*, double*, double, double }* %17, i32 0, i32 3
  store double* %145, double** %152, align 8
  %153 = getelementptr inbounds { double, double*, double*, double*, double*, double, double }, { double, double*, double*, double*, double*, double, double }* %17, i32 0, i32 4
  store double* %146, double** %153, align 8
  %154 = getelementptr inbounds { double, double*, double*, double*, double*, double, double }, { double, double*, double*, double*, double*, double, double }* %17, i32 0, i32 5
  store double %147, double* %154, align 8
  %155 = getelementptr inbounds { double, double*, double*, double*, double*, double, double }, { double, double*, double*, double*, double*, double, double }* %17, i32 0, i32 6
  store double %148, double* %155, align 8
  ret void
}

attributes #0 = { nofree norecurse nounwind willreturn "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
