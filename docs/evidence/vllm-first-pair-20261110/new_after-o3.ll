; ModuleID = '/home/chh/kernel-benchmark-suite-review-speculation/build/decision-fuse/first-pair-comparison/new_after.ll'
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
  br i1 %cmp, label %cleanup, label %if.end, !decision.origin !9

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
  %3 = tail call i32 @llvm.amdgcn.workitem.id.x() #3, !range !10
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
  br label %for.body, !decision.origin !11

for.body:                                         ; preds = %for.cond.cleanup33, %if.end
  %os.sroa.0.0 = phi <2 x float> [ undef, %if.end ], [ %os.sroa.0.1, %for.cond.cleanup33 ]
  %tobool.not = phi i1 [ true, %if.end ], [ false, %for.cond.cleanup33 ]
  %cond.v = select i1 %tobool.not, i16 addrspace(1)* %key.coerce, i16 addrspace(1)* %value.coerce
  %add.ptr331 = getelementptr inbounds i16, i16 addrspace(1)* %cond.v, i64 %mul14
  %cond19.v = select i1 %tobool.not, i8 addrspace(1)* %kd.coerce, i8 addrspace(1)* %vd.coerce
  %cond24.v = select i1 %tobool.not, i8 addrspace(1)* %ks.coerce, i8 addrspace(1)* %vs.coerce
  %cond29 = select i1 %tobool.not, float %kg, float %vg
  br i1 %cmp32418, label %for.body34.lr.ph, label %for.cond.cleanup33, !decision.origin !12

for.body34.lr.ph:                                 ; preds = %for.body
  %div71 = fdiv float 1.000000e+00, %cond29
  br label %for.body34, !decision.origin !13

for.cond.cleanup33:                               ; preds = %if.end204, %for.body
  %os.sroa.0.1 = phi <2 x float> [ %os.sroa.0.0, %for.body ], [ %os.sroa.0.6, %if.end204 ]
  br i1 %tobool.not, label %for.body, label %cleanup, !decision.origin !14

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
  %11 = load i16, i16 addrspace(1)* %arrayidx45347, align 2, !tbaa !15
  %conv.i = zext i16 %11 to i32
  %shl.i = shl nuw i32 %conv.i, 16
  %12 = bitcast i32 %shl.i to float
  %13 = tail call float @llvm.fabs.f32(float %12) #3
  %14 = tail call float @llvm.maxnum.f32(float %13, float 0.000000e+00) #3
  %add43.1 = add nsw i32 %add, 1
  %idxprom44.1 = sext i32 %add43.1 to i64
  %arrayidx45347.1 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.1
  %15 = load i16, i16 addrspace(1)* %arrayidx45347.1, align 2, !tbaa !15
  %conv.i.1 = zext i16 %15 to i32
  %shl.i.1 = shl nuw i32 %conv.i.1, 16
  %16 = bitcast i32 %shl.i.1 to float
  %17 = tail call float @llvm.fabs.f32(float %16) #3
  %18 = tail call float @llvm.maxnum.f32(float %14, float %17) #3
  %add43.2 = add nsw i32 %add, 2
  %idxprom44.2 = sext i32 %add43.2 to i64
  %arrayidx45347.2 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.2
  %19 = load i16, i16 addrspace(1)* %arrayidx45347.2, align 2, !tbaa !15
  %conv.i.2 = zext i16 %19 to i32
  %shl.i.2 = shl nuw i32 %conv.i.2, 16
  %20 = bitcast i32 %shl.i.2 to float
  %21 = tail call float @llvm.fabs.f32(float %20) #3
  %22 = tail call float @llvm.maxnum.f32(float %18, float %21) #3
  %add43.3 = add nsw i32 %add, 3
  %idxprom44.3 = sext i32 %add43.3 to i64
  %arrayidx45347.3 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.3
  %23 = load i16, i16 addrspace(1)* %arrayidx45347.3, align 2, !tbaa !15
  %conv.i.3 = zext i16 %23 to i32
  %shl.i.3 = shl nuw i32 %conv.i.3, 16
  %24 = bitcast i32 %shl.i.3 to float
  %25 = tail call float @llvm.fabs.f32(float %24) #3
  %26 = tail call float @llvm.maxnum.f32(float %22, float %25) #3
  %add43.4 = add nsw i32 %add, 4
  %idxprom44.4 = sext i32 %add43.4 to i64
  %arrayidx45347.4 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.4
  %27 = load i16, i16 addrspace(1)* %arrayidx45347.4, align 2, !tbaa !15
  %conv.i.4 = zext i16 %27 to i32
  %shl.i.4 = shl nuw i32 %conv.i.4, 16
  %28 = bitcast i32 %shl.i.4 to float
  %29 = tail call float @llvm.fabs.f32(float %28) #3
  %30 = tail call float @llvm.maxnum.f32(float %26, float %29) #3
  %add43.5 = add nsw i32 %add, 5
  %idxprom44.5 = sext i32 %add43.5 to i64
  %arrayidx45347.5 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.5
  %31 = load i16, i16 addrspace(1)* %arrayidx45347.5, align 2, !tbaa !15
  %conv.i.5 = zext i16 %31 to i32
  %shl.i.5 = shl nuw i32 %conv.i.5, 16
  %32 = bitcast i32 %shl.i.5 to float
  %33 = tail call float @llvm.fabs.f32(float %32) #3
  %34 = tail call float @llvm.maxnum.f32(float %30, float %33) #3
  %add43.6 = add nsw i32 %add, 6
  %idxprom44.6 = sext i32 %add43.6 to i64
  %arrayidx45347.6 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.6
  %35 = load i16, i16 addrspace(1)* %arrayidx45347.6, align 2, !tbaa !15
  %conv.i.6 = zext i16 %35 to i32
  %shl.i.6 = shl nuw i32 %conv.i.6, 16
  %36 = bitcast i32 %shl.i.6 to float
  %37 = tail call float @llvm.fabs.f32(float %36) #3
  %38 = tail call float @llvm.maxnum.f32(float %34, float %37) #3
  %add43.7 = add nsw i32 %add, 7
  %idxprom44.7 = sext i32 %add43.7 to i64
  %arrayidx45347.7 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.7
  %39 = load i16, i16 addrspace(1)* %arrayidx45347.7, align 2, !tbaa !15
  %conv.i.7 = zext i16 %39 to i32
  %shl.i.7 = shl nuw i32 %conv.i.7, 16
  %40 = bitcast i32 %shl.i.7 to float
  %41 = tail call float @llvm.fabs.f32(float %40) #3
  %42 = tail call float @llvm.maxnum.f32(float %38, float %41) #3
  %add43.8 = add nsw i32 %add, 8
  %idxprom44.8 = sext i32 %add43.8 to i64
  %arrayidx45347.8 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.8
  %43 = load i16, i16 addrspace(1)* %arrayidx45347.8, align 2, !tbaa !15
  %conv.i.8 = zext i16 %43 to i32
  %shl.i.8 = shl nuw i32 %conv.i.8, 16
  %44 = bitcast i32 %shl.i.8 to float
  %45 = tail call float @llvm.fabs.f32(float %44) #3
  %46 = tail call float @llvm.maxnum.f32(float %42, float %45) #3
  %add43.9 = add nsw i32 %add, 9
  %idxprom44.9 = sext i32 %add43.9 to i64
  %arrayidx45347.9 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.9
  %47 = load i16, i16 addrspace(1)* %arrayidx45347.9, align 2, !tbaa !15
  %conv.i.9 = zext i16 %47 to i32
  %shl.i.9 = shl nuw i32 %conv.i.9, 16
  %48 = bitcast i32 %shl.i.9 to float
  %49 = tail call float @llvm.fabs.f32(float %48) #3
  %50 = tail call float @llvm.maxnum.f32(float %46, float %49) #3
  %add43.10 = add nsw i32 %add, 10
  %idxprom44.10 = sext i32 %add43.10 to i64
  %arrayidx45347.10 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.10
  %51 = load i16, i16 addrspace(1)* %arrayidx45347.10, align 2, !tbaa !15
  %conv.i.10 = zext i16 %51 to i32
  %shl.i.10 = shl nuw i32 %conv.i.10, 16
  %52 = bitcast i32 %shl.i.10 to float
  %53 = tail call float @llvm.fabs.f32(float %52) #3
  %54 = tail call float @llvm.maxnum.f32(float %50, float %53) #3
  %add43.11 = add nsw i32 %add, 11
  %idxprom44.11 = sext i32 %add43.11 to i64
  %arrayidx45347.11 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.11
  %55 = load i16, i16 addrspace(1)* %arrayidx45347.11, align 2, !tbaa !15
  %conv.i.11 = zext i16 %55 to i32
  %shl.i.11 = shl nuw i32 %conv.i.11, 16
  %56 = bitcast i32 %shl.i.11 to float
  %57 = tail call float @llvm.fabs.f32(float %56) #3
  %58 = tail call float @llvm.maxnum.f32(float %54, float %57) #3
  %add43.12 = add nsw i32 %add, 12
  %idxprom44.12 = sext i32 %add43.12 to i64
  %arrayidx45347.12 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.12
  %59 = load i16, i16 addrspace(1)* %arrayidx45347.12, align 2, !tbaa !15
  %conv.i.12 = zext i16 %59 to i32
  %shl.i.12 = shl nuw i32 %conv.i.12, 16
  %60 = bitcast i32 %shl.i.12 to float
  %61 = tail call float @llvm.fabs.f32(float %60) #3
  %62 = tail call float @llvm.maxnum.f32(float %58, float %61) #3
  %add43.13 = add nsw i32 %add, 13
  %idxprom44.13 = sext i32 %add43.13 to i64
  %arrayidx45347.13 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.13
  %63 = load i16, i16 addrspace(1)* %arrayidx45347.13, align 2, !tbaa !15
  %conv.i.13 = zext i16 %63 to i32
  %shl.i.13 = shl nuw i32 %conv.i.13, 16
  %64 = bitcast i32 %shl.i.13 to float
  %65 = tail call float @llvm.fabs.f32(float %64) #3
  %66 = tail call float @llvm.maxnum.f32(float %62, float %65) #3
  %add43.14 = add nsw i32 %add, 14
  %idxprom44.14 = sext i32 %add43.14 to i64
  %arrayidx45347.14 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.14
  %67 = load i16, i16 addrspace(1)* %arrayidx45347.14, align 2, !tbaa !15
  %add43.15 = add nsw i32 %add, 15
  %idxprom44.15 = sext i32 %add43.15 to i64
  %arrayidx45347.15 = getelementptr inbounds i16, i16 addrspace(1)* %add.ptr331, i64 %idxprom44.15
  %68 = load i16, i16 addrspace(1)* %arrayidx45347.15, align 2, !tbaa !15
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
  br i1 %cmp.i379, label %_Z4dec8i.exit.i.2, label %_Z4enc8f.exit.thread396, !decision.origin !17

_Z4enc8f.exit.thread396:                          ; preds = %for.body34
  store i8 126, i8 addrspace(5)* %4, align 1, !tbaa !18
  br label %cond.true.i, !decision.origin !19

_Z4enc8f.exit.thread:                             ; preds = %_Z4dec8i.exit.i.6
  store i8 0, i8 addrspace(5)* %4, align 1, !tbaa !18
  br label %cond.false.i377, !decision.origin !20

if.end9.i:                                        ; preds = %_Z4dec8i.exit.i.6
  %sub.i382 = add nsw i32 %lo.1.i.6, -1
  %shr.i62.i = ashr i32 %sub.i382, 3
  %and.i63.i = and i32 %sub.i382, 7
  %tobool.not.i64.i = icmp eq i32 %shr.i62.i, 0
  %conv1.i70.i = sitofp i32 %and.i63.i to float
  br i1 %tobool.not.i64.i, label %cond.false.i72.i, label %cond.true.i69.i, !decision.origin !21

cond.true.i69.i:                                  ; preds = %if.end9.i
  %mul.i66.i = fmul float %conv1.i70.i, 1.250000e-01
  %add.i67.i = fadd float %mul.i66.i, 1.000000e+00
  %sub.i68.i = add nsw i32 %shr.i62.i, -7
  %80 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i67.i, i32 %sub.i68.i) #3
  br label %_Z4dec8i.exit74.i, !decision.origin !22

cond.false.i72.i:                                 ; preds = %if.end9.i
  %mul2.i71.i = fmul float %conv1.i70.i, 0x3F60000000000000
  br label %_Z4dec8i.exit74.i, !decision.origin !23

_Z4dec8i.exit74.i:                                ; preds = %cond.false.i72.i, %cond.true.i69.i
  %cond.i73.i = phi float [ %80, %cond.true.i69.i ], [ %mul2.i71.i, %cond.false.i72.i ]
  %sub11.i = fsub float %mul61, %cond.i73.i
  %shr.i49.i657 = lshr i32 %lo.1.i.6, 3
  %and.i50.i = and i32 %lo.1.i.6, 7
  %tobool.not.i51.i = icmp eq i32 %shr.i49.i657, 0
  %conv1.i57.i = sitofp i32 %and.i50.i to float
  br i1 %tobool.not.i51.i, label %cond.false.i59.i, label %cond.true.i56.i, !decision.origin !24

cond.true.i56.i:                                  ; preds = %_Z4dec8i.exit74.i
  %mul.i53.i = fmul float %conv1.i57.i, 1.250000e-01
  %add.i54.i = fadd float %mul.i53.i, 1.000000e+00
  %sub.i55.i = add nsw i32 %shr.i49.i657, -7
  %81 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i54.i, i32 %sub.i55.i) #3
  br label %_Z4dec8i.exit61.i, !decision.origin !25

cond.false.i59.i:                                 ; preds = %_Z4dec8i.exit74.i
  %mul2.i58.i = fmul float %conv1.i57.i, 0x3F60000000000000
  br label %_Z4dec8i.exit61.i, !decision.origin !26

_Z4dec8i.exit61.i:                                ; preds = %cond.false.i59.i, %cond.true.i56.i
  %cond.i60.i = phi float [ %81, %cond.true.i56.i ], [ %mul2.i58.i, %cond.false.i59.i ]
  %sub13.i = fsub float %cond.i60.i, %mul61
  %cmp14.i = fcmp olt float %sub11.i, %sub13.i
  br i1 %cmp14.i, label %_Z4enc8f.exit, label %cond.false.i384, !decision.origin !27

cond.false.i384:                                  ; preds = %_Z4dec8i.exit61.i
  %cmp16.i383 = fcmp olt float %sub13.i, %sub11.i
  %and.i385 = and i32 %lo.1.i.6, 1
  %tobool.not.i386 = icmp eq i32 %and.i385, 0
  %cond.i387 = select i1 %tobool.not.i386, i32 %lo.1.i.6, i32 %sub.i382
  br i1 %cmp16.i383, label %_Z4enc8f.exit, label %cond.false18.i, !decision.origin !28

cond.false18.i:                                   ; preds = %cond.false.i384
  %.pre449 = and i32 %cond.i387, 7
  br label %_Z4enc8f.exit, !decision.origin !29

_Z4enc8f.exit:                                    ; preds = %cond.false18.i, %cond.false.i384, %_Z4dec8i.exit61.i
  %and.i375.pre-phi = phi i32 [ %and.i63.i, %_Z4dec8i.exit61.i ], [ %and.i50.i, %cond.false.i384 ], [ %.pre449, %cond.false18.i ]
  %cond25.i = phi i32 [ %sub.i382, %_Z4dec8i.exit61.i ], [ %lo.1.i.6, %cond.false.i384 ], [ %cond.i387, %cond.false18.i ]
  %conv.i388 = trunc i32 %cond25.i to i8
  store i8 %conv.i388, i8 addrspace(5)* %4, align 1, !tbaa !18
  %conv67 = lshr i32 %cond25.i, 3
  %tobool.not.i = icmp eq i32 %conv67, 0
  br i1 %tobool.not.i, label %cond.false.i377, label %cond.true.i, !decision.origin !30

cond.true.i:                                      ; preds = %_Z4enc8f.exit, %_Z4enc8f.exit.thread396
  %and.i375404 = phi i32 [ 6, %_Z4enc8f.exit.thread396 ], [ %and.i375.pre-phi, %_Z4enc8f.exit ]
  %shr.i374403 = phi i32 [ 15, %_Z4enc8f.exit.thread396 ], [ %conv67, %_Z4enc8f.exit ]
  %conv.i376 = sitofp i32 %and.i375404 to float
  %mul.i = fmul float %conv.i376, 1.250000e-01
  %add.i = fadd float %mul.i, 1.000000e+00
  %sub.i = add nsw i32 %shr.i374403, -7
  %82 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i, i32 %sub.i) #3
  br label %_Z4dec8i.exit, !decision.origin !31

cond.false.i377:                                  ; preds = %_Z4enc8f.exit, %_Z4enc8f.exit.thread
  %and.i375395 = phi i32 [ 0, %_Z4enc8f.exit.thread ], [ %and.i375.pre-phi, %_Z4enc8f.exit ]
  %conv1.i = sitofp i32 %and.i375395 to float
  %mul2.i = fmul float %conv1.i, 0x3F60000000000000
  br label %_Z4dec8i.exit, !decision.origin !32

_Z4dec8i.exit:                                    ; preds = %cond.false.i377, %cond.true.i
  %cond.i378 = phi float [ %82, %cond.true.i ], [ %mul2.i, %cond.false.i377 ]
  %cmp69 = fcmp une float %cond.i378, 0.000000e+00
  br i1 %cmp69, label %cond.end75, label %cond.end75.thread, !decision.origin !33

cond.end75.thread:                                ; preds = %_Z4dec8i.exit
  %83 = insertelement <2 x float> %os.sroa.0.2, float 0.000000e+00, i32 0
  br label %if.then97.7, !decision.origin !34

cond.end75:                                       ; preds = %_Z4dec8i.exit
  %mul72 = fmul float %div71, %cond.i378
  %div73 = fdiv float 1.000000e+00, %mul72
  %84 = insertelement <2 x float> %os.sroa.0.2, float %div73, i32 0
  %cmp81 = fcmp une float %div73, 0.000000e+00
  %div85 = fdiv float 1.000000e+00, %div73
  %cond88 = select i1 %cmp81, float %div85, float 0.000000e+00
  %cmp96 = fcmp oeq float %div73, 0.000000e+00
  br i1 %cmp96, label %if.then97.7, label %if.else.7, !decision.origin !35

cond.false.i353:                                  ; preds = %for.inc138.7.1
  %cmp1.i352 = fcmp olt float %406, 7.500000e-01
  br i1 %cmp1.i352, label %_Z5pack4f.exit369, label %cond.false3.i355, !decision.origin !36

cond.false3.i355:                                 ; preds = %cond.false.i353
  %cmp4.i354 = fcmp ugt float %406, 1.250000e+00
  br i1 %cmp4.i354, label %cond.false6.i357, label %_Z5pack4f.exit369, !decision.origin !37

cond.false6.i357:                                 ; preds = %cond.false3.i355
  %cmp7.i356 = fcmp olt float %406, 1.750000e+00
  br i1 %cmp7.i356, label %_Z5pack4f.exit369, label %cond.false9.i359, !decision.origin !38

cond.false9.i359:                                 ; preds = %cond.false6.i357
  %cmp10.i358 = fcmp ugt float %406, 2.500000e+00
  br i1 %cmp10.i358, label %cond.false12.i361, label %_Z5pack4f.exit369, !decision.origin !39

cond.false12.i361:                                ; preds = %cond.false9.i359
  %cmp13.i360 = fcmp olt float %406, 3.500000e+00
  br i1 %cmp13.i360, label %_Z5pack4f.exit369, label %cond.false15.i364, !decision.origin !40

cond.false15.i364:                                ; preds = %cond.false12.i361
  %cmp16.i362 = fcmp ole float %406, 5.000000e+00
  %cond.i363 = select i1 %cmp16.i362, i32 6, i32 7
  br label %_Z5pack4f.exit369, !decision.origin !41

_Z5pack4f.exit369:                                ; preds = %for.inc138.7.1, %cond.false15.i364, %cond.false12.i361, %cond.false9.i359, %cond.false6.i357, %cond.false3.i355, %cond.false.i353
  %cond27.i365 = phi i32 [ 0, %for.inc138.7.1 ], [ 1, %cond.false.i353 ], [ 2, %cond.false3.i355 ], [ 3, %cond.false6.i357 ], [ 4, %cond.false9.i359 ], [ %cond.i363, %cond.false15.i364 ], [ 5, %cond.false12.i361 ]
  %85 = bitcast float %mul175 to i32
  %shr.i366 = lshr i32 %85, 28
  %and.i367 = and i32 %shr.i366, 8
  %or.i368 = or i32 %cond27.i365, %and.i367
  %mul183 = fmul float %405, %16
  %86 = tail call float @llvm.fabs.f32(float %mul183) #3
  %cmp.i = fcmp ugt float %86, 2.500000e-01
  br i1 %cmp.i, label %cond.false.i, label %_Z5pack4f.exit, !decision.origin !42

cond.false.i:                                     ; preds = %_Z5pack4f.exit369
  %cmp1.i = fcmp olt float %86, 7.500000e-01
  br i1 %cmp1.i, label %_Z5pack4f.exit, label %cond.false3.i, !decision.origin !43

cond.false3.i:                                    ; preds = %cond.false.i
  %cmp4.i = fcmp ugt float %86, 1.250000e+00
  br i1 %cmp4.i, label %cond.false6.i, label %_Z5pack4f.exit, !decision.origin !44

cond.false6.i:                                    ; preds = %cond.false3.i
  %cmp7.i = fcmp olt float %86, 1.750000e+00
  br i1 %cmp7.i, label %_Z5pack4f.exit, label %cond.false9.i, !decision.origin !45

cond.false9.i:                                    ; preds = %cond.false6.i
  %cmp10.i = fcmp ugt float %86, 2.500000e+00
  br i1 %cmp10.i, label %cond.false12.i, label %_Z5pack4f.exit, !decision.origin !46

cond.false12.i:                                   ; preds = %cond.false9.i
  %cmp13.i = fcmp olt float %86, 3.500000e+00
  br i1 %cmp13.i, label %_Z5pack4f.exit, label %cond.false15.i, !decision.origin !47

cond.false15.i:                                   ; preds = %cond.false12.i
  %cmp16.i = fcmp ole float %86, 5.000000e+00
  %cond.i = select i1 %cmp16.i, i32 6, i32 7
  br label %_Z5pack4f.exit, !decision.origin !48

_Z5pack4f.exit:                                   ; preds = %cond.false15.i, %cond.false12.i, %cond.false9.i, %cond.false6.i, %cond.false3.i, %cond.false.i, %_Z5pack4f.exit369
  %cond27.i = phi i32 [ 0, %_Z5pack4f.exit369 ], [ 1, %cond.false.i ], [ 2, %cond.false3.i ], [ 3, %cond.false6.i ], [ 4, %cond.false9.i ], [ %cond.i, %cond.false15.i ], [ 5, %cond.false12.i ]
  %87 = bitcast float %mul183 to i32
  %shr.i = lshr i32 %87, 28
  %and.i = and i32 %shr.i, 8
  %or.i = or i32 %cond27.i, %and.i
  %shl = shl nuw nsw i32 %or.i, 4
  %or = or i32 %or.i368, %shl
  %conv185 = trunc i32 %or to i8
  %arrayidx188339 = getelementptr inbounds i8, i8 addrspace(1)* %cond19.v, i64 %add164
  store i8 %conv185, i8 addrspace(1)* %arrayidx188339, align 1, !tbaa !18
  %mul175.1 = fmul float %405, %20
  %88 = tail call float @llvm.fabs.f32(float %mul175.1) #3
  %cmp.i351.1 = fcmp ugt float %88, 2.500000e-01
  br i1 %cmp.i351.1, label %cond.false.i353.1, label %_Z5pack4f.exit369.1, !decision.origin !49

if.then193:                                       ; preds = %_Z5pack4f.exit.7
  %div197 = sdiv i32 %rem36.decomposed, %div196.frozen
  %add198 = add nsw i32 %div197, %mul195
  %89 = mul i32 %div197, %div196.frozen
  %rem200.decomposed = sub i32 %rem36.decomposed, %89
  %mul201 = shl nsw i32 %rem200.decomposed, 2
  %add203 = add nsw i32 %rem202.decomposed, %mul201
  br label %if.end204, !decision.origin !50

if.end204:                                        ; preds = %_Z5pack4f.exit.7, %if.then193
  %st.0 = phi i32 [ %add198, %if.then193 ], [ %conv9, %_Z5pack4f.exit.7 ]
  %ss.0 = phi i32 [ %add203, %if.then193 ], [ %rem36.decomposed, %_Z5pack4f.exit.7 ]
  %arrayidx206334 = getelementptr inbounds [2 x i8], [2 x i8] addrspace(5)* %code, i32 0, i32 %404
  %90 = load i8, i8 addrspace(5)* %arrayidx206334, align 1, !tbaa !18
  %conv213 = sext i32 %st.0 to i64
  %add214 = add nsw i64 %mul156, %conv213
  %mul216 = mul nsw i64 %add214, %conv215
  %conv217 = sext i32 %ss.0 to i64
  %add218 = add nsw i64 %mul216, %conv217
  %arrayidx219335 = getelementptr inbounds i8, i8 addrspace(1)* %cond24.v, i64 %add218
  store i8 %90, i8 addrspace(1)* %arrayidx219335, align 1, !tbaa !18
  call void @llvm.lifetime.end.p5i8(i64 2, i8 addrspace(5)* %4) #3
  %add222 = add i32 %g.0419, %9
  %cmp32 = icmp slt i32 %add222, %mul
  br i1 %cmp32, label %for.body34, label %for.cond.cleanup33, !decision.origin !51

cleanup:                                          ; preds = %for.cond.cleanup33, %entry
  ret void, !decision.origin !52

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
  br i1 %tobool.not.i.i.3, label %cond.false.i.i.3, label %cond.true.i.i.3, !decision.origin !53

cond.true.i.i.3:                                  ; preds = %_Z4dec8i.exit.i.2
  %mul.i.i.3 = fmul float %conv1.i.i.3, 1.250000e-01
  %add.i.i.3 = fadd float %mul.i.i.3, 1.000000e+00
  %sub.i.i.3 = add nsw i32 %95, -7
  %96 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i.i.3, i32 %sub.i.i.3) #3
  br label %_Z4dec8i.exit.i.3, !decision.origin !54

cond.false.i.i.3:                                 ; preds = %_Z4dec8i.exit.i.2
  %mul2.i.i.3 = fmul float %conv1.i.i.3, 0x3F60000000000000
  br label %_Z4dec8i.exit.i.3, !decision.origin !55

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
  br i1 %tobool.not.i.i.4, label %cond.false.i.i.4, label %cond.true.i.i.4, !decision.origin !56

cond.true.i.i.4:                                  ; preds = %_Z4dec8i.exit.i.3
  %mul.i.i.4 = fmul float %conv1.i.i.4, 1.250000e-01
  %add.i.i.4 = fadd float %mul.i.i.4, 1.000000e+00
  %sub.i.i.4 = add nsw i32 %97, -7
  %98 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i.i.4, i32 %sub.i.i.4) #3
  br label %_Z4dec8i.exit.i.4, !decision.origin !57

cond.false.i.i.4:                                 ; preds = %_Z4dec8i.exit.i.3
  %mul2.i.i.4 = fmul float %conv1.i.i.4, 0x3F60000000000000
  br label %_Z4dec8i.exit.i.4, !decision.origin !58

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
  br i1 %tobool.not.i.i.5, label %cond.false.i.i.5, label %cond.true.i.i.5, !decision.origin !59

cond.true.i.i.5:                                  ; preds = %_Z4dec8i.exit.i.4
  %mul.i.i.5 = fmul float %conv1.i.i.5, 1.250000e-01
  %add.i.i.5 = fadd float %mul.i.i.5, 1.000000e+00
  %sub.i.i.5 = add nsw i32 %shr.i.i.5, -7
  %99 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i.i.5, i32 %sub.i.i.5) #3
  br label %_Z4dec8i.exit.i.5, !decision.origin !60

cond.false.i.i.5:                                 ; preds = %_Z4dec8i.exit.i.4
  %mul2.i.i.5 = fmul float %conv1.i.i.5, 0x3F60000000000000
  br label %_Z4dec8i.exit.i.5, !decision.origin !61

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
  br i1 %tobool.not.i.i.6, label %cond.false.i.i.6, label %cond.true.i.i.6, !decision.origin !62

cond.true.i.i.6:                                  ; preds = %_Z4dec8i.exit.i.5
  %mul.i.i.6 = fmul float %conv1.i.i.6, 1.250000e-01
  %add.i.i.6 = fadd float %mul.i.i.6, 1.000000e+00
  %sub.i.i.6 = add nsw i32 %shr.i.i.6, -7
  %100 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i.i.6, i32 %sub.i.i.6) #3
  br label %_Z4dec8i.exit.i.6, !decision.origin !63

cond.false.i.i.6:                                 ; preds = %_Z4dec8i.exit.i.5
  %mul2.i.i.6 = fmul float %conv1.i.i.6, 0x3F60000000000000
  br label %_Z4dec8i.exit.i.6, !decision.origin !64

_Z4dec8i.exit.i.6:                                ; preds = %cond.false.i.i.6, %cond.true.i.i.6
  %cond.i.i.6 = phi float [ %100, %cond.true.i.i.6 ], [ %mul2.i.i.6, %cond.false.i.i.6 ]
  %cmp2.i.6 = fcmp olt float %cond.i.i.6, %mul61
  %add4.i.6 = add nuw nsw i32 %div.i.6, 1
  %lo.1.i.6 = select i1 %cmp2.i.6, i32 %add4.i.6, i32 %lo.1.i.5
  %cmp6.i = icmp eq i32 %lo.1.i.6, 0
  br i1 %cmp6.i, label %_Z4enc8f.exit.thread, label %if.end9.i, !decision.origin !65

if.else.7:                                        ; preds = %cond.end75
  %mul116 = fmul float %div73, %12
  %101 = tail call float @llvm.fabs.f32(float %mul116) #3
  %cmp.i43 = fcmp ugt float %101, 2.500000e-01
  %cmp2.i44 = fcmp olt float %101, 7.500000e-01
  %not.cmp.i4354 = xor i1 %cmp.i43, true
  %decision.take = or i1 %cmp2.i44, %not.cmp.i4354
  br i1 %decision.take, label %merged.bb, label %if.else4.i, !decision.short_gate !66

if.else4.i:                                       ; preds = %if.else.7
  %cmp6.i45 = fcmp ugt float %101, 1.250000e+00
  br i1 %cmp6.i45, label %if.else8.i, label %quant_decide.exit, !decision.origin !67

if.else8.i:                                       ; preds = %if.else4.i
  %cmp10.i46 = fcmp olt float %101, 1.750000e+00
  br i1 %cmp10.i46, label %quant_decide.exit, label %if.else12.i, !decision.origin !68

if.else12.i:                                      ; preds = %if.else8.i
  %cmp14.i47 = fcmp ugt float %101, 2.500000e+00
  br i1 %cmp14.i47, label %if.else16.i, label %quant_decide.exit, !decision.origin !69

if.else16.i:                                      ; preds = %if.else12.i
  %cmp18.i = fcmp olt float %101, 3.500000e+00
  br i1 %cmp18.i, label %quant_decide.exit, label %if.else20.i, !decision.origin !70

if.else20.i:                                      ; preds = %if.else16.i
  %cmp22.i = fcmp ugt float %101, 5.000000e+00
  %. = select i1 %cmp22.i, float 6.000000e+00, float 4.000000e+00
  br label %quant_decide.exit, !decision.origin !71, !decision.order !72

quant_decide.exit:                                ; preds = %if.else20.i, %if.else16.i, %if.else12.i, %if.else8.i, %if.else4.i, %merged.bb
  %merged.select.sink = phi float [ %merged.select, %merged.bb ], [ 1.000000e+00, %if.else4.i ], [ 1.500000e+00, %if.else8.i ], [ 2.000000e+00, %if.else12.i ], [ 3.000000e+00, %if.else16.i ], [ %., %if.else20.i ]
  %102 = tail call float @llvm.copysign.f32(float %merged.select.sink, float %mul116) #3
  %mul118 = fmul float %cond88, %102
  %sub = fsub float %mul118, %12
  %mul126 = fmul float %div73, %16
  %103 = tail call float @llvm.fabs.f32(float %mul126) #3
  %cmp.i708 = fcmp ugt float %103, 2.500000e-01
  br i1 %cmp.i708, label %if.else.i711, label %if.then.i709, !decision.origin !73

if.then.i709:                                     ; preds = %quant_decide.exit
  %104 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126) #3
  br label %quant_decide.exit729, !decision.origin !74, !decision.order !75

if.else.i711:                                     ; preds = %quant_decide.exit
  %cmp2.i710 = fcmp olt float %103, 7.500000e-01
  br i1 %cmp2.i710, label %if.then3.i712, label %if.else4.i714, !decision.origin !76

if.then3.i712:                                    ; preds = %if.else.i711
  %105 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126) #3
  br label %quant_decide.exit729, !decision.origin !77, !decision.order !78

if.else4.i714:                                    ; preds = %if.else.i711
  %cmp6.i713 = fcmp ugt float %103, 1.250000e+00
  br i1 %cmp6.i713, label %if.else8.i717, label %if.then7.i715, !decision.origin !79

if.then7.i715:                                    ; preds = %if.else4.i714
  %106 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126) #3
  br label %quant_decide.exit729, !decision.origin !80, !decision.order !81

if.else8.i717:                                    ; preds = %if.else4.i714
  %cmp10.i716 = fcmp olt float %103, 1.750000e+00
  br i1 %cmp10.i716, label %if.then11.i718, label %if.else12.i720, !decision.origin !82

if.then11.i718:                                   ; preds = %if.else8.i717
  %107 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126) #3
  br label %quant_decide.exit729, !decision.origin !83, !decision.order !84

