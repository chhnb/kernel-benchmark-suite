target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-G1-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Balanced decision tree on the same SSA discriminator %x.
define float @tree(float %x, float addrspace(1)* %t) #0 {
entry:
  %p = fcmp olt float %x, 5.000000e-01
  br i1 %p, label %lower, label %upperq
lower:
  %pl = fcmp olt float %x, 2.500000e-01
  br i1 %pl, label %a, label %b
a:
  %a0 = getelementptr inbounds float, float addrspace(1)* %t, i64 0
  %a1 = load float, float addrspace(1)* %a0, align 4
  %a2 = fmul float %a1, %x
  %a3 = fdiv float %a2, 3.000000e+00
  %a4 = fadd float %a3, 1.000000e+00
  br label %join
b:
  %b0 = getelementptr inbounds float, float addrspace(1)* %t, i64 1
  %b1 = load float, float addrspace(1)* %b0, align 4
  %b2 = fmul float %b1, %x
  %b3 = fdiv float %b2, 5.000000e+00
  %b4 = fadd float %b3, 2.000000e+00
  br label %join
upperq:
  %pu = fcmp olt float %x, 7.500000e-01
  br i1 %pu, label %c, label %d
c:
  %c0 = getelementptr inbounds float, float addrspace(1)* %t, i64 2
  %c1 = load float, float addrspace(1)* %c0, align 4
  %c2 = fmul float %c1, %x
  %c3 = fdiv float %c2, 7.000000e+00
  %c4 = fadd float %c3, 3.000000e+00
  br label %join
d:
  %d0 = getelementptr inbounds float, float addrspace(1)* %t, i64 3
  %d1 = load float, float addrspace(1)* %d0, align 4
  %d2 = fmul float %d1, %x
  %d3 = fdiv float %d2, 9.000000e+00
  %d4 = fadd float %d3, 4.000000e+00
  br label %join
join:
  %r = phi float [ %a4, %a ], [ %b4, %b ], [ %c4, %c ], [ %d4, %d ]
  ret float %r
}
attributes #0 = { nounwind "target-cpu"="gfx906" }
