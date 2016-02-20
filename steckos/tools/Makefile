all: date.bin type.bin view.bin more.bin nvram.bin

clean:
	rm -f *.bin *.s *.o
  
%.o: %.c
	cc65 -I ../../cc65 -t none --cpu 65c02 -O $<
	ca65 -I ../../cc65 --cpu 65c02 $(@:.o=.s)
	
     
%.bin: %.o
	ld65 -C ../../cc65/steckos/steckschwein-kernel.cfg -v $< ../../cc65/steckos/steckschwein-kernel.lib -o $@

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

time-test: time-test.bin
	../../transfer.py date.bin -s 0x1000
	
%.bin: %.a
	acme -v -Wtype-mismatch -f plain --cpu 65c02 -o $@ $<

%.o: %.c
	cc65 -t none --cpu 65c02 -O $<
	ca65 -t none --cpu 65c02 $(@:.o=.s)
