; ModuleID = 'llvm-link'
source_filename = "llvm-link"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

%0 = type { %1 addrspace(1)*, %2 addrspace(1)*, %3, i64, i64, i64 }
%1 = type { i64, i64, i32, i32 }
%2 = type { [64 x [8 x i64]] }
%3 = type { i64 }
%4 = type { i64, %3, i64, i32, i32, i64, i64, %5, [2 x i32] }
%5 = type { %6 addrspace(1)* }
%6 = type { %7, [4 x i32], i64, i32, i32, i32, i32, i64, i32, [9 x i32], i64, i32, i32, [4 x i32], i64, i64, i32, i32, [2 x i32], %3, [14 x i32] }
%7 = type { i32, i32, i8 addrspace(1)*, %3, i32, i32, i64 }

@.str = private unnamed_addr addrspace(4) constant [47 x i8] c"%s:%u: %s: Device-side assertion `%s' failed.\0A\00", align 1

; Function Attrs: convergent noinline nounwind
define weak hidden void @__assert_fail(i8* %__assertion, i8* %__file, i32 %__line, i8* %__function) local_unnamed_addr #0 {
entry:
  %0 = tail call i8 addrspace(4)* @llvm.amdgcn.implicitarg.ptr() #12
  %1 = getelementptr inbounds i8, i8 addrspace(4)* %0, i64 24
  %2 = bitcast i8 addrspace(4)* %1 to i8* addrspace(4)*
  %3 = load i8*, i8* addrspace(4)* %2, align 8, !tbaa !5
  %4 = tail call fastcc <2 x i64> @__ockl_hostcall_internal(i8* %3, i64 33, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0) #18
  %5 = extractelement <2 x i64> %4, i64 0
  br i1 icmp eq (i8* addrspacecast (i8 addrspace(4)* getelementptr inbounds ([47 x i8], [47 x i8] addrspace(4)* @.str, i64 0, i64 0) to i8*), i8* null), label %6, label %10

6:                                                ; preds = %entry
  %7 = and i64 %5, -225
  %8 = or i64 %7, 32
  %9 = tail call fastcc <2 x i64> @__ockl_hostcall_internal(i8* %3, i64 %8, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0) #18
  br label %__ockl_printf_append_string_n.exit

10:                                               ; preds = %entry
  %11 = and i64 %5, 2
  %12 = and i64 %5, -3
  %13 = insertelement <2 x i64> <i64 undef, i64 0>, i64 %12, i64 0
  br label %14

14:                                               ; preds = %.loopexit41, %10
  %15 = phi i64 [ select (i1 icmp eq (i8* addrspacecast (i8 addrspace(4)* getelementptr inbounds ([47 x i8], [47 x i8] addrspace(4)* @.str, i64 0, i64 0) to i8*), i8* null), i64 0, i64 add (i64 ptrtoint (i8* addrspacecast (i8 addrspace(4)* getelementptr inbounds ([47 x i8], [47 x i8] addrspace(4)* @.str, i64 0, i64 46) to i8*) to i64), i64 add (i64 sub (i64 0, i64 ptrtoint ([47 x i8]* addrspacecast ([47 x i8] addrspace(4)* @.str to [47 x i8]*) to i64)), i64 1))), %10 ], [ %430, %.loopexit41 ]
  %16 = phi i8 addrspace(4)* [ getelementptr inbounds ([47 x i8], [47 x i8] addrspace(4)* @.str, i64 0, i64 0), %10 ], [ %431, %.loopexit41 ]
  %17 = phi <2 x i64> [ %13, %10 ], [ %429, %.loopexit41 ]
  %18 = icmp ugt i64 %15, 56
  %19 = extractelement <2 x i64> %17, i64 0
  %20 = or i64 %19, %11
  %21 = insertelement <2 x i64> undef, i64 %20, i64 0
  %22 = select i1 %18, <2 x i64> %17, <2 x i64> %21
  %23 = icmp ult i64 %15, 56
  %24 = select i1 %23, i64 %15, i64 56
  %25 = trunc i64 %24 to i32
  %26 = extractelement <2 x i64> %22, i64 0
  %27 = add nuw nsw i64 %24, 7
  %28 = lshr i64 %27, 3
  %29 = and i64 %26, -225
  %30 = shl nuw nsw i64 %28, 5
  %31 = or i64 %29, %30
  %32 = icmp ugt i32 %25, 7
  br i1 %32, label %48, label %33

33:                                               ; preds = %14
  %34 = icmp eq i32 %25, 0
  br i1 %34, label %.loopexit41, label %.preheader52

.preheader52:                                     ; preds = %.preheader52, %33
  %35 = phi i32 [ %46, %.preheader52 ], [ 0, %33 ]
  %36 = phi i64 [ %45, %.preheader52 ], [ 0, %33 ]
  %37 = zext i32 %35 to i64
  %38 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 %37
  %39 = load i8, i8 addrspace(4)* %38, align 1, !tbaa !9
  %40 = zext i8 %39 to i64
  %41 = shl i32 %35, 3
  %42 = and i32 %41, 56
  %43 = zext i32 %42 to i64
  %44 = shl nuw i64 %40, %43
  %45 = or i64 %44, %36
  %46 = add nuw nsw i32 %35, 1
  %47 = icmp eq i32 %46, %25
  br i1 %47, label %.loopexit41, label %.preheader52

48:                                               ; preds = %14
  %49 = load i8, i8 addrspace(4)* %16, align 1, !tbaa !9
  %50 = zext i8 %49 to i64
  %51 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 1
  %52 = load i8, i8 addrspace(4)* %51, align 1, !tbaa !9
  %53 = zext i8 %52 to i64
  %54 = shl nuw nsw i64 %53, 8
  %55 = or i64 %54, %50
  %56 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 2
  %57 = load i8, i8 addrspace(4)* %56, align 1, !tbaa !9
  %58 = zext i8 %57 to i64
  %59 = shl nuw nsw i64 %58, 16
  %60 = or i64 %55, %59
  %61 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 3
  %62 = load i8, i8 addrspace(4)* %61, align 1, !tbaa !9
  %63 = zext i8 %62 to i64
  %64 = shl nuw nsw i64 %63, 24
  %65 = or i64 %60, %64
  %66 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 4
  %67 = load i8, i8 addrspace(4)* %66, align 1, !tbaa !9
  %68 = zext i8 %67 to i64
  %69 = shl nuw nsw i64 %68, 32
  %70 = or i64 %65, %69
  %71 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 5
  %72 = load i8, i8 addrspace(4)* %71, align 1, !tbaa !9
  %73 = zext i8 %72 to i64
  %74 = shl nuw nsw i64 %73, 40
  %75 = or i64 %70, %74
  %76 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 6
  %77 = load i8, i8 addrspace(4)* %76, align 1, !tbaa !9
  %78 = zext i8 %77 to i64
  %79 = shl nuw nsw i64 %78, 48
  %80 = or i64 %75, %79
  %81 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 7
  %82 = load i8, i8 addrspace(4)* %81, align 1, !tbaa !9
  %83 = zext i8 %82 to i64
  %84 = shl nuw i64 %83, 56
  %85 = or i64 %80, %84
  %86 = add nsw i32 %25, -8
  %87 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 8
  %88 = icmp ugt i32 %86, 7
  br i1 %88, label %104, label %89

89:                                               ; preds = %48
  %90 = icmp eq i32 %86, 0
  br i1 %90, label %.loopexit41, label %.preheader50

.preheader50:                                     ; preds = %.preheader50, %89
  %91 = phi i32 [ %102, %.preheader50 ], [ 0, %89 ]
  %92 = phi i64 [ %101, %.preheader50 ], [ 0, %89 ]
  %93 = zext i32 %91 to i64
  %94 = getelementptr inbounds i8, i8 addrspace(4)* %87, i64 %93
  %95 = load i8, i8 addrspace(4)* %94, align 1, !tbaa !9
  %96 = zext i8 %95 to i64
  %97 = shl i32 %91, 3
  %98 = and i32 %97, 56
  %99 = zext i32 %98 to i64
  %100 = shl nuw i64 %96, %99
  %101 = or i64 %100, %92
  %102 = add nuw i32 %91, 1
  %103 = icmp eq i32 %102, %86
  br i1 %103, label %.loopexit41, label %.preheader50

104:                                              ; preds = %48
  %105 = load i8, i8 addrspace(4)* %87, align 1, !tbaa !9
  %106 = zext i8 %105 to i64
  %107 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 9
  %108 = load i8, i8 addrspace(4)* %107, align 1, !tbaa !9
  %109 = zext i8 %108 to i64
  %110 = shl nuw nsw i64 %109, 8
  %111 = or i64 %110, %106
  %112 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 10
  %113 = load i8, i8 addrspace(4)* %112, align 1, !tbaa !9
  %114 = zext i8 %113 to i64
  %115 = shl nuw nsw i64 %114, 16
  %116 = or i64 %111, %115
  %117 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 11
  %118 = load i8, i8 addrspace(4)* %117, align 1, !tbaa !9
  %119 = zext i8 %118 to i64
  %120 = shl nuw nsw i64 %119, 24
  %121 = or i64 %116, %120
  %122 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 12
  %123 = load i8, i8 addrspace(4)* %122, align 1, !tbaa !9
  %124 = zext i8 %123 to i64
  %125 = shl nuw nsw i64 %124, 32
  %126 = or i64 %121, %125
  %127 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 13
  %128 = load i8, i8 addrspace(4)* %127, align 1, !tbaa !9
  %129 = zext i8 %128 to i64
  %130 = shl nuw nsw i64 %129, 40
  %131 = or i64 %126, %130
  %132 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 14
  %133 = load i8, i8 addrspace(4)* %132, align 1, !tbaa !9
  %134 = zext i8 %133 to i64
  %135 = shl nuw nsw i64 %134, 48
  %136 = or i64 %131, %135
  %137 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 15
  %138 = load i8, i8 addrspace(4)* %137, align 1, !tbaa !9
  %139 = zext i8 %138 to i64
  %140 = shl nuw i64 %139, 56
  %141 = or i64 %136, %140
  %142 = add nsw i32 %25, -16
  %143 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 16
  %144 = icmp ugt i32 %142, 7
  br i1 %144, label %160, label %145

145:                                              ; preds = %104
  %146 = icmp eq i32 %142, 0
  br i1 %146, label %.loopexit41, label %.preheader48

.preheader48:                                     ; preds = %.preheader48, %145
  %147 = phi i32 [ %158, %.preheader48 ], [ 0, %145 ]
  %148 = phi i64 [ %157, %.preheader48 ], [ 0, %145 ]
  %149 = zext i32 %147 to i64
  %150 = getelementptr inbounds i8, i8 addrspace(4)* %143, i64 %149
  %151 = load i8, i8 addrspace(4)* %150, align 1, !tbaa !9
  %152 = zext i8 %151 to i64
  %153 = shl i32 %147, 3
  %154 = and i32 %153, 56
  %155 = zext i32 %154 to i64
  %156 = shl nuw i64 %152, %155
  %157 = or i64 %156, %148
  %158 = add nuw i32 %147, 1
  %159 = icmp eq i32 %158, %142
  br i1 %159, label %.loopexit41, label %.preheader48

160:                                              ; preds = %104
  %161 = load i8, i8 addrspace(4)* %143, align 1, !tbaa !9
  %162 = zext i8 %161 to i64
  %163 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 17
  %164 = load i8, i8 addrspace(4)* %163, align 1, !tbaa !9
  %165 = zext i8 %164 to i64
  %166 = shl nuw nsw i64 %165, 8
  %167 = or i64 %166, %162
  %168 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 18
  %169 = load i8, i8 addrspace(4)* %168, align 1, !tbaa !9
  %170 = zext i8 %169 to i64
  %171 = shl nuw nsw i64 %170, 16
  %172 = or i64 %167, %171
  %173 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 19
  %174 = load i8, i8 addrspace(4)* %173, align 1, !tbaa !9
  %175 = zext i8 %174 to i64
  %176 = shl nuw nsw i64 %175, 24
  %177 = or i64 %172, %176
  %178 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 20
  %179 = load i8, i8 addrspace(4)* %178, align 1, !tbaa !9
  %180 = zext i8 %179 to i64
  %181 = shl nuw nsw i64 %180, 32
  %182 = or i64 %177, %181
  %183 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 21
  %184 = load i8, i8 addrspace(4)* %183, align 1, !tbaa !9
  %185 = zext i8 %184 to i64
  %186 = shl nuw nsw i64 %185, 40
  %187 = or i64 %182, %186
  %188 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 22
  %189 = load i8, i8 addrspace(4)* %188, align 1, !tbaa !9
  %190 = zext i8 %189 to i64
  %191 = shl nuw nsw i64 %190, 48
  %192 = or i64 %187, %191
  %193 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 23
  %194 = load i8, i8 addrspace(4)* %193, align 1, !tbaa !9
  %195 = zext i8 %194 to i64
  %196 = shl nuw i64 %195, 56
  %197 = or i64 %192, %196
  %198 = add nsw i32 %25, -24
  %199 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 24
  %200 = icmp ugt i32 %198, 7
  br i1 %200, label %216, label %201

201:                                              ; preds = %160
  %202 = icmp eq i32 %198, 0
  br i1 %202, label %.loopexit41, label %.preheader46

.preheader46:                                     ; preds = %.preheader46, %201
  %203 = phi i32 [ %214, %.preheader46 ], [ 0, %201 ]
  %204 = phi i64 [ %213, %.preheader46 ], [ 0, %201 ]
  %205 = zext i32 %203 to i64
  %206 = getelementptr inbounds i8, i8 addrspace(4)* %199, i64 %205
  %207 = load i8, i8 addrspace(4)* %206, align 1, !tbaa !9
  %208 = zext i8 %207 to i64
  %209 = shl i32 %203, 3
  %210 = and i32 %209, 56
  %211 = zext i32 %210 to i64
  %212 = shl nuw i64 %208, %211
  %213 = or i64 %212, %204
  %214 = add nuw i32 %203, 1
  %215 = icmp eq i32 %214, %198
  br i1 %215, label %.loopexit41, label %.preheader46

216:                                              ; preds = %160
  %217 = load i8, i8 addrspace(4)* %199, align 1, !tbaa !9
  %218 = zext i8 %217 to i64
  %219 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 25
  %220 = load i8, i8 addrspace(4)* %219, align 1, !tbaa !9
  %221 = zext i8 %220 to i64
  %222 = shl nuw nsw i64 %221, 8
  %223 = or i64 %222, %218
  %224 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 26
  %225 = load i8, i8 addrspace(4)* %224, align 1, !tbaa !9
  %226 = zext i8 %225 to i64
  %227 = shl nuw nsw i64 %226, 16
  %228 = or i64 %223, %227
  %229 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 27
  %230 = load i8, i8 addrspace(4)* %229, align 1, !tbaa !9
  %231 = zext i8 %230 to i64
  %232 = shl nuw nsw i64 %231, 24
  %233 = or i64 %228, %232
  %234 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 28
  %235 = load i8, i8 addrspace(4)* %234, align 1, !tbaa !9
  %236 = zext i8 %235 to i64
  %237 = shl nuw nsw i64 %236, 32
  %238 = or i64 %233, %237
  %239 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 29
  %240 = load i8, i8 addrspace(4)* %239, align 1, !tbaa !9
  %241 = zext i8 %240 to i64
  %242 = shl nuw nsw i64 %241, 40
  %243 = or i64 %238, %242
  %244 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 30
  %245 = load i8, i8 addrspace(4)* %244, align 1, !tbaa !9
  %246 = zext i8 %245 to i64
  %247 = shl nuw nsw i64 %246, 48
  %248 = or i64 %243, %247
  %249 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 31
  %250 = load i8, i8 addrspace(4)* %249, align 1, !tbaa !9
  %251 = zext i8 %250 to i64
  %252 = shl nuw i64 %251, 56
  %253 = or i64 %248, %252
  %254 = add nsw i32 %25, -32
  %255 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 32
  %256 = icmp ugt i32 %254, 7
  br i1 %256, label %272, label %257

257:                                              ; preds = %216
  %258 = icmp eq i32 %254, 0
  br i1 %258, label %.loopexit41, label %.preheader44

.preheader44:                                     ; preds = %.preheader44, %257
  %259 = phi i32 [ %270, %.preheader44 ], [ 0, %257 ]
  %260 = phi i64 [ %269, %.preheader44 ], [ 0, %257 ]
  %261 = zext i32 %259 to i64
  %262 = getelementptr inbounds i8, i8 addrspace(4)* %255, i64 %261
  %263 = load i8, i8 addrspace(4)* %262, align 1, !tbaa !9
  %264 = zext i8 %263 to i64
  %265 = shl i32 %259, 3
  %266 = and i32 %265, 56
  %267 = zext i32 %266 to i64
  %268 = shl nuw i64 %264, %267
  %269 = or i64 %268, %260
  %270 = add nuw i32 %259, 1
  %271 = icmp eq i32 %270, %254
  br i1 %271, label %.loopexit41, label %.preheader44

272:                                              ; preds = %216
  %273 = load i8, i8 addrspace(4)* %255, align 1, !tbaa !9
  %274 = zext i8 %273 to i64
  %275 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 33
  %276 = load i8, i8 addrspace(4)* %275, align 1, !tbaa !9
  %277 = zext i8 %276 to i64
  %278 = shl nuw nsw i64 %277, 8
  %279 = or i64 %278, %274
  %280 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 34
  %281 = load i8, i8 addrspace(4)* %280, align 1, !tbaa !9
  %282 = zext i8 %281 to i64
  %283 = shl nuw nsw i64 %282, 16
  %284 = or i64 %279, %283
  %285 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 35
  %286 = load i8, i8 addrspace(4)* %285, align 1, !tbaa !9
  %287 = zext i8 %286 to i64
  %288 = shl nuw nsw i64 %287, 24
  %289 = or i64 %284, %288
  %290 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 36
  %291 = load i8, i8 addrspace(4)* %290, align 1, !tbaa !9
  %292 = zext i8 %291 to i64
  %293 = shl nuw nsw i64 %292, 32
  %294 = or i64 %289, %293
  %295 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 37
  %296 = load i8, i8 addrspace(4)* %295, align 1, !tbaa !9
  %297 = zext i8 %296 to i64
  %298 = shl nuw nsw i64 %297, 40
  %299 = or i64 %294, %298
  %300 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 38
  %301 = load i8, i8 addrspace(4)* %300, align 1, !tbaa !9
  %302 = zext i8 %301 to i64
  %303 = shl nuw nsw i64 %302, 48
  %304 = or i64 %299, %303
  %305 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 39
  %306 = load i8, i8 addrspace(4)* %305, align 1, !tbaa !9
  %307 = zext i8 %306 to i64
  %308 = shl nuw i64 %307, 56
  %309 = or i64 %304, %308
  %310 = add nsw i32 %25, -40
  %311 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 40
  %312 = icmp ugt i32 %310, 7
  br i1 %312, label %328, label %313

313:                                              ; preds = %272
  %314 = icmp eq i32 %310, 0
  br i1 %314, label %.loopexit41, label %.preheader42

