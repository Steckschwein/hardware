all: decoder.jed

clean:
	rm -f *.jed *.fus *.chp *.pin

%.jed: %.pld
	galasm $<
