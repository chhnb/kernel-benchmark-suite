; ModuleID = '/home/chh/kernel-benchmark-suite-review-speculation/build/decision-fuse/first-pair-comparison/old_after.ll'
source_filename = "llvm-link"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p5i8(i64 immarg, i8 addrspace(5)* nocapture) #0

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p5i8(i64 immarg, i8 addrspace(5)* nocapture) #0

; Function Attrs: norecurse nounwind
define protected amdgpu_kernel void @cache_eval(i16 addrspace(1)* nocapture readonly %key.coerce, i16 addrspace(1)* nocapture readonly %value.coerce, i64 addrspace(1)* nocapture readonly %slots.coerce, i8 addrspace(1)* nocapture %kd.coerce, i8 addrspace(1)* nocapture %vd.coerce, i8 addrspace(1)* nocapture %ks.coerce, i8 addrspace(1)* nocapture %vs.coerce, i32 %heads, i32 %dim, i32 %page, i32 %stride, float %kg, float %vg) local_unnamed_addr #1 {
entry:
  %code = alloca [2 x i8], align 1, addrspace(5)
  %0 = tail call i32 @llvm.amdgcn.workgroup.id.x() #3
  %idxprom = sext i32 %0 to i64
  %arrayidx330 = getelementptr inbounds i64, i64 addrspace(1)* %slots.coerce, i64 %idxprom
  %1 = load i64, i64 addrspace(1)* %arrayidx330, align 8, !tbaa !5
  %cmp = icmp slt i64 %1, 0
  br i1 %cmp, label %cleanup, label %if.end

if.end:                                           ; preds = %entry
  %conv = sext i32 %page to i64
  %.frozen = freeze i64 %1
  %conv.frozen = freeze i64 %conv
  %div = sdiv i64 %.frozen, %conv.frozen
  %2 = mul i64 %div, %conv.frozen
  %rem.decomposed = sub i64 %.frozen, %2
  %conv9 = trunc i64 %rem.decomposed to i32
  %div10 = sdiv i32 %dim, 16
  %mul = mul nsw i32 %div10, %heads
  %conv13 = sext i32 %stride to i64
  %mul14 = mul nsw i64 %conv13, %idxprom
  %3 = tail call i32 @llvm.amdgcn.workitem.id.x() #3, !range !9
  %cmp32418 = icmp slt i32 %3, %mul
  %4 = getelementptr inbounds [2 x i8], [2 x i8] addrspace(5)* %code, i32 0, i32 0
  %conv151 = sext i32 %heads to i64
  %mul152 = mul nsw i64 %div, %conv151
  %div159 = sdiv i32 %dim, 2
  %conv160 = sext i32 %div159 to i64
  %div194 = sdiv i32 %conv9, 4
  %mul195 = shl nsw i32 %div194, 2
  %div196 = sdiv i32 %dim, 64
  %rem202.decomposed = sub i32 %conv9, %mul195
  %conv215 = sext i32 %div10 to i64
  %5 = tail call align 4 dereferenceable(64) i8 addrspace(4)* @llvm.amdgcn.dispatch.ptr() #3
  %6 = getelementptr i8, i8 addrspace(4)* %5, i64 4
  %7 = bitcast i8 addrspace(4)* %6 to i16 addrspace(4)*
  %8 = load i16, i16 addrspace(4)* %7, align 4
  %9 = zext i16 %8 to i32
  %arrayidx64340398.1 = getelementptr inbounds [2 x i8], [2 x i8] addrspace(5)* %code, i32 0, i32 1
  %div10.frozen = freeze i32 %div10
  %div196.frozen = freeze i32 %div196
  br label %for.body

for.body:                                         ; preds = %for.cond.cleanup33, %if.end
  %os.sroa.0.0 = phi <2 x float> [ undef, %if.end ], [ %os.sroa.0.1, %for.cond.cleanup33 ]
  %tobool.not = phi i1 [ true, %if.end ], [ false, %for.cond.cleanup33 ]
  %cond.v = select i1 %tobool.not, i16 addrspace(1)* %key.coerce, i16 addrspace(1)* %value.coerce
  %add.ptr331 = getelementptr inbounds i16, i16 addrspace(1)* %cond.v, i64 %mul14
  %cond19.v = select i1 %tobool.not, i8 addrspace(1)* %kd.coerce, i8 addrspace(1)* %vd.coerce
  %cond24.v = select i1 %tobool.not, i8 addrspace(1)* %ks.coerce, i8 addrspace(1)* %vs.coerce
  %cond29 = select i1 %tobool.not, float %kg, float %vg
  br i1 %cmp32418, label %for.body34.lr.ph, label %for.cond.cleanup33

for.body34.lr.ph:                                 ; preds = %for.body
  %div71 = fdiv float 1.000000e+00, %cond29
  br label %for.body34

for.cond.cleanup33:                               ; preds = %if.end204, %for.body
  %os.sroa.0.1 = phi <2 x float> [ %os.sroa.0.0, %for.body ], [ %os.sroa.0.6, %if.end204 ]
  br i1 %tobool.not, label %for.body, label %cleanup

for.body34:                                       ; preds = %if.end204, %for.body34.lr.ph
  %os.sroa.0.2 = phi <2 x float> [ %os.sroa.0.0, %for.body34.lr.ph ], [ %os.sroa.0.6, %if.end204 ]
  %g.0419 = phi i32 [ %3, %for.body34.lr.ph ], [ %add222, %if.end204 ]
  %g.0419.frozen = freeze i32 %g.0419
  %div35 = sdiv i32 %g.0419.frozen, %div10.frozen
  %10 = mul i32 %div35, %div10.frozen
  %rem36.decomposed = sub i32 %g.0419.frozen, %10
  %mul41 = mul nsw i32 %div35, %dim
  %mul42 = shl nsw i32 %rem36.decomposed, 4
  %add = add nsw i32 %mul42, %mul41
  %idxprom44 = sext i32 %add to i64
  %arrayidx45347 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44
  %11 = load i16, i16 addrspace(1)* %arrayidx45347, align 2, !tbaa !10
  %conv.i = zext i16 %11 to i32
  %shl.i = shl nuw i32 %conv.i, 16
  %12 = bitcast i32 %shl.i to float
  %13 = tail call float @llvm.fabs.f32(float %12) #3
  %14 = tail call float @llvm.maxnum.f32(float %13, float 0.000000e+00) #3
  %add43.1 = add nsw i32 %add, 1
  %idxprom44.1 = sext i32 %add43.1 to i64
  %arrayidx45347.1 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.1
  %15 = load i16, i16 addrspace(1)* %arrayidx45347.1, align 2, !tbaa !10
  %conv.i.1 = zext i16 %15 to i32
  %shl.i.1 = shl nuw i32 %conv.i.1, 16
  %16 = bitcast i32 %shl.i.1 to float
  %17 = tail call float @llvm.fabs.f32(float %16) #3
  %18 = tail call float @llvm.maxnum.f32(float %14, float %17) #3
  %add43.2 = add nsw i32 %add, 2
  %idxprom44.2 = sext i32 %add43.2 to i64
  %arrayidx45347.2 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.2
  %19 = load i16, i16 addrspace(1)* %arrayidx45347.2, align 2, !tbaa !10
  %conv.i.2 = zext i16 %19 to i32
  %shl.i.2 = shl nuw i32 %conv.i.2, 16
  %20 = bitcast i32 %shl.i.2 to float
  %21 = tail call float @llvm.fabs.f32(float %20) #3
  %22 = tail call float @llvm.maxnum.f32(float %18, float %21) #3
  %add43.3 = add nsw i32 %add, 3
  %idxprom44.3 = sext i32 %add43.3 to i64
  %arrayidx45347.3 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.3
  %23 = load i16, i16 addrspace(1)* %arrayidx45347.3, align 2, !tbaa !10
  %conv.i.3 = zext i16 %23 to i32
  %shl.i.3 = shl nuw i32 %conv.i.3, 16
  %24 = bitcast i32 %shl.i.3 to float
  %25 = tail call float @llvm.fabs.f32(float %24) #3
  %26 = tail call float @llvm.maxnum.f32(float %22, float %25) #3
  %add43.4 = add nsw i32 %add, 4
  %idxprom44.4 = sext i32 %add43.4 to i64
  %arrayidx45347.4 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.4
  %27 = load i16, i16 addrspace(1)* %arrayidx45347.4, align 2, !tbaa !10
  %conv.i.4 = zext i16 %27 to i32
  %shl.i.4 = shl nuw i32 %conv.i.4, 16
  %28 = bitcast i32 %shl.i.4 to float
  %29 = tail call float @llvm.fabs.f32(float %28) #3
  %30 = tail call float @llvm.maxnum.f32(float %26, float %29) #3
  %add43.5 = add nsw i32 %add, 5
  %idxprom44.5 = sext i32 %add43.5 to i64
  %arrayidx45347.5 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.5
  %31 = load i16, i16 addrspace(1)* %arrayidx45347.5, align 2, !tbaa !10
  %conv.i.5 = zext i16 %31 to i32
  %shl.i.5 = shl nuw i32 %conv.i.5, 16
  %32 = bitcast i32 %shl.i.5 to float
  %33 = tail call float @llvm.fabs.f32(float %32) #3
  %34 = tail call float @llvm.maxnum.f32(float %30, float %33) #3
  %add43.6 = add nsw i32 %add, 6
  %idxprom44.6 = sext i32 %add43.6 to i64
  %arrayidx45347.6 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.6
  %35 = load i16, i16 addrspace(1)* %arrayidx45347.6, align 2, !tbaa !10
  %conv.i.6 = zext i16 %35 to i32
  %shl.i.6 = shl nuw i32 %conv.i.6, 16
  %36 = bitcast i32 %shl.i.6 to float
  %37 = tail call float @llvm.fabs.f32(float %36) #3
  %38 = tail call float @llvm.maxnum.f32(float %34, float %37) #3
  %add43.7 = add nsw i32 %add, 7
  %idxprom44.7 = sext i32 %add43.7 to i64
  %arrayidx45347.7 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.7
  %39 = load i16, i16 addrspace(1)* %arrayidx45347.7, align 2, !tbaa !10
  %conv.i.7 = zext i16 %39 to i32
  %shl.i.7 = shl nuw i32 %conv.i.7, 16
  %40 = bitcast i32 %shl.i.7 to float
  %41 = tail call float @llvm.fabs.f32(float %40) #3
  %42 = tail call float @llvm.maxnum.f32(float %38, float %41) #3
  %add43.8 = add nsw i32 %add, 8
  %idxprom44.8 = sext i32 %add43.8 to i64
  %arrayidx45347.8 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.8
  %43 = load i16, i16 addrspace(1)* %arrayidx45347.8, align 2, !tbaa !10
  %conv.i.8 = zext i16 %43 to i32
  %shl.i.8 = shl nuw i32 %conv.i.8, 16
  %44 = bitcast i32 %shl.i.8 to float
  %45 = tail call float @llvm.fabs.f32(float %44) #3
  %46 = tail call float @llvm.maxnum.f32(float %42, float %45) #3
  %add43.9 = add nsw i32 %add, 9
  %idxprom44.9 = sext i32 %add43.9 to i64
  %arrayidx45347.9 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.9
  %47 = load i16, i16 addrspace(1)* %arrayidx45347.9, align 2, !tbaa !10
  %conv.i.9 = zext i16 %47 to i32
  %shl.i.9 = shl nuw i32 %conv.i.9, 16
  %48 = bitcast i32 %shl.i.9 to float
  %49 = tail call float @llvm.fabs.f32(float %48) #3
  %50 = tail call float @llvm.maxnum.f32(float %46, float %49) #3
  %add43.10 = add nsw i32 %add, 10
  %idxprom44.10 = sext i32 %add43.10 to i64
  %arrayidx45347.10 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.10
  %51 = load i16, i16 addrspace(1)* %arrayidx45347.10, align 2, !tbaa !10
  %conv.i.10 = zext i16 %51 to i32
  %shl.i.10 = shl nuw i32 %conv.i.10, 16
  %52 = bitcast i32 %shl.i.10 to float
  %53 = tail call float @llvm.fabs.f32(float %52) #3
  %54 = tail call float @llvm.maxnum.f32(float %50, float %53) #3
  %add43.11 = add nsw i32 %add, 11
  %idxprom44.11 = sext i32 %add43.11 to i64
  %arrayidx45347.11 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.11
  %55 = load i16, i16 addrspace(1)* %arrayidx45347.11, align 2, !tbaa !10
  %conv.i.11 = zext i16 %55 to i32
  %shl.i.11 = shl nuw i32 %conv.i.11, 16
  %56 = bitcast i32 %shl.i.11 to float
  %57 = tail call float @llvm.fabs.f32(float %56) #3
  %58 = tail call float @llvm.maxnum.f32(float %54, float %57) #3
  %add43.12 = add nsw i32 %add, 12
  %idxprom44.12 = sext i32 %add43.12 to i64
  %arrayidx45347.12 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.12
  %59 = load i16, i16 addrspace(1)* %arrayidx45347.12, align 2, !tbaa !10
  %conv.i.12 = zext i16 %59 to i32
  %shl.i.12 = shl nuw i32 %conv.i.12, 16
  %60 = bitcast i32 %shl.i.12 to float
  %61 = tail call float @llvm.fabs.f32(float %60) #3
  %62 = tail call float @llvm.maxnum.f32(float %58, float %61) #3
  %add43.13 = add nsw i32 %add, 13
  %idxprom44.13 = sext i32 %add43.13 to i64
  %arrayidx45347.13 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.13
  %63 = load i16, i16 addrspace(1)* %arrayidx45347.13, align 2, !tbaa !10
  %conv.i.13 = zext i16 %63 to i32
  %shl.i.13 = shl nuw i32 %conv.i.13, 16
  %64 = bitcast i32 %shl.i.13 to float
  %65 = tail call float @llvm.fabs.f32(float %64) #3
  %66 = tail call float @llvm.maxnum.f32(float %62, float %65) #3
  %add43.14 = add nsw i32 %add, 14
  %idxprom44.14 = sext i32 %add43.14 to i64
  %arrayidx45347.14 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.14
  %67 = load i16, i16 addrspace(1)* %arrayidx45347.14, align 2, !tbaa !10
  %add43.15 = add nsw i32 %add, 15
  %idxprom44.15 = sext i32 %add43.15 to i64
  %arrayidx45347.15 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.15
  %68 = load i16, i16 addrspace(1)* %arrayidx45347.15, align 2, !tbaa !10
  %69 = insertelement <2 x i16> undef, i16 %68, i32 0
  %70 = insertelement <2 x i16> %69, i16 %67, i32 1
  %71 = zext <2 x i16> %70 to <2 x i32>
  %72 = shl nuw <2 x i32> %71, <i32 16, i32 16>
  %73 = bitcast <2 x i32> %72 to <2 x float>
  %74 = extractelement <2 x float> %73, i32 1
  %75 = tail call float @llvm.fabs.f32(float %74) #3
  %76 = tail call float @llvm.maxnum.f32(float %66, float %75) #3
  %77 = extractelement <2 x float> %73, i32 0
  %78 = tail call float @llvm.fabs.f32(float %77) #3
  %79 = tail call float @llvm.maxnum.f32(float %76, float %78) #3
  call void @llvm.lifetime.start.p5i8(i64 2, i8 addrspace(5)* %4) #3
  %mul60 = fmul float %79, 0x3FC5555560000000
  %mul61 = fmul float %cond29, %mul60
  %cmp.i379 = fcmp ult float %mul61, 4.480000e+02
  br i1 %cmp.i379, label %_Z4dec8i.exit.i.2, label %_Z4enc8f.exit.thread396

_Z4enc8f.exit.thread396:                          ; preds = %for.body34
  store i8 126, i8 addrspace(5)* %4, align 1, !tbaa !12
  br label %cond.true.i

_Z4enc8f.exit.thread:                             ; preds = %_Z4dec8i.exit.i.6
  store i8 0, i8 addrspace(5)* %4, align 1, !tbaa !12
  br label %cond.false.i377

if.end9.i:                                        ; preds = %_Z4dec8i.exit.i.6
  %sub.i382 = add nsw i32 %lo.1.i.6, -1
  %shr.i62.i = ashr i32 %sub.i382, 3
  %and.i63.i = and i32 %sub.i382, 7
  %tobool.not.i64.i = icmp eq i32 %shr.i62.i, 0
  %conv1.i70.i = sitofp i32 %and.i63.i to float
  br i1 %tobool.not.i64.i, label %cond.false.i72.i, label %cond.true.i69.i

cond.true.i69.i:                                  ; preds = %if.end9.i
  %mul.i66.i = fmul float %conv1.i70.i, 1.250000e-01
  %add.i67.i = fadd float %mul.i66.i, 1.000000e+00
  %sub.i68.i = add nsw i32 %shr.i62.i, -7
  %80 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i67.i, i32 %sub.i68.i) #3
  br label %_Z4dec8i.exit74.i

cond.false.i72.i:                                 ; preds = %if.end9.i
  %mul2.i71.i = fmul float %conv1.i70.i, 0x3F60000000000000
  br label %_Z4dec8i.exit74.i

_Z4dec8i.exit74.i:                                ; preds = %cond.false.i72.i, %cond.true.i69.i
  %cond.i73.i = phi float [ %80, %cond.true.i69.i ], [ %mul2.i71.i, %cond.false.i72.i ]
  %sub11.i = fsub float %mul61, %cond.i73.i
  %shr.i49.i657 = lshr i32 %lo.1.i.6, 3
  %and.i50.i = and i32 %lo.1.i.6, 7
  %tobool.not.i51.i = icmp eq i32 %shr.i49.i657, 0
  %conv1.i57.i = sitofp i32 %and.i50.i to float
  br i1 %tobool.not.i51.i, label %cond.false.i59.i, label %cond.true.i56.i

cond.true.i56.i:                                  ; preds = %_Z4dec8i.exit74.i
  %mul.i53.i = fmul float %conv1.i57.i, 1.250000e-01
  %add.i54.i = fadd float %mul.i53.i, 1.000000e+00
  %sub.i55.i = add nsw i32 %shr.i49.i657, -7
  %81 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i54.i, i32 %sub.i55.i) #3
  br label %_Z4dec8i.exit61.i

cond.false.i59.i:                                 ; preds = %_Z4dec8i.exit74.i
  %mul2.i58.i = fmul float %conv1.i57.i, 0x3F60000000000000
  br label %_Z4dec8i.exit61.i

_Z4dec8i.exit61.i:                                ; preds = %cond.false.i59.i, %cond.true.i56.i
  %cond.i60.i = phi float [ %81, %cond.true.i56.i ], [ %mul2.i58.i, %cond.false.i59.i ]
  %sub13.i = fsub float %cond.i60.i, %mul61
  %cmp14.i = fcmp olt float %sub11.i, %sub13.i
  br i1 %cmp14.i, label %_Z4enc8f.exit, label %cond.false.i384

cond.false.i384:                                  ; preds = %_Z4dec8i.exit61.i
  %cmp16.i383 = fcmp olt float %sub13.i, %sub11.i
  %and.i385 = and i32 %lo.1.i.6, 1
  %tobool.not.i386 = icmp eq i32 %and.i385, 0
  %cond.i387 = select i1 %tobool.not.i386, i32 %lo.1.i.6, i32 %sub.i382
  br i1 %cmp16.i383, label %_Z4enc8f.exit, label %cond.false18.i

cond.false18.i:                                   ; preds = %cond.false.i384
  %.pre449 = and i32 %cond.i387, 7
  br label %_Z4enc8f.exit

_Z4enc8f.exit:                                    ; preds = %cond.false18.i, %cond.false.i384, %_Z4dec8i.exit61.i
  %and.i375.pre-phi = phi i32 [ %and.i63.i, %_Z4dec8i.exit61.i ], [ %and.i50.i, %cond.false.i384 ], [ %.pre449, %cond.false18.i ]
  %cond25.i = phi i32 [ %sub.i382, %_Z4dec8i.exit61.i ], [ %lo.1.i.6, %cond.false.i384 ], [ %cond.i387, %cond.false18.i ]
  %conv.i388 = trunc i32 %cond25.i to i8
  store i8 %conv.i388, i8 addrspace(5)* %4, align 1, !tbaa !12
  %conv67 = lshr i32 %cond25.i, 3
  %tobool.not.i = icmp eq i32 %conv67, 0
  br i1 %tobool.not.i, label %cond.false.i377, label %cond.true.i

cond.true.i:                                      ; preds = %_Z4enc8f.exit, %_Z4enc8f.exit.thread396
  %and.i375404 = phi i32 [ 6, %_Z4enc8f.exit.thread396 ], [ %and.i375.pre-phi, %_Z4enc8f.exit ]
  %shr.i374403 = phi i32 [ 15, %_Z4enc8f.exit.thread396 ], [ %conv67, %_Z4enc8f.exit ]
  %conv.i376 = sitofp i32 %and.i375404 to float
  %mul.i = fmul float %conv.i376, 1.250000e-01
  %add.i = fadd float %mul.i, 1.000000e+00
  %sub.i = add nsw i32 %shr.i374403, -7
  %82 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i, i32 %sub.i) #3
  br label %_Z4dec8i.exit

cond.false.i377:                                  ; preds = %_Z4enc8f.exit, %_Z4enc8f.exit.thread
  %and.i375395 = phi i32 [ 0, %_Z4enc8f.exit.thread ], [ %and.i375.pre-phi, %_Z4enc8f.exit ]
  %conv1.i = sitofp i32 %and.i375395 to float
  %mul2.i = fmul float %conv1.i, 0x3F60000000000000
  br label %_Z4dec8i.exit

_Z4dec8i.exit:                                    ; preds = %cond.false.i377, %cond.true.i
  %cond.i378 = phi float [ %82, %cond.true.i ], [ %mul2.i, %cond.false.i377 ]
  %cmp69 = fcmp une float %cond.i378, 0.000000e+00
  br i1 %cmp69, label %cond.end75, label %cond.end75.thread

cond.end75.thread:                                ; preds = %_Z4dec8i.exit
  %83 = insertelement <2 x float> %os.sroa.0.2, float 0.000000e+00, i32 0
  br label %if.then97.7

cond.end75:                                       ; preds = %_Z4dec8i.exit
  %mul72 = fmul float %div71, %cond.i378
  %div73 = fdiv float 1.000000e+00, %mul72
  %84 = insertelement <2 x float> %os.sroa.0.2, float %div73, i32 0
  %cmp81 = fcmp une float %div73, 0.000000e+00
  %div85 = fdiv float 1.000000e+00, %div73
  %cond88 = select i1 %cmp81, float %div85, float 0.000000e+00
  %cmp96 = fcmp oeq float %div73, 0.000000e+00
  br i1 %cmp96, label %if.then97.7, label %if.else.7

cond.false.i353:                                  ; preds = %for.inc138.7.1
  %cmp1.i352 = fcmp olt float %405, 7.500000e-01
  br i1 %cmp1.i352, label %_Z5pack4f.exit369, label %cond.false3.i355

cond.false3.i355:                                 ; preds = %cond.false.i353
  %cmp4.i354 = fcmp ugt float %405, 1.250000e+00
  br i1 %cmp4.i354, label %cond.false6.i357, label %_Z5pack4f.exit369

cond.false6.i357:                                 ; preds = %cond.false3.i355
  %cmp7.i356 = fcmp olt float %405, 1.750000e+00
  br i1 %cmp7.i356, label %_Z5pack4f.exit369, label %cond.false9.i359

cond.false9.i359:                                 ; preds = %cond.false6.i357
  %cmp10.i358 = fcmp ugt float %405, 2.500000e+00
  br i1 %cmp10.i358, label %cond.false12.i361, label %_Z5pack4f.exit369

cond.false12.i361:                                ; preds = %cond.false9.i359
  %cmp13.i360 = fcmp olt float %405, 3.500000e+00
  br i1 %cmp13.i360, label %_Z5pack4f.exit369, label %cond.false15.i364

cond.false15.i364:                                ; preds = %cond.false12.i361
  %cmp16.i362 = fcmp ole float %405, 5.000000e+00
  %cond.i363 = select i1 %cmp16.i362, i32 6, i32 7
  br label %_Z5pack4f.exit369

_Z5pack4f.exit369:                                ; preds = %for.inc138.7.1, %cond.false15.i364, %cond.false12.i361, %cond.false9.i359, %cond.false6.i357, %cond.false3.i355, %cond.false.i353
  %cond27.i365 = phi i32 [ 1, %cond.false.i353 ], [ 2, %cond.false3.i355 ], [ 3, %cond.false6.i357 ], [ 4, %cond.false9.i359 ], [ 5, %cond.false12.i361 ], [ %cond.i363, %cond.false15.i364 ], [ 0, %for.inc138.7.1 ]
  %85 = bitcast float %mul175 to i32
  %shr.i366 = lshr i32 %85, 28
  %and.i367 = and i32 %shr.i366, 8
  %or.i368 = or i32 %cond27.i365, %and.i367
  %mul183 = fmul float %404, %16
  %86 = tail call float @llvm.fabs.f32(float %mul183) #3
  %cmp.i = fcmp ugt float %86, 2.500000e-01
  br i1 %cmp.i, label %cond.false.i, label %_Z5pack4f.exit

cond.false.i:                                     ; preds = %_Z5pack4f.exit369
  %cmp1.i = fcmp olt float %86, 7.500000e-01
  br i1 %cmp1.i, label %_Z5pack4f.exit, label %cond.false3.i

cond.false3.i:                                    ; preds = %cond.false.i
  %cmp4.i = fcmp ugt float %86, 1.250000e+00
  br i1 %cmp4.i, label %cond.false6.i, label %_Z5pack4f.exit

cond.false6.i:                                    ; preds = %cond.false3.i
  %cmp7.i = fcmp olt float %86, 1.750000e+00
  br i1 %cmp7.i, label %_Z5pack4f.exit, label %cond.false9.i

cond.false9.i:                                    ; preds = %cond.false6.i
  %cmp10.i = fcmp ugt float %86, 2.500000e+00
  br i1 %cmp10.i, label %cond.false12.i, label %_Z5pack4f.exit

cond.false12.i:                                   ; preds = %cond.false9.i
  %cmp13.i = fcmp olt float %86, 3.500000e+00
  br i1 %cmp13.i, label %_Z5pack4f.exit, label %cond.false15.i

cond.false15.i:                                   ; preds = %cond.false12.i
  %cmp16.i = fcmp ole float %86, 5.000000e+00
  %cond.i = select i1 %cmp16.i, i32 6, i32 7
  br label %_Z5pack4f.exit

