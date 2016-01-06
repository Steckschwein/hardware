all: date.bin type.bin view.bin
clean:
	rm -f *.bin 
%.bin: %.a
	acme -v -Wtype-mismatch -f plain --cpu 65c02 -o $@ $<
