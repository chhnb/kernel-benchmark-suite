; ModuleID = '/home/chh/kernel-benchmark-suite/tests/fusion-search/run-v1/chain-before.ll'
source_filename = "<string>"

; Function Attrs: norecurse nounwind readnone
define i32 @choose(i32 %x, i32 %side, i32 %inner) local_unnamed_addr #0 {
entry:
  %c.not = icmp eq i32 %side, 0
  br i1 %c.not, label %right, label %left

left:                                             ; preds = %entry
  %a = sdiv i32 1000, %x
  %aa = add nsw i32 %a, 7
  br label %join

right:                                            ; preds = %entry
  %b = sdiv i32 2000, %x
  %bb = mul nsw i32 %b, 3
  br label %join

join:                                             ; preds = %right, %left
  %v = phi i32 [ %aa, %left ], [ %bb, %right ]
  %d.not = icmp eq i32 %inner, 0
  %merged.select = select i1 %d.not, i32 4000, i32 3000
  %0 = sdiv i32 %merged.select, %v
  %1 = mul nsw i32 %0, 5
  %2 = add nsw i32 %0, 11
  %z = select i1 %d.not, i32 %1, i32 %2
  ret i32 %z
}

attributes #0 = { norecurse nounwind readnone }
