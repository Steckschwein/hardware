ACME_OPTS=--initmem 0xFF --cpu 65c02
all: bios.bin bios.h.a

clean:
	rm -f *.bin *.labels bios.h.a

%.h.a: %.a
	grep  -e "\$$ff[0-9a-f][0-9a-f]" $<.labels | sort > $@
	#grep  -e "sys_" $<.labels | sort >> $@
   
%.bin: %.a
	acme -v -f plain -l $<.labels $(ACME_OPTS) -o $@ $<
