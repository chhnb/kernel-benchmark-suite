; ModuleID = '/home/chh/kernel-benchmark-suite/experiments/hypersonic-outer-ablation-v1/pair-auto-vs-none/variant.ll'
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
  %1 = addrspacecast double addrspace(1)* %0 to double*
  %2 = extractvalue %struct.Usoa.coerce %U.coerce, 1
  %3 = addrspacecast double addrspace(1)* %2 to double*
  %4 = extractvalue %struct.Usoa.coerce %U.coerce, 2
  %5 = addrspacecast double addrspace(1)* %4 to double*
  %6 = extractvalue %struct.Usoa.coerce %U.coerce, 3
  %7 = addrspacecast double addrspace(1)* %6 to double*
  %8 = extractvalue %struct.Usoa.coerce %xL_states.coerce, 0
  %9 = addrspacecast double addrspace(1)* %8 to double*
  %10 = extractvalue %struct.Usoa.coerce %xL_states.coerce, 1
  %11 = addrspacecast double addrspace(1)* %10 to double*
  %12 = extractvalue %struct.Usoa.coerce %xL_states.coerce, 2
  %13 = addrspacecast double addrspace(1)* %12 to double*
  %14 = extractvalue %struct.Usoa.coerce %xL_states.coerce, 3
  %15 = addrspacecast double addrspace(1)* %14 to double*
  %16 = extractvalue %struct.Usoa.coerce %xR_states.coerce, 0
  %17 = addrspacecast double addrspace(1)* %16 to double*
  %18 = extractvalue %struct.Usoa.coerce %xR_states.coerce, 1
  %19 = addrspacecast double addrspace(1)* %18 to double*
  %20 = extractvalue %struct.Usoa.coerce %xR_states.coerce, 2
  %21 = addrspacecast double addrspace(1)* %20 to double*
  %22 = extractvalue %struct.Usoa.coerce %xR_states.coerce, 3
  %23 = addrspacecast double addrspace(1)* %22 to double*
  %24 = extractvalue %struct.Usoa.coerce %xFlux.coerce, 0
  %25 = extractvalue %struct.Usoa.coerce %xFlux.coerce, 1
  %26 = extractvalue %struct.Usoa.coerce %xFlux.coerce, 2
  %27 = extractvalue %struct.Usoa.coerce %xFlux.coerce, 3
  %28 = tail call i32 @llvm.amdgcn.workgroup.id.x() #2
  %29 = tail call align 4 dereferenceable(64) i8 addrspace(4)* @llvm.amdgcn.dispatch.ptr() #2
  %30 = getelementptr i8, i8 addrspace(4)* %29, i64 4
  %31 = bitcast i8 addrspace(4)* %30 to i16 addrspace(4)*
  %32 = load i16, i16 addrspace(4)* %31, align 4, !range !5, !invariant.load !6
  %33 = zext i16 %32 to i32
  %34 = mul i32 %28, %33
  %35 = tail call i32 @llvm.amdgcn.workitem.id.x() #2, !range !7
  %add = add i32 %34, %35
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
  %36 = load i8, i8 addrspace(1)* %arrayidx268, align 1, !tbaa !8
  %tobool.not = icmp eq i8 %36, 0
  %phi.cast = zext i1 %tobool.not to i32
  %cmp10 = icmp slt i32 %rem.decomposed, 8192
  br i1 %cmp10, label %land.rhs11, label %land.end17

land.rhs11:                                       ; preds = %land.end, %if.end
  %37 = phi i32 [ %phi.cast, %land.end ], [ 0, %if.end ]
  %idxprom13414.pn.in = add nsw i32 %rem.decomposed, %mul.i279
  %idxprom13414.pn = sext i32 %idxprom13414.pn.in to i64
  %arrayidx14267416 = getelementptr inbounds i8, i8 addrspace(1)* %mask.coerce, i64 %idxprom13414.pn
  %38 = load i8, i8 addrspace(1)* %arrayidx14267416, align 1, !tbaa !8
  %tobool15.not = icmp eq i8 %38, 0
  %phi.cast256 = zext i1 %tobool15.not to i32
  br label %land.end17

land.end17:                                       ; preds = %land.rhs11, %land.end
  %39 = phi i32 [ %phi.cast, %land.end ], [ %37, %land.rhs11 ]
  %40 = phi i32 [ 0, %land.end ], [ %phi.cast256, %land.rhs11 ]
  %41 = insertelement <12 x double*> undef, double* %1, i32 0
  %42 = insertelement <12 x double*> %41, double* %3, i32 1
  %43 = insertelement <12 x double*> %42, double* %5, i32 2
  %44 = insertelement <12 x double*> %43, double* %7, i32 3
  %45 = insertelement <12 x double*> %44, double* %9, i32 4
  %46 = insertelement <12 x double*> %45, double* %11, i32 5
  %47 = insertelement <12 x double*> %46, double* %13, i32 6
  %48 = insertelement <12 x double*> %47, double* %15, i32 7
  %49 = insertelement <12 x double*> %48, double* %17, i32 8
  %50 = insertelement <12 x double*> %49, double* %19, i32 9
  %51 = insertelement <12 x double*> %50, double* %21, i32 10
  %52 = insertelement <12 x double*> %51, double* %23, i32 11
  %tobool.not.i = icmp eq i32 %39, 0
  %tobool10.not.i = icmp eq i32 %40, 0
  br i1 %tobool.not.i, label %land.lhs.true8.i, label %merged.bb.i

land.lhs.true8.i:                                 ; preds = %land.end17
  br i1 %tobool10.not.i, label %predication.split27, label %if.then11.i

if.then11.i:                                      ; preds = %land.lhs.true8.i
  %53 = icmp sgt i32 %div, 0
  %spec.store.select.i.i35.i = select i1 %53, i32 %div, i32 0
  %cmp6.i.i36.i = icmp slt i32 %rem.decomposed, 1
  %54 = icmp slt i32 %spec.store.select.i.i35.i, 1023
  %55 = select i1 %54, i32 %spec.store.select.i.i35.i, i32 1023
  %56 = shl nuw nsw i32 %55, 13
  br i1 %cmp6.i.i36.i, label %merged.branch.split301.i, label %merged.bb158.i

if.end9.i.i.i:                                    ; preds = %merged.branch.split.i
  %57 = icmp slt i32 %91, 1023
  %spec.store.select32.i.i.i = select i1 %57, i32 %91, i32 1023
  %cmp10.i.i.i = icmp sgt i32 %.sroa.speculated, 8190
  %mul.i97.i.i.i = shl nuw nsw i32 %spec.store.select32.i.i.i, 13
  %58 = add nsw i32 %88, %mul.i97.i.i.i
  %59 = sext i32 %58 to i64
  br i1 %cmp10.i.i.i, label %predication.split273.i, label %merged.bb227.i

g_2_2.exit.i:                                     ; preds = %merged.bb231.i, %predication.split273.i, %merged.bb231.i.thread152
  %retval.sroa.0.1.i.i.i = phi double [ 1.000000e+00, %merged.bb231.i.thread152 ], [ %140, %merged.bb231.i ], [ %184, %predication.split273.i ]
  %retval.sroa.5.1.i.i.i = phi double [ %171, %merged.bb231.i.thread152 ], [ %166, %merged.bb231.i ], [ %185, %predication.split273.i ]
  %retval.sroa.10.1.i.i.i = phi double [ 0.000000e+00, %merged.bb231.i.thread152 ], [ %171, %merged.bb231.i ], [ %186, %predication.split273.i ]
  %retval.sroa.15.1.i.i.i = phi double [ %176, %merged.bb231.i.thread152 ], [ %188, %merged.bb231.i ], [ %187, %predication.split273.i ]
  %60 = insertelement <8 x i64> undef, i64 %77, i32 0
  %61 = insertelement <8 x i64> %60, i64 %80, i32 1
  %62 = insertelement <8 x i64> %61, i64 %83, i32 2
  %63 = insertelement <8 x i64> %62, i64 %86, i32 3
  %64 = bitcast <8 x i64> %63 to <8 x double>
  %65 = insertelement <8 x double> %64, double %retval.sroa.0.1.i.i.i, i32 4
  br label %if.end109

merged.bb.i:                                      ; preds = %land.end17
  %66 = select i1 %tobool10.not.i, double addrspace(1)* %0, double addrspace(1)* %8
  %67 = select i1 %tobool10.not.i, i32 1, i32 5
  %68 = extractelement <12 x double*> %52, i32 %67
  %69 = select i1 %tobool10.not.i, i32 2, i32 6
  %70 = extractelement <12 x double*> %52, i32 %69
  %71 = select i1 %tobool10.not.i, i32 3, i32 7
  %72 = extractelement <12 x double*> %52, i32 %71
  %.sroa.speculated = select i1 %tobool10.not.i, i32 %sub, i32 %rem.decomposed
  %73 = add nsw i32 %sub, %mul.i279
  %74 = sext i32 %73 to i64
  %75 = getelementptr inbounds double, double addrspace(1)* %16, i64 %74
  %76 = bitcast double addrspace(1)* %75 to i64 addrspace(1)*
  %77 = load i64, i64 addrspace(1)* %76, align 8, !tbaa !11
  %78 = getelementptr inbounds double, double addrspace(1)* %18, i64 %74
  %79 = bitcast double addrspace(1)* %78 to i64 addrspace(1)*
  %80 = load i64, i64 addrspace(1)* %79, align 8, !tbaa !11
  %81 = getelementptr inbounds double, double addrspace(1)* %20, i64 %74
  %82 = bitcast double addrspace(1)* %81 to i64 addrspace(1)*
  %83 = load i64, i64 addrspace(1)* %82, align 8, !tbaa !11
  %84 = getelementptr inbounds double, double addrspace(1)* %22, i64 %74
  %85 = bitcast double addrspace(1)* %84 to i64 addrspace(1)*
  %86 = load i64, i64 addrspace(1)* %85, align 8, !tbaa !11
  %87 = select i1 %tobool10.not.i, i32 0, i32 %mul.i279
  %88 = add i32 %87, %rem.decomposed
  %89 = icmp sgt i32 %div, 0
  %90 = sext i32 %88 to i64
  %91 = select i1 %89, i32 %div, i32 0
  %92 = icmp slt i32 %.sroa.speculated, -1
  br i1 %tobool10.not.i, label %merged.branch.split.i, label %predication.split21.i

