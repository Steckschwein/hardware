
.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/asminc/via.inc"
.include "../steckos/asminc/common.inc"
.include "../steckos/asminc/joystick.inc"

.include "../steckos/asminc/appstart.inc"

LCD_E 	= (1<<5)
LCD_RS 	= (1<<4)

.macro set_bit bit
	lda #bit
	ora via1porta
	sta via1porta
.endmacro

.macro clear_bit bit
	lda #bit
	eor #$ff
	and via1porta
	sta via1porta
.endmacro

.import hexout

	appstart $1000
	joy_off

	lda #$ff
	sta via1ddra

	lda #$00
	sta via1porta

	jsr delay
l:
	;  set register select because we will send a command
	set_bit LCD_RS
	lda #$5a

	jsr send_byte
	clear_bit LCD_RS

	; send bytes
	ldx #$00
@l:
	lda chars,x
	beq @end
	jsr send_byte
	inx
	bne @l

@end:
	jmp (retvec)


send_byte:
	phx
	tax

	lsr
	lsr
	lsr
	lsr

	and #$0f
	ora via1porta
	sta via1porta

	jsr delay
	set_bit LCD_E
	jsr delay
	clear_bit LCD_E

	jsr delay

	lda via1porta
	and #$f0
	sta via1porta

	txa
	and #$0f
	ora via1porta
	sta via1porta
	jsr delay
	set_bit LCD_E
	jsr delay
	clear_bit LCD_E

	jsr delay

	plx
	rts



delay:
;	phy
	phx
;	ldy #$ff
;loop2:
	ldx #$ff
loop:
	.repeat 50
	nop
	.endrepeat

	dex
	bne loop
;	dey
;	bne loop2
	plx
;	ply
	rts

scratch:
	.byte $00
chars:
	.byte "Hello",$00