if.else12.i720:                                   ; preds = %if.else8.i717
  %cmp14.i719 = fcmp ugt float %103, 2.500000e+00
  br i1 %cmp14.i719, label %if.else16.i723, label %if.then15.i721, !decision.origin !85

if.then15.i721:                                   ; preds = %if.else12.i720
  %108 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126) #3
  br label %quant_decide.exit729, !decision.origin !86, !decision.order !87

if.else16.i723:                                   ; preds = %if.else12.i720
  %cmp18.i722 = fcmp olt float %103, 3.500000e+00
  br i1 %cmp18.i722, label %if.then19.i724, label %if.else20.i726, !decision.origin !88

if.then19.i724:                                   ; preds = %if.else16.i723
  %109 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126) #3
  br label %quant_decide.exit729, !decision.origin !89, !decision.order !90

if.else20.i726:                                   ; preds = %if.else16.i723
  %cmp22.i725 = fcmp ugt float %103, 5.000000e+00
  br i1 %cmp22.i725, label %if.end29.i728, label %if.then23.i727, !decision.origin !91

if.then23.i727:                                   ; preds = %if.else20.i726
  %110 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126) #3
  br label %quant_decide.exit729, !decision.origin !92, !decision.order !93

if.end29.i728:                                    ; preds = %if.else20.i726
  %111 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126) #3
  br label %quant_decide.exit729, !decision.origin !94, !decision.order !95

quant_decide.exit729:                             ; preds = %if.end29.i728, %if.then23.i727, %if.then19.i724, %if.then15.i721, %if.then11.i718, %if.then7.i715, %if.then3.i712, %if.then.i709
  %out.i.0 = phi float [ %105, %if.then3.i712 ], [ %107, %if.then11.i718 ], [ %109, %if.then19.i724 ], [ %111, %if.end29.i728 ], [ %110, %if.then23.i727 ], [ %108, %if.then15.i721 ], [ %106, %if.then7.i715 ], [ %104, %if.then.i709 ]
  %mul128 = fmul float %cond88, %out.i.0
  %sub132 = fsub float %mul128, %16
  %mul133 = fmul float %sub, %sub
  %mul134 = fmul float %sub132, %sub132
  %add135 = fadd float %mul133, %mul134
  %e.1 = fadd float %add135, 0.000000e+00
  %mul116.1 = fmul float %div73, %20
  %112 = tail call float @llvm.fabs.f32(float %mul116.1) #3
  %cmp.i686 = fcmp ugt float %112, 2.500000e-01
  br i1 %cmp.i686, label %if.else.i689, label %if.then.i687, !decision.origin !96

if.then.i687:                                     ; preds = %quant_decide.exit729
  %113 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.1) #3
  br label %quant_decide.exit707, !decision.origin !97, !decision.order !98

if.else.i689:                                     ; preds = %quant_decide.exit729
  %cmp2.i688 = fcmp olt float %112, 7.500000e-01
  br i1 %cmp2.i688, label %if.then3.i690, label %if.else4.i692, !decision.origin !99

if.then3.i690:                                    ; preds = %if.else.i689
  %114 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.1) #3
  br label %quant_decide.exit707, !decision.origin !100, !decision.order !101

if.else4.i692:                                    ; preds = %if.else.i689
  %cmp6.i691 = fcmp ugt float %112, 1.250000e+00
  br i1 %cmp6.i691, label %if.else8.i695, label %if.then7.i693, !decision.origin !102

if.then7.i693:                                    ; preds = %if.else4.i692
  %115 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.1) #3
  br label %quant_decide.exit707, !decision.origin !103, !decision.order !104

if.else8.i695:                                    ; preds = %if.else4.i692
  %cmp10.i694 = fcmp olt float %112, 1.750000e+00
  br i1 %cmp10.i694, label %if.then11.i696, label %if.else12.i698, !decision.origin !105

if.then11.i696:                                   ; preds = %if.else8.i695
  %116 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.1) #3
  br label %quant_decide.exit707, !decision.origin !106, !decision.order !107

if.else12.i698:                                   ; preds = %if.else8.i695
  %cmp14.i697 = fcmp ugt float %112, 2.500000e+00
  br i1 %cmp14.i697, label %if.else16.i701, label %if.then15.i699, !decision.origin !108

if.then15.i699:                                   ; preds = %if.else12.i698
  %117 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.1) #3
  br label %quant_decide.exit707, !decision.origin !109, !decision.order !110

if.else16.i701:                                   ; preds = %if.else12.i698
  %cmp18.i700 = fcmp olt float %112, 3.500000e+00
  br i1 %cmp18.i700, label %if.then19.i702, label %if.else20.i704, !decision.origin !111

if.then19.i702:                                   ; preds = %if.else16.i701
  %118 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.1) #3
  br label %quant_decide.exit707, !decision.origin !112, !decision.order !113

if.else20.i704:                                   ; preds = %if.else16.i701
  %cmp22.i703 = fcmp ugt float %112, 5.000000e+00
  br i1 %cmp22.i703, label %if.end29.i706, label %if.then23.i705, !decision.origin !114

if.then23.i705:                                   ; preds = %if.else20.i704
  %119 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.1) #3
  br label %quant_decide.exit707, !decision.origin !115, !decision.order !116

if.end29.i706:                                    ; preds = %if.else20.i704
  %120 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.1) #3
  br label %quant_decide.exit707, !decision.origin !117, !decision.order !118

quant_decide.exit707:                             ; preds = %if.end29.i706, %if.then23.i705, %if.then19.i702, %if.then15.i699, %if.then11.i696, %if.then7.i693, %if.then3.i690, %if.then.i687
  %out.i372.1 = phi float [ %114, %if.then3.i690 ], [ %116, %if.then11.i696 ], [ %118, %if.then19.i702 ], [ %120, %if.end29.i706 ], [ %119, %if.then23.i705 ], [ %117, %if.then15.i699 ], [ %115, %if.then7.i693 ], [ %113, %if.then.i687 ]
  %mul118.1 = fmul float %cond88, %out.i372.1
  %sub.1 = fsub float %mul118.1, %20
  %mul126.1 = fmul float %div73, %24
  %121 = tail call float @llvm.fabs.f32(float %mul126.1) #3
  %cmp.i664 = fcmp ugt float %121, 2.500000e-01
  br i1 %cmp.i664, label %if.else.i667, label %if.then.i665, !decision.origin !119

if.then.i665:                                     ; preds = %quant_decide.exit707
  %122 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.1) #3
  br label %quant_decide.exit685, !decision.origin !120, !decision.order !121

if.else.i667:                                     ; preds = %quant_decide.exit707
  %cmp2.i666 = fcmp olt float %121, 7.500000e-01
  br i1 %cmp2.i666, label %if.then3.i668, label %if.else4.i670, !decision.origin !122

if.then3.i668:                                    ; preds = %if.else.i667
  %123 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.1) #3
  br label %quant_decide.exit685, !decision.origin !123, !decision.order !124

if.else4.i670:                                    ; preds = %if.else.i667
  %cmp6.i669 = fcmp ugt float %121, 1.250000e+00
  br i1 %cmp6.i669, label %if.else8.i673, label %if.then7.i671, !decision.origin !125

if.then7.i671:                                    ; preds = %if.else4.i670
  %124 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.1) #3
  br label %quant_decide.exit685, !decision.origin !126, !decision.order !127

if.else8.i673:                                    ; preds = %if.else4.i670
  %cmp10.i672 = fcmp olt float %121, 1.750000e+00
  br i1 %cmp10.i672, label %if.then11.i674, label %if.else12.i676, !decision.origin !128

if.then11.i674:                                   ; preds = %if.else8.i673
  %125 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.1) #3
  br label %quant_decide.exit685, !decision.origin !129, !decision.order !130

if.else12.i676:                                   ; preds = %if.else8.i673
  %cmp14.i675 = fcmp ugt float %121, 2.500000e+00
  br i1 %cmp14.i675, label %if.else16.i679, label %if.then15.i677, !decision.origin !131

if.then15.i677:                                   ; preds = %if.else12.i676
  %126 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.1) #3
  br label %quant_decide.exit685, !decision.origin !132, !decision.order !133

if.else16.i679:                                   ; preds = %if.else12.i676
  %cmp18.i678 = fcmp olt float %121, 3.500000e+00
  br i1 %cmp18.i678, label %if.then19.i680, label %if.else20.i682, !decision.origin !134

if.then19.i680:                                   ; preds = %if.else16.i679
  %127 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.1) #3
  br label %quant_decide.exit685, !decision.origin !135, !decision.order !136

if.else20.i682:                                   ; preds = %if.else16.i679
  %cmp22.i681 = fcmp ugt float %121, 5.000000e+00
  br i1 %cmp22.i681, label %if.end29.i684, label %if.then23.i683, !decision.origin !137

if.then23.i683:                                   ; preds = %if.else20.i682
  %128 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.1) #3
  br label %quant_decide.exit685, !decision.origin !138, !decision.order !139

if.end29.i684:                                    ; preds = %if.else20.i682
  %129 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.1) #3
  br label %quant_decide.exit685, !decision.origin !140, !decision.order !141

quant_decide.exit685:                             ; preds = %if.end29.i684, %if.then23.i683, %if.then19.i680, %if.then15.i677, %if.then11.i674, %if.then7.i671, %if.then3.i668, %if.then.i665
  %out.i.1 = phi float [ %123, %if.then3.i668 ], [ %125, %if.then11.i674 ], [ %127, %if.then19.i680 ], [ %129, %if.end29.i684 ], [ %128, %if.then23.i683 ], [ %126, %if.then15.i677 ], [ %124, %if.then7.i671 ], [ %122, %if.then.i665 ]
  %mul128.1 = fmul float %cond88, %out.i.1
  %sub132.1 = fsub float %mul128.1, %24
  %mul133.1 = fmul float %sub.1, %sub.1
  %mul134.1 = fmul float %sub132.1, %sub132.1
  %add135.1 = fadd float %mul133.1, %mul134.1
  %e.1.1 = fadd float %e.1, %add135.1
  %mul116.2 = fmul float %div73, %28
  %130 = tail call float @llvm.fabs.f32(float %mul116.2) #3
  %cmp.i642 = fcmp ugt float %130, 2.500000e-01
  br i1 %cmp.i642, label %if.else.i645, label %if.then.i643, !decision.origin !142

if.then.i643:                                     ; preds = %quant_decide.exit685
  %131 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.2) #3
  br label %quant_decide.exit663, !decision.origin !143, !decision.order !144

if.else.i645:                                     ; preds = %quant_decide.exit685
  %cmp2.i644 = fcmp olt float %130, 7.500000e-01
  br i1 %cmp2.i644, label %if.then3.i646, label %if.else4.i648, !decision.origin !145

if.then3.i646:                                    ; preds = %if.else.i645
  %132 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.2) #3
  br label %quant_decide.exit663, !decision.origin !146, !decision.order !147

if.else4.i648:                                    ; preds = %if.else.i645
  %cmp6.i647 = fcmp ugt float %130, 1.250000e+00
  br i1 %cmp6.i647, label %if.else8.i651, label %if.then7.i649, !decision.origin !148

if.then7.i649:                                    ; preds = %if.else4.i648
  %133 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.2) #3
  br label %quant_decide.exit663, !decision.origin !149, !decision.order !150

if.else8.i651:                                    ; preds = %if.else4.i648
  %cmp10.i650 = fcmp olt float %130, 1.750000e+00
  br i1 %cmp10.i650, label %if.then11.i652, label %if.else12.i654, !decision.origin !151

if.then11.i652:                                   ; preds = %if.else8.i651
  %134 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.2) #3
  br label %quant_decide.exit663, !decision.origin !152, !decision.order !153

if.else12.i654:                                   ; preds = %if.else8.i651
  %cmp14.i653 = fcmp ugt float %130, 2.500000e+00
  br i1 %cmp14.i653, label %if.else16.i657, label %if.then15.i655, !decision.origin !154

if.then15.i655:                                   ; preds = %if.else12.i654
  %135 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.2) #3
  br label %quant_decide.exit663, !decision.origin !155, !decision.order !156

if.else16.i657:                                   ; preds = %if.else12.i654
  %cmp18.i656 = fcmp olt float %130, 3.500000e+00
  br i1 %cmp18.i656, label %if.then19.i658, label %if.else20.i660, !decision.origin !157

if.then19.i658:                                   ; preds = %if.else16.i657
  %136 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.2) #3
  br label %quant_decide.exit663, !decision.origin !158, !decision.order !159

if.else20.i660:                                   ; preds = %if.else16.i657
  %cmp22.i659 = fcmp ugt float %130, 5.000000e+00
  br i1 %cmp22.i659, label %if.end29.i662, label %if.then23.i661, !decision.origin !160

if.then23.i661:                                   ; preds = %if.else20.i660
  %137 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.2) #3
  br label %quant_decide.exit663, !decision.origin !161, !decision.order !162

if.end29.i662:                                    ; preds = %if.else20.i660
  %138 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.2) #3
  br label %quant_decide.exit663, !decision.origin !163, !decision.order !164

quant_decide.exit663:                             ; preds = %if.end29.i662, %if.then23.i661, %if.then19.i658, %if.then15.i655, %if.then11.i652, %if.then7.i649, %if.then3.i646, %if.then.i643
  %out.i372.2 = phi float [ %132, %if.then3.i646 ], [ %134, %if.then11.i652 ], [ %136, %if.then19.i658 ], [ %138, %if.end29.i662 ], [ %137, %if.then23.i661 ], [ %135, %if.then15.i655 ], [ %133, %if.then7.i649 ], [ %131, %if.then.i643 ]
  %mul118.2 = fmul float %cond88, %out.i372.2
  %sub.2 = fsub float %mul118.2, %28
  %mul126.2 = fmul float %div73, %32
  %139 = tail call float @llvm.fabs.f32(float %mul126.2) #3
  %cmp.i620 = fcmp ugt float %139, 2.500000e-01
  br i1 %cmp.i620, label %if.else.i623, label %if.then.i621, !decision.origin !165

if.then.i621:                                     ; preds = %quant_decide.exit663
  %140 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.2) #3
  br label %quant_decide.exit641, !decision.origin !166, !decision.order !167

if.else.i623:                                     ; preds = %quant_decide.exit663
  %cmp2.i622 = fcmp olt float %139, 7.500000e-01
  br i1 %cmp2.i622, label %if.then3.i624, label %if.else4.i626, !decision.origin !168

if.then3.i624:                                    ; preds = %if.else.i623
  %141 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.2) #3
  br label %quant_decide.exit641, !decision.origin !169, !decision.order !170

if.else4.i626:                                    ; preds = %if.else.i623
  %cmp6.i625 = fcmp ugt float %139, 1.250000e+00
  br i1 %cmp6.i625, label %if.else8.i629, label %if.then7.i627, !decision.origin !171

if.then7.i627:                                    ; preds = %if.else4.i626
  %142 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.2) #3
  br label %quant_decide.exit641, !decision.origin !172, !decision.order !173

if.else8.i629:                                    ; preds = %if.else4.i626
  %cmp10.i628 = fcmp olt float %139, 1.750000e+00
  br i1 %cmp10.i628, label %if.then11.i630, label %if.else12.i632, !decision.origin !174

if.then11.i630:                                   ; preds = %if.else8.i629
  %143 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.2) #3
  br label %quant_decide.exit641, !decision.origin !175, !decision.order !176

if.else12.i632:                                   ; preds = %if.else8.i629
  %cmp14.i631 = fcmp ugt float %139, 2.500000e+00
  br i1 %cmp14.i631, label %if.else16.i635, label %if.then15.i633, !decision.origin !177

if.then15.i633:                                   ; preds = %if.else12.i632
  %144 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.2) #3
  br label %quant_decide.exit641, !decision.origin !178, !decision.order !179

if.else16.i635:                                   ; preds = %if.else12.i632
  %cmp18.i634 = fcmp olt float %139, 3.500000e+00
  br i1 %cmp18.i634, label %if.then19.i636, label %if.else20.i638, !decision.origin !180

if.then19.i636:                                   ; preds = %if.else16.i635
  %145 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.2) #3
  br label %quant_decide.exit641, !decision.origin !181, !decision.order !182

if.else20.i638:                                   ; preds = %if.else16.i635
  %cmp22.i637 = fcmp ugt float %139, 5.000000e+00
  br i1 %cmp22.i637, label %if.end29.i640, label %if.then23.i639, !decision.origin !183

if.then23.i639:                                   ; preds = %if.else20.i638
  %146 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.2) #3
  br label %quant_decide.exit641, !decision.origin !184, !decision.order !185

if.end29.i640:                                    ; preds = %if.else20.i638
  %147 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.2) #3
  br label %quant_decide.exit641, !decision.origin !186, !decision.order !187

quant_decide.exit641:                             ; preds = %if.end29.i640, %if.then23.i639, %if.then19.i636, %if.then15.i633, %if.then11.i630, %if.then7.i627, %if.then3.i624, %if.then.i621
  %out.i.2 = phi float [ %141, %if.then3.i624 ], [ %143, %if.then11.i630 ], [ %145, %if.then19.i636 ], [ %147, %if.end29.i640 ], [ %146, %if.then23.i639 ], [ %144, %if.then15.i633 ], [ %142, %if.then7.i627 ], [ %140, %if.then.i621 ]
  %mul128.2 = fmul float %cond88, %out.i.2
  %sub132.2 = fsub float %mul128.2, %32
  %mul133.2 = fmul float %sub.2, %sub.2
  %mul134.2 = fmul float %sub132.2, %sub132.2
  %add135.2 = fadd float %mul133.2, %mul134.2
  %e.1.2 = fadd float %e.1.1, %add135.2
  %mul116.3 = fmul float %div73, %36
  %148 = tail call float @llvm.fabs.f32(float %mul116.3) #3
  %cmp.i598 = fcmp ugt float %148, 2.500000e-01
  br i1 %cmp.i598, label %if.else.i601, label %if.then.i599, !decision.origin !188

if.then.i599:                                     ; preds = %quant_decide.exit641
  %149 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.3) #3
  br label %quant_decide.exit619, !decision.origin !189, !decision.order !190

if.else.i601:                                     ; preds = %quant_decide.exit641
  %cmp2.i600 = fcmp olt float %148, 7.500000e-01
  br i1 %cmp2.i600, label %if.then3.i602, label %if.else4.i604, !decision.origin !191

if.then3.i602:                                    ; preds = %if.else.i601
  %150 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.3) #3
  br label %quant_decide.exit619, !decision.origin !192, !decision.order !193

if.else4.i604:                                    ; preds = %if.else.i601
  %cmp6.i603 = fcmp ugt float %148, 1.250000e+00
  br i1 %cmp6.i603, label %if.else8.i607, label %if.then7.i605, !decision.origin !194

if.then7.i605:                                    ; preds = %if.else4.i604
  %151 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.3) #3
  br label %quant_decide.exit619, !decision.origin !195, !decision.order !196

if.else8.i607:                                    ; preds = %if.else4.i604
  %cmp10.i606 = fcmp olt float %148, 1.750000e+00
  br i1 %cmp10.i606, label %if.then11.i608, label %if.else12.i610, !decision.origin !197

if.then11.i608:                                   ; preds = %if.else8.i607
  %152 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.3) #3
  br label %quant_decide.exit619, !decision.origin !198, !decision.order !199

if.else12.i610:                                   ; preds = %if.else8.i607
  %cmp14.i609 = fcmp ugt float %148, 2.500000e+00
  br i1 %cmp14.i609, label %if.else16.i613, label %if.then15.i611, !decision.origin !200

if.then15.i611:                                   ; preds = %if.else12.i610
  %153 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.3) #3
  br label %quant_decide.exit619, !decision.origin !201, !decision.order !202

if.else16.i613:                                   ; preds = %if.else12.i610
  %cmp18.i612 = fcmp olt float %148, 3.500000e+00
  br i1 %cmp18.i612, label %if.then19.i614, label %if.else20.i616, !decision.origin !203

if.then19.i614:                                   ; preds = %if.else16.i613
  %154 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.3) #3
  br label %quant_decide.exit619, !decision.origin !204, !decision.order !205

if.else20.i616:                                   ; preds = %if.else16.i613
  %cmp22.i615 = fcmp ugt float %148, 5.000000e+00
  br i1 %cmp22.i615, label %if.end29.i618, label %if.then23.i617, !decision.origin !206

if.then23.i617:                                   ; preds = %if.else20.i616
  %155 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.3) #3
  br label %quant_decide.exit619, !decision.origin !207, !decision.order !208

if.end29.i618:                                    ; preds = %if.else20.i616
  %156 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.3) #3
  br label %quant_decide.exit619, !decision.origin !209, !decision.order !210

quant_decide.exit619:                             ; preds = %if.end29.i618, %if.then23.i617, %if.then19.i614, %if.then15.i611, %if.then11.i608, %if.then7.i605, %if.then3.i602, %if.then.i599
  %out.i372.3 = phi float [ %150, %if.then3.i602 ], [ %152, %if.then11.i608 ], [ %154, %if.then19.i614 ], [ %156, %if.end29.i618 ], [ %155, %if.then23.i617 ], [ %153, %if.then15.i611 ], [ %151, %if.then7.i605 ], [ %149, %if.then.i599 ]
  %mul118.3 = fmul float %cond88, %out.i372.3
  %sub.3 = fsub float %mul118.3, %36
  %mul126.3 = fmul float %div73, %40
  %157 = tail call float @llvm.fabs.f32(float %mul126.3) #3
  %cmp.i576 = fcmp ugt float %157, 2.500000e-01
  br i1 %cmp.i576, label %if.else.i579, label %if.then.i577, !decision.origin !211

if.then.i577:                                     ; preds = %quant_decide.exit619
  %158 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.3) #3
  br label %quant_decide.exit597, !decision.origin !212, !decision.order !213

if.else.i579:                                     ; preds = %quant_decide.exit619
  %cmp2.i578 = fcmp olt float %157, 7.500000e-01
  br i1 %cmp2.i578, label %if.then3.i580, label %if.else4.i582, !decision.origin !214

if.then3.i580:                                    ; preds = %if.else.i579
  %159 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.3) #3
  br label %quant_decide.exit597, !decision.origin !215, !decision.order !216

if.else4.i582:                                    ; preds = %if.else.i579
  %cmp6.i581 = fcmp ugt float %157, 1.250000e+00
  br i1 %cmp6.i581, label %if.else8.i585, label %if.then7.i583, !decision.origin !217

if.then7.i583:                                    ; preds = %if.else4.i582
  %160 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.3) #3
  br label %quant_decide.exit597, !decision.origin !218, !decision.order !219

if.else8.i585:                                    ; preds = %if.else4.i582
  %cmp10.i584 = fcmp olt float %157, 1.750000e+00
  br i1 %cmp10.i584, label %if.then11.i586, label %if.else12.i588, !decision.origin !220

if.then11.i586:                                   ; preds = %if.else8.i585
  %161 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.3) #3
  br label %quant_decide.exit597, !decision.origin !221, !decision.order !222

if.else12.i588:                                   ; preds = %if.else8.i585
  %cmp14.i587 = fcmp ugt float %157, 2.500000e+00
  br i1 %cmp14.i587, label %if.else16.i591, label %if.then15.i589, !decision.origin !223

if.then15.i589:                                   ; preds = %if.else12.i588
  %162 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.3) #3
  br label %quant_decide.exit597, !decision.origin !224, !decision.order !225

if.else16.i591:                                   ; preds = %if.else12.i588
  %cmp18.i590 = fcmp olt float %157, 3.500000e+00
  br i1 %cmp18.i590, label %if.then19.i592, label %if.else20.i594, !decision.origin !226

if.then19.i592:                                   ; preds = %if.else16.i591
  %163 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.3) #3
  br label %quant_decide.exit597, !decision.origin !227, !decision.order !228

if.else20.i594:                                   ; preds = %if.else16.i591
  %cmp22.i593 = fcmp ugt float %157, 5.000000e+00
  br i1 %cmp22.i593, label %if.end29.i596, label %if.then23.i595, !decision.origin !229

if.then23.i595:                                   ; preds = %if.else20.i594
  %164 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.3) #3
  br label %quant_decide.exit597, !decision.origin !230, !decision.order !231

if.end29.i596:                                    ; preds = %if.else20.i594
  %165 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.3) #3
  br label %quant_decide.exit597, !decision.origin !232, !decision.order !233

quant_decide.exit597:                             ; preds = %if.end29.i596, %if.then23.i595, %if.then19.i592, %if.then15.i589, %if.then11.i586, %if.then7.i583, %if.then3.i580, %if.then.i577
  %out.i.3 = phi float [ %159, %if.then3.i580 ], [ %161, %if.then11.i586 ], [ %163, %if.then19.i592 ], [ %165, %if.end29.i596 ], [ %164, %if.then23.i595 ], [ %162, %if.then15.i589 ], [ %160, %if.then7.i583 ], [ %158, %if.then.i577 ]
  %mul128.3 = fmul float %cond88, %out.i.3
  %sub132.3 = fsub float %mul128.3, %40
  %mul133.3 = fmul float %sub.3, %sub.3
  %mul134.3 = fmul float %sub132.3, %sub132.3
  %add135.3 = fadd float %mul133.3, %mul134.3
  %e.1.3 = fadd float %e.1.2, %add135.3
  %mul116.4 = fmul float %div73, %44
  %166 = tail call float @llvm.fabs.f32(float %mul116.4) #3
  %cmp.i554 = fcmp ugt float %166, 2.500000e-01
  br i1 %cmp.i554, label %if.else.i557, label %if.then.i555, !decision.origin !234

if.then.i555:                                     ; preds = %quant_decide.exit597
  %167 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.4) #3
  br label %quant_decide.exit575, !decision.origin !235, !decision.order !236

if.else.i557:                                     ; preds = %quant_decide.exit597
  %cmp2.i556 = fcmp olt float %166, 7.500000e-01
  br i1 %cmp2.i556, label %if.then3.i558, label %if.else4.i560, !decision.origin !237

if.then3.i558:                                    ; preds = %if.else.i557
  %168 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.4) #3
  br label %quant_decide.exit575, !decision.origin !238, !decision.order !239

if.else4.i560:                                    ; preds = %if.else.i557
  %cmp6.i559 = fcmp ugt float %166, 1.250000e+00
  br i1 %cmp6.i559, label %if.else8.i563, label %if.then7.i561, !decision.origin !240

if.then7.i561:                                    ; preds = %if.else4.i560
  %169 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.4) #3
  br label %quant_decide.exit575, !decision.origin !241, !decision.order !242

if.else8.i563:                                    ; preds = %if.else4.i560
  %cmp10.i562 = fcmp olt float %166, 1.750000e+00
  br i1 %cmp10.i562, label %if.then11.i564, label %if.else12.i566, !decision.origin !243

if.then11.i564:                                   ; preds = %if.else8.i563
  %170 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.4) #3
  br label %quant_decide.exit575, !decision.origin !244, !decision.order !245

if.else12.i566:                                   ; preds = %if.else8.i563
  %cmp14.i565 = fcmp ugt float %166, 2.500000e+00
  br i1 %cmp14.i565, label %if.else16.i569, label %if.then15.i567, !decision.origin !246

if.then15.i567:                                   ; preds = %if.else12.i566
  %171 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.4) #3
  br label %quant_decide.exit575, !decision.origin !247, !decision.order !248

if.else16.i569:                                   ; preds = %if.else12.i566
  %cmp18.i568 = fcmp olt float %166, 3.500000e+00
  br i1 %cmp18.i568, label %if.then19.i570, label %if.else20.i572, !decision.origin !249

if.then19.i570:                                   ; preds = %if.else16.i569
  %172 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.4) #3
  br label %quant_decide.exit575, !decision.origin !250, !decision.order !251

if.else20.i572:                                   ; preds = %if.else16.i569
  %cmp22.i571 = fcmp ugt float %166, 5.000000e+00
  br i1 %cmp22.i571, label %if.end29.i574, label %if.then23.i573, !decision.origin !252

if.then23.i573:                                   ; preds = %if.else20.i572
  %173 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.4) #3
  br label %quant_decide.exit575, !decision.origin !253, !decision.order !254

if.end29.i574:                                    ; preds = %if.else20.i572
  %174 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.4) #3
  br label %quant_decide.exit575, !decision.origin !255, !decision.order !256

quant_decide.exit575:                             ; preds = %if.end29.i574, %if.then23.i573, %if.then19.i570, %if.then15.i567, %if.then11.i564, %if.then7.i561, %if.then3.i558, %if.then.i555
  %out.i372.4 = phi float [ %168, %if.then3.i558 ], [ %170, %if.then11.i564 ], [ %172, %if.then19.i570 ], [ %174, %if.end29.i574 ], [ %173, %if.then23.i573 ], [ %171, %if.then15.i567 ], [ %169, %if.then7.i561 ], [ %167, %if.then.i555 ]
  %mul118.4 = fmul float %cond88, %out.i372.4
  %sub.4 = fsub float %mul118.4, %44
  %mul126.4 = fmul float %div73, %48
  %175 = tail call float @llvm.fabs.f32(float %mul126.4) #3
  %cmp.i532 = fcmp ugt float %175, 2.500000e-01
  br i1 %cmp.i532, label %if.else.i535, label %if.then.i533, !decision.origin !257

if.then.i533:                                     ; preds = %quant_decide.exit575
  %176 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.4) #3
  br label %quant_decide.exit553, !decision.origin !258, !decision.order !259

if.else.i535:                                     ; preds = %quant_decide.exit575
  %cmp2.i534 = fcmp olt float %175, 7.500000e-01
  br i1 %cmp2.i534, label %if.then3.i536, label %if.else4.i538, !decision.origin !260

if.then3.i536:                                    ; preds = %if.else.i535
  %177 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.4) #3
  br label %quant_decide.exit553, !decision.origin !261, !decision.order !262

if.else4.i538:                                    ; preds = %if.else.i535
  %cmp6.i537 = fcmp ugt float %175, 1.250000e+00
  br i1 %cmp6.i537, label %if.else8.i541, label %if.then7.i539, !decision.origin !263

if.then7.i539:                                    ; preds = %if.else4.i538
  %178 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.4) #3
  br label %quant_decide.exit553, !decision.origin !264, !decision.order !265

if.else8.i541:                                    ; preds = %if.else4.i538
  %cmp10.i540 = fcmp olt float %175, 1.750000e+00
  br i1 %cmp10.i540, label %if.then11.i542, label %if.else12.i544, !decision.origin !266

if.then11.i542:                                   ; preds = %if.else8.i541
  %179 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.4) #3
  br label %quant_decide.exit553, !decision.origin !267, !decision.order !268

if.else12.i544:                                   ; preds = %if.else8.i541
  %cmp14.i543 = fcmp ugt float %175, 2.500000e+00
  br i1 %cmp14.i543, label %if.else16.i547, label %if.then15.i545, !decision.origin !269

if.then15.i545:                                   ; preds = %if.else12.i544
  %180 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.4) #3
  br label %quant_decide.exit553, !decision.origin !270, !decision.order !271

if.else16.i547:                                   ; preds = %if.else12.i544
  %cmp18.i546 = fcmp olt float %175, 3.500000e+00
  br i1 %cmp18.i546, label %if.then19.i548, label %if.else20.i550, !decision.origin !272

if.then19.i548:                                   ; preds = %if.else16.i547
  %181 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.4) #3
  br label %quant_decide.exit553, !decision.origin !273, !decision.order !274

if.else20.i550:                                   ; preds = %if.else16.i547
  %cmp22.i549 = fcmp ugt float %175, 5.000000e+00
  br i1 %cmp22.i549, label %if.end29.i552, label %if.then23.i551, !decision.origin !275

if.then23.i551:                                   ; preds = %if.else20.i550
  %182 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.4) #3
  br label %quant_decide.exit553, !decision.origin !276, !decision.order !277

if.end29.i552:                                    ; preds = %if.else20.i550
  %183 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.4) #3
  br label %quant_decide.exit553, !decision.origin !278, !decision.order !279

quant_decide.exit553:                             ; preds = %if.end29.i552, %if.then23.i551, %if.then19.i548, %if.then15.i545, %if.then11.i542, %if.then7.i539, %if.then3.i536, %if.then.i533
  %out.i.4 = phi float [ %177, %if.then3.i536 ], [ %179, %if.then11.i542 ], [ %181, %if.then19.i548 ], [ %183, %if.end29.i552 ], [ %182, %if.then23.i551 ], [ %180, %if.then15.i545 ], [ %178, %if.then7.i539 ], [ %176, %if.then.i533 ]
  %mul128.4 = fmul float %cond88, %out.i.4
  %sub132.4 = fsub float %mul128.4, %48
  %mul133.4 = fmul float %sub.4, %sub.4
  %mul134.4 = fmul float %sub132.4, %sub132.4
  %add135.4 = fadd float %mul133.4, %mul134.4
  %e.1.4 = fadd float %e.1.3, %add135.4
  %mul116.5 = fmul float %div73, %52
  %184 = tail call float @llvm.fabs.f32(float %mul116.5) #3
  %cmp.i510 = fcmp ugt float %184, 2.500000e-01
  br i1 %cmp.i510, label %if.else.i513, label %if.then.i511, !decision.origin !280

if.then.i511:                                     ; preds = %quant_decide.exit553
  %185 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.5) #3
  br label %quant_decide.exit531, !decision.origin !281, !decision.order !282

if.else.i513:                                     ; preds = %quant_decide.exit553
  %cmp2.i512 = fcmp olt float %184, 7.500000e-01
  br i1 %cmp2.i512, label %if.then3.i514, label %if.else4.i516, !decision.origin !283

if.then3.i514:                                    ; preds = %if.else.i513
  %186 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.5) #3
  br label %quant_decide.exit531, !decision.origin !284, !decision.order !285

if.else4.i516:                                    ; preds = %if.else.i513
  %cmp6.i515 = fcmp ugt float %184, 1.250000e+00
  br i1 %cmp6.i515, label %if.else8.i519, label %if.then7.i517, !decision.origin !286

