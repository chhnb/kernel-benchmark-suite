; ModuleID = '/home/chh/kernel-benchmark-suite/experiments/hypersonic-scoped-triangle-20261109-v1/triangle-pair/variant.ll'
source_filename = "/home/chh/kernel-benchmark-suite/cases/hypersonic/hip/source.hip"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

%struct.SimConfig = type { double, double, double, double, double, double, double, double, double, double, double, i32 }
%struct.Usoa.coerce = type { double addrspace(1)*, double addrspace(1)*, double addrspace(1)*, double addrspace(1)* }
%struct.Csoa.coerce = type { double addrspace(1)*, double addrspace(1)*, double addrspace(1)*, double addrspace(1)* }
%struct.Csoa.coerce.0 = type { double addrspace(1)*, double addrspace(1)*, double addrspace(1)*, double addrspace(1)* }
%struct.Csoa.coerce.1 = type { double addrspace(1)*, double addrspace(1)*, double addrspace(1)*, double addrspace(1)* }

@d_cfg = protected local_unnamed_addr addrspace(4) externally_initialized global %struct.SimConfig zeroinitializer, align 8

; Function Attrs: nofree norecurse nounwind
define protected amdgpu_kernel void @face_kernel(%struct.Usoa.coerce %U.coerce, i8 addrspace(1)* nocapture readonly %mask.coerce, %struct.Csoa.coerce %xL_states.coerce, %struct.Csoa.coerce.0 %xR_states.coerce, %struct.Csoa.coerce.1 %xFlux.coerce) local_unnamed_addr #0 {
entry:
  %0 = extractvalue %struct.Usoa.coerce %U.coerce, 0
  %1 = extractvalue %struct.Usoa.coerce %U.coerce, 1
  %2 = extractvalue %struct.Usoa.coerce %U.coerce, 2
  %3 = extractvalue %struct.Usoa.coerce %U.coerce, 3
  %4 = extractvalue %struct.Csoa.coerce %xL_states.coerce, 0
  %5 = extractvalue %struct.Csoa.coerce %xL_states.coerce, 1
  %6 = extractvalue %struct.Csoa.coerce %xL_states.coerce, 2
  %7 = extractvalue %struct.Csoa.coerce %xL_states.coerce, 3
  %8 = extractvalue %struct.Csoa.coerce.0 %xR_states.coerce, 0
  %9 = extractvalue %struct.Csoa.coerce.0 %xR_states.coerce, 1
  %10 = extractvalue %struct.Csoa.coerce.0 %xR_states.coerce, 2
  %11 = extractvalue %struct.Csoa.coerce.0 %xR_states.coerce, 3
  %12 = extractvalue %struct.Csoa.coerce.1 %xFlux.coerce, 0
  %13 = extractvalue %struct.Csoa.coerce.1 %xFlux.coerce, 1
  %14 = extractvalue %struct.Csoa.coerce.1 %xFlux.coerce, 2
  %15 = extractvalue %struct.Csoa.coerce.1 %xFlux.coerce, 3
  %16 = tail call i32 @llvm.amdgcn.workgroup.id.x() #2
  %17 = tail call align 4 dereferenceable(64) i8 addrspace(4)* @llvm.amdgcn.dispatch.ptr() #2
  %18 = getelementptr i8, i8 addrspace(4)* %17, i64 4
  %19 = bitcast i8 addrspace(4)* %18 to i16 addrspace(4)*
  %20 = load i16, i16 addrspace(4)* %19, align 4, !range !5, !invariant.load !6
  %21 = zext i16 %20 to i32
  %22 = mul i32 %16, %21
  %23 = tail call i32 @llvm.amdgcn.workitem.id.x() #2, !range !7
  %add = add i32 %22, %23
  %cmp = icmp sgt i32 %add, 8389631
  br i1 %cmp, label %cleanup65, label %if.end

if.end:                                           ; preds = %entry
  %add.frozen = freeze i32 %add
  %div = sdiv i32 %add.frozen, 8193
  %24 = mul i32 %div, 8193
  %rem.decomposed = sub i32 %add.frozen, %24
  %sub = add nsw i32 %rem.decomposed, -1
  %cmp8 = icmp sgt i32 %rem.decomposed, 0
  %mul.i314 = shl nsw i32 %div, 13
  br i1 %cmp8, label %land.end, label %land.end17.thread8

land.end17.thread8:                               ; preds = %if.end
  %add.i3133 = add nsw i32 %mul.i314, %rem.decomposed
  %idxprom134 = sext i32 %add.i3133 to i64
  %arrayidx141305 = getelementptr inbounds i8, i8 addrspace(1)* %mask.coerce, i64 %idxprom134
  %25 = load i8, i8 addrspace(1)* %arrayidx141305, align 1, !tbaa !8
  br label %if.else

land.end:                                         ; preds = %if.end
  %add.i315 = add nsw i32 %mul.i314, %sub
  %idxprom = sext i32 %add.i315 to i64
  %arrayidx131 = getelementptr inbounds i8, i8 addrspace(1)* %mask.coerce, i64 %idxprom
  %26 = load i8, i8 addrspace(1)* %arrayidx131, align 1, !tbaa !8
  %tobool.not = icmp eq i8 %26, 0
  %cmp10 = icmp slt i32 %rem.decomposed, 8192
  br i1 %cmp10, label %land.end17, label %if.else.thread

land.end17:                                       ; preds = %land.end
  %add.i313 = add nsw i32 %mul.i314, %rem.decomposed
  %idxprom13 = sext i32 %add.i313 to i64
  %arrayidx14130 = getelementptr inbounds i8, i8 addrspace(1)* %mask.coerce, i64 %idxprom13
  %27 = load i8, i8 addrspace(1)* %arrayidx14130, align 1, !tbaa !8
  %28 = or i8 %27, %26
  %29 = icmp eq i8 %28, 0
  br i1 %29, label %if.then21, label %if.else

if.then21:                                        ; preds = %land.end17
  %arrayidx.i302 = getelementptr inbounds double, double addrspace(1)* %8, i64 %idxprom
  %30 = load double, double addrspace(1)* %arrayidx.i302, align 8, !tbaa !11
  %arrayidx5.i303 = getelementptr inbounds double, double addrspace(1)* %9, i64 %idxprom
  %31 = load double, double addrspace(1)* %arrayidx5.i303, align 8, !tbaa !11
  %arrayidx8.i304 = getelementptr inbounds double, double addrspace(1)* %10, i64 %idxprom
  %32 = load double, double addrspace(1)* %arrayidx8.i304, align 8, !tbaa !11
  %arrayidx11.i305 = getelementptr inbounds double, double addrspace(1)* %11, i64 %idxprom
  %33 = load double, double addrspace(1)* %arrayidx11.i305, align 8, !tbaa !11
  %arrayidx.i291 = getelementptr inbounds double, double addrspace(1)* %4, i64 %idxprom13
  %34 = load double, double addrspace(1)* %arrayidx.i291, align 8, !tbaa !11
  %arrayidx5.i292 = getelementptr inbounds double, double addrspace(1)* %5, i64 %idxprom13
  %35 = load double, double addrspace(1)* %arrayidx5.i292, align 8, !tbaa !11
  %arrayidx8.i293 = getelementptr inbounds double, double addrspace(1)* %6, i64 %idxprom13
  %36 = load double, double addrspace(1)* %arrayidx8.i293, align 8, !tbaa !11
  %arrayidx11.i294 = getelementptr inbounds double, double addrspace(1)* %7, i64 %idxprom13
  %37 = load double, double addrspace(1)* %arrayidx11.i294, align 8, !tbaa !11
  br label %if.end52

if.else:                                          ; preds = %land.end17.thread8, %land.end17
  %.in = phi i8 [ %27, %land.end17 ], [ %25, %land.end17.thread8 ]
  %38 = phi i1 [ %tobool.not, %land.end17 ], [ false, %land.end17.thread8 ]
  %39 = icmp eq i8 %.in, 0
  %leaf.enter = or i1 %39, %38
  br i1 %leaf.enter, label %leaf.union, label %if.else47, !fusion.logical.arm !13

if.else.thread:                                   ; preds = %land.end
  br i1 %tobool.not, label %unify.bb, label %if.else47, !fusion.logical.arm !13

leaf.union:                                       ; preds = %if.else
  br i1 %39, label %if.then29, label %unify.bb

if.then29:                                        ; preds = %leaf.union
  %40 = icmp sgt i32 %div, 0
  %spec.store.select.i176 = select i1 %40, i32 %div, i32 0
  %cmp6.i178 = icmp slt i32 %rem.decomposed, 1
  br i1 %cmp6.i178, label %if.then7.i198, label %if.end15.i218

if.then7.i198:                                    ; preds = %if.then29
  %41 = load double, double addrspace(4)* getelementptr inbounds (%struct.SimConfig, %struct.SimConfig addrspace(4)* @d_cfg, i64 0, i32 5), align 8, !tbaa !14
  %42 = load double, double addrspace(4)* getelementptr inbounds (%struct.SimConfig, %struct.SimConfig addrspace(4)* @d_cfg, i64 0, i32 0), align 8, !tbaa !17
  %43 = fcmp olt double %42, 0x1000000000000000
  %44 = select i1 %43, double 0x4FF0000000000000, double 1.000000e+00
  %45 = fmul double %42, %44
  %46 = tail call double @llvm.amdgcn.rsq.f64(double %45) #2
  %47 = fmul double %45, %46
  %48 = fmul double %46, 5.000000e-01
  %49 = fneg double %48
  %50 = tail call double @llvm.fma.f64(double %49, double %47, double 5.000000e-01) #2
  %51 = tail call double @llvm.fma.f64(double %48, double %50, double %48) #2
  %52 = tail call double @llvm.fma.f64(double %47, double %50, double %47) #2
  %53 = fneg double %52
  %54 = tail call double @llvm.fma.f64(double %53, double %52, double %45) #2
  %55 = tail call double @llvm.fma.f64(double %54, double %51, double %52) #2
  %56 = fneg double %55
  %57 = tail call double @llvm.fma.f64(double %56, double %55, double %45) #2
  %58 = tail call double @llvm.fma.f64(double %57, double %51, double %55) #2
  %59 = select i1 %43, double 0x37F0000000000000, double 1.000000e+00
  %60 = fmul double %59, %58
  %61 = fcmp oeq double %45, 0.000000e+00
  %62 = fcmp oeq double %45, 0x7FF0000000000000
  %63 = or i1 %61, %62
  %64 = select i1 %63, double %45, double %60
  %mul1.i.i179 = fmul double %41, %64
  %sub.i74.i187 = fadd double %42, -1.000000e+00
  %div.i75.i188 = fdiv double 1.000000e+00, %sub.i74.i187
  %mul10.i77.i190 = fmul double %mul1.i.i179, %mul1.i.i179
  %add.i79.i191 = fadd double %mul10.i77.i190, 0.000000e+00
  %mul14.i80.i192 = fmul double %add.i79.i191, 5.000000e-01
  %add15.i81.i193 = fadd double %div.i75.i188, %mul14.i80.i192
  br label %unify.bb

