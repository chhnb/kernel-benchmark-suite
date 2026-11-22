define i32 @auto_guard_reference(i1 %cond, i32* %p, i32 %x) {
entry:
  br i1 %cond, label %left, label %right
left:
  store i32 21, i32* %p
  %lread = load i32, i32* %p
  %lvalue = add i32 %lread, %x
  %lpaired = load i32, i32* %p
  %extra = mul i32 %x, 3
  store i32 %lvalue, i32* %p
  %ldone = add i32 %lpaired, %extra
  store i32 %ldone, i32* %p
  br label %join
right:
  store i32 27, i32* %p
  %rread = load i32, i32* %p
  %rvalue = sub i32 %rread, %x
  %rpaired = load i32, i32* %p
  store i32 %rvalue, i32* %p
  br label %join
join:
  %result = phi i32 [ %ldone, %left ], [ %rpaired, %right ]
  ret i32 %result
}
