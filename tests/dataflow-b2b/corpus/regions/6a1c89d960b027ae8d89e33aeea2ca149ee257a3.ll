; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, double %5, double %6, double %7, [44 x double]* %8) #0 {
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
  %53 = phi double [ 0x3FC6B0CE3157BCB1, %10 ], [ 0x3FB68627D1A51CB5, %31 ]
  %54 = phi double [ 0x3F882FD20DA34F30, %10 ], [ 0x3F67D3564F778B21, %31 ]
  %55 = phi double [ 0x3F380B62C1407B15, %10 ], [ 0x3F077F4625619D43, %31 ]
  %56 = phi double [ 0x3E6129D961D79065, %10 ], [ 0x3E107ECF99D6009A, %31 ]
  %57 = phi double [ 0x3ED66AFC954DE682, %10 ], [ 0x3E95BA568EDD3BFB, %31 ]
  %58 = phi double [ 0x3DCCD7C812F40049, %10 ], [ 0x3D6B7BD497A2CD17, %31 ]
  %59 = phi double [ 0xC013B000D66B8269, %10 ], [ 0xC019A861C808DCFC, %31 ]
  %60 = phi double [ 0xBFEFD66AE54A0BCB, %10 ], [ 0xBFE46D859460DB51, %31 ]
  %61 = phi double [ 0xBFB3B5B6F694BB9E, %10 ], [ 0xBF98ED20B1D6A6D8, %31 ]
  %62 = phi double [ 0xBF676495E4B7EAAA, %10 ], [ 0xBF3D2E78945F9AC6, %31 ]
  %63 = phi double [ 0xBF0B3634004E0F5C, %10 ], [ 0xBED0C1E92AD969EF, %31 ]
  %64 = phi double [ 0x3E1390C28573DB0F, %10 ], [ 0x3DB79116B58241AA, %31 ]
  %65 = phi double [ 0xBE9C2F1FFD2FFECD, %10 ], [ 0xBE512769C01EA7C5, %31 ]
  %66 = phi double [ 0x3D5866A3E6D0F156, %10 ], [ 0x3CED1FCD2AD8841F, %31 ]
  %67 = phi double [ 0x3FE7235AE26E3A60, %10 ], [ 0x3FD6E5B7AB236028, %31 ]
  %68 = phi double [ 0x3FC92E7DCCD1B70C, %10 ], [ 0x3FA8A45F1AE4ADBE, %31 ]
  %69 = phi double [ 0x3F999857B526C821, %10 ], [ 0x3F68BF137C253BD1, %31 ]
  %70 = phi double [ 0x3F0330822740ADF9, %10 ], [ 0x3EB20E304F6E5BCE, %31 ]
  %71 = phi double [ 0x3F586FC94B9EAD30, %10 ], [ 0x3F1751EF5755C229, %31 ]
  %72 = phi double [ 0x3E9090FBB4B042AE, %10 ], [ 0x3E2EB2F3F6504F32, %31 ]
  %73 = phi double [ 0xC004C929A952DE48, %10 ], [ 0xC00D636ADAEC3C05, %31 ]
  %74 = phi double [ 0xC001F1CD6A03BCAA, %10 ], [ 0xBFF8595CA25899FD, %31 ]
  %75 = phi double [ 0xBFE78F054AC7A90B, %10 ], [ 0xBFCED54905311121, %31 ]
  %76 = phi double [ 0xBFBD7935AC58B5B5, %10 ], [ 0xBF92AE2345C460A0, %31 ]
  %77 = phi double [ 0xBF81F96D17A7115B, %10 ], [ 0xBF4625660A41D7B1, %31 ]
  %78 = phi double [ 0x3ECBFD524C94F258, %10 ], [ 0x3E70731CF2A765F0, %31 ]
  %79 = phi double [ 0xBF336C13BBA203F3, %10 ], [ 0xBEE755F1646665DB, %31 ]
  %80 = phi double [ 0x3E32022ABCFF5DE7, %10 ], [ 0x3DC4C8BD76453064, %31 ]
  %81 = phi double [ %29, %10 ], [ %50, %31 ]
  %82 = phi double [ %30, %10 ], [ %51, %31 ]
  %83 = phi double [ 0x3C819FA1E5E36C20, %10 ], [ 0x3C158FD8B3C1B0C0, %31 ]
  %84 = phi double [ 0xBE050B1B8007F8FF, %10 ], [ 0xBDB9FC7E20BD04CC, %31 ]
  %85 = phi double [ 0x3D5CB3C39661DD79, %10 ], [ 0x3D01A287ED1019B8, %31 ]
  %86 = phi double [ 0xBE94B8A80FB81310, %10 ], [ 0xBE59BA2A0439E4A9, %31 ]
  %87 = phi double [ 0xBF1232A95F4E8466, %10 ], [ 0xBEE6B9C7BCE39403, %31 ]
  %88 = phi double [ 0xBF7F5FDEC6827012, %10 ], [ 0xBF63B612102F3C24, %31 ]
  %89 = phi double [ 0xBFD9F6368DFEFDDF, %10 ], [ 0xBFD06A8AF4A3FC55, %31 ]
  %90 = phi double [ 0xC0207852FA1731C0, %10 ], [ 0xC024F817DD06EE79, %31 ]
  %91 = phi double [ 0x3D0A81E9CB6A1EA5, %10 ], [ 0x3CA9D032740CF69A, %31 ]
  %92 = phi double [ 0x3E553724D72BE5C7, %10 ], [ 0x3E14D76BE5BA042B, %31 ]
  %93 = phi double [ 0x3DC001D96C7E2C9D, %10 ], [ 0x3D6F4FAB0C90F842, %31 ]
  %94 = phi double [ 0x3ED71590B83839D8, %10 ], [ 0x3EA6C7746378848A, %31 ]
  %95 = phi double [ 0x3F478C82425FFDCE, %10 ], [ 0x3F275783E6F9B4DA, %31 ]
  %96 = phi double [ 0x3FA66506CA3FCEB3, %10 ], [ 0x3F964BEF3074CF28, %31 ]
  %97 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 0
  store double %53, double* %97, align 8
  %98 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 1
  store double %54, double* %98, align 8
  %99 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 2
  store double %55, double* %99, align 8
  %100 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 3
  store double %56, double* %100, align 8
  %101 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 4
  store double %57, double* %101, align 8
  %102 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 5
  store double %58, double* %102, align 8
  %103 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 6
  store double %59, double* %103, align 8
  %104 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 7
  store double %60, double* %104, align 8
  %105 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 8
  store double %61, double* %105, align 8
  %106 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 9
  store double %62, double* %106, align 8
  %107 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 10
  store double %63, double* %107, align 8
  %108 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 11
  store double %64, double* %108, align 8
  %109 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 12
  store double %65, double* %109, align 8
  %110 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 13
  store double %66, double* %110, align 8
  %111 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 14
  store double %67, double* %111, align 8
  %112 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 15
  store double %68, double* %112, align 8
  %113 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 16
  store double %69, double* %113, align 8
  %114 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 17
  store double %70, double* %114, align 8
  %115 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 18
  store double %71, double* %115, align 8
  %116 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 19
  store double %72, double* %116, align 8
  %117 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 20
  store double %73, double* %117, align 8
  %118 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 21
  store double %74, double* %118, align 8
  %119 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 22
  store double %75, double* %119, align 8
  %120 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 23
  store double %76, double* %120, align 8
  %121 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 24
  store double %77, double* %121, align 8
  %122 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 25
  store double %78, double* %122, align 8
  %123 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 26
  store double %79, double* %123, align 8
  %124 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 27
  store double %80, double* %124, align 8
  %125 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 28
  store double %81, double* %125, align 8
  %126 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 29
  store double %82, double* %126, align 8
  %127 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 30
  store double %83, double* %127, align 8
  %128 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 31
  store double %84, double* %128, align 8
  %129 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 32
  store double %85, double* %129, align 8
  %130 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 33
  store double %86, double* %130, align 8
  %131 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 34
  store double %87, double* %131, align 8
  %132 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 35
  store double %88, double* %132, align 8
  %133 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 36
  store double %89, double* %133, align 8
  %134 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 37
  store double %90, double* %134, align 8
  %135 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 38
  store double %91, double* %135, align 8
  %136 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 39
  store double %92, double* %136, align 8
  %137 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 40
  store double %93, double* %137, align 8
  %138 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 41
  store double %94, double* %138, align 8
  %139 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 42
  store double %95, double* %139, align 8
  %140 = getelementptr inbounds [44 x double], [44 x double]* %8, i32 0, i32 43
  store double %96, double* %140, align 8
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
