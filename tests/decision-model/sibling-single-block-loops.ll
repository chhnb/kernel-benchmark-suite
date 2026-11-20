define i32 @choose(i1 %side, i32 %n, i32 %x) {
entry:
  br i1 %side, label %left, label %right
left:
  %i = phi i32 [ 0, %entry ], [ %i.next, %left ]
  %a = phi i32 [ %x, %entry ], [ %a.next, %left ]
  %a.next = add i32 %a, 7
  %i.next = add i32 %i, 1
  %left.more = icmp slt i32 %i.next, %n
  br i1 %left.more, label %left, label %join
right:
  %j = phi i32 [ 0, %entry ], [ %j.next, %right ]
  %b = phi i32 [ %x, %entry ], [ %b.next, %right ]
  %b.next = add i32 %b, 11
  %j.next = add i32 %j, 2
  %right.more = icmp slt i32 %j.next, %n
  br i1 %right.more, label %right, label %join
join:
  %result = phi i32 [ %a.next, %left ], [ %b.next, %right ]
  ret i32 %result
}