predication.split21.i:                            ; preds = %merged.bb.i
  %93 = getelementptr inbounds double, double addrspace(1)* %66, i64 %90
  %94 = load double, double addrspace(1)* %93, align 8, !tbaa !11
  %95 = getelementptr inbounds double, double* %68, i64 %90
  %96 = load double, double* %95, align 8, !tbaa !11
  %97 = getelementptr inbounds double, double* %70, i64 %90
  %98 = load double, double* %97, align 8, !tbaa !11
  %99 = getelementptr inbounds double, double* %72, i64 %90
  %100 = load double, double* %99, align 8, !tbaa !11
  %101 = insertelement <8 x i64> undef, i64 %77, i32 0
  %102 = insertelement <8 x i64> %101, i64 %80, i32 1
  %103 = insertelement <8 x i64> %102, i64 %83, i32 2
  %104 = insertelement <8 x i64> %103, i64 %86, i32 3
  %105 = bitcast <8 x i64> %104 to <8 x double>
  %106 = insertelement <8 x double> %105, double %94, i32 4
  br label %if.end109

merged.branch.split.i:                            ; preds = %merged.bb.i
  br i1 %92, label %predication.tail250.i, label %if.end9.i.i.i

merged.bb158.i:                                   ; preds = %if.then11.i
  %107 = icmp sgt i32 %rem.decomposed, 8192
  %108 = or i32 %56, 8191
  %109 = zext i32 %108 to i64
  br i1 %107, label %merged.bb159.i.thread.thread, label %merged.bb294.i

merged.bb159.i.thread.thread:                     ; preds = %merged.bb158.i
  %110 = getelementptr inbounds double, double addrspace(1)* %2, i64 %109
  %111 = getelementptr inbounds double, double addrspace(1)* %0, i64 %109
  %112 = load double, double addrspace(1)* %111, align 8, !tbaa !11
  %113 = load double, double addrspace(1)* %110, align 8, !tbaa !11
  %114 = getelementptr inbounds double, double addrspace(1)* %4, i64 %109
  %115 = load double, double addrspace(1)* %114, align 8, !tbaa !11
  %116 = getelementptr inbounds double, double addrspace(1)* %6, i64 %109
  %117 = load double, double addrspace(1)* %116, align 8, !tbaa !11
  br label %face_decide.exit

merged.bb227.i:                                   ; preds = %if.end9.i.i.i
  %118 = getelementptr inbounds i8, i8 addrspace(1)* %mask.coerce, i64 %59
  %119 = load i8, i8 addrspace(1)* %118, align 1, !tbaa !8
  %120 = icmp eq i8 %119, 0
  br i1 %120, label %predication.split273.i, label %predication.split249.i

predication.split249.i:                           ; preds = %merged.bb227.i
  %121 = getelementptr inbounds double, double addrspace(1)* %66, i64 %74
  %122 = load double, double addrspace(1)* %121, align 8, !tbaa !11
  %123 = getelementptr inbounds double, double* %68, i64 %74
  %124 = load double, double* %123, align 8, !tbaa !11
  %125 = getelementptr inbounds double, double* %70, i64 %74
  %126 = load double, double* %125, align 8, !tbaa !11
  %127 = getelementptr inbounds double, double* %72, i64 %74
  %128 = load double, double* %127, align 8, !tbaa !11
  %129 = fcmp ogt double %122, 1.000000e-25
  %130 = select i1 %129, double %122, double 1.000000e-25
  %131 = fdiv double 1.000000e+00, %130
  %132 = fmul double %124, %131
  %133 = fmul double %126, %131
  %134 = fmul double %130, 5.000000e-01
  %135 = fmul double %132, %132
  %136 = fmul double %133, %133
  %137 = fadd double %135, %136
  %138 = fmul double %134, %137
  br label %predication.tail250.i

predication.tail250.i:                            ; preds = %predication.split249.i, %merged.branch.split.i
  %spec.select202 = phi double [ 1.000000e+00, %merged.branch.split.i ], [ 1.000000e-25, %predication.split249.i ]
  %139 = phi double [ undef, %merged.branch.split.i ], [ %128, %predication.split249.i ]
  %140 = phi double [ undef, %merged.branch.split.i ], [ %130, %predication.split249.i ]
  %141 = phi double [ undef, %merged.branch.split.i ], [ %132, %predication.split249.i ]
  %142 = phi double [ undef, %merged.branch.split.i ], [ %133, %predication.split249.i ]
  %143 = phi double [ undef, %merged.branch.split.i ], [ %138, %predication.split249.i ]
  %144 = load double, double addrspace(4)* getelementptr inbounds (%struct.SimConfig, %struct.SimConfig addrspace(4)* @d_cfg, i64 0, i32 5), align 8
  %145 = fsub double %139, %143
  %146 = load double, double addrspace(4)* getelementptr inbounds (%struct.SimConfig, %struct.SimConfig addrspace(4)* @d_cfg, i64 0, i32 0), align 8, !tbaa !13
  %147 = fcmp olt double %146, 0x1000000000000000
  %148 = select i1 %147, double 0x4FF0000000000000, double 1.000000e+00
  %149 = fmul double %146, %148
  %150 = tail call double @llvm.amdgcn.rsq.f64(double %149) #2
  %151 = fmul double %149, %150
  %spec.select197 = select i1 %92, double 5.000000e-01, double %145
  %152 = fadd double %146, -1.000000e+00
  %merged.select232.i = select i1 %92, double %150, double %152
  %153 = fmul double %spec.select197, %merged.select232.i
  %154 = fneg double %153
  %155 = tail call double @llvm.fma.f64(double %154, double %151, double 5.000000e-01) #2
  %156 = tail call double @llvm.fma.f64(double %153, double %155, double %153) #2
  %157 = tail call double @llvm.fma.f64(double %151, double %155, double %151) #2
  %spec.select201 = select i1 %92, double %144, double %140
  %spec.select203 = select i1 %92, double 0x37F0000000000000, double %153
  %spec.select204 = select i1 %92, double %157, double %141
  %158 = fcmp ogt double %153, 1.000000e-25
  %159 = fneg double %spec.select204
  %160 = tail call double @llvm.fma.f64(double %159, double %157, double %149) #2
  %161 = tail call double @llvm.fma.f64(double %160, double %156, double %157) #2
  %merged.select235.i = select i1 %92, double %161, double %142
  %162 = fneg double %merged.select235.i
  %163 = tail call double @llvm.fma.f64(double %162, double %161, double %149) #2
  %164 = tail call double @llvm.fma.f64(double %163, double %156, double %161) #2
  %merged.select236.i = select i1 %92, i1 %147, i1 %158
  %165 = select i1 %merged.select236.i, double %spec.select203, double %spec.select202
  %merged.select239.i = select i1 %92, double %165, double %140
  %merged.select240.i = select i1 %92, double %164, double %159
  %166 = fmul double %merged.select239.i, %merged.select240.i
  %167 = fcmp oeq double %149, 0.000000e+00
  %168 = fcmp oeq double %149, 0x7FF0000000000000
  %169 = or i1 %167, %168
  %170 = select i1 %169, double %149, double %166
  %merged.select242.i = select i1 %92, double %170, double %162
  %171 = fmul double %spec.select201, %merged.select242.i
  %merged.select243.i = select i1 %92, double 1.000000e+00, double %165
  %172 = fdiv double %merged.select243.i, %152
  br i1 %92, label %merged.bb231.i.thread152, label %merged.bb231.i

merged.bb231.i.thread152:                         ; preds = %predication.tail250.i
  %173 = fmul double %171, %171
  %174 = fadd double %173, 0.000000e+00
  %175 = fmul double %174, 5.000000e-01
  %176 = fadd double %172, %175
  br label %g_2_2.exit.i

predication.split273.i:                           ; preds = %merged.bb227.i, %if.end9.i.i.i
  %177 = or i32 %mul.i97.i.i.i, 8191
  %178 = zext i32 %177 to i64
  %179 = select i1 %cmp10.i.i.i, i64 %178, i64 %59
  %180 = getelementptr inbounds double, double addrspace(1)* %66, i64 %179
  %181 = getelementptr inbounds double, double* %68, i64 %179
  %182 = getelementptr inbounds double, double* %70, i64 %179
  %183 = getelementptr inbounds double, double* %72, i64 %179
  %184 = load double, double addrspace(1)* %180, align 8, !tbaa !11
  %185 = load double, double* %181, align 8, !tbaa !11
  %186 = load double, double* %182, align 8, !tbaa !11
  %187 = load double, double* %183, align 8, !tbaa !11
  br label %g_2_2.exit.i

