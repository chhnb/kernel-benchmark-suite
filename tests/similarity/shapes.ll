; Two independent first-match cascades followed by a switch and a loop.
define i32 @multiple_choices(i32 %x, i32 %y) {
entry:
  %c0 = icmp slt i32 %x, 0
  br i1 %c0, label %a0, label %test1
test1:
  %c1 = icmp slt i32 %x, 10
  br i1 %c1, label %a1, label %a2
a0:
  br label %join1
a1:
  br label %join1
a2:
  br label %join1
join1:
  %a = phi i32 [0, %a0], [1, %a1], [2, %a2]
  %d0 = icmp slt i32 %y, 0
  br i1 %d0, label %b0, label %test2
test2:
  %d1 = icmp slt i32 %y, 10
  br i1 %d1, label %b1, label %b2
b0:
  br label %join2
b1:
  br label %join2
b2:
  br label %join2
join2:
  %b = phi i32 [3, %b0], [4, %b1], [5, %b2]
  switch i32 %x, label %sd [i32 0, label %s0 i32 1, label %s1]
sd:
  br label %loop
s0:
  br label %loop
s1:
  br label %loop
loop:
  %i = phi i32 [0, %sd], [0, %s0], [0, %s1], [%inc, %loop]
  %inc = add i32 %i, 1
  %more = icmp slt i32 %inc, 4
  br i1 %more, label %loop, label %exit
exit:
  %result = select i1 %c0, i32 %a, i32 %b
  ret i32 %result
}

define i32 @different_region_shapes(i1 %c, i32 %x) {
entry:
  br i1 %c, label %left, label %right
left:
  switch i32 %x, label %l0 [i32 1, label %l1]
l0:
  br label %lj
l1:
  br label %lj
lj:
  %lv = phi i32 [0, %l0], [1, %l1]
  br label %end
right:
  switch i32 %x, label %r0 [i32 1, label %r1 i32 2, label %r2]
r0:
  br label %rj
r1:
  br label %rj
r2:
  br label %rj
rj:
  %rv = phi i32 [0, %r0], [1, %r1], [2, %r2]
  br label %end
end:
  %v = phi i32 [%lv, %lj], [%rv, %rj]
  ret i32 %v
}

define i32 @loop_vs_plain(i1 %c, i1 %again) {
entry:
  br i1 %c, label %loop, label %plain
loop:
  br i1 %again, label %loop, label %join
plain:
  br label %join
join:
  ret i32 0
}

define i32 @shared_tail(i1 %c, i1 %a, i1 %b) {
entry:
  br i1 %c, label %left, label %right
left:
  br i1 %a, label %shared, label %lonly
right:
  br i1 %b, label %shared, label %ronly
shared:
  br label %end
lonly:
  br label %end
ronly:
  br label %end
end:
  ret i32 0
}
