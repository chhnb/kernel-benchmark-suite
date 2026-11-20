source_filename = "HLLD.ll"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

define void @HLLD(i1 %cond, double %i356, double %i229, double %i28, double %i232, double %i316, double %i235, double %i302, double %i40, double %i238, double %i323, double %i591, double %i46, double %i241, double %i324, double %i592, double %i52, double %i256, double %i337, double %i595, double %i57, double %i244, double %i325, double %i593, double %i62, double %i247, double %i326, double %i594, double addrspace(1)* %arg3, i64 %i23, i64 %i31, i64 %i37, i64 %i43, i64 %i49, i64 %i55, i64 %i60, double %i446, double %i231, double %i85, double %i258, double %i377, double %i261, double %i91, double %i264, double %i416, double %i94, double %i267, double %i417, double %i97, double %i282, double %i428, double %i596, double %i99, double %i270, double %i418, double %i101, double %i273, double %i419) #0 {
entry:
  br i1 %cond, label %left, label %right

left:                                             ; preds = %entry
  %i603 = fsub double %i356, %i229
  %i604 = fmul double %i28, %i229
  %i605 = fsub double %i232, %i604
  %i606 = fmul double %i316, %i603
  %i607 = fsub double %i605, %i606
  %i608 = fmul double %i316, %i356
  %i609 = fadd double %i608, %i607
  %i610 = fmul double %i232, %i229
  %i611 = fsub double %i235, %i610
  %i612 = fmul double %i302, %i316
  %i613 = fmul double %i612, %i603
  %i614 = fsub double %i611, %i613
  %i615 = fmul double %i612, %i356
  %i616 = fadd double %i615, %i614
  %i617 = fmul double %i28, %i40
  %i618 = fmul double %i617, %i229
  %i619 = fsub double %i238, %i618
  %i620 = fmul double %i316, %i323
  %i621 = fmul double %i603, %i620
  %i622 = fsub double %i619, %i621
  %i623 = fmul double %i316, %i591
  %i624 = fmul double %i356, %i623
  %i625 = fadd double %i622, %i624
  %i626 = fmul double %i28, %i46
  %i627 = fmul double %i626, %i229
  %i628 = fsub double %i241, %i627
  %i629 = fmul double %i316, %i324
  %i630 = fmul double %i603, %i629
  %i631 = fsub double %i628, %i630
  %i632 = fmul double %i316, %i592
  %i633 = fmul double %i356, %i632
  %i634 = fadd double %i631, %i633
  %i635 = fmul double %i52, %i229
  %i636 = fsub double %i256, %i635
  %i637 = fmul double %i603, %i337
  %i638 = fsub double %i636, %i637
  %i639 = fmul double %i356, %i595
  %i640 = fadd double %i638, %i639
  %i641 = fmul double %i57, %i229
  %i642 = fsub double %i244, %i641
  %i643 = fmul double %i603, %i325
  %i644 = fsub double %i642, %i643
  %i645 = fmul double %i356, %i593
  %i646 = fadd double %i644, %i645
  %i647 = fmul double %i62, %i229
  %i648 = fsub double %i247, %i647
  %i649 = fmul double %i603, %i326
  %i650 = fsub double %i648, %i649
  %i651 = fmul double %i356, %i594
  %i652 = fadd double %i650, %i651
  %i653 = getelementptr inbounds double, double addrspace(1)* %arg3, i64 %i23
  store double %i609, double addrspace(1)* %i653, align 8, !tbaa !5
  %i654 = getelementptr inbounds double, double addrspace(1)* %arg3, i64 %i31
  store double %i616, double addrspace(1)* %i654, align 8, !tbaa !5
  %i655 = getelementptr inbounds double, double addrspace(1)* %arg3, i64 %i37
  store double %i625, double addrspace(1)* %i655, align 8, !tbaa !5
  %i656 = getelementptr inbounds double, double addrspace(1)* %arg3, i64 %i43
  store double %i634, double addrspace(1)* %i656, align 8, !tbaa !5
  %i657 = getelementptr inbounds double, double addrspace(1)* %arg3, i64 %i49
  store double %i640, double addrspace(1)* %i657, align 8, !tbaa !5
  %i658 = getelementptr inbounds double, double addrspace(1)* %arg3, i64 %i55
  store double %i646, double addrspace(1)* %i658, align 8, !tbaa !5
  %i659 = getelementptr inbounds double, double addrspace(1)* %arg3, i64 %i60
  store double %i652, double addrspace(1)* %i659, align 8, !tbaa !5
  br label %join

