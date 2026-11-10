; ModuleID = '/home/chh/kernel-benchmark-suite/experiments/recursive-all32-greedy-20261108-v1/state-0.ll'
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
  %cmp1.i352 = fcmp olt float %411, 7.500000e-01
  br i1 %cmp1.i352, label %_Z5pack4f.exit369, label %cond.false3.i355, !decision.origin !36

cond.false3.i355:                                 ; preds = %cond.false.i353
  %cmp4.i354 = fcmp ugt float %411, 1.250000e+00
  br i1 %cmp4.i354, label %cond.false6.i357, label %_Z5pack4f.exit369, !decision.origin !37

cond.false6.i357:                                 ; preds = %cond.false3.i355
  %cmp7.i356 = fcmp olt float %411, 1.750000e+00
  br i1 %cmp7.i356, label %_Z5pack4f.exit369, label %cond.false9.i359, !decision.origin !38

cond.false9.i359:                                 ; preds = %cond.false6.i357
  %cmp10.i358 = fcmp ugt float %411, 2.500000e+00
  br i1 %cmp10.i358, label %cond.false12.i361, label %_Z5pack4f.exit369, !decision.origin !39

cond.false12.i361:                                ; preds = %cond.false9.i359
  %cmp13.i360 = fcmp olt float %411, 3.500000e+00
  br i1 %cmp13.i360, label %_Z5pack4f.exit369, label %cond.false15.i364, !decision.origin !40

cond.false15.i364:                                ; preds = %cond.false12.i361
  %cmp16.i362 = fcmp ole float %411, 5.000000e+00
  %cond.i363 = select i1 %cmp16.i362, i32 6, i32 7
  br label %_Z5pack4f.exit369, !decision.origin !41

_Z5pack4f.exit369:                                ; preds = %for.inc138.7.1, %cond.false15.i364, %cond.false12.i361, %cond.false9.i359, %cond.false6.i357, %cond.false3.i355, %cond.false.i353
  %cond27.i365 = phi i32 [ 0, %for.inc138.7.1 ], [ 1, %cond.false.i353 ], [ 2, %cond.false3.i355 ], [ 3, %cond.false6.i357 ], [ 4, %cond.false9.i359 ], [ %cond.i363, %cond.false15.i364 ], [ 5, %cond.false12.i361 ]
  %85 = bitcast float %mul175 to i32
  %shr.i366 = lshr i32 %85, 28
  %and.i367 = and i32 %shr.i366, 8
  %or.i368 = or i32 %cond27.i365, %and.i367
  %mul183 = fmul float %410, %16
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
  %mul175.1 = fmul float %410, %20
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
  %arrayidx206334 = getelementptr inbounds [2 x i8], [2 x i8] addrspace(5)* %code, i32 0, i32 %409
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
  br i1 %cmp.i43, label %if.else.i, label %decision.gate, !decision.origin !66

unify.bb:                                         ; preds = %decision.dispatch
  br label %merged.bb

if.else.i:                                        ; preds = %if.else.7
  %cmp2.i44 = fcmp olt float %101, 7.500000e-01
  br label %decision.gate

decision.gate:                                    ; preds = %if.else.i, %if.else.7
  %decision.value = phi i1 [ undef, %if.else.7 ], [ %cmp2.i44, %if.else.i ]
  %decision.was_left = phi i1 [ true, %if.else.7 ], [ false, %if.else.i ]
  %decision.take = phi i1 [ true, %if.else.7 ], [ %cmp2.i44, %if.else.i ]
  br i1 %decision.take, label %decision.dispatch, label %if.else4.i, !decision.short_gate !67

decision.dispatch:                                ; preds = %decision.gate
  br label %unify.bb, !decision.origin !68, !decision.order !69, !decision.merged_from !70

if.else4.i:                                       ; preds = %decision.gate
  %cmp6.i45 = fcmp ugt float %101, 1.250000e+00
  br i1 %cmp6.i45, label %if.else8.i, label %if.then7.i, !decision.origin !71

if.then7.i:                                       ; preds = %if.else4.i
  %102 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116) #3
  br label %quant_decide.exit, !decision.origin !72, !decision.order !73

if.else8.i:                                       ; preds = %if.else4.i
  %cmp10.i46 = fcmp olt float %101, 1.750000e+00
  br i1 %cmp10.i46, label %if.then11.i, label %if.else12.i, !decision.origin !74

if.then11.i:                                      ; preds = %if.else8.i
  %103 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116) #3
  br label %quant_decide.exit, !decision.origin !75, !decision.order !76

if.else12.i:                                      ; preds = %if.else8.i
  %cmp14.i47 = fcmp ugt float %101, 2.500000e+00
  br i1 %cmp14.i47, label %if.else16.i, label %if.then15.i, !decision.origin !77

if.then15.i:                                      ; preds = %if.else12.i
  %104 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116) #3
  br label %quant_decide.exit, !decision.origin !78, !decision.order !79

if.else16.i:                                      ; preds = %if.else12.i
  %cmp18.i = fcmp olt float %101, 3.500000e+00
  br i1 %cmp18.i, label %if.then19.i, label %if.else20.i, !decision.origin !80

if.then19.i:                                      ; preds = %if.else16.i
  %105 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116) #3
  br label %quant_decide.exit, !decision.origin !81, !decision.order !82

if.else20.i:                                      ; preds = %if.else16.i
  %cmp22.i = fcmp ugt float %101, 5.000000e+00
  br i1 %cmp22.i, label %if.end29.i, label %if.then23.i, !decision.origin !83

if.then23.i:                                      ; preds = %if.else20.i
  %106 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116) #3
  br label %quant_decide.exit, !decision.origin !84, !decision.order !85

if.end29.i:                                       ; preds = %if.else20.i
  %107 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116) #3
  br label %quant_decide.exit, !decision.origin !86, !decision.order !87

quant_decide.exit.pair.join:                      ; preds = %merged.bb
  br label %quant_decide.exit

quant_decide.exit:                                ; preds = %quant_decide.exit.pair.join, %if.end29.i, %if.then23.i, %if.then19.i, %if.then15.i, %if.then11.i, %if.then7.i
  %out.i372.0 = phi float [ %103, %if.then11.i ], [ %105, %if.then19.i ], [ %107, %if.end29.i ], [ %106, %if.then23.i ], [ %104, %if.then15.i ], [ %102, %if.then7.i ], [ %439, %quant_decide.exit.pair.join ]
  %mul118 = fmul float %cond88, %out.i372.0
  %sub = fsub float %mul118, %12
  %mul126 = fmul float %div73, %16
  %108 = tail call float @llvm.fabs.f32(float %mul126) #3
  %cmp.i708 = fcmp ugt float %108, 2.500000e-01
  br i1 %cmp.i708, label %if.else.i711, label %if.then.i709, !decision.origin !88

if.then.i709:                                     ; preds = %quant_decide.exit
  %109 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126) #3
  br label %quant_decide.exit729, !decision.origin !89, !decision.order !90

if.else.i711:                                     ; preds = %quant_decide.exit
  %cmp2.i710 = fcmp olt float %108, 7.500000e-01
  br i1 %cmp2.i710, label %if.then3.i712, label %if.else4.i714, !decision.origin !91

if.then3.i712:                                    ; preds = %if.else.i711
  %110 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126) #3
  br label %quant_decide.exit729, !decision.origin !92, !decision.order !93

if.else4.i714:                                    ; preds = %if.else.i711
  %cmp6.i713 = fcmp ugt float %108, 1.250000e+00
  br i1 %cmp6.i713, label %if.else8.i717, label %if.then7.i715, !decision.origin !94

if.then7.i715:                                    ; preds = %if.else4.i714
  %111 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126) #3
  br label %quant_decide.exit729, !decision.origin !95, !decision.order !96

if.else8.i717:                                    ; preds = %if.else4.i714
  %cmp10.i716 = fcmp olt float %108, 1.750000e+00
  br i1 %cmp10.i716, label %if.then11.i718, label %if.else12.i720, !decision.origin !97

if.then11.i718:                                   ; preds = %if.else8.i717
  %112 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126) #3
  br label %quant_decide.exit729, !decision.origin !98, !decision.order !99

if.else12.i720:                                   ; preds = %if.else8.i717
  %cmp14.i719 = fcmp ugt float %108, 2.500000e+00
  br i1 %cmp14.i719, label %if.else16.i723, label %if.then15.i721, !decision.origin !100

if.then15.i721:                                   ; preds = %if.else12.i720
  %113 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126) #3
  br label %quant_decide.exit729, !decision.origin !101, !decision.order !102

if.else16.i723:                                   ; preds = %if.else12.i720
  %cmp18.i722 = fcmp olt float %108, 3.500000e+00
  br i1 %cmp18.i722, label %if.then19.i724, label %if.else20.i726, !decision.origin !103

if.then19.i724:                                   ; preds = %if.else16.i723
  %114 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126) #3
  br label %quant_decide.exit729, !decision.origin !104, !decision.order !105

if.else20.i726:                                   ; preds = %if.else16.i723
  %cmp22.i725 = fcmp ugt float %108, 5.000000e+00
  br i1 %cmp22.i725, label %if.end29.i728, label %if.then23.i727, !decision.origin !106

if.then23.i727:                                   ; preds = %if.else20.i726
  %115 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126) #3
  br label %quant_decide.exit729, !decision.origin !107, !decision.order !108

if.end29.i728:                                    ; preds = %if.else20.i726
  %116 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126) #3
  br label %quant_decide.exit729, !decision.origin !109, !decision.order !110

quant_decide.exit729:                             ; preds = %if.end29.i728, %if.then23.i727, %if.then19.i724, %if.then15.i721, %if.then11.i718, %if.then7.i715, %if.then3.i712, %if.then.i709
  %out.i.0 = phi float [ %110, %if.then3.i712 ], [ %112, %if.then11.i718 ], [ %114, %if.then19.i724 ], [ %116, %if.end29.i728 ], [ %115, %if.then23.i727 ], [ %113, %if.then15.i721 ], [ %111, %if.then7.i715 ], [ %109, %if.then.i709 ]
  %mul128 = fmul float %cond88, %out.i.0
  %sub132 = fsub float %mul128, %16
  %mul133 = fmul float %sub, %sub
  %mul134 = fmul float %sub132, %sub132
  %add135 = fadd float %mul133, %mul134
  %e.1 = fadd float %add135, 0.000000e+00
  %mul116.1 = fmul float %div73, %20
  %117 = tail call float @llvm.fabs.f32(float %mul116.1) #3
  %cmp.i686 = fcmp ugt float %117, 2.500000e-01
  br i1 %cmp.i686, label %if.else.i689, label %if.then.i687, !decision.origin !111

if.then.i687:                                     ; preds = %quant_decide.exit729
  %118 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.1) #3
  br label %quant_decide.exit707, !decision.origin !112, !decision.order !113

if.else.i689:                                     ; preds = %quant_decide.exit729
  %cmp2.i688 = fcmp olt float %117, 7.500000e-01
  br i1 %cmp2.i688, label %if.then3.i690, label %if.else4.i692, !decision.origin !114

if.then3.i690:                                    ; preds = %if.else.i689
  %119 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.1) #3
  br label %quant_decide.exit707, !decision.origin !115, !decision.order !116

if.else4.i692:                                    ; preds = %if.else.i689
  %cmp6.i691 = fcmp ugt float %117, 1.250000e+00
  br i1 %cmp6.i691, label %if.else8.i695, label %if.then7.i693, !decision.origin !117

if.then7.i693:                                    ; preds = %if.else4.i692
  %120 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.1) #3
  br label %quant_decide.exit707, !decision.origin !118, !decision.order !119

if.else8.i695:                                    ; preds = %if.else4.i692
  %cmp10.i694 = fcmp olt float %117, 1.750000e+00
  br i1 %cmp10.i694, label %if.then11.i696, label %if.else12.i698, !decision.origin !120

if.then11.i696:                                   ; preds = %if.else8.i695
  %121 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.1) #3
  br label %quant_decide.exit707, !decision.origin !121, !decision.order !122

if.else12.i698:                                   ; preds = %if.else8.i695
  %cmp14.i697 = fcmp ugt float %117, 2.500000e+00
  br i1 %cmp14.i697, label %if.else16.i701, label %if.then15.i699, !decision.origin !123

if.then15.i699:                                   ; preds = %if.else12.i698
  %122 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.1) #3
  br label %quant_decide.exit707, !decision.origin !124, !decision.order !125

if.else16.i701:                                   ; preds = %if.else12.i698
  %cmp18.i700 = fcmp olt float %117, 3.500000e+00
  br i1 %cmp18.i700, label %if.then19.i702, label %if.else20.i704, !decision.origin !126

if.then19.i702:                                   ; preds = %if.else16.i701
  %123 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.1) #3
  br label %quant_decide.exit707, !decision.origin !127, !decision.order !128

if.else20.i704:                                   ; preds = %if.else16.i701
  %cmp22.i703 = fcmp ugt float %117, 5.000000e+00
  br i1 %cmp22.i703, label %if.end29.i706, label %if.then23.i705, !decision.origin !129

if.then23.i705:                                   ; preds = %if.else20.i704
  %124 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.1) #3
  br label %quant_decide.exit707, !decision.origin !130, !decision.order !131

if.end29.i706:                                    ; preds = %if.else20.i704
  %125 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.1) #3
  br label %quant_decide.exit707, !decision.origin !132, !decision.order !133

quant_decide.exit707:                             ; preds = %if.end29.i706, %if.then23.i705, %if.then19.i702, %if.then15.i699, %if.then11.i696, %if.then7.i693, %if.then3.i690, %if.then.i687
  %out.i372.1 = phi float [ %119, %if.then3.i690 ], [ %121, %if.then11.i696 ], [ %123, %if.then19.i702 ], [ %125, %if.end29.i706 ], [ %124, %if.then23.i705 ], [ %122, %if.then15.i699 ], [ %120, %if.then7.i693 ], [ %118, %if.then.i687 ]
  %mul118.1 = fmul float %cond88, %out.i372.1
  %sub.1 = fsub float %mul118.1, %20
  %mul126.1 = fmul float %div73, %24
  %126 = tail call float @llvm.fabs.f32(float %mul126.1) #3
  %cmp.i664 = fcmp ugt float %126, 2.500000e-01
  br i1 %cmp.i664, label %if.else.i667, label %if.then.i665, !decision.origin !134

if.then.i665:                                     ; preds = %quant_decide.exit707
  %127 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.1) #3
  br label %quant_decide.exit685, !decision.origin !135, !decision.order !136

if.else.i667:                                     ; preds = %quant_decide.exit707
  %cmp2.i666 = fcmp olt float %126, 7.500000e-01
  br i1 %cmp2.i666, label %if.then3.i668, label %if.else4.i670, !decision.origin !137

if.then3.i668:                                    ; preds = %if.else.i667
  %128 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.1) #3
  br label %quant_decide.exit685, !decision.origin !138, !decision.order !139

if.else4.i670:                                    ; preds = %if.else.i667
  %cmp6.i669 = fcmp ugt float %126, 1.250000e+00
  br i1 %cmp6.i669, label %if.else8.i673, label %if.then7.i671, !decision.origin !140

if.then7.i671:                                    ; preds = %if.else4.i670
  %129 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.1) #3
  br label %quant_decide.exit685, !decision.origin !141, !decision.order !142

if.else8.i673:                                    ; preds = %if.else4.i670
  %cmp10.i672 = fcmp olt float %126, 1.750000e+00
  br i1 %cmp10.i672, label %if.then11.i674, label %if.else12.i676, !decision.origin !143

if.then11.i674:                                   ; preds = %if.else8.i673
  %130 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.1) #3
  br label %quant_decide.exit685, !decision.origin !144, !decision.order !145

if.else12.i676:                                   ; preds = %if.else8.i673
  %cmp14.i675 = fcmp ugt float %126, 2.500000e+00
  br i1 %cmp14.i675, label %if.else16.i679, label %if.then15.i677, !decision.origin !146

if.then15.i677:                                   ; preds = %if.else12.i676
  %131 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.1) #3
  br label %quant_decide.exit685, !decision.origin !147, !decision.order !148

if.else16.i679:                                   ; preds = %if.else12.i676
  %cmp18.i678 = fcmp olt float %126, 3.500000e+00
  br i1 %cmp18.i678, label %if.then19.i680, label %if.else20.i682, !decision.origin !149

if.then19.i680:                                   ; preds = %if.else16.i679
  %132 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.1) #3
  br label %quant_decide.exit685, !decision.origin !150, !decision.order !151

if.else20.i682:                                   ; preds = %if.else16.i679
  %cmp22.i681 = fcmp ugt float %126, 5.000000e+00
  br i1 %cmp22.i681, label %if.end29.i684, label %if.then23.i683, !decision.origin !152

if.then23.i683:                                   ; preds = %if.else20.i682
  %133 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.1) #3
  br label %quant_decide.exit685, !decision.origin !153, !decision.order !154

if.end29.i684:                                    ; preds = %if.else20.i682
  %134 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.1) #3
  br label %quant_decide.exit685, !decision.origin !155, !decision.order !156

quant_decide.exit685:                             ; preds = %if.end29.i684, %if.then23.i683, %if.then19.i680, %if.then15.i677, %if.then11.i674, %if.then7.i671, %if.then3.i668, %if.then.i665
  %out.i.1 = phi float [ %128, %if.then3.i668 ], [ %130, %if.then11.i674 ], [ %132, %if.then19.i680 ], [ %134, %if.end29.i684 ], [ %133, %if.then23.i683 ], [ %131, %if.then15.i677 ], [ %129, %if.then7.i671 ], [ %127, %if.then.i665 ]
  %mul128.1 = fmul float %cond88, %out.i.1
  %sub132.1 = fsub float %mul128.1, %24
  %mul133.1 = fmul float %sub.1, %sub.1
  %mul134.1 = fmul float %sub132.1, %sub132.1
  %add135.1 = fadd float %mul133.1, %mul134.1
  %e.1.1 = fadd float %e.1, %add135.1
  %mul116.2 = fmul float %div73, %28
  %135 = tail call float @llvm.fabs.f32(float %mul116.2) #3
  %cmp.i642 = fcmp ugt float %135, 2.500000e-01
  br i1 %cmp.i642, label %if.else.i645, label %if.then.i643, !decision.origin !157

if.then.i643:                                     ; preds = %quant_decide.exit685
  %136 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.2) #3
  br label %quant_decide.exit663, !decision.origin !158, !decision.order !159

if.else.i645:                                     ; preds = %quant_decide.exit685
  %cmp2.i644 = fcmp olt float %135, 7.500000e-01
  br i1 %cmp2.i644, label %if.then3.i646, label %if.else4.i648, !decision.origin !160

if.then3.i646:                                    ; preds = %if.else.i645
  %137 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.2) #3
  br label %quant_decide.exit663, !decision.origin !161, !decision.order !162

if.else4.i648:                                    ; preds = %if.else.i645
  %cmp6.i647 = fcmp ugt float %135, 1.250000e+00
  br i1 %cmp6.i647, label %if.else8.i651, label %if.then7.i649, !decision.origin !163

if.then7.i649:                                    ; preds = %if.else4.i648
  %138 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.2) #3
  br label %quant_decide.exit663, !decision.origin !164, !decision.order !165

if.else8.i651:                                    ; preds = %if.else4.i648
  %cmp10.i650 = fcmp olt float %135, 1.750000e+00
  br i1 %cmp10.i650, label %if.then11.i652, label %if.else12.i654, !decision.origin !166

if.then11.i652:                                   ; preds = %if.else8.i651
  %139 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.2) #3
  br label %quant_decide.exit663, !decision.origin !167, !decision.order !168

if.else12.i654:                                   ; preds = %if.else8.i651
  %cmp14.i653 = fcmp ugt float %135, 2.500000e+00
  br i1 %cmp14.i653, label %if.else16.i657, label %if.then15.i655, !decision.origin !169

if.then15.i655:                                   ; preds = %if.else12.i654
  %140 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.2) #3
  br label %quant_decide.exit663, !decision.origin !170, !decision.order !171

if.else16.i657:                                   ; preds = %if.else12.i654
  %cmp18.i656 = fcmp olt float %135, 3.500000e+00
  br i1 %cmp18.i656, label %if.then19.i658, label %if.else20.i660, !decision.origin !172

if.then19.i658:                                   ; preds = %if.else16.i657
  %141 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.2) #3
  br label %quant_decide.exit663, !decision.origin !173, !decision.order !174

if.else20.i660:                                   ; preds = %if.else16.i657
  %cmp22.i659 = fcmp ugt float %135, 5.000000e+00
  br i1 %cmp22.i659, label %if.end29.i662, label %if.then23.i661, !decision.origin !175

if.then23.i661:                                   ; preds = %if.else20.i660
  %142 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.2) #3
  br label %quant_decide.exit663, !decision.origin !176, !decision.order !177

if.end29.i662:                                    ; preds = %if.else20.i660
  %143 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.2) #3
  br label %quant_decide.exit663, !decision.origin !178, !decision.order !179

quant_decide.exit663:                             ; preds = %if.end29.i662, %if.then23.i661, %if.then19.i658, %if.then15.i655, %if.then11.i652, %if.then7.i649, %if.then3.i646, %if.then.i643
  %out.i372.2 = phi float [ %137, %if.then3.i646 ], [ %139, %if.then11.i652 ], [ %141, %if.then19.i658 ], [ %143, %if.end29.i662 ], [ %142, %if.then23.i661 ], [ %140, %if.then15.i655 ], [ %138, %if.then7.i649 ], [ %136, %if.then.i643 ]
  %mul118.2 = fmul float %cond88, %out.i372.2
  %sub.2 = fsub float %mul118.2, %28
  %mul126.2 = fmul float %div73, %32
  %144 = tail call float @llvm.fabs.f32(float %mul126.2) #3
  %cmp.i620 = fcmp ugt float %144, 2.500000e-01
  br i1 %cmp.i620, label %if.else.i623, label %if.then.i621, !decision.origin !180

if.then.i621:                                     ; preds = %quant_decide.exit663
  %145 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.2) #3
  br label %quant_decide.exit641, !decision.origin !181, !decision.order !182

if.else.i623:                                     ; preds = %quant_decide.exit663
  %cmp2.i622 = fcmp olt float %144, 7.500000e-01
  br i1 %cmp2.i622, label %if.then3.i624, label %if.else4.i626, !decision.origin !183

if.then3.i624:                                    ; preds = %if.else.i623
  %146 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.2) #3
  br label %quant_decide.exit641, !decision.origin !184, !decision.order !185

if.else4.i626:                                    ; preds = %if.else.i623
  %cmp6.i625 = fcmp ugt float %144, 1.250000e+00
  br i1 %cmp6.i625, label %if.else8.i629, label %if.then7.i627, !decision.origin !186

if.then7.i627:                                    ; preds = %if.else4.i626
  %147 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.2) #3
  br label %quant_decide.exit641, !decision.origin !187, !decision.order !188

if.else8.i629:                                    ; preds = %if.else4.i626
  %cmp10.i628 = fcmp olt float %144, 1.750000e+00
  br i1 %cmp10.i628, label %if.then11.i630, label %if.else12.i632, !decision.origin !189

if.then11.i630:                                   ; preds = %if.else8.i629
  %148 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.2) #3
  br label %quant_decide.exit641, !decision.origin !190, !decision.order !191

if.else12.i632:                                   ; preds = %if.else8.i629
  %cmp14.i631 = fcmp ugt float %144, 2.500000e+00
  br i1 %cmp14.i631, label %if.else16.i635, label %if.then15.i633, !decision.origin !192

if.then15.i633:                                   ; preds = %if.else12.i632
  %149 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.2) #3
  br label %quant_decide.exit641, !decision.origin !193, !decision.order !194

if.else16.i635:                                   ; preds = %if.else12.i632
  %cmp18.i634 = fcmp olt float %144, 3.500000e+00
  br i1 %cmp18.i634, label %if.then19.i636, label %if.else20.i638, !decision.origin !195

if.then19.i636:                                   ; preds = %if.else16.i635
  %150 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.2) #3
  br label %quant_decide.exit641, !decision.origin !196, !decision.order !197

if.else20.i638:                                   ; preds = %if.else16.i635
  %cmp22.i637 = fcmp ugt float %144, 5.000000e+00
  br i1 %cmp22.i637, label %if.end29.i640, label %if.then23.i639, !decision.origin !198

if.then23.i639:                                   ; preds = %if.else20.i638
  %151 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.2) #3
  br label %quant_decide.exit641, !decision.origin !199, !decision.order !200

if.end29.i640:                                    ; preds = %if.else20.i638
  %152 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.2) #3
  br label %quant_decide.exit641, !decision.origin !201, !decision.order !202

quant_decide.exit641:                             ; preds = %if.end29.i640, %if.then23.i639, %if.then19.i636, %if.then15.i633, %if.then11.i630, %if.then7.i627, %if.then3.i624, %if.then.i621
  %out.i.2 = phi float [ %146, %if.then3.i624 ], [ %148, %if.then11.i630 ], [ %150, %if.then19.i636 ], [ %152, %if.end29.i640 ], [ %151, %if.then23.i639 ], [ %149, %if.then15.i633 ], [ %147, %if.then7.i627 ], [ %145, %if.then.i621 ]
  %mul128.2 = fmul float %cond88, %out.i.2
  %sub132.2 = fsub float %mul128.2, %32
  %mul133.2 = fmul float %sub.2, %sub.2
  %mul134.2 = fmul float %sub132.2, %sub132.2
  %add135.2 = fadd float %mul133.2, %mul134.2
  %e.1.2 = fadd float %e.1.1, %add135.2
  %mul116.3 = fmul float %div73, %36
  %153 = tail call float @llvm.fabs.f32(float %mul116.3) #3
  %cmp.i598 = fcmp ugt float %153, 2.500000e-01
  br i1 %cmp.i598, label %if.else.i601, label %if.then.i599, !decision.origin !203

if.then.i599:                                     ; preds = %quant_decide.exit641
  %154 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.3) #3
  br label %quant_decide.exit619, !decision.origin !204, !decision.order !205

if.else.i601:                                     ; preds = %quant_decide.exit641
  %cmp2.i600 = fcmp olt float %153, 7.500000e-01
  br i1 %cmp2.i600, label %if.then3.i602, label %if.else4.i604, !decision.origin !206

if.then3.i602:                                    ; preds = %if.else.i601
  %155 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.3) #3
  br label %quant_decide.exit619, !decision.origin !207, !decision.order !208

if.else4.i604:                                    ; preds = %if.else.i601
  %cmp6.i603 = fcmp ugt float %153, 1.250000e+00
  br i1 %cmp6.i603, label %if.else8.i607, label %if.then7.i605, !decision.origin !209

if.then7.i605:                                    ; preds = %if.else4.i604
  %156 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.3) #3
  br label %quant_decide.exit619, !decision.origin !210, !decision.order !211

if.else8.i607:                                    ; preds = %if.else4.i604
  %cmp10.i606 = fcmp olt float %153, 1.750000e+00
  br i1 %cmp10.i606, label %if.then11.i608, label %if.else12.i610, !decision.origin !212

if.then11.i608:                                   ; preds = %if.else8.i607
  %157 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.3) #3
  br label %quant_decide.exit619, !decision.origin !213, !decision.order !214

if.else12.i610:                                   ; preds = %if.else8.i607
  %cmp14.i609 = fcmp ugt float %153, 2.500000e+00
  br i1 %cmp14.i609, label %if.else16.i613, label %if.then15.i611, !decision.origin !215

if.then15.i611:                                   ; preds = %if.else12.i610
  %158 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.3) #3
  br label %quant_decide.exit619, !decision.origin !216, !decision.order !217

if.else16.i613:                                   ; preds = %if.else12.i610
  %cmp18.i612 = fcmp olt float %153, 3.500000e+00
  br i1 %cmp18.i612, label %if.then19.i614, label %if.else20.i616, !decision.origin !218

if.then19.i614:                                   ; preds = %if.else16.i613
  %159 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.3) #3
  br label %quant_decide.exit619, !decision.origin !219, !decision.order !220

if.else20.i616:                                   ; preds = %if.else16.i613
  %cmp22.i615 = fcmp ugt float %153, 5.000000e+00
  br i1 %cmp22.i615, label %if.end29.i618, label %if.then23.i617, !decision.origin !221

if.then23.i617:                                   ; preds = %if.else20.i616
  %160 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.3) #3
  br label %quant_decide.exit619, !decision.origin !222, !decision.order !223

if.end29.i618:                                    ; preds = %if.else20.i616
  %161 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.3) #3
  br label %quant_decide.exit619, !decision.origin !224, !decision.order !225

quant_decide.exit619:                             ; preds = %if.end29.i618, %if.then23.i617, %if.then19.i614, %if.then15.i611, %if.then11.i608, %if.then7.i605, %if.then3.i602, %if.then.i599
  %out.i372.3 = phi float [ %155, %if.then3.i602 ], [ %157, %if.then11.i608 ], [ %159, %if.then19.i614 ], [ %161, %if.end29.i618 ], [ %160, %if.then23.i617 ], [ %158, %if.then15.i611 ], [ %156, %if.then7.i605 ], [ %154, %if.then.i599 ]
  %mul118.3 = fmul float %cond88, %out.i372.3
  %sub.3 = fsub float %mul118.3, %36
  %mul126.3 = fmul float %div73, %40
  %162 = tail call float @llvm.fabs.f32(float %mul126.3) #3
  %cmp.i576 = fcmp ugt float %162, 2.500000e-01
  br i1 %cmp.i576, label %if.else.i579, label %if.then.i577, !decision.origin !226

if.then.i577:                                     ; preds = %quant_decide.exit619
  %163 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.3) #3
  br label %quant_decide.exit597, !decision.origin !227, !decision.order !228

if.else.i579:                                     ; preds = %quant_decide.exit619
  %cmp2.i578 = fcmp olt float %162, 7.500000e-01
  br i1 %cmp2.i578, label %if.then3.i580, label %if.else4.i582, !decision.origin !229

if.then3.i580:                                    ; preds = %if.else.i579
  %164 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.3) #3
  br label %quant_decide.exit597, !decision.origin !230, !decision.order !231

if.else4.i582:                                    ; preds = %if.else.i579
  %cmp6.i581 = fcmp ugt float %162, 1.250000e+00
  br i1 %cmp6.i581, label %if.else8.i585, label %if.then7.i583, !decision.origin !232

