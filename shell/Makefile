all: shell.bin
sprites: sanduhr.raw sanduhr_135.raw sanduhr_180.raw	sanduhr_225.raw	sanduhr_270.raw	sanduhr_315.raw	sanduhr_45.raw	sanduhr_90.raw
clean:
	rm -f *.bin 

%.bin: %.a
	acme -v -f plain --cpu 65c02 -o $@ $<
%.raw: %.xpm
	sh xpm2acme.sh $< > $@
transfer: shell.bin
	../transfer.py shell.bin 0xb000
