; ModuleID = '<string>'
source_filename = "<string>"

; Function Attrs: norecurse nounwind readnone
define i32 @after(i32 %x, i32 %side, i32 %inner) local_unnamed_addr #0 {
entry:
  %c.not = icmp eq i32 %side, 0
  %0 = add i32 %x, 7
  %1 = mul i32 %x, 3
  %v = select i1 %c.not, i32 %1, i32 %0
  ret i32 %v
}

attributes #0 = { norecurse nounwind readnone }