if.then7.i583:                                    ; preds = %if.else4.i582
  %165 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.3) #3
  br label %quant_decide.exit597, !decision.origin !233, !decision.order !234

if.else8.i585:                                    ; preds = %if.else4.i582
  %cmp10.i584 = fcmp olt float %162, 1.750000e+00
  br i1 %cmp10.i584, label %if.then11.i586, label %if.else12.i588, !decision.origin !235

if.then11.i586:                                   ; preds = %if.else8.i585
  %166 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.3) #3
  br label %quant_decide.exit597, !decision.origin !236, !decision.order !237

if.else12.i588:                                   ; preds = %if.else8.i585
  %cmp14.i587 = fcmp ugt float %162, 2.500000e+00
  br i1 %cmp14.i587, label %if.else16.i591, label %if.then15.i589, !decision.origin !238

if.then15.i589:                                   ; preds = %if.else12.i588
  %167 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.3) #3
  br label %quant_decide.exit597, !decision.origin !239, !decision.order !240

if.else16.i591:                                   ; preds = %if.else12.i588
  %cmp18.i590 = fcmp olt float %162, 3.500000e+00
  br i1 %cmp18.i590, label %if.then19.i592, label %if.else20.i594, !decision.origin !241

if.then19.i592:                                   ; preds = %if.else16.i591
  %168 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.3) #3
  br label %quant_decide.exit597, !decision.origin !242, !decision.order !243

if.else20.i594:                                   ; preds = %if.else16.i591
  %cmp22.i593 = fcmp ugt float %162, 5.000000e+00
  br i1 %cmp22.i593, label %if.end29.i596, label %if.then23.i595, !decision.origin !244

if.then23.i595:                                   ; preds = %if.else20.i594
  %169 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.3) #3
  br label %quant_decide.exit597, !decision.origin !245, !decision.order !246

if.end29.i596:                                    ; preds = %if.else20.i594
  %170 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.3) #3
  br label %quant_decide.exit597, !decision.origin !247, !decision.order !248

quant_decide.exit597:                             ; preds = %if.end29.i596, %if.then23.i595, %if.then19.i592, %if.then15.i589, %if.then11.i586, %if.then7.i583, %if.then3.i580, %if.then.i577
  %out.i.3 = phi float [ %164, %if.then3.i580 ], [ %166, %if.then11.i586 ], [ %168, %if.then19.i592 ], [ %170, %if.end29.i596 ], [ %169, %if.then23.i595 ], [ %167, %if.then15.i589 ], [ %165, %if.then7.i583 ], [ %163, %if.then.i577 ]
  %mul128.3 = fmul float %cond88, %out.i.3
  %sub132.3 = fsub float %mul128.3, %40
  %mul133.3 = fmul float %sub.3, %sub.3
  %mul134.3 = fmul float %sub132.3, %sub132.3
  %add135.3 = fadd float %mul133.3, %mul134.3
  %e.1.3 = fadd float %e.1.2, %add135.3
  %mul116.4 = fmul float %div73, %44
  %171 = tail call float @llvm.fabs.f32(float %mul116.4) #3
  %cmp.i554 = fcmp ugt float %171, 2.500000e-01
  br i1 %cmp.i554, label %if.else.i557, label %if.then.i555, !decision.origin !249

if.then.i555:                                     ; preds = %quant_decide.exit597
  %172 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.4) #3
  br label %quant_decide.exit575, !decision.origin !250, !decision.order !251

if.else.i557:                                     ; preds = %quant_decide.exit597
  %cmp2.i556 = fcmp olt float %171, 7.500000e-01
  br i1 %cmp2.i556, label %if.then3.i558, label %if.else4.i560, !decision.origin !252

if.then3.i558:                                    ; preds = %if.else.i557
  %173 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.4) #3
  br label %quant_decide.exit575, !decision.origin !253, !decision.order !254

if.else4.i560:                                    ; preds = %if.else.i557
  %cmp6.i559 = fcmp ugt float %171, 1.250000e+00
  br i1 %cmp6.i559, label %if.else8.i563, label %if.then7.i561, !decision.origin !255

if.then7.i561:                                    ; preds = %if.else4.i560
  %174 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.4) #3
  br label %quant_decide.exit575, !decision.origin !256, !decision.order !257

if.else8.i563:                                    ; preds = %if.else4.i560
  %cmp10.i562 = fcmp olt float %171, 1.750000e+00
  br i1 %cmp10.i562, label %if.then11.i564, label %if.else12.i566, !decision.origin !258

if.then11.i564:                                   ; preds = %if.else8.i563
  %175 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.4) #3
  br label %quant_decide.exit575, !decision.origin !259, !decision.order !260

if.else12.i566:                                   ; preds = %if.else8.i563
  %cmp14.i565 = fcmp ugt float %171, 2.500000e+00
  br i1 %cmp14.i565, label %if.else16.i569, label %if.then15.i567, !decision.origin !261

if.then15.i567:                                   ; preds = %if.else12.i566
  %176 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.4) #3
  br label %quant_decide.exit575, !decision.origin !262, !decision.order !263

if.else16.i569:                                   ; preds = %if.else12.i566
  %cmp18.i568 = fcmp olt float %171, 3.500000e+00
  br i1 %cmp18.i568, label %if.then19.i570, label %if.else20.i572, !decision.origin !264

if.then19.i570:                                   ; preds = %if.else16.i569
  %177 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.4) #3
  br label %quant_decide.exit575, !decision.origin !265, !decision.order !266

if.else20.i572:                                   ; preds = %if.else16.i569
  %cmp22.i571 = fcmp ugt float %171, 5.000000e+00
  br i1 %cmp22.i571, label %if.end29.i574, label %if.then23.i573, !decision.origin !267

if.then23.i573:                                   ; preds = %if.else20.i572
  %178 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.4) #3
  br label %quant_decide.exit575, !decision.origin !268, !decision.order !269

if.end29.i574:                                    ; preds = %if.else20.i572
  %179 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.4) #3
  br label %quant_decide.exit575, !decision.origin !270, !decision.order !271

quant_decide.exit575:                             ; preds = %if.end29.i574, %if.then23.i573, %if.then19.i570, %if.then15.i567, %if.then11.i564, %if.then7.i561, %if.then3.i558, %if.then.i555
  %out.i372.4 = phi float [ %173, %if.then3.i558 ], [ %175, %if.then11.i564 ], [ %177, %if.then19.i570 ], [ %179, %if.end29.i574 ], [ %178, %if.then23.i573 ], [ %176, %if.then15.i567 ], [ %174, %if.then7.i561 ], [ %172, %if.then.i555 ]
  %mul118.4 = fmul float %cond88, %out.i372.4
  %sub.4 = fsub float %mul118.4, %44
  %mul126.4 = fmul float %div73, %48
  %180 = tail call float @llvm.fabs.f32(float %mul126.4) #3
  %cmp.i532 = fcmp ugt float %180, 2.500000e-01
  br i1 %cmp.i532, label %if.else.i535, label %if.then.i533, !decision.origin !272

if.then.i533:                                     ; preds = %quant_decide.exit575
  %181 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.4) #3
  br label %quant_decide.exit553, !decision.origin !273, !decision.order !274

if.else.i535:                                     ; preds = %quant_decide.exit575
  %cmp2.i534 = fcmp olt float %180, 7.500000e-01
  br i1 %cmp2.i534, label %if.then3.i536, label %if.else4.i538, !decision.origin !275

if.then3.i536:                                    ; preds = %if.else.i535
  %182 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.4) #3
  br label %quant_decide.exit553, !decision.origin !276, !decision.order !277

if.else4.i538:                                    ; preds = %if.else.i535
  %cmp6.i537 = fcmp ugt float %180, 1.250000e+00
  br i1 %cmp6.i537, label %if.else8.i541, label %if.then7.i539, !decision.origin !278

if.then7.i539:                                    ; preds = %if.else4.i538
  %183 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.4) #3
  br label %quant_decide.exit553, !decision.origin !279, !decision.order !280

if.else8.i541:                                    ; preds = %if.else4.i538
  %cmp10.i540 = fcmp olt float %180, 1.750000e+00
  br i1 %cmp10.i540, label %if.then11.i542, label %if.else12.i544, !decision.origin !281

if.then11.i542:                                   ; preds = %if.else8.i541
  %184 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.4) #3
  br label %quant_decide.exit553, !decision.origin !282, !decision.order !283

if.else12.i544:                                   ; preds = %if.else8.i541
  %cmp14.i543 = fcmp ugt float %180, 2.500000e+00
  br i1 %cmp14.i543, label %if.else16.i547, label %if.then15.i545, !decision.origin !284

if.then15.i545:                                   ; preds = %if.else12.i544
  %185 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.4) #3
  br label %quant_decide.exit553, !decision.origin !285, !decision.order !286

if.else16.i547:                                   ; preds = %if.else12.i544
  %cmp18.i546 = fcmp olt float %180, 3.500000e+00
  br i1 %cmp18.i546, label %if.then19.i548, label %if.else20.i550, !decision.origin !287

if.then19.i548:                                   ; preds = %if.else16.i547
  %186 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.4) #3
  br label %quant_decide.exit553, !decision.origin !288, !decision.order !289

if.else20.i550:                                   ; preds = %if.else16.i547
  %cmp22.i549 = fcmp ugt float %180, 5.000000e+00
  br i1 %cmp22.i549, label %if.end29.i552, label %if.then23.i551, !decision.origin !290

if.then23.i551:                                   ; preds = %if.else20.i550
  %187 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.4) #3
  br label %quant_decide.exit553, !decision.origin !291, !decision.order !292

if.end29.i552:                                    ; preds = %if.else20.i550
  %188 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.4) #3
  br label %quant_decide.exit553, !decision.origin !293, !decision.order !294

quant_decide.exit553:                             ; preds = %if.end29.i552, %if.then23.i551, %if.then19.i548, %if.then15.i545, %if.then11.i542, %if.then7.i539, %if.then3.i536, %if.then.i533
  %out.i.4 = phi float [ %182, %if.then3.i536 ], [ %184, %if.then11.i542 ], [ %186, %if.then19.i548 ], [ %188, %if.end29.i552 ], [ %187, %if.then23.i551 ], [ %185, %if.then15.i545 ], [ %183, %if.then7.i539 ], [ %181, %if.then.i533 ]
  %mul128.4 = fmul float %cond88, %out.i.4
  %sub132.4 = fsub float %mul128.4, %48
  %mul133.4 = fmul float %sub.4, %sub.4
  %mul134.4 = fmul float %sub132.4, %sub132.4
  %add135.4 = fadd float %mul133.4, %mul134.4
  %e.1.4 = fadd float %e.1.3, %add135.4
  %mul116.5 = fmul float %div73, %52
  %189 = tail call float @llvm.fabs.f32(float %mul116.5) #3
  %cmp.i510 = fcmp ugt float %189, 2.500000e-01
  br i1 %cmp.i510, label %if.else.i513, label %if.then.i511, !decision.origin !295

if.then.i511:                                     ; preds = %quant_decide.exit553
  %190 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.5) #3
  br label %quant_decide.exit531, !decision.origin !296, !decision.order !297

if.else.i513:                                     ; preds = %quant_decide.exit553
  %cmp2.i512 = fcmp olt float %189, 7.500000e-01
  br i1 %cmp2.i512, label %if.then3.i514, label %if.else4.i516, !decision.origin !298

if.then3.i514:                                    ; preds = %if.else.i513
  %191 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.5) #3
  br label %quant_decide.exit531, !decision.origin !299, !decision.order !300

if.else4.i516:                                    ; preds = %if.else.i513
  %cmp6.i515 = fcmp ugt float %189, 1.250000e+00
  br i1 %cmp6.i515, label %if.else8.i519, label %if.then7.i517, !decision.origin !301

if.then7.i517:                                    ; preds = %if.else4.i516
  %192 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.5) #3
  br label %quant_decide.exit531, !decision.origin !302, !decision.order !303

if.else8.i519:                                    ; preds = %if.else4.i516
  %cmp10.i518 = fcmp olt float %189, 1.750000e+00
  br i1 %cmp10.i518, label %if.then11.i520, label %if.else12.i522, !decision.origin !304

if.then11.i520:                                   ; preds = %if.else8.i519
  %193 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.5) #3
  br label %quant_decide.exit531, !decision.origin !305, !decision.order !306

if.else12.i522:                                   ; preds = %if.else8.i519
  %cmp14.i521 = fcmp ugt float %189, 2.500000e+00
  br i1 %cmp14.i521, label %if.else16.i525, label %if.then15.i523, !decision.origin !307

if.then15.i523:                                   ; preds = %if.else12.i522
  %194 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.5) #3
  br label %quant_decide.exit531, !decision.origin !308, !decision.order !309

if.else16.i525:                                   ; preds = %if.else12.i522
  %cmp18.i524 = fcmp olt float %189, 3.500000e+00
  br i1 %cmp18.i524, label %if.then19.i526, label %if.else20.i528, !decision.origin !310

if.then19.i526:                                   ; preds = %if.else16.i525
  %195 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.5) #3
  br label %quant_decide.exit531, !decision.origin !311, !decision.order !312

if.else20.i528:                                   ; preds = %if.else16.i525
  %cmp22.i527 = fcmp ugt float %189, 5.000000e+00
  br i1 %cmp22.i527, label %if.end29.i530, label %if.then23.i529, !decision.origin !313

if.then23.i529:                                   ; preds = %if.else20.i528
  %196 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.5) #3
  br label %quant_decide.exit531, !decision.origin !314, !decision.order !315

if.end29.i530:                                    ; preds = %if.else20.i528
  %197 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.5) #3
  br label %quant_decide.exit531, !decision.origin !316, !decision.order !317

quant_decide.exit531:                             ; preds = %if.end29.i530, %if.then23.i529, %if.then19.i526, %if.then15.i523, %if.then11.i520, %if.then7.i517, %if.then3.i514, %if.then.i511
  %out.i372.5 = phi float [ %191, %if.then3.i514 ], [ %193, %if.then11.i520 ], [ %195, %if.then19.i526 ], [ %197, %if.end29.i530 ], [ %196, %if.then23.i529 ], [ %194, %if.then15.i523 ], [ %192, %if.then7.i517 ], [ %190, %if.then.i511 ]
  %mul118.5 = fmul float %cond88, %out.i372.5
  %sub.5 = fsub float %mul118.5, %52
  %mul126.5 = fmul float %div73, %56
  %198 = tail call float @llvm.fabs.f32(float %mul126.5) #3
  %cmp.i488 = fcmp ugt float %198, 2.500000e-01
  br i1 %cmp.i488, label %if.else.i491, label %if.then.i489, !decision.origin !318

if.then.i489:                                     ; preds = %quant_decide.exit531
  %199 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.5) #3
  br label %quant_decide.exit509, !decision.origin !319, !decision.order !320

if.else.i491:                                     ; preds = %quant_decide.exit531
  %cmp2.i490 = fcmp olt float %198, 7.500000e-01
  br i1 %cmp2.i490, label %if.then3.i492, label %if.else4.i494, !decision.origin !321

if.then3.i492:                                    ; preds = %if.else.i491
  %200 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.5) #3
  br label %quant_decide.exit509, !decision.origin !322, !decision.order !323

if.else4.i494:                                    ; preds = %if.else.i491
  %cmp6.i493 = fcmp ugt float %198, 1.250000e+00
  br i1 %cmp6.i493, label %if.else8.i497, label %if.then7.i495, !decision.origin !324

if.then7.i495:                                    ; preds = %if.else4.i494
  %201 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.5) #3
  br label %quant_decide.exit509, !decision.origin !325, !decision.order !326

if.else8.i497:                                    ; preds = %if.else4.i494
  %cmp10.i496 = fcmp olt float %198, 1.750000e+00
  br i1 %cmp10.i496, label %if.then11.i498, label %if.else12.i500, !decision.origin !327

if.then11.i498:                                   ; preds = %if.else8.i497
  %202 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.5) #3
  br label %quant_decide.exit509, !decision.origin !328, !decision.order !329

if.else12.i500:                                   ; preds = %if.else8.i497
  %cmp14.i499 = fcmp ugt float %198, 2.500000e+00
  br i1 %cmp14.i499, label %if.else16.i503, label %if.then15.i501, !decision.origin !330

if.then15.i501:                                   ; preds = %if.else12.i500
  %203 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.5) #3
  br label %quant_decide.exit509, !decision.origin !331, !decision.order !332

if.else16.i503:                                   ; preds = %if.else12.i500
  %cmp18.i502 = fcmp olt float %198, 3.500000e+00
  br i1 %cmp18.i502, label %if.then19.i504, label %if.else20.i506, !decision.origin !333

if.then19.i504:                                   ; preds = %if.else16.i503
  %204 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.5) #3
  br label %quant_decide.exit509, !decision.origin !334, !decision.order !335

if.else20.i506:                                   ; preds = %if.else16.i503
  %cmp22.i505 = fcmp ugt float %198, 5.000000e+00
  br i1 %cmp22.i505, label %if.end29.i508, label %if.then23.i507, !decision.origin !336

if.then23.i507:                                   ; preds = %if.else20.i506
  %205 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.5) #3
  br label %quant_decide.exit509, !decision.origin !337, !decision.order !338

if.end29.i508:                                    ; preds = %if.else20.i506
  %206 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.5) #3
  br label %quant_decide.exit509, !decision.origin !339, !decision.order !340

quant_decide.exit509:                             ; preds = %if.end29.i508, %if.then23.i507, %if.then19.i504, %if.then15.i501, %if.then11.i498, %if.then7.i495, %if.then3.i492, %if.then.i489
  %out.i.5 = phi float [ %200, %if.then3.i492 ], [ %202, %if.then11.i498 ], [ %204, %if.then19.i504 ], [ %206, %if.end29.i508 ], [ %205, %if.then23.i507 ], [ %203, %if.then15.i501 ], [ %201, %if.then7.i495 ], [ %199, %if.then.i489 ]
  %mul128.5 = fmul float %cond88, %out.i.5
  %sub132.5 = fsub float %mul128.5, %56
  %mul133.5 = fmul float %sub.5, %sub.5
  %mul134.5 = fmul float %sub132.5, %sub132.5
  %add135.5 = fadd float %mul133.5, %mul134.5
  %e.1.5 = fadd float %e.1.4, %add135.5
  %mul116.6 = fmul float %div73, %60
  %207 = tail call float @llvm.fabs.f32(float %mul116.6) #3
  %cmp.i466 = fcmp ugt float %207, 2.500000e-01
  br i1 %cmp.i466, label %if.else.i469, label %if.then.i467, !decision.origin !341

if.then.i467:                                     ; preds = %quant_decide.exit509
  %208 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.6) #3
  br label %quant_decide.exit487, !decision.origin !342, !decision.order !343

if.else.i469:                                     ; preds = %quant_decide.exit509
  %cmp2.i468 = fcmp olt float %207, 7.500000e-01
  br i1 %cmp2.i468, label %if.then3.i470, label %if.else4.i472, !decision.origin !344

if.then3.i470:                                    ; preds = %if.else.i469
  %209 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.6) #3
  br label %quant_decide.exit487, !decision.origin !345, !decision.order !346

if.else4.i472:                                    ; preds = %if.else.i469
  %cmp6.i471 = fcmp ugt float %207, 1.250000e+00
  br i1 %cmp6.i471, label %if.else8.i475, label %if.then7.i473, !decision.origin !347

if.then7.i473:                                    ; preds = %if.else4.i472
  %210 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.6) #3
  br label %quant_decide.exit487, !decision.origin !348, !decision.order !349

if.else8.i475:                                    ; preds = %if.else4.i472
  %cmp10.i474 = fcmp olt float %207, 1.750000e+00
  br i1 %cmp10.i474, label %if.then11.i476, label %if.else12.i478, !decision.origin !350

if.then11.i476:                                   ; preds = %if.else8.i475
  %211 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.6) #3
  br label %quant_decide.exit487, !decision.origin !351, !decision.order !352

if.else12.i478:                                   ; preds = %if.else8.i475
  %cmp14.i477 = fcmp ugt float %207, 2.500000e+00
  br i1 %cmp14.i477, label %if.else16.i481, label %if.then15.i479, !decision.origin !353

if.then15.i479:                                   ; preds = %if.else12.i478
  %212 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.6) #3
  br label %quant_decide.exit487, !decision.origin !354, !decision.order !355

if.else16.i481:                                   ; preds = %if.else12.i478
  %cmp18.i480 = fcmp olt float %207, 3.500000e+00
  br i1 %cmp18.i480, label %if.then19.i482, label %if.else20.i484, !decision.origin !356

if.then19.i482:                                   ; preds = %if.else16.i481
  %213 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.6) #3
  br label %quant_decide.exit487, !decision.origin !357, !decision.order !358

if.else20.i484:                                   ; preds = %if.else16.i481
  %cmp22.i483 = fcmp ugt float %207, 5.000000e+00
  br i1 %cmp22.i483, label %if.end29.i486, label %if.then23.i485, !decision.origin !359

if.then23.i485:                                   ; preds = %if.else20.i484
  %214 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.6) #3
  br label %quant_decide.exit487, !decision.origin !360, !decision.order !361

if.end29.i486:                                    ; preds = %if.else20.i484
  %215 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.6) #3
  br label %quant_decide.exit487, !decision.origin !362, !decision.order !363

quant_decide.exit487:                             ; preds = %if.end29.i486, %if.then23.i485, %if.then19.i482, %if.then15.i479, %if.then11.i476, %if.then7.i473, %if.then3.i470, %if.then.i467
  %out.i372.6 = phi float [ %209, %if.then3.i470 ], [ %211, %if.then11.i476 ], [ %213, %if.then19.i482 ], [ %215, %if.end29.i486 ], [ %214, %if.then23.i485 ], [ %212, %if.then15.i479 ], [ %210, %if.then7.i473 ], [ %208, %if.then.i467 ]
  %mul118.6 = fmul float %cond88, %out.i372.6
  %sub.6 = fsub float %mul118.6, %60
  %mul126.6 = fmul float %div73, %64
  %216 = tail call float @llvm.fabs.f32(float %mul126.6) #3
  %cmp.i444 = fcmp ugt float %216, 2.500000e-01
  br i1 %cmp.i444, label %if.else.i447, label %if.then.i445, !decision.origin !364

if.then.i445:                                     ; preds = %quant_decide.exit487
  %217 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.6) #3
  br label %quant_decide.exit465, !decision.origin !365, !decision.order !366

if.else.i447:                                     ; preds = %quant_decide.exit487
  %cmp2.i446 = fcmp olt float %216, 7.500000e-01
  br i1 %cmp2.i446, label %if.then3.i448, label %if.else4.i450, !decision.origin !367

if.then3.i448:                                    ; preds = %if.else.i447
  %218 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.6) #3
  br label %quant_decide.exit465, !decision.origin !368, !decision.order !369

if.else4.i450:                                    ; preds = %if.else.i447
  %cmp6.i449 = fcmp ugt float %216, 1.250000e+00
  br i1 %cmp6.i449, label %if.else8.i453, label %if.then7.i451, !decision.origin !370

if.then7.i451:                                    ; preds = %if.else4.i450
  %219 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.6) #3
  br label %quant_decide.exit465, !decision.origin !371, !decision.order !372

if.else8.i453:                                    ; preds = %if.else4.i450
  %cmp10.i452 = fcmp olt float %216, 1.750000e+00
  br i1 %cmp10.i452, label %if.then11.i454, label %if.else12.i456, !decision.origin !373

if.then11.i454:                                   ; preds = %if.else8.i453
  %220 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.6) #3
  br label %quant_decide.exit465, !decision.origin !374, !decision.order !375

if.else12.i456:                                   ; preds = %if.else8.i453
  %cmp14.i455 = fcmp ugt float %216, 2.500000e+00
  br i1 %cmp14.i455, label %if.else16.i459, label %if.then15.i457, !decision.origin !376

if.then15.i457:                                   ; preds = %if.else12.i456
  %221 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.6) #3
  br label %quant_decide.exit465, !decision.origin !377, !decision.order !378

if.else16.i459:                                   ; preds = %if.else12.i456
  %cmp18.i458 = fcmp olt float %216, 3.500000e+00
  br i1 %cmp18.i458, label %if.then19.i460, label %if.else20.i462, !decision.origin !379

if.then19.i460:                                   ; preds = %if.else16.i459
  %222 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.6) #3
  br label %quant_decide.exit465, !decision.origin !380, !decision.order !381

if.else20.i462:                                   ; preds = %if.else16.i459
  %cmp22.i461 = fcmp ugt float %216, 5.000000e+00
  br i1 %cmp22.i461, label %if.end29.i464, label %if.then23.i463, !decision.origin !382

if.then23.i463:                                   ; preds = %if.else20.i462
  %223 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.6) #3
  br label %quant_decide.exit465, !decision.origin !383, !decision.order !384

if.end29.i464:                                    ; preds = %if.else20.i462
  %224 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.6) #3
  br label %quant_decide.exit465, !decision.origin !385, !decision.order !386

quant_decide.exit465:                             ; preds = %if.end29.i464, %if.then23.i463, %if.then19.i460, %if.then15.i457, %if.then11.i454, %if.then7.i451, %if.then3.i448, %if.then.i445
  %out.i.6 = phi float [ %218, %if.then3.i448 ], [ %220, %if.then11.i454 ], [ %222, %if.then19.i460 ], [ %224, %if.end29.i464 ], [ %223, %if.then23.i463 ], [ %221, %if.then15.i457 ], [ %219, %if.then7.i451 ], [ %217, %if.then.i445 ]
  %mul128.6 = fmul float %cond88, %out.i.6
  %sub132.6 = fsub float %mul128.6, %64
  %mul133.6 = fmul float %sub.6, %sub.6
  %mul134.6 = fmul float %sub132.6, %sub132.6
  %add135.6 = fadd float %mul133.6, %mul134.6
  %e.1.6 = fadd float %e.1.5, %add135.6
  %mul116.7 = fmul float %div73, %74
  %225 = tail call float @llvm.fabs.f32(float %mul116.7) #3
  %cmp.i422 = fcmp ugt float %225, 2.500000e-01
  br i1 %cmp.i422, label %if.else.i425, label %if.then.i423, !decision.origin !387

if.then.i423:                                     ; preds = %quant_decide.exit465
  %226 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.7) #3
  br label %quant_decide.exit443, !decision.origin !388, !decision.order !389

if.else.i425:                                     ; preds = %quant_decide.exit465
  %cmp2.i424 = fcmp olt float %225, 7.500000e-01
  br i1 %cmp2.i424, label %if.then3.i426, label %if.else4.i428, !decision.origin !390

if.then3.i426:                                    ; preds = %if.else.i425
  %227 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.7) #3
  br label %quant_decide.exit443, !decision.origin !391, !decision.order !392

if.else4.i428:                                    ; preds = %if.else.i425
  %cmp6.i427 = fcmp ugt float %225, 1.250000e+00
  br i1 %cmp6.i427, label %if.else8.i431, label %if.then7.i429, !decision.origin !393

if.then7.i429:                                    ; preds = %if.else4.i428
  %228 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.7) #3
  br label %quant_decide.exit443, !decision.origin !394, !decision.order !395

if.else8.i431:                                    ; preds = %if.else4.i428
  %cmp10.i430 = fcmp olt float %225, 1.750000e+00
  br i1 %cmp10.i430, label %if.then11.i432, label %if.else12.i434, !decision.origin !396

if.then11.i432:                                   ; preds = %if.else8.i431
  %229 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.7) #3
  br label %quant_decide.exit443, !decision.origin !397, !decision.order !398

if.else12.i434:                                   ; preds = %if.else8.i431
  %cmp14.i433 = fcmp ugt float %225, 2.500000e+00
  br i1 %cmp14.i433, label %if.else16.i437, label %if.then15.i435, !decision.origin !399

if.then15.i435:                                   ; preds = %if.else12.i434
  %230 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.7) #3
  br label %quant_decide.exit443, !decision.origin !400, !decision.order !401

if.else16.i437:                                   ; preds = %if.else12.i434
  %cmp18.i436 = fcmp olt float %225, 3.500000e+00
  br i1 %cmp18.i436, label %if.then19.i438, label %if.else20.i440, !decision.origin !402

if.then19.i438:                                   ; preds = %if.else16.i437
  %231 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.7) #3
  br label %quant_decide.exit443, !decision.origin !403, !decision.order !404

if.else20.i440:                                   ; preds = %if.else16.i437
  %cmp22.i439 = fcmp ugt float %225, 5.000000e+00
  br i1 %cmp22.i439, label %if.end29.i442, label %if.then23.i441, !decision.origin !405

if.then23.i441:                                   ; preds = %if.else20.i440
  %232 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.7) #3
  br label %quant_decide.exit443, !decision.origin !406, !decision.order !407

if.end29.i442:                                    ; preds = %if.else20.i440
  %233 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.7) #3
  br label %quant_decide.exit443, !decision.origin !408, !decision.order !409

quant_decide.exit443:                             ; preds = %if.end29.i442, %if.then23.i441, %if.then19.i438, %if.then15.i435, %if.then11.i432, %if.then7.i429, %if.then3.i426, %if.then.i423
  %out.i372.7 = phi float [ %227, %if.then3.i426 ], [ %229, %if.then11.i432 ], [ %231, %if.then19.i438 ], [ %233, %if.end29.i442 ], [ %232, %if.then23.i441 ], [ %230, %if.then15.i435 ], [ %228, %if.then7.i429 ], [ %226, %if.then.i423 ]
  %mul118.7 = fmul float %cond88, %out.i372.7
  %sub.7 = fsub float %mul118.7, %74
  %mul126.7 = fmul float %div73, %77
  %234 = tail call float @llvm.fabs.f32(float %mul126.7) #3
  %cmp.i400 = fcmp ugt float %234, 2.500000e-01
  br i1 %cmp.i400, label %if.else.i403, label %if.then.i401, !decision.origin !410

if.then.i401:                                     ; preds = %quant_decide.exit443
  %235 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.7) #3
  br label %quant_decide.exit421, !decision.origin !411, !decision.order !412

if.else.i403:                                     ; preds = %quant_decide.exit443
  %cmp2.i402 = fcmp olt float %234, 7.500000e-01
  br i1 %cmp2.i402, label %if.then3.i404, label %if.else4.i406, !decision.origin !413

