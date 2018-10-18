DEFINES=-Dasmunit_char_out=0x200
ADDRESS=0x1000
CA65FLAGS=--include-dir ../ --include-dir ../../../../asmunit --include-dir ../../../asminc --include-dir ../../../kernel $(DEFINES)
LIBS=../../../tools/lib/toollib.a ../../../../asmunit/asmunit.a ../../../lib/steckschwein-kernel.lib
LDFLAGS=--config test.cfg $(DEFINES)

.PHONY: all clean

all: test.ppmview.main

clean:
	rm -f *.prg *.bin *.o *.dis *.log

%.o: %.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)

test.%.bin: test.%.o $(LIBS) $(<:test.%=%)
	ld65 $(LDFLAGS) $< ../$(<:test.%=%) $(LIBS) -o $@

%.dis: %.bin
	dcc6502 -o $(ADDRESS) -d -n -c $< > $@

%.dbg: %.bin
	py65mon -m 65c02 --output 0x0200 $< $(ADDRESS)
	
test.%: test.%.bin
	../../../../asmunit/asmunit_wrapper.sh $@.bin $(ADDRESS)
		
%: %.prg
	../../../transfer.py $<