_Z5pack4f.exit:                                   ; preds = %cond.false15.i, %cond.false12.i, %cond.false9.i, %cond.false6.i, %cond.false3.i, %cond.false.i, %_Z5pack4f.exit369
  %cond27.i = phi i32 [ 0, %_Z5pack4f.exit369 ], [ 1, %cond.false.i ], [ 2, %cond.false3.i ], [ 3, %cond.false6.i ], [ 4, %cond.false9.i ], [ 5, %cond.false12.i ], [ %cond.i, %cond.false15.i ]
  %87 = bitcast float %mul183 to i32
  %shr.i = lshr i32 %87, 28
  %and.i = and i32 %shr.i, 8
  %or.i = or i32 %cond27.i, %and.i
  %shl = shl nuw nsw i32 %or.i, 4
  %or = or i32 %or.i368, %shl
  %conv185 = trunc i32 %or to i8
  %arrayidx188339 = getelementptr inbounds i8, i8 addrspace(1)* %cond19.v, i64 %add164
  store i8 %conv185, i8 addrspace(1)* %arrayidx188339, align 1, !tbaa !12
  %mul175.1 = fmul float %404, %20
  %88 = tail call float @llvm.fabs.f32(float %mul175.1) #3
  %cmp.i351.1 = fcmp ugt float %88, 2.500000e-01
  br i1 %cmp.i351.1, label %cond.false.i353.1, label %_Z5pack4f.exit369.1

if.then193:                                       ; preds = %_Z5pack4f.exit.7
  %div197 = sdiv i32 %rem36.decomposed, %div196.frozen
  %add198 = add nsw i32 %div197, %mul195
  %89 = mul i32 %div197, %div196.frozen
  %rem200.decomposed = sub i32 %rem36.decomposed, %89
  %mul201 = shl nsw i32 %rem200.decomposed, 2
  %add203 = add nsw i32 %rem202.decomposed, %mul201
  br label %if.end204

if.end204:                                        ; preds = %_Z5pack4f.exit.7, %if.then193
  %st.0 = phi i32 [ %add198, %if.then193 ], [ %conv9, %_Z5pack4f.exit.7 ]
  %ss.0 = phi i32 [ %add203, %if.then193 ], [ %rem36.decomposed, %_Z5pack4f.exit.7 ]
  %arrayidx206334 = getelementptr inbounds [2 x i8], [2 x i8] addrspace(5)* %code, i32 0, i32 %403
  %90 = load i8, i8 addrspace(5)* %arrayidx206334, align 1, !tbaa !12
  %conv213 = sext i32 %st.0 to i64
  %add214 = add nsw i64 %mul156, %conv213
  %mul216 = mul nsw i64 %add214, %conv215
  %conv217 = sext i32 %ss.0 to i64
  %add218 = add nsw i64 %mul216, %conv217
  %arrayidx219335 = getelementptr inbounds i8, i8 addrspace(1)* %cond24.v, i64 %add218
  store i8 %90, i8 addrspace(1)* %arrayidx219335, align 1, !tbaa !12
  call void @llvm.lifetime.end.p5i8(i64 2, i8 addrspace(5)* %4) #3
  %add222 = add i32 %g.0419, %9
  %cmp32 = icmp slt i32 %add222, %mul
  br i1 %cmp32, label %for.body34, label %for.cond.cleanup33

cleanup:                                          ; preds = %for.cond.cleanup33, %entry
  ret void

_Z4dec8i.exit.i.2:                                ; preds = %for.body34
  %cmp2.i = fcmp ogt float %mul61, 1.875000e+00
  %hi.1.i = select i1 %cmp2.i, i32 126, i32 63
  %lo.1.i = select i1 %cmp2.i, i32 64, i32 0
  %div.i.1 = select i1 %cmp2.i, i32 95, i32 31
  %91 = lshr i32 %div.i.1, 3
  %sub.i.i.1 = add nsw i32 %91, -7
  %92 = tail call float @llvm.amdgcn.ldexp.f32(float 1.875000e+00, i32 %sub.i.i.1) #3
  %cmp2.i.1 = fcmp olt float %92, %mul61
  %add4.i.1 = add nuw nsw i32 %div.i.1, 1
  %hi.1.i.1 = select i1 %cmp2.i.1, i32 %hi.1.i, i32 %div.i.1
  %lo.1.i.1 = select i1 %cmp2.i.1, i32 %add4.i.1, i32 %lo.1.i
  %add.i381.2 = add nuw nsw i32 %lo.1.i.1, %hi.1.i.1
  %div.i.2 = lshr i32 %add.i381.2, 1
  %93 = lshr i32 %add.i381.2, 4
  %sub.i.i.2 = add nsw i32 %93, -7
  %94 = tail call float @llvm.amdgcn.ldexp.f32(float 1.875000e+00, i32 %sub.i.i.2) #3
  %cmp2.i.2 = fcmp olt float %94, %mul61
  %add4.i.2 = add nuw nsw i32 %div.i.2, 1
  %hi.1.i.2 = select i1 %cmp2.i.2, i32 %hi.1.i.1, i32 %div.i.2
  %lo.1.i.2 = select i1 %cmp2.i.2, i32 %add4.i.2, i32 %lo.1.i.1
  %add.i381.3 = add nuw nsw i32 %lo.1.i.2, %hi.1.i.2
  %div.i.3 = lshr i32 %add.i381.3, 1
  %95 = lshr i32 %add.i381.3, 4
  %and.i.i.3 = and i32 %div.i.3, 7
  %tobool.not.i.i.3 = icmp eq i32 %95, 0
  %conv1.i.i.3 = sitofp i32 %and.i.i.3 to float
  br i1 %tobool.not.i.i.3, label %cond.false.i.i.3, label %cond.true.i.i.3

cond.true.i.i.3:                                  ; preds = %_Z4dec8i.exit.i.2
  %mul.i.i.3 = fmul float %conv1.i.i.3, 1.250000e-01
  %add.i.i.3 = fadd float %mul.i.i.3, 1.000000e+00
  %sub.i.i.3 = add nsw i32 %95, -7
  %96 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i.i.3, i32 %sub.i.i.3) #3
  br label %_Z4dec8i.exit.i.3

cond.false.i.i.3:                                 ; preds = %_Z4dec8i.exit.i.2
  %mul2.i.i.3 = fmul float %conv1.i.i.3, 0x3F60000000000000
  br label %_Z4dec8i.exit.i.3

_Z4dec8i.exit.i.3:                                ; preds = %cond.false.i.i.3, %cond.true.i.i.3
  %cond.i.i.3 = phi float [ %96, %cond.true.i.i.3 ], [ %mul2.i.i.3, %cond.false.i.i.3 ]
  %cmp2.i.3 = fcmp olt float %cond.i.i.3, %mul61
  %add4.i.3 = add nuw nsw i32 %div.i.3, 1
  %hi.1.i.3 = select i1 %cmp2.i.3, i32 %hi.1.i.2, i32 %div.i.3
  %lo.1.i.3 = select i1 %cmp2.i.3, i32 %add4.i.3, i32 %lo.1.i.2
  %add.i381.4 = add nuw nsw i32 %lo.1.i.3, %hi.1.i.3
  %div.i.4 = lshr i32 %add.i381.4, 1
  %97 = lshr i32 %add.i381.4, 4
  %and.i.i.4 = and i32 %div.i.4, 7
  %tobool.not.i.i.4 = icmp eq i32 %97, 0
  %conv1.i.i.4 = sitofp i32 %and.i.i.4 to float
  br i1 %tobool.not.i.i.4, label %cond.false.i.i.4, label %cond.true.i.i.4

cond.true.i.i.4:                                  ; preds = %_Z4dec8i.exit.i.3
  %mul.i.i.4 = fmul float %conv1.i.i.4, 1.250000e-01
  %add.i.i.4 = fadd float %mul.i.i.4, 1.000000e+00
  %sub.i.i.4 = add nsw i32 %97, -7
  %98 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i.i.4, i32 %sub.i.i.4) #3
  br label %_Z4dec8i.exit.i.4

cond.false.i.i.4:                                 ; preds = %_Z4dec8i.exit.i.3
  %mul2.i.i.4 = fmul float %conv1.i.i.4, 0x3F60000000000000
  br label %_Z4dec8i.exit.i.4

_Z4dec8i.exit.i.4:                                ; preds = %cond.false.i.i.4, %cond.true.i.i.4
  %cond.i.i.4 = phi float [ %98, %cond.true.i.i.4 ], [ %mul2.i.i.4, %cond.false.i.i.4 ]
  %cmp2.i.4 = fcmp olt float %cond.i.i.4, %mul61
  %add4.i.4 = add nuw nsw i32 %div.i.4, 1
  %hi.1.i.4 = select i1 %cmp2.i.4, i32 %hi.1.i.3, i32 %div.i.4
  %lo.1.i.4 = select i1 %cmp2.i.4, i32 %add4.i.4, i32 %lo.1.i.3
  %add.i381.5 = add nuw nsw i32 %lo.1.i.4, %hi.1.i.4
  %div.i.5 = sdiv i32 %add.i381.5, 2
  %shr.i.i.5 = ashr i32 %div.i.5, 3
  %and.i.i.5 = and i32 %div.i.5, 7
  %tobool.not.i.i.5 = icmp eq i32 %shr.i.i.5, 0
  %conv1.i.i.5 = sitofp i32 %and.i.i.5 to float
  br i1 %tobool.not.i.i.5, label %cond.false.i.i.5, label %cond.true.i.i.5

cond.true.i.i.5:                                  ; preds = %_Z4dec8i.exit.i.4
  %mul.i.i.5 = fmul float %conv1.i.i.5, 1.250000e-01
  %add.i.i.5 = fadd float %mul.i.i.5, 1.000000e+00
  %sub.i.i.5 = add nsw i32 %shr.i.i.5, -7
  %99 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i.i.5, i32 %sub.i.i.5) #3
  br label %_Z4dec8i.exit.i.5

cond.false.i.i.5:                                 ; preds = %_Z4dec8i.exit.i.4
  %mul2.i.i.5 = fmul float %conv1.i.i.5, 0x3F60000000000000
  br label %_Z4dec8i.exit.i.5

_Z4dec8i.exit.i.5:                                ; preds = %cond.false.i.i.5, %cond.true.i.i.5
  %cond.i.i.5 = phi float [ %99, %cond.true.i.i.5 ], [ %mul2.i.i.5, %cond.false.i.i.5 ]
  %cmp2.i.5 = fcmp olt float %cond.i.i.5, %mul61
  %add4.i.5 = add nuw nsw i32 %div.i.5, 1
  %hi.1.i.5 = select i1 %cmp2.i.5, i32 %hi.1.i.4, i32 %div.i.5
  %lo.1.i.5 = select i1 %cmp2.i.5, i32 %add4.i.5, i32 %lo.1.i.4
  %add.i381.6 = add nuw nsw i32 %lo.1.i.5, %hi.1.i.5
  %div.i.6 = sdiv i32 %add.i381.6, 2
  %shr.i.i.6 = ashr i32 %div.i.6, 3
  %and.i.i.6 = and i32 %div.i.6, 7
  %tobool.not.i.i.6 = icmp eq i32 %shr.i.i.6, 0
  %conv1.i.i.6 = sitofp i32 %and.i.i.6 to float
  br i1 %tobool.not.i.i.6, label %cond.false.i.i.6, label %cond.true.i.i.6

cond.true.i.i.6:                                  ; preds = %_Z4dec8i.exit.i.5
  %mul.i.i.6 = fmul float %conv1.i.i.6, 1.250000e-01
  %add.i.i.6 = fadd float %mul.i.i.6, 1.000000e+00
  %sub.i.i.6 = add nsw i32 %shr.i.i.6, -7
  %100 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i.i.6, i32 %sub.i.i.6) #3
  br label %_Z4dec8i.exit.i.6

cond.false.i.i.6:                                 ; preds = %_Z4dec8i.exit.i.5
  %mul2.i.i.6 = fmul float %conv1.i.i.6, 0x3F60000000000000
  br label %_Z4dec8i.exit.i.6

_Z4dec8i.exit.i.6:                                ; preds = %cond.false.i.i.6, %cond.true.i.i.6
  %cond.i.i.6 = phi float [ %100, %cond.true.i.i.6 ], [ %mul2.i.i.6, %cond.false.i.i.6 ]
  %cmp2.i.6 = fcmp olt float %cond.i.i.6, %mul61
  %add4.i.6 = add nuw nsw i32 %div.i.6, 1
  %lo.1.i.6 = select i1 %cmp2.i.6, i32 %add4.i.6, i32 %lo.1.i.5
  %cmp6.i = icmp eq i32 %lo.1.i.6, 0
  br i1 %cmp6.i, label %_Z4enc8f.exit.thread, label %if.end9.i

if.else.7:                                        ; preds = %cond.end75
  %mul116 = fmul float %div73, %12
  %101 = tail call float @llvm.fabs.f32(float %mul116) #3
  %cmp2.i44 = fcmp olt float %101, 7.500000e-01
  br i1 %cmp2.i44, label %local.copysign, label %if.else4.i

if.else4.i:                                       ; preds = %if.else.7
  %cmp6.i45 = fcmp ugt float %101, 1.250000e+00
  br i1 %cmp6.i45, label %if.else8.i, label %quant_decide.exit

if.else8.i:                                       ; preds = %if.else4.i
  %cmp10.i46 = fcmp olt float %101, 1.750000e+00
  br i1 %cmp10.i46, label %quant_decide.exit, label %if.else12.i

if.else12.i:                                      ; preds = %if.else8.i
  %cmp14.i47 = fcmp ugt float %101, 2.500000e+00
  br i1 %cmp14.i47, label %if.else16.i, label %quant_decide.exit

if.else16.i:                                      ; preds = %if.else12.i
  %cmp18.i = fcmp olt float %101, 3.500000e+00
  br i1 %cmp18.i, label %quant_decide.exit, label %if.else20.i

if.else20.i:                                      ; preds = %if.else16.i
  %cmp22.i = fcmp ugt float %101, 5.000000e+00
  %. = select i1 %cmp22.i, float 6.000000e+00, float 4.000000e+00
  br label %quant_decide.exit

local.copysign:                                   ; preds = %if.else.7
  %cmp.i43 = fcmp ugt float %101, 2.500000e-01
  %local.magnitude = select i1 %cmp.i43, float 5.000000e-01, float 0.000000e+00
  br label %quant_decide.exit

quant_decide.exit:                                ; preds = %if.else20.i, %if.else16.i, %if.else12.i, %if.else8.i, %if.else4.i, %local.copysign
  %local.magnitude.sink = phi float [ %local.magnitude, %local.copysign ], [ 1.000000e+00, %if.else4.i ], [ 1.500000e+00, %if.else8.i ], [ 2.000000e+00, %if.else12.i ], [ 3.000000e+00, %if.else16.i ], [ %., %if.else20.i ]
  %local.result = tail call float @llvm.copysign.f32(float %local.magnitude.sink, float %mul116) #3
  %mul118 = fmul float %cond88, %local.result
  %sub = fsub float %mul118, %12
  %mul126 = fmul float %div73, %16
  %102 = tail call float @llvm.fabs.f32(float %mul126) #3
  %cmp.i708 = fcmp ugt float %102, 2.500000e-01
  br i1 %cmp.i708, label %if.else.i711, label %if.then.i709

if.then.i709:                                     ; preds = %quant_decide.exit
  %103 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126) #3
  br label %quant_decide.exit729

if.else.i711:                                     ; preds = %quant_decide.exit
  %cmp2.i710 = fcmp olt float %102, 7.500000e-01
  br i1 %cmp2.i710, label %if.then3.i712, label %if.else4.i714

if.then3.i712:                                    ; preds = %if.else.i711
  %104 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126) #3
  br label %quant_decide.exit729

if.else4.i714:                                    ; preds = %if.else.i711
  %cmp6.i713 = fcmp ugt float %102, 1.250000e+00
  br i1 %cmp6.i713, label %if.else8.i717, label %if.then7.i715

if.then7.i715:                                    ; preds = %if.else4.i714
  %105 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126) #3
  br label %quant_decide.exit729

if.else8.i717:                                    ; preds = %if.else4.i714
  %cmp10.i716 = fcmp olt float %102, 1.750000e+00
  br i1 %cmp10.i716, label %if.then11.i718, label %if.else12.i720

if.then11.i718:                                   ; preds = %if.else8.i717
  %106 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126) #3
  br label %quant_decide.exit729

if.else12.i720:                                   ; preds = %if.else8.i717
  %cmp14.i719 = fcmp ugt float %102, 2.500000e+00
  br i1 %cmp14.i719, label %if.else16.i723, label %if.then15.i721

if.then15.i721:                                   ; preds = %if.else12.i720
  %107 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126) #3
  br label %quant_decide.exit729

if.else16.i723:                                   ; preds = %if.else12.i720
  %cmp18.i722 = fcmp olt float %102, 3.500000e+00
  br i1 %cmp18.i722, label %if.then19.i724, label %if.else20.i726

if.then19.i724:                                   ; preds = %if.else16.i723
  %108 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126) #3
  br label %quant_decide.exit729

if.else20.i726:                                   ; preds = %if.else16.i723
  %cmp22.i725 = fcmp ugt float %102, 5.000000e+00
  br i1 %cmp22.i725, label %if.end29.i728, label %if.then23.i727

if.then23.i727:                                   ; preds = %if.else20.i726
  %109 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126) #3
  br label %quant_decide.exit729

if.end29.i728:                                    ; preds = %if.else20.i726
  %110 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126) #3
  br label %quant_decide.exit729

quant_decide.exit729:                             ; preds = %if.end29.i728, %if.then23.i727, %if.then19.i724, %if.then15.i721, %if.then11.i718, %if.then7.i715, %if.then3.i712, %if.then.i709
  %out.i.0 = phi float [ %103, %if.then.i709 ], [ %104, %if.then3.i712 ], [ %105, %if.then7.i715 ], [ %106, %if.then11.i718 ], [ %107, %if.then15.i721 ], [ %108, %if.then19.i724 ], [ %109, %if.then23.i727 ], [ %110, %if.end29.i728 ]
  %mul128 = fmul float %cond88, %out.i.0
  %sub132 = fsub float %mul128, %16
  %mul133 = fmul float %sub, %sub
  %mul134 = fmul float %sub132, %sub132
  %add135 = fadd float %mul133, %mul134
  %e.1 = fadd float %add135, 0.000000e+00
  %mul116.1 = fmul float %div73, %20
  %111 = tail call float @llvm.fabs.f32(float %mul116.1) #3
  %cmp.i686 = fcmp ugt float %111, 2.500000e-01
  br i1 %cmp.i686, label %if.else.i689, label %if.then.i687

if.then.i687:                                     ; preds = %quant_decide.exit729
  %112 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.1) #3
  br label %quant_decide.exit707

if.else.i689:                                     ; preds = %quant_decide.exit729
  %cmp2.i688 = fcmp olt float %111, 7.500000e-01
  br i1 %cmp2.i688, label %if.then3.i690, label %if.else4.i692

if.then3.i690:                                    ; preds = %if.else.i689
  %113 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.1) #3
  br label %quant_decide.exit707

if.else4.i692:                                    ; preds = %if.else.i689
  %cmp6.i691 = fcmp ugt float %111, 1.250000e+00
  br i1 %cmp6.i691, label %if.else8.i695, label %if.then7.i693

if.then7.i693:                                    ; preds = %if.else4.i692
  %114 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.1) #3
  br label %quant_decide.exit707

if.else8.i695:                                    ; preds = %if.else4.i692
  %cmp10.i694 = fcmp olt float %111, 1.750000e+00
  br i1 %cmp10.i694, label %if.then11.i696, label %if.else12.i698

if.then11.i696:                                   ; preds = %if.else8.i695
  %115 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.1) #3
  br label %quant_decide.exit707

if.else12.i698:                                   ; preds = %if.else8.i695
  %cmp14.i697 = fcmp ugt float %111, 2.500000e+00
  br i1 %cmp14.i697, label %if.else16.i701, label %if.then15.i699

if.then15.i699:                                   ; preds = %if.else12.i698
  %116 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.1) #3
  br label %quant_decide.exit707

if.else16.i701:                                   ; preds = %if.else12.i698
  %cmp18.i700 = fcmp olt float %111, 3.500000e+00
  br i1 %cmp18.i700, label %if.then19.i702, label %if.else20.i704

if.then19.i702:                                   ; preds = %if.else16.i701
  %117 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.1) #3
  br label %quant_decide.exit707

if.else20.i704:                                   ; preds = %if.else16.i701
  %cmp22.i703 = fcmp ugt float %111, 5.000000e+00
  br i1 %cmp22.i703, label %if.end29.i706, label %if.then23.i705

if.then23.i705:                                   ; preds = %if.else20.i704
  %118 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.1) #3
  br label %quant_decide.exit707

if.end29.i706:                                    ; preds = %if.else20.i704
  %119 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.1) #3
  br label %quant_decide.exit707

quant_decide.exit707:                             ; preds = %if.end29.i706, %if.then23.i705, %if.then19.i702, %if.then15.i699, %if.then11.i696, %if.then7.i693, %if.then3.i690, %if.then.i687
  %out.i372.1 = phi float [ %112, %if.then.i687 ], [ %113, %if.then3.i690 ], [ %114, %if.then7.i693 ], [ %115, %if.then11.i696 ], [ %116, %if.then15.i699 ], [ %117, %if.then19.i702 ], [ %118, %if.then23.i705 ], [ %119, %if.end29.i706 ]
  %mul118.1 = fmul float %cond88, %out.i372.1
  %sub.1 = fsub float %mul118.1, %20
  %mul126.1 = fmul float %div73, %24
  %120 = tail call float @llvm.fabs.f32(float %mul126.1) #3
  %cmp.i664 = fcmp ugt float %120, 2.500000e-01
  br i1 %cmp.i664, label %if.else.i667, label %if.then.i665

if.then.i665:                                     ; preds = %quant_decide.exit707
  %121 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.1) #3
  br label %quant_decide.exit685

if.else.i667:                                     ; preds = %quant_decide.exit707
  %cmp2.i666 = fcmp olt float %120, 7.500000e-01
  br i1 %cmp2.i666, label %if.then3.i668, label %if.else4.i670

if.then3.i668:                                    ; preds = %if.else.i667
  %122 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.1) #3
  br label %quant_decide.exit685

if.else4.i670:                                    ; preds = %if.else.i667
  %cmp6.i669 = fcmp ugt float %120, 1.250000e+00
  br i1 %cmp6.i669, label %if.else8.i673, label %if.then7.i671

if.then7.i671:                                    ; preds = %if.else4.i670
  %123 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.1) #3
  br label %quant_decide.exit685

if.else8.i673:                                    ; preds = %if.else4.i670
  %cmp10.i672 = fcmp olt float %120, 1.750000e+00
  br i1 %cmp10.i672, label %if.then11.i674, label %if.else12.i676

if.then11.i674:                                   ; preds = %if.else8.i673
  %124 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.1) #3
  br label %quant_decide.exit685

if.else12.i676:                                   ; preds = %if.else8.i673
  %cmp14.i675 = fcmp ugt float %120, 2.500000e+00
  br i1 %cmp14.i675, label %if.else16.i679, label %if.then15.i677

if.then15.i677:                                   ; preds = %if.else12.i676
  %125 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.1) #3
  br label %quant_decide.exit685

if.else16.i679:                                   ; preds = %if.else12.i676
  %cmp18.i678 = fcmp olt float %120, 3.500000e+00
  br i1 %cmp18.i678, label %if.then19.i680, label %if.else20.i682

if.then19.i680:                                   ; preds = %if.else16.i679
  %126 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.1) #3
  br label %quant_decide.exit685

if.else20.i682:                                   ; preds = %if.else16.i679
  %cmp22.i681 = fcmp ugt float %120, 5.000000e+00
  br i1 %cmp22.i681, label %if.end29.i684, label %if.then23.i683

if.then23.i683:                                   ; preds = %if.else20.i682
  %127 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.1) #3
  br label %quant_decide.exit685

if.end29.i684:                                    ; preds = %if.else20.i682
  %128 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.1) #3
  br label %quant_decide.exit685

quant_decide.exit685:                             ; preds = %if.end29.i684, %if.then23.i683, %if.then19.i680, %if.then15.i677, %if.then11.i674, %if.then7.i671, %if.then3.i668, %if.then.i665
  %out.i.1 = phi float [ %121, %if.then.i665 ], [ %122, %if.then3.i668 ], [ %123, %if.then7.i671 ], [ %124, %if.then11.i674 ], [ %125, %if.then15.i677 ], [ %126, %if.then19.i680 ], [ %127, %if.then23.i683 ], [ %128, %if.end29.i684 ]
  %mul128.1 = fmul float %cond88, %out.i.1
  %sub132.1 = fsub float %mul128.1, %24
  %mul133.1 = fmul float %sub.1, %sub.1
  %mul134.1 = fmul float %sub132.1, %sub132.1
  %add135.1 = fadd float %mul133.1, %mul134.1
  %e.1.1 = fadd float %e.1, %add135.1
  %mul116.2 = fmul float %div73, %28
  %129 = tail call float @llvm.fabs.f32(float %mul116.2) #3
  %cmp.i642 = fcmp ugt float %129, 2.500000e-01
  br i1 %cmp.i642, label %if.else.i645, label %if.then.i643

if.then.i643:                                     ; preds = %quant_decide.exit685
  %130 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.2) #3
  br label %quant_decide.exit663

if.else.i645:                                     ; preds = %quant_decide.exit685
  %cmp2.i644 = fcmp olt float %129, 7.500000e-01
  br i1 %cmp2.i644, label %if.then3.i646, label %if.else4.i648

if.then3.i646:                                    ; preds = %if.else.i645
  %131 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.2) #3
  br label %quant_decide.exit663

if.else4.i648:                                    ; preds = %if.else.i645
  %cmp6.i647 = fcmp ugt float %129, 1.250000e+00
  br i1 %cmp6.i647, label %if.else8.i651, label %if.then7.i649

if.then7.i649:                                    ; preds = %if.else4.i648
  %132 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.2) #3
  br label %quant_decide.exit663

if.else8.i651:                                    ; preds = %if.else4.i648
  %cmp10.i650 = fcmp olt float %129, 1.750000e+00
  br i1 %cmp10.i650, label %if.then11.i652, label %if.else12.i654

if.then11.i652:                                   ; preds = %if.else8.i651
  %133 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.2) #3
  br label %quant_decide.exit663

if.else12.i654:                                   ; preds = %if.else8.i651
  %cmp14.i653 = fcmp ugt float %129, 2.500000e+00
  br i1 %cmp14.i653, label %if.else16.i657, label %if.then15.i655

if.then15.i655:                                   ; preds = %if.else12.i654
  %134 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.2) #3
  br label %quant_decide.exit663

if.else16.i657:                                   ; preds = %if.else12.i654
  %cmp18.i656 = fcmp olt float %129, 3.500000e+00
  br i1 %cmp18.i656, label %if.then19.i658, label %if.else20.i660

if.then19.i658:                                   ; preds = %if.else16.i657
  %135 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.2) #3
  br label %quant_decide.exit663

if.else20.i660:                                   ; preds = %if.else16.i657
  %cmp22.i659 = fcmp ugt float %129, 5.000000e+00
  br i1 %cmp22.i659, label %if.end29.i662, label %if.then23.i661