if.then3.i404:                                    ; preds = %if.else.i403
  %236 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.7) #3
  br label %quant_decide.exit421, !decision.origin !414, !decision.order !415

if.else4.i406:                                    ; preds = %if.else.i403
  %cmp6.i405 = fcmp ugt float %234, 1.250000e+00
  br i1 %cmp6.i405, label %if.else8.i409, label %if.then7.i407, !decision.origin !416

if.then7.i407:                                    ; preds = %if.else4.i406
  %237 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.7) #3
  br label %quant_decide.exit421, !decision.origin !417, !decision.order !418

if.else8.i409:                                    ; preds = %if.else4.i406
  %cmp10.i408 = fcmp olt float %234, 1.750000e+00
  br i1 %cmp10.i408, label %if.then11.i410, label %if.else12.i412, !decision.origin !419

if.then11.i410:                                   ; preds = %if.else8.i409
  %238 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.7) #3
  br label %quant_decide.exit421, !decision.origin !420, !decision.order !421

if.else12.i412:                                   ; preds = %if.else8.i409
  %cmp14.i411 = fcmp ugt float %234, 2.500000e+00
  br i1 %cmp14.i411, label %if.else16.i415, label %if.then15.i413, !decision.origin !422

if.then15.i413:                                   ; preds = %if.else12.i412
  %239 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.7) #3
  br label %quant_decide.exit421, !decision.origin !423, !decision.order !424

if.else16.i415:                                   ; preds = %if.else12.i412
  %cmp18.i414 = fcmp olt float %234, 3.500000e+00
  br i1 %cmp18.i414, label %if.then19.i416, label %if.else20.i418, !decision.origin !425

if.then19.i416:                                   ; preds = %if.else16.i415
  %240 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.7) #3
  br label %quant_decide.exit421, !decision.origin !426, !decision.order !427

if.else20.i418:                                   ; preds = %if.else16.i415
  %cmp22.i417 = fcmp ugt float %234, 5.000000e+00
  br i1 %cmp22.i417, label %if.end29.i420, label %if.then23.i419, !decision.origin !428

if.then23.i419:                                   ; preds = %if.else20.i418
  %241 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.7) #3
  br label %quant_decide.exit421, !decision.origin !429, !decision.order !430

if.end29.i420:                                    ; preds = %if.else20.i418
  %242 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.7) #3
  br label %quant_decide.exit421, !decision.origin !431, !decision.order !432

quant_decide.exit421:                             ; preds = %if.end29.i420, %if.then23.i419, %if.then19.i416, %if.then15.i413, %if.then11.i410, %if.then7.i407, %if.then3.i404, %if.then.i401
  %out.i.7 = phi float [ %236, %if.then3.i404 ], [ %238, %if.then11.i410 ], [ %240, %if.then19.i416 ], [ %242, %if.end29.i420 ], [ %241, %if.then23.i419 ], [ %239, %if.then15.i413 ], [ %237, %if.then7.i407 ], [ %235, %if.then.i401 ]
  %mul128.7 = fmul float %cond88, %out.i.7
  %sub132.7 = fsub float %mul128.7, %77
  %mul133.7 = fmul float %sub.7, %sub.7
  %mul134.7 = fmul float %sub132.7, %sub132.7
  br label %for.inc138.7, !decision.origin !433

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
  br label %for.inc138.7, !decision.origin !434

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
  br i1 %cmp.i379.1, label %_Z4dec8i.exit.i.2.1, label %_Z4enc8f.exit.thread396.1, !decision.origin !435

_Z4enc8f.exit.thread396.1:                        ; preds = %for.inc138.7
  store i8 126, i8 addrspace(5)* %arrayidx64340398.1, align 1, !tbaa !18
  br label %cond.true.i.1, !decision.origin !436

_Z4dec8i.exit.i.2.1:                              ; preds = %for.inc138.7
  %cmp2.i.1424 = fcmp ogt float %mul61.1, 1.875000e+00
  %hi.1.i.1425 = select i1 %cmp2.i.1424, i32 126, i32 63
  %lo.1.i.1426 = select i1 %cmp2.i.1424, i32 64, i32 0
  %div.i.1.1 = select i1 %cmp2.i.1424, i32 95, i32 31
  %243 = lshr i32 %div.i.1.1, 3
  %sub.i.i.1.1 = add nsw i32 %243, -7
  %244 = tail call float @llvm.amdgcn.ldexp.f32(float 1.875000e+00, i32 %sub.i.i.1.1) #3
  %cmp2.i.1.1 = fcmp olt float %244, %mul61.1
  %add4.i.1.1 = add nuw nsw i32 %div.i.1.1, 1
  %hi.1.i.1.1 = select i1 %cmp2.i.1.1, i32 %hi.1.i.1425, i32 %div.i.1.1
  %lo.1.i.1.1 = select i1 %cmp2.i.1.1, i32 %add4.i.1.1, i32 %lo.1.i.1426
  %add.i381.2.1 = add nuw nsw i32 %lo.1.i.1.1, %hi.1.i.1.1
  %div.i.2.1 = lshr i32 %add.i381.2.1, 1
  %245 = lshr i32 %add.i381.2.1, 4
  %sub.i.i.2.1 = add nsw i32 %245, -7
  %246 = tail call float @llvm.amdgcn.ldexp.f32(float 1.875000e+00, i32 %sub.i.i.2.1) #3
  %cmp2.i.2.1 = fcmp olt float %246, %mul61.1
  %add4.i.2.1 = add nuw nsw i32 %div.i.2.1, 1
  %hi.1.i.2.1 = select i1 %cmp2.i.2.1, i32 %hi.1.i.1.1, i32 %div.i.2.1
  %lo.1.i.2.1 = select i1 %cmp2.i.2.1, i32 %add4.i.2.1, i32 %lo.1.i.1.1
  %add.i381.3.1 = add nuw nsw i32 %lo.1.i.2.1, %hi.1.i.2.1
  %div.i.3.1 = lshr i32 %add.i381.3.1, 1
  %247 = lshr i32 %add.i381.3.1, 4
  %and.i.i.3.1 = and i32 %div.i.3.1, 7
  %tobool.not.i.i.3.1 = icmp eq i32 %247, 0
  %conv1.i.i.3.1 = sitofp i32 %and.i.i.3.1 to float
  br i1 %tobool.not.i.i.3.1, label %cond.false.i.i.3.1, label %cond.true.i.i.3.1, !decision.origin !437

cond.true.i.i.3.1:                                ; preds = %_Z4dec8i.exit.i.2.1
  %mul.i.i.3.1 = fmul float %conv1.i.i.3.1, 1.250000e-01
  %add.i.i.3.1 = fadd float %mul.i.i.3.1, 1.000000e+00
  %sub.i.i.3.1 = add nsw i32 %247, -7
  %248 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i.i.3.1, i32 %sub.i.i.3.1) #3
  br label %_Z4dec8i.exit.i.3.1, !decision.origin !438

cond.false.i.i.3.1:                               ; preds = %_Z4dec8i.exit.i.2.1
  %mul2.i.i.3.1 = fmul float %conv1.i.i.3.1, 0x3F60000000000000
  br label %_Z4dec8i.exit.i.3.1, !decision.origin !439

_Z4dec8i.exit.i.3.1:                              ; preds = %cond.false.i.i.3.1, %cond.true.i.i.3.1
  %cond.i.i.3.1 = phi float [ %248, %cond.true.i.i.3.1 ], [ %mul2.i.i.3.1, %cond.false.i.i.3.1 ]
  %cmp2.i.3.1 = fcmp olt float %cond.i.i.3.1, %mul61.1
  %add4.i.3.1 = add nuw nsw i32 %div.i.3.1, 1
  %hi.1.i.3.1 = select i1 %cmp2.i.3.1, i32 %hi.1.i.2.1, i32 %div.i.3.1
  %lo.1.i.3.1 = select i1 %cmp2.i.3.1, i32 %add4.i.3.1, i32 %lo.1.i.2.1
  %add.i381.4.1 = add nuw nsw i32 %lo.1.i.3.1, %hi.1.i.3.1
  %div.i.4.1 = lshr i32 %add.i381.4.1, 1
  %249 = lshr i32 %add.i381.4.1, 4
  %and.i.i.4.1 = and i32 %div.i.4.1, 7
  %tobool.not.i.i.4.1 = icmp eq i32 %249, 0
  %conv1.i.i.4.1 = sitofp i32 %and.i.i.4.1 to float
  br i1 %tobool.not.i.i.4.1, label %cond.false.i.i.4.1, label %cond.true.i.i.4.1, !decision.origin !440

cond.true.i.i.4.1:                                ; preds = %_Z4dec8i.exit.i.3.1
  %mul.i.i.4.1 = fmul float %conv1.i.i.4.1, 1.250000e-01
  %add.i.i.4.1 = fadd float %mul.i.i.4.1, 1.000000e+00
  %sub.i.i.4.1 = add nsw i32 %249, -7
  %250 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i.i.4.1, i32 %sub.i.i.4.1) #3
  br label %_Z4dec8i.exit.i.4.1, !decision.origin !441

cond.false.i.i.4.1:                               ; preds = %_Z4dec8i.exit.i.3.1
  %mul2.i.i.4.1 = fmul float %conv1.i.i.4.1, 0x3F60000000000000
  br label %_Z4dec8i.exit.i.4.1, !decision.origin !442

_Z4dec8i.exit.i.4.1:                              ; preds = %cond.false.i.i.4.1, %cond.true.i.i.4.1
  %cond.i.i.4.1 = phi float [ %250, %cond.true.i.i.4.1 ], [ %mul2.i.i.4.1, %cond.false.i.i.4.1 ]
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
  br i1 %tobool.not.i.i.5.1, label %cond.false.i.i.5.1, label %cond.true.i.i.5.1, !decision.origin !443

cond.true.i.i.5.1:                                ; preds = %_Z4dec8i.exit.i.4.1
  %mul.i.i.5.1 = fmul float %conv1.i.i.5.1, 1.250000e-01
  %add.i.i.5.1 = fadd float %mul.i.i.5.1, 1.000000e+00
  %sub.i.i.5.1 = add nsw i32 %shr.i.i.5.1, -7
  %251 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i.i.5.1, i32 %sub.i.i.5.1) #3
  br label %_Z4dec8i.exit.i.5.1, !decision.origin !444

cond.false.i.i.5.1:                               ; preds = %_Z4dec8i.exit.i.4.1
  %mul2.i.i.5.1 = fmul float %conv1.i.i.5.1, 0x3F60000000000000
  br label %_Z4dec8i.exit.i.5.1, !decision.origin !445

_Z4dec8i.exit.i.5.1:                              ; preds = %cond.false.i.i.5.1, %cond.true.i.i.5.1
  %cond.i.i.5.1 = phi float [ %251, %cond.true.i.i.5.1 ], [ %mul2.i.i.5.1, %cond.false.i.i.5.1 ]
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
  br i1 %tobool.not.i.i.6.1, label %cond.false.i.i.6.1, label %cond.true.i.i.6.1, !decision.origin !446

cond.true.i.i.6.1:                                ; preds = %_Z4dec8i.exit.i.5.1
  %mul.i.i.6.1 = fmul float %conv1.i.i.6.1, 1.250000e-01
  %add.i.i.6.1 = fadd float %mul.i.i.6.1, 1.000000e+00
  %sub.i.i.6.1 = add nsw i32 %shr.i.i.6.1, -7
  %252 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i.i.6.1, i32 %sub.i.i.6.1) #3
  br label %_Z4dec8i.exit.i.6.1, !decision.origin !447

cond.false.i.i.6.1:                               ; preds = %_Z4dec8i.exit.i.5.1
  %mul2.i.i.6.1 = fmul float %conv1.i.i.6.1, 0x3F60000000000000
  br label %_Z4dec8i.exit.i.6.1, !decision.origin !448

_Z4dec8i.exit.i.6.1:                              ; preds = %cond.false.i.i.6.1, %cond.true.i.i.6.1
  %cond.i.i.6.1 = phi float [ %252, %cond.true.i.i.6.1 ], [ %mul2.i.i.6.1, %cond.false.i.i.6.1 ]
  %cmp2.i.6.1 = fcmp olt float %cond.i.i.6.1, %mul61.1
  %add4.i.6.1 = add nuw nsw i32 %div.i.6.1, 1
  %lo.1.i.6.1 = select i1 %cmp2.i.6.1, i32 %add4.i.6.1, i32 %lo.1.i.5.1
  %cmp6.i.1 = icmp eq i32 %lo.1.i.6.1, 0
  br i1 %cmp6.i.1, label %_Z4enc8f.exit.thread.1, label %if.end9.i.1, !decision.origin !449

if.end9.i.1:                                      ; preds = %_Z4dec8i.exit.i.6.1
  %sub.i382.1 = add nsw i32 %lo.1.i.6.1, -1
  %shr.i62.i.1 = ashr i32 %sub.i382.1, 3
  %and.i63.i.1 = and i32 %sub.i382.1, 7
  %tobool.not.i64.i.1 = icmp eq i32 %shr.i62.i.1, 0
  %conv1.i70.i.1 = sitofp i32 %and.i63.i.1 to float
  br i1 %tobool.not.i64.i.1, label %cond.false.i72.i.1, label %cond.true.i69.i.1, !decision.origin !450

cond.true.i69.i.1:                                ; preds = %if.end9.i.1
  %mul.i66.i.1 = fmul float %conv1.i70.i.1, 1.250000e-01
  %add.i67.i.1 = fadd float %mul.i66.i.1, 1.000000e+00
  %sub.i68.i.1 = add nsw i32 %shr.i62.i.1, -7
  %253 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i67.i.1, i32 %sub.i68.i.1) #3
  br label %_Z4dec8i.exit74.i.1, !decision.origin !451

cond.false.i72.i.1:                               ; preds = %if.end9.i.1
  %mul2.i71.i.1 = fmul float %conv1.i70.i.1, 0x3F60000000000000
  br label %_Z4dec8i.exit74.i.1, !decision.origin !452

_Z4dec8i.exit74.i.1:                              ; preds = %cond.false.i72.i.1, %cond.true.i69.i.1
  %cond.i73.i.1 = phi float [ %253, %cond.true.i69.i.1 ], [ %mul2.i71.i.1, %cond.false.i72.i.1 ]
  %sub11.i.1 = fsub float %mul61.1, %cond.i73.i.1
  %shr.i49.i.1656 = lshr i32 %lo.1.i.6.1, 3
  %and.i50.i.1 = and i32 %lo.1.i.6.1, 7
  %tobool.not.i51.i.1 = icmp eq i32 %shr.i49.i.1656, 0
  %conv1.i57.i.1 = sitofp i32 %and.i50.i.1 to float
  br i1 %tobool.not.i51.i.1, label %cond.false.i59.i.1, label %cond.true.i56.i.1, !decision.origin !453

cond.true.i56.i.1:                                ; preds = %_Z4dec8i.exit74.i.1
  %mul.i53.i.1 = fmul float %conv1.i57.i.1, 1.250000e-01
  %add.i54.i.1 = fadd float %mul.i53.i.1, 1.000000e+00
  %sub.i55.i.1 = add nsw i32 %shr.i49.i.1656, -7
  %254 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i54.i.1, i32 %sub.i55.i.1) #3
  br label %_Z4dec8i.exit61.i.1, !decision.origin !454

cond.false.i59.i.1:                               ; preds = %_Z4dec8i.exit74.i.1
  %mul2.i58.i.1 = fmul float %conv1.i57.i.1, 0x3F60000000000000
  br label %_Z4dec8i.exit61.i.1, !decision.origin !455

_Z4dec8i.exit61.i.1:                              ; preds = %cond.false.i59.i.1, %cond.true.i56.i.1
  %cond.i60.i.1 = phi float [ %254, %cond.true.i56.i.1 ], [ %mul2.i58.i.1, %cond.false.i59.i.1 ]
  %sub13.i.1 = fsub float %cond.i60.i.1, %mul61.1
  %cmp14.i.1 = fcmp olt float %sub11.i.1, %sub13.i.1
  br i1 %cmp14.i.1, label %_Z4enc8f.exit.1, label %cond.false.i384.1, !decision.origin !456

cond.false.i384.1:                                ; preds = %_Z4dec8i.exit61.i.1
  %cmp16.i383.1 = fcmp olt float %sub13.i.1, %sub11.i.1
  %and.i385.1 = and i32 %lo.1.i.6.1, 1
  %tobool.not.i386.1 = icmp eq i32 %and.i385.1, 0
  %cond.i387.1 = select i1 %tobool.not.i386.1, i32 %lo.1.i.6.1, i32 %sub.i382.1
  br i1 %cmp16.i383.1, label %_Z4enc8f.exit.1, label %cond.false18.i.1, !decision.origin !457

cond.false18.i.1:                                 ; preds = %cond.false.i384.1
  %.pre = and i32 %cond.i387.1, 7
  br label %_Z4enc8f.exit.1, !decision.origin !458

_Z4enc8f.exit.1:                                  ; preds = %cond.false18.i.1, %cond.false.i384.1, %_Z4dec8i.exit61.i.1
  %and.i375.1.pre-phi = phi i32 [ %.pre, %cond.false18.i.1 ], [ %and.i50.i.1, %cond.false.i384.1 ], [ %and.i63.i.1, %_Z4dec8i.exit61.i.1 ]
  %cond25.i.1 = phi i32 [ %cond.i387.1, %cond.false18.i.1 ], [ %lo.1.i.6.1, %cond.false.i384.1 ], [ %sub.i382.1, %_Z4dec8i.exit61.i.1 ]
  %conv.i388.1 = trunc i32 %cond25.i.1 to i8
  store i8 %conv.i388.1, i8 addrspace(5)* %arrayidx64340398.1, align 1, !tbaa !18
  %conv67.1 = lshr i32 %cond25.i.1, 3
  %tobool.not.i.1 = icmp eq i32 %conv67.1, 0
  br i1 %tobool.not.i.1, label %cond.false.i377.1, label %cond.true.i.1, !decision.origin !459

cond.true.i.1:                                    ; preds = %_Z4enc8f.exit.1, %_Z4enc8f.exit.thread396.1
  %and.i375404.1 = phi i32 [ 6, %_Z4enc8f.exit.thread396.1 ], [ %and.i375.1.pre-phi, %_Z4enc8f.exit.1 ]
  %shr.i374403.1 = phi i32 [ 15, %_Z4enc8f.exit.thread396.1 ], [ %conv67.1, %_Z4enc8f.exit.1 ]
  %conv.i376.1 = sitofp i32 %and.i375404.1 to float
  %mul.i.1 = fmul float %conv.i376.1, 1.250000e-01
  %add.i.1 = fadd float %mul.i.1, 1.000000e+00
  %sub.i.1 = add nsw i32 %shr.i374403.1, -7
  %255 = tail call float @llvm.amdgcn.ldexp.f32(float %add.i.1, i32 %sub.i.1) #3
  br label %_Z4dec8i.exit.1, !decision.origin !460

_Z4enc8f.exit.thread.1:                           ; preds = %_Z4dec8i.exit.i.6.1
  store i8 0, i8 addrspace(5)* %arrayidx64340398.1, align 1, !tbaa !18
  br label %cond.false.i377.1, !decision.origin !461

cond.false.i377.1:                                ; preds = %_Z4enc8f.exit.thread.1, %_Z4enc8f.exit.1
  %and.i375395.1 = phi i32 [ 0, %_Z4enc8f.exit.thread.1 ], [ %and.i375.1.pre-phi, %_Z4enc8f.exit.1 ]
  %conv1.i.1 = sitofp i32 %and.i375395.1 to float
  %mul2.i.1 = fmul float %conv1.i.1, 0x3F60000000000000
  br label %_Z4dec8i.exit.1, !decision.origin !462

_Z4dec8i.exit.1:                                  ; preds = %cond.false.i377.1, %cond.true.i.1
  %cond.i378.1 = phi float [ %255, %cond.true.i.1 ], [ %mul2.i.1, %cond.false.i377.1 ]
  %cmp69.1 = fcmp une float %cond.i378.1, 0.000000e+00
  br i1 %cmp69.1, label %cond.end75.1, label %cond.end75.1.thread, !decision.origin !463

cond.end75.1.thread:                              ; preds = %_Z4dec8i.exit.1
  %256 = insertelement <2 x float> %os.sroa.0.4, float 0.000000e+00, i32 1
  br label %if.then97.7.1, !decision.origin !464

cond.end75.1:                                     ; preds = %_Z4dec8i.exit.1
  %mul72.1 = fmul float %div71, %cond.i378.1
  %div73.1 = fdiv float 1.000000e+00, %mul72.1
  %257 = insertelement <2 x float> %os.sroa.0.4, float %div73.1, i32 1
  %cmp81.1 = fcmp une float %div73.1, 0.000000e+00
  %div85.1 = fdiv float 1.000000e+00, %div73.1
  %cond88.1 = select i1 %cmp81.1, float %div85.1, float 0.000000e+00
  %cmp96.1 = fcmp oeq float %div73.1, 0.000000e+00
  br i1 %cmp96.1, label %if.then97.7.1, label %if.else.7.1, !decision.origin !465

if.else.7.1:                                      ; preds = %cond.end75.1
  %mul116.1429 = fmul float %div73.1, %12
  %258 = tail call float @llvm.fabs.f32(float %mul116.1429) #3
  %cmp.i378 = fcmp ugt float %258, 2.500000e-01
  br i1 %cmp.i378, label %if.else.i381, label %if.then.i379, !decision.origin !466

if.then.i379:                                     ; preds = %if.else.7.1
  %259 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.1429) #3
  br label %quant_decide.exit399, !decision.origin !467, !decision.order !468

if.else.i381:                                     ; preds = %if.else.7.1
  %cmp2.i380 = fcmp olt float %258, 7.500000e-01
  br i1 %cmp2.i380, label %if.then3.i382, label %if.else4.i384, !decision.origin !469

if.then3.i382:                                    ; preds = %if.else.i381
  %260 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.1429) #3
  br label %quant_decide.exit399, !decision.origin !470, !decision.order !471

if.else4.i384:                                    ; preds = %if.else.i381
  %cmp6.i383 = fcmp ugt float %258, 1.250000e+00
  br i1 %cmp6.i383, label %if.else8.i387, label %if.then7.i385, !decision.origin !472

if.then7.i385:                                    ; preds = %if.else4.i384
  %261 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.1429) #3
  br label %quant_decide.exit399, !decision.origin !473, !decision.order !474

if.else8.i387:                                    ; preds = %if.else4.i384
  %cmp10.i386 = fcmp olt float %258, 1.750000e+00
  br i1 %cmp10.i386, label %if.then11.i388, label %if.else12.i390, !decision.origin !475

if.then11.i388:                                   ; preds = %if.else8.i387
  %262 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.1429) #3
  br label %quant_decide.exit399, !decision.origin !476, !decision.order !477

if.else12.i390:                                   ; preds = %if.else8.i387
  %cmp14.i389 = fcmp ugt float %258, 2.500000e+00
  br i1 %cmp14.i389, label %if.else16.i393, label %if.then15.i391, !decision.origin !478

if.then15.i391:                                   ; preds = %if.else12.i390
  %263 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.1429) #3
  br label %quant_decide.exit399, !decision.origin !479, !decision.order !480

if.else16.i393:                                   ; preds = %if.else12.i390
  %cmp18.i392 = fcmp olt float %258, 3.500000e+00
  br i1 %cmp18.i392, label %if.then19.i394, label %if.else20.i396, !decision.origin !481

if.then19.i394:                                   ; preds = %if.else16.i393
  %264 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.1429) #3
  br label %quant_decide.exit399, !decision.origin !482, !decision.order !483

if.else20.i396:                                   ; preds = %if.else16.i393
  %cmp22.i395 = fcmp ugt float %258, 5.000000e+00
  br i1 %cmp22.i395, label %if.end29.i398, label %if.then23.i397, !decision.origin !484

if.then23.i397:                                   ; preds = %if.else20.i396
  %265 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.1429) #3
  br label %quant_decide.exit399, !decision.origin !485, !decision.order !486

if.end29.i398:                                    ; preds = %if.else20.i396
  %266 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.1429) #3
  br label %quant_decide.exit399, !decision.origin !487, !decision.order !488

quant_decide.exit399:                             ; preds = %if.end29.i398, %if.then23.i397, %if.then19.i394, %if.then15.i391, %if.then11.i388, %if.then7.i385, %if.then3.i382, %if.then.i379
  %out.i372.8 = phi float [ %260, %if.then3.i382 ], [ %262, %if.then11.i388 ], [ %264, %if.then19.i394 ], [ %266, %if.end29.i398 ], [ %265, %if.then23.i397 ], [ %263, %if.then15.i391 ], [ %261, %if.then7.i385 ], [ %259, %if.then.i379 ]
  %mul118.1430 = fmul float %cond88.1, %out.i372.8
  %sub.1431 = fsub float %mul118.1430, %12
  %mul126.1433 = fmul float %div73.1, %16
  %267 = tail call float @llvm.fabs.f32(float %mul126.1433) #3
  %cmp.i356 = fcmp ugt float %267, 2.500000e-01
  br i1 %cmp.i356, label %if.else.i359, label %if.then.i357, !decision.origin !489

if.then.i357:                                     ; preds = %quant_decide.exit399
  %268 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.1433) #3
  br label %quant_decide.exit377, !decision.origin !490, !decision.order !491

if.else.i359:                                     ; preds = %quant_decide.exit399
  %cmp2.i358 = fcmp olt float %267, 7.500000e-01
  br i1 %cmp2.i358, label %if.then3.i360, label %if.else4.i362, !decision.origin !492

if.then3.i360:                                    ; preds = %if.else.i359
  %269 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.1433) #3
  br label %quant_decide.exit377, !decision.origin !493, !decision.order !494

if.else4.i362:                                    ; preds = %if.else.i359
  %cmp6.i361 = fcmp ugt float %267, 1.250000e+00
  br i1 %cmp6.i361, label %if.else8.i365, label %if.then7.i363, !decision.origin !495

if.then7.i363:                                    ; preds = %if.else4.i362
  %270 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.1433) #3
  br label %quant_decide.exit377, !decision.origin !496, !decision.order !497

if.else8.i365:                                    ; preds = %if.else4.i362
  %cmp10.i364 = fcmp olt float %267, 1.750000e+00
  br i1 %cmp10.i364, label %if.then11.i366, label %if.else12.i368, !decision.origin !498

if.then11.i366:                                   ; preds = %if.else8.i365
  %271 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.1433) #3
  br label %quant_decide.exit377, !decision.origin !499, !decision.order !500

if.else12.i368:                                   ; preds = %if.else8.i365
  %cmp14.i367 = fcmp ugt float %267, 2.500000e+00
  br i1 %cmp14.i367, label %if.else16.i371, label %if.then15.i369, !decision.origin !501

if.then15.i369:                                   ; preds = %if.else12.i368
  %272 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.1433) #3
  br label %quant_decide.exit377, !decision.origin !502, !decision.order !503

if.else16.i371:                                   ; preds = %if.else12.i368
  %cmp18.i370 = fcmp olt float %267, 3.500000e+00
  br i1 %cmp18.i370, label %if.then19.i372, label %if.else20.i374, !decision.origin !504

if.then19.i372:                                   ; preds = %if.else16.i371
  %273 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.1433) #3
  br label %quant_decide.exit377, !decision.origin !505, !decision.order !506

if.else20.i374:                                   ; preds = %if.else16.i371
  %cmp22.i373 = fcmp ugt float %267, 5.000000e+00
  br i1 %cmp22.i373, label %if.end29.i376, label %if.then23.i375, !decision.origin !507

if.then23.i375:                                   ; preds = %if.else20.i374
  %274 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.1433) #3
  br label %quant_decide.exit377, !decision.origin !508, !decision.order !509

if.end29.i376:                                    ; preds = %if.else20.i374
  %275 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.1433) #3
  br label %quant_decide.exit377, !decision.origin !510, !decision.order !511

quant_decide.exit377:                             ; preds = %if.end29.i376, %if.then23.i375, %if.then19.i372, %if.then15.i369, %if.then11.i366, %if.then7.i363, %if.then3.i360, %if.then.i357
  %out.i.8 = phi float [ %269, %if.then3.i360 ], [ %271, %if.then11.i366 ], [ %273, %if.then19.i372 ], [ %275, %if.end29.i376 ], [ %274, %if.then23.i375 ], [ %272, %if.then15.i369 ], [ %270, %if.then7.i363 ], [ %268, %if.then.i357 ]
  %mul128.1434 = fmul float %cond88.1, %out.i.8
  %sub132.1435 = fsub float %mul128.1434, %16
  %mul133.1436 = fmul float %sub.1431, %sub.1431
  %mul134.1437 = fmul float %sub132.1435, %sub132.1435
  %add135.1438 = fadd float %mul133.1436, %mul134.1437
  %e.1.1447 = fadd float %add135.1438, 0.000000e+00
  %mul116.1.1 = fmul float %div73.1, %20
  %276 = tail call float @llvm.fabs.f32(float %mul116.1.1) #3
  %cmp.i334 = fcmp ugt float %276, 2.500000e-01
  br i1 %cmp.i334, label %if.else.i337, label %if.then.i335, !decision.origin !512

if.then.i335:                                     ; preds = %quant_decide.exit377
  %277 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.1.1) #3
  br label %quant_decide.exit355, !decision.origin !513, !decision.order !514

if.else.i337:                                     ; preds = %quant_decide.exit377
  %cmp2.i336 = fcmp olt float %276, 7.500000e-01
  br i1 %cmp2.i336, label %if.then3.i338, label %if.else4.i340, !decision.origin !515

if.then3.i338:                                    ; preds = %if.else.i337
  %278 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.1.1) #3
  br label %quant_decide.exit355, !decision.origin !516, !decision.order !517

if.else4.i340:                                    ; preds = %if.else.i337
  %cmp6.i339 = fcmp ugt float %276, 1.250000e+00
  br i1 %cmp6.i339, label %if.else8.i343, label %if.then7.i341, !decision.origin !518

if.then7.i341:                                    ; preds = %if.else4.i340
  %279 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.1.1) #3
  br label %quant_decide.exit355, !decision.origin !519, !decision.order !520

