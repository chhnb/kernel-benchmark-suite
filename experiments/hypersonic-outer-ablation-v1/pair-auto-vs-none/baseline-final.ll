; ModuleID = '/home/chh/kernel-benchmark-suite/experiments/hypersonic-outer-ablation-v1/pair-auto-vs-none/baseline.ll'
source_filename = "llvm-link"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

%struct.SimConfig = type { double, double, double, double, double, double, double, double, double, double, double, i32 }
%struct.Usoa.coerce = type { double addrspace(1)*, double addrspace(1)*, double addrspace(1)*, double addrspace(1)* }

@d_cfg = protected local_unnamed_addr addrspace(4) externally_initialized global %struct.SimConfig zeroinitializer, align 8

; Function Attrs: nofree norecurse nounwind
define protected amdgpu_kernel void @face_kernel(%struct.Usoa.coerce %U.coerce, i8 addrspace(1)* nocapture readonly %mask.coerce, %struct.Usoa.coerce %xL_states.coerce, %struct.Usoa.coerce %xR_states.coerce, %struct.Usoa.coerce %xFlux.coerce) local_unnamed_addr #0 {
entry:
  %0 = extractvalue %struct.Usoa.coerce %U.coerce, 0
  %1 = extractvalue %struct.Usoa.coerce %U.coerce, 1
  %2 = extractvalue %struct.Usoa.coerce %U.coerce, 2
  %3 = extractvalue %struct.Usoa.coerce %U.coerce, 3
  %4 = extractvalue %struct.Usoa.coerce %xL_states.coerce, 0
  %5 = extractvalue %struct.Usoa.coerce %xL_states.coerce, 1
  %6 = extractvalue %struct.Usoa.coerce %xL_states.coerce, 2
  %7 = extractvalue %struct.Usoa.coerce %xL_states.coerce, 3
  %8 = extractvalue %struct.Usoa.coerce %xR_states.coerce, 0
  %9 = extractvalue %struct.Usoa.coerce %xR_states.coerce, 1
  %10 = extractvalue %struct.Usoa.coerce %xR_states.coerce, 2
  %11 = extractvalue %struct.Usoa.coerce %xR_states.coerce, 3
  %12 = extractvalue %struct.Usoa.coerce %xFlux.coerce, 0
  %13 = extractvalue %struct.Usoa.coerce %xFlux.coerce, 1
  %14 = extractvalue %struct.Usoa.coerce %xFlux.coerce, 2
  %15 = extractvalue %struct.Usoa.coerce %xFlux.coerce, 3
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
  br i1 %cmp, label %cleanup128, label %if.end

if.end:                                           ; preds = %entry
  %add.frozen = freeze i32 %add
  %div = sdiv i32 %add.frozen, 8193
  %.neg = mul nsw i32 %div, -8193
  %rem.decomposed = add i32 %.neg, %add.frozen
  %sub = add nsw i32 %rem.decomposed, -1
  %cmp8 = icmp sgt i32 %rem.decomposed, 0
  %mul.i279 = shl nsw i32 %div, 13
  br i1 %cmp8, label %land.end, label %land.rhs11

land.end:                                         ; preds = %if.end
  %add.i280 = add nsw i32 %sub, %mul.i279
  %idxprom = sext i32 %add.i280 to i64
  %arrayidx268 = getelementptr inbounds i8, i8 addrspace(1)* %mask.coerce, i64 %idxprom
  %24 = load i8, i8 addrspace(1)* %arrayidx268, align 1, !tbaa !8
  %tobool.not = icmp eq i8 %24, 0
  %phi.cast = zext i1 %tobool.not to i32
  %cmp10 = icmp slt i32 %rem.decomposed, 8192
  br i1 %cmp10, label %land.rhs11, label %land.end17

land.rhs11:                                       ; preds = %land.end, %if.end
  %25 = phi i32 [ %phi.cast, %land.end ], [ 0, %if.end ]
  %idxprom13414.pn.in = add nsw i32 %rem.decomposed, %mul.i279
  %idxprom13414.pn = sext i32 %idxprom13414.pn.in to i64
  %arrayidx14267416 = getelementptr inbounds i8, i8 addrspace(1)* %mask.coerce, i64 %idxprom13414.pn
  %26 = load i8, i8 addrspace(1)* %arrayidx14267416, align 1, !tbaa !8
  %tobool15.not = icmp eq i8 %26, 0
  %phi.cast256 = zext i1 %tobool15.not to i32
  br label %land.end17

land.end17:                                       ; preds = %land.rhs11, %land.end
  %27 = phi i32 [ %phi.cast, %land.end ], [ %25, %land.rhs11 ]
  %28 = phi i32 [ 0, %land.end ], [ %phi.cast256, %land.rhs11 ]
  %tobool.not.i = icmp eq i32 %27, 0
  %tobool10.not.i = icmp eq i32 %28, 0
  br i1 %tobool.not.i, label %land.lhs.true8.i, label %land.lhs.true.i

land.lhs.true.i:                                  ; preds = %land.end17
  %add.i.i11.i = add nsw i32 %sub, %mul.i279
  %idxprom.i180.i.i = sext i32 %add.i.i11.i to i64
  %arrayidx.i181.i.i = getelementptr inbounds double, double addrspace(1)* %8, i64 %idxprom.i180.i.i
  %29 = load double, double addrspace(1)* %arrayidx.i181.i.i, align 8, !tbaa !11
  %arrayidx5.i.i12.i = getelementptr inbounds double, double addrspace(1)* %9, i64 %idxprom.i180.i.i
  %30 = load double, double addrspace(1)* %arrayidx5.i.i12.i, align 8, !tbaa !11
  %arrayidx8.i.i13.i = getelementptr inbounds double, double addrspace(1)* %10, i64 %idxprom.i180.i.i
  %31 = load double, double addrspace(1)* %arrayidx8.i.i13.i, align 8, !tbaa !11
  %arrayidx11.i.i14.i = getelementptr inbounds double, double addrspace(1)* %11, i64 %idxprom.i180.i.i
  %32 = load double, double addrspace(1)* %arrayidx11.i.i14.i, align 8, !tbaa !11
  br i1 %tobool10.not.i, label %if.then24.i, label %if.then.i

if.then.i:                                        ; preds = %land.lhs.true.i
  %add.i178.i.i = add nsw i32 %rem.decomposed, %mul.i279
  %idxprom.i.i.i = sext i32 %add.i178.i.i to i64
  %arrayidx.i.i.i = getelementptr inbounds double, double addrspace(1)* %4, i64 %idxprom.i.i.i
  %33 = load double, double addrspace(1)* %arrayidx.i.i.i, align 8, !tbaa !11
  %arrayidx5.i.i.i = getelementptr inbounds double, double addrspace(1)* %5, i64 %idxprom.i.i.i
  %34 = load double, double addrspace(1)* %arrayidx5.i.i.i, align 8, !tbaa !11
  %arrayidx8.i.i.i = getelementptr inbounds double, double addrspace(1)* %6, i64 %idxprom.i.i.i
  %35 = load double, double addrspace(1)* %arrayidx8.i.i.i, align 8, !tbaa !11
  %arrayidx11.i.i.i = getelementptr inbounds double, double addrspace(1)* %7, i64 %idxprom.i.i.i
  %36 = load double, double addrspace(1)* %arrayidx11.i.i.i, align 8, !tbaa !11
  br label %if.end109

land.lhs.true8.i:                                 ; preds = %land.end17
  br i1 %tobool10.not.i, label %predication.split27, label %if.then11.i

if.then11.i:                                      ; preds = %land.lhs.true8.i
  %37 = icmp sgt i32 %div, 0
  %spec.store.select.i.i35.i = select i1 %37, i32 %div, i32 0
  %cmp6.i.i36.i = icmp slt i32 %rem.decomposed, 1
  br i1 %cmp6.i.i36.i, label %if.then7.i.i44.i, label %if.end9.i.i48.i

if.then7.i.i44.i:                                 ; preds = %if.then11.i
  %38 = load double, double addrspace(4)* getelementptr inbounds (%struct.SimConfig, %struct.SimConfig addrspace(4)* @d_cfg, i64 0, i32 5), align 8, !tbaa !13
  %39 = load double, double addrspace(4)* getelementptr inbounds (%struct.SimConfig, %struct.SimConfig addrspace(4)* @d_cfg, i64 0, i32 0), align 8, !tbaa !16
  %40 = fcmp olt double %39, 0x1000000000000000
  %41 = select i1 %40, double 0x4FF0000000000000, double 1.000000e+00
  %42 = fmul double %39, %41
  %43 = tail call double @llvm.amdgcn.rsq.f64(double %42) #2
  %44 = fmul double %42, %43
  %45 = fmul double %43, 5.000000e-01
  %46 = fneg double %45
  %47 = tail call double @llvm.fma.f64(double %46, double %44, double 5.000000e-01) #2
  %48 = tail call double @llvm.fma.f64(double %45, double %47, double %45) #2
  %49 = tail call double @llvm.fma.f64(double %44, double %47, double %44) #2
  %50 = fneg double %49
  %51 = tail call double @llvm.fma.f64(double %50, double %49, double %42) #2
  %52 = tail call double @llvm.fma.f64(double %51, double %48, double %49) #2
  %53 = fneg double %52
  %54 = tail call double @llvm.fma.f64(double %53, double %52, double %42) #2
  %55 = tail call double @llvm.fma.f64(double %54, double %48, double %52) #2
  %56 = select i1 %40, double 0x37F0000000000000, double 1.000000e+00
  %57 = fmul double %56, %55
  %58 = fcmp oeq double %42, 0.000000e+00
  %59 = fcmp oeq double %42, 0x7FF0000000000000
  %60 = or i1 %58, %59
  %61 = select i1 %60, double %42, double %57
  %mul1.i.i.i37.i = fmul double %38, %61
  %sub.i105.i.i38.i = fadd double %39, -1.000000e+00
  %div.i106.i.i39.i = fdiv double 1.000000e+00, %sub.i105.i.i38.i
  %mul10.i108.i.i40.i = fmul double %mul1.i.i.i37.i, %mul1.i.i.i37.i
  %add.i110.i.i41.i = fadd double %mul10.i108.i.i40.i, 0.000000e+00
  %mul14.i111.i.i42.i = fmul double %add.i110.i.i41.i, 5.000000e-01
  %add15.i112.i.i43.i = fadd double %div.i106.i.i39.i, %mul14.i111.i.i42.i
  br label %g_1_1.exit.i

