DEFINES=-Dasmunit_char_out=0x200
CA65FLAGS=--include-dir ../../../../asmunit --include-dir ../../../asminc --include-dir ../../../kernel $(DEFINES)
LIBS=../toollib.a ../../../../asmunit/asmunit.a
LDFLAGS=--config ../../../../asmunit/asmunit.cfg $(LIBS) $(DEFINES)

.PHONY: all clean

all: test_hexout test_bin2dual test_bin2asc test_rot13 test_sqrt8

clean:
	rm -f *.bin *.o *.dis *.log

%.o: %.asm ../../../../asmunit/*.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)

%.bin: %.o $(LIBS)
	ld65 $(LDFLAGS) $< $(LIBS) -o $@

%.dis: %.bin
	dcc6502 -o 0x1000 -d -n -c $< > $@

test_%: test_%.bin
	../../../../asmunit/asmunit_wrapper.sh $@.bin 1000
#	py65mon -m 65c02 -o f001
#	../../../../transfer.py $@.prg