if.else8.i343:                                    ; preds = %if.else4.i340
  %cmp10.i342 = fcmp olt float %276, 1.750000e+00
  br i1 %cmp10.i342, label %if.then11.i344, label %if.else12.i346, !decision.origin !521

if.then11.i344:                                   ; preds = %if.else8.i343
  %280 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.1.1) #3
  br label %quant_decide.exit355, !decision.origin !522, !decision.order !523

if.else12.i346:                                   ; preds = %if.else8.i343
  %cmp14.i345 = fcmp ugt float %276, 2.500000e+00
  br i1 %cmp14.i345, label %if.else16.i349, label %if.then15.i347, !decision.origin !524

if.then15.i347:                                   ; preds = %if.else12.i346
  %281 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.1.1) #3
  br label %quant_decide.exit355, !decision.origin !525, !decision.order !526

if.else16.i349:                                   ; preds = %if.else12.i346
  %cmp18.i348 = fcmp olt float %276, 3.500000e+00
  br i1 %cmp18.i348, label %if.then19.i350, label %if.else20.i352, !decision.origin !527

if.then19.i350:                                   ; preds = %if.else16.i349
  %282 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.1.1) #3
  br label %quant_decide.exit355, !decision.origin !528, !decision.order !529

if.else20.i352:                                   ; preds = %if.else16.i349
  %cmp22.i351 = fcmp ugt float %276, 5.000000e+00
  br i1 %cmp22.i351, label %if.end29.i354, label %if.then23.i353, !decision.origin !530

if.then23.i353:                                   ; preds = %if.else20.i352
  %283 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.1.1) #3
  br label %quant_decide.exit355, !decision.origin !531, !decision.order !532

if.end29.i354:                                    ; preds = %if.else20.i352
  %284 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.1.1) #3
  br label %quant_decide.exit355, !decision.origin !533, !decision.order !534

quant_decide.exit355:                             ; preds = %if.end29.i354, %if.then23.i353, %if.then19.i350, %if.then15.i347, %if.then11.i344, %if.then7.i341, %if.then3.i338, %if.then.i335
  %out.i372.9 = phi float [ %278, %if.then3.i338 ], [ %280, %if.then11.i344 ], [ %282, %if.then19.i350 ], [ %284, %if.end29.i354 ], [ %283, %if.then23.i353 ], [ %281, %if.then15.i347 ], [ %279, %if.then7.i341 ], [ %277, %if.then.i335 ]
  %mul118.1.1 = fmul float %cond88.1, %out.i372.9
  %sub.1.1 = fsub float %mul118.1.1, %20
  %mul126.1.1 = fmul float %div73.1, %24
  %285 = tail call float @llvm.fabs.f32(float %mul126.1.1) #3
  %cmp.i312 = fcmp ugt float %285, 2.500000e-01
  br i1 %cmp.i312, label %if.else.i315, label %if.then.i313, !decision.origin !535

if.then.i313:                                     ; preds = %quant_decide.exit355
  %286 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.1.1) #3
  br label %quant_decide.exit333, !decision.origin !536, !decision.order !537

if.else.i315:                                     ; preds = %quant_decide.exit355
  %cmp2.i314 = fcmp olt float %285, 7.500000e-01
  br i1 %cmp2.i314, label %if.then3.i316, label %if.else4.i318, !decision.origin !538

if.then3.i316:                                    ; preds = %if.else.i315
  %287 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.1.1) #3
  br label %quant_decide.exit333, !decision.origin !539, !decision.order !540

if.else4.i318:                                    ; preds = %if.else.i315
  %cmp6.i317 = fcmp ugt float %285, 1.250000e+00
  br i1 %cmp6.i317, label %if.else8.i321, label %if.then7.i319, !decision.origin !541

if.then7.i319:                                    ; preds = %if.else4.i318
  %288 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.1.1) #3
  br label %quant_decide.exit333, !decision.origin !542, !decision.order !543

if.else8.i321:                                    ; preds = %if.else4.i318
  %cmp10.i320 = fcmp olt float %285, 1.750000e+00
  br i1 %cmp10.i320, label %if.then11.i322, label %if.else12.i324, !decision.origin !544

if.then11.i322:                                   ; preds = %if.else8.i321
  %289 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.1.1) #3
  br label %quant_decide.exit333, !decision.origin !545, !decision.order !546

if.else12.i324:                                   ; preds = %if.else8.i321
  %cmp14.i323 = fcmp ugt float %285, 2.500000e+00
  br i1 %cmp14.i323, label %if.else16.i327, label %if.then15.i325, !decision.origin !547

if.then15.i325:                                   ; preds = %if.else12.i324
  %290 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.1.1) #3
  br label %quant_decide.exit333, !decision.origin !548, !decision.order !549

if.else16.i327:                                   ; preds = %if.else12.i324
  %cmp18.i326 = fcmp olt float %285, 3.500000e+00
  br i1 %cmp18.i326, label %if.then19.i328, label %if.else20.i330, !decision.origin !550

if.then19.i328:                                   ; preds = %if.else16.i327
  %291 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.1.1) #3
  br label %quant_decide.exit333, !decision.origin !551, !decision.order !552

if.else20.i330:                                   ; preds = %if.else16.i327
  %cmp22.i329 = fcmp ugt float %285, 5.000000e+00
  br i1 %cmp22.i329, label %if.end29.i332, label %if.then23.i331, !decision.origin !553

if.then23.i331:                                   ; preds = %if.else20.i330
  %292 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.1.1) #3
  br label %quant_decide.exit333, !decision.origin !554, !decision.order !555

if.end29.i332:                                    ; preds = %if.else20.i330
  %293 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.1.1) #3
  br label %quant_decide.exit333, !decision.origin !556, !decision.order !557

quant_decide.exit333:                             ; preds = %if.end29.i332, %if.then23.i331, %if.then19.i328, %if.then15.i325, %if.then11.i322, %if.then7.i319, %if.then3.i316, %if.then.i313
  %out.i.9 = phi float [ %287, %if.then3.i316 ], [ %289, %if.then11.i322 ], [ %291, %if.then19.i328 ], [ %293, %if.end29.i332 ], [ %292, %if.then23.i331 ], [ %290, %if.then15.i325 ], [ %288, %if.then7.i319 ], [ %286, %if.then.i313 ]
  %mul128.1.1 = fmul float %cond88.1, %out.i.9
  %sub132.1.1 = fsub float %mul128.1.1, %24
  %mul133.1.1 = fmul float %sub.1.1, %sub.1.1
  %mul134.1.1 = fmul float %sub132.1.1, %sub132.1.1
  %add135.1.1 = fadd float %mul133.1.1, %mul134.1.1
  %e.1.1.1 = fadd float %e.1.1447, %add135.1.1
  %mul116.2.1 = fmul float %div73.1, %28
  %294 = tail call float @llvm.fabs.f32(float %mul116.2.1) #3
  %cmp.i290 = fcmp ugt float %294, 2.500000e-01
  br i1 %cmp.i290, label %if.else.i293, label %if.then.i291, !decision.origin !558

if.then.i291:                                     ; preds = %quant_decide.exit333
  %295 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.2.1) #3
  br label %quant_decide.exit311, !decision.origin !559, !decision.order !560

if.else.i293:                                     ; preds = %quant_decide.exit333
  %cmp2.i292 = fcmp olt float %294, 7.500000e-01
  br i1 %cmp2.i292, label %if.then3.i294, label %if.else4.i296, !decision.origin !561

if.then3.i294:                                    ; preds = %if.else.i293
  %296 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.2.1) #3
  br label %quant_decide.exit311, !decision.origin !562, !decision.order !563

if.else4.i296:                                    ; preds = %if.else.i293
  %cmp6.i295 = fcmp ugt float %294, 1.250000e+00
  br i1 %cmp6.i295, label %if.else8.i299, label %if.then7.i297, !decision.origin !564

if.then7.i297:                                    ; preds = %if.else4.i296
  %297 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.2.1) #3
  br label %quant_decide.exit311, !decision.origin !565, !decision.order !566

if.else8.i299:                                    ; preds = %if.else4.i296
  %cmp10.i298 = fcmp olt float %294, 1.750000e+00
  br i1 %cmp10.i298, label %if.then11.i300, label %if.else12.i302, !decision.origin !567

if.then11.i300:                                   ; preds = %if.else8.i299
  %298 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.2.1) #3
  br label %quant_decide.exit311, !decision.origin !568, !decision.order !569

if.else12.i302:                                   ; preds = %if.else8.i299
  %cmp14.i301 = fcmp ugt float %294, 2.500000e+00
  br i1 %cmp14.i301, label %if.else16.i305, label %if.then15.i303, !decision.origin !570

if.then15.i303:                                   ; preds = %if.else12.i302
  %299 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.2.1) #3
  br label %quant_decide.exit311, !decision.origin !571, !decision.order !572

if.else16.i305:                                   ; preds = %if.else12.i302
  %cmp18.i304 = fcmp olt float %294, 3.500000e+00
  br i1 %cmp18.i304, label %if.then19.i306, label %if.else20.i308, !decision.origin !573

if.then19.i306:                                   ; preds = %if.else16.i305
  %300 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.2.1) #3
  br label %quant_decide.exit311, !decision.origin !574, !decision.order !575

if.else20.i308:                                   ; preds = %if.else16.i305
  %cmp22.i307 = fcmp ugt float %294, 5.000000e+00
  br i1 %cmp22.i307, label %if.end29.i310, label %if.then23.i309, !decision.origin !576

if.then23.i309:                                   ; preds = %if.else20.i308
  %301 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.2.1) #3
  br label %quant_decide.exit311, !decision.origin !577, !decision.order !578

if.end29.i310:                                    ; preds = %if.else20.i308
  %302 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.2.1) #3
  br label %quant_decide.exit311, !decision.origin !579, !decision.order !580

quant_decide.exit311:                             ; preds = %if.end29.i310, %if.then23.i309, %if.then19.i306, %if.then15.i303, %if.then11.i300, %if.then7.i297, %if.then3.i294, %if.then.i291
  %out.i372.10 = phi float [ %296, %if.then3.i294 ], [ %298, %if.then11.i300 ], [ %300, %if.then19.i306 ], [ %302, %if.end29.i310 ], [ %301, %if.then23.i309 ], [ %299, %if.then15.i303 ], [ %297, %if.then7.i297 ], [ %295, %if.then.i291 ]
  %mul118.2.1 = fmul float %cond88.1, %out.i372.10
  %sub.2.1 = fsub float %mul118.2.1, %28
  %mul126.2.1 = fmul float %div73.1, %32
  %303 = tail call float @llvm.fabs.f32(float %mul126.2.1) #3
  %cmp.i268 = fcmp ugt float %303, 2.500000e-01
  br i1 %cmp.i268, label %if.else.i271, label %if.then.i269, !decision.origin !581

if.then.i269:                                     ; preds = %quant_decide.exit311
  %304 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.2.1) #3
  br label %quant_decide.exit289, !decision.origin !582, !decision.order !583

if.else.i271:                                     ; preds = %quant_decide.exit311
  %cmp2.i270 = fcmp olt float %303, 7.500000e-01
  br i1 %cmp2.i270, label %if.then3.i272, label %if.else4.i274, !decision.origin !584

if.then3.i272:                                    ; preds = %if.else.i271
  %305 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.2.1) #3
  br label %quant_decide.exit289, !decision.origin !585, !decision.order !586

if.else4.i274:                                    ; preds = %if.else.i271
  %cmp6.i273 = fcmp ugt float %303, 1.250000e+00
  br i1 %cmp6.i273, label %if.else8.i277, label %if.then7.i275, !decision.origin !587

if.then7.i275:                                    ; preds = %if.else4.i274
  %306 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.2.1) #3
  br label %quant_decide.exit289, !decision.origin !588, !decision.order !589

if.else8.i277:                                    ; preds = %if.else4.i274
  %cmp10.i276 = fcmp olt float %303, 1.750000e+00
  br i1 %cmp10.i276, label %if.then11.i278, label %if.else12.i280, !decision.origin !590

if.then11.i278:                                   ; preds = %if.else8.i277
  %307 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.2.1) #3
  br label %quant_decide.exit289, !decision.origin !591, !decision.order !592

if.else12.i280:                                   ; preds = %if.else8.i277
  %cmp14.i279 = fcmp ugt float %303, 2.500000e+00
  br i1 %cmp14.i279, label %if.else16.i283, label %if.then15.i281, !decision.origin !593

if.then15.i281:                                   ; preds = %if.else12.i280
  %308 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.2.1) #3
  br label %quant_decide.exit289, !decision.origin !594, !decision.order !595

if.else16.i283:                                   ; preds = %if.else12.i280
  %cmp18.i282 = fcmp olt float %303, 3.500000e+00
  br i1 %cmp18.i282, label %if.then19.i284, label %if.else20.i286, !decision.origin !596

if.then19.i284:                                   ; preds = %if.else16.i283
  %309 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.2.1) #3
  br label %quant_decide.exit289, !decision.origin !597, !decision.order !598

if.else20.i286:                                   ; preds = %if.else16.i283
  %cmp22.i285 = fcmp ugt float %303, 5.000000e+00
  br i1 %cmp22.i285, label %if.end29.i288, label %if.then23.i287, !decision.origin !599

if.then23.i287:                                   ; preds = %if.else20.i286
  %310 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.2.1) #3
  br label %quant_decide.exit289, !decision.origin !600, !decision.order !601

if.end29.i288:                                    ; preds = %if.else20.i286
  %311 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.2.1) #3
  br label %quant_decide.exit289, !decision.origin !602, !decision.order !603

quant_decide.exit289:                             ; preds = %if.end29.i288, %if.then23.i287, %if.then19.i284, %if.then15.i281, %if.then11.i278, %if.then7.i275, %if.then3.i272, %if.then.i269
  %out.i.10 = phi float [ %305, %if.then3.i272 ], [ %307, %if.then11.i278 ], [ %309, %if.then19.i284 ], [ %311, %if.end29.i288 ], [ %310, %if.then23.i287 ], [ %308, %if.then15.i281 ], [ %306, %if.then7.i275 ], [ %304, %if.then.i269 ]
  %mul128.2.1 = fmul float %cond88.1, %out.i.10
  %sub132.2.1 = fsub float %mul128.2.1, %32
  %mul133.2.1 = fmul float %sub.2.1, %sub.2.1
  %mul134.2.1 = fmul float %sub132.2.1, %sub132.2.1
  %add135.2.1 = fadd float %mul133.2.1, %mul134.2.1
  %e.1.2.1 = fadd float %e.1.1.1, %add135.2.1
  %mul116.3.1 = fmul float %div73.1, %36
  %312 = tail call float @llvm.fabs.f32(float %mul116.3.1) #3
  %cmp.i246 = fcmp ugt float %312, 2.500000e-01
  br i1 %cmp.i246, label %if.else.i249, label %if.then.i247, !decision.origin !604

if.then.i247:                                     ; preds = %quant_decide.exit289
  %313 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.3.1) #3
  br label %quant_decide.exit267, !decision.origin !605, !decision.order !606

if.else.i249:                                     ; preds = %quant_decide.exit289
  %cmp2.i248 = fcmp olt float %312, 7.500000e-01
  br i1 %cmp2.i248, label %if.then3.i250, label %if.else4.i252, !decision.origin !607

if.then3.i250:                                    ; preds = %if.else.i249
  %314 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.3.1) #3
  br label %quant_decide.exit267, !decision.origin !608, !decision.order !609

if.else4.i252:                                    ; preds = %if.else.i249
  %cmp6.i251 = fcmp ugt float %312, 1.250000e+00
  br i1 %cmp6.i251, label %if.else8.i255, label %if.then7.i253, !decision.origin !610

if.then7.i253:                                    ; preds = %if.else4.i252
  %315 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.3.1) #3
  br label %quant_decide.exit267, !decision.origin !611, !decision.order !612

if.else8.i255:                                    ; preds = %if.else4.i252
  %cmp10.i254 = fcmp olt float %312, 1.750000e+00
  br i1 %cmp10.i254, label %if.then11.i256, label %if.else12.i258, !decision.origin !613

if.then11.i256:                                   ; preds = %if.else8.i255
  %316 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.3.1) #3
  br label %quant_decide.exit267, !decision.origin !614, !decision.order !615

if.else12.i258:                                   ; preds = %if.else8.i255
  %cmp14.i257 = fcmp ugt float %312, 2.500000e+00
  br i1 %cmp14.i257, label %if.else16.i261, label %if.then15.i259, !decision.origin !616

if.then15.i259:                                   ; preds = %if.else12.i258
  %317 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.3.1) #3
  br label %quant_decide.exit267, !decision.origin !617, !decision.order !618

if.else16.i261:                                   ; preds = %if.else12.i258
  %cmp18.i260 = fcmp olt float %312, 3.500000e+00
  br i1 %cmp18.i260, label %if.then19.i262, label %if.else20.i264, !decision.origin !619

if.then19.i262:                                   ; preds = %if.else16.i261
  %318 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.3.1) #3
  br label %quant_decide.exit267, !decision.origin !620, !decision.order !621

if.else20.i264:                                   ; preds = %if.else16.i261
  %cmp22.i263 = fcmp ugt float %312, 5.000000e+00
  br i1 %cmp22.i263, label %if.end29.i266, label %if.then23.i265, !decision.origin !622

if.then23.i265:                                   ; preds = %if.else20.i264
  %319 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.3.1) #3
  br label %quant_decide.exit267, !decision.origin !623, !decision.order !624

if.end29.i266:                                    ; preds = %if.else20.i264
  %320 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.3.1) #3
  br label %quant_decide.exit267, !decision.origin !625, !decision.order !626

quant_decide.exit267:                             ; preds = %if.end29.i266, %if.then23.i265, %if.then19.i262, %if.then15.i259, %if.then11.i256, %if.then7.i253, %if.then3.i250, %if.then.i247
  %out.i372.11 = phi float [ %314, %if.then3.i250 ], [ %316, %if.then11.i256 ], [ %318, %if.then19.i262 ], [ %320, %if.end29.i266 ], [ %319, %if.then23.i265 ], [ %317, %if.then15.i259 ], [ %315, %if.then7.i253 ], [ %313, %if.then.i247 ]
  %mul118.3.1 = fmul float %cond88.1, %out.i372.11
  %sub.3.1 = fsub float %mul118.3.1, %36
  %mul126.3.1 = fmul float %div73.1, %40
  %321 = tail call float @llvm.fabs.f32(float %mul126.3.1) #3
  %cmp.i224 = fcmp ugt float %321, 2.500000e-01
  br i1 %cmp.i224, label %if.else.i227, label %if.then.i225, !decision.origin !627

if.then.i225:                                     ; preds = %quant_decide.exit267
  %322 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.3.1) #3
  br label %quant_decide.exit245, !decision.origin !628, !decision.order !629

if.else.i227:                                     ; preds = %quant_decide.exit267
  %cmp2.i226 = fcmp olt float %321, 7.500000e-01
  br i1 %cmp2.i226, label %if.then3.i228, label %if.else4.i230, !decision.origin !630

if.then3.i228:                                    ; preds = %if.else.i227
  %323 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.3.1) #3
  br label %quant_decide.exit245, !decision.origin !631, !decision.order !632

if.else4.i230:                                    ; preds = %if.else.i227
  %cmp6.i229 = fcmp ugt float %321, 1.250000e+00
  br i1 %cmp6.i229, label %if.else8.i233, label %if.then7.i231, !decision.origin !633

if.then7.i231:                                    ; preds = %if.else4.i230
  %324 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.3.1) #3
  br label %quant_decide.exit245, !decision.origin !634, !decision.order !635

if.else8.i233:                                    ; preds = %if.else4.i230
  %cmp10.i232 = fcmp olt float %321, 1.750000e+00
  br i1 %cmp10.i232, label %if.then11.i234, label %if.else12.i236, !decision.origin !636

if.then11.i234:                                   ; preds = %if.else8.i233
  %325 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.3.1) #3
  br label %quant_decide.exit245, !decision.origin !637, !decision.order !638

if.else12.i236:                                   ; preds = %if.else8.i233
  %cmp14.i235 = fcmp ugt float %321, 2.500000e+00
  br i1 %cmp14.i235, label %if.else16.i239, label %if.then15.i237, !decision.origin !639

if.then15.i237:                                   ; preds = %if.else12.i236
  %326 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.3.1) #3
  br label %quant_decide.exit245, !decision.origin !640, !decision.order !641

if.else16.i239:                                   ; preds = %if.else12.i236
  %cmp18.i238 = fcmp olt float %321, 3.500000e+00
  br i1 %cmp18.i238, label %if.then19.i240, label %if.else20.i242, !decision.origin !642

if.then19.i240:                                   ; preds = %if.else16.i239
  %327 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.3.1) #3
  br label %quant_decide.exit245, !decision.origin !643, !decision.order !644

if.else20.i242:                                   ; preds = %if.else16.i239
  %cmp22.i241 = fcmp ugt float %321, 5.000000e+00
  br i1 %cmp22.i241, label %if.end29.i244, label %if.then23.i243, !decision.origin !645

if.then23.i243:                                   ; preds = %if.else20.i242
  %328 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.3.1) #3
  br label %quant_decide.exit245, !decision.origin !646, !decision.order !647

if.end29.i244:                                    ; preds = %if.else20.i242
  %329 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.3.1) #3
  br label %quant_decide.exit245, !decision.origin !648, !decision.order !649

quant_decide.exit245:                             ; preds = %if.end29.i244, %if.then23.i243, %if.then19.i240, %if.then15.i237, %if.then11.i234, %if.then7.i231, %if.then3.i228, %if.then.i225
  %out.i.11 = phi float [ %323, %if.then3.i228 ], [ %325, %if.then11.i234 ], [ %327, %if.then19.i240 ], [ %329, %if.end29.i244 ], [ %328, %if.then23.i243 ], [ %326, %if.then15.i237 ], [ %324, %if.then7.i231 ], [ %322, %if.then.i225 ]
  %mul128.3.1 = fmul float %cond88.1, %out.i.11
  %sub132.3.1 = fsub float %mul128.3.1, %40
  %mul133.3.1 = fmul float %sub.3.1, %sub.3.1
  %mul134.3.1 = fmul float %sub132.3.1, %sub132.3.1
  %add135.3.1 = fadd float %mul133.3.1, %mul134.3.1
  %e.1.3.1 = fadd float %e.1.2.1, %add135.3.1
  %mul116.4.1 = fmul float %div73.1, %44
  %330 = tail call float @llvm.fabs.f32(float %mul116.4.1) #3
  %cmp.i202 = fcmp ugt float %330, 2.500000e-01
  br i1 %cmp.i202, label %if.else.i205, label %if.then.i203, !decision.origin !650

if.then.i203:                                     ; preds = %quant_decide.exit245
  %331 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.4.1) #3
  br label %quant_decide.exit223, !decision.origin !651, !decision.order !652

if.else.i205:                                     ; preds = %quant_decide.exit245
  %cmp2.i204 = fcmp olt float %330, 7.500000e-01
  br i1 %cmp2.i204, label %if.then3.i206, label %if.else4.i208, !decision.origin !653

if.then3.i206:                                    ; preds = %if.else.i205
  %332 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.4.1) #3
  br label %quant_decide.exit223, !decision.origin !654, !decision.order !655

if.else4.i208:                                    ; preds = %if.else.i205
  %cmp6.i207 = fcmp ugt float %330, 1.250000e+00
  br i1 %cmp6.i207, label %if.else8.i211, label %if.then7.i209, !decision.origin !656

if.then7.i209:                                    ; preds = %if.else4.i208
  %333 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.4.1) #3
  br label %quant_decide.exit223, !decision.origin !657, !decision.order !658

if.else8.i211:                                    ; preds = %if.else4.i208
  %cmp10.i210 = fcmp olt float %330, 1.750000e+00
  br i1 %cmp10.i210, label %if.then11.i212, label %if.else12.i214, !decision.origin !659

if.then11.i212:                                   ; preds = %if.else8.i211
  %334 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.4.1) #3
  br label %quant_decide.exit223, !decision.origin !660, !decision.order !661

if.else12.i214:                                   ; preds = %if.else8.i211
  %cmp14.i213 = fcmp ugt float %330, 2.500000e+00
  br i1 %cmp14.i213, label %if.else16.i217, label %if.then15.i215, !decision.origin !662

if.then15.i215:                                   ; preds = %if.else12.i214
  %335 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.4.1) #3
  br label %quant_decide.exit223, !decision.origin !663, !decision.order !664

if.else16.i217:                                   ; preds = %if.else12.i214
  %cmp18.i216 = fcmp olt float %330, 3.500000e+00
  br i1 %cmp18.i216, label %if.then19.i218, label %if.else20.i220, !decision.origin !665

if.then19.i218:                                   ; preds = %if.else16.i217
  %336 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.4.1) #3
  br label %quant_decide.exit223, !decision.origin !666, !decision.order !667

if.else20.i220:                                   ; preds = %if.else16.i217
  %cmp22.i219 = fcmp ugt float %330, 5.000000e+00
  br i1 %cmp22.i219, label %if.end29.i222, label %if.then23.i221, !decision.origin !668

if.then23.i221:                                   ; preds = %if.else20.i220
  %337 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.4.1) #3
  br label %quant_decide.exit223, !decision.origin !669, !decision.order !670

if.end29.i222:                                    ; preds = %if.else20.i220
  %338 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.4.1) #3
  br label %quant_decide.exit223, !decision.origin !671, !decision.order !672

quant_decide.exit223:                             ; preds = %if.end29.i222, %if.then23.i221, %if.then19.i218, %if.then15.i215, %if.then11.i212, %if.then7.i209, %if.then3.i206, %if.then.i203
  %out.i372.12 = phi float [ %332, %if.then3.i206 ], [ %334, %if.then11.i212 ], [ %336, %if.then19.i218 ], [ %338, %if.end29.i222 ], [ %337, %if.then23.i221 ], [ %335, %if.then15.i215 ], [ %333, %if.then7.i209 ], [ %331, %if.then.i203 ]
  %mul118.4.1 = fmul float %cond88.1, %out.i372.12
  %sub.4.1 = fsub float %mul118.4.1, %44
  %mul126.4.1 = fmul float %div73.1, %48
  %339 = tail call float @llvm.fabs.f32(float %mul126.4.1) #3
  %cmp.i180 = fcmp ugt float %339, 2.500000e-01
  br i1 %cmp.i180, label %if.else.i183, label %if.then.i181, !decision.origin !673

if.then.i181:                                     ; preds = %quant_decide.exit223
  %340 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.4.1) #3
  br label %quant_decide.exit201, !decision.origin !674, !decision.order !675

if.else.i183:                                     ; preds = %quant_decide.exit223
  %cmp2.i182 = fcmp olt float %339, 7.500000e-01
  br i1 %cmp2.i182, label %if.then3.i184, label %if.else4.i186, !decision.origin !676

if.then3.i184:                                    ; preds = %if.else.i183
  %341 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.4.1) #3
  br label %quant_decide.exit201, !decision.origin !677, !decision.order !678

if.else4.i186:                                    ; preds = %if.else.i183
  %cmp6.i185 = fcmp ugt float %339, 1.250000e+00
  br i1 %cmp6.i185, label %if.else8.i189, label %if.then7.i187, !decision.origin !679

if.then7.i187:                                    ; preds = %if.else4.i186
  %342 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.4.1) #3
  br label %quant_decide.exit201, !decision.origin !680, !decision.order !681

if.else8.i189:                                    ; preds = %if.else4.i186
  %cmp10.i188 = fcmp olt float %339, 1.750000e+00
  br i1 %cmp10.i188, label %if.then11.i190, label %if.else12.i192, !decision.origin !682

if.then11.i190:                                   ; preds = %if.else8.i189
  %343 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.4.1) #3
  br label %quant_decide.exit201, !decision.origin !683, !decision.order !684

if.else12.i192:                                   ; preds = %if.else8.i189
  %cmp14.i191 = fcmp ugt float %339, 2.500000e+00
  br i1 %cmp14.i191, label %if.else16.i195, label %if.then15.i193, !decision.origin !685

if.then15.i193:                                   ; preds = %if.else12.i192
  %344 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.4.1) #3
  br label %quant_decide.exit201, !decision.origin !686, !decision.order !687

if.else16.i195:                                   ; preds = %if.else12.i192
  %cmp18.i194 = fcmp olt float %339, 3.500000e+00
  br i1 %cmp18.i194, label %if.then19.i196, label %if.else20.i198, !decision.origin !688

if.then19.i196:                                   ; preds = %if.else16.i195
  %345 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.4.1) #3
  br label %quant_decide.exit201, !decision.origin !689, !decision.order !690

if.else20.i198:                                   ; preds = %if.else16.i195
  %cmp22.i197 = fcmp ugt float %339, 5.000000e+00
  br i1 %cmp22.i197, label %if.end29.i200, label %if.then23.i199, !decision.origin !691

if.then23.i199:                                   ; preds = %if.else20.i198
  %346 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.4.1) #3
  br label %quant_decide.exit201, !decision.origin !692, !decision.order !693

if.end29.i200:                                    ; preds = %if.else20.i198
  %347 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.4.1) #3
  br label %quant_decide.exit201, !decision.origin !694, !decision.order !695

quant_decide.exit201:                             ; preds = %if.end29.i200, %if.then23.i199, %if.then19.i196, %if.then15.i193, %if.then11.i190, %if.then7.i187, %if.then3.i184, %if.then.i181
  %out.i.12 = phi float [ %341, %if.then3.i184 ], [ %343, %if.then11.i190 ], [ %345, %if.then19.i196 ], [ %347, %if.end29.i200 ], [ %346, %if.then23.i199 ], [ %344, %if.then15.i193 ], [ %342, %if.then7.i187 ], [ %340, %if.then.i181 ]
  %mul128.4.1 = fmul float %cond88.1, %out.i.12
  %sub132.4.1 = fsub float %mul128.4.1, %48
  %mul133.4.1 = fmul float %sub.4.1, %sub.4.1
  %mul134.4.1 = fmul float %sub132.4.1, %sub132.4.1
  %add135.4.1 = fadd float %mul133.4.1, %mul134.4.1
  %e.1.4.1 = fadd float %e.1.3.1, %add135.4.1
  %mul116.5.1 = fmul float %div73.1, %52
  %348 = tail call float @llvm.fabs.f32(float %mul116.5.1) #3
  %cmp.i158 = fcmp ugt float %348, 2.500000e-01
  br i1 %cmp.i158, label %if.else.i161, label %if.then.i159, !decision.origin !696

