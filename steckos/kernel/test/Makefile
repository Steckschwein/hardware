DEFINES=-Dasmunit_char_out=0x200
KERNEL_ADDRESS=0xe800
CA65FLAGS=--include-dir ../../../asmunit --include-dir ../../asminc --include-dir ../ $(DEFINES)
LIBS=../util.o ../textui.o ../t99xx.lib.o
LDFLAGS=--config ../steckos.cfg $(DEFINES)

.PHONY: all clean

all: test.util test.textui test.matcher

clean:
	rm -f *.bin *.o *.dis *.log

%.o: %.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)

%.bin: %.o $(LIBS)
	ld65 $(LDFLAGS) $< $(LIBS) -o $@

%.dis: %.bin
	dcc6502 -o $(KERNEL_ADDRESS) -d -n -c $< > $@

test.%: test.%.bin
	../../../asmunit/asmunit_wrapper.sh $@.bin $(KERNEL_ADDRESS)
#	../../../../transfer.py $@.prg
		
%: %.prg
	../../../transfer.py $<