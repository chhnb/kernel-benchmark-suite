target triple = "amdgcn-amd-amdhsa"

define i32 @diamond(i1 %c, i32 %a, i32 %b, i32 %x, i32 %y) #0 {
entry:
  br i1 %c, label %left, label %right
left:
  %lp = add i32 %a, 5
  %lu = mul i32 %lp, %x
  %lq = sub i32 %b, 7
  %lv = xor i32 %lq, %y
  br label %join
right:
  %rq = sub i32 %a, 7
  %rv = xor i32 %rq, %y
  %rp = add i32 %b, 5
  %ru = mul i32 %rp, %x
  br label %join
join:
  %u = phi i32 [ %lu, %left ], [ %ru, %right ]
  %v = phi i32 [ %lv, %left ], [ %rv, %right ]
  %out = add i32 %u, %v
  ret i32 %out
}
attributes #0 = { "target-cpu"="gfx906" }
