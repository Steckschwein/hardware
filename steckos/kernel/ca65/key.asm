.include "kernel.inc"
.include "via.inc"
.import spi_r_byte 
.export keyin, getkey
.segment "KERNEL"

; Wait for key

keyin:
@l:	jsr getkey
	cmp #$00
	beq @l
	rts

; Select Keyboard controller on SPI, get byte from buffer
getkey:
	phx

	lda #%01111010
	sta via1portb

	; lda #$ff
	jsr spi_r_byte
       
	ldx #%11111110
	stx via1portb

	plx
	rts