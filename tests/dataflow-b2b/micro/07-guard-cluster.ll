target triple = "amdgcn-amd-amdhsa"

define void @micro(i1 zeroext %C, i32 %x, i32 %y, i32 %d0, i32 %d1, i32 %k, i32 %r0, i32 %r1, i32* %out) {
entry:
  br i1 %C, label %left, label %right

left:
  %ld0 = sdiv i32 %x, %d0
  %lm = mul i32 %x, %k
  %ld1 = sdiv i32 %y, %d1
  br label %join

right:
  %rm = mul i32 %x, %k
  br label %join

join:
  %result0 = phi i32 [ %ld0, %left ], [ %r0, %right ]
  %result1 = phi i32 [ %lm, %left ], [ %rm, %right ]
  %result2 = phi i32 [ %ld1, %left ], [ %r1, %right ]
  %slot0 = getelementptr i32, i32* %out, i64 0
  store i32 %result0, i32* %slot0
  %slot1 = getelementptr i32, i32* %out, i64 1
  store i32 %result1, i32* %slot1
  %slot2 = getelementptr i32, i32* %out, i64 2
  store i32 %result2, i32* %slot2
  ret void
}
