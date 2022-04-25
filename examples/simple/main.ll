; ModuleID = 'main.bc'
source_filename = "main.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 !dbg !9 {
  %1 = alloca i32*, align 8
  %2 = alloca i32*, align 8
  call void @llvm.dbg.declare(metadata i32** %1, metadata !13, metadata !DIExpression()), !dbg !15
  call void @llvm.dbg.declare(metadata i32** %2, metadata !16, metadata !DIExpression()), !dbg !17
  %3 = load i32*, i32** %1, align 8, !dbg !18
  store i32 1, i32* %3, align 4, !dbg !19
  %4 = load i32*, i32** %1, align 8, !dbg !20
  store i32* %4, i32** %2, align 8, !dbg !21
  ret i32 0, !dbg !22
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5, !6, !7}
!llvm.ident = !{!8}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 13.0.0", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "main.c", directory: "/examples/simple")
!2 = !{}
!3 = !{i32 7, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{i32 7, !"uwtable", i32 1}
!7 = !{i32 7, !"frame-pointer", i32 2}
!8 = !{!"clang version 13.0.0"}
!9 = distinct !DISubprogram(name: "main", scope: !1, file: !1, line: 1, type: !10, scopeLine: 2, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!10 = !DISubroutineType(types: !11)
!11 = !{!12}
!12 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!13 = !DILocalVariable(name: "p", scope: !9, file: !1, line: 3, type: !14)
!14 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !12, size: 64)
!15 = !DILocation(line: 3, column: 7, scope: !9)
!16 = !DILocalVariable(name: "q", scope: !9, file: !1, line: 4, type: !14)
!17 = !DILocation(line: 4, column: 7, scope: !9)
!18 = !DILocation(line: 6, column: 3, scope: !9)
!19 = !DILocation(line: 6, column: 5, scope: !9)
!20 = !DILocation(line: 7, column: 6, scope: !9)
!21 = !DILocation(line: 7, column: 4, scope: !9)
!22 = !DILocation(line: 8, column: 1, scope: !9)