merged.bb231.i:                                   ; preds = %predication.tail250.i
  %188 = fadd double %143, %172
  br label %g_2_2.exit.i

merged.bb294.i:                                   ; preds = %merged.bb158.i
  %189 = add nsw i32 %56, %sub
  %190 = sext i32 %189 to i64
  %191 = getelementptr inbounds i8, i8 addrspace(1)* %mask.coerce, i64 %190
  %192 = load i8, i8 addrspace(1)* %191, align 1, !tbaa !8
  %193 = icmp eq i8 %192, 0
  %194 = add nsw i32 %rem.decomposed, %mul.i279
  %195 = sext i32 %194 to i64
  %merged.select296.i = select i1 %193, i64 %190, i64 %195
  %196 = getelementptr inbounds double, double addrspace(1)* %0, i64 %merged.select296.i
  %197 = load double, double addrspace(1)* %196, align 8, !tbaa !11
  %198 = getelementptr inbounds double, double addrspace(1)* %2, i64 %merged.select296.i
  %199 = load double, double addrspace(1)* %198, align 8, !tbaa !11
  %200 = getelementptr inbounds double, double addrspace(1)* %4, i64 %merged.select296.i
  %201 = load double, double addrspace(1)* %200, align 8, !tbaa !11
  %202 = getelementptr inbounds double, double addrspace(1)* %6, i64 %merged.select296.i
  %203 = load double, double addrspace(1)* %202, align 8, !tbaa !11
  br i1 %193, label %face_decide.exit, label %merged.bb295.i.thread159

merged.bb295.i.thread159:                         ; preds = %merged.bb294.i
  %204 = fcmp ogt double %197, 1.000000e-25
  %205 = select i1 %204, double %197, double 1.000000e-25
  %206 = fdiv double 1.000000e+00, %205
  %207 = fmul double %199, %206
  %208 = fmul double %201, %206
  %209 = fmul double %205, 5.000000e-01
  %210 = fmul double %207, %207
  %211 = fmul double %208, %208
  %212 = fadd double %210, %211
  %213 = fmul double %209, %212
  br label %merged.branch.split301.i

merged.branch.split301.i:                         ; preds = %merged.bb295.i.thread159, %if.then11.i
  %spec.select194 = phi double [ 1.000000e-25, %merged.bb295.i.thread159 ], [ 1.000000e+00, %if.then11.i ]
  %214 = phi double [ %205, %merged.bb295.i.thread159 ], [ undef, %if.then11.i ]
  %215 = phi double [ %207, %merged.bb295.i.thread159 ], [ undef, %if.then11.i ]
  %216 = phi double [ %208, %merged.bb295.i.thread159 ], [ undef, %if.then11.i ]
  %217 = phi double [ %213, %merged.bb295.i.thread159 ], [ undef, %if.then11.i ]
  %218 = phi double [ %203, %merged.bb295.i.thread159 ], [ undef, %if.then11.i ]
  %219 = load double, double addrspace(4)* getelementptr inbounds (%struct.SimConfig, %struct.SimConfig addrspace(4)* @d_cfg, i64 0, i32 5), align 8
  %220 = fsub double %218, %217
  %221 = load double, double addrspace(4)* getelementptr inbounds (%struct.SimConfig, %struct.SimConfig addrspace(4)* @d_cfg, i64 0, i32 0), align 8, !tbaa !13
  %222 = fcmp olt double %221, 0x1000000000000000
  %223 = select i1 %222, double 0x4FF0000000000000, double 1.000000e+00
  %224 = fmul double %221, %223
  %225 = tail call double @llvm.amdgcn.rsq.f64(double %224) #2
  %226 = fmul double %224, %225
  %merged.select96.i = select i1 %cmp6.i.i36.i, double 5.000000e-01, double %220
  %227 = fadd double %221, -1.000000e+00
  %merged.select95.i = select i1 %cmp6.i.i36.i, double %225, double %227
  %228 = fmul double %merged.select96.i, %merged.select95.i
  %229 = fneg double %228
  %230 = tail call double @llvm.fma.f64(double %229, double %226, double 5.000000e-01) #2
  %231 = tail call double @llvm.fma.f64(double %228, double %230, double %228) #2
  %232 = tail call double @llvm.fma.f64(double %226, double %230, double %226) #2
  %spec.select193 = select i1 %cmp6.i.i36.i, double %219, double %214
  %spec.select195 = select i1 %cmp6.i.i36.i, double 0x37F0000000000000, double %228
  %spec.select196 = select i1 %cmp6.i.i36.i, double %232, double %215
  %233 = fcmp ogt double %228, 1.000000e-25
  %234 = fneg double %spec.select196
  %235 = tail call double @llvm.fma.f64(double %234, double %232, double %224) #2
  %236 = tail call double @llvm.fma.f64(double %235, double %231, double %232) #2
  %merged.select98.i = select i1 %cmp6.i.i36.i, double %236, double %216
  %237 = fneg double %merged.select98.i
  %238 = tail call double @llvm.fma.f64(double %237, double %236, double %224) #2
  %239 = tail call double @llvm.fma.f64(double %238, double %231, double %236) #2
  %merged.select99.i = select i1 %cmp6.i.i36.i, i1 %222, i1 %233
  %240 = select i1 %merged.select99.i, double %spec.select195, double %spec.select194
  %merged.select102.i = select i1 %cmp6.i.i36.i, double %240, double %214
  %merged.select103.i = select i1 %cmp6.i.i36.i, double %239, double %234
  %241 = fmul double %merged.select102.i, %merged.select103.i
  %242 = fcmp oeq double %224, 0.000000e+00
  %243 = fcmp oeq double %224, 0x7FF0000000000000
  %244 = or i1 %242, %243
  %245 = select i1 %244, double %224, double %241
  %merged.select105.i = select i1 %cmp6.i.i36.i, double %245, double %237
  %246 = fmul double %spec.select193, %merged.select105.i
  %merged.select106.i = select i1 %cmp6.i.i36.i, double 1.000000e+00, double %240
  %247 = fdiv double %merged.select106.i, %227
  %248 = fmul double %246, %246
  %249 = fadd double %248, 0.000000e+00
  %250 = fmul double %249, 5.000000e-01
  %merged.select109.i = select i1 %cmp6.i.i36.i, double %250, double %247
  %merged.select108.i = select i1 %cmp6.i.i36.i, double %247, double %217
  %251 = fadd double %merged.select108.i, %merged.select109.i
  br label %face_decide.exit

face_decide.exit:                                 ; preds = %merged.branch.split301.i, %merged.bb294.i, %merged.bb159.i.thread.thread
  %252 = phi double [ %251, %merged.branch.split301.i ], [ undef, %merged.bb159.i.thread.thread ], [ undef, %merged.bb294.i ]
  %253 = phi double [ %246, %merged.branch.split301.i ], [ undef, %merged.bb159.i.thread.thread ], [ undef, %merged.bb294.i ]
  %254 = phi double [ %214, %merged.branch.split301.i ], [ %112, %merged.bb159.i.thread.thread ], [ %197, %merged.bb294.i ]
  %255 = phi double [ %241, %merged.branch.split301.i ], [ %113, %merged.bb159.i.thread.thread ], [ %199, %merged.bb294.i ]
  %256 = phi double [ %246, %merged.branch.split301.i ], [ %115, %merged.bb159.i.thread.thread ], [ %201, %merged.bb294.i ]
  %257 = phi double [ %251, %merged.branch.split301.i ], [ %117, %merged.bb159.i.thread.thread ], [ %203, %merged.bb294.i ]
  %spec.select6.i = select i1 %cmp6.i.i36.i, double %252, double %257
  %spec.select7.i = select i1 %cmp6.i.i36.i, double 0.000000e+00, double %256
  %spec.select8.i = select i1 %cmp6.i.i36.i, double %253, double %255
  %spec.select9.i = select i1 %cmp6.i.i36.i, double 1.000000e+00, double %254
  %258 = add nsw i32 %rem.decomposed, %mul.i279
  %259 = sext i32 %258 to i64
  %260 = getelementptr inbounds double, double addrspace(1)* %8, i64 %259
  %261 = getelementptr inbounds double, double addrspace(1)* %10, i64 %259
  %262 = getelementptr inbounds double, double addrspace(1)* %12, i64 %259
  %263 = getelementptr inbounds double, double addrspace(1)* %14, i64 %259
  %264 = load double, double addrspace(1)* %260, align 8, !tbaa !11
  %265 = load double, double addrspace(1)* %261, align 8, !tbaa !11
  %266 = load double, double addrspace(1)* %262, align 8, !tbaa !11
  %267 = load double, double addrspace(1)* %263, align 8, !tbaa !11
  %268 = insertelement <8 x double> undef, double %spec.select9.i, i32 0
  %269 = insertelement <8 x double> %268, double %spec.select8.i, i32 1
  %270 = insertelement <8 x double> %269, double %spec.select7.i, i32 2
  %271 = insertelement <8 x double> %270, double %spec.select6.i, i32 3
  %272 = insertelement <8 x double> %271, double %264, i32 4
  br label %if.end109