if.end15.i218:                                    ; preds = %if.then29
  %65 = icmp slt i32 %spec.store.select.i176, 1023
  %spec.store.select1.i177 = select i1 %65, i32 %spec.store.select.i176, i32 1023
  %mul.i55.i213 = shl nuw nsw i32 %spec.store.select1.i177, 13
  %add.i56.i214 = add nuw nsw i32 %mul.i55.i213, %sub
  %idxprom.i215 = sext i32 %add.i56.i214 to i64
  %arrayidx.i216 = getelementptr inbounds i8, i8 addrspace(1)* %mask.coerce, i64 %idxprom.i215
  %66 = load i8, i8 addrspace(1)* %arrayidx.i216, align 1, !tbaa !8
  %tobool.not.i217 = icmp eq i8 %66, 0
  br i1 %tobool.not.i217, label %if.end27.i280, label %if.then17.i270

if.then17.i270:                                   ; preds = %if.end15.i218
  %mul.i53.i219 = shl nsw i32 %div, 13
  %add.i54.i220 = add nsw i32 %mul.i53.i219, %rem.decomposed
  %idxprom.i44.i221 = sext i32 %add.i54.i220 to i64
  %arrayidx.i45.i222 = getelementptr inbounds double, double addrspace(1)* %0, i64 %idxprom.i44.i221
  %67 = load double, double addrspace(1)* %arrayidx.i45.i222, align 8, !tbaa !11
  %arrayidx5.i46.i223 = getelementptr inbounds double, double addrspace(1)* %1, i64 %idxprom.i44.i221
  %68 = load double, double addrspace(1)* %arrayidx5.i46.i223, align 8, !tbaa !11
  %arrayidx8.i47.i224 = getelementptr inbounds double, double addrspace(1)* %2, i64 %idxprom.i44.i221
  %69 = load double, double addrspace(1)* %arrayidx8.i47.i224, align 8, !tbaa !11
  %arrayidx11.i48.i225 = getelementptr inbounds double, double addrspace(1)* %3, i64 %idxprom.i44.i221
  %70 = load double, double addrspace(1)* %arrayidx11.i48.i225, align 8, !tbaa !11
  %cmp.i.i32.i230 = fcmp ogt double %67, 1.000000e-25
  %cond.i.i33.i231 = select i1 %cmp.i.i32.i230, double %67, double 1.000000e-25
  %div.i34.i232 = fdiv double 1.000000e+00, %cond.i.i33.i231
  %mul.i35.i233 = fmul double %68, %div.i34.i232
  %mul3.i.i234 = fmul double %69, %div.i34.i232
  %mul4.i.i235 = fmul double %cond.i.i33.i231, 5.000000e-01
  %mul5.i.i236 = fmul double %mul.i35.i233, %mul.i35.i233
  %mul6.i36.i237 = fmul double %mul3.i.i234, %mul3.i.i234
  %add.i37.i238 = fadd double %mul5.i.i236, %mul6.i36.i237
  %mul7.i38.i239 = fmul double %mul4.i.i235, %add.i37.i238
  %sub.i39.i240 = fsub double %70, %mul7.i38.i239
  %71 = load double, double addrspace(4)* getelementptr inbounds (%struct.SimConfig, %struct.SimConfig addrspace(4)* @d_cfg, i64 0, i32 0), align 8, !tbaa !17
  %sub8.i.i241 = fadd double %71, -1.000000e+00
  %mul9.i.i242 = fmul double %sub8.i.i241, %sub.i39.i240
  %cmp.i15.i.i243 = fcmp ogt double %mul9.i.i242, 1.000000e-25
  %fneg.i.i249 = fneg double %mul.i35.i233
  %fneg5.i.i250 = fneg double %mul3.i.i234
  %cond.i11.i.i255 = select i1 %cmp.i15.i.i243, double %mul9.i.i242, double 1.000000e-25
  %mul.i.i256 = fmul double %cond.i.i33.i231, %fneg.i.i249
  %mul6.i.i257 = fmul double %cond.i.i33.i231, %fneg5.i.i250
  %div.i.i259 = fdiv double %cond.i11.i.i255, %sub8.i.i241
  %add15.i.i265 = fadd double %mul7.i38.i239, %div.i.i259
  br label %unify.bb

if.end27.i280:                                    ; preds = %if.end15.i218
  %arrayidx.i.i272 = getelementptr inbounds double, double addrspace(1)* %0, i64 %idxprom.i215
  %72 = load double, double addrspace(1)* %arrayidx.i.i272, align 8, !tbaa !11
  %arrayidx5.i.i273 = getelementptr inbounds double, double addrspace(1)* %1, i64 %idxprom.i215
  %73 = load double, double addrspace(1)* %arrayidx5.i.i273, align 8, !tbaa !11
  %arrayidx8.i.i274 = getelementptr inbounds double, double addrspace(1)* %2, i64 %idxprom.i215
  %74 = load double, double addrspace(1)* %arrayidx8.i.i274, align 8, !tbaa !11
  %arrayidx11.i.i275 = getelementptr inbounds double, double addrspace(1)* %3, i64 %idxprom.i215
  %75 = load double, double addrspace(1)* %arrayidx11.i.i275, align 8, !tbaa !11
  br label %unify.bb

unify.bb:                                         ; preds = %if.else.thread, %if.end27.i280, %if.then17.i270, %if.then7.i198, %leaf.union
  %76 = phi i1 [ true, %if.end27.i280 ], [ true, %if.then17.i270 ], [ true, %if.then7.i198 ], [ false, %leaf.union ], [ false, %if.else.thread ]
  %merged.select7 = phi double addrspace(1)* [ %7, %if.end27.i280 ], [ %7, %if.then17.i270 ], [ %7, %if.then7.i198 ], [ %11, %leaf.union ], [ %11, %if.else.thread ]
  %merged.select6 = phi double addrspace(1)* [ %6, %if.end27.i280 ], [ %6, %if.then17.i270 ], [ %6, %if.then7.i198 ], [ %10, %leaf.union ], [ %10, %if.else.thread ]
  %merged.select5 = phi double addrspace(1)* [ %5, %if.end27.i280 ], [ %5, %if.then17.i270 ], [ %5, %if.then7.i198 ], [ %9, %leaf.union ], [ %9, %if.else.thread ]
  %merged.select4 = phi double addrspace(1)* [ %4, %if.end27.i280 ], [ %4, %if.then17.i270 ], [ %4, %if.then7.i198 ], [ %8, %leaf.union ], [ %8, %if.else.thread ]
  %merged.select = phi i32 [ %rem.decomposed, %if.end27.i280 ], [ %rem.decomposed, %if.then17.i270 ], [ %rem.decomposed, %if.then7.i198 ], [ %sub, %leaf.union ], [ %sub, %if.else.thread ]
  %moved.phi3 = phi double [ %75, %if.end27.i280 ], [ %add15.i.i265, %if.then17.i270 ], [ %add15.i81.i193, %if.then7.i198 ], [ undef, %leaf.union ], [ undef, %if.else.thread ]
  %moved.phi2 = phi double [ %74, %if.end27.i280 ], [ %mul6.i.i257, %if.then17.i270 ], [ 0.000000e+00, %if.then7.i198 ], [ undef, %leaf.union ], [ undef, %if.else.thread ]
  %moved.phi1 = phi double [ %73, %if.end27.i280 ], [ %mul.i.i256, %if.then17.i270 ], [ %mul1.i.i179, %if.then7.i198 ], [ undef, %leaf.union ], [ undef, %if.else.thread ]
  %moved.phi = phi double [ %72, %if.end27.i280 ], [ %cond.i.i33.i231, %if.then17.i270 ], [ 1.000000e+00, %if.then7.i198 ], [ undef, %leaf.union ], [ undef, %if.else.thread ]
  %77 = shl nsw i32 %div, 13
  %78 = add nsw i32 %merged.select, %77
  %79 = sext i32 %78 to i64
  %80 = getelementptr inbounds double, double addrspace(1)* %merged.select4, i64 %79
  %81 = load double, double addrspace(1)* %80, align 8, !tbaa !11
  %82 = getelementptr inbounds double, double addrspace(1)* %merged.select5, i64 %79
  %83 = load double, double addrspace(1)* %82, align 8, !tbaa !11
  %84 = getelementptr inbounds double, double addrspace(1)* %merged.select6, i64 %79
  %85 = load double, double addrspace(1)* %84, align 8, !tbaa !11
  %86 = getelementptr inbounds double, double addrspace(1)* %merged.select7, i64 %79
  %87 = load double, double addrspace(1)* %86, align 8, !tbaa !11
  %88 = icmp sgt i32 %div, 0
  %89 = select i1 %88, i32 %div, i32 0
  %90 = icmp slt i32 %89, 1023
  %91 = select i1 %90, i32 %89, i32 1023
  br i1 %76, label %if.end52, label %merged.branch.split8

if.then7.i:                                       ; preds = %merged.branch.split8
  %92 = load double, double addrspace(4)* getelementptr inbounds (%struct.SimConfig, %struct.SimConfig addrspace(4)* @d_cfg, i64 0, i32 5), align 8, !tbaa !14
  %93 = load double, double addrspace(4)* getelementptr inbounds (%struct.SimConfig, %struct.SimConfig addrspace(4)* @d_cfg, i64 0, i32 0), align 8, !tbaa !17
  %94 = fcmp olt double %93, 0x1000000000000000
  %95 = select i1 %94, double 0x4FF0000000000000, double 1.000000e+00
  %96 = fmul double %93, %95
  %97 = tail call double @llvm.amdgcn.rsq.f64(double %96) #2
  %98 = fmul double %96, %97
  %99 = fmul double %97, 5.000000e-01
  %100 = fneg double %99
  %101 = tail call double @llvm.fma.f64(double %100, double %98, double 5.000000e-01) #2
  %102 = tail call double @llvm.fma.f64(double %99, double %101, double %99) #2
  %103 = tail call double @llvm.fma.f64(double %98, double %101, double %98) #2
  %104 = fneg double %103
  %105 = tail call double @llvm.fma.f64(double %104, double %103, double %96) #2
  %106 = tail call double @llvm.fma.f64(double %105, double %102, double %103) #2
  %107 = fneg double %106
  %108 = tail call double @llvm.fma.f64(double %107, double %106, double %96) #2
  %109 = tail call double @llvm.fma.f64(double %108, double %102, double %106) #2
  %110 = select i1 %94, double 0x37F0000000000000, double 1.000000e+00
  %111 = fmul double %110, %109
  %112 = fcmp oeq double %96, 0.000000e+00
  %113 = fcmp oeq double %96, 0x7FF0000000000000
  %114 = or i1 %112, %113
  %115 = select i1 %114, double %96, double %111
  %mul1.i.i = fmul double %92, %115
  %sub.i74.i = fadd double %93, -1.000000e+00
  %div.i75.i = fdiv double 1.000000e+00, %sub.i74.i
  %mul10.i77.i = fmul double %mul1.i.i, %mul1.i.i
  %add.i79.i = fadd double %mul10.i77.i, 0.000000e+00
  %mul14.i80.i = fmul double %add.i79.i, 5.000000e-01
  %add15.i81.i = fadd double %div.i75.i, %mul14.i80.i
  br label %if.end52

