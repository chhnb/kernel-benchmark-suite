; ModuleID = '/home/chh/region-fusion-lab/work/tigre-fusion-bounds-20261104/device.hip'
source_filename = "/home/chh/region-fusion-lab/work/tigre-fusion-bounds-20261104/device.hip"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

%struct.Point3D = type { float, float, float }
%struct.Geometry.coerce = type { i32, i32, i32, float, float, float, float, float, float, float addrspace(1)*, float addrspace(1)*, float addrspace(1)*, float addrspace(1)*, i32, i32, float, float, float, float, float addrspace(1)*, float addrspace(1)*, float addrspace(1)*, float addrspace(1)*, float addrspace(1)*, float addrspace(1)*, float, float, float, float, float, float, float addrspace(1)*, float, float }
%struct.__hip_texture = type opaque

@projParamsArrayDev = protected local_unnamed_addr addrspace(4) externally_initialized global [36 x %struct.Point3D] zeroinitializer, align 16

; Function Attrs: convergent norecurse nounwind
define protected amdgpu_kernel void @_Z19kernelPixelDetector8GeometryPfiiP13__hip_texture(%struct.Geometry.coerce %geo.coerce, float addrspace(1)* nocapture %detector.coerce, i32 %currProjSetNumber, i32 %totalNoOfProjections, %struct.__hip_texture addrspace(1)* nocapture readonly %tex.coerce) local_unnamed_addr #0 {
entry:
  %0 = extractvalue %struct.Geometry.coerce %geo.coerce, 0
  %1 = extractvalue %struct.Geometry.coerce %geo.coerce, 1
  %2 = extractvalue %struct.Geometry.coerce %geo.coerce, 2
  %3 = extractvalue %struct.Geometry.coerce %geo.coerce, 6
  %4 = extractvalue %struct.Geometry.coerce %geo.coerce, 7
  %5 = extractvalue %struct.Geometry.coerce %geo.coerce, 8
  %6 = extractvalue %struct.Geometry.coerce %geo.coerce, 13
  %7 = tail call i32 @llvm.amdgcn.workgroup.id.x() #3
  %8 = tail call align 4 dereferenceable(64) i8 addrspace(4)* @llvm.amdgcn.dispatch.ptr() #3
  %9 = getelementptr i8, i8 addrspace(4)* %8, i64 4
  %10 = bitcast i8 addrspace(4)* %9 to i16 addrspace(4)*
  %11 = load i16, i16 addrspace(4)* %10, align 4, !range !5, !invariant.load !6
  %12 = zext i16 %11 to i32
  %13 = mul i32 %7, %12
  %14 = tail call i32 @llvm.amdgcn.workitem.id.x() #3, !range !7
  %add = add i32 %13, %14
  %conv = zext i32 %add to i64
  %15 = tail call i32 @llvm.amdgcn.workgroup.id.y() #3
  %16 = getelementptr i8, i8 addrspace(4)* %8, i64 6
  %17 = bitcast i8 addrspace(4)* %16 to i16 addrspace(4)*
  %18 = load i16, i16 addrspace(4)* %17, align 2, !range !5, !invariant.load !6
  %19 = zext i16 %18 to i32
  %20 = mul i32 %15, %19
  %21 = tail call i32 @llvm.amdgcn.workitem.id.y() #3, !range !7
  %add10 = add i32 %20, %21
  %conv11 = zext i32 %add10 to i64
  %22 = tail call i32 @llvm.amdgcn.workitem.id.z() #3, !range !7
  %conv13 = zext i32 %22 to i64
  %conv14 = sext i32 %6 to i64
  %cmp.not = icmp ult i64 %conv, %conv14
  br i1 %cmp.not, label %lor.lhs.false, label %cleanup550

lor.lhs.false:                                    ; preds = %entry
  %23 = extractvalue %struct.Geometry.coerce %geo.coerce, 14
  %conv15 = sext i32 %23 to i64
  %cmp16 = icmp ule i64 %conv15, %conv11
  %cmp18 = icmp ugt i32 %22, 8
  %or.cond = or i1 %cmp18, %cmp16
  br i1 %or.cond, label %cleanup550, label %if.end

if.end:                                           ; preds = %lor.lhs.false
  %mul28 = mul nsw i64 %conv15, %conv13
  %reass.add = add nsw i64 %mul28, %conv11
  %reass.mul = mul i64 %reass.add, %conv14
  %add29 = add i64 %reass.mul, %conv
  %mul30 = mul nsw i32 %currProjSetNumber, 9
  %conv31 = sext i32 %mul30 to i64
  %add32 = add nsw i64 %conv31, %conv13
  %conv33 = sext i32 %totalNoOfProjections to i64
  %cmp34.not = icmp ult i64 %add32, %conv33
  br i1 %cmp34.not, label %if.end36, label %cleanup550

