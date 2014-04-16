all: bios.bin bios.h.a
clean:
	rm -f *.bin *.labels bios.h.a

%.h.a: %.a
	grep  -e "\$$ff[0-9a-f][0-9a-f]" $<.labels | sort > $@

%.bin: %.a
	acme -v -f plain -l $<.labels  --cpu 65c02 -o $@ $<
