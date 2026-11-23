; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, [8 x [8 x float]] addrspace(3)* %1, i32 %2, [8 x [8 x float]] addrspace(3)* %3, [8 x [8 x float]] addrspace(3)* %4, i32 %5, { [8 x [8 x float]] addrspace(3)*, i32, i32 }* %6) #0 {
  %8 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 1, i32 0
  %9 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 2, i32 0
  %10 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 2, i32 1
  %11 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 3, i32 0
  %12 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 3, i32 1
  %13 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 3, i32 2
  %14 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 4, i32 0
  %15 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 4, i32 1
  %16 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 4, i32 2
  %17 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 4, i32 3
  %18 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 5, i32 0
  %19 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 5, i32 1
  %20 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 5, i32 2
  %21 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 5, i32 3
  %22 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 5, i32 4
  %23 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 6, i32 0
  %24 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 6, i32 1
  %25 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 6, i32 2
  %26 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 6, i32 3
  %27 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 6, i32 4
  %28 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 6, i32 5
  %29 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 7, i32 0
  %30 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 7, i32 1
  %31 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 7, i32 2
  %32 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 7, i32 3
  %33 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 7, i32 4
  %34 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 7, i32 5
  %35 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 7, i32 6
  %36 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 0, i32 0
  %37 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 0, i32 1
  %38 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 1, i32 1
  %39 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 0, i32 2
  %40 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 1, i32 2
  %41 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 2, i32 2
  %42 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 0, i32 3
  %43 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 1, i32 3
  %44 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 2, i32 3
  %45 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 3, i32 3
  %46 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 0, i32 4
  %47 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 1, i32 4
  %48 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 2, i32 4
  %49 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 3, i32 4
  %50 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 4, i32 4
  %51 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 0, i32 5
  %52 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 1, i32 5
  %53 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 2, i32 5
  %54 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 3, i32 5
  %55 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 4, i32 5
  %56 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 5, i32 5
  %57 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 0, i32 6
  %58 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 1, i32 6
  %59 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 2, i32 6
  %60 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 3, i32 6
  %61 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 4, i32 6
  %62 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 5, i32 6
  %63 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 6, i32 6
  %64 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 0, i32 7
  %65 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 1, i32 7
  %66 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 2, i32 7
  %67 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 3, i32 7
  %68 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 4, i32 7
  %69 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 5, i32 7
  %70 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 6, i32 7
  %71 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 7, i32 7
  br i1 %0, label %72, label %200

