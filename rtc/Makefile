all: rtc.bin  set_rtc.bin read_rtc.bin
clean:
	rm -f *.bin *.labels

%.bin: %.a ../bios/defs.h.a
	acme -v -f plain --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py rtc.bin 
set: set_rtc.bin
	../transfer.py set_rtc.bin 
read: set_rtc.bin
	../transfer.py read_rtc.bin 
