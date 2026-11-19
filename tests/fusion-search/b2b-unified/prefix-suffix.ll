target triple = "amdgcn-amd-amdhsa"

define i32 @choose(i1 %p, i32 %x, i32 %y, i32* %mem) #0 {
entry:
  br i1 %p, label %left, label %right
left:
  %lp = mul i32 %x, %y
  store i32 %lp, i32* %mem, align 4
  %a = add i32 %lp, 7
  %l = mul i32 %a, %y
  br label %join
right:
  %rp = mul i32 %x, %y
  %b = load i32, i32* %mem, align 4
  %c = xor i32 %b, %rp
  %r = mul i32 %c, %y
  br label %join
join:
  %v = phi i32 [ %l, %left ], [ %r, %right ]
  %answer = add i32 %v, 23
  ret i32 %answer
}

attributes #0 = { "target-cpu"="gfx906" }
