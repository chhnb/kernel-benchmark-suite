; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: nofree norecurse nounwind willreturn
define void @region(i1 %0, [8 x double] addrspace(4)* %1, double %2, double %3, double %4, [6 x double] addrspace(4)* %5, i1 %6, [7 x double] addrspace(4)* %7, [7 x double] addrspace(4)* %8, [7 x double] addrspace(4)* %9, [7 x double] addrspace(4)* %10, i1 %11, double %12, { double, double, double*, double*, double*, double*, double*, double }* %13) #0 {
  %15 = addrspacecast [8 x double] addrspace(4)* %1 to [8 x double]*
  %16 = getelementptr [8 x double], [8 x double]* %15, i64 0, i64 0
  %17 = addrspacecast [6 x double] addrspace(4)* %5 to [6 x double]*
  %18 = getelementptr [6 x double], [6 x double]* %17, i64 0, i64 4
  %19 = addrspacecast [7 x double] addrspace(4)* %7 to [7 x double]*
  %20 = getelementptr [7 x double], [7 x double]* %19, i64 0, i64 6
  %21 = addrspacecast [7 x double] addrspace(4)* %8 to [7 x double]*
  %22 = getelementptr [7 x double], [7 x double]* %21, i64 0, i64 6
  %23 = addrspacecast [7 x double] addrspace(4)* %9 to [7 x double]*
  %24 = getelementptr [7 x double], [7 x double]* %23, i64 0, i64 6
  %25 = addrspacecast [7 x double] addrspace(4)* %10 to [7 x double]*
  %26 = getelementptr [7 x double], [7 x double]* %25, i64 0, i64 6
  %27 = getelementptr [7 x double], [7 x double]* %19, i64 0, i64 4
  %28 = getelementptr [7 x double], [7 x double]* %21, i64 0, i64 4
  %29 = getelementptr [7 x double], [7 x double]* %23, i64 0, i64 4
  %30 = getelementptr [7 x double], [7 x double]* %25, i64 0, i64 4
  %31 = getelementptr [7 x double], [7 x double]* %19, i64 0, i64 5
  %32 = getelementptr [7 x double], [7 x double]* %21, i64 0, i64 5
  %33 = getelementptr [7 x double], [7 x double]* %23, i64 0, i64 5
  %34 = getelementptr [7 x double], [7 x double]* %25, i64 0, i64 5
  %35 = getelementptr [7 x double], [7 x double]* %19, i64 0, i64 3
  %36 = getelementptr [7 x double], [7 x double]* %21, i64 0, i64 3
  %37 = getelementptr [7 x double], [7 x double]* %23, i64 0, i64 3
  %38 = getelementptr [7 x double], [7 x double]* %25, i64 0, i64 3
  %39 = getelementptr [7 x double], [7 x double]* %19, i64 0, i64 2
  %40 = getelementptr [7 x double], [7 x double]* %21, i64 0, i64 2
  %41 = getelementptr [7 x double], [7 x double]* %23, i64 0, i64 2
  %42 = getelementptr [7 x double], [7 x double]* %25, i64 0, i64 2
  %43 = getelementptr [7 x double], [7 x double]* %19, i64 0, i64 1
  %44 = getelementptr [7 x double], [7 x double]* %21, i64 0, i64 1
  %45 = getelementptr [7 x double], [7 x double]* %23, i64 0, i64 1
  %46 = getelementptr [7 x double], [7 x double]* %25, i64 0, i64 1
  %47 = getelementptr [7 x double], [7 x double]* %19, i64 0, i64 0
  %48 = getelementptr [7 x double], [7 x double]* %21, i64 0, i64 0
  %49 = getelementptr [7 x double], [7 x double]* %23, i64 0, i64 0
  %50 = getelementptr [7 x double], [7 x double]* %25, i64 0, i64 0
  %51 = getelementptr [6 x double], [6 x double]* %17, i64 0, i64 5
  %52 = getelementptr [6 x double], [6 x double]* %17, i64 0, i64 3
  %53 = getelementptr [6 x double], [6 x double]* %17, i64 0, i64 1
  %54 = getelementptr [6 x double], [6 x double]* %17, i64 0, i64 0
  %55 = getelementptr [6 x double], [6 x double]* %17, i64 0, i64 2
  br i1 %0, label %56, label %61

