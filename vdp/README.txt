
- convert the c64 kernal.rom 2 acme asm

c=0 && for l in `od -t x1 CHAR.ROM | cut -d ' ' -f2-`; do echo -n "\$$l"; c=`expr $c + 1`; if [ $c -eq 8 ]; then c=0 && echo; echo -n '!byte '; else echo -n ","; fi  ;done > char.a