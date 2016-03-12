#!/bin/sh

c=0 && echo -n '!byte ' > char.tmp.h.a && for l in `od -t x1 characters.901460-03.bin | grep -v "0010000" | cut -d ' ' -f2-`; do echo -n "\$$l"; c=`expr $c + 1`; if [ $c -eq 8 ]; then c=0 && echo; echo -n '!byte '; else echo -n ","; fi  ;done >> char.tmp.h.a
echo 'charset_c64:' > char.ascii.c64.h.a
sed -n 65,96p characters.c64.a >> char.ascii.c64.h.a 	# 32 chars 
sed -n 33,64p characters.c64.a >> char.ascii.c64.h.a	# 
sed -n 1,32p characters.c64.a >> char.ascii.c64.h.a
sed -n 97,158p characters.c64.a >> char.ascii.c64.h.a
sed -n 161p characters.c64.a >> char.ascii.c64.h.a
sed -n 258,283p characters.c64.a >> char.ascii.c64.h.a

target=char.ascii.vc20.6x8.h.a
echo 'charset_vc20_6x8:' > ${target}
cat char.tmp.h.a >> char.ascii.vc20.h.a
sed -n 65,96p char.tmp.h.a >> ${target}	# 32 chars 
sed -n 33,64p char.tmp.h.a >> ${target}		# 32 chars
sed -n 1,32p char.tmp.h.a >> ${target}		# 32 chars
sed -n 257,288p char.tmp.h.a >> ${target}	# 32 chars
#inverse
sed -n 193,224p char.tmp.h.a >> ${target}	# 32 chars 
sed -n 161,192p char.tmp.h.a >> ${target}		# 32 chars
sed -n 129,160p char.tmp.h.a >> ${target}		# 32 chars
sed -n 385,416p char.tmp.h.a >> ${target}	# 32 chars

sed -n 161p characters.901460-03.a >> char.ascii.vc20.h.a
sed -n 258,283p characters.901460-03.a >> char.ascii.vc20.h.a
