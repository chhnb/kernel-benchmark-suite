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
  %53 = phi double [ 0x3F86397D81A61D6E, %10 ], [ 0x3F762C8C65771E78, %31 ]
  %54 = phi double [ 0x3F0730EC426E6E84, %10 ], [ 0x3EE71602E8EA99F3, %31 ]
  %55 = phi double [ 0x3E768F19E4302EF3, %10 ], [ 0x3E46680C94743FD9, %31 ]
  %56 = phi double [ 0x3D1ED0326F0CBDDC, %10 ], [ 0x3CCE78F4A7F13C7D, %31 ]
  %57 = phi double [ 0x3DD49301DA58AEFA, %10 ], [ 0x3D9463E48A976F97, %31 ]
  %58 = phi double [ 0x3C495387D39D2504, %10 ], [ 0x3BE8FEBB5A4047D7, %31 ]
  %59 = phi double [ 0xC02A92BAF87A7B72, %10 ], [ 0xC030CB31255FFA09, %31 ]
  %60 = phi double [ 0xBFC4B5F131A679CC, %10 ], [ 0xBFBA19EDB555D8AD, %31 ]
  %61 = phi double [ 0xBF48C2CA21FD14A5, %10 ], [ 0xBF2F1E266EB4C824, %31 ]
  %62 = phi double [ 0xBEBC6E261AE99633, %10 ], [ 0xBE91D0F7FEBA5A35, %31 ]
  %63 = phi double [ 0xBE2007A65CA14E38, %10 ], [ 0xBDE40A018263D493, %31 ]
  %64 = phi double [ 0x3CA5D280D4B5A285, %10 ], [ 0x3C4B275AC5F91B68, %31 ]
  %65 = phi double [ 0xBD7021DF3392EE60, %10 ], [ 0xBD241E51766A91FB, %31 ]
  %66 = phi double [ 0x3BAA9A26E0297ED8, %10 ], [ 0x3B408480D3491A50, %31 ]
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
