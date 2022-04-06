CC=clang
SRC=$(wildcard *.c)
DOT=$(SRC:.c=.dot)
SLC=$(SRC:.c=.slice)
BC=$(SRC:.c=.bc)
LL=$(SRC:.c=.ll)
ELF=$(SRC:.c=)

$(BC): $(SRC)
	$(CC) -I. -g -O0 -c -emit-llvm -o $(^:.c=.bc) $<


$(LL): $(SRC)
	$(CC) -I. -g -O0 -S -emit-llvm -o $(^:.c=.ll) $<

$(ELF): $(SRC)
	$(CC) -I. -g -O0 -o $(^:.c=) $<

$(DOT): $(BC)
	llvm-dg-dump $^ > $(addprefix dg-,$@)
	llvm-cda-dump -dot $^ > $(addprefix cda-,$@)
	llvm-dda-dump -dot $^ > $(addprefix dda-,$@)

$(SLC): $(BC)
	llvm-slicer -dump-dg $(DIR) -o $@ --sc=$(CRIT) $^


.PHONY: all clean slice

all: $(BC) $(LL) $(DOT) $(ELF)

slice: $(SLC)

clean:
	rm *.bc *.ll *.dot *.slice
