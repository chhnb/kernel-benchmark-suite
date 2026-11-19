source_filename = "MapAiry10.ll"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.fabs.f64(double) #0

; Function Attrs: nounwind readnone speculatable willreturn
declare i32 @llvm.amdgcn.frexp.exp.i32.f64(double) #1

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.amdgcn.frexp.mant.f64(double) #1

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.amdgcn.ldexp.f64(double, i32) #1

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.amdgcn.rcp.f64(double) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.fma.f64(double, double, double) #0

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare <2 x double> @llvm.fma.v2f64(<2 x double>, <2 x double>, <2 x double>) #0

define double @MapAiry10(i1 %cond, double %arrayidx.val) #2 {
entry:
  br i1 %cond, label %left, label %right

left:                                             ; preds = %entry
  %sub13.i.i.i.i = fadd double %arrayidx.val, -1.250000e-01
  %mul.i.i270.i.i.i.i = fmul double %sub13.i.i.i.i, %sub13.i.i.i.i
  %mul1.i.i271.i.i.i.i = fmul double %mul.i.i270.i.i.i.i, 0x406D392CDE09E490
  %i634 = fsub double 0x408C7AAA9D225E9A, %mul1.i.i271.i.i.i.i
  %mul5.i.i273.i.i.i.i = fmul double %mul.i.i270.i.i.i.i, 0x408B6249334DA816
  %i635 = fsub double 0x408C1B9BAF952B96, %mul5.i.i273.i.i.i.i
  %mul10.i.i275.i.i.i.i = fmul double %mul.i.i270.i.i.i.i, %i634
  %mul12.i.i276.i.i.i.i = fmul double %mul.i.i270.i.i.i.i, %i635
  %add15.i.i277.i.i.i.i = fadd double %mul10.i.i275.i.i.i.i, 0xC05E9BCF5C362E51
  %add18.i.i278.i.i.i.i = fadd double %mul12.i.i276.i.i.i.i, 0xC066A4A24A4E1713
  %mul20.i.i279.i.i.i.i = fmul double %mul.i.i270.i.i.i.i, %add15.i.i277.i.i.i.i
  %mul22.i.i280.i.i.i.i = fmul double %mul.i.i270.i.i.i.i, %add18.i.i278.i.i.i.i
  %add25.i.i281.i.i.i.i = fadd double %mul20.i.i279.i.i.i.i, 0xC04249A2BD20D346
  %add28.i.i282.i.i.i.i = fadd double %mul22.i.i280.i.i.i.i, 0xC001804F92FE2A82
  %mul30.i.i283.i.i.i.i = fmul double %sub13.i.i.i.i, %add25.i.i281.i.i.i.i
  %add33.i.i284.i.i.i.i = fadd double %add28.i.i282.i.i.i.i, %mul30.i.i283.i.i.i.i
  %mul1.i.i256.i.i.i.i = fmul double %mul.i.i270.i.i.i.i, 0x405E5232607614DB
  %add.i.i257.i.i.i.i = fadd double %mul1.i.i256.i.i.i.i, 0xC0809E1D789AFFE5
  %mul5.i.i258.i.i.i.i = fmul double %mul.i.i270.i.i.i.i, 0x404C078043CB129C
  %i636 = fsub double 0xC0320C17B7F0ED52, %mul5.i.i258.i.i.i.i
  %mul10.i.i260.i.i.i.i = fmul double %mul.i.i270.i.i.i.i, %add.i.i257.i.i.i.i
  %mul12.i.i261.i.i.i.i = fmul double %mul.i.i270.i.i.i.i, %i636
  %add15.i.i262.i.i.i.i = fadd double %mul10.i.i260.i.i.i.i, 0x4071A64A34042F35
  %add18.i.i263.i.i.i.i = fadd double %mul12.i.i261.i.i.i.i, 0x405F12CC60181A8F
  %mul20.i.i264.i.i.i.i = fmul double %mul.i.i270.i.i.i.i, %add15.i.i262.i.i.i.i
  %mul22.i.i265.i.i.i.i = fmul double %mul.i.i270.i.i.i.i, %add18.i.i263.i.i.i.i
  %add25.i.i266.i.i.i.i = fadd double %mul20.i.i264.i.i.i.i, 0x40332E0500972875
  %add28.i.i267.i.i.i.i = fadd double %mul22.i.i265.i.i.i.i, 1.000000e+00
  %mul30.i.i268.i.i.i.i = fmul double %sub13.i.i.i.i, %add25.i.i266.i.i.i.i
  %add33.i.i269.i.i.i.i = fadd double %add28.i.i267.i.i.i.i, %mul30.i.i268.i.i.i.i
  %div16.i.i.i.i = fdiv double %add33.i.i284.i.i.i.i, %add33.i.i269.i.i.i.i
  br label %join