.preheader42:                                     ; preds = %.preheader42, %313
  %315 = phi i32 [ %326, %.preheader42 ], [ 0, %313 ]
  %316 = phi i64 [ %325, %.preheader42 ], [ 0, %313 ]
  %317 = zext i32 %315 to i64
  %318 = getelementptr inbounds i8, i8 addrspace(4)* %311, i64 %317
  %319 = load i8, i8 addrspace(4)* %318, align 1, !tbaa !9
  %320 = zext i8 %319 to i64
  %321 = shl i32 %315, 3
  %322 = and i32 %321, 56
  %323 = zext i32 %322 to i64
  %324 = shl nuw i64 %320, %323
  %325 = or i64 %324, %316
  %326 = add nuw i32 %315, 1
  %327 = icmp eq i32 %326, %310
  br i1 %327, label %.loopexit41, label %.preheader42

328:                                              ; preds = %272
  %329 = load i8, i8 addrspace(4)* %311, align 1, !tbaa !9
  %330 = zext i8 %329 to i64
  %331 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 41
  %332 = load i8, i8 addrspace(4)* %331, align 1, !tbaa !9
  %333 = zext i8 %332 to i64
  %334 = shl nuw nsw i64 %333, 8
  %335 = or i64 %334, %330
  %336 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 42
  %337 = load i8, i8 addrspace(4)* %336, align 1, !tbaa !9
  %338 = zext i8 %337 to i64
  %339 = shl nuw nsw i64 %338, 16
  %340 = or i64 %335, %339
  %341 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 43
  %342 = load i8, i8 addrspace(4)* %341, align 1, !tbaa !9
  %343 = zext i8 %342 to i64
  %344 = shl nuw nsw i64 %343, 24
  %345 = or i64 %340, %344
  %346 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 44
  %347 = load i8, i8 addrspace(4)* %346, align 1, !tbaa !9
  %348 = zext i8 %347 to i64
  %349 = shl nuw nsw i64 %348, 32
  %350 = or i64 %345, %349
  %351 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 45
  %352 = load i8, i8 addrspace(4)* %351, align 1, !tbaa !9
  %353 = zext i8 %352 to i64
  %354 = shl nuw nsw i64 %353, 40
  %355 = or i64 %350, %354
  %356 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 46
  %357 = load i8, i8 addrspace(4)* %356, align 1, !tbaa !9
  %358 = zext i8 %357 to i64
  %359 = shl nuw nsw i64 %358, 48
  %360 = or i64 %355, %359
  %361 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 47
  %362 = load i8, i8 addrspace(4)* %361, align 1, !tbaa !9
  %363 = zext i8 %362 to i64
  %364 = shl nuw i64 %363, 56
  %365 = or i64 %360, %364
  %366 = add nsw i32 %25, -48
  %367 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 48
  %368 = icmp ugt i32 %366, 7
  br i1 %368, label %371, label %369

369:                                              ; preds = %328
  %370 = icmp eq i32 %366, 0
  br i1 %370, label %.loopexit41, label %.preheader40

371:                                              ; preds = %328
  %372 = load i8, i8 addrspace(4)* %367, align 1, !tbaa !9
  %373 = zext i8 %372 to i64
  %374 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 49
  %375 = load i8, i8 addrspace(4)* %374, align 1, !tbaa !9
  %376 = zext i8 %375 to i64
  %377 = shl nuw nsw i64 %376, 8
  %378 = or i64 %377, %373
  %379 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 50
  %380 = load i8, i8 addrspace(4)* %379, align 1, !tbaa !9
  %381 = zext i8 %380 to i64
  %382 = shl nuw nsw i64 %381, 16
  %383 = or i64 %378, %382
  %384 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 51
  %385 = load i8, i8 addrspace(4)* %384, align 1, !tbaa !9
  %386 = zext i8 %385 to i64
  %387 = shl nuw nsw i64 %386, 24
  %388 = or i64 %383, %387
  %389 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 52
  %390 = load i8, i8 addrspace(4)* %389, align 1, !tbaa !9
  %391 = zext i8 %390 to i64
  %392 = shl nuw nsw i64 %391, 32
  %393 = or i64 %388, %392
  %394 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 53
  %395 = load i8, i8 addrspace(4)* %394, align 1, !tbaa !9
  %396 = zext i8 %395 to i64
  %397 = shl nuw nsw i64 %396, 40
  %398 = or i64 %393, %397
  %399 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 54
  %400 = load i8, i8 addrspace(4)* %399, align 1, !tbaa !9
  %401 = zext i8 %400 to i64
  %402 = shl nuw nsw i64 %401, 48
  %403 = or i64 %398, %402
  %404 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 55
  %405 = load i8, i8 addrspace(4)* %404, align 1, !tbaa !9
  %406 = zext i8 %405 to i64
  %407 = shl nuw i64 %406, 56
  %408 = or i64 %403, %407
  br label %.loopexit41

.preheader40:                                     ; preds = %.preheader40, %369
  %409 = phi i32 [ %420, %.preheader40 ], [ 0, %369 ]
  %410 = phi i64 [ %419, %.preheader40 ], [ 0, %369 ]
  %411 = zext i32 %409 to i64
  %412 = getelementptr inbounds i8, i8 addrspace(4)* %367, i64 %411
  %413 = load i8, i8 addrspace(4)* %412, align 1, !tbaa !9
  %414 = zext i8 %413 to i64
  %415 = shl i32 %409, 3
  %416 = and i32 %415, 56
  %417 = zext i32 %416 to i64
  %418 = shl nuw i64 %414, %417
  %419 = or i64 %418, %410
  %420 = add nuw i32 %409, 1
  %421 = icmp eq i32 %420, %366
  br i1 %421, label %.loopexit41, label %.preheader40

.loopexit41:                                      ; preds = %.preheader40, %371, %369, %.preheader42, %313, %.preheader44, %257, %.preheader46, %201, %.preheader48, %145, %.preheader50, %89, %.preheader52, %33
  %422 = phi i64 [ %365, %371 ], [ %365, %369 ], [ 0, %313 ], [ 0, %201 ], [ 0, %89 ], [ 0, %33 ], [ 0, %145 ], [ 0, %257 ], [ %365, %.preheader40 ], [ %325, %.preheader42 ], [ 0, %.preheader44 ], [ 0, %.preheader46 ], [ 0, %.preheader48 ], [ 0, %.preheader50 ], [ 0, %.preheader52 ]
  %423 = phi i64 [ %253, %371 ], [ %253, %369 ], [ %253, %313 ], [ 0, %201 ], [ 0, %89 ], [ 0, %33 ], [ 0, %145 ], [ %253, %257 ], [ %253, %.preheader40 ], [ %253, %.preheader42 ], [ %253, %.preheader44 ], [ %213, %.preheader46 ], [ 0, %.preheader48 ], [ 0, %.preheader50 ], [ 0, %.preheader52 ]
  %424 = phi i64 [ %141, %371 ], [ %141, %369 ], [ %141, %313 ], [ %141, %201 ], [ 0, %89 ], [ 0, %33 ], [ %141, %145 ], [ %141, %257 ], [ %141, %.preheader40 ], [ %141, %.preheader42 ], [ %141, %.preheader44 ], [ %141, %.preheader46 ], [ %141, %.preheader48 ], [ %101, %.preheader50 ], [ 0, %.preheader52 ]
  %425 = phi i64 [ %85, %371 ], [ %85, %369 ], [ %85, %313 ], [ %85, %201 ], [ %85, %89 ], [ 0, %33 ], [ %85, %145 ], [ %85, %257 ], [ %85, %.preheader40 ], [ %85, %.preheader42 ], [ %85, %.preheader44 ], [ %85, %.preheader46 ], [ %85, %.preheader48 ], [ %85, %.preheader50 ], [ %45, %.preheader52 ]
  %426 = phi i64 [ %197, %371 ], [ %197, %369 ], [ %197, %313 ], [ %197, %201 ], [ 0, %89 ], [ 0, %33 ], [ 0, %145 ], [ %197, %257 ], [ %197, %.preheader40 ], [ %197, %.preheader42 ], [ %197, %.preheader44 ], [ %197, %.preheader46 ], [ %157, %.preheader48 ], [ 0, %.preheader50 ], [ 0, %.preheader52 ]
  %427 = phi i64 [ %309, %371 ], [ %309, %369 ], [ %309, %313 ], [ 0, %201 ], [ 0, %89 ], [ 0, %33 ], [ 0, %145 ], [ 0, %257 ], [ %309, %.preheader40 ], [ %309, %.preheader42 ], [ %269, %.preheader44 ], [ 0, %.preheader46 ], [ 0, %.preheader48 ], [ 0, %.preheader50 ], [ 0, %.preheader52 ]
  %428 = phi i64 [ %408, %371 ], [ 0, %369 ], [ 0, %313 ], [ 0, %201 ], [ 0, %89 ], [ 0, %33 ], [ 0, %145 ], [ 0, %257 ], [ %419, %.preheader40 ], [ 0, %.preheader42 ], [ 0, %.preheader44 ], [ 0, %.preheader46 ], [ 0, %.preheader48 ], [ 0, %.preheader50 ], [ 0, %.preheader52 ]
  %429 = tail call fastcc <2 x i64> @__ockl_hostcall_internal(i8* %3, i64 %31, i64 %425, i64 %424, i64 %426, i64 %423, i64 %427, i64 %422, i64 %428) #18
  %430 = sub i64 %15, %24
  %431 = getelementptr inbounds i8, i8 addrspace(4)* %16, i64 %24
  %432 = icmp eq i64 %430, 0
  br i1 %432, label %__ockl_printf_append_string_n.exit, label %14

__ockl_printf_append_string_n.exit:               ; preds = %.loopexit41, %6
  %433 = phi <2 x i64> [ %9, %6 ], [ %429, %.loopexit41 ]
  %434 = extractelement <2 x i64> %433, i64 0
  %435 = icmp eq i8* %__file, null
  br i1 %435, label %strlen.join1.thread, label %strlen.while2

strlen.while2:                                    ; preds = %strlen.while2, %__ockl_printf_append_string_n.exit
  %436 = phi i8* [ %437, %strlen.while2 ], [ %__file, %__ockl_printf_append_string_n.exit ]
  %437 = getelementptr i8, i8* %436, i64 1
  %438 = load i8, i8* %436, align 1
  %439 = icmp eq i8 %438, 0
  br i1 %439, label %strlen.join1, label %strlen.while2

strlen.join1.thread:                              ; preds = %__ockl_printf_append_string_n.exit
  %440 = and i64 %434, -225
  %441 = or i64 %440, 32
  %442 = tail call fastcc <2 x i64> @__ockl_hostcall_internal(i8* %3, i64 %441, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0) #18
  br label %__ockl_printf_append_string_n.exit10

strlen.join1:                                     ; preds = %strlen.while2
  %443 = ptrtoint i8* %436 to i64
  %444 = ptrtoint i8* %__file to i64
  %445 = sub i64 1, %444
  %446 = add i64 %445, %443
  %447 = and i64 %434, 2
  %448 = and i64 %434, -3
  %449 = insertelement <2 x i64> <i64 undef, i64 0>, i64 %448, i64 0
  br label %450

450:                                              ; preds = %.loopexit27, %strlen.join1
  %451 = phi i64 [ %446, %strlen.join1 ], [ %866, %.loopexit27 ]
  %452 = phi i8* [ %__file, %strlen.join1 ], [ %867, %.loopexit27 ]
  %453 = phi <2 x i64> [ %449, %strlen.join1 ], [ %865, %.loopexit27 ]
  %454 = icmp ugt i64 %451, 56
  %455 = extractelement <2 x i64> %453, i64 0
  %456 = or i64 %455, %447
  %457 = insertelement <2 x i64> undef, i64 %456, i64 0
  %458 = select i1 %454, <2 x i64> %453, <2 x i64> %457
  %459 = icmp ult i64 %451, 56
  %460 = select i1 %459, i64 %451, i64 56
  %461 = trunc i64 %460 to i32
  %462 = extractelement <2 x i64> %458, i64 0
  %463 = add nuw nsw i64 %460, 7
  %464 = lshr i64 %463, 3
  %465 = and i64 %462, -225
  %466 = shl nuw nsw i64 %464, 5
  %467 = or i64 %465, %466
  %468 = icmp ugt i32 %461, 7
  br i1 %468, label %484, label %469

469:                                              ; preds = %450
  %470 = icmp eq i32 %461, 0
  br i1 %470, label %.loopexit27, label %.preheader38

.preheader38:                                     ; preds = %.preheader38, %469
  %471 = phi i32 [ %482, %.preheader38 ], [ 0, %469 ]
  %472 = phi i64 [ %481, %.preheader38 ], [ 0, %469 ]
  %473 = zext i32 %471 to i64
  %474 = getelementptr inbounds i8, i8* %452, i64 %473
  %475 = load i8, i8* %474, align 1, !tbaa !9
  %476 = zext i8 %475 to i64
  %477 = shl i32 %471, 3
  %478 = and i32 %477, 56
  %479 = zext i32 %478 to i64
  %480 = shl nuw i64 %476, %479
  %481 = or i64 %480, %472
  %482 = add nuw nsw i32 %471, 1
  %483 = icmp eq i32 %482, %461
  br i1 %483, label %.loopexit27, label %.preheader38

484:                                              ; preds = %450
  %485 = load i8, i8* %452, align 1, !tbaa !9
  %486 = zext i8 %485 to i64
  %487 = getelementptr inbounds i8, i8* %452, i64 1
  %488 = load i8, i8* %487, align 1, !tbaa !9
  %489 = zext i8 %488 to i64
  %490 = shl nuw nsw i64 %489, 8
  %491 = or i64 %490, %486
  %492 = getelementptr inbounds i8, i8* %452, i64 2
  %493 = load i8, i8* %492, align 1, !tbaa !9
  %494 = zext i8 %493 to i64
  %495 = shl nuw nsw i64 %494, 16
  %496 = or i64 %491, %495
  %497 = getelementptr inbounds i8, i8* %452, i64 3
  %498 = load i8, i8* %497, align 1, !tbaa !9
  %499 = zext i8 %498 to i64
  %500 = shl nuw nsw i64 %499, 24
  %501 = or i64 %496, %500
  %502 = getelementptr inbounds i8, i8* %452, i64 4
  %503 = load i8, i8* %502, align 1, !tbaa !9
  %504 = zext i8 %503 to i64
  %505 = shl nuw nsw i64 %504, 32
  %506 = or i64 %501, %505
  %507 = getelementptr inbounds i8, i8* %452, i64 5
  %508 = load i8, i8* %507, align 1, !tbaa !9
  %509 = zext i8 %508 to i64
  %510 = shl nuw nsw i64 %509, 40
  %511 = or i64 %506, %510
  %512 = getelementptr inbounds i8, i8* %452, i64 6
  %513 = load i8, i8* %512, align 1, !tbaa !9
  %514 = zext i8 %513 to i64
  %515 = shl nuw nsw i64 %514, 48
  %516 = or i64 %511, %515
  %517 = getelementptr inbounds i8, i8* %452, i64 7
  %518 = load i8, i8* %517, align 1, !tbaa !9
  %519 = zext i8 %518 to i64
  %520 = shl nuw i64 %519, 56
  %521 = or i64 %516, %520
  %522 = add nsw i32 %461, -8
  %523 = getelementptr inbounds i8, i8* %452, i64 8
  %524 = icmp ugt i32 %522, 7
  br i1 %524, label %540, label %525

525:                                              ; preds = %484
  %526 = icmp eq i32 %522, 0
  br i1 %526, label %.loopexit27, label %.preheader36

.preheader36:                                     ; preds = %.preheader36, %525
  %527 = phi i32 [ %538, %.preheader36 ], [ 0, %525 ]
  %528 = phi i64 [ %537, %.preheader36 ], [ 0, %525 ]
  %529 = zext i32 %527 to i64
  %530 = getelementptr inbounds i8, i8* %523, i64 %529
  %531 = load i8, i8* %530, align 1, !tbaa !9
  %532 = zext i8 %531 to i64
  %533 = shl i32 %527, 3
  %534 = and i32 %533, 56
  %535 = zext i32 %534 to i64
  %536 = shl nuw i64 %532, %535
  %537 = or i64 %536, %528
  %538 = add nuw i32 %527, 1
  %539 = icmp eq i32 %538, %522
  br i1 %539, label %.loopexit27, label %.preheader36

540:                                              ; preds = %484
  %541 = load i8, i8* %523, align 1, !tbaa !9
  %542 = zext i8 %541 to i64
  %543 = getelementptr inbounds i8, i8* %452, i64 9
  %544 = load i8, i8* %543, align 1, !tbaa !9
  %545 = zext i8 %544 to i64
  %546 = shl nuw nsw i64 %545, 8
  %547 = or i64 %546, %542
  %548 = getelementptr inbounds i8, i8* %452, i64 10
  %549 = load i8, i8* %548, align 1, !tbaa !9
  %550 = zext i8 %549 to i64
  %551 = shl nuw nsw i64 %550, 16
  %552 = or i64 %547, %551
  %553 = getelementptr inbounds i8, i8* %452, i64 11
  %554 = load i8, i8* %553, align 1, !tbaa !9
  %555 = zext i8 %554 to i64
  %556 = shl nuw nsw i64 %555, 24
  %557 = or i64 %552, %556
  %558 = getelementptr inbounds i8, i8* %452, i64 12
  %559 = load i8, i8* %558, align 1, !tbaa !9
  %560 = zext i8 %559 to i64
  %561 = shl nuw nsw i64 %560, 32
  %562 = or i64 %557, %561
  %563 = getelementptr inbounds i8, i8* %452, i64 13
  %564 = load i8, i8* %563, align 1, !tbaa !9
  %565 = zext i8 %564 to i64
  %566 = shl nuw nsw i64 %565, 40
  %567 = or i64 %562, %566
  %568 = getelementptr inbounds i8, i8* %452, i64 14
  %569 = load i8, i8* %568, align 1, !tbaa !9
  %570 = zext i8 %569 to i64
  %571 = shl nuw nsw i64 %570, 48
  %572 = or i64 %567, %571
  %573 = getelementptr inbounds i8, i8* %452, i64 15
  %574 = load i8, i8* %573, align 1, !tbaa !9
  %575 = zext i8 %574 to i64
  %576 = shl nuw i64 %575, 56
  %577 = or i64 %572, %576
  %578 = add nsw i32 %461, -16
  %579 = getelementptr inbounds i8, i8* %452, i64 16
  %580 = icmp ugt i32 %578, 7
  br i1 %580, label %596, label %581

581:                                              ; preds = %540
  %582 = icmp eq i32 %578, 0
  br i1 %582, label %.loopexit27, label %.preheader34

.preheader34:                                     ; preds = %.preheader34, %581
  %583 = phi i32 [ %594, %.preheader34 ], [ 0, %581 ]
  %584 = phi i64 [ %593, %.preheader34 ], [ 0, %581 ]
  %585 = zext i32 %583 to i64
  %586 = getelementptr inbounds i8, i8* %579, i64 %585
  %587 = load i8, i8* %586, align 1, !tbaa !9
  %588 = zext i8 %587 to i64
  %589 = shl i32 %583, 3
  %590 = and i32 %589, 56
  %591 = zext i32 %590 to i64
  %592 = shl nuw i64 %588, %591
  %593 = or i64 %592, %584
  %594 = add nuw i32 %583, 1
  %595 = icmp eq i32 %594, %578
  br i1 %595, label %.loopexit27, label %.preheader34

