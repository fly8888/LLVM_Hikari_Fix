; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -basicaa -slp-vectorizer -dce -S -mtriple=i386-apple-macosx10.8.0 -mcpu=corei7-avx | FileCheck %s

target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-f32:32:32-f64:32:64-v64:64:64-v128:128:128-a0:0:64-f80:128:128-n8:16:32-S128"
target triple = "i386-apple-macosx10.8.0"

define double @foo(double* nocapture %D) {
; CHECK-LABEL: @foo(
; CHECK-NEXT:    br label [[TMP1:%.*]]
; CHECK:       1:
; CHECK-NEXT:    [[I_02:%.*]] = phi i32 [ 0, [[TMP0:%.*]] ], [ [[TMP12:%.*]], [[TMP1]] ]
; CHECK-NEXT:    [[SUM_01:%.*]] = phi double [ 0.000000e+00, [[TMP0]] ], [ [[TMP11:%.*]], [[TMP1]] ]
; CHECK-NEXT:    [[TMP2:%.*]] = shl nsw i32 [[I_02]], 1
; CHECK-NEXT:    [[TMP3:%.*]] = getelementptr inbounds double, double* [[D:%.*]], i32 [[TMP2]]
; CHECK-NEXT:    [[TMP4:%.*]] = bitcast double* [[TMP3]] to <2 x double>*
; CHECK-NEXT:    [[TMP5:%.*]] = load <2 x double>, <2 x double>* [[TMP4]], align 4
; CHECK-NEXT:    [[TMP6:%.*]] = fmul <2 x double> [[TMP5]], [[TMP5]]
; CHECK-NEXT:    [[TMP7:%.*]] = fmul <2 x double> [[TMP6]], [[TMP6]]
; CHECK-NEXT:    [[TMP8:%.*]] = extractelement <2 x double> [[TMP7]], i32 0
; CHECK-NEXT:    [[TMP9:%.*]] = extractelement <2 x double> [[TMP7]], i32 1
; CHECK-NEXT:    [[TMP10:%.*]] = fadd double [[TMP8]], [[TMP9]]
; CHECK-NEXT:    [[TMP11]] = fadd double [[SUM_01]], [[TMP10]]
; CHECK-NEXT:    [[TMP12]] = add nsw i32 [[I_02]], 1
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp eq i32 [[TMP12]], 100
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[TMP13:%.*]], label [[TMP1]]
; CHECK:       13:
; CHECK-NEXT:    ret double [[TMP11]]
;
  br label %1

; <label>:1                                       ; preds = %1, %0
  %i.02 = phi i32 [ 0, %0 ], [ %10, %1 ]
  %sum.01 = phi double [ 0.000000e+00, %0 ], [ %9, %1 ]
  %2 = shl nsw i32 %i.02, 1
  %3 = getelementptr inbounds double, double* %D, i32 %2
  %4 = load double, double* %3, align 4
  %A4 = fmul double %4, %4
  %A42 = fmul double %A4, %A4
  %5 = or i32 %2, 1
  %6 = getelementptr inbounds double, double* %D, i32 %5
  %7 = load double, double* %6, align 4
  %A7 = fmul double %7, %7
  %A72 = fmul double %A7, %A7
  %8 = fadd double %A42, %A72
  %9 = fadd double %sum.01, %8
  %10 = add nsw i32 %i.02, 1
  %exitcond = icmp eq i32 %10, 100
  br i1 %exitcond, label %11, label %1

; <label>:11                                      ; preds = %1
  ret double %9
}

