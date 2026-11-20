source_filename = "vllm-7.ll"
target triple = "amdgcn-amd-amdhsa"

define float @quant(float %x, float %signed) #0 {
entry:
  %upper = fcmp ugt float %x, 2.500000e+00
  br i1 %upper, label %high, label %low

low:                                              ; preds = %entry
  %lo175 = fcmp olt float %x, 1.750000e+00
  %lo125 = fcmp ugt float %x, 1.250000e+00
  %lo075 = fcmp olt float %x, 7.500000e-01
  %lo025 = fcmp ugt float %x, 2.500000e-01
  %s105 = select i1 %lo025, float 5.000000e-01, float 0.000000e+00
  %s106 = select i1 %lo075, float %s105, float 1.000000e+00
  %s107 = select i1 %lo125, float 1.500000e+00, float %s106
  %s108 = select i1 %lo175, float %s107, float 2.000000e+00
  %low.result = tail call float @llvm.copysign.f32(float %s108, float %signed)
  br label %exit

high:                                             ; preds = %entry
  %hi35 = fcmp olt float %x, 3.500000e+00
  %hi50 = fcmp ugt float %x, 5.000000e+00
  %s111 = select i1 %hi50, float 6.000000e+00, float 4.000000e+00
  %s112 = select i1 %hi35, float 3.000000e+00, float %s111
  %high.result = tail call float @llvm.copysign.f32(float %s112, float %signed)
  br label %exit

exit:                                             ; preds = %high, %low
  %result = phi float [ %low.result, %low ], [ %high.result, %high ]
  ret float %result
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare float @llvm.copysign.f32(float, float) #1

attributes #0 = { "target-cpu"="gfx906" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
