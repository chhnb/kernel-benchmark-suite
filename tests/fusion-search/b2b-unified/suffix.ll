target triple = "amdgcn-amd-amdhsa"

define i32 @choose(i1 %p, i32 %x, i32 %y, i32* %mem) #0 {
entry:
  br i1 %p, label %left, label %right
left:
  %a = load i32, i32* %mem, align 4
  %b = mul i32 %a, %y
  %l = mul i32 %b, %x
  br label %join
right:
  %c = xor i32 %x, 17
  %d = mul i32 %c, %y
  %r = mul i32 %d, %x
  br label %join
join:
  %v = phi i32 [ %l, %left ], [ %r, %right ]
  %answer = add i32 %v, 23
  ret i32 %answer
}

attributes #0 = { "target-cpu"="gfx906" }