if.end36:                                         ; preds = %if.end
  %mul37 = shl nuw nsw i64 %conv13, 2
  %uvOrigin.sroa.0.0..sroa_idx = getelementptr inbounds [36 x %struct.Point3D], [36 x %struct.Point3D] addrspace(4)* @projParamsArrayDev, i64 0, i64 %mul37, i32 0
  %uvOrigin.sroa.0.0.copyload = load float, float addrspace(4)* %uvOrigin.sroa.0.0..sroa_idx, align 16, !tbaa.struct !8
  %uvOrigin.sroa.4.0..sroa_idx805 = getelementptr inbounds [36 x %struct.Point3D], [36 x %struct.Point3D] addrspace(4)* @projParamsArrayDev, i64 0, i64 %mul37, i32 1
  %uvOrigin.sroa.4.0.copyload = load float, float addrspace(4)* %uvOrigin.sroa.4.0..sroa_idx805, align 4, !tbaa.struct !8
  %uvOrigin.sroa.5.0..sroa_idx807 = getelementptr inbounds [36 x %struct.Point3D], [36 x %struct.Point3D] addrspace(4)* @projParamsArrayDev, i64 0, i64 %mul37, i32 2
  %uvOrigin.sroa.5.0.copyload = load float, float addrspace(4)* %uvOrigin.sroa.5.0..sroa_idx807, align 8, !tbaa.struct !8
  %add39 = or i64 %mul37, 1
  %deltaU.sroa.0.0..sroa_idx = getelementptr inbounds [36 x %struct.Point3D], [36 x %struct.Point3D] addrspace(4)* @projParamsArrayDev, i64 0, i64 %add39, i32 0
  %deltaU.sroa.0.0.copyload = load float, float addrspace(4)* %deltaU.sroa.0.0..sroa_idx, align 4, !tbaa.struct !8
  %deltaU.sroa.4.0..sroa_idx800 = getelementptr inbounds [36 x %struct.Point3D], [36 x %struct.Point3D] addrspace(4)* @projParamsArrayDev, i64 0, i64 %add39, i32 1
  %deltaU.sroa.4.0.copyload = load float, float addrspace(4)* %deltaU.sroa.4.0..sroa_idx800, align 4, !tbaa.struct !8
  %deltaU.sroa.5.0..sroa_idx802 = getelementptr inbounds [36 x %struct.Point3D], [36 x %struct.Point3D] addrspace(4)* @projParamsArrayDev, i64 0, i64 %add39, i32 2
  %deltaU.sroa.5.0.copyload = load float, float addrspace(4)* %deltaU.sroa.5.0..sroa_idx802, align 4, !tbaa.struct !8
  %add42 = or i64 %mul37, 2
  %deltaV.sroa.0.0..sroa_idx = getelementptr inbounds [36 x %struct.Point3D], [36 x %struct.Point3D] addrspace(4)* @projParamsArrayDev, i64 0, i64 %add42, i32 0
  %deltaV.sroa.0.0.copyload = load float, float addrspace(4)* %deltaV.sroa.0.0..sroa_idx, align 8, !tbaa.struct !8
  %deltaV.sroa.4.0..sroa_idx795 = getelementptr inbounds [36 x %struct.Point3D], [36 x %struct.Point3D] addrspace(4)* @projParamsArrayDev, i64 0, i64 %add42, i32 1
  %deltaV.sroa.4.0.copyload = load float, float addrspace(4)* %deltaV.sroa.4.0..sroa_idx795, align 4, !tbaa.struct !8
  %deltaV.sroa.5.0..sroa_idx797 = getelementptr inbounds [36 x %struct.Point3D], [36 x %struct.Point3D] addrspace(4)* @projParamsArrayDev, i64 0, i64 %add42, i32 2
  %deltaV.sroa.5.0.copyload = load float, float addrspace(4)* %deltaV.sroa.5.0..sroa_idx797, align 8, !tbaa.struct !8
  %add45 = or i64 %mul37, 3
  %source.sroa.0.0..sroa_idx = getelementptr inbounds [36 x %struct.Point3D], [36 x %struct.Point3D] addrspace(4)* @projParamsArrayDev, i64 0, i64 %add45, i32 0
  %source.sroa.0.0.copyload = load float, float addrspace(4)* %source.sroa.0.0..sroa_idx, align 4, !tbaa.struct !8
  %source.sroa.18.0..sroa_idx762 = getelementptr inbounds [36 x %struct.Point3D], [36 x %struct.Point3D] addrspace(4)* @projParamsArrayDev, i64 0, i64 %add45, i32 1
  %source.sroa.18.0.copyload = load float, float addrspace(4)* %source.sroa.18.0..sroa_idx762, align 4, !tbaa.struct !8
  %source.sroa.33.0..sroa_idx778 = getelementptr inbounds [36 x %struct.Point3D], [36 x %struct.Point3D] addrspace(4)* @projParamsArrayDev, i64 0, i64 %add45, i32 2
  %source.sroa.33.0.copyload = load float, float addrspace(4)* %source.sroa.33.0..sroa_idx778, align 4, !tbaa.struct !8
  %24 = xor i64 %conv11, -1
  %sub49 = add nsw i64 %24, %conv15
  %conv50 = uitofp i32 %add to float
  %mul52 = fmul float %deltaU.sroa.0.0.copyload, %conv50
  %add53 = fadd float %uvOrigin.sroa.0.0.copyload, %mul52
  %conv54 = uitofp i64 %sub49 to float
  %mul56 = fmul float %deltaV.sroa.0.0.copyload, %conv54
  %add57 = fadd float %add53, %mul56
  %mul61 = fmul float %deltaU.sroa.4.0.copyload, %conv50
  %add62 = fadd float %uvOrigin.sroa.4.0.copyload, %mul61
  %mul65 = fmul float %deltaV.sroa.4.0.copyload, %conv54
  %add66 = fadd float %add62, %mul65
  %mul70 = fmul float %deltaU.sroa.5.0.copyload, %conv50
  %add71 = fadd float %uvOrigin.sroa.5.0.copyload, %mul70
  %mul74 = fmul float %deltaV.sroa.5.0.copyload, %conv54
  %add75 = fadd float %add71, %mul74
  %sub79 = fsub float %add57, %source.sroa.0.0.copyload
  %sub83 = fsub float %add66, %source.sroa.18.0.copyload
  %sub87 = fsub float %add75, %source.sroa.33.0.copyload
  %25 = tail call float @llvm.fabs.f32(float %sub79) #3
  %cmp91 = fcmp olt float %25, 0x3F50624DE0000000
  %cond = select i1 %cmp91, float 0.000000e+00, float %sub79
  %26 = tail call float @llvm.fabs.f32(float %sub83) #3
  %cmp96 = fcmp olt float %26, 0x3F50624DE0000000
  %cond101 = select i1 %cmp96, float 0.000000e+00, float %sub83
  %27 = tail call float @llvm.fabs.f32(float %sub87) #3
  %cmp105 = fcmp olt float %27, 0x3F50624DE0000000
  %cond110 = select i1 %cmp105, float 0.000000e+00, float %sub87
  %fneg = fneg float %source.sroa.0.0.copyload
  %div.i904 = fdiv float %fneg, %cond
  %conv115 = sitofp i32 %0 to float
  %sub117 = fsub float %conv115, %source.sroa.0.0.copyload
  %div.i903 = fdiv float %sub117, %cond
  %28 = tail call float @llvm.minnum.f32(float %div.i904, float %div.i903) #3
  %fneg122 = fneg float %source.sroa.18.0.copyload
  %div.i902 = fdiv float %fneg122, %cond101
  %conv125 = sitofp i32 %1 to float
  %sub127 = fsub float %conv125, %source.sroa.18.0.copyload
  %div.i901 = fdiv float %sub127, %cond101
  %29 = tail call float @llvm.minnum.f32(float %div.i902, float %div.i901) #3
  %fneg132 = fneg float %source.sroa.33.0.copyload
  %div.i900 = fdiv float %fneg132, %cond110
  %conv135 = sitofp i32 %2 to float
  %sub137 = fsub float %conv135, %source.sroa.33.0.copyload
  %div.i899 = fdiv float %sub137, %cond110
  %30 = tail call float @llvm.minnum.f32(float %div.i900, float %div.i899) #3
  %31 = tail call float @llvm.maxnum.f32(float %div.i904, float %div.i903) #3
  %32 = tail call float @llvm.maxnum.f32(float %div.i902, float %div.i901) #3
  %33 = tail call float @llvm.maxnum.f32(float %div.i900, float %div.i899) #3
  %34 = tail call float @llvm.maxnum.f32(float %28, float %29) #3
  %35 = tail call float @llvm.maxnum.f32(float %34, float %30) #3
  %36 = tail call float @llvm.minnum.f32(float %31, float %32) #3
  %37 = tail call float @llvm.minnum.f32(float %36, float %33) #3
  %cmp178 = fcmp ult float %35, %37
  br i1 %cmp178, label %if.end181, label %if.then179

if.then179:                                       ; preds = %if.end36
  %arrayidx180849 = getelementptr inbounds float, float addrspace(1)* %detector.coerce, i64 %add29
  store float 0.000000e+00, float addrspace(1)* %arrayidx180849, align 4, !tbaa !9
  br label %cleanup550