if.end109:                                        ; preds = %face_decide.exit, %predication.split21.i, %g_2_2.exit.i
  %.sink210 = phi double [ %265, %face_decide.exit ], [ %96, %predication.split21.i ], [ %retval.sroa.5.1.i.i.i, %g_2_2.exit.i ]
  %.sink = phi <8 x double> [ %272, %face_decide.exit ], [ %106, %predication.split21.i ], [ %65, %g_2_2.exit.i ]
  %.sink209 = phi double [ %266, %face_decide.exit ], [ %98, %predication.split21.i ], [ %retval.sroa.10.1.i.i.i, %g_2_2.exit.i ]
  %.sink207 = phi double [ %267, %face_decide.exit ], [ %100, %predication.split21.i ], [ %retval.sroa.15.1.i.i.i, %g_2_2.exit.i ]
  %273 = insertelement <8 x double> %.sink, double %.sink210, i32 5
  %274 = insertelement <8 x double> %273, double %.sink207, i32 7
  %275 = extractelement <8 x double> %.sink, i32 4
  %276 = extractelement <8 x double> %.sink, i32 3
  %277 = extractelement <8 x double> %.sink, i32 2
  %278 = extractelement <8 x double> %.sink, i32 1
  %279 = extractelement <8 x double> %.sink, i32 0
  %280 = shufflevector <8 x double> %274, <8 x double> undef, <2 x i32> <i32 0, i32 4>
  %281 = fcmp ogt <2 x double> %280, <double 1.000000e-25, double 1.000000e-25>
  %282 = select <2 x i1> %281, <2 x double> %280, <2 x double> <double 1.000000e-25, double 1.000000e-25>
  %283 = fdiv <2 x double> <double 1.000000e+00, double 1.000000e+00>, %282
  %284 = extractelement <2 x double> %283, i32 0
  %mul3.i.i.i = fmul double %277, %284
  %285 = extractelement <2 x double> %282, i32 0
  %mul4.i.i.i = fmul double %285, 5.000000e-01
  %286 = shufflevector <8 x double> %274, <8 x double> undef, <2 x i32> <i32 1, i32 5>
  %287 = fmul <2 x double> %286, %283
  %288 = extractelement <2 x double> %287, i32 0
  %mul5.i.i.i = fmul double %288, %288
  %mul6.i.i.i = fmul double %mul3.i.i.i, %mul3.i.i.i
  %add.i.i.i = fadd double %mul5.i.i.i, %mul6.i.i.i
  %289 = load double, double addrspace(4)* getelementptr inbounds (%struct.SimConfig, %struct.SimConfig addrspace(4)* @d_cfg, i64 0, i32 0), align 8, !tbaa !13
  %sub8.i.i.i = fadd double %289, -1.000000e+00
  %290 = extractelement <2 x double> %283, i32 1
  %mul3.i1678.i.i = fmul double %.sink209, %290
  %291 = extractelement <2 x double> %282, i32 1
  %mul4.i1679.i.i = fmul double %291, 5.000000e-01
  %292 = extractelement <2 x double> %287, i32 1
  %mul5.i1680.i.i = fmul double %292, %292
  %mul6.i1681.i.i = fmul double %mul3.i1678.i.i, %mul3.i1678.i.i
  %add.i1682.i.i = fadd double %mul5.i1680.i.i, %mul6.i1681.i.i
  %293 = insertelement <2 x double> undef, double %mul4.i.i.i, i32 0
  %294 = insertelement <2 x double> %293, double %mul4.i1679.i.i, i32 1
  %295 = insertelement <2 x double> undef, double %add.i.i.i, i32 0
  %296 = insertelement <2 x double> %295, double %add.i1682.i.i, i32 1
  %297 = fmul <2 x double> %294, %296
  %298 = shufflevector <8 x double> %274, <8 x double> undef, <2 x i32> <i32 3, i32 7>
  %299 = fsub <2 x double> %298, %297
  %300 = insertelement <2 x double> undef, double %sub8.i.i.i, i32 0
  %301 = shufflevector <2 x double> %300, <2 x double> undef, <2 x i32> zeroinitializer
  %302 = fmul <2 x double> %301, %299
  %303 = fcmp ogt <2 x double> %302, <double 1.000000e-25, double 1.000000e-25>
  %304 = select <2 x i1> %303, <2 x double> %302, <2 x double> <double 1.000000e-25, double 1.000000e-25>
  %305 = insertelement <2 x double> undef, double %289, i32 0
  %306 = shufflevector <2 x double> %305, <2 x double> undef, <2 x i32> zeroinitializer
  %307 = fmul <2 x double> %306, %304
  %308 = fdiv <2 x double> %307, %282
  %309 = fcmp olt <2 x double> %308, <double 0x1000000000000000, double 0x1000000000000000>
  %310 = select <2 x i1> %309, <2 x double> <double 0x4FF0000000000000, double 0x4FF0000000000000>, <2 x double> <double 1.000000e+00, double 1.000000e+00>
  %311 = fmul <2 x double> %308, %310
  %312 = extractelement <2 x double> %311, i32 0
  %313 = tail call double @llvm.amdgcn.rsq.f64(double %312) #2
  %314 = fmul double %313, 5.000000e-01
  %315 = extractelement <2 x double> %311, i32 1
  %316 = tail call double @llvm.amdgcn.rsq.f64(double %315) #2
  %317 = insertelement <2 x double> undef, double %313, i32 0
  %318 = insertelement <2 x double> %317, double %316, i32 1
  %319 = fmul <2 x double> %311, %318
  %320 = fmul double %316, 5.000000e-01
  %321 = insertelement <2 x double> undef, double %314, i32 0
  %322 = insertelement <2 x double> %321, double %320, i32 1
  %323 = fneg <2 x double> %322
  %324 = tail call <2 x double> @llvm.fma.v2f64(<2 x double> %323, <2 x double> %319, <2 x double> <double 5.000000e-01, double 5.000000e-01>)
  %325 = tail call <2 x double> @llvm.fma.v2f64(<2 x double> %322, <2 x double> %324, <2 x double> %322)
  %326 = tail call <2 x double> @llvm.fma.v2f64(<2 x double> %319, <2 x double> %324, <2 x double> %319)
  %327 = fneg <2 x double> %326
  %328 = tail call <2 x double> @llvm.fma.v2f64(<2 x double> %327, <2 x double> %326, <2 x double> %311)
  %329 = tail call <2 x double> @llvm.fma.v2f64(<2 x double> %328, <2 x double> %325, <2 x double> %326)
  %330 = fneg <2 x double> %329
  %331 = tail call <2 x double> @llvm.fma.v2f64(<2 x double> %330, <2 x double> %329, <2 x double> %311)
  %332 = tail call <2 x double> @llvm.fma.v2f64(<2 x double> %331, <2 x double> %325, <2 x double> %329)
  %333 = select <2 x i1> %309, <2 x double> <double 0x37F0000000000000, double 0x37F0000000000000>, <2 x double> <double 1.000000e+00, double 1.000000e+00>
  %334 = fmul <2 x double> %333, %332
  %335 = fcmp oeq <2 x double> %311, <double 0x7FF0000000000000, double 0.000000e+00>
  %336 = fcmp oeq <2 x double> %311, <double 0.000000e+00, double 0x7FF0000000000000>
  %337 = or <2 x i1> %336, %335
  %338 = select <2 x i1> %337, <2 x double> %311, <2 x double> %334
  %339 = fsub <2 x double> %287, %338
  %340 = extractelement <2 x double> %339, i32 0
  %341 = extractelement <2 x double> %339, i32 1
  %cmp.i1660.i.i = fcmp olt double %340, %341
  %cond.i1661.i.i = select i1 %cmp.i1660.i.i, double %340, double %341
  %342 = extractelement <2 x double> %338, i32 0
  %add.i.i = fadd double %288, %342
  %343 = extractelement <2 x double> %338, i32 1
  %add15.i.i = fadd double %292, %343
  %cmp.i1658.i.i = fcmp ogt double %add.i.i, %add15.i.i
  %cond.i1659.i.i = select i1 %cmp.i1658.i.i, double %add.i.i, double %add15.i.i
  %mul.i1649.i.i = fmul double %278, %288
  %344 = extractelement <2 x double> %304, i32 0
  %add.i1650.i.i = fadd double %mul.i1649.i.i, %344
  %mul6.i1651.i.i = fmul double %277, %288
  %add9.i1652.i.i = fadd double %276, %344
  %mul10.i1653.i.i = fmul double %288, %add9.i1652.i.i
  %mul.i1621.i.i = fmul double %.sink210, %292
  %345 = extractelement <2 x double> %304, i32 1
  %add.i1622.i.i = fadd double %mul.i1621.i.i, %345
  %mul6.i1623.i.i = fmul double %.sink209, %292
  %add9.i.i.i = fadd double %.sink207, %345
  %mul10.i.i.i = fmul double %292, %add9.i.i.i
  %cmp.i.i = fcmp ult double %cond.i1661.i.i, 0.000000e+00
  br i1 %cmp.i.i, label %if.end.i.i, label %predication.split25

if.end.i.i:                                       ; preds = %if.end109
  %cmp21.i.i = fcmp ugt double %cond.i1659.i.i, 0.000000e+00
  br i1 %cmp21.i.i, label %if.end23.i.i, label %predication.split25