if.end9.i.i48.i:                                  ; preds = %if.then11.i
  %62 = icmp slt i32 %spec.store.select.i.i35.i, 1023
  %spec.store.select32.i.i45.i = select i1 %62, i32 %spec.store.select.i.i35.i, i32 1023
  %cmp10.i.i46.i = icmp sgt i32 %rem.decomposed, 8192
  %mul.i97.i.i47.i = shl nuw nsw i32 %spec.store.select32.i.i45.i, 13
  br i1 %cmp10.i.i46.i, label %if.then11.i.i55.i, label %if.end15.i.i60.i

if.then11.i.i55.i:                                ; preds = %if.end9.i.i48.i
  %add.i98.i.i49.i = or i32 %mul.i97.i.i47.i, 8191
  %idxprom.i88.i.i50.i = zext i32 %add.i98.i.i49.i to i64
  %arrayidx.i89.i.i51.i = getelementptr inbounds double, double addrspace(1)* %0, i64 %idxprom.i88.i.i50.i
  %63 = load double, double addrspace(1)* %arrayidx.i89.i.i51.i, align 8, !tbaa !11
  %arrayidx5.i90.i.i52.i = getelementptr inbounds double, double addrspace(1)* %1, i64 %idxprom.i88.i.i50.i
  %64 = load double, double addrspace(1)* %arrayidx5.i90.i.i52.i, align 8, !tbaa !11
  %arrayidx8.i91.i.i53.i = getelementptr inbounds double, double addrspace(1)* %2, i64 %idxprom.i88.i.i50.i
  %65 = load double, double addrspace(1)* %arrayidx8.i91.i.i53.i, align 8, !tbaa !11
  %arrayidx11.i92.i.i54.i = getelementptr inbounds double, double addrspace(1)* %3, i64 %idxprom.i88.i.i50.i
  %66 = load double, double addrspace(1)* %arrayidx11.i92.i.i54.i, align 8, !tbaa !11
  br label %g_1_1.exit.i

if.end15.i.i60.i:                                 ; preds = %if.end9.i.i48.i
  %add.i87.i.i56.i = add nsw i32 %mul.i97.i.i47.i, %sub
  %idxprom.i.i57.i = sext i32 %add.i87.i.i56.i to i64
  %arrayidx.i.i58.i52 = getelementptr inbounds i8, i8 addrspace(1)* %mask.coerce, i64 %idxprom.i.i57.i
  %67 = load i8, i8 addrspace(1)* %arrayidx.i.i58.i52, align 1, !tbaa !8
  %tobool.not.i.i59.i = icmp eq i8 %67, 0
  br i1 %tobool.not.i.i59.i, label %if.end27.i.i91.i, label %if.then17.i.i86.i

if.then17.i.i86.i:                                ; preds = %if.end15.i.i60.i
  %add.i85.i.i.i = add nsw i32 %rem.decomposed, %mul.i279
  %idxprom.i75.i.i.i = sext i32 %add.i85.i.i.i to i64
  %arrayidx.i76.i.i61.i = getelementptr inbounds double, double addrspace(1)* %0, i64 %idxprom.i75.i.i.i
  %68 = load double, double addrspace(1)* %arrayidx.i76.i.i61.i, align 8, !tbaa !11
  %arrayidx5.i77.i.i62.i = getelementptr inbounds double, double addrspace(1)* %1, i64 %idxprom.i75.i.i.i
  %69 = load double, double addrspace(1)* %arrayidx5.i77.i.i62.i, align 8, !tbaa !11
  %arrayidx8.i78.i.i63.i = getelementptr inbounds double, double addrspace(1)* %2, i64 %idxprom.i75.i.i.i
  %70 = load double, double addrspace(1)* %arrayidx8.i78.i.i63.i, align 8, !tbaa !11
  %arrayidx11.i79.i.i64.i = getelementptr inbounds double, double addrspace(1)* %3, i64 %idxprom.i75.i.i.i
  %71 = load double, double addrspace(1)* %arrayidx11.i79.i.i64.i, align 8, !tbaa !11
  %cmp.i.i63.i.i65.i = fcmp ogt double %68, 1.000000e-25
  %cond.i.i64.i.i66.i = select i1 %cmp.i.i63.i.i65.i, double %68, double 1.000000e-25
  %div.i65.i.i67.i = fdiv double 1.000000e+00, %cond.i.i64.i.i66.i
  %mul.i66.i.i68.i = fmul double %69, %div.i65.i.i67.i
  %mul3.i.i.i69.i = fmul double %70, %div.i65.i.i67.i
  %mul4.i.i.i70.i = fmul double %cond.i.i64.i.i66.i, 5.000000e-01
  %mul5.i.i.i71.i = fmul double %mul.i66.i.i68.i, %mul.i66.i.i68.i
  %mul6.i67.i.i72.i = fmul double %mul3.i.i.i69.i, %mul3.i.i.i69.i
  %add.i68.i.i73.i = fadd double %mul5.i.i.i71.i, %mul6.i67.i.i72.i
  %mul7.i69.i.i74.i = fmul double %mul4.i.i.i70.i, %add.i68.i.i73.i
  %sub.i70.i.i75.i = fsub double %71, %mul7.i69.i.i74.i
  %72 = load double, double addrspace(4)* getelementptr inbounds (%struct.SimConfig, %struct.SimConfig addrspace(4)* @d_cfg, i64 0, i32 0), align 8, !tbaa !16
  %sub8.i.i.i76.i = fadd double %72, -1.000000e+00
  %mul9.i.i.i77.i = fmul double %sub8.i.i.i76.i, %sub.i70.i.i75.i
  %cmp.i28.i.i.i78.i = fcmp ogt double %mul9.i.i.i77.i, 1.000000e-25
  %fneg.i.i.i79.i = fneg double %mul.i66.i.i68.i
  %fneg5.i.i.i80.i = fneg double %mul3.i.i.i69.i
  %cond.i26.i.i.i81.i = select i1 %cmp.i28.i.i.i78.i, double %mul9.i.i.i77.i, double 1.000000e-25
  %mul.i.i.i82.i = fmul double %cond.i.i64.i.i66.i, %fneg.i.i.i79.i
  %mul6.i.i.i83.i = fmul double %cond.i.i64.i.i66.i, %fneg5.i.i.i80.i
  %div.i.i.i84.i = fdiv double %cond.i26.i.i.i81.i, %sub8.i.i.i76.i
  %add15.i.i.i85.i = fadd double %mul7.i69.i.i74.i, %div.i.i.i84.i
  br label %g_1_1.exit.i

if.end27.i.i91.i:                                 ; preds = %if.end15.i.i60.i
  %arrayidx.i.i.i87.i = getelementptr inbounds double, double addrspace(1)* %0, i64 %idxprom.i.i57.i
  %73 = load double, double addrspace(1)* %arrayidx.i.i.i87.i, align 8, !tbaa !11
  %arrayidx5.i.i.i88.i = getelementptr inbounds double, double addrspace(1)* %1, i64 %idxprom.i.i57.i
  %74 = load double, double addrspace(1)* %arrayidx5.i.i.i88.i, align 8, !tbaa !11
  %arrayidx8.i.i.i89.i = getelementptr inbounds double, double addrspace(1)* %2, i64 %idxprom.i.i57.i
  %75 = load double, double addrspace(1)* %arrayidx8.i.i.i89.i, align 8, !tbaa !11
  %arrayidx11.i.i.i90.i = getelementptr inbounds double, double addrspace(1)* %3, i64 %idxprom.i.i57.i
  %76 = load double, double addrspace(1)* %arrayidx11.i.i.i90.i, align 8, !tbaa !11
  br label %g_1_1.exit.i

g_1_1.exit.i:                                     ; preds = %if.end27.i.i91.i, %if.then17.i.i86.i, %if.then11.i.i55.i, %if.then7.i.i44.i
  %retval.sroa.0.1.i.i92.i = phi double [ 1.000000e+00, %if.then7.i.i44.i ], [ %63, %if.then11.i.i55.i ], [ %cond.i.i64.i.i66.i, %if.then17.i.i86.i ], [ %73, %if.end27.i.i91.i ]
  %retval.sroa.5.1.i.i93.i = phi double [ %mul1.i.i.i37.i, %if.then7.i.i44.i ], [ %64, %if.then11.i.i55.i ], [ %mul.i.i.i82.i, %if.then17.i.i86.i ], [ %74, %if.end27.i.i91.i ]
  %retval.sroa.10.1.i.i94.i = phi double [ 0.000000e+00, %if.then7.i.i44.i ], [ %65, %if.then11.i.i55.i ], [ %mul6.i.i.i83.i, %if.then17.i.i86.i ], [ %75, %if.end27.i.i91.i ]
  %retval.sroa.15.1.i.i95.i = phi double [ %add15.i112.i.i43.i, %if.then7.i.i44.i ], [ %66, %if.then11.i.i55.i ], [ %add15.i.i.i85.i, %if.then17.i.i86.i ], [ %76, %if.end27.i.i91.i ]
  %add.i185.i.i = add nsw i32 %rem.decomposed, %mul.i279
  %idxprom.i179.i97.i = sext i32 %add.i185.i.i to i64
  %arrayidx.i180.i98.i = getelementptr inbounds double, double addrspace(1)* %4, i64 %idxprom.i179.i97.i
  %77 = load double, double addrspace(1)* %arrayidx.i180.i98.i, align 8, !tbaa !11
  %arrayidx5.i.i99.i = getelementptr inbounds double, double addrspace(1)* %5, i64 %idxprom.i179.i97.i
  %78 = load double, double addrspace(1)* %arrayidx5.i.i99.i, align 8, !tbaa !11
  %arrayidx8.i.i100.i = getelementptr inbounds double, double addrspace(1)* %6, i64 %idxprom.i179.i97.i
  %79 = load double, double addrspace(1)* %arrayidx8.i.i100.i, align 8, !tbaa !11
  %arrayidx11.i.i101.i = getelementptr inbounds double, double addrspace(1)* %7, i64 %idxprom.i179.i97.i
  %80 = load double, double addrspace(1)* %arrayidx11.i.i101.i, align 8, !tbaa !11
  br label %if.end109

if.then24.i:                                      ; preds = %land.lhs.true.i
  %81 = icmp sgt i32 %div, 0
  %spec.store.select.i.i.i = select i1 %81, i32 %div, i32 0
  %cmp6.i.i.i = icmp slt i32 %rem.decomposed, 0
  br i1 %cmp6.i.i.i, label %if.then7.i.i.i, label %if.end9.i.i.i

