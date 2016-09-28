ASM_INCLUDE=../asminc

all: ls.bin date.bin type.bin view.bin more.bin nvram.bin uname.bin hello.bin time-test.bin mainarg.bin fibo.bin clear.bin

clean:
	rm -f *.bin *.s *.o
  
%.o: %.c
	cc65 -I ../../cc65 -t none --cpu 65c02 -O $<
	ca65 -I ../../cc65 --cpu 65c02 --include-dir $(ASM_INCLUDE) $(@:.o=.s)
     
%.bin: %.o ../lib/steckschwein-kernel.lib
	ld65 -C ../lib/steckschwein-kernel.cfg $< ../lib/steckschwein-kernel.lib -o $@

ls.bin: 
	cl65 --include-dir $(ASM_INCLUDE) --target none --config ../kernel/steckos.cfg ls.asm -o ls.bin

clear: clear.bin
	../../transfer.py clear.bin -s 0x1000

uname: uname.bin
	../../transfer.py uname.bin -s 0x1000

mainarg: mainarg.bin
	../../transfer.py mainarg.bin -s 0x1000
	
hello: hello.bin
	../../transfer.py hello.bin -s 0x1000
    
sieve: sieve.bin
	../../transfer.py sieve.bin -s 0x1000

nvram: nvram.bin
	../../transfer.py nvram.bin -s 0x1000

date: date.bin
	../../transfer.py date.bin -s 0x1000
    
stdio_test: stdio_test.bin
	../../transfer.py stdio_test.bin -s 0x1000

time-test: time-test.bin
	../../transfer.py time-test.bin -s 0x1000
    
fibo: fibo.bin
	../../transfer.py fibo.bin -s 0x1000
    
ls: ls.bin
	../../transfer.py ls.bin -s 0x1000
	
%.bin: %.a
	acme -v -Wtype-mismatch -f plain --cpu 65c02 -o $@ $<

%.o: %.c
	cc65 -t none --cpu 65c02 -O $<
	ca65 -t none --cpu 65c02 $(@:.o=.s)
