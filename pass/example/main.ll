; ModuleID = 'main.bc'
source_filename = "main.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @by_value(i32 %0, i32 %1) #0 !dbg !7 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  store i32 %0, i32* %3, align 4
  call void @llvm.dbg.declare(metadata i32* %3, metadata !11, metadata !DIExpression()), !dbg !12
  store i32 %1, i32* %4, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !13, metadata !DIExpression()), !dbg !14
  call void @llvm.dbg.declare(metadata i32* %5, metadata !15, metadata !DIExpression()), !dbg !16
  %6 = load i32, i32* %3, align 4, !dbg !17
  %7 = load i32, i32* %4, align 4, !dbg !18
  %8 = add nsw i32 %6, %7, !dbg !19
  store i32 %8, i32* %5, align 4, !dbg !16
  %9 = load i32, i32* %5, align 4, !dbg !20
  ret i32 %9, !dbg !21
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32* @by_address(i32* %0, i32* %1, i32* %2) #0 !dbg !22 {
  %4 = alloca i32*, align 8
  %5 = alloca i32*, align 8
  %6 = alloca i32*, align 8
  store i32* %0, i32** %4, align 8
  call void @llvm.dbg.declare(metadata i32** %4, metadata !26, metadata !DIExpression()), !dbg !27
  store i32* %1, i32** %5, align 8
  call void @llvm.dbg.declare(metadata i32** %5, metadata !28, metadata !DIExpression()), !dbg !29
  store i32* %2, i32** %6, align 8
  call void @llvm.dbg.declare(metadata i32** %6, metadata !30, metadata !DIExpression()), !dbg !31
  %7 = load i32*, i32** %4, align 8, !dbg !32
  %8 = load i32, i32* %7, align 4, !dbg !33
  %9 = load i32*, i32** %5, align 8, !dbg !34
  %10 = load i32, i32* %9, align 4, !dbg !35
  %11 = add nsw i32 %8, %10, !dbg !36
  %12 = load i32*, i32** %6, align 8, !dbg !37
  store i32 %11, i32* %12, align 4, !dbg !38
  %13 = load i32*, i32** %6, align 8, !dbg !39
  ret i32* %13, !dbg !40
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main(i32 %0, i8** %1) #0 !dbg !41 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i8**, align 8
  %6 = alloca i32*, align 8
  %7 = alloca i32*, align 8
  %8 = alloca i32*, align 8
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  store i32 0, i32* %3, align 4
  store i32 %0, i32* %4, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !47, metadata !DIExpression()), !dbg !48
  store i8** %1, i8*** %5, align 8
  call void @llvm.dbg.declare(metadata i8*** %5, metadata !49, metadata !DIExpression()), !dbg !50
  call void @llvm.dbg.declare(metadata i32** %6, metadata !51, metadata !DIExpression()), !dbg !52
  call void @llvm.dbg.declare(metadata i32** %7, metadata !53, metadata !DIExpression()), !dbg !54
  call void @llvm.dbg.declare(metadata i32** %8, metadata !55, metadata !DIExpression()), !dbg !56
  %11 = load i32*, i32** %6, align 8, !dbg !57
  store i32 42, i32* %11, align 4, !dbg !58
  %12 = load i32*, i32** %7, align 8, !dbg !59
  store i32 0, i32* %12, align 4, !dbg !60
  call void @llvm.dbg.declare(metadata i32* %9, metadata !61, metadata !DIExpression()), !dbg !62
  call void @llvm.dbg.declare(metadata i32* %10, metadata !63, metadata !DIExpression()), !dbg !64
  store i32 0, i32* %10, align 4, !dbg !64
  store i32 5, i32* %9, align 4, !dbg !65
  %13 = load i32, i32* %4, align 4, !dbg !66
  store i32 %13, i32* %10, align 4, !dbg !67
  %14 = load i32, i32* %10, align 4, !dbg !68
  %15 = load i32, i32* %9, align 4, !dbg !69
  %16 = mul nsw i32 %14, %15, !dbg !70
  store i32 %16, i32* %9, align 4, !dbg !71
  %17 = load i32, i32* %4, align 4, !dbg !72
  %18 = icmp sgt i32 %17, 2, !dbg !74
  br i1 %18, label %19, label %23, !dbg !75