596:                                              ; preds = %540
  %597 = load i8, i8* %579, align 1, !tbaa !9
  %598 = zext i8 %597 to i64
  %599 = getelementptr inbounds i8, i8* %452, i64 17
  %600 = load i8, i8* %599, align 1, !tbaa !9
  %601 = zext i8 %600 to i64
  %602 = shl nuw nsw i64 %601, 8
  %603 = or i64 %602, %598
  %604 = getelementptr inbounds i8, i8* %452, i64 18
  %605 = load i8, i8* %604, align 1, !tbaa !9
  %606 = zext i8 %605 to i64
  %607 = shl nuw nsw i64 %606, 16
  %608 = or i64 %603, %607
  %609 = getelementptr inbounds i8, i8* %452, i64 19
  %610 = load i8, i8* %609, align 1, !tbaa !9
  %611 = zext i8 %610 to i64
  %612 = shl nuw nsw i64 %611, 24
  %613 = or i64 %608, %612
  %614 = getelementptr inbounds i8, i8* %452, i64 20
  %615 = load i8, i8* %614, align 1, !tbaa !9
  %616 = zext i8 %615 to i64
  %617 = shl nuw nsw i64 %616, 32
  %618 = or i64 %613, %617
  %619 = getelementptr inbounds i8, i8* %452, i64 21
  %620 = load i8, i8* %619, align 1, !tbaa !9
  %621 = zext i8 %620 to i64
  %622 = shl nuw nsw i64 %621, 40
  %623 = or i64 %618, %622
  %624 = getelementptr inbounds i8, i8* %452, i64 22
  %625 = load i8, i8* %624, align 1, !tbaa !9
  %626 = zext i8 %625 to i64
  %627 = shl nuw nsw i64 %626, 48
  %628 = or i64 %623, %627
  %629 = getelementptr inbounds i8, i8* %452, i64 23
  %630 = load i8, i8* %629, align 1, !tbaa !9
  %631 = zext i8 %630 to i64
  %632 = shl nuw i64 %631, 56
  %633 = or i64 %628, %632
  %634 = add nsw i32 %461, -24
  %635 = getelementptr inbounds i8, i8* %452, i64 24
  %636 = icmp ugt i32 %634, 7
  br i1 %636, label %652, label %637

637:                                              ; preds = %596
  %638 = icmp eq i32 %634, 0
  br i1 %638, label %.loopexit27, label %.preheader32

.preheader32:                                     ; preds = %.preheader32, %637
  %639 = phi i32 [ %650, %.preheader32 ], [ 0, %637 ]
  %640 = phi i64 [ %649, %.preheader32 ], [ 0, %637 ]
  %641 = zext i32 %639 to i64
  %642 = getelementptr inbounds i8, i8* %635, i64 %641
  %643 = load i8, i8* %642, align 1, !tbaa !9
  %644 = zext i8 %643 to i64
  %645 = shl i32 %639, 3
  %646 = and i32 %645, 56
  %647 = zext i32 %646 to i64
  %648 = shl nuw i64 %644, %647
  %649 = or i64 %648, %640
  %650 = add nuw i32 %639, 1
  %651 = icmp eq i32 %650, %634
  br i1 %651, label %.loopexit27, label %.preheader32

652:                                              ; preds = %596
  %653 = load i8, i8* %635, align 1, !tbaa !9
  %654 = zext i8 %653 to i64
  %655 = getelementptr inbounds i8, i8* %452, i64 25
  %656 = load i8, i8* %655, align 1, !tbaa !9
  %657 = zext i8 %656 to i64
  %658 = shl nuw nsw i64 %657, 8
  %659 = or i64 %658, %654
  %660 = getelementptr inbounds i8, i8* %452, i64 26
  %661 = load i8, i8* %660, align 1, !tbaa !9
  %662 = zext i8 %661 to i64
  %663 = shl nuw nsw i64 %662, 16
  %664 = or i64 %659, %663
  %665 = getelementptr inbounds i8, i8* %452, i64 27
  %666 = load i8, i8* %665, align 1, !tbaa !9
  %667 = zext i8 %666 to i64
  %668 = shl nuw nsw i64 %667, 24
  %669 = or i64 %664, %668
  %670 = getelementptr inbounds i8, i8* %452, i64 28
  %671 = load i8, i8* %670, align 1, !tbaa !9
  %672 = zext i8 %671 to i64
  %673 = shl nuw nsw i64 %672, 32
  %674 = or i64 %669, %673
  %675 = getelementptr inbounds i8, i8* %452, i64 29
  %676 = load i8, i8* %675, align 1, !tbaa !9
  %677 = zext i8 %676 to i64
  %678 = shl nuw nsw i64 %677, 40
  %679 = or i64 %674, %678
  %680 = getelementptr inbounds i8, i8* %452, i64 30
  %681 = load i8, i8* %680, align 1, !tbaa !9
  %682 = zext i8 %681 to i64
  %683 = shl nuw nsw i64 %682, 48
  %684 = or i64 %679, %683
  %685 = getelementptr inbounds i8, i8* %452, i64 31
  %686 = load i8, i8* %685, align 1, !tbaa !9
  %687 = zext i8 %686 to i64
  %688 = shl nuw i64 %687, 56
  %689 = or i64 %684, %688
  %690 = add nsw i32 %461, -32
  %691 = getelementptr inbounds i8, i8* %452, i64 32
  %692 = icmp ugt i32 %690, 7
  br i1 %692, label %708, label %693

693:                                              ; preds = %652
  %694 = icmp eq i32 %690, 0
  br i1 %694, label %.loopexit27, label %.preheader30

.preheader30:                                     ; preds = %.preheader30, %693
  %695 = phi i32 [ %706, %.preheader30 ], [ 0, %693 ]
  %696 = phi i64 [ %705, %.preheader30 ], [ 0, %693 ]
  %697 = zext i32 %695 to i64
  %698 = getelementptr inbounds i8, i8* %691, i64 %697
  %699 = load i8, i8* %698, align 1, !tbaa !9
  %700 = zext i8 %699 to i64
  %701 = shl i32 %695, 3
  %702 = and i32 %701, 56
  %703 = zext i32 %702 to i64
  %704 = shl nuw i64 %700, %703
  %705 = or i64 %704, %696
  %706 = add nuw i32 %695, 1
  %707 = icmp eq i32 %706, %690
  br i1 %707, label %.loopexit27, label %.preheader30

708:                                              ; preds = %652
  %709 = load i8, i8* %691, align 1, !tbaa !9
  %710 = zext i8 %709 to i64
  %711 = getelementptr inbounds i8, i8* %452, i64 33
  %712 = load i8, i8* %711, align 1, !tbaa !9
  %713 = zext i8 %712 to i64
  %714 = shl nuw nsw i64 %713, 8
  %715 = or i64 %714, %710
  %716 = getelementptr inbounds i8, i8* %452, i64 34
  %717 = load i8, i8* %716, align 1, !tbaa !9
  %718 = zext i8 %717 to i64
  %719 = shl nuw nsw i64 %718, 16
  %720 = or i64 %715, %719
  %721 = getelementptr inbounds i8, i8* %452, i64 35
  %722 = load i8, i8* %721, align 1, !tbaa !9
  %723 = zext i8 %722 to i64
  %724 = shl nuw nsw i64 %723, 24
  %725 = or i64 %720, %724
  %726 = getelementptr inbounds i8, i8* %452, i64 36
  %727 = load i8, i8* %726, align 1, !tbaa !9
  %728 = zext i8 %727 to i64
  %729 = shl nuw nsw i64 %728, 32
  %730 = or i64 %725, %729
  %731 = getelementptr inbounds i8, i8* %452, i64 37
  %732 = load i8, i8* %731, align 1, !tbaa !9
  %733 = zext i8 %732 to i64
  %734 = shl nuw nsw i64 %733, 40
  %735 = or i64 %730, %734
  %736 = getelementptr inbounds i8, i8* %452, i64 38
  %737 = load i8, i8* %736, align 1, !tbaa !9
  %738 = zext i8 %737 to i64
  %739 = shl nuw nsw i64 %738, 48
  %740 = or i64 %735, %739
  %741 = getelementptr inbounds i8, i8* %452, i64 39
  %742 = load i8, i8* %741, align 1, !tbaa !9
  %743 = zext i8 %742 to i64
  %744 = shl nuw i64 %743, 56
  %745 = or i64 %740, %744
  %746 = add nsw i32 %461, -40
  %747 = getelementptr inbounds i8, i8* %452, i64 40
  %748 = icmp ugt i32 %746, 7
  br i1 %748, label %764, label %749

749:                                              ; preds = %708
  %750 = icmp eq i32 %746, 0
  br i1 %750, label %.loopexit27, label %.preheader28

.preheader28:                                     ; preds = %.preheader28, %749
  %751 = phi i32 [ %762, %.preheader28 ], [ 0, %749 ]
  %752 = phi i64 [ %761, %.preheader28 ], [ 0, %749 ]
  %753 = zext i32 %751 to i64
  %754 = getelementptr inbounds i8, i8* %747, i64 %753
  %755 = load i8, i8* %754, align 1, !tbaa !9
  %756 = zext i8 %755 to i64
  %757 = shl i32 %751, 3
  %758 = and i32 %757, 56
  %759 = zext i32 %758 to i64
  %760 = shl nuw i64 %756, %759
  %761 = or i64 %760, %752
  %762 = add nuw i32 %751, 1
  %763 = icmp eq i32 %762, %746
  br i1 %763, label %.loopexit27, label %.preheader28

764:                                              ; preds = %708
  %765 = load i8, i8* %747, align 1, !tbaa !9
  %766 = zext i8 %765 to i64
  %767 = getelementptr inbounds i8, i8* %452, i64 41
  %768 = load i8, i8* %767, align 1, !tbaa !9
  %769 = zext i8 %768 to i64
  %770 = shl nuw nsw i64 %769, 8
  %771 = or i64 %770, %766
  %772 = getelementptr inbounds i8, i8* %452, i64 42
  %773 = load i8, i8* %772, align 1, !tbaa !9
  %774 = zext i8 %773 to i64
  %775 = shl nuw nsw i64 %774, 16
  %776 = or i64 %771, %775
  %777 = getelementptr inbounds i8, i8* %452, i64 43
  %778 = load i8, i8* %777, align 1, !tbaa !9
  %779 = zext i8 %778 to i64
  %780 = shl nuw nsw i64 %779, 24
  %781 = or i64 %776, %780
  %782 = getelementptr inbounds i8, i8* %452, i64 44
  %783 = load i8, i8* %782, align 1, !tbaa !9
  %784 = zext i8 %783 to i64
  %785 = shl nuw nsw i64 %784, 32
  %786 = or i64 %781, %785
  %787 = getelementptr inbounds i8, i8* %452, i64 45
  %788 = load i8, i8* %787, align 1, !tbaa !9
  %789 = zext i8 %788 to i64
  %790 = shl nuw nsw i64 %789, 40
  %791 = or i64 %786, %790
  %792 = getelementptr inbounds i8, i8* %452, i64 46
  %793 = load i8, i8* %792, align 1, !tbaa !9
  %794 = zext i8 %793 to i64
  %795 = shl nuw nsw i64 %794, 48
  %796 = or i64 %791, %795
  %797 = getelementptr inbounds i8, i8* %452, i64 47
  %798 = load i8, i8* %797, align 1, !tbaa !9
  %799 = zext i8 %798 to i64
  %800 = shl nuw i64 %799, 56
  %801 = or i64 %796, %800
  %802 = add nsw i32 %461, -48
  %803 = getelementptr inbounds i8, i8* %452, i64 48
  %804 = icmp ugt i32 %802, 7
  br i1 %804, label %807, label %805

805:                                              ; preds = %764
  %806 = icmp eq i32 %802, 0
  br i1 %806, label %.loopexit27, label %.preheader26

807:                                              ; preds = %764
  %808 = load i8, i8* %803, align 1, !tbaa !9
  %809 = zext i8 %808 to i64
  %810 = getelementptr inbounds i8, i8* %452, i64 49
  %811 = load i8, i8* %810, align 1, !tbaa !9
  %812 = zext i8 %811 to i64
  %813 = shl nuw nsw i64 %812, 8
  %814 = or i64 %813, %809
  %815 = getelementptr inbounds i8, i8* %452, i64 50
  %816 = load i8, i8* %815, align 1, !tbaa !9
  %817 = zext i8 %816 to i64
  %818 = shl nuw nsw i64 %817, 16
  %819 = or i64 %814, %818
  %820 = getelementptr inbounds i8, i8* %452, i64 51
  %821 = load i8, i8* %820, align 1, !tbaa !9
  %822 = zext i8 %821 to i64
  %823 = shl nuw nsw i64 %822, 24
  %824 = or i64 %819, %823
  %825 = getelementptr inbounds i8, i8* %452, i64 52
  %826 = load i8, i8* %825, align 1, !tbaa !9
  %827 = zext i8 %826 to i64
  %828 = shl nuw nsw i64 %827, 32
  %829 = or i64 %824, %828
  %830 = getelementptr inbounds i8, i8* %452, i64 53
  %831 = load i8, i8* %830, align 1, !tbaa !9
  %832 = zext i8 %831 to i64
  %833 = shl nuw nsw i64 %832, 40
  %834 = or i64 %829, %833
  %835 = getelementptr inbounds i8, i8* %452, i64 54
  %836 = load i8, i8* %835, align 1, !tbaa !9
  %837 = zext i8 %836 to i64
  %838 = shl nuw nsw i64 %837, 48
  %839 = or i64 %834, %838
  %840 = getelementptr inbounds i8, i8* %452, i64 55
  %841 = load i8, i8* %840, align 1, !tbaa !9
  %842 = zext i8 %841 to i64
  %843 = shl nuw i64 %842, 56
  %844 = or i64 %839, %843
  br label %.loopexit27

.preheader26:                                     ; preds = %.preheader26, %805
  %845 = phi i32 [ %856, %.preheader26 ], [ 0, %805 ]
  %846 = phi i64 [ %855, %.preheader26 ], [ 0, %805 ]
  %847 = zext i32 %845 to i64
  %848 = getelementptr inbounds i8, i8* %803, i64 %847
  %849 = load i8, i8* %848, align 1, !tbaa !9
  %850 = zext i8 %849 to i64
  %851 = shl i32 %845, 3
  %852 = and i32 %851, 56
  %853 = zext i32 %852 to i64
  %854 = shl nuw i64 %850, %853
  %855 = or i64 %854, %846
  %856 = add nuw i32 %845, 1
  %857 = icmp eq i32 %856, %802
  br i1 %857, label %.loopexit27, label %.preheader26

.loopexit27:                                      ; preds = %.preheader26, %807, %805, %.preheader28, %749, %.preheader30, %693, %.preheader32, %637, %.preheader34, %581, %.preheader36, %525, %.preheader38, %469
  %858 = phi i64 [ %801, %807 ], [ %801, %805 ], [ 0, %749 ], [ 0, %637 ], [ 0, %525 ], [ 0, %469 ], [ 0, %581 ], [ 0, %693 ], [ %801, %.preheader26 ], [ %761, %.preheader28 ], [ 0, %.preheader30 ], [ 0, %.preheader32 ], [ 0, %.preheader34 ], [ 0, %.preheader36 ], [ 0, %.preheader38 ]
  %859 = phi i64 [ %689, %807 ], [ %689, %805 ], [ %689, %749 ], [ 0, %637 ], [ 0, %525 ], [ 0, %469 ], [ 0, %581 ], [ %689, %693 ], [ %689, %.preheader26 ], [ %689, %.preheader28 ], [ %689, %.preheader30 ], [ %649, %.preheader32 ], [ 0, %.preheader34 ], [ 0, %.preheader36 ], [ 0, %.preheader38 ]
  %860 = phi i64 [ %577, %807 ], [ %577, %805 ], [ %577, %749 ], [ %577, %637 ], [ 0, %525 ], [ 0, %469 ], [ %577, %581 ], [ %577, %693 ], [ %577, %.preheader26 ], [ %577, %.preheader28 ], [ %577, %.preheader30 ], [ %577, %.preheader32 ], [ %577, %.preheader34 ], [ %537, %.preheader36 ], [ 0, %.preheader38 ]
  %861 = phi i64 [ %521, %807 ], [ %521, %805 ], [ %521, %749 ], [ %521, %637 ], [ %521, %525 ], [ 0, %469 ], [ %521, %581 ], [ %521, %693 ], [ %521, %.preheader26 ], [ %521, %.preheader28 ], [ %521, %.preheader30 ], [ %521, %.preheader32 ], [ %521, %.preheader34 ], [ %521, %.preheader36 ], [ %481, %.preheader38 ]
  %862 = phi i64 [ %633, %807 ], [ %633, %805 ], [ %633, %749 ], [ %633, %637 ], [ 0, %525 ], [ 0, %469 ], [ 0, %581 ], [ %633, %693 ], [ %633, %.preheader26 ], [ %633, %.preheader28 ], [ %633, %.preheader30 ], [ %633, %.preheader32 ], [ %593, %.preheader34 ], [ 0, %.preheader36 ], [ 0, %.preheader38 ]
  %863 = phi i64 [ %745, %807 ], [ %745, %805 ], [ %745, %749 ], [ 0, %637 ], [ 0, %525 ], [ 0, %469 ], [ 0, %581 ], [ 0, %693 ], [ %745, %.preheader26 ], [ %745, %.preheader28 ], [ %705, %.preheader30 ], [ 0, %.preheader32 ], [ 0, %.preheader34 ], [ 0, %.preheader36 ], [ 0, %.preheader38 ]
  %864 = phi i64 [ %844, %807 ], [ 0, %805 ], [ 0, %749 ], [ 0, %637 ], [ 0, %525 ], [ 0, %469 ], [ 0, %581 ], [ 0, %693 ], [ %855, %.preheader26 ], [ 0, %.preheader28 ], [ 0, %.preheader30 ], [ 0, %.preheader32 ], [ 0, %.preheader34 ], [ 0, %.preheader36 ], [ 0, %.preheader38 ]
  %865 = tail call fastcc <2 x i64> @__ockl_hostcall_internal(i8* %3, i64 %467, i64 %861, i64 %860, i64 %862, i64 %859, i64 %863, i64 %858, i64 %864) #18
  %866 = sub i64 %451, %460
  %867 = getelementptr inbounds i8, i8* %452, i64 %460
  %868 = icmp eq i64 %866, 0
  br i1 %868, label %__ockl_printf_append_string_n.exit10, label %450

__ockl_printf_append_string_n.exit10:             ; preds = %.loopexit27, %strlen.join1.thread
  %869 = phi <2 x i64> [ %442, %strlen.join1.thread ], [ %865, %.loopexit27 ]
  %870 = extractelement <2 x i64> %869, i64 0
  %871 = zext i32 %__line to i64
  %872 = and i64 %870, -225
  %873 = or i64 %872, 32
  %874 = tail call fastcc <2 x i64> @__ockl_hostcall_internal(i8* %3, i64 %873, i64 %871, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0) #18
  %875 = extractelement <2 x i64> %874, i64 0
  %876 = icmp eq i8* %__function, null
  br i1 %876, label %strlen.join4.thread, label %strlen.while5

strlen.while5:                                    ; preds = %strlen.while5, %__ockl_printf_append_string_n.exit10
  %877 = phi i8* [ %878, %strlen.while5 ], [ %__function, %__ockl_printf_append_string_n.exit10 ]
  %878 = getelementptr i8, i8* %877, i64 1
  %879 = load i8, i8* %877, align 1
  %880 = icmp eq i8 %879, 0
  br i1 %880, label %strlen.join4, label %strlen.while5

strlen.join4.thread:                              ; preds = %__ockl_printf_append_string_n.exit10
  %881 = and i64 %875, -225
  %882 = or i64 %881, 32
  %883 = tail call fastcc <2 x i64> @__ockl_hostcall_internal(i8* %3, i64 %882, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0) #18
  br label %__ockl_printf_append_string_n.exit11

