all: decoder.jed 

clean:
	rm -f *.jed *.fus *.chp *.pin *.bin *.label

%.jed: %.pld
	galasm -fp $<

	