if.then7.i.i.i:                                   ; preds = %if.then24.i
  %82 = load double, double addrspace(4)* getelementptr inbounds (%struct.SimConfig, %struct.SimConfig addrspace(4)* @d_cfg, i64 0, i32 5), align 8, !tbaa !13
  %83 = load double, double addrspace(4)* getelementptr inbounds (%struct.SimConfig, %struct.SimConfig addrspace(4)* @d_cfg, i64 0, i32 0), align 8, !tbaa !16
  %84 = fcmp olt double %83, 0x1000000000000000
  %85 = select i1 %84, double 0x4FF0000000000000, double 1.000000e+00
  %86 = fmul double %83, %85
  %87 = tail call double @llvm.amdgcn.rsq.f64(double %86) #2
  %88 = fmul double %86, %87
  %89 = fmul double %87, 5.000000e-01
  %90 = fneg double %89
  %91 = tail call double @llvm.fma.f64(double %90, double %88, double 5.000000e-01) #2
  %92 = tail call double @llvm.fma.f64(double %89, double %91, double %89) #2
  %93 = tail call double @llvm.fma.f64(double %88, double %91, double %88) #2
  %94 = fneg double %93
  %95 = tail call double @llvm.fma.f64(double %94, double %93, double %86) #2
  %96 = tail call double @llvm.fma.f64(double %95, double %92, double %93) #2
  %97 = fneg double %96
  %98 = tail call double @llvm.fma.f64(double %97, double %96, double %86) #2
  %99 = tail call double @llvm.fma.f64(double %98, double %92, double %96) #2
  %100 = select i1 %84, double 0x37F0000000000000, double 1.000000e+00
  %101 = fmul double %100, %99
  %102 = fcmp oeq double %86, 0.000000e+00
  %103 = fcmp oeq double %86, 0x7FF0000000000000
  %104 = or i1 %102, %103
  %105 = select i1 %104, double %86, double %101
  %mul1.i.i.i.i = fmul double %82, %105
  %sub.i105.i.i.i = fadd double %83, -1.000000e+00
  %div.i106.i.i.i = fdiv double 1.000000e+00, %sub.i105.i.i.i
  %mul10.i108.i.i.i = fmul double %mul1.i.i.i.i, %mul1.i.i.i.i
  %add.i110.i.i.i = fadd double %mul10.i108.i.i.i, 0.000000e+00
  %mul14.i111.i.i.i = fmul double %add.i110.i.i.i, 5.000000e-01
  %add15.i112.i.i.i = fadd double %div.i106.i.i.i, %mul14.i111.i.i.i
  br label %if.end109

if.end9.i.i.i:                                    ; preds = %if.then24.i
  %106 = icmp slt i32 %spec.store.select.i.i.i, 1023
  %spec.store.select32.i.i.i = select i1 %106, i32 %spec.store.select.i.i.i, i32 1023
  %cmp10.i.i.i = icmp sgt i32 %rem.decomposed, 8191
  %mul.i97.i.i.i = shl nuw nsw i32 %spec.store.select32.i.i.i, 13
  br i1 %cmp10.i.i.i, label %if.then11.i.i.i, label %if.end15.i.i.i

if.then11.i.i.i:                                  ; preds = %if.end9.i.i.i
  %add.i98.i.i.i = or i32 %mul.i97.i.i.i, 8191
  %idxprom.i88.i.i.i = zext i32 %add.i98.i.i.i to i64
  %arrayidx.i89.i.i.i = getelementptr inbounds double, double addrspace(1)* %0, i64 %idxprom.i88.i.i.i
  %107 = load double, double addrspace(1)* %arrayidx.i89.i.i.i, align 8, !tbaa !11
  %arrayidx5.i90.i.i.i = getelementptr inbounds double, double addrspace(1)* %1, i64 %idxprom.i88.i.i.i
  %108 = load double, double addrspace(1)* %arrayidx5.i90.i.i.i, align 8, !tbaa !11
  %arrayidx8.i91.i.i.i = getelementptr inbounds double, double addrspace(1)* %2, i64 %idxprom.i88.i.i.i
  %109 = load double, double addrspace(1)* %arrayidx8.i91.i.i.i, align 8, !tbaa !11
  %arrayidx11.i92.i.i.i = getelementptr inbounds double, double addrspace(1)* %3, i64 %idxprom.i88.i.i.i
  %110 = load double, double addrspace(1)* %arrayidx11.i92.i.i.i, align 8, !tbaa !11
  br label %if.end109

if.end15.i.i.i:                                   ; preds = %if.end9.i.i.i
  %add.i87.i.i.i = add nuw nsw i32 %mul.i97.i.i.i, %rem.decomposed
  %idxprom.i.i15.i = sext i32 %add.i87.i.i.i to i64
  %arrayidx.i.i16.i34 = getelementptr inbounds i8, i8 addrspace(1)* %mask.coerce, i64 %idxprom.i.i15.i
  %111 = load i8, i8 addrspace(1)* %arrayidx.i.i16.i34, align 1, !tbaa !8
  %tobool.not.i.i.i = icmp eq i8 %111, 0
  br i1 %tobool.not.i.i.i, label %if.end27.i.i.i, label %if.then17.i.i.i

if.then17.i.i.i:                                  ; preds = %if.end15.i.i.i
  %arrayidx.i76.i.i.i = getelementptr inbounds double, double addrspace(1)* %0, i64 %idxprom.i180.i.i
  %112 = load double, double addrspace(1)* %arrayidx.i76.i.i.i, align 8, !tbaa !11
  %arrayidx5.i77.i.i.i = getelementptr inbounds double, double addrspace(1)* %1, i64 %idxprom.i180.i.i
  %113 = load double, double addrspace(1)* %arrayidx5.i77.i.i.i, align 8, !tbaa !11
  %arrayidx8.i78.i.i.i = getelementptr inbounds double, double addrspace(1)* %2, i64 %idxprom.i180.i.i
  %114 = load double, double addrspace(1)* %arrayidx8.i78.i.i.i, align 8, !tbaa !11
  %arrayidx11.i79.i.i.i = getelementptr inbounds double, double addrspace(1)* %3, i64 %idxprom.i180.i.i
  %115 = load double, double addrspace(1)* %arrayidx11.i79.i.i.i, align 8, !tbaa !11
  %cmp.i.i63.i.i.i = fcmp ogt double %112, 1.000000e-25
  %cond.i.i64.i.i.i = select i1 %cmp.i.i63.i.i.i, double %112, double 1.000000e-25
  %div.i65.i.i.i = fdiv double 1.000000e+00, %cond.i.i64.i.i.i
  %mul.i66.i.i.i = fmul double %113, %div.i65.i.i.i
  %mul3.i.i.i.i = fmul double %114, %div.i65.i.i.i
  %mul4.i.i.i.i = fmul double %cond.i.i64.i.i.i, 5.000000e-01
  %mul5.i.i.i.i = fmul double %mul.i66.i.i.i, %mul.i66.i.i.i
  %mul6.i67.i.i.i = fmul double %mul3.i.i.i.i, %mul3.i.i.i.i
  %add.i68.i.i.i = fadd double %mul5.i.i.i.i, %mul6.i67.i.i.i
  %mul7.i69.i.i.i = fmul double %mul4.i.i.i.i, %add.i68.i.i.i
  %sub.i70.i.i.i = fsub double %115, %mul7.i69.i.i.i
  %116 = load double, double addrspace(4)* getelementptr inbounds (%struct.SimConfig, %struct.SimConfig addrspace(4)* @d_cfg, i64 0, i32 0), align 8, !tbaa !16
  %sub8.i.i.i.i = fadd double %116, -1.000000e+00
  %mul9.i.i.i.i = fmul double %sub8.i.i.i.i, %sub.i70.i.i.i
  %cmp.i28.i.i.i.i = fcmp ogt double %mul9.i.i.i.i, 1.000000e-25
  %fneg.i.i.i.i = fneg double %mul.i66.i.i.i
  %fneg5.i.i.i.i = fneg double %mul3.i.i.i.i
  %cond.i26.i.i.i.i = select i1 %cmp.i28.i.i.i.i, double %mul9.i.i.i.i, double 1.000000e-25
  %mul.i.i.i.i = fmul double %cond.i.i64.i.i.i, %fneg.i.i.i.i
  %mul6.i.i.i.i = fmul double %cond.i.i64.i.i.i, %fneg5.i.i.i.i
  %div.i.i.i.i = fdiv double %cond.i26.i.i.i.i, %sub8.i.i.i.i
  %add15.i.i.i.i = fadd double %mul7.i69.i.i.i, %div.i.i.i.i
  br label %if.end109

if.end27.i.i.i:                                   ; preds = %if.end15.i.i.i
  %arrayidx.i.i.i.i = getelementptr inbounds double, double addrspace(1)* %0, i64 %idxprom.i.i15.i
  %117 = load double, double addrspace(1)* %arrayidx.i.i.i.i, align 8, !tbaa !11
  %arrayidx5.i.i.i.i = getelementptr inbounds double, double addrspace(1)* %1, i64 %idxprom.i.i15.i
  %118 = load double, double addrspace(1)* %arrayidx5.i.i.i.i, align 8, !tbaa !11
  %arrayidx8.i.i.i.i = getelementptr inbounds double, double addrspace(1)* %2, i64 %idxprom.i.i15.i
  %119 = load double, double addrspace(1)* %arrayidx8.i.i.i.i, align 8, !tbaa !11
  %arrayidx11.i.i.i.i = getelementptr inbounds double, double addrspace(1)* %3, i64 %idxprom.i.i15.i
  %120 = load double, double addrspace(1)* %arrayidx11.i.i.i.i, align 8, !tbaa !11
  br label %if.end109

