; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree norecurse nounwind
define double @region(i1 %0, double %1, double %2, double %3, i1 %4, double %5, double %6, double %7, double %8, double %9, double %10, double %11, double %12, double %13, double %14, double %15, double %16, double %17, double %18, double %19, double %20, double %21, double %22, double %23, double %24, double %25, double %26, double %27, double %28, double %29, double %30, double %31, double %32, double %33, double %34, double %35, double %36, double %37, double %38, double %39, double %40, double %41, double %42, double %43, double %44, double %45, double %46) #0 {
  br i1 %0, label %48, label %97

48:                                               ; preds = %47
  %49 = fcmp oeq double %1, 0x7FF0000000000000
  %50 = select i1 %49, double %2, double %3
  %51 = fcmp olt double %2, 0.000000e+00
  %52 = select i1 %51, double 0x7FF8000000000000, double %50
  %53 = fcmp oeq double %2, 0.000000e+00
  %54 = select i1 %53, double 0xFFF0000000000000, double %52
  %55 = fmul double %54, %54
  %56 = select i1 %4, double %5, double %6
  %57 = fmul double %55, %56
  %58 = select i1 %4, double %7, double %8
  %59 = fsub double %58, %57
  %60 = select i1 %4, double %9, double %10
  %61 = fmul double %55, %60
  %62 = select i1 %4, double %11, double %12
  %63 = fsub double %62, %61
  %64 = fmul double %55, %59
  %65 = fmul double %55, %63
  %66 = select i1 %4, double %13, double %14
  %67 = fadd double %64, %66
  %68 = select i1 %4, double %15, double %16
  %69 = fadd double %65, %68
  %70 = fmul double %55, %67
  %71 = fmul double %55, %69
  %72 = select i1 %4, double %17, double %18
  %73 = fadd double %70, %72
  %74 = select i1 %4, double %19, double %20
  %75 = fadd double %71, %74
  %76 = fmul double %54, %73
  %77 = fsub double %75, %76
  %78 = select i1 %4, double %21, double %22
  %79 = fmul double %55, %78
  %80 = select i1 %4, double %23, double %24
  %81 = fadd double %79, %80
  %82 = select i1 %4, double %25, double %26
  %83 = fmul double %55, %82
  %84 = select i1 %4, double %27, double %28
  %85 = fadd double %83, %84
  %86 = fmul double %55, %81
  %87 = fmul double %55, %85
  %88 = select i1 %4, double %29, double %30
  %89 = fadd double %86, %88
  %90 = select i1 %4, double %31, double %32
  %91 = fadd double %87, %90
  %92 = fmul double %55, %89
  %93 = fadd double %92, 1.000000e+00
  %94 = fmul double %54, %91
  %95 = fsub double %93, %94
  %96 = fdiv double %77, %95
  br label %132

97:                                               ; preds = %47
  %98 = fcmp oeq double %1, 0x7FF0000000000000
  %99 = select i1 %98, double %2, double %3
  %100 = fcmp olt double %2, 0.000000e+00
  %101 = select i1 %100, double 0x7FF8000000000000, double %99
  %102 = fcmp oeq double %2, 0.000000e+00
  %103 = select i1 %102, double 0xFFF0000000000000, double %101
  %104 = fmul double %103, %103
  %105 = fmul double %104, %33
  %106 = fsub double %34, %105
  %107 = fmul double %104, %35
  %108 = fsub double %36, %107
  %109 = fmul double %104, %106
  %110 = fmul double %104, %108
  %111 = fadd double %109, %37
  %112 = fadd double %110, %38
  %113 = fmul double %104, %111
  %114 = fmul double %104, %112
  %115 = fadd double %113, %39
  %116 = fadd double %114, %40
  %117 = fmul double %103, %115
  %118 = fsub double %116, %117
  %119 = fmul double %104, %41
  %120 = fadd double %119, %42
  %121 = fmul double %104, %43
  %122 = fadd double %121, %44
  %123 = fmul double %104, %120
  %124 = fmul double %104, %122
  %125 = fadd double %123, %45
  %126 = fadd double %124, %46
  %127 = fmul double %104, %125
  %128 = fadd double %127, 1.000000e+00
  %129 = fmul double %103, %126
  %130 = fsub double %128, %129
  %131 = fdiv double %118, %130
  br label %132

132:                                              ; preds = %97, %48
  %133 = phi double [ %96, %48 ], [ %131, %97 ]
  ret double %133
}

attributes #0 = { nofree norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
