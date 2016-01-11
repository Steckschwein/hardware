all: date.bin type.bin view.bin more.bin nvram.bin

clean:
	rm -f *.bin *.s *.o
  
%.o: %.c
	cc65 -I ../../cc65 -t none --cpu 65c02 -O $<
	ca65 -I ../../cc65 --cpu 65c02 $(@:.o=.s)
	
     
nvram.bin: nvram.o
	ld65 -C ../../cc65/steckschwein.cfg -v $< ../../cc65/steckos/steckschwein-kernel.lib -o $@

%.bin: %.a
	acme -v -Wtype-mismatch -f plain --cpu 65c02 -o $@ $<

%.o: %.c
	cc65 -t none --cpu 65c02 -O $<
	ca65 -t none --cpu 65c02 $(@:.o=.s)
    