if.then7.i517:                                    ; preds = %if.else4.i516
  %187 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.5) #3
  br label %quant_decide.exit531, !decision.origin !287, !decision.order !288

if.else8.i519:                                    ; preds = %if.else4.i516
  %cmp10.i518 = fcmp olt float %184, 1.750000e+00
  br i1 %cmp10.i518, label %if.then11.i520, label %if.else12.i522, !decision.origin !289

if.then11.i520:                                   ; preds = %if.else8.i519
  %188 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.5) #3
  br label %quant_decide.exit531, !decision.origin !290, !decision.order !291

if.else12.i522:                                   ; preds = %if.else8.i519
  %cmp14.i521 = fcmp ugt float %184, 2.500000e+00
  br i1 %cmp14.i521, label %if.else16.i525, label %if.then15.i523, !decision.origin !292

if.then15.i523:                                   ; preds = %if.else12.i522
  %189 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.5) #3
  br label %quant_decide.exit531, !decision.origin !293, !decision.order !294

if.else16.i525:                                   ; preds = %if.else12.i522
  %cmp18.i524 = fcmp olt float %184, 3.500000e+00
  br i1 %cmp18.i524, label %if.then19.i526, label %if.else20.i528, !decision.origin !295

if.then19.i526:                                   ; preds = %if.else16.i525
  %190 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.5) #3
  br label %quant_decide.exit531, !decision.origin !296, !decision.order !297

if.else20.i528:                                   ; preds = %if.else16.i525
  %cmp22.i527 = fcmp ugt float %184, 5.000000e+00
  br i1 %cmp22.i527, label %if.end29.i530, label %if.then23.i529, !decision.origin !298

if.then23.i529:                                   ; preds = %if.else20.i528
  %191 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.5) #3
  br label %quant_decide.exit531, !decision.origin !299, !decision.order !300

if.end29.i530:                                    ; preds = %if.else20.i528
  %192 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.5) #3
  br label %quant_decide.exit531, !decision.origin !301, !decision.order !302

quant_decide.exit531:                             ; preds = %if.end29.i530, %if.then23.i529, %if.then19.i526, %if.then15.i523, %if.then11.i520, %if.then7.i517, %if.then3.i514, %if.then.i511
  %out.i372.5 = phi float [ %186, %if.then3.i514 ], [ %188, %if.then11.i520 ], [ %190, %if.then19.i526 ], [ %192, %if.end29.i530 ], [ %191, %if.then23.i529 ], [ %189, %if.then15.i523 ], [ %187, %if.then7.i517 ], [ %185, %if.then.i511 ]
  %mul118.5 = fmul float %cond88, %out.i372.5
  %sub.5 = fsub float %mul118.5, %52
  %mul126.5 = fmul float %div73, %56
  %193 = tail call float @llvm.fabs.f32(float %mul126.5) #3
  %cmp.i488 = fcmp ugt float %193, 2.500000e-01
  br i1 %cmp.i488, label %if.else.i491, label %if.then.i489, !decision.origin !303

if.then.i489:                                     ; preds = %quant_decide.exit531
  %194 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.5) #3
  br label %quant_decide.exit509, !decision.origin !304, !decision.order !305

if.else.i491:                                     ; preds = %quant_decide.exit531
  %cmp2.i490 = fcmp olt float %193, 7.500000e-01
  br i1 %cmp2.i490, label %if.then3.i492, label %if.else4.i494, !decision.origin !306

if.then3.i492:                                    ; preds = %if.else.i491
  %195 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.5) #3
  br label %quant_decide.exit509, !decision.origin !307, !decision.order !308

if.else4.i494:                                    ; preds = %if.else.i491
  %cmp6.i493 = fcmp ugt float %193, 1.250000e+00
  br i1 %cmp6.i493, label %if.else8.i497, label %if.then7.i495, !decision.origin !309

if.then7.i495:                                    ; preds = %if.else4.i494
  %196 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.5) #3
  br label %quant_decide.exit509, !decision.origin !310, !decision.order !311

if.else8.i497:                                    ; preds = %if.else4.i494
  %cmp10.i496 = fcmp olt float %193, 1.750000e+00
  br i1 %cmp10.i496, label %if.then11.i498, label %if.else12.i500, !decision.origin !312

if.then11.i498:                                   ; preds = %if.else8.i497
  %197 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.5) #3
  br label %quant_decide.exit509, !decision.origin !313, !decision.order !314

if.else12.i500:                                   ; preds = %if.else8.i497
  %cmp14.i499 = fcmp ugt float %193, 2.500000e+00
  br i1 %cmp14.i499, label %if.else16.i503, label %if.then15.i501, !decision.origin !315

if.then15.i501:                                   ; preds = %if.else12.i500
  %198 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.5) #3
  br label %quant_decide.exit509, !decision.origin !316, !decision.order !317

if.else16.i503:                                   ; preds = %if.else12.i500
  %cmp18.i502 = fcmp olt float %193, 3.500000e+00
  br i1 %cmp18.i502, label %if.then19.i504, label %if.else20.i506, !decision.origin !318

if.then19.i504:                                   ; preds = %if.else16.i503
  %199 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.5) #3
  br label %quant_decide.exit509, !decision.origin !319, !decision.order !320

if.else20.i506:                                   ; preds = %if.else16.i503
  %cmp22.i505 = fcmp ugt float %193, 5.000000e+00
  br i1 %cmp22.i505, label %if.end29.i508, label %if.then23.i507, !decision.origin !321

if.then23.i507:                                   ; preds = %if.else20.i506
  %200 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.5) #3
  br label %quant_decide.exit509, !decision.origin !322, !decision.order !323

if.end29.i508:                                    ; preds = %if.else20.i506
  %201 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.5) #3
  br label %quant_decide.exit509, !decision.origin !324, !decision.order !325

quant_decide.exit509:                             ; preds = %if.end29.i508, %if.then23.i507, %if.then19.i504, %if.then15.i501, %if.then11.i498, %if.then7.i495, %if.then3.i492, %if.then.i489
  %out.i.5 = phi float [ %195, %if.then3.i492 ], [ %197, %if.then11.i498 ], [ %199, %if.then19.i504 ], [ %201, %if.end29.i508 ], [ %200, %if.then23.i507 ], [ %198, %if.then15.i501 ], [ %196, %if.then7.i495 ], [ %194, %if.then.i489 ]
  %mul128.5 = fmul float %cond88, %out.i.5
  %sub132.5 = fsub float %mul128.5, %56
  %mul133.5 = fmul float %sub.5, %sub.5
  %mul134.5 = fmul float %sub132.5, %sub132.5
  %add135.5 = fadd float %mul133.5, %mul134.5
  %e.1.5 = fadd float %e.1.4, %add135.5
  %mul116.6 = fmul float %div73, %60
  %202 = tail call float @llvm.fabs.f32(float %mul116.6) #3
  %cmp.i466 = fcmp ugt float %202, 2.500000e-01
  br i1 %cmp.i466, label %if.else.i469, label %if.then.i467, !decision.origin !326

if.then.i467:                                     ; preds = %quant_decide.exit509
  %203 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.6) #3
  br label %quant_decide.exit487, !decision.origin !327, !decision.order !328

if.else.i469:                                     ; preds = %quant_decide.exit509
  %cmp2.i468 = fcmp olt float %202, 7.500000e-01
  br i1 %cmp2.i468, label %if.then3.i470, label %if.else4.i472, !decision.origin !329

if.then3.i470:                                    ; preds = %if.else.i469
  %204 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.6) #3
  br label %quant_decide.exit487, !decision.origin !330, !decision.order !331

if.else4.i472:                                    ; preds = %if.else.i469
  %cmp6.i471 = fcmp ugt float %202, 1.250000e+00
  br i1 %cmp6.i471, label %if.else8.i475, label %if.then7.i473, !decision.origin !332

if.then7.i473:                                    ; preds = %if.else4.i472
  %205 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.6) #3
  br label %quant_decide.exit487, !decision.origin !333, !decision.order !334

if.else8.i475:                                    ; preds = %if.else4.i472
  %cmp10.i474 = fcmp olt float %202, 1.750000e+00
  br i1 %cmp10.i474, label %if.then11.i476, label %if.else12.i478, !decision.origin !335

if.then11.i476:                                   ; preds = %if.else8.i475
  %206 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.6) #3
  br label %quant_decide.exit487, !decision.origin !336, !decision.order !337

if.else12.i478:                                   ; preds = %if.else8.i475
  %cmp14.i477 = fcmp ugt float %202, 2.500000e+00
  br i1 %cmp14.i477, label %if.else16.i481, label %if.then15.i479, !decision.origin !338

if.then15.i479:                                   ; preds = %if.else12.i478
  %207 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.6) #3
  br label %quant_decide.exit487, !decision.origin !339, !decision.order !340

if.else16.i481:                                   ; preds = %if.else12.i478
  %cmp18.i480 = fcmp olt float %202, 3.500000e+00
  br i1 %cmp18.i480, label %if.then19.i482, label %if.else20.i484, !decision.origin !341

if.then19.i482:                                   ; preds = %if.else16.i481
  %208 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.6) #3
  br label %quant_decide.exit487, !decision.origin !342, !decision.order !343

if.else20.i484:                                   ; preds = %if.else16.i481
  %cmp22.i483 = fcmp ugt float %202, 5.000000e+00
  br i1 %cmp22.i483, label %if.end29.i486, label %if.then23.i485, !decision.origin !344

if.then23.i485:                                   ; preds = %if.else20.i484
  %209 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.6) #3
  br label %quant_decide.exit487, !decision.origin !345, !decision.order !346

if.end29.i486:                                    ; preds = %if.else20.i484
  %210 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.6) #3
  br label %quant_decide.exit487, !decision.origin !347, !decision.order !348

quant_decide.exit487:                             ; preds = %if.end29.i486, %if.then23.i485, %if.then19.i482, %if.then15.i479, %if.then11.i476, %if.then7.i473, %if.then3.i470, %if.then.i467
  %out.i372.6 = phi float [ %204, %if.then3.i470 ], [ %206, %if.then11.i476 ], [ %208, %if.then19.i482 ], [ %210, %if.end29.i486 ], [ %209, %if.then23.i485 ], [ %207, %if.then15.i479 ], [ %205, %if.then7.i473 ], [ %203, %if.then.i467 ]
  %mul118.6 = fmul float %cond88, %out.i372.6
  %sub.6 = fsub float %mul118.6, %60
  %mul126.6 = fmul float %div73, %64
  %211 = tail call float @llvm.fabs.f32(float %mul126.6) #3
  %cmp.i444 = fcmp ugt float %211, 2.500000e-01
  br i1 %cmp.i444, label %if.else.i447, label %if.then.i445, !decision.origin !349

if.then.i445:                                     ; preds = %quant_decide.exit487
  %212 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.6) #3
  br label %quant_decide.exit465, !decision.origin !350, !decision.order !351

if.else.i447:                                     ; preds = %quant_decide.exit487
  %cmp2.i446 = fcmp olt float %211, 7.500000e-01
  br i1 %cmp2.i446, label %if.then3.i448, label %if.else4.i450, !decision.origin !352

if.then3.i448:                                    ; preds = %if.else.i447
  %213 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.6) #3
  br label %quant_decide.exit465, !decision.origin !353, !decision.order !354

if.else4.i450:                                    ; preds = %if.else.i447
  %cmp6.i449 = fcmp ugt float %211, 1.250000e+00
  br i1 %cmp6.i449, label %if.else8.i453, label %if.then7.i451, !decision.origin !355

if.then7.i451:                                    ; preds = %if.else4.i450
  %214 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.6) #3
  br label %quant_decide.exit465, !decision.origin !356, !decision.order !357

if.else8.i453:                                    ; preds = %if.else4.i450
  %cmp10.i452 = fcmp olt float %211, 1.750000e+00
  br i1 %cmp10.i452, label %if.then11.i454, label %if.else12.i456, !decision.origin !358

if.then11.i454:                                   ; preds = %if.else8.i453
  %215 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.6) #3
  br label %quant_decide.exit465, !decision.origin !359, !decision.order !360

if.else12.i456:                                   ; preds = %if.else8.i453
  %cmp14.i455 = fcmp ugt float %211, 2.500000e+00
  br i1 %cmp14.i455, label %if.else16.i459, label %if.then15.i457, !decision.origin !361

if.then15.i457:                                   ; preds = %if.else12.i456
  %216 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.6) #3
  br label %quant_decide.exit465, !decision.origin !362, !decision.order !363

if.else16.i459:                                   ; preds = %if.else12.i456
  %cmp18.i458 = fcmp olt float %211, 3.500000e+00
  br i1 %cmp18.i458, label %if.then19.i460, label %if.else20.i462, !decision.origin !364

if.then19.i460:                                   ; preds = %if.else16.i459
  %217 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.6) #3
  br label %quant_decide.exit465, !decision.origin !365, !decision.order !366

if.else20.i462:                                   ; preds = %if.else16.i459
  %cmp22.i461 = fcmp ugt float %211, 5.000000e+00
  br i1 %cmp22.i461, label %if.end29.i464, label %if.then23.i463, !decision.origin !367

if.then23.i463:                                   ; preds = %if.else20.i462
  %218 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.6) #3
  br label %quant_decide.exit465, !decision.origin !368, !decision.order !369

if.end29.i464:                                    ; preds = %if.else20.i462
  %219 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.6) #3
  br label %quant_decide.exit465, !decision.origin !370, !decision.order !371

quant_decide.exit465:                             ; preds = %if.end29.i464, %if.then23.i463, %if.then19.i460, %if.then15.i457, %if.then11.i454, %if.then7.i451, %if.then3.i448, %if.then.i445
  %out.i.6 = phi float [ %213, %if.then3.i448 ], [ %215, %if.then11.i454 ], [ %217, %if.then19.i460 ], [ %219, %if.end29.i464 ], [ %218, %if.then23.i463 ], [ %216, %if.then15.i457 ], [ %214, %if.then7.i451 ], [ %212, %if.then.i445 ]
  %mul128.6 = fmul float %cond88, %out.i.6
  %sub132.6 = fsub float %mul128.6, %64
  %mul133.6 = fmul float %sub.6, %sub.6
  %mul134.6 = fmul float %sub132.6, %sub132.6
  %add135.6 = fadd float %mul133.6, %mul134.6
  %e.1.6 = fadd float %e.1.5, %add135.6
  %mul116.7 = fmul float %74, %div73
  %220 = tail call float @llvm.fabs.f32(float %mul116.7) #3
  %cmp.i422 = fcmp ugt float %220, 2.500000e-01
  br i1 %cmp.i422, label %if.else.i425, label %if.then.i423, !decision.origin !372

if.then.i423:                                     ; preds = %quant_decide.exit465
  %221 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.7) #3
  br label %quant_decide.exit443, !decision.origin !373, !decision.order !374

if.else.i425:                                     ; preds = %quant_decide.exit465
  %cmp2.i424 = fcmp olt float %220, 7.500000e-01
  br i1 %cmp2.i424, label %if.then3.i426, label %if.else4.i428, !decision.origin !375

if.then3.i426:                                    ; preds = %if.else.i425
  %222 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.7) #3
  br label %quant_decide.exit443, !decision.origin !376, !decision.order !377

if.else4.i428:                                    ; preds = %if.else.i425
  %cmp6.i427 = fcmp ugt float %220, 1.250000e+00
  br i1 %cmp6.i427, label %if.else8.i431, label %if.then7.i429, !decision.origin !378

if.then7.i429:                                    ; preds = %if.else4.i428
  %223 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.7) #3
  br label %quant_decide.exit443, !decision.origin !379, !decision.order !380

if.else8.i431:                                    ; preds = %if.else4.i428
  %cmp10.i430 = fcmp olt float %220, 1.750000e+00
  br i1 %cmp10.i430, label %if.then11.i432, label %if.else12.i434, !decision.origin !381

if.then11.i432:                                   ; preds = %if.else8.i431
  %224 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.7) #3
  br label %quant_decide.exit443, !decision.origin !382, !decision.order !383

if.else12.i434:                                   ; preds = %if.else8.i431
  %cmp14.i433 = fcmp ugt float %220, 2.500000e+00
  br i1 %cmp14.i433, label %if.else16.i437, label %if.then15.i435, !decision.origin !384

if.then15.i435:                                   ; preds = %if.else12.i434
  %225 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.7) #3
  br label %quant_decide.exit443, !decision.origin !385, !decision.order !386

if.else16.i437:                                   ; preds = %if.else12.i434
  %cmp18.i436 = fcmp olt float %220, 3.500000e+00
  br i1 %cmp18.i436, label %if.then19.i438, label %if.else20.i440, !decision.origin !387

if.then19.i438:                                   ; preds = %if.else16.i437
  %226 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.7) #3
  br label %quant_decide.exit443, !decision.origin !388, !decision.order !389

if.else20.i440:                                   ; preds = %if.else16.i437
  %cmp22.i439 = fcmp ugt float %220, 5.000000e+00
  br i1 %cmp22.i439, label %if.end29.i442, label %if.then23.i441, !decision.origin !390

if.then23.i441:                                   ; preds = %if.else20.i440
  %227 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.7) #3
  br label %quant_decide.exit443, !decision.origin !391, !decision.order !392

if.end29.i442:                                    ; preds = %if.else20.i440
  %228 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.7) #3
  br label %quant_decide.exit443, !decision.origin !393, !decision.order !394

quant_decide.exit443:                             ; preds = %if.end29.i442, %if.then23.i441, %if.then19.i438, %if.then15.i435, %if.then11.i432, %if.then7.i429, %if.then3.i426, %if.then.i423
  %out.i372.7 = phi float [ %222, %if.then3.i426 ], [ %224, %if.then11.i432 ], [ %226, %if.then19.i438 ], [ %228, %if.end29.i442 ], [ %227, %if.then23.i441 ], [ %225, %if.then15.i435 ], [ %223, %if.then7.i429 ], [ %221, %if.then.i423 ]
  %mul118.7 = fmul float %cond88, %out.i372.7
  %sub.7 = fsub float %mul118.7, %74
  %mul126.7 = fmul float %77, %div73
  %229 = tail call float @llvm.fabs.f32(float %mul126.7) #3
  %cmp.i400 = fcmp ugt float %229, 2.500000e-01
  br i1 %cmp.i400, label %if.else.i403, label %if.then.i401, !decision.origin !395

if.then.i401:                                     ; preds = %quant_decide.exit443
  %230 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.7) #3
  br label %quant_decide.exit421, !decision.origin !396, !decision.order !397

if.else.i403:                                     ; preds = %quant_decide.exit443
  %cmp2.i402 = fcmp olt float %229, 7.500000e-01
  br i1 %cmp2.i402, label %if.then3.i404, label %if.else4.i406, !decision.origin !398

if.then3.i404:                                    ; preds = %if.else.i403
  %231 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.7) #3
  br label %quant_decide.exit421, !decision.origin !399, !decision.order !400

if.else4.i406:                                    ; preds = %if.else.i403
  %cmp6.i405 = fcmp ugt float %229, 1.250000e+00
  br i1 %cmp6.i405, label %if.else8.i409, label %if.then7.i407, !decision.origin !401

if.then7.i407:                                    ; preds = %if.else4.i406
  %232 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.7) #3
  br label %quant_decide.exit421, !decision.origin !402, !decision.order !403

if.else8.i409:                                    ; preds = %if.else4.i406
  %cmp10.i408 = fcmp olt float %229, 1.750000e+00
  br i1 %cmp10.i408, label %if.then11.i410, label %if.else12.i412, !decision.origin !404

if.then11.i410:                                   ; preds = %if.else8.i409
  %233 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.7) #3
  br label %quant_decide.exit421, !decision.origin !405, !decision.order !406

if.else12.i412:                                   ; preds = %if.else8.i409
  %cmp14.i411 = fcmp ugt float %229, 2.500000e+00
  br i1 %cmp14.i411, label %if.else16.i415, label %if.then15.i413, !decision.origin !407

if.then15.i413:                                   ; preds = %if.else12.i412
  %234 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.7) #3
  br label %quant_decide.exit421, !decision.origin !408, !decision.order !409

if.else16.i415:                                   ; preds = %if.else12.i412
  %cmp18.i414 = fcmp olt float %229, 3.500000e+00
  br i1 %cmp18.i414, label %if.then19.i416, label %if.else20.i418, !decision.origin !410

if.then19.i416:                                   ; preds = %if.else16.i415
  %235 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.7) #3
  br label %quant_decide.exit421, !decision.origin !411, !decision.order !412

if.else20.i418:                                   ; preds = %if.else16.i415
  %cmp22.i417 = fcmp ugt float %229, 5.000000e+00
  br i1 %cmp22.i417, label %if.end29.i420, label %if.then23.i419, !decision.origin !413

if.then23.i419:                                   ; preds = %if.else20.i418
  %236 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.7) #3
  br label %quant_decide.exit421, !decision.origin !414, !decision.order !415

if.end29.i420:                                    ; preds = %if.else20.i418
  %237 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.7) #3
  br label %quant_decide.exit421, !decision.origin !416, !decision.order !417

quant_decide.exit421:                             ; preds = %if.end29.i420, %if.then23.i419, %if.then19.i416, %if.then15.i413, %if.then11.i410, %if.then7.i407, %if.then3.i404, %if.then.i401
  %out.i.7 = phi float [ %231, %if.then3.i404 ], [ %233, %if.then11.i410 ], [ %235, %if.then19.i416 ], [ %237, %if.end29.i420 ], [ %236, %if.then23.i419 ], [ %234, %if.then15.i413 ], [ %232, %if.then7.i407 ], [ %230, %if.then.i401 ]
  %mul128.7 = fmul float %cond88, %out.i.7
  %sub132.7 = fsub float %mul128.7, %77
  %mul133.7 = fmul float %sub.7, %sub.7
  %mul134.7 = fmul float %sub132.7, %sub132.7
  br label %for.inc138.7, !decision.origin !418

if.then97.7:                                      ; preds = %cond.end75, %cond.end75.thread
  %os.sroa.0.3 = phi <2 x float> [ %84, %cond.end75 ], [ %83, %cond.end75.thread ]
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
  br label %for.inc138.7, !decision.origin !419

for.inc138.7:                                     ; preds = %if.then97.7, %quant_decide.exit421
  %os.sroa.0.4 = phi <2 x float> [ %os.sroa.0.3, %if.then97.7 ], [ %84, %quant_decide.exit421 ]
  %mul109.7.sink = phi float [ %mul109.7, %if.then97.7 ], [ %mul134.7, %quant_decide.exit421 ]
  %mul102.7.sink = phi float [ %mul102.7, %if.then97.7 ], [ %mul133.7, %quant_decide.exit421 ]
  %e.1.6551 = phi float [ %e.1.6550, %if.then97.7 ], [ %e.1.6, %quant_decide.exit421 ]
  %add110.7 = fadd float %mul109.7.sink, %mul102.7.sink
  %e.1.7 = fadd float %e.1.6551, %add110.7
  %mul60.1 = fmul float %79, 2.500000e-01
  %mul61.1 = fmul float %cond29, %mul60.1
  %cmp.i379.1 = fcmp ult float %mul61.1, 4.480000e+02
  br i1 %cmp.i379.1, label %_Z4dec8i.exit.i.2.1, label %_Z4enc8f.exit.thread396.1, !decision.origin !420

_Z4enc8f.exit.thread396.1:                        ; preds = %for.inc138.7
  store i8 126, i8 addrspace(5)* %arrayidx64340398.1, align 1, !tbaa !18
  br label %cond.true.i.1, !decision.origin !421

_Z4dec8i.exit.i.2.1:                              ; preds = %for.inc138.7
  %cmp2.i.1424 = fcmp ogt float %mul61.1, 1.875000e+00
  %hi.1.i.1425 = select i1 %cmp2.i.1424, i32 126, i32 63
  %lo.1.i.1426 = select i1 %cmp2.i.1424, i32 64, i32 0
  %div.i.1.1 = select i1 %cmp2.i.1424, i32 95, i32 31
  %238 = lshr i32 %div.i.1.1, 3
  %sub.i.i.1.1 = add nsw i32 %238, -7
  %239 = tail call float @llvm.amdgcn.ldexp.f32(float 1.875000e+00, i32 %sub.i.i.1.1) #3
  %cmp2.i.1.1 = fcmp olt float %239, %mul61.1
  %add4.i.1.1 = add nuw nsw i32 %div.i.1.1, 1
  %hi.1.i.1.1 = select i1 %cmp2.i.1.1, i32 %hi.1.i.1425, i32 %div.i.1.1
  %lo.1.i.1.1 = select i1 %cmp2.i.1.1, i32 %add4.i.1.1, i32 %lo.1.i.1426
  %add.i381.2.1 = add nuw nsw i32 %lo.1.i.1.1, %hi.1.i.1.1
  %div.i.2.1 = lshr i32 %add.i381.2.1, 1
  %240 = lshr i32 %add.i381.2.1, 4
  %sub.i.i.2.1 = add nsw i32 %240, -7
  %241 = tail call float @llvm.amdgcn.ldexp.f32(float 1.875000e+00, i32 %sub.i.i.2.1) #3
  %cmp2.i.2.1 = fcmp olt float %241, %mul61.1
  %add4.i.2.1 = add nuw nsw i32 %div.i.2.1, 1
  %hi.1.i.2.1 = select i1 %cmp2.i.2.1, i32 %hi.1.i.1.1, i32 %div.i.2.1
  %lo.1.i.2.1 = select i1 %cmp2.i.2.1, i32 %add4.i.2.1, i32 %lo.1.i.1.1
  %add.i381.3.1 = add nuw nsw i32 %lo.1.i.2.1, %hi.1.i.2.1
  %div.i.3.1 = lshr i32 %add.i381.3.1, 1
  %242 = lshr i32 %add.i381.3.1, 4
  %and.i.i.3.1 = and i32 %div.i.3.1, 7
  %tobool.not.i.i.3.1 = icmp eq i32 %242, 0
  %conv1.i.i.3.1 = sitofp i32 %and.i.i.3.1 to float
  br i1 %tobool.not.i.i.3.1, label %cond.false.i.i.3.1, label %cond.true.i.i.3.1, !decision.origin !422

cond.true.i.i.3.1:                                ; preds = %_Z4dec8i.exit.i.2.1
  %mul.i.i.3.1 = fmul float %conv1.i.i.3.1, 1.250000e-01
  %add.i.i.3.1 = fadd float %mul.i.i.3.1, 1.000000e+00
  %sub.i.i.3.1 = add nsw i32 %242, -7
  %243 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i.i.3.1, i32 %sub.i.i.3.1) #3
  br label %_Z4dec8i.exit.i.3.1, !decision.origin !423

cond.false.i.i.3.1:                               ; preds = %_Z4dec8i.exit.i.2.1
  %mul2.i.i.3.1 = fmul float %conv1.i.i.3.1, 0x3F60000000000000
  br label %_Z4dec8i.exit.i.3.1, !decision.origin !424

_Z4dec8i.exit.i.3.1:                              ; preds = %cond.false.i.i.3.1, %cond.true.i.i.3.1
  %cond.i.i.3.1 = phi float [ %243, %cond.true.i.i.3.1 ], [ %mul2.i.i.3.1, %cond.false.i.i.3.1 ]
  %cmp2.i.3.1 = fcmp olt float %cond.i.i.3.1, %mul61.1
  %add4.i.3.1 = add nuw nsw i32 %div.i.3.1, 1
  %hi.1.i.3.1 = select i1 %cmp2.i.3.1, i32 %hi.1.i.2.1, i32 %div.i.3.1
  %lo.1.i.3.1 = select i1 %cmp2.i.3.1, i32 %add4.i.3.1, i32 %lo.1.i.2.1
  %add.i381.4.1 = add nuw nsw i32 %lo.1.i.3.1, %hi.1.i.3.1
  %div.i.4.1 = lshr i32 %add.i381.4.1, 1
  %244 = lshr i32 %add.i381.4.1, 4
  %and.i.i.4.1 = and i32 %div.i.4.1, 7
  %tobool.not.i.i.4.1 = icmp eq i32 %244, 0
  %conv1.i.i.4.1 = sitofp i32 %and.i.i.4.1 to float
  br i1 %tobool.not.i.i.4.1, label %cond.false.i.i.4.1, label %cond.true.i.i.4.1, !decision.origin !425

cond.true.i.i.4.1:                                ; preds = %_Z4dec8i.exit.i.3.1
  %mul.i.i.4.1 = fmul float %conv1.i.i.4.1, 1.250000e-01
  %add.i.i.4.1 = fadd float %mul.i.i.4.1, 1.000000e+00
  %sub.i.i.4.1 = add nsw i32 %244, -7
  %245 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i.i.4.1, i32 %sub.i.i.4.1) #3
  br label %_Z4dec8i.exit.i.4.1, !decision.origin !426

cond.false.i.i.4.1:                               ; preds = %_Z4dec8i.exit.i.3.1
  %mul2.i.i.4.1 = fmul float %conv1.i.i.4.1, 0x3F60000000000000
  br label %_Z4dec8i.exit.i.4.1, !decision.origin !427

_Z4dec8i.exit.i.4.1:                              ; preds = %cond.false.i.i.4.1, %cond.true.i.i.4.1
  %cond.i.i.4.1 = phi float [ %245, %cond.true.i.i.4.1 ], [ %mul2.i.i.4.1, %cond.false.i.i.4.1 ]
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
  br i1 %tobool.not.i.i.5.1, label %cond.false.i.i.5.1, label %cond.true.i.i.5.1, !decision.origin !428

cond.true.i.i.5.1:                                ; preds = %_Z4dec8i.exit.i.4.1
  %mul.i.i.5.1 = fmul float %conv1.i.i.5.1, 1.250000e-01
  %add.i.i.5.1 = fadd float %mul.i.i.5.1, 1.000000e+00
  %sub.i.i.5.1 = add nsw i32 %shr.i.i.5.1, -7
  %246 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i.i.5.1, i32 %sub.i.i.5.1) #3
  br label %_Z4dec8i.exit.i.5.1, !decision.origin !429

cond.false.i.i.5.1:                               ; preds = %_Z4dec8i.exit.i.4.1
  %mul2.i.i.5.1 = fmul float %conv1.i.i.5.1, 0x3F60000000000000
  br label %_Z4dec8i.exit.i.5.1, !decision.origin !430

_Z4dec8i.exit.i.5.1:                              ; preds = %cond.false.i.i.5.1, %cond.true.i.i.5.1
  %cond.i.i.5.1 = phi float [ %246, %cond.true.i.i.5.1 ], [ %mul2.i.i.5.1, %cond.false.i.i.5.1 ]
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
  br i1 %tobool.not.i.i.6.1, label %cond.false.i.i.6.1, label %cond.true.i.i.6.1, !decision.origin !431

cond.true.i.i.6.1:                                ; preds = %_Z4dec8i.exit.i.5.1
  %mul.i.i.6.1 = fmul float %conv1.i.i.6.1, 1.250000e-01
  %add.i.i.6.1 = fadd float %mul.i.i.6.1, 1.000000e+00
  %sub.i.i.6.1 = add nsw i32 %shr.i.i.6.1, -7
  %247 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i.i.6.1, i32 %sub.i.i.6.1) #3
  br label %_Z4dec8i.exit.i.6.1, !decision.origin !432

cond.false.i.i.6.1:                               ; preds = %_Z4dec8i.exit.i.5.1
  %mul2.i.i.6.1 = fmul float %conv1.i.i.6.1, 0x3F60000000000000
  br label %_Z4dec8i.exit.i.6.1, !decision.origin !433

_Z4dec8i.exit.i.6.1:                              ; preds = %cond.false.i.i.6.1, %cond.true.i.i.6.1
  %cond.i.i.6.1 = phi float [ %247, %cond.true.i.i.6.1 ], [ %mul2.i.i.6.1, %cond.false.i.i.6.1 ]
  %cmp2.i.6.1 = fcmp olt float %cond.i.i.6.1, %mul61.1
  %add4.i.6.1 = add nuw nsw i32 %div.i.6.1, 1
  %lo.1.i.6.1 = select i1 %cmp2.i.6.1, i32 %add4.i.6.1, i32 %lo.1.i.5.1
  %cmp6.i.1 = icmp eq i32 %lo.1.i.6.1, 0
  br i1 %cmp6.i.1, label %_Z4enc8f.exit.thread.1, label %if.end9.i.1, !decision.origin !434

if.end9.i.1:                                      ; preds = %_Z4dec8i.exit.i.6.1
  %sub.i382.1 = add nsw i32 %lo.1.i.6.1, -1
  %shr.i62.i.1 = ashr i32 %sub.i382.1, 3
  %and.i63.i.1 = and i32 %sub.i382.1, 7
  %tobool.not.i64.i.1 = icmp eq i32 %shr.i62.i.1, 0
  %conv1.i70.i.1 = sitofp i32 %and.i63.i.1 to float
  br i1 %tobool.not.i64.i.1, label %cond.false.i72.i.1, label %cond.true.i69.i.1, !decision.origin !435

cond.true.i69.i.1:                                ; preds = %if.end9.i.1
  %mul.i66.i.1 = fmul float %conv1.i70.i.1, 1.250000e-01
  %add.i67.i.1 = fadd float %mul.i66.i.1, 1.000000e+00
  %sub.i68.i.1 = add nsw i32 %shr.i62.i.1, -7
  %248 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i67.i.1, i32 %sub.i68.i.1) #3
  br label %_Z4dec8i.exit74.i.1, !decision.origin !436

cond.false.i72.i.1:                               ; preds = %if.end9.i.1
  %mul2.i71.i.1 = fmul float %conv1.i70.i.1, 0x3F60000000000000
  br label %_Z4dec8i.exit74.i.1, !decision.origin !437

