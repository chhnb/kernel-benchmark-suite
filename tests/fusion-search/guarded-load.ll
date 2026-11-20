target triple = "x86_64-pc-linux-gnu"
define i32 @choose(i1 %outside, i8* %mask, i32* %data, i8* %written) {
entry:
 br i1 %outside, label %left, label %right
left:
 %a = load i32, i32* %data
 br label %join
right:
 %m = load i8, i8* %mask
 store i8 %m, i8* %written
 %c = icmp eq i8 %m, 0
 br i1 %c, label %normal, label %special
normal:
 %b = load i32, i32* %data
 br label %join
special:
 %s = load i32, i32* %data
 %v = sub i32 0, %s
 br label %join
join:
 %result = phi i32 [%a,%left], [%b,%normal], [%v,%special]
 ret i32 %result
}

define i32 @choose_boundary(i1 %region, i32 %x, i8* %mask, i32* %left, i32* %right) #0 {
entry:
  br i1 %region, label %long, label %short
long:
  %at.edge = icmp sge i32 %x, 4
  br i1 %at.edge, label %edge, label %masked
edge:
  %edge.ptr = getelementptr inbounds i32, i32* %left, i64 3
  %edge.val = load i32, i32* %edge.ptr, align 4
  br label %join
masked:
  %idx = sext i32 %x to i64
  %mask.ptr = getelementptr inbounds i8, i8* %mask, i64 %idx
  %m = load i8, i8* %mask.ptr, align 1
  %masked.out = icmp ne i8 %m, 0
  br i1 %masked.out, label %detour, label %normal
normal:
  %normal.ptr = getelementptr inbounds i32, i32* %left, i64 %idx
  %normal.val = load i32, i32* %normal.ptr, align 4
  br label %join
detour:
  %detour.val = load i32, i32* %left, align 4
  br label %join
short:
  %next = add i32 %x, 1
  %short.idx = sext i32 %next to i64
  %short.ptr = getelementptr inbounds i32, i32* %right, i64 %short.idx
  %short.val = load i32, i32* %short.ptr, align 4
  br label %join
join:
  %res = phi i32 [%edge.val, %edge], [%normal.val, %normal], [%detour.val, %detour], [%short.val, %short]
  ret i32 %res
}

attributes #0 = { "target-cpu"="x86-64" }
