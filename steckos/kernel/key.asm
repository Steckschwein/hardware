.include "kernel.inc"
.include "via.inc"
.import spi_r_byte 
.export keyin, getkey
.segment "KERNEL"

; Wait for key

keyin:
@l:	jsr getkey
	bcc @l
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

        cmp #$00 
        beq @l1
        ;toupper
        sec
        rts
@l1:
        lda #$00
        clc
        rts

