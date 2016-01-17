all: date.bin type.bin view.bin more.bin nvram.bin

clean:
	rm -f *.bin *.s *.o
  
%.o: %.c
	cc65 -I ../../cc65 -t none --cpu 65c02 -O $<
	ca65 -I ../../cc65 --cpu 65c02 $(@:.o=.s)
	
     
nvram.bin: nvram.o
	ld65 -C ../../cc65/steckos/steckschwein-kernel.cfg -v $< ../../cc65/steckos/steckschwein-kernel.lib -o $@

mainarg.bin: mainarg.o
	ld65 -C ../../cc65/steckos/steckschwein-kernel.cfg -v $< ../../cc65/steckos/steckschwein-kernel.lib -o $@

mainarg: mainarg.bin
	../../transfer.py mainarg.bin 0x1000
	
hello.bin: hello.o
	ld65 -C ../../cc65/steckos/steckschwein-kernel.cfg -v $< ../../cc65/steckos/steckschwein-kernel.lib -o $@
	
hello: hello.bin
	../../transfer.py hello.bin 0x1000
	
%.bin: %.a
	acme -v -Wtype-mismatch -f plain --cpu 65c02 -o $@ $<

%.o: %.c
	cc65 -t none --cpu 65c02 -O $<
	ca65 -t none --cpu 65c02 $(@:.o=.s)