_Z4dec8i.exit74.i.1:                              ; preds = %cond.false.i72.i.1, %cond.true.i69.i.1
  %cond.i73.i.1 = phi float [ %248, %cond.true.i69.i.1 ], [ %mul2.i71.i.1, %cond.false.i72.i.1 ]
  %sub11.i.1 = fsub float %mul61.1, %cond.i73.i.1
  %shr.i49.i.1656 = lshr i32 %lo.1.i.6.1, 3
  %and.i50.i.1 = and i32 %lo.1.i.6.1, 7
  %tobool.not.i51.i.1 = icmp eq i32 %shr.i49.i.1656, 0
  %conv1.i57.i.1 = sitofp i32 %and.i50.i.1 to float
  br i1 %tobool.not.i51.i.1, label %cond.false.i59.i.1, label %cond.true.i56.i.1, !decision.origin !438

cond.true.i56.i.1:                                ; preds = %_Z4dec8i.exit74.i.1
  %mul.i53.i.1 = fmul float %conv1.i57.i.1, 1.250000e-01
  %add.i54.i.1 = fadd float %mul.i53.i.1, 1.000000e+00
  %sub.i55.i.1 = add nsw i32 %shr.i49.i.1656, -7
  %249 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i54.i.1, i32 %sub.i55.i.1) #3
  br label %_Z4dec8i.exit61.i.1, !decision.origin !439

cond.false.i59.i.1:                               ; preds = %_Z4dec8i.exit74.i.1
  %mul2.i58.i.1 = fmul float %conv1.i57.i.1, 0x3F60000000000000
  br label %_Z4dec8i.exit61.i.1, !decision.origin !440

_Z4dec8i.exit61.i.1:                              ; preds = %cond.false.i59.i.1, %cond.true.i56.i.1
  %cond.i60.i.1 = phi float [ %249, %cond.true.i56.i.1 ], [ %mul2.i58.i.1, %cond.false.i59.i.1 ]
  %sub13.i.1 = fsub float %cond.i60.i.1, %mul61.1
  %cmp14.i.1 = fcmp olt float %sub11.i.1, %sub13.i.1
  br i1 %cmp14.i.1, label %_Z4enc8f.exit.1, label %cond.false.i384.1, !decision.origin !441

cond.false.i384.1:                                ; preds = %_Z4dec8i.exit61.i.1
  %cmp16.i383.1 = fcmp olt float %sub13.i.1, %sub11.i.1
  %and.i385.1 = and i32 %lo.1.i.6.1, 1
  %tobool.not.i386.1 = icmp eq i32 %and.i385.1, 0
  %cond.i387.1 = select i1 %tobool.not.i386.1, i32 %lo.1.i.6.1, i32 %sub.i382.1
  br i1 %cmp16.i383.1, label %_Z4enc8f.exit.1, label %cond.false18.i.1, !decision.origin !442

cond.false18.i.1:                                 ; preds = %cond.false.i384.1
  %.pre = and i32 %cond.i387.1, 7
  br label %_Z4enc8f.exit.1, !decision.origin !443

_Z4enc8f.exit.1:                                  ; preds = %cond.false18.i.1, %cond.false.i384.1, %_Z4dec8i.exit61.i.1
  %and.i375.1.pre-phi = phi i32 [ %.pre, %cond.false18.i.1 ], [ %and.i50.i.1, %cond.false.i384.1 ], [ %and.i63.i.1, %_Z4dec8i.exit61.i.1 ]
  %cond25.i.1 = phi i32 [ %cond.i387.1, %cond.false18.i.1 ], [ %lo.1.i.6.1, %cond.false.i384.1 ], [ %sub.i382.1, %_Z4dec8i.exit61.i.1 ]
  %conv.i388.1 = trunc i32 %cond25.i.1 to i8
  store i8 %conv.i388.1, i8 addrspace(5)* %arrayidx64340398.1, align 1, !tbaa !18
  %conv67.1 = lshr i32 %cond25.i.1, 3
  %tobool.not.i.1 = icmp eq i32 %conv67.1, 0
  br i1 %tobool.not.i.1, label %cond.false.i377.1, label %cond.true.i.1, !decision.origin !444

cond.true.i.1:                                    ; preds = %_Z4enc8f.exit.1, %_Z4enc8f.exit.thread396.1
  %and.i375404.1 = phi i32 [ 6, %_Z4enc8f.exit.thread396.1 ], [ %and.i375.1.pre-phi, %_Z4enc8f.exit.1 ]
  %shr.i374403.1 = phi i32 [ 15, %_Z4enc8f.exit.thread396.1 ], [ %conv67.1, %_Z4enc8f.exit.1 ]
  %conv.i376.1 = sitofp i32 %and.i375404.1 to float
  %mul.i.1 = fmul float %conv.i376.1, 1.250000e-01
  %add.i.1 = fadd float %mul.i.1, 1.000000e+00
  %sub.i.1 = add nsw i32 %shr.i374403.1, -7
  %250 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i.1, i32 %sub.i.1) #3
  br label %_Z4dec8i.exit.1, !decision.origin !445

_Z4enc8f.exit.thread.1:                           ; preds = %_Z4dec8i.exit.i.6.1
  store i8 0, i8 addrspace(5)* %arrayidx64340398.1, align 1, !tbaa !18
  br label %cond.false.i377.1, !decision.origin !446

cond.false.i377.1:                                ; preds = %_Z4enc8f.exit.thread.1, %_Z4enc8f.exit.1
  %and.i375395.1 = phi i32 [ 0, %_Z4enc8f.exit.thread.1 ], [ %and.i375.1.pre-phi, %_Z4enc8f.exit.1 ]
  %conv1.i.1 = sitofp i32 %and.i375395.1 to float
  %mul2.i.1 = fmul float %conv1.i.1, 0x3F60000000000000
  br label %_Z4dec8i.exit.1, !decision.origin !447

_Z4dec8i.exit.1:                                  ; preds = %cond.false.i377.1, %cond.true.i.1
  %cond.i378.1 = phi float [ %250, %cond.true.i.1 ], [ %mul2.i.1, %cond.false.i377.1 ]
  %cmp69.1 = fcmp une float %cond.i378.1, 0.000000e+00
  br i1 %cmp69.1, label %cond.end75.1, label %cond.end75.1.thread, !decision.origin !448

cond.end75.1.thread:                              ; preds = %_Z4dec8i.exit.1
  %251 = insertelement <2 x float> %os.sroa.0.4, float 0.000000e+00, i32 1
  br label %if.then97.7.1, !decision.origin !449

cond.end75.1:                                     ; preds = %_Z4dec8i.exit.1
  %mul72.1 = fmul float %div71, %cond.i378.1
  %div73.1 = fdiv float 1.000000e+00, %mul72.1
  %252 = insertelement <2 x float> %os.sroa.0.4, float %div73.1, i32 1
  %cmp81.1 = fcmp une float %div73.1, 0.000000e+00
  %div85.1 = fdiv float 1.000000e+00, %div73.1
  %cond88.1 = select i1 %cmp81.1, float %div85.1, float 0.000000e+00
  %cmp96.1 = fcmp oeq float %div73.1, 0.000000e+00
  br i1 %cmp96.1, label %if.then97.7.1, label %if.else.7.1, !decision.origin !450

if.else.7.1:                                      ; preds = %cond.end75.1
  %mul116.1429 = fmul float %div73.1, %12
  %253 = tail call float @llvm.fabs.f32(float %mul116.1429) #3
  %cmp.i378 = fcmp ugt float %253, 2.500000e-01
  br i1 %cmp.i378, label %if.else.i381, label %if.then.i379, !decision.origin !451

if.then.i379:                                     ; preds = %if.else.7.1
  %254 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.1429) #3
  br label %quant_decide.exit399, !decision.origin !452, !decision.order !453

if.else.i381:                                     ; preds = %if.else.7.1
  %cmp2.i380 = fcmp olt float %253, 7.500000e-01
  br i1 %cmp2.i380, label %if.then3.i382, label %if.else4.i384, !decision.origin !454

if.then3.i382:                                    ; preds = %if.else.i381
  %255 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.1429) #3
  br label %quant_decide.exit399, !decision.origin !455, !decision.order !456

if.else4.i384:                                    ; preds = %if.else.i381
  %cmp6.i383 = fcmp ugt float %253, 1.250000e+00
  br i1 %cmp6.i383, label %if.else8.i387, label %if.then7.i385, !decision.origin !457

if.then7.i385:                                    ; preds = %if.else4.i384
  %256 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.1429) #3
  br label %quant_decide.exit399, !decision.origin !458, !decision.order !459

if.else8.i387:                                    ; preds = %if.else4.i384
  %cmp10.i386 = fcmp olt float %253, 1.750000e+00
  br i1 %cmp10.i386, label %if.then11.i388, label %if.else12.i390, !decision.origin !460

if.then11.i388:                                   ; preds = %if.else8.i387
  %257 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.1429) #3
  br label %quant_decide.exit399, !decision.origin !461, !decision.order !462

if.else12.i390:                                   ; preds = %if.else8.i387
  %cmp14.i389 = fcmp ugt float %253, 2.500000e+00
  br i1 %cmp14.i389, label %if.else16.i393, label %if.then15.i391, !decision.origin !463

if.then15.i391:                                   ; preds = %if.else12.i390
  %258 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.1429) #3
  br label %quant_decide.exit399, !decision.origin !464, !decision.order !465

if.else16.i393:                                   ; preds = %if.else12.i390
  %cmp18.i392 = fcmp olt float %253, 3.500000e+00
  br i1 %cmp18.i392, label %if.then19.i394, label %if.else20.i396, !decision.origin !466

if.then19.i394:                                   ; preds = %if.else16.i393
  %259 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.1429) #3
  br label %quant_decide.exit399, !decision.origin !467, !decision.order !468

if.else20.i396:                                   ; preds = %if.else16.i393
  %cmp22.i395 = fcmp ugt float %253, 5.000000e+00
  br i1 %cmp22.i395, label %if.end29.i398, label %if.then23.i397, !decision.origin !469

if.then23.i397:                                   ; preds = %if.else20.i396
  %260 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.1429) #3
  br label %quant_decide.exit399, !decision.origin !470, !decision.order !471

if.end29.i398:                                    ; preds = %if.else20.i396
  %261 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.1429) #3
  br label %quant_decide.exit399, !decision.origin !472, !decision.order !473

quant_decide.exit399:                             ; preds = %if.end29.i398, %if.then23.i397, %if.then19.i394, %if.then15.i391, %if.then11.i388, %if.then7.i385, %if.then3.i382, %if.then.i379
  %out.i372.8 = phi float [ %255, %if.then3.i382 ], [ %257, %if.then11.i388 ], [ %259, %if.then19.i394 ], [ %261, %if.end29.i398 ], [ %260, %if.then23.i397 ], [ %258, %if.then15.i391 ], [ %256, %if.then7.i385 ], [ %254, %if.then.i379 ]
  %mul118.1430 = fmul float %cond88.1, %out.i372.8
  %sub.1431 = fsub float %mul118.1430, %12
  %mul126.1433 = fmul float %div73.1, %16
  %262 = tail call float @llvm.fabs.f32(float %mul126.1433) #3
  %cmp.i356 = fcmp ugt float %262, 2.500000e-01
  br i1 %cmp.i356, label %if.else.i359, label %if.then.i357, !decision.origin !474

if.then.i357:                                     ; preds = %quant_decide.exit399
  %263 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.1433) #3
  br label %quant_decide.exit377, !decision.origin !475, !decision.order !476

if.else.i359:                                     ; preds = %quant_decide.exit399
  %cmp2.i358 = fcmp olt float %262, 7.500000e-01
  br i1 %cmp2.i358, label %if.then3.i360, label %if.else4.i362, !decision.origin !477

if.then3.i360:                                    ; preds = %if.else.i359
  %264 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.1433) #3
  br label %quant_decide.exit377, !decision.origin !478, !decision.order !479

if.else4.i362:                                    ; preds = %if.else.i359
  %cmp6.i361 = fcmp ugt float %262, 1.250000e+00
  br i1 %cmp6.i361, label %if.else8.i365, label %if.then7.i363, !decision.origin !480

if.then7.i363:                                    ; preds = %if.else4.i362
  %265 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.1433) #3
  br label %quant_decide.exit377, !decision.origin !481, !decision.order !482

if.else8.i365:                                    ; preds = %if.else4.i362
  %cmp10.i364 = fcmp olt float %262, 1.750000e+00
  br i1 %cmp10.i364, label %if.then11.i366, label %if.else12.i368, !decision.origin !483

if.then11.i366:                                   ; preds = %if.else8.i365
  %266 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.1433) #3
  br label %quant_decide.exit377, !decision.origin !484, !decision.order !485

if.else12.i368:                                   ; preds = %if.else8.i365
  %cmp14.i367 = fcmp ugt float %262, 2.500000e+00
  br i1 %cmp14.i367, label %if.else16.i371, label %if.then15.i369, !decision.origin !486

if.then15.i369:                                   ; preds = %if.else12.i368
  %267 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.1433) #3
  br label %quant_decide.exit377, !decision.origin !487, !decision.order !488

if.else16.i371:                                   ; preds = %if.else12.i368
  %cmp18.i370 = fcmp olt float %262, 3.500000e+00
  br i1 %cmp18.i370, label %if.then19.i372, label %if.else20.i374, !decision.origin !489

if.then19.i372:                                   ; preds = %if.else16.i371
  %268 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.1433) #3
  br label %quant_decide.exit377, !decision.origin !490, !decision.order !491

if.else20.i374:                                   ; preds = %if.else16.i371
  %cmp22.i373 = fcmp ugt float %262, 5.000000e+00
  br i1 %cmp22.i373, label %if.end29.i376, label %if.then23.i375, !decision.origin !492

if.then23.i375:                                   ; preds = %if.else20.i374
  %269 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.1433) #3
  br label %quant_decide.exit377, !decision.origin !493, !decision.order !494

if.end29.i376:                                    ; preds = %if.else20.i374
  %270 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.1433) #3
  br label %quant_decide.exit377, !decision.origin !495, !decision.order !496

quant_decide.exit377:                             ; preds = %if.end29.i376, %if.then23.i375, %if.then19.i372, %if.then15.i369, %if.then11.i366, %if.then7.i363, %if.then3.i360, %if.then.i357
  %out.i.8 = phi float [ %264, %if.then3.i360 ], [ %266, %if.then11.i366 ], [ %268, %if.then19.i372 ], [ %270, %if.end29.i376 ], [ %269, %if.then23.i375 ], [ %267, %if.then15.i369 ], [ %265, %if.then7.i363 ], [ %263, %if.then.i357 ]
  %mul128.1434 = fmul float %cond88.1, %out.i.8
  %sub132.1435 = fsub float %mul128.1434, %16
  %mul133.1436 = fmul float %sub.1431, %sub.1431
  %mul134.1437 = fmul float %sub132.1435, %sub132.1435
  %add135.1438 = fadd float %mul133.1436, %mul134.1437
  %e.1.1447 = fadd float %add135.1438, 0.000000e+00
  %mul116.1.1 = fmul float %div73.1, %20
  %271 = tail call float @llvm.fabs.f32(float %mul116.1.1) #3
  %cmp.i334 = fcmp ugt float %271, 2.500000e-01
  br i1 %cmp.i334, label %if.else.i337, label %if.then.i335, !decision.origin !497

if.then.i335:                                     ; preds = %quant_decide.exit377
  %272 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.1.1) #3
  br label %quant_decide.exit355, !decision.origin !498, !decision.order !499

if.else.i337:                                     ; preds = %quant_decide.exit377
  %cmp2.i336 = fcmp olt float %271, 7.500000e-01
  br i1 %cmp2.i336, label %if.then3.i338, label %if.else4.i340, !decision.origin !500

if.then3.i338:                                    ; preds = %if.else.i337
  %273 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.1.1) #3
  br label %quant_decide.exit355, !decision.origin !501, !decision.order !502

if.else4.i340:                                    ; preds = %if.else.i337
  %cmp6.i339 = fcmp ugt float %271, 1.250000e+00
  br i1 %cmp6.i339, label %if.else8.i343, label %if.then7.i341, !decision.origin !503

if.then7.i341:                                    ; preds = %if.else4.i340
  %274 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.1.1) #3
  br label %quant_decide.exit355, !decision.origin !504, !decision.order !505

if.else8.i343:                                    ; preds = %if.else4.i340
  %cmp10.i342 = fcmp olt float %271, 1.750000e+00
  br i1 %cmp10.i342, label %if.then11.i344, label %if.else12.i346, !decision.origin !506

if.then11.i344:                                   ; preds = %if.else8.i343
  %275 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.1.1) #3
  br label %quant_decide.exit355, !decision.origin !507, !decision.order !508

if.else12.i346:                                   ; preds = %if.else8.i343
  %cmp14.i345 = fcmp ugt float %271, 2.500000e+00
  br i1 %cmp14.i345, label %if.else16.i349, label %if.then15.i347, !decision.origin !509

if.then15.i347:                                   ; preds = %if.else12.i346
  %276 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.1.1) #3
  br label %quant_decide.exit355, !decision.origin !510, !decision.order !511

if.else16.i349:                                   ; preds = %if.else12.i346
  %cmp18.i348 = fcmp olt float %271, 3.500000e+00
  br i1 %cmp18.i348, label %if.then19.i350, label %if.else20.i352, !decision.origin !512

if.then19.i350:                                   ; preds = %if.else16.i349
  %277 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.1.1) #3
  br label %quant_decide.exit355, !decision.origin !513, !decision.order !514

if.else20.i352:                                   ; preds = %if.else16.i349
  %cmp22.i351 = fcmp ugt float %271, 5.000000e+00
  br i1 %cmp22.i351, label %if.end29.i354, label %if.then23.i353, !decision.origin !515

if.then23.i353:                                   ; preds = %if.else20.i352
  %278 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.1.1) #3
  br label %quant_decide.exit355, !decision.origin !516, !decision.order !517

if.end29.i354:                                    ; preds = %if.else20.i352
  %279 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.1.1) #3
  br label %quant_decide.exit355, !decision.origin !518, !decision.order !519

quant_decide.exit355:                             ; preds = %if.end29.i354, %if.then23.i353, %if.then19.i350, %if.then15.i347, %if.then11.i344, %if.then7.i341, %if.then3.i338, %if.then.i335
  %out.i372.9 = phi float [ %273, %if.then3.i338 ], [ %275, %if.then11.i344 ], [ %277, %if.then19.i350 ], [ %279, %if.end29.i354 ], [ %278, %if.then23.i353 ], [ %276, %if.then15.i347 ], [ %274, %if.then7.i341 ], [ %272, %if.then.i335 ]
  %mul118.1.1 = fmul float %cond88.1, %out.i372.9
  %sub.1.1 = fsub float %mul118.1.1, %20
  %mul126.1.1 = fmul float %div73.1, %24
  %280 = tail call float @llvm.fabs.f32(float %mul126.1.1) #3
  %cmp.i312 = fcmp ugt float %280, 2.500000e-01
  br i1 %cmp.i312, label %if.else.i315, label %if.then.i313, !decision.origin !520

if.then.i313:                                     ; preds = %quant_decide.exit355
  %281 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.1.1) #3
  br label %quant_decide.exit333, !decision.origin !521, !decision.order !522

if.else.i315:                                     ; preds = %quant_decide.exit355
  %cmp2.i314 = fcmp olt float %280, 7.500000e-01
  br i1 %cmp2.i314, label %if.then3.i316, label %if.else4.i318, !decision.origin !523

if.then3.i316:                                    ; preds = %if.else.i315
  %282 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.1.1) #3
  br label %quant_decide.exit333, !decision.origin !524, !decision.order !525

if.else4.i318:                                    ; preds = %if.else.i315
  %cmp6.i317 = fcmp ugt float %280, 1.250000e+00
  br i1 %cmp6.i317, label %if.else8.i321, label %if.then7.i319, !decision.origin !526

if.then7.i319:                                    ; preds = %if.else4.i318
  %283 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.1.1) #3
  br label %quant_decide.exit333, !decision.origin !527, !decision.order !528

if.else8.i321:                                    ; preds = %if.else4.i318
  %cmp10.i320 = fcmp olt float %280, 1.750000e+00
  br i1 %cmp10.i320, label %if.then11.i322, label %if.else12.i324, !decision.origin !529

if.then11.i322:                                   ; preds = %if.else8.i321
  %284 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.1.1) #3
  br label %quant_decide.exit333, !decision.origin !530, !decision.order !531

if.else12.i324:                                   ; preds = %if.else8.i321
  %cmp14.i323 = fcmp ugt float %280, 2.500000e+00
  br i1 %cmp14.i323, label %if.else16.i327, label %if.then15.i325, !decision.origin !532

if.then15.i325:                                   ; preds = %if.else12.i324
  %285 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.1.1) #3
  br label %quant_decide.exit333, !decision.origin !533, !decision.order !534

if.else16.i327:                                   ; preds = %if.else12.i324
  %cmp18.i326 = fcmp olt float %280, 3.500000e+00
  br i1 %cmp18.i326, label %if.then19.i328, label %if.else20.i330, !decision.origin !535

if.then19.i328:                                   ; preds = %if.else16.i327
  %286 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.1.1) #3
  br label %quant_decide.exit333, !decision.origin !536, !decision.order !537

if.else20.i330:                                   ; preds = %if.else16.i327
  %cmp22.i329 = fcmp ugt float %280, 5.000000e+00
  br i1 %cmp22.i329, label %if.end29.i332, label %if.then23.i331, !decision.origin !538

if.then23.i331:                                   ; preds = %if.else20.i330
  %287 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.1.1) #3
  br label %quant_decide.exit333, !decision.origin !539, !decision.order !540

if.end29.i332:                                    ; preds = %if.else20.i330
  %288 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.1.1) #3
  br label %quant_decide.exit333, !decision.origin !541, !decision.order !542

quant_decide.exit333:                             ; preds = %if.end29.i332, %if.then23.i331, %if.then19.i328, %if.then15.i325, %if.then11.i322, %if.then7.i319, %if.then3.i316, %if.then.i313
  %out.i.9 = phi float [ %282, %if.then3.i316 ], [ %284, %if.then11.i322 ], [ %286, %if.then19.i328 ], [ %288, %if.end29.i332 ], [ %287, %if.then23.i331 ], [ %285, %if.then15.i325 ], [ %283, %if.then7.i319 ], [ %281, %if.then.i313 ]
  %mul128.1.1 = fmul float %cond88.1, %out.i.9
  %sub132.1.1 = fsub float %mul128.1.1, %24
  %mul133.1.1 = fmul float %sub.1.1, %sub.1.1
  %mul134.1.1 = fmul float %sub132.1.1, %sub132.1.1
  %add135.1.1 = fadd float %mul133.1.1, %mul134.1.1
  %e.1.1.1 = fadd float %e.1.1447, %add135.1.1
  %mul116.2.1 = fmul float %div73.1, %28
  %289 = tail call float @llvm.fabs.f32(float %mul116.2.1) #3
  %cmp.i290 = fcmp ugt float %289, 2.500000e-01
  br i1 %cmp.i290, label %if.else.i293, label %if.then.i291, !decision.origin !543

if.then.i291:                                     ; preds = %quant_decide.exit333
  %290 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.2.1) #3
  br label %quant_decide.exit311, !decision.origin !544, !decision.order !545

if.else.i293:                                     ; preds = %quant_decide.exit333
  %cmp2.i292 = fcmp olt float %289, 7.500000e-01
  br i1 %cmp2.i292, label %if.then3.i294, label %if.else4.i296, !decision.origin !546

if.then3.i294:                                    ; preds = %if.else.i293
  %291 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.2.1) #3
  br label %quant_decide.exit311, !decision.origin !547, !decision.order !548

if.else4.i296:                                    ; preds = %if.else.i293
  %cmp6.i295 = fcmp ugt float %289, 1.250000e+00
  br i1 %cmp6.i295, label %if.else8.i299, label %if.then7.i297, !decision.origin !549

if.then7.i297:                                    ; preds = %if.else4.i296
  %292 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.2.1) #3
  br label %quant_decide.exit311, !decision.origin !550, !decision.order !551

if.else8.i299:                                    ; preds = %if.else4.i296
  %cmp10.i298 = fcmp olt float %289, 1.750000e+00
  br i1 %cmp10.i298, label %if.then11.i300, label %if.else12.i302, !decision.origin !552

if.then11.i300:                                   ; preds = %if.else8.i299
  %293 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.2.1) #3
  br label %quant_decide.exit311, !decision.origin !553, !decision.order !554

if.else12.i302:                                   ; preds = %if.else8.i299
  %cmp14.i301 = fcmp ugt float %289, 2.500000e+00
  br i1 %cmp14.i301, label %if.else16.i305, label %if.then15.i303, !decision.origin !555

if.then15.i303:                                   ; preds = %if.else12.i302
  %294 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.2.1) #3
  br label %quant_decide.exit311, !decision.origin !556, !decision.order !557

if.else16.i305:                                   ; preds = %if.else12.i302
  %cmp18.i304 = fcmp olt float %289, 3.500000e+00
  br i1 %cmp18.i304, label %if.then19.i306, label %if.else20.i308, !decision.origin !558

if.then19.i306:                                   ; preds = %if.else16.i305
  %295 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.2.1) #3
  br label %quant_decide.exit311, !decision.origin !559, !decision.order !560

if.else20.i308:                                   ; preds = %if.else16.i305
  %cmp22.i307 = fcmp ugt float %289, 5.000000e+00
  br i1 %cmp22.i307, label %if.end29.i310, label %if.then23.i309, !decision.origin !561

if.then23.i309:                                   ; preds = %if.else20.i308
  %296 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.2.1) #3
  br label %quant_decide.exit311, !decision.origin !562, !decision.order !563

if.end29.i310:                                    ; preds = %if.else20.i308
  %297 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.2.1) #3
  br label %quant_decide.exit311, !decision.origin !564, !decision.order !565

quant_decide.exit311:                             ; preds = %if.end29.i310, %if.then23.i309, %if.then19.i306, %if.then15.i303, %if.then11.i300, %if.then7.i297, %if.then3.i294, %if.then.i291
  %out.i372.10 = phi float [ %291, %if.then3.i294 ], [ %293, %if.then11.i300 ], [ %295, %if.then19.i306 ], [ %297, %if.end29.i310 ], [ %296, %if.then23.i309 ], [ %294, %if.then15.i303 ], [ %292, %if.then7.i297 ], [ %290, %if.then.i291 ]
  %mul118.2.1 = fmul float %cond88.1, %out.i372.10
  %sub.2.1 = fsub float %mul118.2.1, %28
  %mul126.2.1 = fmul float %div73.1, %32
  %298 = tail call float @llvm.fabs.f32(float %mul126.2.1) #3
  %cmp.i268 = fcmp ugt float %298, 2.500000e-01
  br i1 %cmp.i268, label %if.else.i271, label %if.then.i269, !decision.origin !566

if.then.i269:                                     ; preds = %quant_decide.exit311
  %299 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.2.1) #3
  br label %quant_decide.exit289, !decision.origin !567, !decision.order !568

if.else.i271:                                     ; preds = %quant_decide.exit311
  %cmp2.i270 = fcmp olt float %298, 7.500000e-01
  br i1 %cmp2.i270, label %if.then3.i272, label %if.else4.i274, !decision.origin !569

if.then3.i272:                                    ; preds = %if.else.i271
  %300 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.2.1) #3
  br label %quant_decide.exit289, !decision.origin !570, !decision.order !571

if.else4.i274:                                    ; preds = %if.else.i271
  %cmp6.i273 = fcmp ugt float %298, 1.250000e+00
  br i1 %cmp6.i273, label %if.else8.i277, label %if.then7.i275, !decision.origin !572

if.then7.i275:                                    ; preds = %if.else4.i274
  %301 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.2.1) #3
  br label %quant_decide.exit289, !decision.origin !573, !decision.order !574

if.else8.i277:                                    ; preds = %if.else4.i274
  %cmp10.i276 = fcmp olt float %298, 1.750000e+00
  br i1 %cmp10.i276, label %if.then11.i278, label %if.else12.i280, !decision.origin !575

if.then11.i278:                                   ; preds = %if.else8.i277
  %302 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.2.1) #3
  br label %quant_decide.exit289, !decision.origin !576, !decision.order !577

if.else12.i280:                                   ; preds = %if.else8.i277
  %cmp14.i279 = fcmp ugt float %298, 2.500000e+00
  br i1 %cmp14.i279, label %if.else16.i283, label %if.then15.i281, !decision.origin !578

if.then15.i281:                                   ; preds = %if.else12.i280
  %303 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.2.1) #3
  br label %quant_decide.exit289, !decision.origin !579, !decision.order !580

if.else16.i283:                                   ; preds = %if.else12.i280
  %cmp18.i282 = fcmp olt float %298, 3.500000e+00
  br i1 %cmp18.i282, label %if.then19.i284, label %if.else20.i286, !decision.origin !581

if.then19.i284:                                   ; preds = %if.else16.i283
  %304 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.2.1) #3
  br label %quant_decide.exit289, !decision.origin !582, !decision.order !583

if.else20.i286:                                   ; preds = %if.else16.i283
  %cmp22.i285 = fcmp ugt float %298, 5.000000e+00
  br i1 %cmp22.i285, label %if.end29.i288, label %if.then23.i287, !decision.origin !584

if.then23.i287:                                   ; preds = %if.else20.i286
  %305 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.2.1) #3
  br label %quant_decide.exit289, !decision.origin !585, !decision.order !586

if.end29.i288:                                    ; preds = %if.else20.i286
  %306 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.2.1) #3
  br label %quant_decide.exit289, !decision.origin !587, !decision.order !588

quant_decide.exit289:                             ; preds = %if.end29.i288, %if.then23.i287, %if.then19.i284, %if.then15.i281, %if.then11.i278, %if.then7.i275, %if.then3.i272, %if.then.i269
  %out.i.10 = phi float [ %300, %if.then3.i272 ], [ %302, %if.then11.i278 ], [ %304, %if.then19.i284 ], [ %306, %if.end29.i288 ], [ %305, %if.then23.i287 ], [ %303, %if.then15.i281 ], [ %301, %if.then7.i275 ], [ %299, %if.then.i269 ]
  %mul128.2.1 = fmul float %cond88.1, %out.i.10
  %sub132.2.1 = fsub float %mul128.2.1, %32
  %mul133.2.1 = fmul float %sub.2.1, %sub.2.1
  %mul134.2.1 = fmul float %sub132.2.1, %sub132.2.1
  %add135.2.1 = fadd float %mul133.2.1, %mul134.2.1
  %e.1.2.1 = fadd float %e.1.1.1, %add135.2.1
  %mul116.3.1 = fmul float %div73.1, %36
  %307 = tail call float @llvm.fabs.f32(float %mul116.3.1) #3
  %cmp.i246 = fcmp ugt float %307, 2.500000e-01
  br i1 %cmp.i246, label %if.else.i249, label %if.then.i247, !decision.origin !589

if.then.i247:                                     ; preds = %quant_decide.exit289
  %308 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.3.1) #3
  br label %quant_decide.exit267, !decision.origin !590, !decision.order !591

if.else.i249:                                     ; preds = %quant_decide.exit289
  %cmp2.i248 = fcmp olt float %307, 7.500000e-01
  br i1 %cmp2.i248, label %if.then3.i250, label %if.else4.i252, !decision.origin !592

if.then3.i250:                                    ; preds = %if.else.i249
  %309 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.3.1) #3
  br label %quant_decide.exit267, !decision.origin !593, !decision.order !594

if.else4.i252:                                    ; preds = %if.else.i249
  %cmp6.i251 = fcmp ugt float %307, 1.250000e+00
  br i1 %cmp6.i251, label %if.else8.i255, label %if.then7.i253, !decision.origin !595

if.then7.i253:                                    ; preds = %if.else4.i252
  %310 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.3.1) #3
  br label %quant_decide.exit267, !decision.origin !596, !decision.order !597

if.else8.i255:                                    ; preds = %if.else4.i252
  %cmp10.i254 = fcmp olt float %307, 1.750000e+00
  br i1 %cmp10.i254, label %if.then11.i256, label %if.else12.i258, !decision.origin !598

if.then11.i256:                                   ; preds = %if.else8.i255
  %311 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.3.1) #3
  br label %quant_decide.exit267, !decision.origin !599, !decision.order !600

if.else12.i258:                                   ; preds = %if.else8.i255
  %cmp14.i257 = fcmp ugt float %307, 2.500000e+00
  br i1 %cmp14.i257, label %if.else16.i261, label %if.then15.i259, !decision.origin !601

if.then15.i259:                                   ; preds = %if.else12.i258
  %312 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.3.1) #3
  br label %quant_decide.exit267, !decision.origin !602, !decision.order !603

if.else16.i261:                                   ; preds = %if.else12.i258
  %cmp18.i260 = fcmp olt float %307, 3.500000e+00
  br i1 %cmp18.i260, label %if.then19.i262, label %if.else20.i264, !decision.origin !604

if.then19.i262:                                   ; preds = %if.else16.i261
  %313 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.3.1) #3
  br label %quant_decide.exit267, !decision.origin !605, !decision.order !606

if.else20.i264:                                   ; preds = %if.else16.i261
  %cmp22.i263 = fcmp ugt float %307, 5.000000e+00
  br i1 %cmp22.i263, label %if.end29.i266, label %if.then23.i265, !decision.origin !607

if.then23.i265:                                   ; preds = %if.else20.i264
  %314 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.3.1) #3
  br label %quant_decide.exit267, !decision.origin !608, !decision.order !609

if.end29.i266:                                    ; preds = %if.else20.i264
  %315 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.3.1) #3
  br label %quant_decide.exit267, !decision.origin !610, !decision.order !611

