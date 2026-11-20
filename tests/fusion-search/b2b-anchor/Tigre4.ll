source_filename = "Tigre4.ll"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare float @llvm.floor.f32(float) #0

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.amdgcn.rcp.f32(float) #1

; Function Attrs: nounwind readonly willreturn
declare float @llvm.amdgcn.image.sample.lz.3d.f32.f32(i32 immarg, float, float, float, <8 x i32>, <4 x i32>, i1 immarg, i32 immarg, i32 immarg) #2

define { float, float, i64, i64, float, float } @Tigre4(i1 %cond, float %ax.0909, float %ac.0916, i64 %i.0912, i64 %j.0913, i64 %k.0914, i32 addrspace(4)* %i226, i32 addrspace(4)* %i227, i32 addrspace(4)* %i228, i32 addrspace(4)* %add.ptr.i, i32 addrspace(4)* %i229, <8 x i32> addrspace(4)* %i231, <4 x i32> addrspace(4)* %i232, float %sum.0917, float %cond435, float %retval.1.i886, float %ay.0910, float %cond439, float %retval.1.i875) #3 {
entry:
  br i1 %cond, label %left, label %right

left:                                             ; preds = %entry
  %sub486 = fsub float %ax.0909, %ac.0916
  %conv487 = uitofp i64 %i.0912 to float
  %conv488 = uitofp i64 %j.0913 to float
  %conv489 = uitofp i64 %k.0914 to float
  %i233 = load i32, i32 addrspace(4)* %i226, align 4, !tbaa !5
  %i234 = uitofp i32 %i233 to float
  %i235 = load i32, i32 addrspace(4)* %i227, align 4, !tbaa !5
  %i236 = lshr i32 %i235, 14
  %i237 = and i32 %i236, 16383
  %i238 = add nuw nsw i32 %i237, 1
  %i239 = uitofp i32 %i238 to float
  %i240 = load i32, i32 addrspace(4)* %i228, align 4, !tbaa !5
  %i241 = and i32 %i240, 8191
  %i242 = add nuw nsw i32 %i241, 1
  %i243 = uitofp i32 %i242 to float
  %i244 = load i32, i32 addrspace(4)* %add.ptr.i, align 4, !tbaa !5
  %i245 = and i32 %i244, 32768
  %i246 = icmp eq i32 %i245, 0
  %i247 = select i1 %i246, float %i234, float 1.000000e+00
  %i248 = select i1 %i246, float %i239, float 1.000000e+00
  %i249 = select i1 %i246, float %i243, float 1.000000e+00
  %i250 = fmul float %i247, %conv487
  %i251 = tail call float @llvm.floor.f32(float %i250) #4
  %i252 = tail call float @llvm.amdgcn.rcp.f32(float %i247) #4
  %i253 = fmul float %i252, %i251
  %i254 = fmul float %i248, %conv488
  %i255 = tail call float @llvm.floor.f32(float %i254) #4
  %i256 = tail call float @llvm.amdgcn.rcp.f32(float %i248) #4
  %i257 = fmul float %i256, %i255
  %i258 = fmul float %i249, %conv489
  %i259 = tail call float @llvm.floor.f32(float %i258) #4
  %i260 = tail call float @llvm.amdgcn.rcp.f32(float %i249) #4
  %i261 = fmul float %i260, %i259
  %i262 = load i32, i32 addrspace(4)* %i229, align 4, !tbaa !5
  %i263 = and i32 %i262, 1048576
  %i264 = icmp eq i32 %i263, 0
  %i265 = select i1 %i264, float %i253, float %conv487
  %i266 = select i1 %i264, float %i257, float %conv488
  %i267 = select i1 %i264, float %i261, float %conv489
  %i268 = load <8 x i32>, <8 x i32> addrspace(4)* %i231, align 32, !tbaa !9
  %i269 = load <4 x i32>, <4 x i32> addrspace(4)* %i232, align 16, !tbaa !9
  %i270 = tail call float @llvm.amdgcn.image.sample.lz.3d.f32.f32(i32 1, float %i265, float %i266, float %i267, <8 x i32> %i268, <4 x i32> %i269, i1 false, i32 0, i32 0)
  %mul491 = fmul float %sub486, %i270
  %add492 = fadd float %sum.0917, %mul491
  %add494 = fadd float %cond435, %conv487
  %conv495 = fptoui float %add494 to i64
  %add496 = fadd float %retval.1.i886, %ax.0909
  br label %join

