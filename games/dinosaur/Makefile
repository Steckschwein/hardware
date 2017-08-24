all: dinosaur.prg dinosaur.hi

%.res: %.xpm
	sh xpm2acme16bit.sh dinosaur.sprites.xpm > dinosaur.sprites.res
	sh xpm2acme16bit.sh dinosaur.sprites.pterodactyl.xpm > dinosaur.sprites.pterodactyl.res
	sh xpm2acme8bit.sh dinosaur.chars.1.xpm > dinosaur.chars.1.res
	sh xpm2acme8bit.sh dinosaur.chars.2.xpm > dinosaur.chars.2.res
	sh xpm2acme8bit.sh dinosaur.chars.3.xpm > dinosaur.chars.3.res
	sh xpm2acme8bit.sh dinosaur.chars.4.xpm > dinosaur.chars.4.res
	sh xpm2acme8bit.sh dinosaur.chars.5.xpm > dinosaur.chars.5.res
	sh xpm2acme8bit.sh dinosaur.chars.6.xpm > dinosaur.chars.6.res
	sh xpm2acme8bit.sh dinosaur.chars.1.4px.xpm > dinosaur.chars.1.4px.res
	sh xpm2acme8bit.sh dinosaur.chars.2.4px.xpm > dinosaur.chars.2.4px.res
	sh xpm2acme8bit.sh dinosaur.chars.3.4px.xpm > dinosaur.chars.3.4px.res
	sh xpm2acme8bit.sh dinosaur.chars.4.4px.xpm > dinosaur.chars.4.4px.res
	sh xpm2acme8bit.sh dinosaur.chars.5.4px.xpm > dinosaur.chars.5.4px.res
	sh xpm2acme8bit.sh dinosaur.chars.6.4px.xpm > dinosaur.chars.6.4px.res

clean:
	rm -f *.prg *.labels *.res DINOSAUR.HI

%.prg: %.a ${ACME}/t9929.h.a ${ACME}/*.lib.a *.res 
	acme -v -f cbm --cpu 65c02 -o $@ $<

dinosaur.hi:
	dd if=/dev/zero of=DINOSAUR.HI bs=3 count=1
transfer: all
	../../transfer.py dinosaur.prg