19:                                               ; preds = %2
  %20 = load i32*, i32** %6, align 8, !dbg !76
  %21 = load i32, i32* %20, align 4, !dbg !78
  %22 = call i32 @by_value(i32 %21, i32 2), !dbg !79
  store i32 %22, i32* %9, align 4, !dbg !80
  store i32 1, i32* %10, align 4, !dbg !81
  br label %34, !dbg !82

23:                                               ; preds = %2
  %24 = load i32, i32* %4, align 4, !dbg !83
  %25 = icmp sgt i32 %24, 1, !dbg !85
  br i1 %25, label %26, label %31, !dbg !86

26:                                               ; preds = %23
  %27 = load i32*, i32** %6, align 8, !dbg !87
  %28 = load i32*, i32** %7, align 8, !dbg !89
  %29 = load i32*, i32** %8, align 8, !dbg !90
  %30 = call i32* @by_address(i32* %27, i32* %28, i32* %29), !dbg !91
  store i32* %30, i32** %7, align 8, !dbg !92
  store i32 0, i32* %10, align 4, !dbg !93
  br label %33, !dbg !94

31:                                               ; preds = %23
  %32 = load i32, i32* %10, align 4, !dbg !95
  store i32 %32, i32* %9, align 4, !dbg !97
  br label %33

33:                                               ; preds = %31, %26
  br label %34

