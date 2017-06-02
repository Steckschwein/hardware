OBJ=ehbasic.prg
ASM_INCLUDE=../steckos/asminc
CA65 := ca65
LDFLAGS=--config ../steckos/kernel/steckos.cfg
# uncomment for a serial line version
#DEFINES=-DUART

all: $(OBJ) 
clean:
	rm -f *.prg *.o

%.o: %.asm basic.asm
	$(CA65) --include-dir $(ASM_INCLUDE) --target none $(DEFINES)  $<


ehbasic.prg: steck_mon.o 
	ld65 $(LDFLAGS) steck_mon.o -o ehbasic.prg

transfer: all
	../transfer.py $(OBJ) 