if.end109:                                        ; preds = %if.then7.i.i.i, %if.then11.i.i.i, %if.then17.i.i.i, %if.end27.i.i.i, %if.then.i, %g_1_1.exit.i
  %.sink13 = phi double [ %29, %if.then.i ], [ %retval.sroa.0.1.i.i92.i, %g_1_1.exit.i ], [ %29, %if.end27.i.i.i ], [ %29, %if.then17.i.i.i ], [ %29, %if.then11.i.i.i ], [ %29, %if.then7.i.i.i ]
  %.sink = phi double [ %30, %if.then.i ], [ %retval.sroa.5.1.i.i93.i, %g_1_1.exit.i ], [ %30, %if.end27.i.i.i ], [ %30, %if.then17.i.i.i ], [ %30, %if.then11.i.i.i ], [ %30, %if.then7.i.i.i ]
  %.sink12 = phi double [ %31, %if.then.i ], [ %retval.sroa.10.1.i.i94.i, %g_1_1.exit.i ], [ %31, %if.end27.i.i.i ], [ %31, %if.then17.i.i.i ], [ %31, %if.then11.i.i.i ], [ %31, %if.then7.i.i.i ]
  %.sink10 = phi double [ %32, %if.then.i ], [ %retval.sroa.15.1.i.i95.i, %g_1_1.exit.i ], [ %32, %if.end27.i.i.i ], [ %32, %if.then17.i.i.i ], [ %32, %if.then11.i.i.i ], [ %32, %if.then7.i.i.i ]
  %.sink9 = phi double [ %33, %if.then.i ], [ %77, %g_1_1.exit.i ], [ %117, %if.end27.i.i.i ], [ %cond.i.i64.i.i.i, %if.then17.i.i.i ], [ %107, %if.then11.i.i.i ], [ 1.000000e+00, %if.then7.i.i.i ]
  %.sink7 = phi double [ %34, %if.then.i ], [ %78, %g_1_1.exit.i ], [ %118, %if.end27.i.i.i ], [ %mul.i.i.i.i, %if.then17.i.i.i ], [ %108, %if.then11.i.i.i ], [ %mul1.i.i.i.i, %if.then7.i.i.i ]
  %.sink6 = phi double [ %35, %if.then.i ], [ %79, %g_1_1.exit.i ], [ %119, %if.end27.i.i.i ], [ %mul6.i.i.i.i, %if.then17.i.i.i ], [ %109, %if.then11.i.i.i ], [ 0.000000e+00, %if.then7.i.i.i ]
  %.sink4 = phi double [ %36, %if.then.i ], [ %80, %g_1_1.exit.i ], [ %120, %if.end27.i.i.i ], [ %add15.i.i.i.i, %if.then17.i.i.i ], [ %110, %if.then11.i.i.i ], [ %add15.i112.i.i.i, %if.then7.i.i.i ]
  %vals.sroa.0.0.vec.insert = insertelement <8 x double> undef, double %.sink13, i32 0
  %121 = insertelement <8 x double> %vals.sroa.0.0.vec.insert, double %.sink, i32 1
  %122 = insertelement <8 x double> %121, double %.sink12, i32 2
  %123 = insertelement <8 x double> %122, double %.sink10, i32 3
  %124 = insertelement <8 x double> %123, double %.sink9, i32 4
  %125 = insertelement <8 x double> %124, double %.sink7, i32 5
  %126 = insertelement <8 x double> %125, double %.sink6, i32 6
  %127 = insertelement <8 x double> %126, double %.sink4, i32 7
  %128 = shufflevector <8 x double> %127, <8 x double> undef, <2 x i32> <i32 0, i32 4>
  %129 = fcmp ogt <2 x double> %128, <double 1.000000e-25, double 1.000000e-25>
  %130 = select <2 x i1> %129, <2 x double> %128, <2 x double> <double 1.000000e-25, double 1.000000e-25>
  %131 = fdiv <2 x double> <double 1.000000e+00, double 1.000000e+00>, %130
  %132 = extractelement <2 x double> %131, i32 0
  %mul3.i.i.i = fmul double %.sink12, %132
  %133 = extractelement <2 x double> %130, i32 0
  %mul4.i.i.i = fmul double %133, 5.000000e-01
  %134 = shufflevector <8 x double> %127, <8 x double> undef, <2 x i32> <i32 1, i32 5>
  %135 = fmul <2 x double> %134, %131
  %136 = extractelement <2 x double> %135, i32 0
  %mul5.i.i.i = fmul double %136, %136
  %mul6.i.i.i = fmul double %mul3.i.i.i, %mul3.i.i.i
  %add.i.i.i = fadd double %mul5.i.i.i, %mul6.i.i.i
  %137 = load double, double addrspace(4)* getelementptr inbounds (%struct.SimConfig, %struct.SimConfig addrspace(4)* @d_cfg, i64 0, i32 0), align 8, !tbaa !16
  %sub8.i.i.i = fadd double %137, -1.000000e+00
  %138 = extractelement <2 x double> %131, i32 1
  %mul3.i1678.i.i = fmul double %.sink6, %138
  %139 = extractelement <2 x double> %130, i32 1
  %mul4.i1679.i.i = fmul double %139, 5.000000e-01
  %140 = extractelement <2 x double> %135, i32 1
  %mul5.i1680.i.i = fmul double %140, %140
  %mul6.i1681.i.i = fmul double %mul3.i1678.i.i, %mul3.i1678.i.i
  %add.i1682.i.i = fadd double %mul5.i1680.i.i, %mul6.i1681.i.i
  %141 = insertelement <2 x double> undef, double %mul4.i.i.i, i32 0
  %142 = insertelement <2 x double> %141, double %mul4.i1679.i.i, i32 1
  %143 = insertelement <2 x double> undef, double %add.i.i.i, i32 0
  %144 = insertelement <2 x double> %143, double %add.i1682.i.i, i32 1
  %145 = fmul <2 x double> %142, %144
  %146 = shufflevector <8 x double> %127, <8 x double> undef, <2 x i32> <i32 3, i32 7>
  %147 = fsub <2 x double> %146, %145
  %148 = insertelement <2 x double> undef, double %sub8.i.i.i, i32 0
  %149 = shufflevector <2 x double> %148, <2 x double> undef, <2 x i32> zeroinitializer
  %150 = fmul <2 x double> %149, %147
  %151 = fcmp ogt <2 x double> %150, <double 1.000000e-25, double 1.000000e-25>
  %152 = select <2 x i1> %151, <2 x double> %150, <2 x double> <double 1.000000e-25, double 1.000000e-25>
  %153 = insertelement <2 x double> undef, double %137, i32 0
  %154 = shufflevector <2 x double> %153, <2 x double> undef, <2 x i32> zeroinitializer
  %155 = fmul <2 x double> %154, %152
  %156 = fdiv <2 x double> %155, %130
  %157 = fcmp olt <2 x double> %156, <double 0x1000000000000000, double 0x1000000000000000>
  %158 = select <2 x i1> %157, <2 x double> <double 0x4FF0000000000000, double 0x4FF0000000000000>, <2 x double> <double 1.000000e+00, double 1.000000e+00>
  %159 = fmul <2 x double> %156, %158
  %160 = extractelement <2 x double> %159, i32 0
  %161 = tail call double @llvm.amdgcn.rsq.f64(double %160) #2
  %162 = fmul double %161, 5.000000e-01
  %163 = extractelement <2 x double> %159, i32 1
  %164 = tail call double @llvm.amdgcn.rsq.f64(double %163) #2
  %165 = insertelement <2 x double> undef, double %161, i32 0
  %166 = insertelement <2 x double> %165, double %164, i32 1
  %167 = fmul <2 x double> %159, %166
  %168 = fmul double %164, 5.000000e-01
  %169 = insertelement <2 x double> undef, double %162, i32 0
  %170 = insertelement <2 x double> %169, double %168, i32 1
  %171 = fneg <2 x double> %170
  %172 = tail call <2 x double> @llvm.fma.v2f64(<2 x double> %171, <2 x double> %167, <2 x double> <double 5.000000e-01, double 5.000000e-01>)
  %173 = tail call <2 x double> @llvm.fma.v2f64(<2 x double> %170, <2 x double> %172, <2 x double> %170)
  %174 = tail call <2 x double> @llvm.fma.v2f64(<2 x double> %167, <2 x double> %172, <2 x double> %167)
  %175 = fneg <2 x double> %174
  %176 = tail call <2 x double> @llvm.fma.v2f64(<2 x double> %175, <2 x double> %174, <2 x double> %159)
  %177 = tail call <2 x double> @llvm.fma.v2f64(<2 x double> %176, <2 x double> %173, <2 x double> %174)
  %178 = fneg <2 x double> %177
  %179 = tail call <2 x double> @llvm.fma.v2f64(<2 x double> %178, <2 x double> %177, <2 x double> %159)
  %180 = tail call <2 x double> @llvm.fma.v2f64(<2 x double> %179, <2 x double> %173, <2 x double> %177)
  %181 = select <2 x i1> %157, <2 x double> <double 0x37F0000000000000, double 0x37F0000000000000>, <2 x double> <double 1.000000e+00, double 1.000000e+00>
  %182 = fmul <2 x double> %181, %180
  %183 = fcmp oeq <2 x double> %159, <double 0x7FF0000000000000, double 0.000000e+00>
  %184 = fcmp oeq <2 x double> %159, <double 0.000000e+00, double 0x7FF0000000000000>
  %185 = or <2 x i1> %184, %183
  %186 = select <2 x i1> %185, <2 x double> %159, <2 x double> %182
  %187 = fsub <2 x double> %135, %186
  %188 = extractelement <2 x double> %187, i32 0
  %189 = extractelement <2 x double> %187, i32 1
  %cmp.i1660.i.i = fcmp olt double %188, %189
  %cond.i1661.i.i = select i1 %cmp.i1660.i.i, double %188, double %189
  %190 = extractelement <2 x double> %186, i32 0
  %add.i.i = fadd double %136, %190
  %191 = extractelement <2 x double> %186, i32 1
  %add15.i.i = fadd double %140, %191
  %cmp.i1658.i.i = fcmp ogt double %add.i.i, %add15.i.i
  %cond.i1659.i.i = select i1 %cmp.i1658.i.i, double %add.i.i, double %add15.i.i
  %mul.i1649.i.i = fmul double %.sink, %136
  %192 = extractelement <2 x double> %152, i32 0
  %add.i1650.i.i = fadd double %mul.i1649.i.i, %192
  %mul6.i1651.i.i = fmul double %.sink12, %136
  %add9.i1652.i.i = fadd double %.sink10, %192
  %mul10.i1653.i.i = fmul double %136, %add9.i1652.i.i
  %mul.i1621.i.i = fmul double %.sink7, %140
  %193 = extractelement <2 x double> %152, i32 1
  %add.i1622.i.i = fadd double %mul.i1621.i.i, %193
  %mul6.i1623.i.i = fmul double %.sink6, %140
  %add9.i.i.i = fadd double %.sink4, %193
  %mul10.i.i.i = fmul double %140, %add9.i.i.i
  %cmp.i.i = fcmp ult double %cond.i1661.i.i, 0.000000e+00
  br i1 %cmp.i.i, label %if.end.i.i, label %predication.split25

if.end.i.i:                                       ; preds = %if.end109
  %cmp21.i.i = fcmp ugt double %cond.i1659.i.i, 0.000000e+00
  br i1 %cmp21.i.i, label %if.end23.i.i, label %predication.split25