if.end23.i.i:                                     ; preds = %if.end.i.i
  %sub26.i.i = fsub double %345, %344
  %mul.i.i = fmul double %285, %288
  %sub27.i.i = fsub double %cond.i1661.i.i, %288
  %mul28.i.i = fmul double %mul.i.i, %sub27.i.i
  %add29.i.i = fadd double %sub26.i.i, %mul28.i.i
  %mul30.i.i = fmul double %291, %292
  %sub31.i.i = fsub double %cond.i1659.i.i, %292
  %mul32.i.i = fmul double %mul30.i.i, %sub31.i.i
  %sub33.i.i = fsub double %add29.i.i, %mul32.i.i
  %mul35.i.i = fmul double %285, %sub27.i.i
  %mul37.i.i = fmul double %291, %sub31.i.i
  %sub38.i.i = fsub double %mul35.i.i, %mul37.i.i
  %cmp.i1598.i.i = fcmp olt double %sub38.i.i, 0.000000e+00
  %fneg.i1599.i.i = fneg double %sub38.i.i
  %cond.i1600.i.i = select i1 %cmp.i1598.i.i, double %fneg.i1599.i.i, double %sub38.i.i
  %cmp40.i.i = fcmp olt double %cond.i1600.i.i, 0x3D06849B86A12B9B
  br i1 %cmp40.i.i, label %if.end21.i1511.i.i, label %lor.lhs.false.i.i

lor.lhs.false.i.i:                                ; preds = %if.end23.i.i
  %346 = tail call i1 @llvm.amdgcn.class.f64(double %sub33.i.i, i32 504) #2
  br i1 %346, label %lor.lhs.false42.i.i, label %if.end21.i1511.i.i

lor.lhs.false42.i.i:                              ; preds = %lor.lhs.false.i.i
  %347 = tail call i1 @llvm.amdgcn.class.f64(double %sub38.i.i, i32 504) #2
  br i1 %347, label %if.end48.i.i, label %if.end21.i1511.i.i

if.end21.i1511.i.i:                               ; preds = %lor.lhs.false42.i.i, %lor.lhs.false.i.i, %if.end23.i.i
  %sub22.i1506.i.i = fsub double %cond.i1659.i.i, %cond.i1661.i.i
  %cmp.i.i1507.i.i = fcmp olt double %sub22.i1506.i.i, 0.000000e+00
  %fneg.i.i1508.i.i = fneg double %sub22.i1506.i.i
  %cond.i.i1509.i.i = select i1 %cmp.i.i1507.i.i, double %fneg.i.i1508.i.i, double %sub22.i1506.i.i
  %cmp24.i1510.i.i = fcmp olt double %cond.i.i1509.i.i, 0x3D06849B86A12B9B
  br i1 %cmp24.i1510.i.i, label %predication.tail, label %predication.split

if.end48.i.i:                                     ; preds = %lor.lhs.false42.i.i
  %div.i.i = fdiv double %sub33.i.i, %sub38.i.i
  %348 = tail call i1 @llvm.amdgcn.class.f64(double %div.i.i, i32 504) #2
  br i1 %348, label %if.end54.i.i, label %if.end21.i1278.i.i

if.end21.i1278.i.i:                               ; preds = %if.end48.i.i
  %sub22.i1273.i.i = fsub double %cond.i1659.i.i, %cond.i1661.i.i
  %cmp.i.i1274.i.i = fcmp olt double %sub22.i1273.i.i, 0.000000e+00
  %fneg.i.i1275.i.i = fneg double %sub22.i1273.i.i
  %cond.i.i1276.i.i = select i1 %cmp.i.i1274.i.i, double %fneg.i.i1275.i.i, double %sub22.i1273.i.i
  %cmp24.i1277.i.i = fcmp olt double %cond.i.i1276.i.i, 0x3D06849B86A12B9B
  br i1 %cmp24.i1277.i.i, label %predication.tail66, label %predication.split65

if.end54.i.i:                                     ; preds = %if.end48.i.i
  %sub57.i.i = fsub double %div.i.i, %288
  %mul58.i.i = fmul double %mul35.i.i, %sub57.i.i
  %add59.i.i = fadd double %344, %mul58.i.i
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
  %349 = tail call i1 @llvm.amdgcn.class.f64(double %div75.i.i, i32 504) #2
  br i1 %349, label %lor.lhs.false84.i.i, label %if.end21.i805.i.i

lor.lhs.false84.i.i:                              ; preds = %lor.lhs.false82.i.i
  %350 = tail call i1 @llvm.amdgcn.class.f64(double %div78.i.i, i32 504) #2
  br i1 %350, label %if.end90.i.i, label %if.end21.i805.i.i

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
  %mul94.i.i = fmul double %276, %sub27.i.i
  %mul95.i.i = fmul double %288, %344
  %sub96.i.i = fsub double %mul94.i.i, %mul95.i.i
  %mul97.i.i = fmul double %div.i.i, %cond.i1131.i.i
  %add98.i.i = fadd double %sub96.i.i, %mul97.i.i
  %div99.i.i = fdiv double %add98.i.i, %sub61.i.i
  %351 = tail call i1 @llvm.amdgcn.class.f64(double %div99.i.i, i32 504) #2
  br i1 %351, label %if.end105.i.i, label %if.end21.i572.i.i

if.end21.i572.i.i:                                ; preds = %if.end90.i.i
  %sub22.i567.i.i = fsub double %cond.i1659.i.i, %cond.i1661.i.i
  %cmp.i.i568.i.i = fcmp olt double %sub22.i567.i.i, 0.000000e+00
  %fneg.i.i569.i.i = fneg double %sub22.i567.i.i
  %cond.i.i570.i.i = select i1 %cmp.i.i568.i.i, double %fneg.i.i569.i.i, double %sub22.i567.i.i
  %cmp24.i571.i.i = fcmp olt double %cond.i.i570.i.i, 0x3D06849B86A12B9B
  br i1 %cmp24.i571.i.i, label %predication.tail126, label %predication.split125

if.end105.i.i:                                    ; preds = %if.end90.i.i
  %mul116.i.i = fmul double %.sink207, %sub31.i.i
  %mul117.i.i = fmul double %292, %345
  %sub118.i.i = fsub double %mul116.i.i, %mul117.i.i
  %add120.i.i = fadd double %sub118.i.i, %mul97.i.i
  %div121.i.i = fdiv double %add120.i.i, %sub62.i.i
  %352 = tail call i1 @llvm.amdgcn.class.f64(double %div121.i.i, i32 504) #2
  %353 = fsub double %cond.i1659.i.i, %cond.i1661.i.i
  %354 = fcmp olt double %353, 0.000000e+00
  %355 = fneg double %353
  %356 = select i1 %354, double %355, double %353
  %357 = fcmp ult double %div.i.i, 0.000000e+00
  %358 = fcmp olt double %356, 0x3D06849B86A12B9B
  %359 = select i1 %352, i1 %357, i1 %358
  br i1 %359, label %merged.bb138, label %merged.bb137

cleanup128:                                       ; preds = %predication.split27, %predication.split25, %entry
  ret void

predication.split25:                              ; preds = %merged.bb139, %predication.tail126, %predication.tail106, %predication.tail86, %predication.tail66, %predication.tail, %if.end.i.i, %if.end109
  %moved.phi3.ph = phi double [ %spec.select, %merged.bb139 ], [ %528, %predication.tail126 ], [ %497, %predication.tail106 ], [ %466, %predication.tail86 ], [ %435, %predication.tail66 ], [ %404, %predication.tail ], [ %mul10.i.i.i, %if.end.i.i ], [ %mul10.i1653.i.i, %if.end109 ]
  %moved.phi2.ph = phi double [ %spec.select1, %merged.bb139 ], [ %527, %predication.tail126 ], [ %496, %predication.tail106 ], [ %465, %predication.tail86 ], [ %434, %predication.tail66 ], [ %403, %predication.tail ], [ %mul6.i1623.i.i, %if.end.i.i ], [ %mul6.i1651.i.i, %if.end109 ]
  %moved.phi1.ph = phi double [ %spec.select2, %merged.bb139 ], [ %526, %predication.tail126 ], [ %495, %predication.tail106 ], [ %464, %predication.tail86 ], [ %433, %predication.tail66 ], [ %402, %predication.tail ], [ %add.i1622.i.i, %if.end.i.i ], [ %add.i1650.i.i, %if.end109 ]
  %moved.phi.ph = phi double [ %spec.select3, %merged.bb139 ], [ %525, %predication.tail126 ], [ %494, %predication.tail106 ], [ %463, %predication.tail86 ], [ %432, %predication.tail66 ], [ %401, %predication.tail ], [ %.sink210, %if.end.i.i ], [ %278, %if.end109 ]
  %360 = sext i32 %add to i64
  %361 = getelementptr inbounds double, double addrspace(1)* %24, i64 %360
  store double %moved.phi.ph, double addrspace(1)* %361, align 8, !tbaa !11
  %362 = getelementptr inbounds double, double addrspace(1)* %25, i64 %360
  store double %moved.phi1.ph, double addrspace(1)* %362, align 8, !tbaa !11
  %363 = getelementptr inbounds double, double addrspace(1)* %26, i64 %360
  store double %moved.phi2.ph, double addrspace(1)* %363, align 8, !tbaa !11
  %364 = getelementptr inbounds double, double addrspace(1)* %27, i64 %360
  store double %moved.phi3.ph, double addrspace(1)* %364, align 8, !tbaa !11
  br label %cleanup128

