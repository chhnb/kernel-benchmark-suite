define i32 @before(i32 %x, i32 %side, i32 %inner) {
entry:
 %c = icmp ne i32 %side, 0
 %d = icmp ne i32 %inner, 0
 br i1 %c, label %left, label %right
left:
 br i1 %d, label %l0, label %l1
l0:
 %a = add i32 %x, 7
 br label %lj
l1:
 %b = mul i32 %x, 3
 br label %lj
lj:
 %lv = phi i32 [%a, %l0], [%b, %l1]
 br label %join
right:
 br i1 %d, label %r0, label %r1
r0:
 %u = sub i32 %x, 5
 br label %rj
r1:
 %v = mul i32 %x, 2
 br label %rj
rj:
 %rv = phi i32 [%u, %r0], [%v, %r1]
 br label %join
join:
 %z = phi i32 [%lv, %lj], [%rv, %rj]
 ret i32 %z
}
