
.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/asminc/via.inc"
.include "../steckos/asminc/common.inc"
.include "../steckos/asminc/joystick.inc"

.include "../steckos/asminc/appstart.inc"

.include "lcd.inc"



.import hexout

	appstart $1000
	joy_off

	lda #$ff
	sta via1ddra

	lda #$00
	sta via1porta

	jsr lcd_init_4bit
	jsr delay

	ldx #$00
@l:
	lda chars,x
	beq @next
	jsr lcd_send_byte
	jsr delay
	inx
	bne @l

@next:
	; set address to next row
	clear_bit LCD_RS, via1porta
	lda #$c0
	jsr lcd_send_byte
	set_bit LCD_RS, via1porta
	jsr delay_40us

	ldx #$00
@l2:
	lda chars,x
	beq @end
	jsr lcd_send_byte
	jsr delay
	inx
	bne @l2


@end:
	;jmp (retvec)
	jmp krn_upload

; init lcd to 4bit mode
lcd_init_4bit:
	clear_bit LCD_RS, via1porta

	lda #$30
	sta via1porta
	jsr pulse_clock
	jsr delay_40us

	lda #$30
	sta via1porta
	jsr pulse_clock
	jsr delay_40us

	lda #$30
	sta via1porta
	jsr pulse_clock
	jsr delay_40us

	lda #$20
	sta via1porta
	jsr pulse_clock
	jsr delay_40us

	lda #$28
	jsr lcd_send_byte
	jsr delay_40us

	lda #$0e
	jsr lcd_send_byte
	jsr delay_40us

	lda #$80
	jsr lcd_send_byte
	jsr delay_40us

	lda #$01
	jsr lcd_send_byte



	set_bit LCD_RS, via1porta
	rts

;lcd_busy_wait:
;	lda #$0f
;	sta via1ddra
;
;@l:
;
;	lda #LCD_RW|LCD_E
;	lda via1porta
;	dec via1porta
;	jsr hexout
;
;	jsr pulse_clock
;	bit #$00
;	bne @l
;
;	lda #$ff
;	sta via1ddra
;	rts


lcd_send_byte:
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
	inc via1porta
	nop
	nop
	dec via1porta

	rts

delay_40us:

	ldx #$40
@l:
			; 1cl = 125ns
	nop 	;2cl = 250ns
	nop 	;2cl = 250ns
	dex 	;2cl = 250ns
	bne @l
			;2cl = 250ns
			;      1000ns = 1us
	rts

delay:
	phy
	phx
	ldy #4
@loop2:
	ldx #250
@loop1:
	.repeat 5
	nop
	.endrepeat

	dex
	bne @loop1
	dey
	bne @loop2
	plx
	ply
	rts

chars:
	.byte "1234567812345678",$00
