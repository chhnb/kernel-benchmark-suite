; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i32 %1, i32 addrspace(3)* %2, i32 addrspace(1)* %3, i32 %4, [8192 x i32] addrspace(3)* %5, i32 addrspace(3)* %6) #0 {
  br i1 %0, label %8, label %389

8:                                                ; preds = %7
  %9 = shl nsw i32 %1, 6
  %10 = load i32, i32 addrspace(3)* %2, align 16, !tbaa !0
  %11 = sext i32 %9 to i64
  %12 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %11
  store i32 %10, i32 addrspace(1)* %12, align 4, !tbaa !0
  %13 = or i32 %4, 1
  %14 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %13
  %15 = load i32, i32 addrspace(3)* %14, align 4, !tbaa !0
  %16 = or i32 %9, 1
  %17 = sext i32 %16 to i64
  %18 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %17
  store i32 %15, i32 addrspace(1)* %18, align 4, !tbaa !0
  %19 = or i32 %4, 2
  %20 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %19
  %21 = load i32, i32 addrspace(3)* %20, align 8, !tbaa !0
  %22 = or i32 %9, 2
  %23 = sext i32 %22 to i64
  %24 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %23
  store i32 %21, i32 addrspace(1)* %24, align 4, !tbaa !0
  %25 = or i32 %4, 3
  %26 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %25
  %27 = load i32, i32 addrspace(3)* %26, align 4, !tbaa !0
  %28 = or i32 %9, 3
  %29 = sext i32 %28 to i64
  %30 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %29
  store i32 %27, i32 addrspace(1)* %30, align 4, !tbaa !0
  %31 = or i32 %4, 4
  %32 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %31
  %33 = load i32, i32 addrspace(3)* %32, align 16, !tbaa !0
  %34 = or i32 %9, 4
  %35 = sext i32 %34 to i64
  %36 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %35
  store i32 %33, i32 addrspace(1)* %36, align 4, !tbaa !0
  %37 = or i32 %4, 5
  %38 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %37
  %39 = load i32, i32 addrspace(3)* %38, align 4, !tbaa !0
  %40 = or i32 %9, 5
  %41 = sext i32 %40 to i64
  %42 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %41
  store i32 %39, i32 addrspace(1)* %42, align 4, !tbaa !0
  %43 = or i32 %4, 6
  %44 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %43
  %45 = load i32, i32 addrspace(3)* %44, align 8, !tbaa !0
  %46 = or i32 %9, 6
  %47 = sext i32 %46 to i64
  %48 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %47
  store i32 %45, i32 addrspace(1)* %48, align 4, !tbaa !0
  %49 = or i32 %4, 7
  %50 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %49
  %51 = load i32, i32 addrspace(3)* %50, align 4, !tbaa !0
  %52 = or i32 %9, 7
  %53 = sext i32 %52 to i64
  %54 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %53
  store i32 %51, i32 addrspace(1)* %54, align 4, !tbaa !0
  %55 = or i32 %4, 8
  %56 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %55
  %57 = load i32, i32 addrspace(3)* %56, align 16, !tbaa !0
  %58 = or i32 %9, 8
  %59 = sext i32 %58 to i64
  %60 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %59
  store i32 %57, i32 addrspace(1)* %60, align 4, !tbaa !0
  %61 = or i32 %4, 9
  %62 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %61
  %63 = load i32, i32 addrspace(3)* %62, align 4, !tbaa !0
  %64 = or i32 %9, 9
  %65 = sext i32 %64 to i64
  %66 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %65
  store i32 %63, i32 addrspace(1)* %66, align 4, !tbaa !0
  %67 = or i32 %4, 10
  %68 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %67
  %69 = load i32, i32 addrspace(3)* %68, align 8, !tbaa !0
  %70 = or i32 %9, 10
  %71 = sext i32 %70 to i64
  %72 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %71
  store i32 %69, i32 addrspace(1)* %72, align 4, !tbaa !0
  %73 = or i32 %4, 11
  %74 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %73
  %75 = load i32, i32 addrspace(3)* %74, align 4, !tbaa !0
  %76 = or i32 %9, 11
  %77 = sext i32 %76 to i64
  %78 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %77
  store i32 %75, i32 addrspace(1)* %78, align 4, !tbaa !0
  %79 = or i32 %4, 12
  %80 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %79
  %81 = load i32, i32 addrspace(3)* %80, align 16, !tbaa !0
  %82 = or i32 %9, 12
  %83 = sext i32 %82 to i64
  %84 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %83
  store i32 %81, i32 addrspace(1)* %84, align 4, !tbaa !0
  %85 = or i32 %4, 13
  %86 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %85
  %87 = load i32, i32 addrspace(3)* %86, align 4, !tbaa !0
  %88 = or i32 %9, 13
  %89 = sext i32 %88 to i64
  %90 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %89
  store i32 %87, i32 addrspace(1)* %90, align 4, !tbaa !0
  %91 = or i32 %4, 14
  %92 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %91
  %93 = load i32, i32 addrspace(3)* %92, align 8, !tbaa !0
  %94 = or i32 %9, 14
  %95 = sext i32 %94 to i64
  %96 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %95
  store i32 %93, i32 addrspace(1)* %96, align 4, !tbaa !0
  %97 = or i32 %4, 15
  %98 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %97
  %99 = load i32, i32 addrspace(3)* %98, align 4, !tbaa !0
  %100 = or i32 %9, 15
  %101 = sext i32 %100 to i64
  %102 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %101
  store i32 %99, i32 addrspace(1)* %102, align 4, !tbaa !0
  %103 = or i32 %4, 16
  %104 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %103
  %105 = load i32, i32 addrspace(3)* %104, align 16, !tbaa !0
  %106 = or i32 %9, 16
  %107 = sext i32 %106 to i64
  %108 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %107
  store i32 %105, i32 addrspace(1)* %108, align 4, !tbaa !0
  %109 = or i32 %4, 17
  %110 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %109
  %111 = load i32, i32 addrspace(3)* %110, align 4, !tbaa !0
  %112 = or i32 %9, 17
  %113 = sext i32 %112 to i64
  %114 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %113
  store i32 %111, i32 addrspace(1)* %114, align 4, !tbaa !0
  %115 = or i32 %4, 18
  %116 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %115
  %117 = load i32, i32 addrspace(3)* %116, align 8, !tbaa !0
  %118 = or i32 %9, 18
  %119 = sext i32 %118 to i64
  %120 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %119
  store i32 %117, i32 addrspace(1)* %120, align 4, !tbaa !0
  %121 = or i32 %4, 19
  %122 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %121
  %123 = load i32, i32 addrspace(3)* %122, align 4, !tbaa !0
  %124 = or i32 %9, 19
  %125 = sext i32 %124 to i64
  %126 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %125
  store i32 %123, i32 addrspace(1)* %126, align 4, !tbaa !0
  %127 = or i32 %4, 20
  %128 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %127
  %129 = load i32, i32 addrspace(3)* %128, align 16, !tbaa !0
  %130 = or i32 %9, 20
  %131 = sext i32 %130 to i64
  %132 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %131
  store i32 %129, i32 addrspace(1)* %132, align 4, !tbaa !0
  %133 = or i32 %4, 21
  %134 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %133
  %135 = load i32, i32 addrspace(3)* %134, align 4, !tbaa !0
  %136 = or i32 %9, 21
  %137 = sext i32 %136 to i64
  %138 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %137
  store i32 %135, i32 addrspace(1)* %138, align 4, !tbaa !0
  %139 = or i32 %4, 22
  %140 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %139
  %141 = load i32, i32 addrspace(3)* %140, align 8, !tbaa !0
  %142 = or i32 %9, 22
  %143 = sext i32 %142 to i64
  %144 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %143
  store i32 %141, i32 addrspace(1)* %144, align 4, !tbaa !0
  %145 = or i32 %4, 23
  %146 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %145
  %147 = load i32, i32 addrspace(3)* %146, align 4, !tbaa !0
  %148 = or i32 %9, 23
  %149 = sext i32 %148 to i64
  %150 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %149
  store i32 %147, i32 addrspace(1)* %150, align 4, !tbaa !0
  %151 = or i32 %4, 24
  %152 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %151
  %153 = load i32, i32 addrspace(3)* %152, align 16, !tbaa !0
  %154 = or i32 %9, 24
  %155 = sext i32 %154 to i64
  %156 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %155
  store i32 %153, i32 addrspace(1)* %156, align 4, !tbaa !0
  %157 = or i32 %4, 25
  %158 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %157
  %159 = load i32, i32 addrspace(3)* %158, align 4, !tbaa !0
  %160 = or i32 %9, 25
  %161 = sext i32 %160 to i64
  %162 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %161
  store i32 %159, i32 addrspace(1)* %162, align 4, !tbaa !0
  %163 = or i32 %4, 26
  %164 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %163
  %165 = load i32, i32 addrspace(3)* %164, align 8, !tbaa !0
  %166 = or i32 %9, 26
  %167 = sext i32 %166 to i64
  %168 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %167
  store i32 %165, i32 addrspace(1)* %168, align 4, !tbaa !0
  %169 = or i32 %4, 27
  %170 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %169
  %171 = load i32, i32 addrspace(3)* %170, align 4, !tbaa !0
  %172 = or i32 %9, 27
  %173 = sext i32 %172 to i64
  %174 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %173
  store i32 %171, i32 addrspace(1)* %174, align 4, !tbaa !0
  %175 = or i32 %4, 28
  %176 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %175
  %177 = load i32, i32 addrspace(3)* %176, align 16, !tbaa !0
  %178 = or i32 %9, 28
  %179 = sext i32 %178 to i64
  %180 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %179
  store i32 %177, i32 addrspace(1)* %180, align 4, !tbaa !0
  %181 = or i32 %4, 29
  %182 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %181
  %183 = load i32, i32 addrspace(3)* %182, align 4, !tbaa !0
  %184 = or i32 %9, 29
  %185 = sext i32 %184 to i64
  %186 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %185
  store i32 %183, i32 addrspace(1)* %186, align 4, !tbaa !0
  %187 = or i32 %4, 30
  %188 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %187
  %189 = load i32, i32 addrspace(3)* %188, align 8, !tbaa !0
  %190 = or i32 %9, 30
  %191 = sext i32 %190 to i64
  %192 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %191
  store i32 %189, i32 addrspace(1)* %192, align 4, !tbaa !0
  %193 = or i32 %4, 31
  %194 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %193
  %195 = load i32, i32 addrspace(3)* %194, align 4, !tbaa !0
  %196 = or i32 %9, 31
  %197 = sext i32 %196 to i64
  %198 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %197
  store i32 %195, i32 addrspace(1)* %198, align 4, !tbaa !0
  %199 = or i32 %4, 32
  %200 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %199
  %201 = load i32, i32 addrspace(3)* %200, align 16, !tbaa !0
  %202 = or i32 %9, 32
  %203 = sext i32 %202 to i64
  %204 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %203
  store i32 %201, i32 addrspace(1)* %204, align 4, !tbaa !0
  %205 = or i32 %4, 33
  %206 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %205
  %207 = load i32, i32 addrspace(3)* %206, align 4, !tbaa !0
  %208 = or i32 %9, 33
  %209 = sext i32 %208 to i64
  %210 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %209
  store i32 %207, i32 addrspace(1)* %210, align 4, !tbaa !0
  %211 = or i32 %4, 34
  %212 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %211
  %213 = load i32, i32 addrspace(3)* %212, align 8, !tbaa !0
  %214 = or i32 %9, 34
  %215 = sext i32 %214 to i64
  %216 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %215
  store i32 %213, i32 addrspace(1)* %216, align 4, !tbaa !0
  %217 = or i32 %4, 35
  %218 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %217
  %219 = load i32, i32 addrspace(3)* %218, align 4, !tbaa !0
  %220 = or i32 %9, 35
  %221 = sext i32 %220 to i64
  %222 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %221
  store i32 %219, i32 addrspace(1)* %222, align 4, !tbaa !0
  %223 = or i32 %4, 36
  %224 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %223
  %225 = load i32, i32 addrspace(3)* %224, align 16, !tbaa !0
  %226 = or i32 %9, 36
  %227 = sext i32 %226 to i64
  %228 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %227
  store i32 %225, i32 addrspace(1)* %228, align 4, !tbaa !0
  %229 = or i32 %4, 37
  %230 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %229
  %231 = load i32, i32 addrspace(3)* %230, align 4, !tbaa !0
  %232 = or i32 %9, 37
  %233 = sext i32 %232 to i64
  %234 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %233
  store i32 %231, i32 addrspace(1)* %234, align 4, !tbaa !0
  %235 = or i32 %4, 38
  %236 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %235
  %237 = load i32, i32 addrspace(3)* %236, align 8, !tbaa !0
  %238 = or i32 %9, 38
  %239 = sext i32 %238 to i64
  %240 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %239
  store i32 %237, i32 addrspace(1)* %240, align 4, !tbaa !0
  %241 = or i32 %4, 39
  %242 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %241
  %243 = load i32, i32 addrspace(3)* %242, align 4, !tbaa !0
  %244 = or i32 %9, 39
  %245 = sext i32 %244 to i64
  %246 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %245
  store i32 %243, i32 addrspace(1)* %246, align 4, !tbaa !0
  %247 = or i32 %4, 40
  %248 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %247
  %249 = load i32, i32 addrspace(3)* %248, align 16, !tbaa !0
  %250 = or i32 %9, 40
  %251 = sext i32 %250 to i64
  %252 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %251
  store i32 %249, i32 addrspace(1)* %252, align 4, !tbaa !0
  %253 = or i32 %4, 41
  %254 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %253
  %255 = load i32, i32 addrspace(3)* %254, align 4, !tbaa !0
  %256 = or i32 %9, 41
  %257 = sext i32 %256 to i64
  %258 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %257
  store i32 %255, i32 addrspace(1)* %258, align 4, !tbaa !0
  %259 = or i32 %4, 42
  %260 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %259
  %261 = load i32, i32 addrspace(3)* %260, align 8, !tbaa !0
  %262 = or i32 %9, 42
  %263 = sext i32 %262 to i64
  %264 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %263
  store i32 %261, i32 addrspace(1)* %264, align 4, !tbaa !0
  %265 = or i32 %4, 43
  %266 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %265
  %267 = load i32, i32 addrspace(3)* %266, align 4, !tbaa !0
  %268 = or i32 %9, 43
  %269 = sext i32 %268 to i64
  %270 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %269
  store i32 %267, i32 addrspace(1)* %270, align 4, !tbaa !0
  %271 = or i32 %4, 44
  %272 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %271
  %273 = load i32, i32 addrspace(3)* %272, align 16, !tbaa !0
  %274 = or i32 %9, 44
  %275 = sext i32 %274 to i64
  %276 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %275
  store i32 %273, i32 addrspace(1)* %276, align 4, !tbaa !0
  %277 = or i32 %4, 45
  %278 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %277
  %279 = load i32, i32 addrspace(3)* %278, align 4, !tbaa !0
  %280 = or i32 %9, 45
  %281 = sext i32 %280 to i64
  %282 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %281
  store i32 %279, i32 addrspace(1)* %282, align 4, !tbaa !0
  %283 = or i32 %4, 46
  %284 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %283
  %285 = load i32, i32 addrspace(3)* %284, align 8, !tbaa !0
  %286 = or i32 %9, 46
  %287 = sext i32 %286 to i64
  %288 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %287
  store i32 %285, i32 addrspace(1)* %288, align 4, !tbaa !0
  %289 = or i32 %4, 47
  %290 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %289
  %291 = load i32, i32 addrspace(3)* %290, align 4, !tbaa !0
  %292 = or i32 %9, 47
  %293 = sext i32 %292 to i64
  %294 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %293
  store i32 %291, i32 addrspace(1)* %294, align 4, !tbaa !0
  %295 = or i32 %4, 48
  %296 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %295
  %297 = load i32, i32 addrspace(3)* %296, align 16, !tbaa !0
  %298 = or i32 %9, 48
  %299 = sext i32 %298 to i64
  %300 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %299
  store i32 %297, i32 addrspace(1)* %300, align 4, !tbaa !0
  %301 = or i32 %4, 49
  %302 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %301
  %303 = load i32, i32 addrspace(3)* %302, align 4, !tbaa !0
  %304 = or i32 %9, 49
  %305 = sext i32 %304 to i64
  %306 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %305
  store i32 %303, i32 addrspace(1)* %306, align 4, !tbaa !0
  %307 = or i32 %4, 50
  %308 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %307
  %309 = load i32, i32 addrspace(3)* %308, align 8, !tbaa !0
  %310 = or i32 %9, 50
  %311 = sext i32 %310 to i64
  %312 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %311
  store i32 %309, i32 addrspace(1)* %312, align 4, !tbaa !0
  %313 = or i32 %4, 51
  %314 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %313
  %315 = load i32, i32 addrspace(3)* %314, align 4, !tbaa !0
  %316 = or i32 %9, 51
  %317 = sext i32 %316 to i64
  %318 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %317
  store i32 %315, i32 addrspace(1)* %318, align 4, !tbaa !0
  %319 = or i32 %4, 52
  %320 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %319
  %321 = load i32, i32 addrspace(3)* %320, align 16, !tbaa !0
  %322 = or i32 %9, 52
  %323 = sext i32 %322 to i64
  %324 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %323
  store i32 %321, i32 addrspace(1)* %324, align 4, !tbaa !0
  %325 = or i32 %4, 53
  %326 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %325
  %327 = load i32, i32 addrspace(3)* %326, align 4, !tbaa !0
  %328 = or i32 %9, 53
  %329 = sext i32 %328 to i64
  %330 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %329
  store i32 %327, i32 addrspace(1)* %330, align 4, !tbaa !0
  %331 = or i32 %4, 54
  %332 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %331
  %333 = load i32, i32 addrspace(3)* %332, align 8, !tbaa !0
  %334 = or i32 %9, 54
  %335 = sext i32 %334 to i64
  %336 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %335
  store i32 %333, i32 addrspace(1)* %336, align 4, !tbaa !0
  %337 = or i32 %4, 55
  %338 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %337
  %339 = load i32, i32 addrspace(3)* %338, align 4, !tbaa !0
  %340 = or i32 %9, 55
  %341 = sext i32 %340 to i64
  %342 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %341
  store i32 %339, i32 addrspace(1)* %342, align 4, !tbaa !0
  %343 = or i32 %4, 56
  %344 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %343
  %345 = load i32, i32 addrspace(3)* %344, align 16, !tbaa !0
  %346 = or i32 %9, 56
  %347 = sext i32 %346 to i64
  %348 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %347
  store i32 %345, i32 addrspace(1)* %348, align 4, !tbaa !0
  %349 = or i32 %4, 57
  %350 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %349
  %351 = load i32, i32 addrspace(3)* %350, align 4, !tbaa !0
  %352 = or i32 %9, 57
  %353 = sext i32 %352 to i64
  %354 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %353
  store i32 %351, i32 addrspace(1)* %354, align 4, !tbaa !0
  %355 = or i32 %4, 58
  %356 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %355
  %357 = load i32, i32 addrspace(3)* %356, align 8, !tbaa !0
  %358 = or i32 %9, 58
  %359 = sext i32 %358 to i64
  %360 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %359
  store i32 %357, i32 addrspace(1)* %360, align 4, !tbaa !0
  %361 = or i32 %4, 59
  %362 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %361
  %363 = load i32, i32 addrspace(3)* %362, align 4, !tbaa !0
  %364 = or i32 %9, 59
  %365 = sext i32 %364 to i64
  %366 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %365
  store i32 %363, i32 addrspace(1)* %366, align 4, !tbaa !0
  %367 = or i32 %4, 60
  %368 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %367
  %369 = load i32, i32 addrspace(3)* %368, align 16, !tbaa !0
  %370 = or i32 %9, 60
  %371 = sext i32 %370 to i64
  %372 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %371
  store i32 %369, i32 addrspace(1)* %372, align 4, !tbaa !0
  %373 = or i32 %4, 61
  %374 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %373
  %375 = load i32, i32 addrspace(3)* %374, align 4, !tbaa !0
  %376 = or i32 %9, 61
  %377 = sext i32 %376 to i64
  %378 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %377
  store i32 %375, i32 addrspace(1)* %378, align 4, !tbaa !0
  %379 = or i32 %4, 62
  %380 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %5, i32 0, i32 %379
  %381 = load i32, i32 addrspace(3)* %380, align 8, !tbaa !0
  %382 = or i32 %9, 62
  %383 = sext i32 %382 to i64
  %384 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %383
  store i32 %381, i32 addrspace(1)* %384, align 4, !tbaa !0
  %385 = load i32, i32 addrspace(3)* %6, align 4, !tbaa !0
  %386 = or i32 %9, 63
  %387 = sext i32 %386 to i64
  %388 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %387
  store i32 %385, i32 addrspace(1)* %388, align 4, !tbaa !0
  br label %389

389:                                              ; preds = %8, %7
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
