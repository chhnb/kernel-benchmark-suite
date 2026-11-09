define void @baseline(i1 %pick, i32 %div, i32 %rem, i32 %sub, double %gamma, double* %p0, double* %p1, double* %p2, double* %p3, double* %p4, double* %p5, double* %p6, double* %p7, double* %p8, double* %p9, double* %p10, double* %p11, double* %out) {
entry:
  br i1 %pick, label %left, label %right
left:
  %mul.i310 = shl nsw i32 %div, 13
  %add.i311 = add nsw i32 %mul.i310, %sub
  %idxprom.i301 = sext i32 %add.i311 to i64
  %arrayidx.i302 = getelementptr inbounds double, double* %p8, i64 %idxprom.i301
  %v28 = load double, double* %arrayidx.i302, align 8
  %arrayidx5.i303 = getelementptr inbounds double, double* %p9, i64 %idxprom.i301
  %v29 = load double, double* %arrayidx5.i303, align 8
  %arrayidx8.i304 = getelementptr inbounds double, double* %p10, i64 %idxprom.i301
  %v30 = load double, double* %arrayidx8.i304, align 8
  %arrayidx11.i305 = getelementptr inbounds double, double* %p11, i64 %idxprom.i301
  %v31 = load double, double* %arrayidx11.i305, align 8
  %add.i300 = add nsw i32 %mul.i310, %rem
  %idxprom.i290 = sext i32 %add.i300 to i64
  %arrayidx.i291 = getelementptr inbounds double, double* %p4, i64 %idxprom.i290
  %v32 = load double, double* %arrayidx.i291, align 8
  %arrayidx5.i292 = getelementptr inbounds double, double* %p5, i64 %idxprom.i290
  %v33 = load double, double* %arrayidx5.i292, align 8
  %arrayidx8.i293 = getelementptr inbounds double, double* %p6, i64 %idxprom.i290
  %v34 = load double, double* %arrayidx8.i293, align 8
  %arrayidx11.i294 = getelementptr inbounds double, double* %p7, i64 %idxprom.i290
  %v35 = load double, double* %arrayidx11.i294, align 8
  br label %join


right:
  %mul.i53.i219 = shl nsw i32 %div, 13
  %add.i54.i220 = add nsw i32 %mul.i53.i219, %rem
  %idxprom.i44.i221 = sext i32 %add.i54.i220 to i64
  %arrayidx.i45.i222 = getelementptr inbounds double, double* %p0, i64 %idxprom.i44.i221
  %v63 = load double, double* %arrayidx.i45.i222, align 8
  %arrayidx5.i46.i223 = getelementptr inbounds double, double* %p1, i64 %idxprom.i44.i221
  %v64 = load double, double* %arrayidx5.i46.i223, align 8
  %arrayidx8.i47.i224 = getelementptr inbounds double, double* %p2, i64 %idxprom.i44.i221
  %v65 = load double, double* %arrayidx8.i47.i224, align 8
  %arrayidx11.i48.i225 = getelementptr inbounds double, double* %p3, i64 %idxprom.i44.i221
  %v66 = load double, double* %arrayidx11.i48.i225, align 8
  %cmp.i.i32.i230 = fcmp ogt double %v63, 1.000000e-25
  %cond.i.i33.i231 = select i1 %cmp.i.i32.i230, double %v63, double 1.000000e-25
  %div.i34.i232 = fdiv double 1.000000e+00, %cond.i.i33.i231
  %mul.i35.i233 = fmul double %v64, %div.i34.i232
  %mul3.i.i234 = fmul double %v65, %div.i34.i232
  %mul4.i.i235 = fmul double %cond.i.i33.i231, 5.000000e-01
  %mul5.i.i236 = fmul double %mul.i35.i233, %mul.i35.i233
  %mul6.i36.i237 = fmul double %mul3.i.i234, %mul3.i.i234
  %add.i37.i238 = fadd double %mul5.i.i236, %mul6.i36.i237
  %mul7.i38.i239 = fmul double %mul4.i.i235, %add.i37.i238
  %sub.i39.i240 = fsub double %v66, %mul7.i38.i239
  %v67 = fadd double %gamma, 0.0
  %sub8.i.i241 = fadd double %v67, -1.000000e+00
  %mul9.i.i242 = fmul double %sub8.i.i241, %sub.i39.i240
  %cmp.i15.i.i243 = fcmp ogt double %mul9.i.i242, 1.000000e-25
  %fneg.i.i249 = fneg double %mul.i35.i233
  %fneg5.i.i250 = fneg double %mul3.i.i234
  %cond.i11.i.i255 = select i1 %cmp.i15.i.i243, double %mul9.i.i242, double 1.000000e-25
  %mul.i.i256 = fmul double %cond.i.i33.i231, %fneg.i.i249
  %mul6.i.i257 = fmul double %cond.i.i33.i231, %fneg5.i.i250
  %div.i.i259 = fdiv double %cond.i11.i.i255, %sub8.i.i241
  %add15.i.i265 = fadd double %mul7.i38.i239, %div.i.i259
  br label %join


join:
  %r0 = phi double [ %v28, %left ], [ %cond.i.i33.i231, %right ]
  %r1 = phi double [ %v29, %left ], [ %mul.i.i256, %right ]
  %r2 = phi double [ %v30, %left ], [ %mul6.i.i257, %right ]
  %r3 = phi double [ %v31, %left ], [ %add15.i.i265, %right ]
  %r4 = phi double [ %v32, %left ], [ %v63, %right ]
  %r5 = phi double [ %v33, %left ], [ %v64, %right ]
  %r6 = phi double [ %v34, %left ], [ %v65, %right ]
  %r7 = phi double [ %v35, %left ], [ %v66, %right ]
  %o0 = getelementptr double, double* %out, i64 0
  store double %r0, double* %o0
  %o1 = getelementptr double, double* %out, i64 1
  store double %r1, double* %o1
  %o2 = getelementptr double, double* %out, i64 2
  store double %r2, double* %o2
  %o3 = getelementptr double, double* %out, i64 3
  store double %r3, double* %o3
  %o4 = getelementptr double, double* %out, i64 4
  store double %r4, double* %o4
  %o5 = getelementptr double, double* %out, i64 5
  store double %r5, double* %o5
  %o6 = getelementptr double, double* %out, i64 6
  store double %r6, double* %o6
  %o7 = getelementptr double, double* %out, i64 7
  store double %r7, double* %o7
  ret void
}

