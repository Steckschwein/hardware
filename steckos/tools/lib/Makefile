CPU=65c02
CA65FLAGS=--include-dir ../../asminc
LDFLAGS=--config ../steckos-c-app.cfg
OBJS=bin2asc.o fsutil.o hexout.o bin2dual.o lcd.o dword2asc.o rot13.o sqrt8.o

.PHONY: all clean

all: toollib.a

clean:
	rm -f *.o toollib.a

%.o: %.asm
	ca65 --cpu $(CPU) $(CA65FLAGS) $(@:.o=.asm)

toollib.a: $(OBJS)
	ar65 a toollib.a $(OBJS)