if.then23.i661:                                   ; preds = %if.else20.i660
  %136 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.2) #3
  br label %quant_decide.exit663

if.end29.i662:                                    ; preds = %if.else20.i660
  %137 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.2) #3
  br label %quant_decide.exit663

quant_decide.exit663:                             ; preds = %if.end29.i662, %if.then23.i661, %if.then19.i658, %if.then15.i655, %if.then11.i652, %if.then7.i649, %if.then3.i646, %if.then.i643
  %out.i372.2 = phi float [ %130, %if.then.i643 ], [ %131, %if.then3.i646 ], [ %132, %if.then7.i649 ], [ %133, %if.then11.i652 ], [ %134, %if.then15.i655 ], [ %135, %if.then19.i658 ], [ %136, %if.then23.i661 ], [ %137, %if.end29.i662 ]
  %mul118.2 = fmul float %cond88, %out.i372.2
  %sub.2 = fsub float %mul118.2, %28
  %mul126.2 = fmul float %div73, %32
  %138 = tail call float @llvm.fabs.f32(float %mul126.2) #3
  %cmp.i620 = fcmp ugt float %138, 2.500000e-01
  br i1 %cmp.i620, label %if.else.i623, label %if.then.i621

if.then.i621:                                     ; preds = %quant_decide.exit663
  %139 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.2) #3
  br label %quant_decide.exit641

if.else.i623:                                     ; preds = %quant_decide.exit663
  %cmp2.i622 = fcmp olt float %138, 7.500000e-01
  br i1 %cmp2.i622, label %if.then3.i624, label %if.else4.i626

if.then3.i624:                                    ; preds = %if.else.i623
  %140 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.2) #3
  br label %quant_decide.exit641

if.else4.i626:                                    ; preds = %if.else.i623
  %cmp6.i625 = fcmp ugt float %138, 1.250000e+00
  br i1 %cmp6.i625, label %if.else8.i629, label %if.then7.i627

if.then7.i627:                                    ; preds = %if.else4.i626
  %141 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.2) #3
  br label %quant_decide.exit641

if.else8.i629:                                    ; preds = %if.else4.i626
  %cmp10.i628 = fcmp olt float %138, 1.750000e+00
  br i1 %cmp10.i628, label %if.then11.i630, label %if.else12.i632

if.then11.i630:                                   ; preds = %if.else8.i629
  %142 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.2) #3
  br label %quant_decide.exit641

if.else12.i632:                                   ; preds = %if.else8.i629
  %cmp14.i631 = fcmp ugt float %138, 2.500000e+00
  br i1 %cmp14.i631, label %if.else16.i635, label %if.then15.i633

if.then15.i633:                                   ; preds = %if.else12.i632
  %143 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.2) #3
  br label %quant_decide.exit641

if.else16.i635:                                   ; preds = %if.else12.i632
  %cmp18.i634 = fcmp olt float %138, 3.500000e+00
  br i1 %cmp18.i634, label %if.then19.i636, label %if.else20.i638

if.then19.i636:                                   ; preds = %if.else16.i635
  %144 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.2) #3
  br label %quant_decide.exit641

if.else20.i638:                                   ; preds = %if.else16.i635
  %cmp22.i637 = fcmp ugt float %138, 5.000000e+00
  br i1 %cmp22.i637, label %if.end29.i640, label %if.then23.i639

if.then23.i639:                                   ; preds = %if.else20.i638
  %145 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.2) #3
  br label %quant_decide.exit641

if.end29.i640:                                    ; preds = %if.else20.i638
  %146 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.2) #3
  br label %quant_decide.exit641

quant_decide.exit641:                             ; preds = %if.end29.i640, %if.then23.i639, %if.then19.i636, %if.then15.i633, %if.then11.i630, %if.then7.i627, %if.then3.i624, %if.then.i621
  %out.i.2 = phi float [ %139, %if.then.i621 ], [ %140, %if.then3.i624 ], [ %141, %if.then7.i627 ], [ %142, %if.then11.i630 ], [ %143, %if.then15.i633 ], [ %144, %if.then19.i636 ], [ %145, %if.then23.i639 ], [ %146, %if.end29.i640 ]
  %mul128.2 = fmul float %cond88, %out.i.2
  %sub132.2 = fsub float %mul128.2, %32
  %mul133.2 = fmul float %sub.2, %sub.2
  %mul134.2 = fmul float %sub132.2, %sub132.2
  %add135.2 = fadd float %mul133.2, %mul134.2
  %e.1.2 = fadd float %e.1.1, %add135.2
  %mul116.3 = fmul float %div73, %36
  %147 = tail call float @llvm.fabs.f32(float %mul116.3) #3
  %cmp.i598 = fcmp ugt float %147, 2.500000e-01
  br i1 %cmp.i598, label %if.else.i601, label %if.then.i599

if.then.i599:                                     ; preds = %quant_decide.exit641
  %148 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.3) #3
  br label %quant_decide.exit619

if.else.i601:                                     ; preds = %quant_decide.exit641
  %cmp2.i600 = fcmp olt float %147, 7.500000e-01
  br i1 %cmp2.i600, label %if.then3.i602, label %if.else4.i604

if.then3.i602:                                    ; preds = %if.else.i601
  %149 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.3) #3
  br label %quant_decide.exit619

if.else4.i604:                                    ; preds = %if.else.i601
  %cmp6.i603 = fcmp ugt float %147, 1.250000e+00
  br i1 %cmp6.i603, label %if.else8.i607, label %if.then7.i605

if.then7.i605:                                    ; preds = %if.else4.i604
  %150 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.3) #3
  br label %quant_decide.exit619

if.else8.i607:                                    ; preds = %if.else4.i604
  %cmp10.i606 = fcmp olt float %147, 1.750000e+00
  br i1 %cmp10.i606, label %if.then11.i608, label %if.else12.i610

if.then11.i608:                                   ; preds = %if.else8.i607
  %151 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.3) #3
  br label %quant_decide.exit619

if.else12.i610:                                   ; preds = %if.else8.i607
  %cmp14.i609 = fcmp ugt float %147, 2.500000e+00
  br i1 %cmp14.i609, label %if.else16.i613, label %if.then15.i611

if.then15.i611:                                   ; preds = %if.else12.i610
  %152 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.3) #3
  br label %quant_decide.exit619

if.else16.i613:                                   ; preds = %if.else12.i610
  %cmp18.i612 = fcmp olt float %147, 3.500000e+00
  br i1 %cmp18.i612, label %if.then19.i614, label %if.else20.i616

if.then19.i614:                                   ; preds = %if.else16.i613
  %153 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.3) #3
  br label %quant_decide.exit619

if.else20.i616:                                   ; preds = %if.else16.i613
  %cmp22.i615 = fcmp ugt float %147, 5.000000e+00
  br i1 %cmp22.i615, label %if.end29.i618, label %if.then23.i617

if.then23.i617:                                   ; preds = %if.else20.i616
  %154 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.3) #3
  br label %quant_decide.exit619

if.end29.i618:                                    ; preds = %if.else20.i616
  %155 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.3) #3
  br label %quant_decide.exit619

quant_decide.exit619:                             ; preds = %if.end29.i618, %if.then23.i617, %if.then19.i614, %if.then15.i611, %if.then11.i608, %if.then7.i605, %if.then3.i602, %if.then.i599
  %out.i372.3 = phi float [ %148, %if.then.i599 ], [ %149, %if.then3.i602 ], [ %150, %if.then7.i605 ], [ %151, %if.then11.i608 ], [ %152, %if.then15.i611 ], [ %153, %if.then19.i614 ], [ %154, %if.then23.i617 ], [ %155, %if.end29.i618 ]
  %mul118.3 = fmul float %cond88, %out.i372.3
  %sub.3 = fsub float %mul118.3, %36
  %mul126.3 = fmul float %div73, %40
  %156 = tail call float @llvm.fabs.f32(float %mul126.3) #3
  %cmp.i576 = fcmp ugt float %156, 2.500000e-01
  br i1 %cmp.i576, label %if.else.i579, label %if.then.i577

if.then.i577:                                     ; preds = %quant_decide.exit619
  %157 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.3) #3
  br label %quant_decide.exit597

if.else.i579:                                     ; preds = %quant_decide.exit619
  %cmp2.i578 = fcmp olt float %156, 7.500000e-01
  br i1 %cmp2.i578, label %if.then3.i580, label %if.else4.i582

if.then3.i580:                                    ; preds = %if.else.i579
  %158 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.3) #3
  br label %quant_decide.exit597

if.else4.i582:                                    ; preds = %if.else.i579
  %cmp6.i581 = fcmp ugt float %156, 1.250000e+00
  br i1 %cmp6.i581, label %if.else8.i585, label %if.then7.i583

if.then7.i583:                                    ; preds = %if.else4.i582
  %159 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.3) #3
  br label %quant_decide.exit597

if.else8.i585:                                    ; preds = %if.else4.i582
  %cmp10.i584 = fcmp olt float %156, 1.750000e+00
  br i1 %cmp10.i584, label %if.then11.i586, label %if.else12.i588

if.then11.i586:                                   ; preds = %if.else8.i585
  %160 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.3) #3
  br label %quant_decide.exit597

if.else12.i588:                                   ; preds = %if.else8.i585
  %cmp14.i587 = fcmp ugt float %156, 2.500000e+00
  br i1 %cmp14.i587, label %if.else16.i591, label %if.then15.i589

if.then15.i589:                                   ; preds = %if.else12.i588
  %161 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.3) #3
  br label %quant_decide.exit597

if.else16.i591:                                   ; preds = %if.else12.i588
  %cmp18.i590 = fcmp olt float %156, 3.500000e+00
  br i1 %cmp18.i590, label %if.then19.i592, label %if.else20.i594

if.then19.i592:                                   ; preds = %if.else16.i591
  %162 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.3) #3
  br label %quant_decide.exit597

if.else20.i594:                                   ; preds = %if.else16.i591
  %cmp22.i593 = fcmp ugt float %156, 5.000000e+00
  br i1 %cmp22.i593, label %if.end29.i596, label %if.then23.i595

if.then23.i595:                                   ; preds = %if.else20.i594
  %163 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.3) #3
  br label %quant_decide.exit597

if.end29.i596:                                    ; preds = %if.else20.i594
  %164 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.3) #3
  br label %quant_decide.exit597

quant_decide.exit597:                             ; preds = %if.end29.i596, %if.then23.i595, %if.then19.i592, %if.then15.i589, %if.then11.i586, %if.then7.i583, %if.then3.i580, %if.then.i577
  %out.i.3 = phi float [ %157, %if.then.i577 ], [ %158, %if.then3.i580 ], [ %159, %if.then7.i583 ], [ %160, %if.then11.i586 ], [ %161, %if.then15.i589 ], [ %162, %if.then19.i592 ], [ %163, %if.then23.i595 ], [ %164, %if.end29.i596 ]
  %mul128.3 = fmul float %cond88, %out.i.3
  %sub132.3 = fsub float %mul128.3, %40
  %mul133.3 = fmul float %sub.3, %sub.3
  %mul134.3 = fmul float %sub132.3, %sub132.3
  %add135.3 = fadd float %mul133.3, %mul134.3
  %e.1.3 = fadd float %e.1.2, %add135.3
  %mul116.4 = fmul float %div73, %44
  %165 = tail call float @llvm.fabs.f32(float %mul116.4) #3
  %cmp.i554 = fcmp ugt float %165, 2.500000e-01
  br i1 %cmp.i554, label %if.else.i557, label %if.then.i555

if.then.i555:                                     ; preds = %quant_decide.exit597
  %166 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.4) #3
  br label %quant_decide.exit575

if.else.i557:                                     ; preds = %quant_decide.exit597
  %cmp2.i556 = fcmp olt float %165, 7.500000e-01
  br i1 %cmp2.i556, label %if.then3.i558, label %if.else4.i560

if.then3.i558:                                    ; preds = %if.else.i557
  %167 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.4) #3
  br label %quant_decide.exit575

if.else4.i560:                                    ; preds = %if.else.i557
  %cmp6.i559 = fcmp ugt float %165, 1.250000e+00
  br i1 %cmp6.i559, label %if.else8.i563, label %if.then7.i561

if.then7.i561:                                    ; preds = %if.else4.i560
  %168 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.4) #3
  br label %quant_decide.exit575

if.else8.i563:                                    ; preds = %if.else4.i560
  %cmp10.i562 = fcmp olt float %165, 1.750000e+00
  br i1 %cmp10.i562, label %if.then11.i564, label %if.else12.i566

if.then11.i564:                                   ; preds = %if.else8.i563
  %169 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.4) #3
  br label %quant_decide.exit575

if.else12.i566:                                   ; preds = %if.else8.i563
  %cmp14.i565 = fcmp ugt float %165, 2.500000e+00
  br i1 %cmp14.i565, label %if.else16.i569, label %if.then15.i567

if.then15.i567:                                   ; preds = %if.else12.i566
  %170 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.4) #3
  br label %quant_decide.exit575

if.else16.i569:                                   ; preds = %if.else12.i566
  %cmp18.i568 = fcmp olt float %165, 3.500000e+00
  br i1 %cmp18.i568, label %if.then19.i570, label %if.else20.i572

if.then19.i570:                                   ; preds = %if.else16.i569
  %171 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.4) #3
  br label %quant_decide.exit575

if.else20.i572:                                   ; preds = %if.else16.i569
  %cmp22.i571 = fcmp ugt float %165, 5.000000e+00
  br i1 %cmp22.i571, label %if.end29.i574, label %if.then23.i573

if.then23.i573:                                   ; preds = %if.else20.i572
  %172 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.4) #3
  br label %quant_decide.exit575

if.end29.i574:                                    ; preds = %if.else20.i572
  %173 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.4) #3
  br label %quant_decide.exit575

quant_decide.exit575:                             ; preds = %if.end29.i574, %if.then23.i573, %if.then19.i570, %if.then15.i567, %if.then11.i564, %if.then7.i561, %if.then3.i558, %if.then.i555
  %out.i372.4 = phi float [ %166, %if.then.i555 ], [ %167, %if.then3.i558 ], [ %168, %if.then7.i561 ], [ %169, %if.then11.i564 ], [ %170, %if.then15.i567 ], [ %171, %if.then19.i570 ], [ %172, %if.then23.i573 ], [ %173, %if.end29.i574 ]
  %mul118.4 = fmul float %cond88, %out.i372.4
  %sub.4 = fsub float %mul118.4, %44
  %mul126.4 = fmul float %div73, %48
  %174 = tail call float @llvm.fabs.f32(float %mul126.4) #3
  %cmp.i532 = fcmp ugt float %174, 2.500000e-01
  br i1 %cmp.i532, label %if.else.i535, label %if.then.i533

if.then.i533:                                     ; preds = %quant_decide.exit575
  %175 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.4) #3
  br label %quant_decide.exit553

if.else.i535:                                     ; preds = %quant_decide.exit575
  %cmp2.i534 = fcmp olt float %174, 7.500000e-01
  br i1 %cmp2.i534, label %if.then3.i536, label %if.else4.i538

if.then3.i536:                                    ; preds = %if.else.i535
  %176 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.4) #3
  br label %quant_decide.exit553

if.else4.i538:                                    ; preds = %if.else.i535
  %cmp6.i537 = fcmp ugt float %174, 1.250000e+00
  br i1 %cmp6.i537, label %if.else8.i541, label %if.then7.i539

if.then7.i539:                                    ; preds = %if.else4.i538
  %177 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.4) #3
  br label %quant_decide.exit553

if.else8.i541:                                    ; preds = %if.else4.i538
  %cmp10.i540 = fcmp olt float %174, 1.750000e+00
  br i1 %cmp10.i540, label %if.then11.i542, label %if.else12.i544

if.then11.i542:                                   ; preds = %if.else8.i541
  %178 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.4) #3
  br label %quant_decide.exit553

if.else12.i544:                                   ; preds = %if.else8.i541
  %cmp14.i543 = fcmp ugt float %174, 2.500000e+00
  br i1 %cmp14.i543, label %if.else16.i547, label %if.then15.i545

if.then15.i545:                                   ; preds = %if.else12.i544
  %179 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.4) #3
  br label %quant_decide.exit553

if.else16.i547:                                   ; preds = %if.else12.i544
  %cmp18.i546 = fcmp olt float %174, 3.500000e+00
  br i1 %cmp18.i546, label %if.then19.i548, label %if.else20.i550

if.then19.i548:                                   ; preds = %if.else16.i547
  %180 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.4) #3
  br label %quant_decide.exit553

if.else20.i550:                                   ; preds = %if.else16.i547
  %cmp22.i549 = fcmp ugt float %174, 5.000000e+00
  br i1 %cmp22.i549, label %if.end29.i552, label %if.then23.i551

if.then23.i551:                                   ; preds = %if.else20.i550
  %181 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.4) #3
  br label %quant_decide.exit553

if.end29.i552:                                    ; preds = %if.else20.i550
  %182 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.4) #3
  br label %quant_decide.exit553

quant_decide.exit553:                             ; preds = %if.end29.i552, %if.then23.i551, %if.then19.i548, %if.then15.i545, %if.then11.i542, %if.then7.i539, %if.then3.i536, %if.then.i533
  %out.i.4 = phi float [ %175, %if.then.i533 ], [ %176, %if.then3.i536 ], [ %177, %if.then7.i539 ], [ %178, %if.then11.i542 ], [ %179, %if.then15.i545 ], [ %180, %if.then19.i548 ], [ %181, %if.then23.i551 ], [ %182, %if.end29.i552 ]
  %mul128.4 = fmul float %cond88, %out.i.4
  %sub132.4 = fsub float %mul128.4, %48
  %mul133.4 = fmul float %sub.4, %sub.4
  %mul134.4 = fmul float %sub132.4, %sub132.4
  %add135.4 = fadd float %mul133.4, %mul134.4
  %e.1.4 = fadd float %e.1.3, %add135.4
  %mul116.5 = fmul float %div73, %52
  %183 = tail call float @llvm.fabs.f32(float %mul116.5) #3
  %cmp.i510 = fcmp ugt float %183, 2.500000e-01
  br i1 %cmp.i510, label %if.else.i513, label %if.then.i511

if.then.i511:                                     ; preds = %quant_decide.exit553
  %184 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.5) #3
  br label %quant_decide.exit531

if.else.i513:                                     ; preds = %quant_decide.exit553
  %cmp2.i512 = fcmp olt float %183, 7.500000e-01
  br i1 %cmp2.i512, label %if.then3.i514, label %if.else4.i516

if.then3.i514:                                    ; preds = %if.else.i513
  %185 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.5) #3
  br label %quant_decide.exit531

if.else4.i516:                                    ; preds = %if.else.i513
  %cmp6.i515 = fcmp ugt float %183, 1.250000e+00
  br i1 %cmp6.i515, label %if.else8.i519, label %if.then7.i517

if.then7.i517:                                    ; preds = %if.else4.i516
  %186 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.5) #3
  br label %quant_decide.exit531

if.else8.i519:                                    ; preds = %if.else4.i516
  %cmp10.i518 = fcmp olt float %183, 1.750000e+00
  br i1 %cmp10.i518, label %if.then11.i520, label %if.else12.i522

if.then11.i520:                                   ; preds = %if.else8.i519
  %187 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.5) #3
  br label %quant_decide.exit531

if.else12.i522:                                   ; preds = %if.else8.i519
  %cmp14.i521 = fcmp ugt float %183, 2.500000e+00
  br i1 %cmp14.i521, label %if.else16.i525, label %if.then15.i523

if.then15.i523:                                   ; preds = %if.else12.i522
  %188 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.5) #3
  br label %quant_decide.exit531

if.else16.i525:                                   ; preds = %if.else12.i522
  %cmp18.i524 = fcmp olt float %183, 3.500000e+00
  br i1 %cmp18.i524, label %if.then19.i526, label %if.else20.i528

if.then19.i526:                                   ; preds = %if.else16.i525
  %189 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.5) #3
  br label %quant_decide.exit531

if.else20.i528:                                   ; preds = %if.else16.i525
  %cmp22.i527 = fcmp ugt float %183, 5.000000e+00
  br i1 %cmp22.i527, label %if.end29.i530, label %if.then23.i529

if.then23.i529:                                   ; preds = %if.else20.i528
  %190 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.5) #3
  br label %quant_decide.exit531

if.end29.i530:                                    ; preds = %if.else20.i528
  %191 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.5) #3
  br label %quant_decide.exit531

quant_decide.exit531:                             ; preds = %if.end29.i530, %if.then23.i529, %if.then19.i526, %if.then15.i523, %if.then11.i520, %if.then7.i517, %if.then3.i514, %if.then.i511
  %out.i372.5 = phi float [ %184, %if.then.i511 ], [ %185, %if.then3.i514 ], [ %186, %if.then7.i517 ], [ %187, %if.then11.i520 ], [ %188, %if.then15.i523 ], [ %189, %if.then19.i526 ], [ %190, %if.then23.i529 ], [ %191, %if.end29.i530 ]
  %mul118.5 = fmul float %cond88, %out.i372.5
  %sub.5 = fsub float %mul118.5, %52
  %mul126.5 = fmul float %div73, %56
  %192 = tail call float @llvm.fabs.f32(float %mul126.5) #3
  %cmp.i488 = fcmp ugt float %192, 2.500000e-01
  br i1 %cmp.i488, label %if.else.i491, label %if.then.i489

if.then.i489:                                     ; preds = %quant_decide.exit531
  %193 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.5) #3
  br label %quant_decide.exit509

if.else.i491:                                     ; preds = %quant_decide.exit531
  %cmp2.i490 = fcmp olt float %192, 7.500000e-01
  br i1 %cmp2.i490, label %if.then3.i492, label %if.else4.i494

if.then3.i492:                                    ; preds = %if.else.i491
  %194 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.5) #3
  br label %quant_decide.exit509

if.else4.i494:                                    ; preds = %if.else.i491
  %cmp6.i493 = fcmp ugt float %192, 1.250000e+00
  br i1 %cmp6.i493, label %if.else8.i497, label %if.then7.i495

if.then7.i495:                                    ; preds = %if.else4.i494
  %195 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.5) #3
  br label %quant_decide.exit509

if.else8.i497:                                    ; preds = %if.else4.i494
  %cmp10.i496 = fcmp olt float %192, 1.750000e+00
  br i1 %cmp10.i496, label %if.then11.i498, label %if.else12.i500

if.then11.i498:                                   ; preds = %if.else8.i497
  %196 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.5) #3
  br label %quant_decide.exit509

if.else12.i500:                                   ; preds = %if.else8.i497
  %cmp14.i499 = fcmp ugt float %192, 2.500000e+00
  br i1 %cmp14.i499, label %if.else16.i503, label %if.then15.i501

if.then15.i501:                                   ; preds = %if.else12.i500
  %197 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.5) #3
  br label %quant_decide.exit509

if.else16.i503:                                   ; preds = %if.else12.i500
  %cmp18.i502 = fcmp olt float %192, 3.500000e+00
  br i1 %cmp18.i502, label %if.then19.i504, label %if.else20.i506

if.then19.i504:                                   ; preds = %if.else16.i503
  %198 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.5) #3
  br label %quant_decide.exit509

if.else20.i506:                                   ; preds = %if.else16.i503
  %cmp22.i505 = fcmp ugt float %192, 5.000000e+00
  br i1 %cmp22.i505, label %if.end29.i508, label %if.then23.i507

if.then23.i507:                                   ; preds = %if.else20.i506
  %199 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.5) #3
  br label %quant_decide.exit509

if.end29.i508:                                    ; preds = %if.else20.i506
  %200 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.5) #3
  br label %quant_decide.exit509

quant_decide.exit509:                             ; preds = %if.end29.i508, %if.then23.i507, %if.then19.i504, %if.then15.i501, %if.then11.i498, %if.then7.i495, %if.then3.i492, %if.then.i489
  %out.i.5 = phi float [ %193, %if.then.i489 ], [ %194, %if.then3.i492 ], [ %195, %if.then7.i495 ], [ %196, %if.then11.i498 ], [ %197, %if.then15.i501 ], [ %198, %if.then19.i504 ], [ %199, %if.then23.i507 ], [ %200, %if.end29.i508 ]
  %mul128.5 = fmul float %cond88, %out.i.5
  %sub132.5 = fsub float %mul128.5, %56
  %mul133.5 = fmul float %sub.5, %sub.5
  %mul134.5 = fmul float %sub132.5, %sub132.5
  %add135.5 = fadd float %mul133.5, %mul134.5
  %e.1.5 = fadd float %e.1.4, %add135.5
  %mul116.6 = fmul float %div73, %60
  %201 = tail call float @llvm.fabs.f32(float %mul116.6) #3
  %cmp.i466 = fcmp ugt float %201, 2.500000e-01
  br i1 %cmp.i466, label %if.else.i469, label %if.then.i467

if.then.i467:                                     ; preds = %quant_decide.exit509
  %202 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.6) #3
  br label %quant_decide.exit487

if.else.i469:                                     ; preds = %quant_decide.exit509
  %cmp2.i468 = fcmp olt float %201, 7.500000e-01
  br i1 %cmp2.i468, label %if.then3.i470, label %if.else4.i472

if.then3.i470:                                    ; preds = %if.else.i469
  %203 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.6) #3
  br label %quant_decide.exit487

if.else4.i472:                                    ; preds = %if.else.i469
  %cmp6.i471 = fcmp ugt float %201, 1.250000e+00
  br i1 %cmp6.i471, label %if.else8.i475, label %if.then7.i473

if.then7.i473:                                    ; preds = %if.else4.i472
  %204 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.6) #3
  br label %quant_decide.exit487

if.else8.i475:                                    ; preds = %if.else4.i472
  %cmp10.i474 = fcmp olt float %201, 1.750000e+00
  br i1 %cmp10.i474, label %if.then11.i476, label %if.else12.i478

if.then11.i476:                                   ; preds = %if.else8.i475
  %205 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.6) #3
  br label %quant_decide.exit487

if.else12.i478:                                   ; preds = %if.else8.i475
  %cmp14.i477 = fcmp ugt float %201, 2.500000e+00
  br i1 %cmp14.i477, label %if.else16.i481, label %if.then15.i479

if.then15.i479:                                   ; preds = %if.else12.i478
  %206 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.6) #3
  br label %quant_decide.exit487

if.else16.i481:                                   ; preds = %if.else12.i478
  %cmp18.i480 = fcmp olt float %201, 3.500000e+00
  br i1 %cmp18.i480, label %if.then19.i482, label %if.else20.i484

if.then19.i482:                                   ; preds = %if.else16.i481
  %207 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.6) #3
  br label %quant_decide.exit487

if.else20.i484:                                   ; preds = %if.else16.i481
  %cmp22.i483 = fcmp ugt float %201, 5.000000e+00
  br i1 %cmp22.i483, label %if.end29.i486, label %if.then23.i485

if.then23.i485:                                   ; preds = %if.else20.i484
  %208 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.6) #3
  br label %quant_decide.exit487

