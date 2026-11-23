; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, double %1, double %2, double %3, double %4, double %5, double %6, double %7, [58 x double]* %8) #0 {
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
  %53 = phi double [ 0x3FA7ABC63BB9671C, %10 ], [ 0x3F97906FA7E2C9CF, %31 ]
  %54 = phi double [ 0x3F4A8E38348FD9B2, %10 ], [ 0x3F2A514E711D09AD, %31 ]
  %55 = phi double [ 0x3EDC231F3DEEB6F9, %10 ], [ 0x3EABC3297454E377, %31 ]
  %56 = phi double [ 0x3DC87E4D72BFB8FA, %10 ], [ 0x3D77F69D5EF2EF55, %31 ]
  %57 = phi double [ 0x3E5C80E1BF396002, %10 ], [ 0x3E1C00B930B6EDE4, %31 ]
  %58 = phi double [ 0x3D18B1987155CEA4, %10 ], [ 0x3CB8106C9C12C679, %31 ]
  %59 = phi double [ 0xC00A6041983C62F2, %10 ], [ 0xC00E0DA8FADB7C8C, %31 ]
  %60 = phi double [ 0xBFC4DA929BC925CB, %10 ], [ 0xBFB77177F6F25868, %31 ]
  %61 = phi double [ 0xBF69297448457D24, %10 ], [ 0xBF4BE8F64D9A4925, %31 ]
  %62 = phi double [ 0xBEFCEEB9D33660E7, %10 ], [ 0xBECFA9C0D9C5E4A9, %31 ]
  %63 = phi double [ 0xBE80201FEE58D5EB, %10 ], [ 0xBE4167CB2DE9484D, %31 ]
  %64 = phi double [ 0x3D42DFCD4EC1917B, %10 ], [ 0x3CE3BA542B23A837, %31 ]
  %65 = phi double [ 0xBDEF4147E6D836F1, %10 ], [ 0xBDA09F2D7C5D35C1, %31 ]
  %66 = phi double [ 0x3C4C7C5BAC69CA30, %10 ], [ 0x3BDBA8610FC6ED80, %31 ]
  %67 = phi double [ %30, %10 ], [ %51, %31 ]
  %68 = phi double [ %29, %10 ], [ %50, %31 ]
  %69 = phi double [ 0x3E10954573CD1409, %10 ], [ 0x3DA028AD2F8C812A, %31 ]
  %70 = phi double [ 0xBF267FDAD7E340C0, %10 ], [ 0xBED9332B494FD162, %31 ]
  %71 = phi double [ 0x3EBE74EDE276BA2A, %10 ], [ 0x3E6073196B230E1D, %31 ]
  %72 = phi double [ 0xBF74D4DF73958DD4, %10 ], [ 0xBF383759EF2EC40C, %31 ]
  %73 = phi double [ 0xBFB0A4004AB9FA2F, %10 ], [ 0xBF843505D28DAEAC, %31 ]
  %74 = phi double [ 0xBFD95EAC9AE91EB0, %10 ], [ 0xBFC045854783A19F, %31 ]
  %75 = phi double [ 0xBFF1F8D8D4096576, %10 ], [ 0xBFE8CAFD8375357B, %31 ]
  %76 = phi double [ 0xBFF2AD2669F16A11, %10 ], [ 0xBFFC8922BA24935C, %31 ]
  %77 = phi double [ 0x3E9C1C977F10265B, %10 ], [ 0x3E3B89766DC0E470, %31 ]
  %78 = phi double [ 0x3F5F07E1D05A5DFD, %10 ], [ 0x3F1EA8AD4669BB53, %31 ]
  %79 = phi double [ 0x3F0B438FF2C388C0, %10 ], [ 0x3EBAD46BFAE07B75, %31 ]
  %80 = phi double [ 0x3F9DF8C6DBF0F003, %10 ], [ 0x3F6DB7207E85C0EF, %31 ]
  %81 = phi double [ 0x3FCBB079F2C252E4, %10 ], [ 0x3FAB895727F039DB, %31 ]
  %82 = phi double [ 0x3FE82B2F4B11BB5A, %10 ], [ 0x3FD81A505016D302, %31 ]
  %83 = phi double [ 0x3D2EEF3A19525962, %10 ], [ 0x3CBD95F745F985C6, %31 ]
  %84 = phi double [ 0xBE8B5F843E1F3895, %10 ], [ 0xBE3D53C778BDFF24, %31 ]
  %85 = phi double [ 0x3E015340F5605AFB, %10 ], [ 0x3DA2170560574A27, %31 ]
  %86 = phi double [ 0xBEFB16A0F7496BD2, %10 ], [ 0xBEBDB51233A64720, %31 ]
  %87 = phi double [ 0xBF5751B27C5C9BFB, %10 ], [ 0xBF2A2DC3D4DAE3C5, %31 ]
  %88 = phi double [ 0xBFA370C135EBE2E0, %10 ], [ 0xBF865CF2B86753CE, %31 ]
  %89 = phi double [ 0xBFDED3DE58969B0C, %10 ], [ 0xBFD232BB27D90F0B, %31 ]
  %90 = phi double [ 0xC002991536F3B198, %10 ], [ 0xC00695E2D61C0C6E, %31 ]
  %91 = phi double [ 0x3DDA87308BB58726, %10 ], [ 0x3D7985F69E9DFA4C, %31 ]
  %92 = phi double [ 0x3EDDEB134B240B6B, %10 ], [ 0x3E9D26DA9BE0FF59, %31 ]
  %93 = phi double [ 0x3E6A03AD8C7D561F, %10 ], [ 0x3E192F9212752578, %31 ]
  %94 = phi double [ 0x3F3D2E4291C2C2D0, %10 ], [ 0x3F0C9E4DE67437CE, %31 ]
  %95 = phi double [ 0x3F8B35517DD09962, %10 ], [ 0x3F6ADBBA962C2080, %31 ]
  %96 = phi double [ 0x3FC7F5B66495DDB6, %10 ], [ 0x3FB7CE42A74538CD, %31 ]
  %97 = phi double [ 0x3B6B104CE845D8CA, %10 ], [ 0x3AFAA825FA80AEBC, %31 ]
  %98 = phi double [ 0xBD51A9A584540197, %10 ], [ 0xBD02C12978DF0869, %31 ]
  %99 = phi double [ 0x3C84A9C31CF1706D, %10 ], [ 0x3C25ADBF5D5E2D40, %31 ]
  %100 = phi double [ 0xBE02B6DCAE997177, %10 ], [ 0xBDC40F84D4D29208, %31 ]
  %101 = phi double [ 0xBEA134E225D1132C, %10 ], [ 0xBE729A0FDD66F4F2, %31 ]
  %102 = phi double [ 0xBF2EA5E4F352FCF9, %10 ], [ 0xBF10B2EEE9D945FC, %31 ]
  %103 = phi double [ 0xBFAA00AF73AD4FC4, %10 ], [ 0xBF9C8D7861FA32DF, %31 ]
  %104 = phi double [ 0xC010D5424AFC6707, %10 ], [ 0xC0129EFFBA10F842, %31 ]
  %105 = phi double [ 0x3C579C2A1977500A, %10 ], [ 0x3BF74C460513871A, %31 ]
  %106 = phi double [ 0x3DDBA32CD8E6FFE2, %10 ], [ 0x3D9B6269284AABC4, %31 ]
  %107 = phi double [ 0x3D27942AF0BDEC40, %10 ], [ 0x3CD7504574599FA7, %31 ]
  %108 = phi double [ 0x3E7B7CAE58B9ECC4, %10 ], [ 0x3E4B4BB19F333FF9, %31 ]
  %109 = phi double [ 0x3F0A244903F50D45, %10 ], [ 0x3EEA04DE23809639, %31 ]
  %110 = phi double [ 0x3F877C1A4ABB8039, %10 ], [ 0x3F776DDB0ABF64AF, %31 ]
  %111 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 0
  store double %53, double* %111, align 8
  %112 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 1
  store double %54, double* %112, align 8
  %113 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 2
  store double %55, double* %113, align 8
  %114 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 3
  store double %56, double* %114, align 8
  %115 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 4
  store double %57, double* %115, align 8
  %116 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 5
  store double %58, double* %116, align 8
  %117 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 6
  store double %59, double* %117, align 8
  %118 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 7
  store double %60, double* %118, align 8
  %119 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 8
  store double %61, double* %119, align 8
  %120 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 9
  store double %62, double* %120, align 8
  %121 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 10
  store double %63, double* %121, align 8
  %122 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 11
  store double %64, double* %122, align 8
  %123 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 12
  store double %65, double* %123, align 8
  %124 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 13
  store double %66, double* %124, align 8
  %125 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 14
  store double %67, double* %125, align 8
  %126 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 15
  store double %68, double* %126, align 8
  %127 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 16
  store double %69, double* %127, align 8
  %128 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 17
  store double %70, double* %128, align 8
  %129 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 18
  store double %71, double* %129, align 8
  %130 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 19
  store double %72, double* %130, align 8
  %131 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 20
  store double %73, double* %131, align 8
  %132 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 21
  store double %74, double* %132, align 8
  %133 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 22
  store double %75, double* %133, align 8
  %134 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 23
  store double %76, double* %134, align 8
  %135 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 24
  store double %77, double* %135, align 8
  %136 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 25
  store double %78, double* %136, align 8
  %137 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 26
  store double %79, double* %137, align 8
  %138 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 27
  store double %80, double* %138, align 8
  %139 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 28
  store double %81, double* %139, align 8
  %140 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 29
  store double %82, double* %140, align 8
  %141 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 30
  store double %83, double* %141, align 8
  %142 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 31
  store double %84, double* %142, align 8
  %143 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 32
  store double %85, double* %143, align 8
  %144 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 33
  store double %86, double* %144, align 8
  %145 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 34
  store double %87, double* %145, align 8
  %146 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 35
  store double %88, double* %146, align 8
  %147 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 36
  store double %89, double* %147, align 8
  %148 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 37
  store double %90, double* %148, align 8
  %149 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 38
  store double %91, double* %149, align 8
  %150 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 39
  store double %92, double* %150, align 8
  %151 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 40
  store double %93, double* %151, align 8
  %152 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 41
  store double %94, double* %152, align 8
  %153 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 42
  store double %95, double* %153, align 8
  %154 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 43
  store double %96, double* %154, align 8
  %155 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 44
  store double %97, double* %155, align 8
  %156 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 45
  store double %98, double* %156, align 8
  %157 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 46
  store double %99, double* %157, align 8
  %158 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 47
  store double %100, double* %158, align 8
  %159 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 48
  store double %101, double* %159, align 8
  %160 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 49
  store double %102, double* %160, align 8
  %161 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 50
  store double %103, double* %161, align 8
  %162 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 51
  store double %104, double* %162, align 8
  %163 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 52
  store double %105, double* %163, align 8
  %164 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 53
  store double %106, double* %164, align 8
  %165 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 54
  store double %107, double* %165, align 8
  %166 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 55
  store double %108, double* %166, align 8
  %167 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 56
  store double %109, double* %167, align 8
  %168 = getelementptr inbounds [58 x double], [58 x double]* %8, i32 0, i32 57
  store double %110, double* %168, align 8
  ret void
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare <2 x double> @llvm.fma.v2f64(<2 x double>, <2 x double>, <2 x double>) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare double @llvm.fabs.f64(double) #1

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { nounwind }
attributes #3 = { nounwind readnone }
