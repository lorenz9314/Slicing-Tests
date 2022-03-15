# Slicing Tools

Dieses Repository enthält die Slicing- und Analyse-Tools DG und Joern,
verpackt als Docker-Images. Die Images befinden sich in den Ordnern
`./Docker/DG/` und `./Docker/Joern`. Dort ebenfalls befindlich, ist ein
jeweiliges Shell-Skript `run.sh`, welches die Docker-Images baut und den
Container ausführt.

Weiterhin befinden sich im Wurzelverzeichnis des Repository, die Ordner
`files` und `examples`. Letzterer beinhaltet einige Minimalbeispiele, um
die Tools zu testen. Dort ist ebenfalls der CPython-Interpreter in
LLVM-IR und LLVM-Bitcode enthalten, als ein deutlich komplexeres
Beispiel. Der übrigen Beispiele werden automatisch gebaut, wenn das
`run.sh`-Skript im DG-Ordner ausgeführt wird. Der `files`-Ordner ist
leer und kann genutzt werden, um Dateien zwischen dem Container und dem
Host auszutauschen.

Beide Ordner `files` und `examples` werden in den Container abgebildet.
Im Fall von Joern, sind diese unter `/joern/files` sowie
`/joern/examples` und unter DG direkt im Wurzelverzeichnis zu finden.


## DG

DG stellt mehrere Programme zur Verfügung, der Kern ist jedoch das
Slicing-Tool `llvm-slicer`, welches die Funktionen aller anderen Tools
beinhaltet. Im Folgenden wird aus diesem Grund stets `llvm-slicer`
verwendet.

Nachdem das `run.sh`-Skript aufgerufen wurde, startet eine Shell im
Wurzelverzeichnis des Containers. Wir wechseln in dem Ordner mit dem
Beispiel `multi`, welches Aufrufe einer Funktion c() von verschiedenen
Call-Sites enthält und führen `make` aus, um das Beispiel in LLVM-IR zu
übersetzen.

```
root@b1d1254999f3:/# ls
root@b1d1254999f3:/# cd examples/multi
root@b1d1254999f3:/examples/multi# make
clang -I. -g -O0 -c -emit-llvm -o main.bc main.c
```

Das Makefile ruft clang mit den Argumenten `-g` und `-c -emit-llvm` auf.
Während `-g` notwendig ist, um später Slicing-Kriterien in der Form
`line:variable` angeben zu können, wird `-c` benötigt, damit das Linking
übersprungen wird und LLVM-Bitcode mit der `-emit-llvm`-Option
ausgegeben wird. Die Verwendung von `-S` an Stelle von `-c`, führt dazu,
dass der Compiler lesbaren LLVM-IR-Code ausgibt. Mit Hilfe von
`llvm-dis` kann aber auch im Nachhinein zwischen den Formaten
gewechselt werden. Für DG, wird das Programm allerdings in der
Form von Bitcode benötigt. Im Folgenden rufen wir nun den llvm-slicer
auf, um ein Slice für die Variable `x` in der Zeile `20` zu generieren:

```
root@b1d1254999f3:/examples/multi# llvm-slicer -c 20:x main.bc
SC: Matched '20#x' to:
    %6 = call i32 @b(i32 %4, i32 %5), !dbg !16
    %7 = call i32 @a(i32 %3, i32 %6), !dbg !17
[llvm-slicer] cutoff 0 diverging blocks and 0 completely removed
Matched line 20 with variable x to:
  %3 = load i32, i32* %2, align 4, !dbg !13
Matched line 20 with variable x to:
  %4 = load i32, i32* %2, align 4, !dbg !14
Matched line 20 with variable x to:
  %5 = load i32, i32* %2, align 4, !dbg !15
Matched line 20 with variable x to:
  %6 = call i32 @b(i32 %4, i32 %5), !dbg !16
Matched line 20 with variable x to:
  %7 = call i32 @a(i32 %3, i32 %6), !dbg !17
[llvm-slicer] CPU time of pointer analysis: 2.060000e-04 s
[llvm-slicer] CPU time of data dependence analysis: 1.470000e-04 s
[llvm-slicer] CPU time of control dependence analysis: 3.400000e-05 s
[llvm-slicer] Finding dependent nodes took 0 sec 0 ms
[llvm-slicer] Slicing dependence graph took 0 sec 0 ms
[llvm-slicer] Sliced away 11 from 41 nodes in DG
[llvm-slicer] saving sliced module to: main.sliced
```

In diesem sehr einfachen Beispiel, wird dem Slicer lediglich ein
einzelnes Kriterium mit dem `-c`-Argument, in der `line:variable`-Form
übergeben. Dieses ist inzwischen allerdings überholt und durch die
neuere `file#function#line#variable`-Form ersetzt worden, welche mit
`-sc` übergeben wird. Diese eignet sich auch für Programme, die aus
mehreren Dateien bestehen und mit einem Linker zusammengeführt wurden.
LLVM bietet zu diesem Zweck einen Linker, `llvm-link`, der auf Bitcode
arbeitet. Unabhängig von der Art, wie die Kriterien übergeben werden (es
können auch mehrere Kriterien übergeben werden), generiert der
`llvm-slicer` eine Datei mit dem Suffix `.sliced`. Die Datei enthält den
Programm-Slice und kann entweder direkt, als Bitcode, betrachtet werden
oder aber zuvor in C-Code zurück übersetzt werden. Das Tool
`llvm-to-source` bietet darüber hinaus aber auch die Möglichkeit, den
Slice auf Zeilen der Quelldatei abzubilden:

```
root@b1d1254999f3:/examples/multi# llvm-to-source main.sliced
3
8
13
18
20
```

Betrachten wir diese Angaben in der Quelldatei, so ist der korrekte
Backward-Slice für die Variable `x` in Zeile `20` erkennbar:

```
  1 int c(int x, int y)
  2 {
  3     return x + y;
  4 }
  5
  6 int b(int u, int v)
  7 {
  8     return c(u, v);
  9 }
 10
 11 int a(int u, int v)
 12 {
 13     return c(u, v);
 14 }
 15
 16 int main()
 17 {
 18     int x = 1;
 19
 20     return a(x, b(x, x));
 21 }
```





## Joern

