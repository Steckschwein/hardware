ASM_INCLUDE=../asminc
LIBS=../lib/steckschwein-kernel.lib ../lib/steckschwein-gfx.lib

all: ls.prg ll.prg rename.prg date.prg nvram.prg uname.prg hello.prg time-test.prg mainarg.prg fibo.prg clear.prg setdate.prg view.prg

clean:
	rm -f *.prg *.s *.o
  
%.o: %.c
	cc65 -I ../../cc65 -t none --cpu 65c02 -O $<
	ca65 -I ../../cc65 --cpu 65c02 --include-dir $(ASM_INCLUDE) $(@:.o=.s)

%.o: %.asm
	ca65 --include-dir $(ASM_INCLUDE) $(@:.o=.asm)

%.prg: %.o ../lib/steckschwein-kernel.lib
	ld65 -C ../lib/steckschwein-kernel.cfg $< $(LIBS) -o $@

ls.prg: ls.o ls_entry_short.o
	cl65 --include-dir $(ASM_INCLUDE) --target none --config ../kernel/steckos.cfg ls.o ls_entry_short.o -o ls.prg
ll.prg: ls.o ls_entry_long.o
	cl65 --include-dir $(ASM_INCLUDE) --target none --config ../kernel/steckos.cfg ls.o ls_entry_long.o -o ll.prg

clear: clear.prg
	../../transfer.py clear.prg -s 0x1000

uname: uname.prg
	../../transfer.py uname.prg -s 0x1000

keycode: keycode.prg
	../../transfer.py keycode.prg -s 0x1000
	
coniotst: coniotst.prg
	../../transfer.py coniotst.prg -s 0x1000

mainarg: mainarg.prg
	../../transfer.py mainarg.prg -s 0x1000
	
hello: hello.prg
	../../transfer.py hello.prg -s 0x1000
    
sieve: sieve.prg
	../../transfer.py sieve.prg -s 0x1000

nvram: nvram.prg
	../../transfer.py nvram.prg -s 0x1000

date: date.prg
	../../transfer.py date.prg -s 0x1000
    
stdio_test: stdio_test.prg
	../../transfer.py stdio_test.prg -s 0x1000

time-test: time-test.prg
	../../transfer.py time-test.prg -s 0x1000

setdate: setdate.prg
	../../transfer.py setdate.prg -s 0x1000
    
fibo: fibo.prg
	../../transfer.py fibo.prg -s 0x1000
    
ls: ls.prg
	../../transfer.py ls.prg -s 0x1000

view: view.prg
	../../transfer.py view.prg -s 0x1000
