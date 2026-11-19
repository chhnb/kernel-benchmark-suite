target triple = "amdgcn-amd-amdhsa"

define double @diamond(i1 %c, i32 %a, i32 %b, i32 %x, double %p, double %q) #0 {
entry:
  br i1 %c, label %left, label %right
left:
  %lp = add i32 %a, 5
  %lf = fmul double %p, %p
  %lu = xor i32 %lp, %x
  br label %join
right:
  %rp = add i32 %b, 5
  %ru = xor i32 %rp, %x
  %rf = fmul double %q, %q
  br label %join
join:
  %u = phi i32 [ %lu, %left ], [ %ru, %right ]
  %f = phi double [ %lf, %left ], [ %rf, %right ]
  %d = sitofp i32 %u to double
  %out = fadd double %d, %f
  ret double %out
}
attributes #0 = { "target-cpu"="gfx906" }
