
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
	; init lcd to 4bit mode

	jsr init_lcd_4bit

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


init_lcd_4bit:
	clear_bit LCD_RS


	lda #$03
	jsr send_byte
	jsr delay

	lda #$03
	jsr send_byte
	jsr delay

	lda #$02
	jsr send_byte
	jsr delay

	lda #$28
	jsr send_byte
	jsr delay

	set_bit LCD_RS
	rts

send_byte:
	phx
	tax

	; clear lower nibble in port
	lda via1porta
	and #$f0
	sta via1porta

	txa
	lsr
	lsr
	lsr
	lsr

	ora via1porta
	sta via1porta

	set_bit LCD_E
	jsr delay
	clear_bit LCD_E
	jsr delay


	; clear lower nibble in port
	lda via1porta
	and #$f0
	sta via1porta

	txa
	and #$0f
	ora via1porta
	sta via1porta


	set_bit LCD_E
	jsr delay
	clear_bit LCD_E
	jsr delay

	plx
	rts



delay:
	phy
	phx
	ldy #$ff
loop2:
	ldx #$ff
loop:
	.repeat 50
	nop
	.endrepeat

	dex
	bne loop
	dey
	bne loop2
	plx
	ply
	rts

chars:
	.byte "Hello World!",$00
