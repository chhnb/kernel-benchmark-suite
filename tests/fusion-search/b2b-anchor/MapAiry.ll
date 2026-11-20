source_filename = "MapAiry.ll"
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

define double @MapAiry(i1 %cond, double %arrayidx.val) #2 {
entry:
  br i1 %cond, label %left, label %right

left:                                             ; preds = %entry
  %i735 = tail call double @llvm.amdgcn.ldexp.f64(double %arrayidx.val, i32 4) #3
  %i736 = tail call double @llvm.amdgcn.frexp.mant.f64(double %i735) #3
  %i737 = fcmp olt double %i736, 0x3FE5555555555555
  %i738 = zext i1 %i737 to i32
  %i739 = tail call double @llvm.amdgcn.ldexp.f64(double %i736, i32 %i738) #3
  %i740 = tail call i32 @llvm.amdgcn.frexp.exp.i32.f64(double %i735) #3
  %i741 = sub nsw i32 %i740, %i738
  %i742 = fadd double %i739, -1.000000e+00
  %i743 = fadd double %i739, 1.000000e+00
  %i744 = fsub double %i743, %i739
  %i745 = fsub double %i743, %i744
  %i746 = fsub double %i739, %i745
  %i747 = fsub double 1.000000e+00, %i744
  %i748 = fadd double %i747, %i746
  %i749 = tail call double @llvm.amdgcn.rcp.f64(double %i743) #3
  %i750 = fneg double %i743
  %i751 = tail call double @llvm.fma.f64(double %i750, double %i749, double 1.000000e+00) #3
  %i752 = tail call double @llvm.fma.f64(double %i751, double %i749, double %i749) #3
  %i753 = tail call double @llvm.fma.f64(double %i750, double %i752, double 1.000000e+00) #3
  %i754 = tail call double @llvm.fma.f64(double %i753, double %i752, double %i752) #3
  %i755 = fmul double %i742, %i754
  %i756 = fmul double %i743, %i755
  %i757 = fneg double %i756
  %i758 = tail call double @llvm.fma.f64(double %i755, double %i743, double %i757) #3
  %i759 = tail call double @llvm.fma.f64(double %i755, double %i748, double %i758) #3
  %i760 = fadd double %i756, %i759
  %i761 = fsub double %i760, %i756
  %i762 = fsub double %i759, %i761
  %i763 = fsub double %i742, %i760
  %i764 = fsub double %i742, %i763
  %i765 = fsub double %i764, %i760
  %i766 = fsub double %i765, %i762
  %i767 = fadd double %i763, %i766
  %i768 = fmul double %i754, %i767
  %i769 = fadd double %i755, %i768
  %i770 = fsub double %i769, %i755
  %i771 = fsub double %i768, %i770
  %i772 = fmul double %i769, %i769
  %i773 = fneg double %i772
  %i774 = tail call double @llvm.fma.f64(double %i769, double %i769, double %i773) #3
  %i775 = fmul double %i771, 2.000000e+00
  %i776 = tail call double @llvm.fma.f64(double %i769, double %i775, double %i774) #3
  %i777 = tail call double @llvm.fma.f64(double %i771, double %i771, double %i776) #3
  %i778 = fadd double %i772, %i777
  %i779 = fsub double %i778, %i772
  %i780 = fsub double %i777, %i779
  %i781 = tail call double @llvm.fma.f64(double %i778, double 0x3FC3AB76BF559E2B, double 0x3FC385386B47B09A) #3
  %i782 = tail call double @llvm.fma.f64(double %i778, double %i781, double 0x3FC7474DD7F4DF2E) #3
  %i783 = tail call double @llvm.fma.f64(double %i778, double %i782, double 0x3FCC71C016291751) #3
  %i784 = tail call double @llvm.fma.f64(double %i778, double %i783, double 0x3FD249249B27ACF1) #3
  %i785 = tail call double @llvm.fma.f64(double %i778, double %i784, double 0x3FD99999998EF7B6) #3
  %i786 = tail call double @llvm.fma.f64(double %i778, double %i785, double 0x3FE5555555555780) #3
  %i787 = tail call double @llvm.amdgcn.ldexp.f64(double %i769, i32 1) #3
  %i788 = tail call double @llvm.amdgcn.ldexp.f64(double %i771, i32 1) #3
  %i789 = fmul double %i769, %i778
  %i790 = fneg double %i789
  %i791 = tail call double @llvm.fma.f64(double %i769, double %i778, double %i790) #3
  %i792 = fmul double %i771, %i778
  %i793 = tail call double @llvm.fma.f64(double %i769, double %i780, double %i792) #3
  %i794 = fadd double %i791, %i793
  %i795 = fadd double %i789, %i794
  %i796 = fsub double %i795, %i789
  %i797 = fsub double %i794, %i796
  %i798 = fmul double %i795, %i786
  %i799 = fneg double %i798
  %i800 = tail call double @llvm.fma.f64(double %i795, double %i786, double %i799) #3
  %i801 = tail call double @llvm.fma.f64(double %i797, double %i786, double %i800) #3
  %i802 = fadd double %i798, %i801
  %i803 = fsub double %i802, %i798
  %i804 = fsub double %i801, %i803
  %i805 = fadd double %i787, %i802
  %i806 = fsub double %i805, %i787
  %i807 = fsub double %i805, %i806
  %i808 = fsub double %i787, %i807
  %i809 = fsub double %i802, %i806
  %i810 = fadd double %i809, %i808
  %i811 = fadd double %i788, %i804
  %i812 = fsub double %i811, %i788
  %i813 = fsub double %i811, %i812
  %i814 = fsub double %i788, %i813
  %i815 = fsub double %i804, %i812
  %i816 = fadd double %i815, %i814
  %i817 = fadd double %i811, %i810
  %i818 = fadd double %i805, %i817
  %i819 = fsub double %i818, %i805
  %i820 = fsub double %i817, %i819
  %i821 = fadd double %i816, %i820
  %i822 = fadd double %i818, %i821
  %i823 = fsub double %i822, %i818
  %i824 = fsub double %i821, %i823
  %i825 = sitofp i32 %i741 to double
  %i826 = fmul double %i822, 0x3FF71547652B82FE
  %i827 = fneg double %i826
  %i828 = fmul double %i822, 0x3C7777D0FFDA0D24
  %i829 = insertelement <2 x double> undef, double %i822, i32 0
  %i830 = insertelement <2 x double> %i829, double %i824, i32 1
  %i831 = insertelement <2 x double> undef, double %i827, i32 0
  %i832 = insertelement <2 x double> %i831, double %i828, i32 1
  %i833 = tail call <2 x double> @llvm.fma.v2f64(<2 x double> %i830, <2 x double> <double 0x3FF71547652B82FE, double 0x3FF71547652B82FE>, <2 x double> %i832) #3
  %i834 = extractelement <2 x double> %i833, i32 0
  %i835 = extractelement <2 x double> %i833, i32 1
  %i836 = fadd double %i834, %i835
  %i837 = fadd double %i826, %i836
  %i838 = fsub double %i837, %i826
  %i839 = fsub double %i836, %i838
  %i840 = fadd double %i837, %i825
  %i841 = fsub double %i840, %i825
  %i842 = fsub double %i841, %i840
  %i843 = fadd double %i842, %i825
  %i844 = fsub double %i837, %i841
  %i845 = fadd double %i844, %i843
  %i846 = fadd double %i839, %i845
  %i847 = fadd double %i840, %i846
  %i848 = tail call double @llvm.fabs.f64(double %i735) #4
  %i849 = fcmp oeq double %i848, 0x7FF0000000000000
  %i850 = select i1 %i849, double %i735, double %i847
  %i851 = fcmp olt double %i735, 0.000000e+00
  %i852 = select i1 %i851, double 0x7FF8000000000000, double %i850
  %i853 = fcmp oeq double %i735, 0.000000e+00
  %i854 = select i1 %i853, double 0xFFF0000000000000, double %i852
  %mul.i.i218.i.i.i.i = fmul double %i854, %i854
  %mul1.i.i219.i.i.i.i = fmul double %mul.i.i218.i.i.i.i, 0x3E32022ABCFF5DE7
  %i855 = fsub double 0xBF336C13BBA203F3, %mul1.i.i219.i.i.i.i
  %mul5.i.i221.i.i.i.i = fmul double %mul.i.i218.i.i.i.i, 0x3ECBFD524C94F258
  %i856 = fsub double 0xBF81F96D17A7115B, %mul5.i.i221.i.i.i.i
  %mul10.i.i223.i.i.i.i = fmul double %mul.i.i218.i.i.i.i, %i855
  %mul12.i.i224.i.i.i.i = fmul double %mul.i.i218.i.i.i.i, %i856
  %add15.i.i225.i.i.i.i = fadd double %mul10.i.i223.i.i.i.i, 0xBFBD7935AC58B5B5
  %add18.i.i226.i.i.i.i = fadd double %mul12.i.i224.i.i.i.i, 0xBFE78F054AC7A90B
  %mul20.i.i227.i.i.i.i = fmul double %mul.i.i218.i.i.i.i, %add15.i.i225.i.i.i.i
  %mul22.i.i228.i.i.i.i = fmul double %mul.i.i218.i.i.i.i, %add18.i.i226.i.i.i.i
  %add25.i.i229.i.i.i.i = fadd double %mul20.i.i227.i.i.i.i, 0xC001F1CD6A03BCAA
  %add28.i.i230.i.i.i.i = fadd double %mul22.i.i228.i.i.i.i, 0xC004C929A952DE48
  %i857 = fmul double %i854, %add25.i.i229.i.i.i.i
  %add33.i.i232.i.i.i.i = fsub double %add28.i.i230.i.i.i.i, %i857
  %mul1.i.i206.i.i.i.i = fmul double %mul.i.i218.i.i.i.i, 0x3E9090FBB4B042AE
  %add.i.i207.i.i.i.i = fadd double %mul1.i.i206.i.i.i.i, 0x3F586FC94B9EAD30
  %mul5.i.i208.i.i.i.i = fmul double %mul.i.i218.i.i.i.i, 0x3F0330822740ADF9
  %add7.i.i209.i.i.i.i = fadd double %mul5.i.i208.i.i.i.i, 0x3F999857B526C821
  %mul10.i.i210.i.i.i.i = fmul double %mul.i.i218.i.i.i.i, %add.i.i207.i.i.i.i
  %mul12.i.i211.i.i.i.i = fmul double %mul.i.i218.i.i.i.i, %add7.i.i209.i.i.i.i
  %add15.i.i212.i.i.i.i = fadd double %mul10.i.i210.i.i.i.i, 0x3FC92E7DCCD1B70C
  %add18.i.i213.i.i.i.i = fadd double %mul12.i.i211.i.i.i.i, 0x3FE7235AE26E3A60
  %mul20.i.i214.i.i.i.i = fmul double %mul.i.i218.i.i.i.i, %add15.i.i212.i.i.i.i
  %add23.i.i215.i.i.i.i = fadd double %mul20.i.i214.i.i.i.i, 1.000000e+00
  %i858 = fmul double %i854, %add18.i.i213.i.i.i.i
  %add28.i.i217.i.i.i.i = fsub double %add23.i.i215.i.i.i.i, %i858
  %div37.i.i.i.i = fdiv double %add33.i.i232.i.i.i.i, %add28.i.i217.i.i.i.i
  br label %join