if.end29.i486:                                    ; preds = %if.else20.i484
  %209 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.6) #3
  br label %quant_decide.exit487

quant_decide.exit487:                             ; preds = %if.end29.i486, %if.then23.i485, %if.then19.i482, %if.then15.i479, %if.then11.i476, %if.then7.i473, %if.then3.i470, %if.then.i467
  %out.i372.6 = phi float [ %202, %if.then.i467 ], [ %203, %if.then3.i470 ], [ %204, %if.then7.i473 ], [ %205, %if.then11.i476 ], [ %206, %if.then15.i479 ], [ %207, %if.then19.i482 ], [ %208, %if.then23.i485 ], [ %209, %if.end29.i486 ]
  %mul118.6 = fmul float %cond88, %out.i372.6
  %sub.6 = fsub float %mul118.6, %60
  %mul126.6 = fmul float %div73, %64
  %210 = tail call float @llvm.fabs.f32(float %mul126.6) #3
  %cmp.i444 = fcmp ugt float %210, 2.500000e-01
  br i1 %cmp.i444, label %if.else.i447, label %if.then.i445

if.then.i445:                                     ; preds = %quant_decide.exit487
  %211 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.6) #3
  br label %quant_decide.exit465

if.else.i447:                                     ; preds = %quant_decide.exit487
  %cmp2.i446 = fcmp olt float %210, 7.500000e-01
  br i1 %cmp2.i446, label %if.then3.i448, label %if.else4.i450

if.then3.i448:                                    ; preds = %if.else.i447
  %212 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.6) #3
  br label %quant_decide.exit465

if.else4.i450:                                    ; preds = %if.else.i447
  %cmp6.i449 = fcmp ugt float %210, 1.250000e+00
  br i1 %cmp6.i449, label %if.else8.i453, label %if.then7.i451

if.then7.i451:                                    ; preds = %if.else4.i450
  %213 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.6) #3
  br label %quant_decide.exit465

if.else8.i453:                                    ; preds = %if.else4.i450
  %cmp10.i452 = fcmp olt float %210, 1.750000e+00
  br i1 %cmp10.i452, label %if.then11.i454, label %if.else12.i456

if.then11.i454:                                   ; preds = %if.else8.i453
  %214 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.6) #3
  br label %quant_decide.exit465

if.else12.i456:                                   ; preds = %if.else8.i453
  %cmp14.i455 = fcmp ugt float %210, 2.500000e+00
  br i1 %cmp14.i455, label %if.else16.i459, label %if.then15.i457

if.then15.i457:                                   ; preds = %if.else12.i456
  %215 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.6) #3
  br label %quant_decide.exit465

if.else16.i459:                                   ; preds = %if.else12.i456
  %cmp18.i458 = fcmp olt float %210, 3.500000e+00
  br i1 %cmp18.i458, label %if.then19.i460, label %if.else20.i462

if.then19.i460:                                   ; preds = %if.else16.i459
  %216 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.6) #3
  br label %quant_decide.exit465

if.else20.i462:                                   ; preds = %if.else16.i459
  %cmp22.i461 = fcmp ugt float %210, 5.000000e+00
  br i1 %cmp22.i461, label %if.end29.i464, label %if.then23.i463

if.then23.i463:                                   ; preds = %if.else20.i462
  %217 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.6) #3
  br label %quant_decide.exit465

if.end29.i464:                                    ; preds = %if.else20.i462
  %218 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.6) #3
  br label %quant_decide.exit465

quant_decide.exit465:                             ; preds = %if.end29.i464, %if.then23.i463, %if.then19.i460, %if.then15.i457, %if.then11.i454, %if.then7.i451, %if.then3.i448, %if.then.i445
  %out.i.6 = phi float [ %211, %if.then.i445 ], [ %212, %if.then3.i448 ], [ %213, %if.then7.i451 ], [ %214, %if.then11.i454 ], [ %215, %if.then15.i457 ], [ %216, %if.then19.i460 ], [ %217, %if.then23.i463 ], [ %218, %if.end29.i464 ]
  %mul128.6 = fmul float %cond88, %out.i.6
  %sub132.6 = fsub float %mul128.6, %64
  %mul133.6 = fmul float %sub.6, %sub.6
  %mul134.6 = fmul float %sub132.6, %sub132.6
  %add135.6 = fadd float %mul133.6, %mul134.6
  %e.1.6 = fadd float %e.1.5, %add135.6
  %mul116.7 = fmul float %74, %div73
  %219 = tail call float @llvm.fabs.f32(float %mul116.7) #3
  %cmp.i422 = fcmp ugt float %219, 2.500000e-01
  br i1 %cmp.i422, label %if.else.i425, label %if.then.i423

if.then.i423:                                     ; preds = %quant_decide.exit465
  %220 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.7) #3
  br label %quant_decide.exit443

if.else.i425:                                     ; preds = %quant_decide.exit465
  %cmp2.i424 = fcmp olt float %219, 7.500000e-01
  br i1 %cmp2.i424, label %if.then3.i426, label %if.else4.i428

if.then3.i426:                                    ; preds = %if.else.i425
  %221 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.7) #3
  br label %quant_decide.exit443

if.else4.i428:                                    ; preds = %if.else.i425
  %cmp6.i427 = fcmp ugt float %219, 1.250000e+00
  br i1 %cmp6.i427, label %if.else8.i431, label %if.then7.i429

if.then7.i429:                                    ; preds = %if.else4.i428
  %222 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.7) #3
  br label %quant_decide.exit443

if.else8.i431:                                    ; preds = %if.else4.i428
  %cmp10.i430 = fcmp olt float %219, 1.750000e+00
  br i1 %cmp10.i430, label %if.then11.i432, label %if.else12.i434

if.then11.i432:                                   ; preds = %if.else8.i431
  %223 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.7) #3
  br label %quant_decide.exit443

if.else12.i434:                                   ; preds = %if.else8.i431
  %cmp14.i433 = fcmp ugt float %219, 2.500000e+00
  br i1 %cmp14.i433, label %if.else16.i437, label %if.then15.i435

if.then15.i435:                                   ; preds = %if.else12.i434
  %224 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.7) #3
  br label %quant_decide.exit443

if.else16.i437:                                   ; preds = %if.else12.i434
  %cmp18.i436 = fcmp olt float %219, 3.500000e+00
  br i1 %cmp18.i436, label %if.then19.i438, label %if.else20.i440

if.then19.i438:                                   ; preds = %if.else16.i437
  %225 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.7) #3
  br label %quant_decide.exit443

if.else20.i440:                                   ; preds = %if.else16.i437
  %cmp22.i439 = fcmp ugt float %219, 5.000000e+00
  br i1 %cmp22.i439, label %if.end29.i442, label %if.then23.i441

if.then23.i441:                                   ; preds = %if.else20.i440
  %226 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.7) #3
  br label %quant_decide.exit443

if.end29.i442:                                    ; preds = %if.else20.i440
  %227 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.7) #3
  br label %quant_decide.exit443

quant_decide.exit443:                             ; preds = %if.end29.i442, %if.then23.i441, %if.then19.i438, %if.then15.i435, %if.then11.i432, %if.then7.i429, %if.then3.i426, %if.then.i423
  %out.i372.7 = phi float [ %220, %if.then.i423 ], [ %221, %if.then3.i426 ], [ %222, %if.then7.i429 ], [ %223, %if.then11.i432 ], [ %224, %if.then15.i435 ], [ %225, %if.then19.i438 ], [ %226, %if.then23.i441 ], [ %227, %if.end29.i442 ]
  %mul118.7 = fmul float %cond88, %out.i372.7
  %sub.7 = fsub float %mul118.7, %74
  %mul126.7 = fmul float %77, %div73
  %228 = tail call float @llvm.fabs.f32(float %mul126.7) #3
  %cmp.i400 = fcmp ugt float %228, 2.500000e-01
  br i1 %cmp.i400, label %if.else.i403, label %if.then.i401

if.then.i401:                                     ; preds = %quant_decide.exit443
  %229 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.7) #3
  br label %quant_decide.exit421

if.else.i403:                                     ; preds = %quant_decide.exit443
  %cmp2.i402 = fcmp olt float %228, 7.500000e-01
  br i1 %cmp2.i402, label %if.then3.i404, label %if.else4.i406

if.then3.i404:                                    ; preds = %if.else.i403
  %230 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.7) #3
  br label %quant_decide.exit421

if.else4.i406:                                    ; preds = %if.else.i403
  %cmp6.i405 = fcmp ugt float %228, 1.250000e+00
  br i1 %cmp6.i405, label %if.else8.i409, label %if.then7.i407

if.then7.i407:                                    ; preds = %if.else4.i406
  %231 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.7) #3
  br label %quant_decide.exit421

if.else8.i409:                                    ; preds = %if.else4.i406
  %cmp10.i408 = fcmp olt float %228, 1.750000e+00
  br i1 %cmp10.i408, label %if.then11.i410, label %if.else12.i412

if.then11.i410:                                   ; preds = %if.else8.i409
  %232 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.7) #3
  br label %quant_decide.exit421

if.else12.i412:                                   ; preds = %if.else8.i409
  %cmp14.i411 = fcmp ugt float %228, 2.500000e+00
  br i1 %cmp14.i411, label %if.else16.i415, label %if.then15.i413

if.then15.i413:                                   ; preds = %if.else12.i412
  %233 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.7) #3
  br label %quant_decide.exit421

if.else16.i415:                                   ; preds = %if.else12.i412
  %cmp18.i414 = fcmp olt float %228, 3.500000e+00
  br i1 %cmp18.i414, label %if.then19.i416, label %if.else20.i418

if.then19.i416:                                   ; preds = %if.else16.i415
  %234 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.7) #3
  br label %quant_decide.exit421

if.else20.i418:                                   ; preds = %if.else16.i415
  %cmp22.i417 = fcmp ugt float %228, 5.000000e+00
  br i1 %cmp22.i417, label %if.end29.i420, label %if.then23.i419

if.then23.i419:                                   ; preds = %if.else20.i418
  %235 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.7) #3
  br label %quant_decide.exit421

if.end29.i420:                                    ; preds = %if.else20.i418
  %236 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.7) #3
  br label %quant_decide.exit421

quant_decide.exit421:                             ; preds = %if.end29.i420, %if.then23.i419, %if.then19.i416, %if.then15.i413, %if.then11.i410, %if.then7.i407, %if.then3.i404, %if.then.i401
  %out.i.7 = phi float [ %229, %if.then.i401 ], [ %230, %if.then3.i404 ], [ %231, %if.then7.i407 ], [ %232, %if.then11.i410 ], [ %233, %if.then15.i413 ], [ %234, %if.then19.i416 ], [ %235, %if.then23.i419 ], [ %236, %if.end29.i420 ]
  %mul128.7 = fmul float %cond88, %out.i.7
  %sub132.7 = fsub float %mul128.7, %77
  %mul133.7 = fmul float %sub.7, %sub.7
  %mul134.7 = fmul float %sub132.7, %sub132.7
  br label %for.inc138.7

if.then97.7:                                      ; preds = %cond.end75, %cond.end75.thread
  %os.sroa.0.3 = phi <2 x float> [ %83, %cond.end75.thread ], [ %84, %cond.end75 ]
  %mul102 = fmul float %12, %12
  %mul109 = fmul float %16, %16
  %add110 = fadd float %mul102, %mul109
  %e.1478 = fadd float %add110, 0.000000e+00
  %mul102.1 = fmul float %20, %20
  %mul109.1 = fmul float %24, %24
  %add110.1 = fadd float %mul102.1, %mul109.1
  %e.1.1490 = fadd float %e.1478, %add110.1
  %mul102.2 = fmul float %28, %28
  %mul109.2 = fmul float %32, %32
  %add110.2 = fadd float %mul102.2, %mul109.2
  %e.1.2502 = fadd float %e.1.1490, %add110.2
  %mul102.3 = fmul float %36, %36
  %mul109.3 = fmul float %40, %40
  %add110.3 = fadd float %mul102.3, %mul109.3
  %e.1.3514 = fadd float %e.1.2502, %add110.3
  %mul102.4 = fmul float %44, %44
  %mul109.4 = fmul float %48, %48
  %add110.4 = fadd float %mul102.4, %mul109.4
  %e.1.4526 = fadd float %e.1.3514, %add110.4
  %mul102.5 = fmul float %52, %52
  %mul109.5 = fmul float %56, %56
  %add110.5 = fadd float %mul102.5, %mul109.5
  %e.1.5538 = fadd float %e.1.4526, %add110.5
  %mul102.6 = fmul float %60, %60
  %mul109.6 = fmul float %64, %64
  %add110.6 = fadd float %mul102.6, %mul109.6
  %e.1.6550 = fadd float %e.1.5538, %add110.6
  %mul102.7 = fmul float %74, %74
  %mul109.7 = fmul float %77, %77
  br label %for.inc138.7

for.inc138.7:                                     ; preds = %if.then97.7, %quant_decide.exit421
  %os.sroa.0.4 = phi <2 x float> [ %84, %quant_decide.exit421 ], [ %os.sroa.0.3, %if.then97.7 ]
  %mul109.7.sink = phi float [ %mul134.7, %quant_decide.exit421 ], [ %mul109.7, %if.then97.7 ]
  %mul102.7.sink = phi float [ %mul133.7, %quant_decide.exit421 ], [ %mul102.7, %if.then97.7 ]
  %e.1.6551 = phi float [ %e.1.6, %quant_decide.exit421 ], [ %e.1.6550, %if.then97.7 ]
  %add110.7 = fadd float %mul109.7.sink, %mul102.7.sink
  %e.1.7 = fadd float %e.1.6551, %add110.7
  %mul60.1 = fmul float %79, 2.500000e-01
  %mul61.1 = fmul float %cond29, %mul60.1
  %cmp.i379.1 = fcmp ult float %mul61.1, 4.480000e+02
  br i1 %cmp.i379.1, label %_Z4dec8i.exit.i.2.1, label %_Z4enc8f.exit.thread396.1

_Z4enc8f.exit.thread396.1:                        ; preds = %for.inc138.7
  store i8 126, i8 addrspace(5)* %arrayidx64340398.1, align 1, !tbaa !12
  br label %cond.true.i.1

_Z4dec8i.exit.i.2.1:                              ; preds = %for.inc138.7
  %cmp2.i.1424 = fcmp ogt float %mul61.1, 1.875000e+00
  %hi.1.i.1425 = select i1 %cmp2.i.1424, i32 126, i32 63
  %lo.1.i.1426 = select i1 %cmp2.i.1424, i32 64, i32 0
  %div.i.1.1 = select i1 %cmp2.i.1424, i32 95, i32 31
  %237 = lshr i32 %div.i.1.1, 3
  %sub.i.i.1.1 = add nsw i32 %237, -7
  %238 = tail call float @llvm.amdgcn.ldexp.f32(float 1.875000e+00, i32 %sub.i.i.1.1) #3
  %cmp2.i.1.1 = fcmp olt float %238, %mul61.1
  %add4.i.1.1 = add nuw nsw i32 %div.i.1.1, 1
  %hi.1.i.1.1 = select i1 %cmp2.i.1.1, i32 %hi.1.i.1425, i32 %div.i.1.1
  %lo.1.i.1.1 = select i1 %cmp2.i.1.1, i32 %add4.i.1.1, i32 %lo.1.i.1426
  %add.i381.2.1 = add nuw nsw i32 %lo.1.i.1.1, %hi.1.i.1.1
  %div.i.2.1 = lshr i32 %add.i381.2.1, 1
  %239 = lshr i32 %add.i381.2.1, 4
  %sub.i.i.2.1 = add nsw i32 %239, -7
  %240 = tail call float @llvm.amdgcn.ldexp.f32(float 1.875000e+00, i32 %sub.i.i.2.1) #3
  %cmp2.i.2.1 = fcmp olt float %240, %mul61.1
  %add4.i.2.1 = add nuw nsw i32 %div.i.2.1, 1
  %hi.1.i.2.1 = select i1 %cmp2.i.2.1, i32 %hi.1.i.1.1, i32 %div.i.2.1
  %lo.1.i.2.1 = select i1 %cmp2.i.2.1, i32 %add4.i.2.1, i32 %lo.1.i.1.1
  %add.i381.3.1 = add nuw nsw i32 %lo.1.i.2.1, %hi.1.i.2.1
  %div.i.3.1 = lshr i32 %add.i381.3.1, 1
  %241 = lshr i32 %add.i381.3.1, 4
  %and.i.i.3.1 = and i32 %div.i.3.1, 7
  %tobool.not.i.i.3.1 = icmp eq i32 %241, 0
  %conv1.i.i.3.1 = sitofp i32 %and.i.i.3.1 to float
  br i1 %tobool.not.i.i.3.1, label %cond.false.i.i.3.1, label %cond.true.i.i.3.1

cond.true.i.i.3.1:                                ; preds = %_Z4dec8i.exit.i.2.1
  %mul.i.i.3.1 = fmul float %conv1.i.i.3.1, 1.250000e-01
  %add.i.i.3.1 = fadd float %mul.i.i.3.1, 1.000000e+00
  %sub.i.i.3.1 = add nsw i32 %241, -7
  %242 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i.i.3.1, i32 %sub.i.i.3.1) #3
  br label %_Z4dec8i.exit.i.3.1

cond.false.i.i.3.1:                               ; preds = %_Z4dec8i.exit.i.2.1
  %mul2.i.i.3.1 = fmul float %conv1.i.i.3.1, 0x3F60000000000000
  br label %_Z4dec8i.exit.i.3.1

_Z4dec8i.exit.i.3.1:                              ; preds = %cond.false.i.i.3.1, %cond.true.i.i.3.1
  %cond.i.i.3.1 = phi float [ %242, %cond.true.i.i.3.1 ], [ %mul2.i.i.3.1, %cond.false.i.i.3.1 ]
  %cmp2.i.3.1 = fcmp olt float %cond.i.i.3.1, %mul61.1
  %add4.i.3.1 = add nuw nsw i32 %div.i.3.1, 1
  %hi.1.i.3.1 = select i1 %cmp2.i.3.1, i32 %hi.1.i.2.1, i32 %div.i.3.1
  %lo.1.i.3.1 = select i1 %cmp2.i.3.1, i32 %add4.i.3.1, i32 %lo.1.i.2.1
  %add.i381.4.1 = add nuw nsw i32 %lo.1.i.3.1, %hi.1.i.3.1
  %div.i.4.1 = lshr i32 %add.i381.4.1, 1
  %243 = lshr i32 %add.i381.4.1, 4
  %and.i.i.4.1 = and i32 %div.i.4.1, 7
  %tobool.not.i.i.4.1 = icmp eq i32 %243, 0
  %conv1.i.i.4.1 = sitofp i32 %and.i.i.4.1 to float
  br i1 %tobool.not.i.i.4.1, label %cond.false.i.i.4.1, label %cond.true.i.i.4.1

cond.true.i.i.4.1:                                ; preds = %_Z4dec8i.exit.i.3.1
  %mul.i.i.4.1 = fmul float %conv1.i.i.4.1, 1.250000e-01
  %add.i.i.4.1 = fadd float %mul.i.i.4.1, 1.000000e+00
  %sub.i.i.4.1 = add nsw i32 %243, -7
  %244 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i.i.4.1, i32 %sub.i.i.4.1) #3
  br label %_Z4dec8i.exit.i.4.1

cond.false.i.i.4.1:                               ; preds = %_Z4dec8i.exit.i.3.1
  %mul2.i.i.4.1 = fmul float %conv1.i.i.4.1, 0x3F60000000000000
  br label %_Z4dec8i.exit.i.4.1

_Z4dec8i.exit.i.4.1:                              ; preds = %cond.false.i.i.4.1, %cond.true.i.i.4.1
  %cond.i.i.4.1 = phi float [ %244, %cond.true.i.i.4.1 ], [ %mul2.i.i.4.1, %cond.false.i.i.4.1 ]
  %cmp2.i.4.1 = fcmp olt float %cond.i.i.4.1, %mul61.1
  %add4.i.4.1 = add nuw nsw i32 %div.i.4.1, 1
  %hi.1.i.4.1 = select i1 %cmp2.i.4.1, i32 %hi.1.i.3.1, i32 %div.i.4.1
  %lo.1.i.4.1 = select i1 %cmp2.i.4.1, i32 %add4.i.4.1, i32 %lo.1.i.3.1
  %add.i381.5.1 = add nuw nsw i32 %lo.1.i.4.1, %hi.1.i.4.1
  %div.i.5.1 = sdiv i32 %add.i381.5.1, 2
  %shr.i.i.5.1 = ashr i32 %div.i.5.1, 3
  %and.i.i.5.1 = and i32 %div.i.5.1, 7
  %tobool.not.i.i.5.1 = icmp eq i32 %shr.i.i.5.1, 0
  %conv1.i.i.5.1 = sitofp i32 %and.i.i.5.1 to float
  br i1 %tobool.not.i.i.5.1, label %cond.false.i.i.5.1, label %cond.true.i.i.5.1

cond.true.i.i.5.1:                                ; preds = %_Z4dec8i.exit.i.4.1
  %mul.i.i.5.1 = fmul float %conv1.i.i.5.1, 1.250000e-01
  %add.i.i.5.1 = fadd float %mul.i.i.5.1, 1.000000e+00
  %sub.i.i.5.1 = add nsw i32 %shr.i.i.5.1, -7
  %245 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i.i.5.1, i32 %sub.i.i.5.1) #3
  br label %_Z4dec8i.exit.i.5.1

cond.false.i.i.5.1:                               ; preds = %_Z4dec8i.exit.i.4.1
  %mul2.i.i.5.1 = fmul float %conv1.i.i.5.1, 0x3F60000000000000
  br label %_Z4dec8i.exit.i.5.1

_Z4dec8i.exit.i.5.1:                              ; preds = %cond.false.i.i.5.1, %cond.true.i.i.5.1
  %cond.i.i.5.1 = phi float [ %245, %cond.true.i.i.5.1 ], [ %mul2.i.i.5.1, %cond.false.i.i.5.1 ]
  %cmp2.i.5.1 = fcmp olt float %cond.i.i.5.1, %mul61.1
  %add4.i.5.1 = add nuw nsw i32 %div.i.5.1, 1
  %hi.1.i.5.1 = select i1 %cmp2.i.5.1, i32 %hi.1.i.4.1, i32 %div.i.5.1
  %lo.1.i.5.1 = select i1 %cmp2.i.5.1, i32 %add4.i.5.1, i32 %lo.1.i.4.1
  %add.i381.6.1 = add nuw nsw i32 %lo.1.i.5.1, %hi.1.i.5.1
  %div.i.6.1 = sdiv i32 %add.i381.6.1, 2
  %shr.i.i.6.1 = ashr i32 %div.i.6.1, 3
  %and.i.i.6.1 = and i32 %div.i.6.1, 7
  %tobool.not.i.i.6.1 = icmp eq i32 %shr.i.i.6.1, 0
  %conv1.i.i.6.1 = sitofp i32 %and.i.i.6.1 to float
  br i1 %tobool.not.i.i.6.1, label %cond.false.i.i.6.1, label %cond.true.i.i.6.1

cond.true.i.i.6.1:                                ; preds = %_Z4dec8i.exit.i.5.1
  %mul.i.i.6.1 = fmul float %conv1.i.i.6.1, 1.250000e-01
  %add.i.i.6.1 = fadd float %mul.i.i.6.1, 1.000000e+00
  %sub.i.i.6.1 = add nsw i32 %shr.i.i.6.1, -7
  %246 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i.i.6.1, i32 %sub.i.i.6.1) #3
  br label %_Z4dec8i.exit.i.6.1

cond.false.i.i.6.1:                               ; preds = %_Z4dec8i.exit.i.5.1
  %mul2.i.i.6.1 = fmul float %conv1.i.i.6.1, 0x3F60000000000000
  br label %_Z4dec8i.exit.i.6.1

_Z4dec8i.exit.i.6.1:                              ; preds = %cond.false.i.i.6.1, %cond.true.i.i.6.1
  %cond.i.i.6.1 = phi float [ %246, %cond.true.i.i.6.1 ], [ %mul2.i.i.6.1, %cond.false.i.i.6.1 ]
  %cmp2.i.6.1 = fcmp olt float %cond.i.i.6.1, %mul61.1
  %add4.i.6.1 = add nuw nsw i32 %div.i.6.1, 1
  %lo.1.i.6.1 = select i1 %cmp2.i.6.1, i32 %add4.i.6.1, i32 %lo.1.i.5.1
  %cmp6.i.1 = icmp eq i32 %lo.1.i.6.1, 0
  br i1 %cmp6.i.1, label %_Z4enc8f.exit.thread.1, label %if.end9.i.1

if.end9.i.1:                                      ; preds = %_Z4dec8i.exit.i.6.1
  %sub.i382.1 = add nsw i32 %lo.1.i.6.1, -1
  %shr.i62.i.1 = ashr i32 %sub.i382.1, 3
  %and.i63.i.1 = and i32 %sub.i382.1, 7
  %tobool.not.i64.i.1 = icmp eq i32 %shr.i62.i.1, 0
  %conv1.i70.i.1 = sitofp i32 %and.i63.i.1 to float
  br i1 %tobool.not.i64.i.1, label %cond.false.i72.i.1, label %cond.true.i69.i.1

cond.true.i69.i.1:                                ; preds = %if.end9.i.1
  %mul.i66.i.1 = fmul float %conv1.i70.i.1, 1.250000e-01
  %add.i67.i.1 = fadd float %mul.i66.i.1, 1.000000e+00
  %sub.i68.i.1 = add nsw i32 %shr.i62.i.1, -7
  %247 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i67.i.1, i32 %sub.i68.i.1) #3
  br label %_Z4dec8i.exit74.i.1

cond.false.i72.i.1:                               ; preds = %if.end9.i.1
  %mul2.i71.i.1 = fmul float %conv1.i70.i.1, 0x3F60000000000000
  br label %_Z4dec8i.exit74.i.1

_Z4dec8i.exit74.i.1:                              ; preds = %cond.false.i72.i.1, %cond.true.i69.i.1
  %cond.i73.i.1 = phi float [ %247, %cond.true.i69.i.1 ], [ %mul2.i71.i.1, %cond.false.i72.i.1 ]
  %sub11.i.1 = fsub float %mul61.1, %cond.i73.i.1
  %shr.i49.i.1656 = lshr i32 %lo.1.i.6.1, 3
  %and.i50.i.1 = and i32 %lo.1.i.6.1, 7
  %tobool.not.i51.i.1 = icmp eq i32 %shr.i49.i.1656, 0
  %conv1.i57.i.1 = sitofp i32 %and.i50.i.1 to float
  br i1 %tobool.not.i51.i.1, label %cond.false.i59.i.1, label %cond.true.i56.i.1

