all: shell.bin client.bin repl.bin
clean:
	rm -f *.bin 

%.bin: %.a
	acme -v -Wtype-mismatch -f plain --cpu 65c02 -o $@ $<
%.raw: %.xpm
	sh xpm2acme.sh $< > $@
transfer: shell.bin
	../transfer.py shell.bin 0xd000
test: repl.bin
	py65mon -m 65c02  -l repl.bin
