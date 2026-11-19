target triple = "amdgcn-amd-amdhsa"

define i32 @diamond(i1 %c, i32 %a, i32 %b, i32 %x, i32 %y) #0 {
entry:
  br i1 %c, label %left, label %right
left:
  %lp = add i32 %a, 5
  %lu = mul i32 %lp, %x
  %lv = xor i32 %lp, %y
  br label %join
right:
  %rp = add i32 %b, 5
  %ru = mul i32 %rp, %x
  %rv = xor i32 %rp, %y
  br label %join
join:
  %u = phi i32 [ %lu, %left ], [ %ru, %right ]
  %v = phi i32 [ %lv, %left ], [ %rv, %right ]
  %out = add i32 %u, %v
  ret i32 %out
}
attributes #0 = { "target-cpu"="gfx906" }
