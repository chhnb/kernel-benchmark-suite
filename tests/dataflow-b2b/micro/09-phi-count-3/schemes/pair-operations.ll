target triple = "amdgcn-amd-amdhsa"

define void @micro(i1 zeroext %C, i32 %x, i32 %y, i32 %k, i32* %out) {
entry:
  %value = select i1 %C, i32 %x, i32 %y
  %result0 = add i32 %value, %k
  %result1 = sub i32 %value, %k
  %result2 = xor i32 %value, %k
  %slot0 = getelementptr i32, i32* %out, i64 0
  store i32 %result0, i32* %slot0
  %slot1 = getelementptr i32, i32* %out, i64 1
  store i32 %result1, i32* %slot1
  %slot2 = getelementptr i32, i32* %out, i64 2
  store i32 %result2, i32* %slot2
  ret void
}