if.then.i159:                                     ; preds = %quant_decide.exit201
  %349 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.5.1) #3
  br label %quant_decide.exit179, !decision.origin !697, !decision.order !698

if.else.i161:                                     ; preds = %quant_decide.exit201
  %cmp2.i160 = fcmp olt float %348, 7.500000e-01
  br i1 %cmp2.i160, label %if.then3.i162, label %if.else4.i164, !decision.origin !699

if.then3.i162:                                    ; preds = %if.else.i161
  %350 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.5.1) #3
  br label %quant_decide.exit179, !decision.origin !700, !decision.order !701

if.else4.i164:                                    ; preds = %if.else.i161
  %cmp6.i163 = fcmp ugt float %348, 1.250000e+00
  br i1 %cmp6.i163, label %if.else8.i167, label %if.then7.i165, !decision.origin !702

if.then7.i165:                                    ; preds = %if.else4.i164
  %351 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.5.1) #3
  br label %quant_decide.exit179, !decision.origin !703, !decision.order !704

if.else8.i167:                                    ; preds = %if.else4.i164
  %cmp10.i166 = fcmp olt float %348, 1.750000e+00
  br i1 %cmp10.i166, label %if.then11.i168, label %if.else12.i170, !decision.origin !705

if.then11.i168:                                   ; preds = %if.else8.i167
  %352 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.5.1) #3
  br label %quant_decide.exit179, !decision.origin !706, !decision.order !707

if.else12.i170:                                   ; preds = %if.else8.i167
  %cmp14.i169 = fcmp ugt float %348, 2.500000e+00
  br i1 %cmp14.i169, label %if.else16.i173, label %if.then15.i171, !decision.origin !708

if.then15.i171:                                   ; preds = %if.else12.i170
  %353 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.5.1) #3
  br label %quant_decide.exit179, !decision.origin !709, !decision.order !710

if.else16.i173:                                   ; preds = %if.else12.i170
  %cmp18.i172 = fcmp olt float %348, 3.500000e+00
  br i1 %cmp18.i172, label %if.then19.i174, label %if.else20.i176, !decision.origin !711

if.then19.i174:                                   ; preds = %if.else16.i173
  %354 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.5.1) #3
  br label %quant_decide.exit179, !decision.origin !712, !decision.order !713

if.else20.i176:                                   ; preds = %if.else16.i173
  %cmp22.i175 = fcmp ugt float %348, 5.000000e+00
  br i1 %cmp22.i175, label %if.end29.i178, label %if.then23.i177, !decision.origin !714

if.then23.i177:                                   ; preds = %if.else20.i176
  %355 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.5.1) #3
  br label %quant_decide.exit179, !decision.origin !715, !decision.order !716

if.end29.i178:                                    ; preds = %if.else20.i176
  %356 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.5.1) #3
  br label %quant_decide.exit179, !decision.origin !717, !decision.order !718

quant_decide.exit179:                             ; preds = %if.end29.i178, %if.then23.i177, %if.then19.i174, %if.then15.i171, %if.then11.i168, %if.then7.i165, %if.then3.i162, %if.then.i159
  %out.i372.13 = phi float [ %350, %if.then3.i162 ], [ %352, %if.then11.i168 ], [ %354, %if.then19.i174 ], [ %356, %if.end29.i178 ], [ %355, %if.then23.i177 ], [ %353, %if.then15.i171 ], [ %351, %if.then7.i165 ], [ %349, %if.then.i159 ]
  %mul118.5.1 = fmul float %cond88.1, %out.i372.13
  %sub.5.1 = fsub float %mul118.5.1, %52
  %mul126.5.1 = fmul float %div73.1, %56
  %357 = tail call float @llvm.fabs.f32(float %mul126.5.1) #3
  %cmp.i136 = fcmp ugt float %357, 2.500000e-01
  br i1 %cmp.i136, label %if.else.i139, label %if.then.i137, !decision.origin !719

if.then.i137:                                     ; preds = %quant_decide.exit179
  %358 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.5.1) #3
  br label %quant_decide.exit157, !decision.origin !720, !decision.order !721

if.else.i139:                                     ; preds = %quant_decide.exit179
  %cmp2.i138 = fcmp olt float %357, 7.500000e-01
  br i1 %cmp2.i138, label %if.then3.i140, label %if.else4.i142, !decision.origin !722

if.then3.i140:                                    ; preds = %if.else.i139
  %359 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.5.1) #3
  br label %quant_decide.exit157, !decision.origin !723, !decision.order !724

if.else4.i142:                                    ; preds = %if.else.i139
  %cmp6.i141 = fcmp ugt float %357, 1.250000e+00
  br i1 %cmp6.i141, label %if.else8.i145, label %if.then7.i143, !decision.origin !725

if.then7.i143:                                    ; preds = %if.else4.i142
  %360 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.5.1) #3
  br label %quant_decide.exit157, !decision.origin !726, !decision.order !727

if.else8.i145:                                    ; preds = %if.else4.i142
  %cmp10.i144 = fcmp olt float %357, 1.750000e+00
  br i1 %cmp10.i144, label %if.then11.i146, label %if.else12.i148, !decision.origin !728

if.then11.i146:                                   ; preds = %if.else8.i145
  %361 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.5.1) #3
  br label %quant_decide.exit157, !decision.origin !729, !decision.order !730

if.else12.i148:                                   ; preds = %if.else8.i145
  %cmp14.i147 = fcmp ugt float %357, 2.500000e+00
  br i1 %cmp14.i147, label %if.else16.i151, label %if.then15.i149, !decision.origin !731

if.then15.i149:                                   ; preds = %if.else12.i148
  %362 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.5.1) #3
  br label %quant_decide.exit157, !decision.origin !732, !decision.order !733

if.else16.i151:                                   ; preds = %if.else12.i148
  %cmp18.i150 = fcmp olt float %357, 3.500000e+00
  br i1 %cmp18.i150, label %if.then19.i152, label %if.else20.i154, !decision.origin !734

if.then19.i152:                                   ; preds = %if.else16.i151
  %363 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.5.1) #3
  br label %quant_decide.exit157, !decision.origin !735, !decision.order !736

if.else20.i154:                                   ; preds = %if.else16.i151
  %cmp22.i153 = fcmp ugt float %357, 5.000000e+00
  br i1 %cmp22.i153, label %if.end29.i156, label %if.then23.i155, !decision.origin !737

if.then23.i155:                                   ; preds = %if.else20.i154
  %364 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.5.1) #3
  br label %quant_decide.exit157, !decision.origin !738, !decision.order !739

if.end29.i156:                                    ; preds = %if.else20.i154
  %365 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.5.1) #3
  br label %quant_decide.exit157, !decision.origin !740, !decision.order !741

quant_decide.exit157:                             ; preds = %if.end29.i156, %if.then23.i155, %if.then19.i152, %if.then15.i149, %if.then11.i146, %if.then7.i143, %if.then3.i140, %if.then.i137
  %out.i.13 = phi float [ %359, %if.then3.i140 ], [ %361, %if.then11.i146 ], [ %363, %if.then19.i152 ], [ %365, %if.end29.i156 ], [ %364, %if.then23.i155 ], [ %362, %if.then15.i149 ], [ %360, %if.then7.i143 ], [ %358, %if.then.i137 ]
  %mul128.5.1 = fmul float %cond88.1, %out.i.13
  %sub132.5.1 = fsub float %mul128.5.1, %56
  %mul133.5.1 = fmul float %sub.5.1, %sub.5.1
  %mul134.5.1 = fmul float %sub132.5.1, %sub132.5.1
  %add135.5.1 = fadd float %mul133.5.1, %mul134.5.1
  %e.1.5.1 = fadd float %e.1.4.1, %add135.5.1
  %mul116.6.1 = fmul float %div73.1, %60
  %366 = tail call float @llvm.fabs.f32(float %mul116.6.1) #3
  %cmp.i114 = fcmp ugt float %366, 2.500000e-01
  br i1 %cmp.i114, label %if.else.i117, label %if.then.i115, !decision.origin !742

if.then.i115:                                     ; preds = %quant_decide.exit157
  %367 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.6.1) #3
  br label %quant_decide.exit135, !decision.origin !743, !decision.order !744

if.else.i117:                                     ; preds = %quant_decide.exit157
  %cmp2.i116 = fcmp olt float %366, 7.500000e-01
  br i1 %cmp2.i116, label %if.then3.i118, label %if.else4.i120, !decision.origin !745

if.then3.i118:                                    ; preds = %if.else.i117
  %368 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.6.1) #3
  br label %quant_decide.exit135, !decision.origin !746, !decision.order !747

if.else4.i120:                                    ; preds = %if.else.i117
  %cmp6.i119 = fcmp ugt float %366, 1.250000e+00
  br i1 %cmp6.i119, label %if.else8.i123, label %if.then7.i121, !decision.origin !748

if.then7.i121:                                    ; preds = %if.else4.i120
  %369 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.6.1) #3
  br label %quant_decide.exit135, !decision.origin !749, !decision.order !750

if.else8.i123:                                    ; preds = %if.else4.i120
  %cmp10.i122 = fcmp olt float %366, 1.750000e+00
  br i1 %cmp10.i122, label %if.then11.i124, label %if.else12.i126, !decision.origin !751

if.then11.i124:                                   ; preds = %if.else8.i123
  %370 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.6.1) #3
  br label %quant_decide.exit135, !decision.origin !752, !decision.order !753

if.else12.i126:                                   ; preds = %if.else8.i123
  %cmp14.i125 = fcmp ugt float %366, 2.500000e+00
  br i1 %cmp14.i125, label %if.else16.i129, label %if.then15.i127, !decision.origin !754

if.then15.i127:                                   ; preds = %if.else12.i126
  %371 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.6.1) #3
  br label %quant_decide.exit135, !decision.origin !755, !decision.order !756

if.else16.i129:                                   ; preds = %if.else12.i126
  %cmp18.i128 = fcmp olt float %366, 3.500000e+00
  br i1 %cmp18.i128, label %if.then19.i130, label %if.else20.i132, !decision.origin !757

if.then19.i130:                                   ; preds = %if.else16.i129
  %372 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.6.1) #3
  br label %quant_decide.exit135, !decision.origin !758, !decision.order !759

if.else20.i132:                                   ; preds = %if.else16.i129
  %cmp22.i131 = fcmp ugt float %366, 5.000000e+00
  br i1 %cmp22.i131, label %if.end29.i134, label %if.then23.i133, !decision.origin !760

if.then23.i133:                                   ; preds = %if.else20.i132
  %373 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.6.1) #3
  br label %quant_decide.exit135, !decision.origin !761, !decision.order !762

if.end29.i134:                                    ; preds = %if.else20.i132
  %374 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.6.1) #3
  br label %quant_decide.exit135, !decision.origin !763, !decision.order !764

quant_decide.exit135:                             ; preds = %if.end29.i134, %if.then23.i133, %if.then19.i130, %if.then15.i127, %if.then11.i124, %if.then7.i121, %if.then3.i118, %if.then.i115
  %out.i372.14 = phi float [ %368, %if.then3.i118 ], [ %370, %if.then11.i124 ], [ %372, %if.then19.i130 ], [ %374, %if.end29.i134 ], [ %373, %if.then23.i133 ], [ %371, %if.then15.i127 ], [ %369, %if.then7.i121 ], [ %367, %if.then.i115 ]
  %mul118.6.1 = fmul float %cond88.1, %out.i372.14
  %sub.6.1 = fsub float %mul118.6.1, %60
  %mul126.6.1 = fmul float %div73.1, %64
  %375 = tail call float @llvm.fabs.f32(float %mul126.6.1) #3
  %cmp.i92 = fcmp ugt float %375, 2.500000e-01
  br i1 %cmp.i92, label %if.else.i95, label %if.then.i93, !decision.origin !765

if.then.i93:                                      ; preds = %quant_decide.exit135
  %376 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.6.1) #3
  br label %quant_decide.exit113, !decision.origin !766, !decision.order !767

if.else.i95:                                      ; preds = %quant_decide.exit135
  %cmp2.i94 = fcmp olt float %375, 7.500000e-01
  br i1 %cmp2.i94, label %if.then3.i96, label %if.else4.i98, !decision.origin !768

if.then3.i96:                                     ; preds = %if.else.i95
  %377 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.6.1) #3
  br label %quant_decide.exit113, !decision.origin !769, !decision.order !770

if.else4.i98:                                     ; preds = %if.else.i95
  %cmp6.i97 = fcmp ugt float %375, 1.250000e+00
  br i1 %cmp6.i97, label %if.else8.i101, label %if.then7.i99, !decision.origin !771

if.then7.i99:                                     ; preds = %if.else4.i98
  %378 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.6.1) #3
  br label %quant_decide.exit113, !decision.origin !772, !decision.order !773

if.else8.i101:                                    ; preds = %if.else4.i98
  %cmp10.i100 = fcmp olt float %375, 1.750000e+00
  br i1 %cmp10.i100, label %if.then11.i102, label %if.else12.i104, !decision.origin !774

if.then11.i102:                                   ; preds = %if.else8.i101
  %379 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.6.1) #3
  br label %quant_decide.exit113, !decision.origin !775, !decision.order !776

if.else12.i104:                                   ; preds = %if.else8.i101
  %cmp14.i103 = fcmp ugt float %375, 2.500000e+00
  br i1 %cmp14.i103, label %if.else16.i107, label %if.then15.i105, !decision.origin !777

if.then15.i105:                                   ; preds = %if.else12.i104
  %380 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.6.1) #3
  br label %quant_decide.exit113, !decision.origin !778, !decision.order !779

if.else16.i107:                                   ; preds = %if.else12.i104
  %cmp18.i106 = fcmp olt float %375, 3.500000e+00
  br i1 %cmp18.i106, label %if.then19.i108, label %if.else20.i110, !decision.origin !780

if.then19.i108:                                   ; preds = %if.else16.i107
  %381 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.6.1) #3
  br label %quant_decide.exit113, !decision.origin !781, !decision.order !782

if.else20.i110:                                   ; preds = %if.else16.i107
  %cmp22.i109 = fcmp ugt float %375, 5.000000e+00
  br i1 %cmp22.i109, label %if.end29.i112, label %if.then23.i111, !decision.origin !783

if.then23.i111:                                   ; preds = %if.else20.i110
  %382 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.6.1) #3
  br label %quant_decide.exit113, !decision.origin !784, !decision.order !785

if.end29.i112:                                    ; preds = %if.else20.i110
  %383 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.6.1) #3
  br label %quant_decide.exit113, !decision.origin !786, !decision.order !787

quant_decide.exit113:                             ; preds = %if.end29.i112, %if.then23.i111, %if.then19.i108, %if.then15.i105, %if.then11.i102, %if.then7.i99, %if.then3.i96, %if.then.i93
  %out.i.14 = phi float [ %377, %if.then3.i96 ], [ %379, %if.then11.i102 ], [ %381, %if.then19.i108 ], [ %383, %if.end29.i112 ], [ %382, %if.then23.i111 ], [ %380, %if.then15.i105 ], [ %378, %if.then7.i99 ], [ %376, %if.then.i93 ]
  %mul128.6.1 = fmul float %cond88.1, %out.i.14
  %sub132.6.1 = fsub float %mul128.6.1, %64
  %mul133.6.1 = fmul float %sub.6.1, %sub.6.1
  %mul134.6.1 = fmul float %sub132.6.1, %sub132.6.1
  %add135.6.1 = fadd float %mul133.6.1, %mul134.6.1
  %e.1.6.1 = fadd float %e.1.5.1, %add135.6.1
  %mul116.7.1 = fmul float %div73.1, %74
  %384 = tail call float @llvm.fabs.f32(float %mul116.7.1) #3
  %cmp.i70 = fcmp ugt float %384, 2.500000e-01
  br i1 %cmp.i70, label %if.else.i73, label %if.then.i71, !decision.origin !788

if.then.i71:                                      ; preds = %quant_decide.exit113
  %385 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116.7.1) #3
  br label %quant_decide.exit91, !decision.origin !789, !decision.order !790

if.else.i73:                                      ; preds = %quant_decide.exit113
  %cmp2.i72 = fcmp olt float %384, 7.500000e-01
  br i1 %cmp2.i72, label %if.then3.i74, label %if.else4.i76, !decision.origin !791

if.then3.i74:                                     ; preds = %if.else.i73
  %386 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116.7.1) #3
  br label %quant_decide.exit91, !decision.origin !792, !decision.order !793

if.else4.i76:                                     ; preds = %if.else.i73
  %cmp6.i75 = fcmp ugt float %384, 1.250000e+00
  br i1 %cmp6.i75, label %if.else8.i79, label %if.then7.i77, !decision.origin !794

if.then7.i77:                                     ; preds = %if.else4.i76
  %387 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116.7.1) #3
  br label %quant_decide.exit91, !decision.origin !795, !decision.order !796

if.else8.i79:                                     ; preds = %if.else4.i76
  %cmp10.i78 = fcmp olt float %384, 1.750000e+00
  br i1 %cmp10.i78, label %if.then11.i80, label %if.else12.i82, !decision.origin !797

if.then11.i80:                                    ; preds = %if.else8.i79
  %388 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116.7.1) #3
  br label %quant_decide.exit91, !decision.origin !798, !decision.order !799

if.else12.i82:                                    ; preds = %if.else8.i79
  %cmp14.i81 = fcmp ugt float %384, 2.500000e+00
  br i1 %cmp14.i81, label %if.else16.i85, label %if.then15.i83, !decision.origin !800

if.then15.i83:                                    ; preds = %if.else12.i82
  %389 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116.7.1) #3
  br label %quant_decide.exit91, !decision.origin !801, !decision.order !802

if.else16.i85:                                    ; preds = %if.else12.i82
  %cmp18.i84 = fcmp olt float %384, 3.500000e+00
  br i1 %cmp18.i84, label %if.then19.i86, label %if.else20.i88, !decision.origin !803

if.then19.i86:                                    ; preds = %if.else16.i85
  %390 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116.7.1) #3
  br label %quant_decide.exit91, !decision.origin !804, !decision.order !805

if.else20.i88:                                    ; preds = %if.else16.i85
  %cmp22.i87 = fcmp ugt float %384, 5.000000e+00
  br i1 %cmp22.i87, label %if.end29.i90, label %if.then23.i89, !decision.origin !806

if.then23.i89:                                    ; preds = %if.else20.i88
  %391 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116.7.1) #3
  br label %quant_decide.exit91, !decision.origin !807, !decision.order !808

if.end29.i90:                                     ; preds = %if.else20.i88
  %392 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116.7.1) #3
  br label %quant_decide.exit91, !decision.origin !809, !decision.order !810

quant_decide.exit91:                              ; preds = %if.end29.i90, %if.then23.i89, %if.then19.i86, %if.then15.i83, %if.then11.i80, %if.then7.i77, %if.then3.i74, %if.then.i71
  %out.i372.15 = phi float [ %386, %if.then3.i74 ], [ %388, %if.then11.i80 ], [ %390, %if.then19.i86 ], [ %392, %if.end29.i90 ], [ %391, %if.then23.i89 ], [ %389, %if.then15.i83 ], [ %387, %if.then7.i77 ], [ %385, %if.then.i71 ]
  %mul118.7.1 = fmul float %cond88.1, %out.i372.15
  %sub.7.1 = fsub float %mul118.7.1, %74
  %mul126.7.1 = fmul float %div73.1, %77
  %393 = tail call float @llvm.fabs.f32(float %mul126.7.1) #3
  %cmp.i48 = fcmp ugt float %393, 2.500000e-01
  br i1 %cmp.i48, label %if.else.i51, label %if.then.i49, !decision.origin !811

if.then.i49:                                      ; preds = %quant_decide.exit91
  %394 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul126.7.1) #3
  br label %quant_decide.exit69, !decision.origin !812, !decision.order !813

if.else.i51:                                      ; preds = %quant_decide.exit91
  %cmp2.i50 = fcmp olt float %393, 7.500000e-01
  br i1 %cmp2.i50, label %if.then3.i52, label %if.else4.i54, !decision.origin !814

if.then3.i52:                                     ; preds = %if.else.i51
  %395 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul126.7.1) #3
  br label %quant_decide.exit69, !decision.origin !815, !decision.order !816

if.else4.i54:                                     ; preds = %if.else.i51
  %cmp6.i53 = fcmp ugt float %393, 1.250000e+00
  br i1 %cmp6.i53, label %if.else8.i57, label %if.then7.i55, !decision.origin !817

if.then7.i55:                                     ; preds = %if.else4.i54
  %396 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul126.7.1) #3
  br label %quant_decide.exit69, !decision.origin !818, !decision.order !819

if.else8.i57:                                     ; preds = %if.else4.i54
  %cmp10.i56 = fcmp olt float %393, 1.750000e+00
  br i1 %cmp10.i56, label %if.then11.i58, label %if.else12.i60, !decision.origin !820

if.then11.i58:                                    ; preds = %if.else8.i57
  %397 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul126.7.1) #3
  br label %quant_decide.exit69, !decision.origin !821, !decision.order !822

if.else12.i60:                                    ; preds = %if.else8.i57
  %cmp14.i59 = fcmp ugt float %393, 2.500000e+00
  br i1 %cmp14.i59, label %if.else16.i63, label %if.then15.i61, !decision.origin !823

if.then15.i61:                                    ; preds = %if.else12.i60
  %398 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul126.7.1) #3
  br label %quant_decide.exit69, !decision.origin !824, !decision.order !825

if.else16.i63:                                    ; preds = %if.else12.i60
  %cmp18.i62 = fcmp olt float %393, 3.500000e+00
  br i1 %cmp18.i62, label %if.then19.i64, label %if.else20.i66, !decision.origin !826

if.then19.i64:                                    ; preds = %if.else16.i63
  %399 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul126.7.1) #3
  br label %quant_decide.exit69, !decision.origin !827, !decision.order !828

if.else20.i66:                                    ; preds = %if.else16.i63
  %cmp22.i65 = fcmp ugt float %393, 5.000000e+00
  br i1 %cmp22.i65, label %if.end29.i68, label %if.then23.i67, !decision.origin !829

if.then23.i67:                                    ; preds = %if.else20.i66
  %400 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul126.7.1) #3
  br label %quant_decide.exit69, !decision.origin !830, !decision.order !831

if.end29.i68:                                     ; preds = %if.else20.i66
  %401 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul126.7.1) #3
  br label %quant_decide.exit69, !decision.origin !832, !decision.order !833

quant_decide.exit69:                              ; preds = %if.end29.i68, %if.then23.i67, %if.then19.i64, %if.then15.i61, %if.then11.i58, %if.then7.i55, %if.then3.i52, %if.then.i49
  %out.i.15 = phi float [ %395, %if.then3.i52 ], [ %397, %if.then11.i58 ], [ %399, %if.then19.i64 ], [ %401, %if.end29.i68 ], [ %400, %if.then23.i67 ], [ %398, %if.then15.i61 ], [ %396, %if.then7.i55 ], [ %394, %if.then.i49 ]
  %mul128.7.1 = fmul float %cond88.1, %out.i.15
  %sub132.7.1 = fsub float %mul128.7.1, %77
  %402 = insertelement <2 x float> undef, float %sub132.7.1, i32 0
  %403 = insertelement <2 x float> %402, float %sub.7.1, i32 1
  %404 = fmul <2 x float> %403, %403
  br label %for.inc138.7.1, !decision.origin !834

if.then97.7.1:                                    ; preds = %cond.end75.1, %cond.end75.1.thread
  %os.sroa.0.5 = phi <2 x float> [ %257, %cond.end75.1 ], [ %256, %cond.end75.1.thread ]
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
  %405 = fmul <2 x float> %73, %73
  br label %for.inc138.7.1, !decision.origin !835

for.inc138.7.1:                                   ; preds = %if.then97.7.1, %quant_decide.exit69
  %os.sroa.0.6 = phi <2 x float> [ %os.sroa.0.5, %if.then97.7.1 ], [ %257, %quant_decide.exit69 ]
  %e.1.6.1654 = phi float [ %e.1.6.1653, %if.then97.7.1 ], [ %e.1.6.1, %quant_decide.exit69 ]
  %406 = phi <2 x float> [ %405, %if.then97.7.1 ], [ %404, %quant_decide.exit69 ]
  %407 = extractelement <2 x float> %406, i32 0
  %408 = extractelement <2 x float> %406, i32 1
  %add110.7.1 = fadd float %407, %408
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
  %409 = zext i1 %cmp149 to i32
  %410 = extractelement <2 x float> %os.sroa.0.6, i32 %409
  %mul175 = fmul float %410, %12
  %411 = tail call float @llvm.fabs.f32(float %mul175) #3
  %cmp.i351 = fcmp ugt float %411, 2.500000e-01
  br i1 %cmp.i351, label %cond.false.i353, label %_Z5pack4f.exit369, !decision.origin !836

cond.false.i353.1:                                ; preds = %_Z5pack4f.exit
  %cmp1.i352.1 = fcmp olt float %88, 7.500000e-01
  br i1 %cmp1.i352.1, label %_Z5pack4f.exit369.1, label %cond.false3.i355.1, !decision.origin !837

cond.false3.i355.1:                               ; preds = %cond.false.i353.1
  %cmp4.i354.1 = fcmp ugt float %88, 1.250000e+00
  br i1 %cmp4.i354.1, label %cond.false6.i357.1, label %_Z5pack4f.exit369.1, !decision.origin !838

cond.false6.i357.1:                               ; preds = %cond.false3.i355.1
  %cmp7.i356.1 = fcmp olt float %88, 1.750000e+00
  br i1 %cmp7.i356.1, label %_Z5pack4f.exit369.1, label %cond.false9.i359.1, !decision.origin !839

cond.false9.i359.1:                               ; preds = %cond.false6.i357.1
  %cmp10.i358.1 = fcmp ugt float %88, 2.500000e+00
  br i1 %cmp10.i358.1, label %cond.false12.i361.1, label %_Z5pack4f.exit369.1, !decision.origin !840

cond.false12.i361.1:                              ; preds = %cond.false9.i359.1
  %cmp13.i360.1 = fcmp olt float %88, 3.500000e+00
  br i1 %cmp13.i360.1, label %_Z5pack4f.exit369.1, label %cond.false15.i364.1, !decision.origin !841

cond.false15.i364.1:                              ; preds = %cond.false12.i361.1
  %cmp16.i362.1 = fcmp ole float %88, 5.000000e+00
  %cond.i363.1 = select i1 %cmp16.i362.1, i32 6, i32 7
  br label %_Z5pack4f.exit369.1, !decision.origin !842

_Z5pack4f.exit369.1:                              ; preds = %cond.false15.i364.1, %cond.false12.i361.1, %cond.false9.i359.1, %cond.false6.i357.1, %cond.false3.i355.1, %cond.false.i353.1, %_Z5pack4f.exit
  %cond27.i365.1 = phi i32 [ 0, %_Z5pack4f.exit ], [ 1, %cond.false.i353.1 ], [ 2, %cond.false3.i355.1 ], [ 3, %cond.false6.i357.1 ], [ 4, %cond.false9.i359.1 ], [ %cond.i363.1, %cond.false15.i364.1 ], [ 5, %cond.false12.i361.1 ]
  %412 = bitcast float %mul175.1 to i32
  %shr.i366.1 = lshr i32 %412, 28
  %and.i367.1 = and i32 %shr.i366.1, 8
  %or.i368.1 = or i32 %cond27.i365.1, %and.i367.1
  %mul183.1 = fmul float %410, %24
  %413 = tail call float @llvm.fabs.f32(float %mul183.1) #3
  %cmp.i.1 = fcmp ugt float %413, 2.500000e-01
  br i1 %cmp.i.1, label %cond.false.i.1, label %_Z5pack4f.exit.1, !decision.origin !843

cond.false.i.1:                                   ; preds = %_Z5pack4f.exit369.1
  %cmp1.i.1 = fcmp olt float %413, 7.500000e-01
  br i1 %cmp1.i.1, label %_Z5pack4f.exit.1, label %cond.false3.i.1, !decision.origin !844

cond.false3.i.1:                                  ; preds = %cond.false.i.1
  %cmp4.i.1 = fcmp ugt float %413, 1.250000e+00
  br i1 %cmp4.i.1, label %cond.false6.i.1, label %_Z5pack4f.exit.1, !decision.origin !845

cond.false6.i.1:                                  ; preds = %cond.false3.i.1
  %cmp7.i.1 = fcmp olt float %413, 1.750000e+00
  br i1 %cmp7.i.1, label %_Z5pack4f.exit.1, label %cond.false9.i.1, !decision.origin !846

cond.false9.i.1:                                  ; preds = %cond.false6.i.1
  %cmp10.i.1 = fcmp ugt float %413, 2.500000e+00
  br i1 %cmp10.i.1, label %cond.false12.i.1, label %_Z5pack4f.exit.1, !decision.origin !847

cond.false12.i.1:                                 ; preds = %cond.false9.i.1
  %cmp13.i.1 = fcmp olt float %413, 3.500000e+00
  br i1 %cmp13.i.1, label %_Z5pack4f.exit.1, label %cond.false15.i.1, !decision.origin !848

cond.false15.i.1:                                 ; preds = %cond.false12.i.1
  %cmp16.i.1 = fcmp ole float %413, 5.000000e+00
  %cond.i.1 = select i1 %cmp16.i.1, i32 6, i32 7
  br label %_Z5pack4f.exit.1, !decision.origin !849