if.end181:                                        ; preds = %if.end36
  %cmp184 = fcmp olt float %source.sroa.0.0.copyload, %add57
  %cmp186 = fcmp oeq float %35, %28
  br i1 %cmp184, label %if.then185, label %if.else

if.then185:                                       ; preds = %if.end181
  %mul191 = fmul float %cond, %35
  %add192 = fadd float %source.sroa.0.0.copyload, %mul191
  %38 = tail call float @llvm.ceil.f32(float %add192) #3
  %cond195 = select i1 %cmp186, float 1.000000e+00, float %38
  %cmp196 = fcmp oeq float %37, %31
  %mul203 = fmul float %cond, %37
  %add204 = fadd float %source.sroa.0.0.copyload, %mul203
  %39 = tail call float @llvm.floor.f32(float %add204) #3
  br i1 %cmp196, label %if.end231, label %cond.false200

cond.false200:                                    ; preds = %if.then185
  br label %if.end231

if.else:                                          ; preds = %if.end181
  %sub212 = fadd float %conv115, -1.000000e+00
  %mul216 = fmul float %cond, %35
  %add217 = fadd float %source.sroa.0.0.copyload, %mul216
  %40 = tail call float @llvm.floor.f32(float %add217) #3
  %cond220 = select i1 %cmp186, float %sub212, float %40
  %cmp221 = fcmp oeq float %37, %31
  %mul226 = fmul float %cond, %37
  %add227 = fadd float %source.sroa.0.0.copyload, %mul226
  %41 = tail call float @llvm.ceil.f32(float %add227) #3
  br i1 %cmp221, label %if.end231, label %cond.false223

cond.false223:                                    ; preds = %if.else
  br label %if.end231

if.end231:                                        ; preds = %cond.false223, %if.else, %cond.false200, %if.then185
  %imin.0.pn = phi float [ %cond220, %cond.false223 ], [ %cond220, %if.else ], [ %cond195, %cond.false200 ], [ %cond195, %if.then185 ]
  %imax.0 = phi float [ %cond220, %cond.false223 ], [ %cond220, %if.else ], [ %39, %cond.false200 ], [ %conv115, %if.then185 ]
  %imin.0 = phi float [ %41, %cond.false223 ], [ 0.000000e+00, %if.else ], [ %cond195, %cond.false200 ], [ %cond195, %if.then185 ]
  %cmp234 = fcmp olt float %source.sroa.18.0.copyload, %add66
  %cmp236 = fcmp oeq float %35, %29
  br i1 %cmp234, label %if.then235, label %if.else258

if.then235:                                       ; preds = %if.end231
  %mul241 = fmul float %cond101, %35
  %add242 = fadd float %source.sroa.18.0.copyload, %mul241
  %42 = tail call float @llvm.ceil.f32(float %add242) #3
  %cond245 = select i1 %cmp236, float 1.000000e+00, float %42
  %cmp246 = fcmp oeq float %37, %32
  %mul253 = fmul float %cond101, %37
  %add254 = fadd float %source.sroa.18.0.copyload, %mul253
  %43 = tail call float @llvm.floor.f32(float %add254) #3
  br i1 %cmp246, label %if.end282, label %cond.false250

cond.false250:                                    ; preds = %if.then235
  br label %if.end282

if.else258:                                       ; preds = %if.end231
  %sub263 = fadd float %conv125, -1.000000e+00
  %mul267 = fmul float %cond101, %35
  %add268 = fadd float %source.sroa.18.0.copyload, %mul267
  %44 = tail call float @llvm.floor.f32(float %add268) #3
  %cond271 = select i1 %cmp236, float %sub263, float %44
  %cmp272 = fcmp oeq float %37, %32
  %mul277 = fmul float %cond101, %37
  %add278 = fadd float %source.sroa.18.0.copyload, %mul277
  %45 = tail call float @llvm.ceil.f32(float %add278) #3
  br i1 %cmp272, label %if.end282, label %cond.false274

cond.false274:                                    ; preds = %if.else258
  br label %if.end282

if.end282:                                        ; preds = %cond.false274, %if.else258, %cond.false250, %if.then235
  %jmin.0.pn = phi float [ %cond271, %cond.false274 ], [ %cond271, %if.else258 ], [ %cond245, %cond.false250 ], [ %cond245, %if.then235 ]
  %jmax.0 = phi float [ %cond271, %cond.false274 ], [ %cond271, %if.else258 ], [ %43, %cond.false250 ], [ %conv125, %if.then235 ]
  %jmin.0 = phi float [ %45, %cond.false274 ], [ 0.000000e+00, %if.else258 ], [ %cond245, %cond.false250 ], [ %cond245, %if.then235 ]
  %cmp285 = fcmp olt float %source.sroa.33.0.copyload, %add75
  %cmp287 = fcmp oeq float %35, %30
  br i1 %cmp285, label %if.then286, label %if.else309

if.then286:                                       ; preds = %if.end282
  %mul292 = fmul float %cond110, %35
  %add293 = fadd float %source.sroa.33.0.copyload, %mul292
  %46 = tail call float @llvm.ceil.f32(float %add293) #3
  %cond296 = select i1 %cmp287, float 1.000000e+00, float %46
  %cmp297 = fcmp oeq float %37, %33
  %mul304 = fmul float %cond110, %37
  %add305 = fadd float %source.sroa.33.0.copyload, %mul304
  %47 = tail call float @llvm.floor.f32(float %add305) #3
  br i1 %cmp297, label %if.end333, label %cond.false301

cond.false301:                                    ; preds = %if.then286
  br label %if.end333

if.else309:                                       ; preds = %if.end282
  %sub314 = fadd float %conv135, -1.000000e+00
  %mul318 = fmul float %cond110, %35
  %add319 = fadd float %source.sroa.33.0.copyload, %mul318
  %48 = tail call float @llvm.floor.f32(float %add319) #3
  %cond322 = select i1 %cmp287, float %sub314, float %48
  %cmp323 = fcmp oeq float %37, %33
  %mul328 = fmul float %cond110, %37
  %add329 = fadd float %source.sroa.33.0.copyload, %mul328
  %49 = tail call float @llvm.ceil.f32(float %add329) #3
  br i1 %cmp323, label %if.end333, label %cond.false325

cond.false325:                                    ; preds = %if.else309
  br label %if.end333