if.end23.i.i:                                     ; preds = %if.end.i.i
  %sub26.i.i = fsub double %193, %192
  %mul.i.i = fmul double %133, %136
  %sub27.i.i = fsub double %cond.i1661.i.i, %136
  %mul28.i.i = fmul double %mul.i.i, %sub27.i.i
  %add29.i.i = fadd double %sub26.i.i, %mul28.i.i
  %mul30.i.i = fmul double %139, %140
  %sub31.i.i = fsub double %cond.i1659.i.i, %140
  %mul32.i.i = fmul double %mul30.i.i, %sub31.i.i
  %sub33.i.i = fsub double %add29.i.i, %mul32.i.i
  %mul35.i.i = fmul double %133, %sub27.i.i
  %mul37.i.i = fmul double %139, %sub31.i.i
  %sub38.i.i = fsub double %mul35.i.i, %mul37.i.i
  %cmp.i1598.i.i = fcmp olt double %sub38.i.i, 0.000000e+00
  %fneg.i1599.i.i = fneg double %sub38.i.i
  %cond.i1600.i.i = select i1 %cmp.i1598.i.i, double %fneg.i1599.i.i, double %sub38.i.i
  %cmp40.i.i = fcmp olt double %cond.i1600.i.i, 0x3D06849B86A12B9B
  br i1 %cmp40.i.i, label %if.end21.i1511.i.i, label %lor.lhs.false.i.i

lor.lhs.false.i.i:                                ; preds = %if.end23.i.i
  %194 = tail call i1 @llvm.amdgcn.class.f64(double %sub33.i.i, i32 504) #2
  br i1 %194, label %lor.lhs.false42.i.i, label %if.end21.i1511.i.i

lor.lhs.false42.i.i:                              ; preds = %lor.lhs.false.i.i
  %195 = tail call i1 @llvm.amdgcn.class.f64(double %sub38.i.i, i32 504) #2
  br i1 %195, label %if.end48.i.i, label %if.end21.i1511.i.i

if.end21.i1511.i.i:                               ; preds = %lor.lhs.false42.i.i, %lor.lhs.false.i.i, %if.end23.i.i
  %sub22.i1506.i.i = fsub double %cond.i1659.i.i, %cond.i1661.i.i
  %cmp.i.i1507.i.i = fcmp olt double %sub22.i1506.i.i, 0.000000e+00
  %fneg.i.i1508.i.i = fneg double %sub22.i1506.i.i
  %cond.i.i1509.i.i = select i1 %cmp.i.i1507.i.i, double %fneg.i.i1508.i.i, double %sub22.i1506.i.i
  %cmp24.i1510.i.i = fcmp olt double %cond.i.i1509.i.i, 0x3D06849B86A12B9B
  br i1 %cmp24.i1510.i.i, label %predication.tail, label %predication.split

if.end48.i.i:                                     ; preds = %lor.lhs.false42.i.i
  %div.i.i = fdiv double %sub33.i.i, %sub38.i.i
  %196 = tail call i1 @llvm.amdgcn.class.f64(double %div.i.i, i32 504) #2
  br i1 %196, label %if.end54.i.i, label %if.end21.i1278.i.i

if.end21.i1278.i.i:                               ; preds = %if.end48.i.i
  %sub22.i1273.i.i = fsub double %cond.i1659.i.i, %cond.i1661.i.i
  %cmp.i.i1274.i.i = fcmp olt double %sub22.i1273.i.i, 0.000000e+00
  %fneg.i.i1275.i.i = fneg double %sub22.i1273.i.i
  %cond.i.i1276.i.i = select i1 %cmp.i.i1274.i.i, double %fneg.i.i1275.i.i, double %sub22.i1273.i.i
  %cmp24.i1277.i.i = fcmp olt double %cond.i.i1276.i.i, 0x3D06849B86A12B9B
  br i1 %cmp24.i1277.i.i, label %predication.tail66, label %predication.split65

if.end54.i.i:                                     ; preds = %if.end48.i.i
  %sub57.i.i = fsub double %div.i.i, %136
  %mul58.i.i = fmul double %mul35.i.i, %sub57.i.i
  %add59.i.i = fadd double %192, %mul58.i.i
  %cmp.i1130.i.i = fcmp ogt double %add59.i.i, 1.000000e-25
  %cond.i1131.i.i = select i1 %cmp.i1130.i.i, double %add59.i.i, double 1.000000e-25
  %sub61.i.i = fsub double %cond.i1661.i.i, %div.i.i
  %sub62.i.i = fsub double %cond.i1659.i.i, %div.i.i
  %cmp.i1127.i.i = fcmp olt double %sub61.i.i, 0.000000e+00
  %fneg.i1128.i.i = fneg double %sub61.i.i
  %cond.i1129.i.i = select i1 %cmp.i1127.i.i, double %fneg.i1128.i.i, double %sub61.i.i
  %cmp64.i.i = fcmp olt double %cond.i1129.i.i, 0x3D06849B86A12B9B
  br i1 %cmp64.i.i, label %if.end21.i1038.i.i, label %lor.lhs.false65.i.i

lor.lhs.false65.i.i:                              ; preds = %if.end54.i.i
  %cmp.i1125.i.i = fcmp olt double %sub62.i.i, 0.000000e+00
  %fneg.i1126.i.i = fneg double %sub62.i.i
  %cond.i.i.i = select i1 %cmp.i1125.i.i, double %fneg.i1126.i.i, double %sub62.i.i
  %cmp67.i.i = fcmp olt double %cond.i.i.i, 0x3D06849B86A12B9B
  br i1 %cmp67.i.i, label %if.end21.i1038.i.i, label %if.end72.i.i

if.end21.i1038.i.i:                               ; preds = %lor.lhs.false65.i.i, %if.end54.i.i
  %sub22.i1033.i.i = fsub double %cond.i1659.i.i, %cond.i1661.i.i
  %cmp.i.i1034.i.i = fcmp olt double %sub22.i1033.i.i, 0.000000e+00
  %fneg.i.i1035.i.i = fneg double %sub22.i1033.i.i
  %cond.i.i1036.i.i = select i1 %cmp.i.i1034.i.i, double %fneg.i.i1035.i.i, double %sub22.i1033.i.i
  %cmp24.i1037.i.i = fcmp olt double %cond.i.i1036.i.i, 0x3D06849B86A12B9B
  br i1 %cmp24.i1037.i.i, label %predication.tail86, label %predication.split85

if.end72.i.i:                                     ; preds = %lor.lhs.false65.i.i
  %div75.i.i = fdiv double %mul35.i.i, %sub61.i.i
  %div78.i.i = fdiv double %mul37.i.i, %sub62.i.i
  %cmp79.i.i = fcmp ogt double %div75.i.i, 0.000000e+00
  %cmp81.i.i = fcmp ogt double %div78.i.i, 0.000000e+00
  %or.cond.i.i = and i1 %cmp79.i.i, %cmp81.i.i
  br i1 %or.cond.i.i, label %lor.lhs.false82.i.i, label %if.end21.i805.i.i

lor.lhs.false82.i.i:                              ; preds = %if.end72.i.i
  %197 = tail call i1 @llvm.amdgcn.class.f64(double %div75.i.i, i32 504) #2
  br i1 %197, label %lor.lhs.false84.i.i, label %if.end21.i805.i.i

lor.lhs.false84.i.i:                              ; preds = %lor.lhs.false82.i.i
  %198 = tail call i1 @llvm.amdgcn.class.f64(double %div78.i.i, i32 504) #2
  br i1 %198, label %if.end90.i.i, label %if.end21.i805.i.i

if.end21.i805.i.i:                                ; preds = %lor.lhs.false84.i.i, %lor.lhs.false82.i.i, %if.end72.i.i
  %sub22.i800.i.i = fsub double %cond.i1659.i.i, %cond.i1661.i.i
  %cmp.i.i801.i.i = fcmp olt double %sub22.i800.i.i, 0.000000e+00
  %fneg.i.i802.i.i = fneg double %sub22.i800.i.i
  %cond.i.i803.i.i = select i1 %cmp.i.i801.i.i, double %fneg.i.i802.i.i, double %sub22.i800.i.i
  %cmp24.i804.i.i = fcmp olt double %cond.i.i803.i.i, 0x3D06849B86A12B9B
  br i1 %cmp24.i804.i.i, label %predication.tail106, label %predication.split105

if.end90.i.i:                                     ; preds = %lor.lhs.false84.i.i
  %mul91.i.i = fmul double %div.i.i, %div75.i.i
  %mul92.i.i = fmul double %mul3.i.i.i, %div75.i.i
  %mul94.i.i = fmul double %.sink10, %sub27.i.i
  %mul95.i.i = fmul double %136, %192
  %sub96.i.i = fsub double %mul94.i.i, %mul95.i.i
  %mul97.i.i = fmul double %div.i.i, %cond.i1131.i.i
  %add98.i.i = fadd double %sub96.i.i, %mul97.i.i
  %div99.i.i = fdiv double %add98.i.i, %sub61.i.i
  %199 = tail call i1 @llvm.amdgcn.class.f64(double %div99.i.i, i32 504) #2
  br i1 %199, label %if.end105.i.i, label %if.end21.i572.i.i

if.end21.i572.i.i:                                ; preds = %if.end90.i.i
  %sub22.i567.i.i = fsub double %cond.i1659.i.i, %cond.i1661.i.i
  %cmp.i.i568.i.i = fcmp olt double %sub22.i567.i.i, 0.000000e+00
  %fneg.i.i569.i.i = fneg double %sub22.i567.i.i
  %cond.i.i570.i.i = select i1 %cmp.i.i568.i.i, double %fneg.i.i569.i.i, double %sub22.i567.i.i
  %cmp24.i571.i.i = fcmp olt double %cond.i.i570.i.i, 0x3D06849B86A12B9B
  br i1 %cmp24.i571.i.i, label %predication.tail126, label %predication.split125

if.end105.i.i:                                    ; preds = %if.end90.i.i
  %mul116.i.i = fmul double %.sink4, %sub31.i.i
  %mul117.i.i = fmul double %140, %193
  %sub118.i.i = fsub double %mul116.i.i, %mul117.i.i
  %add120.i.i = fadd double %sub118.i.i, %mul97.i.i
  %div121.i.i = fdiv double %add120.i.i, %sub62.i.i
  %200 = tail call i1 @llvm.amdgcn.class.f64(double %div121.i.i, i32 504) #2
  %201 = fsub double %cond.i1659.i.i, %cond.i1661.i.i
  %202 = fcmp olt double %201, 0.000000e+00
  %203 = fneg double %201
  %204 = select i1 %202, double %203, double %201
  %205 = fcmp ult double %div.i.i, 0.000000e+00
  %206 = fcmp olt double %204, 0x3D06849B86A12B9B
  %207 = select i1 %200, i1 %205, i1 %206
  br i1 %207, label %merged.bb138, label %merged.bb137