predication.split27:                              ; preds = %land.lhs.true8.i
  %365 = sext i32 %add to i64
  %366 = getelementptr inbounds double, double addrspace(1)* %24, i64 %365
  %367 = bitcast double addrspace(1)* %366 to i64 addrspace(1)*
  store i64 0, i64 addrspace(1)* %367, align 8, !tbaa !11
  %368 = getelementptr inbounds double, double addrspace(1)* %25, i64 %365
  %369 = bitcast double addrspace(1)* %368 to i64 addrspace(1)*
  store i64 0, i64 addrspace(1)* %369, align 8, !tbaa !11
  %370 = getelementptr inbounds double, double addrspace(1)* %26, i64 %365
  %371 = bitcast double addrspace(1)* %370 to i64 addrspace(1)*
  store i64 0, i64 addrspace(1)* %371, align 8, !tbaa !11
  %372 = getelementptr inbounds double, double addrspace(1)* %27, i64 %365
  %373 = bitcast double addrspace(1)* %372 to i64 addrspace(1)*
  store i64 0, i64 addrspace(1)* %373, align 8, !tbaa !11
  br label %cleanup128

predication.split:                                ; preds = %if.end21.i1511.i.i
  %374 = fmul double %278, %cond.i1659.i.i
  %375 = fmul double %add.i1650.i.i, %cond.i1659.i.i
  %376 = fmul double %mul6.i1651.i.i, %cond.i1659.i.i
  %377 = fmul double %mul10.i1653.i.i, %cond.i1659.i.i
  %378 = fmul double %cond.i1661.i.i, %cond.i1659.i.i
  %379 = fsub double %275, %279
  %380 = fsub double %.sink210, %278
  %381 = fsub double %.sink209, %277
  %382 = fsub double %.sink207, %276
  %383 = fmul double %379, %378
  %384 = fmul double %380, %378
  %385 = fmul double %381, %378
  %386 = fmul double %382, %378
  %387 = fdiv double 1.000000e+00, %sub22.i1506.i.i
  %388 = fmul double %.sink210, %cond.i1661.i.i
  %389 = fsub double %374, %388
  %390 = fmul double %add.i1622.i.i, %cond.i1661.i.i
  %391 = fsub double %375, %390
  %392 = fmul double %mul6.i1623.i.i, %cond.i1661.i.i
  %393 = fsub double %376, %392
  %394 = fmul double %mul10.i.i.i, %cond.i1661.i.i
  %395 = fsub double %377, %394
  br label %predication.tail

predication.tail:                                 ; preds = %predication.split, %if.end21.i1511.i.i
  %merged.select37 = phi double [ %386, %predication.split ], [ %mul10.i1653.i.i, %if.end21.i1511.i.i ]
  %merged.select36 = phi double [ %395, %predication.split ], [ %mul10.i.i.i, %if.end21.i1511.i.i ]
  %merged.select35 = phi double [ %385, %predication.split ], [ %mul6.i1651.i.i, %if.end21.i1511.i.i ]
  %merged.select34 = phi double [ %393, %predication.split ], [ %mul6.i1623.i.i, %if.end21.i1511.i.i ]
  %merged.select33 = phi double [ %384, %predication.split ], [ %add.i1650.i.i, %if.end21.i1511.i.i ]
  %merged.select32 = phi double [ %391, %predication.split ], [ %add.i1622.i.i, %if.end21.i1511.i.i ]
  %merged.select31 = phi double [ %383, %predication.split ], [ %278, %if.end21.i1511.i.i ]
  %merged.select30 = phi double [ %389, %predication.split ], [ %.sink210, %if.end21.i1511.i.i ]
  %396 = phi double [ %387, %predication.split ], [ undef, %if.end21.i1511.i.i ]
  %397 = fadd double %merged.select31, %merged.select30
  %398 = fadd double %merged.select33, %merged.select32
  %399 = fadd double %merged.select35, %merged.select34
  %400 = fadd double %merged.select37, %merged.select36
  %merged.select38 = select i1 %cmp24.i1510.i.i, double %397, double %396
  %merged.select39 = select i1 %cmp24.i1510.i.i, double 5.000000e-01, double %397
  %401 = fmul double %merged.select38, %merged.select39
  %merged.select40 = select i1 %cmp24.i1510.i.i, double %398, double %396
  %merged.select41 = select i1 %cmp24.i1510.i.i, double 5.000000e-01, double %398
  %402 = fmul double %merged.select41, %merged.select40
  %merged.select42 = select i1 %cmp24.i1510.i.i, double %399, double %396
  %merged.select43 = select i1 %cmp24.i1510.i.i, double 5.000000e-01, double %399
  %403 = fmul double %merged.select43, %merged.select42
  %merged.select44 = select i1 %cmp24.i1510.i.i, double %400, double %396
  %merged.select45 = select i1 %cmp24.i1510.i.i, double 5.000000e-01, double %400
  %404 = fmul double %merged.select45, %merged.select44
  br label %predication.split25

predication.split65:                              ; preds = %if.end21.i1278.i.i
  %405 = fmul double %278, %cond.i1659.i.i
  %406 = fmul double %add.i1650.i.i, %cond.i1659.i.i
  %407 = fmul double %mul6.i1651.i.i, %cond.i1659.i.i
  %408 = fmul double %mul10.i1653.i.i, %cond.i1659.i.i
  %409 = fmul double %cond.i1661.i.i, %cond.i1659.i.i
  %410 = fsub double %275, %279
  %411 = fsub double %.sink210, %278
  %412 = fsub double %.sink209, %277
  %413 = fsub double %.sink207, %276
  %414 = fmul double %410, %409
  %415 = fmul double %411, %409
  %416 = fmul double %412, %409
  %417 = fmul double %413, %409
  %418 = fdiv double 1.000000e+00, %sub22.i1273.i.i
  %419 = fmul double %.sink210, %cond.i1661.i.i
  %420 = fsub double %405, %419
  %421 = fmul double %add.i1622.i.i, %cond.i1661.i.i
  %422 = fsub double %406, %421
  %423 = fmul double %mul6.i1623.i.i, %cond.i1661.i.i
  %424 = fsub double %407, %423
  %425 = fmul double %mul10.i.i.i, %cond.i1661.i.i
  %426 = fsub double %408, %425
  br label %predication.tail66

predication.tail66:                               ; preds = %predication.split65, %if.end21.i1278.i.i
  %merged.select55 = phi double [ %417, %predication.split65 ], [ %mul10.i1653.i.i, %if.end21.i1278.i.i ]
  %merged.select54 = phi double [ %426, %predication.split65 ], [ %mul10.i.i.i, %if.end21.i1278.i.i ]
  %merged.select53 = phi double [ %416, %predication.split65 ], [ %mul6.i1651.i.i, %if.end21.i1278.i.i ]
  %merged.select52 = phi double [ %424, %predication.split65 ], [ %mul6.i1623.i.i, %if.end21.i1278.i.i ]
  %merged.select51 = phi double [ %415, %predication.split65 ], [ %add.i1650.i.i, %if.end21.i1278.i.i ]
  %merged.select50 = phi double [ %422, %predication.split65 ], [ %add.i1622.i.i, %if.end21.i1278.i.i ]
  %merged.select49 = phi double [ %414, %predication.split65 ], [ %278, %if.end21.i1278.i.i ]
  %merged.select48 = phi double [ %420, %predication.split65 ], [ %.sink210, %if.end21.i1278.i.i ]
  %427 = phi double [ %418, %predication.split65 ], [ undef, %if.end21.i1278.i.i ]
  %428 = fadd double %merged.select49, %merged.select48
  %429 = fadd double %merged.select51, %merged.select50
  %430 = fadd double %merged.select53, %merged.select52
  %431 = fadd double %merged.select55, %merged.select54
  %merged.select56 = select i1 %cmp24.i1277.i.i, double %428, double %427
  %merged.select57 = select i1 %cmp24.i1277.i.i, double 5.000000e-01, double %428
  %432 = fmul double %merged.select56, %merged.select57
  %merged.select58 = select i1 %cmp24.i1277.i.i, double %429, double %427
  %merged.select59 = select i1 %cmp24.i1277.i.i, double 5.000000e-01, double %429
  %433 = fmul double %merged.select59, %merged.select58
  %merged.select60 = select i1 %cmp24.i1277.i.i, double %430, double %427
  %merged.select61 = select i1 %cmp24.i1277.i.i, double 5.000000e-01, double %430
  %434 = fmul double %merged.select61, %merged.select60
  %merged.select62 = select i1 %cmp24.i1277.i.i, double %431, double %427
  %merged.select63 = select i1 %cmp24.i1277.i.i, double 5.000000e-01, double %431
  %435 = fmul double %merged.select63, %merged.select62
  br label %predication.split25