cond.true.i56.i.1:                                ; preds = %_Z4dec8i.exit74.i.1
  %mul.i53.i.1 = fmul float %conv1.i57.i.1, 1.250000e-01
  %add.i54.i.1 = fadd float %mul.i53.i.1, 1.000000e+00
  %sub.i55.i.1 = add nsw i32 %shr.i49.i.1656, -7
  %248 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i54.i.1, i32 %sub.i55.i.1) #3
  br label %_Z4dec8i.exit61.i.1

cond.false.i59.i.1:                               ; preds = %_Z4dec8i.exit74.i.1
  %mul2.i58.i.1 = fmul float %conv1.i57.i.1, 0x3F60000000000000
  br label %_Z4dec8i.exit61.i.1

_Z4dec8i.exit61.i.1:                              ; preds = %cond.false.i59.i.1, %cond.true.i56.i.1
  %cond.i60.i.1 = phi float [ %248, %cond.true.i56.i.1 ], [ %mul2.i58.i.1, %cond.false.i59.i.1 ]
  %sub13.i.1 = fsub float %cond.i60.i.1, %mul61.1
  %cmp14.i.1 = fcmp olt float %sub11.i.1, %sub13.i.1
  br i1 %cmp14.i.1, label %_Z4enc8f.exit.1, label %cond.false.i384.1

cond.false.i384.1:                                ; preds = %_Z4dec8i.exit61.i.1
  %cmp16.i383.1 = fcmp olt float %sub13.i.1, %sub11.i.1
  %and.i385.1 = and i32 %lo.1.i.6.1, 1
  %tobool.not.i386.1 = icmp eq i32 %and.i385.1, 0
  %cond.i387.1 = select i1 %tobool.not.i386.1, i32 %lo.1.i.6.1, i32 %sub.i382.1
  br i1 %cmp16.i383.1, label %_Z4enc8f.exit.1, label %cond.false18.i.1

cond.false18.i.1:                                 ; preds = %cond.false.i384.1
  %.pre = and i32 %cond.i387.1, 7
  br label %_Z4enc8f.exit.1

_Z4enc8f.exit.1:                                  ; preds = %cond.false18.i.1, %cond.false.i384.1, %_Z4dec8i.exit61.i.1
  %and.i375.1.pre-phi = phi i32 [ %and.i63.i.1, %_Z4dec8i.exit61.i.1 ], [ %and.i50.i.1, %cond.false.i384.1 ], [ %.pre, %cond.false18.i.1 ]
  %cond25.i.1 = phi i32 [ %sub.i382.1, %_Z4dec8i.exit61.i.1 ], [ %lo.1.i.6.1, %cond.false.i384.1 ], [ %cond.i387.1, %cond.false18.i.1 ]
  %conv.i388.1 = trunc i32 %cond25.i.1 to i8
  store i8 %conv.i388.1, i8 addrspace(5)* %arrayidx64340398.1, align 1, !tbaa !12
  %conv67.1 = lshr i32 %cond25.i.1, 3
  %tobool.not.i.1 = icmp eq i32 %conv67.1, 0
  br i1 %tobool.not.i.1, label %cond.false.i377.1, label %cond.true.i.1

cond.true.i.1:                                    ; preds = %_Z4enc8f.exit.1, %_Z4enc8f.exit.thread396.1
  %and.i375404.1 = phi i32 [ 6, %_Z4enc8f.exit.thread396.1 ], [ %and.i375.1.pre-phi, %_Z4enc8f.exit.1 ]
  %shr.i374403.1 = phi i32 [ 15, %_Z4enc8f.exit.thread396.1 ], [ %conv67.1, %_Z4enc8f.exit.1 ]
  %conv.i376.1 = sitofp i32 %and.i375404.1 to float
  %mul.i.1 = fmul float %conv.i376.1, 1.250000e-01
  %add.i.1 = fadd float %mul.i.1, 1.000000e+00
  %sub.i.1 = add nsw i32 %shr.i374403.1, -7
  %249 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i.1, i32 %sub.i.1) #3
  br label %_Z4dec8i.exit.1

_Z4enc8f.exit.thread.1:                           ; preds = %_Z4dec8i.exit.i.6.1
  store i8 0, i8 addrspace(5)* %arrayidx64340398.1, align 1, !tbaa !12
  br label %cond.false.i377.1

cond.false.i377.1:                                ; preds = %_Z4enc8f.exit.thread.1, %_Z4enc8f.exit.1
  %and.i375395.1 = phi i32 [ %and.i375.1.pre-phi, %_Z4enc8f.exit.1 ], [ 0, %_Z4enc8f.exit.thread.1 ]
  %conv1.i.1 = sitofp i32 %and.i375395.1 to float
  %mul2.i.1 = fmul float %conv1.i.1, 0x3F60000000000000
  br label %_Z4dec8i.exit.1

_Z4dec8i.exit.1:                                  ; preds = %cond.false.i377.1, %cond.true.i.1
  %cond.i378.1 = phi float [ %249, %cond.true.i.1 ], [ %mul2.i.1, %cond.false.i377.1 ]
  %cmp69.1 = fcmp une float %cond.i378.1, 0.000000e+00
  br i1 %cmp69.1, label %cond.end75.1, label %cond.end75.1.thread

cond.end75.1.thread:                              ; preds = %_Z4dec8i.exit.1
  %250 = insertelement <2 x float> %os.sroa.0.4, float 0.000000e+00, i32 1
  br label %if.then97.7.1

cond.end75.1:                                     ; preds = %_Z4dec8i.exit.1
  %mul72.1 = fmul float %div71, %cond.i378.1
  %div73.1 = fdiv float 1.000000e+00, %mul72.1
  %251 = insertelement <2 x float> %os.sroa.0.4, float %div73.1, i32 1
  %cmp81.1 = fcmp une float %div73.1, 0.000000e+00
  %div85.1 = fdiv float 1.000000e+00, %div73.1
  %cond88.1 = select i1 %cmp81.1, float %div85.1, float 0.000000e+00
  %cmp96.1 = fcmp oeq float %div73.1, 0.000000e+00
  br i1 %cmp96.1, label %if.then97.7.1, label %if.else.7.1

if.else.7.1:                                      ; preds = %cond.end75.1
  %mul116.1429 = fmul float %div73.1, %12
  %252 = tail call float @llvm.fabs.f32(float %mul116.1429) #3
  %cmp.i378 = fcmp ugt float %252, 2.500000e-01
  br i1 %cmp.i378, label %if.else.i381, label %if.then.i379

if.then.i379:                                     ; preds = %if.else.7.1
  %253 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.1429) #3
  br label %quant_decide.exit399

if.else.i381:                                     ; preds = %if.else.7.1
  %cmp2.i380 = fcmp olt float %252, 7.500000e-01
  br i1 %cmp2.i380, label %if.then3.i382, label %if.else4.i384

if.then3.i382:                                    ; preds = %if.else.i381
  %254 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.1429) #3
  br label %quant_decide.exit399

if.else4.i384:                                    ; preds = %if.else.i381
  %cmp6.i383 = fcmp ugt float %252, 1.250000e+00
  br i1 %cmp6.i383, label %if.else8.i387, label %if.then7.i385

if.then7.i385:                                    ; preds = %if.else4.i384
  %255 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.1429) #3
  br label %quant_decide.exit399

if.else8.i387:                                    ; preds = %if.else4.i384
  %cmp10.i386 = fcmp olt float %252, 1.750000e+00
  br i1 %cmp10.i386, label %if.then11.i388, label %if.else12.i390

if.then11.i388:                                   ; preds = %if.else8.i387
  %256 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.1429) #3
  br label %quant_decide.exit399

if.else12.i390:                                   ; preds = %if.else8.i387
  %cmp14.i389 = fcmp ugt float %252, 2.500000e+00
  br i1 %cmp14.i389, label %if.else16.i393, label %if.then15.i391

if.then15.i391:                                   ; preds = %if.else12.i390
  %257 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.1429) #3
  br label %quant_decide.exit399

if.else16.i393:                                   ; preds = %if.else12.i390
  %cmp18.i392 = fcmp olt float %252, 3.500000e+00
  br i1 %cmp18.i392, label %if.then19.i394, label %if.else20.i396

if.then19.i394:                                   ; preds = %if.else16.i393
  %258 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.1429) #3
  br label %quant_decide.exit399

if.else20.i396:                                   ; preds = %if.else16.i393
  %cmp22.i395 = fcmp ugt float %252, 5.000000e+00
  br i1 %cmp22.i395, label %if.end29.i398, label %if.then23.i397

if.then23.i397:                                   ; preds = %if.else20.i396
  %259 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.1429) #3
  br label %quant_decide.exit399

if.end29.i398:                                    ; preds = %if.else20.i396
  %260 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.1429) #3
  br label %quant_decide.exit399

quant_decide.exit399:                             ; preds = %if.end29.i398, %if.then23.i397, %if.then19.i394, %if.then15.i391, %if.then11.i388, %if.then7.i385, %if.then3.i382, %if.then.i379
  %out.i372.8 = phi float [ %253, %if.then.i379 ], [ %254, %if.then3.i382 ], [ %255, %if.then7.i385 ], [ %256, %if.then11.i388 ], [ %257, %if.then15.i391 ], [ %258, %if.then19.i394 ], [ %259, %if.then23.i397 ], [ %260, %if.end29.i398 ]
  %mul118.1430 = fmul float %cond88.1, %out.i372.8
  %sub.1431 = fsub float %mul118.1430, %12
  %mul126.1433 = fmul float %div73.1, %16
  %261 = tail call float @llvm.fabs.f32(float %mul126.1433) #3
  %cmp.i356 = fcmp ugt float %261, 2.500000e-01
  br i1 %cmp.i356, label %if.else.i359, label %if.then.i357

if.then.i357:                                     ; preds = %quant_decide.exit399
  %262 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.1433) #3
  br label %quant_decide.exit377

if.else.i359:                                     ; preds = %quant_decide.exit399
  %cmp2.i358 = fcmp olt float %261, 7.500000e-01
  br i1 %cmp2.i358, label %if.then3.i360, label %if.else4.i362

if.then3.i360:                                    ; preds = %if.else.i359
  %263 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.1433) #3
  br label %quant_decide.exit377

if.else4.i362:                                    ; preds = %if.else.i359
  %cmp6.i361 = fcmp ugt float %261, 1.250000e+00
  br i1 %cmp6.i361, label %if.else8.i365, label %if.then7.i363

if.then7.i363:                                    ; preds = %if.else4.i362
  %264 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.1433) #3
  br label %quant_decide.exit377

if.else8.i365:                                    ; preds = %if.else4.i362
  %cmp10.i364 = fcmp olt float %261, 1.750000e+00
  br i1 %cmp10.i364, label %if.then11.i366, label %if.else12.i368

if.then11.i366:                                   ; preds = %if.else8.i365
  %265 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.1433) #3
  br label %quant_decide.exit377

if.else12.i368:                                   ; preds = %if.else8.i365
  %cmp14.i367 = fcmp ugt float %261, 2.500000e+00
  br i1 %cmp14.i367, label %if.else16.i371, label %if.then15.i369

if.then15.i369:                                   ; preds = %if.else12.i368
  %266 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.1433) #3
  br label %quant_decide.exit377

if.else16.i371:                                   ; preds = %if.else12.i368
  %cmp18.i370 = fcmp olt float %261, 3.500000e+00
  br i1 %cmp18.i370, label %if.then19.i372, label %if.else20.i374

if.then19.i372:                                   ; preds = %if.else16.i371
  %267 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.1433) #3
  br label %quant_decide.exit377

if.else20.i374:                                   ; preds = %if.else16.i371
  %cmp22.i373 = fcmp ugt float %261, 5.000000e+00
  br i1 %cmp22.i373, label %if.end29.i376, label %if.then23.i375

if.then23.i375:                                   ; preds = %if.else20.i374
  %268 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.1433) #3
  br label %quant_decide.exit377

if.end29.i376:                                    ; preds = %if.else20.i374
  %269 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.1433) #3
  br label %quant_decide.exit377

quant_decide.exit377:                             ; preds = %if.end29.i376, %if.then23.i375, %if.then19.i372, %if.then15.i369, %if.then11.i366, %if.then7.i363, %if.then3.i360, %if.then.i357
  %out.i.8 = phi float [ %262, %if.then.i357 ], [ %263, %if.then3.i360 ], [ %264, %if.then7.i363 ], [ %265, %if.then11.i366 ], [ %266, %if.then15.i369 ], [ %267, %if.then19.i372 ], [ %268, %if.then23.i375 ], [ %269, %if.end29.i376 ]
  %mul128.1434 = fmul float %cond88.1, %out.i.8
  %sub132.1435 = fsub float %mul128.1434, %16
  %mul133.1436 = fmul float %sub.1431, %sub.1431
  %mul134.1437 = fmul float %sub132.1435, %sub132.1435
  %add135.1438 = fadd float %mul133.1436, %mul134.1437
  %e.1.1447 = fadd float %add135.1438, 0.000000e+00
  %mul116.1.1 = fmul float %div73.1, %20
  %270 = tail call float @llvm.fabs.f32(float %mul116.1.1) #3
  %cmp.i334 = fcmp ugt float %270, 2.500000e-01
  br i1 %cmp.i334, label %if.else.i337, label %if.then.i335

if.then.i335:                                     ; preds = %quant_decide.exit377
  %271 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.1.1) #3
  br label %quant_decide.exit355

if.else.i337:                                     ; preds = %quant_decide.exit377
  %cmp2.i336 = fcmp olt float %270, 7.500000e-01
  br i1 %cmp2.i336, label %if.then3.i338, label %if.else4.i340

if.then3.i338:                                    ; preds = %if.else.i337
  %272 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.1.1) #3
  br label %quant_decide.exit355

if.else4.i340:                                    ; preds = %if.else.i337
  %cmp6.i339 = fcmp ugt float %270, 1.250000e+00
  br i1 %cmp6.i339, label %if.else8.i343, label %if.then7.i341

if.then7.i341:                                    ; preds = %if.else4.i340
  %273 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.1.1) #3
  br label %quant_decide.exit355

if.else8.i343:                                    ; preds = %if.else4.i340
  %cmp10.i342 = fcmp olt float %270, 1.750000e+00
  br i1 %cmp10.i342, label %if.then11.i344, label %if.else12.i346

if.then11.i344:                                   ; preds = %if.else8.i343
  %274 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.1.1) #3
  br label %quant_decide.exit355

if.else12.i346:                                   ; preds = %if.else8.i343
  %cmp14.i345 = fcmp ugt float %270, 2.500000e+00
  br i1 %cmp14.i345, label %if.else16.i349, label %if.then15.i347

if.then15.i347:                                   ; preds = %if.else12.i346
  %275 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.1.1) #3
  br label %quant_decide.exit355

if.else16.i349:                                   ; preds = %if.else12.i346
  %cmp18.i348 = fcmp olt float %270, 3.500000e+00
  br i1 %cmp18.i348, label %if.then19.i350, label %if.else20.i352

if.then19.i350:                                   ; preds = %if.else16.i349
  %276 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.1.1) #3
  br label %quant_decide.exit355

if.else20.i352:                                   ; preds = %if.else16.i349
  %cmp22.i351 = fcmp ugt float %270, 5.000000e+00
  br i1 %cmp22.i351, label %if.end29.i354, label %if.then23.i353

if.then23.i353:                                   ; preds = %if.else20.i352
  %277 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.1.1) #3
  br label %quant_decide.exit355

if.end29.i354:                                    ; preds = %if.else20.i352
  %278 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.1.1) #3
  br label %quant_decide.exit355

quant_decide.exit355:                             ; preds = %if.end29.i354, %if.then23.i353, %if.then19.i350, %if.then15.i347, %if.then11.i344, %if.then7.i341, %if.then3.i338, %if.then.i335
  %out.i372.9 = phi float [ %271, %if.then.i335 ], [ %272, %if.then3.i338 ], [ %273, %if.then7.i341 ], [ %274, %if.then11.i344 ], [ %275, %if.then15.i347 ], [ %276, %if.then19.i350 ], [ %277, %if.then23.i353 ], [ %278, %if.end29.i354 ]
  %mul118.1.1 = fmul float %cond88.1, %out.i372.9
  %sub.1.1 = fsub float %mul118.1.1, %20
  %mul126.1.1 = fmul float %div73.1, %24
  %279 = tail call float @llvm.fabs.f32(float %mul126.1.1) #3
  %cmp.i312 = fcmp ugt float %279, 2.500000e-01
  br i1 %cmp.i312, label %if.else.i315, label %if.then.i313

if.then.i313:                                     ; preds = %quant_decide.exit355
  %280 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.1.1) #3
  br label %quant_decide.exit333

if.else.i315:                                     ; preds = %quant_decide.exit355
  %cmp2.i314 = fcmp olt float %279, 7.500000e-01
  br i1 %cmp2.i314, label %if.then3.i316, label %if.else4.i318

if.then3.i316:                                    ; preds = %if.else.i315
  %281 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.1.1) #3
  br label %quant_decide.exit333

if.else4.i318:                                    ; preds = %if.else.i315
  %cmp6.i317 = fcmp ugt float %279, 1.250000e+00
  br i1 %cmp6.i317, label %if.else8.i321, label %if.then7.i319

if.then7.i319:                                    ; preds = %if.else4.i318
  %282 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.1.1) #3
  br label %quant_decide.exit333

if.else8.i321:                                    ; preds = %if.else4.i318
  %cmp10.i320 = fcmp olt float %279, 1.750000e+00
  br i1 %cmp10.i320, label %if.then11.i322, label %if.else12.i324

if.then11.i322:                                   ; preds = %if.else8.i321
  %283 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.1.1) #3
  br label %quant_decide.exit333

if.else12.i324:                                   ; preds = %if.else8.i321
  %cmp14.i323 = fcmp ugt float %279, 2.500000e+00
  br i1 %cmp14.i323, label %if.else16.i327, label %if.then15.i325

if.then15.i325:                                   ; preds = %if.else12.i324
  %284 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.1.1) #3
  br label %quant_decide.exit333

if.else16.i327:                                   ; preds = %if.else12.i324
  %cmp18.i326 = fcmp olt float %279, 3.500000e+00
  br i1 %cmp18.i326, label %if.then19.i328, label %if.else20.i330

if.then19.i328:                                   ; preds = %if.else16.i327
  %285 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.1.1) #3
  br label %quant_decide.exit333

if.else20.i330:                                   ; preds = %if.else16.i327
  %cmp22.i329 = fcmp ugt float %279, 5.000000e+00
  br i1 %cmp22.i329, label %if.end29.i332, label %if.then23.i331

if.then23.i331:                                   ; preds = %if.else20.i330
  %286 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.1.1) #3
  br label %quant_decide.exit333

if.end29.i332:                                    ; preds = %if.else20.i330
  %287 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.1.1) #3
  br label %quant_decide.exit333

quant_decide.exit333:                             ; preds = %if.end29.i332, %if.then23.i331, %if.then19.i328, %if.then15.i325, %if.then11.i322, %if.then7.i319, %if.then3.i316, %if.then.i313
  %out.i.9 = phi float [ %280, %if.then.i313 ], [ %281, %if.then3.i316 ], [ %282, %if.then7.i319 ], [ %283, %if.then11.i322 ], [ %284, %if.then15.i325 ], [ %285, %if.then19.i328 ], [ %286, %if.then23.i331 ], [ %287, %if.end29.i332 ]
  %mul128.1.1 = fmul float %cond88.1, %out.i.9
  %sub132.1.1 = fsub float %mul128.1.1, %24
  %mul133.1.1 = fmul float %sub.1.1, %sub.1.1
  %mul134.1.1 = fmul float %sub132.1.1, %sub132.1.1
  %add135.1.1 = fadd float %mul133.1.1, %mul134.1.1
  %e.1.1.1 = fadd float %e.1.1447, %add135.1.1
  %mul116.2.1 = fmul float %div73.1, %28
  %288 = tail call float @llvm.fabs.f32(float %mul116.2.1) #3
  %cmp.i290 = fcmp ugt float %288, 2.500000e-01
  br i1 %cmp.i290, label %if.else.i293, label %if.then.i291

if.then.i291:                                     ; preds = %quant_decide.exit333
  %289 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.2.1) #3
  br label %quant_decide.exit311

if.else.i293:                                     ; preds = %quant_decide.exit333
  %cmp2.i292 = fcmp olt float %288, 7.500000e-01
  br i1 %cmp2.i292, label %if.then3.i294, label %if.else4.i296

if.then3.i294:                                    ; preds = %if.else.i293
  %290 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.2.1) #3
  br label %quant_decide.exit311

if.else4.i296:                                    ; preds = %if.else.i293
  %cmp6.i295 = fcmp ugt float %288, 1.250000e+00
  br i1 %cmp6.i295, label %if.else8.i299, label %if.then7.i297

if.then7.i297:                                    ; preds = %if.else4.i296
  %291 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.2.1) #3
  br label %quant_decide.exit311

if.else8.i299:                                    ; preds = %if.else4.i296
  %cmp10.i298 = fcmp olt float %288, 1.750000e+00
  br i1 %cmp10.i298, label %if.then11.i300, label %if.else12.i302

if.then11.i300:                                   ; preds = %if.else8.i299
  %292 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.2.1) #3
  br label %quant_decide.exit311

if.else12.i302:                                   ; preds = %if.else8.i299
  %cmp14.i301 = fcmp ugt float %288, 2.500000e+00
  br i1 %cmp14.i301, label %if.else16.i305, label %if.then15.i303

if.then15.i303:                                   ; preds = %if.else12.i302
  %293 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.2.1) #3
  br label %quant_decide.exit311

if.else16.i305:                                   ; preds = %if.else12.i302
  %cmp18.i304 = fcmp olt float %288, 3.500000e+00
  br i1 %cmp18.i304, label %if.then19.i306, label %if.else20.i308

if.then19.i306:                                   ; preds = %if.else16.i305
  %294 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.2.1) #3
  br label %quant_decide.exit311

if.else20.i308:                                   ; preds = %if.else16.i305
  %cmp22.i307 = fcmp ugt float %288, 5.000000e+00
  br i1 %cmp22.i307, label %if.end29.i310, label %if.then23.i309

if.then23.i309:                                   ; preds = %if.else20.i308
  %295 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.2.1) #3
  br label %quant_decide.exit311

if.end29.i310:                                    ; preds = %if.else20.i308
  %296 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.2.1) #3
  br label %quant_decide.exit311

quant_decide.exit311:                             ; preds = %if.end29.i310, %if.then23.i309, %if.then19.i306, %if.then15.i303, %if.then11.i300, %if.then7.i297, %if.then3.i294, %if.then.i291
  %out.i372.10 = phi float [ %289, %if.then.i291 ], [ %290, %if.then3.i294 ], [ %291, %if.then7.i297 ], [ %292, %if.then11.i300 ], [ %293, %if.then15.i303 ], [ %294, %if.then19.i306 ], [ %295, %if.then23.i309 ], [ %296, %if.end29.i310 ]
  %mul118.2.1 = fmul float %cond88.1, %out.i372.10
  %sub.2.1 = fsub float %mul118.2.1, %28
  %mul126.2.1 = fmul float %div73.1, %32
  %297 = tail call float @llvm.fabs.f32(float %mul126.2.1) #3
  %cmp.i268 = fcmp ugt float %297, 2.500000e-01
  br i1 %cmp.i268, label %if.else.i271, label %if.then.i269

if.then.i269:                                     ; preds = %quant_decide.exit311
  %298 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.2.1) #3
  br label %quant_decide.exit289

if.else.i271:                                     ; preds = %quant_decide.exit311
  %cmp2.i270 = fcmp olt float %297, 7.500000e-01
  br i1 %cmp2.i270, label %if.then3.i272, label %if.else4.i274

if.then3.i272:                                    ; preds = %if.else.i271
  %299 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.2.1) #3
  br label %quant_decide.exit289

if.else4.i274:                                    ; preds = %if.else.i271
  %cmp6.i273 = fcmp ugt float %297, 1.250000e+00
  br i1 %cmp6.i273, label %if.else8.i277, label %if.then7.i275

if.then7.i275:                                    ; preds = %if.else4.i274
  %300 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.2.1) #3
  br label %quant_decide.exit289

if.else8.i277:                                    ; preds = %if.else4.i274
  %cmp10.i276 = fcmp olt float %297, 1.750000e+00
  br i1 %cmp10.i276, label %if.then11.i278, label %if.else12.i280

if.then11.i278:                                   ; preds = %if.else8.i277
  %301 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.2.1) #3
  br label %quant_decide.exit289

if.else12.i280:                                   ; preds = %if.else8.i277
  %cmp14.i279 = fcmp ugt float %297, 2.500000e+00
  br i1 %cmp14.i279, label %if.else16.i283, label %if.then15.i281

if.then15.i281:                                   ; preds = %if.else12.i280
  %302 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.2.1) #3
  br label %quant_decide.exit289

if.else16.i283:                                   ; preds = %if.else12.i280
  %cmp18.i282 = fcmp olt float %297, 3.500000e+00
  br i1 %cmp18.i282, label %if.then19.i284, label %if.else20.i286

if.then19.i284:                                   ; preds = %if.else16.i283
  %303 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.2.1) #3
  br label %quant_decide.exit289

if.else20.i286:                                   ; preds = %if.else16.i283
  %cmp22.i285 = fcmp ugt float %297, 5.000000e+00
  br i1 %cmp22.i285, label %if.end29.i288, label %if.then23.i287

if.then23.i287:                                   ; preds = %if.else20.i286
  %304 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.2.1) #3
  br label %quant_decide.exit289

if.end29.i288:                                    ; preds = %if.else20.i286
  %305 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.2.1) #3
  br label %quant_decide.exit289

quant_decide.exit289:                             ; preds = %if.end29.i288, %if.then23.i287, %if.then19.i284, %if.then15.i281, %if.then11.i278, %if.then7.i275, %if.then3.i272, %if.then.i269
  %out.i.10 = phi float [ %298, %if.then.i269 ], [ %299, %if.then3.i272 ], [ %300, %if.then7.i275 ], [ %301, %if.then11.i278 ], [ %302, %if.then15.i281 ], [ %303, %if.then19.i284 ], [ %304, %if.then23.i287 ], [ %305, %if.end29.i288 ]
  %mul128.2.1 = fmul float %cond88.1, %out.i.10
  %sub132.2.1 = fsub float %mul128.2.1, %32
  %mul133.2.1 = fmul float %sub.2.1, %sub.2.1
  %mul134.2.1 = fmul float %sub132.2.1, %sub132.2.1
  %add135.2.1 = fadd float %mul133.2.1, %mul134.2.1
  %e.1.2.1 = fadd float %e.1.1.1, %add135.2.1
  %mul116.3.1 = fmul float %div73.1, %36
  %306 = tail call float @llvm.fabs.f32(float %mul116.3.1) #3
  %cmp.i246 = fcmp ugt float %306, 2.500000e-01
  br i1 %cmp.i246, label %if.else.i249, label %if.then.i247

if.then.i247:                                     ; preds = %quant_decide.exit289
  %307 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.3.1) #3
  br label %quant_decide.exit267

