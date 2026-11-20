; Extracted verbatim first eight-leaf quantization tree from cases/vllm-quant/start.ll.
; External product mul116 is the scalar input; quantized PHI is returned.
target triple = "amdgcn-amd-amdhsa"
declare float @llvm.fabs.f32(float)
declare float @llvm.copysign.f32(float,float)
define float @quant8(float %mul116) #0 {
if.else.7:                                        ; preds = %cond.end75
  %v101 = tail call float @llvm.fabs.f32(float %mul116)
  %cmp.i43 = fcmp ugt float %v101, 2.500000e-01
  br i1 %cmp.i43, label %if.else.i, label %if.then.i

if.then.i:                                        ; preds = %if.else.7
  %v102 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116)
  br label %quant_decide.exit

if.else.i:                                        ; preds = %if.else.7
  %cmp2.i44 = fcmp olt float %v101, 7.500000e-01
  br i1 %cmp2.i44, label %if.then3.i, label %if.else4.i

if.then3.i:                                       ; preds = %if.else.i
  %v103 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116)
  br label %quant_decide.exit

if.else4.i:                                       ; preds = %if.else.i
  %cmp6.i45 = fcmp ugt float %v101, 1.250000e+00
  br i1 %cmp6.i45, label %if.else8.i, label %if.then7.i

if.then7.i:                                       ; preds = %if.else4.i
  %v104 = tail call float @llvm.copysign.f32(float 1.000000e+00, float %mul116)
  br label %quant_decide.exit

if.else8.i:                                       ; preds = %if.else4.i
  %cmp10.i46 = fcmp olt float %v101, 1.750000e+00
  br i1 %cmp10.i46, label %if.then11.i, label %if.else12.i

if.then11.i:                                      ; preds = %if.else8.i
  %v105 = tail call float @llvm.copysign.f32(float 1.500000e+00, float %mul116)
  br label %quant_decide.exit

if.else12.i:                                      ; preds = %if.else8.i
  %cmp14.i47 = fcmp ugt float %v101, 2.500000e+00
  br i1 %cmp14.i47, label %if.else16.i, label %if.then15.i

if.then15.i:                                      ; preds = %if.else12.i
  %v106 = tail call float @llvm.copysign.f32(float 2.000000e+00, float %mul116)
  br label %quant_decide.exit

if.else16.i:                                      ; preds = %if.else12.i
  %cmp18.i = fcmp olt float %v101, 3.500000e+00
  br i1 %cmp18.i, label %if.then19.i, label %if.else20.i

if.then19.i:                                      ; preds = %if.else16.i
  %v107 = tail call float @llvm.copysign.f32(float 3.000000e+00, float %mul116)
  br label %quant_decide.exit

if.else20.i:                                      ; preds = %if.else16.i
  %cmp22.i = fcmp ugt float %v101, 5.000000e+00
  br i1 %cmp22.i, label %if.end29.i, label %if.then23.i

if.then23.i:                                      ; preds = %if.else20.i
  %v108 = tail call float @llvm.copysign.f32(float 4.000000e+00, float %mul116)
  br label %quant_decide.exit

if.end29.i:                                       ; preds = %if.else20.i
  %v109 = tail call float @llvm.copysign.f32(float 6.000000e+00, float %mul116)
  br label %quant_decide.exit

quant_decide.exit:                                ; preds = %if.end29.i, %if.then23.i, %if.then19.i, %if.then15.i, %if.then11.i, %if.then7.i, %if.then3.i, %if.then.i
  %out.i372.0 = phi float [ %v103, %if.then3.i ], [ %v105, %if.then11.i ], [ %v107, %if.then19.i ], [ %v109, %if.end29.i ], [ %v108, %if.then23.i ], [ %v106, %if.then15.i ], [ %v104, %if.then7.i ], [ %v102, %if.then.i ]
  ret float %out.i372.0
}
attributes #0 = { "target-cpu"="gfx906" }
