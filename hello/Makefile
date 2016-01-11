all: hello.bin hello.o spi.o
clean:
	rm -f *.bin *.o

%.o: %.c
	cc65 -t none --cpu 65c02 -O $<
	ca65 --cpu 65c02 $(@:.o=.s)
	
     
%.bin: %.o
#	acme -v -f plain --cpu 65c02 -o $@ $<
	ld65 -C ../cc65/steckschwein.cfg -v $< ../cc65/stecki.lib -o $@

spi.bin: spi.o
	ld65 -C ../cc65/steckschwein.cfg -v $< ../cc65/stecki.lib -o $@

spitest: spi.bin
	../transfer.py spi.bin 0x1000
	
transfer: hello.bin
	../transfer.py hello.bin 0x1000