define void @gap_off(i1 %pick, i32 %div, i32 %rem, i32 %sub, double %gamma, double* %p0, double* %p1, double* %p2, double* %p3, double* %p4, double* %p5, double* %p6, double* %p7, double* %p8, double* %p9, double* %p10, double* %p11, double* %out) {
entry:
  br i1 %pick, label %left, label %right
left:
  %mul.i310 = shl nsw i32 %div, 13
  %add.i311 = add nsw i32 %mul.i310, %sub
  %idxprom.i301 = sext i32 %add.i311 to i64
  %arrayidx.i302 = getelementptr inbounds double, double* %p8, i64 %idxprom.i301
  %v28 = load double, double* %arrayidx.i302, align 8
  %arrayidx5.i303 = getelementptr inbounds double, double* %p9, i64 %idxprom.i301
  %v29 = load double, double* %arrayidx5.i303, align 8
  %arrayidx8.i304 = getelementptr inbounds double, double* %p10, i64 %idxprom.i301
  %v30 = load double, double* %arrayidx8.i304, align 8
  %arrayidx11.i305 = getelementptr inbounds double, double* %p11, i64 %idxprom.i301
  %v31 = load double, double* %arrayidx11.i305, align 8
  %add.i300 = add nsw i32 %mul.i310, %rem
  %idxprom.i290 = sext i32 %add.i300 to i64
  %arrayidx.i291 = getelementptr inbounds double, double* %p4, i64 %idxprom.i290
  %v32 = load double, double* %arrayidx.i291, align 8
  %arrayidx5.i292 = getelementptr inbounds double, double* %p5, i64 %idxprom.i290
  %v33 = load double, double* %arrayidx5.i292, align 8
  %arrayidx8.i293 = getelementptr inbounds double, double* %p6, i64 %idxprom.i290
  %v34 = load double, double* %arrayidx8.i293, align 8
  %arrayidx11.i294 = getelementptr inbounds double, double* %p7, i64 %idxprom.i290
  %v35 = load double, double* %arrayidx11.i294, align 8
  br label %join


right:
  %mul.i53.i219 = shl nsw i32 %div, 13
  %add.i54.i220 = add nsw i32 %mul.i53.i219, %rem
  %idxprom.i44.i221 = sext i32 %add.i54.i220 to i64
  %arrayidx.i45.i222 = getelementptr inbounds double, double* %p0, i64 %idxprom.i44.i221
  %v63 = load double, double* %arrayidx.i45.i222, align 8
  %arrayidx5.i46.i223 = getelementptr inbounds double, double* %p1, i64 %idxprom.i44.i221
  %v64 = load double, double* %arrayidx5.i46.i223, align 8
  %arrayidx8.i47.i224 = getelementptr inbounds double, double* %p2, i64 %idxprom.i44.i221
  %v65 = load double, double* %arrayidx8.i47.i224, align 8
  %arrayidx11.i48.i225 = getelementptr inbounds double, double* %p3, i64 %idxprom.i44.i221
  %v66 = load double, double* %arrayidx11.i48.i225, align 8
  %cmp.i.i32.i230 = fcmp ogt double %v63, 1.000000e-25
  %cond.i.i33.i231 = select i1 %cmp.i.i32.i230, double %v63, double 1.000000e-25
  %div.i34.i232 = fdiv double 1.000000e+00, %cond.i.i33.i231
  %mul.i35.i233 = fmul double %v64, %div.i34.i232
  %mul3.i.i234 = fmul double %v65, %div.i34.i232
  %mul4.i.i235 = fmul double %cond.i.i33.i231, 5.000000e-01
  %mul5.i.i236 = fmul double %mul.i35.i233, %mul.i35.i233
  %mul6.i36.i237 = fmul double %mul3.i.i234, %mul3.i.i234
  %add.i37.i238 = fadd double %mul5.i.i236, %mul6.i36.i237
  %mul7.i38.i239 = fmul double %mul4.i.i235, %add.i37.i238
  %sub.i39.i240 = fsub double %v66, %mul7.i38.i239
  %v67 = fadd double %gamma, 0.0
  %sub8.i.i241 = fadd double %v67, -1.000000e+00
  %mul9.i.i242 = fmul double %sub8.i.i241, %sub.i39.i240
  %cmp.i15.i.i243 = fcmp ogt double %mul9.i.i242, 1.000000e-25
  %fneg.i.i249 = fneg double %mul.i35.i233
  %fneg5.i.i250 = fneg double %mul3.i.i234
  %cond.i11.i.i255 = select i1 %cmp.i15.i.i243, double %mul9.i.i242, double 1.000000e-25
  %mul.i.i256 = fmul double %cond.i.i33.i231, %fneg.i.i249
  %mul6.i.i257 = fmul double %cond.i.i33.i231, %fneg5.i.i250
  %div.i.i259 = fdiv double %cond.i11.i.i255, %sub8.i.i241
  %add15.i.i265 = fadd double %mul7.i38.i239, %div.i.i259
  br label %join


join:
  %r0 = phi double [ %v28, %left ], [ %cond.i.i33.i231, %right ]
  %r1 = phi double [ %v29, %left ], [ %mul.i.i256, %right ]
  %r2 = phi double [ %v30, %left ], [ %mul6.i.i257, %right ]
  %r3 = phi double [ %v31, %left ], [ %add15.i.i265, %right ]
  %r4 = phi double [ %v32, %left ], [ %v63, %right ]
  %r5 = phi double [ %v33, %left ], [ %v64, %right ]
  %r6 = phi double [ %v34, %left ], [ %v65, %right ]
  %r7 = phi double [ %v35, %left ], [ %v66, %right ]
  %o0 = getelementptr double, double* %out, i64 0
  store double %r0, double* %o0
  %o1 = getelementptr double, double* %out, i64 1
  store double %r1, double* %o1
  %o2 = getelementptr double, double* %out, i64 2
  store double %r2, double* %o2
  %o3 = getelementptr double, double* %out, i64 3
  store double %r3, double* %o3
  %o4 = getelementptr double, double* %out, i64 4
  store double %r4, double* %o4
  %o5 = getelementptr double, double* %out, i64 5
  store double %r5, double* %o5
  %o6 = getelementptr double, double* %out, i64 6
  store double %r6, double* %o6
  %o7 = getelementptr double, double* %out, i64 7
  store double %r7, double* %o7
  ret void
}

