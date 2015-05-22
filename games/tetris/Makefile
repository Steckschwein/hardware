all: test_blocks.bin
clean:
	rm -f *.ca* *.bin *.labels
blocks.bin:

fig6502.a: forth65/FIG6502.ASM
	cp forth65/FIG6502.ASM fig6502.a
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

fig6502.bin: fig6502.a
	acme -v -f plain --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py tetris.bin	
