.include "kernel.inc"
.include "via.inc"
.import spi_r_byte, spi_deselect
.export getkey
.segment "KERNEL"

; Select Keyboard controller on SPI, get byte from buffer
getkey:
	phx

	lda #%01111010
	sta via1portb

	jsr spi_r_byte
       
	ldx #%11111110
	stx via1portb

	plx

        cmp #$00 
        beq @l1
        sec
        rts
@l1:
        clc
        rts

