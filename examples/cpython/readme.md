# CPython Example

Zum Testen von DG wähle ich die CPython-Implementierung. Ich baue das
Programm mit _wllvm_, ein Wrapper für LLVM der es erlaubt, herkömmliche
C- und C++-Projekte mit wenig Aufwand in LLVM-IR zu übersetzen, siehe
[WLLVM](https://github.com/SRI-CSL/whole-program-llvm). Die von mir
verwendete Python-Version ist
[hier](https://github.com/python/cpython/tree/df9f759)
auffindbar.


Nach dem Bauen und Linken des Python-Interpreters habe ich zunächst
nach geeigneten Slicing-Kriterien um das Tool zu testen. Ich wähle an
dieser Stelle zunächst die Datei _Python/getopt.c_, da diese etwas
übersichtlicher ist und dort die Variable `option` in der Funktion
`＿PyOS＿GetOpt＿`. Die Variable wird in Zeile 63 deklariert und in
Zeile 98 das erste Mal definiert sowie benutzt. Um sicherzustellen, dass
die Variable an dem betrachteten Punkt im Programm definitiv definiert
ist verwende ich Zeile 110 als Kriterium.

Ich prüfe nun anhand des Bitcodes, den ich zuvor in eine lesbare Form
übersetzt habe, ob meine Angaben auffindbar sein sollten indem ich die
Debug-Informationen betrachte und finde den Eintrag für
_"Python/getopt.c"_. Ferner ist dort ebenfalls der Eintrag für die
Deklaration der Variable `option`

```
!158879 = !DIFile(filename: "Python/getopt.c", directory: "/home/lorenz1/Downloads/cpython")

...

!667221 = !DILocalVariable(name: "option", scope: !667210, file: !158879, line: 63, type: !565)
```

Ein Blick in den Quellcode zeigt, dass der Eintrag korrekt ist:

``` 
int _PyOS_GetOpt(Py_ssize_t argc, wchar_t * const *argv, int *longindex)
{
62  wchar_t *ptr;
63  wchar_t option;
64  
65  if (*opt_ptr == '\0') {
```

Nun, rufe ich den `llvm-slicer` wie folgt auf:

``
llvm-slicer -sc "Python/getopt.c#_PyOS_GetOpt#110#&option" python.bc
No reachable slicing criteria: 'Python/getopt.c#_PyOS_GetOpt#72#&option' ''
[llvm-slicer] saving sliced module to: python.sliced
```

Das Tool ist nicht in der Lage, dass Kriterium ausfindig zu machen,
weshalb ich einen weiteren Versuch wage. Ich entscheide mich für die
Datei _Python/hashtable.c_, da ich davon ausgehe, dass die
Implementierung einer Hashtable vermutlich nur wenige Abhängigkeiten hat
und größtenteils autonom sein sollte. Die Slices sollten entsprechend
klein ausfallen. Ich prüfe erneut die Debug-Informationen und finde den
Eintrag für die Datei.

```
!216196 = !DIFile(filename: "Python/hashtable.c", directory: "/home/lorenz1/Downloads/cpython")
```

Bezüglich des Kriteriums, entscheide ich mich für den Parameter `key`
der Funktion `＿Py＿hashtable＿steal` und prüfe dessen Existenz in den
Debug-Informationen:

```
!616955 = distinct !DISubprogram(name: "_Py_hashtable_steal", scope: !216196, file: !216196, line: 174, type: !616956, scopeLine: 175, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !216195, retainedNodes: !4)

...

!616873 = !DILocalVariable(name: "key", arg: 1, scope: !616872, file: !216196, line: 92, type: !8765)
```

Die Funktion endet in Zeile 205, welche ich für das Kriterium wähle.
Leider kann das Tool das Slicing-Kriterium erneut nicht auffinden. Aus
diesem Grund versuche ich einen zweiten Anlauf und wähle dieses Mal
Zeile 300, um auszuschließen, dass das Tool möglicherweise Probleme hat
die Zeile zu finden. DG ist nun in der Lage ein Kriterium zu finden,
wenn auch das Falsche. Nach kurzer Zeit kommt es jedoch zu einem
Segmentation-Fault und das Programm bricht ab, ein häufig beobachtetes
Verhalten. Dem Stacktrace zur Folge, scheint das Problem auf die
Points-To-Analyse zurückzuführen zu sein. Das deaktivieren der
Field-sensitiven Analyse, sowie die Verwendung der Flow-sensitiven
Analyse zeigten keine Veränderungen.

```
lorenz1@stw10:~/mlsast/misc/slicing/examples/cpython$ llvm-slicer -sc "Python/hashtable.c#_Py_hashtable_steal#300#&key" python.bc
SC: Matched 'Python/hashtable.c#_Py_hashtable_steal#300#&key' to: 
    %109 = load i64, i64* %108, align 8, !dbg !308364, !tbaa !308245
[llvm-slicer] cutoff 89 diverging blocks and 13 completely removed
WARNING: Non-0 memset:   tail call void @llvm.memset.p0i8.i64(i8* nonnull align 8 %54, i8 -1, i64 %56, i1 false), !dbg !308319
WARNING: Non-0 memset:   call void @llvm.memset.p0i8.i64(i8* align 1 %27, i8 63, i64 %110, i1 false), !dbg !308347
WARNING: Non-0 memset:   call void @llvm.memset.p0i8.i64(i8* align 1 %65, i8 63, i64 %140, i1 false), !dbg !308340
  %38 = insertvalue { double, double } undef, double %36, 0, !dbg !308279
  %39 = insertvalue { double, double } %38, double %37, 1, !dbg !308279
WARN: Unsupported return of an aggregate type
  ret { double, double } %39, !dbg !308279
ShuffleVector instruction is not supported, loosing precision
ShuffleVector instruction is not supported, loosing precision
ShuffleVector instruction is not supported, loosing precision
ShuffleVector instruction is not supported, loosing precision
PTA: Inline assembly found, analysis  may be unsound
WARNING: Non-0 memset:   call void @llvm.memset.p0i8.i64(i8* nonnull align 1 dereferenceable(64) %120, i8 %119, i64 64, i1 false), !dbg !308399
WARNING: Non-0 memset:   call void @llvm.memset.p0i8.i64(i8* nonnull align 1 dereferenceable(64) %120, i8 %119, i64 64, i1 false), !dbg !308398
WARNING: Non-0 memset:   call void @llvm.memset.p0i8.i64(i8* nonnull align 1 dereferenceable(64) %117, i8 %116, i64 64, i1 false), !dbg !308395
WARNING: Non-0 memset:   call void @llvm.memset.p0i8.i64(i8* nonnull align 1 dereferenceable(64) %117, i8 %116, i64 64, i1 false), !dbg !308395
ShuffleVector instruction is not supported, loosing precision
ShuffleVector instruction is not supported, loosing precision
WARNING: Non-0 memset:   call void @llvm.memset.p0i8.i64(i8* align 1 %27, i8 63, i64 %130, i1 false), !dbg !308351
  #0 0x00007f52e1fa542f llvm::sys::PrintStackTrace(llvm::raw_ostream&) (/lib/x86_64-linux-gnu/libLLVM-11.so.1+0xaa642f)
  #1 0x00007f52e1fa3762 llvm::sys::RunSignalHandlers() (/lib/x86_64-linux-gnu/libLLVM-11.so.1+0xaa4762)
  #2 0x00007f52e1fa5905 (/lib/x86_64-linux-gnu/libLLVM-11.so.1+0xaa6905)
  #3 0x00007f52e116e0c0 (/lib/x86_64-linux-gnu/libc.so.6+0x430c0)
  #4 0x00007f52e64e7b8f __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
  #5 0x00007f52e64e7b8f std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
  #6 0x00007f52e64e7b8f dg::SubgraphNode<dg::pta::PSNode>::addUser(dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/include/dg/SubgraphNode.h:399:9
  #7 0x00007f52e64e7b8f unsigned long dg::SubgraphNode<dg::pta::PSNode>::addOperand<dg::pta::PSNode*, dg::pta::PSNode>(dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/include/dg/SubgraphNode.h:152:9
  #8 0x00007f52e64e7b8f unsigned long dg::SubgraphNode<dg::pta::PSNode>::addOperand<dg::pta::PSNode*, dg::pta::PSNode*&>(dg::pta::PSNode*, dg::pta::PSNode*&) /home/lorenz1/mlsast/misc/tools/dg/include/dg/SubgraphNode.h:139:9
  #9 0x00007f52e64e7b8f dg::pta::PSNode::PSNode<dg::pta::PSNode*&, dg::pta::PSNode*&>(unsigned int, dg::pta::PSNodeType, dg::pta::PSNode*&, dg::pta::PSNode*&) /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PSNode.h:207:9
 #10 0x00007f52e64e7b8f dg::pta::PSNodeMemcpy::PSNodeMemcpy(unsigned int, dg::pta::PSNode*, dg::pta::PSNode*, dg::Offset) /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PSNode.h:390:65
 #11 0x00007f52e64e7b8f _ZN2dg3pta12PointerGraph11nodeFactoryILNS0_10PSNodeTypeE20EJRPNS0_11PSNodeAllocES6_RKmENS0_12PSNodeMemcpyEEENSt9enable_ifIXntsrSt7is_sameIT1_NS0_6PSNodeEE5valueEPSC_E4typeEDpOT0_ /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:149:16
 #12 0x00007f52e64e7b8f dg::pta::PSNode* dg::pta::PointerGraph::create<(dg::pta::PSNodeType)20, dg::pta::PSNodeAlloc*&, dg::pta::PSNodeAlloc*&, unsigned long const&>(dg::pta::PSNodeAlloc*&, dg::pta::PSNodeAlloc*&, unsigned long const&) /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:188:17
 #13 0x00007f52e64e7b8f dg::pta::LLVMPointerGraphBuilder::createInsertElement(llvm::Instruction const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Instructions.cpp:389:50
 #14 0x00007f52e64d8016 __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
 #15 0x00007f52e64d8016 std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
 #16 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::PSNodesSeq::begin() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:84:56
 #17 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::buildPointerGraphBlock(llvm::BasicBlock const&, dg::pta::PointerSubgraph*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Block.cpp:49:25
 #18 0x00007f52e64d20f6 std::vector<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*, std::allocator<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*> >::empty() const /usr/include/c++/9/bits/stl_vector.h:1005:24
 #19 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::PSNodesBlock::empty() const /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:98:49
 #20 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::buildFunction(llvm::Function const&) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:584:22
 #21 0x00007f52e64d258b dg::pta::LLVMPointerGraphBuilder::createOrGetSubgraph(llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:238:9
 #22 0x00007f52e64d3606 dg::pta::LLVMPointerGraphBuilder::getAndConnectSubgraph(llvm::Function const*, llvm::CallInst const*, dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:110:50
 #23 0x00007f52e64d3d9b _ZN2dg3pta12PointerGraph11nodeFactoryILNS0_10PSNodeTypeE10EJENS0_13PSNodeCallRetEEENSt9enable_ifIXntsrSt7is_sameIT1_NS0_6PSNodeEE5valueEPS7_E4typeEDpOT0_ /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:149:16
 #24 0x00007f52e64d3d9b dg::pta::PSNode* dg::pta::PointerGraph::create<(dg::pta::PSNodeType)10>() /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:188:17
 #25 0x00007f52e64d3d9b dg::pta::LLVMPointerGraphBuilder::createCallToFunction(llvm::CallInst const*, llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:137:31
 #26 0x00007f52e64edee5 dg::pta::LLVMPointerGraphBuilder::createCall(llvm::Instruction const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Calls.cpp:33:1
 #27 0x00007f52e64d8016 __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
 #28 0x00007f52e64d8016 std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
 #29 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::PSNodesSeq::begin() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:84:56
 #30 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::buildPointerGraphBlock(llvm::BasicBlock const&, dg::pta::PointerSubgraph*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Block.cpp:49:25
 #31 0x00007f52e64d20f6 std::vector<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*, std::allocator<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*> >::empty() const /usr/include/c++/9/bits/stl_vector.h:1005:24
 #32 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::PSNodesBlock::empty() const /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:98:49
 #33 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::buildFunction(llvm::Function const&) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:584:22
 #34 0x00007f52e64d258b dg::pta::LLVMPointerGraphBuilder::createOrGetSubgraph(llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:238:9
 #35 0x00007f52e64d3606 dg::pta::LLVMPointerGraphBuilder::getAndConnectSubgraph(llvm::Function const*, llvm::CallInst const*, dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:110:50
 #36 0x00007f52e64d3d9b _ZN2dg3pta12PointerGraph11nodeFactoryILNS0_10PSNodeTypeE10EJENS0_13PSNodeCallRetEEENSt9enable_ifIXntsrSt7is_sameIT1_NS0_6PSNodeEE5valueEPS7_E4typeEDpOT0_ /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:149:16
 #37 0x00007f52e64d3d9b dg::pta::PSNode* dg::pta::PointerGraph::create<(dg::pta::PSNodeType)10>() /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:188:17
 #38 0x00007f52e64d3d9b dg::pta::LLVMPointerGraphBuilder::createCallToFunction(llvm::CallInst const*, llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:137:31
 #39 0x00007f52e64edee5 dg::pta::LLVMPointerGraphBuilder::createCall(llvm::Instruction const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Calls.cpp:33:1
 #40 0x00007f52e64d8016 __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
 #41 0x00007f52e64d8016 std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
 #42 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::PSNodesSeq::begin() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:84:56
 #43 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::buildPointerGraphBlock(llvm::BasicBlock const&, dg::pta::PointerSubgraph*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Block.cpp:49:25
 #44 0x00007f52e64d20f6 std::vector<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*, std::allocator<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*> >::empty() const /usr/include/c++/9/bits/stl_vector.h:1005:24
 #45 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::PSNodesBlock::empty() const /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:98:49
 #46 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::buildFunction(llvm::Function const&) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:584:22
 #47 0x00007f52e64d258b dg::pta::LLVMPointerGraphBuilder::createOrGetSubgraph(llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:238:9
 #48 0x00007f52e64d3606 dg::pta::LLVMPointerGraphBuilder::getAndConnectSubgraph(llvm::Function const*, llvm::CallInst const*, dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:110:50
 #49 0x00007f52e64d3d9b _ZN2dg3pta12PointerGraph11nodeFactoryILNS0_10PSNodeTypeE10EJENS0_13PSNodeCallRetEEENSt9enable_ifIXntsrSt7is_sameIT1_NS0_6PSNodeEE5valueEPS7_E4typeEDpOT0_ /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:149:16
 #50 0x00007f52e64d3d9b dg::pta::PSNode* dg::pta::PointerGraph::create<(dg::pta::PSNodeType)10>() /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:188:17
 #51 0x00007f52e64d3d9b dg::pta::LLVMPointerGraphBuilder::createCallToFunction(llvm::CallInst const*, llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:137:31
 #52 0x00007f52e64edee5 dg::pta::LLVMPointerGraphBuilder::createCall(llvm::Instruction const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Calls.cpp:33:1
 #53 0x00007f52e64d8016 __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
 #54 0x00007f52e64d8016 std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
 #55 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::PSNodesSeq::begin() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:84:56
 #56 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::buildPointerGraphBlock(llvm::BasicBlock const&, dg::pta::PointerSubgraph*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Block.cpp:49:25
 #57 0x00007f52e64d20f6 std::vector<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*, std::allocator<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*> >::empty() const /usr/include/c++/9/bits/stl_vector.h:1005:24
 #58 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::PSNodesBlock::empty() const /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:98:49
 #59 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::buildFunction(llvm::Function const&) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:584:22
 #60 0x00007f52e64d258b dg::pta::LLVMPointerGraphBuilder::createOrGetSubgraph(llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:238:9
 #61 0x00007f52e64d3606 dg::pta::LLVMPointerGraphBuilder::getAndConnectSubgraph(llvm::Function const*, llvm::CallInst const*, dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:110:50
 #62 0x00007f52e64d3d9b _ZN2dg3pta12PointerGraph11nodeFactoryILNS0_10PSNodeTypeE10EJENS0_13PSNodeCallRetEEENSt9enable_ifIXntsrSt7is_sameIT1_NS0_6PSNodeEE5valueEPS7_E4typeEDpOT0_ /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:149:16
 #63 0x00007f52e64d3d9b dg::pta::PSNode* dg::pta::PointerGraph::create<(dg::pta::PSNodeType)10>() /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:188:17
 #64 0x00007f52e64d3d9b dg::pta::LLVMPointerGraphBuilder::createCallToFunction(llvm::CallInst const*, llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:137:31
 #65 0x00007f52e64edee5 dg::pta::LLVMPointerGraphBuilder::createCall(llvm::Instruction const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Calls.cpp:33:1
 #66 0x00007f52e64d8016 __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
 #67 0x00007f52e64d8016 std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
 #68 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::PSNodesSeq::begin() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:84:56
 #69 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::buildPointerGraphBlock(llvm::BasicBlock const&, dg::pta::PointerSubgraph*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Block.cpp:49:25
 #70 0x00007f52e64d20f6 std::vector<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*, std::allocator<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*> >::empty() const /usr/include/c++/9/bits/stl_vector.h:1005:24
 #71 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::PSNodesBlock::empty() const /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:98:49
 #72 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::buildFunction(llvm::Function const&) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:584:22
 #73 0x00007f52e64d258b dg::pta::LLVMPointerGraphBuilder::createOrGetSubgraph(llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:238:9
 #74 0x00007f52e64d3606 dg::pta::LLVMPointerGraphBuilder::getAndConnectSubgraph(llvm::Function const*, llvm::CallInst const*, dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:110:50
 #75 0x00007f52e64d3d9b _ZN2dg3pta12PointerGraph11nodeFactoryILNS0_10PSNodeTypeE10EJENS0_13PSNodeCallRetEEENSt9enable_ifIXntsrSt7is_sameIT1_NS0_6PSNodeEE5valueEPS7_E4typeEDpOT0_ /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:149:16
 #76 0x00007f52e64d3d9b dg::pta::PSNode* dg::pta::PointerGraph::create<(dg::pta::PSNodeType)10>() /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:188:17
 #77 0x00007f52e64d3d9b dg::pta::LLVMPointerGraphBuilder::createCallToFunction(llvm::CallInst const*, llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:137:31
 #78 0x00007f52e64edee5 dg::pta::LLVMPointerGraphBuilder::createCall(llvm::Instruction const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Calls.cpp:33:1
 #79 0x00007f52e64d8016 __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
 #80 0x00007f52e64d8016 std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
 #81 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::PSNodesSeq::begin() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:84:56
 #82 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::buildPointerGraphBlock(llvm::BasicBlock const&, dg::pta::PointerSubgraph*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Block.cpp:49:25
 #83 0x00007f52e64d20f6 std::vector<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*, std::allocator<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*> >::empty() const /usr/include/c++/9/bits/stl_vector.h:1005:24
 #84 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::PSNodesBlock::empty() const /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:98:49
 #85 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::buildFunction(llvm::Function const&) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:584:22
 #86 0x00007f52e64d258b dg::pta::LLVMPointerGraphBuilder::createOrGetSubgraph(llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:238:9
 #87 0x00007f52e64d3606 dg::pta::LLVMPointerGraphBuilder::getAndConnectSubgraph(llvm::Function const*, llvm::CallInst const*, dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:110:50
 #88 0x00007f52e64d3d9b _ZN2dg3pta12PointerGraph11nodeFactoryILNS0_10PSNodeTypeE10EJENS0_13PSNodeCallRetEEENSt9enable_ifIXntsrSt7is_sameIT1_NS0_6PSNodeEE5valueEPS7_E4typeEDpOT0_ /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:149:16
 #89 0x00007f52e64d3d9b dg::pta::PSNode* dg::pta::PointerGraph::create<(dg::pta::PSNodeType)10>() /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:188:17
 #90 0x00007f52e64d3d9b dg::pta::LLVMPointerGraphBuilder::createCallToFunction(llvm::CallInst const*, llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:137:31
 #91 0x00007f52e64edee5 dg::pta::LLVMPointerGraphBuilder::createCall(llvm::Instruction const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Calls.cpp:33:1
 #92 0x00007f52e64d8016 __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
 #93 0x00007f52e64d8016 std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
 #94 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::PSNodesSeq::begin() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:84:56
 #95 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::buildPointerGraphBlock(llvm::BasicBlock const&, dg::pta::PointerSubgraph*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Block.cpp:49:25
 #96 0x00007f52e64d20f6 std::vector<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*, std::allocator<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*> >::empty() const /usr/include/c++/9/bits/stl_vector.h:1005:24
 #97 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::PSNodesBlock::empty() const /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:98:49
 #98 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::buildFunction(llvm::Function const&) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:584:22
 #99 0x00007f52e64d258b dg::pta::LLVMPointerGraphBuilder::createOrGetSubgraph(llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:238:9
#100 0x00007f52e64d3606 dg::pta::LLVMPointerGraphBuilder::getAndConnectSubgraph(llvm::Function const*, llvm::CallInst const*, dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:110:50
#101 0x00007f52e64d3d9b _ZN2dg3pta12PointerGraph11nodeFactoryILNS0_10PSNodeTypeE10EJENS0_13PSNodeCallRetEEENSt9enable_ifIXntsrSt7is_sameIT1_NS0_6PSNodeEE5valueEPS7_E4typeEDpOT0_ /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:149:16
#102 0x00007f52e64d3d9b dg::pta::PSNode* dg::pta::PointerGraph::create<(dg::pta::PSNodeType)10>() /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:188:17
#103 0x00007f52e64d3d9b dg::pta::LLVMPointerGraphBuilder::createCallToFunction(llvm::CallInst const*, llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:137:31
#104 0x00007f52e64edee5 dg::pta::LLVMPointerGraphBuilder::createCall(llvm::Instruction const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Calls.cpp:33:1
#105 0x00007f52e64d8016 __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
#106 0x00007f52e64d8016 std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
#107 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::PSNodesSeq::begin() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:84:56
#108 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::buildPointerGraphBlock(llvm::BasicBlock const&, dg::pta::PointerSubgraph*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Block.cpp:49:25
#109 0x00007f52e64d20f6 std::vector<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*, std::allocator<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*> >::empty() const /usr/include/c++/9/bits/stl_vector.h:1005:24
#110 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::PSNodesBlock::empty() const /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:98:49
#111 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::buildFunction(llvm::Function const&) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:584:22
#112 0x00007f52e64d258b dg::pta::LLVMPointerGraphBuilder::createOrGetSubgraph(llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:238:9
#113 0x00007f52e64d3606 dg::pta::LLVMPointerGraphBuilder::getAndConnectSubgraph(llvm::Function const*, llvm::CallInst const*, dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:110:50
#114 0x00007f52e64d3d9b _ZN2dg3pta12PointerGraph11nodeFactoryILNS0_10PSNodeTypeE10EJENS0_13PSNodeCallRetEEENSt9enable_ifIXntsrSt7is_sameIT1_NS0_6PSNodeEE5valueEPS7_E4typeEDpOT0_ /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:149:16
#115 0x00007f52e64d3d9b dg::pta::PSNode* dg::pta::PointerGraph::create<(dg::pta::PSNodeType)10>() /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:188:17
#116 0x00007f52e64d3d9b dg::pta::LLVMPointerGraphBuilder::createCallToFunction(llvm::CallInst const*, llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:137:31
#117 0x00007f52e64edee5 dg::pta::LLVMPointerGraphBuilder::createCall(llvm::Instruction const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Calls.cpp:33:1
#118 0x00007f52e64d8016 __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
#119 0x00007f52e64d8016 std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
#120 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::PSNodesSeq::begin() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:84:56
#121 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::buildPointerGraphBlock(llvm::BasicBlock const&, dg::pta::PointerSubgraph*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Block.cpp:49:25
#122 0x00007f52e64d20f6 std::vector<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*, std::allocator<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*> >::empty() const /usr/include/c++/9/bits/stl_vector.h:1005:24
#123 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::PSNodesBlock::empty() const /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:98:49
#124 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::buildFunction(llvm::Function const&) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:584:22
#125 0x00007f52e64d258b dg::pta::LLVMPointerGraphBuilder::createOrGetSubgraph(llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:238:9
#126 0x00007f52e64d3606 dg::pta::LLVMPointerGraphBuilder::getAndConnectSubgraph(llvm::Function const*, llvm::CallInst const*, dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:110:50
#127 0x00007f52e64d3d9b _ZN2dg3pta12PointerGraph11nodeFactoryILNS0_10PSNodeTypeE10EJENS0_13PSNodeCallRetEEENSt9enable_ifIXntsrSt7is_sameIT1_NS0_6PSNodeEE5valueEPS7_E4typeEDpOT0_ /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:149:16
#128 0x00007f52e64d3d9b dg::pta::PSNode* dg::pta::PointerGraph::create<(dg::pta::PSNodeType)10>() /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:188:17
#129 0x00007f52e64d3d9b dg::pta::LLVMPointerGraphBuilder::createCallToFunction(llvm::CallInst const*, llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:137:31
#130 0x00007f52e64edee5 dg::pta::LLVMPointerGraphBuilder::createCall(llvm::Instruction const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Calls.cpp:33:1
#131 0x00007f52e64d8016 __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
#132 0x00007f52e64d8016 std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
#133 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::PSNodesSeq::begin() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:84:56
#134 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::buildPointerGraphBlock(llvm::BasicBlock const&, dg::pta::PointerSubgraph*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Block.cpp:49:25
#135 0x00007f52e64d20f6 std::vector<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*, std::allocator<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*> >::empty() const /usr/include/c++/9/bits/stl_vector.h:1005:24
#136 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::PSNodesBlock::empty() const /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:98:49
#137 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::buildFunction(llvm::Function const&) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:584:22
#138 0x00007f52e64d258b dg::pta::LLVMPointerGraphBuilder::createOrGetSubgraph(llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:238:9
#139 0x00007f52e64d3606 dg::pta::LLVMPointerGraphBuilder::getAndConnectSubgraph(llvm::Function const*, llvm::CallInst const*, dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:110:50
#140 0x00007f52e64d3d9b _ZN2dg3pta12PointerGraph11nodeFactoryILNS0_10PSNodeTypeE10EJENS0_13PSNodeCallRetEEENSt9enable_ifIXntsrSt7is_sameIT1_NS0_6PSNodeEE5valueEPS7_E4typeEDpOT0_ /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:149:16
#141 0x00007f52e64d3d9b dg::pta::PSNode* dg::pta::PointerGraph::create<(dg::pta::PSNodeType)10>() /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:188:17
#142 0x00007f52e64d3d9b dg::pta::LLVMPointerGraphBuilder::createCallToFunction(llvm::CallInst const*, llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:137:31
#143 0x00007f52e64edee5 dg::pta::LLVMPointerGraphBuilder::createCall(llvm::Instruction const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Calls.cpp:33:1
#144 0x00007f52e64d8016 __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
#145 0x00007f52e64d8016 std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
#146 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::PSNodesSeq::begin() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:84:56
#147 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::buildPointerGraphBlock(llvm::BasicBlock const&, dg::pta::PointerSubgraph*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Block.cpp:49:25
#148 0x00007f52e64d20f6 std::vector<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*, std::allocator<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*> >::empty() const /usr/include/c++/9/bits/stl_vector.h:1005:24
#149 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::PSNodesBlock::empty() const /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:98:49
#150 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::buildFunction(llvm::Function const&) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:584:22
#151 0x00007f52e64d258b dg::pta::LLVMPointerGraphBuilder::createOrGetSubgraph(llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:238:9
#152 0x00007f52e64d3606 dg::pta::LLVMPointerGraphBuilder::getAndConnectSubgraph(llvm::Function const*, llvm::CallInst const*, dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:110:50
#153 0x00007f52e64d3d9b _ZN2dg3pta12PointerGraph11nodeFactoryILNS0_10PSNodeTypeE10EJENS0_13PSNodeCallRetEEENSt9enable_ifIXntsrSt7is_sameIT1_NS0_6PSNodeEE5valueEPS7_E4typeEDpOT0_ /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:149:16
#154 0x00007f52e64d3d9b dg::pta::PSNode* dg::pta::PointerGraph::create<(dg::pta::PSNodeType)10>() /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:188:17
#155 0x00007f52e64d3d9b dg::pta::LLVMPointerGraphBuilder::createCallToFunction(llvm::CallInst const*, llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:137:31
#156 0x00007f52e64edee5 dg::pta::LLVMPointerGraphBuilder::createCall(llvm::Instruction const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Calls.cpp:33:1
#157 0x00007f52e64d8016 __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
#158 0x00007f52e64d8016 std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
#159 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::PSNodesSeq::begin() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:84:56
#160 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::buildPointerGraphBlock(llvm::BasicBlock const&, dg::pta::PointerSubgraph*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Block.cpp:49:25
#161 0x00007f52e64d20f6 std::vector<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*, std::allocator<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*> >::empty() const /usr/include/c++/9/bits/stl_vector.h:1005:24
#162 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::PSNodesBlock::empty() const /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:98:49
#163 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::buildFunction(llvm::Function const&) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:584:22
#164 0x00007f52e64d258b dg::pta::LLVMPointerGraphBuilder::createOrGetSubgraph(llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:238:9
#165 0x00007f52e64d3606 dg::pta::LLVMPointerGraphBuilder::getAndConnectSubgraph(llvm::Function const*, llvm::CallInst const*, dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:110:50
#166 0x00007f52e64d3d9b _ZN2dg3pta12PointerGraph11nodeFactoryILNS0_10PSNodeTypeE10EJENS0_13PSNodeCallRetEEENSt9enable_ifIXntsrSt7is_sameIT1_NS0_6PSNodeEE5valueEPS7_E4typeEDpOT0_ /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:149:16
#167 0x00007f52e64d3d9b dg::pta::PSNode* dg::pta::PointerGraph::create<(dg::pta::PSNodeType)10>() /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:188:17
#168 0x00007f52e64d3d9b dg::pta::LLVMPointerGraphBuilder::createCallToFunction(llvm::CallInst const*, llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:137:31
#169 0x00007f52e64edee5 dg::pta::LLVMPointerGraphBuilder::createCall(llvm::Instruction const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Calls.cpp:33:1
#170 0x00007f52e64d8016 __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
#171 0x00007f52e64d8016 std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
#172 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::PSNodesSeq::begin() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:84:56
#173 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::buildPointerGraphBlock(llvm::BasicBlock const&, dg::pta::PointerSubgraph*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Block.cpp:49:25
#174 0x00007f52e64d20f6 std::vector<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*, std::allocator<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*> >::empty() const /usr/include/c++/9/bits/stl_vector.h:1005:24
#175 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::PSNodesBlock::empty() const /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:98:49
#176 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::buildFunction(llvm::Function const&) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:584:22
#177 0x00007f52e64d258b dg::pta::LLVMPointerGraphBuilder::createOrGetSubgraph(llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:238:9
#178 0x00007f52e64d3606 dg::pta::LLVMPointerGraphBuilder::getAndConnectSubgraph(llvm::Function const*, llvm::CallInst const*, dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:110:50
#179 0x00007f52e64d3d9b _ZN2dg3pta12PointerGraph11nodeFactoryILNS0_10PSNodeTypeE10EJENS0_13PSNodeCallRetEEENSt9enable_ifIXntsrSt7is_sameIT1_NS0_6PSNodeEE5valueEPS7_E4typeEDpOT0_ /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:149:16
#180 0x00007f52e64d3d9b dg::pta::PSNode* dg::pta::PointerGraph::create<(dg::pta::PSNodeType)10>() /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:188:17
#181 0x00007f52e64d3d9b dg::pta::LLVMPointerGraphBuilder::createCallToFunction(llvm::CallInst const*, llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:137:31
#182 0x00007f52e64edee5 dg::pta::LLVMPointerGraphBuilder::createCall(llvm::Instruction const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Calls.cpp:33:1
#183 0x00007f52e64d8016 __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
#184 0x00007f52e64d8016 std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
#185 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::PSNodesSeq::begin() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:84:56
#186 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::buildPointerGraphBlock(llvm::BasicBlock const&, dg::pta::PointerSubgraph*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Block.cpp:49:25
#187 0x00007f52e64d20f6 std::vector<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*, std::allocator<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*> >::empty() const /usr/include/c++/9/bits/stl_vector.h:1005:24
#188 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::PSNodesBlock::empty() const /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:98:49
#189 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::buildFunction(llvm::Function const&) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:584:22
#190 0x00007f52e64d258b dg::pta::LLVMPointerGraphBuilder::createOrGetSubgraph(llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:238:9
#191 0x00007f52e64d3606 dg::pta::LLVMPointerGraphBuilder::getAndConnectSubgraph(llvm::Function const*, llvm::CallInst const*, dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:110:50
#192 0x00007f52e64d3d9b _ZN2dg3pta12PointerGraph11nodeFactoryILNS0_10PSNodeTypeE10EJENS0_13PSNodeCallRetEEENSt9enable_ifIXntsrSt7is_sameIT1_NS0_6PSNodeEE5valueEPS7_E4typeEDpOT0_ /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:149:16
#193 0x00007f52e64d3d9b dg::pta::PSNode* dg::pta::PointerGraph::create<(dg::pta::PSNodeType)10>() /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:188:17
#194 0x00007f52e64d3d9b dg::pta::LLVMPointerGraphBuilder::createCallToFunction(llvm::CallInst const*, llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:137:31
#195 0x00007f52e64edee5 dg::pta::LLVMPointerGraphBuilder::createCall(llvm::Instruction const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Calls.cpp:33:1
#196 0x00007f52e64d8016 __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
#197 0x00007f52e64d8016 std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
#198 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::PSNodesSeq::begin() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:84:56
#199 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::buildPointerGraphBlock(llvm::BasicBlock const&, dg::pta::PointerSubgraph*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Block.cpp:49:25
#200 0x00007f52e64d20f6 std::vector<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*, std::allocator<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*> >::empty() const /usr/include/c++/9/bits/stl_vector.h:1005:24
#201 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::PSNodesBlock::empty() const /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:98:49
#202 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::buildFunction(llvm::Function const&) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:584:22
#203 0x00007f52e64d258b dg::pta::LLVMPointerGraphBuilder::createOrGetSubgraph(llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:238:9
#204 0x00007f52e64d3606 dg::pta::LLVMPointerGraphBuilder::getAndConnectSubgraph(llvm::Function const*, llvm::CallInst const*, dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:110:50
#205 0x00007f52e64d3d9b _ZN2dg3pta12PointerGraph11nodeFactoryILNS0_10PSNodeTypeE10EJENS0_13PSNodeCallRetEEENSt9enable_ifIXntsrSt7is_sameIT1_NS0_6PSNodeEE5valueEPS7_E4typeEDpOT0_ /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:149:16
#206 0x00007f52e64d3d9b dg::pta::PSNode* dg::pta::PointerGraph::create<(dg::pta::PSNodeType)10>() /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:188:17
#207 0x00007f52e64d3d9b dg::pta::LLVMPointerGraphBuilder::createCallToFunction(llvm::CallInst const*, llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:137:31
#208 0x00007f52e64edee5 dg::pta::LLVMPointerGraphBuilder::createCall(llvm::Instruction const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Calls.cpp:33:1
#209 0x00007f52e64d8016 __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
#210 0x00007f52e64d8016 std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
#211 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::PSNodesSeq::begin() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:84:56
#212 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::buildPointerGraphBlock(llvm::BasicBlock const&, dg::pta::PointerSubgraph*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Block.cpp:49:25
#213 0x00007f52e64d20f6 std::vector<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*, std::allocator<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*> >::empty() const /usr/include/c++/9/bits/stl_vector.h:1005:24
#214 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::PSNodesBlock::empty() const /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:98:49
#215 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::buildFunction(llvm::Function const&) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:584:22
#216 0x00007f52e64d258b dg::pta::LLVMPointerGraphBuilder::createOrGetSubgraph(llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:238:9
#217 0x00007f52e64d3606 dg::pta::LLVMPointerGraphBuilder::getAndConnectSubgraph(llvm::Function const*, llvm::CallInst const*, dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:110:50
#218 0x00007f52e64d3d9b _ZN2dg3pta12PointerGraph11nodeFactoryILNS0_10PSNodeTypeE10EJENS0_13PSNodeCallRetEEENSt9enable_ifIXntsrSt7is_sameIT1_NS0_6PSNodeEE5valueEPS7_E4typeEDpOT0_ /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:149:16
#219 0x00007f52e64d3d9b dg::pta::PSNode* dg::pta::PointerGraph::create<(dg::pta::PSNodeType)10>() /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:188:17
#220 0x00007f52e64d3d9b dg::pta::LLVMPointerGraphBuilder::createCallToFunction(llvm::CallInst const*, llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:137:31
#221 0x00007f52e64edee5 dg::pta::LLVMPointerGraphBuilder::createCall(llvm::Instruction const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Calls.cpp:33:1
#222 0x00007f52e64d8016 __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
#223 0x00007f52e64d8016 std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
#224 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::PSNodesSeq::begin() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:84:56
#225 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::buildPointerGraphBlock(llvm::BasicBlock const&, dg::pta::PointerSubgraph*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Block.cpp:49:25
#226 0x00007f52e64d20f6 std::vector<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*, std::allocator<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*> >::empty() const /usr/include/c++/9/bits/stl_vector.h:1005:24
#227 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::PSNodesBlock::empty() const /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:98:49
#228 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::buildFunction(llvm::Function const&) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:584:22
#229 0x00007f52e64d258b dg::pta::LLVMPointerGraphBuilder::createOrGetSubgraph(llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:238:9
#230 0x00007f52e64d3606 dg::pta::LLVMPointerGraphBuilder::getAndConnectSubgraph(llvm::Function const*, llvm::CallInst const*, dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:110:50
#231 0x00007f52e64d3d9b _ZN2dg3pta12PointerGraph11nodeFactoryILNS0_10PSNodeTypeE10EJENS0_13PSNodeCallRetEEENSt9enable_ifIXntsrSt7is_sameIT1_NS0_6PSNodeEE5valueEPS7_E4typeEDpOT0_ /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:149:16
#232 0x00007f52e64d3d9b dg::pta::PSNode* dg::pta::PointerGraph::create<(dg::pta::PSNodeType)10>() /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:188:17
#233 0x00007f52e64d3d9b dg::pta::LLVMPointerGraphBuilder::createCallToFunction(llvm::CallInst const*, llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:137:31
#234 0x00007f52e64edee5 dg::pta::LLVMPointerGraphBuilder::createCall(llvm::Instruction const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Calls.cpp:33:1
#235 0x00007f52e64d8016 __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
#236 0x00007f52e64d8016 std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
#237 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::PSNodesSeq::begin() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:84:56
#238 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::buildPointerGraphBlock(llvm::BasicBlock const&, dg::pta::PointerSubgraph*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Block.cpp:49:25
#239 0x00007f52e64d20f6 std::vector<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*, std::allocator<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*> >::empty() const /usr/include/c++/9/bits/stl_vector.h:1005:24
#240 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::PSNodesBlock::empty() const /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:98:49
#241 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::buildFunction(llvm::Function const&) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:584:22
#242 0x00007f52e64d258b dg::pta::LLVMPointerGraphBuilder::createOrGetSubgraph(llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:238:9
#243 0x00007f52e64d3606 dg::pta::LLVMPointerGraphBuilder::getAndConnectSubgraph(llvm::Function const*, llvm::CallInst const*, dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:110:50
#244 0x00007f52e64d3d9b _ZN2dg3pta12PointerGraph11nodeFactoryILNS0_10PSNodeTypeE10EJENS0_13PSNodeCallRetEEENSt9enable_ifIXntsrSt7is_sameIT1_NS0_6PSNodeEE5valueEPS7_E4typeEDpOT0_ /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:149:16
#245 0x00007f52e64d3d9b dg::pta::PSNode* dg::pta::PointerGraph::create<(dg::pta::PSNodeType)10>() /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:188:17
#246 0x00007f52e64d3d9b dg::pta::LLVMPointerGraphBuilder::createCallToFunction(llvm::CallInst const*, llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:137:31
#247 0x00007f52e64edee5 dg::pta::LLVMPointerGraphBuilder::createCall(llvm::Instruction const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Calls.cpp:33:1
#248 0x00007f52e64d8016 __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
#249 0x00007f52e64d8016 std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
#250 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::PSNodesSeq::begin() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:84:56
#251 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::buildPointerGraphBlock(llvm::BasicBlock const&, dg::pta::PointerSubgraph*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Block.cpp:49:25
#252 0x00007f52e64d20f6 std::vector<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*, std::allocator<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*> >::empty() const /usr/include/c++/9/bits/stl_vector.h:1005:24
#253 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::PSNodesBlock::empty() const /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:98:49
#254 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::buildFunction(llvm::Function const&) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:584:22
#255 0x00007f52e64d258b dg::pta::LLVMPointerGraphBuilder::createOrGetSubgraph(llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:238:9
#256 0x00007f52e64d3606 dg::pta::LLVMPointerGraphBuilder::getAndConnectSubgraph(llvm::Function const*, llvm::CallInst const*, dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:110:50
#257 0x00007f52e64d3d9b _ZN2dg3pta12PointerGraph11nodeFactoryILNS0_10PSNodeTypeE10EJENS0_13PSNodeCallRetEEENSt9enable_ifIXntsrSt7is_sameIT1_NS0_6PSNodeEE5valueEPS7_E4typeEDpOT0_ /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:149:16
#258 0x00007f52e64d3d9b dg::pta::PSNode* dg::pta::PointerGraph::create<(dg::pta::PSNodeType)10>() /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:188:17
#259 0x00007f52e64d3d9b dg::pta::LLVMPointerGraphBuilder::createCallToFunction(llvm::CallInst const*, llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:137:31
#260 0x00007f52e64edee5 dg::pta::LLVMPointerGraphBuilder::createCall(llvm::Instruction const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Calls.cpp:33:1
#261 0x00007f52e64d8016 __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
#262 0x00007f52e64d8016 std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
#263 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::PSNodesSeq::begin() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:84:56
#264 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::buildPointerGraphBlock(llvm::BasicBlock const&, dg::pta::PointerSubgraph*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Block.cpp:49:25
#265 0x00007f52e64d20f6 std::vector<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*, std::allocator<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*> >::empty() const /usr/include/c++/9/bits/stl_vector.h:1005:24
#266 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::PSNodesBlock::empty() const /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:98:49
#267 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::buildFunction(llvm::Function const&) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:584:22
#268 0x00007f52e64d258b dg::pta::LLVMPointerGraphBuilder::createOrGetSubgraph(llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:238:9
#269 0x00007f52e64d3606 dg::pta::LLVMPointerGraphBuilder::getAndConnectSubgraph(llvm::Function const*, llvm::CallInst const*, dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:110:50
#270 0x00007f52e64d3d9b _ZN2dg3pta12PointerGraph11nodeFactoryILNS0_10PSNodeTypeE10EJENS0_13PSNodeCallRetEEENSt9enable_ifIXntsrSt7is_sameIT1_NS0_6PSNodeEE5valueEPS7_E4typeEDpOT0_ /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:149:16
#271 0x00007f52e64d3d9b dg::pta::PSNode* dg::pta::PointerGraph::create<(dg::pta::PSNodeType)10>() /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:188:17
#272 0x00007f52e64d3d9b dg::pta::LLVMPointerGraphBuilder::createCallToFunction(llvm::CallInst const*, llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:137:31
#273 0x00007f52e64edee5 dg::pta::LLVMPointerGraphBuilder::createCall(llvm::Instruction const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Calls.cpp:33:1
#274 0x00007f52e64d8016 __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
#275 0x00007f52e64d8016 std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
#276 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::PSNodesSeq::begin() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:84:56
#277 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::buildPointerGraphBlock(llvm::BasicBlock const&, dg::pta::PointerSubgraph*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Block.cpp:49:25
#278 0x00007f52e64d20f6 std::vector<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*, std::allocator<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*> >::empty() const /usr/include/c++/9/bits/stl_vector.h:1005:24
#279 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::PSNodesBlock::empty() const /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:98:49
#280 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::buildFunction(llvm::Function const&) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:584:22
#281 0x00007f52e64d258b dg::pta::LLVMPointerGraphBuilder::createOrGetSubgraph(llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:238:9
#282 0x00007f52e64d3606 dg::pta::LLVMPointerGraphBuilder::getAndConnectSubgraph(llvm::Function const*, llvm::CallInst const*, dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:110:50
#283 0x00007f52e64d3d9b _ZN2dg3pta12PointerGraph11nodeFactoryILNS0_10PSNodeTypeE10EJENS0_13PSNodeCallRetEEENSt9enable_ifIXntsrSt7is_sameIT1_NS0_6PSNodeEE5valueEPS7_E4typeEDpOT0_ /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:149:16
#284 0x00007f52e64d3d9b dg::pta::PSNode* dg::pta::PointerGraph::create<(dg::pta::PSNodeType)10>() /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:188:17
#285 0x00007f52e64d3d9b dg::pta::LLVMPointerGraphBuilder::createCallToFunction(llvm::CallInst const*, llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:137:31
#286 0x00007f52e64edee5 dg::pta::LLVMPointerGraphBuilder::createCall(llvm::Instruction const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Calls.cpp:33:1
#287 0x00007f52e64d8016 __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
#288 0x00007f52e64d8016 std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
#289 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::PSNodesSeq::begin() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:84:56
#290 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::buildPointerGraphBlock(llvm::BasicBlock const&, dg::pta::PointerSubgraph*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Block.cpp:49:25
#291 0x00007f52e64d20f6 std::vector<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*, std::allocator<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*> >::empty() const /usr/include/c++/9/bits/stl_vector.h:1005:24
#292 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::PSNodesBlock::empty() const /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:98:49
#293 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::buildFunction(llvm::Function const&) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:584:22
#294 0x00007f52e64d258b dg::pta::LLVMPointerGraphBuilder::createOrGetSubgraph(llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:238:9
#295 0x00007f52e64d3606 dg::pta::LLVMPointerGraphBuilder::getAndConnectSubgraph(llvm::Function const*, llvm::CallInst const*, dg::pta::PSNode*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:110:50
#296 0x00007f52e64d3d9b _ZN2dg3pta12PointerGraph11nodeFactoryILNS0_10PSNodeTypeE10EJENS0_13PSNodeCallRetEEENSt9enable_ifIXntsrSt7is_sameIT1_NS0_6PSNodeEE5valueEPS7_E4typeEDpOT0_ /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:149:16
#297 0x00007f52e64d3d9b dg::pta::PSNode* dg::pta::PointerGraph::create<(dg::pta::PSNodeType)10>() /home/lorenz1/mlsast/misc/tools/dg/include/dg/PointerAnalysis/PointerGraph.h:188:17
#298 0x00007f52e64d3d9b dg::pta::LLVMPointerGraphBuilder::createCallToFunction(llvm::CallInst const*, llvm::Function const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:137:31
#299 0x00007f52e64edee5 dg::pta::LLVMPointerGraphBuilder::createCall(llvm::Instruction const*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Calls.cpp:33:1
#300 0x00007f52e64d8016 __gnu_cxx::__normal_iterator<dg::pta::PSNode**, std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> > >::__normal_iterator(dg::pta::PSNode** const&) /usr/include/c++/9/bits/stl_iterator.h:807:23
#301 0x00007f52e64d8016 std::vector<dg::pta::PSNode*, std::allocator<dg::pta::PSNode*> >::begin() /usr/include/c++/9/bits/stl_vector.h:809:47
#302 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::PSNodesSeq::begin() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:84:56
#303 0x00007f52e64d8016 dg::pta::LLVMPointerGraphBuilder::buildPointerGraphBlock(llvm::BasicBlock const&, dg::pta::PointerSubgraph*) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/Block.cpp:49:25
#304 0x00007f52e64d20f6 std::vector<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*, std::allocator<dg::pta::LLVMPointerGraphBuilder::PSNodesSeq*> >::empty() const /usr/include/c++/9/bits/stl_vector.h:1005:24
#305 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::PSNodesBlock::empty() const /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerGraph.h:98:49
#306 0x00007f52e64d20f6 dg::pta::LLVMPointerGraphBuilder::buildFunction(llvm::Function const&) /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:584:22
#307 0x00007f52e64d336a dg::pta::LLVMPointerGraphBuilder::buildLLVMPointerGraph() /home/lorenz1/mlsast/misc/tools/dg/lib/llvm/PointerAnalysis/PointerGraph.cpp:645:24
#308 0x00005567e1fa8d44 dg::DGLLVMPointerAnalysis::buildSubgraph() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerAnalysis.h:288:12
#309 0x00005567e1fa8d44 dg::DGLLVMPointerAnalysis::initialize() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerAnalysis.h:310:22
#310 0x00005567e1fa9c98 dg::DGLLVMPointerAnalysis::run() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/PointerAnalysis/PointerAnalysis.h:330:23
#311 0x00005567e1fa9c98 dg::llvmdg::LLVMDependenceGraphBuilder::_runPointerAnalysis() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/LLVMDependenceGraphBuilder.h:79:18
#312 0x00005567e1fa9c98 dg::llvmdg::LLVMDependenceGraphBuilder::constructCFGOnly() /home/lorenz1/mlsast/misc/tools/dg/include/dg/llvm/LLVMDependenceGraphBuilder.h:201:28
#313 0x00005567e1fa9c98 Slicer::buildDG(bool) /home/lorenz1/mlsast/misc/tools/dg/tools/include/dg/tools/llvm-slicer.h:83:52
#314 0x00005567e1f99ec6 main /home/lorenz1/mlsast/misc/tools/dg/tools/llvm-slicer.cpp:238:5
#315 0x00007f52e114f0b3 __libc_start_main /build/glibc-sMfBJT/glibc-2.31/csu/../csu/libc-start.c:342:3
#316 0x00005567e1f9a8ae _start (/usr/local/bin/llvm-slicer+0x108ae)
PLEASE submit a bug report to https://bugs.llvm.org/ and include the crash backtrace.
Segmentation fault (core dumped)
```