cleanup128:                                       ; preds = %predication.split27, %predication.split25, %entry
  ret void

predication.split25:                              ; preds = %merged.bb139, %predication.tail126, %predication.tail106, %predication.tail86, %predication.tail66, %predication.tail, %if.end.i.i, %if.end109
  %moved.phi3.ph = phi double [ %spec.select, %merged.bb139 ], [ %376, %predication.tail126 ], [ %345, %predication.tail106 ], [ %314, %predication.tail86 ], [ %283, %predication.tail66 ], [ %252, %predication.tail ], [ %mul10.i.i.i, %if.end.i.i ], [ %mul10.i1653.i.i, %if.end109 ]
  %moved.phi2.ph = phi double [ %spec.select1, %merged.bb139 ], [ %375, %predication.tail126 ], [ %344, %predication.tail106 ], [ %313, %predication.tail86 ], [ %282, %predication.tail66 ], [ %251, %predication.tail ], [ %mul6.i1623.i.i, %if.end.i.i ], [ %mul6.i1651.i.i, %if.end109 ]
  %moved.phi1.ph = phi double [ %spec.select2, %merged.bb139 ], [ %374, %predication.tail126 ], [ %343, %predication.tail106 ], [ %312, %predication.tail86 ], [ %281, %predication.tail66 ], [ %250, %predication.tail ], [ %add.i1622.i.i, %if.end.i.i ], [ %add.i1650.i.i, %if.end109 ]
  %moved.phi.ph = phi double [ %spec.select3, %merged.bb139 ], [ %373, %predication.tail126 ], [ %342, %predication.tail106 ], [ %311, %predication.tail86 ], [ %280, %predication.tail66 ], [ %249, %predication.tail ], [ %.sink7, %if.end.i.i ], [ %.sink, %if.end109 ]
  %208 = sext i32 %add to i64
  %209 = getelementptr inbounds double, double addrspace(1)* %12, i64 %208
  store double %moved.phi.ph, double addrspace(1)* %209, align 8, !tbaa !11
  %210 = getelementptr inbounds double, double addrspace(1)* %13, i64 %208
  store double %moved.phi1.ph, double addrspace(1)* %210, align 8, !tbaa !11
  %211 = getelementptr inbounds double, double addrspace(1)* %14, i64 %208
  store double %moved.phi2.ph, double addrspace(1)* %211, align 8, !tbaa !11
  %212 = getelementptr inbounds double, double addrspace(1)* %15, i64 %208
  store double %moved.phi3.ph, double addrspace(1)* %212, align 8, !tbaa !11
  br label %cleanup128

predication.split27:                              ; preds = %land.lhs.true8.i
  %213 = sext i32 %add to i64
  %214 = getelementptr inbounds double, double addrspace(1)* %12, i64 %213
  %215 = bitcast double addrspace(1)* %214 to i64 addrspace(1)*
  store i64 0, i64 addrspace(1)* %215, align 8, !tbaa !11
  %216 = getelementptr inbounds double, double addrspace(1)* %13, i64 %213
  %217 = bitcast double addrspace(1)* %216 to i64 addrspace(1)*
  store i64 0, i64 addrspace(1)* %217, align 8, !tbaa !11
  %218 = getelementptr inbounds double, double addrspace(1)* %14, i64 %213
  %219 = bitcast double addrspace(1)* %218 to i64 addrspace(1)*
  store i64 0, i64 addrspace(1)* %219, align 8, !tbaa !11
  %220 = getelementptr inbounds double, double addrspace(1)* %15, i64 %213
  %221 = bitcast double addrspace(1)* %220 to i64 addrspace(1)*
  store i64 0, i64 addrspace(1)* %221, align 8, !tbaa !11
  br label %cleanup128

predication.split:                                ; preds = %if.end21.i1511.i.i
  %222 = fmul double %.sink, %cond.i1659.i.i
  %223 = fmul double %add.i1650.i.i, %cond.i1659.i.i
  %224 = fmul double %mul6.i1651.i.i, %cond.i1659.i.i
  %225 = fmul double %mul10.i1653.i.i, %cond.i1659.i.i
  %226 = fmul double %cond.i1661.i.i, %cond.i1659.i.i
  %227 = fsub double %.sink9, %.sink13
  %228 = fsub double %.sink7, %.sink
  %229 = fsub double %.sink6, %.sink12
  %230 = fsub double %.sink4, %.sink10
  %231 = fmul double %227, %226
  %232 = fmul double %228, %226
  %233 = fmul double %229, %226
  %234 = fmul double %230, %226
  %235 = fdiv double 1.000000e+00, %sub22.i1506.i.i
  %236 = fmul double %.sink7, %cond.i1661.i.i
  %237 = fsub double %222, %236
  %238 = fmul double %add.i1622.i.i, %cond.i1661.i.i
  %239 = fsub double %223, %238
  %240 = fmul double %mul6.i1623.i.i, %cond.i1661.i.i
  %241 = fsub double %224, %240
  %242 = fmul double %mul10.i.i.i, %cond.i1661.i.i
  %243 = fsub double %225, %242
  br label %predication.tail

predication.tail:                                 ; preds = %predication.split, %if.end21.i1511.i.i
  %merged.select37 = phi double [ %234, %predication.split ], [ %mul10.i1653.i.i, %if.end21.i1511.i.i ]
  %merged.select36 = phi double [ %243, %predication.split ], [ %mul10.i.i.i, %if.end21.i1511.i.i ]
  %merged.select35 = phi double [ %233, %predication.split ], [ %mul6.i1651.i.i, %if.end21.i1511.i.i ]
  %merged.select34 = phi double [ %241, %predication.split ], [ %mul6.i1623.i.i, %if.end21.i1511.i.i ]
  %merged.select33 = phi double [ %232, %predication.split ], [ %add.i1650.i.i, %if.end21.i1511.i.i ]
  %merged.select32 = phi double [ %239, %predication.split ], [ %add.i1622.i.i, %if.end21.i1511.i.i ]
  %merged.select31 = phi double [ %231, %predication.split ], [ %.sink, %if.end21.i1511.i.i ]
  %merged.select30 = phi double [ %237, %predication.split ], [ %.sink7, %if.end21.i1511.i.i ]
  %244 = phi double [ %235, %predication.split ], [ undef, %if.end21.i1511.i.i ]
  %245 = fadd double %merged.select31, %merged.select30
  %246 = fadd double %merged.select33, %merged.select32
  %247 = fadd double %merged.select35, %merged.select34
  %248 = fadd double %merged.select37, %merged.select36
  %merged.select38 = select i1 %cmp24.i1510.i.i, double %245, double %244
  %merged.select39 = select i1 %cmp24.i1510.i.i, double 5.000000e-01, double %245
  %249 = fmul double %merged.select38, %merged.select39
  %merged.select40 = select i1 %cmp24.i1510.i.i, double %246, double %244
  %merged.select41 = select i1 %cmp24.i1510.i.i, double 5.000000e-01, double %246
  %250 = fmul double %merged.select41, %merged.select40
  %merged.select42 = select i1 %cmp24.i1510.i.i, double %247, double %244
  %merged.select43 = select i1 %cmp24.i1510.i.i, double 5.000000e-01, double %247
  %251 = fmul double %merged.select43, %merged.select42
  %merged.select44 = select i1 %cmp24.i1510.i.i, double %248, double %244
  %merged.select45 = select i1 %cmp24.i1510.i.i, double 5.000000e-01, double %248
  %252 = fmul double %merged.select45, %merged.select44
  br label %predication.split25

predication.split65:                              ; preds = %if.end21.i1278.i.i
  %253 = fmul double %.sink, %cond.i1659.i.i
  %254 = fmul double %add.i1650.i.i, %cond.i1659.i.i
  %255 = fmul double %mul6.i1651.i.i, %cond.i1659.i.i
  %256 = fmul double %mul10.i1653.i.i, %cond.i1659.i.i
  %257 = fmul double %cond.i1661.i.i, %cond.i1659.i.i
  %258 = fsub double %.sink9, %.sink13
  %259 = fsub double %.sink7, %.sink
  %260 = fsub double %.sink6, %.sink12
  %261 = fsub double %.sink4, %.sink10
  %262 = fmul double %258, %257
  %263 = fmul double %259, %257
  %264 = fmul double %260, %257
  %265 = fmul double %261, %257
  %266 = fdiv double 1.000000e+00, %sub22.i1273.i.i
  %267 = fmul double %.sink7, %cond.i1661.i.i
  %268 = fsub double %253, %267
  %269 = fmul double %add.i1622.i.i, %cond.i1661.i.i
  %270 = fsub double %254, %269
  %271 = fmul double %mul6.i1623.i.i, %cond.i1661.i.i
  %272 = fsub double %255, %271
  %273 = fmul double %mul10.i.i.i, %cond.i1661.i.i
  %274 = fsub double %256, %273
  br label %predication.tail66

predication.tail66:                               ; preds = %predication.split65, %if.end21.i1278.i.i
  %merged.select55 = phi double [ %265, %predication.split65 ], [ %mul10.i1653.i.i, %if.end21.i1278.i.i ]
  %merged.select54 = phi double [ %274, %predication.split65 ], [ %mul10.i.i.i, %if.end21.i1278.i.i ]
  %merged.select53 = phi double [ %264, %predication.split65 ], [ %mul6.i1651.i.i, %if.end21.i1278.i.i ]
  %merged.select52 = phi double [ %272, %predication.split65 ], [ %mul6.i1623.i.i, %if.end21.i1278.i.i ]
  %merged.select51 = phi double [ %263, %predication.split65 ], [ %add.i1650.i.i, %if.end21.i1278.i.i ]
  %merged.select50 = phi double [ %270, %predication.split65 ], [ %add.i1622.i.i, %if.end21.i1278.i.i ]
  %merged.select49 = phi double [ %262, %predication.split65 ], [ %.sink, %if.end21.i1278.i.i ]
  %merged.select48 = phi double [ %268, %predication.split65 ], [ %.sink7, %if.end21.i1278.i.i ]
  %275 = phi double [ %266, %predication.split65 ], [ undef, %if.end21.i1278.i.i ]
  %276 = fadd double %merged.select49, %merged.select48
  %277 = fadd double %merged.select51, %merged.select50
  %278 = fadd double %merged.select53, %merged.select52
  %279 = fadd double %merged.select55, %merged.select54
  %merged.select56 = select i1 %cmp24.i1277.i.i, double %276, double %275
  %merged.select57 = select i1 %cmp24.i1277.i.i, double 5.000000e-01, double %276
  %280 = fmul double %merged.select56, %merged.select57
  %merged.select58 = select i1 %cmp24.i1277.i.i, double %277, double %275
  %merged.select59 = select i1 %cmp24.i1277.i.i, double 5.000000e-01, double %277
  %281 = fmul double %merged.select59, %merged.select58
  %merged.select60 = select i1 %cmp24.i1277.i.i, double %278, double %275
  %merged.select61 = select i1 %cmp24.i1277.i.i, double 5.000000e-01, double %278
  %282 = fmul double %merged.select61, %merged.select60
  %merged.select62 = select i1 %cmp24.i1277.i.i, double %279, double %275
  %merged.select63 = select i1 %cmp24.i1277.i.i, double 5.000000e-01, double %279
  %283 = fmul double %merged.select63, %merged.select62
  br label %predication.split25

