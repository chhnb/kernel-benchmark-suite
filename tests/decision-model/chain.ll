define i32 @case(i32 %x) {
entry:
  %c0 = icmp slt i32 %x, 0
  br i1 %c0, label %a, label %test1
test1:
  %c1 = icmp slt i32 %x, 5
  br i1 %c1, label %b, label %test2
test2:
  %c2 = icmp slt i32 %x, 12
  br i1 %c2, label %c, label %d
a:
  %av = add i32 %x, 100
  br label %join
b:
  %bv = mul i32 %x, 7
  br label %join
c:
  %cv = sub i32 %x, 21
  br label %join
d:
  %dv = add i32 %x, 9
  br label %join
join:
  %v = phi i32 [%av,%a], [%bv,%b], [%cv,%c], [%dv,%d]
  ret i32 %v
}
