CPU=65c02
OBJ=ehbasic.prg
LDFLAGS=--config ../steckos/kernel/steckos.cfg
# uncomment for a serial line version
#DEFINES=-DUART

all: $(OBJ) 
clean:
	rm -f *.prg *.o

%.o: %.asm 
	ca65 --cpu $(CPU) --target none $(DEFINES)  $<


ehbasic.prg: steck_mon.o 
	ld65 $(LDFLAGS) steck_mon.o -o ehbasic.prg




transfer: all
	../transfer.py $(OBJ) 
