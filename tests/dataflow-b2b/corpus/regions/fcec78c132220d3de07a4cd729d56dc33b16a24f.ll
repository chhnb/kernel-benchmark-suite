; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i32 %1, i32 addrspace(1)* %2, [8192 x i32] addrspace(3)* %3, i32 %4) #0 {
  br i1 %0, label %6, label %390

6:                                                ; preds = %5
  %7 = shl nsw i32 %1, 6
  %8 = sext i32 %7 to i64
  %9 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %8
  %10 = load i32, i32 addrspace(1)* %9, align 4, !tbaa !0
  %11 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %4
  store i32 %10, i32 addrspace(3)* %11, align 16, !tbaa !0
  %12 = or i32 %7, 1
  %13 = sext i32 %12 to i64
  %14 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %13
  %15 = load i32, i32 addrspace(1)* %14, align 4, !tbaa !0
  %16 = or i32 %4, 1
  %17 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %16
  store i32 %15, i32 addrspace(3)* %17, align 4, !tbaa !0
  %18 = or i32 %7, 2
  %19 = sext i32 %18 to i64
  %20 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %19
  %21 = load i32, i32 addrspace(1)* %20, align 4, !tbaa !0
  %22 = or i32 %4, 2
  %23 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %22
  store i32 %21, i32 addrspace(3)* %23, align 8, !tbaa !0
  %24 = or i32 %7, 3
  %25 = sext i32 %24 to i64
  %26 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %25
  %27 = load i32, i32 addrspace(1)* %26, align 4, !tbaa !0
  %28 = or i32 %4, 3
  %29 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %28
  store i32 %27, i32 addrspace(3)* %29, align 4, !tbaa !0
  %30 = or i32 %7, 4
  %31 = sext i32 %30 to i64
  %32 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %31
  %33 = load i32, i32 addrspace(1)* %32, align 4, !tbaa !0
  %34 = or i32 %4, 4
  %35 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %34
  store i32 %33, i32 addrspace(3)* %35, align 16, !tbaa !0
  %36 = or i32 %7, 5
  %37 = sext i32 %36 to i64
  %38 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %37
  %39 = load i32, i32 addrspace(1)* %38, align 4, !tbaa !0
  %40 = or i32 %4, 5
  %41 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %40
  store i32 %39, i32 addrspace(3)* %41, align 4, !tbaa !0
  %42 = or i32 %7, 6
  %43 = sext i32 %42 to i64
  %44 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %43
  %45 = load i32, i32 addrspace(1)* %44, align 4, !tbaa !0
  %46 = or i32 %4, 6
  %47 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %46
  store i32 %45, i32 addrspace(3)* %47, align 8, !tbaa !0
  %48 = or i32 %7, 7
  %49 = sext i32 %48 to i64
  %50 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %49
  %51 = load i32, i32 addrspace(1)* %50, align 4, !tbaa !0
  %52 = or i32 %4, 7
  %53 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %52
  store i32 %51, i32 addrspace(3)* %53, align 4, !tbaa !0
  %54 = or i32 %7, 8
  %55 = sext i32 %54 to i64
  %56 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %55
  %57 = load i32, i32 addrspace(1)* %56, align 4, !tbaa !0
  %58 = or i32 %4, 8
  %59 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %58
  store i32 %57, i32 addrspace(3)* %59, align 16, !tbaa !0
  %60 = or i32 %7, 9
  %61 = sext i32 %60 to i64
  %62 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %61
  %63 = load i32, i32 addrspace(1)* %62, align 4, !tbaa !0
  %64 = or i32 %4, 9
  %65 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %64
  store i32 %63, i32 addrspace(3)* %65, align 4, !tbaa !0
  %66 = or i32 %7, 10
  %67 = sext i32 %66 to i64
  %68 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %67
  %69 = load i32, i32 addrspace(1)* %68, align 4, !tbaa !0
  %70 = or i32 %4, 10
  %71 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %70
  store i32 %69, i32 addrspace(3)* %71, align 8, !tbaa !0
  %72 = or i32 %7, 11
  %73 = sext i32 %72 to i64
  %74 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %73
  %75 = load i32, i32 addrspace(1)* %74, align 4, !tbaa !0
  %76 = or i32 %4, 11
  %77 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %76
  store i32 %75, i32 addrspace(3)* %77, align 4, !tbaa !0
  %78 = or i32 %7, 12
  %79 = sext i32 %78 to i64
  %80 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %79
  %81 = load i32, i32 addrspace(1)* %80, align 4, !tbaa !0
  %82 = or i32 %4, 12
  %83 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %82
  store i32 %81, i32 addrspace(3)* %83, align 16, !tbaa !0
  %84 = or i32 %7, 13
  %85 = sext i32 %84 to i64
  %86 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %85
  %87 = load i32, i32 addrspace(1)* %86, align 4, !tbaa !0
  %88 = or i32 %4, 13
  %89 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %88
  store i32 %87, i32 addrspace(3)* %89, align 4, !tbaa !0
  %90 = or i32 %7, 14
  %91 = sext i32 %90 to i64
  %92 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %91
  %93 = load i32, i32 addrspace(1)* %92, align 4, !tbaa !0
  %94 = or i32 %4, 14
  %95 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %94
  store i32 %93, i32 addrspace(3)* %95, align 8, !tbaa !0
  %96 = or i32 %7, 15
  %97 = sext i32 %96 to i64
  %98 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %97
  %99 = load i32, i32 addrspace(1)* %98, align 4, !tbaa !0
  %100 = or i32 %4, 15
  %101 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %100
  store i32 %99, i32 addrspace(3)* %101, align 4, !tbaa !0
  %102 = or i32 %7, 16
  %103 = sext i32 %102 to i64
  %104 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %103
  %105 = load i32, i32 addrspace(1)* %104, align 4, !tbaa !0
  %106 = or i32 %4, 16
  %107 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %106
  store i32 %105, i32 addrspace(3)* %107, align 16, !tbaa !0
  %108 = or i32 %7, 17
  %109 = sext i32 %108 to i64
  %110 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %109
  %111 = load i32, i32 addrspace(1)* %110, align 4, !tbaa !0
  %112 = or i32 %4, 17
  %113 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %112
  store i32 %111, i32 addrspace(3)* %113, align 4, !tbaa !0
  %114 = or i32 %7, 18
  %115 = sext i32 %114 to i64
  %116 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %115
  %117 = load i32, i32 addrspace(1)* %116, align 4, !tbaa !0
  %118 = or i32 %4, 18
  %119 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %118
  store i32 %117, i32 addrspace(3)* %119, align 8, !tbaa !0
  %120 = or i32 %7, 19
  %121 = sext i32 %120 to i64
  %122 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %121
  %123 = load i32, i32 addrspace(1)* %122, align 4, !tbaa !0
  %124 = or i32 %4, 19
  %125 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %124
  store i32 %123, i32 addrspace(3)* %125, align 4, !tbaa !0
  %126 = or i32 %7, 20
  %127 = sext i32 %126 to i64
  %128 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %127
  %129 = load i32, i32 addrspace(1)* %128, align 4, !tbaa !0
  %130 = or i32 %4, 20
  %131 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %130
  store i32 %129, i32 addrspace(3)* %131, align 16, !tbaa !0
  %132 = or i32 %7, 21
  %133 = sext i32 %132 to i64
  %134 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %133
  %135 = load i32, i32 addrspace(1)* %134, align 4, !tbaa !0
  %136 = or i32 %4, 21
  %137 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %136
  store i32 %135, i32 addrspace(3)* %137, align 4, !tbaa !0
  %138 = or i32 %7, 22
  %139 = sext i32 %138 to i64
  %140 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %139
  %141 = load i32, i32 addrspace(1)* %140, align 4, !tbaa !0
  %142 = or i32 %4, 22
  %143 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %142
  store i32 %141, i32 addrspace(3)* %143, align 8, !tbaa !0
  %144 = or i32 %7, 23
  %145 = sext i32 %144 to i64
  %146 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %145
  %147 = load i32, i32 addrspace(1)* %146, align 4, !tbaa !0
  %148 = or i32 %4, 23
  %149 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %148
  store i32 %147, i32 addrspace(3)* %149, align 4, !tbaa !0
  %150 = or i32 %7, 24
  %151 = sext i32 %150 to i64
  %152 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %151
  %153 = load i32, i32 addrspace(1)* %152, align 4, !tbaa !0
  %154 = or i32 %4, 24
  %155 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %154
  store i32 %153, i32 addrspace(3)* %155, align 16, !tbaa !0
  %156 = or i32 %7, 25
  %157 = sext i32 %156 to i64
  %158 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %157
  %159 = load i32, i32 addrspace(1)* %158, align 4, !tbaa !0
  %160 = or i32 %4, 25
  %161 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %160
  store i32 %159, i32 addrspace(3)* %161, align 4, !tbaa !0
  %162 = or i32 %7, 26
  %163 = sext i32 %162 to i64
  %164 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %163
  %165 = load i32, i32 addrspace(1)* %164, align 4, !tbaa !0
  %166 = or i32 %4, 26
  %167 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %166
  store i32 %165, i32 addrspace(3)* %167, align 8, !tbaa !0
  %168 = or i32 %7, 27
  %169 = sext i32 %168 to i64
  %170 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %169
  %171 = load i32, i32 addrspace(1)* %170, align 4, !tbaa !0
  %172 = or i32 %4, 27
  %173 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %172
  store i32 %171, i32 addrspace(3)* %173, align 4, !tbaa !0
  %174 = or i32 %7, 28
  %175 = sext i32 %174 to i64
  %176 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %175
  %177 = load i32, i32 addrspace(1)* %176, align 4, !tbaa !0
  %178 = or i32 %4, 28
  %179 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %178
  store i32 %177, i32 addrspace(3)* %179, align 16, !tbaa !0
  %180 = or i32 %7, 29
  %181 = sext i32 %180 to i64
  %182 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %181
  %183 = load i32, i32 addrspace(1)* %182, align 4, !tbaa !0
  %184 = or i32 %4, 29
  %185 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %184
  store i32 %183, i32 addrspace(3)* %185, align 4, !tbaa !0
  %186 = or i32 %7, 30
  %187 = sext i32 %186 to i64
  %188 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %187
  %189 = load i32, i32 addrspace(1)* %188, align 4, !tbaa !0
  %190 = or i32 %4, 30
  %191 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %190
  store i32 %189, i32 addrspace(3)* %191, align 8, !tbaa !0
  %192 = or i32 %7, 31
  %193 = sext i32 %192 to i64
  %194 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %193
  %195 = load i32, i32 addrspace(1)* %194, align 4, !tbaa !0
  %196 = or i32 %4, 31
  %197 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %196
  store i32 %195, i32 addrspace(3)* %197, align 4, !tbaa !0
  %198 = or i32 %7, 32
  %199 = sext i32 %198 to i64
  %200 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %199
  %201 = load i32, i32 addrspace(1)* %200, align 4, !tbaa !0
  %202 = or i32 %4, 32
  %203 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %202
  store i32 %201, i32 addrspace(3)* %203, align 16, !tbaa !0
  %204 = or i32 %7, 33
  %205 = sext i32 %204 to i64
  %206 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %205
  %207 = load i32, i32 addrspace(1)* %206, align 4, !tbaa !0
  %208 = or i32 %4, 33
  %209 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %208
  store i32 %207, i32 addrspace(3)* %209, align 4, !tbaa !0
  %210 = or i32 %7, 34
  %211 = sext i32 %210 to i64
  %212 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %211
  %213 = load i32, i32 addrspace(1)* %212, align 4, !tbaa !0
  %214 = or i32 %4, 34
  %215 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %214
  store i32 %213, i32 addrspace(3)* %215, align 8, !tbaa !0
  %216 = or i32 %7, 35
  %217 = sext i32 %216 to i64
  %218 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %217
  %219 = load i32, i32 addrspace(1)* %218, align 4, !tbaa !0
  %220 = or i32 %4, 35
  %221 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %220
  store i32 %219, i32 addrspace(3)* %221, align 4, !tbaa !0
  %222 = or i32 %7, 36
  %223 = sext i32 %222 to i64
  %224 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %223
  %225 = load i32, i32 addrspace(1)* %224, align 4, !tbaa !0
  %226 = or i32 %4, 36
  %227 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %226
  store i32 %225, i32 addrspace(3)* %227, align 16, !tbaa !0
  %228 = or i32 %7, 37
  %229 = sext i32 %228 to i64
  %230 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %229
  %231 = load i32, i32 addrspace(1)* %230, align 4, !tbaa !0
  %232 = or i32 %4, 37
  %233 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %232
  store i32 %231, i32 addrspace(3)* %233, align 4, !tbaa !0
  %234 = or i32 %7, 38
  %235 = sext i32 %234 to i64
  %236 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %235
  %237 = load i32, i32 addrspace(1)* %236, align 4, !tbaa !0
  %238 = or i32 %4, 38
  %239 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %238
  store i32 %237, i32 addrspace(3)* %239, align 8, !tbaa !0
  %240 = or i32 %7, 39
  %241 = sext i32 %240 to i64
  %242 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %241
  %243 = load i32, i32 addrspace(1)* %242, align 4, !tbaa !0
  %244 = or i32 %4, 39
  %245 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %244
  store i32 %243, i32 addrspace(3)* %245, align 4, !tbaa !0
  %246 = or i32 %7, 40
  %247 = sext i32 %246 to i64
  %248 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %247
  %249 = load i32, i32 addrspace(1)* %248, align 4, !tbaa !0
  %250 = or i32 %4, 40
  %251 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %250
  store i32 %249, i32 addrspace(3)* %251, align 16, !tbaa !0
  %252 = or i32 %7, 41
  %253 = sext i32 %252 to i64
  %254 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %253
  %255 = load i32, i32 addrspace(1)* %254, align 4, !tbaa !0
  %256 = or i32 %4, 41
  %257 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %256
  store i32 %255, i32 addrspace(3)* %257, align 4, !tbaa !0
  %258 = or i32 %7, 42
  %259 = sext i32 %258 to i64
  %260 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %259
  %261 = load i32, i32 addrspace(1)* %260, align 4, !tbaa !0
  %262 = or i32 %4, 42
  %263 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %262
  store i32 %261, i32 addrspace(3)* %263, align 8, !tbaa !0
  %264 = or i32 %7, 43
  %265 = sext i32 %264 to i64
  %266 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %265
  %267 = load i32, i32 addrspace(1)* %266, align 4, !tbaa !0
  %268 = or i32 %4, 43
  %269 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %268
  store i32 %267, i32 addrspace(3)* %269, align 4, !tbaa !0
  %270 = or i32 %7, 44
  %271 = sext i32 %270 to i64
  %272 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %271
  %273 = load i32, i32 addrspace(1)* %272, align 4, !tbaa !0
  %274 = or i32 %4, 44
  %275 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %274
  store i32 %273, i32 addrspace(3)* %275, align 16, !tbaa !0
  %276 = or i32 %7, 45
  %277 = sext i32 %276 to i64
  %278 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %277
  %279 = load i32, i32 addrspace(1)* %278, align 4, !tbaa !0
  %280 = or i32 %4, 45
  %281 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %280
  store i32 %279, i32 addrspace(3)* %281, align 4, !tbaa !0
  %282 = or i32 %7, 46
  %283 = sext i32 %282 to i64
  %284 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %283
  %285 = load i32, i32 addrspace(1)* %284, align 4, !tbaa !0
  %286 = or i32 %4, 46
  %287 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %286
  store i32 %285, i32 addrspace(3)* %287, align 8, !tbaa !0
  %288 = or i32 %7, 47
  %289 = sext i32 %288 to i64
  %290 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %289
  %291 = load i32, i32 addrspace(1)* %290, align 4, !tbaa !0
  %292 = or i32 %4, 47
  %293 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %292
  store i32 %291, i32 addrspace(3)* %293, align 4, !tbaa !0
  %294 = or i32 %7, 48
  %295 = sext i32 %294 to i64
  %296 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %295
  %297 = load i32, i32 addrspace(1)* %296, align 4, !tbaa !0
  %298 = or i32 %4, 48
  %299 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %298
  store i32 %297, i32 addrspace(3)* %299, align 16, !tbaa !0
  %300 = or i32 %7, 49
  %301 = sext i32 %300 to i64
  %302 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %301
  %303 = load i32, i32 addrspace(1)* %302, align 4, !tbaa !0
  %304 = or i32 %4, 49
  %305 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %304
  store i32 %303, i32 addrspace(3)* %305, align 4, !tbaa !0
  %306 = or i32 %7, 50
  %307 = sext i32 %306 to i64
  %308 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %307
  %309 = load i32, i32 addrspace(1)* %308, align 4, !tbaa !0
  %310 = or i32 %4, 50
  %311 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %310
  store i32 %309, i32 addrspace(3)* %311, align 8, !tbaa !0
  %312 = or i32 %7, 51
  %313 = sext i32 %312 to i64
  %314 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %313
  %315 = load i32, i32 addrspace(1)* %314, align 4, !tbaa !0
  %316 = or i32 %4, 51
  %317 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %316
  store i32 %315, i32 addrspace(3)* %317, align 4, !tbaa !0
  %318 = or i32 %7, 52
  %319 = sext i32 %318 to i64
  %320 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %319
  %321 = load i32, i32 addrspace(1)* %320, align 4, !tbaa !0
  %322 = or i32 %4, 52
  %323 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %322
  store i32 %321, i32 addrspace(3)* %323, align 16, !tbaa !0
  %324 = or i32 %7, 53
  %325 = sext i32 %324 to i64
  %326 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %325
  %327 = load i32, i32 addrspace(1)* %326, align 4, !tbaa !0
  %328 = or i32 %4, 53
  %329 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %328
  store i32 %327, i32 addrspace(3)* %329, align 4, !tbaa !0
  %330 = or i32 %7, 54
  %331 = sext i32 %330 to i64
  %332 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %331
  %333 = load i32, i32 addrspace(1)* %332, align 4, !tbaa !0
  %334 = or i32 %4, 54
  %335 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %334
  store i32 %333, i32 addrspace(3)* %335, align 8, !tbaa !0
  %336 = or i32 %7, 55
  %337 = sext i32 %336 to i64
  %338 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %337
  %339 = load i32, i32 addrspace(1)* %338, align 4, !tbaa !0
  %340 = or i32 %4, 55
  %341 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %340
  store i32 %339, i32 addrspace(3)* %341, align 4, !tbaa !0
  %342 = or i32 %7, 56
  %343 = sext i32 %342 to i64
  %344 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %343
  %345 = load i32, i32 addrspace(1)* %344, align 4, !tbaa !0
  %346 = or i32 %4, 56
  %347 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %346
  store i32 %345, i32 addrspace(3)* %347, align 16, !tbaa !0
  %348 = or i32 %7, 57
  %349 = sext i32 %348 to i64
  %350 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %349
  %351 = load i32, i32 addrspace(1)* %350, align 4, !tbaa !0
  %352 = or i32 %4, 57
  %353 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %352
  store i32 %351, i32 addrspace(3)* %353, align 4, !tbaa !0
  %354 = or i32 %7, 58
  %355 = sext i32 %354 to i64
  %356 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %355
  %357 = load i32, i32 addrspace(1)* %356, align 4, !tbaa !0
  %358 = or i32 %4, 58
  %359 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %358
  store i32 %357, i32 addrspace(3)* %359, align 8, !tbaa !0
  %360 = or i32 %7, 59
  %361 = sext i32 %360 to i64
  %362 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %361
  %363 = load i32, i32 addrspace(1)* %362, align 4, !tbaa !0
  %364 = or i32 %4, 59
  %365 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %364
  store i32 %363, i32 addrspace(3)* %365, align 4, !tbaa !0
  %366 = or i32 %7, 60
  %367 = sext i32 %366 to i64
  %368 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %367
  %369 = load i32, i32 addrspace(1)* %368, align 4, !tbaa !0
  %370 = or i32 %4, 60
  %371 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %370
  store i32 %369, i32 addrspace(3)* %371, align 16, !tbaa !0
  %372 = or i32 %7, 61
  %373 = sext i32 %372 to i64
  %374 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %373
  %375 = load i32, i32 addrspace(1)* %374, align 4, !tbaa !0
  %376 = or i32 %4, 61
  %377 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %376
  store i32 %375, i32 addrspace(3)* %377, align 4, !tbaa !0
  %378 = or i32 %7, 62
  %379 = sext i32 %378 to i64
  %380 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %379
  %381 = load i32, i32 addrspace(1)* %380, align 4, !tbaa !0
  %382 = or i32 %4, 62
  %383 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %382
  store i32 %381, i32 addrspace(3)* %383, align 8, !tbaa !0
  %384 = or i32 %7, 63
  %385 = sext i32 %384 to i64
  %386 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %385
  %387 = load i32, i32 addrspace(1)* %386, align 4, !tbaa !0
  %388 = or i32 %4, 63
  %389 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %388
  store i32 %387, i32 addrspace(3)* %389, align 4, !tbaa !0
  br label %390

390:                                              ; preds = %6, %5
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
