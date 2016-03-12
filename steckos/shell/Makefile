all: shell.bin client.bin 
clean:
	rm -f *.bin 

%.bin: %.a
	acme -v -l $<.labels -Wtype-mismatch -f plain --cpu 65c02 -o $@ $<
transfer: shell.bin
	../../transfer.py shell.bin -s 0xd000
