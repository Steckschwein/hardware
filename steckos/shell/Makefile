all: shell.bin client.bin 
clean:
	rm -f *.bin 

%.bin: %.a
	acme -v -Wtype-mismatch -f plain --cpu 65c02 -o $@ $<
transfer: shell.bin
	../../transfer.py shell.bin 0xd000
