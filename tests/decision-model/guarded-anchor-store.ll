define i32 @choose(i1 %side, i1 %test, i32 %x) {
entry:
  %scratch = alloca i32, align 4
  store i32 23, i32* %scratch
  br i1 %side, label %short, label %long
short:
  %a = mul i32 %x, 7
  br label %join
long:
  store i32 %x, i32* %scratch
  br i1 %test, label %adjust, label %tail
adjust:
  %incremented = add i32 %x, 3
  store i32 %incremented, i32* %scratch
  br label %tail
tail:
  %y = phi i32 [ %x, %long ], [ %incremented, %adjust ]
  %b = mul i32 %y, 11
  br label %join
join:
  %result = phi i32 [ %a, %short ], [ %b, %tail ]
  %memory = load i32, i32* %scratch
  %sum = add i32 %result, %memory
  ret i32 %sum
}