34:                                               ; preds = %33, %19
  %35 = load i32, i32* %9, align 4, !dbg !98
  %36 = load i32, i32* %10, align 4, !dbg !99
  %37 = call i32 @by_value(i32 %35, i32 %36), !dbg !100
  ret i32 %37, !dbg !101
}

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "Ubuntu clang version 11.0.0-2~ubuntu20.04.1", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "main.c", directory: "/home/lorenz1/mlsast/misc/dot2json/example")
!2 = !{}
!3 = !{i32 7, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{!"Ubuntu clang version 11.0.0-2~ubuntu20.04.1"}
!7 = distinct !DISubprogram(name: "by_value", scope: !1, file: !1, line: 1, type: !8, scopeLine: 2, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!8 = !DISubroutineType(types: !9)
!9 = !{!10, !10, !10}
!10 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!11 = !DILocalVariable(name: "a", arg: 1, scope: !7, file: !1, line: 1, type: !10)
!12 = !DILocation(line: 1, column: 18, scope: !7)
!13 = !DILocalVariable(name: "b", arg: 2, scope: !7, file: !1, line: 1, type: !10)
!14 = !DILocation(line: 1, column: 25, scope: !7)
!15 = !DILocalVariable(name: "c", scope: !7, file: !1, line: 3, type: !10)
!16 = !DILocation(line: 3, column: 9, scope: !7)
!17 = !DILocation(line: 3, column: 13, scope: !7)
!18 = !DILocation(line: 3, column: 17, scope: !7)
!19 = !DILocation(line: 3, column: 15, scope: !7)
!20 = !DILocation(line: 5, column: 12, scope: !7)
!21 = !DILocation(line: 5, column: 5, scope: !7)
!22 = distinct !DISubprogram(name: "by_address", scope: !1, file: !1, line: 8, type: !23, scopeLine: 9, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!23 = !DISubroutineType(types: !24)
!24 = !{!25, !25, !25, !25}
!25 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !10, size: 64)
!26 = !DILocalVariable(name: "a", arg: 1, scope: !22, file: !1, line: 8, type: !25)
!27 = !DILocation(line: 8, column: 22, scope: !22)
!28 = !DILocalVariable(name: "b", arg: 2, scope: !22, file: !1, line: 8, type: !25)
!29 = !DILocation(line: 8, column: 30, scope: !22)
!30 = !DILocalVariable(name: "c", arg: 3, scope: !22, file: !1, line: 8, type: !25)
!31 = !DILocation(line: 8, column: 38, scope: !22)
!32 = !DILocation(line: 10, column: 11, scope: !22)
!33 = !DILocation(line: 10, column: 10, scope: !22)
!34 = !DILocation(line: 10, column: 16, scope: !22)
!35 = !DILocation(line: 10, column: 15, scope: !22)
!36 = !DILocation(line: 10, column: 13, scope: !22)
!37 = !DILocation(line: 10, column: 6, scope: !22)
!38 = !DILocation(line: 10, column: 8, scope: !22)
!39 = !DILocation(line: 12, column: 12, scope: !22)
!40 = !DILocation(line: 12, column: 5, scope: !22)
!41 = distinct !DISubprogram(name: "main", scope: !1, file: !1, line: 15, type: !42, scopeLine: 16, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!42 = !DISubroutineType(types: !43)
!43 = !{!10, !10, !44}
!44 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !45, size: 64)
!45 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !46, size: 64)
!46 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!47 = !DILocalVariable(name: "argc", arg: 1, scope: !41, file: !1, line: 15, type: !10)
!48 = !DILocation(line: 15, column: 14, scope: !41)
!49 = !DILocalVariable(name: "argv", arg: 2, scope: !41, file: !1, line: 15, type: !44)
!50 = !DILocation(line: 15, column: 27, scope: !41)
!51 = !DILocalVariable(name: "x", scope: !41, file: !1, line: 17, type: !25)
!52 = !DILocation(line: 17, column: 10, scope: !41)
!53 = !DILocalVariable(name: "y", scope: !41, file: !1, line: 18, type: !25)
!54 = !DILocation(line: 18, column: 10, scope: !41)
!55 = !DILocalVariable(name: "r", scope: !41, file: !1, line: 19, type: !25)
!56 = !DILocation(line: 19, column: 10, scope: !41)
!57 = !DILocation(line: 21, column: 6, scope: !41)
!58 = !DILocation(line: 21, column: 8, scope: !41)
!59 = !DILocation(line: 22, column: 6, scope: !41)
!60 = !DILocation(line: 22, column: 8, scope: !41)
!61 = !DILocalVariable(name: "u", scope: !41, file: !1, line: 24, type: !10)
!62 = !DILocation(line: 24, column: 9, scope: !41)
!63 = !DILocalVariable(name: "v", scope: !41, file: !1, line: 24, type: !10)
!64 = !DILocation(line: 24, column: 12, scope: !41)
!65 = !DILocation(line: 26, column: 7, scope: !41)
!66 = !DILocation(line: 27, column: 9, scope: !41)
!67 = !DILocation(line: 27, column: 7, scope: !41)
!68 = !DILocation(line: 28, column: 9, scope: !41)
!69 = !DILocation(line: 28, column: 13, scope: !41)
!70 = !DILocation(line: 28, column: 11, scope: !41)
!71 = !DILocation(line: 28, column: 7, scope: !41)
!72 = !DILocation(line: 30, column: 9, scope: !73)
!73 = distinct !DILexicalBlock(scope: !41, file: !1, line: 30, column: 9)
!74 = !DILocation(line: 30, column: 14, scope: !73)
!75 = !DILocation(line: 30, column: 9, scope: !41)
!76 = !DILocation(line: 31, column: 23, scope: !77)
!77 = distinct !DILexicalBlock(scope: !73, file: !1, line: 30, column: 19)
!78 = !DILocation(line: 31, column: 22, scope: !77)
!79 = !DILocation(line: 31, column: 13, scope: !77)
!80 = !DILocation(line: 31, column: 11, scope: !77)
!81 = !DILocation(line: 32, column: 11, scope: !77)
!82 = !DILocation(line: 33, column: 5, scope: !77)
!83 = !DILocation(line: 33, column: 16, scope: !84)
!84 = distinct !DILexicalBlock(scope: !73, file: !1, line: 33, column: 16)
!85 = !DILocation(line: 33, column: 21, scope: !84)
!86 = !DILocation(line: 33, column: 16, scope: !73)
!87 = !DILocation(line: 34, column: 24, scope: !88)
!88 = distinct !DILexicalBlock(scope: !84, file: !1, line: 33, column: 26)
!89 = !DILocation(line: 34, column: 27, scope: !88)
!90 = !DILocation(line: 34, column: 30, scope: !88)
!91 = !DILocation(line: 34, column: 13, scope: !88)
!92 = !DILocation(line: 34, column: 11, scope: !88)
!93 = !DILocation(line: 35, column: 11, scope: !88)
!94 = !DILocation(line: 36, column: 5, scope: !88)
!95 = !DILocation(line: 37, column: 13, scope: !96)
!96 = distinct !DILexicalBlock(scope: !84, file: !1, line: 36, column: 12)
!97 = !DILocation(line: 37, column: 11, scope: !96)
!98 = !DILocation(line: 40, column: 21, scope: !41)
!99 = !DILocation(line: 40, column: 24, scope: !41)
!100 = !DILocation(line: 40, column: 12, scope: !41)
!101 = !DILocation(line: 40, column: 5, scope: !41)
