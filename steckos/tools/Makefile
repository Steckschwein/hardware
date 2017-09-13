CPU=65c02
CA65FLAGS=--include-dir ../asminc --include-dir ../kernel
LDFLAGS=--config ../steckos-c-app.cfg ../lib/steckschwein-kernel.lib

.PHONY: all clean

all: ls.prg ll.prg rename.prg date.prg nvram.prg uname.prg hello.prg fibo.prg clear.prg setdate.prg view.prg echo.prg od.prg rmdir.prg keycode.prg

clean:
	rm -f *.prg *.s *.o
  
%.o: %.c
	cc65 -I ../../cc65 -t none --cpu $(CPU) -O $<
	ca65 -I ../../cc65 --cpu $(CPU) $(CA65FLAGS) $(@:.o=.s)

%.o: %.asm
	ca65 --cpu $(CPU) $(CA65FLAGS) $(@:.o=.asm)

%.prg: %.o ../lib/steckschwein-kernel.lib
	ld65 $< $(LDFLAGS) -o $@

ls.prg: ls.o ls_entry_short.o
	cl65 $(CA65FLAGS) --target none --config ../kernel/steckosapp.cfg ls.o ls_entry_short.o -o ls.prg
ll.prg: ls.o ls_entry_long.o
	cl65 $(CA65FLAGS) --target none --config ../kernel/steckosapp.cfg ls.o ls_entry_long.o -o ll.prg

%: %.prg
	../../transfer.py $< -s 0x1000	
