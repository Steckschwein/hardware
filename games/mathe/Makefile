ASM_INCLUDE=../../steckos/asminc

all: mathe.bin

clean:
	rm -f *.bin *.s *.o
	
%.o: %.c
	cc65 -I ../../cc65 -t none --cpu 65c02 -O $<
	ca65 -I ../../cc65 --cpu 65c02 --include-dir $(ASM_INCLUDE) $(@:.o=.s)
     
%.bin: %.o ../../steckos/lib/steckschwein-kernel.lib
	ld65 -C ../../steckos/lib/steckschwein-kernel.cfg $< ../../steckos/lib/steckschwein-kernel.lib -o $@
	
mathe: mathe.bin
	../../transfer.py mathe.bin -s 0x1000