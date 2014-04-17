all: vdp

clean:
	rm -f *.bin
	
vdp: t9929.bin

c=0
charrom:
	echo -n '!byte ' >> char.a && for l in `od -t x1 CHAR.ROM | grep -v "0010000" | cut -d ' ' -f2-`; do echo -n "\$$l"; c=`expr $c + 1`; if [ $c -eq 8 ]; then c=0 && echo; echo -n '!byte '; else echo -n ","; fi  ;done >> char.a
	echo 'charset_c64:' > char.ascii.a
	sed -n 65,95p char.a >> char.ascii.a
	sed -n 33,63p char.a >> char.ascii.a
	sed -n 1,32p char.a >> char.ascii.a
	sed -n 161p char.a >> char.ascii.a
	sed -n 258,283p char.a >> char.ascii.a
  
%.bin: %.a
	acme -v -f plain -l $<.labels --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py t9929.bin 0x1000