quant_decide.exit267:                             ; preds = %if.end29.i266, %if.then23.i265, %if.then19.i262, %if.then15.i259, %if.then11.i256, %if.then7.i253, %if.then3.i250, %if.then.i247
  %out.i372.11 = phi float [ %309, %if.then3.i250 ], [ %311, %if.then11.i256 ], [ %313, %if.then19.i262 ], [ %315, %if.end29.i266 ], [ %314, %if.then23.i265 ], [ %312, %if.then15.i259 ], [ %310, %if.then7.i253 ], [ %308, %if.then.i247 ]
  %mul118.3.1 = fmul float %cond88.1, %out.i372.11
  %sub.3.1 = fsub float %mul118.3.1, %36
  %mul126.3.1 = fmul float %div73.1, %40
  %316 = tail call float @llvm.fabs.f32(float %mul126.3.1) #3
  %cmp.i224 = fcmp ugt float %316, 2.500000e-01
  br i1 %cmp.i224, label %if.else.i227, label %if.then.i225, !decision.origin !612

if.then.i225:                                     ; preds = %quant_decide.exit267
  %317 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.3.1) #3
  br label %quant_decide.exit245, !decision.origin !613, !decision.order !614

if.else.i227:                                     ; preds = %quant_decide.exit267
  %cmp2.i226 = fcmp olt float %316, 7.500000e-01
  br i1 %cmp2.i226, label %if.then3.i228, label %if.else4.i230, !decision.origin !615

if.then3.i228:                                    ; preds = %if.else.i227
  %318 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.3.1) #3
  br label %quant_decide.exit245, !decision.origin !616, !decision.order !617

if.else4.i230:                                    ; preds = %if.else.i227
  %cmp6.i229 = fcmp ugt float %316, 1.250000e+00
  br i1 %cmp6.i229, label %if.else8.i233, label %if.then7.i231, !decision.origin !618

if.then7.i231:                                    ; preds = %if.else4.i230
  %319 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.3.1) #3
  br label %quant_decide.exit245, !decision.origin !619, !decision.order !620

if.else8.i233:                                    ; preds = %if.else4.i230
  %cmp10.i232 = fcmp olt float %316, 1.750000e+00
  br i1 %cmp10.i232, label %if.then11.i234, label %if.else12.i236, !decision.origin !621

if.then11.i234:                                   ; preds = %if.else8.i233
  %320 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.3.1) #3
  br label %quant_decide.exit245, !decision.origin !622, !decision.order !623

if.else12.i236:                                   ; preds = %if.else8.i233
  %cmp14.i235 = fcmp ugt float %316, 2.500000e+00
  br i1 %cmp14.i235, label %if.else16.i239, label %if.then15.i237, !decision.origin !624

if.then15.i237:                                   ; preds = %if.else12.i236
  %321 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.3.1) #3
  br label %quant_decide.exit245, !decision.origin !625, !decision.order !626

if.else16.i239:                                   ; preds = %if.else12.i236
  %cmp18.i238 = fcmp olt float %316, 3.500000e+00
  br i1 %cmp18.i238, label %if.then19.i240, label %if.else20.i242, !decision.origin !627

if.then19.i240:                                   ; preds = %if.else16.i239
  %322 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.3.1) #3
  br label %quant_decide.exit245, !decision.origin !628, !decision.order !629

if.else20.i242:                                   ; preds = %if.else16.i239
  %cmp22.i241 = fcmp ugt float %316, 5.000000e+00
  br i1 %cmp22.i241, label %if.end29.i244, label %if.then23.i243, !decision.origin !630

if.then23.i243:                                   ; preds = %if.else20.i242
  %323 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.3.1) #3
  br label %quant_decide.exit245, !decision.origin !631, !decision.order !632

if.end29.i244:                                    ; preds = %if.else20.i242
  %324 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.3.1) #3
  br label %quant_decide.exit245, !decision.origin !633, !decision.order !634

quant_decide.exit245:                             ; preds = %if.end29.i244, %if.then23.i243, %if.then19.i240, %if.then15.i237, %if.then11.i234, %if.then7.i231, %if.then3.i228, %if.then.i225
  %out.i.11 = phi float [ %318, %if.then3.i228 ], [ %320, %if.then11.i234 ], [ %322, %if.then19.i240 ], [ %324, %if.end29.i244 ], [ %323, %if.then23.i243 ], [ %321, %if.then15.i237 ], [ %319, %if.then7.i231 ], [ %317, %if.then.i225 ]
  %mul128.3.1 = fmul float %cond88.1, %out.i.11
  %sub132.3.1 = fsub float %mul128.3.1, %40
  %mul133.3.1 = fmul float %sub.3.1, %sub.3.1
  %mul134.3.1 = fmul float %sub132.3.1, %sub132.3.1
  %add135.3.1 = fadd float %mul133.3.1, %mul134.3.1
  %e.1.3.1 = fadd float %e.1.2.1, %add135.3.1
  %mul116.4.1 = fmul float %div73.1, %44
  %325 = tail call float @llvm.fabs.f32(float %mul116.4.1) #3
  %cmp.i202 = fcmp ugt float %325, 2.500000e-01
  br i1 %cmp.i202, label %if.else.i205, label %if.then.i203, !decision.origin !635

if.then.i203:                                     ; preds = %quant_decide.exit245
  %326 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.4.1) #3
  br label %quant_decide.exit223, !decision.origin !636, !decision.order !637

if.else.i205:                                     ; preds = %quant_decide.exit245
  %cmp2.i204 = fcmp olt float %325, 7.500000e-01
  br i1 %cmp2.i204, label %if.then3.i206, label %if.else4.i208, !decision.origin !638

if.then3.i206:                                    ; preds = %if.else.i205
  %327 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.4.1) #3
  br label %quant_decide.exit223, !decision.origin !639, !decision.order !640

if.else4.i208:                                    ; preds = %if.else.i205
  %cmp6.i207 = fcmp ugt float %325, 1.250000e+00
  br i1 %cmp6.i207, label %if.else8.i211, label %if.then7.i209, !decision.origin !641

if.then7.i209:                                    ; preds = %if.else4.i208
  %328 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.4.1) #3
  br label %quant_decide.exit223, !decision.origin !642, !decision.order !643

if.else8.i211:                                    ; preds = %if.else4.i208
  %cmp10.i210 = fcmp olt float %325, 1.750000e+00
  br i1 %cmp10.i210, label %if.then11.i212, label %if.else12.i214, !decision.origin !644

if.then11.i212:                                   ; preds = %if.else8.i211
  %329 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.4.1) #3
  br label %quant_decide.exit223, !decision.origin !645, !decision.order !646

if.else12.i214:                                   ; preds = %if.else8.i211
  %cmp14.i213 = fcmp ugt float %325, 2.500000e+00
  br i1 %cmp14.i213, label %if.else16.i217, label %if.then15.i215, !decision.origin !647

if.then15.i215:                                   ; preds = %if.else12.i214
  %330 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.4.1) #3
  br label %quant_decide.exit223, !decision.origin !648, !decision.order !649

if.else16.i217:                                   ; preds = %if.else12.i214
  %cmp18.i216 = fcmp olt float %325, 3.500000e+00
  br i1 %cmp18.i216, label %if.then19.i218, label %if.else20.i220, !decision.origin !650

if.then19.i218:                                   ; preds = %if.else16.i217
  %331 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.4.1) #3
  br label %quant_decide.exit223, !decision.origin !651, !decision.order !652

if.else20.i220:                                   ; preds = %if.else16.i217
  %cmp22.i219 = fcmp ugt float %325, 5.000000e+00
  br i1 %cmp22.i219, label %if.end29.i222, label %if.then23.i221, !decision.origin !653

if.then23.i221:                                   ; preds = %if.else20.i220
  %332 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.4.1) #3
  br label %quant_decide.exit223, !decision.origin !654, !decision.order !655

if.end29.i222:                                    ; preds = %if.else20.i220
  %333 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.4.1) #3
  br label %quant_decide.exit223, !decision.origin !656, !decision.order !657

quant_decide.exit223:                             ; preds = %if.end29.i222, %if.then23.i221, %if.then19.i218, %if.then15.i215, %if.then11.i212, %if.then7.i209, %if.then3.i206, %if.then.i203
  %out.i372.12 = phi float [ %327, %if.then3.i206 ], [ %329, %if.then11.i212 ], [ %331, %if.then19.i218 ], [ %333, %if.end29.i222 ], [ %332, %if.then23.i221 ], [ %330, %if.then15.i215 ], [ %328, %if.then7.i209 ], [ %326, %if.then.i203 ]
  %mul118.4.1 = fmul float %cond88.1, %out.i372.12
  %sub.4.1 = fsub float %mul118.4.1, %44
  %mul126.4.1 = fmul float %div73.1, %48
  %334 = tail call float @llvm.fabs.f32(float %mul126.4.1) #3
  %cmp.i180 = fcmp ugt float %334, 2.500000e-01
  br i1 %cmp.i180, label %if.else.i183, label %if.then.i181, !decision.origin !658

if.then.i181:                                     ; preds = %quant_decide.exit223
  %335 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.4.1) #3
  br label %quant_decide.exit201, !decision.origin !659, !decision.order !660

if.else.i183:                                     ; preds = %quant_decide.exit223
  %cmp2.i182 = fcmp olt float %334, 7.500000e-01
  br i1 %cmp2.i182, label %if.then3.i184, label %if.else4.i186, !decision.origin !661

if.then3.i184:                                    ; preds = %if.else.i183
  %336 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.4.1) #3
  br label %quant_decide.exit201, !decision.origin !662, !decision.order !663

if.else4.i186:                                    ; preds = %if.else.i183
  %cmp6.i185 = fcmp ugt float %334, 1.250000e+00
  br i1 %cmp6.i185, label %if.else8.i189, label %if.then7.i187, !decision.origin !664

if.then7.i187:                                    ; preds = %if.else4.i186
  %337 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.4.1) #3
  br label %quant_decide.exit201, !decision.origin !665, !decision.order !666

if.else8.i189:                                    ; preds = %if.else4.i186
  %cmp10.i188 = fcmp olt float %334, 1.750000e+00
  br i1 %cmp10.i188, label %if.then11.i190, label %if.else12.i192, !decision.origin !667

if.then11.i190:                                   ; preds = %if.else8.i189
  %338 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.4.1) #3
  br label %quant_decide.exit201, !decision.origin !668, !decision.order !669

if.else12.i192:                                   ; preds = %if.else8.i189
  %cmp14.i191 = fcmp ugt float %334, 2.500000e+00
  br i1 %cmp14.i191, label %if.else16.i195, label %if.then15.i193, !decision.origin !670

if.then15.i193:                                   ; preds = %if.else12.i192
  %339 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.4.1) #3
  br label %quant_decide.exit201, !decision.origin !671, !decision.order !672

if.else16.i195:                                   ; preds = %if.else12.i192
  %cmp18.i194 = fcmp olt float %334, 3.500000e+00
  br i1 %cmp18.i194, label %if.then19.i196, label %if.else20.i198, !decision.origin !673

if.then19.i196:                                   ; preds = %if.else16.i195
  %340 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.4.1) #3
  br label %quant_decide.exit201, !decision.origin !674, !decision.order !675

if.else20.i198:                                   ; preds = %if.else16.i195
  %cmp22.i197 = fcmp ugt float %334, 5.000000e+00
  br i1 %cmp22.i197, label %if.end29.i200, label %if.then23.i199, !decision.origin !676

if.then23.i199:                                   ; preds = %if.else20.i198
  %341 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.4.1) #3
  br label %quant_decide.exit201, !decision.origin !677, !decision.order !678

if.end29.i200:                                    ; preds = %if.else20.i198
  %342 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.4.1) #3
  br label %quant_decide.exit201, !decision.origin !679, !decision.order !680

quant_decide.exit201:                             ; preds = %if.end29.i200, %if.then23.i199, %if.then19.i196, %if.then15.i193, %if.then11.i190, %if.then7.i187, %if.then3.i184, %if.then.i181
  %out.i.12 = phi float [ %336, %if.then3.i184 ], [ %338, %if.then11.i190 ], [ %340, %if.then19.i196 ], [ %342, %if.end29.i200 ], [ %341, %if.then23.i199 ], [ %339, %if.then15.i193 ], [ %337, %if.then7.i187 ], [ %335, %if.then.i181 ]
  %mul128.4.1 = fmul float %cond88.1, %out.i.12
  %sub132.4.1 = fsub float %mul128.4.1, %48
  %mul133.4.1 = fmul float %sub.4.1, %sub.4.1
  %mul134.4.1 = fmul float %sub132.4.1, %sub132.4.1
  %add135.4.1 = fadd float %mul133.4.1, %mul134.4.1
  %e.1.4.1 = fadd float %e.1.3.1, %add135.4.1
  %mul116.5.1 = fmul float %div73.1, %52
  %343 = tail call float @llvm.fabs.f32(float %mul116.5.1) #3
  %cmp.i158 = fcmp ugt float %343, 2.500000e-01
  br i1 %cmp.i158, label %if.else.i161, label %if.then.i159, !decision.origin !681

if.then.i159:                                     ; preds = %quant_decide.exit201
  %344 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.5.1) #3
  br label %quant_decide.exit179, !decision.origin !682, !decision.order !683

if.else.i161:                                     ; preds = %quant_decide.exit201
  %cmp2.i160 = fcmp olt float %343, 7.500000e-01
  br i1 %cmp2.i160, label %if.then3.i162, label %if.else4.i164, !decision.origin !684

if.then3.i162:                                    ; preds = %if.else.i161
  %345 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.5.1) #3
  br label %quant_decide.exit179, !decision.origin !685, !decision.order !686

if.else4.i164:                                    ; preds = %if.else.i161
  %cmp6.i163 = fcmp ugt float %343, 1.250000e+00
  br i1 %cmp6.i163, label %if.else8.i167, label %if.then7.i165, !decision.origin !687

if.then7.i165:                                    ; preds = %if.else4.i164
  %346 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.5.1) #3
  br label %quant_decide.exit179, !decision.origin !688, !decision.order !689

if.else8.i167:                                    ; preds = %if.else4.i164
  %cmp10.i166 = fcmp olt float %343, 1.750000e+00
  br i1 %cmp10.i166, label %if.then11.i168, label %if.else12.i170, !decision.origin !690

if.then11.i168:                                   ; preds = %if.else8.i167
  %347 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.5.1) #3
  br label %quant_decide.exit179, !decision.origin !691, !decision.order !692

if.else12.i170:                                   ; preds = %if.else8.i167
  %cmp14.i169 = fcmp ugt float %343, 2.500000e+00
  br i1 %cmp14.i169, label %if.else16.i173, label %if.then15.i171, !decision.origin !693

if.then15.i171:                                   ; preds = %if.else12.i170
  %348 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.5.1) #3
  br label %quant_decide.exit179, !decision.origin !694, !decision.order !695

if.else16.i173:                                   ; preds = %if.else12.i170
  %cmp18.i172 = fcmp olt float %343, 3.500000e+00
  br i1 %cmp18.i172, label %if.then19.i174, label %if.else20.i176, !decision.origin !696

if.then19.i174:                                   ; preds = %if.else16.i173
  %349 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.5.1) #3
  br label %quant_decide.exit179, !decision.origin !697, !decision.order !698

if.else20.i176:                                   ; preds = %if.else16.i173
  %cmp22.i175 = fcmp ugt float %343, 5.000000e+00
  br i1 %cmp22.i175, label %if.end29.i178, label %if.then23.i177, !decision.origin !699

if.then23.i177:                                   ; preds = %if.else20.i176
  %350 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.5.1) #3
  br label %quant_decide.exit179, !decision.origin !700, !decision.order !701

if.end29.i178:                                    ; preds = %if.else20.i176
  %351 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.5.1) #3
  br label %quant_decide.exit179, !decision.origin !702, !decision.order !703

quant_decide.exit179:                             ; preds = %if.end29.i178, %if.then23.i177, %if.then19.i174, %if.then15.i171, %if.then11.i168, %if.then7.i165, %if.then3.i162, %if.then.i159
  %out.i372.13 = phi float [ %345, %if.then3.i162 ], [ %347, %if.then11.i168 ], [ %349, %if.then19.i174 ], [ %351, %if.end29.i178 ], [ %350, %if.then23.i177 ], [ %348, %if.then15.i171 ], [ %346, %if.then7.i165 ], [ %344, %if.then.i159 ]
  %mul118.5.1 = fmul float %cond88.1, %out.i372.13
  %sub.5.1 = fsub float %mul118.5.1, %52
  %mul126.5.1 = fmul float %div73.1, %56
  %352 = tail call float @llvm.fabs.f32(float %mul126.5.1) #3
  %cmp.i136 = fcmp ugt float %352, 2.500000e-01
  br i1 %cmp.i136, label %if.else.i139, label %if.then.i137, !decision.origin !704

if.then.i137:                                     ; preds = %quant_decide.exit179
  %353 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.5.1) #3
  br label %quant_decide.exit157, !decision.origin !705, !decision.order !706

if.else.i139:                                     ; preds = %quant_decide.exit179
  %cmp2.i138 = fcmp olt float %352, 7.500000e-01
  br i1 %cmp2.i138, label %if.then3.i140, label %if.else4.i142, !decision.origin !707

if.then3.i140:                                    ; preds = %if.else.i139
  %354 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.5.1) #3
  br label %quant_decide.exit157, !decision.origin !708, !decision.order !709

if.else4.i142:                                    ; preds = %if.else.i139
  %cmp6.i141 = fcmp ugt float %352, 1.250000e+00
  br i1 %cmp6.i141, label %if.else8.i145, label %if.then7.i143, !decision.origin !710

if.then7.i143:                                    ; preds = %if.else4.i142
  %355 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.5.1) #3
  br label %quant_decide.exit157, !decision.origin !711, !decision.order !712

if.else8.i145:                                    ; preds = %if.else4.i142
  %cmp10.i144 = fcmp olt float %352, 1.750000e+00
  br i1 %cmp10.i144, label %if.then11.i146, label %if.else12.i148, !decision.origin !713

if.then11.i146:                                   ; preds = %if.else8.i145
  %356 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.5.1) #3
  br label %quant_decide.exit157, !decision.origin !714, !decision.order !715

if.else12.i148:                                   ; preds = %if.else8.i145
  %cmp14.i147 = fcmp ugt float %352, 2.500000e+00
  br i1 %cmp14.i147, label %if.else16.i151, label %if.then15.i149, !decision.origin !716

if.then15.i149:                                   ; preds = %if.else12.i148
  %357 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.5.1) #3
  br label %quant_decide.exit157, !decision.origin !717, !decision.order !718

if.else16.i151:                                   ; preds = %if.else12.i148
  %cmp18.i150 = fcmp olt float %352, 3.500000e+00
  br i1 %cmp18.i150, label %if.then19.i152, label %if.else20.i154, !decision.origin !719

if.then19.i152:                                   ; preds = %if.else16.i151
  %358 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.5.1) #3
  br label %quant_decide.exit157, !decision.origin !720, !decision.order !721

if.else20.i154:                                   ; preds = %if.else16.i151
  %cmp22.i153 = fcmp ugt float %352, 5.000000e+00
  br i1 %cmp22.i153, label %if.end29.i156, label %if.then23.i155, !decision.origin !722

if.then23.i155:                                   ; preds = %if.else20.i154
  %359 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.5.1) #3
  br label %quant_decide.exit157, !decision.origin !723, !decision.order !724

if.end29.i156:                                    ; preds = %if.else20.i154
  %360 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.5.1) #3
  br label %quant_decide.exit157, !decision.origin !725, !decision.order !726

quant_decide.exit157:                             ; preds = %if.end29.i156, %if.then23.i155, %if.then19.i152, %if.then15.i149, %if.then11.i146, %if.then7.i143, %if.then3.i140, %if.then.i137
  %out.i.13 = phi float [ %354, %if.then3.i140 ], [ %356, %if.then11.i146 ], [ %358, %if.then19.i152 ], [ %360, %if.end29.i156 ], [ %359, %if.then23.i155 ], [ %357, %if.then15.i149 ], [ %355, %if.then7.i143 ], [ %353, %if.then.i137 ]
  %mul128.5.1 = fmul float %cond88.1, %out.i.13
  %sub132.5.1 = fsub float %mul128.5.1, %56
  %mul133.5.1 = fmul float %sub.5.1, %sub.5.1
  %mul134.5.1 = fmul float %sub132.5.1, %sub132.5.1
  %add135.5.1 = fadd float %mul133.5.1, %mul134.5.1
  %e.1.5.1 = fadd float %e.1.4.1, %add135.5.1
  %mul116.6.1 = fmul float %div73.1, %60
  %361 = tail call float @llvm.fabs.f32(float %mul116.6.1) #3
  %cmp.i114 = fcmp ugt float %361, 2.500000e-01
  br i1 %cmp.i114, label %if.else.i117, label %if.then.i115, !decision.origin !727

if.then.i115:                                     ; preds = %quant_decide.exit157
  %362 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.6.1) #3
  br label %quant_decide.exit135, !decision.origin !728, !decision.order !729

if.else.i117:                                     ; preds = %quant_decide.exit157
  %cmp2.i116 = fcmp olt float %361, 7.500000e-01
  br i1 %cmp2.i116, label %if.then3.i118, label %if.else4.i120, !decision.origin !730

if.then3.i118:                                    ; preds = %if.else.i117
  %363 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.6.1) #3
  br label %quant_decide.exit135, !decision.origin !731, !decision.order !732

if.else4.i120:                                    ; preds = %if.else.i117
  %cmp6.i119 = fcmp ugt float %361, 1.250000e+00
  br i1 %cmp6.i119, label %if.else8.i123, label %if.then7.i121, !decision.origin !733

if.then7.i121:                                    ; preds = %if.else4.i120
  %364 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.6.1) #3
  br label %quant_decide.exit135, !decision.origin !734, !decision.order !735

if.else8.i123:                                    ; preds = %if.else4.i120
  %cmp10.i122 = fcmp olt float %361, 1.750000e+00
  br i1 %cmp10.i122, label %if.then11.i124, label %if.else12.i126, !decision.origin !736

if.then11.i124:                                   ; preds = %if.else8.i123
  %365 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.6.1) #3
  br label %quant_decide.exit135, !decision.origin !737, !decision.order !738

if.else12.i126:                                   ; preds = %if.else8.i123
  %cmp14.i125 = fcmp ugt float %361, 2.500000e+00
  br i1 %cmp14.i125, label %if.else16.i129, label %if.then15.i127, !decision.origin !739

if.then15.i127:                                   ; preds = %if.else12.i126
  %366 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.6.1) #3
  br label %quant_decide.exit135, !decision.origin !740, !decision.order !741

if.else16.i129:                                   ; preds = %if.else12.i126
  %cmp18.i128 = fcmp olt float %361, 3.500000e+00
  br i1 %cmp18.i128, label %if.then19.i130, label %if.else20.i132, !decision.origin !742

if.then19.i130:                                   ; preds = %if.else16.i129
  %367 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.6.1) #3
  br label %quant_decide.exit135, !decision.origin !743, !decision.order !744

if.else20.i132:                                   ; preds = %if.else16.i129
  %cmp22.i131 = fcmp ugt float %361, 5.000000e+00
  br i1 %cmp22.i131, label %if.end29.i134, label %if.then23.i133, !decision.origin !745

if.then23.i133:                                   ; preds = %if.else20.i132
  %368 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.6.1) #3
  br label %quant_decide.exit135, !decision.origin !746, !decision.order !747

if.end29.i134:                                    ; preds = %if.else20.i132
  %369 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.6.1) #3
  br label %quant_decide.exit135, !decision.origin !748, !decision.order !749

quant_decide.exit135:                             ; preds = %if.end29.i134, %if.then23.i133, %if.then19.i130, %if.then15.i127, %if.then11.i124, %if.then7.i121, %if.then3.i118, %if.then.i115
  %out.i372.14 = phi float [ %363, %if.then3.i118 ], [ %365, %if.then11.i124 ], [ %367, %if.then19.i130 ], [ %369, %if.end29.i134 ], [ %368, %if.then23.i133 ], [ %366, %if.then15.i127 ], [ %364, %if.then7.i121 ], [ %362, %if.then.i115 ]
  %mul118.6.1 = fmul float %cond88.1, %out.i372.14
  %sub.6.1 = fsub float %mul118.6.1, %60
  %mul126.6.1 = fmul float %div73.1, %64
  %370 = tail call float @llvm.fabs.f32(float %mul126.6.1) #3
  %cmp.i92 = fcmp ugt float %370, 2.500000e-01
  br i1 %cmp.i92, label %if.else.i95, label %if.then.i93, !decision.origin !750

if.then.i93:                                      ; preds = %quant_decide.exit135
  %371 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.6.1) #3
  br label %quant_decide.exit113, !decision.origin !751, !decision.order !752

if.else.i95:                                      ; preds = %quant_decide.exit135
  %cmp2.i94 = fcmp olt float %370, 7.500000e-01
  br i1 %cmp2.i94, label %if.then3.i96, label %if.else4.i98, !decision.origin !753

if.then3.i96:                                     ; preds = %if.else.i95
  %372 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.6.1) #3
  br label %quant_decide.exit113, !decision.origin !754, !decision.order !755

if.else4.i98:                                     ; preds = %if.else.i95
  %cmp6.i97 = fcmp ugt float %370, 1.250000e+00
  br i1 %cmp6.i97, label %if.else8.i101, label %if.then7.i99, !decision.origin !756

if.then7.i99:                                     ; preds = %if.else4.i98
  %373 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.6.1) #3
  br label %quant_decide.exit113, !decision.origin !757, !decision.order !758

if.else8.i101:                                    ; preds = %if.else4.i98
  %cmp10.i100 = fcmp olt float %370, 1.750000e+00
  br i1 %cmp10.i100, label %if.then11.i102, label %if.else12.i104, !decision.origin !759

if.then11.i102:                                   ; preds = %if.else8.i101
  %374 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.6.1) #3
  br label %quant_decide.exit113, !decision.origin !760, !decision.order !761

if.else12.i104:                                   ; preds = %if.else8.i101
  %cmp14.i103 = fcmp ugt float %370, 2.500000e+00
  br i1 %cmp14.i103, label %if.else16.i107, label %if.then15.i105, !decision.origin !762

if.then15.i105:                                   ; preds = %if.else12.i104
  %375 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.6.1) #3
  br label %quant_decide.exit113, !decision.origin !763, !decision.order !764

if.else16.i107:                                   ; preds = %if.else12.i104
  %cmp18.i106 = fcmp olt float %370, 3.500000e+00
  br i1 %cmp18.i106, label %if.then19.i108, label %if.else20.i110, !decision.origin !765

if.then19.i108:                                   ; preds = %if.else16.i107
  %376 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.6.1) #3
  br label %quant_decide.exit113, !decision.origin !766, !decision.order !767

if.else20.i110:                                   ; preds = %if.else16.i107
  %cmp22.i109 = fcmp ugt float %370, 5.000000e+00
  br i1 %cmp22.i109, label %if.end29.i112, label %if.then23.i111, !decision.origin !768

if.then23.i111:                                   ; preds = %if.else20.i110
  %377 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.6.1) #3
  br label %quant_decide.exit113, !decision.origin !769, !decision.order !770

if.end29.i112:                                    ; preds = %if.else20.i110
  %378 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.6.1) #3
  br label %quant_decide.exit113, !decision.origin !771, !decision.order !772

quant_decide.exit113:                             ; preds = %if.end29.i112, %if.then23.i111, %if.then19.i108, %if.then15.i105, %if.then11.i102, %if.then7.i99, %if.then3.i96, %if.then.i93
  %out.i.14 = phi float [ %372, %if.then3.i96 ], [ %374, %if.then11.i102 ], [ %376, %if.then19.i108 ], [ %378, %if.end29.i112 ], [ %377, %if.then23.i111 ], [ %375, %if.then15.i105 ], [ %373, %if.then7.i99 ], [ %371, %if.then.i93 ]
  %mul128.6.1 = fmul float %cond88.1, %out.i.14
  %sub132.6.1 = fsub float %mul128.6.1, %64
  %mul133.6.1 = fmul float %sub.6.1, %sub.6.1
  %mul134.6.1 = fmul float %sub132.6.1, %sub132.6.1
  %add135.6.1 = fadd float %mul133.6.1, %mul134.6.1
  %e.1.6.1 = fadd float %e.1.5.1, %add135.6.1
  %mul116.7.1 = fmul float %74, %div73.1
  %379 = tail call float @llvm.fabs.f32(float %mul116.7.1) #3
  %cmp.i70 = fcmp ugt float %379, 2.500000e-01
  br i1 %cmp.i70, label %if.else.i73, label %if.then.i71, !decision.origin !773

if.then.i71:                                      ; preds = %quant_decide.exit113
  %380 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.7.1) #3
  br label %quant_decide.exit91, !decision.origin !774, !decision.order !775

if.else.i73:                                      ; preds = %quant_decide.exit113
  %cmp2.i72 = fcmp olt float %379, 7.500000e-01
  br i1 %cmp2.i72, label %if.then3.i74, label %if.else4.i76, !decision.origin !776

if.then3.i74:                                     ; preds = %if.else.i73
  %381 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.7.1) #3
  br label %quant_decide.exit91, !decision.origin !777, !decision.order !778

if.else4.i76:                                     ; preds = %if.else.i73
  %cmp6.i75 = fcmp ugt float %379, 1.250000e+00
  br i1 %cmp6.i75, label %if.else8.i79, label %if.then7.i77, !decision.origin !779

if.then7.i77:                                     ; preds = %if.else4.i76
  %382 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.7.1) #3
  br label %quant_decide.exit91, !decision.origin !780, !decision.order !781

if.else8.i79:                                     ; preds = %if.else4.i76
  %cmp10.i78 = fcmp olt float %379, 1.750000e+00
  br i1 %cmp10.i78, label %if.then11.i80, label %if.else12.i82, !decision.origin !782

if.then11.i80:                                    ; preds = %if.else8.i79
  %383 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.7.1) #3
  br label %quant_decide.exit91, !decision.origin !783, !decision.order !784

if.else12.i82:                                    ; preds = %if.else8.i79
  %cmp14.i81 = fcmp ugt float %379, 2.500000e+00
  br i1 %cmp14.i81, label %if.else16.i85, label %if.then15.i83, !decision.origin !785

if.then15.i83:                                    ; preds = %if.else12.i82
  %384 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.7.1) #3
  br label %quant_decide.exit91, !decision.origin !786, !decision.order !787

if.else16.i85:                                    ; preds = %if.else12.i82
  %cmp18.i84 = fcmp olt float %379, 3.500000e+00
  br i1 %cmp18.i84, label %if.then19.i86, label %if.else20.i88, !decision.origin !788

if.then19.i86:                                    ; preds = %if.else16.i85
  %385 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.7.1) #3
  br label %quant_decide.exit91, !decision.origin !789, !decision.order !790

if.else20.i88:                                    ; preds = %if.else16.i85
  %cmp22.i87 = fcmp ugt float %379, 5.000000e+00
  br i1 %cmp22.i87, label %if.end29.i90, label %if.then23.i89, !decision.origin !791

if.then23.i89:                                    ; preds = %if.else20.i88
  %386 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.7.1) #3
  br label %quant_decide.exit91, !decision.origin !792, !decision.order !793

if.end29.i90:                                     ; preds = %if.else20.i88
  %387 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.7.1) #3
  br label %quant_decide.exit91, !decision.origin !794, !decision.order !795

quant_decide.exit91:                              ; preds = %if.end29.i90, %if.then23.i89, %if.then19.i86, %if.then15.i83, %if.then11.i80, %if.then7.i77, %if.then3.i74, %if.then.i71
  %out.i372.15 = phi float [ %381, %if.then3.i74 ], [ %383, %if.then11.i80 ], [ %385, %if.then19.i86 ], [ %387, %if.end29.i90 ], [ %386, %if.then23.i89 ], [ %384, %if.then15.i83 ], [ %382, %if.then7.i77 ], [ %380, %if.then.i71 ]
  %mul118.7.1 = fmul float %cond88.1, %out.i372.15
  %sub.7.1 = fsub float %mul118.7.1, %74
  %mul126.7.1 = fmul float %77, %div73.1
  %388 = tail call float @llvm.fabs.f32(float %mul126.7.1) #3
  %cmp.i48 = fcmp ugt float %388, 2.500000e-01
  br i1 %cmp.i48, label %if.else.i51, label %if.then.i49, !decision.origin !796

if.then.i49:                                      ; preds = %quant_decide.exit91
  %389 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.7.1) #3
  br label %quant_decide.exit69, !decision.origin !797, !decision.order !798

if.else.i51:                                      ; preds = %quant_decide.exit91
  %cmp2.i50 = fcmp olt float %388, 7.500000e-01
  br i1 %cmp2.i50, label %if.then3.i52, label %if.else4.i54, !decision.origin !799

if.then3.i52:                                     ; preds = %if.else.i51
  %390 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.7.1) #3
  br label %quant_decide.exit69, !decision.origin !800, !decision.order !801

if.else4.i54:                                     ; preds = %if.else.i51
  %cmp6.i53 = fcmp ugt float %388, 1.250000e+00
  br i1 %cmp6.i53, label %if.else8.i57, label %if.then7.i55, !decision.origin !802

if.then7.i55:                                     ; preds = %if.else4.i54
  %391 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.7.1) #3
  br label %quant_decide.exit69, !decision.origin !803, !decision.order !804

if.else8.i57:                                     ; preds = %if.else4.i54
  %cmp10.i56 = fcmp olt float %388, 1.750000e+00
  br i1 %cmp10.i56, label %if.then11.i58, label %if.else12.i60, !decision.origin !805

if.then11.i58:                                    ; preds = %if.else8.i57
  %392 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.7.1) #3
  br label %quant_decide.exit69, !decision.origin !806, !decision.order !807

if.else12.i60:                                    ; preds = %if.else8.i57
  %cmp14.i59 = fcmp ugt float %388, 2.500000e+00
  br i1 %cmp14.i59, label %if.else16.i63, label %if.then15.i61, !decision.origin !808

if.then15.i61:                                    ; preds = %if.else12.i60
  %393 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.7.1) #3
  br label %quant_decide.exit69, !decision.origin !809, !decision.order !810

if.else16.i63:                                    ; preds = %if.else12.i60
  %cmp18.i62 = fcmp olt float %388, 3.500000e+00
  br i1 %cmp18.i62, label %if.then19.i64, label %if.else20.i66, !decision.origin !811

