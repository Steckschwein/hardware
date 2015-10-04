all: decoder.jed rdy.jed

clean:
	rm -f *.jed *.fus *.chp *.pin *.bin *.label

%.jed: %.pld
	galasm -fp $<

	