72:                                               ; preds = %7
  %73 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 1, i32 %2
  %74 = load float, float addrspace(3)* %73, align 4, !tbaa !1
  %75 = load float, float addrspace(3)* %8, align 16, !tbaa !1
  %76 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 0, i32 %2
  %77 = load float, float addrspace(3)* %76, align 4, !tbaa !1
  %78 = fmul contract float %75, %77
  %79 = fsub contract float %74, %78
  store float %79, float addrspace(3)* %73, align 4, !tbaa !1
  %80 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 2, i32 %2
  %81 = load float, float addrspace(3)* %80, align 4, !tbaa !1
  %82 = load float, float addrspace(3)* %9, align 16, !tbaa !1
  %83 = load float, float addrspace(3)* %76, align 4, !tbaa !1
  %84 = fmul contract float %82, %83
  %85 = fsub contract float %81, %84
  store float %85, float addrspace(3)* %80, align 4, !tbaa !1
  %86 = load float, float addrspace(3)* %10, align 4, !tbaa !1
  %87 = load float, float addrspace(3)* %73, align 4, !tbaa !1
  %88 = fmul contract float %86, %87
  %89 = fsub contract float %85, %88
  store float %89, float addrspace(3)* %80, align 4, !tbaa !1
  %90 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 3, i32 %2
  %91 = load float, float addrspace(3)* %90, align 4, !tbaa !1
  %92 = load float, float addrspace(3)* %11, align 16, !tbaa !1
  %93 = load float, float addrspace(3)* %76, align 4, !tbaa !1
  %94 = fmul contract float %92, %93
  %95 = fsub contract float %91, %94
  store float %95, float addrspace(3)* %90, align 4, !tbaa !1
  %96 = load float, float addrspace(3)* %12, align 4, !tbaa !1
  %97 = load float, float addrspace(3)* %73, align 4, !tbaa !1
  %98 = fmul contract float %96, %97
  %99 = fsub contract float %95, %98
  store float %99, float addrspace(3)* %90, align 4, !tbaa !1
  %100 = load float, float addrspace(3)* %13, align 8, !tbaa !1
  %101 = load float, float addrspace(3)* %80, align 4, !tbaa !1
  %102 = fmul contract float %100, %101
  %103 = fsub contract float %99, %102
  store float %103, float addrspace(3)* %90, align 4, !tbaa !1
  %104 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 4, i32 %2
  %105 = load float, float addrspace(3)* %104, align 4, !tbaa !1
  %106 = load float, float addrspace(3)* %14, align 16, !tbaa !1
  %107 = load float, float addrspace(3)* %76, align 4, !tbaa !1
  %108 = fmul contract float %106, %107
  %109 = fsub contract float %105, %108
  store float %109, float addrspace(3)* %104, align 4, !tbaa !1
  %110 = load float, float addrspace(3)* %15, align 4, !tbaa !1
  %111 = load float, float addrspace(3)* %73, align 4, !tbaa !1
  %112 = fmul contract float %110, %111
  %113 = fsub contract float %109, %112
  store float %113, float addrspace(3)* %104, align 4, !tbaa !1
  %114 = load float, float addrspace(3)* %16, align 8, !tbaa !1
  %115 = load float, float addrspace(3)* %80, align 4, !tbaa !1
  %116 = fmul contract float %114, %115
  %117 = fsub contract float %113, %116
  store float %117, float addrspace(3)* %104, align 4, !tbaa !1
  %118 = load float, float addrspace(3)* %17, align 4, !tbaa !1
  %119 = load float, float addrspace(3)* %90, align 4, !tbaa !1
  %120 = fmul contract float %118, %119
  %121 = fsub contract float %117, %120
  store float %121, float addrspace(3)* %104, align 4, !tbaa !1
  %122 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 5, i32 %2
  %123 = load float, float addrspace(3)* %122, align 4, !tbaa !1
  %124 = load float, float addrspace(3)* %18, align 16, !tbaa !1
  %125 = load float, float addrspace(3)* %76, align 4, !tbaa !1
  %126 = fmul contract float %124, %125
  %127 = fsub contract float %123, %126
  store float %127, float addrspace(3)* %122, align 4, !tbaa !1
  %128 = load float, float addrspace(3)* %19, align 4, !tbaa !1
  %129 = load float, float addrspace(3)* %73, align 4, !tbaa !1
  %130 = fmul contract float %128, %129
  %131 = fsub contract float %127, %130
  store float %131, float addrspace(3)* %122, align 4, !tbaa !1
  %132 = load float, float addrspace(3)* %20, align 8, !tbaa !1
  %133 = load float, float addrspace(3)* %80, align 4, !tbaa !1
  %134 = fmul contract float %132, %133
  %135 = fsub contract float %131, %134
  store float %135, float addrspace(3)* %122, align 4, !tbaa !1
  %136 = load float, float addrspace(3)* %21, align 4, !tbaa !1
  %137 = load float, float addrspace(3)* %90, align 4, !tbaa !1
  %138 = fmul contract float %136, %137
  %139 = fsub contract float %135, %138
  store float %139, float addrspace(3)* %122, align 4, !tbaa !1
  %140 = load float, float addrspace(3)* %22, align 16, !tbaa !1
  %141 = load float, float addrspace(3)* %104, align 4, !tbaa !1
  %142 = fmul contract float %140, %141
  %143 = fsub contract float %139, %142
  store float %143, float addrspace(3)* %122, align 4, !tbaa !1
  %144 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 6, i32 %2
  %145 = load float, float addrspace(3)* %144, align 4, !tbaa !1
  %146 = load float, float addrspace(3)* %23, align 16, !tbaa !1
  %147 = load float, float addrspace(3)* %76, align 4, !tbaa !1
  %148 = fmul contract float %146, %147
  %149 = fsub contract float %145, %148
  store float %149, float addrspace(3)* %144, align 4, !tbaa !1
  %150 = load float, float addrspace(3)* %24, align 4, !tbaa !1
  %151 = load float, float addrspace(3)* %73, align 4, !tbaa !1
  %152 = fmul contract float %150, %151
  %153 = fsub contract float %149, %152
  store float %153, float addrspace(3)* %144, align 4, !tbaa !1
  %154 = load float, float addrspace(3)* %25, align 8, !tbaa !1
  %155 = load float, float addrspace(3)* %80, align 4, !tbaa !1
  %156 = fmul contract float %154, %155
  %157 = fsub contract float %153, %156
  store float %157, float addrspace(3)* %144, align 4, !tbaa !1
  %158 = load float, float addrspace(3)* %26, align 4, !tbaa !1
  %159 = load float, float addrspace(3)* %90, align 4, !tbaa !1
  %160 = fmul contract float %158, %159
  %161 = fsub contract float %157, %160
  store float %161, float addrspace(3)* %144, align 4, !tbaa !1
  %162 = load float, float addrspace(3)* %27, align 16, !tbaa !1
  %163 = load float, float addrspace(3)* %104, align 4, !tbaa !1
  %164 = fmul contract float %162, %163
  %165 = fsub contract float %161, %164
  store float %165, float addrspace(3)* %144, align 4, !tbaa !1
  %166 = load float, float addrspace(3)* %28, align 4, !tbaa !1
  %167 = load float, float addrspace(3)* %122, align 4, !tbaa !1
  %168 = fmul contract float %166, %167
  %169 = fsub contract float %165, %168
  store float %169, float addrspace(3)* %144, align 4, !tbaa !1
  %170 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 7, i32 %2
  %171 = load float, float addrspace(3)* %170, align 4, !tbaa !1
  %172 = load float, float addrspace(3)* %29, align 16, !tbaa !1
  %173 = load float, float addrspace(3)* %76, align 4, !tbaa !1
  %174 = fmul contract float %172, %173
  %175 = fsub contract float %171, %174
  store float %175, float addrspace(3)* %170, align 4, !tbaa !1
  %176 = load float, float addrspace(3)* %30, align 4, !tbaa !1
  %177 = load float, float addrspace(3)* %73, align 4, !tbaa !1
  %178 = fmul contract float %176, %177
  %179 = fsub contract float %175, %178
  store float %179, float addrspace(3)* %170, align 4, !tbaa !1
  %180 = load float, float addrspace(3)* %31, align 8, !tbaa !1
  %181 = load float, float addrspace(3)* %80, align 4, !tbaa !1
  %182 = fmul contract float %180, %181
  %183 = fsub contract float %179, %182
  store float %183, float addrspace(3)* %170, align 4, !tbaa !1
  %184 = load float, float addrspace(3)* %32, align 4, !tbaa !1
  %185 = load float, float addrspace(3)* %90, align 4, !tbaa !1
  %186 = fmul contract float %184, %185
  %187 = fsub contract float %183, %186
  store float %187, float addrspace(3)* %170, align 4, !tbaa !1
  %188 = load float, float addrspace(3)* %33, align 16, !tbaa !1
  %189 = load float, float addrspace(3)* %104, align 4, !tbaa !1
  %190 = fmul contract float %188, %189
  %191 = fsub contract float %187, %190
  store float %191, float addrspace(3)* %170, align 4, !tbaa !1
  %192 = load float, float addrspace(3)* %34, align 4, !tbaa !1
  %193 = load float, float addrspace(3)* %122, align 4, !tbaa !1
  %194 = fmul contract float %192, %193
  %195 = fsub contract float %191, %194
  store float %195, float addrspace(3)* %170, align 4, !tbaa !1
  %196 = load float, float addrspace(3)* %35, align 8, !tbaa !1
  %197 = load float, float addrspace(3)* %144, align 4, !tbaa !1
  %198 = fmul contract float %196, %197
  %199 = fsub contract float %195, %198
  store float %199, float addrspace(3)* %170, align 4, !tbaa !1
  br label %339

