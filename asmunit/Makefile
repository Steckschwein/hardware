DEFINES=-Dasmunit_char_out=0x200
CA65FLAGS=$(DEFINES)
LIBS=asmunit.a
LDFLAGS=--config asmunit.cfg $(LIBS) $(DEFINES)
OBJS=asmunit.o

.PHONY: all clean test

all: test asmunit.a

test: test.asmunit

clean:
	rm -f *.o toollib.a

%.o: %.asm asmunit.inc
	ca65 $(CA65FLAGS) $(@:.o=.asm)

asmunit.a: $(OBJS) test.asmunit
	ar65 a asmunit.a $(OBJS)
	
%.bin: %.o asmunit.o
	ld65 -Ln labels.map $(LDFLAGS) $< asmunit.o -o $@

%.dis: %.bin
	dcc6502 -o 0x1000 -d -n -c $< > $@

test.%: test.%.bin
	./asmunit_wrapper.sh $@.bin 1000 false # false - do not fail on error here