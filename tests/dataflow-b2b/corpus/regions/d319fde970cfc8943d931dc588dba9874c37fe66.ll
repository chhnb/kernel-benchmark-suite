; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-i64:64-i128:128-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: nofree norecurse nounwind willreturn
define void @region(i1 %0, [8 x double] addrspace(4)* %1, double %2, double %3, double %4, [6 x double] addrspace(4)* %5, i1 %6, [7 x double] addrspace(4)* %7, [7 x double] addrspace(4)* %8, [7 x double] addrspace(4)* %9, [7 x double] addrspace(4)* %10, i1 %11, [7 x double] addrspace(4)* %12, [7 x double] addrspace(4)* %13, [7 x double] addrspace(4)* %14, [7 x double] addrspace(4)* %15, { double, double*, double*, double*, double*, double, double }* %16) #0 {
  %18 = addrspacecast [8 x double] addrspace(4)* %1 to [8 x double]*
  %19 = getelementptr [8 x double], [8 x double]* %18, i64 0, i64 5
  %20 = getelementptr [8 x double], [8 x double]* %18, i64 0, i64 6
  %21 = getelementptr [8 x double], [8 x double]* %18, i64 0, i64 4
  %22 = getelementptr [8 x double], [8 x double]* %18, i64 0, i64 3
  %23 = getelementptr [8 x double], [8 x double]* %18, i64 0, i64 2
  %24 = getelementptr [8 x double], [8 x double]* %18, i64 0, i64 1
  %25 = getelementptr [8 x double], [8 x double]* %18, i64 0, i64 0
  %26 = addrspacecast [6 x double] addrspace(4)* %5 to [6 x double]*
  %27 = getelementptr [6 x double], [6 x double]* %26, i64 0, i64 4
  %28 = getelementptr [6 x double], [6 x double]* %26, i64 0, i64 2
  %29 = addrspacecast [7 x double] addrspace(4)* %7 to [7 x double]*
  %30 = getelementptr [7 x double], [7 x double]* %29, i64 0, i64 4
  %31 = addrspacecast [7 x double] addrspace(4)* %8 to [7 x double]*
  %32 = getelementptr [7 x double], [7 x double]* %31, i64 0, i64 4
  %33 = addrspacecast [7 x double] addrspace(4)* %9 to [7 x double]*
  %34 = getelementptr [7 x double], [7 x double]* %33, i64 0, i64 4
  %35 = addrspacecast [7 x double] addrspace(4)* %10 to [7 x double]*
  %36 = getelementptr [7 x double], [7 x double]* %35, i64 0, i64 4
  %37 = getelementptr [7 x double], [7 x double]* %29, i64 0, i64 5
  %38 = getelementptr [7 x double], [7 x double]* %31, i64 0, i64 5
  %39 = getelementptr [7 x double], [7 x double]* %33, i64 0, i64 5
  %40 = getelementptr [7 x double], [7 x double]* %35, i64 0, i64 5
  %41 = getelementptr [7 x double], [7 x double]* %29, i64 0, i64 3
  %42 = getelementptr [7 x double], [7 x double]* %31, i64 0, i64 3
  %43 = getelementptr [7 x double], [7 x double]* %33, i64 0, i64 3
  %44 = getelementptr [7 x double], [7 x double]* %35, i64 0, i64 3
  %45 = getelementptr [7 x double], [7 x double]* %29, i64 0, i64 2
  %46 = getelementptr [7 x double], [7 x double]* %31, i64 0, i64 2
  %47 = getelementptr [7 x double], [7 x double]* %33, i64 0, i64 2
  %48 = getelementptr [7 x double], [7 x double]* %35, i64 0, i64 2
  %49 = getelementptr [7 x double], [7 x double]* %29, i64 0, i64 1
  %50 = getelementptr [7 x double], [7 x double]* %31, i64 0, i64 1
  %51 = getelementptr [7 x double], [7 x double]* %33, i64 0, i64 1
  %52 = getelementptr [7 x double], [7 x double]* %35, i64 0, i64 1
  %53 = getelementptr [7 x double], [7 x double]* %29, i64 0, i64 0
  %54 = getelementptr [7 x double], [7 x double]* %31, i64 0, i64 0
  %55 = getelementptr [7 x double], [7 x double]* %33, i64 0, i64 0
  %56 = getelementptr [7 x double], [7 x double]* %35, i64 0, i64 0
  %57 = addrspacecast [7 x double] addrspace(4)* %12 to [7 x double]*
  %58 = getelementptr [7 x double], [7 x double]* %57, i64 0, i64 6
  %59 = addrspacecast [7 x double] addrspace(4)* %13 to [7 x double]*
  %60 = getelementptr [7 x double], [7 x double]* %59, i64 0, i64 6
  %61 = addrspacecast [7 x double] addrspace(4)* %14 to [7 x double]*
  %62 = getelementptr [7 x double], [7 x double]* %61, i64 0, i64 6
  %63 = addrspacecast [7 x double] addrspace(4)* %15 to [7 x double]*
  %64 = getelementptr [7 x double], [7 x double]* %63, i64 0, i64 6
  %65 = getelementptr [7 x double], [7 x double]* %57, i64 0, i64 4
  %66 = getelementptr [7 x double], [7 x double]* %59, i64 0, i64 4
  %67 = getelementptr [7 x double], [7 x double]* %61, i64 0, i64 4
  %68 = getelementptr [7 x double], [7 x double]* %63, i64 0, i64 4
  %69 = getelementptr [7 x double], [7 x double]* %57, i64 0, i64 5
  %70 = getelementptr [7 x double], [7 x double]* %59, i64 0, i64 5
  %71 = getelementptr [7 x double], [7 x double]* %61, i64 0, i64 5
  %72 = getelementptr [7 x double], [7 x double]* %63, i64 0, i64 5
  %73 = getelementptr [7 x double], [7 x double]* %57, i64 0, i64 3
  %74 = getelementptr [7 x double], [7 x double]* %59, i64 0, i64 3
  %75 = getelementptr [7 x double], [7 x double]* %61, i64 0, i64 3
  %76 = getelementptr [7 x double], [7 x double]* %63, i64 0, i64 3
  %77 = getelementptr [7 x double], [7 x double]* %57, i64 0, i64 2
  %78 = getelementptr [7 x double], [7 x double]* %59, i64 0, i64 2
  %79 = getelementptr [7 x double], [7 x double]* %61, i64 0, i64 2
  %80 = getelementptr [7 x double], [7 x double]* %63, i64 0, i64 2
  %81 = getelementptr [7 x double], [7 x double]* %57, i64 0, i64 1
  %82 = getelementptr [7 x double], [7 x double]* %59, i64 0, i64 1
  %83 = getelementptr [7 x double], [7 x double]* %61, i64 0, i64 1
  %84 = getelementptr [7 x double], [7 x double]* %63, i64 0, i64 1
  %85 = getelementptr [7 x double], [7 x double]* %57, i64 0, i64 0
  %86 = getelementptr [7 x double], [7 x double]* %59, i64 0, i64 0
  %87 = getelementptr [7 x double], [7 x double]* %61, i64 0, i64 0
  %88 = getelementptr [7 x double], [7 x double]* %63, i64 0, i64 0
  %89 = getelementptr [6 x double], [6 x double]* %26, i64 0, i64 0
  %90 = getelementptr [6 x double], [6 x double]* %26, i64 0, i64 1
  %91 = getelementptr [6 x double], [6 x double]* %26, i64 0, i64 3
  %92 = getelementptr [6 x double], [6 x double]* %26, i64 0, i64 5
  br i1 %0, label %93, label %117