predication.split85:                              ; preds = %if.end21.i1038.i.i
  %436 = fmul double %278, %cond.i1659.i.i
  %437 = fmul double %add.i1650.i.i, %cond.i1659.i.i
  %438 = fmul double %mul6.i1651.i.i, %cond.i1659.i.i
  %439 = fmul double %mul10.i1653.i.i, %cond.i1659.i.i
  %440 = fmul double %cond.i1661.i.i, %cond.i1659.i.i
  %441 = fsub double %275, %279
  %442 = fsub double %.sink210, %278
  %443 = fsub double %.sink209, %277
  %444 = fsub double %.sink207, %276
  %445 = fmul double %441, %440
  %446 = fmul double %442, %440
  %447 = fmul double %443, %440
  %448 = fmul double %444, %440
  %449 = fdiv double 1.000000e+00, %sub22.i1033.i.i
  %450 = fmul double %.sink210, %cond.i1661.i.i
  %451 = fsub double %436, %450
  %452 = fmul double %add.i1622.i.i, %cond.i1661.i.i
  %453 = fsub double %437, %452
  %454 = fmul double %mul6.i1623.i.i, %cond.i1661.i.i
  %455 = fsub double %438, %454
  %456 = fmul double %mul10.i.i.i, %cond.i1661.i.i
  %457 = fsub double %439, %456
  br label %predication.tail86

predication.tail86:                               ; preds = %predication.split85, %if.end21.i1038.i.i
  %merged.select75 = phi double [ %448, %predication.split85 ], [ %mul10.i1653.i.i, %if.end21.i1038.i.i ]
  %merged.select74 = phi double [ %457, %predication.split85 ], [ %mul10.i.i.i, %if.end21.i1038.i.i ]
  %merged.select73 = phi double [ %447, %predication.split85 ], [ %mul6.i1651.i.i, %if.end21.i1038.i.i ]
  %merged.select72 = phi double [ %455, %predication.split85 ], [ %mul6.i1623.i.i, %if.end21.i1038.i.i ]
  %merged.select71 = phi double [ %446, %predication.split85 ], [ %add.i1650.i.i, %if.end21.i1038.i.i ]
  %merged.select70 = phi double [ %453, %predication.split85 ], [ %add.i1622.i.i, %if.end21.i1038.i.i ]
  %merged.select69 = phi double [ %445, %predication.split85 ], [ %278, %if.end21.i1038.i.i ]
  %merged.select68 = phi double [ %451, %predication.split85 ], [ %.sink210, %if.end21.i1038.i.i ]
  %458 = phi double [ %449, %predication.split85 ], [ undef, %if.end21.i1038.i.i ]
  %459 = fadd double %merged.select69, %merged.select68
  %460 = fadd double %merged.select71, %merged.select70
  %461 = fadd double %merged.select73, %merged.select72
  %462 = fadd double %merged.select75, %merged.select74
  %merged.select76 = select i1 %cmp24.i1037.i.i, double %459, double %458
  %merged.select77 = select i1 %cmp24.i1037.i.i, double 5.000000e-01, double %459
  %463 = fmul double %merged.select76, %merged.select77
  %merged.select78 = select i1 %cmp24.i1037.i.i, double %460, double %458
  %merged.select79 = select i1 %cmp24.i1037.i.i, double 5.000000e-01, double %460
  %464 = fmul double %merged.select79, %merged.select78
  %merged.select80 = select i1 %cmp24.i1037.i.i, double %461, double %458
  %merged.select81 = select i1 %cmp24.i1037.i.i, double 5.000000e-01, double %461
  %465 = fmul double %merged.select81, %merged.select80
  %merged.select82 = select i1 %cmp24.i1037.i.i, double %462, double %458
  %merged.select83 = select i1 %cmp24.i1037.i.i, double 5.000000e-01, double %462
  %466 = fmul double %merged.select83, %merged.select82
  br label %predication.split25

predication.split105:                             ; preds = %if.end21.i805.i.i
  %467 = fmul double %278, %cond.i1659.i.i
  %468 = fmul double %add.i1650.i.i, %cond.i1659.i.i
  %469 = fmul double %mul6.i1651.i.i, %cond.i1659.i.i
  %470 = fmul double %mul10.i1653.i.i, %cond.i1659.i.i
  %471 = fmul double %cond.i1661.i.i, %cond.i1659.i.i
  %472 = fsub double %275, %279
  %473 = fsub double %.sink210, %278
  %474 = fsub double %.sink209, %277
  %475 = fsub double %.sink207, %276
  %476 = fmul double %472, %471
  %477 = fmul double %473, %471
  %478 = fmul double %474, %471
  %479 = fmul double %475, %471
  %480 = fdiv double 1.000000e+00, %sub22.i800.i.i
  %481 = fmul double %.sink210, %cond.i1661.i.i
  %482 = fsub double %467, %481
  %483 = fmul double %add.i1622.i.i, %cond.i1661.i.i
  %484 = fsub double %468, %483
  %485 = fmul double %mul6.i1623.i.i, %cond.i1661.i.i
  %486 = fsub double %469, %485
  %487 = fmul double %mul10.i.i.i, %cond.i1661.i.i
  %488 = fsub double %470, %487
  br label %predication.tail106

predication.tail106:                              ; preds = %predication.split105, %if.end21.i805.i.i
  %merged.select95 = phi double [ %479, %predication.split105 ], [ %mul10.i1653.i.i, %if.end21.i805.i.i ]
  %merged.select94 = phi double [ %488, %predication.split105 ], [ %mul10.i.i.i, %if.end21.i805.i.i ]
  %merged.select93 = phi double [ %478, %predication.split105 ], [ %mul6.i1651.i.i, %if.end21.i805.i.i ]
  %merged.select92 = phi double [ %486, %predication.split105 ], [ %mul6.i1623.i.i, %if.end21.i805.i.i ]
  %merged.select91 = phi double [ %477, %predication.split105 ], [ %add.i1650.i.i, %if.end21.i805.i.i ]
  %merged.select90 = phi double [ %484, %predication.split105 ], [ %add.i1622.i.i, %if.end21.i805.i.i ]
  %merged.select89 = phi double [ %476, %predication.split105 ], [ %278, %if.end21.i805.i.i ]
  %merged.select88 = phi double [ %482, %predication.split105 ], [ %.sink210, %if.end21.i805.i.i ]
  %489 = phi double [ %480, %predication.split105 ], [ undef, %if.end21.i805.i.i ]
  %490 = fadd double %merged.select89, %merged.select88
  %491 = fadd double %merged.select91, %merged.select90
  %492 = fadd double %merged.select93, %merged.select92
  %493 = fadd double %merged.select95, %merged.select94
  %merged.select96 = select i1 %cmp24.i804.i.i, double %490, double %489
  %merged.select97 = select i1 %cmp24.i804.i.i, double 5.000000e-01, double %490
  %494 = fmul double %merged.select96, %merged.select97
  %merged.select98 = select i1 %cmp24.i804.i.i, double %491, double %489
  %merged.select99 = select i1 %cmp24.i804.i.i, double 5.000000e-01, double %491
  %495 = fmul double %merged.select99, %merged.select98
  %merged.select100 = select i1 %cmp24.i804.i.i, double %492, double %489
  %merged.select101 = select i1 %cmp24.i804.i.i, double 5.000000e-01, double %492
  %496 = fmul double %merged.select101, %merged.select100
  %merged.select102 = select i1 %cmp24.i804.i.i, double %493, double %489
  %merged.select103 = select i1 %cmp24.i804.i.i, double 5.000000e-01, double %493
  %497 = fmul double %merged.select103, %merged.select102
  br label %predication.split25

predication.split125:                             ; preds = %if.end21.i572.i.i
  %498 = fmul double %278, %cond.i1659.i.i
  %499 = fmul double %add.i1650.i.i, %cond.i1659.i.i
  %500 = fmul double %mul6.i1651.i.i, %cond.i1659.i.i
  %501 = fmul double %mul10.i1653.i.i, %cond.i1659.i.i
  %502 = fmul double %cond.i1661.i.i, %cond.i1659.i.i
  %503 = fsub double %275, %279
  %504 = fsub double %.sink210, %278
  %505 = fsub double %.sink209, %277
  %506 = fsub double %.sink207, %276
  %507 = fmul double %503, %502
  %508 = fmul double %504, %502
  %509 = fmul double %505, %502
  %510 = fmul double %506, %502
  %511 = fdiv double 1.000000e+00, %sub22.i567.i.i
  %512 = fmul double %.sink210, %cond.i1661.i.i
  %513 = fsub double %498, %512
  %514 = fmul double %add.i1622.i.i, %cond.i1661.i.i
  %515 = fsub double %499, %514
  %516 = fmul double %mul6.i1623.i.i, %cond.i1661.i.i
  %517 = fsub double %500, %516
  %518 = fmul double %mul10.i.i.i, %cond.i1661.i.i
  %519 = fsub double %501, %518
  br label %predication.tail126

