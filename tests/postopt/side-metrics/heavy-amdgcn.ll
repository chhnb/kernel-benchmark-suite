target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Right side: heavy path block, then a branch on an unrelated value %y.
define float @tree(float %x, float %y) #0 {
entry:
  %p = fcmp olt float %x, 5.000000e-01
  br i1 %p, label %L, label %upper
L:
  %a1 = fmul float %x, 1.500000e+00
  %a2 = fmul float %a1, %x
  %a3 = fdiv float %a2, 3.000000e+00
  %a4 = fadd float %a3, 1.000000e+00
  br label %join
upper:
  %u1 = fdiv float 1.000000e+00, %x
  %u2 = fdiv float %u1, %y
  %u3 = fmul float %u2, %u1
  %q = fcmp olt float %y, 0.000000e+00
  br i1 %q, label %c, label %d
c:
  %c1 = fmul float %u3, 2.500000e+00
  %c2 = fadd float %c1, 3.000000e+00
  br label %join
d:
  %d1 = fmul float %u3, %x
  %d2 = fmul float %d1, %x
  %d3 = fdiv float %d2, 9.000000e+00
  %d4 = fadd float %d3, 4.000000e+00
  br label %join
join:
  %r = phi float [ %a4, %L ], [ %c2, %c ], [ %d4, %d ]
  ret float %r
}
attributes #0 = { nounwind "target-cpu"="gfx906" }
