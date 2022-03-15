CC=clang
SRC=$(wildcard *.c)
DOT=$(SRC:.c=.dot)
SLC=$(SRC:.c=.slice)
BC=$(SRC:.c=.bc)
LL=$(SRC:.c=.ll)
OPTS=--entry=nomain

$(BC): $(SRC)
	$(CC) -I. -g -O0 -c -emit-llvm -o $(^:.c=.bc) $<


$(LL): $(SRC)
	$(CC) -I. -g -O0 -S -emit-llvm -o $(^:.c=.ll) $<

$(DOT): $(BC)
	llvm-dg-dump $(OPTS) $^ > $@

$(SLC): $(BC)
	llvm-slicer -dump-dg $(DIR) $(OPTS) -o $@ --sc=$(CRIT) $^


.PHONY: all clean slice

all: $(BC) $(LL) $(DOT) 

slice: $(SLC)

clean:
	rm *.bc *.ll *.dot *.slice
