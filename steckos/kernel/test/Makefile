OUT_ADDRESS=0x200
DEFINES=-Dasmunit_char_out=0x200
KERNEL_ADDRESS=0xe800
CA65FLAGS=--include-dir ../../../asmunit --include-dir ../../asminc --include-dir ../ $(DEFINES)
LIBS=../t99xx.lib.o ../debug.o ../../../asmunit/asmunit.a
LDFLAGS=--config test.cfg $(DEFINES)

# testing purpose of kernel api from client point of view
LIBS_PRG=../../tools/lib/toollib.a
LDFLAGS_PRG=--config ../../steckos-c-app.cfg

.PHONY: all clean

all: test.util test.textui test.matcher test.fat32 test.ansi

clean:
	rm -f *.prg *.bin *.o *.dis *.log

%.o: %.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)

test.%.bin: test.%.o $(LIBS) $(<:test.%=%)
	ld65 $(LDFLAGS) $< $(LIBS) ../$(<:test.%=%) -o $@

test.matcher.bin: test.matcher.o ../matcher.o ../util.o $(LIBS)
	ld65 $(LDFLAGS) $< $(LIBS) ../matcher.o ../util.o -o $@

%.prg: %.o $(LIBS)
	ld65 $(LDFLAGS_PRG) $< $(LIBS_PRG) -o $@

%.dis: %.bin
	dcc6502 -o $(KERNEL_ADDRESS) -d -n -c $< > $@

%.dbg: %.bin
	py65mon -m 65c02 --output 0x0200 $< $(KERNEL_ADDRESS)

#../util.o ../textui.o ../fat32.o

test.%: test.%.bin
	../../../asmunit/asmunit_wrapper.sh $@.bin $(KERNEL_ADDRESS)

%: %.prg
	../../../transfer.py $<