define i1 @two_wide_fcmp_reduction(<2 x double> %a0) {
; CHECK-LABEL: @two_wide_fcmp_reduction(
; CHECK-NEXT:    [[A:%.*]] = fcmp ogt <2 x double> [[A0:%.*]], <double 1.000000e+00, double 1.000000e+00>
; CHECK-NEXT:    [[B:%.*]] = extractelement <2 x i1> [[A]], i32 0
; CHECK-NEXT:    [[C:%.*]] = extractelement <2 x i1> [[A]], i32 1
; CHECK-NEXT:    [[D:%.*]] = and i1 [[B]], [[C]]
; CHECK-NEXT:    ret i1 [[D]]
;
  %a = fcmp ogt <2 x double> %a0, <double 1.0, double 1.0>
  %b = extractelement <2 x i1> %a, i32 0
  %c = extractelement <2 x i1> %a, i32 1
  %d = and i1 %b, %c
  ret i1 %d
}

define double @fadd_reduction(<2 x double> %a0) {
; CHECK-LABEL: @fadd_reduction(
; CHECK-NEXT:    [[A:%.*]] = fadd fast <2 x double> [[A0:%.*]], <double 1.000000e+00, double 1.000000e+00>
; CHECK-NEXT:    [[B:%.*]] = extractelement <2 x double> [[A]], i32 0
; CHECK-NEXT:    [[C:%.*]] = extractelement <2 x double> [[A]], i32 1
; CHECK-NEXT:    [[D:%.*]] = fadd fast double [[B]], [[C]]
; CHECK-NEXT:    ret double [[D]]
;
  %a = fadd fast <2 x double> %a0, <double 1.000000e+00, double 1.000000e+00>
  %b = extractelement <2 x double> %a, i32 0
  %c = extractelement <2 x double> %a, i32 1
  %d = fadd fast double %b, %c
  ret double %d
}

; PR43745 https://bugs.llvm.org/show_bug.cgi?id=43745

define i1 @fcmp_lt_gt(double %a, double %b, double %c) {
; CHECK-LABEL: @fcmp_lt_gt(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[FNEG:%.*]] = fneg double [[B:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = fmul double [[A:%.*]], 2.000000e+00
; CHECK-NEXT:    [[TMP0:%.*]] = insertelement <2 x double> undef, double [[FNEG]], i32 0
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <2 x double> [[TMP0]], double [[C:%.*]], i32 1
; CHECK-NEXT:    [[TMP2:%.*]] = insertelement <2 x double> undef, double [[C]], i32 0
; CHECK-NEXT:    [[TMP3:%.*]] = insertelement <2 x double> [[TMP2]], double [[B]], i32 1
; CHECK-NEXT:    [[TMP4:%.*]] = fsub <2 x double> [[TMP1]], [[TMP3]]
; CHECK-NEXT:    [[TMP5:%.*]] = insertelement <2 x double> undef, double [[MUL]], i32 0
; CHECK-NEXT:    [[TMP6:%.*]] = insertelement <2 x double> [[TMP5]], double [[MUL]], i32 1
; CHECK-NEXT:    [[TMP7:%.*]] = fdiv <2 x double> [[TMP4]], [[TMP6]]
; CHECK-NEXT:    [[TMP8:%.*]] = extractelement <2 x double> [[TMP7]], i32 1
; CHECK-NEXT:    [[CMP:%.*]] = fcmp olt double [[TMP8]], 0x3EB0C6F7A0B5ED8D
; CHECK-NEXT:    [[TMP9:%.*]] = extractelement <2 x double> [[TMP7]], i32 0
; CHECK-NEXT:    [[CMP4:%.*]] = fcmp olt double [[TMP9]], 0x3EB0C6F7A0B5ED8D
; CHECK-NEXT:    [[OR_COND:%.*]] = and i1 [[CMP]], [[CMP4]]
; CHECK-NEXT:    br i1 [[OR_COND]], label [[CLEANUP:%.*]], label [[LOR_LHS_FALSE:%.*]]
; CHECK:       lor.lhs.false:
; CHECK-NEXT:    [[TMP10:%.*]] = fcmp ule <2 x double> [[TMP7]], <double 1.000000e+00, double 1.000000e+00>
; CHECK-NEXT:    [[TMP11:%.*]] = extractelement <2 x i1> [[TMP10]], i32 0
; CHECK-NEXT:    [[TMP12:%.*]] = extractelement <2 x i1> [[TMP10]], i32 1
; CHECK-NEXT:    [[NOT_OR_COND9:%.*]] = or i1 [[TMP11]], [[TMP12]]
; CHECK-NEXT:    ret i1 [[NOT_OR_COND9]]
; CHECK:       cleanup:
; CHECK-NEXT:    ret i1 false
;
entry:
  %fneg = fneg double %b
  %add = fsub double %c, %b
  %mul = fmul double %a, 2.000000e+00
  %div = fdiv double %add, %mul
  %sub = fsub double %fneg, %c
  %div3 = fdiv double %sub, %mul
  %cmp = fcmp olt double %div, 0x3EB0C6F7A0B5ED8D
  %cmp4 = fcmp olt double %div3, 0x3EB0C6F7A0B5ED8D
  %or.cond = and i1 %cmp, %cmp4
  br i1 %or.cond, label %cleanup, label %lor.lhs.false

lor.lhs.false:
  %cmp5 = fcmp ule double %div, 1.000000e+00
  %cmp7 = fcmp ule double %div3, 1.000000e+00
  %not.or.cond9 = or i1 %cmp7, %cmp5
  ret i1 %not.or.cond9

cleanup:
  ret i1 false
}

define i1 @fcmp_lt(double %a, double %b, double %c) {
; CHECK-LABEL: @fcmp_lt(
; CHECK-NEXT:    [[FNEG:%.*]] = fneg double [[B:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = fmul double [[A:%.*]], 2.000000e+00
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <2 x double> undef, double [[FNEG]], i32 0
; CHECK-NEXT:    [[TMP2:%.*]] = insertelement <2 x double> [[TMP1]], double [[C:%.*]], i32 1
; CHECK-NEXT:    [[TMP3:%.*]] = insertelement <2 x double> undef, double [[C]], i32 0
; CHECK-NEXT:    [[TMP4:%.*]] = insertelement <2 x double> [[TMP3]], double [[B]], i32 1
; CHECK-NEXT:    [[TMP5:%.*]] = fsub <2 x double> [[TMP2]], [[TMP4]]
; CHECK-NEXT:    [[TMP6:%.*]] = insertelement <2 x double> undef, double [[MUL]], i32 0
; CHECK-NEXT:    [[TMP7:%.*]] = insertelement <2 x double> [[TMP6]], double [[MUL]], i32 1
; CHECK-NEXT:    [[TMP8:%.*]] = fdiv <2 x double> [[TMP5]], [[TMP7]]
; CHECK-NEXT:    [[TMP9:%.*]] = fcmp uge <2 x double> [[TMP8]], <double 0x3EB0C6F7A0B5ED8D, double 0x3EB0C6F7A0B5ED8D>
; CHECK-NEXT:    [[TMP10:%.*]] = extractelement <2 x i1> [[TMP9]], i32 0
; CHECK-NEXT:    [[TMP11:%.*]] = extractelement <2 x i1> [[TMP9]], i32 1
; CHECK-NEXT:    [[NOT_OR_COND:%.*]] = or i1 [[TMP10]], [[TMP11]]
; CHECK-NEXT:    ret i1 [[NOT_OR_COND]]
;
  %fneg = fneg double %b
  %add = fsub double %c, %b
  %mul = fmul double %a, 2.000000e+00
  %div = fdiv double %add, %mul
  %sub = fsub double %fneg, %c
  %div3 = fdiv double %sub, %mul
  %cmp = fcmp uge double %div, 0x3EB0C6F7A0B5ED8D
  %cmp4 = fcmp uge double %div3, 0x3EB0C6F7A0B5ED8D
  %not.or.cond = or i1 %cmp4, %cmp
  ret i1 %not.or.cond
}