_Z5pack4f.exit.1:                                 ; preds = %cond.false15.i.1, %cond.false12.i.1, %cond.false9.i.1, %cond.false6.i.1, %cond.false3.i.1, %cond.false.i.1, %_Z5pack4f.exit369.1
  %cond27.i.1 = phi i32 [ 0, %_Z5pack4f.exit369.1 ], [ 1, %cond.false.i.1 ], [ 2, %cond.false3.i.1 ], [ 3, %cond.false6.i.1 ], [ 4, %cond.false9.i.1 ], [ %cond.i.1, %cond.false15.i.1 ], [ 5, %cond.false12.i.1 ]
  %414 = bitcast float %mul183.1 to i32
  %shr.i.1 = lshr i32 %414, 28
  %and.i.1 = and i32 %shr.i.1, 8
  %or.i.1 = or i32 %cond27.i.1, %and.i.1
  %shl.1 = shl nuw nsw i32 %or.i.1, 4
  %or.1 = or i32 %or.i368.1, %shl.1
  %conv185.1 = trunc i32 %or.1 to i8
  %add187.1 = add nsw i64 %add164, 1
  %arrayidx188339.1 = getelementptr inbounds i8, i8 addrspace(1)* %cond19.v, i64 %add187.1
  store i8 %conv185.1, i8 addrspace(1)* %arrayidx188339.1, align 1, !tbaa !18
  %mul175.2 = fmul float %410, %28
  %415 = tail call float @llvm.fabs.f32(float %mul175.2) #3
  %cmp.i351.2 = fcmp ugt float %415, 2.500000e-01
  br i1 %cmp.i351.2, label %cond.false.i353.2, label %_Z5pack4f.exit369.2, !decision.origin !850

cond.false.i353.2:                                ; preds = %_Z5pack4f.exit.1
  %cmp1.i352.2 = fcmp olt float %415, 7.500000e-01
  br i1 %cmp1.i352.2, label %_Z5pack4f.exit369.2, label %cond.false3.i355.2, !decision.origin !851

cond.false3.i355.2:                               ; preds = %cond.false.i353.2
  %cmp4.i354.2 = fcmp ugt float %415, 1.250000e+00
  br i1 %cmp4.i354.2, label %cond.false6.i357.2, label %_Z5pack4f.exit369.2, !decision.origin !852

cond.false6.i357.2:                               ; preds = %cond.false3.i355.2
  %cmp7.i356.2 = fcmp olt float %415, 1.750000e+00
  br i1 %cmp7.i356.2, label %_Z5pack4f.exit369.2, label %cond.false9.i359.2, !decision.origin !853

cond.false9.i359.2:                               ; preds = %cond.false6.i357.2
  %cmp10.i358.2 = fcmp ugt float %415, 2.500000e+00
  br i1 %cmp10.i358.2, label %cond.false12.i361.2, label %_Z5pack4f.exit369.2, !decision.origin !854

cond.false12.i361.2:                              ; preds = %cond.false9.i359.2
  %cmp13.i360.2 = fcmp olt float %415, 3.500000e+00
  br i1 %cmp13.i360.2, label %_Z5pack4f.exit369.2, label %cond.false15.i364.2, !decision.origin !855

cond.false15.i364.2:                              ; preds = %cond.false12.i361.2
  %cmp16.i362.2 = fcmp ole float %415, 5.000000e+00
  %cond.i363.2 = select i1 %cmp16.i362.2, i32 6, i32 7
  br label %_Z5pack4f.exit369.2, !decision.origin !856

_Z5pack4f.exit369.2:                              ; preds = %cond.false15.i364.2, %cond.false12.i361.2, %cond.false9.i359.2, %cond.false6.i357.2, %cond.false3.i355.2, %cond.false.i353.2, %_Z5pack4f.exit.1
  %cond27.i365.2 = phi i32 [ 0, %_Z5pack4f.exit.1 ], [ 1, %cond.false.i353.2 ], [ 2, %cond.false3.i355.2 ], [ 3, %cond.false6.i357.2 ], [ 4, %cond.false9.i359.2 ], [ %cond.i363.2, %cond.false15.i364.2 ], [ 5, %cond.false12.i361.2 ]
  %416 = bitcast float %mul175.2 to i32
  %shr.i366.2 = lshr i32 %416, 28
  %and.i367.2 = and i32 %shr.i366.2, 8
  %or.i368.2 = or i32 %cond27.i365.2, %and.i367.2
  %mul183.2 = fmul float %410, %32
  %417 = tail call float @llvm.fabs.f32(float %mul183.2) #3
  %cmp.i.2 = fcmp ugt float %417, 2.500000e-01
  br i1 %cmp.i.2, label %cond.false.i.2, label %_Z5pack4f.exit.2, !decision.origin !857

cond.false.i.2:                                   ; preds = %_Z5pack4f.exit369.2
  %cmp1.i.2 = fcmp olt float %417, 7.500000e-01
  br i1 %cmp1.i.2, label %_Z5pack4f.exit.2, label %cond.false3.i.2, !decision.origin !858

cond.false3.i.2:                                  ; preds = %cond.false.i.2
  %cmp4.i.2 = fcmp ugt float %417, 1.250000e+00
  br i1 %cmp4.i.2, label %cond.false6.i.2, label %_Z5pack4f.exit.2, !decision.origin !859

cond.false6.i.2:                                  ; preds = %cond.false3.i.2
  %cmp7.i.2 = fcmp olt float %417, 1.750000e+00
  br i1 %cmp7.i.2, label %_Z5pack4f.exit.2, label %cond.false9.i.2, !decision.origin !860

cond.false9.i.2:                                  ; preds = %cond.false6.i.2
  %cmp10.i.2 = fcmp ugt float %417, 2.500000e+00
  br i1 %cmp10.i.2, label %cond.false12.i.2, label %_Z5pack4f.exit.2, !decision.origin !861

cond.false12.i.2:                                 ; preds = %cond.false9.i.2
  %cmp13.i.2 = fcmp olt float %417, 3.500000e+00
  br i1 %cmp13.i.2, label %_Z5pack4f.exit.2, label %cond.false15.i.2, !decision.origin !862

cond.false15.i.2:                                 ; preds = %cond.false12.i.2
  %cmp16.i.2 = fcmp ole float %417, 5.000000e+00
  %cond.i.2 = select i1 %cmp16.i.2, i32 6, i32 7
  br label %_Z5pack4f.exit.2, !decision.origin !863

_Z5pack4f.exit.2:                                 ; preds = %cond.false15.i.2, %cond.false12.i.2, %cond.false9.i.2, %cond.false6.i.2, %cond.false3.i.2, %cond.false.i.2, %_Z5pack4f.exit369.2
  %cond27.i.2 = phi i32 [ 0, %_Z5pack4f.exit369.2 ], [ 1, %cond.false.i.2 ], [ 2, %cond.false3.i.2 ], [ 3, %cond.false6.i.2 ], [ 4, %cond.false9.i.2 ], [ %cond.i.2, %cond.false15.i.2 ], [ 5, %cond.false12.i.2 ]
  %418 = bitcast float %mul183.2 to i32
  %shr.i.2 = lshr i32 %418, 28
  %and.i.2 = and i32 %shr.i.2, 8
  %or.i.2 = or i32 %cond27.i.2, %and.i.2
  %shl.2 = shl nuw nsw i32 %or.i.2, 4
  %or.2 = or i32 %or.i368.2, %shl.2
  %conv185.2 = trunc i32 %or.2 to i8
  %add187.2 = add nsw i64 %add164, 2
  %arrayidx188339.2 = getelementptr inbounds i8, i8 addrspace(1)* %cond19.v, i64 %add187.2
  store i8 %conv185.2, i8 addrspace(1)* %arrayidx188339.2, align 1, !tbaa !18
  %mul175.3 = fmul float %410, %36
  %419 = tail call float @llvm.fabs.f32(float %mul175.3) #3
  %cmp.i351.3 = fcmp ugt float %419, 2.500000e-01
  br i1 %cmp.i351.3, label %cond.false.i353.3, label %_Z5pack4f.exit369.3, !decision.origin !864

cond.false.i353.3:                                ; preds = %_Z5pack4f.exit.2
  %cmp1.i352.3 = fcmp olt float %419, 7.500000e-01
  br i1 %cmp1.i352.3, label %_Z5pack4f.exit369.3, label %cond.false3.i355.3, !decision.origin !865

cond.false3.i355.3:                               ; preds = %cond.false.i353.3
  %cmp4.i354.3 = fcmp ugt float %419, 1.250000e+00
  br i1 %cmp4.i354.3, label %cond.false6.i357.3, label %_Z5pack4f.exit369.3, !decision.origin !866

cond.false6.i357.3:                               ; preds = %cond.false3.i355.3
  %cmp7.i356.3 = fcmp olt float %419, 1.750000e+00
  br i1 %cmp7.i356.3, label %_Z5pack4f.exit369.3, label %cond.false9.i359.3, !decision.origin !867

cond.false9.i359.3:                               ; preds = %cond.false6.i357.3
  %cmp10.i358.3 = fcmp ugt float %419, 2.500000e+00
  br i1 %cmp10.i358.3, label %cond.false12.i361.3, label %_Z5pack4f.exit369.3, !decision.origin !868

cond.false12.i361.3:                              ; preds = %cond.false9.i359.3
  %cmp13.i360.3 = fcmp olt float %419, 3.500000e+00
  br i1 %cmp13.i360.3, label %_Z5pack4f.exit369.3, label %cond.false15.i364.3, !decision.origin !869

cond.false15.i364.3:                              ; preds = %cond.false12.i361.3
  %cmp16.i362.3 = fcmp ole float %419, 5.000000e+00
  %cond.i363.3 = select i1 %cmp16.i362.3, i32 6, i32 7
  br label %_Z5pack4f.exit369.3, !decision.origin !870

_Z5pack4f.exit369.3:                              ; preds = %cond.false15.i364.3, %cond.false12.i361.3, %cond.false9.i359.3, %cond.false6.i357.3, %cond.false3.i355.3, %cond.false.i353.3, %_Z5pack4f.exit.2
  %cond27.i365.3 = phi i32 [ 0, %_Z5pack4f.exit.2 ], [ 1, %cond.false.i353.3 ], [ 2, %cond.false3.i355.3 ], [ 3, %cond.false6.i357.3 ], [ 4, %cond.false9.i359.3 ], [ %cond.i363.3, %cond.false15.i364.3 ], [ 5, %cond.false12.i361.3 ]
  %420 = bitcast float %mul175.3 to i32
  %shr.i366.3 = lshr i32 %420, 28
  %and.i367.3 = and i32 %shr.i366.3, 8
  %or.i368.3 = or i32 %cond27.i365.3, %and.i367.3
  %mul183.3 = fmul float %410, %40
  %421 = tail call float @llvm.fabs.f32(float %mul183.3) #3
  %cmp.i.3 = fcmp ugt float %421, 2.500000e-01
  br i1 %cmp.i.3, label %cond.false.i.3, label %_Z5pack4f.exit.3, !decision.origin !871

cond.false.i.3:                                   ; preds = %_Z5pack4f.exit369.3
  %cmp1.i.3 = fcmp olt float %421, 7.500000e-01
  br i1 %cmp1.i.3, label %_Z5pack4f.exit.3, label %cond.false3.i.3, !decision.origin !872

cond.false3.i.3:                                  ; preds = %cond.false.i.3
  %cmp4.i.3 = fcmp ugt float %421, 1.250000e+00
  br i1 %cmp4.i.3, label %cond.false6.i.3, label %_Z5pack4f.exit.3, !decision.origin !873

cond.false6.i.3:                                  ; preds = %cond.false3.i.3
  %cmp7.i.3 = fcmp olt float %421, 1.750000e+00
  br i1 %cmp7.i.3, label %_Z5pack4f.exit.3, label %cond.false9.i.3, !decision.origin !874

cond.false9.i.3:                                  ; preds = %cond.false6.i.3
  %cmp10.i.3 = fcmp ugt float %421, 2.500000e+00
  br i1 %cmp10.i.3, label %cond.false12.i.3, label %_Z5pack4f.exit.3, !decision.origin !875

cond.false12.i.3:                                 ; preds = %cond.false9.i.3
  %cmp13.i.3 = fcmp olt float %421, 3.500000e+00
  br i1 %cmp13.i.3, label %_Z5pack4f.exit.3, label %cond.false15.i.3, !decision.origin !876

cond.false15.i.3:                                 ; preds = %cond.false12.i.3
  %cmp16.i.3 = fcmp ole float %421, 5.000000e+00
  %cond.i.3 = select i1 %cmp16.i.3, i32 6, i32 7
  br label %_Z5pack4f.exit.3, !decision.origin !877

_Z5pack4f.exit.3:                                 ; preds = %cond.false15.i.3, %cond.false12.i.3, %cond.false9.i.3, %cond.false6.i.3, %cond.false3.i.3, %cond.false.i.3, %_Z5pack4f.exit369.3
  %cond27.i.3 = phi i32 [ 0, %_Z5pack4f.exit369.3 ], [ 1, %cond.false.i.3 ], [ 2, %cond.false3.i.3 ], [ 3, %cond.false6.i.3 ], [ 4, %cond.false9.i.3 ], [ %cond.i.3, %cond.false15.i.3 ], [ 5, %cond.false12.i.3 ]
  %422 = bitcast float %mul183.3 to i32
  %shr.i.3 = lshr i32 %422, 28
  %and.i.3 = and i32 %shr.i.3, 8
  %or.i.3 = or i32 %cond27.i.3, %and.i.3
  %shl.3 = shl nuw nsw i32 %or.i.3, 4
  %or.3 = or i32 %or.i368.3, %shl.3
  %conv185.3 = trunc i32 %or.3 to i8
  %add187.3 = add nsw i64 %add164, 3
  %arrayidx188339.3 = getelementptr inbounds i8, i8 addrspace(1)* %cond19.v, i64 %add187.3
  store i8 %conv185.3, i8 addrspace(1)* %arrayidx188339.3, align 1, !tbaa !18
  %mul175.4 = fmul float %410, %44
  %423 = tail call float @llvm.fabs.f32(float %mul175.4) #3
  %cmp.i351.4 = fcmp ugt float %423, 2.500000e-01
  br i1 %cmp.i351.4, label %cond.false.i353.4, label %_Z5pack4f.exit369.4, !decision.origin !878

cond.false.i353.4:                                ; preds = %_Z5pack4f.exit.3
  %cmp1.i352.4 = fcmp olt float %423, 7.500000e-01
  br i1 %cmp1.i352.4, label %_Z5pack4f.exit369.4, label %cond.false3.i355.4, !decision.origin !879

cond.false3.i355.4:                               ; preds = %cond.false.i353.4
  %cmp4.i354.4 = fcmp ugt float %423, 1.250000e+00
  br i1 %cmp4.i354.4, label %cond.false6.i357.4, label %_Z5pack4f.exit369.4, !decision.origin !880

cond.false6.i357.4:                               ; preds = %cond.false3.i355.4
  %cmp7.i356.4 = fcmp olt float %423, 1.750000e+00
  br i1 %cmp7.i356.4, label %_Z5pack4f.exit369.4, label %cond.false9.i359.4, !decision.origin !881

cond.false9.i359.4:                               ; preds = %cond.false6.i357.4
  %cmp10.i358.4 = fcmp ugt float %423, 2.500000e+00
  br i1 %cmp10.i358.4, label %cond.false12.i361.4, label %_Z5pack4f.exit369.4, !decision.origin !882

cond.false12.i361.4:                              ; preds = %cond.false9.i359.4
  %cmp13.i360.4 = fcmp olt float %423, 3.500000e+00
  br i1 %cmp13.i360.4, label %_Z5pack4f.exit369.4, label %cond.false15.i364.4, !decision.origin !883

cond.false15.i364.4:                              ; preds = %cond.false12.i361.4
  %cmp16.i362.4 = fcmp ole float %423, 5.000000e+00
  %cond.i363.4 = select i1 %cmp16.i362.4, i32 6, i32 7
  br label %_Z5pack4f.exit369.4, !decision.origin !884

_Z5pack4f.exit369.4:                              ; preds = %cond.false15.i364.4, %cond.false12.i361.4, %cond.false9.i359.4, %cond.false6.i357.4, %cond.false3.i355.4, %cond.false.i353.4, %_Z5pack4f.exit.3
  %cond27.i365.4 = phi i32 [ 0, %_Z5pack4f.exit.3 ], [ 1, %cond.false.i353.4 ], [ 2, %cond.false3.i355.4 ], [ 3, %cond.false6.i357.4 ], [ 4, %cond.false9.i359.4 ], [ %cond.i363.4, %cond.false15.i364.4 ], [ 5, %cond.false12.i361.4 ]
  %424 = bitcast float %mul175.4 to i32
  %shr.i366.4 = lshr i32 %424, 28
  %and.i367.4 = and i32 %shr.i366.4, 8
  %or.i368.4 = or i32 %cond27.i365.4, %and.i367.4
  %mul183.4 = fmul float %410, %48
  %425 = tail call float @llvm.fabs.f32(float %mul183.4) #3
  %cmp.i.4 = fcmp ugt float %425, 2.500000e-01
  br i1 %cmp.i.4, label %cond.false.i.4, label %_Z5pack4f.exit.4, !decision.origin !885

cond.false.i.4:                                   ; preds = %_Z5pack4f.exit369.4
  %cmp1.i.4 = fcmp olt float %425, 7.500000e-01
  br i1 %cmp1.i.4, label %_Z5pack4f.exit.4, label %cond.false3.i.4, !decision.origin !886

cond.false3.i.4:                                  ; preds = %cond.false.i.4
  %cmp4.i.4 = fcmp ugt float %425, 1.250000e+00
  br i1 %cmp4.i.4, label %cond.false6.i.4, label %_Z5pack4f.exit.4, !decision.origin !887

cond.false6.i.4:                                  ; preds = %cond.false3.i.4
  %cmp7.i.4 = fcmp olt float %425, 1.750000e+00
  br i1 %cmp7.i.4, label %_Z5pack4f.exit.4, label %cond.false9.i.4, !decision.origin !888

cond.false9.i.4:                                  ; preds = %cond.false6.i.4
  %cmp10.i.4 = fcmp ugt float %425, 2.500000e+00
  br i1 %cmp10.i.4, label %cond.false12.i.4, label %_Z5pack4f.exit.4, !decision.origin !889

cond.false12.i.4:                                 ; preds = %cond.false9.i.4
  %cmp13.i.4 = fcmp olt float %425, 3.500000e+00
  br i1 %cmp13.i.4, label %_Z5pack4f.exit.4, label %cond.false15.i.4, !decision.origin !890

cond.false15.i.4:                                 ; preds = %cond.false12.i.4
  %cmp16.i.4 = fcmp ole float %425, 5.000000e+00
  %cond.i.4 = select i1 %cmp16.i.4, i32 6, i32 7
  br label %_Z5pack4f.exit.4, !decision.origin !891

_Z5pack4f.exit.4:                                 ; preds = %cond.false15.i.4, %cond.false12.i.4, %cond.false9.i.4, %cond.false6.i.4, %cond.false3.i.4, %cond.false.i.4, %_Z5pack4f.exit369.4
  %cond27.i.4 = phi i32 [ 0, %_Z5pack4f.exit369.4 ], [ 1, %cond.false.i.4 ], [ 2, %cond.false3.i.4 ], [ 3, %cond.false6.i.4 ], [ 4, %cond.false9.i.4 ], [ %cond.i.4, %cond.false15.i.4 ], [ 5, %cond.false12.i.4 ]
  %426 = bitcast float %mul183.4 to i32
  %shr.i.4 = lshr i32 %426, 28
  %and.i.4 = and i32 %shr.i.4, 8
  %or.i.4 = or i32 %cond27.i.4, %and.i.4
  %shl.4 = shl nuw nsw i32 %or.i.4, 4
  %or.4 = or i32 %or.i368.4, %shl.4
  %conv185.4 = trunc i32 %or.4 to i8
  %add187.4 = add nsw i64 %add164, 4
  %arrayidx188339.4 = getelementptr inbounds i8, i8 addrspace(1)* %cond19.v, i64 %add187.4
  store i8 %conv185.4, i8 addrspace(1)* %arrayidx188339.4, align 1, !tbaa !18
  %mul175.5 = fmul float %410, %52
  %427 = tail call float @llvm.fabs.f32(float %mul175.5) #3
  %cmp.i351.5 = fcmp ugt float %427, 2.500000e-01
  br i1 %cmp.i351.5, label %cond.false.i353.5, label %_Z5pack4f.exit369.5, !decision.origin !892

cond.false.i353.5:                                ; preds = %_Z5pack4f.exit.4
  %cmp1.i352.5 = fcmp olt float %427, 7.500000e-01
  br i1 %cmp1.i352.5, label %_Z5pack4f.exit369.5, label %cond.false3.i355.5, !decision.origin !893

cond.false3.i355.5:                               ; preds = %cond.false.i353.5
  %cmp4.i354.5 = fcmp ugt float %427, 1.250000e+00
  br i1 %cmp4.i354.5, label %cond.false6.i357.5, label %_Z5pack4f.exit369.5, !decision.origin !894

cond.false6.i357.5:                               ; preds = %cond.false3.i355.5
  %cmp7.i356.5 = fcmp olt float %427, 1.750000e+00
  br i1 %cmp7.i356.5, label %_Z5pack4f.exit369.5, label %cond.false9.i359.5, !decision.origin !895

cond.false9.i359.5:                               ; preds = %cond.false6.i357.5
  %cmp10.i358.5 = fcmp ugt float %427, 2.500000e+00
  br i1 %cmp10.i358.5, label %cond.false12.i361.5, label %_Z5pack4f.exit369.5, !decision.origin !896

cond.false12.i361.5:                              ; preds = %cond.false9.i359.5
  %cmp13.i360.5 = fcmp olt float %427, 3.500000e+00
  br i1 %cmp13.i360.5, label %_Z5pack4f.exit369.5, label %cond.false15.i364.5, !decision.origin !897

cond.false15.i364.5:                              ; preds = %cond.false12.i361.5
  %cmp16.i362.5 = fcmp ole float %427, 5.000000e+00
  %cond.i363.5 = select i1 %cmp16.i362.5, i32 6, i32 7
  br label %_Z5pack4f.exit369.5, !decision.origin !898

_Z5pack4f.exit369.5:                              ; preds = %cond.false15.i364.5, %cond.false12.i361.5, %cond.false9.i359.5, %cond.false6.i357.5, %cond.false3.i355.5, %cond.false.i353.5, %_Z5pack4f.exit.4
  %cond27.i365.5 = phi i32 [ 0, %_Z5pack4f.exit.4 ], [ 1, %cond.false.i353.5 ], [ 2, %cond.false3.i355.5 ], [ 3, %cond.false6.i357.5 ], [ 4, %cond.false9.i359.5 ], [ %cond.i363.5, %cond.false15.i364.5 ], [ 5, %cond.false12.i361.5 ]
  %428 = bitcast float %mul175.5 to i32
  %shr.i366.5 = lshr i32 %428, 28
  %and.i367.5 = and i32 %shr.i366.5, 8
  %or.i368.5 = or i32 %cond27.i365.5, %and.i367.5
  %mul183.5 = fmul float %410, %56
  %429 = tail call float @llvm.fabs.f32(float %mul183.5) #3
  %cmp.i.5 = fcmp ugt float %429, 2.500000e-01
  br i1 %cmp.i.5, label %cond.false.i.5, label %_Z5pack4f.exit.5, !decision.origin !899

cond.false.i.5:                                   ; preds = %_Z5pack4f.exit369.5
  %cmp1.i.5 = fcmp olt float %429, 7.500000e-01
  br i1 %cmp1.i.5, label %_Z5pack4f.exit.5, label %cond.false3.i.5, !decision.origin !900

cond.false3.i.5:                                  ; preds = %cond.false.i.5
  %cmp4.i.5 = fcmp ugt float %429, 1.250000e+00
  br i1 %cmp4.i.5, label %cond.false6.i.5, label %_Z5pack4f.exit.5, !decision.origin !901

cond.false6.i.5:                                  ; preds = %cond.false3.i.5
  %cmp7.i.5 = fcmp olt float %429, 1.750000e+00
  br i1 %cmp7.i.5, label %_Z5pack4f.exit.5, label %cond.false9.i.5, !decision.origin !902

cond.false9.i.5:                                  ; preds = %cond.false6.i.5
  %cmp10.i.5 = fcmp ugt float %429, 2.500000e+00
  br i1 %cmp10.i.5, label %cond.false12.i.5, label %_Z5pack4f.exit.5, !decision.origin !903

cond.false12.i.5:                                 ; preds = %cond.false9.i.5
  %cmp13.i.5 = fcmp olt float %429, 3.500000e+00
  br i1 %cmp13.i.5, label %_Z5pack4f.exit.5, label %cond.false15.i.5, !decision.origin !904

cond.false15.i.5:                                 ; preds = %cond.false12.i.5
  %cmp16.i.5 = fcmp ole float %429, 5.000000e+00
  %cond.i.5 = select i1 %cmp16.i.5, i32 6, i32 7
  br label %_Z5pack4f.exit.5, !decision.origin !905

_Z5pack4f.exit.5:                                 ; preds = %cond.false15.i.5, %cond.false12.i.5, %cond.false9.i.5, %cond.false6.i.5, %cond.false3.i.5, %cond.false.i.5, %_Z5pack4f.exit369.5
  %cond27.i.5 = phi i32 [ 0, %_Z5pack4f.exit369.5 ], [ 1, %cond.false.i.5 ], [ 2, %cond.false3.i.5 ], [ 3, %cond.false6.i.5 ], [ 4, %cond.false9.i.5 ], [ %cond.i.5, %cond.false15.i.5 ], [ 5, %cond.false12.i.5 ]
  %430 = bitcast float %mul183.5 to i32
  %shr.i.5 = lshr i32 %430, 28
  %and.i.5 = and i32 %shr.i.5, 8
  %or.i.5 = or i32 %cond27.i.5, %and.i.5
  %shl.5 = shl nuw nsw i32 %or.i.5, 4
  %or.5 = or i32 %or.i368.5, %shl.5
  %conv185.5 = trunc i32 %or.5 to i8
  %add187.5 = add nsw i64 %add164, 5
  %arrayidx188339.5 = getelementptr inbounds i8, i8 addrspace(1)* %cond19.v, i64 %add187.5
  store i8 %conv185.5, i8 addrspace(1)* %arrayidx188339.5, align 1, !tbaa !18
  %mul175.6 = fmul float %410, %60
  %431 = tail call float @llvm.fabs.f32(float %mul175.6) #3
  %cmp.i351.6 = fcmp ugt float %431, 2.500000e-01
  br i1 %cmp.i351.6, label %cond.false.i353.6, label %_Z5pack4f.exit369.6, !decision.origin !906

cond.false.i353.6:                                ; preds = %_Z5pack4f.exit.5
  %cmp1.i352.6 = fcmp olt float %431, 7.500000e-01
  br i1 %cmp1.i352.6, label %_Z5pack4f.exit369.6, label %cond.false3.i355.6, !decision.origin !907

cond.false3.i355.6:                               ; preds = %cond.false.i353.6
  %cmp4.i354.6 = fcmp ugt float %431, 1.250000e+00
  br i1 %cmp4.i354.6, label %cond.false6.i357.6, label %_Z5pack4f.exit369.6, !decision.origin !908

cond.false6.i357.6:                               ; preds = %cond.false3.i355.6
  %cmp7.i356.6 = fcmp olt float %431, 1.750000e+00
  br i1 %cmp7.i356.6, label %_Z5pack4f.exit369.6, label %cond.false9.i359.6, !decision.origin !909

cond.false9.i359.6:                               ; preds = %cond.false6.i357.6
  %cmp10.i358.6 = fcmp ugt float %431, 2.500000e+00
  br i1 %cmp10.i358.6, label %cond.false12.i361.6, label %_Z5pack4f.exit369.6, !decision.origin !910

cond.false12.i361.6:                              ; preds = %cond.false9.i359.6
  %cmp13.i360.6 = fcmp olt float %431, 3.500000e+00
  br i1 %cmp13.i360.6, label %_Z5pack4f.exit369.6, label %cond.false15.i364.6, !decision.origin !911

cond.false15.i364.6:                              ; preds = %cond.false12.i361.6
  %cmp16.i362.6 = fcmp ole float %431, 5.000000e+00
  %cond.i363.6 = select i1 %cmp16.i362.6, i32 6, i32 7
  br label %_Z5pack4f.exit369.6, !decision.origin !912

_Z5pack4f.exit369.6:                              ; preds = %cond.false15.i364.6, %cond.false12.i361.6, %cond.false9.i359.6, %cond.false6.i357.6, %cond.false3.i355.6, %cond.false.i353.6, %_Z5pack4f.exit.5
  %cond27.i365.6 = phi i32 [ 0, %_Z5pack4f.exit.5 ], [ 1, %cond.false.i353.6 ], [ 2, %cond.false3.i355.6 ], [ 3, %cond.false6.i357.6 ], [ 4, %cond.false9.i359.6 ], [ %cond.i363.6, %cond.false15.i364.6 ], [ 5, %cond.false12.i361.6 ]
  %432 = bitcast float %mul175.6 to i32
  %shr.i366.6 = lshr i32 %432, 28
  %and.i367.6 = and i32 %shr.i366.6, 8
  %or.i368.6 = or i32 %cond27.i365.6, %and.i367.6
  %mul183.6 = fmul float %410, %64
  %433 = tail call float @llvm.fabs.f32(float %mul183.6) #3
  %cmp.i.6 = fcmp ugt float %433, 2.500000e-01
  br i1 %cmp.i.6, label %cond.false.i.6, label %_Z5pack4f.exit.6, !decision.origin !913

cond.false.i.6:                                   ; preds = %_Z5pack4f.exit369.6
  %cmp1.i.6 = fcmp olt float %433, 7.500000e-01
  br i1 %cmp1.i.6, label %_Z5pack4f.exit.6, label %cond.false3.i.6, !decision.origin !914

cond.false3.i.6:                                  ; preds = %cond.false.i.6
  %cmp4.i.6 = fcmp ugt float %433, 1.250000e+00
  br i1 %cmp4.i.6, label %cond.false6.i.6, label %_Z5pack4f.exit.6, !decision.origin !915

cond.false6.i.6:                                  ; preds = %cond.false3.i.6
  %cmp7.i.6 = fcmp olt float %433, 1.750000e+00
  br i1 %cmp7.i.6, label %_Z5pack4f.exit.6, label %cond.false9.i.6, !decision.origin !916

cond.false9.i.6:                                  ; preds = %cond.false6.i.6
  %cmp10.i.6 = fcmp ugt float %433, 2.500000e+00
  br i1 %cmp10.i.6, label %cond.false12.i.6, label %_Z5pack4f.exit.6, !decision.origin !917

