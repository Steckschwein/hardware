CA65FLAGS=--include-dir ../../../../asmunit --include-dir ../../../asminc --include-dir ../../../kernel
LIBS=../toollib.a ../../../lib/steckschwein-kernel.lib
LDFLAGS=--config ../../../../asmunit/asmunit.cfg $(LIBS)
#LDFLAGS=--config ../../../steckos-c-app.cfg $(LIBS)
#LDFLAGS=--target sim65c02 -D__EXEHDR__=1

OBJS=test_hexout.o

.PHONY: all clean

all: test_hexout.bin test_bin2dual.bin
testall: test_hexout test_bin2dual

clean:
	rm -f *.bin *.o *.dis toollib.a

%.o: %.asm ../../../../asmunit/*.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)

%.bin: %.o $(LIBS)
	ld65 $(LDFLAGS) $< $(LIBS) -o $@

test_%: test_%.bin
	../../../../asmunit/asmunit_wrapper.sh $@.bin 1000
#	py65mon -m 65c02 -o f001
#	../../../../transfer.py $@.prg


%.dis: %.bin
	dcc6502 -o 0x1000 -d -n -c $< > $@
