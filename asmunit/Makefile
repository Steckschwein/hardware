DEFINES=-Dasmunit_char_out=0x200
CA65FLAGS=$(DEFINES)
OBJS=asmunit.o

.PHONY: all clean

all: asmunit.a

clean:
	rm -f *.o toollib.a

%.o: %.asm asmunit.inc
	ca65 $(CA65FLAGS) $(@:.o=.asm)

asmunit.a: $(OBJS)
	ar65 a asmunit.a $(OBJS)