if.end333:                                        ; preds = %cond.false325, %if.else309, %cond.false301, %if.then286
  %kmin.0.pn = phi float [ %cond322, %cond.false325 ], [ %cond322, %if.else309 ], [ %cond296, %cond.false301 ], [ %cond296, %if.then286 ]
  %kmin.0 = phi float [ %49, %cond.false325 ], [ 0.000000e+00, %if.else309 ], [ %cond296, %cond.false301 ], [ %cond296, %if.then286 ]
  %kmax.0 = phi float [ %cond322, %cond.false325 ], [ %cond322, %if.else309 ], [ %47, %cond.false301 ], [ %conv135, %if.then286 ]
  %sub339.pn = fsub float %imin.0.pn, %source.sroa.0.0.copyload
  %cond348 = fdiv float %sub339.pn, %cond
  %sub354.pn = fsub float %jmin.0.pn, %source.sroa.18.0.copyload
  %cond363 = fdiv float %sub354.pn, %cond101
  %sub369.pn = fsub float %kmin.0.pn, %source.sroa.33.0.copyload
  %cond378 = fdiv float %sub369.pn, %cond110
  %50 = tail call float @llvm.fabs.f32(float %cond348) #4
  %51 = fcmp oeq float %50, 0x7FF0000000000000
  %cond384 = select i1 %51, float %50, float %cond348
  %52 = tail call float @llvm.fabs.f32(float %cond363) #4
  %53 = fcmp oeq float %52, 0x7FF0000000000000
  %cond390 = select i1 %53, float %52, float %cond363
  %54 = tail call float @llvm.fabs.f32(float %cond378) #4
  %55 = fcmp oeq float %54, 0x7FF0000000000000
  %cond396 = select i1 %55, float %54, float %cond378
  %56 = tail call float @llvm.minnum.f32(float %cond384, float %cond390) #3
  %57 = tail call float @llvm.minnum.f32(float %56, float %cond396) #3
  %add400 = fadd float %35, %57
  %mul401 = fmul float %add400, 5.000000e-01
  %mul403 = fmul float %cond, %mul401
  %add404 = fadd float %source.sroa.0.0.copyload, %mul403
  %58 = tail call float @llvm.floor.f32(float %add404) #3
  %conv406 = fptoui float %58 to i64
  %mul411 = fmul float %cond101, %mul401
  %add412 = fadd float %source.sroa.18.0.copyload, %mul411
  %59 = tail call float @llvm.floor.f32(float %add412) #3
  %conv414 = fptoui float %59 to i64
  %mul419 = fmul float %cond110, %mul401
  %add420 = fadd float %source.sroa.33.0.copyload, %mul419
  %60 = tail call float @llvm.floor.f32(float %add420) #3
  %conv422 = fptoui float %60 to i64
  %61 = tail call float @llvm.fabs.f32(float %cond) #3
  %cmp.i877 = fcmp oeq float %cond, 0.000000e+00
  br i1 %cmp.i877, label %_Z12tigre_rcp_rdf.exit887, label %if.end.i879

if.end.i879:                                      ; preds = %if.end333
  %conv1.i878 = fdiv float 1.000000e+00, %61
  %62 = fcmp oeq float %conv1.i878, 0x7FF0000000000000
  br i1 %62, label %_Z12tigre_rcp_rdf.exit887, label %if.end3.i884

if.end3.i884:                                     ; preds = %if.end.i879
  %conv.i880 = fpext float %61 to double
  %conv4.i881 = fpext float %conv1.i878 to double
  %mul.i882 = fmul double %conv.i880, %conv4.i881
  %cmp6.i883 = fcmp ogt double %mul.i882, 1.000000e+00
  br i1 %cmp6.i883, label %if.then7.i885, label %_Z12tigre_rcp_rdf.exit887

if.then7.i885:                                    ; preds = %if.end3.i884
  %63 = insertelement <2 x float> <float undef, float 0.000000e+00>, float %conv1.i878, i32 0
  %64 = bitcast <2 x float> %63 to <2 x i32>
  %65 = sub nsw <2 x i32> <i32 -2147483648, i32 -2147483648>, %64
  %66 = icmp slt <2 x i32> %64, zeroinitializer
  %67 = select <2 x i1> %66, <2 x i32> %65, <2 x i32> %64
  %68 = extractelement <2 x i32> %67, i32 0
  %69 = extractelement <2 x i32> %67, i32 1
  %70 = icmp slt i32 %68, %69
  %71 = select i1 %70, i32 1, i32 -1
  %72 = add nsw i32 %71, %68
  %73 = sub nsw i32 -2147483648, %72
  %74 = icmp slt i32 %72, 0
  %75 = select i1 %74, i32 %73, i32 %72
  %76 = fcmp uno float %conv1.i878, 0.000000e+00
  %77 = bitcast float %conv1.i878 to i32
  %78 = select i1 %76, i32 %77, i32 %75
  %79 = insertelement <2 x float> <float 0.000000e+00, float undef>, float %conv1.i878, i32 1
  %80 = tail call <2 x float> @llvm.fabs.v2f32(<2 x float> %79) #3
  %81 = bitcast <2 x float> %80 to <2 x i32>
  %82 = extractelement <2 x i32> %81, i32 0
  %83 = extractelement <2 x i32> %81, i32 1
  %84 = or i32 %82, %83
  %85 = icmp eq i32 %84, 0
  %86 = icmp eq i32 %77, 0
  %87 = or i1 %86, %85
  %88 = bitcast i32 %78 to float
  %89 = select i1 %87, float 0.000000e+00, float %88
  br label %_Z12tigre_rcp_rdf.exit887

_Z12tigre_rcp_rdf.exit887:                        ; preds = %if.end333, %if.end.i879, %if.end3.i884, %if.then7.i885
  %retval.1.i886 = phi float [ 0x7FF0000000000000, %if.end333 ], [ 0x47EFFFFFE0000000, %if.end.i879 ], [ %89, %if.then7.i885 ], [ %conv1.i878, %if.end3.i884 ]
  %90 = tail call float @llvm.fabs.f32(float %cond101) #3
  %cmp.i866 = fcmp oeq float %cond101, 0.000000e+00
  br i1 %cmp.i866, label %_Z12tigre_rcp_rdf.exit876, label %if.end.i868

if.end.i868:                                      ; preds = %_Z12tigre_rcp_rdf.exit887
  %conv1.i867 = fdiv float 1.000000e+00, %90
  %91 = fcmp oeq float %conv1.i867, 0x7FF0000000000000
  br i1 %91, label %_Z12tigre_rcp_rdf.exit876, label %if.end3.i873

if.end3.i873:                                     ; preds = %if.end.i868
  %conv.i869 = fpext float %90 to double
  %conv4.i870 = fpext float %conv1.i867 to double
  %mul.i871 = fmul double %conv.i869, %conv4.i870
  %cmp6.i872 = fcmp ogt double %mul.i871, 1.000000e+00
  br i1 %cmp6.i872, label %if.then7.i874, label %_Z12tigre_rcp_rdf.exit876

