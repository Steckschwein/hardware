OBJ=basic.prg
ASM_INCLUDE=../asminc
LIBS=../lib/steckschwein-kernel.lib
AR65 := $(if $(wildcard ../bin/ar65*),../bin/ar65,ar65)
CA65 := $(if $(wildcard ../bin/ca65*),../bin/ca65,ca65)
CC65 := $(if $(wildcard ../bin/cc65*),../bin/cc65,cc65)
LD65 := $(if $(wildcard ../bin/ld65*),../bin/ld65,ld65)
LDFLAGS=-Ln basic.lbl --config ../kernel/steckosapp.cfg
# uncomment for a serial line version
#DEFINES=-DUART

all: $(OBJ) 
clean:
	rm -f *.prg *.o *.lbl

%.o: %.asm basic.asm ext/*.asm $(LIBS)
	$(CA65) --include-dir $(ASM_INCLUDE) --target none $(DEFINES)  $<

basic.prg: steck_mon.o 
	$(LD65) $(LDFLAGS) steck_mon.o $(LIBS) -o basic.prg

transfer: all
	../transfer.py $(OBJ) 
