; The dead multiplies occupy the four reverse-DP positions. The live trailing multiply still makes an optimal greedy suffix.
target triple = "amdgcn-amd-amdhsa"

define i32 @choose(i1 %p, i32 %x, i32 %y, i32* %ptr) #0 {
entry:
  br i1 %p, label %left, label %right
left:
  %a = load i32, i32* %ptr, align 4
  %ld0 = mul i32 %x, 11
  %ld1 = mul i32 %x, 12
  %ld2 = mul i32 %x, 13
  %ld3 = mul i32 %x, 14
  %ld4 = mul i32 %x, 15
  %lv = add i32 %a, 5
  %l = mul i32 %lv, %y
  br label %join
right:
  %b = or i32 %x, 11
  %rd0 = mul i32 %x, 11
  %rd1 = mul i32 %x, 12
  %rd2 = mul i32 %x, 13
  %rd3 = mul i32 %x, 14
  %rd4 = mul i32 %x, 15
  %rv = sub i32 %b, 7
  %r = mul i32 %rv, %y
  br label %join
join:
  %result = phi i32 [ %l, %left ], [ %r, %right ]
  ret i32 %result
}
attributes #0 = { "target-cpu"="gfx906" }
