all: test_blocks.bin
clean:
	rm -f *.ca* *.bin *.labels
blocks.bin:

%.raw:
	cp	../tetris.c64/$(*F).raw $(*F).raw

%.ca: ../tetris.c64/%.asm
	cp	../tetris.c64/$(*F).asm $(*F).ca
	#bugs
	if [ "$(*F)" = "test_blocks" ]; then sed -ir "s/ora #\\\$$00000011/ora #%00000011/g" $(*F).ca; sed -n 7~1p -i $(*F).ca;	fi
	#comments and addresses
	sed -ir "s/\/\//;/g" $(*F).ca
	sed -ir "s/\.const //g" $(*F).ca
	sed -ir "s/\.pc.*code.*/*=0xc000/g" $(*F).ca
	sed -ir "s/\.pc.*character data.*/*=0x3800/g" $(*F).ca
	#label
	sed -ir "s/!skip+/+/g" $(*F).ca
	sed -ir "s/!skip:/+/g" $(*F).ca
	sed -ir "s/!exit+/+/g" $(*F).ca
	sed -ir "s/!exit:/+/g" $(*F).ca
	sed -ir "s/!loop-/-/g" $(*F).ca
	sed -ir "s/!loop:/-/g" $(*F).ca
	sed -ir "s/!startLoop-/-/g" $(*F).ca
	sed -ir "s/!startLoop:/-/g" $(*F).ca
	sed -ir "s/!nextkey+/+/g" $(*F).ca
	sed -ir "s/!nextkey:/+/g" $(*F).ca
	#macros
	sed -ir "s/\.import source /!source /g" $(*F).ca
	sed -ir "s/\.import binary /!binary /g" $(*F).ca
	sed -ir "s/\.byte /!byte /g" $(*F).ca
	sed -ir "s/\.text /!text /g" $(*F).ca
	sed -ir "s/\.fill /!fill /g" $(*F).ca
	sed -ir "s/.asm/.ca/g" $(*F).ca

#.SECONDARY: blocks.ca test_blocks.ca input.ca screens.ca lines2.ca scores.ca

%.bin: %.ca blocks.ca test_blocks.ca input.ca screens.ca lines2.ca scores.ca tetris_chars.raw tetris_playscreen.raw
	acme -v -f plain --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py tetris.bin	