56:                                               ; preds = %14
  %57 = load double, double* %16, align 8, !tbaa !0
  %58 = fadd double %2, %57
  %59 = fmul double %3, %4
  %60 = load double, double* %18, align 8, !tbaa !0
  br label %87

61:                                               ; preds = %14
  %62 = select i1 %6, double* %20, double* %22
  %63 = select i1 %6, double* %24, double* %26
  %64 = select i1 %11, double* %62, double* %63
  %65 = load double, double* %64, align 8, !tbaa !0
  %66 = fmul double %12, %65
  %67 = select i1 %6, double* %27, double* %28
  %68 = select i1 %6, double* %29, double* %30
  %69 = select i1 %11, double* %67, double* %68
  %70 = load double, double* %69, align 8, !tbaa !0
  %71 = fadd double %66, %70
  %72 = select i1 %6, double* %31, double* %32
  %73 = select i1 %6, double* %33, double* %34
  %74 = select i1 %11, double* %72, double* %73
  %75 = select i1 %6, double* %35, double* %36
  %76 = select i1 %6, double* %37, double* %38
  %77 = select i1 %11, double* %75, double* %76
  %78 = select i1 %6, double* %39, double* %40
  %79 = select i1 %6, double* %41, double* %42
  %80 = select i1 %11, double* %78, double* %79
  %81 = select i1 %6, double* %43, double* %44
  %82 = select i1 %6, double* %45, double* %46
  %83 = select i1 %11, double* %81, double* %82
  %84 = select i1 %6, double* %47, double* %48
  %85 = select i1 %6, double* %49, double* %50
  %86 = select i1 %11, double* %84, double* %85
  br label %87

87:                                               ; preds = %61, %56
  %88 = phi double [ %59, %56 ], [ %4, %61 ]
  %89 = phi double [ %58, %56 ], [ %2, %61 ]
  %90 = phi double* [ %51, %56 ], [ %74, %61 ]
  %91 = phi double* [ %52, %56 ], [ %77, %61 ]
  %92 = phi double* [ %53, %56 ], [ %83, %61 ]
  %93 = phi double* [ %54, %56 ], [ %86, %61 ]
  %94 = phi double* [ %55, %56 ], [ %80, %61 ]
  %95 = phi double [ %60, %56 ], [ %71, %61 ]
  %96 = getelementptr inbounds { double, double, double*, double*, double*, double*, double*, double }, { double, double, double*, double*, double*, double*, double*, double }* %13, i32 0, i32 0
  store double %88, double* %96, align 8
  %97 = getelementptr inbounds { double, double, double*, double*, double*, double*, double*, double }, { double, double, double*, double*, double*, double*, double*, double }* %13, i32 0, i32 1
  store double %89, double* %97, align 8
  %98 = getelementptr inbounds { double, double, double*, double*, double*, double*, double*, double }, { double, double, double*, double*, double*, double*, double*, double }* %13, i32 0, i32 2
  store double* %90, double** %98, align 8
  %99 = getelementptr inbounds { double, double, double*, double*, double*, double*, double*, double }, { double, double, double*, double*, double*, double*, double*, double }* %13, i32 0, i32 3
  store double* %91, double** %99, align 8
  %100 = getelementptr inbounds { double, double, double*, double*, double*, double*, double*, double }, { double, double, double*, double*, double*, double*, double*, double }* %13, i32 0, i32 4
  store double* %92, double** %100, align 8
  %101 = getelementptr inbounds { double, double, double*, double*, double*, double*, double*, double }, { double, double, double*, double*, double*, double*, double*, double }* %13, i32 0, i32 5
  store double* %93, double** %101, align 8
  %102 = getelementptr inbounds { double, double, double*, double*, double*, double*, double*, double }, { double, double, double*, double*, double*, double*, double*, double }* %13, i32 0, i32 6
  store double* %94, double** %102, align 8
  %103 = getelementptr inbounds { double, double, double*, double*, double*, double*, double*, double }, { double, double, double*, double*, double*, double*, double*, double }* %13, i32 0, i32 7
  store double %95, double* %103, align 8
  ret void
}

attributes #0 = { nofree norecurse nounwind willreturn "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
