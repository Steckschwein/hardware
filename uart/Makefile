all: uart.bin test.bin
clean:
	rm *.bin


test: test.bin
memtest: memtest.bin

%.bin: %.a
	acme -v -f plain -l $<.labels  --cpu 65c02 -o $@ $<

transfer: uart.bin
	../transfer.py uart.bin