strlen.join4:                                     ; preds = %strlen.while5
  %884 = ptrtoint i8* %877 to i64
  %885 = ptrtoint i8* %__function to i64
  %886 = sub i64 1, %885
  %887 = add i64 %886, %884
  %888 = and i64 %875, 2
  %889 = and i64 %875, -3
  %890 = insertelement <2 x i64> <i64 undef, i64 0>, i64 %889, i64 0
  br label %891

891:                                              ; preds = %.loopexit, %strlen.join4
  %892 = phi i64 [ %887, %strlen.join4 ], [ %1307, %.loopexit ]
  %893 = phi i8* [ %__function, %strlen.join4 ], [ %1308, %.loopexit ]
  %894 = phi <2 x i64> [ %890, %strlen.join4 ], [ %1306, %.loopexit ]
  %895 = icmp ugt i64 %892, 56
  %896 = extractelement <2 x i64> %894, i64 0
  %897 = or i64 %896, %888
  %898 = insertelement <2 x i64> undef, i64 %897, i64 0
  %899 = select i1 %895, <2 x i64> %894, <2 x i64> %898
  %900 = icmp ult i64 %892, 56
  %901 = select i1 %900, i64 %892, i64 56
  %902 = trunc i64 %901 to i32
  %903 = extractelement <2 x i64> %899, i64 0
  %904 = add nuw nsw i64 %901, 7
  %905 = lshr i64 %904, 3
  %906 = and i64 %903, -225
  %907 = shl nuw nsw i64 %905, 5
  %908 = or i64 %906, %907
  %909 = icmp ugt i32 %902, 7
  br i1 %909, label %925, label %910

910:                                              ; preds = %891
  %911 = icmp eq i32 %902, 0
  br i1 %911, label %.loopexit, label %.preheader24

.preheader24:                                     ; preds = %.preheader24, %910
  %912 = phi i32 [ %923, %.preheader24 ], [ 0, %910 ]
  %913 = phi i64 [ %922, %.preheader24 ], [ 0, %910 ]
  %914 = zext i32 %912 to i64
  %915 = getelementptr inbounds i8, i8* %893, i64 %914
  %916 = load i8, i8* %915, align 1, !tbaa !9
  %917 = zext i8 %916 to i64
  %918 = shl i32 %912, 3
  %919 = and i32 %918, 56
  %920 = zext i32 %919 to i64
  %921 = shl nuw i64 %917, %920
  %922 = or i64 %921, %913
  %923 = add nuw nsw i32 %912, 1
  %924 = icmp eq i32 %923, %902
  br i1 %924, label %.loopexit, label %.preheader24

925:                                              ; preds = %891
  %926 = load i8, i8* %893, align 1, !tbaa !9
  %927 = zext i8 %926 to i64
  %928 = getelementptr inbounds i8, i8* %893, i64 1
  %929 = load i8, i8* %928, align 1, !tbaa !9
  %930 = zext i8 %929 to i64
  %931 = shl nuw nsw i64 %930, 8
  %932 = or i64 %931, %927
  %933 = getelementptr inbounds i8, i8* %893, i64 2
  %934 = load i8, i8* %933, align 1, !tbaa !9
  %935 = zext i8 %934 to i64
  %936 = shl nuw nsw i64 %935, 16
  %937 = or i64 %932, %936
  %938 = getelementptr inbounds i8, i8* %893, i64 3
  %939 = load i8, i8* %938, align 1, !tbaa !9
  %940 = zext i8 %939 to i64
  %941 = shl nuw nsw i64 %940, 24
  %942 = or i64 %937, %941
  %943 = getelementptr inbounds i8, i8* %893, i64 4
  %944 = load i8, i8* %943, align 1, !tbaa !9
  %945 = zext i8 %944 to i64
  %946 = shl nuw nsw i64 %945, 32
  %947 = or i64 %942, %946
  %948 = getelementptr inbounds i8, i8* %893, i64 5
  %949 = load i8, i8* %948, align 1, !tbaa !9
  %950 = zext i8 %949 to i64
  %951 = shl nuw nsw i64 %950, 40
  %952 = or i64 %947, %951
  %953 = getelementptr inbounds i8, i8* %893, i64 6
  %954 = load i8, i8* %953, align 1, !tbaa !9
  %955 = zext i8 %954 to i64
  %956 = shl nuw nsw i64 %955, 48
  %957 = or i64 %952, %956
  %958 = getelementptr inbounds i8, i8* %893, i64 7
  %959 = load i8, i8* %958, align 1, !tbaa !9
  %960 = zext i8 %959 to i64
  %961 = shl nuw i64 %960, 56
  %962 = or i64 %957, %961
  %963 = add nsw i32 %902, -8
  %964 = getelementptr inbounds i8, i8* %893, i64 8
  %965 = icmp ugt i32 %963, 7
  br i1 %965, label %981, label %966

966:                                              ; preds = %925
  %967 = icmp eq i32 %963, 0
  br i1 %967, label %.loopexit, label %.preheader22

.preheader22:                                     ; preds = %.preheader22, %966
  %968 = phi i32 [ %979, %.preheader22 ], [ 0, %966 ]
  %969 = phi i64 [ %978, %.preheader22 ], [ 0, %966 ]
  %970 = zext i32 %968 to i64
  %971 = getelementptr inbounds i8, i8* %964, i64 %970
  %972 = load i8, i8* %971, align 1, !tbaa !9
  %973 = zext i8 %972 to i64
  %974 = shl i32 %968, 3
  %975 = and i32 %974, 56
  %976 = zext i32 %975 to i64
  %977 = shl nuw i64 %973, %976
  %978 = or i64 %977, %969
  %979 = add nuw i32 %968, 1
  %980 = icmp eq i32 %979, %963
  br i1 %980, label %.loopexit, label %.preheader22

981:                                              ; preds = %925
  %982 = load i8, i8* %964, align 1, !tbaa !9
  %983 = zext i8 %982 to i64
  %984 = getelementptr inbounds i8, i8* %893, i64 9
  %985 = load i8, i8* %984, align 1, !tbaa !9
  %986 = zext i8 %985 to i64
  %987 = shl nuw nsw i64 %986, 8
  %988 = or i64 %987, %983
  %989 = getelementptr inbounds i8, i8* %893, i64 10
  %990 = load i8, i8* %989, align 1, !tbaa !9
  %991 = zext i8 %990 to i64
  %992 = shl nuw nsw i64 %991, 16
  %993 = or i64 %988, %992
  %994 = getelementptr inbounds i8, i8* %893, i64 11
  %995 = load i8, i8* %994, align 1, !tbaa !9
  %996 = zext i8 %995 to i64
  %997 = shl nuw nsw i64 %996, 24
  %998 = or i64 %993, %997
  %999 = getelementptr inbounds i8, i8* %893, i64 12
  %1000 = load i8, i8* %999, align 1, !tbaa !9
  %1001 = zext i8 %1000 to i64
  %1002 = shl nuw nsw i64 %1001, 32
  %1003 = or i64 %998, %1002
  %1004 = getelementptr inbounds i8, i8* %893, i64 13
  %1005 = load i8, i8* %1004, align 1, !tbaa !9
  %1006 = zext i8 %1005 to i64
  %1007 = shl nuw nsw i64 %1006, 40
  %1008 = or i64 %1003, %1007
  %1009 = getelementptr inbounds i8, i8* %893, i64 14
  %1010 = load i8, i8* %1009, align 1, !tbaa !9
  %1011 = zext i8 %1010 to i64
  %1012 = shl nuw nsw i64 %1011, 48
  %1013 = or i64 %1008, %1012
  %1014 = getelementptr inbounds i8, i8* %893, i64 15
  %1015 = load i8, i8* %1014, align 1, !tbaa !9
  %1016 = zext i8 %1015 to i64
  %1017 = shl nuw i64 %1016, 56
  %1018 = or i64 %1013, %1017
  %1019 = add nsw i32 %902, -16
  %1020 = getelementptr inbounds i8, i8* %893, i64 16
  %1021 = icmp ugt i32 %1019, 7
  br i1 %1021, label %1037, label %1022

1022:                                             ; preds = %981
  %1023 = icmp eq i32 %1019, 0
  br i1 %1023, label %.loopexit, label %.preheader20

.preheader20:                                     ; preds = %.preheader20, %1022
  %1024 = phi i32 [ %1035, %.preheader20 ], [ 0, %1022 ]
  %1025 = phi i64 [ %1034, %.preheader20 ], [ 0, %1022 ]
  %1026 = zext i32 %1024 to i64
  %1027 = getelementptr inbounds i8, i8* %1020, i64 %1026
  %1028 = load i8, i8* %1027, align 1, !tbaa !9
  %1029 = zext i8 %1028 to i64
  %1030 = shl i32 %1024, 3
  %1031 = and i32 %1030, 56
  %1032 = zext i32 %1031 to i64
  %1033 = shl nuw i64 %1029, %1032
  %1034 = or i64 %1033, %1025
  %1035 = add nuw i32 %1024, 1
  %1036 = icmp eq i32 %1035, %1019
  br i1 %1036, label %.loopexit, label %.preheader20

1037:                                             ; preds = %981
  %1038 = load i8, i8* %1020, align 1, !tbaa !9
  %1039 = zext i8 %1038 to i64
  %1040 = getelementptr inbounds i8, i8* %893, i64 17
  %1041 = load i8, i8* %1040, align 1, !tbaa !9
  %1042 = zext i8 %1041 to i64
  %1043 = shl nuw nsw i64 %1042, 8
  %1044 = or i64 %1043, %1039
  %1045 = getelementptr inbounds i8, i8* %893, i64 18
  %1046 = load i8, i8* %1045, align 1, !tbaa !9
  %1047 = zext i8 %1046 to i64
  %1048 = shl nuw nsw i64 %1047, 16
  %1049 = or i64 %1044, %1048
  %1050 = getelementptr inbounds i8, i8* %893, i64 19
  %1051 = load i8, i8* %1050, align 1, !tbaa !9
  %1052 = zext i8 %1051 to i64
  %1053 = shl nuw nsw i64 %1052, 24
  %1054 = or i64 %1049, %1053
  %1055 = getelementptr inbounds i8, i8* %893, i64 20
  %1056 = load i8, i8* %1055, align 1, !tbaa !9
  %1057 = zext i8 %1056 to i64
  %1058 = shl nuw nsw i64 %1057, 32
  %1059 = or i64 %1054, %1058
  %1060 = getelementptr inbounds i8, i8* %893, i64 21
  %1061 = load i8, i8* %1060, align 1, !tbaa !9
  %1062 = zext i8 %1061 to i64
  %1063 = shl nuw nsw i64 %1062, 40
  %1064 = or i64 %1059, %1063
  %1065 = getelementptr inbounds i8, i8* %893, i64 22
  %1066 = load i8, i8* %1065, align 1, !tbaa !9
  %1067 = zext i8 %1066 to i64
  %1068 = shl nuw nsw i64 %1067, 48
  %1069 = or i64 %1064, %1068
  %1070 = getelementptr inbounds i8, i8* %893, i64 23
  %1071 = load i8, i8* %1070, align 1, !tbaa !9
  %1072 = zext i8 %1071 to i64
  %1073 = shl nuw i64 %1072, 56
  %1074 = or i64 %1069, %1073
  %1075 = add nsw i32 %902, -24
  %1076 = getelementptr inbounds i8, i8* %893, i64 24
  %1077 = icmp ugt i32 %1075, 7
  br i1 %1077, label %1093, label %1078

1078:                                             ; preds = %1037
  %1079 = icmp eq i32 %1075, 0
  br i1 %1079, label %.loopexit, label %.preheader18

.preheader18:                                     ; preds = %.preheader18, %1078
  %1080 = phi i32 [ %1091, %.preheader18 ], [ 0, %1078 ]
  %1081 = phi i64 [ %1090, %.preheader18 ], [ 0, %1078 ]
  %1082 = zext i32 %1080 to i64
  %1083 = getelementptr inbounds i8, i8* %1076, i64 %1082
  %1084 = load i8, i8* %1083, align 1, !tbaa !9
  %1085 = zext i8 %1084 to i64
  %1086 = shl i32 %1080, 3
  %1087 = and i32 %1086, 56
  %1088 = zext i32 %1087 to i64
  %1089 = shl nuw i64 %1085, %1088
  %1090 = or i64 %1089, %1081
  %1091 = add nuw i32 %1080, 1
  %1092 = icmp eq i32 %1091, %1075
  br i1 %1092, label %.loopexit, label %.preheader18

1093:                                             ; preds = %1037
  %1094 = load i8, i8* %1076, align 1, !tbaa !9
  %1095 = zext i8 %1094 to i64
  %1096 = getelementptr inbounds i8, i8* %893, i64 25
  %1097 = load i8, i8* %1096, align 1, !tbaa !9
  %1098 = zext i8 %1097 to i64
  %1099 = shl nuw nsw i64 %1098, 8
  %1100 = or i64 %1099, %1095
  %1101 = getelementptr inbounds i8, i8* %893, i64 26
  %1102 = load i8, i8* %1101, align 1, !tbaa !9
  %1103 = zext i8 %1102 to i64
  %1104 = shl nuw nsw i64 %1103, 16
  %1105 = or i64 %1100, %1104
  %1106 = getelementptr inbounds i8, i8* %893, i64 27
  %1107 = load i8, i8* %1106, align 1, !tbaa !9
  %1108 = zext i8 %1107 to i64
  %1109 = shl nuw nsw i64 %1108, 24
  %1110 = or i64 %1105, %1109
  %1111 = getelementptr inbounds i8, i8* %893, i64 28
  %1112 = load i8, i8* %1111, align 1, !tbaa !9
  %1113 = zext i8 %1112 to i64
  %1114 = shl nuw nsw i64 %1113, 32
  %1115 = or i64 %1110, %1114
  %1116 = getelementptr inbounds i8, i8* %893, i64 29
  %1117 = load i8, i8* %1116, align 1, !tbaa !9
  %1118 = zext i8 %1117 to i64
  %1119 = shl nuw nsw i64 %1118, 40
  %1120 = or i64 %1115, %1119
  %1121 = getelementptr inbounds i8, i8* %893, i64 30
  %1122 = load i8, i8* %1121, align 1, !tbaa !9
  %1123 = zext i8 %1122 to i64
  %1124 = shl nuw nsw i64 %1123, 48
  %1125 = or i64 %1120, %1124
  %1126 = getelementptr inbounds i8, i8* %893, i64 31
  %1127 = load i8, i8* %1126, align 1, !tbaa !9
  %1128 = zext i8 %1127 to i64
  %1129 = shl nuw i64 %1128, 56
  %1130 = or i64 %1125, %1129
  %1131 = add nsw i32 %902, -32
  %1132 = getelementptr inbounds i8, i8* %893, i64 32
  %1133 = icmp ugt i32 %1131, 7
  br i1 %1133, label %1149, label %1134

1134:                                             ; preds = %1093
  %1135 = icmp eq i32 %1131, 0
  br i1 %1135, label %.loopexit, label %.preheader16

.preheader16:                                     ; preds = %.preheader16, %1134
  %1136 = phi i32 [ %1147, %.preheader16 ], [ 0, %1134 ]
  %1137 = phi i64 [ %1146, %.preheader16 ], [ 0, %1134 ]
  %1138 = zext i32 %1136 to i64
  %1139 = getelementptr inbounds i8, i8* %1132, i64 %1138
  %1140 = load i8, i8* %1139, align 1, !tbaa !9
  %1141 = zext i8 %1140 to i64
  %1142 = shl i32 %1136, 3
  %1143 = and i32 %1142, 56
  %1144 = zext i32 %1143 to i64
  %1145 = shl nuw i64 %1141, %1144
  %1146 = or i64 %1145, %1137
  %1147 = add nuw i32 %1136, 1
  %1148 = icmp eq i32 %1147, %1131
  br i1 %1148, label %.loopexit, label %.preheader16

1149:                                             ; preds = %1093
  %1150 = load i8, i8* %1132, align 1, !tbaa !9
  %1151 = zext i8 %1150 to i64
  %1152 = getelementptr inbounds i8, i8* %893, i64 33
  %1153 = load i8, i8* %1152, align 1, !tbaa !9
  %1154 = zext i8 %1153 to i64
  %1155 = shl nuw nsw i64 %1154, 8
  %1156 = or i64 %1155, %1151
  %1157 = getelementptr inbounds i8, i8* %893, i64 34
  %1158 = load i8, i8* %1157, align 1, !tbaa !9
  %1159 = zext i8 %1158 to i64
  %1160 = shl nuw nsw i64 %1159, 16
  %1161 = or i64 %1156, %1160
  %1162 = getelementptr inbounds i8, i8* %893, i64 35
  %1163 = load i8, i8* %1162, align 1, !tbaa !9
  %1164 = zext i8 %1163 to i64
  %1165 = shl nuw nsw i64 %1164, 24
  %1166 = or i64 %1161, %1165
  %1167 = getelementptr inbounds i8, i8* %893, i64 36
  %1168 = load i8, i8* %1167, align 1, !tbaa !9
  %1169 = zext i8 %1168 to i64
  %1170 = shl nuw nsw i64 %1169, 32
  %1171 = or i64 %1166, %1170
  %1172 = getelementptr inbounds i8, i8* %893, i64 37
  %1173 = load i8, i8* %1172, align 1, !tbaa !9
  %1174 = zext i8 %1173 to i64
  %1175 = shl nuw nsw i64 %1174, 40
  %1176 = or i64 %1171, %1175
  %1177 = getelementptr inbounds i8, i8* %893, i64 38
  %1178 = load i8, i8* %1177, align 1, !tbaa !9
  %1179 = zext i8 %1178 to i64
  %1180 = shl nuw nsw i64 %1179, 48
  %1181 = or i64 %1176, %1180
  %1182 = getelementptr inbounds i8, i8* %893, i64 39
  %1183 = load i8, i8* %1182, align 1, !tbaa !9
  %1184 = zext i8 %1183 to i64
  %1185 = shl nuw i64 %1184, 56
  %1186 = or i64 %1181, %1185
  %1187 = add nsw i32 %902, -40
  %1188 = getelementptr inbounds i8, i8* %893, i64 40
  %1189 = icmp ugt i32 %1187, 7
  br i1 %1189, label %1205, label %1190

1190:                                             ; preds = %1149
  %1191 = icmp eq i32 %1187, 0
  br i1 %1191, label %.loopexit, label %.preheader14

.preheader14:                                     ; preds = %.preheader14, %1190
  %1192 = phi i32 [ %1203, %.preheader14 ], [ 0, %1190 ]
  %1193 = phi i64 [ %1202, %.preheader14 ], [ 0, %1190 ]
  %1194 = zext i32 %1192 to i64
  %1195 = getelementptr inbounds i8, i8* %1188, i64 %1194
  %1196 = load i8, i8* %1195, align 1, !tbaa !9
  %1197 = zext i8 %1196 to i64
  %1198 = shl i32 %1192, 3
  %1199 = and i32 %1198, 56
  %1200 = zext i32 %1199 to i64
  %1201 = shl nuw i64 %1197, %1200
  %1202 = or i64 %1201, %1193
  %1203 = add nuw i32 %1192, 1
  %1204 = icmp eq i32 %1203, %1187
  br i1 %1204, label %.loopexit, label %.preheader14