if.then7.i874:                                    ; preds = %if.end3.i873
  %92 = insertelement <2 x float> <float undef, float 0.000000e+00>, float %conv1.i867, i32 0
  %93 = bitcast <2 x float> %92 to <2 x i32>
  %94 = sub nsw <2 x i32> <i32 -2147483648, i32 -2147483648>, %93
  %95 = icmp slt <2 x i32> %93, zeroinitializer
  %96 = select <2 x i1> %95, <2 x i32> %94, <2 x i32> %93
  %97 = extractelement <2 x i32> %96, i32 0
  %98 = extractelement <2 x i32> %96, i32 1
  %99 = icmp slt i32 %97, %98
  %100 = select i1 %99, i32 1, i32 -1
  %101 = add nsw i32 %100, %97
  %102 = sub nsw i32 -2147483648, %101
  %103 = icmp slt i32 %101, 0
  %104 = select i1 %103, i32 %102, i32 %101
  %105 = fcmp uno float %conv1.i867, 0.000000e+00
  %106 = bitcast float %conv1.i867 to i32
  %107 = select i1 %105, i32 %106, i32 %104
  %108 = insertelement <2 x float> <float 0.000000e+00, float undef>, float %conv1.i867, i32 1
  %109 = tail call <2 x float> @llvm.fabs.v2f32(<2 x float> %108) #3
  %110 = bitcast <2 x float> %109 to <2 x i32>
  %111 = extractelement <2 x i32> %110, i32 0
  %112 = extractelement <2 x i32> %110, i32 1
  %113 = or i32 %111, %112
  %114 = icmp eq i32 %113, 0
  %115 = icmp eq i32 %106, 0
  %116 = or i1 %115, %114
  %117 = bitcast i32 %107 to float
  %118 = select i1 %116, float 0.000000e+00, float %117
  br label %_Z12tigre_rcp_rdf.exit876

_Z12tigre_rcp_rdf.exit876:                        ; preds = %_Z12tigre_rcp_rdf.exit887, %if.end.i868, %if.end3.i873, %if.then7.i874
  %retval.1.i875 = phi float [ 0x7FF0000000000000, %_Z12tigre_rcp_rdf.exit887 ], [ 0x47EFFFFFE0000000, %if.end.i868 ], [ %118, %if.then7.i874 ], [ %conv1.i867, %if.end3.i873 ]
  %119 = tail call float @llvm.fabs.f32(float %cond110) #3
  %cmp.i862 = fcmp oeq float %cond110, 0.000000e+00
  br i1 %cmp.i862, label %_Z12tigre_rcp_rdf.exit, label %if.end.i

if.end.i:                                         ; preds = %_Z12tigre_rcp_rdf.exit876
  %conv1.i863 = fdiv float 1.000000e+00, %119
  %120 = fcmp oeq float %conv1.i863, 0x7FF0000000000000
  br i1 %120, label %_Z12tigre_rcp_rdf.exit, label %if.end3.i

if.end3.i:                                        ; preds = %if.end.i
  %conv.i864 = fpext float %119 to double
  %conv4.i = fpext float %conv1.i863 to double
  %mul.i865 = fmul double %conv.i864, %conv4.i
  %cmp6.i = fcmp ogt double %mul.i865, 1.000000e+00
  br i1 %cmp6.i, label %if.then7.i, label %_Z12tigre_rcp_rdf.exit

if.then7.i:                                       ; preds = %if.end3.i
  %121 = insertelement <2 x float> <float undef, float 0.000000e+00>, float %conv1.i863, i32 0
  %122 = bitcast <2 x float> %121 to <2 x i32>
  %123 = sub nsw <2 x i32> <i32 -2147483648, i32 -2147483648>, %122
  %124 = icmp slt <2 x i32> %122, zeroinitializer
  %125 = select <2 x i1> %124, <2 x i32> %123, <2 x i32> %122
  %126 = extractelement <2 x i32> %125, i32 0
  %127 = extractelement <2 x i32> %125, i32 1
  %128 = icmp slt i32 %126, %127
  %129 = select i1 %128, i32 1, i32 -1
  %130 = add nsw i32 %129, %126
  %131 = sub nsw i32 -2147483648, %130
  %132 = icmp slt i32 %130, 0
  %133 = select i1 %132, i32 %131, i32 %130
  %134 = fcmp uno float %conv1.i863, 0.000000e+00
  %135 = bitcast float %conv1.i863 to i32
  %136 = select i1 %134, i32 %135, i32 %133
  %137 = insertelement <2 x float> <float 0.000000e+00, float undef>, float %conv1.i863, i32 1
  %138 = tail call <2 x float> @llvm.fabs.v2f32(<2 x float> %137) #3
  %139 = bitcast <2 x float> %138 to <2 x i32>
  %140 = extractelement <2 x i32> %139, i32 0
  %141 = extractelement <2 x i32> %139, i32 1
  %142 = or i32 %140, %141
  %143 = icmp eq i32 %142, 0
  %144 = icmp eq i32 %135, 0
  %145 = or i1 %144, %143
  %146 = bitcast i32 %136 to float
  %147 = select i1 %145, float 0.000000e+00, float %146
  br label %_Z12tigre_rcp_rdf.exit

_Z12tigre_rcp_rdf.exit:                           ; preds = %_Z12tigre_rcp_rdf.exit876, %if.end.i, %if.end3.i, %if.then7.i
  %retval.1.i = phi float [ 0x7FF0000000000000, %_Z12tigre_rcp_rdf.exit876 ], [ 0x47EFFFFFE0000000, %if.end.i ], [ %147, %if.then7.i ], [ %conv1.i863, %if.end3.i ]
  %cond435 = select i1 %cmp184, float 1.000000e+00, float -1.000000e+00
  %cond439 = select i1 %cmp234, float 1.000000e+00, float -1.000000e+00
  %cond443 = select i1 %cmp285, float 1.000000e+00, float -1.000000e+00
  %mul446 = fmul float %cond, %cond
  %mul447 = fmul float %3, %mul446
  %mul449 = fmul float %3, %mul447
  %mul452 = fmul float %cond101, %cond101
  %mul453 = fmul float %4, %mul452
  %mul455 = fmul float %4, %mul453
  %add456 = fadd float %mul449, %mul455
  %mul459 = fmul float %cond110, %cond110
  %mul460 = fmul float %5, %mul459
  %mul462 = fmul float %5, %mul460
  %add463 = fadd float %add456, %mul462
  %conv.i = fpext float %add463 to double
  %148 = fcmp olt double %conv.i, 0x1000000000000000
  %149 = select i1 %148, double 0x4FF0000000000000, double 1.000000e+00
  %150 = fmul double %149, %conv.i
  %151 = tail call double @llvm.amdgcn.rsq.f64(double %150) #3
  %152 = fmul double %150, %151
  %153 = fmul double %151, 5.000000e-01
  %154 = fneg double %153
  %155 = tail call double @llvm.fma.f64(double %154, double %152, double 5.000000e-01) #3
  %156 = tail call double @llvm.fma.f64(double %153, double %155, double %153) #3
  %157 = tail call double @llvm.fma.f64(double %152, double %155, double %152) #3
  %158 = fneg double %157
  %159 = tail call double @llvm.fma.f64(double %158, double %157, double %150) #3
  %160 = tail call double @llvm.fma.f64(double %159, double %156, double %157) #3
  %161 = fneg double %160
  %162 = tail call double @llvm.fma.f64(double %161, double %160, double %150) #3
  %163 = tail call double @llvm.fma.f64(double %162, double %156, double %160) #3
  %164 = select i1 %148, double 0x37F0000000000000, double 1.000000e+00
  %165 = fmul double %164, %163
  %166 = fcmp oeq double %150, 0.000000e+00
  %167 = fcmp oeq double %150, 0x7FF0000000000000
  %168 = or i1 %166, %167
  %169 = select i1 %168, double %150, double %165
  %conv1.i = fptrunc double %169 to float
  %conv2.i = fpext float %conv1.i to double
  %mul.i = fmul double %conv2.i, %conv2.i
  %cmp.i = fcmp ogt double %mul.i, %conv.i
  br i1 %cmp.i, label %if.then.i, label %_Z13tigre_sqrt_rdf.exit