93:                                               ; preds = %17
  %94 = load double, double* %19, align 8, !tbaa !0
  %95 = fadd double %2, %94
  %96 = load double, double* %20, align 8, !tbaa !0
  %97 = fmul double %3, %96
  %98 = load double, double* %21, align 8, !tbaa !0
  %99 = fadd double %97, %98
  %100 = fmul double %3, %95
  %101 = fmul double %3, %99
  %102 = load double, double* %22, align 8, !tbaa !0
  %103 = fadd double %100, %102
  %104 = load double, double* %23, align 8, !tbaa !0
  %105 = fadd double %101, %104
  %106 = fmul double %3, %103
  %107 = fmul double %3, %105
  %108 = load double, double* %24, align 8, !tbaa !0
  %109 = fadd double %106, %108
  %110 = load double, double* %25, align 8, !tbaa !0
  %111 = fadd double %107, %110
  %112 = fmul double %4, %109
  %113 = load double, double* %27, align 8, !tbaa !0
  %114 = fmul double %3, %113
  %115 = load double, double* %28, align 8, !tbaa !0
  %116 = fadd double %114, %115
  br label %180

117:                                              ; preds = %17
  %118 = select i1 %6, double* %30, double* %32
  %119 = select i1 %6, double* %34, double* %36
  %120 = select i1 %11, double* %118, double* %119
  %121 = load double, double* %120, align 8, !tbaa !0
  %122 = fadd double %2, %121
  %123 = select i1 %6, double* %37, double* %38
  %124 = select i1 %6, double* %39, double* %40
  %125 = select i1 %11, double* %123, double* %124
  %126 = load double, double* %125, align 8, !tbaa !0
  %127 = fmul double %3, %126
  %128 = select i1 %6, double* %41, double* %42
  %129 = select i1 %6, double* %43, double* %44
  %130 = select i1 %11, double* %128, double* %129
  %131 = load double, double* %130, align 8, !tbaa !0
  %132 = fadd double %127, %131
  %133 = fmul double %3, %122
  %134 = fmul double %3, %132
  %135 = select i1 %6, double* %45, double* %46
  %136 = select i1 %6, double* %47, double* %48
  %137 = select i1 %11, double* %135, double* %136
  %138 = load double, double* %137, align 8, !tbaa !0
  %139 = fadd double %133, %138
  %140 = select i1 %6, double* %49, double* %50
  %141 = select i1 %6, double* %51, double* %52
  %142 = select i1 %11, double* %140, double* %141
  %143 = load double, double* %142, align 8, !tbaa !0
  %144 = fadd double %134, %143
  %145 = fmul double %3, %139
  %146 = select i1 %6, double* %53, double* %54
  %147 = select i1 %6, double* %55, double* %56
  %148 = select i1 %11, double* %146, double* %147
  %149 = load double, double* %148, align 8, !tbaa !0
  %150 = fadd double %145, %149
  %151 = fmul double %4, %144
  %152 = select i1 %6, double* %58, double* %60
  %153 = select i1 %6, double* %62, double* %64
  %154 = select i1 %11, double* %152, double* %153
  %155 = load double, double* %154, align 8, !tbaa !0
  %156 = fmul double %3, %155
  %157 = select i1 %6, double* %65, double* %66
  %158 = select i1 %6, double* %67, double* %68
  %159 = select i1 %11, double* %157, double* %158
  %160 = load double, double* %159, align 8, !tbaa !0
  %161 = fadd double %156, %160
  %162 = select i1 %6, double* %69, double* %70
  %163 = select i1 %6, double* %71, double* %72
  %164 = select i1 %11, double* %162, double* %163
  %165 = select i1 %6, double* %73, double* %74
  %166 = select i1 %6, double* %75, double* %76
  %167 = select i1 %11, double* %165, double* %166
  %168 = fmul double %3, %161
  %169 = select i1 %6, double* %77, double* %78
  %170 = select i1 %6, double* %79, double* %80
  %171 = select i1 %11, double* %169, double* %170
  %172 = load double, double* %171, align 8, !tbaa !0
  %173 = fadd double %168, %172
  %174 = select i1 %6, double* %81, double* %82
  %175 = select i1 %6, double* %83, double* %84
  %176 = select i1 %11, double* %174, double* %175
  %177 = select i1 %6, double* %85, double* %86
  %178 = select i1 %6, double* %87, double* %88
  %179 = select i1 %11, double* %177, double* %178
  br label %180