if.end9.i:                                        ; preds = %merged.branch.split8
  %cmp10.i = icmp sgt i32 %rem.decomposed, 8191
  %mul.i66.i = shl nuw nsw i32 %91, 13
  br i1 %cmp10.i, label %if.then11.i, label %if.end15.i

if.then11.i:                                      ; preds = %if.end9.i
  %add.i67.i = or i32 %mul.i66.i, 8191
  %idxprom.i57.i = zext i32 %add.i67.i to i64
  %arrayidx.i58.i = getelementptr inbounds double, double addrspace(1)* %0, i64 %idxprom.i57.i
  %116 = load double, double addrspace(1)* %arrayidx.i58.i, align 8, !tbaa !11
  %arrayidx5.i59.i = getelementptr inbounds double, double addrspace(1)* %1, i64 %idxprom.i57.i
  %117 = load double, double addrspace(1)* %arrayidx5.i59.i, align 8, !tbaa !11
  %arrayidx8.i60.i = getelementptr inbounds double, double addrspace(1)* %2, i64 %idxprom.i57.i
  %118 = load double, double addrspace(1)* %arrayidx8.i60.i, align 8, !tbaa !11
  %arrayidx11.i61.i = getelementptr inbounds double, double addrspace(1)* %3, i64 %idxprom.i57.i
  %119 = load double, double addrspace(1)* %arrayidx11.i61.i, align 8, !tbaa !11
  br label %if.end52

if.end15.i:                                       ; preds = %if.end9.i
  %add.i56.i = add nuw nsw i32 %mul.i66.i, %rem.decomposed
  %idxprom.i146 = sext i32 %add.i56.i to i64
  %arrayidx.i147 = getelementptr inbounds i8, i8 addrspace(1)* %mask.coerce, i64 %idxprom.i146
  %120 = load i8, i8 addrspace(1)* %arrayidx.i147, align 1, !tbaa !8
  %tobool.not.i = icmp eq i8 %120, 0
  br i1 %tobool.not.i, label %if.end27.i, label %if.then17.i

if.then17.i:                                      ; preds = %if.end15.i
  %arrayidx.i45.i = getelementptr inbounds double, double addrspace(1)* %0, i64 %79
  %121 = load double, double addrspace(1)* %arrayidx.i45.i, align 8, !tbaa !11
  %arrayidx5.i46.i = getelementptr inbounds double, double addrspace(1)* %1, i64 %79
  %122 = load double, double addrspace(1)* %arrayidx5.i46.i, align 8, !tbaa !11
  %arrayidx8.i47.i = getelementptr inbounds double, double addrspace(1)* %2, i64 %79
  %123 = load double, double addrspace(1)* %arrayidx8.i47.i, align 8, !tbaa !11
  %arrayidx11.i48.i = getelementptr inbounds double, double addrspace(1)* %3, i64 %79
  %124 = load double, double addrspace(1)* %arrayidx11.i48.i, align 8, !tbaa !11
  %cmp.i.i32.i = fcmp ogt double %121, 1.000000e-25
  %cond.i.i33.i = select i1 %cmp.i.i32.i, double %121, double 1.000000e-25
  %div.i34.i = fdiv double 1.000000e+00, %cond.i.i33.i
  %mul.i35.i = fmul double %122, %div.i34.i
  %mul3.i.i = fmul double %123, %div.i34.i
  %mul4.i.i = fmul double %cond.i.i33.i, 5.000000e-01
  %mul5.i.i = fmul double %mul.i35.i, %mul.i35.i
  %mul6.i36.i = fmul double %mul3.i.i, %mul3.i.i
  %add.i37.i = fadd double %mul5.i.i, %mul6.i36.i
  %mul7.i38.i = fmul double %mul4.i.i, %add.i37.i
  %sub.i39.i = fsub double %124, %mul7.i38.i
  %125 = load double, double addrspace(4)* getelementptr inbounds (%struct.SimConfig, %struct.SimConfig addrspace(4)* @d_cfg, i64 0, i32 0), align 8, !tbaa !17
  %sub8.i.i = fadd double %125, -1.000000e+00
  %mul9.i.i = fmul double %sub8.i.i, %sub.i39.i
  %cmp.i15.i.i = fcmp ogt double %mul9.i.i, 1.000000e-25
  %fneg.i.i = fneg double %mul.i35.i
  %fneg5.i.i = fneg double %mul3.i.i
  %cond.i11.i.i = select i1 %cmp.i15.i.i, double %mul9.i.i, double 1.000000e-25
  %mul.i.i149 = fmul double %cond.i.i33.i, %fneg.i.i
  %mul6.i.i = fmul double %cond.i.i33.i, %fneg5.i.i
  %div.i.i151 = fdiv double %cond.i11.i.i, %sub8.i.i
  %add15.i.i153 = fadd double %mul7.i38.i, %div.i.i151
  br label %if.end52

if.end27.i:                                       ; preds = %if.end15.i
  %arrayidx.i.i = getelementptr inbounds double, double addrspace(1)* %0, i64 %idxprom.i146
  %126 = load double, double addrspace(1)* %arrayidx.i.i, align 8, !tbaa !11
  %arrayidx5.i.i = getelementptr inbounds double, double addrspace(1)* %1, i64 %idxprom.i146
  %127 = load double, double addrspace(1)* %arrayidx5.i.i, align 8, !tbaa !11
  %arrayidx8.i.i = getelementptr inbounds double, double addrspace(1)* %2, i64 %idxprom.i146
  %128 = load double, double addrspace(1)* %arrayidx8.i.i, align 8, !tbaa !11
  %arrayidx11.i.i = getelementptr inbounds double, double addrspace(1)* %3, i64 %idxprom.i146
  %129 = load double, double addrspace(1)* %arrayidx11.i.i, align 8, !tbaa !11
  br label %if.end52

if.else47:                                        ; preds = %if.else.thread, %if.else
  %idxprom.i135 = sext i32 %add to i64
  %arrayidx.i136 = getelementptr inbounds double, double addrspace(1)* %12, i64 %idxprom.i135
  %130 = bitcast double addrspace(1)* %arrayidx.i136 to i64 addrspace(1)*
  store i64 0, i64 addrspace(1)* %130, align 8, !tbaa !11
  %arrayidx5.i138 = getelementptr inbounds double, double addrspace(1)* %13, i64 %idxprom.i135
  %131 = bitcast double addrspace(1)* %arrayidx5.i138 to i64 addrspace(1)*
  store i64 0, i64 addrspace(1)* %131, align 8, !tbaa !11
  %arrayidx8.i140 = getelementptr inbounds double, double addrspace(1)* %14, i64 %idxprom.i135
  %132 = bitcast double addrspace(1)* %arrayidx8.i140 to i64 addrspace(1)*
  store i64 0, i64 addrspace(1)* %132, align 8, !tbaa !11
  %arrayidx11.i142 = getelementptr inbounds double, double addrspace(1)* %15, i64 %idxprom.i135
  %133 = bitcast double addrspace(1)* %arrayidx11.i142 to i64 addrspace(1)*
  store i64 0, i64 addrspace(1)* %133, align 8, !tbaa !11
  br label %cleanup65