if.then.i:                                        ; preds = %_Z12tigre_rcp_rdf.exit
  %170 = insertelement <2 x float> <float undef, float 0.000000e+00>, float %conv1.i, i32 0
  %171 = bitcast <2 x float> %170 to <2 x i32>
  %172 = sub nsw <2 x i32> <i32 -2147483648, i32 -2147483648>, %171
  %173 = icmp slt <2 x i32> %171, zeroinitializer
  %174 = select <2 x i1> %173, <2 x i32> %172, <2 x i32> %171
  %175 = extractelement <2 x i32> %174, i32 0
  %176 = extractelement <2 x i32> %174, i32 1
  %177 = icmp slt i32 %175, %176
  %178 = select i1 %177, i32 1, i32 -1
  %179 = add nsw i32 %178, %175
  %180 = sub nsw i32 -2147483648, %179
  %181 = icmp slt i32 %179, 0
  %182 = select i1 %181, i32 %180, i32 %179
  %183 = fcmp uno float %conv1.i, 0.000000e+00
  %184 = bitcast float %conv1.i to i32
  %185 = select i1 %183, i32 %184, i32 %182
  %186 = insertelement <2 x float> <float 0.000000e+00, float undef>, float %conv1.i, i32 1
  %187 = tail call <2 x float> @llvm.fabs.v2f32(<2 x float> %186) #3
  %188 = bitcast <2 x float> %187 to <2 x i32>
  %189 = extractelement <2 x i32> %188, i32 0
  %190 = extractelement <2 x i32> %188, i32 1
  %191 = or i32 %189, %190
  %192 = icmp eq i32 %191, 0
  %193 = icmp eq i32 %184, 0
  %194 = or i1 %193, %192
  %195 = bitcast i32 %185 to float
  %196 = select i1 %194, float 0.000000e+00, float %195
  br label %_Z13tigre_sqrt_rdf.exit

_Z13tigre_sqrt_rdf.exit:                          ; preds = %_Z12tigre_rcp_rdf.exit, %if.then.i
  %r.0.i = phi float [ %196, %if.then.i ], [ %conv1.i, %_Z12tigre_rcp_rdf.exit ]
  %sub465 = fsub float %imax.0, %imin.0
  %add466 = fadd float %sub465, 1.000000e+00
  %sub467 = fsub float %jmax.0, %jmin.0
  %add468 = fadd float %sub467, 1.000000e+00
  %add469 = fadd float %add466, %add468
  %sub470 = fsub float %kmax.0, %kmin.0
  %add471 = fadd float %sub470, 1.000000e+00
  %add472 = fadd float %add469, %add471
  %conv473 = fptoui float %add472 to i64
  %cmp483908.not = icmp eq i64 %conv473, 0
  br i1 %cmp483908.not, label %for.cond.cleanup, label %for.body.lr.ph

for.body.lr.ph:                                   ; preds = %_Z13tigre_sqrt_rdf.exit
  %conv480 = uitofp i64 %conv422 to float
  %add481 = fadd float %conv480, 5.000000e-01
  %conv482 = fptoui float %add481 to i64
  %conv477 = uitofp i64 %conv414 to float
  %add478 = fadd float %conv477, 5.000000e-01
  %conv479 = fptoui float %add478 to i64
  %conv474 = uitofp i64 %conv406 to float
  %add475 = fadd float %conv474, 5.000000e-01
  %conv476 = fptoui float %add475 to i64
  %197 = bitcast %struct.__hip_texture addrspace(1)* %tex.coerce to i32 addrspace(1)*
  %198 = addrspacecast i32 addrspace(1)* %197 to i32 addrspace(4)*
  %add.ptr.i = getelementptr inbounds i32, i32 addrspace(4)* %198, i64 12
  %199 = getelementptr inbounds i32, i32 addrspace(4)* %198, i64 10
  %200 = getelementptr inbounds i32, i32 addrspace(4)* %198, i64 2
  %201 = getelementptr inbounds i32, i32 addrspace(4)* %198, i64 4
  %202 = getelementptr inbounds i32, i32 addrspace(4)* %198, i64 14
  %203 = bitcast %struct.__hip_texture addrspace(1)* %tex.coerce to <8 x i32> addrspace(1)*
  %204 = addrspacecast <8 x i32> addrspace(1)* %203 to <8 x i32> addrspace(4)*
  %205 = bitcast i32 addrspace(4)* %add.ptr.i to <4 x i32> addrspace(4)*
  br label %for.body

for.cond.cleanup:                                 ; preds = %if.end527, %_Z13tigre_sqrt_rdf.exit
  %sum.0.lcssa = phi float [ 0.000000e+00, %_Z13tigre_sqrt_rdf.exit ], [ %sum.1, %if.end527 ]
  %mul530 = fmul float %r.0.i, %sum.0.lcssa
  %arrayidx531848 = getelementptr inbounds float, float addrspace(1)* %detector.coerce, i64 %add29
  store float %mul530, float addrspace(1)* %arrayidx531848, align 4, !tbaa !9
  br label %cleanup550

for.body:                                         ; preds = %for.body.lr.ph, %if.end527
  %ii.0918 = phi i64 [ 0, %for.body.lr.ph ], [ %inc, %if.end527 ]
  %sum.0917 = phi float [ 0.000000e+00, %for.body.lr.ph ], [ %sum.1, %if.end527 ]
  %ac.0916 = phi float [ %35, %for.body.lr.ph ], [ %ac.1, %if.end527 ]
  %aminc.0915 = phi float [ %57, %for.body.lr.ph ], [ %321, %if.end527 ]
  %k.0914 = phi i64 [ %conv482, %for.body.lr.ph ], [ %k.1, %if.end527 ]
  %j.0913 = phi i64 [ %conv479, %for.body.lr.ph ], [ %j.1, %if.end527 ]
  %i.0912 = phi i64 [ %conv476, %for.body.lr.ph ], [ %i.1, %if.end527 ]
  %az.0911 = phi float [ %cond396, %for.body.lr.ph ], [ %az.1, %if.end527 ]
  %ay.0910 = phi float [ %cond390, %for.body.lr.ph ], [ %ay.1, %if.end527 ]
  %ax.0909 = phi float [ %cond384, %for.body.lr.ph ], [ %ax.1, %if.end527 ]
  %cmp484 = fcmp oeq float %ax.0909, %aminc.0915
  br i1 %cmp484, label %if.then485, label %if.else497

