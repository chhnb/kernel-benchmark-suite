; ModuleID = '<string>'
source_filename = "<string>"

define i32 @after(i32 %x, i32 %side, i32 %inner) {
entry:
  %c.not = icmp eq i32 %side, 0
  %d.not = icmp eq i32 %inner, 0
  br i1 %d.not, label %merged.bb5, label %merged.bb4

merged.bb:                                        ; preds = %merged.bb4, %merged.bb5
  %0 = phi i32 [ %4, %merged.bb5 ], [ %2, %merged.bb4 ]
  %1 = phi i32 [ %4, %merged.bb5 ], [ %3, %merged.bb4 ]
  %z = select i1 %c.not, i32 %1, i32 %0
  ret i32 %z

merged.bb4:                                       ; preds = %entry
  %2 = add i32 %x, 7
  %3 = add i32 %x, -5
  br label %merged.bb

merged.bb5:                                       ; preds = %entry
  %merged.select = select i1 %c.not, i32 2, i32 3
  %4 = mul i32 %merged.select, %x
  br label %merged.bb
}
