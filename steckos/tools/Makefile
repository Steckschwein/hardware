all: date.bin type.bin view.bin more.bin

clean:
	rm -f *.bin *.s *.o
    
%.bin: %.a
	acme -v -Wtype-mismatch -f plain --cpu 65c02 -o $@ $<

%.o: %.c
	cc65 -t none --cpu 65c02 -O $<
	ca65 -t none --cpu 65c02 hello.s
    
hello: hello.o
	ld65 -C ../../cc65/steckos/steckschwein-kernel.cfg -v $< ../../cc65/steckos/steckschwein-kernel.lib -o $@