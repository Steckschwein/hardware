CPU=65c02
CA65FLAGS=--include-dir ../asminc --include-dir ../kernel
LDFLAGS=--config ../steckos-c-app.cfg ../lib/steckschwein-kernel.lib
ASM_INCLUDE=--include-dir ../steckos/kernel --include-dir ../steckos/asminc
TOOLLIB=lib/toollib.a
TOOLS=ls.prg ll.prg stat.prg fsinfo.prg attrib.prg rename.prg help.prg nvram.prg uname.prg clear.prg view.prg echo.prg od.prg touch.prg rmdir.prg mkdir.prg cp.prg pwd.prg rm.prg du.prg keycode.prg hello.prg fig.prg vramtest.prg wozmon.prg

.PHONY: all clean

all: $(TOOLS)

clean:
	rm -f *.prg *.s *.o toollib.a
	(cd lib; make clean)
	(cd xmodem; make clean)
	(cd ppmview; make clean)

%.o: %.c
	cc65 -I ../../cc65 -t none --cpu $(CPU) -O $<
	ca65 -I ../../cc65 --cpu $(CPU) $(CA65FLAGS) $(@:.o=.s)

%.o: %.asm
	ca65 --cpu $(CPU) $(CA65FLAGS) $(ASM_INCLUDE) $(@:.o=.asm)

toollib:
	( cd lib ; make )

%.prg: %.o toollib ../lib/steckschwein-kernel.lib
	ld65 $< $(LDFLAGS) $(TOOLLIB) -o $@

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

ls.prg: toollib ls.o ls_entry_short.o
	cl65 $(CA65FLAGS) --target none --config ../kernel/steckosapp.cfg ls.o ls_entry_short.o $(TOOLLIB) -o ls.prg
ll.prg: toollib ls.o ls_entry_long.o
	cl65 $(CA65FLAGS) --target none --config ../kernel/steckosapp.cfg ls.o ls_entry_long.o $(TOOLLIB) -o ll.prg
stat.prg: toollib ls.o ls_entry_stat.o
	cl65 $(CA65FLAGS) --target none --config ../kernel/steckosapp.cfg ls.o ls_entry_stat.o $(TOOLLIB) -o stat.prg

%: %.prg
	../../transfer.py $< -s 0x1000