if.end52:                                         ; preds = %if.end27.i, %if.then17.i, %if.then11.i, %if.then7.i, %unify.bb, %if.then21
  %UR.sroa.15.0 = phi double [ %37, %if.then21 ], [ %87, %unify.bb ], [ %add15.i81.i, %if.then7.i ], [ %119, %if.then11.i ], [ %add15.i.i153, %if.then17.i ], [ %129, %if.end27.i ]
  %UR.sroa.11.0 = phi double [ %36, %if.then21 ], [ %85, %unify.bb ], [ 0.000000e+00, %if.then7.i ], [ %118, %if.then11.i ], [ %mul6.i.i, %if.then17.i ], [ %128, %if.end27.i ]
  %UR.sroa.7.0 = phi double [ %35, %if.then21 ], [ %83, %unify.bb ], [ %mul1.i.i, %if.then7.i ], [ %117, %if.then11.i ], [ %mul.i.i149, %if.then17.i ], [ %127, %if.end27.i ]
  %UR.sroa.0.0 = phi double [ %34, %if.then21 ], [ %81, %unify.bb ], [ 1.000000e+00, %if.then7.i ], [ %116, %if.then11.i ], [ %cond.i.i33.i, %if.then17.i ], [ %126, %if.end27.i ]
  %UL.sroa.15.0 = phi double [ %33, %if.then21 ], [ %moved.phi3, %unify.bb ], [ %87, %if.then7.i ], [ %87, %if.then11.i ], [ %87, %if.then17.i ], [ %87, %if.end27.i ]
  %UL.sroa.11.0 = phi double [ %32, %if.then21 ], [ %moved.phi2, %unify.bb ], [ %85, %if.then7.i ], [ %85, %if.then11.i ], [ %85, %if.then17.i ], [ %85, %if.end27.i ]
  %UL.sroa.7.0 = phi double [ %31, %if.then21 ], [ %moved.phi1, %unify.bb ], [ %83, %if.then7.i ], [ %83, %if.then11.i ], [ %83, %if.then17.i ], [ %83, %if.end27.i ]
  %UL.sroa.0.0 = phi double [ %30, %if.then21 ], [ %moved.phi, %unify.bb ], [ %81, %if.then7.i ], [ %81, %if.then11.i ], [ %81, %if.then17.i ], [ %81, %if.end27.i ]
  %cmp.i.i.i.i = fcmp ogt double %UL.sroa.0.0, 1.000000e-25
  %cond.i.i.i.i = select i1 %cmp.i.i.i.i, double %UL.sroa.0.0, double 1.000000e-25
  %div.i.i.i = fdiv double 1.000000e+00, %cond.i.i.i.i
  %mul.i.i.i = fmul double %UL.sroa.7.0, %div.i.i.i
  %mul3.i.i.i = fmul double %UL.sroa.11.0, %div.i.i.i
  %mul4.i.i.i = fmul double %cond.i.i.i.i, 5.000000e-01
  %mul5.i.i.i = fmul double %mul.i.i.i, %mul.i.i.i
  %mul6.i.i.i = fmul double %mul3.i.i.i, %mul3.i.i.i
  %add.i.i.i = fadd double %mul5.i.i.i, %mul6.i.i.i
  %mul7.i.i.i = fmul double %mul4.i.i.i, %add.i.i.i
  %sub.i.i.i = fsub double %UL.sroa.15.0, %mul7.i.i.i
  %134 = load double, double addrspace(4)* getelementptr inbounds (%struct.SimConfig, %struct.SimConfig addrspace(4)* @d_cfg, i64 0, i32 0), align 8, !tbaa !17
  %sub8.i.i.i = fadd double %134, -1.000000e+00
  %mul9.i.i.i = fmul double %sub8.i.i.i, %sub.i.i.i
  %cmp.i15.i.i.i = fcmp ogt double %mul9.i.i.i, 1.000000e-25
  %cond.i16.i.i.i = select i1 %cmp.i15.i.i.i, double %mul9.i.i.i, double 1.000000e-25
  %cmp.i.i1444.i.i = fcmp ogt double %UR.sroa.0.0, 1.000000e-25
  %cond.i.i1445.i.i = select i1 %cmp.i.i1444.i.i, double %UR.sroa.0.0, double 1.000000e-25
  %div.i1446.i.i = fdiv double 1.000000e+00, %cond.i.i1445.i.i
  %mul.i1447.i.i = fmul double %UR.sroa.7.0, %div.i1446.i.i
  %mul3.i1448.i.i = fmul double %UR.sroa.11.0, %div.i1446.i.i
  %mul4.i1449.i.i = fmul double %cond.i.i1445.i.i, 5.000000e-01
  %mul5.i1450.i.i = fmul double %mul.i1447.i.i, %mul.i1447.i.i
  %mul6.i1451.i.i = fmul double %mul3.i1448.i.i, %mul3.i1448.i.i
  %add.i1452.i.i = fadd double %mul5.i1450.i.i, %mul6.i1451.i.i
  %mul7.i1453.i.i = fmul double %mul4.i1449.i.i, %add.i1452.i.i
  %sub.i1454.i.i = fsub double %UR.sroa.15.0, %mul7.i1453.i.i
  %mul9.i1456.i.i = fmul double %sub8.i.i.i, %sub.i1454.i.i
  %cmp.i15.i1457.i.i = fcmp ogt double %mul9.i1456.i.i, 1.000000e-25
  %cond.i16.i1458.i.i = select i1 %cmp.i15.i1457.i.i, double %mul9.i1456.i.i, double 1.000000e-25
  %mul.i1438.i.i = fmul double %134, %cond.i16.i.i.i
  %div.i1441.i.i = fdiv double %mul.i1438.i.i, %cond.i.i.i.i
  %135 = fcmp olt double %div.i1441.i.i, 0x1000000000000000
  %136 = select i1 %135, double 0x4FF0000000000000, double 1.000000e+00
  %137 = fmul double %div.i1441.i.i, %136
  %138 = tail call double @llvm.amdgcn.rsq.f64(double %137) #2
  %139 = fmul double %137, %138
  %140 = fmul double %138, 5.000000e-01
  %141 = fneg double %140
  %142 = tail call double @llvm.fma.f64(double %141, double %139, double 5.000000e-01) #2
  %143 = tail call double @llvm.fma.f64(double %140, double %142, double %140) #2
  %144 = tail call double @llvm.fma.f64(double %139, double %142, double %139) #2
  %145 = fneg double %144
  %146 = tail call double @llvm.fma.f64(double %145, double %144, double %137) #2
  %147 = tail call double @llvm.fma.f64(double %146, double %143, double %144) #2
  %148 = fneg double %147
  %149 = tail call double @llvm.fma.f64(double %148, double %147, double %137) #2
  %150 = tail call double @llvm.fma.f64(double %149, double %143, double %147) #2
  %151 = select i1 %135, double 0x37F0000000000000, double 1.000000e+00
  %152 = fmul double %151, %150
  %153 = fcmp oeq double %137, 0.000000e+00
  %154 = fcmp oeq double %137, 0x7FF0000000000000
  %155 = or i1 %153, %154
  %156 = select i1 %155, double %137, double %152
  %mul.i1434.i.i = fmul double %134, %cond.i16.i1458.i.i
  %div.i1435.i.i = fdiv double %mul.i1434.i.i, %cond.i.i1445.i.i
  %157 = fcmp olt double %div.i1435.i.i, 0x1000000000000000
  %158 = select i1 %157, double 0x4FF0000000000000, double 1.000000e+00
  %159 = fmul double %div.i1435.i.i, %158
  %160 = tail call double @llvm.amdgcn.rsq.f64(double %159) #2
  %161 = fmul double %159, %160
  %162 = fmul double %160, 5.000000e-01
  %163 = fneg double %162
  %164 = tail call double @llvm.fma.f64(double %163, double %161, double 5.000000e-01) #2
  %165 = tail call double @llvm.fma.f64(double %162, double %164, double %162) #2
  %166 = tail call double @llvm.fma.f64(double %161, double %164, double %161) #2
  %167 = fneg double %166
  %168 = tail call double @llvm.fma.f64(double %167, double %166, double %159) #2
  %169 = tail call double @llvm.fma.f64(double %168, double %165, double %166) #2
  %170 = fneg double %169
  %171 = tail call double @llvm.fma.f64(double %170, double %169, double %159) #2
  %172 = tail call double @llvm.fma.f64(double %171, double %165, double %169) #2
  %173 = select i1 %157, double 0x37F0000000000000, double 1.000000e+00
  %174 = fmul double %173, %172
  %175 = fcmp oeq double %159, 0.000000e+00
  %176 = fcmp oeq double %159, 0x7FF0000000000000
  %177 = or i1 %175, %176
  %178 = select i1 %177, double %159, double %174
  %sub.i.i = fsub double %mul.i.i.i, %156
  %sub13.i.i = fsub double %mul.i1447.i.i, %178
  %cmp.i1430.i.i = fcmp olt double %sub.i.i, %sub13.i.i
  %cond.i1431.i.i = select i1 %cmp.i1430.i.i, double %sub.i.i, double %sub13.i.i
  %add.i.i = fadd double %mul.i.i.i, %156
  %add15.i.i = fadd double %mul.i1447.i.i, %178
  %cmp.i1428.i.i = fcmp ogt double %add.i.i, %add15.i.i
  %cond.i1429.i.i = select i1 %cmp.i1428.i.i, double %add.i.i, double %add15.i.i
  %mul.i1419.i.i = fmul double %UL.sroa.7.0, %mul.i.i.i
  %add.i1420.i.i = fadd double %mul.i1419.i.i, %cond.i16.i.i.i
  %mul6.i1421.i.i = fmul double %UL.sroa.11.0, %mul.i.i.i
  %add9.i1422.i.i = fadd double %UL.sroa.15.0, %cond.i16.i.i.i
  %mul10.i1423.i.i = fmul double %mul.i.i.i, %add9.i1422.i.i
  %mul.i1391.i.i = fmul double %UR.sroa.7.0, %mul.i1447.i.i
  %add.i1392.i.i = fadd double %mul.i1391.i.i, %cond.i16.i1458.i.i
  %mul6.i1393.i.i = fmul double %UR.sroa.11.0, %mul.i1447.i.i
  %add9.i.i.i = fadd double %UR.sroa.15.0, %cond.i16.i1458.i.i
  %mul10.i.i.i = fmul double %mul.i1447.i.i, %add9.i.i.i
  %cmp.i.i = fcmp ult double %cond.i1431.i.i, 0.000000e+00
  br i1 %cmp.i.i, label %if.end.i.i, label %_Z6hllc_x4ConsS_.exit

if.end.i.i:                                       ; preds = %if.end52
  %cmp21.i.i = fcmp ugt double %cond.i1429.i.i, 0.000000e+00
  br i1 %cmp21.i.i, label %if.end23.i.i, label %_Z6hllc_x4ConsS_.exit

if.end23.i.i:                                     ; preds = %if.end.i.i
  %sub26.i.i = fsub double %cond.i16.i1458.i.i, %cond.i16.i.i.i
  %mul.i.i = fmul double %cond.i.i.i.i, %mul.i.i.i
  %sub27.i.i = fsub double %cond.i1431.i.i, %mul.i.i.i
  %mul28.i.i = fmul double %mul.i.i, %sub27.i.i
  %add29.i.i = fadd double %sub26.i.i, %mul28.i.i
  %mul30.i.i = fmul double %cond.i.i1445.i.i, %mul.i1447.i.i
  %sub31.i.i = fsub double %cond.i1429.i.i, %mul.i1447.i.i
  %mul32.i.i = fmul double %mul30.i.i, %sub31.i.i
  %sub33.i.i = fsub double %add29.i.i, %mul32.i.i
  %mul35.i.i = fmul double %cond.i.i.i.i, %sub27.i.i
  %mul37.i.i = fmul double %cond.i.i1445.i.i, %sub31.i.i
  %sub38.i.i = fsub double %mul35.i.i, %mul37.i.i
  %cmp.i1368.i.i = fcmp olt double %sub38.i.i, 0.000000e+00
  %fneg.i1369.i.i = fneg double %sub38.i.i
  %cond.i1370.i.i = select i1 %cmp.i1368.i.i, double %fneg.i1369.i.i, double %sub38.i.i
  %cmp40.i.i = fcmp olt double %cond.i1370.i.i, 0x3D06849B86A12B9B
  br i1 %cmp40.i.i, label %if.end21.i1281.i.i, label %lor.lhs.false.i.i

lor.lhs.false.i.i:                                ; preds = %if.end23.i.i
  %179 = tail call i1 @llvm.amdgcn.class.f64(double %sub33.i.i, i32 504) #2
  br i1 %179, label %lor.lhs.false42.i.i, label %if.end21.i1281.i.i

lor.lhs.false42.i.i:                              ; preds = %lor.lhs.false.i.i
  %180 = tail call i1 @llvm.amdgcn.class.f64(double %sub38.i.i, i32 504) #2
  br i1 %180, label %if.end48.i.i, label %if.end21.i1281.i.i

if.end21.i1281.i.i:                               ; preds = %lor.lhs.false42.i.i, %lor.lhs.false.i.i, %if.end23.i.i
  %sub22.i1276.i.i = fsub double %cond.i1429.i.i, %cond.i1431.i.i
  %cmp.i.i1277.i.i = fcmp olt double %sub22.i1276.i.i, 0.000000e+00
  %fneg.i.i1278.i.i = fneg double %sub22.i1276.i.i
  %cond.i.i1279.i.i = select i1 %cmp.i.i1277.i.i, double %fneg.i.i1278.i.i, double %sub22.i1276.i.i
  %cmp24.i1280.i.i = fcmp olt double %cond.i.i1279.i.i, 0x3D06849B86A12B9B
  br i1 %cmp24.i1280.i.i, label %if.then25.i1298.i.i, label %if.end31.i1358.i.i

if.then25.i1298.i.i:                              ; preds = %if.end21.i1281.i.i
  %add.i147.i1282.i.i = fadd double %UR.sroa.7.0, %UL.sroa.7.0
  %add7.i148.i1283.i.i = fadd double %add.i1392.i.i, %add.i1420.i.i
  %add10.i149.i1284.i.i = fadd double %mul6.i1393.i.i, %mul6.i1421.i.i
  %add13.i150.i1285.i.i = fadd double %mul10.i.i.i, %mul10.i1423.i.i
  %mul.i139.i1290.i.i = fmul double %add.i147.i1282.i.i, 5.000000e-01
  %mul4.i140.i1291.i.i = fmul double %add7.i148.i1283.i.i, 5.000000e-01
  %mul6.i141.i1292.i.i = fmul double %add10.i149.i1284.i.i, 5.000000e-01
  %mul8.i142.i1293.i.i = fmul double %add13.i150.i1285.i.i, 5.000000e-01
  br label %_Z6hllc_x4ConsS_.exit

