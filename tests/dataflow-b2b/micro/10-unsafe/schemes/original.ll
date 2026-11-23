target triple = "amdgcn-amd-amdhsa"

define void @micro(i1 zeroext %C, i32 %x, i32 %d, i32* %p, i32 %r0, i32 %r1, i32* %out) {
entry:
  br i1 %C, label %left, label %join

left:
  %div = sdiv i32 %x, %d
  %loaded = load i32, i32* %p, align 4
  br label %join

join:
  %result0 = phi i32 [ %div, %left ], [ %r0, %entry ]
  %result1 = phi i32 [ %loaded, %left ], [ %r1, %entry ]
  %slot0 = getelementptr i32, i32* %out, i64 0
  store i32 %result0, i32* %slot0
  %slot1 = getelementptr i32, i32* %out, i64 1
  store i32 %result1, i32* %slot1
  ret void
}