if.else.i249:                                     ; preds = %quant_decide.exit289
  %cmp2.i248 = fcmp olt float %306, 7.500000e-01
  br i1 %cmp2.i248, label %if.then3.i250, label %if.else4.i252

if.then3.i250:                                    ; preds = %if.else.i249
  %308 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.3.1) #3
  br label %quant_decide.exit267

if.else4.i252:                                    ; preds = %if.else.i249
  %cmp6.i251 = fcmp ugt float %306, 1.250000e+00
  br i1 %cmp6.i251, label %if.else8.i255, label %if.then7.i253

if.then7.i253:                                    ; preds = %if.else4.i252
  %309 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.3.1) #3
  br label %quant_decide.exit267

if.else8.i255:                                    ; preds = %if.else4.i252
  %cmp10.i254 = fcmp olt float %306, 1.750000e+00
  br i1 %cmp10.i254, label %if.then11.i256, label %if.else12.i258

if.then11.i256:                                   ; preds = %if.else8.i255
  %310 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.3.1) #3
  br label %quant_decide.exit267

if.else12.i258:                                   ; preds = %if.else8.i255
  %cmp14.i257 = fcmp ugt float %306, 2.500000e+00
  br i1 %cmp14.i257, label %if.else16.i261, label %if.then15.i259

if.then15.i259:                                   ; preds = %if.else12.i258
  %311 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.3.1) #3
  br label %quant_decide.exit267

if.else16.i261:                                   ; preds = %if.else12.i258
  %cmp18.i260 = fcmp olt float %306, 3.500000e+00
  br i1 %cmp18.i260, label %if.then19.i262, label %if.else20.i264

if.then19.i262:                                   ; preds = %if.else16.i261
  %312 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.3.1) #3
  br label %quant_decide.exit267

if.else20.i264:                                   ; preds = %if.else16.i261
  %cmp22.i263 = fcmp ugt float %306, 5.000000e+00
  br i1 %cmp22.i263, label %if.end29.i266, label %if.then23.i265

if.then23.i265:                                   ; preds = %if.else20.i264
  %313 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.3.1) #3
  br label %quant_decide.exit267

if.end29.i266:                                    ; preds = %if.else20.i264
  %314 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.3.1) #3
  br label %quant_decide.exit267

quant_decide.exit267:                             ; preds = %if.end29.i266, %if.then23.i265, %if.then19.i262, %if.then15.i259, %if.then11.i256, %if.then7.i253, %if.then3.i250, %if.then.i247
  %out.i372.11 = phi float [ %307, %if.then.i247 ], [ %308, %if.then3.i250 ], [ %309, %if.then7.i253 ], [ %310, %if.then11.i256 ], [ %311, %if.then15.i259 ], [ %312, %if.then19.i262 ], [ %313, %if.then23.i265 ], [ %314, %if.end29.i266 ]
  %mul118.3.1 = fmul float %cond88.1, %out.i372.11
  %sub.3.1 = fsub float %mul118.3.1, %36
  %mul126.3.1 = fmul float %div73.1, %40
  %315 = tail call float @llvm.fabs.f32(float %mul126.3.1) #3
  %cmp.i224 = fcmp ugt float %315, 2.500000e-01
  br i1 %cmp.i224, label %if.else.i227, label %if.then.i225

if.then.i225:                                     ; preds = %quant_decide.exit267
  %316 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.3.1) #3
  br label %quant_decide.exit245

if.else.i227:                                     ; preds = %quant_decide.exit267
  %cmp2.i226 = fcmp olt float %315, 7.500000e-01
  br i1 %cmp2.i226, label %if.then3.i228, label %if.else4.i230

if.then3.i228:                                    ; preds = %if.else.i227
  %317 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.3.1) #3
  br label %quant_decide.exit245

if.else4.i230:                                    ; preds = %if.else.i227
  %cmp6.i229 = fcmp ugt float %315, 1.250000e+00
  br i1 %cmp6.i229, label %if.else8.i233, label %if.then7.i231

if.then7.i231:                                    ; preds = %if.else4.i230
  %318 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.3.1) #3
  br label %quant_decide.exit245

if.else8.i233:                                    ; preds = %if.else4.i230
  %cmp10.i232 = fcmp olt float %315, 1.750000e+00
  br i1 %cmp10.i232, label %if.then11.i234, label %if.else12.i236

if.then11.i234:                                   ; preds = %if.else8.i233
  %319 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.3.1) #3
  br label %quant_decide.exit245

if.else12.i236:                                   ; preds = %if.else8.i233
  %cmp14.i235 = fcmp ugt float %315, 2.500000e+00
  br i1 %cmp14.i235, label %if.else16.i239, label %if.then15.i237

if.then15.i237:                                   ; preds = %if.else12.i236
  %320 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.3.1) #3
  br label %quant_decide.exit245

if.else16.i239:                                   ; preds = %if.else12.i236
  %cmp18.i238 = fcmp olt float %315, 3.500000e+00
  br i1 %cmp18.i238, label %if.then19.i240, label %if.else20.i242

if.then19.i240:                                   ; preds = %if.else16.i239
  %321 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.3.1) #3
  br label %quant_decide.exit245

if.else20.i242:                                   ; preds = %if.else16.i239
  %cmp22.i241 = fcmp ugt float %315, 5.000000e+00
  br i1 %cmp22.i241, label %if.end29.i244, label %if.then23.i243

if.then23.i243:                                   ; preds = %if.else20.i242
  %322 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.3.1) #3
  br label %quant_decide.exit245

if.end29.i244:                                    ; preds = %if.else20.i242
  %323 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.3.1) #3
  br label %quant_decide.exit245

quant_decide.exit245:                             ; preds = %if.end29.i244, %if.then23.i243, %if.then19.i240, %if.then15.i237, %if.then11.i234, %if.then7.i231, %if.then3.i228, %if.then.i225
  %out.i.11 = phi float [ %316, %if.then.i225 ], [ %317, %if.then3.i228 ], [ %318, %if.then7.i231 ], [ %319, %if.then11.i234 ], [ %320, %if.then15.i237 ], [ %321, %if.then19.i240 ], [ %322, %if.then23.i243 ], [ %323, %if.end29.i244 ]
  %mul128.3.1 = fmul float %cond88.1, %out.i.11
  %sub132.3.1 = fsub float %mul128.3.1, %40
  %mul133.3.1 = fmul float %sub.3.1, %sub.3.1
  %mul134.3.1 = fmul float %sub132.3.1, %sub132.3.1
  %add135.3.1 = fadd float %mul133.3.1, %mul134.3.1
  %e.1.3.1 = fadd float %e.1.2.1, %add135.3.1
  %mul116.4.1 = fmul float %div73.1, %44
  %324 = tail call float @llvm.fabs.f32(float %mul116.4.1) #3
  %cmp.i202 = fcmp ugt float %324, 2.500000e-01
  br i1 %cmp.i202, label %if.else.i205, label %if.then.i203

if.then.i203:                                     ; preds = %quant_decide.exit245
  %325 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.4.1) #3
  br label %quant_decide.exit223

if.else.i205:                                     ; preds = %quant_decide.exit245
  %cmp2.i204 = fcmp olt float %324, 7.500000e-01
  br i1 %cmp2.i204, label %if.then3.i206, label %if.else4.i208

if.then3.i206:                                    ; preds = %if.else.i205
  %326 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.4.1) #3
  br label %quant_decide.exit223

if.else4.i208:                                    ; preds = %if.else.i205
  %cmp6.i207 = fcmp ugt float %324, 1.250000e+00
  br i1 %cmp6.i207, label %if.else8.i211, label %if.then7.i209

if.then7.i209:                                    ; preds = %if.else4.i208
  %327 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.4.1) #3
  br label %quant_decide.exit223

if.else8.i211:                                    ; preds = %if.else4.i208
  %cmp10.i210 = fcmp olt float %324, 1.750000e+00
  br i1 %cmp10.i210, label %if.then11.i212, label %if.else12.i214

if.then11.i212:                                   ; preds = %if.else8.i211
  %328 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.4.1) #3
  br label %quant_decide.exit223

if.else12.i214:                                   ; preds = %if.else8.i211
  %cmp14.i213 = fcmp ugt float %324, 2.500000e+00
  br i1 %cmp14.i213, label %if.else16.i217, label %if.then15.i215

if.then15.i215:                                   ; preds = %if.else12.i214
  %329 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.4.1) #3
  br label %quant_decide.exit223

if.else16.i217:                                   ; preds = %if.else12.i214
  %cmp18.i216 = fcmp olt float %324, 3.500000e+00
  br i1 %cmp18.i216, label %if.then19.i218, label %if.else20.i220

if.then19.i218:                                   ; preds = %if.else16.i217
  %330 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.4.1) #3
  br label %quant_decide.exit223

if.else20.i220:                                   ; preds = %if.else16.i217
  %cmp22.i219 = fcmp ugt float %324, 5.000000e+00
  br i1 %cmp22.i219, label %if.end29.i222, label %if.then23.i221

if.then23.i221:                                   ; preds = %if.else20.i220
  %331 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.4.1) #3
  br label %quant_decide.exit223

if.end29.i222:                                    ; preds = %if.else20.i220
  %332 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.4.1) #3
  br label %quant_decide.exit223

quant_decide.exit223:                             ; preds = %if.end29.i222, %if.then23.i221, %if.then19.i218, %if.then15.i215, %if.then11.i212, %if.then7.i209, %if.then3.i206, %if.then.i203
  %out.i372.12 = phi float [ %325, %if.then.i203 ], [ %326, %if.then3.i206 ], [ %327, %if.then7.i209 ], [ %328, %if.then11.i212 ], [ %329, %if.then15.i215 ], [ %330, %if.then19.i218 ], [ %331, %if.then23.i221 ], [ %332, %if.end29.i222 ]
  %mul118.4.1 = fmul float %cond88.1, %out.i372.12
  %sub.4.1 = fsub float %mul118.4.1, %44
  %mul126.4.1 = fmul float %div73.1, %48
  %333 = tail call float @llvm.fabs.f32(float %mul126.4.1) #3
  %cmp.i180 = fcmp ugt float %333, 2.500000e-01
  br i1 %cmp.i180, label %if.else.i183, label %if.then.i181

if.then.i181:                                     ; preds = %quant_decide.exit223
  %334 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.4.1) #3
  br label %quant_decide.exit201

if.else.i183:                                     ; preds = %quant_decide.exit223
  %cmp2.i182 = fcmp olt float %333, 7.500000e-01
  br i1 %cmp2.i182, label %if.then3.i184, label %if.else4.i186

if.then3.i184:                                    ; preds = %if.else.i183
  %335 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.4.1) #3
  br label %quant_decide.exit201

if.else4.i186:                                    ; preds = %if.else.i183
  %cmp6.i185 = fcmp ugt float %333, 1.250000e+00
  br i1 %cmp6.i185, label %if.else8.i189, label %if.then7.i187

if.then7.i187:                                    ; preds = %if.else4.i186
  %336 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.4.1) #3
  br label %quant_decide.exit201

if.else8.i189:                                    ; preds = %if.else4.i186
  %cmp10.i188 = fcmp olt float %333, 1.750000e+00
  br i1 %cmp10.i188, label %if.then11.i190, label %if.else12.i192

if.then11.i190:                                   ; preds = %if.else8.i189
  %337 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.4.1) #3
  br label %quant_decide.exit201

if.else12.i192:                                   ; preds = %if.else8.i189
  %cmp14.i191 = fcmp ugt float %333, 2.500000e+00
  br i1 %cmp14.i191, label %if.else16.i195, label %if.then15.i193

if.then15.i193:                                   ; preds = %if.else12.i192
  %338 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.4.1) #3
  br label %quant_decide.exit201

if.else16.i195:                                   ; preds = %if.else12.i192
  %cmp18.i194 = fcmp olt float %333, 3.500000e+00
  br i1 %cmp18.i194, label %if.then19.i196, label %if.else20.i198

if.then19.i196:                                   ; preds = %if.else16.i195
  %339 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.4.1) #3
  br label %quant_decide.exit201

if.else20.i198:                                   ; preds = %if.else16.i195
  %cmp22.i197 = fcmp ugt float %333, 5.000000e+00
  br i1 %cmp22.i197, label %if.end29.i200, label %if.then23.i199

if.then23.i199:                                   ; preds = %if.else20.i198
  %340 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.4.1) #3
  br label %quant_decide.exit201

if.end29.i200:                                    ; preds = %if.else20.i198
  %341 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.4.1) #3
  br label %quant_decide.exit201

quant_decide.exit201:                             ; preds = %if.end29.i200, %if.then23.i199, %if.then19.i196, %if.then15.i193, %if.then11.i190, %if.then7.i187, %if.then3.i184, %if.then.i181
  %out.i.12 = phi float [ %334, %if.then.i181 ], [ %335, %if.then3.i184 ], [ %336, %if.then7.i187 ], [ %337, %if.then11.i190 ], [ %338, %if.then15.i193 ], [ %339, %if.then19.i196 ], [ %340, %if.then23.i199 ], [ %341, %if.end29.i200 ]
  %mul128.4.1 = fmul float %cond88.1, %out.i.12
  %sub132.4.1 = fsub float %mul128.4.1, %48
  %mul133.4.1 = fmul float %sub.4.1, %sub.4.1
  %mul134.4.1 = fmul float %sub132.4.1, %sub132.4.1
  %add135.4.1 = fadd float %mul133.4.1, %mul134.4.1
  %e.1.4.1 = fadd float %e.1.3.1, %add135.4.1
  %mul116.5.1 = fmul float %div73.1, %52
  %342 = tail call float @llvm.fabs.f32(float %mul116.5.1) #3
  %cmp.i158 = fcmp ugt float %342, 2.500000e-01
  br i1 %cmp.i158, label %if.else.i161, label %if.then.i159

if.then.i159:                                     ; preds = %quant_decide.exit201
  %343 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.5.1) #3
  br label %quant_decide.exit179

if.else.i161:                                     ; preds = %quant_decide.exit201
  %cmp2.i160 = fcmp olt float %342, 7.500000e-01
  br i1 %cmp2.i160, label %if.then3.i162, label %if.else4.i164

if.then3.i162:                                    ; preds = %if.else.i161
  %344 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.5.1) #3
  br label %quant_decide.exit179

if.else4.i164:                                    ; preds = %if.else.i161
  %cmp6.i163 = fcmp ugt float %342, 1.250000e+00
  br i1 %cmp6.i163, label %if.else8.i167, label %if.then7.i165

if.then7.i165:                                    ; preds = %if.else4.i164
  %345 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.5.1) #3
  br label %quant_decide.exit179

if.else8.i167:                                    ; preds = %if.else4.i164
  %cmp10.i166 = fcmp olt float %342, 1.750000e+00
  br i1 %cmp10.i166, label %if.then11.i168, label %if.else12.i170

if.then11.i168:                                   ; preds = %if.else8.i167
  %346 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.5.1) #3
  br label %quant_decide.exit179

if.else12.i170:                                   ; preds = %if.else8.i167
  %cmp14.i169 = fcmp ugt float %342, 2.500000e+00
  br i1 %cmp14.i169, label %if.else16.i173, label %if.then15.i171

if.then15.i171:                                   ; preds = %if.else12.i170
  %347 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.5.1) #3
  br label %quant_decide.exit179

if.else16.i173:                                   ; preds = %if.else12.i170
  %cmp18.i172 = fcmp olt float %342, 3.500000e+00
  br i1 %cmp18.i172, label %if.then19.i174, label %if.else20.i176

if.then19.i174:                                   ; preds = %if.else16.i173
  %348 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.5.1) #3
  br label %quant_decide.exit179

if.else20.i176:                                   ; preds = %if.else16.i173
  %cmp22.i175 = fcmp ugt float %342, 5.000000e+00
  br i1 %cmp22.i175, label %if.end29.i178, label %if.then23.i177

if.then23.i177:                                   ; preds = %if.else20.i176
  %349 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.5.1) #3
  br label %quant_decide.exit179

if.end29.i178:                                    ; preds = %if.else20.i176
  %350 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.5.1) #3
  br label %quant_decide.exit179

quant_decide.exit179:                             ; preds = %if.end29.i178, %if.then23.i177, %if.then19.i174, %if.then15.i171, %if.then11.i168, %if.then7.i165, %if.then3.i162, %if.then.i159
  %out.i372.13 = phi float [ %343, %if.then.i159 ], [ %344, %if.then3.i162 ], [ %345, %if.then7.i165 ], [ %346, %if.then11.i168 ], [ %347, %if.then15.i171 ], [ %348, %if.then19.i174 ], [ %349, %if.then23.i177 ], [ %350, %if.end29.i178 ]
  %mul118.5.1 = fmul float %cond88.1, %out.i372.13
  %sub.5.1 = fsub float %mul118.5.1, %52
  %mul126.5.1 = fmul float %div73.1, %56
  %351 = tail call float @llvm.fabs.f32(float %mul126.5.1) #3
  %cmp.i136 = fcmp ugt float %351, 2.500000e-01
  br i1 %cmp.i136, label %if.else.i139, label %if.then.i137

if.then.i137:                                     ; preds = %quant_decide.exit179
  %352 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.5.1) #3
  br label %quant_decide.exit157

if.else.i139:                                     ; preds = %quant_decide.exit179
  %cmp2.i138 = fcmp olt float %351, 7.500000e-01
  br i1 %cmp2.i138, label %if.then3.i140, label %if.else4.i142

if.then3.i140:                                    ; preds = %if.else.i139
  %353 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.5.1) #3
  br label %quant_decide.exit157

if.else4.i142:                                    ; preds = %if.else.i139
  %cmp6.i141 = fcmp ugt float %351, 1.250000e+00
  br i1 %cmp6.i141, label %if.else8.i145, label %if.then7.i143

if.then7.i143:                                    ; preds = %if.else4.i142
  %354 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.5.1) #3
  br label %quant_decide.exit157

if.else8.i145:                                    ; preds = %if.else4.i142
  %cmp10.i144 = fcmp olt float %351, 1.750000e+00
  br i1 %cmp10.i144, label %if.then11.i146, label %if.else12.i148

if.then11.i146:                                   ; preds = %if.else8.i145
  %355 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.5.1) #3
  br label %quant_decide.exit157

if.else12.i148:                                   ; preds = %if.else8.i145
  %cmp14.i147 = fcmp ugt float %351, 2.500000e+00
  br i1 %cmp14.i147, label %if.else16.i151, label %if.then15.i149

if.then15.i149:                                   ; preds = %if.else12.i148
  %356 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.5.1) #3
  br label %quant_decide.exit157

if.else16.i151:                                   ; preds = %if.else12.i148
  %cmp18.i150 = fcmp olt float %351, 3.500000e+00
  br i1 %cmp18.i150, label %if.then19.i152, label %if.else20.i154

if.then19.i152:                                   ; preds = %if.else16.i151
  %357 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.5.1) #3
  br label %quant_decide.exit157

if.else20.i154:                                   ; preds = %if.else16.i151
  %cmp22.i153 = fcmp ugt float %351, 5.000000e+00
  br i1 %cmp22.i153, label %if.end29.i156, label %if.then23.i155

if.then23.i155:                                   ; preds = %if.else20.i154
  %358 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.5.1) #3
  br label %quant_decide.exit157

if.end29.i156:                                    ; preds = %if.else20.i154
  %359 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.5.1) #3
  br label %quant_decide.exit157

quant_decide.exit157:                             ; preds = %if.end29.i156, %if.then23.i155, %if.then19.i152, %if.then15.i149, %if.then11.i146, %if.then7.i143, %if.then3.i140, %if.then.i137
  %out.i.13 = phi float [ %352, %if.then.i137 ], [ %353, %if.then3.i140 ], [ %354, %if.then7.i143 ], [ %355, %if.then11.i146 ], [ %356, %if.then15.i149 ], [ %357, %if.then19.i152 ], [ %358, %if.then23.i155 ], [ %359, %if.end29.i156 ]
  %mul128.5.1 = fmul float %cond88.1, %out.i.13
  %sub132.5.1 = fsub float %mul128.5.1, %56
  %mul133.5.1 = fmul float %sub.5.1, %sub.5.1
  %mul134.5.1 = fmul float %sub132.5.1, %sub132.5.1
  %add135.5.1 = fadd float %mul133.5.1, %mul134.5.1
  %e.1.5.1 = fadd float %e.1.4.1, %add135.5.1
  %mul116.6.1 = fmul float %div73.1, %60
  %360 = tail call float @llvm.fabs.f32(float %mul116.6.1) #3
  %cmp.i114 = fcmp ugt float %360, 2.500000e-01
  br i1 %cmp.i114, label %if.else.i117, label %if.then.i115

if.then.i115:                                     ; preds = %quant_decide.exit157
  %361 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.6.1) #3
  br label %quant_decide.exit135

if.else.i117:                                     ; preds = %quant_decide.exit157
  %cmp2.i116 = fcmp olt float %360, 7.500000e-01
  br i1 %cmp2.i116, label %if.then3.i118, label %if.else4.i120

if.then3.i118:                                    ; preds = %if.else.i117
  %362 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.6.1) #3
  br label %quant_decide.exit135

if.else4.i120:                                    ; preds = %if.else.i117
  %cmp6.i119 = fcmp ugt float %360, 1.250000e+00
  br i1 %cmp6.i119, label %if.else8.i123, label %if.then7.i121

if.then7.i121:                                    ; preds = %if.else4.i120
  %363 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.6.1) #3
  br label %quant_decide.exit135

if.else8.i123:                                    ; preds = %if.else4.i120
  %cmp10.i122 = fcmp olt float %360, 1.750000e+00
  br i1 %cmp10.i122, label %if.then11.i124, label %if.else12.i126

if.then11.i124:                                   ; preds = %if.else8.i123
  %364 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.6.1) #3
  br label %quant_decide.exit135

if.else12.i126:                                   ; preds = %if.else8.i123
  %cmp14.i125 = fcmp ugt float %360, 2.500000e+00
  br i1 %cmp14.i125, label %if.else16.i129, label %if.then15.i127

if.then15.i127:                                   ; preds = %if.else12.i126
  %365 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.6.1) #3
  br label %quant_decide.exit135

if.else16.i129:                                   ; preds = %if.else12.i126
  %cmp18.i128 = fcmp olt float %360, 3.500000e+00
  br i1 %cmp18.i128, label %if.then19.i130, label %if.else20.i132

if.then19.i130:                                   ; preds = %if.else16.i129
  %366 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.6.1) #3
  br label %quant_decide.exit135

if.else20.i132:                                   ; preds = %if.else16.i129
  %cmp22.i131 = fcmp ugt float %360, 5.000000e+00
  br i1 %cmp22.i131, label %if.end29.i134, label %if.then23.i133

if.then23.i133:                                   ; preds = %if.else20.i132
  %367 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.6.1) #3
  br label %quant_decide.exit135

if.end29.i134:                                    ; preds = %if.else20.i132
  %368 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.6.1) #3
  br label %quant_decide.exit135

quant_decide.exit135:                             ; preds = %if.end29.i134, %if.then23.i133, %if.then19.i130, %if.then15.i127, %if.then11.i124, %if.then7.i121, %if.then3.i118, %if.then.i115
  %out.i372.14 = phi float [ %361, %if.then.i115 ], [ %362, %if.then3.i118 ], [ %363, %if.then7.i121 ], [ %364, %if.then11.i124 ], [ %365, %if.then15.i127 ], [ %366, %if.then19.i130 ], [ %367, %if.then23.i133 ], [ %368, %if.end29.i134 ]
  %mul118.6.1 = fmul float %cond88.1, %out.i372.14
  %sub.6.1 = fsub float %mul118.6.1, %60
  %mul126.6.1 = fmul float %div73.1, %64
  %369 = tail call float @llvm.fabs.f32(float %mul126.6.1) #3
  %cmp.i92 = fcmp ugt float %369, 2.500000e-01
  br i1 %cmp.i92, label %if.else.i95, label %if.then.i93

if.then.i93:                                      ; preds = %quant_decide.exit135
  %370 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.6.1) #3
  br label %quant_decide.exit113

if.else.i95:                                      ; preds = %quant_decide.exit135
  %cmp2.i94 = fcmp olt float %369, 7.500000e-01
  br i1 %cmp2.i94, label %if.then3.i96, label %if.else4.i98

if.then3.i96:                                     ; preds = %if.else.i95
  %371 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.6.1) #3
  br label %quant_decide.exit113

if.else4.i98:                                     ; preds = %if.else.i95
  %cmp6.i97 = fcmp ugt float %369, 1.250000e+00
  br i1 %cmp6.i97, label %if.else8.i101, label %if.then7.i99

if.then7.i99:                                     ; preds = %if.else4.i98
  %372 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.6.1) #3
  br label %quant_decide.exit113

if.else8.i101:                                    ; preds = %if.else4.i98
  %cmp10.i100 = fcmp olt float %369, 1.750000e+00
  br i1 %cmp10.i100, label %if.then11.i102, label %if.else12.i104

if.then11.i102:                                   ; preds = %if.else8.i101
  %373 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.6.1) #3
  br label %quant_decide.exit113

if.else12.i104:                                   ; preds = %if.else8.i101
  %cmp14.i103 = fcmp ugt float %369, 2.500000e+00
  br i1 %cmp14.i103, label %if.else16.i107, label %if.then15.i105

if.then15.i105:                                   ; preds = %if.else12.i104
  %374 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.6.1) #3
  br label %quant_decide.exit113

if.else16.i107:                                   ; preds = %if.else12.i104
  %cmp18.i106 = fcmp olt float %369, 3.500000e+00
  br i1 %cmp18.i106, label %if.then19.i108, label %if.else20.i110

if.then19.i108:                                   ; preds = %if.else16.i107
  %375 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.6.1) #3
  br label %quant_decide.exit113

if.else20.i110:                                   ; preds = %if.else16.i107
  %cmp22.i109 = fcmp ugt float %369, 5.000000e+00
  br i1 %cmp22.i109, label %if.end29.i112, label %if.then23.i111

if.then23.i111:                                   ; preds = %if.else20.i110
  %376 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.6.1) #3
  br label %quant_decide.exit113

if.end29.i112:                                    ; preds = %if.else20.i110
  %377 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.6.1) #3
  br label %quant_decide.exit113

quant_decide.exit113:                             ; preds = %if.end29.i112, %if.then23.i111, %if.then19.i108, %if.then15.i105, %if.then11.i102, %if.then7.i99, %if.then3.i96, %if.then.i93
  %out.i.14 = phi float [ %370, %if.then.i93 ], [ %371, %if.then3.i96 ], [ %372, %if.then7.i99 ], [ %373, %if.then11.i102 ], [ %374, %if.then15.i105 ], [ %375, %if.then19.i108 ], [ %376, %if.then23.i111 ], [ %377, %if.end29.i112 ]
  %mul128.6.1 = fmul float %cond88.1, %out.i.14
  %sub132.6.1 = fsub float %mul128.6.1, %64
  %mul133.6.1 = fmul float %sub.6.1, %sub.6.1
  %mul134.6.1 = fmul float %sub132.6.1, %sub132.6.1
  %add135.6.1 = fadd float %mul133.6.1, %mul134.6.1
  %e.1.6.1 = fadd float %e.1.5.1, %add135.6.1
  %mul116.7.1 = fmul float %74, %div73.1
  %378 = tail call float @llvm.fabs.f32(float %mul116.7.1) #3
  %cmp.i70 = fcmp ugt float %378, 2.500000e-01
  br i1 %cmp.i70, label %if.else.i73, label %if.then.i71