predication.split85:                              ; preds = %if.end21.i1038.i.i
  %284 = fmul double %.sink, %cond.i1659.i.i
  %285 = fmul double %add.i1650.i.i, %cond.i1659.i.i
  %286 = fmul double %mul6.i1651.i.i, %cond.i1659.i.i
  %287 = fmul double %mul10.i1653.i.i, %cond.i1659.i.i
  %288 = fmul double %cond.i1661.i.i, %cond.i1659.i.i
  %289 = fsub double %.sink9, %.sink13
  %290 = fsub double %.sink7, %.sink
  %291 = fsub double %.sink6, %.sink12
  %292 = fsub double %.sink4, %.sink10
  %293 = fmul double %289, %288
  %294 = fmul double %290, %288
  %295 = fmul double %291, %288
  %296 = fmul double %292, %288
  %297 = fdiv double 1.000000e+00, %sub22.i1033.i.i
  %298 = fmul double %.sink7, %cond.i1661.i.i
  %299 = fsub double %284, %298
  %300 = fmul double %add.i1622.i.i, %cond.i1661.i.i
  %301 = fsub double %285, %300
  %302 = fmul double %mul6.i1623.i.i, %cond.i1661.i.i
  %303 = fsub double %286, %302
  %304 = fmul double %mul10.i.i.i, %cond.i1661.i.i
  %305 = fsub double %287, %304
  br label %predication.tail86

predication.tail86:                               ; preds = %predication.split85, %if.end21.i1038.i.i
  %merged.select75 = phi double [ %296, %predication.split85 ], [ %mul10.i1653.i.i, %if.end21.i1038.i.i ]
  %merged.select74 = phi double [ %305, %predication.split85 ], [ %mul10.i.i.i, %if.end21.i1038.i.i ]
  %merged.select73 = phi double [ %295, %predication.split85 ], [ %mul6.i1651.i.i, %if.end21.i1038.i.i ]
  %merged.select72 = phi double [ %303, %predication.split85 ], [ %mul6.i1623.i.i, %if.end21.i1038.i.i ]
  %merged.select71 = phi double [ %294, %predication.split85 ], [ %add.i1650.i.i, %if.end21.i1038.i.i ]
  %merged.select70 = phi double [ %301, %predication.split85 ], [ %add.i1622.i.i, %if.end21.i1038.i.i ]
  %merged.select69 = phi double [ %293, %predication.split85 ], [ %.sink, %if.end21.i1038.i.i ]
  %merged.select68 = phi double [ %299, %predication.split85 ], [ %.sink7, %if.end21.i1038.i.i ]
  %306 = phi double [ %297, %predication.split85 ], [ undef, %if.end21.i1038.i.i ]
  %307 = fadd double %merged.select69, %merged.select68
  %308 = fadd double %merged.select71, %merged.select70
  %309 = fadd double %merged.select73, %merged.select72
  %310 = fadd double %merged.select75, %merged.select74
  %merged.select76 = select i1 %cmp24.i1037.i.i, double %307, double %306
  %merged.select77 = select i1 %cmp24.i1037.i.i, double 5.000000e-01, double %307
  %311 = fmul double %merged.select76, %merged.select77
  %merged.select78 = select i1 %cmp24.i1037.i.i, double %308, double %306
  %merged.select79 = select i1 %cmp24.i1037.i.i, double 5.000000e-01, double %308
  %312 = fmul double %merged.select79, %merged.select78
  %merged.select80 = select i1 %cmp24.i1037.i.i, double %309, double %306
  %merged.select81 = select i1 %cmp24.i1037.i.i, double 5.000000e-01, double %309
  %313 = fmul double %merged.select81, %merged.select80
  %merged.select82 = select i1 %cmp24.i1037.i.i, double %310, double %306
  %merged.select83 = select i1 %cmp24.i1037.i.i, double 5.000000e-01, double %310
  %314 = fmul double %merged.select83, %merged.select82
  br label %predication.split25

predication.split105:                             ; preds = %if.end21.i805.i.i
  %315 = fmul double %.sink, %cond.i1659.i.i
  %316 = fmul double %add.i1650.i.i, %cond.i1659.i.i
  %317 = fmul double %mul6.i1651.i.i, %cond.i1659.i.i
  %318 = fmul double %mul10.i1653.i.i, %cond.i1659.i.i
  %319 = fmul double %cond.i1661.i.i, %cond.i1659.i.i
  %320 = fsub double %.sink9, %.sink13
  %321 = fsub double %.sink7, %.sink
  %322 = fsub double %.sink6, %.sink12
  %323 = fsub double %.sink4, %.sink10
  %324 = fmul double %320, %319
  %325 = fmul double %321, %319
  %326 = fmul double %322, %319
  %327 = fmul double %323, %319
  %328 = fdiv double 1.000000e+00, %sub22.i800.i.i
  %329 = fmul double %.sink7, %cond.i1661.i.i
  %330 = fsub double %315, %329
  %331 = fmul double %add.i1622.i.i, %cond.i1661.i.i
  %332 = fsub double %316, %331
  %333 = fmul double %mul6.i1623.i.i, %cond.i1661.i.i
  %334 = fsub double %317, %333
  %335 = fmul double %mul10.i.i.i, %cond.i1661.i.i
  %336 = fsub double %318, %335
  br label %predication.tail106

predication.tail106:                              ; preds = %predication.split105, %if.end21.i805.i.i
  %merged.select95 = phi double [ %327, %predication.split105 ], [ %mul10.i1653.i.i, %if.end21.i805.i.i ]
  %merged.select94 = phi double [ %336, %predication.split105 ], [ %mul10.i.i.i, %if.end21.i805.i.i ]
  %merged.select93 = phi double [ %326, %predication.split105 ], [ %mul6.i1651.i.i, %if.end21.i805.i.i ]
  %merged.select92 = phi double [ %334, %predication.split105 ], [ %mul6.i1623.i.i, %if.end21.i805.i.i ]
  %merged.select91 = phi double [ %325, %predication.split105 ], [ %add.i1650.i.i, %if.end21.i805.i.i ]
  %merged.select90 = phi double [ %332, %predication.split105 ], [ %add.i1622.i.i, %if.end21.i805.i.i ]
  %merged.select89 = phi double [ %324, %predication.split105 ], [ %.sink, %if.end21.i805.i.i ]
  %merged.select88 = phi double [ %330, %predication.split105 ], [ %.sink7, %if.end21.i805.i.i ]
  %337 = phi double [ %328, %predication.split105 ], [ undef, %if.end21.i805.i.i ]
  %338 = fadd double %merged.select89, %merged.select88
  %339 = fadd double %merged.select91, %merged.select90
  %340 = fadd double %merged.select93, %merged.select92
  %341 = fadd double %merged.select95, %merged.select94
  %merged.select96 = select i1 %cmp24.i804.i.i, double %338, double %337
  %merged.select97 = select i1 %cmp24.i804.i.i, double 5.000000e-01, double %338
  %342 = fmul double %merged.select96, %merged.select97
  %merged.select98 = select i1 %cmp24.i804.i.i, double %339, double %337
  %merged.select99 = select i1 %cmp24.i804.i.i, double 5.000000e-01, double %339
  %343 = fmul double %merged.select99, %merged.select98
  %merged.select100 = select i1 %cmp24.i804.i.i, double %340, double %337
  %merged.select101 = select i1 %cmp24.i804.i.i, double 5.000000e-01, double %340
  %344 = fmul double %merged.select101, %merged.select100
  %merged.select102 = select i1 %cmp24.i804.i.i, double %341, double %337
  %merged.select103 = select i1 %cmp24.i804.i.i, double 5.000000e-01, double %341
  %345 = fmul double %merged.select103, %merged.select102
  br label %predication.split25

predication.split125:                             ; preds = %if.end21.i572.i.i
  %346 = fmul double %.sink, %cond.i1659.i.i
  %347 = fmul double %add.i1650.i.i, %cond.i1659.i.i
  %348 = fmul double %mul6.i1651.i.i, %cond.i1659.i.i
  %349 = fmul double %mul10.i1653.i.i, %cond.i1659.i.i
  %350 = fmul double %cond.i1661.i.i, %cond.i1659.i.i
  %351 = fsub double %.sink9, %.sink13
  %352 = fsub double %.sink7, %.sink
  %353 = fsub double %.sink6, %.sink12
  %354 = fsub double %.sink4, %.sink10
  %355 = fmul double %351, %350
  %356 = fmul double %352, %350
  %357 = fmul double %353, %350
  %358 = fmul double %354, %350
  %359 = fdiv double 1.000000e+00, %sub22.i567.i.i
  %360 = fmul double %.sink7, %cond.i1661.i.i
  %361 = fsub double %346, %360
  %362 = fmul double %add.i1622.i.i, %cond.i1661.i.i
  %363 = fsub double %347, %362
  %364 = fmul double %mul6.i1623.i.i, %cond.i1661.i.i
  %365 = fsub double %348, %364
  %366 = fmul double %mul10.i.i.i, %cond.i1661.i.i
  %367 = fsub double %349, %366
  br label %predication.tail126

