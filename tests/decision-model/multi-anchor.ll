define double @evaluate(i1 %first, i1 %second, i1 %alt, double* %p, double* %q, double %x) {
entry:
  br i1 %first, label %left, label %test
test:
  br i1 %second, label %right, label %third
left:
  %lx = fmul double %x, 1.0
  br i1 %alt, label %la, label %lb
la:
  %lva = fmul double %lx, 2.0
  br label %lt
lb:
  %lvb = fsub double %lx, 3.0
  br label %lt
lt:
  %lv = phi double [ %lva, %la ], [ %lvb, %lb ]
  %lp = load double, double* %p
  %lo = fadd double %lv, %lp
  br label %shared
right:
  %rx = fmul double %x, -1.0
  br i1 %alt, label %ra, label %rb
ra:
  %rva = fmul double %rx, -2.0
  br label %rt
rb:
  %rvb = fsub double %rx, 5.0
  br label %rt
rt:
  %rv = phi double [ %rva, %ra ], [ %rvb, %rb ]
  %rp = load double, double* %q
  %ro = fadd double %rv, %rp
  br label %shared
third:
  br label %exit
shared:
  %v = phi double [ %lo, %lt ], [ %ro, %rt ]
  br label %exit
exit:
  %result = phi double [ %v, %shared ], [ -0.0, %third ]
  ret double %result
}
