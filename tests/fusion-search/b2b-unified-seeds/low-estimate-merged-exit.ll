; Five matched operations require six distinct operand selects before cleanup.
target triple = "amdgcn-amd-amdhsa"

define i32 @choose(i1 %p, i32 %x, i32 %y, i32* %ptr) #0 {
entry:
  br i1 %p, label %left, label %right
left:
  %l0 = mul i32 %x, 3
  %l1 = xor i32 %x, 4
  %l2 = add i32 %x, 5
  %l3 = sub i32 %x, 6
  %l4 = or i32 %x, 7
  br label %join
right:
  %r0 = mul i32 %y, 9
  %r1 = xor i32 %y, 10
  %r2 = add i32 %y, 11
  %r3 = sub i32 %y, 12
  %r4 = or i32 %y, 13
  br label %join
join:
  %v0 = phi i32 [ %l0, %left ], [ %r0, %right ]
  %v1 = phi i32 [ %l1, %left ], [ %r1, %right ]
  %v2 = phi i32 [ %l2, %left ], [ %r2, %right ]
  %v3 = phi i32 [ %l3, %left ], [ %r3, %right ]
  %v4 = phi i32 [ %l4, %left ], [ %r4, %right ]
  %out0 = getelementptr i32, i32* %ptr, i32 0
  store i32 %v0, i32* %out0, align 4
  %out1 = getelementptr i32, i32* %ptr, i32 1
  store i32 %v1, i32* %out1, align 4
  %out2 = getelementptr i32, i32* %ptr, i32 2
  store i32 %v2, i32* %out2, align 4
  %out3 = getelementptr i32, i32* %ptr, i32 3
  store i32 %v3, i32* %out3, align 4
  %out4 = getelementptr i32, i32* %ptr, i32 4
  store i32 %v4, i32* %out4, align 4
  ret i32 %v0
}
attributes #0 = { "target-cpu"="gfx906" }