180:                                              ; preds = %117, %93
  %181 = phi double [ %116, %93 ], [ %173, %117 ]
  %182 = phi double* [ %89, %93 ], [ %179, %117 ]
  %183 = phi double* [ %90, %93 ], [ %176, %117 ]
  %184 = phi double* [ %91, %93 ], [ %167, %117 ]
  %185 = phi double* [ %92, %93 ], [ %164, %117 ]
  %186 = phi double [ %111, %93 ], [ %151, %117 ]
  %187 = phi double [ %112, %93 ], [ %150, %117 ]
  %188 = getelementptr inbounds { double, double*, double*, double*, double*, double, double }, { double, double*, double*, double*, double*, double, double }* %16, i32 0, i32 0
  store double %181, double* %188, align 8
  %189 = getelementptr inbounds { double, double*, double*, double*, double*, double, double }, { double, double*, double*, double*, double*, double, double }* %16, i32 0, i32 1
  store double* %182, double** %189, align 8
  %190 = getelementptr inbounds { double, double*, double*, double*, double*, double, double }, { double, double*, double*, double*, double*, double, double }* %16, i32 0, i32 2
  store double* %183, double** %190, align 8
  %191 = getelementptr inbounds { double, double*, double*, double*, double*, double, double }, { double, double*, double*, double*, double*, double, double }* %16, i32 0, i32 3
  store double* %184, double** %191, align 8
  %192 = getelementptr inbounds { double, double*, double*, double*, double*, double, double }, { double, double*, double*, double*, double*, double, double }* %16, i32 0, i32 4
  store double* %185, double** %192, align 8
  %193 = getelementptr inbounds { double, double*, double*, double*, double*, double, double }, { double, double*, double*, double*, double*, double, double }* %16, i32 0, i32 5
  store double %186, double* %193, align 8
  %194 = getelementptr inbounds { double, double*, double*, double*, double*, double, double }, { double, double*, double*, double*, double*, double, double }* %16, i32 0, i32 6
  store double %187, double* %194, align 8
  ret void
}

attributes #0 = { nofree norecurse nounwind willreturn "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_70" "target-features"="+ptx32,+sm_70" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
