; ModuleID = 'main.bc'
source_filename = "main.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @by_value(i32 %0, i32 %1) #0 !dbg !9 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  store i32 %0, i32* %3, align 4
  call void @llvm.dbg.declare(metadata i32* %3, metadata !13, metadata !DIExpression()), !dbg !14
  store i32 %1, i32* %4, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !15, metadata !DIExpression()), !dbg !16
  call void @llvm.dbg.declare(metadata i32* %5, metadata !17, metadata !DIExpression()), !dbg !18
  %6 = load i32, i32* %3, align 4, !dbg !19
  %7 = load i32, i32* %4, align 4, !dbg !20
  %8 = add nsw i32 %6, %7, !dbg !21
  store i32 %8, i32* %5, align 4, !dbg !18
  %9 = load i32, i32* %5, align 4, !dbg !22
  ret i32 %9, !dbg !23
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32* @by_address(i32* %0, i32* %1, i32* %2) #0 !dbg !24 {
  %4 = alloca i32*, align 8
  %5 = alloca i32*, align 8
  %6 = alloca i32*, align 8
  store i32* %0, i32** %4, align 8
  call void @llvm.dbg.declare(metadata i32** %4, metadata !28, metadata !DIExpression()), !dbg !29
  store i32* %1, i32** %5, align 8
  call void @llvm.dbg.declare(metadata i32** %5, metadata !30, metadata !DIExpression()), !dbg !31
  store i32* %2, i32** %6, align 8
  call void @llvm.dbg.declare(metadata i32** %6, metadata !32, metadata !DIExpression()), !dbg !33
  %7 = load i32*, i32** %4, align 8, !dbg !34
  %8 = load i32, i32* %7, align 4, !dbg !35
  %9 = load i32*, i32** %5, align 8, !dbg !36
  %10 = load i32, i32* %9, align 4, !dbg !37
  %11 = add nsw i32 %8, %10, !dbg !38
  %12 = load i32*, i32** %6, align 8, !dbg !39
  store i32 %11, i32* %12, align 4, !dbg !40
  %13 = load i32*, i32** %6, align 8, !dbg !41
  ret i32* %13, !dbg !42
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main(i32 %0, i8** %1) #0 !dbg !43 {
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
  call void @llvm.dbg.declare(metadata i32* %4, metadata !49, metadata !DIExpression()), !dbg !50
  store i8** %1, i8*** %5, align 8
  call void @llvm.dbg.declare(metadata i8*** %5, metadata !51, metadata !DIExpression()), !dbg !52
  call void @llvm.dbg.declare(metadata i32** %6, metadata !53, metadata !DIExpression()), !dbg !54
  call void @llvm.dbg.declare(metadata i32** %7, metadata !55, metadata !DIExpression()), !dbg !56
  call void @llvm.dbg.declare(metadata i32** %8, metadata !57, metadata !DIExpression()), !dbg !58
  %11 = load i32*, i32** %6, align 8, !dbg !59
  store i32 42, i32* %11, align 4, !dbg !60
  %12 = load i32*, i32** %7, align 8, !dbg !61
  store i32 0, i32* %12, align 4, !dbg !62
  call void @llvm.dbg.declare(metadata i32* %9, metadata !63, metadata !DIExpression()), !dbg !64
  call void @llvm.dbg.declare(metadata i32* %10, metadata !65, metadata !DIExpression()), !dbg !66
  store i32 0, i32* %10, align 4, !dbg !66
  store i32 5, i32* %9, align 4, !dbg !67
  %13 = load i32, i32* %4, align 4, !dbg !68
  store i32 %13, i32* %10, align 4, !dbg !69
  %14 = load i32, i32* %10, align 4, !dbg !70
  %15 = load i32, i32* %9, align 4, !dbg !71
  %16 = mul nsw i32 %14, %15, !dbg !72
  store i32 %16, i32* %9, align 4, !dbg !73
  %17 = load i32, i32* %4, align 4, !dbg !74
  %18 = icmp sgt i32 %17, 2, !dbg !76
  br i1 %18, label %19, label %23, !dbg !77

19:                                               ; preds = %2
  %20 = load i32*, i32** %6, align 8, !dbg !78
  %21 = load i32, i32* %20, align 4, !dbg !80
  %22 = call i32 @by_value(i32 %21, i32 2), !dbg !81
  store i32 %22, i32* %9, align 4, !dbg !82
  store i32 1, i32* %10, align 4, !dbg !83
  br label %34, !dbg !84