right:                                            ; preds = %entry
  %i859 = tail call double @llvm.amdgcn.ldexp.f64(double %arrayidx.val, i32 8) #3
  %i860 = tail call double @llvm.amdgcn.frexp.mant.f64(double %i859) #3
  %i861 = fcmp olt double %i860, 0x3FE5555555555555
  %i862 = zext i1 %i861 to i32
  %i863 = tail call double @llvm.amdgcn.ldexp.f64(double %i860, i32 %i862) #3
  %i864 = tail call i32 @llvm.amdgcn.frexp.exp.i32.f64(double %i859) #3
  %i865 = sub nsw i32 %i864, %i862
  %i866 = fadd double %i863, -1.000000e+00
  %i867 = fadd double %i863, 1.000000e+00
  %i868 = fsub double %i867, %i863
  %i869 = fsub double %i867, %i868
  %i870 = fsub double %i863, %i869
  %i871 = fsub double 1.000000e+00, %i868
  %i872 = fadd double %i871, %i870
  %i873 = tail call double @llvm.amdgcn.rcp.f64(double %i867) #3
  %i874 = fneg double %i867
  %i875 = tail call double @llvm.fma.f64(double %i874, double %i873, double 1.000000e+00) #3
  %i876 = tail call double @llvm.fma.f64(double %i875, double %i873, double %i873) #3
  %i877 = tail call double @llvm.fma.f64(double %i874, double %i876, double 1.000000e+00) #3
  %i878 = tail call double @llvm.fma.f64(double %i877, double %i876, double %i876) #3
  %i879 = fmul double %i866, %i878
  %i880 = fmul double %i867, %i879
  %i881 = fneg double %i880
  %i882 = tail call double @llvm.fma.f64(double %i879, double %i867, double %i881) #3
  %i883 = tail call double @llvm.fma.f64(double %i879, double %i872, double %i882) #3
  %i884 = fadd double %i880, %i883
  %i885 = fsub double %i884, %i880
  %i886 = fsub double %i883, %i885
  %i887 = fsub double %i866, %i884
  %i888 = fsub double %i866, %i887
  %i889 = fsub double %i888, %i884
  %i890 = fsub double %i889, %i886
  %i891 = fadd double %i887, %i890
  %i892 = fmul double %i878, %i891
  %i893 = fadd double %i879, %i892
  %i894 = fsub double %i893, %i879
  %i895 = fsub double %i892, %i894
  %i896 = fmul double %i893, %i893
  %i897 = fneg double %i896
  %i898 = tail call double @llvm.fma.f64(double %i893, double %i893, double %i897) #3
  %i899 = fmul double %i895, 2.000000e+00
  %i900 = tail call double @llvm.fma.f64(double %i893, double %i899, double %i898) #3
  %i901 = tail call double @llvm.fma.f64(double %i895, double %i895, double %i900) #3
  %i902 = fadd double %i896, %i901
  %i903 = fsub double %i902, %i896
  %i904 = fsub double %i901, %i903
  %i905 = tail call double @llvm.fma.f64(double %i902, double 0x3FC3AB76BF559E2B, double 0x3FC385386B47B09A) #3
  %i906 = tail call double @llvm.fma.f64(double %i902, double %i905, double 0x3FC7474DD7F4DF2E) #3
  %i907 = tail call double @llvm.fma.f64(double %i902, double %i906, double 0x3FCC71C016291751) #3
  %i908 = tail call double @llvm.fma.f64(double %i902, double %i907, double 0x3FD249249B27ACF1) #3
  %i909 = tail call double @llvm.fma.f64(double %i902, double %i908, double 0x3FD99999998EF7B6) #3
  %i910 = tail call double @llvm.fma.f64(double %i902, double %i909, double 0x3FE5555555555780) #3
  %i911 = tail call double @llvm.amdgcn.ldexp.f64(double %i893, i32 1) #3
  %i912 = tail call double @llvm.amdgcn.ldexp.f64(double %i895, i32 1) #3
  %i913 = fmul double %i893, %i902
  %i914 = fneg double %i913
  %i915 = tail call double @llvm.fma.f64(double %i893, double %i902, double %i914) #3
  %i916 = fmul double %i895, %i902
  %i917 = tail call double @llvm.fma.f64(double %i893, double %i904, double %i916) #3
  %i918 = fadd double %i915, %i917
  %i919 = fadd double %i913, %i918
  %i920 = fsub double %i919, %i913
  %i921 = fsub double %i918, %i920
  %i922 = fmul double %i919, %i910
  %i923 = fneg double %i922
  %i924 = tail call double @llvm.fma.f64(double %i919, double %i910, double %i923) #3
  %i925 = tail call double @llvm.fma.f64(double %i921, double %i910, double %i924) #3
  %i926 = fadd double %i922, %i925
  %i927 = fsub double %i926, %i922
  %i928 = fsub double %i925, %i927
  %i929 = fadd double %i911, %i926
  %i930 = fsub double %i929, %i911
  %i931 = fsub double %i929, %i930
  %i932 = fsub double %i911, %i931
  %i933 = fsub double %i926, %i930
  %i934 = fadd double %i933, %i932
  %i935 = fadd double %i912, %i928
  %i936 = fsub double %i935, %i912
  %i937 = fsub double %i935, %i936
  %i938 = fsub double %i912, %i937
  %i939 = fsub double %i928, %i936
  %i940 = fadd double %i939, %i938
  %i941 = fadd double %i935, %i934
  %i942 = fadd double %i929, %i941
  %i943 = fsub double %i942, %i929
  %i944 = fsub double %i941, %i943
  %i945 = fadd double %i940, %i944
  %i946 = fadd double %i942, %i945
  %i947 = fsub double %i946, %i942
  %i948 = fsub double %i945, %i947
  %i949 = sitofp i32 %i865 to double
  %i950 = fmul double %i946, 0x3FF71547652B82FE
  %i951 = fneg double %i950
  %i952 = fmul double %i946, 0x3C7777D0FFDA0D24
  %i953 = insertelement <2 x double> undef, double %i946, i32 0
  %i954 = insertelement <2 x double> %i953, double %i948, i32 1
  %i955 = insertelement <2 x double> undef, double %i951, i32 0
  %i956 = insertelement <2 x double> %i955, double %i952, i32 1
  %i957 = tail call <2 x double> @llvm.fma.v2f64(<2 x double> %i954, <2 x double> <double 0x3FF71547652B82FE, double 0x3FF71547652B82FE>, <2 x double> %i956) #3
  %i958 = extractelement <2 x double> %i957, i32 0
  %i959 = extractelement <2 x double> %i957, i32 1
  %i960 = fadd double %i958, %i959
  %i961 = fadd double %i950, %i960
  %i962 = fsub double %i961, %i950
  %i963 = fsub double %i960, %i962
  %i964 = fadd double %i961, %i949
  %i965 = fsub double %i964, %i949
  %i966 = fsub double %i965, %i964
  %i967 = fadd double %i966, %i949
  %i968 = fsub double %i961, %i965
  %i969 = fadd double %i968, %i967
  %i970 = fadd double %i963, %i969
  %i971 = fadd double %i964, %i970
  %i972 = tail call double @llvm.fabs.f64(double %i859) #4
  %i973 = fcmp oeq double %i972, 0x7FF0000000000000
  %i974 = select i1 %i973, double %i859, double %i971
  %i975 = fcmp olt double %i859, 0.000000e+00
  %i976 = select i1 %i975, double 0x7FF8000000000000, double %i974
  %i977 = fcmp oeq double %i859, 0.000000e+00
  %i978 = select i1 %i977, double 0xFFF0000000000000, double %i976
  %mul.i.i190.i.i.i.i = fmul double %i978, %i978
  %mul1.i.i191.i.i.i.i = fmul double %mul.i.i190.i.i.i.i, 0x3DC4C8BD76453064
  %i979 = fsub double 0xBEE755F1646665DB, %mul1.i.i191.i.i.i.i
  %mul5.i.i193.i.i.i.i = fmul double %mul.i.i190.i.i.i.i, 0x3E70731CF2A765F0
  %i980 = fsub double 0xBF4625660A41D7B1, %mul5.i.i193.i.i.i.i
  %mul10.i.i195.i.i.i.i = fmul double %mul.i.i190.i.i.i.i, %i979
  %mul12.i.i196.i.i.i.i = fmul double %mul.i.i190.i.i.i.i, %i980
  %add15.i.i197.i.i.i.i = fadd double %mul10.i.i195.i.i.i.i, 0xBF92AE2345C460A0
  %add18.i.i198.i.i.i.i = fadd double %mul12.i.i196.i.i.i.i, 0xBFCED54905311121
  %mul20.i.i199.i.i.i.i = fmul double %mul.i.i190.i.i.i.i, %add15.i.i197.i.i.i.i
  %mul22.i.i200.i.i.i.i = fmul double %mul.i.i190.i.i.i.i, %add18.i.i198.i.i.i.i
  %add25.i.i201.i.i.i.i = fadd double %mul20.i.i199.i.i.i.i, 0xBFF8595CA25899FD
  %add28.i.i202.i.i.i.i = fadd double %mul22.i.i200.i.i.i.i, 0xC00D636ADAEC3C05
  %i981 = fmul double %i978, %add25.i.i201.i.i.i.i
  %add33.i.i204.i.i.i.i = fsub double %add28.i.i202.i.i.i.i, %i981
  %mul1.i.i178.i.i.i.i = fmul double %mul.i.i190.i.i.i.i, 0x3E2EB2F3F6504F32
  %add.i.i179.i.i.i.i = fadd double %mul1.i.i178.i.i.i.i, 0x3F1751EF5755C229
  %mul5.i.i180.i.i.i.i = fmul double %mul.i.i190.i.i.i.i, 0x3EB20E304F6E5BCE
  %add7.i.i181.i.i.i.i = fadd double %mul5.i.i180.i.i.i.i, 0x3F68BF137C253BD1
  %mul10.i.i182.i.i.i.i = fmul double %mul.i.i190.i.i.i.i, %add.i.i179.i.i.i.i
  %mul12.i.i183.i.i.i.i = fmul double %mul.i.i190.i.i.i.i, %add7.i.i181.i.i.i.i
  %add15.i.i184.i.i.i.i = fadd double %mul10.i.i182.i.i.i.i, 0x3FA8A45F1AE4ADBE
  %add18.i.i185.i.i.i.i = fadd double %mul12.i.i183.i.i.i.i, 0x3FD6E5B7AB236028
  %mul20.i.i186.i.i.i.i = fmul double %mul.i.i190.i.i.i.i, %add15.i.i184.i.i.i.i
  %add23.i.i187.i.i.i.i = fadd double %mul20.i.i186.i.i.i.i, 1.000000e+00
  %i982 = fmul double %i978, %add18.i.i185.i.i.i.i
  %add28.i.i189.i.i.i.i = fsub double %add23.i.i187.i.i.i.i, %i982
  %div48.i30.i.i.i = fdiv double %add33.i.i204.i.i.i.i, %add28.i.i189.i.i.i.i
  br label %join

join:                                             ; preds = %right, %left
  %result = phi double [ %div37.i.i.i.i, %left ], [ %div48.i30.i.i.i, %right ]
  ret double %result
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