if.end31.i1358.i.i:                               ; preds = %if.end21.i1281.i.i
  %mul.i131.i1299.i.i = fmul double %UL.sroa.7.0, %cond.i1429.i.i
  %mul4.i132.i1300.i.i = fmul double %add.i1420.i.i, %cond.i1429.i.i
  %mul6.i133.i1301.i.i = fmul double %mul6.i1421.i.i, %cond.i1429.i.i
  %mul8.i134.i1302.i.i = fmul double %mul10.i1423.i.i, %cond.i1429.i.i
  %mul.i1316.i.i = fmul double %cond.i1431.i.i, %cond.i1429.i.i
  %sub.i118.i1317.i.i = fsub double %UR.sroa.0.0, %UL.sroa.0.0
  %sub7.i.i1318.i.i = fsub double %UR.sroa.7.0, %UL.sroa.7.0
  %sub10.i.i1319.i.i = fsub double %UR.sroa.11.0, %UL.sroa.11.0
  %sub13.i.i1320.i.i = fsub double %UR.sroa.15.0, %UL.sroa.15.0
  %mul.i110.i1325.i.i = fmul double %sub.i118.i1317.i.i, %mul.i1316.i.i
  %mul4.i111.i1326.i.i = fmul double %sub7.i.i1318.i.i, %mul.i1316.i.i
  %mul6.i112.i1327.i.i = fmul double %sub10.i.i1319.i.i, %mul.i1316.i.i
  %mul8.i113.i1328.i.i = fmul double %sub13.i.i1320.i.i, %mul.i1316.i.i
  %div.i1333.i.i = fdiv double 1.000000e+00, %sub22.i1276.i.i
  %181 = fmul double %UR.sroa.7.0, %cond.i1431.i.i
  %add.i102.i1334.i.i = fsub double %mul.i131.i1299.i.i, %181
  %182 = fmul double %add.i1392.i.i, %cond.i1431.i.i
  %add7.i103.i1335.i.i = fsub double %mul4.i132.i1300.i.i, %182
  %183 = fmul double %mul6.i1393.i.i, %cond.i1431.i.i
  %add10.i104.i1336.i.i = fsub double %mul6.i133.i1301.i.i, %183
  %184 = fmul double %mul10.i.i.i, %cond.i1431.i.i
  %add13.i105.i1337.i.i = fsub double %mul8.i134.i1302.i.i, %184
  %add.i97.i1342.i.i = fadd double %add.i102.i1334.i.i, %mul.i110.i1325.i.i
  %add7.i.i1343.i.i = fadd double %add7.i103.i1335.i.i, %mul4.i111.i1326.i.i
  %add10.i.i1344.i.i = fadd double %add10.i104.i1336.i.i, %mul6.i112.i1327.i.i
  %add13.i.i1345.i.i = fadd double %add13.i105.i1337.i.i, %mul8.i113.i1328.i.i
  %mul.i90.i1350.i.i = fmul double %div.i1333.i.i, %add.i97.i1342.i.i
  %mul4.i91.i1351.i.i = fmul double %div.i1333.i.i, %add7.i.i1343.i.i
  %mul6.i92.i1352.i.i = fmul double %div.i1333.i.i, %add10.i.i1344.i.i
  %mul8.i.i1353.i.i = fmul double %div.i1333.i.i, %add13.i.i1345.i.i
  br label %_Z6hllc_x4ConsS_.exit

if.end48.i.i:                                     ; preds = %lor.lhs.false42.i.i
  %div.i.i = fdiv double %sub33.i.i, %sub38.i.i
  %185 = tail call i1 @llvm.amdgcn.class.f64(double %div.i.i, i32 504) #2
  br i1 %185, label %if.end54.i.i, label %if.end21.i1048.i.i

if.end21.i1048.i.i:                               ; preds = %if.end48.i.i
  %sub22.i1043.i.i = fsub double %cond.i1429.i.i, %cond.i1431.i.i
  %cmp.i.i1044.i.i = fcmp olt double %sub22.i1043.i.i, 0.000000e+00
  %fneg.i.i1045.i.i = fneg double %sub22.i1043.i.i
  %cond.i.i1046.i.i = select i1 %cmp.i.i1044.i.i, double %fneg.i.i1045.i.i, double %sub22.i1043.i.i
  %cmp24.i1047.i.i = fcmp olt double %cond.i.i1046.i.i, 0x3D06849B86A12B9B
  br i1 %cmp24.i1047.i.i, label %if.then25.i1065.i.i, label %if.end31.i1125.i.i

if.then25.i1065.i.i:                              ; preds = %if.end21.i1048.i.i
  %add.i147.i1049.i.i = fadd double %UR.sroa.7.0, %UL.sroa.7.0
  %add7.i148.i1050.i.i = fadd double %add.i1392.i.i, %add.i1420.i.i
  %add10.i149.i1051.i.i = fadd double %mul6.i1393.i.i, %mul6.i1421.i.i
  %add13.i150.i1052.i.i = fadd double %mul10.i.i.i, %mul10.i1423.i.i
  %mul.i139.i1057.i.i = fmul double %add.i147.i1049.i.i, 5.000000e-01
  %mul4.i140.i1058.i.i = fmul double %add7.i148.i1050.i.i, 5.000000e-01
  %mul6.i141.i1059.i.i = fmul double %add10.i149.i1051.i.i, 5.000000e-01
  %mul8.i142.i1060.i.i = fmul double %add13.i150.i1052.i.i, 5.000000e-01
  br label %_Z6hllc_x4ConsS_.exit

if.end31.i1125.i.i:                               ; preds = %if.end21.i1048.i.i
  %mul.i131.i1066.i.i = fmul double %UL.sroa.7.0, %cond.i1429.i.i
  %mul4.i132.i1067.i.i = fmul double %add.i1420.i.i, %cond.i1429.i.i
  %mul6.i133.i1068.i.i = fmul double %mul6.i1421.i.i, %cond.i1429.i.i
  %mul8.i134.i1069.i.i = fmul double %mul10.i1423.i.i, %cond.i1429.i.i
  %mul.i1083.i.i = fmul double %cond.i1431.i.i, %cond.i1429.i.i
  %sub.i118.i1084.i.i = fsub double %UR.sroa.0.0, %UL.sroa.0.0
  %sub7.i.i1085.i.i = fsub double %UR.sroa.7.0, %UL.sroa.7.0
  %sub10.i.i1086.i.i = fsub double %UR.sroa.11.0, %UL.sroa.11.0
  %sub13.i.i1087.i.i = fsub double %UR.sroa.15.0, %UL.sroa.15.0
  %mul.i110.i1092.i.i = fmul double %sub.i118.i1084.i.i, %mul.i1083.i.i
  %mul4.i111.i1093.i.i = fmul double %sub7.i.i1085.i.i, %mul.i1083.i.i
  %mul6.i112.i1094.i.i = fmul double %sub10.i.i1086.i.i, %mul.i1083.i.i
  %mul8.i113.i1095.i.i = fmul double %sub13.i.i1087.i.i, %mul.i1083.i.i
  %div.i1100.i.i = fdiv double 1.000000e+00, %sub22.i1043.i.i
  %186 = fmul double %UR.sroa.7.0, %cond.i1431.i.i
  %add.i102.i1101.i.i = fsub double %mul.i131.i1066.i.i, %186
  %187 = fmul double %add.i1392.i.i, %cond.i1431.i.i
  %add7.i103.i1102.i.i = fsub double %mul4.i132.i1067.i.i, %187
  %188 = fmul double %mul6.i1393.i.i, %cond.i1431.i.i
  %add10.i104.i1103.i.i = fsub double %mul6.i133.i1068.i.i, %188
  %189 = fmul double %mul10.i.i.i, %cond.i1431.i.i
  %add13.i105.i1104.i.i = fsub double %mul8.i134.i1069.i.i, %189
  %add.i97.i1109.i.i = fadd double %add.i102.i1101.i.i, %mul.i110.i1092.i.i
  %add7.i.i1110.i.i = fadd double %add7.i103.i1102.i.i, %mul4.i111.i1093.i.i
  %add10.i.i1111.i.i = fadd double %add10.i104.i1103.i.i, %mul6.i112.i1094.i.i
  %add13.i.i1112.i.i = fadd double %add13.i105.i1104.i.i, %mul8.i113.i1095.i.i
  %mul.i90.i1117.i.i = fmul double %div.i1100.i.i, %add.i97.i1109.i.i
  %mul4.i91.i1118.i.i = fmul double %div.i1100.i.i, %add7.i.i1110.i.i
  %mul6.i92.i1119.i.i = fmul double %div.i1100.i.i, %add10.i.i1111.i.i
  %mul8.i.i1120.i.i = fmul double %div.i1100.i.i, %add13.i.i1112.i.i
  br label %_Z6hllc_x4ConsS_.exit

if.end54.i.i:                                     ; preds = %if.end48.i.i
  %sub57.i.i = fsub double %div.i.i, %mul.i.i.i
  %mul58.i.i = fmul double %mul35.i.i, %sub57.i.i
  %add59.i.i = fadd double %cond.i16.i.i.i, %mul58.i.i
  %cmp.i900.i.i = fcmp ogt double %add59.i.i, 1.000000e-25
  %cond.i901.i.i = select i1 %cmp.i900.i.i, double %add59.i.i, double 1.000000e-25
  %sub61.i.i = fsub double %cond.i1431.i.i, %div.i.i
  %sub62.i.i = fsub double %cond.i1429.i.i, %div.i.i
  %cmp.i897.i.i = fcmp olt double %sub61.i.i, 0.000000e+00
  %fneg.i898.i.i = fneg double %sub61.i.i
  %cond.i899.i.i = select i1 %cmp.i897.i.i, double %fneg.i898.i.i, double %sub61.i.i
  %cmp64.i.i = fcmp olt double %cond.i899.i.i, 0x3D06849B86A12B9B
  br i1 %cmp64.i.i, label %if.end21.i808.i.i, label %lor.lhs.false65.i.i

lor.lhs.false65.i.i:                              ; preds = %if.end54.i.i
  %cmp.i895.i.i = fcmp olt double %sub62.i.i, 0.000000e+00
  %fneg.i896.i.i = fneg double %sub62.i.i
  %cond.i.i.i = select i1 %cmp.i895.i.i, double %fneg.i896.i.i, double %sub62.i.i
  %cmp67.i.i = fcmp olt double %cond.i.i.i, 0x3D06849B86A12B9B
  br i1 %cmp67.i.i, label %if.end21.i808.i.i, label %if.end72.i.i