23:                                               ; preds = %2
  %24 = load i32, i32* %4, align 4, !dbg !85
  %25 = icmp sgt i32 %24, 1, !dbg !87
  br i1 %25, label %26, label %31, !dbg !88

26:                                               ; preds = %23
  %27 = load i32*, i32** %6, align 8, !dbg !89
  %28 = load i32*, i32** %7, align 8, !dbg !91
  %29 = load i32*, i32** %8, align 8, !dbg !92
  %30 = call i32* @by_address(i32* %27, i32* %28, i32* %29), !dbg !93
  store i32* %30, i32** %7, align 8, !dbg !94
  store i32 0, i32* %10, align 4, !dbg !95
  br label %33, !dbg !96

31:                                               ; preds = %23
  %32 = load i32, i32* %10, align 4, !dbg !97
  store i32 %32, i32* %9, align 4, !dbg !99
  br label %33

33:                                               ; preds = %31, %26
  br label %34

34:                                               ; preds = %33, %19
  %35 = load i32, i32* %9, align 4, !dbg !100
  %36 = load i32, i32* %10, align 4, !dbg !101
  %37 = call i32 @by_value(i32 %35, i32 %36), !dbg !102
  ret i32 %37, !dbg !103
}

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5, !6, !7}
!llvm.ident = !{!8}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 13.0.0", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "main.c", directory: "/examples/fullchains")
!2 = !{}
!3 = !{i32 7, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{i32 7, !"uwtable", i32 1}
!7 = !{i32 7, !"frame-pointer", i32 2}
!8 = !{!"clang version 13.0.0"}
!9 = distinct !DISubprogram(name: "by_value", scope: !1, file: !1, line: 1, type: !10, scopeLine: 2, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!10 = !DISubroutineType(types: !11)
!11 = !{!12, !12, !12}
!12 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!13 = !DILocalVariable(name: "a", arg: 1, scope: !9, file: !1, line: 1, type: !12)
!14 = !DILocation(line: 1, column: 18, scope: !9)
!15 = !DILocalVariable(name: "b", arg: 2, scope: !9, file: !1, line: 1, type: !12)
!16 = !DILocation(line: 1, column: 25, scope: !9)
!17 = !DILocalVariable(name: "c", scope: !9, file: !1, line: 3, type: !12)
!18 = !DILocation(line: 3, column: 9, scope: !9)
!19 = !DILocation(line: 3, column: 13, scope: !9)
!20 = !DILocation(line: 3, column: 17, scope: !9)
!21 = !DILocation(line: 3, column: 15, scope: !9)
!22 = !DILocation(line: 5, column: 12, scope: !9)
!23 = !DILocation(line: 5, column: 5, scope: !9)
!24 = distinct !DISubprogram(name: "by_address", scope: !1, file: !1, line: 8, type: !25, scopeLine: 9, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!25 = !DISubroutineType(types: !26)
!26 = !{!27, !27, !27, !27}
!27 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !12, size: 64)
!28 = !DILocalVariable(name: "a", arg: 1, scope: !24, file: !1, line: 8, type: !27)
!29 = !DILocation(line: 8, column: 22, scope: !24)
!30 = !DILocalVariable(name: "b", arg: 2, scope: !24, file: !1, line: 8, type: !27)
!31 = !DILocation(line: 8, column: 30, scope: !24)
!32 = !DILocalVariable(name: "c", arg: 3, scope: !24, file: !1, line: 8, type: !27)
!33 = !DILocation(line: 8, column: 38, scope: !24)
!34 = !DILocation(line: 10, column: 11, scope: !24)
!35 = !DILocation(line: 10, column: 10, scope: !24)
!36 = !DILocation(line: 10, column: 16, scope: !24)
!37 = !DILocation(line: 10, column: 15, scope: !24)
!38 = !DILocation(line: 10, column: 13, scope: !24)
!39 = !DILocation(line: 10, column: 6, scope: !24)
!40 = !DILocation(line: 10, column: 8, scope: !24)
!41 = !DILocation(line: 12, column: 12, scope: !24)
!42 = !DILocation(line: 12, column: 5, scope: !24)
!43 = distinct !DISubprogram(name: "main", scope: !1, file: !1, line: 15, type: !44, scopeLine: 16, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!44 = !DISubroutineType(types: !45)
!45 = !{!12, !12, !46}
!46 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !47, size: 64)
!47 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !48, size: 64)
!48 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!49 = !DILocalVariable(name: "argc", arg: 1, scope: !43, file: !1, line: 15, type: !12)
!50 = !DILocation(line: 15, column: 14, scope: !43)
!51 = !DILocalVariable(name: "argv", arg: 2, scope: !43, file: !1, line: 15, type: !46)
!52 = !DILocation(line: 15, column: 27, scope: !43)
!53 = !DILocalVariable(name: "x", scope: !43, file: !1, line: 17, type: !27)
!54 = !DILocation(line: 17, column: 10, scope: !43)
!55 = !DILocalVariable(name: "y", scope: !43, file: !1, line: 18, type: !27)
!56 = !DILocation(line: 18, column: 10, scope: !43)
!57 = !DILocalVariable(name: "r", scope: !43, file: !1, line: 19, type: !27)
!58 = !DILocation(line: 19, column: 10, scope: !43)
!59 = !DILocation(line: 21, column: 6, scope: !43)
!60 = !DILocation(line: 21, column: 8, scope: !43)
!61 = !DILocation(line: 22, column: 6, scope: !43)
!62 = !DILocation(line: 22, column: 8, scope: !43)
!63 = !DILocalVariable(name: "u", scope: !43, file: !1, line: 24, type: !12)
!64 = !DILocation(line: 24, column: 9, scope: !43)
!65 = !DILocalVariable(name: "v", scope: !43, file: !1, line: 24, type: !12)
!66 = !DILocation(line: 24, column: 12, scope: !43)
!67 = !DILocation(line: 26, column: 7, scope: !43)
!68 = !DILocation(line: 27, column: 9, scope: !43)
!69 = !DILocation(line: 27, column: 7, scope: !43)
!70 = !DILocation(line: 28, column: 9, scope: !43)
!71 = !DILocation(line: 28, column: 13, scope: !43)
!72 = !DILocation(line: 28, column: 11, scope: !43)
!73 = !DILocation(line: 28, column: 7, scope: !43)
!74 = !DILocation(line: 30, column: 9, scope: !75)
!75 = distinct !DILexicalBlock(scope: !43, file: !1, line: 30, column: 9)
!76 = !DILocation(line: 30, column: 14, scope: !75)
!77 = !DILocation(line: 30, column: 9, scope: !43)
!78 = !DILocation(line: 31, column: 23, scope: !79)
!79 = distinct !DILexicalBlock(scope: !75, file: !1, line: 30, column: 19)
!80 = !DILocation(line: 31, column: 22, scope: !79)
!81 = !DILocation(line: 31, column: 13, scope: !79)
!82 = !DILocation(line: 31, column: 11, scope: !79)
!83 = !DILocation(line: 32, column: 11, scope: !79)
!84 = !DILocation(line: 33, column: 5, scope: !79)
!85 = !DILocation(line: 33, column: 16, scope: !86)
!86 = distinct !DILexicalBlock(scope: !75, file: !1, line: 33, column: 16)
!87 = !DILocation(line: 33, column: 21, scope: !86)
!88 = !DILocation(line: 33, column: 16, scope: !75)
!89 = !DILocation(line: 34, column: 24, scope: !90)
!90 = distinct !DILexicalBlock(scope: !86, file: !1, line: 33, column: 26)
!91 = !DILocation(line: 34, column: 27, scope: !90)
!92 = !DILocation(line: 34, column: 30, scope: !90)
!93 = !DILocation(line: 34, column: 13, scope: !90)
!94 = !DILocation(line: 34, column: 11, scope: !90)
!95 = !DILocation(line: 35, column: 11, scope: !90)
!96 = !DILocation(line: 36, column: 5, scope: !90)
!97 = !DILocation(line: 37, column: 13, scope: !98)
!98 = distinct !DILexicalBlock(scope: !86, file: !1, line: 36, column: 12)
!99 = !DILocation(line: 37, column: 11, scope: !98)
!100 = !DILocation(line: 40, column: 21, scope: !43)
!101 = !DILocation(line: 40, column: 24, scope: !43)
!102 = !DILocation(line: 40, column: 12, scope: !43)
!103 = !DILocation(line: 40, column: 5, scope: !43)