cond.false12.i.6:                                 ; preds = %cond.false9.i.6
  %cmp13.i.6 = fcmp olt float %433, 3.500000e+00
  br i1 %cmp13.i.6, label %_Z5pack4f.exit.6, label %cond.false15.i.6, !decision.origin !918

cond.false15.i.6:                                 ; preds = %cond.false12.i.6
  %cmp16.i.6 = fcmp ole float %433, 5.000000e+00
  %cond.i.6 = select i1 %cmp16.i.6, i32 6, i32 7
  br label %_Z5pack4f.exit.6, !decision.origin !919

_Z5pack4f.exit.6:                                 ; preds = %cond.false15.i.6, %cond.false12.i.6, %cond.false9.i.6, %cond.false6.i.6, %cond.false3.i.6, %cond.false.i.6, %_Z5pack4f.exit369.6
  %cond27.i.6 = phi i32 [ 0, %_Z5pack4f.exit369.6 ], [ 1, %cond.false.i.6 ], [ 2, %cond.false3.i.6 ], [ 3, %cond.false6.i.6 ], [ 4, %cond.false9.i.6 ], [ %cond.i.6, %cond.false15.i.6 ], [ 5, %cond.false12.i.6 ]
  %434 = bitcast float %mul183.6 to i32
  %shr.i.6 = lshr i32 %434, 28
  %and.i.6 = and i32 %shr.i.6, 8
  %or.i.6 = or i32 %cond27.i.6, %and.i.6
  %shl.6 = shl nuw nsw i32 %or.i.6, 4
  %or.6 = or i32 %or.i368.6, %shl.6
  %conv185.6 = trunc i32 %or.6 to i8
  %add187.6 = add nsw i64 %add164, 6
  %arrayidx188339.6 = getelementptr inbounds i8, i8 addrspace(1)* %cond19.v, i64 %add187.6
  store i8 %conv185.6, i8 addrspace(1)* %arrayidx188339.6, align 1, !tbaa !18
  %mul175.7 = fmul float %410, %74
  %435 = tail call float @llvm.fabs.f32(float %mul175.7) #3
  %cmp.i351.7 = fcmp ugt float %435, 2.500000e-01
  br i1 %cmp.i351.7, label %cond.false.i353.7, label %_Z5pack4f.exit369.7, !decision.origin !920

cond.false.i353.7:                                ; preds = %_Z5pack4f.exit.6
  %cmp1.i352.7 = fcmp olt float %435, 7.500000e-01
  br i1 %cmp1.i352.7, label %_Z5pack4f.exit369.7, label %cond.false3.i355.7, !decision.origin !921

cond.false3.i355.7:                               ; preds = %cond.false.i353.7
  %cmp4.i354.7 = fcmp ugt float %435, 1.250000e+00
  br i1 %cmp4.i354.7, label %cond.false6.i357.7, label %_Z5pack4f.exit369.7, !decision.origin !922

cond.false6.i357.7:                               ; preds = %cond.false3.i355.7
  %cmp7.i356.7 = fcmp olt float %435, 1.750000e+00
  br i1 %cmp7.i356.7, label %_Z5pack4f.exit369.7, label %cond.false9.i359.7, !decision.origin !923

cond.false9.i359.7:                               ; preds = %cond.false6.i357.7
  %cmp10.i358.7 = fcmp ugt float %435, 2.500000e+00
  br i1 %cmp10.i358.7, label %cond.false12.i361.7, label %_Z5pack4f.exit369.7, !decision.origin !924

cond.false12.i361.7:                              ; preds = %cond.false9.i359.7
  %cmp13.i360.7 = fcmp olt float %435, 3.500000e+00
  br i1 %cmp13.i360.7, label %_Z5pack4f.exit369.7, label %cond.false15.i364.7, !decision.origin !925

cond.false15.i364.7:                              ; preds = %cond.false12.i361.7
  %cmp16.i362.7 = fcmp ole float %435, 5.000000e+00
  %cond.i363.7 = select i1 %cmp16.i362.7, i32 6, i32 7
  br label %_Z5pack4f.exit369.7, !decision.origin !926

_Z5pack4f.exit369.7:                              ; preds = %cond.false15.i364.7, %cond.false12.i361.7, %cond.false9.i359.7, %cond.false6.i357.7, %cond.false3.i355.7, %cond.false.i353.7, %_Z5pack4f.exit.6
  %cond27.i365.7 = phi i32 [ 0, %_Z5pack4f.exit.6 ], [ 1, %cond.false.i353.7 ], [ 2, %cond.false3.i355.7 ], [ 3, %cond.false6.i357.7 ], [ 4, %cond.false9.i359.7 ], [ %cond.i363.7, %cond.false15.i364.7 ], [ 5, %cond.false12.i361.7 ]
  %436 = bitcast float %mul175.7 to i32
  %shr.i366.7 = lshr i32 %436, 28
  %and.i367.7 = and i32 %shr.i366.7, 8
  %or.i368.7 = or i32 %cond27.i365.7, %and.i367.7
  %mul183.7 = fmul float %410, %77
  %437 = tail call float @llvm.fabs.f32(float %mul183.7) #3
  %cmp.i.7 = fcmp ugt float %437, 2.500000e-01
  br i1 %cmp.i.7, label %cond.false.i.7, label %_Z5pack4f.exit.7, !decision.origin !927

cond.false.i.7:                                   ; preds = %_Z5pack4f.exit369.7
  %cmp1.i.7 = fcmp olt float %437, 7.500000e-01
  br i1 %cmp1.i.7, label %_Z5pack4f.exit.7, label %cond.false3.i.7, !decision.origin !928

cond.false3.i.7:                                  ; preds = %cond.false.i.7
  %cmp4.i.7 = fcmp ugt float %437, 1.250000e+00
  br i1 %cmp4.i.7, label %cond.false6.i.7, label %_Z5pack4f.exit.7, !decision.origin !929

cond.false6.i.7:                                  ; preds = %cond.false3.i.7
  %cmp7.i.7 = fcmp olt float %437, 1.750000e+00
  br i1 %cmp7.i.7, label %_Z5pack4f.exit.7, label %cond.false9.i.7, !decision.origin !930

cond.false9.i.7:                                  ; preds = %cond.false6.i.7
  %cmp10.i.7 = fcmp ugt float %437, 2.500000e+00
  br i1 %cmp10.i.7, label %cond.false12.i.7, label %_Z5pack4f.exit.7, !decision.origin !931

cond.false12.i.7:                                 ; preds = %cond.false9.i.7
  %cmp13.i.7 = fcmp olt float %437, 3.500000e+00
  br i1 %cmp13.i.7, label %_Z5pack4f.exit.7, label %cond.false15.i.7, !decision.origin !932

cond.false15.i.7:                                 ; preds = %cond.false12.i.7
  %cmp16.i.7 = fcmp ole float %437, 5.000000e+00
  %cond.i.7 = select i1 %cmp16.i.7, i32 6, i32 7
  br label %_Z5pack4f.exit.7, !decision.origin !933

_Z5pack4f.exit.7:                                 ; preds = %cond.false15.i.7, %cond.false12.i.7, %cond.false9.i.7, %cond.false6.i.7, %cond.false3.i.7, %cond.false.i.7, %_Z5pack4f.exit369.7
  %cond27.i.7 = phi i32 [ 0, %_Z5pack4f.exit369.7 ], [ 1, %cond.false.i.7 ], [ 2, %cond.false3.i.7 ], [ 3, %cond.false6.i.7 ], [ 4, %cond.false9.i.7 ], [ %cond.i.7, %cond.false15.i.7 ], [ 5, %cond.false12.i.7 ]
  %438 = bitcast float %mul183.7 to i32
  %shr.i.7 = lshr i32 %438, 28
  %and.i.7 = and i32 %shr.i.7, 8
  %or.i.7 = or i32 %cond27.i.7, %and.i.7
  %shl.7 = shl nuw nsw i32 %or.i.7, 4
  %or.7 = or i32 %or.i368.7, %shl.7
  %conv185.7 = trunc i32 %or.7 to i8
  %add187.7 = add nsw i64 %add164, 7
  %arrayidx188339.7 = getelementptr inbounds i8, i8 addrspace(1)* %cond19.v, i64 %add187.7
  store i8 %conv185.7, i8 addrspace(1)* %arrayidx188339.7, align 1, !tbaa !18
  br i1 %tobool.not, label %if.end204, label %if.then193, !decision.origin !934