predication.tail126:                              ; preds = %predication.split125, %if.end21.i572.i.i
  %merged.select115 = phi double [ %510, %predication.split125 ], [ %mul10.i1653.i.i, %if.end21.i572.i.i ]
  %merged.select114 = phi double [ %519, %predication.split125 ], [ %mul10.i.i.i, %if.end21.i572.i.i ]
  %merged.select113 = phi double [ %509, %predication.split125 ], [ %mul6.i1651.i.i, %if.end21.i572.i.i ]
  %merged.select112 = phi double [ %517, %predication.split125 ], [ %mul6.i1623.i.i, %if.end21.i572.i.i ]
  %merged.select111 = phi double [ %508, %predication.split125 ], [ %add.i1650.i.i, %if.end21.i572.i.i ]
  %merged.select110 = phi double [ %515, %predication.split125 ], [ %add.i1622.i.i, %if.end21.i572.i.i ]
  %merged.select109 = phi double [ %507, %predication.split125 ], [ %278, %if.end21.i572.i.i ]
  %merged.select108 = phi double [ %513, %predication.split125 ], [ %.sink210, %if.end21.i572.i.i ]
  %520 = phi double [ %511, %predication.split125 ], [ undef, %if.end21.i572.i.i ]
  %521 = fadd double %merged.select109, %merged.select108
  %522 = fadd double %merged.select111, %merged.select110
  %523 = fadd double %merged.select113, %merged.select112
  %524 = fadd double %merged.select115, %merged.select114
  %merged.select116 = select i1 %cmp24.i571.i.i, double %521, double %520
  %merged.select117 = select i1 %cmp24.i571.i.i, double 5.000000e-01, double %521
  %525 = fmul double %merged.select116, %merged.select117
  %merged.select118 = select i1 %cmp24.i571.i.i, double %522, double %520
  %merged.select119 = select i1 %cmp24.i571.i.i, double 5.000000e-01, double %522
  %526 = fmul double %merged.select119, %merged.select118
  %merged.select120 = select i1 %cmp24.i571.i.i, double %523, double %520
  %merged.select121 = select i1 %cmp24.i571.i.i, double 5.000000e-01, double %523
  %527 = fmul double %merged.select121, %merged.select120
  %merged.select122 = select i1 %cmp24.i571.i.i, double %524, double %520
  %merged.select123 = select i1 %cmp24.i571.i.i, double 5.000000e-01, double %524
  %528 = fmul double %merged.select123, %merged.select122
  br label %predication.split25

merged.bb137:                                     ; preds = %if.end105.i.i
  br i1 %352, label %predication.tail174.thread, label %predication.split175

predication.tail174.thread:                       ; preds = %merged.bb137
  %529 = fsub double %div75.i.i, %279
  br label %predication.tail176

predication.split175:                             ; preds = %merged.bb137
  %530 = fmul double %278, %cond.i1659.i.i
  %531 = fmul double %add.i1650.i.i, %cond.i1659.i.i
  %532 = fmul double %mul6.i1651.i.i, %cond.i1659.i.i
  %533 = fmul double %mul10.i1653.i.i, %cond.i1659.i.i
  %534 = fmul double %cond.i1661.i.i, %cond.i1659.i.i
  %535 = fsub double %275, %279
  %536 = fsub double %.sink210, %278
  %537 = fsub double %.sink209, %277
  %538 = fsub double %.sink207, %276
  %539 = fmul double %535, %534
  %540 = fmul double %536, %534
  %541 = fmul double %537, %534
  br label %predication.tail176

predication.tail176:                              ; preds = %predication.split175, %predication.tail174.thread
  %542 = phi double [ %533, %predication.split175 ], [ undef, %predication.tail174.thread ]
  %merged.select154 = phi double [ %mul10.i.i.i, %predication.split175 ], [ %cond.i1661.i.i, %predication.tail174.thread ]
  %merged.select152 = phi double [ %532, %predication.split175 ], [ %div99.i.i, %predication.tail174.thread ]
  %merged.select150 = phi double [ %mul6.i1623.i.i, %predication.split175 ], [ %cond.i1661.i.i, %predication.tail174.thread ]
  %merged.select148 = phi double [ %531, %predication.split175 ], [ %mul92.i.i, %predication.tail174.thread ]
  %merged.select146 = phi double [ %add.i1622.i.i, %predication.split175 ], [ %cond.i1661.i.i, %predication.tail174.thread ]
  %merged.select144 = phi double [ %530, %predication.split175 ], [ %mul91.i.i, %predication.tail174.thread ]
  %merged.select143 = phi double [ %534, %predication.split175 ], [ %529, %predication.tail174.thread ]
  %merged.select142 = phi double [ %538, %predication.split175 ], [ %cond.i1661.i.i, %predication.tail174.thread ]
  %543 = phi double [ %539, %predication.split175 ], [ undef, %predication.tail174.thread ]
  %544 = phi double [ %540, %predication.split175 ], [ undef, %predication.tail174.thread ]
  %545 = phi double [ %541, %predication.split175 ], [ undef, %predication.tail174.thread ]
  %546 = fmul double %merged.select143, %merged.select142
  %547 = fdiv double 1.000000e+00, %353
  %548 = fadd double %278, %546
  %549 = fmul double %.sink210, %cond.i1661.i.i
  %merged.select145 = select i1 %352, double %278, double %549
  %550 = fsub double %merged.select144, %merged.select145
  %merged.select147 = select i1 %352, double %550, double %cond.i1661.i.i
  %551 = fmul double %merged.select146, %merged.select147
  %552 = fadd double %add.i1650.i.i, %551
  %merged.select149 = select i1 %352, double %277, double %551
  %553 = fsub double %merged.select148, %merged.select149
  %merged.select151 = select i1 %352, double %553, double %cond.i1661.i.i
  %554 = fmul double %merged.select150, %merged.select151
  %555 = fadd double %mul6.i1651.i.i, %554
  %merged.select153 = select i1 %352, double %276, double %554
  %556 = fsub double %merged.select152, %merged.select153
  %merged.select155 = select i1 %352, double %556, double %cond.i1661.i.i
  %557 = fmul double %merged.select154, %merged.select155
  %merged.select156 = select i1 %352, double %mul10.i1653.i.i, double %550
  %merged.select157 = select i1 %352, double %557, double %543
  %558 = fadd double %merged.select156, %merged.select157
  br i1 %352, label %merged.bb139, label %predication.split189

predication.split189:                             ; preds = %predication.tail176
  %559 = fsub double %542, %557
  %560 = fadd double %544, %553
  %561 = fadd double %545, %556
  %562 = fadd double %546, %559
  %563 = fmul double %547, %558
  %564 = fmul double %547, %560
  %565 = fmul double %547, %561
  %566 = fmul double %547, %562
  br label %merged.bb139

merged.bb138:                                     ; preds = %if.end105.i.i
  %mul113.i.i = fmul double %mul3.i1678.i.i, %div78.i.i
  %mul112.i.i = fmul double %div.i.i, %div78.i.i
  %567 = fadd double %.sink210, %278
  %568 = fadd double %add.i1622.i.i, %add.i1650.i.i
  %569 = fadd double %mul6.i1623.i.i, %mul6.i1651.i.i
  %spec.select198 = select i1 %352, double %cond.i1659.i.i, double %569
  %spec.select199 = select i1 %352, double %cond.i1659.i.i, double %568
  %spec.select200 = select i1 %352, double %cond.i1659.i.i, double %567
  %570 = fsub double %div78.i.i, %275
  %571 = fadd double %mul10.i.i.i, %mul10.i1653.i.i
  %merged.select159 = select i1 %352, double %570, double 5.000000e-01
  %572 = fmul double %spec.select200, %merged.select159
  %573 = fadd double %.sink210, %572
  %574 = fsub double %mul112.i.i, %.sink210
  %merged.select161 = select i1 %352, double %574, double 5.000000e-01
  %575 = fmul double %spec.select199, %merged.select161
  %576 = fadd double %add.i1622.i.i, %575
  %577 = fsub double %mul113.i.i, %.sink209
  %merged.select163 = select i1 %352, double %577, double 5.000000e-01
  %578 = fmul double %spec.select198, %merged.select163
  %579 = fadd double %mul6.i1623.i.i, %578
  %580 = fsub double %div121.i.i, %.sink207
  %merged.select164 = select i1 %352, double %cond.i1659.i.i, double %571
  %merged.select165 = select i1 %352, double %580, double 5.000000e-01
  %581 = fmul double %merged.select164, %merged.select165
  %582 = fadd double %mul10.i.i.i, %581
  br label %merged.bb139

merged.bb139:                                     ; preds = %merged.bb138, %predication.split189, %predication.tail176
  %583 = phi double [ %548, %predication.tail176 ], [ %548, %predication.split189 ], [ %573, %merged.bb138 ]
  %584 = phi double [ %552, %predication.tail176 ], [ %552, %predication.split189 ], [ %576, %merged.bb138 ]
  %585 = phi double [ %555, %predication.tail176 ], [ %555, %predication.split189 ], [ %579, %merged.bb138 ]
  %586 = phi double [ %558, %predication.tail176 ], [ %558, %predication.split189 ], [ %582, %merged.bb138 ]
  %587 = phi double [ undef, %predication.tail176 ], [ %563, %predication.split189 ], [ %572, %merged.bb138 ]
  %588 = phi double [ undef, %predication.tail176 ], [ %564, %predication.split189 ], [ %575, %merged.bb138 ]
  %589 = phi double [ undef, %predication.tail176 ], [ %565, %predication.split189 ], [ %578, %merged.bb138 ]
  %590 = phi double [ undef, %predication.tail176 ], [ %566, %predication.split189 ], [ %581, %merged.bb138 ]
  %spec.select = select i1 %352, double %586, double %590
  %spec.select1 = select i1 %352, double %585, double %589
  %spec.select2 = select i1 %352, double %584, double %588
  %spec.select3 = select i1 %352, double %583, double %587
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
!13 = !{!14, !12, i64 0}
!14 = !{!"_ZTS9SimConfig", !12, i64 0, !12, i64 8, !12, i64 16, !12, i64 24, !12, i64 32, !12, i64 40, !12, i64 48, !12, i64 56, !12, i64 64, !12, i64 72, !12, i64 80, !15, i64 88}
!15 = !{!"int", !9, i64 0}
