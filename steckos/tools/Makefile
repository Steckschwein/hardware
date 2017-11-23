CPU=65c02
CA65FLAGS=--include-dir ../asminc --include-dir ../kernel
LDFLAGS=--config ../steckos-c-app.cfg ../lib/steckschwein-kernel.lib

.PHONY: all clean

all: ls.prg ll.prg stat.prg fsinfo.prg attrib.prg rename.prg help.prg date.prg nvram.prg uname.prg hello.prg fibo.prg clear.prg setdate.prg view.prg echo.prg od.prg rmdir.prg mkdir.prg keycode.prg touch.prg du.prg cp.prg pwd.prg rm.prg
	(cd xmodem; make )


clean:
	rm -f *.prg *.s *.o
	(cd xmodem; make clean)

%.o: %.c
	cc65 -I ../../cc65 -t none --cpu $(CPU) -O $<
	ca65 -I ../../cc65 --cpu $(CPU) $(CA65FLAGS) $(@:.o=.s)

%.o: %.asm
	ca65 --cpu $(CPU) $(CA65FLAGS) $(@:.o=.asm)

%.prg:  %.o ../lib/steckschwein-kernel.lib
	ld65 $< $(LDFLAGS) -o $@

ls.prg: toollib.o ls.o ls_entry_short.o
	cl65 $(CA65FLAGS) --target none --config ../kernel/steckosapp.cfg ls.o ls_entry_short.o toollib.o -o ls.prg
ll.prg: toollib.o ls.o ls_entry_long.o
	cl65 $(CA65FLAGS) --target none --config ../kernel/steckosapp.cfg ls.o ls_entry_long.o toollib.o -o ll.prg
stat.prg: toollib.o ls.o ls_entry_stat.o
	cl65 $(CA65FLAGS) --target none --config ../kernel/steckosapp.cfg ls.o ls_entry_stat.o toollib.o -o stat.prg


%: %.prg
	../../transfer.py $< -s 0x1000