if.end21.i808.i.i:                                ; preds = %lor.lhs.false65.i.i, %if.end54.i.i
  %sub22.i803.i.i = fsub double %cond.i1429.i.i, %cond.i1431.i.i
  %cmp.i.i804.i.i = fcmp olt double %sub22.i803.i.i, 0.000000e+00
  %fneg.i.i805.i.i = fneg double %sub22.i803.i.i
  %cond.i.i806.i.i = select i1 %cmp.i.i804.i.i, double %fneg.i.i805.i.i, double %sub22.i803.i.i
  %cmp24.i807.i.i = fcmp olt double %cond.i.i806.i.i, 0x3D06849B86A12B9B
  br i1 %cmp24.i807.i.i, label %if.then25.i825.i.i, label %if.end31.i885.i.i

if.then25.i825.i.i:                               ; preds = %if.end21.i808.i.i
  %add.i147.i809.i.i = fadd double %UR.sroa.7.0, %UL.sroa.7.0
  %add7.i148.i810.i.i = fadd double %add.i1392.i.i, %add.i1420.i.i
  %add10.i149.i811.i.i = fadd double %mul6.i1393.i.i, %mul6.i1421.i.i
  %add13.i150.i812.i.i = fadd double %mul10.i.i.i, %mul10.i1423.i.i
  %mul.i139.i817.i.i = fmul double %add.i147.i809.i.i, 5.000000e-01
  %mul4.i140.i818.i.i = fmul double %add7.i148.i810.i.i, 5.000000e-01
  %mul6.i141.i819.i.i = fmul double %add10.i149.i811.i.i, 5.000000e-01
  %mul8.i142.i820.i.i = fmul double %add13.i150.i812.i.i, 5.000000e-01
  br label %_Z6hllc_x4ConsS_.exit

if.end31.i885.i.i:                                ; preds = %if.end21.i808.i.i
  %mul.i131.i826.i.i = fmul double %UL.sroa.7.0, %cond.i1429.i.i
  %mul4.i132.i827.i.i = fmul double %add.i1420.i.i, %cond.i1429.i.i
  %mul6.i133.i828.i.i = fmul double %mul6.i1421.i.i, %cond.i1429.i.i
  %mul8.i134.i829.i.i = fmul double %mul10.i1423.i.i, %cond.i1429.i.i
  %mul.i843.i.i = fmul double %cond.i1431.i.i, %cond.i1429.i.i
  %sub.i118.i844.i.i = fsub double %UR.sroa.0.0, %UL.sroa.0.0
  %sub7.i.i845.i.i = fsub double %UR.sroa.7.0, %UL.sroa.7.0
  %sub10.i.i846.i.i = fsub double %UR.sroa.11.0, %UL.sroa.11.0
  %sub13.i.i847.i.i = fsub double %UR.sroa.15.0, %UL.sroa.15.0
  %mul.i110.i852.i.i = fmul double %sub.i118.i844.i.i, %mul.i843.i.i
  %mul4.i111.i853.i.i = fmul double %sub7.i.i845.i.i, %mul.i843.i.i
  %mul6.i112.i854.i.i = fmul double %sub10.i.i846.i.i, %mul.i843.i.i
  %mul8.i113.i855.i.i = fmul double %sub13.i.i847.i.i, %mul.i843.i.i
  %div.i860.i.i = fdiv double 1.000000e+00, %sub22.i803.i.i
  %190 = fmul double %UR.sroa.7.0, %cond.i1431.i.i
  %add.i102.i861.i.i = fsub double %mul.i131.i826.i.i, %190
  %191 = fmul double %add.i1392.i.i, %cond.i1431.i.i
  %add7.i103.i862.i.i = fsub double %mul4.i132.i827.i.i, %191
  %192 = fmul double %mul6.i1393.i.i, %cond.i1431.i.i
  %add10.i104.i863.i.i = fsub double %mul6.i133.i828.i.i, %192
  %193 = fmul double %mul10.i.i.i, %cond.i1431.i.i
  %add13.i105.i864.i.i = fsub double %mul8.i134.i829.i.i, %193
  %add.i97.i869.i.i = fadd double %add.i102.i861.i.i, %mul.i110.i852.i.i
  %add7.i.i870.i.i = fadd double %add7.i103.i862.i.i, %mul4.i111.i853.i.i
  %add10.i.i871.i.i = fadd double %add10.i104.i863.i.i, %mul6.i112.i854.i.i
  %add13.i.i872.i.i = fadd double %add13.i105.i864.i.i, %mul8.i113.i855.i.i
  %mul.i90.i877.i.i = fmul double %div.i860.i.i, %add.i97.i869.i.i
  %mul4.i91.i878.i.i = fmul double %div.i860.i.i, %add7.i.i870.i.i
  %mul6.i92.i879.i.i = fmul double %div.i860.i.i, %add10.i.i871.i.i
  %mul8.i.i880.i.i = fmul double %div.i860.i.i, %add13.i.i872.i.i
  br label %_Z6hllc_x4ConsS_.exit

if.end72.i.i:                                     ; preds = %lor.lhs.false65.i.i
  %div75.i.i = fdiv double %mul35.i.i, %sub61.i.i
  %div78.i.i = fdiv double %mul37.i.i, %sub62.i.i
  %cmp79.i.i = fcmp ogt double %div75.i.i, 0.000000e+00
  %cmp81.i.i = fcmp ogt double %div78.i.i, 0.000000e+00
  %or.cond.i.i = and i1 %cmp79.i.i, %cmp81.i.i
  br i1 %or.cond.i.i, label %lor.lhs.false82.i.i, label %if.end21.i575.i.i

lor.lhs.false82.i.i:                              ; preds = %if.end72.i.i
  %194 = tail call i1 @llvm.amdgcn.class.f64(double %div75.i.i, i32 504) #2
  br i1 %194, label %lor.lhs.false84.i.i, label %if.end21.i575.i.i

lor.lhs.false84.i.i:                              ; preds = %lor.lhs.false82.i.i
  %195 = tail call i1 @llvm.amdgcn.class.f64(double %div78.i.i, i32 504) #2
  br i1 %195, label %if.end90.i.i, label %if.end21.i575.i.i

if.end21.i575.i.i:                                ; preds = %lor.lhs.false84.i.i, %lor.lhs.false82.i.i, %if.end72.i.i
  %sub22.i570.i.i = fsub double %cond.i1429.i.i, %cond.i1431.i.i
  %cmp.i.i571.i.i = fcmp olt double %sub22.i570.i.i, 0.000000e+00
  %fneg.i.i572.i.i = fneg double %sub22.i570.i.i
  %cond.i.i573.i.i = select i1 %cmp.i.i571.i.i, double %fneg.i.i572.i.i, double %sub22.i570.i.i
  %cmp24.i574.i.i = fcmp olt double %cond.i.i573.i.i, 0x3D06849B86A12B9B
  br i1 %cmp24.i574.i.i, label %if.then25.i592.i.i, label %if.end31.i652.i.i

if.then25.i592.i.i:                               ; preds = %if.end21.i575.i.i
  %add.i147.i576.i.i = fadd double %UR.sroa.7.0, %UL.sroa.7.0
  %add7.i148.i577.i.i = fadd double %add.i1392.i.i, %add.i1420.i.i
  %add10.i149.i578.i.i = fadd double %mul6.i1393.i.i, %mul6.i1421.i.i
  %add13.i150.i579.i.i = fadd double %mul10.i.i.i, %mul10.i1423.i.i
  %mul.i139.i584.i.i = fmul double %add.i147.i576.i.i, 5.000000e-01
  %mul4.i140.i585.i.i = fmul double %add7.i148.i577.i.i, 5.000000e-01
  %mul6.i141.i586.i.i = fmul double %add10.i149.i578.i.i, 5.000000e-01
  %mul8.i142.i587.i.i = fmul double %add13.i150.i579.i.i, 5.000000e-01
  br label %_Z6hllc_x4ConsS_.exit

if.end31.i652.i.i:                                ; preds = %if.end21.i575.i.i
  %mul.i131.i593.i.i = fmul double %UL.sroa.7.0, %cond.i1429.i.i
  %mul4.i132.i594.i.i = fmul double %add.i1420.i.i, %cond.i1429.i.i
  %mul6.i133.i595.i.i = fmul double %mul6.i1421.i.i, %cond.i1429.i.i
  %mul8.i134.i596.i.i = fmul double %mul10.i1423.i.i, %cond.i1429.i.i
  %mul.i610.i.i = fmul double %cond.i1431.i.i, %cond.i1429.i.i
  %sub.i118.i611.i.i = fsub double %UR.sroa.0.0, %UL.sroa.0.0
  %sub7.i.i612.i.i = fsub double %UR.sroa.7.0, %UL.sroa.7.0
  %sub10.i.i613.i.i = fsub double %UR.sroa.11.0, %UL.sroa.11.0
  %sub13.i.i614.i.i = fsub double %UR.sroa.15.0, %UL.sroa.15.0
  %mul.i110.i619.i.i = fmul double %sub.i118.i611.i.i, %mul.i610.i.i
  %mul4.i111.i620.i.i = fmul double %sub7.i.i612.i.i, %mul.i610.i.i
  %mul6.i112.i621.i.i = fmul double %sub10.i.i613.i.i, %mul.i610.i.i
  %mul8.i113.i622.i.i = fmul double %sub13.i.i614.i.i, %mul.i610.i.i
  %div.i627.i.i = fdiv double 1.000000e+00, %sub22.i570.i.i
  %196 = fmul double %UR.sroa.7.0, %cond.i1431.i.i
  %add.i102.i628.i.i = fsub double %mul.i131.i593.i.i, %196
  %197 = fmul double %add.i1392.i.i, %cond.i1431.i.i
  %add7.i103.i629.i.i = fsub double %mul4.i132.i594.i.i, %197
  %198 = fmul double %mul6.i1393.i.i, %cond.i1431.i.i
  %add10.i104.i630.i.i = fsub double %mul6.i133.i595.i.i, %198
  %199 = fmul double %mul10.i.i.i, %cond.i1431.i.i
  %add13.i105.i631.i.i = fsub double %mul8.i134.i596.i.i, %199
  %add.i97.i636.i.i = fadd double %add.i102.i628.i.i, %mul.i110.i619.i.i
  %add7.i.i637.i.i = fadd double %add7.i103.i629.i.i, %mul4.i111.i620.i.i
  %add10.i.i638.i.i = fadd double %add10.i104.i630.i.i, %mul6.i112.i621.i.i
  %add13.i.i639.i.i = fadd double %add13.i105.i631.i.i, %mul8.i113.i622.i.i
  %mul.i90.i644.i.i = fmul double %div.i627.i.i, %add.i97.i636.i.i
  %mul4.i91.i645.i.i = fmul double %div.i627.i.i, %add7.i.i637.i.i
  %mul6.i92.i646.i.i = fmul double %div.i627.i.i, %add10.i.i638.i.i
  %mul8.i.i647.i.i = fmul double %div.i627.i.i, %add13.i.i639.i.i
  br label %_Z6hllc_x4ConsS_.exit

