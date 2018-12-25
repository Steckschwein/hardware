MAKEFILE=Makefile
DIST_TARGET=/media/dommas/STCKSCHWN/
all: build

clean:
	(cd test; make clean)
	(cd tools; make clean)
	(cd tools/lib; make clean)
	(cd tools/ppmview; make clean)
	(cd tools/xmodem; make clean)
	(cd shell; make clean)
	(cd libsrc; make clean)
	(cd kernel; make clean)
	(cd ehbasic; make clean)
	(cd imfplayer; make clean)
	rm -rf dist/*

lib/steckschwein-kernel.lib:
	(cd kernel; make )
	(cd libsrc ; make )

lib: kernel lib/steckschwein-kernel.lib

build: lib
	(cd tools/lib; make )
	(cd shell; make )
	(cd tools; make )
	(cd tools/ppmview; make )
	(cd tools/xmodem; make )
	(cd ehbasic; make )
	(cd imfplayer; make )
	(cd test; make )

test:
	(cd kernel; make test)
	(cd tools; make test)

dist: build
	./mkdist.sh $(DIST_TARGET)
