target triple = "amdgcn-amd-amdhsa"

define i32 @choose(i1 %p, i32 %x, i32 %y, i32* %mem) #0 {
entry:
  br i1 %p, label %left, label %right
left:
  %l = mul i32 %x, %y
  br label %join
right:
  %r = mul i32 %y, %x
  br label %join
join:
  %v = phi i32 [ %l, %left ], [ %r, %right ]
  %answer = add i32 %v, 23
  ret i32 %answer
}

attributes #0 = { "target-cpu"="gfx906" }
