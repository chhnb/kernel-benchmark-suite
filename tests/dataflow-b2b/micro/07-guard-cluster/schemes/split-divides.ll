target triple = "amdgcn-amd-amdhsa"

define void @micro(i1 zeroext %C, i32 %x, i32 %y, i32 %d0, i32 %d1, i32 %k, i32 %r0, i32 %r1, i32* %out) {
entry:
  br i1 %C, label %first, label %shared
first:
  %a = sdiv i32 %x, %d0
  br label %shared
shared:
  %result0 = phi i32 [ %a, %first ], [ %r0, %entry ]
  %result1 = mul i32 %x, %k
  br i1 %C, label %second, label %join
second:
  %b = sdiv i32 %y, %d1
  br label %join
join:
  %result2 = phi i32 [ %b, %second ], [ %r1, %shared ]
  %slot0 = getelementptr i32, i32* %out, i64 0
  store i32 %result0, i32* %slot0
  %slot1 = getelementptr i32, i32* %out, i64 1
  store i32 %result1, i32* %slot1
  %slot2 = getelementptr i32, i32* %out, i64 2
  store i32 %result2, i32* %slot2
  ret void
}
