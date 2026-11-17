target triple = "amdgcn-amd-amdhsa"
define i32 @choose(i1 %side, i1 %test, i32 %x) #0 {
entry:
  br i1 %side, label %left, label %right
left:
  br i1 %test, label %left.work, label %left.exit
left.work:
  %a = mul i32 %x, 7
  br label %left.exit
left.exit:
  %l = phi i32 [ %x, %left ], [ %a, %left.work ]
  %lv = add i32 %l, 1
  br label %join
right:
  br i1 %test, label %right.work, label %right.exit
right.work:
  %b = mul i32 %x, 11
  br label %right.exit
right.exit:
  %r = phi i32 [ %x, %right ], [ %b, %right.work ]
  %rv = sub i32 %r, 2
  br label %join
join:
  %result = phi i32 [ %lv, %left.exit ], [ %rv, %right.exit ]
  ret i32 %result
}
attributes #0 = { "target-cpu"="gfx906" }