merged.bb:                                        ; preds = %unify.bb
  %merged.select = select i1 %decision.was_left, float 0.000000e+00, float 5.000000e-01
  %439 = tail call float @llvm.copysign.f32(float %merged.select, float %mul116) #3
  br label %quant_decide.exit.pair.join
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
!66 = !{!"cache_eval:%if.else.7"}
!67 = !{}
!68 = !{!"merge(cache_eval:%if.then.i,cache_eval:%if.then3.i)"}
!69 = !{!"D13", i32 0, i32 1}
!70 = !{!"cache_eval:%if.then.i", !"cache_eval:%if.then3.i"}
!71 = !{!"cache_eval:%if.else4.i"}
!72 = !{!"cache_eval:%if.then7.i"}
!73 = !{!"D13", i32 2, i32 2}
!74 = !{!"cache_eval:%if.else8.i"}
!75 = !{!"cache_eval:%if.then11.i"}
!76 = !{!"D13", i32 3, i32 3}
!77 = !{!"cache_eval:%if.else12.i"}
!78 = !{!"cache_eval:%if.then15.i"}
!79 = !{!"D13", i32 4, i32 4}
!80 = !{!"cache_eval:%if.else16.i"}
!81 = !{!"cache_eval:%if.then19.i"}
!82 = !{!"D13", i32 5, i32 5}
!83 = !{!"cache_eval:%if.else20.i"}
!84 = !{!"cache_eval:%if.then23.i"}
!85 = !{!"D13", i32 6, i32 6}
!86 = !{!"cache_eval:%if.end29.i"}
!87 = !{!"D13", i32 7, i32 7}
!88 = !{!"cache_eval:%quant_decide.exit"}
!89 = !{!"cache_eval:%if.then.i709"}
!90 = !{!"D14", i32 0, i32 0}
!91 = !{!"cache_eval:%if.else.i711"}
!92 = !{!"cache_eval:%if.then3.i712"}
!93 = !{!"D14", i32 1, i32 1}
!94 = !{!"cache_eval:%if.else4.i714"}
!95 = !{!"cache_eval:%if.then7.i715"}
!96 = !{!"D14", i32 2, i32 2}
!97 = !{!"cache_eval:%if.else8.i717"}
!98 = !{!"cache_eval:%if.then11.i718"}
!99 = !{!"D14", i32 3, i32 3}
!100 = !{!"cache_eval:%if.else12.i720"}
!101 = !{!"cache_eval:%if.then15.i721"}
!102 = !{!"D14", i32 4, i32 4}
!103 = !{!"cache_eval:%if.else16.i723"}
!104 = !{!"cache_eval:%if.then19.i724"}
!105 = !{!"D14", i32 5, i32 5}
!106 = !{!"cache_eval:%if.else20.i726"}
!107 = !{!"cache_eval:%if.then23.i727"}
!108 = !{!"D14", i32 6, i32 6}
!109 = !{!"cache_eval:%if.end29.i728"}
!110 = !{!"D14", i32 7, i32 7}
!111 = !{!"cache_eval:%quant_decide.exit729"}
!112 = !{!"cache_eval:%if.then.i687"}
!113 = !{!"D15", i32 0, i32 0}
!114 = !{!"cache_eval:%if.else.i689"}
!115 = !{!"cache_eval:%if.then3.i690"}
!116 = !{!"D15", i32 1, i32 1}
!117 = !{!"cache_eval:%if.else4.i692"}
!118 = !{!"cache_eval:%if.then7.i693"}
!119 = !{!"D15", i32 2, i32 2}
!120 = !{!"cache_eval:%if.else8.i695"}
!121 = !{!"cache_eval:%if.then11.i696"}
!122 = !{!"D15", i32 3, i32 3}
!123 = !{!"cache_eval:%if.else12.i698"}
!124 = !{!"cache_eval:%if.then15.i699"}
!125 = !{!"D15", i32 4, i32 4}
!126 = !{!"cache_eval:%if.else16.i701"}
!127 = !{!"cache_eval:%if.then19.i702"}
!128 = !{!"D15", i32 5, i32 5}
!129 = !{!"cache_eval:%if.else20.i704"}
!130 = !{!"cache_eval:%if.then23.i705"}
!131 = !{!"D15", i32 6, i32 6}
!132 = !{!"cache_eval:%if.end29.i706"}
!133 = !{!"D15", i32 7, i32 7}
!134 = !{!"cache_eval:%quant_decide.exit707"}
!135 = !{!"cache_eval:%if.then.i665"}
!136 = !{!"D16", i32 0, i32 0}
!137 = !{!"cache_eval:%if.else.i667"}
!138 = !{!"cache_eval:%if.then3.i668"}
!139 = !{!"D16", i32 1, i32 1}
!140 = !{!"cache_eval:%if.else4.i670"}
!141 = !{!"cache_eval:%if.then7.i671"}
!142 = !{!"D16", i32 2, i32 2}
!143 = !{!"cache_eval:%if.else8.i673"}
!144 = !{!"cache_eval:%if.then11.i674"}
!145 = !{!"D16", i32 3, i32 3}
!146 = !{!"cache_eval:%if.else12.i676"}
!147 = !{!"cache_eval:%if.then15.i677"}
!148 = !{!"D16", i32 4, i32 4}
!149 = !{!"cache_eval:%if.else16.i679"}
!150 = !{!"cache_eval:%if.then19.i680"}
!151 = !{!"D16", i32 5, i32 5}
!152 = !{!"cache_eval:%if.else20.i682"}
!153 = !{!"cache_eval:%if.then23.i683"}
!154 = !{!"D16", i32 6, i32 6}
!155 = !{!"cache_eval:%if.end29.i684"}
!156 = !{!"D16", i32 7, i32 7}
!157 = !{!"cache_eval:%quant_decide.exit685"}
!158 = !{!"cache_eval:%if.then.i643"}
!159 = !{!"D17", i32 0, i32 0}
!160 = !{!"cache_eval:%if.else.i645"}
!161 = !{!"cache_eval:%if.then3.i646"}
!162 = !{!"D17", i32 1, i32 1}
!163 = !{!"cache_eval:%if.else4.i648"}
!164 = !{!"cache_eval:%if.then7.i649"}
!165 = !{!"D17", i32 2, i32 2}
!166 = !{!"cache_eval:%if.else8.i651"}
!167 = !{!"cache_eval:%if.then11.i652"}
!168 = !{!"D17", i32 3, i32 3}
!169 = !{!"cache_eval:%if.else12.i654"}
!170 = !{!"cache_eval:%if.then15.i655"}
!171 = !{!"D17", i32 4, i32 4}
!172 = !{!"cache_eval:%if.else16.i657"}
!173 = !{!"cache_eval:%if.then19.i658"}
!174 = !{!"D17", i32 5, i32 5}
!175 = !{!"cache_eval:%if.else20.i660"}
!176 = !{!"cache_eval:%if.then23.i661"}
!177 = !{!"D17", i32 6, i32 6}
!178 = !{!"cache_eval:%if.end29.i662"}
!179 = !{!"D17", i32 7, i32 7}
!180 = !{!"cache_eval:%quant_decide.exit663"}
!181 = !{!"cache_eval:%if.then.i621"}
!182 = !{!"D18", i32 0, i32 0}
!183 = !{!"cache_eval:%if.else.i623"}
!184 = !{!"cache_eval:%if.then3.i624"}
!185 = !{!"D18", i32 1, i32 1}
!186 = !{!"cache_eval:%if.else4.i626"}
!187 = !{!"cache_eval:%if.then7.i627"}
!188 = !{!"D18", i32 2, i32 2}
!189 = !{!"cache_eval:%if.else8.i629"}
!190 = !{!"cache_eval:%if.then11.i630"}
!191 = !{!"D18", i32 3, i32 3}
!192 = !{!"cache_eval:%if.else12.i632"}
!193 = !{!"cache_eval:%if.then15.i633"}
!194 = !{!"D18", i32 4, i32 4}
!195 = !{!"cache_eval:%if.else16.i635"}
!196 = !{!"cache_eval:%if.then19.i636"}
!197 = !{!"D18", i32 5, i32 5}
!198 = !{!"cache_eval:%if.else20.i638"}
!199 = !{!"cache_eval:%if.then23.i639"}
!200 = !{!"D18", i32 6, i32 6}
!201 = !{!"cache_eval:%if.end29.i640"}
!202 = !{!"D18", i32 7, i32 7}
!203 = !{!"cache_eval:%quant_decide.exit641"}
!204 = !{!"cache_eval:%if.then.i599"}
!205 = !{!"D19", i32 0, i32 0}
!206 = !{!"cache_eval:%if.else.i601"}
!207 = !{!"cache_eval:%if.then3.i602"}
!208 = !{!"D19", i32 1, i32 1}
!209 = !{!"cache_eval:%if.else4.i604"}
!210 = !{!"cache_eval:%if.then7.i605"}
!211 = !{!"D19", i32 2, i32 2}
!212 = !{!"cache_eval:%if.else8.i607"}
!213 = !{!"cache_eval:%if.then11.i608"}
!214 = !{!"D19", i32 3, i32 3}
!215 = !{!"cache_eval:%if.else12.i610"}
!216 = !{!"cache_eval:%if.then15.i611"}
!217 = !{!"D19", i32 4, i32 4}
!218 = !{!"cache_eval:%if.else16.i613"}
!219 = !{!"cache_eval:%if.then19.i614"}
!220 = !{!"D19", i32 5, i32 5}
!221 = !{!"cache_eval:%if.else20.i616"}
!222 = !{!"cache_eval:%if.then23.i617"}
!223 = !{!"D19", i32 6, i32 6}
!224 = !{!"cache_eval:%if.end29.i618"}
!225 = !{!"D19", i32 7, i32 7}
!226 = !{!"cache_eval:%quant_decide.exit619"}
!227 = !{!"cache_eval:%if.then.i577"}
!228 = !{!"D20", i32 0, i32 0}
!229 = !{!"cache_eval:%if.else.i579"}
!230 = !{!"cache_eval:%if.then3.i580"}
!231 = !{!"D20", i32 1, i32 1}
!232 = !{!"cache_eval:%if.else4.i582"}
!233 = !{!"cache_eval:%if.then7.i583"}
!234 = !{!"D20", i32 2, i32 2}
!235 = !{!"cache_eval:%if.else8.i585"}
!236 = !{!"cache_eval:%if.then11.i586"}
!237 = !{!"D20", i32 3, i32 3}
!238 = !{!"cache_eval:%if.else12.i588"}
!239 = !{!"cache_eval:%if.then15.i589"}
!240 = !{!"D20", i32 4, i32 4}
!241 = !{!"cache_eval:%if.else16.i591"}
!242 = !{!"cache_eval:%if.then19.i592"}
!243 = !{!"D20", i32 5, i32 5}
!244 = !{!"cache_eval:%if.else20.i594"}
!245 = !{!"cache_eval:%if.then23.i595"}
!246 = !{!"D20", i32 6, i32 6}
!247 = !{!"cache_eval:%if.end29.i596"}
!248 = !{!"D20", i32 7, i32 7}
!249 = !{!"cache_eval:%quant_decide.exit597"}
!250 = !{!"cache_eval:%if.then.i555"}
!251 = !{!"D21", i32 0, i32 0}
!252 = !{!"cache_eval:%if.else.i557"}
!253 = !{!"cache_eval:%if.then3.i558"}
!254 = !{!"D21", i32 1, i32 1}
!255 = !{!"cache_eval:%if.else4.i560"}
!256 = !{!"cache_eval:%if.then7.i561"}
!257 = !{!"D21", i32 2, i32 2}
!258 = !{!"cache_eval:%if.else8.i563"}
!259 = !{!"cache_eval:%if.then11.i564"}
!260 = !{!"D21", i32 3, i32 3}
!261 = !{!"cache_eval:%if.else12.i566"}
!262 = !{!"cache_eval:%if.then15.i567"}
!263 = !{!"D21", i32 4, i32 4}
!264 = !{!"cache_eval:%if.else16.i569"}
!265 = !{!"cache_eval:%if.then19.i570"}
!266 = !{!"D21", i32 5, i32 5}
!267 = !{!"cache_eval:%if.else20.i572"}
!268 = !{!"cache_eval:%if.then23.i573"}
!269 = !{!"D21", i32 6, i32 6}
!270 = !{!"cache_eval:%if.end29.i574"}
!271 = !{!"D21", i32 7, i32 7}
!272 = !{!"cache_eval:%quant_decide.exit575"}
!273 = !{!"cache_eval:%if.then.i533"}
!274 = !{!"D22", i32 0, i32 0}
!275 = !{!"cache_eval:%if.else.i535"}
!276 = !{!"cache_eval:%if.then3.i536"}
!277 = !{!"D22", i32 1, i32 1}
!278 = !{!"cache_eval:%if.else4.i538"}
!279 = !{!"cache_eval:%if.then7.i539"}
!280 = !{!"D22", i32 2, i32 2}
!281 = !{!"cache_eval:%if.else8.i541"}
!282 = !{!"cache_eval:%if.then11.i542"}
!283 = !{!"D22", i32 3, i32 3}
!284 = !{!"cache_eval:%if.else12.i544"}
!285 = !{!"cache_eval:%if.then15.i545"}
!286 = !{!"D22", i32 4, i32 4}
!287 = !{!"cache_eval:%if.else16.i547"}
!288 = !{!"cache_eval:%if.then19.i548"}
!289 = !{!"D22", i32 5, i32 5}
!290 = !{!"cache_eval:%if.else20.i550"}
!291 = !{!"cache_eval:%if.then23.i551"}
!292 = !{!"D22", i32 6, i32 6}
!293 = !{!"cache_eval:%if.end29.i552"}
!294 = !{!"D22", i32 7, i32 7}
!295 = !{!"cache_eval:%quant_decide.exit553"}
!296 = !{!"cache_eval:%if.then.i511"}
!297 = !{!"D23", i32 0, i32 0}
!298 = !{!"cache_eval:%if.else.i513"}
!299 = !{!"cache_eval:%if.then3.i514"}
!300 = !{!"D23", i32 1, i32 1}
!301 = !{!"cache_eval:%if.else4.i516"}
!302 = !{!"cache_eval:%if.then7.i517"}
!303 = !{!"D23", i32 2, i32 2}
!304 = !{!"cache_eval:%if.else8.i519"}
!305 = !{!"cache_eval:%if.then11.i520"}
!306 = !{!"D23", i32 3, i32 3}
!307 = !{!"cache_eval:%if.else12.i522"}
!308 = !{!"cache_eval:%if.then15.i523"}
!309 = !{!"D23", i32 4, i32 4}
!310 = !{!"cache_eval:%if.else16.i525"}
!311 = !{!"cache_eval:%if.then19.i526"}
!312 = !{!"D23", i32 5, i32 5}
!313 = !{!"cache_eval:%if.else20.i528"}
!314 = !{!"cache_eval:%if.then23.i529"}
!315 = !{!"D23", i32 6, i32 6}
!316 = !{!"cache_eval:%if.end29.i530"}
!317 = !{!"D23", i32 7, i32 7}
!318 = !{!"cache_eval:%quant_decide.exit531"}
!319 = !{!"cache_eval:%if.then.i489"}
!320 = !{!"D24", i32 0, i32 0}
!321 = !{!"cache_eval:%if.else.i491"}
!322 = !{!"cache_eval:%if.then3.i492"}
!323 = !{!"D24", i32 1, i32 1}
!324 = !{!"cache_eval:%if.else4.i494"}
!325 = !{!"cache_eval:%if.then7.i495"}
!326 = !{!"D24", i32 2, i32 2}
!327 = !{!"cache_eval:%if.else8.i497"}
!328 = !{!"cache_eval:%if.then11.i498"}
!329 = !{!"D24", i32 3, i32 3}
!330 = !{!"cache_eval:%if.else12.i500"}
!331 = !{!"cache_eval:%if.then15.i501"}
!332 = !{!"D24", i32 4, i32 4}
!333 = !{!"cache_eval:%if.else16.i503"}
!334 = !{!"cache_eval:%if.then19.i504"}
!335 = !{!"D24", i32 5, i32 5}
!336 = !{!"cache_eval:%if.else20.i506"}
!337 = !{!"cache_eval:%if.then23.i507"}
!338 = !{!"D24", i32 6, i32 6}
!339 = !{!"cache_eval:%if.end29.i508"}
!340 = !{!"D24", i32 7, i32 7}
!341 = !{!"cache_eval:%quant_decide.exit509"}
!342 = !{!"cache_eval:%if.then.i467"}
!343 = !{!"D25", i32 0, i32 0}
!344 = !{!"cache_eval:%if.else.i469"}
!345 = !{!"cache_eval:%if.then3.i470"}
!346 = !{!"D25", i32 1, i32 1}
!347 = !{!"cache_eval:%if.else4.i472"}
!348 = !{!"cache_eval:%if.then7.i473"}
!349 = !{!"D25", i32 2, i32 2}
!350 = !{!"cache_eval:%if.else8.i475"}
!351 = !{!"cache_eval:%if.then11.i476"}
!352 = !{!"D25", i32 3, i32 3}
!353 = !{!"cache_eval:%if.else12.i478"}
!354 = !{!"cache_eval:%if.then15.i479"}
!355 = !{!"D25", i32 4, i32 4}
!356 = !{!"cache_eval:%if.else16.i481"}
!357 = !{!"cache_eval:%if.then19.i482"}
!358 = !{!"D25", i32 5, i32 5}
!359 = !{!"cache_eval:%if.else20.i484"}
!360 = !{!"cache_eval:%if.then23.i485"}
!361 = !{!"D25", i32 6, i32 6}
!362 = !{!"cache_eval:%if.end29.i486"}
!363 = !{!"D25", i32 7, i32 7}
!364 = !{!"cache_eval:%quant_decide.exit487"}
!365 = !{!"cache_eval:%if.then.i445"}
!366 = !{!"D26", i32 0, i32 0}
!367 = !{!"cache_eval:%if.else.i447"}
!368 = !{!"cache_eval:%if.then3.i448"}
!369 = !{!"D26", i32 1, i32 1}
!370 = !{!"cache_eval:%if.else4.i450"}
!371 = !{!"cache_eval:%if.then7.i451"}
!372 = !{!"D26", i32 2, i32 2}
!373 = !{!"cache_eval:%if.else8.i453"}
!374 = !{!"cache_eval:%if.then11.i454"}
!375 = !{!"D26", i32 3, i32 3}
!376 = !{!"cache_eval:%if.else12.i456"}
!377 = !{!"cache_eval:%if.then15.i457"}
!378 = !{!"D26", i32 4, i32 4}
!379 = !{!"cache_eval:%if.else16.i459"}
!380 = !{!"cache_eval:%if.then19.i460"}
!381 = !{!"D26", i32 5, i32 5}
!382 = !{!"cache_eval:%if.else20.i462"}
!383 = !{!"cache_eval:%if.then23.i463"}
!384 = !{!"D26", i32 6, i32 6}
!385 = !{!"cache_eval:%if.end29.i464"}
!386 = !{!"D26", i32 7, i32 7}
!387 = !{!"cache_eval:%quant_decide.exit465"}
!388 = !{!"cache_eval:%if.then.i423"}
!389 = !{!"D27", i32 0, i32 0}
!390 = !{!"cache_eval:%if.else.i425"}
!391 = !{!"cache_eval:%if.then3.i426"}
!392 = !{!"D27", i32 1, i32 1}
!393 = !{!"cache_eval:%if.else4.i428"}
!394 = !{!"cache_eval:%if.then7.i429"}
!395 = !{!"D27", i32 2, i32 2}
!396 = !{!"cache_eval:%if.else8.i431"}
!397 = !{!"cache_eval:%if.then11.i432"}
!398 = !{!"D27", i32 3, i32 3}
!399 = !{!"cache_eval:%if.else12.i434"}
!400 = !{!"cache_eval:%if.then15.i435"}
!401 = !{!"D27", i32 4, i32 4}
!402 = !{!"cache_eval:%if.else16.i437"}
!403 = !{!"cache_eval:%if.then19.i438"}
!404 = !{!"D27", i32 5, i32 5}
!405 = !{!"cache_eval:%if.else20.i440"}
!406 = !{!"cache_eval:%if.then23.i441"}
!407 = !{!"D27", i32 6, i32 6}
!408 = !{!"cache_eval:%if.end29.i442"}
!409 = !{!"D27", i32 7, i32 7}
!410 = !{!"cache_eval:%quant_decide.exit443"}
!411 = !{!"cache_eval:%if.then.i401"}
!412 = !{!"D28", i32 0, i32 0}
!413 = !{!"cache_eval:%if.else.i403"}
!414 = !{!"cache_eval:%if.then3.i404"}
!415 = !{!"D28", i32 1, i32 1}
!416 = !{!"cache_eval:%if.else4.i406"}
!417 = !{!"cache_eval:%if.then7.i407"}
!418 = !{!"D28", i32 2, i32 2}
!419 = !{!"cache_eval:%if.else8.i409"}
!420 = !{!"cache_eval:%if.then11.i410"}
!421 = !{!"D28", i32 3, i32 3}
!422 = !{!"cache_eval:%if.else12.i412"}
!423 = !{!"cache_eval:%if.then15.i413"}
!424 = !{!"D28", i32 4, i32 4}
!425 = !{!"cache_eval:%if.else16.i415"}
!426 = !{!"cache_eval:%if.then19.i416"}
!427 = !{!"D28", i32 5, i32 5}
!428 = !{!"cache_eval:%if.else20.i418"}
!429 = !{!"cache_eval:%if.then23.i419"}
!430 = !{!"D28", i32 6, i32 6}
!431 = !{!"cache_eval:%if.end29.i420"}
!432 = !{!"D28", i32 7, i32 7}
!433 = !{!"cache_eval:%quant_decide.exit421"}
!434 = !{!"cache_eval:%if.then97.7"}
!435 = !{!"cache_eval:%for.inc138.7"}
!436 = !{!"cache_eval:%_Z4enc8f.exit.thread396.1"}
!437 = !{!"cache_eval:%_Z4dec8i.exit.i.2.1"}
!438 = !{!"cache_eval:%cond.true.i.i.3.1"}
!439 = !{!"cache_eval:%cond.false.i.i.3.1"}
!440 = !{!"cache_eval:%_Z4dec8i.exit.i.3.1"}
!441 = !{!"cache_eval:%cond.true.i.i.4.1"}
!442 = !{!"cache_eval:%cond.false.i.i.4.1"}
!443 = !{!"cache_eval:%_Z4dec8i.exit.i.4.1"}
!444 = !{!"cache_eval:%cond.true.i.i.5.1"}
!445 = !{!"cache_eval:%cond.false.i.i.5.1"}
!446 = !{!"cache_eval:%_Z4dec8i.exit.i.5.1"}
!447 = !{!"cache_eval:%cond.true.i.i.6.1"}
!448 = !{!"cache_eval:%cond.false.i.i.6.1"}
!449 = !{!"cache_eval:%_Z4dec8i.exit.i.6.1"}
!450 = !{!"cache_eval:%if.end9.i.1"}
!451 = !{!"cache_eval:%cond.true.i69.i.1"}
!452 = !{!"cache_eval:%cond.false.i72.i.1"}
!453 = !{!"cache_eval:%_Z4dec8i.exit74.i.1"}
!454 = !{!"cache_eval:%cond.true.i56.i.1"}
!455 = !{!"cache_eval:%cond.false.i59.i.1"}
!456 = !{!"cache_eval:%_Z4dec8i.exit61.i.1"}
!457 = !{!"cache_eval:%cond.false.i384.1"}
!458 = !{!"cache_eval:%cond.false18.i.1"}
!459 = !{!"cache_eval:%_Z4enc8f.exit.1"}
!460 = !{!"cache_eval:%cond.true.i.1"}
!461 = !{!"cache_eval:%_Z4enc8f.exit.thread.1"}
!462 = !{!"cache_eval:%cond.false.i377.1"}
!463 = !{!"cache_eval:%_Z4dec8i.exit.1"}
!464 = !{!"cache_eval:%cond.end75.1.thread"}
!465 = !{!"cache_eval:%cond.end75.1"}
!466 = !{!"cache_eval:%if.else.7.1"}
!467 = !{!"cache_eval:%if.then.i379"}
!468 = !{!"D38", i32 0, i32 0}
!469 = !{!"cache_eval:%if.else.i381"}
!470 = !{!"cache_eval:%if.then3.i382"}
!471 = !{!"D38", i32 1, i32 1}
!472 = !{!"cache_eval:%if.else4.i384"}
!473 = !{!"cache_eval:%if.then7.i385"}
!474 = !{!"D38", i32 2, i32 2}
!475 = !{!"cache_eval:%if.else8.i387"}
!476 = !{!"cache_eval:%if.then11.i388"}
!477 = !{!"D38", i32 3, i32 3}
!478 = !{!"cache_eval:%if.else12.i390"}
!479 = !{!"cache_eval:%if.then15.i391"}
!480 = !{!"D38", i32 4, i32 4}
!481 = !{!"cache_eval:%if.else16.i393"}
!482 = !{!"cache_eval:%if.then19.i394"}
!483 = !{!"D38", i32 5, i32 5}
!484 = !{!"cache_eval:%if.else20.i396"}
!485 = !{!"cache_eval:%if.then23.i397"}
!486 = !{!"D38", i32 6, i32 6}
!487 = !{!"cache_eval:%if.end29.i398"}
!488 = !{!"D38", i32 7, i32 7}
!489 = !{!"cache_eval:%quant_decide.exit399"}
!490 = !{!"cache_eval:%if.then.i357"}
!491 = !{!"D39", i32 0, i32 0}
!492 = !{!"cache_eval:%if.else.i359"}
!493 = !{!"cache_eval:%if.then3.i360"}
!494 = !{!"D39", i32 1, i32 1}
!495 = !{!"cache_eval:%if.else4.i362"}
!496 = !{!"cache_eval:%if.then7.i363"}
!497 = !{!"D39", i32 2, i32 2}
!498 = !{!"cache_eval:%if.else8.i365"}
!499 = !{!"cache_eval:%if.then11.i366"}
!500 = !{!"D39", i32 3, i32 3}
!501 = !{!"cache_eval:%if.else12.i368"}
!502 = !{!"cache_eval:%if.then15.i369"}
!503 = !{!"D39", i32 4, i32 4}
!504 = !{!"cache_eval:%if.else16.i371"}
!505 = !{!"cache_eval:%if.then19.i372"}
!506 = !{!"D39", i32 5, i32 5}
!507 = !{!"cache_eval:%if.else20.i374"}
!508 = !{!"cache_eval:%if.then23.i375"}
!509 = !{!"D39", i32 6, i32 6}
!510 = !{!"cache_eval:%if.end29.i376"}
!511 = !{!"D39", i32 7, i32 7}
!512 = !{!"cache_eval:%quant_decide.exit377"}
!513 = !{!"cache_eval:%if.then.i335"}
!514 = !{!"D40", i32 0, i32 0}
!515 = !{!"cache_eval:%if.else.i337"}
!516 = !{!"cache_eval:%if.then3.i338"}
!517 = !{!"D40", i32 1, i32 1}
!518 = !{!"cache_eval:%if.else4.i340"}
!519 = !{!"cache_eval:%if.then7.i341"}
!520 = !{!"D40", i32 2, i32 2}
!521 = !{!"cache_eval:%if.else8.i343"}
!522 = !{!"cache_eval:%if.then11.i344"}
!523 = !{!"D40", i32 3, i32 3}
!524 = !{!"cache_eval:%if.else12.i346"}
!525 = !{!"cache_eval:%if.then15.i347"}
!526 = !{!"D40", i32 4, i32 4}
!527 = !{!"cache_eval:%if.else16.i349"}
!528 = !{!"cache_eval:%if.then19.i350"}
!529 = !{!"D40", i32 5, i32 5}
!530 = !{!"cache_eval:%if.else20.i352"}
!531 = !{!"cache_eval:%if.then23.i353"}
!532 = !{!"D40", i32 6, i32 6}
!533 = !{!"cache_eval:%if.end29.i354"}
!534 = !{!"D40", i32 7, i32 7}
!535 = !{!"cache_eval:%quant_decide.exit355"}
!536 = !{!"cache_eval:%if.then.i313"}
!537 = !{!"D41", i32 0, i32 0}
!538 = !{!"cache_eval:%if.else.i315"}
!539 = !{!"cache_eval:%if.then3.i316"}
!540 = !{!"D41", i32 1, i32 1}
!541 = !{!"cache_eval:%if.else4.i318"}
!542 = !{!"cache_eval:%if.then7.i319"}
!543 = !{!"D41", i32 2, i32 2}
!544 = !{!"cache_eval:%if.else8.i321"}
!545 = !{!"cache_eval:%if.then11.i322"}
!546 = !{!"D41", i32 3, i32 3}
!547 = !{!"cache_eval:%if.else12.i324"}
!548 = !{!"cache_eval:%if.then15.i325"}
!549 = !{!"D41", i32 4, i32 4}
!550 = !{!"cache_eval:%if.else16.i327"}
!551 = !{!"cache_eval:%if.then19.i328"}
!552 = !{!"D41", i32 5, i32 5}
!553 = !{!"cache_eval:%if.else20.i330"}
!554 = !{!"cache_eval:%if.then23.i331"}
!555 = !{!"D41", i32 6, i32 6}
!556 = !{!"cache_eval:%if.end29.i332"}
!557 = !{!"D41", i32 7, i32 7}
!558 = !{!"cache_eval:%quant_decide.exit333"}
!559 = !{!"cache_eval:%if.then.i291"}
!560 = !{!"D42", i32 0, i32 0}
!561 = !{!"cache_eval:%if.else.i293"}
!562 = !{!"cache_eval:%if.then3.i294"}
!563 = !{!"D42", i32 1, i32 1}
!564 = !{!"cache_eval:%if.else4.i296"}
!565 = !{!"cache_eval:%if.then7.i297"}
!566 = !{!"D42", i32 2, i32 2}
!567 = !{!"cache_eval:%if.else8.i299"}
!568 = !{!"cache_eval:%if.then11.i300"}
!569 = !{!"D42", i32 3, i32 3}
!570 = !{!"cache_eval:%if.else12.i302"}
!571 = !{!"cache_eval:%if.then15.i303"}
!572 = !{!"D42", i32 4, i32 4}
!573 = !{!"cache_eval:%if.else16.i305"}
!574 = !{!"cache_eval:%if.then19.i306"}
!575 = !{!"D42", i32 5, i32 5}
!576 = !{!"cache_eval:%if.else20.i308"}
!577 = !{!"cache_eval:%if.then23.i309"}
!578 = !{!"D42", i32 6, i32 6}
!579 = !{!"cache_eval:%if.end29.i310"}
!580 = !{!"D42", i32 7, i32 7}
!581 = !{!"cache_eval:%quant_decide.exit311"}
!582 = !{!"cache_eval:%if.then.i269"}
!583 = !{!"D43", i32 0, i32 0}
!584 = !{!"cache_eval:%if.else.i271"}
!585 = !{!"cache_eval:%if.then3.i272"}
!586 = !{!"D43", i32 1, i32 1}
!587 = !{!"cache_eval:%if.else4.i274"}
!588 = !{!"cache_eval:%if.then7.i275"}
!589 = !{!"D43", i32 2, i32 2}
!590 = !{!"cache_eval:%if.else8.i277"}
!591 = !{!"cache_eval:%if.then11.i278"}
!592 = !{!"D43", i32 3, i32 3}
!593 = !{!"cache_eval:%if.else12.i280"}
!594 = !{!"cache_eval:%if.then15.i281"}
!595 = !{!"D43", i32 4, i32 4}
!596 = !{!"cache_eval:%if.else16.i283"}
!597 = !{!"cache_eval:%if.then19.i284"}
!598 = !{!"D43", i32 5, i32 5}
!599 = !{!"cache_eval:%if.else20.i286"}
!600 = !{!"cache_eval:%if.then23.i287"}
!601 = !{!"D43", i32 6, i32 6}
!602 = !{!"cache_eval:%if.end29.i288"}
!603 = !{!"D43", i32 7, i32 7}
!604 = !{!"cache_eval:%quant_decide.exit289"}
!605 = !{!"cache_eval:%if.then.i247"}
!606 = !{!"D44", i32 0, i32 0}
!607 = !{!"cache_eval:%if.else.i249"}
!608 = !{!"cache_eval:%if.then3.i250"}
!609 = !{!"D44", i32 1, i32 1}
!610 = !{!"cache_eval:%if.else4.i252"}
!611 = !{!"cache_eval:%if.then7.i253"}
!612 = !{!"D44", i32 2, i32 2}
!613 = !{!"cache_eval:%if.else8.i255"}
!614 = !{!"cache_eval:%if.then11.i256"}
!615 = !{!"D44", i32 3, i32 3}
!616 = !{!"cache_eval:%if.else12.i258"}
!617 = !{!"cache_eval:%if.then15.i259"}
!618 = !{!"D44", i32 4, i32 4}
!619 = !{!"cache_eval:%if.else16.i261"}
!620 = !{!"cache_eval:%if.then19.i262"}
!621 = !{!"D44", i32 5, i32 5}
!622 = !{!"cache_eval:%if.else20.i264"}
!623 = !{!"cache_eval:%if.then23.i265"}
!624 = !{!"D44", i32 6, i32 6}
!625 = !{!"cache_eval:%if.end29.i266"}
!626 = !{!"D44", i32 7, i32 7}
!627 = !{!"cache_eval:%quant_decide.exit267"}
!628 = !{!"cache_eval:%if.then.i225"}
!629 = !{!"D45", i32 0, i32 0}
!630 = !{!"cache_eval:%if.else.i227"}
!631 = !{!"cache_eval:%if.then3.i228"}
!632 = !{!"D45", i32 1, i32 1}
!633 = !{!"cache_eval:%if.else4.i230"}
!634 = !{!"cache_eval:%if.then7.i231"}
!635 = !{!"D45", i32 2, i32 2}
!636 = !{!"cache_eval:%if.else8.i233"}
!637 = !{!"cache_eval:%if.then11.i234"}
!638 = !{!"D45", i32 3, i32 3}
!639 = !{!"cache_eval:%if.else12.i236"}
!640 = !{!"cache_eval:%if.then15.i237"}
!641 = !{!"D45", i32 4, i32 4}
!642 = !{!"cache_eval:%if.else16.i239"}
!643 = !{!"cache_eval:%if.then19.i240"}
!644 = !{!"D45", i32 5, i32 5}
!645 = !{!"cache_eval:%if.else20.i242"}
!646 = !{!"cache_eval:%if.then23.i243"}
!647 = !{!"D45", i32 6, i32 6}
!648 = !{!"cache_eval:%if.end29.i244"}
!649 = !{!"D45", i32 7, i32 7}
!650 = !{!"cache_eval:%quant_decide.exit245"}
!651 = !{!"cache_eval:%if.then.i203"}
!652 = !{!"D46", i32 0, i32 0}
!653 = !{!"cache_eval:%if.else.i205"}
!654 = !{!"cache_eval:%if.then3.i206"}
!655 = !{!"D46", i32 1, i32 1}
!656 = !{!"cache_eval:%if.else4.i208"}
!657 = !{!"cache_eval:%if.then7.i209"}
!658 = !{!"D46", i32 2, i32 2}
!659 = !{!"cache_eval:%if.else8.i211"}
!660 = !{!"cache_eval:%if.then11.i212"}
!661 = !{!"D46", i32 3, i32 3}
!662 = !{!"cache_eval:%if.else12.i214"}
!663 = !{!"cache_eval:%if.then15.i215"}
!664 = !{!"D46", i32 4, i32 4}
!665 = !{!"cache_eval:%if.else16.i217"}
!666 = !{!"cache_eval:%if.then19.i218"}
!667 = !{!"D46", i32 5, i32 5}
!668 = !{!"cache_eval:%if.else20.i220"}
!669 = !{!"cache_eval:%if.then23.i221"}
!670 = !{!"D46", i32 6, i32 6}
!671 = !{!"cache_eval:%if.end29.i222"}
!672 = !{!"D46", i32 7, i32 7}
!673 = !{!"cache_eval:%quant_decide.exit223"}
!674 = !{!"cache_eval:%if.then.i181"}
!675 = !{!"D47", i32 0, i32 0}
!676 = !{!"cache_eval:%if.else.i183"}
!677 = !{!"cache_eval:%if.then3.i184"}
!678 = !{!"D47", i32 1, i32 1}
!679 = !{!"cache_eval:%if.else4.i186"}
!680 = !{!"cache_eval:%if.then7.i187"}
!681 = !{!"D47", i32 2, i32 2}
!682 = !{!"cache_eval:%if.else8.i189"}
!683 = !{!"cache_eval:%if.then11.i190"}
!684 = !{!"D47", i32 3, i32 3}
!685 = !{!"cache_eval:%if.else12.i192"}
!686 = !{!"cache_eval:%if.then15.i193"}
!687 = !{!"D47", i32 4, i32 4}
!688 = !{!"cache_eval:%if.else16.i195"}
!689 = !{!"cache_eval:%if.then19.i196"}
!690 = !{!"D47", i32 5, i32 5}
!691 = !{!"cache_eval:%if.else20.i198"}
!692 = !{!"cache_eval:%if.then23.i199"}
!693 = !{!"D47", i32 6, i32 6}
!694 = !{!"cache_eval:%if.end29.i200"}
!695 = !{!"D47", i32 7, i32 7}
!696 = !{!"cache_eval:%quant_decide.exit201"}
!697 = !{!"cache_eval:%if.then.i159"}
!698 = !{!"D48", i32 0, i32 0}
!699 = !{!"cache_eval:%if.else.i161"}
!700 = !{!"cache_eval:%if.then3.i162"}
!701 = !{!"D48", i32 1, i32 1}
!702 = !{!"cache_eval:%if.else4.i164"}
!703 = !{!"cache_eval:%if.then7.i165"}
!704 = !{!"D48", i32 2, i32 2}
!705 = !{!"cache_eval:%if.else8.i167"}
!706 = !{!"cache_eval:%if.then11.i168"}
!707 = !{!"D48", i32 3, i32 3}
!708 = !{!"cache_eval:%if.else12.i170"}
!709 = !{!"cache_eval:%if.then15.i171"}
!710 = !{!"D48", i32 4, i32 4}
!711 = !{!"cache_eval:%if.else16.i173"}
!712 = !{!"cache_eval:%if.then19.i174"}
!713 = !{!"D48", i32 5, i32 5}
!714 = !{!"cache_eval:%if.else20.i176"}
!715 = !{!"cache_eval:%if.then23.i177"}
!716 = !{!"D48", i32 6, i32 6}
!717 = !{!"cache_eval:%if.end29.i178"}
!718 = !{!"D48", i32 7, i32 7}
!719 = !{!"cache_eval:%quant_decide.exit179"}
!720 = !{!"cache_eval:%if.then.i137"}
!721 = !{!"D49", i32 0, i32 0}
!722 = !{!"cache_eval:%if.else.i139"}
!723 = !{!"cache_eval:%if.then3.i140"}
!724 = !{!"D49", i32 1, i32 1}
!725 = !{!"cache_eval:%if.else4.i142"}
!726 = !{!"cache_eval:%if.then7.i143"}
!727 = !{!"D49", i32 2, i32 2}
!728 = !{!"cache_eval:%if.else8.i145"}
!729 = !{!"cache_eval:%if.then11.i146"}
!730 = !{!"D49", i32 3, i32 3}
!731 = !{!"cache_eval:%if.else12.i148"}
!732 = !{!"cache_eval:%if.then15.i149"}
!733 = !{!"D49", i32 4, i32 4}
!734 = !{!"cache_eval:%if.else16.i151"}
!735 = !{!"cache_eval:%if.then19.i152"}
!736 = !{!"D49", i32 5, i32 5}
!737 = !{!"cache_eval:%if.else20.i154"}
!738 = !{!"cache_eval:%if.then23.i155"}
!739 = !{!"D49", i32 6, i32 6}
!740 = !{!"cache_eval:%if.end29.i156"}
!741 = !{!"D49", i32 7, i32 7}
!742 = !{!"cache_eval:%quant_decide.exit157"}
!743 = !{!"cache_eval:%if.then.i115"}
!744 = !{!"D50", i32 0, i32 0}
!745 = !{!"cache_eval:%if.else.i117"}
!746 = !{!"cache_eval:%if.then3.i118"}
!747 = !{!"D50", i32 1, i32 1}
!748 = !{!"cache_eval:%if.else4.i120"}
!749 = !{!"cache_eval:%if.then7.i121"}
!750 = !{!"D50", i32 2, i32 2}
!751 = !{!"cache_eval:%if.else8.i123"}
!752 = !{!"cache_eval:%if.then11.i124"}
!753 = !{!"D50", i32 3, i32 3}
!754 = !{!"cache_eval:%if.else12.i126"}
!755 = !{!"cache_eval:%if.then15.i127"}
!756 = !{!"D50", i32 4, i32 4}
!757 = !{!"cache_eval:%if.else16.i129"}
!758 = !{!"cache_eval:%if.then19.i130"}
!759 = !{!"D50", i32 5, i32 5}
!760 = !{!"cache_eval:%if.else20.i132"}
!761 = !{!"cache_eval:%if.then23.i133"}
!762 = !{!"D50", i32 6, i32 6}
!763 = !{!"cache_eval:%if.end29.i134"}
!764 = !{!"D50", i32 7, i32 7}
!765 = !{!"cache_eval:%quant_decide.exit135"}
!766 = !{!"cache_eval:%if.then.i93"}
!767 = !{!"D51", i32 0, i32 0}
!768 = !{!"cache_eval:%if.else.i95"}
!769 = !{!"cache_eval:%if.then3.i96"}
!770 = !{!"D51", i32 1, i32 1}
!771 = !{!"cache_eval:%if.else4.i98"}
!772 = !{!"cache_eval:%if.then7.i99"}
!773 = !{!"D51", i32 2, i32 2}
!774 = !{!"cache_eval:%if.else8.i101"}
!775 = !{!"cache_eval:%if.then11.i102"}
!776 = !{!"D51", i32 3, i32 3}
!777 = !{!"cache_eval:%if.else12.i104"}
!778 = !{!"cache_eval:%if.then15.i105"}
!779 = !{!"D51", i32 4, i32 4}
!780 = !{!"cache_eval:%if.else16.i107"}
!781 = !{!"cache_eval:%if.then19.i108"}
!782 = !{!"D51", i32 5, i32 5}
!783 = !{!"cache_eval:%if.else20.i110"}
!784 = !{!"cache_eval:%if.then23.i111"}
!785 = !{!"D51", i32 6, i32 6}
!786 = !{!"cache_eval:%if.end29.i112"}
!787 = !{!"D51", i32 7, i32 7}
!788 = !{!"cache_eval:%quant_decide.exit113"}
!789 = !{!"cache_eval:%if.then.i71"}
!790 = !{!"D52", i32 0, i32 0}
!791 = !{!"cache_eval:%if.else.i73"}
!792 = !{!"cache_eval:%if.then3.i74"}
!793 = !{!"D52", i32 1, i32 1}
!794 = !{!"cache_eval:%if.else4.i76"}
!795 = !{!"cache_eval:%if.then7.i77"}
!796 = !{!"D52", i32 2, i32 2}
!797 = !{!"cache_eval:%if.else8.i79"}
!798 = !{!"cache_eval:%if.then11.i80"}
!799 = !{!"D52", i32 3, i32 3}
!800 = !{!"cache_eval:%if.else12.i82"}
!801 = !{!"cache_eval:%if.then15.i83"}
!802 = !{!"D52", i32 4, i32 4}
!803 = !{!"cache_eval:%if.else16.i85"}
!804 = !{!"cache_eval:%if.then19.i86"}
!805 = !{!"D52", i32 5, i32 5}
!806 = !{!"cache_eval:%if.else20.i88"}
!807 = !{!"cache_eval:%if.then23.i89"}
!808 = !{!"D52", i32 6, i32 6}
!809 = !{!"cache_eval:%if.end29.i90"}
!810 = !{!"D52", i32 7, i32 7}
!811 = !{!"cache_eval:%quant_decide.exit91"}
!812 = !{!"cache_eval:%if.then.i49"}
!813 = !{!"D53", i32 0, i32 0}
!814 = !{!"cache_eval:%if.else.i51"}
!815 = !{!"cache_eval:%if.then3.i52"}
!816 = !{!"D53", i32 1, i32 1}
!817 = !{!"cache_eval:%if.else4.i54"}
!818 = !{!"cache_eval:%if.then7.i55"}
!819 = !{!"D53", i32 2, i32 2}
!820 = !{!"cache_eval:%if.else8.i57"}
!821 = !{!"cache_eval:%if.then11.i58"}
!822 = !{!"D53", i32 3, i32 3}
!823 = !{!"cache_eval:%if.else12.i60"}
!824 = !{!"cache_eval:%if.then15.i61"}
!825 = !{!"D53", i32 4, i32 4}
!826 = !{!"cache_eval:%if.else16.i63"}
!827 = !{!"cache_eval:%if.then19.i64"}
!828 = !{!"D53", i32 5, i32 5}
!829 = !{!"cache_eval:%if.else20.i66"}
!830 = !{!"cache_eval:%if.then23.i67"}
!831 = !{!"D53", i32 6, i32 6}
!832 = !{!"cache_eval:%if.end29.i68"}
!833 = !{!"D53", i32 7, i32 7}
!834 = !{!"cache_eval:%quant_decide.exit69"}
!835 = !{!"cache_eval:%if.then97.7.1"}
!836 = !{!"cache_eval:%for.inc138.7.1"}
!837 = !{!"cache_eval:%cond.false.i353.1"}
!838 = !{!"cache_eval:%cond.false3.i355.1"}
!839 = !{!"cache_eval:%cond.false6.i357.1"}
!840 = !{!"cache_eval:%cond.false9.i359.1"}
!841 = !{!"cache_eval:%cond.false12.i361.1"}
!842 = !{!"cache_eval:%cond.false15.i364.1"}
!843 = !{!"cache_eval:%_Z5pack4f.exit369.1"}
!844 = !{!"cache_eval:%cond.false.i.1"}
!845 = !{!"cache_eval:%cond.false3.i.1"}
!846 = !{!"cache_eval:%cond.false6.i.1"}
!847 = !{!"cache_eval:%cond.false9.i.1"}
!848 = !{!"cache_eval:%cond.false12.i.1"}
!849 = !{!"cache_eval:%cond.false15.i.1"}
!850 = !{!"cache_eval:%_Z5pack4f.exit.1"}
!851 = !{!"cache_eval:%cond.false.i353.2"}
!852 = !{!"cache_eval:%cond.false3.i355.2"}
!853 = !{!"cache_eval:%cond.false6.i357.2"}
!854 = !{!"cache_eval:%cond.false9.i359.2"}
!855 = !{!"cache_eval:%cond.false12.i361.2"}
!856 = !{!"cache_eval:%cond.false15.i364.2"}
!857 = !{!"cache_eval:%_Z5pack4f.exit369.2"}
!858 = !{!"cache_eval:%cond.false.i.2"}
!859 = !{!"cache_eval:%cond.false3.i.2"}
!860 = !{!"cache_eval:%cond.false6.i.2"}
!861 = !{!"cache_eval:%cond.false9.i.2"}
!862 = !{!"cache_eval:%cond.false12.i.2"}
!863 = !{!"cache_eval:%cond.false15.i.2"}
!864 = !{!"cache_eval:%_Z5pack4f.exit.2"}
!865 = !{!"cache_eval:%cond.false.i353.3"}
!866 = !{!"cache_eval:%cond.false3.i355.3"}
!867 = !{!"cache_eval:%cond.false6.i357.3"}
!868 = !{!"cache_eval:%cond.false9.i359.3"}
!869 = !{!"cache_eval:%cond.false12.i361.3"}
!870 = !{!"cache_eval:%cond.false15.i364.3"}
!871 = !{!"cache_eval:%_Z5pack4f.exit369.3"}
!872 = !{!"cache_eval:%cond.false.i.3"}
!873 = !{!"cache_eval:%cond.false3.i.3"}
!874 = !{!"cache_eval:%cond.false6.i.3"}
!875 = !{!"cache_eval:%cond.false9.i.3"}
!876 = !{!"cache_eval:%cond.false12.i.3"}
!877 = !{!"cache_eval:%cond.false15.i.3"}
!878 = !{!"cache_eval:%_Z5pack4f.exit.3"}
!879 = !{!"cache_eval:%cond.false.i353.4"}
!880 = !{!"cache_eval:%cond.false3.i355.4"}
!881 = !{!"cache_eval:%cond.false6.i357.4"}
!882 = !{!"cache_eval:%cond.false9.i359.4"}
!883 = !{!"cache_eval:%cond.false12.i361.4"}
!884 = !{!"cache_eval:%cond.false15.i364.4"}
!885 = !{!"cache_eval:%_Z5pack4f.exit369.4"}
!886 = !{!"cache_eval:%cond.false.i.4"}
!887 = !{!"cache_eval:%cond.false3.i.4"}
!888 = !{!"cache_eval:%cond.false6.i.4"}
!889 = !{!"cache_eval:%cond.false9.i.4"}
!890 = !{!"cache_eval:%cond.false12.i.4"}
!891 = !{!"cache_eval:%cond.false15.i.4"}
!892 = !{!"cache_eval:%_Z5pack4f.exit.4"}
!893 = !{!"cache_eval:%cond.false.i353.5"}
!894 = !{!"cache_eval:%cond.false3.i355.5"}
!895 = !{!"cache_eval:%cond.false6.i357.5"}
!896 = !{!"cache_eval:%cond.false9.i359.5"}
!897 = !{!"cache_eval:%cond.false12.i361.5"}
!898 = !{!"cache_eval:%cond.false15.i364.5"}
!899 = !{!"cache_eval:%_Z5pack4f.exit369.5"}
!900 = !{!"cache_eval:%cond.false.i.5"}
!901 = !{!"cache_eval:%cond.false3.i.5"}
!902 = !{!"cache_eval:%cond.false6.i.5"}
!903 = !{!"cache_eval:%cond.false9.i.5"}
!904 = !{!"cache_eval:%cond.false12.i.5"}
!905 = !{!"cache_eval:%cond.false15.i.5"}
!906 = !{!"cache_eval:%_Z5pack4f.exit.5"}
!907 = !{!"cache_eval:%cond.false.i353.6"}
!908 = !{!"cache_eval:%cond.false3.i355.6"}
!909 = !{!"cache_eval:%cond.false6.i357.6"}
!910 = !{!"cache_eval:%cond.false9.i359.6"}
!911 = !{!"cache_eval:%cond.false12.i361.6"}
!912 = !{!"cache_eval:%cond.false15.i364.6"}
!913 = !{!"cache_eval:%_Z5pack4f.exit369.6"}
!914 = !{!"cache_eval:%cond.false.i.6"}
!915 = !{!"cache_eval:%cond.false3.i.6"}
!916 = !{!"cache_eval:%cond.false6.i.6"}
!917 = !{!"cache_eval:%cond.false9.i.6"}
!918 = !{!"cache_eval:%cond.false12.i.6"}
!919 = !{!"cache_eval:%cond.false15.i.6"}
!920 = !{!"cache_eval:%_Z5pack4f.exit.6"}
!921 = !{!"cache_eval:%cond.false.i353.7"}
!922 = !{!"cache_eval:%cond.false3.i355.7"}
!923 = !{!"cache_eval:%cond.false6.i357.7"}
!924 = !{!"cache_eval:%cond.false9.i359.7"}
!925 = !{!"cache_eval:%cond.false12.i361.7"}
!926 = !{!"cache_eval:%cond.false15.i364.7"}
!927 = !{!"cache_eval:%_Z5pack4f.exit369.7"}
!928 = !{!"cache_eval:%cond.false.i.7"}
!929 = !{!"cache_eval:%cond.false3.i.7"}
!930 = !{!"cache_eval:%cond.false6.i.7"}
!931 = !{!"cache_eval:%cond.false9.i.7"}
!932 = !{!"cache_eval:%cond.false12.i.7"}
!933 = !{!"cache_eval:%cond.false15.i.7"}
!934 = !{!"cache_eval:%_Z5pack4f.exit.7"}
