; ModuleID = '<string>'
source_filename = "<string>"

; Function Attrs: norecurse nounwind readnone
define i32 @choose(i32 %x, i32 %side, i32 %inner) local_unnamed_addr #0 {
entry:
  %c.not = icmp eq i32 %side, 0
  %d.not = icmp eq i32 %inner, 0
  %merged.select = select i1 %c.not, i32 2, i32 3
  %0 = mul i32 %merged.select, %x
  %1 = add i32 %x, 7
  %2 = add i32 %x, -5
  %3 = select i1 %d.not, i32 %0, i32 %1
  %4 = select i1 %d.not, i32 %0, i32 %2
  %z = select i1 %c.not, i32 %4, i32 %3
  ret i32 %z
}

attributes #0 = { norecurse nounwind readnone }