if.then485:                                       ; preds = %for.body
  %sub486 = fsub float %ax.0909, %ac.0916
  %conv487 = uitofp i64 %i.0912 to float
  %conv488 = uitofp i64 %j.0913 to float
  %conv489 = uitofp i64 %k.0914 to float
  %206 = load i32, i32 addrspace(4)* %199, align 4, !tbaa !13
  %207 = uitofp i32 %206 to float
  %208 = load i32, i32 addrspace(4)* %200, align 4, !tbaa !13
  %209 = lshr i32 %208, 14
  %210 = and i32 %209, 16383
  %211 = add nuw nsw i32 %210, 1
  %212 = uitofp i32 %211 to float
  %213 = load i32, i32 addrspace(4)* %201, align 4, !tbaa !13
  %214 = and i32 %213, 8191
  %215 = add nuw nsw i32 %214, 1
  %216 = uitofp i32 %215 to float
  %217 = load i32, i32 addrspace(4)* %add.ptr.i, align 4, !tbaa !13
  %218 = and i32 %217, 32768
  %219 = icmp eq i32 %218, 0
  %220 = select i1 %219, float %207, float 1.000000e+00
  %221 = select i1 %219, float %212, float 1.000000e+00
  %222 = select i1 %219, float %216, float 1.000000e+00
  %223 = fmul float %220, %conv487
  %224 = tail call float @llvm.floor.f32(float %223) #3
  %225 = tail call float @llvm.amdgcn.rcp.f32(float %220) #3
  %226 = fmul float %225, %224
  %227 = fmul float %221, %conv488
  %228 = tail call float @llvm.floor.f32(float %227) #3
  %229 = tail call float @llvm.amdgcn.rcp.f32(float %221) #3
  %230 = fmul float %229, %228
  %231 = fmul float %222, %conv489
  %232 = tail call float @llvm.floor.f32(float %231) #3
  %233 = tail call float @llvm.amdgcn.rcp.f32(float %222) #3
  %234 = fmul float %233, %232
  %235 = load i32, i32 addrspace(4)* %202, align 4, !tbaa !13
  %236 = and i32 %235, 1048576
  %237 = icmp eq i32 %236, 0
  %238 = select i1 %237, float %226, float %conv487
  %239 = select i1 %237, float %230, float %conv488
  %240 = select i1 %237, float %234, float %conv489
  %241 = load <8 x i32>, <8 x i32> addrspace(4)* %204, align 32, !tbaa !17
  %242 = load <4 x i32>, <4 x i32> addrspace(4)* %205, align 16, !tbaa !17
  %243 = tail call float @llvm.amdgcn.image.sample.lz.3d.f32.f32(i32 1, float %238, float %239, float %240, <8 x i32> %241, <4 x i32> %242, i1 false, i32 0, i32 0)
  %mul491 = fmul float %sub486, %243
  %add492 = fadd float %sum.0917, %mul491
  %add494 = fadd float %cond435, %conv487
  %conv495 = fptoui float %add494 to i64
  %add496 = fadd float %retval.1.i886, %ax.0909
  br label %if.end527

if.else497:                                       ; preds = %for.body
  %cmp498 = fcmp oeq float %ay.0910, %aminc.0915
  br i1 %cmp498, label %if.then499, label %if.else511

if.then499:                                       ; preds = %if.else497
  %sub500 = fsub float %ay.0910, %ac.0916
  %conv501 = uitofp i64 %i.0912 to float
  %conv502 = uitofp i64 %j.0913 to float
  %conv503 = uitofp i64 %k.0914 to float
  %244 = load i32, i32 addrspace(4)* %199, align 4, !tbaa !13
  %245 = uitofp i32 %244 to float
  %246 = load i32, i32 addrspace(4)* %200, align 4, !tbaa !13
  %247 = lshr i32 %246, 14
  %248 = and i32 %247, 16383
  %249 = add nuw nsw i32 %248, 1
  %250 = uitofp i32 %249 to float
  %251 = load i32, i32 addrspace(4)* %201, align 4, !tbaa !13
  %252 = and i32 %251, 8191
  %253 = add nuw nsw i32 %252, 1
  %254 = uitofp i32 %253 to float
  %255 = load i32, i32 addrspace(4)* %add.ptr.i, align 4, !tbaa !13
  %256 = and i32 %255, 32768
  %257 = icmp eq i32 %256, 0
  %258 = select i1 %257, float %245, float 1.000000e+00
  %259 = select i1 %257, float %250, float 1.000000e+00
  %260 = select i1 %257, float %254, float 1.000000e+00
  %261 = fmul float %258, %conv501
  %262 = tail call float @llvm.floor.f32(float %261) #3
  %263 = tail call float @llvm.amdgcn.rcp.f32(float %258) #3
  %264 = fmul float %263, %262
  %265 = fmul float %259, %conv502
  %266 = tail call float @llvm.floor.f32(float %265) #3
  %267 = tail call float @llvm.amdgcn.rcp.f32(float %259) #3
  %268 = fmul float %267, %266
  %269 = fmul float %260, %conv503
  %270 = tail call float @llvm.floor.f32(float %269) #3
  %271 = tail call float @llvm.amdgcn.rcp.f32(float %260) #3
  %272 = fmul float %271, %270
  %273 = load i32, i32 addrspace(4)* %202, align 4, !tbaa !13
  %274 = and i32 %273, 1048576
  %275 = icmp eq i32 %274, 0
  %276 = select i1 %275, float %264, float %conv501
  %277 = select i1 %275, float %268, float %conv502
  %278 = select i1 %275, float %272, float %conv503
  %279 = load <8 x i32>, <8 x i32> addrspace(4)* %204, align 32, !tbaa !17
  %280 = load <4 x i32>, <4 x i32> addrspace(4)* %205, align 16, !tbaa !17
  %281 = tail call float @llvm.amdgcn.image.sample.lz.3d.f32.f32(i32 1, float %276, float %277, float %278, <8 x i32> %279, <4 x i32> %280, i1 false, i32 0, i32 0)
  %mul505 = fmul float %sub500, %281
  %add506 = fadd float %sum.0917, %mul505
  %add508 = fadd float %cond439, %conv502
  %conv509 = fptoui float %add508 to i64
  %add510 = fadd float %retval.1.i875, %ay.0910
  br label %if.end527

if.else511:                                       ; preds = %if.else497
  %cmp512 = fcmp oeq float %az.0911, %aminc.0915
  br i1 %cmp512, label %if.then513, label %if.end527

