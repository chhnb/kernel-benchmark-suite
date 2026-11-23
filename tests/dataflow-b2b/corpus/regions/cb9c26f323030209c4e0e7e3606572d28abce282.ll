; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, double %5, double %6, double %7, [16 x double]* %8) #0 {
  br i1 %0, label %10, label %31

10:                                               ; preds = %9
  %11 = insertelement <2 x double> undef, double %1, i32 0
  %12 = insertelement <2 x double> %11, double %2, i32 1
  %13 = insertelement <2 x double> undef, double %3, i32 0
  %14 = insertelement <2 x double> %13, double %4, i32 1
  %15 = tail call <2 x double> @llvm.fma.v2f64(<2 x double> %12, <2 x double> <double 0x3FF71547652B82FE, double 0x3FF71547652B82FE>, <2 x double> %14) #2
  %16 = extractelement <2 x double> %15, i32 0
  %17 = extractelement <2 x double> %15, i32 1
  %18 = fadd double %16, %17
  %19 = fadd double %5, %18
  %20 = fsub double %19, %5
  %21 = fsub double %18, %20
  %22 = fadd double %19, %6
  %23 = fsub double %22, %6
  %24 = fsub double %23, %22
  %25 = fadd double %24, %6
  %26 = fsub double %19, %23
  %27 = fadd double %26, %25
  %28 = fadd double %21, %27
  %29 = fadd double %22, %28
  %30 = tail call double @llvm.fabs.f64(double %7) #3
  br label %52

31:                                               ; preds = %9
  %32 = insertelement <2 x double> undef, double %1, i32 0
  %33 = insertelement <2 x double> %32, double %2, i32 1
  %34 = insertelement <2 x double> undef, double %3, i32 0
  %35 = insertelement <2 x double> %34, double %4, i32 1
  %36 = tail call <2 x double> @llvm.fma.v2f64(<2 x double> %33, <2 x double> <double 0x3FF71547652B82FE, double 0x3FF71547652B82FE>, <2 x double> %35) #2
  %37 = extractelement <2 x double> %36, i32 0
  %38 = extractelement <2 x double> %36, i32 1
  %39 = fadd double %37, %38
  %40 = fadd double %5, %39
  %41 = fsub double %40, %5
  %42 = fsub double %39, %41
  %43 = fadd double %40, %6
  %44 = fsub double %43, %6
  %45 = fsub double %44, %43
  %46 = fadd double %45, %6
  %47 = fsub double %40, %44
  %48 = fadd double %47, %46
  %49 = fadd double %42, %48
  %50 = fadd double %43, %49
  %51 = tail call double @llvm.fabs.f64(double %7) #3
  br label %52

52:                                               ; preds = %31, %10
  %53 = phi double [ 0x3FA66506CA3FCEB3, %10 ], [ 0x3F964BEF3074CF28, %31 ]
  %54 = phi double [ 0x3F478C82425FFDCE, %10 ], [ 0x3F275783E6F9B4DA, %31 ]
  %55 = phi double [ 0x3ED71590B83839D8, %10 ], [ 0x3EA6C7746378848A, %31 ]
  %56 = phi double [ 0x3DC001D96C7E2C9D, %10 ], [ 0x3D6F4FAB0C90F842, %31 ]
  %57 = phi double [ 0x3E553724D72BE5C7, %10 ], [ 0x3E14D76BE5BA042B, %31 ]
  %58 = phi double [ 0x3D0A81E9CB6A1EA5, %10 ], [ 0x3CA9D032740CF69A, %31 ]
  %59 = phi double [ 0xC0207852FA1731C0, %10 ], [ 0xC024F817DD06EE79, %31 ]
  %60 = phi double [ 0xBFD9F6368DFEFDDF, %10 ], [ 0xBFD06A8AF4A3FC55, %31 ]
  %61 = phi double [ 0xBF7F5FDEC6827012, %10 ], [ 0xBF63B612102F3C24, %31 ]
  %62 = phi double [ 0xBF1232A95F4E8466, %10 ], [ 0xBEE6B9C7BCE39403, %31 ]
  %63 = phi double [ 0xBE94B8A80FB81310, %10 ], [ 0xBE59BA2A0439E4A9, %31 ]
  %64 = phi double [ 0x3D5CB3C39661DD79, %10 ], [ 0x3D01A287ED1019B8, %31 ]
  %65 = phi double [ 0xBE050B1B8007F8FF, %10 ], [ 0xBDB9FC7E20BD04CC, %31 ]
  %66 = phi double [ 0x3C819FA1E5E36C20, %10 ], [ 0x3C158FD8B3C1B0C0, %31 ]
  %67 = phi double [ %29, %10 ], [ %50, %31 ]
  %68 = phi double [ %30, %10 ], [ %51, %31 ]
  %69 = getelementptr inbounds [16 x double], [16 x double]* %8, i32 0, i32 0
  store double %53, double* %69, align 8
  %70 = getelementptr inbounds [16 x double], [16 x double]* %8, i32 0, i32 1
  store double %54, double* %70, align 8
  %71 = getelementptr inbounds [16 x double], [16 x double]* %8, i32 0, i32 2
  store double %55, double* %71, align 8
  %72 = getelementptr inbounds [16 x double], [16 x double]* %8, i32 0, i32 3
  store double %56, double* %72, align 8
  %73 = getelementptr inbounds [16 x double], [16 x double]* %8, i32 0, i32 4
  store double %57, double* %73, align 8
  %74 = getelementptr inbounds [16 x double], [16 x double]* %8, i32 0, i32 5
  store double %58, double* %74, align 8
  %75 = getelementptr inbounds [16 x double], [16 x double]* %8, i32 0, i32 6
  store double %59, double* %75, align 8
  %76 = getelementptr inbounds [16 x double], [16 x double]* %8, i32 0, i32 7
  store double %60, double* %76, align 8
  %77 = getelementptr inbounds [16 x double], [16 x double]* %8, i32 0, i32 8
  store double %61, double* %77, align 8
  %78 = getelementptr inbounds [16 x double], [16 x double]* %8, i32 0, i32 9
  store double %62, double* %78, align 8
  %79 = getelementptr inbounds [16 x double], [16 x double]* %8, i32 0, i32 10
  store double %63, double* %79, align 8
  %80 = getelementptr inbounds [16 x double], [16 x double]* %8, i32 0, i32 11
  store double %64, double* %80, align 8
  %81 = getelementptr inbounds [16 x double], [16 x double]* %8, i32 0, i32 12
  store double %65, double* %81, align 8
  %82 = getelementptr inbounds [16 x double], [16 x double]* %8, i32 0, i32 13
  store double %66, double* %82, align 8
  %83 = getelementptr inbounds [16 x double], [16 x double]* %8, i32 0, i32 14
  store double %67, double* %83, align 8
  %84 = getelementptr inbounds [16 x double], [16 x double]* %8, i32 0, i32 15
  store double %68, double* %84, align 8
  ret void
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare <2 x double> @llvm.fma.v2f64(<2 x double>, <2 x double>, <2 x double>) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.fabs.f64(double) #1

attributes #0 = { nofree norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { nounwind }
attributes #3 = { nounwind readnone }
