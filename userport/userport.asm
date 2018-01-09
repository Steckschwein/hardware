
.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/asminc/via.inc"
.include "../steckos/asminc/common.inc"
.include "../steckos/asminc/joystick.inc"

.include "../steckos/asminc/appstart.inc"

LCD_E 	= (1<<0)
LCD_RS 	= (1<<1)

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

	jsr init_lcd_4bit
	; send bytes
	ldx #$00
@l:
	lda chars,x
	beq @end
	jsr send_byte
	jsr delay
	inx
	bne @l

@end:
	jmp (retvec)


; init lcd to 4bit mode

init_lcd_4bit:
	clear_bit LCD_RS

	lda #$30
	jsr send_byte
	jsr delay

	lda #$30
	jsr send_byte
	jsr delay

	lda #$30
	jsr send_byte
	jsr delay

	lda #$20
	jsr send_byte
	jsr delay

	lda #$28
	jsr send_byte
	jsr delay

	;lda #%00001110
	;jsr send_byte
	;jsr delay

	set_bit LCD_RS
	rts

send_byte:
	phx
	tax

	lda via1porta
	and #$0f
	sta via1porta

	txa
	and #$f0
	jsr send_nibble

	lda via1porta
	and #$0f
	sta via1porta


	txa

	asl
	asl
	asl
	asl

	jsr send_nibble
	plx
	rts

send_nibble:
	ora via1porta
	;jsr hexout
	sta via1porta
	; fall through to pulse_clock

pulse_clock:
	set_bit LCD_E
	jsr delay
	clear_bit LCD_E

	rts


delay:
	phx
	ldx #$ff
loop:
	.repeat 10
	nop
	.endrepeat

	dex
	bne loop
	plx
	rts

chars:
	.byte "Hello World!3",$00
