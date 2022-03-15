# Non Termination

This program only terminates if an arbitrary command line argument is
supplied, otherwise it will enter an endless loop. This loop, however,
prevents the argv array to be accessed at an out of bounds index. The
loop depends on the variable "y", which if sliced away may lead to
imprecise results as DG expects all loops to terminate eventually:

"Symbiotic is very precise: it may produce an incorrect answer in only
one situation: when slicing removes a non-terminating loop or call to
exit, which makes a previously unreachable error reachable.  That can
happen because slicing assumes that every loop eventually terminates.
A remedy of this behavior is possible, but currently not implemented
(we describe it in Chapter 2)."

Marek Chalupa, "Slicing of LLVM bitcode", Masaryk University
Faculty of Informatics Brno, 2016
