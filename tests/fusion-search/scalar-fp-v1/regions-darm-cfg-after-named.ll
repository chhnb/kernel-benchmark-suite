; ModuleID = '<string>'
source_filename = "<string>"

define i32 @after(i32 %x, i32 %side, i32 %inner) {
entry:
  %c = icmp ne i32 %side, 0
  %d = icmp ne i32 %inner, 0
  br i1 %d, label %merged.bb5, label %merged.bb4

merged.bb:                                        ; preds = %merged.bb5, %merged.bb4
  %0 = phi i32 [ %2, %merged.bb4 ], [ %4, %merged.bb5 ]
  %1 = phi i32 [ %2, %merged.bb4 ], [ %6, %merged.bb5 ]
  %z = select i1 %c, i32 %0, i32 %1
  ret i32 %z

merged.bb4:                                       ; preds = %entry
  %merged.select = select i1 %c, i32 3, i32 2
  %2 = mul i32 %x, %merged.select
  br label %merged.bb

merged.bb5:                                       ; preds = %entry
  %3 = add i32 %x, 7
  %4 = select i1 %c, i32 %3, i32 undef
  %5 = sub i32 %x, 5
  %6 = select i1 %c, i32 undef, i32 %5
  br label %merged.bb
}