if.then.i71:                                      ; preds = %quant_decide.exit113
  %379 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.7.1) #3
  br label %quant_decide.exit91

if.else.i73:                                      ; preds = %quant_decide.exit113
  %cmp2.i72 = fcmp olt float %378, 7.500000e-01
  br i1 %cmp2.i72, label %if.then3.i74, label %if.else4.i76

if.then3.i74:                                     ; preds = %if.else.i73
  %380 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.7.1) #3
  br label %quant_decide.exit91

if.else4.i76:                                     ; preds = %if.else.i73
  %cmp6.i75 = fcmp ugt float %378, 1.250000e+00
  br i1 %cmp6.i75, label %if.else8.i79, label %if.then7.i77

if.then7.i77:                                     ; preds = %if.else4.i76
  %381 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.7.1) #3
  br label %quant_decide.exit91

if.else8.i79:                                     ; preds = %if.else4.i76
  %cmp10.i78 = fcmp olt float %378, 1.750000e+00
  br i1 %cmp10.i78, label %if.then11.i80, label %if.else12.i82

if.then11.i80:                                    ; preds = %if.else8.i79
  %382 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.7.1) #3
  br label %quant_decide.exit91

if.else12.i82:                                    ; preds = %if.else8.i79
  %cmp14.i81 = fcmp ugt float %378, 2.500000e+00
  br i1 %cmp14.i81, label %if.else16.i85, label %if.then15.i83

if.then15.i83:                                    ; preds = %if.else12.i82
  %383 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.7.1) #3
  br label %quant_decide.exit91

if.else16.i85:                                    ; preds = %if.else12.i82
  %cmp18.i84 = fcmp olt float %378, 3.500000e+00
  br i1 %cmp18.i84, label %if.then19.i86, label %if.else20.i88

if.then19.i86:                                    ; preds = %if.else16.i85
  %384 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.7.1) #3
  br label %quant_decide.exit91

if.else20.i88:                                    ; preds = %if.else16.i85
  %cmp22.i87 = fcmp ugt float %378, 5.000000e+00
  br i1 %cmp22.i87, label %if.end29.i90, label %if.then23.i89

if.then23.i89:                                    ; preds = %if.else20.i88
  %385 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.7.1) #3
  br label %quant_decide.exit91

if.end29.i90:                                     ; preds = %if.else20.i88
  %386 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.7.1) #3
  br label %quant_decide.exit91

quant_decide.exit91:                              ; preds = %if.end29.i90, %if.then23.i89, %if.then19.i86, %if.then15.i83, %if.then11.i80, %if.then7.i77, %if.then3.i74, %if.then.i71
  %out.i372.15 = phi float [ %379, %if.then.i71 ], [ %380, %if.then3.i74 ], [ %381, %if.then7.i77 ], [ %382, %if.then11.i80 ], [ %383, %if.then15.i83 ], [ %384, %if.then19.i86 ], [ %385, %if.then23.i89 ], [ %386, %if.end29.i90 ]
  %mul118.7.1 = fmul float %cond88.1, %out.i372.15
  %sub.7.1 = fsub float %mul118.7.1, %74
  %mul126.7.1 = fmul float %77, %div73.1
  %387 = tail call float @llvm.fabs.f32(float %mul126.7.1) #3
  %cmp.i48 = fcmp ugt float %387, 2.500000e-01
  br i1 %cmp.i48, label %if.else.i51, label %if.then.i49

if.then.i49:                                      ; preds = %quant_decide.exit91
  %388 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.7.1) #3
  br label %quant_decide.exit69

if.else.i51:                                      ; preds = %quant_decide.exit91
  %cmp2.i50 = fcmp olt float %387, 7.500000e-01
  br i1 %cmp2.i50, label %if.then3.i52, label %if.else4.i54

if.then3.i52:                                     ; preds = %if.else.i51
  %389 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.7.1) #3
  br label %quant_decide.exit69

if.else4.i54:                                     ; preds = %if.else.i51
  %cmp6.i53 = fcmp ugt float %387, 1.250000e+00
  br i1 %cmp6.i53, label %if.else8.i57, label %if.then7.i55

if.then7.i55:                                     ; preds = %if.else4.i54
  %390 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.7.1) #3
  br label %quant_decide.exit69

if.else8.i57:                                     ; preds = %if.else4.i54
  %cmp10.i56 = fcmp olt float %387, 1.750000e+00
  br i1 %cmp10.i56, label %if.then11.i58, label %if.else12.i60

if.then11.i58:                                    ; preds = %if.else8.i57
  %391 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.7.1) #3
  br label %quant_decide.exit69

if.else12.i60:                                    ; preds = %if.else8.i57
  %cmp14.i59 = fcmp ugt float %387, 2.500000e+00
  br i1 %cmp14.i59, label %if.else16.i63, label %if.then15.i61

if.then15.i61:                                    ; preds = %if.else12.i60
  %392 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.7.1) #3
  br label %quant_decide.exit69

if.else16.i63:                                    ; preds = %if.else12.i60
  %cmp18.i62 = fcmp olt float %387, 3.500000e+00
  br i1 %cmp18.i62, label %if.then19.i64, label %if.else20.i66

if.then19.i64:                                    ; preds = %if.else16.i63
  %393 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.7.1) #3
  br label %quant_decide.exit69

if.else20.i66:                                    ; preds = %if.else16.i63
  %cmp22.i65 = fcmp ugt float %387, 5.000000e+00
  br i1 %cmp22.i65, label %if.end29.i68, label %if.then23.i67

if.then23.i67:                                    ; preds = %if.else20.i66
  %394 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.7.1) #3
  br label %quant_decide.exit69

if.end29.i68:                                     ; preds = %if.else20.i66
  %395 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.7.1) #3
  br label %quant_decide.exit69

quant_decide.exit69:                              ; preds = %if.end29.i68, %if.then23.i67, %if.then19.i64, %if.then15.i61, %if.then11.i58, %if.then7.i55, %if.then3.i52, %if.then.i49
  %out.i.15 = phi float [ %388, %if.then.i49 ], [ %389, %if.then3.i52 ], [ %390, %if.then7.i55 ], [ %391, %if.then11.i58 ], [ %392, %if.then15.i61 ], [ %393, %if.then19.i64 ], [ %394, %if.then23.i67 ], [ %395, %if.end29.i68 ]
  %mul128.7.1 = fmul float %cond88.1, %out.i.15
  %sub132.7.1 = fsub float %mul128.7.1, %77
  %396 = insertelement <2 x float> undef, float %sub132.7.1, i32 0
  %397 = insertelement <2 x float> %396, float %sub.7.1, i32 1
  %398 = fmul <2 x float> %397, %397
  br label %for.inc138.7.1

if.then97.7.1:                                    ; preds = %cond.end75.1, %cond.end75.1.thread
  %os.sroa.0.5 = phi <2 x float> [ %250, %cond.end75.1.thread ], [ %251, %cond.end75.1 ]
  %mul102.1441 = fmul float %12, %12
  %mul109.1443 = fmul float %16, %16
  %add110.1444 = fadd float %mul102.1441, %mul109.1443
  %e.1.1447581 = fadd float %add110.1444, 0.000000e+00
  %mul102.1.1 = fmul float %20, %20
  %mul109.1.1 = fmul float %24, %24
  %add110.1.1 = fadd float %mul102.1.1, %mul109.1.1
  %e.1.1.1593 = fadd float %e.1.1447581, %add110.1.1
  %mul102.2.1 = fmul float %28, %28
  %mul109.2.1 = fmul float %32, %32
  %add110.2.1 = fadd float %mul102.2.1, %mul109.2.1
  %e.1.2.1605 = fadd float %e.1.1.1593, %add110.2.1
  %mul102.3.1 = fmul float %36, %36
  %mul109.3.1 = fmul float %40, %40
  %add110.3.1 = fadd float %mul102.3.1, %mul109.3.1
  %e.1.3.1617 = fadd float %e.1.2.1605, %add110.3.1
  %mul102.4.1 = fmul float %44, %44
  %mul109.4.1 = fmul float %48, %48
  %add110.4.1 = fadd float %mul102.4.1, %mul109.4.1
  %e.1.4.1629 = fadd float %e.1.3.1617, %add110.4.1
  %mul102.5.1 = fmul float %52, %52
  %mul109.5.1 = fmul float %56, %56
  %add110.5.1 = fadd float %mul102.5.1, %mul109.5.1
  %e.1.5.1641 = fadd float %e.1.4.1629, %add110.5.1
  %mul102.6.1 = fmul float %60, %60
  %mul109.6.1 = fmul float %64, %64
  %add110.6.1 = fadd float %mul102.6.1, %mul109.6.1
  %e.1.6.1653 = fadd float %e.1.5.1641, %add110.6.1
  %399 = fmul <2 x float> %73, %73
  br label %for.inc138.7.1

for.inc138.7.1:                                   ; preds = %if.then97.7.1, %quant_decide.exit69
  %os.sroa.0.6 = phi <2 x float> [ %251, %quant_decide.exit69 ], [ %os.sroa.0.5, %if.then97.7.1 ]
  %e.1.6.1654 = phi float [ %e.1.6.1, %quant_decide.exit69 ], [ %e.1.6.1653, %if.then97.7.1 ]
  %400 = phi <2 x float> [ %398, %quant_decide.exit69 ], [ %399, %if.then97.7.1 ]
  %401 = extractelement <2 x float> %400, i32 0
  %402 = extractelement <2 x float> %400, i32 1
  %add110.7.1 = fadd float %401, %402
  %e.1.7.1 = fadd float %e.1.6.1654, %add110.7.1
  %cmp149 = fcmp olt float %e.1.7.1, %e.1.7
  %conv153 = sext i32 %div35 to i64
  %add154 = add nsw i64 %mul152, %conv153
  %mul156 = mul nsw i64 %add154, %conv
  %add158 = add nsw i64 %mul156, %rem.decomposed
  %mul161 = mul nsw i64 %add158, %conv160
  %mul162 = shl nsw i32 %rem36.decomposed, 3
  %conv163 = sext i32 %mul162 to i64
  %add164 = add nsw i64 %mul161, %conv163
  %403 = zext i1 %cmp149 to i32
  %404 = extractelement <2 x float> %os.sroa.0.6, i32 %403
  %mul175 = fmul float %404, %12
  %405 = tail call float @llvm.fabs.f32(float %mul175) #3
  %cmp.i351 = fcmp ugt float %405, 2.500000e-01
  br i1 %cmp.i351, label %cond.false.i353, label %_Z5pack4f.exit369

cond.false.i353.1:                                ; preds = %_Z5pack4f.exit
  %cmp1.i352.1 = fcmp olt float %88, 7.500000e-01
  br i1 %cmp1.i352.1, label %_Z5pack4f.exit369.1, label %cond.false3.i355.1

cond.false3.i355.1:                               ; preds = %cond.false.i353.1
  %cmp4.i354.1 = fcmp ugt float %88, 1.250000e+00
  br i1 %cmp4.i354.1, label %cond.false6.i357.1, label %_Z5pack4f.exit369.1

cond.false6.i357.1:                               ; preds = %cond.false3.i355.1
  %cmp7.i356.1 = fcmp olt float %88, 1.750000e+00
  br i1 %cmp7.i356.1, label %_Z5pack4f.exit369.1, label %cond.false9.i359.1

cond.false9.i359.1:                               ; preds = %cond.false6.i357.1
  %cmp10.i358.1 = fcmp ugt float %88, 2.500000e+00
  br i1 %cmp10.i358.1, label %cond.false12.i361.1, label %_Z5pack4f.exit369.1

cond.false12.i361.1:                              ; preds = %cond.false9.i359.1
  %cmp13.i360.1 = fcmp olt float %88, 3.500000e+00
  br i1 %cmp13.i360.1, label %_Z5pack4f.exit369.1, label %cond.false15.i364.1

cond.false15.i364.1:                              ; preds = %cond.false12.i361.1
  %cmp16.i362.1 = fcmp ole float %88, 5.000000e+00
  %cond.i363.1 = select i1 %cmp16.i362.1, i32 6, i32 7
  br label %_Z5pack4f.exit369.1

_Z5pack4f.exit369.1:                              ; preds = %cond.false15.i364.1, %cond.false12.i361.1, %cond.false9.i359.1, %cond.false6.i357.1, %cond.false3.i355.1, %cond.false.i353.1, %_Z5pack4f.exit
  %cond27.i365.1 = phi i32 [ 0, %_Z5pack4f.exit ], [ 1, %cond.false.i353.1 ], [ 2, %cond.false3.i355.1 ], [ 3, %cond.false6.i357.1 ], [ 4, %cond.false9.i359.1 ], [ 5, %cond.false12.i361.1 ], [ %cond.i363.1, %cond.false15.i364.1 ]
  %406 = bitcast float %mul175.1 to i32
  %shr.i366.1 = lshr i32 %406, 28
  %and.i367.1 = and i32 %shr.i366.1, 8
  %or.i368.1 = or i32 %cond27.i365.1, %and.i367.1
  %mul183.1 = fmul float %404, %24
  %407 = tail call float @llvm.fabs.f32(float %mul183.1) #3
  %cmp.i.1 = fcmp ugt float %407, 2.500000e-01
  br i1 %cmp.i.1, label %cond.false.i.1, label %_Z5pack4f.exit.1

cond.false.i.1:                                   ; preds = %_Z5pack4f.exit369.1
  %cmp1.i.1 = fcmp olt float %407, 7.500000e-01
  br i1 %cmp1.i.1, label %_Z5pack4f.exit.1, label %cond.false3.i.1

cond.false3.i.1:                                  ; preds = %cond.false.i.1
  %cmp4.i.1 = fcmp ugt float %407, 1.250000e+00
  br i1 %cmp4.i.1, label %cond.false6.i.1, label %_Z5pack4f.exit.1

cond.false6.i.1:                                  ; preds = %cond.false3.i.1
  %cmp7.i.1 = fcmp olt float %407, 1.750000e+00
  br i1 %cmp7.i.1, label %_Z5pack4f.exit.1, label %cond.false9.i.1

cond.false9.i.1:                                  ; preds = %cond.false6.i.1
  %cmp10.i.1 = fcmp ugt float %407, 2.500000e+00
  br i1 %cmp10.i.1, label %cond.false12.i.1, label %_Z5pack4f.exit.1

cond.false12.i.1:                                 ; preds = %cond.false9.i.1
  %cmp13.i.1 = fcmp olt float %407, 3.500000e+00
  br i1 %cmp13.i.1, label %_Z5pack4f.exit.1, label %cond.false15.i.1

cond.false15.i.1:                                 ; preds = %cond.false12.i.1
  %cmp16.i.1 = fcmp ole float %407, 5.000000e+00
  %cond.i.1 = select i1 %cmp16.i.1, i32 6, i32 7
  br label %_Z5pack4f.exit.1

_Z5pack4f.exit.1:                                 ; preds = %cond.false15.i.1, %cond.false12.i.1, %cond.false9.i.1, %cond.false6.i.1, %cond.false3.i.1, %cond.false.i.1, %_Z5pack4f.exit369.1
  %cond27.i.1 = phi i32 [ 0, %_Z5pack4f.exit369.1 ], [ 1, %cond.false.i.1 ], [ 2, %cond.false3.i.1 ], [ 3, %cond.false6.i.1 ], [ 4, %cond.false9.i.1 ], [ 5, %cond.false12.i.1 ], [ %cond.i.1, %cond.false15.i.1 ]
  %408 = bitcast float %mul183.1 to i32
  %shr.i.1 = lshr i32 %408, 28
  %and.i.1 = and i32 %shr.i.1, 8
  %or.i.1 = or i32 %cond27.i.1, %and.i.1
  %shl.1 = shl nuw nsw i32 %or.i.1, 4
  %or.1 = or i32 %or.i368.1, %shl.1
  %conv185.1 = trunc i32 %or.1 to i8
  %add187.1 = add nsw i64 %add164, 1
  %arrayidx188339.1 = getelementptr inbounds i8, i8 addrspace(1)* %cond19.v, i64 %add187.1
  store i8 %conv185.1, i8 addrspace(1)* %arrayidx188339.1, align 1, !tbaa !12
  %mul175.2 = fmul float %404, %28
  %409 = tail call float @llvm.fabs.f32(float %mul175.2) #3
  %cmp.i351.2 = fcmp ugt float %409, 2.500000e-01
  br i1 %cmp.i351.2, label %cond.false.i353.2, label %_Z5pack4f.exit369.2

cond.false.i353.2:                                ; preds = %_Z5pack4f.exit.1
  %cmp1.i352.2 = fcmp olt float %409, 7.500000e-01
  br i1 %cmp1.i352.2, label %_Z5pack4f.exit369.2, label %cond.false3.i355.2

cond.false3.i355.2:                               ; preds = %cond.false.i353.2
  %cmp4.i354.2 = fcmp ugt float %409, 1.250000e+00
  br i1 %cmp4.i354.2, label %cond.false6.i357.2, label %_Z5pack4f.exit369.2

cond.false6.i357.2:                               ; preds = %cond.false3.i355.2
  %cmp7.i356.2 = fcmp olt float %409, 1.750000e+00
  br i1 %cmp7.i356.2, label %_Z5pack4f.exit369.2, label %cond.false9.i359.2

cond.false9.i359.2:                               ; preds = %cond.false6.i357.2
  %cmp10.i358.2 = fcmp ugt float %409, 2.500000e+00
  br i1 %cmp10.i358.2, label %cond.false12.i361.2, label %_Z5pack4f.exit369.2

cond.false12.i361.2:                              ; preds = %cond.false9.i359.2
  %cmp13.i360.2 = fcmp olt float %409, 3.500000e+00
  br i1 %cmp13.i360.2, label %_Z5pack4f.exit369.2, label %cond.false15.i364.2

cond.false15.i364.2:                              ; preds = %cond.false12.i361.2
  %cmp16.i362.2 = fcmp ole float %409, 5.000000e+00
  %cond.i363.2 = select i1 %cmp16.i362.2, i32 6, i32 7
  br label %_Z5pack4f.exit369.2

_Z5pack4f.exit369.2:                              ; preds = %cond.false15.i364.2, %cond.false12.i361.2, %cond.false9.i359.2, %cond.false6.i357.2, %cond.false3.i355.2, %cond.false.i353.2, %_Z5pack4f.exit.1
  %cond27.i365.2 = phi i32 [ 0, %_Z5pack4f.exit.1 ], [ 1, %cond.false.i353.2 ], [ 2, %cond.false3.i355.2 ], [ 3, %cond.false6.i357.2 ], [ 4, %cond.false9.i359.2 ], [ 5, %cond.false12.i361.2 ], [ %cond.i363.2, %cond.false15.i364.2 ]
  %410 = bitcast float %mul175.2 to i32
  %shr.i366.2 = lshr i32 %410, 28
  %and.i367.2 = and i32 %shr.i366.2, 8
  %or.i368.2 = or i32 %cond27.i365.2, %and.i367.2
  %mul183.2 = fmul float %404, %32
  %411 = tail call float @llvm.fabs.f32(float %mul183.2) #3
  %cmp.i.2 = fcmp ugt float %411, 2.500000e-01
  br i1 %cmp.i.2, label %cond.false.i.2, label %_Z5pack4f.exit.2

cond.false.i.2:                                   ; preds = %_Z5pack4f.exit369.2
  %cmp1.i.2 = fcmp olt float %411, 7.500000e-01
  br i1 %cmp1.i.2, label %_Z5pack4f.exit.2, label %cond.false3.i.2

cond.false3.i.2:                                  ; preds = %cond.false.i.2
  %cmp4.i.2 = fcmp ugt float %411, 1.250000e+00
  br i1 %cmp4.i.2, label %cond.false6.i.2, label %_Z5pack4f.exit.2

cond.false6.i.2:                                  ; preds = %cond.false3.i.2
  %cmp7.i.2 = fcmp olt float %411, 1.750000e+00
  br i1 %cmp7.i.2, label %_Z5pack4f.exit.2, label %cond.false9.i.2

cond.false9.i.2:                                  ; preds = %cond.false6.i.2
  %cmp10.i.2 = fcmp ugt float %411, 2.500000e+00
  br i1 %cmp10.i.2, label %cond.false12.i.2, label %_Z5pack4f.exit.2

cond.false12.i.2:                                 ; preds = %cond.false9.i.2
  %cmp13.i.2 = fcmp olt float %411, 3.500000e+00
  br i1 %cmp13.i.2, label %_Z5pack4f.exit.2, label %cond.false15.i.2

cond.false15.i.2:                                 ; preds = %cond.false12.i.2
  %cmp16.i.2 = fcmp ole float %411, 5.000000e+00
  %cond.i.2 = select i1 %cmp16.i.2, i32 6, i32 7
  br label %_Z5pack4f.exit.2

_Z5pack4f.exit.2:                                 ; preds = %cond.false15.i.2, %cond.false12.i.2, %cond.false9.i.2, %cond.false6.i.2, %cond.false3.i.2, %cond.false.i.2, %_Z5pack4f.exit369.2
  %cond27.i.2 = phi i32 [ 0, %_Z5pack4f.exit369.2 ], [ 1, %cond.false.i.2 ], [ 2, %cond.false3.i.2 ], [ 3, %cond.false6.i.2 ], [ 4, %cond.false9.i.2 ], [ 5, %cond.false12.i.2 ], [ %cond.i.2, %cond.false15.i.2 ]
  %412 = bitcast float %mul183.2 to i32
  %shr.i.2 = lshr i32 %412, 28
  %and.i.2 = and i32 %shr.i.2, 8
  %or.i.2 = or i32 %cond27.i.2, %and.i.2
  %shl.2 = shl nuw nsw i32 %or.i.2, 4
  %or.2 = or i32 %or.i368.2, %shl.2
  %conv185.2 = trunc i32 %or.2 to i8
  %add187.2 = add nsw i64 %add164, 2
  %arrayidx188339.2 = getelementptr inbounds i8, i8 addrspace(1)* %cond19.v, i64 %add187.2
  store i8 %conv185.2, i8 addrspace(1)* %arrayidx188339.2, align 1, !tbaa !12
  %mul175.3 = fmul float %404, %36
  %413 = tail call float @llvm.fabs.f32(float %mul175.3) #3
  %cmp.i351.3 = fcmp ugt float %413, 2.500000e-01
  br i1 %cmp.i351.3, label %cond.false.i353.3, label %_Z5pack4f.exit369.3

cond.false.i353.3:                                ; preds = %_Z5pack4f.exit.2
  %cmp1.i352.3 = fcmp olt float %413, 7.500000e-01
  br i1 %cmp1.i352.3, label %_Z5pack4f.exit369.3, label %cond.false3.i355.3

cond.false3.i355.3:                               ; preds = %cond.false.i353.3
  %cmp4.i354.3 = fcmp ugt float %413, 1.250000e+00
  br i1 %cmp4.i354.3, label %cond.false6.i357.3, label %_Z5pack4f.exit369.3

cond.false6.i357.3:                               ; preds = %cond.false3.i355.3
  %cmp7.i356.3 = fcmp olt float %413, 1.750000e+00
  br i1 %cmp7.i356.3, label %_Z5pack4f.exit369.3, label %cond.false9.i359.3

cond.false9.i359.3:                               ; preds = %cond.false6.i357.3
  %cmp10.i358.3 = fcmp ugt float %413, 2.500000e+00
  br i1 %cmp10.i358.3, label %cond.false12.i361.3, label %_Z5pack4f.exit369.3

cond.false12.i361.3:                              ; preds = %cond.false9.i359.3
  %cmp13.i360.3 = fcmp olt float %413, 3.500000e+00
  br i1 %cmp13.i360.3, label %_Z5pack4f.exit369.3, label %cond.false15.i364.3

cond.false15.i364.3:                              ; preds = %cond.false12.i361.3
  %cmp16.i362.3 = fcmp ole float %413, 5.000000e+00
  %cond.i363.3 = select i1 %cmp16.i362.3, i32 6, i32 7
  br label %_Z5pack4f.exit369.3

_Z5pack4f.exit369.3:                              ; preds = %cond.false15.i364.3, %cond.false12.i361.3, %cond.false9.i359.3, %cond.false6.i357.3, %cond.false3.i355.3, %cond.false.i353.3, %_Z5pack4f.exit.2
  %cond27.i365.3 = phi i32 [ 0, %_Z5pack4f.exit.2 ], [ 1, %cond.false.i353.3 ], [ 2, %cond.false3.i355.3 ], [ 3, %cond.false6.i357.3 ], [ 4, %cond.false9.i359.3 ], [ 5, %cond.false12.i361.3 ], [ %cond.i363.3, %cond.false15.i364.3 ]
  %414 = bitcast float %mul175.3 to i32
  %shr.i366.3 = lshr i32 %414, 28
  %and.i367.3 = and i32 %shr.i366.3, 8
  %or.i368.3 = or i32 %cond27.i365.3, %and.i367.3
  %mul183.3 = fmul float %404, %40
  %415 = tail call float @llvm.fabs.f32(float %mul183.3) #3
  %cmp.i.3 = fcmp ugt float %415, 2.500000e-01
  br i1 %cmp.i.3, label %cond.false.i.3, label %_Z5pack4f.exit.3

cond.false.i.3:                                   ; preds = %_Z5pack4f.exit369.3
  %cmp1.i.3 = fcmp olt float %415, 7.500000e-01
  br i1 %cmp1.i.3, label %_Z5pack4f.exit.3, label %cond.false3.i.3

cond.false3.i.3:                                  ; preds = %cond.false.i.3
  %cmp4.i.3 = fcmp ugt float %415, 1.250000e+00
  br i1 %cmp4.i.3, label %cond.false6.i.3, label %_Z5pack4f.exit.3

cond.false6.i.3:                                  ; preds = %cond.false3.i.3
  %cmp7.i.3 = fcmp olt float %415, 1.750000e+00
  br i1 %cmp7.i.3, label %_Z5pack4f.exit.3, label %cond.false9.i.3

cond.false9.i.3:                                  ; preds = %cond.false6.i.3
  %cmp10.i.3 = fcmp ugt float %415, 2.500000e+00
  br i1 %cmp10.i.3, label %cond.false12.i.3, label %_Z5pack4f.exit.3

cond.false12.i.3:                                 ; preds = %cond.false9.i.3
  %cmp13.i.3 = fcmp olt float %415, 3.500000e+00
  br i1 %cmp13.i.3, label %_Z5pack4f.exit.3, label %cond.false15.i.3

