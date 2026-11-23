target triple = "amdgcn-amd-amdhsa"

define void @micro(i1 zeroext %C, i32 %x, i32 %y, i32 %k, i32 %u, i32 %v, i32* %out) {
entry:
  br i1 %C, label %left, label %right

left:
  %la = add i32 %x, %k
  %ls = sub i32 %x, %k
  %lx = xor i32 %x, %k
  br label %join

right:
  %ra = add i32 %y, %k
  %rs = sub i32 %y, %k
  %rx = xor i32 %y, %k
  br label %join

join:
  %result0 = phi i32 [ %la, %left ], [ %ra, %right ]
  %result1 = phi i32 [ %ls, %left ], [ %rs, %right ]
  %result2 = phi i32 [ %lx, %left ], [ %rx, %right ]
  %result3 = phi i32 [ %u, %left ], [ %v, %right ]
  %slot0 = getelementptr i32, i32* %out, i64 0
  store i32 %result0, i32* %slot0
  %slot1 = getelementptr i32, i32* %out, i64 1
  store i32 %result1, i32* %slot1
  %slot2 = getelementptr i32, i32* %out, i64 2
  store i32 %result2, i32* %slot2
  %slot3 = getelementptr i32, i32* %out, i64 3
  store i32 %result3, i32* %slot3
  ret void
}