if.then19.i64:                                    ; preds = %if.else16.i63
  %394 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.7.1) #3
  br label %quant_decide.exit69, !decision.origin !812, !decision.order !813

if.else20.i66:                                    ; preds = %if.else16.i63
  %cmp22.i65 = fcmp ugt float %388, 5.000000e+00
  br i1 %cmp22.i65, label %if.end29.i68, label %if.then23.i67, !decision.origin !814

if.then23.i67:                                    ; preds = %if.else20.i66
  %395 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.7.1) #3
  br label %quant_decide.exit69, !decision.origin !815, !decision.order !816

if.end29.i68:                                     ; preds = %if.else20.i66
  %396 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.7.1) #3
  br label %quant_decide.exit69, !decision.origin !817, !decision.order !818

quant_decide.exit69:                              ; preds = %if.end29.i68, %if.then23.i67, %if.then19.i64, %if.then15.i61, %if.then11.i58, %if.then7.i55, %if.then3.i52, %if.then.i49
  %out.i.15 = phi float [ %390, %if.then3.i52 ], [ %392, %if.then11.i58 ], [ %394, %if.then19.i64 ], [ %396, %if.end29.i68 ], [ %395, %if.then23.i67 ], [ %393, %if.then15.i61 ], [ %391, %if.then7.i55 ], [ %389, %if.then.i49 ]
  %mul128.7.1 = fmul float %cond88.1, %out.i.15
  %sub132.7.1 = fsub float %mul128.7.1, %77
  %397 = insertelement <2 x float> undef, float %sub132.7.1, i32 0
  %398 = insertelement <2 x float> %397, float %sub.7.1, i32 1
  %399 = fmul <2 x float> %398, %398
  br label %for.inc138.7.1, !decision.origin !819

if.then97.7.1:                                    ; preds = %cond.end75.1, %cond.end75.1.thread
  %os.sroa.0.5 = phi <2 x float> [ %252, %cond.end75.1 ], [ %251, %cond.end75.1.thread ]
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
  %400 = fmul <2 x float> %73, %73
  br label %for.inc138.7.1, !decision.origin !820

for.inc138.7.1:                                   ; preds = %if.then97.7.1, %quant_decide.exit69
  %os.sroa.0.6 = phi <2 x float> [ %os.sroa.0.5, %if.then97.7.1 ], [ %252, %quant_decide.exit69 ]
  %e.1.6.1654 = phi float [ %e.1.6.1653, %if.then97.7.1 ], [ %e.1.6.1, %quant_decide.exit69 ]
  %401 = phi <2 x float> [ %400, %if.then97.7.1 ], [ %399, %quant_decide.exit69 ]
  %402 = extractelement <2 x float> %401, i32 0
  %403 = extractelement <2 x float> %401, i32 1
  %add110.7.1 = fadd float %402, %403
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
  %404 = zext i1 %cmp149 to i32
  %405 = extractelement <2 x float> %os.sroa.0.6, i32 %404
  %mul175 = fmul float %405, %12
  %406 = tail call float @llvm.fabs.f32(float %mul175) #3
  %cmp.i351 = fcmp ugt float %406, 2.500000e-01
  br i1 %cmp.i351, label %cond.false.i353, label %_Z5pack4f.exit369, !decision.origin !821

cond.false.i353.1:                                ; preds = %_Z5pack4f.exit
  %cmp1.i352.1 = fcmp olt float %88, 7.500000e-01
  br i1 %cmp1.i352.1, label %_Z5pack4f.exit369.1, label %cond.false3.i355.1, !decision.origin !822

cond.false3.i355.1:                               ; preds = %cond.false.i353.1
  %cmp4.i354.1 = fcmp ugt float %88, 1.250000e+00
  br i1 %cmp4.i354.1, label %cond.false6.i357.1, label %_Z5pack4f.exit369.1, !decision.origin !823

cond.false6.i357.1:                               ; preds = %cond.false3.i355.1
  %cmp7.i356.1 = fcmp olt float %88, 1.750000e+00
  br i1 %cmp7.i356.1, label %_Z5pack4f.exit369.1, label %cond.false9.i359.1, !decision.origin !824

cond.false9.i359.1:                               ; preds = %cond.false6.i357.1
  %cmp10.i358.1 = fcmp ugt float %88, 2.500000e+00
  br i1 %cmp10.i358.1, label %cond.false12.i361.1, label %_Z5pack4f.exit369.1, !decision.origin !825

cond.false12.i361.1:                              ; preds = %cond.false9.i359.1
  %cmp13.i360.1 = fcmp olt float %88, 3.500000e+00
  br i1 %cmp13.i360.1, label %_Z5pack4f.exit369.1, label %cond.false15.i364.1, !decision.origin !826

cond.false15.i364.1:                              ; preds = %cond.false12.i361.1
  %cmp16.i362.1 = fcmp ole float %88, 5.000000e+00
  %cond.i363.1 = select i1 %cmp16.i362.1, i32 6, i32 7
  br label %_Z5pack4f.exit369.1, !decision.origin !827

_Z5pack4f.exit369.1:                              ; preds = %cond.false15.i364.1, %cond.false12.i361.1, %cond.false9.i359.1, %cond.false6.i357.1, %cond.false3.i355.1, %cond.false.i353.1, %_Z5pack4f.exit
  %cond27.i365.1 = phi i32 [ 0, %_Z5pack4f.exit ], [ 1, %cond.false.i353.1 ], [ 2, %cond.false3.i355.1 ], [ 3, %cond.false6.i357.1 ], [ 4, %cond.false9.i359.1 ], [ %cond.i363.1, %cond.false15.i364.1 ], [ 5, %cond.false12.i361.1 ]
  %407 = bitcast float %mul175.1 to i32
  %shr.i366.1 = lshr i32 %407, 28
  %and.i367.1 = and i32 %shr.i366.1, 8
  %or.i368.1 = or i32 %cond27.i365.1, %and.i367.1
  %mul183.1 = fmul float %405, %24
  %408 = tail call float @llvm.fabs.f32(float %mul183.1) #3
  %cmp.i.1 = fcmp ugt float %408, 2.500000e-01
  br i1 %cmp.i.1, label %cond.false.i.1, label %_Z5pack4f.exit.1, !decision.origin !828

cond.false.i.1:                                   ; preds = %_Z5pack4f.exit369.1
  %cmp1.i.1 = fcmp olt float %408, 7.500000e-01
  br i1 %cmp1.i.1, label %_Z5pack4f.exit.1, label %cond.false3.i.1, !decision.origin !829

cond.false3.i.1:                                  ; preds = %cond.false.i.1
  %cmp4.i.1 = fcmp ugt float %408, 1.250000e+00
  br i1 %cmp4.i.1, label %cond.false6.i.1, label %_Z5pack4f.exit.1, !decision.origin !830

cond.false6.i.1:                                  ; preds = %cond.false3.i.1
  %cmp7.i.1 = fcmp olt float %408, 1.750000e+00
  br i1 %cmp7.i.1, label %_Z5pack4f.exit.1, label %cond.false9.i.1, !decision.origin !831

cond.false9.i.1:                                  ; preds = %cond.false6.i.1
  %cmp10.i.1 = fcmp ugt float %408, 2.500000e+00
  br i1 %cmp10.i.1, label %cond.false12.i.1, label %_Z5pack4f.exit.1, !decision.origin !832

cond.false12.i.1:                                 ; preds = %cond.false9.i.1
  %cmp13.i.1 = fcmp olt float %408, 3.500000e+00
  br i1 %cmp13.i.1, label %_Z5pack4f.exit.1, label %cond.false15.i.1, !decision.origin !833

cond.false15.i.1:                                 ; preds = %cond.false12.i.1
  %cmp16.i.1 = fcmp ole float %408, 5.000000e+00
  %cond.i.1 = select i1 %cmp16.i.1, i32 6, i32 7
  br label %_Z5pack4f.exit.1, !decision.origin !834

_Z5pack4f.exit.1:                                 ; preds = %cond.false15.i.1, %cond.false12.i.1, %cond.false9.i.1, %cond.false6.i.1, %cond.false3.i.1, %cond.false.i.1, %_Z5pack4f.exit369.1
  %cond27.i.1 = phi i32 [ 0, %_Z5pack4f.exit369.1 ], [ 1, %cond.false.i.1 ], [ 2, %cond.false3.i.1 ], [ 3, %cond.false6.i.1 ], [ 4, %cond.false9.i.1 ], [ %cond.i.1, %cond.false15.i.1 ], [ 5, %cond.false12.i.1 ]
  %409 = bitcast float %mul183.1 to i32
  %shr.i.1 = lshr i32 %409, 28
  %and.i.1 = and i32 %shr.i.1, 8
  %or.i.1 = or i32 %cond27.i.1, %and.i.1
  %shl.1 = shl nuw nsw i32 %or.i.1, 4
  %or.1 = or i32 %or.i368.1, %shl.1
  %conv185.1 = trunc i32 %or.1 to i8
  %add187.1 = add nsw i64 %add164, 1
  %arrayidx188339.1 = getelementptr inbounds i8, i8 addrspace(1)* %cond19.v, i64 %add187.1
  store i8 %conv185.1, i8 addrspace(1)* %arrayidx188339.1, align 1, !tbaa !18
  %mul175.2 = fmul float %405, %28
  %410 = tail call float @llvm.fabs.f32(float %mul175.2) #3
  %cmp.i351.2 = fcmp ugt float %410, 2.500000e-01
  br i1 %cmp.i351.2, label %cond.false.i353.2, label %_Z5pack4f.exit369.2, !decision.origin !835

cond.false.i353.2:                                ; preds = %_Z5pack4f.exit.1
  %cmp1.i352.2 = fcmp olt float %410, 7.500000e-01
  br i1 %cmp1.i352.2, label %_Z5pack4f.exit369.2, label %cond.false3.i355.2, !decision.origin !836

cond.false3.i355.2:                               ; preds = %cond.false.i353.2
  %cmp4.i354.2 = fcmp ugt float %410, 1.250000e+00
  br i1 %cmp4.i354.2, label %cond.false6.i357.2, label %_Z5pack4f.exit369.2, !decision.origin !837

cond.false6.i357.2:                               ; preds = %cond.false3.i355.2
  %cmp7.i356.2 = fcmp olt float %410, 1.750000e+00
  br i1 %cmp7.i356.2, label %_Z5pack4f.exit369.2, label %cond.false9.i359.2, !decision.origin !838

cond.false9.i359.2:                               ; preds = %cond.false6.i357.2
  %cmp10.i358.2 = fcmp ugt float %410, 2.500000e+00
  br i1 %cmp10.i358.2, label %cond.false12.i361.2, label %_Z5pack4f.exit369.2, !decision.origin !839

cond.false12.i361.2:                              ; preds = %cond.false9.i359.2
  %cmp13.i360.2 = fcmp olt float %410, 3.500000e+00
  br i1 %cmp13.i360.2, label %_Z5pack4f.exit369.2, label %cond.false15.i364.2, !decision.origin !840

cond.false15.i364.2:                              ; preds = %cond.false12.i361.2
  %cmp16.i362.2 = fcmp ole float %410, 5.000000e+00
  %cond.i363.2 = select i1 %cmp16.i362.2, i32 6, i32 7
  br label %_Z5pack4f.exit369.2, !decision.origin !841

_Z5pack4f.exit369.2:                              ; preds = %cond.false15.i364.2, %cond.false12.i361.2, %cond.false9.i359.2, %cond.false6.i357.2, %cond.false3.i355.2, %cond.false.i353.2, %_Z5pack4f.exit.1
  %cond27.i365.2 = phi i32 [ 0, %_Z5pack4f.exit.1 ], [ 1, %cond.false.i353.2 ], [ 2, %cond.false3.i355.2 ], [ 3, %cond.false6.i357.2 ], [ 4, %cond.false9.i359.2 ], [ %cond.i363.2, %cond.false15.i364.2 ], [ 5, %cond.false12.i361.2 ]
  %411 = bitcast float %mul175.2 to i32
  %shr.i366.2 = lshr i32 %411, 28
  %and.i367.2 = and i32 %shr.i366.2, 8
  %or.i368.2 = or i32 %cond27.i365.2, %and.i367.2
  %mul183.2 = fmul float %405, %32
  %412 = tail call float @llvm.fabs.f32(float %mul183.2) #3
  %cmp.i.2 = fcmp ugt float %412, 2.500000e-01
  br i1 %cmp.i.2, label %cond.false.i.2, label %_Z5pack4f.exit.2, !decision.origin !842

cond.false.i.2:                                   ; preds = %_Z5pack4f.exit369.2
  %cmp1.i.2 = fcmp olt float %412, 7.500000e-01
  br i1 %cmp1.i.2, label %_Z5pack4f.exit.2, label %cond.false3.i.2, !decision.origin !843

cond.false3.i.2:                                  ; preds = %cond.false.i.2
  %cmp4.i.2 = fcmp ugt float %412, 1.250000e+00
  br i1 %cmp4.i.2, label %cond.false6.i.2, label %_Z5pack4f.exit.2, !decision.origin !844

cond.false6.i.2:                                  ; preds = %cond.false3.i.2
  %cmp7.i.2 = fcmp olt float %412, 1.750000e+00
  br i1 %cmp7.i.2, label %_Z5pack4f.exit.2, label %cond.false9.i.2, !decision.origin !845

cond.false9.i.2:                                  ; preds = %cond.false6.i.2
  %cmp10.i.2 = fcmp ugt float %412, 2.500000e+00
  br i1 %cmp10.i.2, label %cond.false12.i.2, label %_Z5pack4f.exit.2, !decision.origin !846

cond.false12.i.2:                                 ; preds = %cond.false9.i.2
  %cmp13.i.2 = fcmp olt float %412, 3.500000e+00
  br i1 %cmp13.i.2, label %_Z5pack4f.exit.2, label %cond.false15.i.2, !decision.origin !847

cond.false15.i.2:                                 ; preds = %cond.false12.i.2
  %cmp16.i.2 = fcmp ole float %412, 5.000000e+00
  %cond.i.2 = select i1 %cmp16.i.2, i32 6, i32 7
  br label %_Z5pack4f.exit.2, !decision.origin !848

_Z5pack4f.exit.2:                                 ; preds = %cond.false15.i.2, %cond.false12.i.2, %cond.false9.i.2, %cond.false6.i.2, %cond.false3.i.2, %cond.false.i.2, %_Z5pack4f.exit369.2
  %cond27.i.2 = phi i32 [ 0, %_Z5pack4f.exit369.2 ], [ 1, %cond.false.i.2 ], [ 2, %cond.false3.i.2 ], [ 3, %cond.false6.i.2 ], [ 4, %cond.false9.i.2 ], [ %cond.i.2, %cond.false15.i.2 ], [ 5, %cond.false12.i.2 ]
  %413 = bitcast float %mul183.2 to i32
  %shr.i.2 = lshr i32 %413, 28
  %and.i.2 = and i32 %shr.i.2, 8
  %or.i.2 = or i32 %cond27.i.2, %and.i.2
  %shl.2 = shl nuw nsw i32 %or.i.2, 4
  %or.2 = or i32 %or.i368.2, %shl.2
  %conv185.2 = trunc i32 %or.2 to i8
  %add187.2 = add nsw i64 %add164, 2
  %arrayidx188339.2 = getelementptr inbounds i8, i8 addrspace(1)* %cond19.v, i64 %add187.2
  store i8 %conv185.2, i8 addrspace(1)* %arrayidx188339.2, align 1, !tbaa !18
  %mul175.3 = fmul float %405, %36
  %414 = tail call float @llvm.fabs.f32(float %mul175.3) #3
  %cmp.i351.3 = fcmp ugt float %414, 2.500000e-01
  br i1 %cmp.i351.3, label %cond.false.i353.3, label %_Z5pack4f.exit369.3, !decision.origin !849

cond.false.i353.3:                                ; preds = %_Z5pack4f.exit.2
  %cmp1.i352.3 = fcmp olt float %414, 7.500000e-01
  br i1 %cmp1.i352.3, label %_Z5pack4f.exit369.3, label %cond.false3.i355.3, !decision.origin !850

cond.false3.i355.3:                               ; preds = %cond.false.i353.3
  %cmp4.i354.3 = fcmp ugt float %414, 1.250000e+00
  br i1 %cmp4.i354.3, label %cond.false6.i357.3, label %_Z5pack4f.exit369.3, !decision.origin !851

cond.false6.i357.3:                               ; preds = %cond.false3.i355.3
  %cmp7.i356.3 = fcmp olt float %414, 1.750000e+00
  br i1 %cmp7.i356.3, label %_Z5pack4f.exit369.3, label %cond.false9.i359.3, !decision.origin !852

cond.false9.i359.3:                               ; preds = %cond.false6.i357.3
  %cmp10.i358.3 = fcmp ugt float %414, 2.500000e+00
  br i1 %cmp10.i358.3, label %cond.false12.i361.3, label %_Z5pack4f.exit369.3, !decision.origin !853

cond.false12.i361.3:                              ; preds = %cond.false9.i359.3
  %cmp13.i360.3 = fcmp olt float %414, 3.500000e+00
  br i1 %cmp13.i360.3, label %_Z5pack4f.exit369.3, label %cond.false15.i364.3, !decision.origin !854

cond.false15.i364.3:                              ; preds = %cond.false12.i361.3
  %cmp16.i362.3 = fcmp ole float %414, 5.000000e+00
  %cond.i363.3 = select i1 %cmp16.i362.3, i32 6, i32 7
  br label %_Z5pack4f.exit369.3, !decision.origin !855

_Z5pack4f.exit369.3:                              ; preds = %cond.false15.i364.3, %cond.false12.i361.3, %cond.false9.i359.3, %cond.false6.i357.3, %cond.false3.i355.3, %cond.false.i353.3, %_Z5pack4f.exit.2
  %cond27.i365.3 = phi i32 [ 0, %_Z5pack4f.exit.2 ], [ 1, %cond.false.i353.3 ], [ 2, %cond.false3.i355.3 ], [ 3, %cond.false6.i357.3 ], [ 4, %cond.false9.i359.3 ], [ %cond.i363.3, %cond.false15.i364.3 ], [ 5, %cond.false12.i361.3 ]
  %415 = bitcast float %mul175.3 to i32
  %shr.i366.3 = lshr i32 %415, 28
  %and.i367.3 = and i32 %shr.i366.3, 8
  %or.i368.3 = or i32 %cond27.i365.3, %and.i367.3
  %mul183.3 = fmul float %405, %40
  %416 = tail call float @llvm.fabs.f32(float %mul183.3) #3
  %cmp.i.3 = fcmp ugt float %416, 2.500000e-01
  br i1 %cmp.i.3, label %cond.false.i.3, label %_Z5pack4f.exit.3, !decision.origin !856

cond.false.i.3:                                   ; preds = %_Z5pack4f.exit369.3
  %cmp1.i.3 = fcmp olt float %416, 7.500000e-01
  br i1 %cmp1.i.3, label %_Z5pack4f.exit.3, label %cond.false3.i.3, !decision.origin !857

cond.false3.i.3:                                  ; preds = %cond.false.i.3
  %cmp4.i.3 = fcmp ugt float %416, 1.250000e+00
  br i1 %cmp4.i.3, label %cond.false6.i.3, label %_Z5pack4f.exit.3, !decision.origin !858

cond.false6.i.3:                                  ; preds = %cond.false3.i.3
  %cmp7.i.3 = fcmp olt float %416, 1.750000e+00
  br i1 %cmp7.i.3, label %_Z5pack4f.exit.3, label %cond.false9.i.3, !decision.origin !859

cond.false9.i.3:                                  ; preds = %cond.false6.i.3
  %cmp10.i.3 = fcmp ugt float %416, 2.500000e+00
  br i1 %cmp10.i.3, label %cond.false12.i.3, label %_Z5pack4f.exit.3, !decision.origin !860

cond.false12.i.3:                                 ; preds = %cond.false9.i.3
  %cmp13.i.3 = fcmp olt float %416, 3.500000e+00
  br i1 %cmp13.i.3, label %_Z5pack4f.exit.3, label %cond.false15.i.3, !decision.origin !861

cond.false15.i.3:                                 ; preds = %cond.false12.i.3
  %cmp16.i.3 = fcmp ole float %416, 5.000000e+00
  %cond.i.3 = select i1 %cmp16.i.3, i32 6, i32 7
  br label %_Z5pack4f.exit.3, !decision.origin !862

_Z5pack4f.exit.3:                                 ; preds = %cond.false15.i.3, %cond.false12.i.3, %cond.false9.i.3, %cond.false6.i.3, %cond.false3.i.3, %cond.false.i.3, %_Z5pack4f.exit369.3
  %cond27.i.3 = phi i32 [ 0, %_Z5pack4f.exit369.3 ], [ 1, %cond.false.i.3 ], [ 2, %cond.false3.i.3 ], [ 3, %cond.false6.i.3 ], [ 4, %cond.false9.i.3 ], [ %cond.i.3, %cond.false15.i.3 ], [ 5, %cond.false12.i.3 ]
  %417 = bitcast float %mul183.3 to i32
  %shr.i.3 = lshr i32 %417, 28
  %and.i.3 = and i32 %shr.i.3, 8
  %or.i.3 = or i32 %cond27.i.3, %and.i.3
  %shl.3 = shl nuw nsw i32 %or.i.3, 4
  %or.3 = or i32 %or.i368.3, %shl.3
  %conv185.3 = trunc i32 %or.3 to i8
  %add187.3 = add nsw i64 %add164, 3
  %arrayidx188339.3 = getelementptr inbounds i8, i8 addrspace(1)* %cond19.v, i64 %add187.3
  store i8 %conv185.3, i8 addrspace(1)* %arrayidx188339.3, align 1, !tbaa !18
  %mul175.4 = fmul float %405, %44
  %418 = tail call float @llvm.fabs.f32(float %mul175.4) #3
  %cmp.i351.4 = fcmp ugt float %418, 2.500000e-01
  br i1 %cmp.i351.4, label %cond.false.i353.4, label %_Z5pack4f.exit369.4, !decision.origin !863

cond.false.i353.4:                                ; preds = %_Z5pack4f.exit.3
  %cmp1.i352.4 = fcmp olt float %418, 7.500000e-01
  br i1 %cmp1.i352.4, label %_Z5pack4f.exit369.4, label %cond.false3.i355.4, !decision.origin !864

cond.false3.i355.4:                               ; preds = %cond.false.i353.4
  %cmp4.i354.4 = fcmp ugt float %418, 1.250000e+00
  br i1 %cmp4.i354.4, label %cond.false6.i357.4, label %_Z5pack4f.exit369.4, !decision.origin !865

cond.false6.i357.4:                               ; preds = %cond.false3.i355.4
  %cmp7.i356.4 = fcmp olt float %418, 1.750000e+00
  br i1 %cmp7.i356.4, label %_Z5pack4f.exit369.4, label %cond.false9.i359.4, !decision.origin !866

cond.false9.i359.4:                               ; preds = %cond.false6.i357.4
  %cmp10.i358.4 = fcmp ugt float %418, 2.500000e+00
  br i1 %cmp10.i358.4, label %cond.false12.i361.4, label %_Z5pack4f.exit369.4, !decision.origin !867

cond.false12.i361.4:                              ; preds = %cond.false9.i359.4
  %cmp13.i360.4 = fcmp olt float %418, 3.500000e+00
  br i1 %cmp13.i360.4, label %_Z5pack4f.exit369.4, label %cond.false15.i364.4, !decision.origin !868

cond.false15.i364.4:                              ; preds = %cond.false12.i361.4
  %cmp16.i362.4 = fcmp ole float %418, 5.000000e+00
  %cond.i363.4 = select i1 %cmp16.i362.4, i32 6, i32 7
  br label %_Z5pack4f.exit369.4, !decision.origin !869

_Z5pack4f.exit369.4:                              ; preds = %cond.false15.i364.4, %cond.false12.i361.4, %cond.false9.i359.4, %cond.false6.i357.4, %cond.false3.i355.4, %cond.false.i353.4, %_Z5pack4f.exit.3
  %cond27.i365.4 = phi i32 [ 0, %_Z5pack4f.exit.3 ], [ 1, %cond.false.i353.4 ], [ 2, %cond.false3.i355.4 ], [ 3, %cond.false6.i357.4 ], [ 4, %cond.false9.i359.4 ], [ %cond.i363.4, %cond.false15.i364.4 ], [ 5, %cond.false12.i361.4 ]
  %419 = bitcast float %mul175.4 to i32
  %shr.i366.4 = lshr i32 %419, 28
  %and.i367.4 = and i32 %shr.i366.4, 8
  %or.i368.4 = or i32 %cond27.i365.4, %and.i367.4
  %mul183.4 = fmul float %405, %48
  %420 = tail call float @llvm.fabs.f32(float %mul183.4) #3
  %cmp.i.4 = fcmp ugt float %420, 2.500000e-01
  br i1 %cmp.i.4, label %cond.false.i.4, label %_Z5pack4f.exit.4, !decision.origin !870

cond.false.i.4:                                   ; preds = %_Z5pack4f.exit369.4
  %cmp1.i.4 = fcmp olt float %420, 7.500000e-01
  br i1 %cmp1.i.4, label %_Z5pack4f.exit.4, label %cond.false3.i.4, !decision.origin !871

cond.false3.i.4:                                  ; preds = %cond.false.i.4
  %cmp4.i.4 = fcmp ugt float %420, 1.250000e+00
  br i1 %cmp4.i.4, label %cond.false6.i.4, label %_Z5pack4f.exit.4, !decision.origin !872

cond.false6.i.4:                                  ; preds = %cond.false3.i.4
  %cmp7.i.4 = fcmp olt float %420, 1.750000e+00
  br i1 %cmp7.i.4, label %_Z5pack4f.exit.4, label %cond.false9.i.4, !decision.origin !873

cond.false9.i.4:                                  ; preds = %cond.false6.i.4
  %cmp10.i.4 = fcmp ugt float %420, 2.500000e+00
  br i1 %cmp10.i.4, label %cond.false12.i.4, label %_Z5pack4f.exit.4, !decision.origin !874

cond.false12.i.4:                                 ; preds = %cond.false9.i.4
  %cmp13.i.4 = fcmp olt float %420, 3.500000e+00
  br i1 %cmp13.i.4, label %_Z5pack4f.exit.4, label %cond.false15.i.4, !decision.origin !875

cond.false15.i.4:                                 ; preds = %cond.false12.i.4
  %cmp16.i.4 = fcmp ole float %420, 5.000000e+00
  %cond.i.4 = select i1 %cmp16.i.4, i32 6, i32 7
  br label %_Z5pack4f.exit.4, !decision.origin !876

_Z5pack4f.exit.4:                                 ; preds = %cond.false15.i.4, %cond.false12.i.4, %cond.false9.i.4, %cond.false6.i.4, %cond.false3.i.4, %cond.false.i.4, %_Z5pack4f.exit369.4
  %cond27.i.4 = phi i32 [ 0, %_Z5pack4f.exit369.4 ], [ 1, %cond.false.i.4 ], [ 2, %cond.false3.i.4 ], [ 3, %cond.false6.i.4 ], [ 4, %cond.false9.i.4 ], [ %cond.i.4, %cond.false15.i.4 ], [ 5, %cond.false12.i.4 ]
  %421 = bitcast float %mul183.4 to i32
  %shr.i.4 = lshr i32 %421, 28
  %and.i.4 = and i32 %shr.i.4, 8
  %or.i.4 = or i32 %cond27.i.4, %and.i.4
  %shl.4 = shl nuw nsw i32 %or.i.4, 4
  %or.4 = or i32 %or.i368.4, %shl.4
  %conv185.4 = trunc i32 %or.4 to i8
  %add187.4 = add nsw i64 %add164, 4
  %arrayidx188339.4 = getelementptr inbounds i8, i8 addrspace(1)* %cond19.v, i64 %add187.4
  store i8 %conv185.4, i8 addrspace(1)* %arrayidx188339.4, align 1, !tbaa !18
  %mul175.5 = fmul float %405, %52
  %422 = tail call float @llvm.fabs.f32(float %mul175.5) #3
  %cmp.i351.5 = fcmp ugt float %422, 2.500000e-01
  br i1 %cmp.i351.5, label %cond.false.i353.5, label %_Z5pack4f.exit369.5, !decision.origin !877

cond.false.i353.5:                                ; preds = %_Z5pack4f.exit.4
  %cmp1.i352.5 = fcmp olt float %422, 7.500000e-01
  br i1 %cmp1.i352.5, label %_Z5pack4f.exit369.5, label %cond.false3.i355.5, !decision.origin !878

cond.false3.i355.5:                               ; preds = %cond.false.i353.5
  %cmp4.i354.5 = fcmp ugt float %422, 1.250000e+00
  br i1 %cmp4.i354.5, label %cond.false6.i357.5, label %_Z5pack4f.exit369.5, !decision.origin !879

cond.false6.i357.5:                               ; preds = %cond.false3.i355.5
  %cmp7.i356.5 = fcmp olt float %422, 1.750000e+00
  br i1 %cmp7.i356.5, label %_Z5pack4f.exit369.5, label %cond.false9.i359.5, !decision.origin !880

cond.false9.i359.5:                               ; preds = %cond.false6.i357.5
  %cmp10.i358.5 = fcmp ugt float %422, 2.500000e+00
  br i1 %cmp10.i358.5, label %cond.false12.i361.5, label %_Z5pack4f.exit369.5, !decision.origin !881

cond.false12.i361.5:                              ; preds = %cond.false9.i359.5
  %cmp13.i360.5 = fcmp olt float %422, 3.500000e+00
  br i1 %cmp13.i360.5, label %_Z5pack4f.exit369.5, label %cond.false15.i364.5, !decision.origin !882

cond.false15.i364.5:                              ; preds = %cond.false12.i361.5
  %cmp16.i362.5 = fcmp ole float %422, 5.000000e+00
  %cond.i363.5 = select i1 %cmp16.i362.5, i32 6, i32 7
  br label %_Z5pack4f.exit369.5, !decision.origin !883

_Z5pack4f.exit369.5:                              ; preds = %cond.false15.i364.5, %cond.false12.i361.5, %cond.false9.i359.5, %cond.false6.i357.5, %cond.false3.i355.5, %cond.false.i353.5, %_Z5pack4f.exit.4
  %cond27.i365.5 = phi i32 [ 0, %_Z5pack4f.exit.4 ], [ 1, %cond.false.i353.5 ], [ 2, %cond.false3.i355.5 ], [ 3, %cond.false6.i357.5 ], [ 4, %cond.false9.i359.5 ], [ %cond.i363.5, %cond.false15.i364.5 ], [ 5, %cond.false12.i361.5 ]
  %423 = bitcast float %mul175.5 to i32
  %shr.i366.5 = lshr i32 %423, 28
  %and.i367.5 = and i32 %shr.i366.5, 8
  %or.i368.5 = or i32 %cond27.i365.5, %and.i367.5
  %mul183.5 = fmul float %405, %56
  %424 = tail call float @llvm.fabs.f32(float %mul183.5) #3
  %cmp.i.5 = fcmp ugt float %424, 2.500000e-01
  br i1 %cmp.i.5, label %cond.false.i.5, label %_Z5pack4f.exit.5, !decision.origin !884

cond.false.i.5:                                   ; preds = %_Z5pack4f.exit369.5
  %cmp1.i.5 = fcmp olt float %424, 7.500000e-01
  br i1 %cmp1.i.5, label %_Z5pack4f.exit.5, label %cond.false3.i.5, !decision.origin !885

cond.false3.i.5:                                  ; preds = %cond.false.i.5
  %cmp4.i.5 = fcmp ugt float %424, 1.250000e+00
  br i1 %cmp4.i.5, label %cond.false6.i.5, label %_Z5pack4f.exit.5, !decision.origin !886

cond.false6.i.5:                                  ; preds = %cond.false3.i.5
  %cmp7.i.5 = fcmp olt float %424, 1.750000e+00
  br i1 %cmp7.i.5, label %_Z5pack4f.exit.5, label %cond.false9.i.5, !decision.origin !887

cond.false9.i.5:                                  ; preds = %cond.false6.i.5
  %cmp10.i.5 = fcmp ugt float %424, 2.500000e+00
  br i1 %cmp10.i.5, label %cond.false12.i.5, label %_Z5pack4f.exit.5, !decision.origin !888

cond.false12.i.5:                                 ; preds = %cond.false9.i.5
  %cmp13.i.5 = fcmp olt float %424, 3.500000e+00
  br i1 %cmp13.i.5, label %_Z5pack4f.exit.5, label %cond.false15.i.5, !decision.origin !889

cond.false15.i.5:                                 ; preds = %cond.false12.i.5
  %cmp16.i.5 = fcmp ole float %424, 5.000000e+00
  %cond.i.5 = select i1 %cmp16.i.5, i32 6, i32 7
  br label %_Z5pack4f.exit.5, !decision.origin !890

_Z5pack4f.exit.5:                                 ; preds = %cond.false15.i.5, %cond.false12.i.5, %cond.false9.i.5, %cond.false6.i.5, %cond.false3.i.5, %cond.false.i.5, %_Z5pack4f.exit369.5
  %cond27.i.5 = phi i32 [ 0, %_Z5pack4f.exit369.5 ], [ 1, %cond.false.i.5 ], [ 2, %cond.false3.i.5 ], [ 3, %cond.false6.i.5 ], [ 4, %cond.false9.i.5 ], [ %cond.i.5, %cond.false15.i.5 ], [ 5, %cond.false12.i.5 ]
  %425 = bitcast float %mul183.5 to i32
  %shr.i.5 = lshr i32 %425, 28
  %and.i.5 = and i32 %shr.i.5, 8
  %or.i.5 = or i32 %cond27.i.5, %and.i.5
  %shl.5 = shl nuw nsw i32 %or.i.5, 4
  %or.5 = or i32 %or.i368.5, %shl.5
  %conv185.5 = trunc i32 %or.5 to i8
  %add187.5 = add nsw i64 %add164, 5
  %arrayidx188339.5 = getelementptr inbounds i8, i8 addrspace(1)* %cond19.v, i64 %add187.5
  store i8 %conv185.5, i8 addrspace(1)* %arrayidx188339.5, align 1, !tbaa !18
  %mul175.6 = fmul float %405, %60
  %426 = tail call float @llvm.fabs.f32(float %mul175.6) #3
  %cmp.i351.6 = fcmp ugt float %426, 2.500000e-01
  br i1 %cmp.i351.6, label %cond.false.i353.6, label %_Z5pack4f.exit369.6, !decision.origin !891