if.end90.i.i:                                     ; preds = %lor.lhs.false84.i.i
  %mul91.i.i = fmul double %div.i.i, %div75.i.i
  %mul92.i.i = fmul double %mul3.i.i.i, %div75.i.i
  %mul94.i.i = fmul double %UL.sroa.15.0, %sub27.i.i
  %mul95.i.i = fmul double %mul.i.i.i, %cond.i16.i.i.i
  %sub96.i.i = fsub double %mul94.i.i, %mul95.i.i
  %mul97.i.i = fmul double %div.i.i, %cond.i901.i.i
  %add98.i.i = fadd double %sub96.i.i, %mul97.i.i
  %div99.i.i = fdiv double %add98.i.i, %sub61.i.i
  %200 = tail call i1 @llvm.amdgcn.class.f64(double %div99.i.i, i32 504) #2
  br i1 %200, label %if.end105.i.i, label %if.end21.i342.i.i

if.end21.i342.i.i:                                ; preds = %if.end90.i.i
  %sub22.i337.i.i = fsub double %cond.i1429.i.i, %cond.i1431.i.i
  %cmp.i.i338.i.i = fcmp olt double %sub22.i337.i.i, 0.000000e+00
  %fneg.i.i339.i.i = fneg double %sub22.i337.i.i
  %cond.i.i340.i.i = select i1 %cmp.i.i338.i.i, double %fneg.i.i339.i.i, double %sub22.i337.i.i
  %cmp24.i341.i.i = fcmp olt double %cond.i.i340.i.i, 0x3D06849B86A12B9B
  br i1 %cmp24.i341.i.i, label %if.then25.i359.i.i, label %if.end31.i419.i.i

if.then25.i359.i.i:                               ; preds = %if.end21.i342.i.i
  %add.i147.i343.i.i = fadd double %UR.sroa.7.0, %UL.sroa.7.0
  %add7.i148.i344.i.i = fadd double %add.i1392.i.i, %add.i1420.i.i
  %add10.i149.i345.i.i = fadd double %mul6.i1393.i.i, %mul6.i1421.i.i
  %add13.i150.i346.i.i = fadd double %mul10.i.i.i, %mul10.i1423.i.i
  %mul.i139.i351.i.i = fmul double %add.i147.i343.i.i, 5.000000e-01
  %mul4.i140.i352.i.i = fmul double %add7.i148.i344.i.i, 5.000000e-01
  %mul6.i141.i353.i.i = fmul double %add10.i149.i345.i.i, 5.000000e-01
  %mul8.i142.i354.i.i = fmul double %add13.i150.i346.i.i, 5.000000e-01
  br label %_Z6hllc_x4ConsS_.exit

if.end31.i419.i.i:                                ; preds = %if.end21.i342.i.i
  %mul.i131.i360.i.i = fmul double %UL.sroa.7.0, %cond.i1429.i.i
  %mul4.i132.i361.i.i = fmul double %add.i1420.i.i, %cond.i1429.i.i
  %mul6.i133.i362.i.i = fmul double %mul6.i1421.i.i, %cond.i1429.i.i
  %mul8.i134.i363.i.i = fmul double %mul10.i1423.i.i, %cond.i1429.i.i
  %mul.i377.i.i = fmul double %cond.i1431.i.i, %cond.i1429.i.i
  %sub.i118.i378.i.i = fsub double %UR.sroa.0.0, %UL.sroa.0.0
  %sub7.i.i379.i.i = fsub double %UR.sroa.7.0, %UL.sroa.7.0
  %sub10.i.i380.i.i = fsub double %UR.sroa.11.0, %UL.sroa.11.0
  %sub13.i.i381.i.i = fsub double %UR.sroa.15.0, %UL.sroa.15.0
  %mul.i110.i386.i.i = fmul double %sub.i118.i378.i.i, %mul.i377.i.i
  %mul4.i111.i387.i.i = fmul double %sub7.i.i379.i.i, %mul.i377.i.i
  %mul6.i112.i388.i.i = fmul double %sub10.i.i380.i.i, %mul.i377.i.i
  %mul8.i113.i389.i.i = fmul double %sub13.i.i381.i.i, %mul.i377.i.i
  %div.i394.i.i = fdiv double 1.000000e+00, %sub22.i337.i.i
  %201 = fmul double %UR.sroa.7.0, %cond.i1431.i.i
  %add.i102.i395.i.i = fsub double %mul.i131.i360.i.i, %201
  %202 = fmul double %add.i1392.i.i, %cond.i1431.i.i
  %add7.i103.i396.i.i = fsub double %mul4.i132.i361.i.i, %202
  %203 = fmul double %mul6.i1393.i.i, %cond.i1431.i.i
  %add10.i104.i397.i.i = fsub double %mul6.i133.i362.i.i, %203
  %204 = fmul double %mul10.i.i.i, %cond.i1431.i.i
  %add13.i105.i398.i.i = fsub double %mul8.i134.i363.i.i, %204
  %add.i97.i403.i.i = fadd double %add.i102.i395.i.i, %mul.i110.i386.i.i
  %add7.i.i404.i.i = fadd double %add7.i103.i396.i.i, %mul4.i111.i387.i.i
  %add10.i.i405.i.i = fadd double %add10.i104.i397.i.i, %mul6.i112.i388.i.i
  %add13.i.i406.i.i = fadd double %add13.i105.i398.i.i, %mul8.i113.i389.i.i
  %mul.i90.i411.i.i = fmul double %div.i394.i.i, %add.i97.i403.i.i
  %mul4.i91.i412.i.i = fmul double %div.i394.i.i, %add7.i.i404.i.i
  %mul6.i92.i413.i.i = fmul double %div.i394.i.i, %add10.i.i405.i.i
  %mul8.i.i414.i.i = fmul double %div.i394.i.i, %add13.i.i406.i.i
  br label %_Z6hllc_x4ConsS_.exit

if.end105.i.i:                                    ; preds = %if.end90.i.i
  %mul112.i.i = fmul double %div.i.i, %div78.i.i
  %mul113.i.i = fmul double %mul3.i1448.i.i, %div78.i.i
  %mul116.i.i = fmul double %UR.sroa.15.0, %sub31.i.i
  %mul117.i.i = fmul double %mul.i1447.i.i, %cond.i16.i1458.i.i
  %sub118.i.i = fsub double %mul116.i.i, %mul117.i.i
  %add120.i.i = fadd double %sub118.i.i, %mul97.i.i
  %div121.i.i = fdiv double %add120.i.i, %sub62.i.i
  %205 = tail call i1 @llvm.amdgcn.class.f64(double %div121.i.i, i32 504) #2
  br i1 %205, label %if.end127.i.i, label %if.end21.i.i.i

if.end21.i.i.i:                                   ; preds = %if.end105.i.i
  %sub22.i.i.i = fsub double %cond.i1429.i.i, %cond.i1431.i.i
  %cmp.i.i188.i.i = fcmp olt double %sub22.i.i.i, 0.000000e+00
  %fneg.i.i.i.i = fneg double %sub22.i.i.i
  %cond.i.i189.i.i = select i1 %cmp.i.i188.i.i, double %fneg.i.i.i.i, double %sub22.i.i.i
  %cmp24.i.i.i = fcmp olt double %cond.i.i189.i.i, 0x3D06849B86A12B9B
  br i1 %cmp24.i.i.i, label %if.then25.i.i.i, label %if.end31.i.i.i

if.then25.i.i.i:                                  ; preds = %if.end21.i.i.i
  %add.i147.i.i.i = fadd double %UR.sroa.7.0, %UL.sroa.7.0
  %add7.i148.i.i.i = fadd double %add.i1392.i.i, %add.i1420.i.i
  %add10.i149.i.i.i = fadd double %mul6.i1393.i.i, %mul6.i1421.i.i
  %add13.i150.i.i.i = fadd double %mul10.i.i.i, %mul10.i1423.i.i
  %mul.i139.i.i.i = fmul double %add.i147.i.i.i, 5.000000e-01
  %mul4.i140.i.i.i = fmul double %add7.i148.i.i.i, 5.000000e-01
  %mul6.i141.i.i.i = fmul double %add10.i149.i.i.i, 5.000000e-01
  %mul8.i142.i.i.i = fmul double %add13.i150.i.i.i, 5.000000e-01
  br label %_Z6hllc_x4ConsS_.exit

if.end31.i.i.i:                                   ; preds = %if.end21.i.i.i
  %mul.i131.i.i.i = fmul double %UL.sroa.7.0, %cond.i1429.i.i
  %mul4.i132.i.i.i = fmul double %add.i1420.i.i, %cond.i1429.i.i
  %mul6.i133.i.i.i = fmul double %mul6.i1421.i.i, %cond.i1429.i.i
  %mul8.i134.i.i.i = fmul double %mul10.i1423.i.i, %cond.i1429.i.i
  %mul.i190.i.i = fmul double %cond.i1431.i.i, %cond.i1429.i.i
  %sub.i118.i.i.i = fsub double %UR.sroa.0.0, %UL.sroa.0.0
  %sub7.i.i.i.i = fsub double %UR.sroa.7.0, %UL.sroa.7.0
  %sub10.i.i.i.i = fsub double %UR.sroa.11.0, %UL.sroa.11.0
  %sub13.i.i.i.i = fsub double %UR.sroa.15.0, %UL.sroa.15.0
  %mul.i110.i.i.i = fmul double %sub.i118.i.i.i, %mul.i190.i.i
  %mul4.i111.i.i.i = fmul double %sub7.i.i.i.i, %mul.i190.i.i
  %mul6.i112.i.i.i = fmul double %sub10.i.i.i.i, %mul.i190.i.i
  %mul8.i113.i.i.i = fmul double %sub13.i.i.i.i, %mul.i190.i.i
  %div.i191.i.i = fdiv double 1.000000e+00, %sub22.i.i.i
  %206 = fmul double %UR.sroa.7.0, %cond.i1431.i.i
  %add.i102.i.i.i = fsub double %mul.i131.i.i.i, %206
  %207 = fmul double %add.i1392.i.i, %cond.i1431.i.i
  %add7.i103.i.i.i = fsub double %mul4.i132.i.i.i, %207
  %208 = fmul double %mul6.i1393.i.i, %cond.i1431.i.i
  %add10.i104.i.i.i = fsub double %mul6.i133.i.i.i, %208
  %209 = fmul double %mul10.i.i.i, %cond.i1431.i.i
  %add13.i105.i.i.i = fsub double %mul8.i134.i.i.i, %209
  %add.i97.i.i.i = fadd double %add.i102.i.i.i, %mul.i110.i.i.i
  %add7.i.i.i.i = fadd double %add7.i103.i.i.i, %mul4.i111.i.i.i
  %add10.i.i.i.i = fadd double %add10.i104.i.i.i, %mul6.i112.i.i.i
  %add13.i.i.i.i = fadd double %add13.i105.i.i.i, %mul8.i113.i.i.i
  %mul.i90.i.i.i = fmul double %div.i191.i.i, %add.i97.i.i.i
  %mul4.i91.i.i.i = fmul double %div.i191.i.i, %add7.i.i.i.i
  %mul6.i92.i.i.i = fmul double %div.i191.i.i, %add10.i.i.i.i
  %mul8.i.i.i.i = fmul double %div.i191.i.i, %add13.i.i.i.i
  br label %_Z6hllc_x4ConsS_.exit

