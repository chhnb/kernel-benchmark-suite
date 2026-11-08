; ModuleID = '<string>'
source_filename = "<string>"

define i32 @choose(i32 %x, i32 %side, i32 %inner) {
entry:
  %c = icmp ne i32 %side, 0
  %0 = add i32 %x, 7
  %1 = select i1 %c, i32 %0, i32 undef
  %2 = mul i32 %x, 3
  %3 = select i1 %c, i32 undef, i32 %2
  %v = select i1 %c, i32 %1, i32 %3
  ret i32 %v
}
