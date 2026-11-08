; ModuleID = '/home/chh/kernel-benchmark-suite/tests/fusion-search/darm-cleanup-v1/chain-before.ll'
source_filename = "<string>"

define i32 @choose(i32 %x, i32 %side, i32 %inner) {
entry:
  %c = icmp ne i32 %side, 0
  %merged.select = select i1 %c, i32 1000, i32 2000
  %0 = sdiv i32 %merged.select, %x
  %1 = add i32 %0, 7
  %2 = select i1 %c, i32 %1, i32 undef
  %3 = mul i32 %0, 3
  %4 = select i1 %c, i32 undef, i32 %3
  %v = select i1 %c, i32 %2, i32 %4
  %d = icmp ne i32 %inner, 0
  %merged.select1 = select i1 %d, i32 3000, i32 4000
  %5 = sdiv i32 %merged.select1, %v
  %6 = add i32 %5, 11
  %7 = select i1 %d, i32 %6, i32 undef
  %8 = mul i32 %5, 5
  %9 = select i1 %d, i32 undef, i32 %8
  %z = select i1 %d, i32 %7, i32 %9
  ret i32 %z
}