right:                                            ; preds = %entry
  %i660 = fsub double %i446, %i231
  %i661 = fmul double %i85, %i231
  %i662 = fsub double %i258, %i661
  %i663 = fmul double %i377, %i660
  %i664 = fsub double %i662, %i663
  %i665 = fmul double %i377, %i446
  %i666 = fadd double %i665, %i664
  %i667 = fmul double %i258, %i231
  %i668 = fsub double %i261, %i667
  %i669 = fmul double %i302, %i377
  %i670 = fmul double %i669, %i660
  %i671 = fsub double %i668, %i670
  %i672 = fmul double %i669, %i446
  %i673 = fadd double %i672, %i671
  %i674 = fmul double %i85, %i91
  %i675 = fmul double %i674, %i231
  %i676 = fsub double %i264, %i675
  %i677 = fmul double %i377, %i416
  %i678 = fmul double %i660, %i677
  %i679 = fsub double %i676, %i678
  %i680 = fmul double %i377, %i591
  %i681 = fmul double %i446, %i680
  %i682 = fadd double %i679, %i681
  %i683 = fmul double %i85, %i94
  %i684 = fmul double %i683, %i231
  %i685 = fsub double %i267, %i684
  %i686 = fmul double %i377, %i417
  %i687 = fmul double %i660, %i686
  %i688 = fsub double %i685, %i687
  %i689 = fmul double %i377, %i592
  %i690 = fmul double %i446, %i689
  %i691 = fadd double %i688, %i690
  %i692 = fmul double %i97, %i231
  %i693 = fsub double %i282, %i692
  %i694 = fmul double %i660, %i428
  %i695 = fsub double %i693, %i694
  %i696 = fmul double %i446, %i596
  %i697 = fadd double %i695, %i696
  %i698 = fmul double %i99, %i231
  %i699 = fsub double %i270, %i698
  %i700 = fmul double %i660, %i418
  %i701 = fsub double %i699, %i700
  %i702 = fmul double %i446, %i593
  %i703 = fadd double %i701, %i702
  %i704 = fmul double %i101, %i231
  %i705 = fsub double %i273, %i704
  %i706 = fmul double %i660, %i419
  %i707 = fsub double %i705, %i706
  %i708 = fmul double %i446, %i594
  %i709 = fadd double %i707, %i708
  %i710 = getelementptr inbounds double, double addrspace(1)* %arg3, i64 %i23
  store double %i666, double addrspace(1)* %i710, align 8, !tbaa !5
  %i711 = getelementptr inbounds double, double addrspace(1)* %arg3, i64 %i31
  store double %i673, double addrspace(1)* %i711, align 8, !tbaa !5
  %i712 = getelementptr inbounds double, double addrspace(1)* %arg3, i64 %i37
  store double %i682, double addrspace(1)* %i712, align 8, !tbaa !5
  %i713 = getelementptr inbounds double, double addrspace(1)* %arg3, i64 %i43
  store double %i691, double addrspace(1)* %i713, align 8, !tbaa !5
  %i714 = getelementptr inbounds double, double addrspace(1)* %arg3, i64 %i49
  store double %i697, double addrspace(1)* %i714, align 8, !tbaa !5
  %i715 = getelementptr inbounds double, double addrspace(1)* %arg3, i64 %i55
  store double %i703, double addrspace(1)* %i715, align 8, !tbaa !5
  %i716 = getelementptr inbounds double, double addrspace(1)* %arg3, i64 %i60
  store double %i709, double addrspace(1)* %i716, align 8, !tbaa !5
  br label %join

join:                                             ; preds = %right, %left
  ret void
}

attributes #0 = { "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" }

!llvm.module.flags = !{!0, !1}
!opencl.ocl.version = !{!2}
!llvm.ident = !{!3, !4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 1}
!2 = !{i32 2, i32 0}
!3 = !{!"Ubuntu clang version 12.0.1-19ubuntu3"}
!4 = !{!"clang version 12.0.0 (/src/external/llvm-project/clang dac2bfceaa8d4a90257dc8a6d58f268e172ce00e)"}
!5 = !{!6, !6, i64 0}
!6 = !{!"double", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C++ TBAA"}
