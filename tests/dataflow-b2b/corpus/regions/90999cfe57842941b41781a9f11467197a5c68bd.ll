; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree norecurse nounwind
define double @region(i1 %0, double %1, double %2, double %3, double %4, double %5, double %6, double %7, double %8, double %9, double %10, double %11, double %12, double %13, double %14, double %15, double %16, double %17, double %18, double %19, double %20, double %21, double %22, double %23, double %24, double %25, double %26, double %27, double %28, double %29, double %30, double %31) #0 {
  br i1 %0, label %33, label %68

33:                                               ; preds = %32
  %34 = fcmp oeq double %1, 0x7FF0000000000000
  %35 = select i1 %34, double %2, double %3
  %36 = fcmp olt double %2, 0.000000e+00
  %37 = select i1 %36, double 0x7FF8000000000000, double %35
  %38 = fcmp oeq double %2, 0.000000e+00
  %39 = select i1 %38, double 0xFFF0000000000000, double %37
  %40 = fmul double %39, %39
  %41 = fmul double %40, %4
  %42 = fsub double %5, %41
  %43 = fmul double %40, %6
  %44 = fsub double %7, %43
  %45 = fmul double %40, %42
  %46 = fmul double %40, %44
  %47 = fadd double %45, %8
  %48 = fadd double %46, %9
  %49 = fmul double %40, %47
  %50 = fmul double %40, %48
  %51 = fadd double %49, %10
  %52 = fadd double %50, %11
  %53 = fmul double %39, %51
  %54 = fsub double %52, %53
  %55 = fmul double %40, %12
  %56 = fadd double %55, %13
  %57 = fmul double %40, %14
  %58 = fadd double %57, %15
  %59 = fmul double %40, %56
  %60 = fmul double %40, %58
  %61 = fadd double %59, %16
  %62 = fadd double %60, %17
  %63 = fmul double %40, %61
  %64 = fadd double %63, 1.000000e+00
  %65 = fmul double %39, %62
  %66 = fsub double %64, %65
  %67 = fdiv double %54, %66
  br label %103

68:                                               ; preds = %32
  %69 = fcmp oeq double %1, 0x7FF0000000000000
  %70 = select i1 %69, double %2, double %3
  %71 = fcmp olt double %2, 0.000000e+00
  %72 = select i1 %71, double 0x7FF8000000000000, double %70
  %73 = fcmp oeq double %2, 0.000000e+00
  %74 = select i1 %73, double 0xFFF0000000000000, double %72
  %75 = fmul double %74, %74
  %76 = fmul double %75, %18
  %77 = fsub double %19, %76
  %78 = fmul double %75, %20
  %79 = fsub double %21, %78
  %80 = fmul double %75, %77
  %81 = fmul double %75, %79
  %82 = fadd double %80, %22
  %83 = fadd double %81, %23
  %84 = fmul double %75, %82
  %85 = fmul double %75, %83
  %86 = fadd double %84, %24
  %87 = fadd double %85, %25
  %88 = fmul double %74, %86
  %89 = fsub double %87, %88
  %90 = fmul double %75, %26
  %91 = fadd double %90, %27
  %92 = fmul double %75, %28
  %93 = fadd double %92, %29
  %94 = fmul double %75, %91
  %95 = fmul double %75, %93
  %96 = fadd double %94, %30
  %97 = fadd double %95, %31
  %98 = fmul double %75, %96
  %99 = fadd double %98, 1.000000e+00
  %100 = fmul double %74, %97
  %101 = fsub double %99, %100
  %102 = fdiv double %89, %101
  br label %103

103:                                              ; preds = %68, %33
  %104 = phi double [ %67, %33 ], [ %102, %68 ]
  ret double %104
}

attributes #0 = { nofree norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
