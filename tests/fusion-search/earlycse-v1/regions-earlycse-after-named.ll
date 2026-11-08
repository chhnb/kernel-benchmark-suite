; ModuleID = '<string>'
source_filename = "<string>"

define i32 @after(i32 %x, i32 %side, i32 %inner) {
entry:
  %c = icmp ne i32 %side, 0
  %d = icmp ne i32 %inner, 0
  br i1 %d, label %merged.bb, label %merged.bb5

merged.bb:                                        ; preds = %entry
  %0 = add i32 %x, 7
  %1 = sub i32 %x, 5
  br label %merged.bb4

merged.bb4:                                       ; preds = %merged.bb, %merged.bb5
  %2 = phi i32 [ %4, %merged.bb5 ], [ %0, %merged.bb ]
  %3 = phi i32 [ %4, %merged.bb5 ], [ %1, %merged.bb ]
  %z = select i1 %c, i32 %2, i32 %3
  ret i32 %z

merged.bb5:                                       ; preds = %entry
  %merged.select = select i1 %c, i32 3, i32 2
  %4 = mul i32 %x, %merged.select
  br label %merged.bb4
}
