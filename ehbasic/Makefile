OBJ=min_mon.bin
all: $(OBJ) basic.a
clean:
	rm -f *.bin 

%.bin: %.a
	acme -v -f plain --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py $(OBJ) 0x8000
