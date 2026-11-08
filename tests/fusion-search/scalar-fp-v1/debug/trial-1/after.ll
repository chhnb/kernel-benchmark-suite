; ModuleID = '/home/chh/kernel-benchmark-suite/tests/fusion-search/scalar-fp-v1/chain-before.ll'
source_filename = "<string>"

define i32 @choose(i32 %x, i32 %side, i32 %inner) {
entry:
  %c = icmp ne i32 %side, 0
  br i1 %c, label %left, label %right

left:                                             ; preds = %entry
  %a = sdiv i32 1000, %x
  %aa = add i32 %a, 7
  br label %join

right:                                            ; preds = %entry
  %b = sdiv i32 2000, %x
  %bb = mul i32 %b, 3
  br label %join

join:                                             ; preds = %right, %left
  %v = phi i32 [ %aa, %left ], [ %bb, %right ]
  %d = icmp ne i32 %inner, 0
  %merged.select = select i1 %d, i32 3000, i32 4000
  %0 = sdiv i32 %merged.select, %v
  %1 = add i32 %0, 11
  %2 = mul i32 %0, 5
  %z = select i1 %d, i32 %1, i32 %2
  ret i32 %z
}