cond.false.i353.6:                                ; preds = %_Z5pack4f.exit.5
  %cmp1.i352.6 = fcmp olt float %426, 7.500000e-01
  br i1 %cmp1.i352.6, label %_Z5pack4f.exit369.6, label %cond.false3.i355.6, !decision.origin !892

cond.false3.i355.6:                               ; preds = %cond.false.i353.6
  %cmp4.i354.6 = fcmp ugt float %426, 1.250000e+00
  br i1 %cmp4.i354.6, label %cond.false6.i357.6, label %_Z5pack4f.exit369.6, !decision.origin !893

cond.false6.i357.6:                               ; preds = %cond.false3.i355.6
  %cmp7.i356.6 = fcmp olt float %426, 1.750000e+00
  br i1 %cmp7.i356.6, label %_Z5pack4f.exit369.6, label %cond.false9.i359.6, !decision.origin !894

cond.false9.i359.6:                               ; preds = %cond.false6.i357.6
  %cmp10.i358.6 = fcmp ugt float %426, 2.500000e+00
  br i1 %cmp10.i358.6, label %cond.false12.i361.6, label %_Z5pack4f.exit369.6, !decision.origin !895

cond.false12.i361.6:                              ; preds = %cond.false9.i359.6
  %cmp13.i360.6 = fcmp olt float %426, 3.500000e+00
  br i1 %cmp13.i360.6, label %_Z5pack4f.exit369.6, label %cond.false15.i364.6, !decision.origin !896

cond.false15.i364.6:                              ; preds = %cond.false12.i361.6
  %cmp16.i362.6 = fcmp ole float %426, 5.000000e+00
  %cond.i363.6 = select i1 %cmp16.i362.6, i32 6, i32 7
  br label %_Z5pack4f.exit369.6, !decision.origin !897

_Z5pack4f.exit369.6:                              ; preds = %cond.false15.i364.6, %cond.false12.i361.6, %cond.false9.i359.6, %cond.false6.i357.6, %cond.false3.i355.6, %cond.false.i353.6, %_Z5pack4f.exit.5
  %cond27.i365.6 = phi i32 [ 0, %_Z5pack4f.exit.5 ], [ 1, %cond.false.i353.6 ], [ 2, %cond.false3.i355.6 ], [ 3, %cond.false6.i357.6 ], [ 4, %cond.false9.i359.6 ], [ %cond.i363.6, %cond.false15.i364.6 ], [ 5, %cond.false12.i361.6 ]
  %427 = bitcast float %mul175.6 to i32
  %shr.i366.6 = lshr i32 %427, 28
  %and.i367.6 = and i32 %shr.i366.6, 8
  %or.i368.6 = or i32 %cond27.i365.6, %and.i367.6
  %mul183.6 = fmul float %405, %64
  %428 = tail call float @llvm.fabs.f32(float %mul183.6) #3
  %cmp.i.6 = fcmp ugt float %428, 2.500000e-01
  br i1 %cmp.i.6, label %cond.false.i.6, label %_Z5pack4f.exit.6, !decision.origin !898

cond.false.i.6:                                   ; preds = %_Z5pack4f.exit369.6
  %cmp1.i.6 = fcmp olt float %428, 7.500000e-01
  br i1 %cmp1.i.6, label %_Z5pack4f.exit.6, label %cond.false3.i.6, !decision.origin !899

cond.false3.i.6:                                  ; preds = %cond.false.i.6
  %cmp4.i.6 = fcmp ugt float %428, 1.250000e+00
  br i1 %cmp4.i.6, label %cond.false6.i.6, label %_Z5pack4f.exit.6, !decision.origin !900

cond.false6.i.6:                                  ; preds = %cond.false3.i.6
  %cmp7.i.6 = fcmp olt float %428, 1.750000e+00
  br i1 %cmp7.i.6, label %_Z5pack4f.exit.6, label %cond.false9.i.6, !decision.origin !901

cond.false9.i.6:                                  ; preds = %cond.false6.i.6
  %cmp10.i.6 = fcmp ugt float %428, 2.500000e+00
  br i1 %cmp10.i.6, label %cond.false12.i.6, label %_Z5pack4f.exit.6, !decision.origin !902

cond.false12.i.6:                                 ; preds = %cond.false9.i.6
  %cmp13.i.6 = fcmp olt float %428, 3.500000e+00
  br i1 %cmp13.i.6, label %_Z5pack4f.exit.6, label %cond.false15.i.6, !decision.origin !903

cond.false15.i.6:                                 ; preds = %cond.false12.i.6
  %cmp16.i.6 = fcmp ole float %428, 5.000000e+00
  %cond.i.6 = select i1 %cmp16.i.6, i32 6, i32 7
  br label %_Z5pack4f.exit.6, !decision.origin !904

_Z5pack4f.exit.6:                                 ; preds = %cond.false15.i.6, %cond.false12.i.6, %cond.false9.i.6, %cond.false6.i.6, %cond.false3.i.6, %cond.false.i.6, %_Z5pack4f.exit369.6
  %cond27.i.6 = phi i32 [ 0, %_Z5pack4f.exit369.6 ], [ 1, %cond.false.i.6 ], [ 2, %cond.false3.i.6 ], [ 3, %cond.false6.i.6 ], [ 4, %cond.false9.i.6 ], [ %cond.i.6, %cond.false15.i.6 ], [ 5, %cond.false12.i.6 ]
  %429 = bitcast float %mul183.6 to i32
  %shr.i.6 = lshr i32 %429, 28
  %and.i.6 = and i32 %shr.i.6, 8
  %or.i.6 = or i32 %cond27.i.6, %and.i.6
  %shl.6 = shl nuw nsw i32 %or.i.6, 4
  %or.6 = or i32 %or.i368.6, %shl.6
  %conv185.6 = trunc i32 %or.6 to i8
  %add187.6 = add nsw i64 %add164, 6
  %arrayidx188339.6 = getelementptr inbounds i8, i8 addrspace(1)* %cond19.v, i64 %add187.6
  store i8 %conv185.6, i8 addrspace(1)* %arrayidx188339.6, align 1, !tbaa !18
  %mul175.7 = fmul float %74, %405
  %430 = tail call float @llvm.fabs.f32(float %mul175.7) #3
  %cmp.i351.7 = fcmp ugt float %430, 2.500000e-01
  br i1 %cmp.i351.7, label %cond.false.i353.7, label %_Z5pack4f.exit369.7, !decision.origin !905

cond.false.i353.7:                                ; preds = %_Z5pack4f.exit.6
  %cmp1.i352.7 = fcmp olt float %430, 7.500000e-01
  br i1 %cmp1.i352.7, label %_Z5pack4f.exit369.7, label %cond.false3.i355.7, !decision.origin !906

cond.false3.i355.7:                               ; preds = %cond.false.i353.7
  %cmp4.i354.7 = fcmp ugt float %430, 1.250000e+00
  br i1 %cmp4.i354.7, label %cond.false6.i357.7, label %_Z5pack4f.exit369.7, !decision.origin !907

cond.false6.i357.7:                               ; preds = %cond.false3.i355.7
  %cmp7.i356.7 = fcmp olt float %430, 1.750000e+00
  br i1 %cmp7.i356.7, label %_Z5pack4f.exit369.7, label %cond.false9.i359.7, !decision.origin !908

cond.false9.i359.7:                               ; preds = %cond.false6.i357.7
  %cmp10.i358.7 = fcmp ugt float %430, 2.500000e+00
  br i1 %cmp10.i358.7, label %cond.false12.i361.7, label %_Z5pack4f.exit369.7, !decision.origin !909

cond.false12.i361.7:                              ; preds = %cond.false9.i359.7
  %cmp13.i360.7 = fcmp olt float %430, 3.500000e+00
  br i1 %cmp13.i360.7, label %_Z5pack4f.exit369.7, label %cond.false15.i364.7, !decision.origin !910

cond.false15.i364.7:                              ; preds = %cond.false12.i361.7
  %cmp16.i362.7 = fcmp ole float %430, 5.000000e+00
  %cond.i363.7 = select i1 %cmp16.i362.7, i32 6, i32 7
  br label %_Z5pack4f.exit369.7, !decision.origin !911

_Z5pack4f.exit369.7:                              ; preds = %cond.false15.i364.7, %cond.false12.i361.7, %cond.false9.i359.7, %cond.false6.i357.7, %cond.false3.i355.7, %cond.false.i353.7, %_Z5pack4f.exit.6
  %cond27.i365.7 = phi i32 [ 0, %_Z5pack4f.exit.6 ], [ 1, %cond.false.i353.7 ], [ 2, %cond.false3.i355.7 ], [ 3, %cond.false6.i357.7 ], [ 4, %cond.false9.i359.7 ], [ %cond.i363.7, %cond.false15.i364.7 ], [ 5, %cond.false12.i361.7 ]
  %431 = bitcast float %mul175.7 to i32
  %shr.i366.7 = lshr i32 %431, 28
  %and.i367.7 = and i32 %shr.i366.7, 8
  %or.i368.7 = or i32 %cond27.i365.7, %and.i367.7
  %mul183.7 = fmul float %77, %405
  %432 = tail call float @llvm.fabs.f32(float %mul183.7) #3
  %cmp.i.7 = fcmp ugt float %432, 2.500000e-01
  br i1 %cmp.i.7, label %cond.false.i.7, label %_Z5pack4f.exit.7, !decision.origin !912

cond.false.i.7:                                   ; preds = %_Z5pack4f.exit369.7
  %cmp1.i.7 = fcmp olt float %432, 7.500000e-01
  br i1 %cmp1.i.7, label %_Z5pack4f.exit.7, label %cond.false3.i.7, !decision.origin !913

cond.false3.i.7:                                  ; preds = %cond.false.i.7
  %cmp4.i.7 = fcmp ugt float %432, 1.250000e+00
  br i1 %cmp4.i.7, label %cond.false6.i.7, label %_Z5pack4f.exit.7, !decision.origin !914

cond.false6.i.7:                                  ; preds = %cond.false3.i.7
  %cmp7.i.7 = fcmp olt float %432, 1.750000e+00
  br i1 %cmp7.i.7, label %_Z5pack4f.exit.7, label %cond.false9.i.7, !decision.origin !915

cond.false9.i.7:                                  ; preds = %cond.false6.i.7
  %cmp10.i.7 = fcmp ugt float %432, 2.500000e+00
  br i1 %cmp10.i.7, label %cond.false12.i.7, label %_Z5pack4f.exit.7, !decision.origin !916

cond.false12.i.7:                                 ; preds = %cond.false9.i.7
  %cmp13.i.7 = fcmp olt float %432, 3.500000e+00
  br i1 %cmp13.i.7, label %_Z5pack4f.exit.7, label %cond.false15.i.7, !decision.origin !917

cond.false15.i.7:                                 ; preds = %cond.false12.i.7
  %cmp16.i.7 = fcmp ole float %432, 5.000000e+00
  %cond.i.7 = select i1 %cmp16.i.7, i32 6, i32 7
  br label %_Z5pack4f.exit.7, !decision.origin !918

_Z5pack4f.exit.7:                                 ; preds = %cond.false15.i.7, %cond.false12.i.7, %cond.false9.i.7, %cond.false6.i.7, %cond.false3.i.7, %cond.false.i.7, %_Z5pack4f.exit369.7
  %cond27.i.7 = phi i32 [ 0, %_Z5pack4f.exit369.7 ], [ 1, %cond.false.i.7 ], [ 2, %cond.false3.i.7 ], [ 3, %cond.false6.i.7 ], [ 4, %cond.false9.i.7 ], [ %cond.i.7, %cond.false15.i.7 ], [ 5, %cond.false12.i.7 ]
  %433 = bitcast float %mul183.7 to i32
  %shr.i.7 = lshr i32 %433, 28
  %and.i.7 = and i32 %shr.i.7, 8
  %or.i.7 = or i32 %cond27.i.7, %and.i.7
  %shl.7 = shl nuw nsw i32 %or.i.7, 4
  %or.7 = or i32 %or.i368.7, %shl.7
  %conv185.7 = trunc i32 %or.7 to i8
  %add187.7 = add nsw i64 %add164, 7
  %arrayidx188339.7 = getelementptr inbounds i8, i8 addrspace(1)* %cond19.v, i64 %add187.7
  store i8 %conv185.7, i8 addrspace(1)* %arrayidx188339.7, align 1, !tbaa !18
  br i1 %tobool.not, label %if.end204, label %if.then193, !decision.origin !919