1205:                                             ; preds = %1149
  %1206 = load i8, i8* %1188, align 1, !tbaa !9
  %1207 = zext i8 %1206 to i64
  %1208 = getelementptr inbounds i8, i8* %893, i64 41
  %1209 = load i8, i8* %1208, align 1, !tbaa !9
  %1210 = zext i8 %1209 to i64
  %1211 = shl nuw nsw i64 %1210, 8
  %1212 = or i64 %1211, %1207
  %1213 = getelementptr inbounds i8, i8* %893, i64 42
  %1214 = load i8, i8* %1213, align 1, !tbaa !9
  %1215 = zext i8 %1214 to i64
  %1216 = shl nuw nsw i64 %1215, 16
  %1217 = or i64 %1212, %1216
  %1218 = getelementptr inbounds i8, i8* %893, i64 43
  %1219 = load i8, i8* %1218, align 1, !tbaa !9
  %1220 = zext i8 %1219 to i64
  %1221 = shl nuw nsw i64 %1220, 24
  %1222 = or i64 %1217, %1221
  %1223 = getelementptr inbounds i8, i8* %893, i64 44
  %1224 = load i8, i8* %1223, align 1, !tbaa !9
  %1225 = zext i8 %1224 to i64
  %1226 = shl nuw nsw i64 %1225, 32
  %1227 = or i64 %1222, %1226
  %1228 = getelementptr inbounds i8, i8* %893, i64 45
  %1229 = load i8, i8* %1228, align 1, !tbaa !9
  %1230 = zext i8 %1229 to i64
  %1231 = shl nuw nsw i64 %1230, 40
  %1232 = or i64 %1227, %1231
  %1233 = getelementptr inbounds i8, i8* %893, i64 46
  %1234 = load i8, i8* %1233, align 1, !tbaa !9
  %1235 = zext i8 %1234 to i64
  %1236 = shl nuw nsw i64 %1235, 48
  %1237 = or i64 %1232, %1236
  %1238 = getelementptr inbounds i8, i8* %893, i64 47
  %1239 = load i8, i8* %1238, align 1, !tbaa !9
  %1240 = zext i8 %1239 to i64
  %1241 = shl nuw i64 %1240, 56
  %1242 = or i64 %1237, %1241
  %1243 = add nsw i32 %902, -48
  %1244 = getelementptr inbounds i8, i8* %893, i64 48
  %1245 = icmp ugt i32 %1243, 7
  br i1 %1245, label %1248, label %1246

1246:                                             ; preds = %1205
  %1247 = icmp eq i32 %1243, 0
  br i1 %1247, label %.loopexit, label %.preheader

1248:                                             ; preds = %1205
  %1249 = load i8, i8* %1244, align 1, !tbaa !9
  %1250 = zext i8 %1249 to i64
  %1251 = getelementptr inbounds i8, i8* %893, i64 49
  %1252 = load i8, i8* %1251, align 1, !tbaa !9
  %1253 = zext i8 %1252 to i64
  %1254 = shl nuw nsw i64 %1253, 8
  %1255 = or i64 %1254, %1250
  %1256 = getelementptr inbounds i8, i8* %893, i64 50
  %1257 = load i8, i8* %1256, align 1, !tbaa !9
  %1258 = zext i8 %1257 to i64
  %1259 = shl nuw nsw i64 %1258, 16
  %1260 = or i64 %1255, %1259
  %1261 = getelementptr inbounds i8, i8* %893, i64 51
  %1262 = load i8, i8* %1261, align 1, !tbaa !9
  %1263 = zext i8 %1262 to i64
  %1264 = shl nuw nsw i64 %1263, 24
  %1265 = or i64 %1260, %1264
  %1266 = getelementptr inbounds i8, i8* %893, i64 52
  %1267 = load i8, i8* %1266, align 1, !tbaa !9
  %1268 = zext i8 %1267 to i64
  %1269 = shl nuw nsw i64 %1268, 32
  %1270 = or i64 %1265, %1269
  %1271 = getelementptr inbounds i8, i8* %893, i64 53
  %1272 = load i8, i8* %1271, align 1, !tbaa !9
  %1273 = zext i8 %1272 to i64
  %1274 = shl nuw nsw i64 %1273, 40
  %1275 = or i64 %1270, %1274
  %1276 = getelementptr inbounds i8, i8* %893, i64 54
  %1277 = load i8, i8* %1276, align 1, !tbaa !9
  %1278 = zext i8 %1277 to i64
  %1279 = shl nuw nsw i64 %1278, 48
  %1280 = or i64 %1275, %1279
  %1281 = getelementptr inbounds i8, i8* %893, i64 55
  %1282 = load i8, i8* %1281, align 1, !tbaa !9
  %1283 = zext i8 %1282 to i64
  %1284 = shl nuw i64 %1283, 56
  %1285 = or i64 %1280, %1284
  br label %.loopexit

.preheader:                                       ; preds = %.preheader, %1246
  %1286 = phi i32 [ %1297, %.preheader ], [ 0, %1246 ]
  %1287 = phi i64 [ %1296, %.preheader ], [ 0, %1246 ]
  %1288 = zext i32 %1286 to i64
  %1289 = getelementptr inbounds i8, i8* %1244, i64 %1288
  %1290 = load i8, i8* %1289, align 1, !tbaa !9
  %1291 = zext i8 %1290 to i64
  %1292 = shl i32 %1286, 3
  %1293 = and i32 %1292, 56
  %1294 = zext i32 %1293 to i64
  %1295 = shl nuw i64 %1291, %1294
  %1296 = or i64 %1295, %1287
  %1297 = add nuw i32 %1286, 1
  %1298 = icmp eq i32 %1297, %1243
  br i1 %1298, label %.loopexit, label %.preheader

.loopexit:                                        ; preds = %.preheader, %1248, %1246, %.preheader14, %1190, %.preheader16, %1134, %.preheader18, %1078, %.preheader20, %1022, %.preheader22, %966, %.preheader24, %910
  %1299 = phi i64 [ %1242, %1248 ], [ %1242, %1246 ], [ 0, %1190 ], [ 0, %1078 ], [ 0, %966 ], [ 0, %910 ], [ 0, %1022 ], [ 0, %1134 ], [ %1242, %.preheader ], [ %1202, %.preheader14 ], [ 0, %.preheader16 ], [ 0, %.preheader18 ], [ 0, %.preheader20 ], [ 0, %.preheader22 ], [ 0, %.preheader24 ]
  %1300 = phi i64 [ %1130, %1248 ], [ %1130, %1246 ], [ %1130, %1190 ], [ 0, %1078 ], [ 0, %966 ], [ 0, %910 ], [ 0, %1022 ], [ %1130, %1134 ], [ %1130, %.preheader ], [ %1130, %.preheader14 ], [ %1130, %.preheader16 ], [ %1090, %.preheader18 ], [ 0, %.preheader20 ], [ 0, %.preheader22 ], [ 0, %.preheader24 ]
  %1301 = phi i64 [ %1018, %1248 ], [ %1018, %1246 ], [ %1018, %1190 ], [ %1018, %1078 ], [ 0, %966 ], [ 0, %910 ], [ %1018, %1022 ], [ %1018, %1134 ], [ %1018, %.preheader ], [ %1018, %.preheader14 ], [ %1018, %.preheader16 ], [ %1018, %.preheader18 ], [ %1018, %.preheader20 ], [ %978, %.preheader22 ], [ 0, %.preheader24 ]
  %1302 = phi i64 [ %962, %1248 ], [ %962, %1246 ], [ %962, %1190 ], [ %962, %1078 ], [ %962, %966 ], [ 0, %910 ], [ %962, %1022 ], [ %962, %1134 ], [ %962, %.preheader ], [ %962, %.preheader14 ], [ %962, %.preheader16 ], [ %962, %.preheader18 ], [ %962, %.preheader20 ], [ %962, %.preheader22 ], [ %922, %.preheader24 ]
  %1303 = phi i64 [ %1074, %1248 ], [ %1074, %1246 ], [ %1074, %1190 ], [ %1074, %1078 ], [ 0, %966 ], [ 0, %910 ], [ 0, %1022 ], [ %1074, %1134 ], [ %1074, %.preheader ], [ %1074, %.preheader14 ], [ %1074, %.preheader16 ], [ %1074, %.preheader18 ], [ %1034, %.preheader20 ], [ 0, %.preheader22 ], [ 0, %.preheader24 ]
  %1304 = phi i64 [ %1186, %1248 ], [ %1186, %1246 ], [ %1186, %1190 ], [ 0, %1078 ], [ 0, %966 ], [ 0, %910 ], [ 0, %1022 ], [ 0, %1134 ], [ %1186, %.preheader ], [ %1186, %.preheader14 ], [ %1146, %.preheader16 ], [ 0, %.preheader18 ], [ 0, %.preheader20 ], [ 0, %.preheader22 ], [ 0, %.preheader24 ]
  %1305 = phi i64 [ %1285, %1248 ], [ 0, %1246 ], [ 0, %1190 ], [ 0, %1078 ], [ 0, %966 ], [ 0, %910 ], [ 0, %1022 ], [ 0, %1134 ], [ %1296, %.preheader ], [ 0, %.preheader14 ], [ 0, %.preheader16 ], [ 0, %.preheader18 ], [ 0, %.preheader20 ], [ 0, %.preheader22 ], [ 0, %.preheader24 ]
  %1306 = tail call fastcc <2 x i64> @__ockl_hostcall_internal(i8* %3, i64 %908, i64 %1302, i64 %1301, i64 %1303, i64 %1300, i64 %1304, i64 %1299, i64 %1305) #18
  %1307 = sub i64 %892, %901
  %1308 = getelementptr inbounds i8, i8* %893, i64 %901
  %1309 = icmp eq i64 %1307, 0
  br i1 %1309, label %__ockl_printf_append_string_n.exit11, label %891

__ockl_printf_append_string_n.exit11:             ; preds = %.loopexit, %strlen.join4.thread
  %1310 = phi <2 x i64> [ %883, %strlen.join4.thread ], [ %1306, %.loopexit ]
  %1311 = icmp eq i8* %__assertion, null
  br i1 %1311, label %strlen.join7, label %strlen.while8

strlen.while8:                                    ; preds = %strlen.while8, %__ockl_printf_append_string_n.exit11
  %1312 = phi i8* [ %1313, %strlen.while8 ], [ %__assertion, %__ockl_printf_append_string_n.exit11 ]
  %1313 = getelementptr i8, i8* %1312, i64 1
  %1314 = load i8, i8* %1312, align 1
  %1315 = icmp eq i8 %1314, 0
  br i1 %1315, label %strlen.while.done9, label %strlen.while8

strlen.while.done9:                               ; preds = %strlen.while8
  %1316 = ptrtoint i8* %__assertion to i64
  %1317 = ptrtoint i8* %1312 to i64
  %1318 = sub i64 1, %1316
  %1319 = add i64 %1318, %1317
  br label %strlen.join7

strlen.join7:                                     ; preds = %strlen.while.done9, %__ockl_printf_append_string_n.exit11
  %1320 = phi i64 [ %1319, %strlen.while.done9 ], [ 0, %__ockl_printf_append_string_n.exit11 ]
  %1321 = extractelement <2 x i64> %1310, i64 0
  %1322 = tail call fastcc i64 @__ockl_printf_append_string_n(i64 %1321, i8* %__assertion, i64 %1320, i32 1)
  tail call void @llvm.trap()
  unreachable
}

; Function Attrs: nounwind readnone speculatable willreturn
declare align 4 i8 addrspace(4)* @llvm.amdgcn.implicitarg.ptr() #1

; Function Attrs: convergent noinline norecurse nounwind optnone
define internal fastcc <2 x i64> @__ockl_hostcall_internal(i8* %0, i64 %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8) unnamed_addr #2 {
  %10 = alloca i8*, align 8, addrspace(5)
  %11 = alloca i32, align 4, addrspace(5)
  %12 = alloca i64, align 8, addrspace(5)
  %13 = alloca i64, align 8, addrspace(5)
  %14 = alloca i64, align 8, addrspace(5)
  %15 = alloca i64, align 8, addrspace(5)
  %16 = alloca i64, align 8, addrspace(5)
  %17 = alloca i64, align 8, addrspace(5)
  %18 = alloca i64, align 8, addrspace(5)
  %19 = alloca i64, align 8, addrspace(5)
  %20 = alloca i32, align 4, addrspace(5)
  %21 = alloca i32, align 4, addrspace(5)
  %22 = alloca %0 addrspace(1)*, align 8, addrspace(5)
  %23 = alloca i64, align 8, addrspace(5)
  %24 = alloca %1 addrspace(1)*, align 8, addrspace(5)
  %25 = alloca %2 addrspace(1)*, align 8, addrspace(5)
  %26 = alloca <2 x i64>, align 16, addrspace(5)
  store i8* %0, i8* addrspace(5)* %10, align 8, !tbaa !10
  store i32 2, i32 addrspace(5)* %11, align 4, !tbaa !12
  store i64 %1, i64 addrspace(5)* %12, align 8, !tbaa !5
  store i64 %2, i64 addrspace(5)* %13, align 8, !tbaa !5
  store i64 %3, i64 addrspace(5)* %14, align 8, !tbaa !5
  store i64 %4, i64 addrspace(5)* %15, align 8, !tbaa !5
  store i64 %5, i64 addrspace(5)* %16, align 8, !tbaa !5
  store i64 %6, i64 addrspace(5)* %17, align 8, !tbaa !5
  store i64 %7, i64 addrspace(5)* %18, align 8, !tbaa !5
  store i64 %8, i64 addrspace(5)* %19, align 8, !tbaa !5
  %27 = bitcast i32 addrspace(5)* %20 to i8 addrspace(5)*
  call void @llvm.lifetime.start.p5i8(i64 4, i8 addrspace(5)* %27) #12
  %28 = call i32 @llvm.amdgcn.mbcnt.lo(i32 -1, i32 0) #12
  %29 = call i32 @llvm.amdgcn.mbcnt.hi(i32 -1, i32 %28) #12
  store i32 %29, i32 addrspace(5)* %20, align 4, !tbaa !12
  %30 = load i32, i32 addrspace(5)* %20, align 4, !tbaa !12
  %31 = call i32 asm sideeffect "; ockl readfirstlane hoisting hack $0", "=v,0"(i32 %30) #18, !srcloc !14
  store i32 %31, i32 addrspace(5)* %20, align 4, !tbaa !12
  %32 = bitcast i32 addrspace(5)* %21 to i8 addrspace(5)*
  call void @llvm.lifetime.start.p5i8(i64 4, i8 addrspace(5)* %32) #12
  %33 = load i32, i32 addrspace(5)* %20, align 4, !tbaa !12
  %34 = call i32 @llvm.amdgcn.readfirstlane(i32 %33)
  store i32 %34, i32 addrspace(5)* %21, align 4, !tbaa !12
  %35 = bitcast %0 addrspace(1)* addrspace(5)* %22 to i8 addrspace(5)*
  call void @llvm.lifetime.start.p5i8(i64 8, i8 addrspace(5)* %35) #12
  %36 = load i8*, i8* addrspace(5)* %10, align 8, !tbaa !10
  %37 = addrspacecast i8* %36 to %0 addrspace(1)*
  store %0 addrspace(1)* %37, %0 addrspace(1)* addrspace(5)* %22, align 8, !tbaa !10
  %38 = bitcast i64 addrspace(5)* %23 to i8 addrspace(5)*
  call void @llvm.lifetime.start.p5i8(i64 8, i8 addrspace(5)* %38) #12
  %39 = load %0 addrspace(1)*, %0 addrspace(1)* addrspace(5)* %22, align 8, !tbaa !10
  %40 = load i32, i32 addrspace(5)* %20, align 4, !tbaa !12
  %41 = load i32, i32 addrspace(5)* %21, align 4, !tbaa !12
  %42 = call fastcc i64 @0(%0 addrspace(1)* %39, i32 %40, i32 %41) #19
  store i64 %42, i64 addrspace(5)* %23, align 8, !tbaa !5
  %43 = bitcast %1 addrspace(1)* addrspace(5)* %24 to i8 addrspace(5)*
  call void @llvm.lifetime.start.p5i8(i64 8, i8 addrspace(5)* %43) #12
  %44 = load %0 addrspace(1)*, %0 addrspace(1)* addrspace(5)* %22, align 8, !tbaa !10
  %45 = load i64, i64 addrspace(5)* %23, align 8, !tbaa !5
  %46 = getelementptr %0, %0 addrspace(1)* %44, i64 0, i32 0
  %47 = load %1 addrspace(1)*, %1 addrspace(1)* addrspace(1)* %46, align 8, !tbaa !15
  %48 = getelementptr %0, %0 addrspace(1)* %44, i64 0, i32 5
  %49 = load i64, i64 addrspace(1)* %48, align 8, !tbaa !18
  %50 = call fastcc %1 addrspace(1)* @1(%1 addrspace(1)* %47, i64 %49, i64 %45) #19
  store %1 addrspace(1)* %50, %1 addrspace(1)* addrspace(5)* %24, align 8, !tbaa !10
  %51 = bitcast %2 addrspace(1)* addrspace(5)* %25 to i8 addrspace(5)*
  call void @llvm.lifetime.start.p5i8(i64 8, i8 addrspace(5)* %51) #12
  %52 = load %0 addrspace(1)*, %0 addrspace(1)* addrspace(5)* %22, align 8, !tbaa !10
  %53 = load i64, i64 addrspace(5)* %23, align 8, !tbaa !5
  %54 = getelementptr %0, %0 addrspace(1)* %52, i64 0, i32 1
  %55 = load %2 addrspace(1)*, %2 addrspace(1)* addrspace(1)* %54, align 8, !tbaa !19
  %56 = getelementptr %0, %0 addrspace(1)* %52, i64 0, i32 5
  %57 = load i64, i64 addrspace(1)* %56, align 8, !tbaa !18
  %58 = call fastcc %2 addrspace(1)* @2(%2 addrspace(1)* %55, i64 %57, i64 %53) #19
  store %2 addrspace(1)* %58, %2 addrspace(1)* addrspace(5)* %25, align 8, !tbaa !10
  %59 = load %1 addrspace(1)*, %1 addrspace(1)* addrspace(5)* %24, align 8, !tbaa !10
  %60 = load %2 addrspace(1)*, %2 addrspace(1)* addrspace(5)* %25, align 8, !tbaa !10
  %61 = load i32, i32 addrspace(5)* %11, align 4, !tbaa !12
  %62 = load i64, i64 addrspace(5)* %12, align 8, !tbaa !5
  %63 = load i64, i64 addrspace(5)* %13, align 8, !tbaa !5
  %64 = load i64, i64 addrspace(5)* %14, align 8, !tbaa !5
  %65 = load i64, i64 addrspace(5)* %15, align 8, !tbaa !5
  %66 = load i64, i64 addrspace(5)* %16, align 8, !tbaa !5
  %67 = load i64, i64 addrspace(5)* %17, align 8, !tbaa !5
  %68 = load i64, i64 addrspace(5)* %18, align 8, !tbaa !5
  %69 = load i64, i64 addrspace(5)* %19, align 8, !tbaa !5
  %70 = load i32, i32 addrspace(5)* %20, align 4, !tbaa !12
  %71 = load i32, i32 addrspace(5)* %21, align 4, !tbaa !12
  call fastcc void @3(%1 addrspace(1)* %59, %2 addrspace(1)* %60, i32 %61, i64 %62, i64 %63, i64 %64, i64 %65, i64 %66, i64 %67, i64 %68, i64 %69, i32 %70, i32 %71) #19
  %72 = load %0 addrspace(1)*, %0 addrspace(1)* addrspace(5)* %22, align 8, !tbaa !10
  %73 = load i64, i64 addrspace(5)* %23, align 8, !tbaa !5
  %74 = load i32, i32 addrspace(5)* %20, align 4, !tbaa !12
  %75 = load i32, i32 addrspace(5)* %21, align 4, !tbaa !12
  call fastcc void @4(%0 addrspace(1)* %72, i64 %73, i32 %74, i32 %75) #19
  %76 = bitcast <2 x i64> addrspace(5)* %26 to i8 addrspace(5)*
  call void @llvm.lifetime.start.p5i8(i64 16, i8 addrspace(5)* %76) #12
  %77 = load %1 addrspace(1)*, %1 addrspace(1)* addrspace(5)* %24, align 8, !tbaa !10
  %78 = load %2 addrspace(1)*, %2 addrspace(1)* addrspace(5)* %25, align 8, !tbaa !10
  %79 = load i32, i32 addrspace(5)* %20, align 4, !tbaa !12
  %80 = load i32, i32 addrspace(5)* %21, align 4, !tbaa !12
  %81 = call fastcc <2 x i64> @5(%1 addrspace(1)* %77, %2 addrspace(1)* %78, i32 %79, i32 %80) #19
  store <2 x i64> %81, <2 x i64> addrspace(5)* %26, align 16, !tbaa !9
  %82 = load %0 addrspace(1)*, %0 addrspace(1)* addrspace(5)* %22, align 8, !tbaa !10
  %83 = load i64, i64 addrspace(5)* %23, align 8, !tbaa !5
  %84 = load i32, i32 addrspace(5)* %20, align 4, !tbaa !12
  %85 = load i32, i32 addrspace(5)* %21, align 4, !tbaa !12
  call fastcc void @6(%0 addrspace(1)* %82, i64 %83, i32 %84, i32 %85) #19
  %86 = load <2 x i64>, <2 x i64> addrspace(5)* %26, align 16, !tbaa !9
  %87 = bitcast <2 x i64> addrspace(5)* %26 to i8 addrspace(5)*
  call void @llvm.lifetime.end.p5i8(i64 16, i8 addrspace(5)* %87) #12
  %88 = bitcast %2 addrspace(1)* addrspace(5)* %25 to i8 addrspace(5)*
  call void @llvm.lifetime.end.p5i8(i64 8, i8 addrspace(5)* %88) #12
  %89 = bitcast %1 addrspace(1)* addrspace(5)* %24 to i8 addrspace(5)*
  call void @llvm.lifetime.end.p5i8(i64 8, i8 addrspace(5)* %89) #12
  %90 = bitcast i64 addrspace(5)* %23 to i8 addrspace(5)*
  call void @llvm.lifetime.end.p5i8(i64 8, i8 addrspace(5)* %90) #12
  %91 = bitcast %0 addrspace(1)* addrspace(5)* %22 to i8 addrspace(5)*
  call void @llvm.lifetime.end.p5i8(i64 8, i8 addrspace(5)* %91) #12
  %92 = bitcast i32 addrspace(5)* %21 to i8 addrspace(5)*
  call void @llvm.lifetime.end.p5i8(i64 4, i8 addrspace(5)* %92) #12
  %93 = bitcast i32 addrspace(5)* %20 to i8 addrspace(5)*
  call void @llvm.lifetime.end.p5i8(i64 4, i8 addrspace(5)* %93) #12
  ret <2 x i64> %86
}