predication.tail126:                              ; preds = %predication.split125, %if.end21.i572.i.i
  %merged.select115 = phi double [ %358, %predication.split125 ], [ %mul10.i1653.i.i, %if.end21.i572.i.i ]
  %merged.select114 = phi double [ %367, %predication.split125 ], [ %mul10.i.i.i, %if.end21.i572.i.i ]
  %merged.select113 = phi double [ %357, %predication.split125 ], [ %mul6.i1651.i.i, %if.end21.i572.i.i ]
  %merged.select112 = phi double [ %365, %predication.split125 ], [ %mul6.i1623.i.i, %if.end21.i572.i.i ]
  %merged.select111 = phi double [ %356, %predication.split125 ], [ %add.i1650.i.i, %if.end21.i572.i.i ]
  %merged.select110 = phi double [ %363, %predication.split125 ], [ %add.i1622.i.i, %if.end21.i572.i.i ]
  %merged.select109 = phi double [ %355, %predication.split125 ], [ %.sink, %if.end21.i572.i.i ]
  %merged.select108 = phi double [ %361, %predication.split125 ], [ %.sink7, %if.end21.i572.i.i ]
  %368 = phi double [ %359, %predication.split125 ], [ undef, %if.end21.i572.i.i ]
  %369 = fadd double %merged.select109, %merged.select108
  %370 = fadd double %merged.select111, %merged.select110
  %371 = fadd double %merged.select113, %merged.select112
  %372 = fadd double %merged.select115, %merged.select114
  %merged.select116 = select i1 %cmp24.i571.i.i, double %369, double %368
  %merged.select117 = select i1 %cmp24.i571.i.i, double 5.000000e-01, double %369
  %373 = fmul double %merged.select116, %merged.select117
  %merged.select118 = select i1 %cmp24.i571.i.i, double %370, double %368
  %merged.select119 = select i1 %cmp24.i571.i.i, double 5.000000e-01, double %370
  %374 = fmul double %merged.select119, %merged.select118
  %merged.select120 = select i1 %cmp24.i571.i.i, double %371, double %368
  %merged.select121 = select i1 %cmp24.i571.i.i, double 5.000000e-01, double %371
  %375 = fmul double %merged.select121, %merged.select120
  %merged.select122 = select i1 %cmp24.i571.i.i, double %372, double %368
  %merged.select123 = select i1 %cmp24.i571.i.i, double 5.000000e-01, double %372
  %376 = fmul double %merged.select123, %merged.select122
  br label %predication.split25

merged.bb137:                                     ; preds = %if.end105.i.i
  br i1 %200, label %predication.tail174.thread, label %predication.split175

predication.tail174.thread:                       ; preds = %merged.bb137
  %377 = fsub double %div75.i.i, %.sink13
  br label %predication.tail176

predication.split175:                             ; preds = %merged.bb137
  %378 = fmul double %.sink, %cond.i1659.i.i
  %379 = fmul double %add.i1650.i.i, %cond.i1659.i.i
  %380 = fmul double %mul6.i1651.i.i, %cond.i1659.i.i
  %381 = fmul double %mul10.i1653.i.i, %cond.i1659.i.i
  %382 = fmul double %cond.i1661.i.i, %cond.i1659.i.i
  %383 = fsub double %.sink9, %.sink13
  %384 = fsub double %.sink7, %.sink
  %385 = fsub double %.sink6, %.sink12
  %386 = fsub double %.sink4, %.sink10
  %387 = fmul double %383, %382
  %388 = fmul double %384, %382
  %389 = fmul double %385, %382
  br label %predication.tail176

predication.tail176:                              ; preds = %predication.split175, %predication.tail174.thread
  %390 = phi double [ %381, %predication.split175 ], [ undef, %predication.tail174.thread ]
  %merged.select154 = phi double [ %mul10.i.i.i, %predication.split175 ], [ %cond.i1661.i.i, %predication.tail174.thread ]
  %merged.select152 = phi double [ %380, %predication.split175 ], [ %div99.i.i, %predication.tail174.thread ]
  %merged.select150 = phi double [ %mul6.i1623.i.i, %predication.split175 ], [ %cond.i1661.i.i, %predication.tail174.thread ]
  %merged.select148 = phi double [ %379, %predication.split175 ], [ %mul92.i.i, %predication.tail174.thread ]
  %merged.select146 = phi double [ %add.i1622.i.i, %predication.split175 ], [ %cond.i1661.i.i, %predication.tail174.thread ]
  %merged.select144 = phi double [ %378, %predication.split175 ], [ %mul91.i.i, %predication.tail174.thread ]
  %merged.select143 = phi double [ %382, %predication.split175 ], [ %377, %predication.tail174.thread ]
  %merged.select142 = phi double [ %386, %predication.split175 ], [ %cond.i1661.i.i, %predication.tail174.thread ]
  %391 = phi double [ %387, %predication.split175 ], [ undef, %predication.tail174.thread ]
  %392 = phi double [ %388, %predication.split175 ], [ undef, %predication.tail174.thread ]
  %393 = phi double [ %389, %predication.split175 ], [ undef, %predication.tail174.thread ]
  %394 = fmul double %merged.select143, %merged.select142
  %395 = fdiv double 1.000000e+00, %201
  %396 = fadd double %.sink, %394
  %397 = fmul double %.sink7, %cond.i1661.i.i
  %merged.select145 = select i1 %200, double %.sink, double %397
  %398 = fsub double %merged.select144, %merged.select145
  %merged.select147 = select i1 %200, double %398, double %cond.i1661.i.i
  %399 = fmul double %merged.select146, %merged.select147
  %400 = fadd double %add.i1650.i.i, %399
  %merged.select149 = select i1 %200, double %.sink12, double %399
  %401 = fsub double %merged.select148, %merged.select149
  %merged.select151 = select i1 %200, double %401, double %cond.i1661.i.i
  %402 = fmul double %merged.select150, %merged.select151
  %403 = fadd double %mul6.i1651.i.i, %402
  %merged.select153 = select i1 %200, double %.sink10, double %402
  %404 = fsub double %merged.select152, %merged.select153
  %merged.select155 = select i1 %200, double %404, double %cond.i1661.i.i
  %405 = fmul double %merged.select154, %merged.select155
  %merged.select156 = select i1 %200, double %mul10.i1653.i.i, double %398
  %merged.select157 = select i1 %200, double %405, double %391
  %406 = fadd double %merged.select156, %merged.select157
  br i1 %200, label %merged.bb139, label %predication.split189

predication.split189:                             ; preds = %predication.tail176
  %407 = fsub double %390, %405
  %408 = fadd double %392, %401
  %409 = fadd double %393, %404
  %410 = fadd double %394, %407
  %411 = fmul double %395, %406
  %412 = fmul double %395, %408
  %413 = fmul double %395, %409
  %414 = fmul double %395, %410
  br label %merged.bb139

merged.bb138:                                     ; preds = %if.end105.i.i
  %mul113.i.i = fmul double %mul3.i1678.i.i, %div78.i.i
  %mul112.i.i = fmul double %div.i.i, %div78.i.i
  %415 = fadd double %.sink7, %.sink
  %416 = fadd double %add.i1622.i.i, %add.i1650.i.i
  %417 = fadd double %mul6.i1623.i.i, %mul6.i1651.i.i
  %spec.select186 = select i1 %200, double %cond.i1659.i.i, double %417
  %spec.select187 = select i1 %200, double %cond.i1659.i.i, double %416
  %spec.select188 = select i1 %200, double %cond.i1659.i.i, double %415
  %418 = fsub double %div78.i.i, %.sink9
  %419 = fadd double %mul10.i.i.i, %mul10.i1653.i.i
  %merged.select159 = select i1 %200, double %418, double 5.000000e-01
  %420 = fmul double %spec.select188, %merged.select159
  %421 = fadd double %.sink7, %420
  %422 = fsub double %mul112.i.i, %.sink7
  %merged.select161 = select i1 %200, double %422, double 5.000000e-01
  %423 = fmul double %spec.select187, %merged.select161
  %424 = fadd double %add.i1622.i.i, %423
  %425 = fsub double %mul113.i.i, %.sink6
  %merged.select163 = select i1 %200, double %425, double 5.000000e-01
  %426 = fmul double %spec.select186, %merged.select163
  %427 = fadd double %mul6.i1623.i.i, %426
  %428 = fsub double %div121.i.i, %.sink4
  %merged.select164 = select i1 %200, double %cond.i1659.i.i, double %419
  %merged.select165 = select i1 %200, double %428, double 5.000000e-01
  %429 = fmul double %merged.select164, %merged.select165
  %430 = fadd double %mul10.i.i.i, %429
  br label %merged.bb139

merged.bb139:                                     ; preds = %merged.bb138, %predication.split189, %predication.tail176
  %431 = phi double [ %396, %predication.tail176 ], [ %396, %predication.split189 ], [ %421, %merged.bb138 ]
  %432 = phi double [ %400, %predication.tail176 ], [ %400, %predication.split189 ], [ %424, %merged.bb138 ]
  %433 = phi double [ %403, %predication.tail176 ], [ %403, %predication.split189 ], [ %427, %merged.bb138 ]
  %434 = phi double [ %406, %predication.tail176 ], [ %406, %predication.split189 ], [ %430, %merged.bb138 ]
  %435 = phi double [ undef, %predication.tail176 ], [ %411, %predication.split189 ], [ %420, %merged.bb138 ]
  %436 = phi double [ undef, %predication.tail176 ], [ %412, %predication.split189 ], [ %423, %merged.bb138 ]
  %437 = phi double [ undef, %predication.tail176 ], [ %413, %predication.split189 ], [ %426, %merged.bb138 ]
  %438 = phi double [ undef, %predication.tail176 ], [ %414, %predication.split189 ], [ %429, %merged.bb138 ]
  %spec.select = select i1 %200, double %434, double %438
  %spec.select1 = select i1 %200, double %433, double %437
  %spec.select2 = select i1 %200, double %432, double %436
  %spec.select3 = select i1 %200, double %431, double %435
  br label %predication.split25
}

; Function Attrs: nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.workgroup.id.x() #1

; Function Attrs: nounwind readnone speculatable willreturn
declare align 4 i8 addrspace(4)* @llvm.amdgcn.dispatch.ptr() #1

; Function Attrs: nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.workitem.id.x() #1

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.amdgcn.rsq.f64(double) #1

; Function Attrs: nounwind readnone speculatable willreturn
declare <2 x double> @llvm.fma.v2f64(<2 x double>, <2 x double>, <2 x double>) #1

; Function Attrs: nounwind readnone speculatable willreturn
declare i1 @llvm.amdgcn.class.f64(double, i32) #1

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.fma.f64(double, double, double) #1

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
!13 = !{!14, !12, i64 40}
!14 = !{!"_ZTS9SimConfig", !12, i64 0, !12, i64 8, !12, i64 16, !12, i64 24, !12, i64 32, !12, i64 40, !12, i64 48, !12, i64 56, !12, i64 64, !12, i64 72, !12, i64 80, !15, i64 88}
!15 = !{!"int", !9, i64 0}
!16 = !{!14, !12, i64 0}
