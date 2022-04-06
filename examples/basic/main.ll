; ModuleID = 'main.bc'
source_filename = "main.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @add_by_value(i32 %0, i32 %1) #0 !dbg !9 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  store i32 %0, i32* %3, align 4
  call void @llvm.dbg.declare(metadata i32* %3, metadata !13, metadata !DIExpression()), !dbg !14
  store i32 %1, i32* %4, align 4
  call void @llvm.dbg.declare(metadata i32* %4, metadata !15, metadata !DIExpression()), !dbg !16
  %5 = load i32, i32* %3, align 4, !dbg !17
  %6 = load i32, i32* %4, align 4, !dbg !18
  %7 = add nsw i32 %5, %6, !dbg !19
  ret i32 %7, !dbg !20
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32* @add_by_addr(i32* %0, i32* %1, i32* %2) #0 !dbg !21 {
  %4 = alloca i32*, align 8
  %5 = alloca i32*, align 8
  %6 = alloca i32*, align 8
  store i32* %0, i32** %4, align 8
  call void @llvm.dbg.declare(metadata i32** %4, metadata !25, metadata !DIExpression()), !dbg !26
  store i32* %1, i32** %5, align 8
  call void @llvm.dbg.declare(metadata i32** %5, metadata !27, metadata !DIExpression()), !dbg !28
  store i32* %2, i32** %6, align 8
  call void @llvm.dbg.declare(metadata i32** %6, metadata !29, metadata !DIExpression()), !dbg !30
  %7 = load i32*, i32** %4, align 8, !dbg !31
  %8 = load i32, i32* %7, align 4, !dbg !32
  %9 = load i32*, i32** %5, align 8, !dbg !33
  %10 = load i32, i32* %9, align 4, !dbg !34
  %11 = add nsw i32 %8, %10, !dbg !35
  %12 = load i32*, i32** %6, align 8, !dbg !36
  store i32 %11, i32* %12, align 4, !dbg !37
  %13 = load i32*, i32** %6, align 8, !dbg !38
  ret i32* %13, !dbg !39
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 !dbg !40 {
  %1 = alloca i32, align 4
  %2 = alloca i32*, align 8
  %3 = alloca i32*, align 8
  %4 = alloca i32*, align 8
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  call void @llvm.dbg.declare(metadata i32** %2, metadata !43, metadata !DIExpression()), !dbg !44
  call void @llvm.dbg.declare(metadata i32** %3, metadata !45, metadata !DIExpression()), !dbg !46
  call void @llvm.dbg.declare(metadata i32** %4, metadata !47, metadata !DIExpression()), !dbg !48
  call void @llvm.dbg.declare(metadata i32* %5, metadata !49, metadata !DIExpression()), !dbg !50
  call void @llvm.dbg.declare(metadata i32* %6, metadata !51, metadata !DIExpression()), !dbg !52
  call void @llvm.dbg.declare(metadata i32* %7, metadata !53, metadata !DIExpression()), !dbg !54
  store i32 42, i32* %7, align 4, !dbg !54
  store i32* %5, i32** %2, align 8, !dbg !55
  %8 = load i32*, i32** %2, align 8, !dbg !56
  store i32* %8, i32** %3, align 8, !dbg !57
  %9 = load i32*, i32** %3, align 8, !dbg !58
  %10 = load i32, i32* %9, align 4, !dbg !59
  store i32 %10, i32* %6, align 4, !dbg !60
  %11 = load i32, i32* %5, align 4, !dbg !61
  %12 = load i32, i32* %6, align 4, !dbg !62
  %13 = call i32 @add_by_value(i32 %11, i32 %12), !dbg !63
  store i32 %13, i32* %7, align 4, !dbg !64
  %14 = load i32*, i32** %3, align 8, !dbg !65
  %15 = load i32*, i32** %2, align 8, !dbg !66
  %16 = load i32*, i32** %4, align 8, !dbg !67
  %17 = call i32* @add_by_addr(i32* %14, i32* %15, i32* %16), !dbg !68
  store i32* %17, i32** %4, align 8, !dbg !69
  ret i32 0, !dbg !70
}

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5, !6, !7}
!llvm.ident = !{!8}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 13.0.0", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "main.c", directory: "/examples/basic")
!2 = !{}
!3 = !{i32 7, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{i32 7, !"uwtable", i32 1}
!7 = !{i32 7, !"frame-pointer", i32 2}
!8 = !{!"clang version 13.0.0"}
!9 = distinct !DISubprogram(name: "add_by_value", scope: !1, file: !1, line: 1, type: !10, scopeLine: 3, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!10 = !DISubroutineType(types: !11)
!11 = !{!12, !12, !12}
!12 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!13 = !DILocalVariable(name: "i", arg: 1, scope: !9, file: !1, line: 1, type: !12)
!14 = !DILocation(line: 1, column: 22, scope: !9)
!15 = !DILocalVariable(name: "j", arg: 2, scope: !9, file: !1, line: 1, type: !12)
!16 = !DILocation(line: 1, column: 29, scope: !9)
!17 = !DILocation(line: 4, column: 16, scope: !9)
!18 = !DILocation(line: 4, column: 20, scope: !9)
!19 = !DILocation(line: 4, column: 18, scope: !9)
!20 = !DILocation(line: 4, column: 9, scope: !9)
!21 = distinct !DISubprogram(name: "add_by_addr", scope: !1, file: !1, line: 7, type: !22, scopeLine: 9, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!22 = !DISubroutineType(types: !23)
!23 = !{!24, !24, !24, !24}
!24 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !12, size: 64)
!25 = !DILocalVariable(name: "a", arg: 1, scope: !21, file: !1, line: 7, type: !24)
!26 = !DILocation(line: 7, column: 23, scope: !21)
!27 = !DILocalVariable(name: "b", arg: 2, scope: !21, file: !1, line: 7, type: !24)
!28 = !DILocation(line: 7, column: 31, scope: !21)
!29 = !DILocalVariable(name: "r", arg: 3, scope: !21, file: !1, line: 7, type: !24)
!30 = !DILocation(line: 7, column: 39, scope: !21)
!31 = !DILocation(line: 10, column: 15, scope: !21)
!32 = !DILocation(line: 10, column: 14, scope: !21)
!33 = !DILocation(line: 10, column: 20, scope: !21)
!34 = !DILocation(line: 10, column: 19, scope: !21)
!35 = !DILocation(line: 10, column: 17, scope: !21)
!36 = !DILocation(line: 10, column: 10, scope: !21)
!37 = !DILocation(line: 10, column: 12, scope: !21)
!38 = !DILocation(line: 12, column: 16, scope: !21)
!39 = !DILocation(line: 12, column: 9, scope: !21)
!40 = distinct !DISubprogram(name: "main", scope: !1, file: !1, line: 15, type: !41, scopeLine: 17, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!41 = !DISubroutineType(types: !42)
!42 = !{!12}
!43 = !DILocalVariable(name: "p", scope: !40, file: !1, line: 18, type: !24)
!44 = !DILocation(line: 18, column: 14, scope: !40)
!45 = !DILocalVariable(name: "q", scope: !40, file: !1, line: 18, type: !24)
!46 = !DILocation(line: 18, column: 18, scope: !40)
!47 = !DILocalVariable(name: "r", scope: !40, file: !1, line: 18, type: !24)
!48 = !DILocation(line: 18, column: 22, scope: !40)
!49 = !DILocalVariable(name: "x", scope: !40, file: !1, line: 19, type: !12)
!50 = !DILocation(line: 19, column: 13, scope: !40)
!51 = !DILocalVariable(name: "y", scope: !40, file: !1, line: 19, type: !12)
!52 = !DILocation(line: 19, column: 16, scope: !40)
!53 = !DILocalVariable(name: "z", scope: !40, file: !1, line: 19, type: !12)
!54 = !DILocation(line: 19, column: 19, scope: !40)
!55 = !DILocation(line: 21, column: 11, scope: !40)
!56 = !DILocation(line: 22, column: 13, scope: !40)
!57 = !DILocation(line: 22, column: 11, scope: !40)
!58 = !DILocation(line: 23, column: 14, scope: !40)
!59 = !DILocation(line: 23, column: 13, scope: !40)
!60 = !DILocation(line: 23, column: 11, scope: !40)
!61 = !DILocation(line: 25, column: 26, scope: !40)
!62 = !DILocation(line: 25, column: 29, scope: !40)
!63 = !DILocation(line: 25, column: 13, scope: !40)
!64 = !DILocation(line: 25, column: 11, scope: !40)
!65 = !DILocation(line: 26, column: 25, scope: !40)
!66 = !DILocation(line: 26, column: 28, scope: !40)
!67 = !DILocation(line: 26, column: 31, scope: !40)
!68 = !DILocation(line: 26, column: 13, scope: !40)
!69 = !DILocation(line: 26, column: 11, scope: !40)
!70 = !DILocation(line: 28, column: 9, scope: !40)
