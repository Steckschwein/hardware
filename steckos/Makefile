MAKEFILE=Makefile
DIST_TARGET=/media/dommas/STCKSCHWN/
all: build

clean:
	(cd test; make clean)
	(cd tools; make clean)
	(cd tools/lib; make clean)
	(cd shell; make clean)
	(cd libsrc; make clean)
	(cd kernel; make clean)
	(cd ehbasic; make clean)
	(cd imfplayer; make clean)
	rm -rf dist/*

build:
	(cd kernel; make )
	(cd libsrc; make )
	(cd tools/lib; make )
	(cd shell; make )
	(cd tools; make )
	(cd ehbasic; make )
	(cd imfplayer; make )
	(cd test; make )

test:
	(cd kernel; make test)
	(cd tools; make test)

dist: build
	./mkdist.sh $(DIST_TARGET)