right:                                            ; preds = %entry
  %i644 = tail call double @llvm.amdgcn.ldexp.f64(double %arrayidx.val, i32 3) #3
  %i645 = tail call double @llvm.amdgcn.frexp.mant.f64(double %i644) #3
  %i646 = fcmp olt double %i645, 0x3FE5555555555555
  %i647 = zext i1 %i646 to i32
  %i648 = tail call double @llvm.amdgcn.ldexp.f64(double %i645, i32 %i647) #3
  %i649 = tail call i32 @llvm.amdgcn.frexp.exp.i32.f64(double %i644) #3
  %i650 = sub nsw i32 %i649, %i647
  %i651 = fadd double %i648, -1.000000e+00
  %i652 = fadd double %i648, 1.000000e+00
  %i653 = fsub double %i652, %i648
  %i654 = fsub double %i652, %i653
  %i655 = fsub double %i648, %i654
  %i656 = fsub double 1.000000e+00, %i653
  %i657 = fadd double %i656, %i655
  %i658 = tail call double @llvm.amdgcn.rcp.f64(double %i652) #3
  %i659 = fneg double %i652
  %i660 = tail call double @llvm.fma.f64(double %i659, double %i658, double 1.000000e+00) #3
  %i661 = tail call double @llvm.fma.f64(double %i660, double %i658, double %i658) #3
  %i662 = tail call double @llvm.fma.f64(double %i659, double %i661, double 1.000000e+00) #3
  %i663 = tail call double @llvm.fma.f64(double %i662, double %i661, double %i661) #3
  %i664 = fmul double %i651, %i663
  %i665 = fmul double %i652, %i664
  %i666 = fneg double %i665
  %i667 = tail call double @llvm.fma.f64(double %i664, double %i652, double %i666) #3
  %i668 = tail call double @llvm.fma.f64(double %i664, double %i657, double %i667) #3
  %i669 = fadd double %i665, %i668
  %i670 = fsub double %i669, %i665
  %i671 = fsub double %i668, %i670
  %i672 = fsub double %i651, %i669
  %i673 = fsub double %i651, %i672
  %i674 = fsub double %i673, %i669
  %i675 = fsub double %i674, %i671
  %i676 = fadd double %i672, %i675
  %i677 = fmul double %i663, %i676
  %i678 = fadd double %i664, %i677
  %i679 = fsub double %i678, %i664
  %i680 = fsub double %i677, %i679
  %i681 = fmul double %i678, %i678
  %i682 = fneg double %i681
  %i683 = tail call double @llvm.fma.f64(double %i678, double %i678, double %i682) #3
  %i684 = fmul double %i680, 2.000000e+00
  %i685 = tail call double @llvm.fma.f64(double %i678, double %i684, double %i683) #3
  %i686 = tail call double @llvm.fma.f64(double %i680, double %i680, double %i685) #3
  %i687 = fadd double %i681, %i686
  %i688 = fsub double %i687, %i681
  %i689 = fsub double %i686, %i688
  %i690 = tail call double @llvm.fma.f64(double %i687, double 0x3FC3AB76BF559E2B, double 0x3FC385386B47B09A) #3
  %i691 = tail call double @llvm.fma.f64(double %i687, double %i690, double 0x3FC7474DD7F4DF2E) #3
  %i692 = tail call double @llvm.fma.f64(double %i687, double %i691, double 0x3FCC71C016291751) #3
  %i693 = tail call double @llvm.fma.f64(double %i687, double %i692, double 0x3FD249249B27ACF1) #3
  %i694 = tail call double @llvm.fma.f64(double %i687, double %i693, double 0x3FD99999998EF7B6) #3
  %i695 = tail call double @llvm.fma.f64(double %i687, double %i694, double 0x3FE5555555555780) #3
  %i696 = tail call double @llvm.amdgcn.ldexp.f64(double %i678, i32 1) #3
  %i697 = tail call double @llvm.amdgcn.ldexp.f64(double %i680, i32 1) #3
  %i698 = fmul double %i678, %i687
  %i699 = fneg double %i698
  %i700 = tail call double @llvm.fma.f64(double %i678, double %i687, double %i699) #3
  %i701 = fmul double %i680, %i687
  %i702 = tail call double @llvm.fma.f64(double %i678, double %i689, double %i701) #3
  %i703 = fadd double %i700, %i702
  %i704 = fadd double %i698, %i703
  %i705 = fsub double %i704, %i698
  %i706 = fsub double %i703, %i705
  %i707 = fmul double %i704, %i695
  %i708 = fneg double %i707
  %i709 = tail call double @llvm.fma.f64(double %i704, double %i695, double %i708) #3
  %i710 = tail call double @llvm.fma.f64(double %i706, double %i695, double %i709) #3
  %i711 = fadd double %i707, %i710
  %i712 = fsub double %i711, %i707
  %i713 = fsub double %i710, %i712
  %i714 = fadd double %i696, %i711
  %i715 = fsub double %i714, %i696
  %i716 = fsub double %i714, %i715
  %i717 = fsub double %i696, %i716
  %i718 = fsub double %i711, %i715
  %i719 = fadd double %i718, %i717
  %i720 = fadd double %i697, %i713
  %i721 = fsub double %i720, %i697
  %i722 = fsub double %i720, %i721
  %i723 = fsub double %i697, %i722
  %i724 = fsub double %i713, %i721
  %i725 = fadd double %i724, %i723
  %i726 = fadd double %i720, %i719
  %i727 = fadd double %i714, %i726
  %i728 = fsub double %i727, %i714
  %i729 = fsub double %i726, %i728
  %i730 = fadd double %i725, %i729
  %i731 = fadd double %i727, %i730
  %i732 = fsub double %i731, %i727
  %i733 = fsub double %i730, %i732
  %i734 = sitofp i32 %i650 to double
  %i735 = fmul double %i731, 0x3FF71547652B82FE
  %i736 = fneg double %i735
  %i737 = fmul double %i731, 0x3C7777D0FFDA0D24
  %i738 = insertelement <2 x double> undef, double %i731, i32 0
  %i739 = insertelement <2 x double> %i738, double %i733, i32 1
  %i740 = insertelement <2 x double> undef, double %i736, i32 0
  %i741 = insertelement <2 x double> %i740, double %i737, i32 1
  %i742 = tail call <2 x double> @llvm.fma.v2f64(<2 x double> %i739, <2 x double> <double 0x3FF71547652B82FE, double 0x3FF71547652B82FE>, <2 x double> %i741) #3
  %i743 = extractelement <2 x double> %i742, i32 0
  %i744 = extractelement <2 x double> %i742, i32 1
  %i745 = fadd double %i743, %i744
  %i746 = fadd double %i735, %i745
  %i747 = fsub double %i746, %i735
  %i748 = fsub double %i745, %i747
  %i749 = fadd double %i746, %i734
  %i750 = fsub double %i749, %i734
  %i751 = fsub double %i750, %i749
  %i752 = fadd double %i751, %i734
  %i753 = fsub double %i746, %i750
  %i754 = fadd double %i753, %i752
  %i755 = fadd double %i748, %i754
  %i756 = fadd double %i749, %i755
  %i757 = tail call double @llvm.fabs.f64(double %i644) #4
  %i758 = fcmp oeq double %i757, 0x7FF0000000000000
  %i759 = select i1 %i758, double %i644, double %i756
  %i760 = fcmp olt double %i644, 0.000000e+00
  %i761 = select i1 %i760, double 0x7FF8000000000000, double %i759
  %i762 = fcmp oeq double %i644, 0.000000e+00
  %i763 = select i1 %i762, double 0xFFF0000000000000, double %i761
  %mul.i.i244.i.i.i.i = fmul double %i763, %i763
  %mul1.i.i245.i.i.i.i = fmul double %mul.i.i244.i.i.i.i, 0x3F1989D450BBA5CA
  %i764 = fsub double 0xBFBD94CCEC41CB08, %mul1.i.i245.i.i.i.i
  %mul5.i.i247.i.i.i.i = fmul double %mul.i.i244.i.i.i.i, 0x3F7B3A00DD9C9429
  %i765 = fsub double 0xBFE8DDD719DA7D3E, %mul5.i.i247.i.i.i.i
  %mul10.i.i249.i.i.i.i = fmul double %mul.i.i244.i.i.i.i, %i764
  %mul12.i.i250.i.i.i.i = fmul double %mul.i.i244.i.i.i.i, %i765
  %add15.i.i251.i.i.i.i = fadd double %mul10.i.i249.i.i.i.i, 0xC001974D2C397C76
  %add18.i.i252.i.i.i.i = fadd double %mul12.i.i250.i.i.i.i, 0xC001804F92FE2A82
  %i766 = fmul double %i763, %add15.i.i251.i.i.i.i
  %add23.i.i254.i.i.i.i = fsub double %add18.i.i252.i.i.i.i, %i766
  %mul1.i.i234.i.i.i.i = fmul double %mul.i.i244.i.i.i.i, 0x3EDBEC7AF5AC0D6F
  %add.i.i235.i.i.i.i = fadd double %mul1.i.i234.i.i.i.i, 0x3F98BA1DB321D0E9
  %mul5.i.i236.i.i.i.i = fmul double %mul.i.i244.i.i.i.i, 0x3F4ED662BB480251
  %add7.i.i237.i.i.i.i = fadd double %mul5.i.i236.i.i.i.i, 0x3FCBD444F5D4FCC2
  %mul10.i.i238.i.i.i.i = fmul double %mul.i.i244.i.i.i.i, %add.i.i235.i.i.i.i
  %mul12.i.i239.i.i.i.i = fmul double %mul.i.i244.i.i.i.i, %add7.i.i237.i.i.i.i
  %add15.i.i240.i.i.i.i = fadd double %mul10.i.i238.i.i.i.i, 0x3FE957680773BEB6
  %add18.i.i241.i.i.i.i = fadd double %mul12.i.i239.i.i.i.i, 1.000000e+00
  %i767 = fmul double %i763, %add15.i.i240.i.i.i.i
  %add23.i.i243.i.i.i.i = fsub double %add18.i.i241.i.i.i.i, %i767
  %div26.i.i.i.i = fdiv double %add23.i.i254.i.i.i.i, %add23.i.i243.i.i.i.i
  br label %join

join:                                             ; preds = %right, %left
  %retval.0.i.i.i.ph = phi double [ %div16.i.i.i.i, %left ], [ %div26.i.i.i.i, %right ]
  ret double %retval.0.i.i.i.ph
}

attributes #0 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" }
attributes #3 = { nounwind }
attributes #4 = { nounwind readnone }

!llvm.module.flags = !{!0, !1}
!opencl.ocl.version = !{!2}
!llvm.ident = !{!3, !4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 1}
!2 = !{i32 2, i32 0}
!3 = !{!"clang version 12.0.0 (https://github.com/charitha22/cgo22ae-darm-code.git e9bc0540325ad9806313d34e84fc901496fd8be6)"}
!4 = !{!"clang version 12.0.0 (/src/external/llvm-project/clang dac2bfceaa8d4a90257dc8a6d58f268e172ce00e)"}
