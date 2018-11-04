CPU=65c02
CA65FLAGS=--include-dir ../asminc --include-dir ../kernel
LDFLAGS=--config ../steckos-c-app.cfg ../lib/steckschwein-kernel.lib
LIBS=../lib/steckschwein-kernel.lib
TOOLLIB=../tools/lib/toollib.a

all: mainarg.prg coniotst.prg

.PHONY: clean

clean:
	rm -f *.prg *.s *.o

%.o: %.c
	cc65 -I ../../cc65 -t none --cpu 65c02 -O $<
	ca65 -I ../../cc65 --cpu 65c02 $(CA65FLAGS) $(@:.o=.s)

%.o: %.asm
	ca65 --cpu $(CPU) $(CA65FLAGS) $(@:.o=.asm)

%.prg: %.o ../lib/steckschwein-kernel.lib
	ld65 $< $(LDFLAGS) $(TOOLLIB) -o $@

ls.prg: ls.o ls_entry_short.o
	cl65 $(CA65FLAGS) --target none --config ../kernel/steckos.cfg ls.o ls_entry_short.o -o ls.prg
ll.prg: ls.o ls_entry_long.o
	cl65 $(CA65FLAGS) --target none --config ../kernel/steckos.cfg ls.o ls_entry_long.o -o ll.prg

coniotst: coniotst.prg
	../../transfer.py coniotst.prg -s 0x1000

mainarg: mainarg.prg
	../../transfer.py mainarg.prg -s 0x1000

stdio_test: stdio_test.prg
	../../transfer.py stdio_test.prg -s 0x1000

time-test: time-test.prg
	../../transfer.py time-test.prg -s 0x1000

%: %.prg
	../../transfer.py $<
