target triple = "amdgcn-amd-amdhsa"
define i32 @f(i1 %p,i1 %q,i32 %x,i32 %y) #0 {
entry: br i1 %p, label %L, label %R
L:
  %l0 = mul i32 %x, 3
  %l1 = mul i32 %l0, 5
  %l2 = mul i32 %l1, 3
  %l3 = mul i32 %l2, 5
  %l4 = mul i32 %l3, 3
  %l5 = mul i32 %l4, 5
  %l6 = mul i32 %l5, 3
  %l7 = mul i32 %l6, 5
  %l8 = mul i32 %l7, 3
  %l9 = mul i32 %l8, 5
  br label %bridge
R:
  %r0 = mul i32 %y, 3
  %r1 = mul i32 %r0, 5
  %r2 = mul i32 %r1, 3
  %r3 = mul i32 %r2, 5
  %r4 = mul i32 %r3, 3
  %r5 = mul i32 %r4, 5
  %r6 = mul i32 %r5, 3
  %r7 = mul i32 %r6, 5
  %r8 = mul i32 %r7, 3
  %r9 = mul i32 %r8, 5
  br label %B
bridge:
  %lv = add i32 %l9, 1
  br label %B
B:
  %v = phi i32 [ %lv, %bridge ], [ %r9, %R ]
  br i1 %q, label %BL, label %BR
BL:
  %a = add i32 %v, 1
  %aa = mul i32 %a, 3
  br label %out
BR:
  %b = add i32 %v, 2
  %bb = mul i32 %b, 3
  br label %out
out:
  %w = phi i32 [ %aa, %BL ], [ %bb, %BR ]
  ret i32 %w
}
attributes #0 = { "target-cpu"="gfx906" }
