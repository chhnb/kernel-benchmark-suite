target triple = "x86_64-pc-linux-gnu"
define i32 @choose(i1 %outside, i8* %mask, i32* %data) {
entry:
 br i1 %outside, label %left, label %right
left:
 %a = load i32, i32* %data
 br label %join
right:
 %m = load i8, i8* %mask
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
