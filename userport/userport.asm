
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
	jsr delay

	ldx #$00
@l:
	lda chars,x
	beq @end
	jsr send_byte
	jsr delay
	inx
	bne @l

@end:
	;jmp (retvec)
	jmp krn_upload

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
	ora via1porta
	sta via1porta
	jsr pulse_clock

	lda via1porta
	and #$0f
	sta via1porta



	txa

	asl
	asl
	asl
	asl

	ora via1porta
	sta via1porta
	jsr pulse_clock
	plx
	rts

pulse_clock:
	jsr small_delay
	inc via1porta
	jsr small_delay
	dec via1porta
	jsr small_delay

	rts

small_delay:
	phx
	ldx #100
@l:
	nop
	dex
	bne @l
	plx
	rts

delay:
	phx
	ldx #$50
loop:
	.repeat 10
	nop
	.endrepeat

	dex
	bne loop
	plx
	rts

chars:
	.byte "was anderes!",$00
