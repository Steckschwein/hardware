#!/bin/sh

c=0 && echo -n '!byte ' > char.tmp.h.a && for l in `od -t x1 characters.901460-03.bin | grep -v "0010000" | cut -d ' ' -f2-`; do echo -n "\$$l"; c=`expr $c + 1`; if [ $c -eq 8 ]; then c=0 && echo; echo -n '!byte '; else echo -n ","; fi  ;done >> char.tmp.h.a
echo 'charset:' > char.ascii.h.a
sed -n 65,96p char.rom.a >> char.ascii.h.a 	# 32 chars 
sed -n 33,64p char.rom.a >> char.ascii.h.a	# 
sed -n 1,32p char.rom.a >> char.ascii.h.a
sed -n 97,158p char.rom.a >> char.ascii.h.a
sed -n 161p char.rom.a >> char.ascii.h.a
sed -n 258,283p char.rom.a >> char.ascii.h.a
