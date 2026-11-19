; The nonmatching operations and two live-outs make the TTI winner a deep forward finalist.
target triple = "amdgcn-amd-amdhsa"

define double @choose(i1 %p, double %x, double %y) #0 {
entry:
  br i1 %p, label %left, label %right
left:
  %l0 = fadd double %x, 0xC030F25386AA802B
  %l1 = fmul double %y, 0x40199996D51EE9B7
  %l2 = fsub double 0x40034649FCCCF81F, %l1
  %l3 = fmul double %y, %l0
  %l = fadd double %l3, 0x40158CEB587D3265
  br label %join
right:
  %r0 = fsub double 0x401B5545C0CB5BDA, %x
  %r1 = fmul double %y, 0x40074E9A9F865729
  %r2 = fadd double %r1, 0xC016B372910B83AB
  %r3 = fmul double %y, %r0
  %r4 = fmul double %y, %r2
  %r5 = fadd double %r3, 0xC0138A29DF206C0B
  %r = fadd double %r4, 0x3FFC33F0B4C09D66
  br label %join
join:
  %v = phi double [ %l, %left ], [ %r, %right ]
  %live = phi double [ %l2, %left ], [ %r5, %right ]
  %result = fadd double %v, %live
  ret double %result
}
attributes #0 = { "target-cpu"="gfx906" }
