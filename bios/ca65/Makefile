.PHONY: all
all: bios.bin loader.bin

.PHONY: clean
clean:
	rm -f *.o *.bin 


	
%.bin: %.asm bios.inc
	cl65 --config bios.cfg -o $@ $<

transfer: bios.bin loader.bin
	../../transfer.py -s 0x0300 loader.bin
