; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: nofree norecurse nounwind willreturn
define void @region(i1 %0, double %1, [7 x double] addrspace(4)* %2, [7 x double] addrspace(4)* %3, [7 x double] addrspace(4)* %4, [7 x double] addrspace(4)* %5, [7 x double] addrspace(4)* %6, [7 x double] addrspace(4)* %7, { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }* %8) #0 {
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
  %45 = getelementptr [7 x double], [7 x double]* %42, i64 0, i64 5
  %46 = getelementptr [7 x double], [7 x double]* %42, i64 0, i64 3
  %47 = getelementptr [7 x double], [7 x double]* %42, i64 0, i64 2
  %48 = getelementptr [7 x double], [7 x double]* %42, i64 0, i64 1
  %49 = getelementptr [7 x double], [7 x double]* %42, i64 0, i64 0
  %50 = addrspacecast [7 x double] addrspace(4)* %7 to [7 x double]*
  %51 = getelementptr [7 x double], [7 x double]* %50, i64 0, i64 5
  %52 = getelementptr [7 x double], [7 x double]* %50, i64 0, i64 3
  %53 = getelementptr [7 x double], [7 x double]* %50, i64 0, i64 1
  %54 = getelementptr [7 x double], [7 x double]* %50, i64 0, i64 0
  %55 = getelementptr [7 x double], [7 x double]* %50, i64 0, i64 2
  %56 = getelementptr [7 x double], [7 x double]* %50, i64 0, i64 4
  %57 = getelementptr [7 x double], [7 x double]* %50, i64 0, i64 6
  br i1 %0, label %58, label %76

58:                                               ; preds = %9
  %59 = fcmp olt double %1, 1.600000e+01
  %60 = freeze i1 %59
  %61 = select i1 %60, double -8.000000e+00, double -1.600000e+01
  %62 = select i1 %60, double* %11, double* %13
  %63 = select i1 %60, double* %14, double* %15
  %64 = select i1 %60, double* %16, double* %17
  %65 = select i1 %60, double* %18, double* %19
  %66 = select i1 %60, double* %20, double* %21
  %67 = select i1 %60, double* %22, double* %23
  %68 = select i1 %60, double* %24, double* %25
  %69 = select i1 %60, double* %27, double* %29
  %70 = select i1 %60, double* %30, double* %31
  %71 = select i1 %60, double* %32, double* %33
  %72 = select i1 %60, double* %34, double* %35
  %73 = select i1 %60, double* %36, double* %37
  %74 = select i1 %60, double* %38, double* %39
  %75 = select i1 %60, double* %40, double* %41
  br label %77

76:                                               ; preds = %9
  br label %77

77:                                               ; preds = %76, %58
  %78 = phi double* [ %62, %58 ], [ %43, %76 ]
  %79 = phi double* [ %63, %58 ], [ %44, %76 ]
  %80 = phi double* [ %64, %58 ], [ %45, %76 ]
  %81 = phi double* [ %65, %58 ], [ %46, %76 ]
  %82 = phi double* [ %66, %58 ], [ %47, %76 ]
  %83 = phi double* [ %67, %58 ], [ %48, %76 ]
  %84 = phi double* [ %68, %58 ], [ %49, %76 ]
  %85 = phi double* [ %71, %58 ], [ %51, %76 ]
  %86 = phi double* [ %72, %58 ], [ %52, %76 ]
  %87 = phi double* [ %74, %58 ], [ %53, %76 ]
  %88 = phi double* [ %75, %58 ], [ %54, %76 ]
  %89 = phi double* [ %73, %58 ], [ %55, %76 ]
  %90 = phi double* [ %70, %58 ], [ %56, %76 ]
  %91 = phi double* [ %69, %58 ], [ %57, %76 ]
  %92 = phi double [ %61, %58 ], [ -3.200000e+01, %76 ]
  %93 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 0
  store double* %78, double** %93, align 8
  %94 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 1
  store double* %79, double** %94, align 8
  %95 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 2
  store double* %80, double** %95, align 8
  %96 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 3
  store double* %81, double** %96, align 8
  %97 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 4
  store double* %82, double** %97, align 8
  %98 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 5
  store double* %83, double** %98, align 8
  %99 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 6
  store double* %84, double** %99, align 8
  %100 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 7
  store double* %85, double** %100, align 8
  %101 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 8
  store double* %86, double** %101, align 8
  %102 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 9
  store double* %87, double** %102, align 8
  %103 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 10
  store double* %88, double** %103, align 8
  %104 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 11
  store double* %89, double** %104, align 8
  %105 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 12
  store double* %90, double** %105, align 8
  %106 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 13
  store double* %91, double** %106, align 8
  %107 = getelementptr inbounds { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }, { double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double*, double }* %8, i32 0, i32 14
  store double %92, double* %107, align 8
  ret void
}

attributes #0 = { nofree norecurse nounwind willreturn "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }
