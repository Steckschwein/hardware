all: fweep.bin

clean:
	rm -f *.bin *.s *.o
  
%.o: %.c
	cc65 -I ../../cc65 -t none --cpu 65c02 -O $<
	ca65 -I ../../cc65 --cpu 65c02 $(@:.o=.s)	
     
%.bin: %.o
	ld65 -C ../../cc65/steckos/steckschwein-kernel.cfg -v $< ../../cc65/steckos/steckschwein-kernel.lib -o $@

fweep: fweep.bin
	../../transfer.py bc.bin -s 0x1000