; Function Attrs: convergent norecurse nounwind
define internal fastcc i64 @__ockl_printf_append_string_n(i64 %0, i8* readonly %1, i64 %2, i32 %3) unnamed_addr #3 {
  %5 = icmp eq i32 %3, 0
  %6 = or i64 %0, 2
  %7 = select i1 %5, i64 %0, i64 %6
  %8 = icmp eq i8* %1, null
  br i1 %8, label %9, label %17

9:                                                ; preds = %4
  %10 = and i64 %7, -225
  %11 = or i64 %10, 32
  %12 = tail call i8 addrspace(4)* @llvm.amdgcn.implicitarg.ptr() #12
  %13 = getelementptr inbounds i8, i8 addrspace(4)* %12, i64 24
  %14 = bitcast i8 addrspace(4)* %13 to i8* addrspace(4)*
  %15 = load i8*, i8* addrspace(4)* %14, align 8, !tbaa !5
  %16 = tail call fastcc <2 x i64> @__ockl_hostcall_internal(i8* %15, i64 %11, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0) #18
  br label %.loopexit21

17:                                               ; preds = %4
  %18 = and i64 %7, 2
  %19 = and i64 %7, -3
  %20 = insertelement <2 x i64> <i64 undef, i64 0>, i64 %19, i64 0
  %21 = tail call i8 addrspace(4)* @llvm.amdgcn.implicitarg.ptr() #12
  %22 = getelementptr inbounds i8, i8 addrspace(4)* %21, i64 24
  %23 = bitcast i8 addrspace(4)* %22 to i8* addrspace(4)*
  %24 = load i8*, i8* addrspace(4)* %23, align 8, !tbaa !5
  br label %25

25:                                               ; preds = %.loopexit, %17
  %26 = phi i64 [ %2, %17 ], [ %441, %.loopexit ]
  %27 = phi i8* [ %1, %17 ], [ %442, %.loopexit ]
  %28 = phi <2 x i64> [ %20, %17 ], [ %440, %.loopexit ]
  %29 = icmp ugt i64 %26, 56
  %30 = extractelement <2 x i64> %28, i64 0
  %31 = or i64 %30, %18
  %32 = insertelement <2 x i64> undef, i64 %31, i64 0
  %33 = select i1 %29, <2 x i64> %28, <2 x i64> %32
  %34 = icmp ult i64 %26, 56
  %35 = select i1 %34, i64 %26, i64 56
  %36 = trunc i64 %35 to i32
  %37 = extractelement <2 x i64> %33, i64 0
  %38 = add nuw nsw i64 %35, 7
  %39 = lshr i64 %38, 3
  %40 = and i64 %37, -225
  %41 = shl nuw nsw i64 %39, 5
  %42 = or i64 %40, %41
  %43 = icmp ugt i32 %36, 7
  br i1 %43, label %59, label %44

44:                                               ; preds = %25
  %45 = icmp eq i32 %36, 0
  br i1 %45, label %.loopexit, label %.preheader19

.preheader19:                                     ; preds = %.preheader19, %44
  %46 = phi i32 [ %57, %.preheader19 ], [ 0, %44 ]
  %47 = phi i64 [ %56, %.preheader19 ], [ 0, %44 ]
  %48 = zext i32 %46 to i64
  %49 = getelementptr inbounds i8, i8* %27, i64 %48
  %50 = load i8, i8* %49, align 1, !tbaa !9
  %51 = zext i8 %50 to i64
  %52 = shl i32 %46, 3
  %53 = and i32 %52, 56
  %54 = zext i32 %53 to i64
  %55 = shl nuw i64 %51, %54
  %56 = or i64 %55, %47
  %57 = add nuw nsw i32 %46, 1
  %58 = icmp eq i32 %57, %36
  br i1 %58, label %.loopexit, label %.preheader19

59:                                               ; preds = %25
  %60 = load i8, i8* %27, align 1, !tbaa !9
  %61 = zext i8 %60 to i64
  %62 = getelementptr inbounds i8, i8* %27, i64 1
  %63 = load i8, i8* %62, align 1, !tbaa !9
  %64 = zext i8 %63 to i64
  %65 = shl nuw nsw i64 %64, 8
  %66 = or i64 %65, %61
  %67 = getelementptr inbounds i8, i8* %27, i64 2
  %68 = load i8, i8* %67, align 1, !tbaa !9
  %69 = zext i8 %68 to i64
  %70 = shl nuw nsw i64 %69, 16
  %71 = or i64 %66, %70
  %72 = getelementptr inbounds i8, i8* %27, i64 3
  %73 = load i8, i8* %72, align 1, !tbaa !9
  %74 = zext i8 %73 to i64
  %75 = shl nuw nsw i64 %74, 24
  %76 = or i64 %71, %75
  %77 = getelementptr inbounds i8, i8* %27, i64 4
  %78 = load i8, i8* %77, align 1, !tbaa !9
  %79 = zext i8 %78 to i64
  %80 = shl nuw nsw i64 %79, 32
  %81 = or i64 %76, %80
  %82 = getelementptr inbounds i8, i8* %27, i64 5
  %83 = load i8, i8* %82, align 1, !tbaa !9
  %84 = zext i8 %83 to i64
  %85 = shl nuw nsw i64 %84, 40
  %86 = or i64 %81, %85
  %87 = getelementptr inbounds i8, i8* %27, i64 6
  %88 = load i8, i8* %87, align 1, !tbaa !9
  %89 = zext i8 %88 to i64
  %90 = shl nuw nsw i64 %89, 48
  %91 = or i64 %86, %90
  %92 = getelementptr inbounds i8, i8* %27, i64 7
  %93 = load i8, i8* %92, align 1, !tbaa !9
  %94 = zext i8 %93 to i64
  %95 = shl nuw i64 %94, 56
  %96 = or i64 %91, %95
  %97 = add nsw i32 %36, -8
  %98 = getelementptr inbounds i8, i8* %27, i64 8
  %99 = icmp ugt i32 %97, 7
  br i1 %99, label %115, label %100

100:                                              ; preds = %59
  %101 = icmp eq i32 %97, 0
  br i1 %101, label %.loopexit, label %.preheader17

.preheader17:                                     ; preds = %.preheader17, %100
  %102 = phi i32 [ %113, %.preheader17 ], [ 0, %100 ]
  %103 = phi i64 [ %112, %.preheader17 ], [ 0, %100 ]
  %104 = zext i32 %102 to i64
  %105 = getelementptr inbounds i8, i8* %98, i64 %104
  %106 = load i8, i8* %105, align 1, !tbaa !9
  %107 = zext i8 %106 to i64
  %108 = shl i32 %102, 3
  %109 = and i32 %108, 56
  %110 = zext i32 %109 to i64
  %111 = shl nuw i64 %107, %110
  %112 = or i64 %111, %103
  %113 = add nuw i32 %102, 1
  %114 = icmp eq i32 %113, %97
  br i1 %114, label %.loopexit, label %.preheader17

115:                                              ; preds = %59
  %116 = load i8, i8* %98, align 1, !tbaa !9
  %117 = zext i8 %116 to i64
  %118 = getelementptr inbounds i8, i8* %27, i64 9
  %119 = load i8, i8* %118, align 1, !tbaa !9
  %120 = zext i8 %119 to i64
  %121 = shl nuw nsw i64 %120, 8
  %122 = or i64 %121, %117
  %123 = getelementptr inbounds i8, i8* %27, i64 10
  %124 = load i8, i8* %123, align 1, !tbaa !9
  %125 = zext i8 %124 to i64
  %126 = shl nuw nsw i64 %125, 16
  %127 = or i64 %122, %126
  %128 = getelementptr inbounds i8, i8* %27, i64 11
  %129 = load i8, i8* %128, align 1, !tbaa !9
  %130 = zext i8 %129 to i64
  %131 = shl nuw nsw i64 %130, 24
  %132 = or i64 %127, %131
  %133 = getelementptr inbounds i8, i8* %27, i64 12
  %134 = load i8, i8* %133, align 1, !tbaa !9
  %135 = zext i8 %134 to i64
  %136 = shl nuw nsw i64 %135, 32
  %137 = or i64 %132, %136
  %138 = getelementptr inbounds i8, i8* %27, i64 13
  %139 = load i8, i8* %138, align 1, !tbaa !9
  %140 = zext i8 %139 to i64
  %141 = shl nuw nsw i64 %140, 40
  %142 = or i64 %137, %141
  %143 = getelementptr inbounds i8, i8* %27, i64 14
  %144 = load i8, i8* %143, align 1, !tbaa !9
  %145 = zext i8 %144 to i64
  %146 = shl nuw nsw i64 %145, 48
  %147 = or i64 %142, %146
  %148 = getelementptr inbounds i8, i8* %27, i64 15
  %149 = load i8, i8* %148, align 1, !tbaa !9
  %150 = zext i8 %149 to i64
  %151 = shl nuw i64 %150, 56
  %152 = or i64 %147, %151
  %153 = add nsw i32 %36, -16
  %154 = getelementptr inbounds i8, i8* %27, i64 16
  %155 = icmp ugt i32 %153, 7
  br i1 %155, label %171, label %156

156:                                              ; preds = %115
  %157 = icmp eq i32 %153, 0
  br i1 %157, label %.loopexit, label %.preheader15

.preheader15:                                     ; preds = %.preheader15, %156
  %158 = phi i32 [ %169, %.preheader15 ], [ 0, %156 ]
  %159 = phi i64 [ %168, %.preheader15 ], [ 0, %156 ]
  %160 = zext i32 %158 to i64
  %161 = getelementptr inbounds i8, i8* %154, i64 %160
  %162 = load i8, i8* %161, align 1, !tbaa !9
  %163 = zext i8 %162 to i64
  %164 = shl i32 %158, 3
  %165 = and i32 %164, 56
  %166 = zext i32 %165 to i64
  %167 = shl nuw i64 %163, %166
  %168 = or i64 %167, %159
  %169 = add nuw i32 %158, 1
  %170 = icmp eq i32 %169, %153
  br i1 %170, label %.loopexit, label %.preheader15

171:                                              ; preds = %115
  %172 = load i8, i8* %154, align 1, !tbaa !9
  %173 = zext i8 %172 to i64
  %174 = getelementptr inbounds i8, i8* %27, i64 17
  %175 = load i8, i8* %174, align 1, !tbaa !9
  %176 = zext i8 %175 to i64
  %177 = shl nuw nsw i64 %176, 8
  %178 = or i64 %177, %173
  %179 = getelementptr inbounds i8, i8* %27, i64 18
  %180 = load i8, i8* %179, align 1, !tbaa !9
  %181 = zext i8 %180 to i64
  %182 = shl nuw nsw i64 %181, 16
  %183 = or i64 %178, %182
  %184 = getelementptr inbounds i8, i8* %27, i64 19
  %185 = load i8, i8* %184, align 1, !tbaa !9
  %186 = zext i8 %185 to i64
  %187 = shl nuw nsw i64 %186, 24
  %188 = or i64 %183, %187
  %189 = getelementptr inbounds i8, i8* %27, i64 20
  %190 = load i8, i8* %189, align 1, !tbaa !9
  %191 = zext i8 %190 to i64
  %192 = shl nuw nsw i64 %191, 32
  %193 = or i64 %188, %192
  %194 = getelementptr inbounds i8, i8* %27, i64 21
  %195 = load i8, i8* %194, align 1, !tbaa !9
  %196 = zext i8 %195 to i64
  %197 = shl nuw nsw i64 %196, 40
  %198 = or i64 %193, %197
  %199 = getelementptr inbounds i8, i8* %27, i64 22
  %200 = load i8, i8* %199, align 1, !tbaa !9
  %201 = zext i8 %200 to i64
  %202 = shl nuw nsw i64 %201, 48
  %203 = or i64 %198, %202
  %204 = getelementptr inbounds i8, i8* %27, i64 23
  %205 = load i8, i8* %204, align 1, !tbaa !9
  %206 = zext i8 %205 to i64
  %207 = shl nuw i64 %206, 56
  %208 = or i64 %203, %207
  %209 = add nsw i32 %36, -24
  %210 = getelementptr inbounds i8, i8* %27, i64 24
  %211 = icmp ugt i32 %209, 7
  br i1 %211, label %227, label %212

212:                                              ; preds = %171
  %213 = icmp eq i32 %209, 0
  br i1 %213, label %.loopexit, label %.preheader13

.preheader13:                                     ; preds = %.preheader13, %212
  %214 = phi i32 [ %225, %.preheader13 ], [ 0, %212 ]
  %215 = phi i64 [ %224, %.preheader13 ], [ 0, %212 ]
  %216 = zext i32 %214 to i64
  %217 = getelementptr inbounds i8, i8* %210, i64 %216
  %218 = load i8, i8* %217, align 1, !tbaa !9
  %219 = zext i8 %218 to i64
  %220 = shl i32 %214, 3
  %221 = and i32 %220, 56
  %222 = zext i32 %221 to i64
  %223 = shl nuw i64 %219, %222
  %224 = or i64 %223, %215
  %225 = add nuw i32 %214, 1
  %226 = icmp eq i32 %225, %209
  br i1 %226, label %.loopexit, label %.preheader13

227:                                              ; preds = %171
  %228 = load i8, i8* %210, align 1, !tbaa !9
  %229 = zext i8 %228 to i64
  %230 = getelementptr inbounds i8, i8* %27, i64 25
  %231 = load i8, i8* %230, align 1, !tbaa !9
  %232 = zext i8 %231 to i64
  %233 = shl nuw nsw i64 %232, 8
  %234 = or i64 %233, %229
  %235 = getelementptr inbounds i8, i8* %27, i64 26
  %236 = load i8, i8* %235, align 1, !tbaa !9
  %237 = zext i8 %236 to i64
  %238 = shl nuw nsw i64 %237, 16
  %239 = or i64 %234, %238
  %240 = getelementptr inbounds i8, i8* %27, i64 27
  %241 = load i8, i8* %240, align 1, !tbaa !9
  %242 = zext i8 %241 to i64
  %243 = shl nuw nsw i64 %242, 24
  %244 = or i64 %239, %243
  %245 = getelementptr inbounds i8, i8* %27, i64 28
  %246 = load i8, i8* %245, align 1, !tbaa !9
  %247 = zext i8 %246 to i64
  %248 = shl nuw nsw i64 %247, 32
  %249 = or i64 %244, %248
  %250 = getelementptr inbounds i8, i8* %27, i64 29
  %251 = load i8, i8* %250, align 1, !tbaa !9
  %252 = zext i8 %251 to i64
  %253 = shl nuw nsw i64 %252, 40
  %254 = or i64 %249, %253
  %255 = getelementptr inbounds i8, i8* %27, i64 30
  %256 = load i8, i8* %255, align 1, !tbaa !9
  %257 = zext i8 %256 to i64
  %258 = shl nuw nsw i64 %257, 48
  %259 = or i64 %254, %258
  %260 = getelementptr inbounds i8, i8* %27, i64 31
  %261 = load i8, i8* %260, align 1, !tbaa !9
  %262 = zext i8 %261 to i64
  %263 = shl nuw i64 %262, 56
  %264 = or i64 %259, %263
  %265 = add nsw i32 %36, -32
  %266 = getelementptr inbounds i8, i8* %27, i64 32
  %267 = icmp ugt i32 %265, 7
  br i1 %267, label %283, label %268

268:                                              ; preds = %227
  %269 = icmp eq i32 %265, 0
  br i1 %269, label %.loopexit, label %.preheader11

.preheader11:                                     ; preds = %.preheader11, %268
  %270 = phi i32 [ %281, %.preheader11 ], [ 0, %268 ]
  %271 = phi i64 [ %280, %.preheader11 ], [ 0, %268 ]
  %272 = zext i32 %270 to i64
  %273 = getelementptr inbounds i8, i8* %266, i64 %272
  %274 = load i8, i8* %273, align 1, !tbaa !9
  %275 = zext i8 %274 to i64
  %276 = shl i32 %270, 3
  %277 = and i32 %276, 56
  %278 = zext i32 %277 to i64
  %279 = shl nuw i64 %275, %278
  %280 = or i64 %279, %271
  %281 = add nuw i32 %270, 1
  %282 = icmp eq i32 %281, %265
  br i1 %282, label %.loopexit, label %.preheader11