if.then513:                                       ; preds = %if.else511
  %sub514 = fsub float %az.0911, %ac.0916
  %conv515 = uitofp i64 %i.0912 to float
  %conv516 = uitofp i64 %j.0913 to float
  %conv517 = uitofp i64 %k.0914 to float
  %282 = load i32, i32 addrspace(4)* %199, align 4, !tbaa !13
  %283 = uitofp i32 %282 to float
  %284 = load i32, i32 addrspace(4)* %200, align 4, !tbaa !13
  %285 = lshr i32 %284, 14
  %286 = and i32 %285, 16383
  %287 = add nuw nsw i32 %286, 1
  %288 = uitofp i32 %287 to float
  %289 = load i32, i32 addrspace(4)* %201, align 4, !tbaa !13
  %290 = and i32 %289, 8191
  %291 = add nuw nsw i32 %290, 1
  %292 = uitofp i32 %291 to float
  %293 = load i32, i32 addrspace(4)* %add.ptr.i, align 4, !tbaa !13
  %294 = and i32 %293, 32768
  %295 = icmp eq i32 %294, 0
  %296 = select i1 %295, float %283, float 1.000000e+00
  %297 = select i1 %295, float %288, float 1.000000e+00
  %298 = select i1 %295, float %292, float 1.000000e+00
  %299 = fmul float %296, %conv515
  %300 = tail call float @llvm.floor.f32(float %299) #3
  %301 = tail call float @llvm.amdgcn.rcp.f32(float %296) #3
  %302 = fmul float %301, %300
  %303 = fmul float %297, %conv516
  %304 = tail call float @llvm.floor.f32(float %303) #3
  %305 = tail call float @llvm.amdgcn.rcp.f32(float %297) #3
  %306 = fmul float %305, %304
  %307 = fmul float %298, %conv517
  %308 = tail call float @llvm.floor.f32(float %307) #3
  %309 = tail call float @llvm.amdgcn.rcp.f32(float %298) #3
  %310 = fmul float %309, %308
  %311 = load i32, i32 addrspace(4)* %202, align 4, !tbaa !13
  %312 = and i32 %311, 1048576
  %313 = icmp eq i32 %312, 0
  %314 = select i1 %313, float %302, float %conv515
  %315 = select i1 %313, float %306, float %conv516
  %316 = select i1 %313, float %310, float %conv517
  %317 = load <8 x i32>, <8 x i32> addrspace(4)* %204, align 32, !tbaa !17
  %318 = load <4 x i32>, <4 x i32> addrspace(4)* %205, align 16, !tbaa !17
  %319 = tail call float @llvm.amdgcn.image.sample.lz.3d.f32.f32(i32 1, float %314, float %315, float %316, <8 x i32> %317, <4 x i32> %318, i1 false, i32 0, i32 0)
  %mul519 = fmul float %sub514, %319
  %add520 = fadd float %sum.0917, %mul519
  %add522 = fadd float %cond443, %conv517
  %conv523 = fptoui float %add522 to i64
  %add524 = fadd float %retval.1.i, %az.0911
  br label %if.end527

if.end527:                                        ; preds = %if.then499, %if.then513, %if.else511, %if.then485
  %ax.1 = phi float [ %add496, %if.then485 ], [ %ax.0909, %if.then499 ], [ %ax.0909, %if.then513 ], [ %ax.0909, %if.else511 ]
  %ay.1 = phi float [ %ay.0910, %if.then485 ], [ %add510, %if.then499 ], [ %ay.0910, %if.then513 ], [ %ay.0910, %if.else511 ]
  %az.1 = phi float [ %az.0911, %if.then485 ], [ %az.0911, %if.then499 ], [ %add524, %if.then513 ], [ %az.0911, %if.else511 ]
  %i.1 = phi i64 [ %conv495, %if.then485 ], [ %i.0912, %if.then499 ], [ %i.0912, %if.then513 ], [ %i.0912, %if.else511 ]
  %j.1 = phi i64 [ %j.0913, %if.then485 ], [ %conv509, %if.then499 ], [ %j.0913, %if.then513 ], [ %j.0913, %if.else511 ]
  %k.1 = phi i64 [ %k.0914, %if.then485 ], [ %k.0914, %if.then499 ], [ %conv523, %if.then513 ], [ %k.0914, %if.else511 ]
  %ac.1 = phi float [ %ax.0909, %if.then485 ], [ %ay.0910, %if.then499 ], [ %az.0911, %if.then513 ], [ %ac.0916, %if.else511 ]
  %sum.1 = phi float [ %add492, %if.then485 ], [ %add506, %if.then499 ], [ %add520, %if.then513 ], [ %sum.0917, %if.else511 ]
  %320 = tail call float @llvm.minnum.f32(float %ax.1, float %ay.1) #3
  %321 = tail call float @llvm.minnum.f32(float %320, float %az.1) #3
  %inc = add nuw i64 %ii.0918, 1
  %exitcond.not = icmp eq i64 %inc, %conv473
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body

cleanup550:                                       ; preds = %if.end, %for.cond.cleanup, %if.then179, %entry, %lor.lhs.false
  ret void
}

; Function Attrs: convergent nounwind readnone speculatable willreturn
declare float @llvm.ceil.f32(float) #1

; Function Attrs: convergent nounwind readnone speculatable willreturn
declare float @llvm.fabs.f32(float) #1

; Function Attrs: convergent nounwind readnone speculatable willreturn
declare float @llvm.floor.f32(float) #1

; Function Attrs: convergent nounwind readnone speculatable willreturn
declare float @llvm.maxnum.f32(float, float) #1

; Function Attrs: convergent nounwind readnone speculatable willreturn
declare float @llvm.minnum.f32(float, float) #1

; Function Attrs: convergent nounwind readnone speculatable willreturn
declare <2 x float> @llvm.fabs.v2f32(<2 x float>) #1

; Function Attrs: convergent nounwind readnone speculatable willreturn
declare double @llvm.amdgcn.rsq.f64(double) #1

; Function Attrs: convergent nounwind readnone speculatable willreturn
declare double @llvm.fma.f64(double, double, double) #1

; Function Attrs: convergent nounwind readnone speculatable willreturn
declare float @llvm.amdgcn.rcp.f32(float) #1

; Function Attrs: convergent nounwind readnone speculatable willreturn
declare align 4 i8 addrspace(4)* @llvm.amdgcn.dispatch.ptr() #1

; Function Attrs: convergent nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.workgroup.id.x() #1

; Function Attrs: convergent nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.workgroup.id.y() #1

; Function Attrs: convergent nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.workitem.id.x() #1

; Function Attrs: convergent nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.workitem.id.y() #1

; Function Attrs: convergent nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.workitem.id.z() #1

; Function Attrs: nounwind readonly willreturn
declare float @llvm.amdgcn.image.sample.lz.3d.f32.f32(i32 immarg, float, float, float, <8 x i32>, <4 x i32>, i1 immarg, i32 immarg, i32 immarg) #2

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,729" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { convergent nounwind readnone speculatable willreturn "correctly-rounded-divide-sqrt-fp-math"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind readonly willreturn }
attributes #3 = { nounwind }
attributes #4 = { nounwind readnone }

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
!8 = !{i64 0, i64 4, !9, i64 4, i64 4, !9, i64 8, i64 4, !9}
!9 = !{!10, !10, i64 0}
!10 = !{!"float", !11, i64 0}
!11 = !{!"omnipotent char", !12, i64 0}
!12 = !{!"Simple C++ TBAA"}
!13 = !{!14, !14, i64 0}
!14 = !{!"int", !15, i64 0}
!15 = !{!"omnipotent char", !16, i64 0}
!16 = !{!"Simple C/C++ TBAA"}
!17 = !{!15, !15, i64 0}