right:                                            ; preds = %entry
  %sub500 = fsub float %ay.0910, %ac.0916
  %conv501 = uitofp i64 %i.0912 to float
  %conv502 = uitofp i64 %j.0913 to float
  %conv503 = uitofp i64 %k.0914 to float
  %i271 = load i32, i32 addrspace(4)* %i226, align 4, !tbaa !5
  %i272 = uitofp i32 %i271 to float
  %i273 = load i32, i32 addrspace(4)* %i227, align 4, !tbaa !5
  %i274 = lshr i32 %i273, 14
  %i275 = and i32 %i274, 16383
  %i276 = add nuw nsw i32 %i275, 1
  %i277 = uitofp i32 %i276 to float
  %i278 = load i32, i32 addrspace(4)* %i228, align 4, !tbaa !5
  %i279 = and i32 %i278, 8191
  %i280 = add nuw nsw i32 %i279, 1
  %i281 = uitofp i32 %i280 to float
  %i282 = load i32, i32 addrspace(4)* %add.ptr.i, align 4, !tbaa !5
  %i283 = and i32 %i282, 32768
  %i284 = icmp eq i32 %i283, 0
  %i285 = select i1 %i284, float %i272, float 1.000000e+00
  %i286 = select i1 %i284, float %i277, float 1.000000e+00
  %i287 = select i1 %i284, float %i281, float 1.000000e+00
  %i288 = fmul float %i285, %conv501
  %i289 = tail call float @llvm.floor.f32(float %i288) #4
  %i290 = tail call float @llvm.amdgcn.rcp.f32(float %i285) #4
  %i291 = fmul float %i290, %i289
  %i292 = fmul float %i286, %conv502
  %i293 = tail call float @llvm.floor.f32(float %i292) #4
  %i294 = tail call float @llvm.amdgcn.rcp.f32(float %i286) #4
  %i295 = fmul float %i294, %i293
  %i296 = fmul float %i287, %conv503
  %i297 = tail call float @llvm.floor.f32(float %i296) #4
  %i298 = tail call float @llvm.amdgcn.rcp.f32(float %i287) #4
  %i299 = fmul float %i298, %i297
  %i300 = load i32, i32 addrspace(4)* %i229, align 4, !tbaa !5
  %i301 = and i32 %i300, 1048576
  %i302 = icmp eq i32 %i301, 0
  %i303 = select i1 %i302, float %i291, float %conv501
  %i304 = select i1 %i302, float %i295, float %conv502
  %i305 = select i1 %i302, float %i299, float %conv503
  %i306 = load <8 x i32>, <8 x i32> addrspace(4)* %i231, align 32, !tbaa !9
  %i307 = load <4 x i32>, <4 x i32> addrspace(4)* %i232, align 16, !tbaa !9
  %i308 = tail call float @llvm.amdgcn.image.sample.lz.3d.f32.f32(i32 1, float %i303, float %i304, float %i305, <8 x i32> %i306, <4 x i32> %i307, i1 false, i32 0, i32 0)
  %mul505 = fmul float %sub500, %i308
  %add506 = fadd float %sum.0917, %mul505
  %add508 = fadd float %cond439, %conv502
  %conv509 = fptoui float %add508 to i64
  %add510 = fadd float %retval.1.i875, %ay.0910
  br label %join

join:                                             ; preds = %right, %left
  %ax.1.ph = phi float [ %add496, %left ], [ %ax.0909, %right ]
  %ay.1.ph = phi float [ %ay.0910, %left ], [ %add510, %right ]
  %i.1.ph = phi i64 [ %conv495, %left ], [ %i.0912, %right ]
  %j.1.ph = phi i64 [ %j.0913, %left ], [ %conv509, %right ]
  %ac.1.ph = phi float [ %ax.0909, %left ], [ %ay.0910, %right ]
  %sum.1.ph = phi float [ %add492, %left ], [ %add506, %right ]
  %0 = insertvalue { float, float, i64, i64, float, float } undef, float %ax.1.ph, 0
  %1 = insertvalue { float, float, i64, i64, float, float } %0, float %ay.1.ph, 1
  %2 = insertvalue { float, float, i64, i64, float, float } %1, i64 %i.1.ph, 2
  %3 = insertvalue { float, float, i64, i64, float, float } %2, i64 %j.1.ph, 3
  %4 = insertvalue { float, float, i64, i64, float, float } %3, float %ac.1.ph, 4
  %5 = insertvalue { float, float, i64, i64, float, float } %4, float %sum.1.ph, 5
  ret { float, float, i64, i64, float, float } %5
}

attributes #0 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { nounwind readonly willreturn }
attributes #3 = { "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0, !1}
!opencl.ocl.version = !{!2}
!llvm.ident = !{!3, !4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 1}
!2 = !{i32 2, i32 0}
!3 = !{!"clang version 12.0.0 (https://github.com/charitha22/cgo22ae-darm-code.git e9bc0540325ad9806313d34e84fc901496fd8be6)"}
!4 = !{!"clang version 12.0.0 (/src/external/llvm-project/clang dac2bfceaa8d4a90257dc8a6d58f268e172ce00e)"}
!5 = !{!6, !6, i64 0}
!6 = !{!"int", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C/C++ TBAA"}
!9 = !{!7, !7, i64 0}