283:                                              ; preds = %227
  %284 = load i8, i8* %266, align 1, !tbaa !9
  %285 = zext i8 %284 to i64
  %286 = getelementptr inbounds i8, i8* %27, i64 33
  %287 = load i8, i8* %286, align 1, !tbaa !9
  %288 = zext i8 %287 to i64
  %289 = shl nuw nsw i64 %288, 8
  %290 = or i64 %289, %285
  %291 = getelementptr inbounds i8, i8* %27, i64 34
  %292 = load i8, i8* %291, align 1, !tbaa !9
  %293 = zext i8 %292 to i64
  %294 = shl nuw nsw i64 %293, 16
  %295 = or i64 %290, %294
  %296 = getelementptr inbounds i8, i8* %27, i64 35
  %297 = load i8, i8* %296, align 1, !tbaa !9
  %298 = zext i8 %297 to i64
  %299 = shl nuw nsw i64 %298, 24
  %300 = or i64 %295, %299
  %301 = getelementptr inbounds i8, i8* %27, i64 36
  %302 = load i8, i8* %301, align 1, !tbaa !9
  %303 = zext i8 %302 to i64
  %304 = shl nuw nsw i64 %303, 32
  %305 = or i64 %300, %304
  %306 = getelementptr inbounds i8, i8* %27, i64 37
  %307 = load i8, i8* %306, align 1, !tbaa !9
  %308 = zext i8 %307 to i64
  %309 = shl nuw nsw i64 %308, 40
  %310 = or i64 %305, %309
  %311 = getelementptr inbounds i8, i8* %27, i64 38
  %312 = load i8, i8* %311, align 1, !tbaa !9
  %313 = zext i8 %312 to i64
  %314 = shl nuw nsw i64 %313, 48
  %315 = or i64 %310, %314
  %316 = getelementptr inbounds i8, i8* %27, i64 39
  %317 = load i8, i8* %316, align 1, !tbaa !9
  %318 = zext i8 %317 to i64
  %319 = shl nuw i64 %318, 56
  %320 = or i64 %315, %319
  %321 = add nsw i32 %36, -40
  %322 = getelementptr inbounds i8, i8* %27, i64 40
  %323 = icmp ugt i32 %321, 7
  br i1 %323, label %339, label %324

324:                                              ; preds = %283
  %325 = icmp eq i32 %321, 0
  br i1 %325, label %.loopexit, label %.preheader9

.preheader9:                                      ; preds = %.preheader9, %324
  %326 = phi i32 [ %337, %.preheader9 ], [ 0, %324 ]
  %327 = phi i64 [ %336, %.preheader9 ], [ 0, %324 ]
  %328 = zext i32 %326 to i64
  %329 = getelementptr inbounds i8, i8* %322, i64 %328
  %330 = load i8, i8* %329, align 1, !tbaa !9
  %331 = zext i8 %330 to i64
  %332 = shl i32 %326, 3
  %333 = and i32 %332, 56
  %334 = zext i32 %333 to i64
  %335 = shl nuw i64 %331, %334
  %336 = or i64 %335, %327
  %337 = add nuw i32 %326, 1
  %338 = icmp eq i32 %337, %321
  br i1 %338, label %.loopexit, label %.preheader9

339:                                              ; preds = %283
  %340 = load i8, i8* %322, align 1, !tbaa !9
  %341 = zext i8 %340 to i64
  %342 = getelementptr inbounds i8, i8* %27, i64 41
  %343 = load i8, i8* %342, align 1, !tbaa !9
  %344 = zext i8 %343 to i64
  %345 = shl nuw nsw i64 %344, 8
  %346 = or i64 %345, %341
  %347 = getelementptr inbounds i8, i8* %27, i64 42
  %348 = load i8, i8* %347, align 1, !tbaa !9
  %349 = zext i8 %348 to i64
  %350 = shl nuw nsw i64 %349, 16
  %351 = or i64 %346, %350
  %352 = getelementptr inbounds i8, i8* %27, i64 43
  %353 = load i8, i8* %352, align 1, !tbaa !9
  %354 = zext i8 %353 to i64
  %355 = shl nuw nsw i64 %354, 24
  %356 = or i64 %351, %355
  %357 = getelementptr inbounds i8, i8* %27, i64 44
  %358 = load i8, i8* %357, align 1, !tbaa !9
  %359 = zext i8 %358 to i64
  %360 = shl nuw nsw i64 %359, 32
  %361 = or i64 %356, %360
  %362 = getelementptr inbounds i8, i8* %27, i64 45
  %363 = load i8, i8* %362, align 1, !tbaa !9
  %364 = zext i8 %363 to i64
  %365 = shl nuw nsw i64 %364, 40
  %366 = or i64 %361, %365
  %367 = getelementptr inbounds i8, i8* %27, i64 46
  %368 = load i8, i8* %367, align 1, !tbaa !9
  %369 = zext i8 %368 to i64
  %370 = shl nuw nsw i64 %369, 48
  %371 = or i64 %366, %370
  %372 = getelementptr inbounds i8, i8* %27, i64 47
  %373 = load i8, i8* %372, align 1, !tbaa !9
  %374 = zext i8 %373 to i64
  %375 = shl nuw i64 %374, 56
  %376 = or i64 %371, %375
  %377 = add nsw i32 %36, -48
  %378 = getelementptr inbounds i8, i8* %27, i64 48
  %379 = icmp ugt i32 %377, 7
  br i1 %379, label %382, label %380

380:                                              ; preds = %339
  %381 = icmp eq i32 %377, 0
  br i1 %381, label %.loopexit, label %.preheader

382:                                              ; preds = %339
  %383 = load i8, i8* %378, align 1, !tbaa !9
  %384 = zext i8 %383 to i64
  %385 = getelementptr inbounds i8, i8* %27, i64 49
  %386 = load i8, i8* %385, align 1, !tbaa !9
  %387 = zext i8 %386 to i64
  %388 = shl nuw nsw i64 %387, 8
  %389 = or i64 %388, %384
  %390 = getelementptr inbounds i8, i8* %27, i64 50
  %391 = load i8, i8* %390, align 1, !tbaa !9
  %392 = zext i8 %391 to i64
  %393 = shl nuw nsw i64 %392, 16
  %394 = or i64 %389, %393
  %395 = getelementptr inbounds i8, i8* %27, i64 51
  %396 = load i8, i8* %395, align 1, !tbaa !9
  %397 = zext i8 %396 to i64
  %398 = shl nuw nsw i64 %397, 24
  %399 = or i64 %394, %398
  %400 = getelementptr inbounds i8, i8* %27, i64 52
  %401 = load i8, i8* %400, align 1, !tbaa !9
  %402 = zext i8 %401 to i64
  %403 = shl nuw nsw i64 %402, 32
  %404 = or i64 %399, %403
  %405 = getelementptr inbounds i8, i8* %27, i64 53
  %406 = load i8, i8* %405, align 1, !tbaa !9
  %407 = zext i8 %406 to i64
  %408 = shl nuw nsw i64 %407, 40
  %409 = or i64 %404, %408
  %410 = getelementptr inbounds i8, i8* %27, i64 54
  %411 = load i8, i8* %410, align 1, !tbaa !9
  %412 = zext i8 %411 to i64
  %413 = shl nuw nsw i64 %412, 48
  %414 = or i64 %409, %413
  %415 = getelementptr inbounds i8, i8* %27, i64 55
  %416 = load i8, i8* %415, align 1, !tbaa !9
  %417 = zext i8 %416 to i64
  %418 = shl nuw i64 %417, 56
  %419 = or i64 %414, %418
  br label %.loopexit

.preheader:                                       ; preds = %.preheader, %380
  %420 = phi i32 [ %431, %.preheader ], [ 0, %380 ]
  %421 = phi i64 [ %430, %.preheader ], [ 0, %380 ]
  %422 = zext i32 %420 to i64
  %423 = getelementptr inbounds i8, i8* %378, i64 %422
  %424 = load i8, i8* %423, align 1, !tbaa !9
  %425 = zext i8 %424 to i64
  %426 = shl i32 %420, 3
  %427 = and i32 %426, 56
  %428 = zext i32 %427 to i64
  %429 = shl nuw i64 %425, %428
  %430 = or i64 %429, %421
  %431 = add nuw i32 %420, 1
  %432 = icmp eq i32 %431, %377
  br i1 %432, label %.loopexit, label %.preheader

.loopexit:                                        ; preds = %.preheader, %382, %380, %.preheader9, %324, %.preheader11, %268, %.preheader13, %212, %.preheader15, %156, %.preheader17, %100, %.preheader19, %44
  %433 = phi i64 [ %376, %382 ], [ %376, %380 ], [ 0, %324 ], [ 0, %212 ], [ 0, %100 ], [ 0, %44 ], [ 0, %156 ], [ 0, %268 ], [ %376, %.preheader ], [ %336, %.preheader9 ], [ 0, %.preheader11 ], [ 0, %.preheader13 ], [ 0, %.preheader15 ], [ 0, %.preheader17 ], [ 0, %.preheader19 ]
  %434 = phi i64 [ %264, %382 ], [ %264, %380 ], [ %264, %324 ], [ 0, %212 ], [ 0, %100 ], [ 0, %44 ], [ 0, %156 ], [ %264, %268 ], [ %264, %.preheader ], [ %264, %.preheader9 ], [ %264, %.preheader11 ], [ %224, %.preheader13 ], [ 0, %.preheader15 ], [ 0, %.preheader17 ], [ 0, %.preheader19 ]
  %435 = phi i64 [ %152, %382 ], [ %152, %380 ], [ %152, %324 ], [ %152, %212 ], [ 0, %100 ], [ 0, %44 ], [ %152, %156 ], [ %152, %268 ], [ %152, %.preheader ], [ %152, %.preheader9 ], [ %152, %.preheader11 ], [ %152, %.preheader13 ], [ %152, %.preheader15 ], [ %112, %.preheader17 ], [ 0, %.preheader19 ]
  %436 = phi i64 [ %96, %382 ], [ %96, %380 ], [ %96, %324 ], [ %96, %212 ], [ %96, %100 ], [ 0, %44 ], [ %96, %156 ], [ %96, %268 ], [ %96, %.preheader ], [ %96, %.preheader9 ], [ %96, %.preheader11 ], [ %96, %.preheader13 ], [ %96, %.preheader15 ], [ %96, %.preheader17 ], [ %56, %.preheader19 ]
  %437 = phi i64 [ %208, %382 ], [ %208, %380 ], [ %208, %324 ], [ %208, %212 ], [ 0, %100 ], [ 0, %44 ], [ 0, %156 ], [ %208, %268 ], [ %208, %.preheader ], [ %208, %.preheader9 ], [ %208, %.preheader11 ], [ %208, %.preheader13 ], [ %168, %.preheader15 ], [ 0, %.preheader17 ], [ 0, %.preheader19 ]
  %438 = phi i64 [ %320, %382 ], [ %320, %380 ], [ %320, %324 ], [ 0, %212 ], [ 0, %100 ], [ 0, %44 ], [ 0, %156 ], [ 0, %268 ], [ %320, %.preheader ], [ %320, %.preheader9 ], [ %280, %.preheader11 ], [ 0, %.preheader13 ], [ 0, %.preheader15 ], [ 0, %.preheader17 ], [ 0, %.preheader19 ]
  %439 = phi i64 [ %419, %382 ], [ 0, %380 ], [ 0, %324 ], [ 0, %212 ], [ 0, %100 ], [ 0, %44 ], [ 0, %156 ], [ 0, %268 ], [ %430, %.preheader ], [ 0, %.preheader9 ], [ 0, %.preheader11 ], [ 0, %.preheader13 ], [ 0, %.preheader15 ], [ 0, %.preheader17 ], [ 0, %.preheader19 ]
  %440 = tail call fastcc <2 x i64> @__ockl_hostcall_internal(i8* %24, i64 %42, i64 %436, i64 %435, i64 %437, i64 %434, i64 %438, i64 %433, i64 %439) #18
  %441 = sub i64 %26, %35
  %442 = getelementptr inbounds i8, i8* %27, i64 %35
  %443 = icmp eq i64 %441, 0
  br i1 %443, label %.loopexit21, label %25

.loopexit21:                                      ; preds = %.loopexit, %9
  %444 = phi <2 x i64> [ %16, %9 ], [ %440, %.loopexit ]
  %445 = extractelement <2 x i64> %444, i64 0
  ret i64 %445
}

; Function Attrs: cold noreturn nounwind
declare void @llvm.trap() #4

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p5i8(i64 immarg, i8 addrspace(5)* nocapture) #5

; Function Attrs: nounwind readnone willreturn
declare i32 @llvm.amdgcn.mbcnt.lo(i32, i32) #6

; Function Attrs: nounwind readnone willreturn
declare i32 @llvm.amdgcn.mbcnt.hi(i32, i32) #6

; Function Attrs: convergent nounwind readnone willreturn
declare i32 @llvm.amdgcn.readfirstlane(i32) #7

; Function Attrs: convergent norecurse nounwind
define internal fastcc i64 @0(%0 addrspace(1)* nocapture %0, i32 %1, i32 %2) unnamed_addr #8 {
  %4 = icmp eq i32 %1, %2
  br i1 %4, label %5, label %.loopexit

5:                                                ; preds = %3
  %6 = getelementptr inbounds %0, %0 addrspace(1)* %0, i64 0, i32 3
  %7 = load atomic i64, i64 addrspace(1)* %6 syncscope("one-as") acquire, align 8
  %8 = getelementptr %0, %0 addrspace(1)* %0, i64 0, i32 0
  %9 = load %1 addrspace(1)*, %1 addrspace(1)* addrspace(1)* %8, align 8, !tbaa !15
  %10 = getelementptr %0, %0 addrspace(1)* %0, i64 0, i32 5
  %11 = load i64, i64 addrspace(1)* %10, align 8, !tbaa !18
  %12 = and i64 %11, %7
  %13 = getelementptr inbounds %1, %1 addrspace(1)* %9, i64 %12, i32 0
  %14 = load atomic i64, i64 addrspace(1)* %13 syncscope("one-as") monotonic, align 8
  %15 = cmpxchg i64 addrspace(1)* %6, i64 %7, i64 %14 syncscope("one-as") acquire monotonic
  %16 = extractvalue { i64, i1 } %15, 1
  br i1 %16, label %.loopexit, label %.preheader

.preheader:                                       ; preds = %.preheader, %5
  %17 = phi { i64, i1 } [ %24, %.preheader ], [ %15, %5 ]
  %18 = extractvalue { i64, i1 } %17, 0
  tail call void @llvm.amdgcn.s.sleep(i32 1) #12
  %19 = load %1 addrspace(1)*, %1 addrspace(1)* addrspace(1)* %8, align 8, !tbaa !15
  %20 = load i64, i64 addrspace(1)* %10, align 8, !tbaa !18
  %21 = and i64 %20, %18
  %22 = getelementptr inbounds %1, %1 addrspace(1)* %19, i64 %21, i32 0
  %23 = load atomic i64, i64 addrspace(1)* %22 syncscope("one-as") monotonic, align 8
  %24 = cmpxchg i64 addrspace(1)* %6, i64 %18, i64 %23 syncscope("one-as") acquire monotonic
  %25 = extractvalue { i64, i1 } %24, 1
  br i1 %25, label %.loopexit.loopexit, label %.preheader

.loopexit.loopexit:                               ; preds = %.preheader
  %26 = extractvalue { i64, i1 } %17, 0
  br label %.loopexit

.loopexit:                                        ; preds = %.loopexit.loopexit, %5, %3
  %27 = phi i64 [ 0, %3 ], [ %7, %5 ], [ %26, %.loopexit.loopexit ]
  %28 = trunc i64 %27 to i32
  %29 = lshr i64 %27, 32
  %30 = trunc i64 %29 to i32
  %31 = tail call i32 @llvm.amdgcn.readfirstlane(i32 %28)
  %32 = tail call i32 @llvm.amdgcn.readfirstlane(i32 %30)
  %33 = zext i32 %32 to i64
  %34 = shl nuw i64 %33, 32
  %35 = zext i32 %31 to i64
  %36 = or i64 %34, %35
  ret i64 %36
}

; Function Attrs: norecurse nounwind readnone
define internal fastcc %1 addrspace(1)* @1(%1 addrspace(1)* readnone %0, i64 %1, i64 %2) unnamed_addr #9 {
  %4 = and i64 %2, %1
  %5 = getelementptr inbounds %1, %1 addrspace(1)* %0, i64 %4
  ret %1 addrspace(1)* %5
}

; Function Attrs: norecurse nounwind readnone
define internal fastcc %2 addrspace(1)* @2(%2 addrspace(1)* readnone %0, i64 %1, i64 %2) unnamed_addr #9 {
  %4 = and i64 %2, %1
  %5 = getelementptr inbounds %2, %2 addrspace(1)* %0, i64 %4
  ret %2 addrspace(1)* %5
}

; Function Attrs: convergent nofree norecurse nounwind
define internal fastcc void @3(%1 addrspace(1)* nocapture %0, %2 addrspace(1)* nocapture %1, i32 %2, i64 %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8, i64 %9, i64 %10, i32 %11, i32 %12) unnamed_addr #10 {
  %14 = tail call i64 @llvm.read_register.i64(metadata !20) #19
  %15 = icmp eq i32 %11, %12
  br i1 %15, label %16, label %20

16:                                               ; preds = %13
  %17 = getelementptr inbounds %1, %1 addrspace(1)* %0, i64 0, i32 2
  %18 = getelementptr inbounds %1, %1 addrspace(1)* %0, i64 0, i32 1
  %19 = getelementptr inbounds %1, %1 addrspace(1)* %0, i64 0, i32 3
  store i32 %2, i32 addrspace(1)* %17, align 8, !tbaa !21
  store i64 %14, i64 addrspace(1)* %18, align 8, !tbaa !23
  store i32 1, i32 addrspace(1)* %19, align 4, !tbaa !24
  br label %20

20:                                               ; preds = %16, %13
  %21 = zext i32 %11 to i64
  %22 = getelementptr inbounds %2, %2 addrspace(1)* %1, i64 0, i32 0, i64 %21, i64 0
  store i64 %3, i64 addrspace(1)* %22, align 8, !tbaa !5
  %23 = getelementptr inbounds %2, %2 addrspace(1)* %1, i64 0, i32 0, i64 %21, i64 1
  store i64 %4, i64 addrspace(1)* %23, align 8, !tbaa !5
  %24 = getelementptr inbounds %2, %2 addrspace(1)* %1, i64 0, i32 0, i64 %21, i64 2
  store i64 %5, i64 addrspace(1)* %24, align 8, !tbaa !5
  %25 = getelementptr inbounds %2, %2 addrspace(1)* %1, i64 0, i32 0, i64 %21, i64 3
  store i64 %6, i64 addrspace(1)* %25, align 8, !tbaa !5
  %26 = getelementptr inbounds %2, %2 addrspace(1)* %1, i64 0, i32 0, i64 %21, i64 4
  store i64 %7, i64 addrspace(1)* %26, align 8, !tbaa !5
  %27 = getelementptr inbounds %2, %2 addrspace(1)* %1, i64 0, i32 0, i64 %21, i64 5
  store i64 %8, i64 addrspace(1)* %27, align 8, !tbaa !5
  %28 = getelementptr inbounds %2, %2 addrspace(1)* %1, i64 0, i32 0, i64 %21, i64 6
  store i64 %9, i64 addrspace(1)* %28, align 8, !tbaa !5
  %29 = getelementptr inbounds %2, %2 addrspace(1)* %1, i64 0, i32 0, i64 %21, i64 7
  store i64 %10, i64 addrspace(1)* %29, align 8, !tbaa !5
  ret void
}

