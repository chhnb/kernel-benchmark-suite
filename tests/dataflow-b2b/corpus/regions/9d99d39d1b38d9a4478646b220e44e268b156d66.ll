; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define double @region(i1 %0, double %1, double %2, double %3, double %4, double %5, double %6, double %7, double %8, double %9, double %10, double %11, double %12, double %13, double %14, double %15, double %16, double %17, double %18, double %19, double %20, double %21, double %22, double %23, double %24, double %25, double %26, double %27, double %28, double %29, double %30, double %31, double %32, double %33, double %34) #0 {
  br i1 %0, label %36, label %78

36:                                               ; preds = %35
  %37 = fcmp oeq double %1, 0x7FF0000000000000
  %38 = select i1 %37, double %2, double %3
  %39 = fcmp olt double %2, 0.000000e+00
  %40 = select i1 %39, double 0x7FF8000000000000, double %38
  %41 = fcmp oeq double %2, 0.000000e+00
  %42 = select i1 %41, double 0xFFF0000000000000, double %40
  %43 = fmul double %42, %42
  %44 = fmul double %43, %4
  %45 = fsub double %5, %44
  %46 = fmul double %43, %6
  %47 = fadd double %46, %7
  %48 = fmul double %43, %45
  %49 = fmul double %43, %47
  %50 = fadd double %48, %8
  %51 = fadd double %49, %9
  %52 = fmul double %43, %50
  %53 = fmul double %43, %51
  %54 = fadd double %52, %10
  %55 = fadd double %53, %11
  %56 = fmul double %43, %54
  %57 = fadd double %56, %12
  %58 = fmul double %42, %55
  %59 = fsub double %57, %58
  %60 = fmul double %43, %13
  %61 = fsub double %14, %60
  %62 = fmul double %43, %15
  %63 = fadd double %62, %16
  %64 = fmul double %43, %61
  %65 = fmul double %43, %63
  %66 = fadd double %64, %17
  %67 = fadd double %65, %18
  %68 = fmul double %43, %66
  %69 = fmul double %43, %67
  %70 = fadd double %68, %19
  %71 = fadd double %69, %20
  %72 = fmul double %43, %70
  %73 = fadd double %72, 1.000000e+00
  %74 = fmul double %42, %71
  %75 = fsub double %73, %74
  %76 = fmul double %21, %75
  %77 = fdiv double %59, %76
  br label %100

78:                                               ; preds = %35
  %79 = fadd double %22, %23
  %80 = fmul double %24, %25
  %81 = fsub double %79, %80
  %82 = fmul double %26, %27
  %83 = fadd double %82, %28
  %84 = fmul double %26, %29
  %85 = fadd double %84, %30
  %86 = fmul double %26, %83
  %87 = fmul double %26, %85
  %88 = fadd double %86, %31
  %89 = fadd double %87, %32
  %90 = fmul double %26, %88
  %91 = fmul double %26, %89
  %92 = fadd double %90, %33
  %93 = fadd double %91, %34
  %94 = fmul double %26, %92
  %95 = fadd double %94, 1.000000e+00
  %96 = fmul double %24, %93
  %97 = fsub double %95, %96
  %98 = fmul double %21, %97
  %99 = fdiv double %81, %98
  br label %100

100:                                              ; preds = %78, %36
  %101 = phi double [ %77, %36 ], [ %99, %78 ]
  ret double %101
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
