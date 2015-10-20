OBJ=min_mon.bin
all: $(OBJ) basic.a
clean:
	rm -f *.bin 

%.bin: %.a basic.a ext/*.a
	acme -v -f plain -l $<.labels --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py $(OBJ) 0xb000