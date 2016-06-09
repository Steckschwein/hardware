.PHONY: all
all: bios.bin 

.PHONY: clean
clean:
	rm -f *.o *.bin 


	
%.bin: %.asm bios.inc
	cl65 --target none --config $*.cfg -o $@ $<

loader.bin: bios.bin
transfer: loader.bin
	../../transfer.py -s 0x0300 loader.bin
