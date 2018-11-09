CA65FLAGS=--include-dir ../../asminc --include-dir ../../../asmunit --include-dir ../../kernel
LDFLAGS=--config ../../steckos-c-app.cfg
LIBS=../lib/toollib.a ../../lib/steckschwein-kernel.lib
TEST_LIBS=$(LIBS) ../../../asmunit/asmunit.a
TEST_LDFLAGS=--config test.cfg -Dasmunit_char_out=0x200

.PHONY: all clean


all: ppmview.prg
		
clean:
	rm -f *.prg *.o

%.o: %.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)

test.%.bin: test.%.o $(TEST_LIBS) $(<:test.%=%)
	ld65 $(TEST_LDFLAGS) $< $(<:test.%=%) $(TEST_LIBS) -o $@
	
test.%: test.%.bin
	../../../asmunit/asmunit_wrapper.sh $@.bin $(ADDRESS)
    
%.prg: %.main.o %.o test.ppmview.main $(LIBS)
	ld65 $(LDFLAGS) ppmview.o ppmview.main.o $(LIBS) -o $@
    
%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@ 
	
%: %.prg
	../../../transfer.py $< -s 0x1000