cond.false15.i.3:                                 ; preds = %cond.false12.i.3
  %cmp16.i.3 = fcmp ole float %415, 5.000000e+00
  %cond.i.3 = select i1 %cmp16.i.3, i32 6, i32 7
  br label %_Z5pack4f.exit.3

_Z5pack4f.exit.3:                                 ; preds = %cond.false15.i.3, %cond.false12.i.3, %cond.false9.i.3, %cond.false6.i.3, %cond.false3.i.3, %cond.false.i.3, %_Z5pack4f.exit369.3
  %cond27.i.3 = phi i32 [ 0, %_Z5pack4f.exit369.3 ], [ 1, %cond.false.i.3 ], [ 2, %cond.false3.i.3 ], [ 3, %cond.false6.i.3 ], [ 4, %cond.false9.i.3 ], [ 5, %cond.false12.i.3 ], [ %cond.i.3, %cond.false15.i.3 ]
  %416 = bitcast float %mul183.3 to i32
  %shr.i.3 = lshr i32 %416, 28
  %and.i.3 = and i32 %shr.i.3, 8
  %or.i.3 = or i32 %cond27.i.3, %and.i.3
  %shl.3 = shl nuw nsw i32 %or.i.3, 4
  %or.3 = or i32 %or.i368.3, %shl.3
  %conv185.3 = trunc i32 %or.3 to i8
  %add187.3 = add nsw i64 %add164, 3
  %arrayidx188339.3 = getelementptr inbounds i8, i8 addrspace(1)* %cond19.v, i64 %add187.3
  store i8 %conv185.3, i8 addrspace(1)* %arrayidx188339.3, align 1, !tbaa !12
  %mul175.4 = fmul float %404, %44
  %417 = tail call float @llvm.fabs.f32(float %mul175.4) #3
  %cmp.i351.4 = fcmp ugt float %417, 2.500000e-01
  br i1 %cmp.i351.4, label %cond.false.i353.4, label %_Z5pack4f.exit369.4

cond.false.i353.4:                                ; preds = %_Z5pack4f.exit.3
  %cmp1.i352.4 = fcmp olt float %417, 7.500000e-01
  br i1 %cmp1.i352.4, label %_Z5pack4f.exit369.4, label %cond.false3.i355.4

cond.false3.i355.4:                               ; preds = %cond.false.i353.4
  %cmp4.i354.4 = fcmp ugt float %417, 1.250000e+00
  br i1 %cmp4.i354.4, label %cond.false6.i357.4, label %_Z5pack4f.exit369.4

cond.false6.i357.4:                               ; preds = %cond.false3.i355.4
  %cmp7.i356.4 = fcmp olt float %417, 1.750000e+00
  br i1 %cmp7.i356.4, label %_Z5pack4f.exit369.4, label %cond.false9.i359.4

cond.false9.i359.4:                               ; preds = %cond.false6.i357.4
  %cmp10.i358.4 = fcmp ugt float %417, 2.500000e+00
  br i1 %cmp10.i358.4, label %cond.false12.i361.4, label %_Z5pack4f.exit369.4

cond.false12.i361.4:                              ; preds = %cond.false9.i359.4
  %cmp13.i360.4 = fcmp olt float %417, 3.500000e+00
  br i1 %cmp13.i360.4, label %_Z5pack4f.exit369.4, label %cond.false15.i364.4

cond.false15.i364.4:                              ; preds = %cond.false12.i361.4
  %cmp16.i362.4 = fcmp ole float %417, 5.000000e+00
  %cond.i363.4 = select i1 %cmp16.i362.4, i32 6, i32 7
  br label %_Z5pack4f.exit369.4

_Z5pack4f.exit369.4:                              ; preds = %cond.false15.i364.4, %cond.false12.i361.4, %cond.false9.i359.4, %cond.false6.i357.4, %cond.false3.i355.4, %cond.false.i353.4, %_Z5pack4f.exit.3
  %cond27.i365.4 = phi i32 [ 0, %_Z5pack4f.exit.3 ], [ 1, %cond.false.i353.4 ], [ 2, %cond.false3.i355.4 ], [ 3, %cond.false6.i357.4 ], [ 4, %cond.false9.i359.4 ], [ 5, %cond.false12.i361.4 ], [ %cond.i363.4, %cond.false15.i364.4 ]
  %418 = bitcast float %mul175.4 to i32
  %shr.i366.4 = lshr i32 %418, 28
  %and.i367.4 = and i32 %shr.i366.4, 8
  %or.i368.4 = or i32 %cond27.i365.4, %and.i367.4
  %mul183.4 = fmul float %404, %48
  %419 = tail call float @llvm.fabs.f32(float %mul183.4) #3
  %cmp.i.4 = fcmp ugt float %419, 2.500000e-01
  br i1 %cmp.i.4, label %cond.false.i.4, label %_Z5pack4f.exit.4

cond.false.i.4:                                   ; preds = %_Z5pack4f.exit369.4
  %cmp1.i.4 = fcmp olt float %419, 7.500000e-01
  br i1 %cmp1.i.4, label %_Z5pack4f.exit.4, label %cond.false3.i.4

cond.false3.i.4:                                  ; preds = %cond.false.i.4
  %cmp4.i.4 = fcmp ugt float %419, 1.250000e+00
  br i1 %cmp4.i.4, label %cond.false6.i.4, label %_Z5pack4f.exit.4

cond.false6.i.4:                                  ; preds = %cond.false3.i.4
  %cmp7.i.4 = fcmp olt float %419, 1.750000e+00
  br i1 %cmp7.i.4, label %_Z5pack4f.exit.4, label %cond.false9.i.4

cond.false9.i.4:                                  ; preds = %cond.false6.i.4
  %cmp10.i.4 = fcmp ugt float %419, 2.500000e+00
  br i1 %cmp10.i.4, label %cond.false12.i.4, label %_Z5pack4f.exit.4

cond.false12.i.4:                                 ; preds = %cond.false9.i.4
  %cmp13.i.4 = fcmp olt float %419, 3.500000e+00
  br i1 %cmp13.i.4, label %_Z5pack4f.exit.4, label %cond.false15.i.4

cond.false15.i.4:                                 ; preds = %cond.false12.i.4
  %cmp16.i.4 = fcmp ole float %419, 5.000000e+00
  %cond.i.4 = select i1 %cmp16.i.4, i32 6, i32 7
  br label %_Z5pack4f.exit.4

_Z5pack4f.exit.4:                                 ; preds = %cond.false15.i.4, %cond.false12.i.4, %cond.false9.i.4, %cond.false6.i.4, %cond.false3.i.4, %cond.false.i.4, %_Z5pack4f.exit369.4
  %cond27.i.4 = phi i32 [ 0, %_Z5pack4f.exit369.4 ], [ 1, %cond.false.i.4 ], [ 2, %cond.false3.i.4 ], [ 3, %cond.false6.i.4 ], [ 4, %cond.false9.i.4 ], [ 5, %cond.false12.i.4 ], [ %cond.i.4, %cond.false15.i.4 ]
  %420 = bitcast float %mul183.4 to i32
  %shr.i.4 = lshr i32 %420, 28
  %and.i.4 = and i32 %shr.i.4, 8
  %or.i.4 = or i32 %cond27.i.4, %and.i.4
  %shl.4 = shl nuw nsw i32 %or.i.4, 4
  %or.4 = or i32 %or.i368.4, %shl.4
  %conv185.4 = trunc i32 %or.4 to i8
  %add187.4 = add nsw i64 %add164, 4
  %arrayidx188339.4 = getelementptr inbounds i8, i8 addrspace(1)* %cond19.v, i64 %add187.4
  store i8 %conv185.4, i8 addrspace(1)* %arrayidx188339.4, align 1, !tbaa !12
  %mul175.5 = fmul float %404, %52
  %421 = tail call float @llvm.fabs.f32(float %mul175.5) #3
  %cmp.i351.5 = fcmp ugt float %421, 2.500000e-01
  br i1 %cmp.i351.5, label %cond.false.i353.5, label %_Z5pack4f.exit369.5

cond.false.i353.5:                                ; preds = %_Z5pack4f.exit.4
  %cmp1.i352.5 = fcmp olt float %421, 7.500000e-01
  br i1 %cmp1.i352.5, label %_Z5pack4f.exit369.5, label %cond.false3.i355.5

cond.false3.i355.5:                               ; preds = %cond.false.i353.5
  %cmp4.i354.5 = fcmp ugt float %421, 1.250000e+00
  br i1 %cmp4.i354.5, label %cond.false6.i357.5, label %_Z5pack4f.exit369.5

cond.false6.i357.5:                               ; preds = %cond.false3.i355.5
  %cmp7.i356.5 = fcmp olt float %421, 1.750000e+00
  br i1 %cmp7.i356.5, label %_Z5pack4f.exit369.5, label %cond.false9.i359.5

cond.false9.i359.5:                               ; preds = %cond.false6.i357.5
  %cmp10.i358.5 = fcmp ugt float %421, 2.500000e+00
  br i1 %cmp10.i358.5, label %cond.false12.i361.5, label %_Z5pack4f.exit369.5

cond.false12.i361.5:                              ; preds = %cond.false9.i359.5
  %cmp13.i360.5 = fcmp olt float %421, 3.500000e+00
  br i1 %cmp13.i360.5, label %_Z5pack4f.exit369.5, label %cond.false15.i364.5

cond.false15.i364.5:                              ; preds = %cond.false12.i361.5
  %cmp16.i362.5 = fcmp ole float %421, 5.000000e+00
  %cond.i363.5 = select i1 %cmp16.i362.5, i32 6, i32 7
  br label %_Z5pack4f.exit369.5

_Z5pack4f.exit369.5:                              ; preds = %cond.false15.i364.5, %cond.false12.i361.5, %cond.false9.i359.5, %cond.false6.i357.5, %cond.false3.i355.5, %cond.false.i353.5, %_Z5pack4f.exit.4
  %cond27.i365.5 = phi i32 [ 0, %_Z5pack4f.exit.4 ], [ 1, %cond.false.i353.5 ], [ 2, %cond.false3.i355.5 ], [ 3, %cond.false6.i357.5 ], [ 4, %cond.false9.i359.5 ], [ 5, %cond.false12.i361.5 ], [ %cond.i363.5, %cond.false15.i364.5 ]
  %422 = bitcast float %mul175.5 to i32
  %shr.i366.5 = lshr i32 %422, 28
  %and.i367.5 = and i32 %shr.i366.5, 8
  %or.i368.5 = or i32 %cond27.i365.5, %and.i367.5
  %mul183.5 = fmul float %404, %56
  %423 = tail call float @llvm.fabs.f32(float %mul183.5) #3
  %cmp.i.5 = fcmp ugt float %423, 2.500000e-01
  br i1 %cmp.i.5, label %cond.false.i.5, label %_Z5pack4f.exit.5

cond.false.i.5:                                   ; preds = %_Z5pack4f.exit369.5
  %cmp1.i.5 = fcmp olt float %423, 7.500000e-01
  br i1 %cmp1.i.5, label %_Z5pack4f.exit.5, label %cond.false3.i.5

cond.false3.i.5:                                  ; preds = %cond.false.i.5
  %cmp4.i.5 = fcmp ugt float %423, 1.250000e+00
  br i1 %cmp4.i.5, label %cond.false6.i.5, label %_Z5pack4f.exit.5

cond.false6.i.5:                                  ; preds = %cond.false3.i.5
  %cmp7.i.5 = fcmp olt float %423, 1.750000e+00
  br i1 %cmp7.i.5, label %_Z5pack4f.exit.5, label %cond.false9.i.5

cond.false9.i.5:                                  ; preds = %cond.false6.i.5
  %cmp10.i.5 = fcmp ugt float %423, 2.500000e+00
  br i1 %cmp10.i.5, label %cond.false12.i.5, label %_Z5pack4f.exit.5

cond.false12.i.5:                                 ; preds = %cond.false9.i.5
  %cmp13.i.5 = fcmp olt float %423, 3.500000e+00
  br i1 %cmp13.i.5, label %_Z5pack4f.exit.5, label %cond.false15.i.5

cond.false15.i.5:                                 ; preds = %cond.false12.i.5
  %cmp16.i.5 = fcmp ole float %423, 5.000000e+00
  %cond.i.5 = select i1 %cmp16.i.5, i32 6, i32 7
  br label %_Z5pack4f.exit.5

_Z5pack4f.exit.5:                                 ; preds = %cond.false15.i.5, %cond.false12.i.5, %cond.false9.i.5, %cond.false6.i.5, %cond.false3.i.5, %cond.false.i.5, %_Z5pack4f.exit369.5
  %cond27.i.5 = phi i32 [ 0, %_Z5pack4f.exit369.5 ], [ 1, %cond.false.i.5 ], [ 2, %cond.false3.i.5 ], [ 3, %cond.false6.i.5 ], [ 4, %cond.false9.i.5 ], [ 5, %cond.false12.i.5 ], [ %cond.i.5, %cond.false15.i.5 ]
  %424 = bitcast float %mul183.5 to i32
  %shr.i.5 = lshr i32 %424, 28
  %and.i.5 = and i32 %shr.i.5, 8
  %or.i.5 = or i32 %cond27.i.5, %and.i.5
  %shl.5 = shl nuw nsw i32 %or.i.5, 4
  %or.5 = or i32 %or.i368.5, %shl.5
  %conv185.5 = trunc i32 %or.5 to i8
  %add187.5 = add nsw i64 %add164, 5
  %arrayidx188339.5 = getelementptr inbounds i8, i8 addrspace(1)* %cond19.v, i64 %add187.5
  store i8 %conv185.5, i8 addrspace(1)* %arrayidx188339.5, align 1, !tbaa !12
  %mul175.6 = fmul float %404, %60
  %425 = tail call float @llvm.fabs.f32(float %mul175.6) #3
  %cmp.i351.6 = fcmp ugt float %425, 2.500000e-01
  br i1 %cmp.i351.6, label %cond.false.i353.6, label %_Z5pack4f.exit369.6

cond.false.i353.6:                                ; preds = %_Z5pack4f.exit.5
  %cmp1.i352.6 = fcmp olt float %425, 7.500000e-01
  br i1 %cmp1.i352.6, label %_Z5pack4f.exit369.6, label %cond.false3.i355.6

cond.false3.i355.6:                               ; preds = %cond.false.i353.6
  %cmp4.i354.6 = fcmp ugt float %425, 1.250000e+00
  br i1 %cmp4.i354.6, label %cond.false6.i357.6, label %_Z5pack4f.exit369.6

cond.false6.i357.6:                               ; preds = %cond.false3.i355.6
  %cmp7.i356.6 = fcmp olt float %425, 1.750000e+00
  br i1 %cmp7.i356.6, label %_Z5pack4f.exit369.6, label %cond.false9.i359.6

cond.false9.i359.6:                               ; preds = %cond.false6.i357.6
  %cmp10.i358.6 = fcmp ugt float %425, 2.500000e+00
  br i1 %cmp10.i358.6, label %cond.false12.i361.6, label %_Z5pack4f.exit369.6

cond.false12.i361.6:                              ; preds = %cond.false9.i359.6
  %cmp13.i360.6 = fcmp olt float %425, 3.500000e+00
  br i1 %cmp13.i360.6, label %_Z5pack4f.exit369.6, label %cond.false15.i364.6

cond.false15.i364.6:                              ; preds = %cond.false12.i361.6
  %cmp16.i362.6 = fcmp ole float %425, 5.000000e+00
  %cond.i363.6 = select i1 %cmp16.i362.6, i32 6, i32 7
  br label %_Z5pack4f.exit369.6

_Z5pack4f.exit369.6:                              ; preds = %cond.false15.i364.6, %cond.false12.i361.6, %cond.false9.i359.6, %cond.false6.i357.6, %cond.false3.i355.6, %cond.false.i353.6, %_Z5pack4f.exit.5
  %cond27.i365.6 = phi i32 [ 0, %_Z5pack4f.exit.5 ], [ 1, %cond.false.i353.6 ], [ 2, %cond.false3.i355.6 ], [ 3, %cond.false6.i357.6 ], [ 4, %cond.false9.i359.6 ], [ 5, %cond.false12.i361.6 ], [ %cond.i363.6, %cond.false15.i364.6 ]
  %426 = bitcast float %mul175.6 to i32
  %shr.i366.6 = lshr i32 %426, 28
  %and.i367.6 = and i32 %shr.i366.6, 8
  %or.i368.6 = or i32 %cond27.i365.6, %and.i367.6
  %mul183.6 = fmul float %404, %64
  %427 = tail call float @llvm.fabs.f32(float %mul183.6) #3
  %cmp.i.6 = fcmp ugt float %427, 2.500000e-01
  br i1 %cmp.i.6, label %cond.false.i.6, label %_Z5pack4f.exit.6

cond.false.i.6:                                   ; preds = %_Z5pack4f.exit369.6
  %cmp1.i.6 = fcmp olt float %427, 7.500000e-01
  br i1 %cmp1.i.6, label %_Z5pack4f.exit.6, label %cond.false3.i.6

cond.false3.i.6:                                  ; preds = %cond.false.i.6
  %cmp4.i.6 = fcmp ugt float %427, 1.250000e+00
  br i1 %cmp4.i.6, label %cond.false6.i.6, label %_Z5pack4f.exit.6

cond.false6.i.6:                                  ; preds = %cond.false3.i.6
  %cmp7.i.6 = fcmp olt float %427, 1.750000e+00
  br i1 %cmp7.i.6, label %_Z5pack4f.exit.6, label %cond.false9.i.6

cond.false9.i.6:                                  ; preds = %cond.false6.i.6
  %cmp10.i.6 = fcmp ugt float %427, 2.500000e+00
  br i1 %cmp10.i.6, label %cond.false12.i.6, label %_Z5pack4f.exit.6

cond.false12.i.6:                                 ; preds = %cond.false9.i.6
  %cmp13.i.6 = fcmp olt float %427, 3.500000e+00
  br i1 %cmp13.i.6, label %_Z5pack4f.exit.6, label %cond.false15.i.6

cond.false15.i.6:                                 ; preds = %cond.false12.i.6
  %cmp16.i.6 = fcmp ole float %427, 5.000000e+00
  %cond.i.6 = select i1 %cmp16.i.6, i32 6, i32 7
  br label %_Z5pack4f.exit.6

_Z5pack4f.exit.6:                                 ; preds = %cond.false15.i.6, %cond.false12.i.6, %cond.false9.i.6, %cond.false6.i.6, %cond.false3.i.6, %cond.false.i.6, %_Z5pack4f.exit369.6
  %cond27.i.6 = phi i32 [ 0, %_Z5pack4f.exit369.6 ], [ 1, %cond.false.i.6 ], [ 2, %cond.false3.i.6 ], [ 3, %cond.false6.i.6 ], [ 4, %cond.false9.i.6 ], [ 5, %cond.false12.i.6 ], [ %cond.i.6, %cond.false15.i.6 ]
  %428 = bitcast float %mul183.6 to i32
  %shr.i.6 = lshr i32 %428, 28
  %and.i.6 = and i32 %shr.i.6, 8
  %or.i.6 = or i32 %cond27.i.6, %and.i.6
  %shl.6 = shl nuw nsw i32 %or.i.6, 4
  %or.6 = or i32 %or.i368.6, %shl.6
  %conv185.6 = trunc i32 %or.6 to i8
  %add187.6 = add nsw i64 %add164, 6
  %arrayidx188339.6 = getelementptr inbounds i8, i8 addrspace(1)* %cond19.v, i64 %add187.6
  store i8 %conv185.6, i8 addrspace(1)* %arrayidx188339.6, align 1, !tbaa !12
  %mul175.7 = fmul float %74, %404
  %429 = tail call float @llvm.fabs.f32(float %mul175.7) #3
  %cmp.i351.7 = fcmp ugt float %429, 2.500000e-01
  br i1 %cmp.i351.7, label %cond.false.i353.7, label %_Z5pack4f.exit369.7

cond.false.i353.7:                                ; preds = %_Z5pack4f.exit.6
  %cmp1.i352.7 = fcmp olt float %429, 7.500000e-01
  br i1 %cmp1.i352.7, label %_Z5pack4f.exit369.7, label %cond.false3.i355.7

cond.false3.i355.7:                               ; preds = %cond.false.i353.7
  %cmp4.i354.7 = fcmp ugt float %429, 1.250000e+00
  br i1 %cmp4.i354.7, label %cond.false6.i357.7, label %_Z5pack4f.exit369.7

cond.false6.i357.7:                               ; preds = %cond.false3.i355.7
  %cmp7.i356.7 = fcmp olt float %429, 1.750000e+00
  br i1 %cmp7.i356.7, label %_Z5pack4f.exit369.7, label %cond.false9.i359.7

cond.false9.i359.7:                               ; preds = %cond.false6.i357.7
  %cmp10.i358.7 = fcmp ugt float %429, 2.500000e+00
  br i1 %cmp10.i358.7, label %cond.false12.i361.7, label %_Z5pack4f.exit369.7

cond.false12.i361.7:                              ; preds = %cond.false9.i359.7
  %cmp13.i360.7 = fcmp olt float %429, 3.500000e+00
  br i1 %cmp13.i360.7, label %_Z5pack4f.exit369.7, label %cond.false15.i364.7

cond.false15.i364.7:                              ; preds = %cond.false12.i361.7
  %cmp16.i362.7 = fcmp ole float %429, 5.000000e+00
  %cond.i363.7 = select i1 %cmp16.i362.7, i32 6, i32 7
  br label %_Z5pack4f.exit369.7

_Z5pack4f.exit369.7:                              ; preds = %cond.false15.i364.7, %cond.false12.i361.7, %cond.false9.i359.7, %cond.false6.i357.7, %cond.false3.i355.7, %cond.false.i353.7, %_Z5pack4f.exit.6
  %cond27.i365.7 = phi i32 [ 0, %_Z5pack4f.exit.6 ], [ 1, %cond.false.i353.7 ], [ 2, %cond.false3.i355.7 ], [ 3, %cond.false6.i357.7 ], [ 4, %cond.false9.i359.7 ], [ 5, %cond.false12.i361.7 ], [ %cond.i363.7, %cond.false15.i364.7 ]
  %430 = bitcast float %mul175.7 to i32
  %shr.i366.7 = lshr i32 %430, 28
  %and.i367.7 = and i32 %shr.i366.7, 8
  %or.i368.7 = or i32 %cond27.i365.7, %and.i367.7
  %mul183.7 = fmul float %77, %404
  %431 = tail call float @llvm.fabs.f32(float %mul183.7) #3
  %cmp.i.7 = fcmp ugt float %431, 2.500000e-01
  br i1 %cmp.i.7, label %cond.false.i.7, label %_Z5pack4f.exit.7

cond.false.i.7:                                   ; preds = %_Z5pack4f.exit369.7
  %cmp1.i.7 = fcmp olt float %431, 7.500000e-01
  br i1 %cmp1.i.7, label %_Z5pack4f.exit.7, label %cond.false3.i.7

cond.false3.i.7:                                  ; preds = %cond.false.i.7
  %cmp4.i.7 = fcmp ugt float %431, 1.250000e+00
  br i1 %cmp4.i.7, label %cond.false6.i.7, label %_Z5pack4f.exit.7

cond.false6.i.7:                                  ; preds = %cond.false3.i.7
  %cmp7.i.7 = fcmp olt float %431, 1.750000e+00
  br i1 %cmp7.i.7, label %_Z5pack4f.exit.7, label %cond.false9.i.7

cond.false9.i.7:                                  ; preds = %cond.false6.i.7
  %cmp10.i.7 = fcmp ugt float %431, 2.500000e+00
  br i1 %cmp10.i.7, label %cond.false12.i.7, label %_Z5pack4f.exit.7

cond.false12.i.7:                                 ; preds = %cond.false9.i.7
  %cmp13.i.7 = fcmp olt float %431, 3.500000e+00
  br i1 %cmp13.i.7, label %_Z5pack4f.exit.7, label %cond.false15.i.7

cond.false15.i.7:                                 ; preds = %cond.false12.i.7
  %cmp16.i.7 = fcmp ole float %431, 5.000000e+00
  %cond.i.7 = select i1 %cmp16.i.7, i32 6, i32 7
  br label %_Z5pack4f.exit.7

_Z5pack4f.exit.7:                                 ; preds = %cond.false15.i.7, %cond.false12.i.7, %cond.false9.i.7, %cond.false6.i.7, %cond.false3.i.7, %cond.false.i.7, %_Z5pack4f.exit369.7
  %cond27.i.7 = phi i32 [ 0, %_Z5pack4f.exit369.7 ], [ 1, %cond.false.i.7 ], [ 2, %cond.false3.i.7 ], [ 3, %cond.false6.i.7 ], [ 4, %cond.false9.i.7 ], [ 5, %cond.false12.i.7 ], [ %cond.i.7, %cond.false15.i.7 ]
  %432 = bitcast float %mul183.7 to i32
  %shr.i.7 = lshr i32 %432, 28
  %and.i.7 = and i32 %shr.i.7, 8
  %or.i.7 = or i32 %cond27.i.7, %and.i.7
  %shl.7 = shl nuw nsw i32 %or.i.7, 4
  %or.7 = or i32 %or.i368.7, %shl.7
  %conv185.7 = trunc i32 %or.7 to i8
  %add187.7 = add nsw i64 %add164, 7
  %arrayidx188339.7 = getelementptr inbounds i8, i8 addrspace(1)* %cond19.v, i64 %add187.7
  store i8 %conv185.7, i8 addrspace(1)* %arrayidx188339.7, align 1, !tbaa !12
  br i1 %tobool.not, label %if.end204, label %if.then193
}

; Function Attrs: nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.workgroup.id.x() #2

; Function Attrs: nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.workitem.id.x() #2

; Function Attrs: nounwind readnone speculatable willreturn
declare align 4 i8 addrspace(4)* @llvm.amdgcn.dispatch.ptr() #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.fabs.f32(float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.maxnum.f32(float, float) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.amdgcn.ldexp.f32(float, i32) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.copysign.f32(float, float) #2

attributes #0 = { argmemonly nounwind willreturn }
attributes #1 = { norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind readnone speculatable willreturn }
attributes #3 = { nounwind }

!llvm.module.flags = !{!0, !1}
!opencl.ocl.version = !{!2}
!llvm.ident = !{!3, !4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 1}
!2 = !{i32 2, i32 0}
!3 = !{!"clang version 12.0.0 (https://github.com/charitha22/cgo22ae-darm-code.git e9bc0540325ad9806313d34e84fc901496fd8be6)"}
!4 = !{!"clang version 12.0.0 (/src/external/llvm-project/clang dac2bfceaa8d4a90257dc8a6d58f268e172ce00e)"}
!5 = !{!6, !6, i64 0}
!6 = !{!"long", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C++ TBAA"}
!9 = !{i32 0, i32 1024}
!10 = !{!11, !11, i64 0}
!11 = !{!"short", !7, i64 0}
!12 = !{!7, !7, i64 0}