if.end127.i.i:                                    ; preds = %if.end105.i.i
  %cmp139.i.i = fcmp ult double %div.i.i, 0.000000e+00
  br i1 %cmp139.i.i, label %if.end169.i.i, label %if.then140.i.i

if.then140.i.i:                                   ; preds = %if.end127.i.i
  %sub144.i.i = fsub double %div75.i.i, %UL.sroa.0.0
  %mul145.i.i = fmul double %cond.i1431.i.i, %sub144.i.i
  %add146.i.i = fadd double %UL.sroa.7.0, %mul145.i.i
  %sub151.i.i = fsub double %mul91.i.i, %UL.sroa.7.0
  %mul152.i.i = fmul double %cond.i1431.i.i, %sub151.i.i
  %add153.i.i = fadd double %add.i1420.i.i, %mul152.i.i
  %sub158.i.i = fsub double %mul92.i.i, %UL.sroa.11.0
  %mul159.i.i = fmul double %cond.i1431.i.i, %sub158.i.i
  %add160.i.i = fadd double %mul6.i1421.i.i, %mul159.i.i
  %sub165.i.i = fsub double %div99.i.i, %UL.sroa.15.0
  %mul166.i.i = fmul double %cond.i1431.i.i, %sub165.i.i
  %add167.i.i = fadd double %mul10.i1423.i.i, %mul166.i.i
  br label %_Z6hllc_x4ConsS_.exit

if.end169.i.i:                                    ; preds = %if.end127.i.i
  %sub173.i.i = fsub double %div78.i.i, %UR.sroa.0.0
  %mul174.i.i = fmul double %cond.i1429.i.i, %sub173.i.i
  %add175.i.i = fadd double %UR.sroa.7.0, %mul174.i.i
  %sub180.i.i = fsub double %mul112.i.i, %UR.sroa.7.0
  %mul181.i.i = fmul double %cond.i1429.i.i, %sub180.i.i
  %add182.i.i = fadd double %add.i1392.i.i, %mul181.i.i
  %sub187.i.i = fsub double %mul113.i.i, %UR.sroa.11.0
  %mul188.i.i = fmul double %cond.i1429.i.i, %sub187.i.i
  %add189.i.i = fadd double %mul6.i1393.i.i, %mul188.i.i
  %sub194.i.i = fsub double %div121.i.i, %UR.sroa.15.0
  %mul195.i.i = fmul double %cond.i1429.i.i, %sub194.i.i
  %add196.i.i = fadd double %mul10.i.i.i, %mul195.i.i
  br label %_Z6hllc_x4ConsS_.exit

_Z6hllc_x4ConsS_.exit:                            ; preds = %if.end169.i.i, %if.then140.i.i, %if.end31.i.i.i, %if.then25.i.i.i, %if.end31.i419.i.i, %if.then25.i359.i.i, %if.end31.i652.i.i, %if.then25.i592.i.i, %if.end31.i885.i.i, %if.then25.i825.i.i, %if.end31.i1125.i.i, %if.then25.i1065.i.i, %if.end31.i1358.i.i, %if.then25.i1298.i.i, %if.end.i.i, %if.end52
  %retval.sroa.0.7.i.i = phi double [ %UL.sroa.7.0, %if.end52 ], [ %UR.sroa.7.0, %if.end.i.i ], [ %mul.i139.i1290.i.i, %if.then25.i1298.i.i ], [ %mul.i90.i1350.i.i, %if.end31.i1358.i.i ], [ %mul.i139.i1057.i.i, %if.then25.i1065.i.i ], [ %mul.i90.i1117.i.i, %if.end31.i1125.i.i ], [ %mul.i139.i817.i.i, %if.then25.i825.i.i ], [ %mul.i90.i877.i.i, %if.end31.i885.i.i ], [ %mul.i139.i584.i.i, %if.then25.i592.i.i ], [ %mul.i90.i644.i.i, %if.end31.i652.i.i ], [ %mul.i139.i351.i.i, %if.then25.i359.i.i ], [ %mul.i90.i411.i.i, %if.end31.i419.i.i ], [ %mul.i139.i.i.i, %if.then25.i.i.i ], [ %mul.i90.i.i.i, %if.end31.i.i.i ], [ %add146.i.i, %if.then140.i.i ], [ %add175.i.i, %if.end169.i.i ]
  %retval.sroa.11.7.i.i = phi double [ %add.i1420.i.i, %if.end52 ], [ %add.i1392.i.i, %if.end.i.i ], [ %mul4.i140.i1291.i.i, %if.then25.i1298.i.i ], [ %mul4.i91.i1351.i.i, %if.end31.i1358.i.i ], [ %mul4.i140.i1058.i.i, %if.then25.i1065.i.i ], [ %mul4.i91.i1118.i.i, %if.end31.i1125.i.i ], [ %mul4.i140.i818.i.i, %if.then25.i825.i.i ], [ %mul4.i91.i878.i.i, %if.end31.i885.i.i ], [ %mul4.i140.i585.i.i, %if.then25.i592.i.i ], [ %mul4.i91.i645.i.i, %if.end31.i652.i.i ], [ %mul4.i140.i352.i.i, %if.then25.i359.i.i ], [ %mul4.i91.i412.i.i, %if.end31.i419.i.i ], [ %mul4.i140.i.i.i, %if.then25.i.i.i ], [ %mul4.i91.i.i.i, %if.end31.i.i.i ], [ %add153.i.i, %if.then140.i.i ], [ %add182.i.i, %if.end169.i.i ]
  %retval.sroa.22.7.i.i = phi double [ %mul6.i1421.i.i, %if.end52 ], [ %mul6.i1393.i.i, %if.end.i.i ], [ %mul6.i141.i1292.i.i, %if.then25.i1298.i.i ], [ %mul6.i92.i1352.i.i, %if.end31.i1358.i.i ], [ %mul6.i141.i1059.i.i, %if.then25.i1065.i.i ], [ %mul6.i92.i1119.i.i, %if.end31.i1125.i.i ], [ %mul6.i141.i819.i.i, %if.then25.i825.i.i ], [ %mul6.i92.i879.i.i, %if.end31.i885.i.i ], [ %mul6.i141.i586.i.i, %if.then25.i592.i.i ], [ %mul6.i92.i646.i.i, %if.end31.i652.i.i ], [ %mul6.i141.i353.i.i, %if.then25.i359.i.i ], [ %mul6.i92.i413.i.i, %if.end31.i419.i.i ], [ %mul6.i141.i.i.i, %if.then25.i.i.i ], [ %mul6.i92.i.i.i, %if.end31.i.i.i ], [ %add160.i.i, %if.then140.i.i ], [ %add189.i.i, %if.end169.i.i ]
  %retval.sroa.33.7.i.i = phi double [ %mul10.i1423.i.i, %if.end52 ], [ %mul10.i.i.i, %if.end.i.i ], [ %mul8.i142.i1293.i.i, %if.then25.i1298.i.i ], [ %mul8.i.i1353.i.i, %if.end31.i1358.i.i ], [ %mul8.i142.i1060.i.i, %if.then25.i1065.i.i ], [ %mul8.i.i1120.i.i, %if.end31.i1125.i.i ], [ %mul8.i142.i820.i.i, %if.then25.i825.i.i ], [ %mul8.i.i880.i.i, %if.end31.i885.i.i ], [ %mul8.i142.i587.i.i, %if.then25.i592.i.i ], [ %mul8.i.i647.i.i, %if.end31.i652.i.i ], [ %mul8.i142.i354.i.i, %if.then25.i359.i.i ], [ %mul8.i.i414.i.i, %if.end31.i419.i.i ], [ %mul8.i142.i.i.i, %if.then25.i.i.i ], [ %mul8.i.i.i.i, %if.end31.i.i.i ], [ %add167.i.i, %if.then140.i.i ], [ %add196.i.i, %if.end169.i.i ]
  %idxprom.i = sext i32 %add to i64
  %arrayidx.i = getelementptr inbounds double, double addrspace(1)* %12, i64 %idxprom.i
  store double %retval.sroa.0.7.i.i, double addrspace(1)* %arrayidx.i, align 8, !tbaa !11
  %arrayidx5.i = getelementptr inbounds double, double addrspace(1)* %13, i64 %idxprom.i
  store double %retval.sroa.11.7.i.i, double addrspace(1)* %arrayidx5.i, align 8, !tbaa !11
  %arrayidx8.i = getelementptr inbounds double, double addrspace(1)* %14, i64 %idxprom.i
  store double %retval.sroa.22.7.i.i, double addrspace(1)* %arrayidx8.i, align 8, !tbaa !11
  %arrayidx11.i = getelementptr inbounds double, double addrspace(1)* %15, i64 %idxprom.i
  store double %retval.sroa.33.7.i.i, double addrspace(1)* %arrayidx11.i, align 8, !tbaa !11
  br label %cleanup65

cleanup65:                                        ; preds = %_Z6hllc_x4ConsS_.exit, %if.else47, %entry
  ret void

merged.branch.split8:                             ; preds = %unify.bb
  %210 = icmp slt i32 %rem.decomposed, 0
  br i1 %210, label %if.then7.i, label %if.end9.i
}

; Function Attrs: nounwind readnone speculatable willreturn
declare i1 @llvm.amdgcn.class.f64(double, i32) #1

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.amdgcn.rsq.f64(double) #1

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.fma.f64(double, double, double) #1

; Function Attrs: nounwind readnone speculatable willreturn
declare align 4 i8 addrspace(4)* @llvm.amdgcn.dispatch.ptr() #1

; Function Attrs: nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.workgroup.id.x() #1

; Function Attrs: nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.workitem.id.x() #1

attributes #0 = { nofree norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { nounwind }

!llvm.module.flags = !{!0, !1}
!opencl.ocl.version = !{!2}
!llvm.ident = !{!3, !4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 1}
!2 = !{i32 2, i32 0}
!3 = !{!"clang version 12.0.0 (https://github.com/charitha22/cgo22ae-darm-code.git e9bc0540325ad9806313d34e84fc901496fd8be6)"}
!4 = !{!"clang version 12.0.0 (/src/external/llvm-project/clang dac2bfceaa8d4a90257dc8a6d58f268e172ce00e)"}
!5 = !{i16 1, i16 1025}
!6 = !{}
!7 = !{i32 0, i32 1024}
!8 = !{!9, !9, i64 0}
!9 = !{!"omnipotent char", !10, i64 0}
!10 = !{!"Simple C++ TBAA"}
!11 = !{!12, !12, i64 0}
!12 = !{!"double", !9, i64 0}
!13 = !{!"if.then29", !"if.then39"}
!14 = !{!15, !12, i64 40}
!15 = !{!"_ZTS9SimConfig", !12, i64 0, !12, i64 8, !12, i64 16, !12, i64 24, !12, i64 32, !12, i64 40, !12, i64 48, !12, i64 56, !12, i64 64, !12, i64 72, !12, i64 80, !16, i64 88}
!16 = !{!"int", !9, i64 0}
!17 = !{!15, !12, i64 0}