define void @gap_on(i1 %pick, i32 %div, i32 %rem, i32 %sub, double %gamma, double* %p0, double* %p1, double* %p2, double* %p3, double* %p4, double* %p5, double* %p6, double* %p7, double* %p8, double* %p9, double* %p10, double* %p11, double* %out) {
entry:
  br i1 %pick, label %left, label %right
left:
  %mul.i310 = shl nsw i32 %div, 13
  %add.i311 = add nsw i32 %mul.i310, %sub
  %idxprom.i301 = sext i32 %add.i311 to i64
  %arrayidx.i302 = getelementptr inbounds double, double* %p8, i64 %idxprom.i301
  %v28 = load double, double* %arrayidx.i302, align 8
  %arrayidx5.i303 = getelementptr inbounds double, double* %p9, i64 %idxprom.i301
  %v29 = load double, double* %arrayidx5.i303, align 8
  %arrayidx8.i304 = getelementptr inbounds double, double* %p10, i64 %idxprom.i301
  %v30 = load double, double* %arrayidx8.i304, align 8
  %arrayidx11.i305 = getelementptr inbounds double, double* %p11, i64 %idxprom.i301
  %v31 = load double, double* %arrayidx11.i305, align 8
  %add.i300 = add nsw i32 %mul.i310, %rem
  %idxprom.i290 = sext i32 %add.i300 to i64
  %arrayidx.i291 = getelementptr inbounds double, double* %p4, i64 %idxprom.i290
  %v32 = load double, double* %arrayidx.i291, align 8
  %arrayidx5.i292 = getelementptr inbounds double, double* %p5, i64 %idxprom.i290
  %v33 = load double, double* %arrayidx5.i292, align 8
  %arrayidx8.i293 = getelementptr inbounds double, double* %p6, i64 %idxprom.i290
  %v34 = load double, double* %arrayidx8.i293, align 8
  %arrayidx11.i294 = getelementptr inbounds double, double* %p7, i64 %idxprom.i290
  %v35 = load double, double* %arrayidx11.i294, align 8
  br label %join


right:
  %mul.i53.i219 = shl nsw i32 %div, 13
  %add.i54.i220 = add nsw i32 %mul.i53.i219, %rem
  %idxprom.i44.i221 = sext i32 %add.i54.i220 to i64
  %arrayidx.i45.i222 = getelementptr inbounds double, double* %p0, i64 %idxprom.i44.i221
  %v63 = load double, double* %arrayidx.i45.i222, align 8
  %arrayidx5.i46.i223 = getelementptr inbounds double, double* %p1, i64 %idxprom.i44.i221
  %v64 = load double, double* %arrayidx5.i46.i223, align 8
  %arrayidx8.i47.i224 = getelementptr inbounds double, double* %p2, i64 %idxprom.i44.i221
  %v65 = load double, double* %arrayidx8.i47.i224, align 8
  %arrayidx11.i48.i225 = getelementptr inbounds double, double* %p3, i64 %idxprom.i44.i221
  %v66 = load double, double* %arrayidx11.i48.i225, align 8
  %cmp.i.i32.i230 = fcmp ogt double %v63, 1.000000e-25
  %cond.i.i33.i231 = select i1 %cmp.i.i32.i230, double %v63, double 1.000000e-25
  %div.i34.i232 = fdiv double 1.000000e+00, %cond.i.i33.i231
  %mul.i35.i233 = fmul double %v64, %div.i34.i232
  %mul3.i.i234 = fmul double %v65, %div.i34.i232
  %mul4.i.i235 = fmul double %cond.i.i33.i231, 5.000000e-01
  %mul5.i.i236 = fmul double %mul.i35.i233, %mul.i35.i233
  %mul6.i36.i237 = fmul double %mul3.i.i234, %mul3.i.i234
  %add.i37.i238 = fadd double %mul5.i.i236, %mul6.i36.i237
  %mul7.i38.i239 = fmul double %mul4.i.i235, %add.i37.i238
  %sub.i39.i240 = fsub double %v66, %mul7.i38.i239
  %v67 = fadd double %gamma, 0.0
  %sub8.i.i241 = fadd double %v67, -1.000000e+00
  %mul9.i.i242 = fmul double %sub8.i.i241, %sub.i39.i240
  %cmp.i15.i.i243 = fcmp ogt double %mul9.i.i242, 1.000000e-25
  %fneg.i.i249 = fneg double %mul.i35.i233
  %fneg5.i.i250 = fneg double %mul3.i.i234
  %cond.i11.i.i255 = select i1 %cmp.i15.i.i243, double %mul9.i.i242, double 1.000000e-25
  %mul.i.i256 = fmul double %cond.i.i33.i231, %fneg.i.i249
  %mul6.i.i257 = fmul double %cond.i.i33.i231, %fneg5.i.i250
  %div.i.i259 = fdiv double %cond.i11.i.i255, %sub8.i.i241
  %add15.i.i265 = fadd double %mul7.i38.i239, %div.i.i259
  br label %join


join:
  %r0 = phi double [ %v28, %left ], [ %cond.i.i33.i231, %right ]
  %r1 = phi double [ %v29, %left ], [ %mul.i.i256, %right ]
  %r2 = phi double [ %v30, %left ], [ %mul6.i.i257, %right ]
  %r3 = phi double [ %v31, %left ], [ %add15.i.i265, %right ]
  %r4 = phi double [ %v32, %left ], [ %v63, %right ]
  %r5 = phi double [ %v33, %left ], [ %v64, %right ]
  %r6 = phi double [ %v34, %left ], [ %v65, %right ]
  %r7 = phi double [ %v35, %left ], [ %v66, %right ]
  %o0 = getelementptr double, double* %out, i64 0
  store double %r0, double* %o0
  %o1 = getelementptr double, double* %out, i64 1
  store double %r1, double* %o1
  %o2 = getelementptr double, double* %out, i64 2
  store double %r2, double* %o2
  %o3 = getelementptr double, double* %out, i64 3
  store double %r3, double* %o3
  %o4 = getelementptr double, double* %out, i64 4
  store double %r4, double* %o4
  %o5 = getelementptr double, double* %out, i64 5
  store double %r5, double* %o5
  %o6 = getelementptr double, double* %out, i64 6
  store double %r6, double* %o6
  %o7 = getelementptr double, double* %out, i64 7
  store double %r7, double* %o7
  ret void
}