; Function Attrs: convergent norecurse nounwind
define internal fastcc void @4(%0 addrspace(1)* nocapture %0, i64 %1, i32 %2, i32 %3) unnamed_addr #8 {
  %5 = icmp eq i32 %2, %3
  br i1 %5, label %6, label %__ockl_hsa_signal_add.exit

6:                                                ; preds = %4
  %7 = getelementptr inbounds %0, %0 addrspace(1)* %0, i64 0, i32 4
  %8 = load atomic i64, i64 addrspace(1)* %7 syncscope("one-as") monotonic, align 8
  %9 = getelementptr %0, %0 addrspace(1)* %0, i64 0, i32 0
  %10 = load %1 addrspace(1)*, %1 addrspace(1)* addrspace(1)* %9, align 8, !tbaa !15
  %11 = getelementptr %0, %0 addrspace(1)* %0, i64 0, i32 5
  %12 = load i64, i64 addrspace(1)* %11, align 8, !tbaa !18
  %13 = and i64 %12, %1
  %14 = getelementptr inbounds %1, %1 addrspace(1)* %10, i64 %13, i32 0
  store i64 %8, i64 addrspace(1)* %14, align 8, !tbaa !25
  %15 = cmpxchg i64 addrspace(1)* %7, i64 %8, i64 %1 syncscope("one-as") release monotonic
  %16 = extractvalue { i64, i1 } %15, 1
  br i1 %16, label %.loopexit, label %.preheader

.preheader:                                       ; preds = %.preheader, %6
  %17 = phi { i64, i1 } [ %19, %.preheader ], [ %15, %6 ]
  %18 = extractvalue { i64, i1 } %17, 0
  tail call void @llvm.amdgcn.s.sleep(i32 1) #12
  store i64 %18, i64 addrspace(1)* %14, align 8, !tbaa !25
  %19 = cmpxchg i64 addrspace(1)* %7, i64 %18, i64 %1 syncscope("one-as") release monotonic
  %20 = extractvalue { i64, i1 } %19, 1
  br i1 %20, label %.loopexit, label %.preheader

.loopexit:                                        ; preds = %.preheader, %6
  %21 = getelementptr inbounds %0, %0 addrspace(1)* %0, i64 0, i32 2, i32 0
  %22 = bitcast i64 addrspace(1)* %21 to %4 addrspace(1)* addrspace(1)*
  %23 = load %4 addrspace(1)*, %4 addrspace(1)* addrspace(1)* %22, align 8
  %24 = getelementptr inbounds %4, %4 addrspace(1)* %23, i64 0, i32 1, i32 0
  %25 = atomicrmw add i64 addrspace(1)* %24, i64 1 syncscope("one-as") release
  %26 = getelementptr inbounds %4, %4 addrspace(1)* %23, i64 0, i32 2
  %27 = bitcast i64 addrspace(1)* %26 to i64 addrspace(1)* addrspace(1)*
  %28 = load i64 addrspace(1)*, i64 addrspace(1)* addrspace(1)* %27, align 16, !tbaa !26
  %29 = icmp eq i64 addrspace(1)* %28, null
  br i1 %29, label %__ockl_hsa_signal_add.exit, label %30

30:                                               ; preds = %.loopexit
  %31 = getelementptr inbounds %4, %4 addrspace(1)* %23, i64 0, i32 3
  %32 = load i32, i32 addrspace(1)* %31, align 8, !tbaa !28
  %33 = zext i32 %32 to i64
  store atomic i64 %33, i64 addrspace(1)* %28 syncscope("one-as") release, align 8
  %34 = tail call i32 @llvm.amdgcn.readfirstlane(i32 %32) #12
  %35 = and i32 %34, 255
  tail call void @llvm.amdgcn.s.sendmsg(i32 1, i32 %35) #12
  br label %__ockl_hsa_signal_add.exit

__ockl_hsa_signal_add.exit:                       ; preds = %30, %.loopexit, %4
  ret void
}

; Function Attrs: convergent norecurse nounwind
define internal fastcc <2 x i64> @5(%1 addrspace(1)* nocapture readonly %0, %2 addrspace(1)* nocapture readonly %1, i32 %2, i32 %3) unnamed_addr #3 {
  %5 = icmp eq i32 %2, %3
  %6 = getelementptr inbounds %1, %1 addrspace(1)* %0, i64 0, i32 3
  br label %7

7:                                                ; preds = %15, %4
  br i1 %5, label %8, label %11

8:                                                ; preds = %7
  %9 = load atomic i32, i32 addrspace(1)* %6 syncscope("one-as") acquire, align 4
  %10 = and i32 %9, 1
  br label %11

11:                                               ; preds = %8, %7
  %12 = phi i32 [ %10, %8 ], [ 1, %7 ]
  %13 = tail call i32 @llvm.amdgcn.readfirstlane(i32 %12)
  %14 = icmp eq i32 %13, 0
  br i1 %14, label %16, label %15

15:                                               ; preds = %11
  tail call void @llvm.amdgcn.s.sleep(i32 1)
  br label %7

16:                                               ; preds = %11
  %17 = zext i32 %2 to i64
  %18 = getelementptr inbounds %2, %2 addrspace(1)* %1, i64 0, i32 0, i64 %17, i64 0
  %19 = bitcast i64 addrspace(1)* %18 to <2 x i64> addrspace(1)*
  %20 = load <2 x i64>, <2 x i64> addrspace(1)* %19, align 8, !tbaa !5
  ret <2 x i64> %20
}

; Function Attrs: convergent norecurse nounwind
define internal fastcc void @6(%0 addrspace(1)* nocapture %0, i64 %1, i32 %2, i32 %3) unnamed_addr #8 {
  %5 = icmp eq i32 %2, %3
  br i1 %5, label %6, label %.loopexit

6:                                                ; preds = %4
  %7 = getelementptr %0, %0 addrspace(1)* %0, i64 0, i32 5
  %8 = load i64, i64 addrspace(1)* %7, align 8, !tbaa !18
  %9 = add i64 %8, 1
  %10 = add i64 %9, %1
  %11 = icmp eq i64 %10, 0
  %12 = select i1 %11, i64 %9, i64 %10
  %13 = getelementptr inbounds %0, %0 addrspace(1)* %0, i64 0, i32 3
  %14 = load atomic i64, i64 addrspace(1)* %13 syncscope("one-as") monotonic, align 8
  %15 = getelementptr %0, %0 addrspace(1)* %0, i64 0, i32 0
  %16 = load %1 addrspace(1)*, %1 addrspace(1)* addrspace(1)* %15, align 8, !tbaa !15
  %17 = and i64 %12, %8
  %18 = getelementptr inbounds %1, %1 addrspace(1)* %16, i64 %17, i32 0
  store i64 %14, i64 addrspace(1)* %18, align 8, !tbaa !25
  %19 = cmpxchg i64 addrspace(1)* %13, i64 %14, i64 %12 syncscope("one-as") release monotonic
  %20 = extractvalue { i64, i1 } %19, 1
  br i1 %20, label %.loopexit, label %.preheader

.preheader:                                       ; preds = %.preheader, %6
  %21 = phi { i64, i1 } [ %23, %.preheader ], [ %19, %6 ]
  %22 = extractvalue { i64, i1 } %21, 0
  tail call void @llvm.amdgcn.s.sleep(i32 1) #12
  store i64 %22, i64 addrspace(1)* %18, align 8, !tbaa !25
  %23 = cmpxchg i64 addrspace(1)* %13, i64 %22, i64 %12 syncscope("one-as") release monotonic
  %24 = extractvalue { i64, i1 } %23, 1
  br i1 %24, label %.loopexit, label %.preheader

.loopexit:                                        ; preds = %.preheader, %6, %4
  ret void
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p5i8(i64 immarg, i8 addrspace(5)* nocapture) #5

; Function Attrs: nounwind willreturn
declare void @llvm.amdgcn.s.sleep(i32 immarg) #11

; Function Attrs: nounwind
declare void @llvm.amdgcn.s.sendmsg(i32 immarg, i32) #12

; Function Attrs: nounwind readonly
declare i64 @llvm.read_register.i64(metadata) #13

; Function Attrs: noinline nounwind
define weak hidden void @__assertfail(i8* %__assertion, i8* %__file, i32 %__line, i8* %__function, i64 %charsize) local_unnamed_addr #14 {
entry:
  tail call void @llvm.trap()
  unreachable
}

; Function Attrs: convergent norecurse nounwind
define protected amdgpu_kernel void @evaluate(float addrspace(1)* nocapture readonly %input.coerce, float addrspace(1)* nocapture %output.coerce, i32 %n) local_unnamed_addr #15 {
entry:
  %y = alloca float, align 4, addrspace(5)
  %0 = tail call i32 @llvm.amdgcn.workgroup.id.x() #12
  %1 = tail call align 4 dereferenceable(64) i8 addrspace(4)* @llvm.amdgcn.dispatch.ptr() #12
  %2 = getelementptr i8, i8 addrspace(4)* %1, i64 4
  %3 = bitcast i8 addrspace(4)* %2 to i16 addrspace(4)*
  %4 = load i16, i16 addrspace(4)* %3, align 4, !range !29, !invariant.load !30
  %5 = zext i16 %4 to i32
  %6 = mul i32 %0, %5
  %7 = tail call i32 @llvm.amdgcn.workitem.id.x() #12, !range !31
  %add = add i32 %6, %7
  %cmp = icmp slt i32 %add, %n
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %y.ascast = addrspacecast float addrspace(5)* %y to float*
  %8 = bitcast float addrspace(5)* %y to i8 addrspace(5)*
  call void @llvm.lifetime.start.p5i8(i64 4, i8 addrspace(5)* %8) #12
  %idxprom = sext i32 %add to i64
  %arrayidx10 = getelementptr inbounds float, float addrspace(1)* %input.coerce, i64 %idxprom
  %9 = load float, float addrspace(1)* %arrayidx10, align 4, !tbaa !32
  call void @quant_decide(float %9, float 5.000000e+00, float 3.000000e+00, float* %y.ascast) #18
  %10 = bitcast float addrspace(5)* %y to i32 addrspace(5)*
  %11 = load i32, i32 addrspace(5)* %10, align 4, !tbaa !32
  %arrayidx611 = getelementptr inbounds float, float addrspace(1)* %output.coerce, i64 %idxprom
  %12 = bitcast float addrspace(1)* %arrayidx611 to i32 addrspace(1)*
  store i32 %11, i32 addrspace(1)* %12, align 4, !tbaa !32
  call void @llvm.lifetime.end.p5i8(i64 4, i8 addrspace(5)* %8) #12
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  ret void
}

; Function Attrs: nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.workgroup.id.x() #1

; Function Attrs: nounwind readnone speculatable willreturn
declare align 4 i8 addrspace(4)* @llvm.amdgcn.dispatch.ptr() #1

; Function Attrs: nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.workitem.id.x() #1

; Function Attrs: alwaysinline convergent nounwind
define hidden void @quant_decide(float %x, float %k, float %clamp_max, float* %out) local_unnamed_addr #16 {
entry:
  %0 = tail call float @llvm.fabs.f32(float %x) #12
  %cmp = fcmp ugt float %0, 2.500000e-01
  br i1 %cmp, label %if.else, label %if.then

if.then:                                          ; preds = %entry
  tail call void @g_0_0(float %x, float %k, float %clamp_max, float* %out) #18
  br label %return

if.else:                                          ; preds = %entry
  %cmp2 = fcmp olt float %0, 7.500000e-01
  br i1 %cmp2, label %if.then3, label %if.else4

if.then3:                                         ; preds = %if.else
  tail call void @g_1_1(float %x, float %k, float %clamp_max, float* %out) #18
  br label %return

if.else4:                                         ; preds = %if.else
  %cmp6 = fcmp ugt float %0, 1.250000e+00
  br i1 %cmp6, label %if.else8, label %if.then7

if.then7:                                         ; preds = %if.else4
  tail call void @g_2_2(float %x, float %k, float %clamp_max, float* %out) #18
  br label %return

if.else8:                                         ; preds = %if.else4
  %cmp10 = fcmp olt float %0, 1.750000e+00
  br i1 %cmp10, label %if.then11, label %if.else12

if.then11:                                        ; preds = %if.else8
  tail call void @g_3_3(float %x, float %k, float %clamp_max, float* %out) #18
  br label %return

if.else12:                                        ; preds = %if.else8
  %cmp14 = fcmp ugt float %0, 2.500000e+00
  br i1 %cmp14, label %if.else16, label %if.then15

if.then15:                                        ; preds = %if.else12
  tail call void @g_4_4(float %x, float %k, float %clamp_max, float* %out) #18
  br label %return

if.else16:                                        ; preds = %if.else12
  %cmp18 = fcmp olt float %0, 3.500000e+00
  br i1 %cmp18, label %if.then19, label %if.else20

if.then19:                                        ; preds = %if.else16
  tail call void @g_5_5(float %x, float %k, float %clamp_max, float* %out) #18
  br label %return

if.else20:                                        ; preds = %if.else16
  %cmp22 = fcmp ugt float %0, 5.000000e+00
  br i1 %cmp22, label %if.end29, label %if.then23

if.then23:                                        ; preds = %if.else20
  tail call void @g_6_6(float %x, float %k, float %clamp_max, float* %out) #18
  br label %return

if.end29:                                         ; preds = %if.else20
  tail call void @g_7_7(float %x, float %k, float %clamp_max, float* %out) #18
  br label %return

return:                                           ; preds = %if.end29, %if.then23, %if.then19, %if.then15, %if.then11, %if.then7, %if.then3, %if.then
  ret void
}

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.fabs.f32(float) #1

; Function Attrs: alwaysinline nofree nounwind writeonly
define hidden void @g_0_0(float %x, float %k, float %clamp_max, float* nocapture %out) local_unnamed_addr #17 {
entry:
  %0 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %x) #12
  store float %0, float* %out, align 4, !tbaa !32
  ret void
}

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.copysign.f32(float, float) #1

; Function Attrs: alwaysinline nofree nounwind writeonly
define hidden void @g_1_1(float %x, float %k, float %clamp_max, float* nocapture %out) local_unnamed_addr #17 {
entry:
  %0 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %x) #12
  store float %0, float* %out, align 4, !tbaa !32
  ret void
}

; Function Attrs: alwaysinline nofree nounwind writeonly
define hidden void @g_2_2(float %x, float %k, float %clamp_max, float* nocapture %out) local_unnamed_addr #17 {
entry:
  %0 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %x) #12
  store float %0, float* %out, align 4, !tbaa !32
  ret void
}

; Function Attrs: alwaysinline nofree nounwind writeonly
define hidden void @g_3_3(float %x, float %k, float %clamp_max, float* nocapture %out) local_unnamed_addr #17 {
entry:
  %0 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %x) #12
  store float %0, float* %out, align 4, !tbaa !32
  ret void
}

; Function Attrs: alwaysinline nofree nounwind writeonly
define hidden void @g_4_4(float %x, float %k, float %clamp_max, float* nocapture %out) local_unnamed_addr #17 {
entry:
  %0 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %x) #12
  store float %0, float* %out, align 4, !tbaa !32
  ret void
}

; Function Attrs: alwaysinline nofree nounwind writeonly
define hidden void @g_5_5(float %x, float %k, float %clamp_max, float* nocapture %out) local_unnamed_addr #17 {
entry:
  %0 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %x) #12
  store float %0, float* %out, align 4, !tbaa !32
  ret void
}

; Function Attrs: alwaysinline nofree nounwind writeonly
define hidden void @g_6_6(float %x, float %k, float %clamp_max, float* nocapture %out) local_unnamed_addr #17 {
entry:
  %0 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %x) #12
  store float %0, float* %out, align 4, !tbaa !32
  ret void
}

; Function Attrs: alwaysinline nofree nounwind writeonly
define hidden void @g_7_7(float %x, float %k, float %clamp_max, float* nocapture %out) local_unnamed_addr #17 {
entry:
  %0 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %x) #12
  store float %0, float* %out, align 4, !tbaa !32
  ret void
}

attributes #0 = { convergent noinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { convergent noinline norecurse nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { convergent norecurse nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { cold noreturn nounwind }
attributes #5 = { argmemonly nounwind willreturn }
attributes #6 = { nounwind readnone willreturn }
attributes #7 = { convergent nounwind readnone willreturn }
attributes #8 = { convergent norecurse nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #9 = { norecurse nounwind readnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #10 = { convergent nofree norecurse nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #11 = { nounwind willreturn }
attributes #12 = { nounwind }
attributes #13 = { nounwind readonly }
attributes #14 = { noinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #15 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #16 = { alwaysinline convergent nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #17 = { alwaysinline nofree nounwind writeonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #18 = { convergent nounwind }
attributes #19 = { convergent }

!opencl.ocl.version = !{!0, !0, !0, !0, !0, !0, !0, !0, !0, !0}
!llvm.ident = !{!1, !2, !1, !2, !1, !2, !1, !2, !1, !2, !1, !2, !1, !2, !1, !2, !1, !2, !1, !2}
!llvm.module.flags = !{!3, !4}

!0 = !{i32 2, i32 0}
!1 = !{!"clang version 12.0.0 (https://github.com/charitha22/cgo22ae-darm-code.git e9bc0540325ad9806313d34e84fc901496fd8be6)"}
!2 = !{!"clang version 12.0.0 (/src/external/llvm-project/clang dac2bfceaa8d4a90257dc8a6d58f268e172ce00e)"}
!3 = !{i32 1, !"wchar_size", i32 4}
!4 = !{i32 7, !"PIC Level", i32 1}
!5 = !{!6, !6, i64 0}
!6 = !{!"long", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C/C++ TBAA"}
!9 = !{!7, !7, i64 0}
!10 = !{!11, !11, i64 0}
!11 = !{!"any pointer", !7, i64 0}
!12 = !{!13, !13, i64 0}
!13 = !{!"int", !7, i64 0}
!14 = !{i32 2509}
!15 = !{!16, !11, i64 0}
!16 = !{!"", !11, i64 0, !11, i64 8, !17, i64 16, !6, i64 24, !6, i64 32, !6, i64 40}
!17 = !{!"hsa_signal_s", !6, i64 0}
!18 = !{!16, !6, i64 40}
!19 = !{!16, !11, i64 8}
!20 = !{!"exec"}
!21 = !{!22, !13, i64 16}
!22 = !{!"", !6, i64 0, !6, i64 8, !13, i64 16, !13, i64 20}
!23 = !{!22, !6, i64 8}
!24 = !{!22, !13, i64 20}
!25 = !{!22, !6, i64 0}
!26 = !{!27, !6, i64 16}
!27 = !{!"amd_signal_s", !6, i64 0, !7, i64 8, !6, i64 16, !13, i64 24, !13, i64 28, !6, i64 32, !6, i64 40, !7, i64 48, !7, i64 56}
!28 = !{!27, !13, i64 24}
!29 = !{i16 1, i16 1025}
!30 = !{}
!31 = !{i32 0, i32 1024}
!32 = !{!33, !33, i64 0}
!33 = !{!"float", !34, i64 0}
!34 = !{!"omnipotent char", !35, i64 0}
!35 = !{!"Simple C++ TBAA"}
