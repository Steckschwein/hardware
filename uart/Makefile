all: uart.bin 
clean:
	rm *.bin


%.bin: %.a
	acme -v -f plain -l $<.labels  --cpu 65c02 -o $@ $<

transfer: uart.bin
	../transfer.py uart.bin