200:                                              ; preds = %7
  %201 = add nsw i32 %2, -8
  %202 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %201, i32 0
  %203 = load float, float addrspace(3)* %202, align 16, !tbaa !1
  %204 = load float, float addrspace(3)* %36, align 16, !tbaa !1
  %205 = fdiv contract float %203, %204
  store float %205, float addrspace(3)* %202, align 16, !tbaa !1
  %206 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %201, i32 1
  %207 = load float, float addrspace(3)* %206, align 4, !tbaa !1
  %208 = load float, float addrspace(3)* %37, align 4, !tbaa !1
  %209 = fmul contract float %205, %208
  %210 = fsub contract float %207, %209
  store float %210, float addrspace(3)* %206, align 4, !tbaa !1
  %211 = load float, float addrspace(3)* %38, align 4, !tbaa !1
  %212 = fdiv contract float %210, %211
  store float %212, float addrspace(3)* %206, align 4, !tbaa !1
  %213 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %201, i32 2
  %214 = load float, float addrspace(3)* %213, align 8, !tbaa !1
  %215 = load float, float addrspace(3)* %39, align 8, !tbaa !1
  %216 = fmul contract float %205, %215
  %217 = fsub contract float %214, %216
  store float %217, float addrspace(3)* %213, align 8, !tbaa !1
  %218 = load float, float addrspace(3)* %206, align 4, !tbaa !1
  %219 = load float, float addrspace(3)* %40, align 8, !tbaa !1
  %220 = fmul contract float %218, %219
  %221 = fsub contract float %217, %220
  store float %221, float addrspace(3)* %213, align 8, !tbaa !1
  %222 = load float, float addrspace(3)* %41, align 8, !tbaa !1
  %223 = fdiv contract float %221, %222
  store float %223, float addrspace(3)* %213, align 8, !tbaa !1
  %224 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %201, i32 3
  %225 = load float, float addrspace(3)* %224, align 4, !tbaa !1
  %226 = load float, float addrspace(3)* %42, align 4, !tbaa !1
  %227 = fmul contract float %205, %226
  %228 = fsub contract float %225, %227
  store float %228, float addrspace(3)* %224, align 4, !tbaa !1
  %229 = load float, float addrspace(3)* %206, align 4, !tbaa !1
  %230 = load float, float addrspace(3)* %43, align 4, !tbaa !1
  %231 = fmul contract float %229, %230
  %232 = fsub contract float %228, %231
  store float %232, float addrspace(3)* %224, align 4, !tbaa !1
  %233 = load float, float addrspace(3)* %213, align 8, !tbaa !1
  %234 = load float, float addrspace(3)* %44, align 4, !tbaa !1
  %235 = fmul contract float %233, %234
  %236 = fsub contract float %232, %235
  store float %236, float addrspace(3)* %224, align 4, !tbaa !1
  %237 = load float, float addrspace(3)* %45, align 4, !tbaa !1
  %238 = fdiv contract float %236, %237
  store float %238, float addrspace(3)* %224, align 4, !tbaa !1
  %239 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %201, i32 4
  %240 = load float, float addrspace(3)* %239, align 16, !tbaa !1
  %241 = load float, float addrspace(3)* %46, align 16, !tbaa !1
  %242 = fmul contract float %205, %241
  %243 = fsub contract float %240, %242
  store float %243, float addrspace(3)* %239, align 16, !tbaa !1
  %244 = load float, float addrspace(3)* %206, align 4, !tbaa !1
  %245 = load float, float addrspace(3)* %47, align 16, !tbaa !1
  %246 = fmul contract float %244, %245
  %247 = fsub contract float %243, %246
  store float %247, float addrspace(3)* %239, align 16, !tbaa !1
  %248 = load float, float addrspace(3)* %213, align 8, !tbaa !1
  %249 = load float, float addrspace(3)* %48, align 16, !tbaa !1
  %250 = fmul contract float %248, %249
  %251 = fsub contract float %247, %250
  store float %251, float addrspace(3)* %239, align 16, !tbaa !1
  %252 = load float, float addrspace(3)* %224, align 4, !tbaa !1
  %253 = load float, float addrspace(3)* %49, align 16, !tbaa !1
  %254 = fmul contract float %252, %253
  %255 = fsub contract float %251, %254
  store float %255, float addrspace(3)* %239, align 16, !tbaa !1
  %256 = load float, float addrspace(3)* %50, align 16, !tbaa !1
  %257 = fdiv contract float %255, %256
  store float %257, float addrspace(3)* %239, align 16, !tbaa !1
  %258 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %201, i32 5
  %259 = load float, float addrspace(3)* %258, align 4, !tbaa !1
  %260 = load float, float addrspace(3)* %51, align 4, !tbaa !1
  %261 = fmul contract float %205, %260
  %262 = fsub contract float %259, %261
  store float %262, float addrspace(3)* %258, align 4, !tbaa !1
  %263 = load float, float addrspace(3)* %206, align 4, !tbaa !1
  %264 = load float, float addrspace(3)* %52, align 4, !tbaa !1
  %265 = fmul contract float %263, %264
  %266 = fsub contract float %262, %265
  store float %266, float addrspace(3)* %258, align 4, !tbaa !1
  %267 = load float, float addrspace(3)* %213, align 8, !tbaa !1
  %268 = load float, float addrspace(3)* %53, align 4, !tbaa !1
  %269 = fmul contract float %267, %268
  %270 = fsub contract float %266, %269
  store float %270, float addrspace(3)* %258, align 4, !tbaa !1
  %271 = load float, float addrspace(3)* %224, align 4, !tbaa !1
  %272 = load float, float addrspace(3)* %54, align 4, !tbaa !1
  %273 = fmul contract float %271, %272
  %274 = fsub contract float %270, %273
  store float %274, float addrspace(3)* %258, align 4, !tbaa !1
  %275 = load float, float addrspace(3)* %239, align 16, !tbaa !1
  %276 = load float, float addrspace(3)* %55, align 4, !tbaa !1
  %277 = fmul contract float %275, %276
  %278 = fsub contract float %274, %277
  store float %278, float addrspace(3)* %258, align 4, !tbaa !1
  %279 = load float, float addrspace(3)* %56, align 4, !tbaa !1
  %280 = fdiv contract float %278, %279
  store float %280, float addrspace(3)* %258, align 4, !tbaa !1
  %281 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %201, i32 6
  %282 = load float, float addrspace(3)* %281, align 8, !tbaa !1
  %283 = load float, float addrspace(3)* %57, align 8, !tbaa !1
  %284 = fmul contract float %205, %283
  %285 = fsub contract float %282, %284
  store float %285, float addrspace(3)* %281, align 8, !tbaa !1
  %286 = load float, float addrspace(3)* %206, align 4, !tbaa !1
  %287 = load float, float addrspace(3)* %58, align 8, !tbaa !1
  %288 = fmul contract float %286, %287
  %289 = fsub contract float %285, %288
  store float %289, float addrspace(3)* %281, align 8, !tbaa !1
  %290 = load float, float addrspace(3)* %213, align 8, !tbaa !1
  %291 = load float, float addrspace(3)* %59, align 8, !tbaa !1
  %292 = fmul contract float %290, %291
  %293 = fsub contract float %289, %292
  store float %293, float addrspace(3)* %281, align 8, !tbaa !1
  %294 = load float, float addrspace(3)* %224, align 4, !tbaa !1
  %295 = load float, float addrspace(3)* %60, align 8, !tbaa !1
  %296 = fmul contract float %294, %295
  %297 = fsub contract float %293, %296
  store float %297, float addrspace(3)* %281, align 8, !tbaa !1
  %298 = load float, float addrspace(3)* %239, align 16, !tbaa !1
  %299 = load float, float addrspace(3)* %61, align 8, !tbaa !1
  %300 = fmul contract float %298, %299
  %301 = fsub contract float %297, %300
  store float %301, float addrspace(3)* %281, align 8, !tbaa !1
  %302 = load float, float addrspace(3)* %258, align 4, !tbaa !1
  %303 = load float, float addrspace(3)* %62, align 8, !tbaa !1
  %304 = fmul contract float %302, %303
  %305 = fsub contract float %301, %304
  store float %305, float addrspace(3)* %281, align 8, !tbaa !1
  %306 = load float, float addrspace(3)* %63, align 8, !tbaa !1
  %307 = fdiv contract float %305, %306
  store float %307, float addrspace(3)* %281, align 8, !tbaa !1
  %308 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %201, i32 7
  %309 = load float, float addrspace(3)* %308, align 4, !tbaa !1
  %310 = load float, float addrspace(3)* %64, align 4, !tbaa !1
  %311 = fmul contract float %205, %310
  %312 = fsub contract float %309, %311
  store float %312, float addrspace(3)* %308, align 4, !tbaa !1
  %313 = load float, float addrspace(3)* %206, align 4, !tbaa !1
  %314 = load float, float addrspace(3)* %65, align 4, !tbaa !1
  %315 = fmul contract float %313, %314
  %316 = fsub contract float %312, %315
  store float %316, float addrspace(3)* %308, align 4, !tbaa !1
  %317 = load float, float addrspace(3)* %213, align 8, !tbaa !1
  %318 = load float, float addrspace(3)* %66, align 4, !tbaa !1
  %319 = fmul contract float %317, %318
  %320 = fsub contract float %316, %319
  store float %320, float addrspace(3)* %308, align 4, !tbaa !1
  %321 = load float, float addrspace(3)* %224, align 4, !tbaa !1
  %322 = load float, float addrspace(3)* %67, align 4, !tbaa !1
  %323 = fmul contract float %321, %322
  %324 = fsub contract float %320, %323
  store float %324, float addrspace(3)* %308, align 4, !tbaa !1
  %325 = load float, float addrspace(3)* %239, align 16, !tbaa !1
  %326 = load float, float addrspace(3)* %68, align 4, !tbaa !1
  %327 = fmul contract float %325, %326
  %328 = fsub contract float %324, %327
  store float %328, float addrspace(3)* %308, align 4, !tbaa !1
  %329 = load float, float addrspace(3)* %258, align 4, !tbaa !1
  %330 = load float, float addrspace(3)* %69, align 4, !tbaa !1
  %331 = fmul contract float %329, %330
  %332 = fsub contract float %328, %331
  store float %332, float addrspace(3)* %308, align 4, !tbaa !1
  %333 = load float, float addrspace(3)* %281, align 8, !tbaa !1
  %334 = load float, float addrspace(3)* %70, align 4, !tbaa !1
  %335 = fmul contract float %333, %334
  %336 = fsub contract float %332, %335
  store float %336, float addrspace(3)* %308, align 4, !tbaa !1
  %337 = load float, float addrspace(3)* %71, align 4, !tbaa !1
  %338 = fdiv contract float %336, %337
  store float %338, float addrspace(3)* %308, align 4, !tbaa !1
  br label %339

339:                                              ; preds = %200, %72
  %340 = phi [8 x [8 x float]] addrspace(3)* [ %1, %72 ], [ %4, %200 ]
  %341 = phi i32 [ 1, %72 ], [ -8, %200 ]
  %342 = phi i32 [ %5, %72 ], [ %2, %200 ]
  %343 = getelementptr inbounds { [8 x [8 x float]] addrspace(3)*, i32, i32 }, { [8 x [8 x float]] addrspace(3)*, i32, i32 }* %6, i32 0, i32 0
  store [8 x [8 x float]] addrspace(3)* %340, [8 x [8 x float]] addrspace(3)** %343, align 4
  %344 = getelementptr inbounds { [8 x [8 x float]] addrspace(3)*, i32, i32 }, { [8 x [8 x float]] addrspace(3)*, i32, i32 }* %6, i32 0, i32 1
  store i32 %341, i32* %344, align 4
  %345 = getelementptr inbounds { [8 x [8 x float]] addrspace(3)*, i32, i32 }, { [8 x [8 x float]] addrspace(3)*, i32, i32 }* %6, i32 0, i32 2
  store i32 %342, i32* %345, align 4
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 2, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
