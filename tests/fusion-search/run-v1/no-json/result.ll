; ModuleID = '/home/chh/kernel-benchmark-suite/tests/fusion-search/run-v1/chain-before.ll'
source_filename = "<string>"

; Function Attrs: norecurse nounwind readnone
define i32 @choose(i32 %x, i32 %side, i32 %inner) local_unnamed_addr #0 {
entry:
  %c.not = icmp eq i32 %side, 0
  %merged.select = select i1 %c.not, i32 2000, i32 1000
  %0 = sdiv i32 %merged.select, %x
  %1 = mul nsw i32 %0, 3
  %2 = add nsw i32 %0, 7
  %v = select i1 %c.not, i32 %1, i32 %2
  %d.not = icmp eq i32 %inner, 0
  %merged.select1 = select i1 %d.not, i32 4000, i32 3000
  %3 = sdiv i32 %merged.select1, %v
  %4 = mul nsw i32 %3, 5
  %5 = add nsw i32 %3, 11
  %z = select i1 %d.not, i32 %4, i32 %5
  ret i32 %z
}

attributes #0 = { norecurse nounwind readnone }