merged.bb:                                        ; preds = %if.else.7
  %merged.select = select i1 %cmp.i43, float 5.000000e-01, float 0.000000e+00
  br label %quant_decide.exit
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
!9 = !{!"cache_eval:%entry"}
!10 = !{i32 0, i32 1024}
!11 = !{!"cache_eval:%if.end"}
!12 = !{!"cache_eval:%for.body"}
!13 = !{!"cache_eval:%for.body34.lr.ph"}
!14 = !{!"cache_eval:%for.cond.cleanup33"}
!15 = !{!16, !16, i64 0}
!16 = !{!"short", !7, i64 0}
!17 = !{!"cache_eval:%for.body34"}
!18 = !{!7, !7, i64 0}
!19 = !{!"cache_eval:%_Z4enc8f.exit.thread396"}
!20 = !{!"cache_eval:%_Z4enc8f.exit.thread"}
!21 = !{!"cache_eval:%if.end9.i"}
!22 = !{!"cache_eval:%cond.true.i69.i"}
!23 = !{!"cache_eval:%cond.false.i72.i"}
!24 = !{!"cache_eval:%_Z4dec8i.exit74.i"}
!25 = !{!"cache_eval:%cond.true.i56.i"}
!26 = !{!"cache_eval:%cond.false.i59.i"}
!27 = !{!"cache_eval:%_Z4dec8i.exit61.i"}
!28 = !{!"cache_eval:%cond.false.i384"}
!29 = !{!"cache_eval:%cond.false18.i"}
!30 = !{!"cache_eval:%_Z4enc8f.exit"}
!31 = !{!"cache_eval:%cond.true.i"}
!32 = !{!"cache_eval:%cond.false.i377"}
!33 = !{!"cache_eval:%_Z4dec8i.exit"}
!34 = !{!"cache_eval:%cond.end75.thread"}
!35 = !{!"cache_eval:%cond.end75"}
!36 = !{!"cache_eval:%cond.false.i353"}
!37 = !{!"cache_eval:%cond.false3.i355"}
!38 = !{!"cache_eval:%cond.false6.i357"}
!39 = !{!"cache_eval:%cond.false9.i359"}
!40 = !{!"cache_eval:%cond.false12.i361"}
!41 = !{!"cache_eval:%cond.false15.i364"}
!42 = !{!"cache_eval:%_Z5pack4f.exit369"}
!43 = !{!"cache_eval:%cond.false.i"}
!44 = !{!"cache_eval:%cond.false3.i"}
!45 = !{!"cache_eval:%cond.false6.i"}
!46 = !{!"cache_eval:%cond.false9.i"}
!47 = !{!"cache_eval:%cond.false12.i"}
!48 = !{!"cache_eval:%cond.false15.i"}
!49 = !{!"cache_eval:%_Z5pack4f.exit"}
!50 = !{!"cache_eval:%if.then193"}
!51 = !{!"cache_eval:%if.end204"}
!52 = !{!"cache_eval:%cleanup"}
!53 = !{!"cache_eval:%_Z4dec8i.exit.i.2"}
!54 = !{!"cache_eval:%cond.true.i.i.3"}
!55 = !{!"cache_eval:%cond.false.i.i.3"}
!56 = !{!"cache_eval:%_Z4dec8i.exit.i.3"}
!57 = !{!"cache_eval:%cond.true.i.i.4"}
!58 = !{!"cache_eval:%cond.false.i.i.4"}
!59 = !{!"cache_eval:%_Z4dec8i.exit.i.4"}
!60 = !{!"cache_eval:%cond.true.i.i.5"}
!61 = !{!"cache_eval:%cond.false.i.i.5"}
!62 = !{!"cache_eval:%_Z4dec8i.exit.i.5"}
!63 = !{!"cache_eval:%cond.true.i.i.6"}
!64 = !{!"cache_eval:%cond.false.i.i.6"}
!65 = !{!"cache_eval:%_Z4dec8i.exit.i.6"}
!66 = !{}
!67 = !{!"cache_eval:%if.else4.i"}
!68 = !{!"cache_eval:%if.else8.i"}
!69 = !{!"cache_eval:%if.else12.i"}
!70 = !{!"cache_eval:%if.else16.i"}
!71 = !{!"cache_eval:%if.end29.i"}
!72 = !{!"D13", i32 7, i32 7}
!73 = !{!"cache_eval:%quant_decide.exit"}
!74 = !{!"cache_eval:%if.then.i709"}
!75 = !{!"D14", i32 0, i32 0}
!76 = !{!"cache_eval:%if.else.i711"}
!77 = !{!"cache_eval:%if.then3.i712"}
!78 = !{!"D14", i32 1, i32 1}
!79 = !{!"cache_eval:%if.else4.i714"}
!80 = !{!"cache_eval:%if.then7.i715"}
!81 = !{!"D14", i32 2, i32 2}
!82 = !{!"cache_eval:%if.else8.i717"}
!83 = !{!"cache_eval:%if.then11.i718"}
!84 = !{!"D14", i32 3, i32 3}
!85 = !{!"cache_eval:%if.else12.i720"}
!86 = !{!"cache_eval:%if.then15.i721"}
!87 = !{!"D14", i32 4, i32 4}
!88 = !{!"cache_eval:%if.else16.i723"}
!89 = !{!"cache_eval:%if.then19.i724"}
!90 = !{!"D14", i32 5, i32 5}
!91 = !{!"cache_eval:%if.else20.i726"}
!92 = !{!"cache_eval:%if.then23.i727"}
!93 = !{!"D14", i32 6, i32 6}
!94 = !{!"cache_eval:%if.end29.i728"}
!95 = !{!"D14", i32 7, i32 7}
!96 = !{!"cache_eval:%quant_decide.exit729"}
!97 = !{!"cache_eval:%if.then.i687"}
!98 = !{!"D15", i32 0, i32 0}
!99 = !{!"cache_eval:%if.else.i689"}
!100 = !{!"cache_eval:%if.then3.i690"}
!101 = !{!"D15", i32 1, i32 1}
!102 = !{!"cache_eval:%if.else4.i692"}
!103 = !{!"cache_eval:%if.then7.i693"}
!104 = !{!"D15", i32 2, i32 2}
!105 = !{!"cache_eval:%if.else8.i695"}
!106 = !{!"cache_eval:%if.then11.i696"}
!107 = !{!"D15", i32 3, i32 3}
!108 = !{!"cache_eval:%if.else12.i698"}
!109 = !{!"cache_eval:%if.then15.i699"}
!110 = !{!"D15", i32 4, i32 4}
!111 = !{!"cache_eval:%if.else16.i701"}
!112 = !{!"cache_eval:%if.then19.i702"}
!113 = !{!"D15", i32 5, i32 5}
!114 = !{!"cache_eval:%if.else20.i704"}
!115 = !{!"cache_eval:%if.then23.i705"}
!116 = !{!"D15", i32 6, i32 6}
!117 = !{!"cache_eval:%if.end29.i706"}
!118 = !{!"D15", i32 7, i32 7}
!119 = !{!"cache_eval:%quant_decide.exit707"}
!120 = !{!"cache_eval:%if.then.i665"}
!121 = !{!"D16", i32 0, i32 0}
!122 = !{!"cache_eval:%if.else.i667"}
!123 = !{!"cache_eval:%if.then3.i668"}
!124 = !{!"D16", i32 1, i32 1}
!125 = !{!"cache_eval:%if.else4.i670"}
!126 = !{!"cache_eval:%if.then7.i671"}
!127 = !{!"D16", i32 2, i32 2}
!128 = !{!"cache_eval:%if.else8.i673"}
!129 = !{!"cache_eval:%if.then11.i674"}
!130 = !{!"D16", i32 3, i32 3}
!131 = !{!"cache_eval:%if.else12.i676"}
!132 = !{!"cache_eval:%if.then15.i677"}
!133 = !{!"D16", i32 4, i32 4}
!134 = !{!"cache_eval:%if.else16.i679"}
!135 = !{!"cache_eval:%if.then19.i680"}
!136 = !{!"D16", i32 5, i32 5}
!137 = !{!"cache_eval:%if.else20.i682"}
!138 = !{!"cache_eval:%if.then23.i683"}
!139 = !{!"D16", i32 6, i32 6}
!140 = !{!"cache_eval:%if.end29.i684"}
!141 = !{!"D16", i32 7, i32 7}
!142 = !{!"cache_eval:%quant_decide.exit685"}
!143 = !{!"cache_eval:%if.then.i643"}
!144 = !{!"D17", i32 0, i32 0}
!145 = !{!"cache_eval:%if.else.i645"}
!146 = !{!"cache_eval:%if.then3.i646"}
!147 = !{!"D17", i32 1, i32 1}
!148 = !{!"cache_eval:%if.else4.i648"}
!149 = !{!"cache_eval:%if.then7.i649"}
!150 = !{!"D17", i32 2, i32 2}
!151 = !{!"cache_eval:%if.else8.i651"}
!152 = !{!"cache_eval:%if.then11.i652"}
!153 = !{!"D17", i32 3, i32 3}
!154 = !{!"cache_eval:%if.else12.i654"}
!155 = !{!"cache_eval:%if.then15.i655"}
!156 = !{!"D17", i32 4, i32 4}
!157 = !{!"cache_eval:%if.else16.i657"}
!158 = !{!"cache_eval:%if.then19.i658"}
!159 = !{!"D17", i32 5, i32 5}
!160 = !{!"cache_eval:%if.else20.i660"}
!161 = !{!"cache_eval:%if.then23.i661"}
!162 = !{!"D17", i32 6, i32 6}
!163 = !{!"cache_eval:%if.end29.i662"}
!164 = !{!"D17", i32 7, i32 7}
!165 = !{!"cache_eval:%quant_decide.exit663"}
!166 = !{!"cache_eval:%if.then.i621"}
!167 = !{!"D18", i32 0, i32 0}
!168 = !{!"cache_eval:%if.else.i623"}
!169 = !{!"cache_eval:%if.then3.i624"}
!170 = !{!"D18", i32 1, i32 1}
!171 = !{!"cache_eval:%if.else4.i626"}
!172 = !{!"cache_eval:%if.then7.i627"}
!173 = !{!"D18", i32 2, i32 2}
!174 = !{!"cache_eval:%if.else8.i629"}
!175 = !{!"cache_eval:%if.then11.i630"}
!176 = !{!"D18", i32 3, i32 3}
!177 = !{!"cache_eval:%if.else12.i632"}
!178 = !{!"cache_eval:%if.then15.i633"}
!179 = !{!"D18", i32 4, i32 4}
!180 = !{!"cache_eval:%if.else16.i635"}
!181 = !{!"cache_eval:%if.then19.i636"}
!182 = !{!"D18", i32 5, i32 5}
!183 = !{!"cache_eval:%if.else20.i638"}
!184 = !{!"cache_eval:%if.then23.i639"}
!185 = !{!"D18", i32 6, i32 6}
!186 = !{!"cache_eval:%if.end29.i640"}
!187 = !{!"D18", i32 7, i32 7}
!188 = !{!"cache_eval:%quant_decide.exit641"}
!189 = !{!"cache_eval:%if.then.i599"}
!190 = !{!"D19", i32 0, i32 0}
!191 = !{!"cache_eval:%if.else.i601"}
!192 = !{!"cache_eval:%if.then3.i602"}
!193 = !{!"D19", i32 1, i32 1}
!194 = !{!"cache_eval:%if.else4.i604"}
!195 = !{!"cache_eval:%if.then7.i605"}
!196 = !{!"D19", i32 2, i32 2}
!197 = !{!"cache_eval:%if.else8.i607"}
!198 = !{!"cache_eval:%if.then11.i608"}
!199 = !{!"D19", i32 3, i32 3}
!200 = !{!"cache_eval:%if.else12.i610"}
!201 = !{!"cache_eval:%if.then15.i611"}
!202 = !{!"D19", i32 4, i32 4}
!203 = !{!"cache_eval:%if.else16.i613"}
!204 = !{!"cache_eval:%if.then19.i614"}
!205 = !{!"D19", i32 5, i32 5}
!206 = !{!"cache_eval:%if.else20.i616"}
!207 = !{!"cache_eval:%if.then23.i617"}
!208 = !{!"D19", i32 6, i32 6}
!209 = !{!"cache_eval:%if.end29.i618"}
!210 = !{!"D19", i32 7, i32 7}
!211 = !{!"cache_eval:%quant_decide.exit619"}
!212 = !{!"cache_eval:%if.then.i577"}
!213 = !{!"D20", i32 0, i32 0}
!214 = !{!"cache_eval:%if.else.i579"}
!215 = !{!"cache_eval:%if.then3.i580"}
!216 = !{!"D20", i32 1, i32 1}
!217 = !{!"cache_eval:%if.else4.i582"}
!218 = !{!"cache_eval:%if.then7.i583"}
!219 = !{!"D20", i32 2, i32 2}
!220 = !{!"cache_eval:%if.else8.i585"}
!221 = !{!"cache_eval:%if.then11.i586"}
!222 = !{!"D20", i32 3, i32 3}
!223 = !{!"cache_eval:%if.else12.i588"}
!224 = !{!"cache_eval:%if.then15.i589"}
!225 = !{!"D20", i32 4, i32 4}
!226 = !{!"cache_eval:%if.else16.i591"}
!227 = !{!"cache_eval:%if.then19.i592"}
!228 = !{!"D20", i32 5, i32 5}
!229 = !{!"cache_eval:%if.else20.i594"}
!230 = !{!"cache_eval:%if.then23.i595"}
!231 = !{!"D20", i32 6, i32 6}
!232 = !{!"cache_eval:%if.end29.i596"}
!233 = !{!"D20", i32 7, i32 7}
!234 = !{!"cache_eval:%quant_decide.exit597"}
!235 = !{!"cache_eval:%if.then.i555"}
!236 = !{!"D21", i32 0, i32 0}
!237 = !{!"cache_eval:%if.else.i557"}
!238 = !{!"cache_eval:%if.then3.i558"}
!239 = !{!"D21", i32 1, i32 1}
!240 = !{!"cache_eval:%if.else4.i560"}
!241 = !{!"cache_eval:%if.then7.i561"}
!242 = !{!"D21", i32 2, i32 2}
!243 = !{!"cache_eval:%if.else8.i563"}
!244 = !{!"cache_eval:%if.then11.i564"}
!245 = !{!"D21", i32 3, i32 3}
!246 = !{!"cache_eval:%if.else12.i566"}
!247 = !{!"cache_eval:%if.then15.i567"}
!248 = !{!"D21", i32 4, i32 4}
!249 = !{!"cache_eval:%if.else16.i569"}
!250 = !{!"cache_eval:%if.then19.i570"}
!251 = !{!"D21", i32 5, i32 5}
!252 = !{!"cache_eval:%if.else20.i572"}
!253 = !{!"cache_eval:%if.then23.i573"}
!254 = !{!"D21", i32 6, i32 6}
!255 = !{!"cache_eval:%if.end29.i574"}
!256 = !{!"D21", i32 7, i32 7}
!257 = !{!"cache_eval:%quant_decide.exit575"}
!258 = !{!"cache_eval:%if.then.i533"}
!259 = !{!"D22", i32 0, i32 0}
!260 = !{!"cache_eval:%if.else.i535"}
!261 = !{!"cache_eval:%if.then3.i536"}
!262 = !{!"D22", i32 1, i32 1}
!263 = !{!"cache_eval:%if.else4.i538"}
!264 = !{!"cache_eval:%if.then7.i539"}
!265 = !{!"D22", i32 2, i32 2}
!266 = !{!"cache_eval:%if.else8.i541"}
!267 = !{!"cache_eval:%if.then11.i542"}
!268 = !{!"D22", i32 3, i32 3}
!269 = !{!"cache_eval:%if.else12.i544"}
!270 = !{!"cache_eval:%if.then15.i545"}
!271 = !{!"D22", i32 4, i32 4}
!272 = !{!"cache_eval:%if.else16.i547"}
!273 = !{!"cache_eval:%if.then19.i548"}
!274 = !{!"D22", i32 5, i32 5}
!275 = !{!"cache_eval:%if.else20.i550"}
!276 = !{!"cache_eval:%if.then23.i551"}
!277 = !{!"D22", i32 6, i32 6}
!278 = !{!"cache_eval:%if.end29.i552"}
!279 = !{!"D22", i32 7, i32 7}
!280 = !{!"cache_eval:%quant_decide.exit553"}
!281 = !{!"cache_eval:%if.then.i511"}
!282 = !{!"D23", i32 0, i32 0}
!283 = !{!"cache_eval:%if.else.i513"}
!284 = !{!"cache_eval:%if.then3.i514"}
!285 = !{!"D23", i32 1, i32 1}
!286 = !{!"cache_eval:%if.else4.i516"}
!287 = !{!"cache_eval:%if.then7.i517"}
!288 = !{!"D23", i32 2, i32 2}
!289 = !{!"cache_eval:%if.else8.i519"}
!290 = !{!"cache_eval:%if.then11.i520"}
!291 = !{!"D23", i32 3, i32 3}
!292 = !{!"cache_eval:%if.else12.i522"}
!293 = !{!"cache_eval:%if.then15.i523"}
!294 = !{!"D23", i32 4, i32 4}
!295 = !{!"cache_eval:%if.else16.i525"}
!296 = !{!"cache_eval:%if.then19.i526"}
!297 = !{!"D23", i32 5, i32 5}
!298 = !{!"cache_eval:%if.else20.i528"}
!299 = !{!"cache_eval:%if.then23.i529"}
!300 = !{!"D23", i32 6, i32 6}
!301 = !{!"cache_eval:%if.end29.i530"}
!302 = !{!"D23", i32 7, i32 7}
!303 = !{!"cache_eval:%quant_decide.exit531"}
!304 = !{!"cache_eval:%if.then.i489"}
!305 = !{!"D24", i32 0, i32 0}
!306 = !{!"cache_eval:%if.else.i491"}
!307 = !{!"cache_eval:%if.then3.i492"}
!308 = !{!"D24", i32 1, i32 1}
!309 = !{!"cache_eval:%if.else4.i494"}
!310 = !{!"cache_eval:%if.then7.i495"}
!311 = !{!"D24", i32 2, i32 2}
!312 = !{!"cache_eval:%if.else8.i497"}
!313 = !{!"cache_eval:%if.then11.i498"}
!314 = !{!"D24", i32 3, i32 3}
!315 = !{!"cache_eval:%if.else12.i500"}
!316 = !{!"cache_eval:%if.then15.i501"}
!317 = !{!"D24", i32 4, i32 4}
!318 = !{!"cache_eval:%if.else16.i503"}
!319 = !{!"cache_eval:%if.then19.i504"}
!320 = !{!"D24", i32 5, i32 5}
!321 = !{!"cache_eval:%if.else20.i506"}
!322 = !{!"cache_eval:%if.then23.i507"}
!323 = !{!"D24", i32 6, i32 6}
!324 = !{!"cache_eval:%if.end29.i508"}
!325 = !{!"D24", i32 7, i32 7}
!326 = !{!"cache_eval:%quant_decide.exit509"}
!327 = !{!"cache_eval:%if.then.i467"}
!328 = !{!"D25", i32 0, i32 0}
!329 = !{!"cache_eval:%if.else.i469"}
!330 = !{!"cache_eval:%if.then3.i470"}
!331 = !{!"D25", i32 1, i32 1}
!332 = !{!"cache_eval:%if.else4.i472"}
!333 = !{!"cache_eval:%if.then7.i473"}
!334 = !{!"D25", i32 2, i32 2}
!335 = !{!"cache_eval:%if.else8.i475"}
!336 = !{!"cache_eval:%if.then11.i476"}
!337 = !{!"D25", i32 3, i32 3}
!338 = !{!"cache_eval:%if.else12.i478"}
!339 = !{!"cache_eval:%if.then15.i479"}
!340 = !{!"D25", i32 4, i32 4}
!341 = !{!"cache_eval:%if.else16.i481"}
!342 = !{!"cache_eval:%if.then19.i482"}
!343 = !{!"D25", i32 5, i32 5}
!344 = !{!"cache_eval:%if.else20.i484"}
!345 = !{!"cache_eval:%if.then23.i485"}
!346 = !{!"D25", i32 6, i32 6}
!347 = !{!"cache_eval:%if.end29.i486"}
!348 = !{!"D25", i32 7, i32 7}
!349 = !{!"cache_eval:%quant_decide.exit487"}
!350 = !{!"cache_eval:%if.then.i445"}
!351 = !{!"D26", i32 0, i32 0}
!352 = !{!"cache_eval:%if.else.i447"}
!353 = !{!"cache_eval:%if.then3.i448"}
!354 = !{!"D26", i32 1, i32 1}
!355 = !{!"cache_eval:%if.else4.i450"}
!356 = !{!"cache_eval:%if.then7.i451"}
!357 = !{!"D26", i32 2, i32 2}
!358 = !{!"cache_eval:%if.else8.i453"}
!359 = !{!"cache_eval:%if.then11.i454"}
!360 = !{!"D26", i32 3, i32 3}
!361 = !{!"cache_eval:%if.else12.i456"}
!362 = !{!"cache_eval:%if.then15.i457"}
!363 = !{!"D26", i32 4, i32 4}
!364 = !{!"cache_eval:%if.else16.i459"}
!365 = !{!"cache_eval:%if.then19.i460"}
!366 = !{!"D26", i32 5, i32 5}
!367 = !{!"cache_eval:%if.else20.i462"}
!368 = !{!"cache_eval:%if.then23.i463"}
!369 = !{!"D26", i32 6, i32 6}
!370 = !{!"cache_eval:%if.end29.i464"}
!371 = !{!"D26", i32 7, i32 7}
!372 = !{!"cache_eval:%quant_decide.exit465"}
!373 = !{!"cache_eval:%if.then.i423"}
!374 = !{!"D27", i32 0, i32 0}
!375 = !{!"cache_eval:%if.else.i425"}
!376 = !{!"cache_eval:%if.then3.i426"}
!377 = !{!"D27", i32 1, i32 1}
!378 = !{!"cache_eval:%if.else4.i428"}
!379 = !{!"cache_eval:%if.then7.i429"}
!380 = !{!"D27", i32 2, i32 2}
!381 = !{!"cache_eval:%if.else8.i431"}
!382 = !{!"cache_eval:%if.then11.i432"}
!383 = !{!"D27", i32 3, i32 3}
!384 = !{!"cache_eval:%if.else12.i434"}
!385 = !{!"cache_eval:%if.then15.i435"}
!386 = !{!"D27", i32 4, i32 4}
!387 = !{!"cache_eval:%if.else16.i437"}
!388 = !{!"cache_eval:%if.then19.i438"}
!389 = !{!"D27", i32 5, i32 5}
!390 = !{!"cache_eval:%if.else20.i440"}
!391 = !{!"cache_eval:%if.then23.i441"}
!392 = !{!"D27", i32 6, i32 6}
!393 = !{!"cache_eval:%if.end29.i442"}
!394 = !{!"D27", i32 7, i32 7}
!395 = !{!"cache_eval:%quant_decide.exit443"}
!396 = !{!"cache_eval:%if.then.i401"}
!397 = !{!"D28", i32 0, i32 0}
!398 = !{!"cache_eval:%if.else.i403"}
!399 = !{!"cache_eval:%if.then3.i404"}
!400 = !{!"D28", i32 1, i32 1}
!401 = !{!"cache_eval:%if.else4.i406"}
!402 = !{!"cache_eval:%if.then7.i407"}
!403 = !{!"D28", i32 2, i32 2}
!404 = !{!"cache_eval:%if.else8.i409"}
!405 = !{!"cache_eval:%if.then11.i410"}
!406 = !{!"D28", i32 3, i32 3}
!407 = !{!"cache_eval:%if.else12.i412"}
!408 = !{!"cache_eval:%if.then15.i413"}
!409 = !{!"D28", i32 4, i32 4}
!410 = !{!"cache_eval:%if.else16.i415"}
!411 = !{!"cache_eval:%if.then19.i416"}
!412 = !{!"D28", i32 5, i32 5}
!413 = !{!"cache_eval:%if.else20.i418"}
!414 = !{!"cache_eval:%if.then23.i419"}
!415 = !{!"D28", i32 6, i32 6}
!416 = !{!"cache_eval:%if.end29.i420"}
!417 = !{!"D28", i32 7, i32 7}
!418 = !{!"cache_eval:%quant_decide.exit421"}
!419 = !{!"cache_eval:%if.then97.7"}
!420 = !{!"cache_eval:%for.inc138.7"}
!421 = !{!"cache_eval:%_Z4enc8f.exit.thread396.1"}
!422 = !{!"cache_eval:%_Z4dec8i.exit.i.2.1"}
!423 = !{!"cache_eval:%cond.true.i.i.3.1"}
!424 = !{!"cache_eval:%cond.false.i.i.3.1"}
!425 = !{!"cache_eval:%_Z4dec8i.exit.i.3.1"}
!426 = !{!"cache_eval:%cond.true.i.i.4.1"}
!427 = !{!"cache_eval:%cond.false.i.i.4.1"}
!428 = !{!"cache_eval:%_Z4dec8i.exit.i.4.1"}
!429 = !{!"cache_eval:%cond.true.i.i.5.1"}
!430 = !{!"cache_eval:%cond.false.i.i.5.1"}
!431 = !{!"cache_eval:%_Z4dec8i.exit.i.5.1"}
!432 = !{!"cache_eval:%cond.true.i.i.6.1"}
!433 = !{!"cache_eval:%cond.false.i.i.6.1"}
!434 = !{!"cache_eval:%_Z4dec8i.exit.i.6.1"}
!435 = !{!"cache_eval:%if.end9.i.1"}
!436 = !{!"cache_eval:%cond.true.i69.i.1"}
!437 = !{!"cache_eval:%cond.false.i72.i.1"}
!438 = !{!"cache_eval:%_Z4dec8i.exit74.i.1"}
!439 = !{!"cache_eval:%cond.true.i56.i.1"}
!440 = !{!"cache_eval:%cond.false.i59.i.1"}
!441 = !{!"cache_eval:%_Z4dec8i.exit61.i.1"}
!442 = !{!"cache_eval:%cond.false.i384.1"}
!443 = !{!"cache_eval:%cond.false18.i.1"}
!444 = !{!"cache_eval:%_Z4enc8f.exit.1"}
!445 = !{!"cache_eval:%cond.true.i.1"}
!446 = !{!"cache_eval:%_Z4enc8f.exit.thread.1"}
!447 = !{!"cache_eval:%cond.false.i377.1"}
!448 = !{!"cache_eval:%_Z4dec8i.exit.1"}
!449 = !{!"cache_eval:%cond.end75.1.thread"}
!450 = !{!"cache_eval:%cond.end75.1"}
!451 = !{!"cache_eval:%if.else.7.1"}
!452 = !{!"cache_eval:%if.then.i379"}
!453 = !{!"D38", i32 0, i32 0}
!454 = !{!"cache_eval:%if.else.i381"}
!455 = !{!"cache_eval:%if.then3.i382"}
!456 = !{!"D38", i32 1, i32 1}
!457 = !{!"cache_eval:%if.else4.i384"}
!458 = !{!"cache_eval:%if.then7.i385"}
!459 = !{!"D38", i32 2, i32 2}
!460 = !{!"cache_eval:%if.else8.i387"}
!461 = !{!"cache_eval:%if.then11.i388"}
!462 = !{!"D38", i32 3, i32 3}
!463 = !{!"cache_eval:%if.else12.i390"}
!464 = !{!"cache_eval:%if.then15.i391"}
!465 = !{!"D38", i32 4, i32 4}
!466 = !{!"cache_eval:%if.else16.i393"}
!467 = !{!"cache_eval:%if.then19.i394"}
!468 = !{!"D38", i32 5, i32 5}
!469 = !{!"cache_eval:%if.else20.i396"}
!470 = !{!"cache_eval:%if.then23.i397"}
!471 = !{!"D38", i32 6, i32 6}
!472 = !{!"cache_eval:%if.end29.i398"}
!473 = !{!"D38", i32 7, i32 7}
!474 = !{!"cache_eval:%quant_decide.exit399"}
!475 = !{!"cache_eval:%if.then.i357"}
!476 = !{!"D39", i32 0, i32 0}
!477 = !{!"cache_eval:%if.else.i359"}
!478 = !{!"cache_eval:%if.then3.i360"}
!479 = !{!"D39", i32 1, i32 1}
!480 = !{!"cache_eval:%if.else4.i362"}
!481 = !{!"cache_eval:%if.then7.i363"}
!482 = !{!"D39", i32 2, i32 2}
!483 = !{!"cache_eval:%if.else8.i365"}
!484 = !{!"cache_eval:%if.then11.i366"}
!485 = !{!"D39", i32 3, i32 3}
!486 = !{!"cache_eval:%if.else12.i368"}
!487 = !{!"cache_eval:%if.then15.i369"}
!488 = !{!"D39", i32 4, i32 4}
!489 = !{!"cache_eval:%if.else16.i371"}
!490 = !{!"cache_eval:%if.then19.i372"}
!491 = !{!"D39", i32 5, i32 5}
!492 = !{!"cache_eval:%if.else20.i374"}
!493 = !{!"cache_eval:%if.then23.i375"}
!494 = !{!"D39", i32 6, i32 6}
!495 = !{!"cache_eval:%if.end29.i376"}
!496 = !{!"D39", i32 7, i32 7}
!497 = !{!"cache_eval:%quant_decide.exit377"}
!498 = !{!"cache_eval:%if.then.i335"}
!499 = !{!"D40", i32 0, i32 0}
!500 = !{!"cache_eval:%if.else.i337"}
!501 = !{!"cache_eval:%if.then3.i338"}
!502 = !{!"D40", i32 1, i32 1}
!503 = !{!"cache_eval:%if.else4.i340"}
!504 = !{!"cache_eval:%if.then7.i341"}
!505 = !{!"D40", i32 2, i32 2}
!506 = !{!"cache_eval:%if.else8.i343"}
!507 = !{!"cache_eval:%if.then11.i344"}
!508 = !{!"D40", i32 3, i32 3}
!509 = !{!"cache_eval:%if.else12.i346"}
!510 = !{!"cache_eval:%if.then15.i347"}
!511 = !{!"D40", i32 4, i32 4}
!512 = !{!"cache_eval:%if.else16.i349"}
!513 = !{!"cache_eval:%if.then19.i350"}
!514 = !{!"D40", i32 5, i32 5}
!515 = !{!"cache_eval:%if.else20.i352"}
!516 = !{!"cache_eval:%if.then23.i353"}
!517 = !{!"D40", i32 6, i32 6}
!518 = !{!"cache_eval:%if.end29.i354"}
!519 = !{!"D40", i32 7, i32 7}
!520 = !{!"cache_eval:%quant_decide.exit355"}
!521 = !{!"cache_eval:%if.then.i313"}
!522 = !{!"D41", i32 0, i32 0}
!523 = !{!"cache_eval:%if.else.i315"}
!524 = !{!"cache_eval:%if.then3.i316"}
!525 = !{!"D41", i32 1, i32 1}
!526 = !{!"cache_eval:%if.else4.i318"}
!527 = !{!"cache_eval:%if.then7.i319"}
!528 = !{!"D41", i32 2, i32 2}
!529 = !{!"cache_eval:%if.else8.i321"}
!530 = !{!"cache_eval:%if.then11.i322"}
!531 = !{!"D41", i32 3, i32 3}
!532 = !{!"cache_eval:%if.else12.i324"}
!533 = !{!"cache_eval:%if.then15.i325"}
!534 = !{!"D41", i32 4, i32 4}
!535 = !{!"cache_eval:%if.else16.i327"}
!536 = !{!"cache_eval:%if.then19.i328"}
!537 = !{!"D41", i32 5, i32 5}
!538 = !{!"cache_eval:%if.else20.i330"}
!539 = !{!"cache_eval:%if.then23.i331"}
!540 = !{!"D41", i32 6, i32 6}
!541 = !{!"cache_eval:%if.end29.i332"}
!542 = !{!"D41", i32 7, i32 7}
!543 = !{!"cache_eval:%quant_decide.exit333"}
!544 = !{!"cache_eval:%if.then.i291"}
!545 = !{!"D42", i32 0, i32 0}
!546 = !{!"cache_eval:%if.else.i293"}
!547 = !{!"cache_eval:%if.then3.i294"}
!548 = !{!"D42", i32 1, i32 1}
!549 = !{!"cache_eval:%if.else4.i296"}
!550 = !{!"cache_eval:%if.then7.i297"}
!551 = !{!"D42", i32 2, i32 2}
!552 = !{!"cache_eval:%if.else8.i299"}
!553 = !{!"cache_eval:%if.then11.i300"}
!554 = !{!"D42", i32 3, i32 3}
!555 = !{!"cache_eval:%if.else12.i302"}
!556 = !{!"cache_eval:%if.then15.i303"}
!557 = !{!"D42", i32 4, i32 4}
!558 = !{!"cache_eval:%if.else16.i305"}
!559 = !{!"cache_eval:%if.then19.i306"}
!560 = !{!"D42", i32 5, i32 5}
!561 = !{!"cache_eval:%if.else20.i308"}
!562 = !{!"cache_eval:%if.then23.i309"}
!563 = !{!"D42", i32 6, i32 6}
!564 = !{!"cache_eval:%if.end29.i310"}
!565 = !{!"D42", i32 7, i32 7}
!566 = !{!"cache_eval:%quant_decide.exit311"}
!567 = !{!"cache_eval:%if.then.i269"}
!568 = !{!"D43", i32 0, i32 0}
!569 = !{!"cache_eval:%if.else.i271"}
!570 = !{!"cache_eval:%if.then3.i272"}
!571 = !{!"D43", i32 1, i32 1}
!572 = !{!"cache_eval:%if.else4.i274"}
!573 = !{!"cache_eval:%if.then7.i275"}
!574 = !{!"D43", i32 2, i32 2}
!575 = !{!"cache_eval:%if.else8.i277"}
!576 = !{!"cache_eval:%if.then11.i278"}
!577 = !{!"D43", i32 3, i32 3}
!578 = !{!"cache_eval:%if.else12.i280"}
!579 = !{!"cache_eval:%if.then15.i281"}
!580 = !{!"D43", i32 4, i32 4}
!581 = !{!"cache_eval:%if.else16.i283"}
!582 = !{!"cache_eval:%if.then19.i284"}
!583 = !{!"D43", i32 5, i32 5}
!584 = !{!"cache_eval:%if.else20.i286"}
!585 = !{!"cache_eval:%if.then23.i287"}
!586 = !{!"D43", i32 6, i32 6}
!587 = !{!"cache_eval:%if.end29.i288"}
!588 = !{!"D43", i32 7, i32 7}
!589 = !{!"cache_eval:%quant_decide.exit289"}
!590 = !{!"cache_eval:%if.then.i247"}
!591 = !{!"D44", i32 0, i32 0}
!592 = !{!"cache_eval:%if.else.i249"}
!593 = !{!"cache_eval:%if.then3.i250"}
!594 = !{!"D44", i32 1, i32 1}
!595 = !{!"cache_eval:%if.else4.i252"}
!596 = !{!"cache_eval:%if.then7.i253"}
!597 = !{!"D44", i32 2, i32 2}
!598 = !{!"cache_eval:%if.else8.i255"}
!599 = !{!"cache_eval:%if.then11.i256"}
!600 = !{!"D44", i32 3, i32 3}
!601 = !{!"cache_eval:%if.else12.i258"}
!602 = !{!"cache_eval:%if.then15.i259"}
!603 = !{!"D44", i32 4, i32 4}
!604 = !{!"cache_eval:%if.else16.i261"}
!605 = !{!"cache_eval:%if.then19.i262"}
!606 = !{!"D44", i32 5, i32 5}
!607 = !{!"cache_eval:%if.else20.i264"}
!608 = !{!"cache_eval:%if.then23.i265"}
!609 = !{!"D44", i32 6, i32 6}
!610 = !{!"cache_eval:%if.end29.i266"}
!611 = !{!"D44", i32 7, i32 7}
!612 = !{!"cache_eval:%quant_decide.exit267"}
!613 = !{!"cache_eval:%if.then.i225"}
!614 = !{!"D45", i32 0, i32 0}
!615 = !{!"cache_eval:%if.else.i227"}
!616 = !{!"cache_eval:%if.then3.i228"}
!617 = !{!"D45", i32 1, i32 1}
!618 = !{!"cache_eval:%if.else4.i230"}
!619 = !{!"cache_eval:%if.then7.i231"}
!620 = !{!"D45", i32 2, i32 2}
!621 = !{!"cache_eval:%if.else8.i233"}
!622 = !{!"cache_eval:%if.then11.i234"}
!623 = !{!"D45", i32 3, i32 3}
!624 = !{!"cache_eval:%if.else12.i236"}
!625 = !{!"cache_eval:%if.then15.i237"}
!626 = !{!"D45", i32 4, i32 4}
!627 = !{!"cache_eval:%if.else16.i239"}
!628 = !{!"cache_eval:%if.then19.i240"}
!629 = !{!"D45", i32 5, i32 5}
!630 = !{!"cache_eval:%if.else20.i242"}
!631 = !{!"cache_eval:%if.then23.i243"}
!632 = !{!"D45", i32 6, i32 6}
!633 = !{!"cache_eval:%if.end29.i244"}
!634 = !{!"D45", i32 7, i32 7}
!635 = !{!"cache_eval:%quant_decide.exit245"}
!636 = !{!"cache_eval:%if.then.i203"}
!637 = !{!"D46", i32 0, i32 0}
!638 = !{!"cache_eval:%if.else.i205"}
!639 = !{!"cache_eval:%if.then3.i206"}
!640 = !{!"D46", i32 1, i32 1}
!641 = !{!"cache_eval:%if.else4.i208"}
!642 = !{!"cache_eval:%if.then7.i209"}
!643 = !{!"D46", i32 2, i32 2}
!644 = !{!"cache_eval:%if.else8.i211"}
!645 = !{!"cache_eval:%if.then11.i212"}
!646 = !{!"D46", i32 3, i32 3}
!647 = !{!"cache_eval:%if.else12.i214"}
!648 = !{!"cache_eval:%if.then15.i215"}
!649 = !{!"D46", i32 4, i32 4}
!650 = !{!"cache_eval:%if.else16.i217"}
!651 = !{!"cache_eval:%if.then19.i218"}
!652 = !{!"D46", i32 5, i32 5}
!653 = !{!"cache_eval:%if.else20.i220"}
!654 = !{!"cache_eval:%if.then23.i221"}
!655 = !{!"D46", i32 6, i32 6}
!656 = !{!"cache_eval:%if.end29.i222"}
!657 = !{!"D46", i32 7, i32 7}
!658 = !{!"cache_eval:%quant_decide.exit223"}
!659 = !{!"cache_eval:%if.then.i181"}
!660 = !{!"D47", i32 0, i32 0}
!661 = !{!"cache_eval:%if.else.i183"}
!662 = !{!"cache_eval:%if.then3.i184"}
!663 = !{!"D47", i32 1, i32 1}
!664 = !{!"cache_eval:%if.else4.i186"}
!665 = !{!"cache_eval:%if.then7.i187"}
!666 = !{!"D47", i32 2, i32 2}
!667 = !{!"cache_eval:%if.else8.i189"}
!668 = !{!"cache_eval:%if.then11.i190"}
!669 = !{!"D47", i32 3, i32 3}
!670 = !{!"cache_eval:%if.else12.i192"}
!671 = !{!"cache_eval:%if.then15.i193"}
!672 = !{!"D47", i32 4, i32 4}
!673 = !{!"cache_eval:%if.else16.i195"}
!674 = !{!"cache_eval:%if.then19.i196"}
!675 = !{!"D47", i32 5, i32 5}
!676 = !{!"cache_eval:%if.else20.i198"}
!677 = !{!"cache_eval:%if.then23.i199"}
!678 = !{!"D47", i32 6, i32 6}
!679 = !{!"cache_eval:%if.end29.i200"}
!680 = !{!"D47", i32 7, i32 7}
!681 = !{!"cache_eval:%quant_decide.exit201"}
!682 = !{!"cache_eval:%if.then.i159"}
!683 = !{!"D48", i32 0, i32 0}
!684 = !{!"cache_eval:%if.else.i161"}
!685 = !{!"cache_eval:%if.then3.i162"}
!686 = !{!"D48", i32 1, i32 1}
!687 = !{!"cache_eval:%if.else4.i164"}
!688 = !{!"cache_eval:%if.then7.i165"}
!689 = !{!"D48", i32 2, i32 2}
!690 = !{!"cache_eval:%if.else8.i167"}
!691 = !{!"cache_eval:%if.then11.i168"}
!692 = !{!"D48", i32 3, i32 3}
!693 = !{!"cache_eval:%if.else12.i170"}
!694 = !{!"cache_eval:%if.then15.i171"}
!695 = !{!"D48", i32 4, i32 4}
!696 = !{!"cache_eval:%if.else16.i173"}
!697 = !{!"cache_eval:%if.then19.i174"}
!698 = !{!"D48", i32 5, i32 5}
!699 = !{!"cache_eval:%if.else20.i176"}
!700 = !{!"cache_eval:%if.then23.i177"}
!701 = !{!"D48", i32 6, i32 6}
!702 = !{!"cache_eval:%if.end29.i178"}
!703 = !{!"D48", i32 7, i32 7}
!704 = !{!"cache_eval:%quant_decide.exit179"}
!705 = !{!"cache_eval:%if.then.i137"}
!706 = !{!"D49", i32 0, i32 0}
!707 = !{!"cache_eval:%if.else.i139"}
!708 = !{!"cache_eval:%if.then3.i140"}
!709 = !{!"D49", i32 1, i32 1}
!710 = !{!"cache_eval:%if.else4.i142"}
!711 = !{!"cache_eval:%if.then7.i143"}
!712 = !{!"D49", i32 2, i32 2}
!713 = !{!"cache_eval:%if.else8.i145"}
!714 = !{!"cache_eval:%if.then11.i146"}
!715 = !{!"D49", i32 3, i32 3}
!716 = !{!"cache_eval:%if.else12.i148"}
!717 = !{!"cache_eval:%if.then15.i149"}
!718 = !{!"D49", i32 4, i32 4}
!719 = !{!"cache_eval:%if.else16.i151"}
!720 = !{!"cache_eval:%if.then19.i152"}
!721 = !{!"D49", i32 5, i32 5}
!722 = !{!"cache_eval:%if.else20.i154"}
!723 = !{!"cache_eval:%if.then23.i155"}
!724 = !{!"D49", i32 6, i32 6}
!725 = !{!"cache_eval:%if.end29.i156"}
!726 = !{!"D49", i32 7, i32 7}
!727 = !{!"cache_eval:%quant_decide.exit157"}
!728 = !{!"cache_eval:%if.then.i115"}
!729 = !{!"D50", i32 0, i32 0}
!730 = !{!"cache_eval:%if.else.i117"}
!731 = !{!"cache_eval:%if.then3.i118"}
!732 = !{!"D50", i32 1, i32 1}
!733 = !{!"cache_eval:%if.else4.i120"}
!734 = !{!"cache_eval:%if.then7.i121"}
!735 = !{!"D50", i32 2, i32 2}
!736 = !{!"cache_eval:%if.else8.i123"}
!737 = !{!"cache_eval:%if.then11.i124"}
!738 = !{!"D50", i32 3, i32 3}
!739 = !{!"cache_eval:%if.else12.i126"}
!740 = !{!"cache_eval:%if.then15.i127"}
!741 = !{!"D50", i32 4, i32 4}
!742 = !{!"cache_eval:%if.else16.i129"}
!743 = !{!"cache_eval:%if.then19.i130"}
!744 = !{!"D50", i32 5, i32 5}
!745 = !{!"cache_eval:%if.else20.i132"}
!746 = !{!"cache_eval:%if.then23.i133"}
!747 = !{!"D50", i32 6, i32 6}
!748 = !{!"cache_eval:%if.end29.i134"}
!749 = !{!"D50", i32 7, i32 7}
!750 = !{!"cache_eval:%quant_decide.exit135"}
!751 = !{!"cache_eval:%if.then.i93"}
!752 = !{!"D51", i32 0, i32 0}
!753 = !{!"cache_eval:%if.else.i95"}
!754 = !{!"cache_eval:%if.then3.i96"}
!755 = !{!"D51", i32 1, i32 1}
!756 = !{!"cache_eval:%if.else4.i98"}
!757 = !{!"cache_eval:%if.then7.i99"}
!758 = !{!"D51", i32 2, i32 2}
!759 = !{!"cache_eval:%if.else8.i101"}
!760 = !{!"cache_eval:%if.then11.i102"}
!761 = !{!"D51", i32 3, i32 3}
!762 = !{!"cache_eval:%if.else12.i104"}
!763 = !{!"cache_eval:%if.then15.i105"}
!764 = !{!"D51", i32 4, i32 4}
!765 = !{!"cache_eval:%if.else16.i107"}
!766 = !{!"cache_eval:%if.then19.i108"}
!767 = !{!"D51", i32 5, i32 5}
!768 = !{!"cache_eval:%if.else20.i110"}
!769 = !{!"cache_eval:%if.then23.i111"}
!770 = !{!"D51", i32 6, i32 6}
!771 = !{!"cache_eval:%if.end29.i112"}
!772 = !{!"D51", i32 7, i32 7}
!773 = !{!"cache_eval:%quant_decide.exit113"}
!774 = !{!"cache_eval:%if.then.i71"}
!775 = !{!"D52", i32 0, i32 0}
!776 = !{!"cache_eval:%if.else.i73"}
!777 = !{!"cache_eval:%if.then3.i74"}
!778 = !{!"D52", i32 1, i32 1}
!779 = !{!"cache_eval:%if.else4.i76"}
!780 = !{!"cache_eval:%if.then7.i77"}
!781 = !{!"D52", i32 2, i32 2}
!782 = !{!"cache_eval:%if.else8.i79"}
!783 = !{!"cache_eval:%if.then11.i80"}
!784 = !{!"D52", i32 3, i32 3}
!785 = !{!"cache_eval:%if.else12.i82"}
!786 = !{!"cache_eval:%if.then15.i83"}
!787 = !{!"D52", i32 4, i32 4}
!788 = !{!"cache_eval:%if.else16.i85"}
!789 = !{!"cache_eval:%if.then19.i86"}
!790 = !{!"D52", i32 5, i32 5}
!791 = !{!"cache_eval:%if.else20.i88"}
!792 = !{!"cache_eval:%if.then23.i89"}
!793 = !{!"D52", i32 6, i32 6}
!794 = !{!"cache_eval:%if.end29.i90"}
!795 = !{!"D52", i32 7, i32 7}
!796 = !{!"cache_eval:%quant_decide.exit91"}
!797 = !{!"cache_eval:%if.then.i49"}
!798 = !{!"D53", i32 0, i32 0}
!799 = !{!"cache_eval:%if.else.i51"}
!800 = !{!"cache_eval:%if.then3.i52"}
!801 = !{!"D53", i32 1, i32 1}
!802 = !{!"cache_eval:%if.else4.i54"}
!803 = !{!"cache_eval:%if.then7.i55"}
!804 = !{!"D53", i32 2, i32 2}
!805 = !{!"cache_eval:%if.else8.i57"}
!806 = !{!"cache_eval:%if.then11.i58"}
!807 = !{!"D53", i32 3, i32 3}
!808 = !{!"cache_eval:%if.else12.i60"}
!809 = !{!"cache_eval:%if.then15.i61"}
!810 = !{!"D53", i32 4, i32 4}
!811 = !{!"cache_eval:%if.else16.i63"}
!812 = !{!"cache_eval:%if.then19.i64"}
!813 = !{!"D53", i32 5, i32 5}
!814 = !{!"cache_eval:%if.else20.i66"}
!815 = !{!"cache_eval:%if.then23.i67"}
!816 = !{!"D53", i32 6, i32 6}
!817 = !{!"cache_eval:%if.end29.i68"}
!818 = !{!"D53", i32 7, i32 7}
!819 = !{!"cache_eval:%quant_decide.exit69"}
!820 = !{!"cache_eval:%if.then97.7.1"}
!821 = !{!"cache_eval:%for.inc138.7.1"}
!822 = !{!"cache_eval:%cond.false.i353.1"}
!823 = !{!"cache_eval:%cond.false3.i355.1"}
!824 = !{!"cache_eval:%cond.false6.i357.1"}
!825 = !{!"cache_eval:%cond.false9.i359.1"}
!826 = !{!"cache_eval:%cond.false12.i361.1"}
!827 = !{!"cache_eval:%cond.false15.i364.1"}
!828 = !{!"cache_eval:%_Z5pack4f.exit369.1"}
!829 = !{!"cache_eval:%cond.false.i.1"}
!830 = !{!"cache_eval:%cond.false3.i.1"}
!831 = !{!"cache_eval:%cond.false6.i.1"}
!832 = !{!"cache_eval:%cond.false9.i.1"}
!833 = !{!"cache_eval:%cond.false12.i.1"}
!834 = !{!"cache_eval:%cond.false15.i.1"}
!835 = !{!"cache_eval:%_Z5pack4f.exit.1"}
!836 = !{!"cache_eval:%cond.false.i353.2"}
!837 = !{!"cache_eval:%cond.false3.i355.2"}
!838 = !{!"cache_eval:%cond.false6.i357.2"}
!839 = !{!"cache_eval:%cond.false9.i359.2"}
!840 = !{!"cache_eval:%cond.false12.i361.2"}
!841 = !{!"cache_eval:%cond.false15.i364.2"}
!842 = !{!"cache_eval:%_Z5pack4f.exit369.2"}
!843 = !{!"cache_eval:%cond.false.i.2"}
!844 = !{!"cache_eval:%cond.false3.i.2"}
!845 = !{!"cache_eval:%cond.false6.i.2"}
!846 = !{!"cache_eval:%cond.false9.i.2"}
!847 = !{!"cache_eval:%cond.false12.i.2"}
!848 = !{!"cache_eval:%cond.false15.i.2"}
!849 = !{!"cache_eval:%_Z5pack4f.exit.2"}
!850 = !{!"cache_eval:%cond.false.i353.3"}
!851 = !{!"cache_eval:%cond.false3.i355.3"}
!852 = !{!"cache_eval:%cond.false6.i357.3"}
!853 = !{!"cache_eval:%cond.false9.i359.3"}
!854 = !{!"cache_eval:%cond.false12.i361.3"}
!855 = !{!"cache_eval:%cond.false15.i364.3"}
!856 = !{!"cache_eval:%_Z5pack4f.exit369.3"}
!857 = !{!"cache_eval:%cond.false.i.3"}
!858 = !{!"cache_eval:%cond.false3.i.3"}
!859 = !{!"cache_eval:%cond.false6.i.3"}
!860 = !{!"cache_eval:%cond.false9.i.3"}
!861 = !{!"cache_eval:%cond.false12.i.3"}
!862 = !{!"cache_eval:%cond.false15.i.3"}
!863 = !{!"cache_eval:%_Z5pack4f.exit.3"}
!864 = !{!"cache_eval:%cond.false.i353.4"}
!865 = !{!"cache_eval:%cond.false3.i355.4"}
!866 = !{!"cache_eval:%cond.false6.i357.4"}
!867 = !{!"cache_eval:%cond.false9.i359.4"}
!868 = !{!"cache_eval:%cond.false12.i361.4"}
!869 = !{!"cache_eval:%cond.false15.i364.4"}
!870 = !{!"cache_eval:%_Z5pack4f.exit369.4"}
!871 = !{!"cache_eval:%cond.false.i.4"}
!872 = !{!"cache_eval:%cond.false3.i.4"}
!873 = !{!"cache_eval:%cond.false6.i.4"}
!874 = !{!"cache_eval:%cond.false9.i.4"}
!875 = !{!"cache_eval:%cond.false12.i.4"}
!876 = !{!"cache_eval:%cond.false15.i.4"}
!877 = !{!"cache_eval:%_Z5pack4f.exit.4"}
!878 = !{!"cache_eval:%cond.false.i353.5"}
!879 = !{!"cache_eval:%cond.false3.i355.5"}
!880 = !{!"cache_eval:%cond.false6.i357.5"}
!881 = !{!"cache_eval:%cond.false9.i359.5"}
!882 = !{!"cache_eval:%cond.false12.i361.5"}
!883 = !{!"cache_eval:%cond.false15.i364.5"}
!884 = !{!"cache_eval:%_Z5pack4f.exit369.5"}
!885 = !{!"cache_eval:%cond.false.i.5"}
!886 = !{!"cache_eval:%cond.false3.i.5"}
!887 = !{!"cache_eval:%cond.false6.i.5"}
!888 = !{!"cache_eval:%cond.false9.i.5"}
!889 = !{!"cache_eval:%cond.false12.i.5"}
!890 = !{!"cache_eval:%cond.false15.i.5"}
!891 = !{!"cache_eval:%_Z5pack4f.exit.5"}
!892 = !{!"cache_eval:%cond.false.i353.6"}
!893 = !{!"cache_eval:%cond.false3.i355.6"}
!894 = !{!"cache_eval:%cond.false6.i357.6"}
!895 = !{!"cache_eval:%cond.false9.i359.6"}
!896 = !{!"cache_eval:%cond.false12.i361.6"}
!897 = !{!"cache_eval:%cond.false15.i364.6"}
!898 = !{!"cache_eval:%_Z5pack4f.exit369.6"}
!899 = !{!"cache_eval:%cond.false.i.6"}
!900 = !{!"cache_eval:%cond.false3.i.6"}
!901 = !{!"cache_eval:%cond.false6.i.6"}
!902 = !{!"cache_eval:%cond.false9.i.6"}
!903 = !{!"cache_eval:%cond.false12.i.6"}
!904 = !{!"cache_eval:%cond.false15.i.6"}
!905 = !{!"cache_eval:%_Z5pack4f.exit.6"}
!906 = !{!"cache_eval:%cond.false.i353.7"}
!907 = !{!"cache_eval:%cond.false3.i355.7"}
!908 = !{!"cache_eval:%cond.false6.i357.7"}
!909 = !{!"cache_eval:%cond.false9.i359.7"}
!910 = !{!"cache_eval:%cond.false12.i361.7"}
!911 = !{!"cache_eval:%cond.false15.i364.7"}
!912 = !{!"cache_eval:%_Z5pack4f.exit369.7"}
!913 = !{!"cache_eval:%cond.false.i.7"}
!914 = !{!"cache_eval:%cond.false3.i.7"}
!915 = !{!"cache_eval:%cond.false6.i.7"}
!916 = !{!"cache_eval:%cond.false9.i.7"}
!917 = !{!"cache_eval:%cond.false12.i.7"}
!918 = !{!"cache_eval:%cond.false15.i.7"}
!919 = !{!"cache_eval:%_Z5pack4f.exit.7"}
